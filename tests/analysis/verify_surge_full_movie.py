"""Independent full-movie pixels, new native masks, fits and correspondence."""
import argparse
import json
from pathlib import Path
import h5py
import numpy as np
from PIL import Image
from verify_surge_separation import rows,sha,require,read_pixels
from verify_surge_onset_trace_panel import compare,write_csv
from verify_surge_model_selection import unseen,select
from verify_surge_local_onset import estimate
from verify_surge_pulse_onset import fit_batch
from verify_surge_expanded_peak import expand


def recipe(h,w,n,pixel,eligible=None):
    radius=85.5/pixel;d=int(np.floor(radius+.5));k=int(np.ceil(radius))
    yy,xx=np.mgrid[-k:k+1,-k:k+1];disk=(xx*xx+yy*yy<=radius*radius)
    if eligible is not None:
        shape=(h+2*k,w+2*k)
        convolution=np.fft.irfftn(np.fft.rfftn(eligible,s=shape,axes=(0,1))*np.fft.rfftn(disk,s=shape,axes=(0,1)),s=shape,axes=(0,1))
        coverage=np.rint(convolution[k:k+h,k:k+w])/np.count_nonzero(disk)
        y,x=np.mgrid[1:h+1,1:w+1];neighbor=np.zeros((h,w));neighbor[:,:w-d]=coverage[:,d:]
        valid=(x-radius>=1)&(x+d+radius<=w)&(y-radius>=1)&(y+radius<=h)&(coverage>=.95)&(neighbor>=.95)
        distance=(x-(w+1)/2)**2+(y-(h+1)/2)**2;distance[~valid]=np.inf
        index=int(np.argmin(distance.reshape(-1,order='F')));row,col=np.unravel_index(index,(h,w),order='F')
        require(np.isfinite(distance[row,col]),'No eligible challenge position')
        centers=np.array([[col+1,row+1],[col+1+d,row+1]])
    else:centers=None
    fractions=np.array([.2*sign*unseen(n,onset,rise,shape)[0] for onset,rise,shape,sign in
        [(101,7,'quadratic',1),(201,23,'gamma',1),(401,7,'quadratic',1),(409,7,'quadratic',1),(501,7,'quadratic',1),(509,7,'quadratic',-1)]])
    return centers,fractions


def verify_record(rec):
    rec=Path(rec);out=rec/'candidate-measurement';m=json.loads((rec/'challenge-manifest.json').read_text());p=json.loads((out/'provenance.json').read_text())
    for pathkey,hashkey in [('SourceTiff','SourceSHA256'),('ConstructedTiff','ConstructedSHA256'),('SurgeMat','SurgeMatSHA256'),('SinkMat','SinkMatSHA256')]:
        require(sha(p[pathkey])==p[hashkey],'Changed recording input/output '+pathkey)
    require(sha(out/'measurement-inputs.mat')==p['MeasurementCacheSHA256'],'Changed cache')
    meta=rows(out/'events.csv');measured=rows(out/'measurements.csv');pairrows=rows(out/'event-component-pairs.csv');truthrows=rows(out/'component-summary.csv')
    h,w,n=p['Height'],p['Width'],p['Frames'];expected_frames={'M400-01-baseline-awake':600,'FB2316-baseline':1200}
    require(n==expected_frames[m['SourceProfile']['Session']] and h==w==512 and m['SourceProfile']['SampleHz']==1,'Recording dimensions/profile')
    with h5py.File(out/'measurement-inputs.mat') as f:
        native=f['NativePixels'][()].T;refs=f['Pixels'][()].ravel();allrefs=f['AllDetectedPixels'][()].ravel()
        px=[read_pixels(f,f[r]) for r in refs];npix=[[read_pixels(f,f[r]) for r in row] for row in native]
        blocked_px=[read_pixels(f,f[r]) for r in allrefs]
        xx=f['XTrace'][()].T;yy=f['YTrace'][()].T;components=f['ComponentTrace'][()].transpose(2,1,0)
        tpx=[read_pixels(f,f[r]) for r in f['TruthPixels'][()].ravel()]
        eligible_s=read_pixels(f,f['EligiblePixelsSurge']);eligible_k=read_pixels(f,f['EligiblePixelsSink'])
        require(len(px)==len(meta)==p['SurgeEvents']+p['SinkEvents'],'Event count')
        for e,row in enumerate(meta):
            a,b=int(row['NativeStartFrame']),int(row['NativeEndFrame'])
            require(np.array_equal(px[e],np.unique(np.concatenate(npix[e][a-1:b]))),'Fixed support union')
            require(all(len(v)>0 for v in npix[e][a-1:b]),'Native holes')
            require(sum(len(v) for v in npix[e])==int(row['NativeVolume']),'Native volume')
            require(all(not len(v) for v in npix[e][:a-1]+npix[e][b:]),'Pixels outside native interval')
        for frame in range(n):
            union=np.unique(np.concatenate([v[frame] for v in npix])) if npix else np.array([],int)
            require(np.array_equal(union,blocked_px[frame]),'Both-sign union masks')
        control=rec.parent/'control'/'candidate-measurement'/'measurement-inputs.mat'
        with h5py.File(control) as cf:
            es=read_pixels(cf,cf['EligiblePixelsSurge']);ek=read_pixels(cf,cf['EligiblePixelsSink'])
            eligible=np.zeros(h*w);eligible[np.intersect1d(es,ek)]=1;eligible=eligible.reshape((h,w),order='F')
        centers,fractions=recipe(h,w,n,m['SourceProfile']['PixelSize'],eligible)
        require(np.array_equal(centers,np.array(m['Recipe']['CentersXY'])),'Placement differs from control-only rule')
        y,x=np.mgrid[1:h+1,1:w+1];radius=85.5/m['SourceProfile']['PixelSize'];masks=[]
        for j in (0,0,0,1,0,1):
            mask=((x-centers[j,0])**2+(y-centers[j,1])**2<=radius*radius)
            masks.append(mask)
        for j,mask in enumerate(masks):require(np.array_equal(np.flatnonzero(mask.reshape(-1,order='F')),tpx[j]),'Truth geometry')
        require(np.allclose(f['Fractions'][()].T,fractions,atol=1e-14,rtol=1e-12),'Prescribed waveforms')
        applied=fractions if m['Case']=='challenge' else fractions*0
        require(np.allclose(f['AppliedFractions'][()].T,applied,atol=1e-14),'Applied/control fractions')
        overlaps=[[np.intersect1d(pixels,q) for q in tpx] for pixels in px]
        max_round=0
        with Image.open(p['SourceTiff']) as source,Image.open(p['ConstructedTiff']) as movie:
            require(source.n_frames==movie.n_frames==n,'Movie frame counts')
            for frame in range(n):
                source.seek(frame);movie.seek(frame);a=np.asarray(source,dtype=float);b=np.asarray(movie)
                factor=np.ones((h,w))
                for q in range(6):factor[masks[q]]+=applied[q,frame]
                latent=a*factor;require(np.all((latent>=0)&(latent<=65535)),'Clipping')
                expected=np.floor(latent+.5).astype(np.uint16)
                require(np.array_equal(expected,b),'Constructed movie pixels')
                max_round=max(max_round,float(np.max(abs(expected.astype(float)-latent))))
                af=a.reshape(-1,order='F');bf=b.reshape(-1,order='F')
                for e,pixels in enumerate(px):
                    require(np.isclose(np.mean(af[pixels]),xx[e,frame],atol=1e-10,rtol=1e-12),'Source support mean')
                    require(np.isclose(np.mean(bf[pixels],dtype=float),yy[e,frame],atol=1e-10,rtol=1e-12),'Observed support mean')
                    comp=np.array([np.sum(af[ip])/len(pixels)*applied[q,frame] for q,ip in enumerate(overlaps[e])])
                    require(np.allclose(comp,components[e,frame,:],atol=1e-10,rtol=1e-12),'Component contributions')
        require(np.isclose(max_round,m['MaxRoundingError'],atol=1e-10),'Rounding receipt')
        measurements={int(r['EventIndex']):r for r in measured};reconstructed={};decomposed=0
        for e,row in enumerate(meta):
            if row['EventType']!='surge':continue
            start,end=int(row['NativeStartFrame']),int(row['NativeEndFrame']);mask=np.zeros(n,bool)
            for frame in range(max(0,start-61),start-1):mask[frame]=np.intersect1d(px[e],blocked_px[frame]).size>0
            a=estimate(yy[e],start,end,mask,'available');b=fit_batch(yy[e:e+1],start,end,mask)[0];c=select(a,b)
            r=expand(yy[e],start,end,c['OnsetFrame'],c['Status'],mask)
            r.update(EventIndex=e+1,OnsetStatus=c['Status'],SelectedModel=c['SelectedModel'],OnsetFrame=c['OnsetFrame'],
                RisingScore=c['RisingScore'],PulseScore=c['PulseScore'],SelectedScore=c['SelectedScore'],FitStartFrame=c['FitStartFrame'],FitEndFrame=c['FitEndFrame'])
            r.update(dict.fromkeys(('OraclePositiveReferenceFraction','OracleNegativeReferenceFraction','OracleSourceAtPeak','OraclePositiveAtPeak',
                'OracleNegativeAtPeak','OracleRoundingAtPeak','OracleReferenceEffect','DecompositionResidual'),np.nan));r['StrongestPositiveComponentAtPeak']=0
            if r['ExpandedArithmeticValid'] and m['Case']=='challenge':
                pre=slice(int(r['ReferenceStartFrame'])-1,int(r['ReferenceEndFrame']));peak=int(r['ExpandedPeakFrame'])-1
                pos=np.maximum(components[e],0).sum(axis=1);neg=np.minimum(components[e],0).sum(axis=1)
                bx=np.mean(xx[e,pre]);by=np.mean(yy[e,pre]);rounding=yy[e,peak]-xx[e,peak]-pos[peak]-neg[peak]
                terms=[(xx[e,peak]-bx)/bx,pos[peak]/bx,neg[peak]/bx,rounding/bx,yy[e,peak]*(bx-by)/(bx*by)]
                r.update(OraclePositiveReferenceFraction=np.mean(pos[pre])/bx,OracleNegativeReferenceFraction=np.mean(neg[pre])/bx,
                    **dict(zip(('OracleSourceAtPeak','OraclePositiveAtPeak','OracleNegativeAtPeak','OracleRoundingAtPeak','OracleReferenceEffect'),terms)),
                    DecompositionResidual=r['ExpandedSignedAmplitude']-sum(terms))
                require(abs(r['DecompositionResidual'])<1e-10,'Decomposition identity')
                if max(components[e,peak])>0:r['StrongestPositiveComponentAtPeak']=int(np.argmax(components[e,peak]))+1
                decomposed+=1
            compare(measurements[e+1],r);reconstructed[e+1]=r
        require(len(measured)==p['SurgeEvents'],'Candidate scope')
        production=rows(rec/'production-amplitude-audit.csv')
        lookup={(r['EventType'],int(r['EventRow'])):e for e,r in enumerate(meta)}
        require(len(production)==len(meta),'Production audit scope')
        for row in production:
            e=lookup[row['EventType'],int(row['EventRow'])];a,b=int(row['StartFrame']),int(row['EndFrame'])
            pre=np.arange(max(0,a-21),a-1);overlap=np.array([np.intersect1d(px[e],blocked_px[t]).size>0 for t in pre],bool)
            clean=pre[~overlap&np.isfinite(yy[e,pre])];baseline=np.nan;amplitude=np.nan;status='insufficient_clean_prebaseline'
            if len(clean)==20:
                baseline=float(np.mean(yy[e,clean]))
                if baseline>0 and np.isfinite(baseline) and np.all(np.isfinite(yy[e,a-1:b])):
                    delta=(yy[e,a-1:b]-baseline)/baseline
                    amplitude=float(-min(delta) if row['EventType']=='sink' else max(delta));status='valid'
                else:status='nonpositive_baseline_or_missing_event_signal'
            compare(row,dict(FootprintPixels=len(px[e]),BaselineWindowFrames=20,CleanBaselineFrames=len(clean),
                TruncatedBaseline=len(pre)<20,OverlapExcludedFrames=int(sum(overlap)),NonfiniteBaselineFrames=int(sum(~np.isfinite(yy[e,pre]))),
                RecomputedBaseline=baseline,StoredBaseline=baseline,RecomputedAmplitude=amplitude,StoredAmplitude=amplitude,
                RecomputedStatus=status,StoredStatus=status,MeasurementMatches=True,WrongDirection=bool(np.isfinite(amplitude) and amplitude<0)))
        pairs={};require(len(pairrows)==6*len(meta),'Pair coverage')
        for row in pairrows:
            e,q=int(row['EventIndex'])-1,int(row['Component'])-1;frames=np.flatnonzero(fractions[q]!=0)
            inter=sum(np.intersect1d(npix[e][frame],tpx[q]).size for frame in frames);volume=len(tpx[q])*len(frames)
            same=(meta[e]['EventType']=='surge')==(q!=5);iou=inter/(int(meta[e]['NativeVolume'])+volume-inter)
            compare(row,dict(EventIndex=e+1,Component=q+1,SameSign=same,Intersection=inter,TruthVolume=volume,IoU=iou));pairs[e+1,q+1]=(same,inter,iou)
        rank=sorted([(iou,q,e) for (e,q),(same,inter,iou) in pairs.items() if same and inter>0],key=lambda v:(-v[0],v[1],v[2]))
        assignments={};used=set()
        for iou,q,e in rank:
            if q not in assignments and e not in used:assignments[q]=e;used.add(e)
        require(len(truthrows)==6,'Component coverage')
        blockers=[]
        for row in truthrows:
            q=int(row['Component']);frames=np.flatnonzero(fractions[q-1]!=0);e=assignments.get(q,0)
            t=dict(Component=q,Imposed=m['Case']=='challenge',TruthStartFrame=int(frames[0])+1,TruthEndFrame=int(frames[-1])+1,
                EligibleFraction=float(np.mean(np.isin(tpx[q-1],eligible_s if q!=6 else eligible_k))),
                IntersectingSameSignEvents=sum(same and inter>0 for (ei,qi),(same,inter,iou) in pairs.items() if qi==q),
                AssignedEventIndex=e,AssignedIoU=pairs[e,q][2] if e else 0,
                AssignedEventIntersectsComponents=sum(inter>0 for (ei,qi),(same,inter,iou) in pairs.items() if ei==e) if e else 0,
                OnsetStatus='no_assigned_surge',ExpandedStatus='no_assigned_surge',OnsetErrorSec=np.nan,
                NativeEnvelopeFraction=np.nan,ExpandedEnvelopeFraction=np.nan,AssignedComponentStrongestAtPeak=False)
            if e and meta[e-1]['EventType']=='surge':
                a=reconstructed[e];t.update(OnsetStatus=a['OnsetStatus'],ExpandedStatus=a['ExpandedStatus'])
                if t['Imposed'] and a['OnsetStatus']=='resolved':t['OnsetErrorSec']=a['OnsetFrame']-(frames[0]+1)
                if t['Imposed'] and a['ArithmeticValid']:t['NativeEnvelopeFraction']=abs(fractions[q-1,int(a['NativePeakFrame'])-1])/max(abs(fractions[q-1]))
                if t['Imposed'] and a['ExpandedArithmeticValid']:
                    t.update(ExpandedEnvelopeFraction=abs(fractions[q-1,int(a['ExpandedPeakFrame'])-1])/max(abs(fractions[q-1])),
                        AssignedComponentStrongestAtPeak=a['StrongestPositiveComponentAtPeak']==q)
            elif e:t.update(OnsetStatus='sink_measurement_not_evaluated',ExpandedStatus='sink_measurement_not_evaluated')
            compare(row,t)
            if e and meta[e-1]['EventType']=='surge':
                start=int(meta[e-1]['NativeStartFrame'])
                blocked=[f for f in range(max(0,start-61),start-1) if np.intersect1d(px[e-1],blocked_px[f]).size]
                if blocked:
                    last=blocked[-1]
                    for other in range(len(meta)):
                        intersection=np.intersect1d(px[e-1],npix[other][last]).size
                        if intersection:
                            blockers.append(dict(Component=q,AssignedEventIndex=e,OnsetStatus=t['OnsetStatus'],Imposed=t['Imposed'],
                                NativeStartFrame=start,LatestBlockedFrame=last+1,ContiguousPreNativeFrames=start-last-2,
                                BlockerEventIndex=other+1,BlockerEventType=meta[other]['EventType'],
                                BlockerNativeStartFrame=int(meta[other]['NativeStartFrame']),BlockerNativeEndFrame=int(meta[other]['NativeEndFrame']),
                                SharedPixelsAtLatestBlock=intersection,BlockerIntersectsComponent=pairs[other+1,q][1]>0,
                                LatestBlockWithinComponentWindow=bool(fractions[q-1,last]!=0)))
        if blockers:write_csv(out/'context-blockers.csv',blockers)
    return dict(Session=m['SourceProfile']['Session'],Case=m['Case'],MoviePixelsVerified=h*w*n,SupportFramePairsVerified=len(meta)*n,
        ComponentFitsVerified=2*p['SurgeEvents'],CandidateMeasurementsVerified=p['SurgeEvents'],DecompositionsVerified=decomposed,
        EventComponentPairsVerified=len(pairrows),ComponentSummariesVerified=6,ProductionAmplitudesVerified=len(production))


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('root');a=parser.parse_args();root=Path(a.root)
    result=[]
    for session in ('M400-01-baseline-awake','FB2316-baseline'):
        for case in ('control','challenge'):
            result.append(verify_record(root/session/case));print('VERIFIED FULL MOVIE',session,case,flush=True)
    write_csv(root/'independent-recording-verification.csv',result)
    inputs=rows(root/'input-manifest.csv');require(len(inputs)==4,'Original input coverage')
    for r in inputs:require(sha(r['Path'])==r['SHA256'],'Source changed')
    (root/'independent-verification.json').write_text(json.dumps(dict(RecordingsVerified=len(result),
        MoviePixelsVerified=sum(r['MoviePixelsVerified'] for r in result),SupportFramePairsVerified=sum(r['SupportFramePairsVerified'] for r in result),
        ComponentFitsVerified=sum(r['ComponentFitsVerified'] for r in result),ProductionChanged=False),indent=2)+'\n')
