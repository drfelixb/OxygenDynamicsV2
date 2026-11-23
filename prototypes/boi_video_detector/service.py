"""Experimental spatial/temporal proposal service, separate from measurement.

Inputs are source-bound block means, N x row x column. Coordinates in outputs
are one-based recording frames; comparison masks remain fixed in image space.
No function calculates scientific amplitude, accepted area or hypoxic burden.
"""
from __future__ import annotations
from dataclasses import dataclass, asdict, replace
import hashlib
import warnings
import numpy as np
from scipy import ndimage

SCHEMA='boi-video-proposal-0.1'


@dataclass(frozen=True)
class Settings:
    block_pixels:int=4
    spatial_sigma_blocks:tuple=(0.,1.,2.)
    preceding_seconds:tuple=(30.,90.)
    current_seconds:float=5.
    preceding_gap_seconds:float=5.
    minimum_context_seconds:float=10.
    reference_context_seconds:float=20.
    onset_lookback_seconds:float=30.
    recovery_hold_seconds:float=5.
    threshold:float=4.
    surrounding_sigma_blocks:float=6.
    minimum_component_blocks:int=4
    minimum_assessment_samples:int=3
    overlap_fraction:float=.20
    maximum_link_gap_frames:int=1
    distance_fallback_blocks:float=2.
    context_near_blocks:tuple=(6.,20.)
    context_far_blocks:float=38.
    observed_strength:float=4.
    remaining_deficit_fraction:float=.25
    motion_shift_blocks:float=1.5
    motion_peak_ratio:float=1.01
    motion_correlation_min:float=.8

    def frame_count(self,seconds,fs):return max(1,int(round(seconds*fs)))
    def sensitivity(self):return replace(self,threshold=3.)
    def contract(self):return asdict(self)


def mad(a,axis=0):
    with warnings.catch_warnings():
        warnings.simplefilter('ignore',RuntimeWarning)
        if axis==0 and a.ndim>=2:
            # Column chunks preserve each exact time series and median operation.
            # Avoid full-volume temporary masks/sorts inside nanmedian.
            flat=a.reshape(a.shape[0],-1);out=np.empty(flat.shape[1],dtype=a.dtype)
            for start in range(0,flat.shape[1],256):
                x=flat[:,start:start+256];m=np.nanmedian(x,axis=0,keepdims=True)
                out[start:start+256]=np.nanmedian(np.abs(x-m),axis=0)*1.4826
            return out.reshape(a.shape[1:])
        m=np.nanmedian(a,axis=axis,keepdims=True)
        return np.nanmedian(np.abs(a-m),axis=axis)*1.4826


def noise_of(a):
    out=mad(np.diff(a,axis=0),axis=0)/np.sqrt(2.)
    finite=out[np.isfinite(out)&(out>0)]
    floor=max(float(np.median(finite))*.1,1e-6) if finite.size else 1e-6
    return np.maximum(np.nan_to_num(out,nan=floor),floor).astype(np.float32)


def observation_domain(raw):
    with warnings.catch_warnings():
        warnings.simplefilter('ignore',RuntimeWarning)
        level=np.nanmedian(raw,axis=0)
    noise=noise_of(raw);finite=np.mean(np.isfinite(raw),axis=0)
    q10,q99=np.nanpercentile(level,[10,99]);typical=float(np.median(noise[np.isfinite(level)]))
    dark_reference=float(q10) if q99-q10>10*typical else 0.
    cutoff=dark_reference+6*typical
    domain=(level>cutoff)&(finite>=.9)
    return domain,noise,{'DomainMethod':'raw_median_signal_above_empirical_dark_plus6noise; finite_fraction>=0.9',
                         'DarkReferenceInputUnits':dark_reference,'CutoffInputUnits':cutoff,
                         'EligibleBlocks':int(domain.sum()),'TotalBlocks':int(domain.size),
                         'Qualification':'experimental observability domain, not anatomical tissue or normalization support'}


def spatial_mean(movie,domain,sigma):
    valid=np.isfinite(movie)&domain[None]
    if sigma==0:return np.where(valid,movie,np.nan).astype(np.float32)
    num=ndimage.gaussian_filter(np.where(valid,movie,0).astype(np.float32),(0,sigma,sigma),mode='nearest')
    if np.all(valid==domain[None]):
        weight=ndimage.gaussian_filter(domain.astype(np.float32),sigma,mode='nearest')[None]
    else:
        weight=ndimage.gaussian_filter(valid.astype(np.float32),(0,sigma,sigma),mode='nearest')
    result=np.divide(num,weight,out=np.full_like(num,np.nan),where=weight>1e-6)
    result[~valid]=np.nan
    return result


def temporal_mean(movie,size):
    valid=np.isfinite(movie)
    num=ndimage.uniform_filter1d(np.where(valid,movie,0).astype(np.float32),size,axis=0,mode='nearest')
    den=ndimage.uniform_filter1d(valid.astype(np.float32),size,axis=0,mode='nearest')
    return np.divide(num,den,out=np.full_like(num,np.nan),where=den>.5)


def preceding_mean(movie,length,gap,minimum):
    n,h,w=movie.shape;valid=np.isfinite(movie)
    total=np.zeros((n+1,h,w),np.float64)
    np.cumsum(np.where(valid,movie,0),axis=0,dtype=np.float64,out=total[1:])
    count=np.zeros((n+1,h,w),np.uint32)
    np.cumsum(valid,axis=0,dtype=np.uint32,out=count[1:])
    result=np.full(movie.shape,np.nan,np.float32);sizes=np.zeros(n,np.int32)
    for t in range(n):
        hi=max(0,t-gap);lo=max(0,hi-length);sizes[t]=hi-lo
        c=count[hi]-count[lo]
        np.divide(total[hi]-total[lo],c,out=result[t],where=c>=minimum)
    return result,sizes


def global_motion(raw,domain,S):
    n,h,w=raw.shape;window=np.outer(np.hanning(h),np.hanning(w))*domain
    shifts=np.zeros((n,2),np.float32);ratios=np.zeros(n,np.float32)
    previous=None;previous_power=0.
    for t in range(n):
        a=np.nan_to_num(raw[t]).astype(np.float64)
        a=(ndimage.gaussian_filter(a,1.5)-ndimage.gaussian_filter(a,8))*window
        ft=np.fft.fft2(a)
        if previous is not None:
            corr=np.fft.fftshift(np.fft.ifft2(ft*np.conj(previous)).real)
            cy,cx=h//2,w//2;radius=min(10,cy,cx)
            small=corr[cy-radius:cy+radius+1,cx-radius:cx+radius+1]
            peak=np.unravel_index(np.argmax(small),small.shape);shift=np.array(peak,dtype=float)-radius
            value=float(small[peak]);zero=float(corr[cy,cx]);correlation=value/max(np.sqrt(np.sum(a*a)*previous_power),1e-12)
            shifts[t]=shift;ratios[t]=value/max(zero,1e-12) if correlation>=S.motion_correlation_min else 0.
        previous=ft;previous_power=float(np.sum(a*a))
    flags=(np.linalg.norm(shifts,axis=1)>S.motion_shift_blocks)&(ratios>S.motion_peak_ratio)
    return shifts,ratios,flags


def build_evidence(raw,denoised,fs=1.,settings=None):
    S=settings or Settings()
    assert raw.ndim==3 and raw.shape==denoised.shape and fs>0
    domain,raw_noise,quality=observation_domain(raw)
    assert domain.any(),'No observable domain; do not fabricate a zero-event result'
    n,h,w=raw.shape;k=S.frame_count(S.current_seconds,fs)
    gap=S.frame_count(S.preceding_gap_seconds,fs);minimum=S.frame_count(S.minimum_context_seconds,fs)
    absolute=np.full(raw.shape,-np.inf,np.float32);local=np.full(raw.shape,-np.inf,np.float32)
    for movie in [raw,denoised]:
        for sigma in S.spatial_sigma_blocks:
            smoothed=spatial_mean(movie,domain,sigma)
            current=temporal_mean(smoothed,k)
            for seconds in S.preceding_seconds:
                length=S.frame_count(seconds,fs)
                reference,count=preceding_mean(smoothed,length,gap,minimum)
                difference=np.divide(reference-current,reference,out=np.full_like(reference,np.nan),where=reference>1e-6)
                # Estimate the actual smoothed contrast variation, preserving temporal correlation.
                sigma_absolute=mad(difference,axis=0)
                good=sigma_absolute[np.isfinite(sigma_absolute)&(sigma_absolute>0)]
                floor=max(float(np.median(good))*.1,1e-6) if good.size else 1e-6
                sigma_absolute=np.maximum(np.nan_to_num(sigma_absolute,nan=floor),floor)
                z=difference/sigma_absolute
                np.fmax(absolute,z,out=absolute)
                surrounding=spatial_mean(difference,domain,S.surrounding_sigma_blocks)
                differential=difference-surrounding
                sigma_local=mad(differential,axis=0)
                good=sigma_local[np.isfinite(sigma_local)&(sigma_local>0)]
                floor_local=max(float(np.median(good))*.1,1e-6) if good.size else 1e-6
                sigma_local=np.maximum(np.nan_to_num(sigma_local,nan=floor_local),floor_local)
                np.fmax(local,differential/sigma_local,out=local)
                # Initial low states are explicitly left-censored, not closed episodes.
                for t in range(min(n,gap+minimum)):
                    lo=t+gap;hi=min(n,lo+length)
                    if hi-lo<minimum:continue
                    with warnings.catch_warnings():
                        warnings.simplefilter('ignore',RuntimeWarning)
                        future=np.nanmean(smoothed[lo:hi],axis=0)
                    initial=np.divide(future-current[t],future,out=np.full_like(future,np.nan),where=future>1e-6)
                    np.fmax(absolute[t],initial/sigma_absolute,out=absolute[t])
                    valid=np.isfinite(initial)&domain;values=np.where(valid,initial,0.)
                    wt=ndimage.gaussian_filter(valid.astype(float),S.surrounding_sigma_blocks)
                    around=np.divide(ndimage.gaussian_filter(values,S.surrounding_sigma_blocks),wt,out=np.full_like(values,np.nan),where=wt>1e-6)
                    np.fmax(local[t],(initial-around)/sigma_local,out=local[t])
                del reference,z,difference,surrounding,differential,sigma_absolute,sigma_local
            del smoothed,current
    invalid=~np.isfinite(raw)|~domain[None]
    absolute[invalid]=-np.inf;local[invalid]=-np.inf
    shifts,ratios,motion=global_motion(raw,domain,S)
    return {'AbsoluteZ':absolute,'LocalZ':local,'Domain':domain,'RawNoise':raw_noise,
            'Quality':quality,'GlobalShiftBlocks':shifts,'GlobalMotionPeakRatio':ratios,'MotionFlag':motion,
            'SourceSampleHz':float(fs),'Settings':S.contract(),'ProposalSources':['raw','provided_denoised'],
            'ContrastNoiseMethod':'empirical temporal MAD of the actual smoothed preceding-current contrast; not white-noise SE'}


def overlap_edges(previous,current,current_sizes,tracks,frame,gap,S):
    ids,inverse=np.unique(previous,return_inverse=True);inverse=inverse.ravel();m=len(current_sizes)-1
    if not m:return []
    joint=np.bincount(inverse*(m+1)+current.ravel(),minlength=len(ids)*(m+1)).reshape(len(ids),m+1)
    prev_sizes=np.bincount(inverse,minlength=len(ids));edges=[]
    for i,j in zip(*np.nonzero(joint[:,1:])):
        j+=1;pid=int(ids[i])
        if pid==0 or tracks[pid]['frames'][-1]!=frame-gap:continue
        score=float(joint[i,j]/min(prev_sizes[i],current_sizes[j]))
        if score>=S.overlap_fraction:edges.append((score-.03*(gap-1),pid,int(j),gap,int(joint[i,j]),score))
    return edges


def track_regions(evidence,S,channel):
    z=evidence['AbsoluteZ'] if channel=='absolute' else evidence['LocalZ'];n,h,w=z.shape
    maps=np.zeros((n,h,w),np.int32);tracks={};contacts=[];coverage=[];next_id=1
    for f in range(n):
        eligible=evidence['Domain']&np.isfinite(z[f]);binary=eligible&(z[f]>=S.threshold)
        components,ncomp=ndimage.label(binary,structure=np.ones((3,3)))
        size=np.bincount(components.ravel());kept=np.flatnonzero(size>=S.minimum_component_blocks);kept=kept[kept>0]
        remap=np.zeros(ncomp+1,np.int32);remap[kept]=np.arange(1,len(kept)+1);current=remap[components]
        sizes=np.bincount(current.ravel(),minlength=len(kept)+1)
        centres={j:np.mean(np.argwhere(current==j),axis=0) for j in range(1,len(kept)+1)}
        edges=[]
        for gap in range(1,S.maximum_link_gap_frames+2):
            if f>=gap:edges+=overlap_edges(maps[f-gap],current,sizes,tracks,f,gap,S)
        edges.sort(key=lambda x:(-x[0],x[3],x[1],x[2]))
        assignment={};used=set()
        for edge in edges:
            score,pid,cid,gap,intersection,fraction=edge
            if pid not in used and cid not in assignment:assignment[cid]=(pid,gap,'overlap',fraction);used.add(pid)
        # Conservative local displacement fallback; all such links stay visible.
        available=[pid for pid,T in tracks.items() if 1<=f-T['frames'][-1]<=S.maximum_link_gap_frames+1 and pid not in used]
        fallback=[]
        for cid in centres:
            if cid in assignment:continue
            for pid in available:
                T=tracks[pid];distance=float(np.linalg.norm(centres[cid]-T['centroids'][-1]));ratio=sizes[cid]/T['areas'][-1]
                if distance<=S.distance_fallback_blocks and .25<=ratio<=4:fallback.append((distance,pid,cid))
        for distance,pid,cid in sorted(fallback):
            if pid in used or cid in assignment:continue
            gap=f-tracks[pid]['frames'][-1];assignment[cid]=(pid,gap,'displacement',0.);used.add(pid)
        parent_children={};child_parents={}
        for edge in edges:
            _,pid,cid,gap,intersection,fraction=edge
            parent_children.setdefault(pid,set()).add(cid);child_parents.setdefault(cid,set()).add(pid)
        lookup=np.zeros(len(kept)+1,np.int32)
        for cid in centres:
            if cid in assignment:pid,gap,method,fraction=assignment[cid]
            else:
                pid=next_id;next_id+=1;gap=0;method='new';fraction=1.
                tracks[pid]={'frames':[],'areas':[],'centroids':[],'GapLinks':0,'DisplacementLinks':0,'SplitContacts':0,'MergeContacts':0,'MinOverlap':1.}
            T=tracks[pid];T['frames'].append(f);T['areas'].append(int(sizes[cid]));T['centroids'].append(centres[cid])
            T['GapLinks']+=int(gap>1);T['DisplacementLinks']+=int(method=='displacement');T['MinOverlap']=min(T['MinOverlap'],fraction)
            split=any(len(parent_children.get(p,set()))>1 for p in child_parents.get(cid,set()))
            merge=len(child_parents.get(cid,set()))>1;T['SplitContacts']+=int(split);T['MergeContacts']+=int(merge)
            if split or merge or gap>1 or method=='displacement':
                contacts.append({'Frame':f+1,'Track':pid,'Parents':sorted(child_parents.get(cid,set())),
                                 'Split':bool(split),'Merge':bool(merge),'GapFrames':max(0,gap-1),'Method':method})
            lookup[cid]=pid
        maps[f]=lookup[current]
        coverage.append([int(eligible.sum()),int(binary.sum()),ncomp,len(kept),int((binary&(current==0)).sum()),int(np.max(z[f][eligible])) if eligible.any() else 0])
    return maps,tracks,contacts,np.asarray(coverage,np.int32)


def mean_trace(raw,mask):
    if not mask.any():return np.full(raw.shape[0],np.nan)
    # Missing pixels invalidate the matched-cohort observation; never shrink it silently.
    return np.mean(raw[:,mask],axis=1,dtype=np.float64)


def native_indices(coarse_indices,coarse_shape,block_pixels=4):
    """One-based MATLAB column-major native indices for whole coarse blocks."""
    row,col=np.unravel_index(np.asarray(coarse_indices,dtype=int),coarse_shape)
    dr,dc=np.meshgrid(np.arange(block_pixels),np.arange(block_pixels),indexing='ij')
    rr=row[:,None]*block_pixels+dr.ravel()[None]
    cc=col[:,None]*block_pixels+dc.ravel()[None]
    return np.unique((rr+cc*(coarse_shape[0]*block_pixels)+1).ravel()).astype(np.uint32)


def smooth_trace(x,size=3):
    finite=np.isfinite(x);a=ndimage.uniform_filter1d(np.where(finite,x,0.),size,mode='nearest')
    b=ndimage.uniform_filter1d(finite.astype(float),size,mode='nearest')
    return np.divide(a,b,out=np.full_like(a,np.nan),where=b>.5)


def scalar_noise(x):
    d=np.diff(x);v=d[np.isfinite(d)]
    return max(float(np.median(np.abs(v-np.median(v)))*1.4826/np.sqrt(2)),1e-6) if len(v) else np.nan


def assess_episode(raw,domain,mask,first,last,fs,S,motion=None,tracking=None):
    """Observed matched-pixel phases. No changing-mask mean enters this decision."""
    n=raw.shape[0];tracking=tracking or {};motion=np.zeros(n,bool) if motion is None else motion
    x=mean_trace(raw,mask);distance=ndimage.distance_transform_edt(~mask)
    near=domain&(distance>=S.context_near_blocks[0])&(distance<=S.context_near_blocks[1])
    far=domain&(distance>=S.context_far_blocks)
    y=mean_trace(raw,near);z=mean_trace(raw,far);field=mean_trace(raw,domain)
    gap=S.frame_count(S.preceding_gap_seconds,fs);width=S.frame_count(S.reference_context_seconds,fs)
    p1=max(0,first-gap);p0=max(0,p1-width);minimum=S.frame_count(S.minimum_context_seconds,fs)
    result={'SpatialFirstFrame':first+1,'SpatialLastFrame':last+1,'PrecedingContextFrames':([p0+1,p1] if p1>p0 else None),
            'ComparisonFootprintBlocks':int(mask.sum()),'ContextNearBlocks':int(near.sum()),'ContextFarBlocks':int(far.sum()),
            'PrecedingContextIsMeasurementBaseline':False,'MeasurementReady':False,'ScientificAreaAvailable':False,
            'ScientificBurdenAvailable':False,'Status':'uncertain','Flags':[],'RecoveryFrameRange':None,'OnsetFrameRange':None}
    traces={'Raw':x,'Near':y,'Far':z,'Field':field,'Contrast':np.full(n,np.nan)}
    if p1-p0<minimum or not np.all(np.isfinite(x[p0:p1])):
        result['Status']='incomplete_preceding_state';return result,traces
    bx=float(np.mean(x[p0:p1]));by=float(np.mean(y[p0:p1]));bz=float(np.mean(z[p0:p1]))
    if not bx>0:result['Status']='uncertain_invalid_preceding_signal';return result,traces
    neighbours=[]
    if by>0 and np.isfinite(by):neighbours.append(y/by)
    if bz>0 and np.isfinite(bz):neighbours.append(z/bz)
    if neighbours:
        background=np.nanmean(neighbours,axis=0);contrast=100*(x/bx-background)
    else:contrast=100*(x/bx-1);result['Flags'].append('surrounding_context_unavailable')
    traces['Contrast']=contrast;sx=smooth_trace(x);sc=smooth_trace(contrast)
    lo=max(0,first-3);hi=min(n,last+4)
    if not np.any(np.isfinite(sc[lo:hi])):result['Status']='uncertain_missing_data';return result,traces
    trough=lo+int(np.nanargmin(sc[lo:hi]));pre_c=float(np.mean(contrast[p0:p1]))
    nx=scalar_noise(x);nc=scalar_noise(contrast);depth_x=bx-float(sx[trough]);depth_c=pre_c-float(sc[trough])
    nx=max(nx,1e-6);nc=max(nc,.01)
    strong_raw=depth_x>=S.observed_strength*nx;strong_local=depth_c>=S.observed_strength*nc
    support=contrast<pre_c-max(2*nc,.2*max(0,depth_c))
    left=trough;right=trough
    while left>0 and support[left-1]:left-=1
    while right<n-1 and support[right+1]:right+=1
    temporal_support=right-left+1
    tolerance_x=max(S.observed_strength*nx,S.remaining_deficit_fraction*max(0,depth_x))
    tolerance_c=max(S.observed_strength*nc,S.remaining_deficit_fraction*max(0,depth_c))
    hold=S.frame_count(S.recovery_hold_seconds,fs);recovery=None;relative_only=None
    # Search observed remaining recording, without a universal maximum event duration.
    for start in range(trough+1,n-hold+1):
        stop=start+hold
        if not np.all(np.isfinite(x[start:stop])) or not np.all(np.isfinite(contrast[start:stop])):continue
        post_x=float(np.median(x[start:stop]));post_c=float(np.median(contrast[start:stop]))
        local_return=post_c>=pre_c-tolerance_c
        rise=post_x-float(sx[trough])>=S.observed_strength*nx
        if local_return and relative_only is None:relative_only=(start,stop,post_x,post_c,rise)
        if local_return and rise:recovery=(start,stop,post_x,post_c,rise);break
    chosen=recovery or relative_only
    bound=pre_c-max(nc,.2*max(0,depth_c));lookback=S.frame_count(S.onset_lookback_seconds,fs)
    onset0=max(0,first-lookback);before=np.flatnonzero(sc[onset0:trough+1]>=bound)
    onset=min(trough,onset0+int(before[-1])+1) if len(before) else onset0
    result['OnsetFrameRange']=[max(1,onset),min(n,onset+3)]
    result.update({'TroughFrame':trough+1,'RawDeclineSupported':bool(strong_raw),'LocalContrastSupported':bool(strong_local),
                   'RawDeclineNoiseUnits':float(depth_x/nx),'LocalContrastNoiseUnits':float(depth_c/nc),
                   'RecognitionRawContextMean':bx,'RecognitionContrastContextMean':pre_c,
                   'RawNoiseInputUnits':nx,'ContrastNoisePercent':nc,'ObservedDipSupportFrames':temporal_support,
                   'MatchedFootprintSHA256':hashlib.sha256(np.packbits(mask.ravel()).tobytes()).hexdigest()})
    if chosen:
        start,stop,post_x,post_c,rise=chosen
        result['RecoveryFrameRange']=[start+1,stop];result['RawRiseSupported']=bool(rise)
        result['RawPreviousStateReturn']=bool(abs(post_x-bx)<=tolerance_x)
        result['ObservedRelativeReturn']=True
        result['ObservedPostRawMean']=post_x;result['ObservedPostContrastMean']=post_c
        if not result['RawPreviousStateReturn']:result['Flags'].append('raw_preceding_state_not_restored')
    else:
        result['RawRiseSupported']=False;result['RawPreviousStateReturn']=False;result['ObservedRelativeReturn']=False
    end=(chosen[1] if chosen else min(n,last+hold))
    phase_gap=not np.all(np.isfinite(x[p0:end]));motion_flag=bool(np.any(motion[p0:end]))
    if motion_flag:result['Flags'].append('global_motion_evidence')
    if phase_gap:result['Flags'].append('missing_observations_in_episode_context')
    if p1-p0>1:
        drift=float(np.polyfit(np.arange(p1-p0),x[p0:p1],1)[0])*(p1-p0)
        if abs(drift)>max(2*nx,.5*max(0,depth_x)):result['Flags'].append('preceding_state_changes_reference_review_needed')
    if by>0:
        near_drop=1-float(np.nanmean(y[max(0,trough-2):min(n,trough+3)]))/by
        local_drop=max(0,depth_x/bx)
        if near_drop>.5*local_drop and near_drop>.01:result['Flags'].append('nearby_tissue_also_changes')
    if tracking.get('GapLinks',0):result['Flags'].append('tracking_gap_area_unknown')
    if tracking.get('SplitContacts',0) or tracking.get('MergeContacts',0):result['Flags'].append('tracking_contact_ambiguity')
    if tracking.get('DisplacementLinks',0):result['Flags'].append('tracking_shape_displacement')
    if not neighbours:status='shared_or_context_unresolved'
    elif not strong_raw:status='uncertain_raw_decline'
    elif not strong_local:status='shared_change'
    elif temporal_support<S.frame_count(S.current_seconds,fs):status='uncertain_short_observed_support'
    elif phase_gap:status='uncertain_missing_data'
    elif motion_flag:status='uncertain_motion'
    elif recovery:
        status='local_reversible_candidate'
        if tracking.get('DisplacementLinks',0):status='local_reversible_candidate_tracking_uncertain'
    elif relative_only:status='uncertain_relative_recovery_in_changing_field'
    elif last>=n-hold:status='incomplete_recovery'
    else:status='persistent_local_or_regional_change'
    result['Status']=status
    return result,traces


def detect(raw,denoised,fs=1.,settings=None,evidence=None):
    S=settings or Settings();evidence=evidence or build_evidence(raw,denoised,fs,S)
    map_list=[];tracks={};contacts=[];coverage_list=[];offset=0
    for channel_index,channel in enumerate(['absolute','local']):
        channel_maps,channel_tracks,channel_contacts,channel_coverage=track_regions(evidence,S,channel)
        channel_maps[channel_maps>0]+=offset
        for tid,T in channel_tracks.items():T['Channel']=channel;T['ChannelIndex']=channel_index;tracks[tid+offset]=T
        for edge in channel_contacts:
            edge=dict(edge);edge['Track']+=offset;edge['Parents']=[p+offset for p in edge['Parents']];edge['Channel']=channel;contacts.append(edge)
        map_list.append(channel_maps);coverage_list.append(channel_coverage);offset+=len(channel_tracks)
    maps=np.stack(map_list);coverage=np.stack(coverage_list,axis=1)
    domain=evidence['Domain'];catalogue=[];masks={}
    for tid,T in tracks.items():
        frames=np.asarray(T['frames']);areas=np.asarray(T['areas']);nactive=len(frames)
        channel_maps=maps[T['ChannelIndex']]
        occupancy=np.sum(channel_maps[frames]==tid,axis=0)
        comparison=occupancy>=max(1,int(np.ceil(.5*nactive)))
        if not comparison.any():comparison=channel_maps[frames[int(np.argmax(areas))]]==tid
        masks[tid]=np.flatnonzero(comparison.ravel()).astype(np.uint32)
        first=int(frames[0]);last=int(frames[-1]);episode=1
        while first<=last:
            if nactive<S.minimum_assessment_samples:
                R={'Status':'insufficient_temporal_support','SpatialFirstFrame':first+1,'SpatialLastFrame':last+1,
                   'ComparisonFootprintBlocks':int(comparison.sum()),'Flags':[],'RecoveryFrameRange':None,
                   'OnsetFrameRange':None,'MeasurementReady':False,'ScientificAreaAvailable':False,'ScientificBurdenAvailable':False}
            else:R,_=assess_episode(raw,domain,comparison,first,last,fs,S,evidence['MotionFlag'],T)
            R.update({'CandidateID':f't{tid:05d}-e{episode:02d}','TrackID':tid,'EpisodeInTrack':episode,
                      'ActiveFrames':int(np.sum(frames>=first)),'MaximumExtentBlocks':int(np.max(areas)),
                      'MinimumExtentBlocks':int(np.min(areas)),'MaximumObservableDomainFraction':float(np.max(areas)/domain.sum()),
                      'ExtentGrowthRatio':float(areas[-1]/max(areas[0],1)),
                      'Tracking':{k:T[k] for k in ['GapLinks','DisplacementLinks','SplitContacts','MergeContacts','MinOverlap']},
                      'ComparisonFootprintRule':'blocks present >=half active frames; fallback largest observed mask',
                      'SignalAuthority':'raw source block means; denoised used for proposals only',
                      'Schema':SCHEMA,'SourceSampleHz':float(fs),'NativeBlockEdgePixels':S.block_pixels,
                      'ProposalChannel':T['Channel'],'ProposalSourceStages':['raw','provided_denoised']})
            catalogue.append(R)
            recovery=R.get('RecoveryFrameRange')
            if not recovery or not R['Status'].startswith('local_reversible_candidate'):break
            following=frames[frames>=recovery[1]+S.frame_count(S.recovery_hold_seconds,fs)]
            if len(following)<S.minimum_assessment_samples:break
            new_first=int(following[0])
            if new_first<=first:raise AssertionError('Episode progression must advance')
            first=new_first;episode+=1
    return {'Schema':SCHEMA,'Catalogue':catalogue,'TrackMaps':maps,'ComparisonMasks':masks,'Tracks':tracks,
            'Contacts':contacts,'Coverage':coverage,'Evidence':evidence,'Settings':S.contract()}
