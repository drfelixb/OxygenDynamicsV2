"""Finite synthetic recognition/geometry fixtures; no recording access."""
from pathlib import Path
import json,sys,time
import numpy as np
from scipy import ndimage

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'prototypes'))
from boi_video_detector.service import Settings,detect,assess_episode,native_indices


def pulse(t,centre,width):return np.maximum(0,1-np.abs(t-centre)/(width/2))


def scene(kind,seed):
    rng=np.random.default_rng(seed);n=240;h=w=64;t=np.arange(n);yy,xx=np.mgrid[:h,:w]
    texture=40*ndimage.gaussian_filter(rng.normal(size=(h,w)),2)+40*np.sin(xx/5)*np.cos(yy/7)
    raw=(1000+texture)[None]+rng.normal(0,5,(n,h,w));g=np.exp(-((yy-30)**2+(xx-28)**2)/(2*3**2))
    if kind=='localized':raw-=120*pulse(t,100,36)[:,None,None]*g
    elif kind=='shared':raw-=120*pulse(t,100,36)[:,None,None]
    elif kind=='spreading_persistent':
        for f in range(70,n):
            radius=min(12,2+(f-70)/12);a=np.exp(-((yy-30)**2+(xx-28)**2)/(2*radius**2));raw[f]-=200*a*min(1,(f-70)/20)
    elif kind=='local_with_field_drift':raw-=.4*t[:,None,None]+120*pulse(t,100,36)[:,None,None]*g
    elif kind=='weak_gradual':raw-=25*pulse(t,110,110)[:,None,None]*g
    elif kind=='recurrent_changed_state':raw-=((t>=120)*90)[:,None,None]+110*(pulse(t,65,30)+pulse(t,180,30))[:,None,None]*g
    elif kind=='recurrent_without_intervening_return':raw-=100*(pulse(t,90,80)+pulse(t,115,80))[:,None,None]*g
    elif kind=='changing_mask_bias':raw-=150*(t>=80)[:,None,None]*g
    elif kind=='split_merge':
        for f in range(75,135):
            r=2+5*pulse(f,105,60);g1=np.exp(-((yy-30)**2+(xx-24)**2)/(2*r*r));g2=np.exp(-((yy-30)**2+(xx-36)**2)/(2*r*r));raw[f]-=100*(g1+g2)
    elif kind=='vascular_gap':raw-=120*pulse(t,100,36)[:,None,None]*g;raw[:,:,29:31]=rng.normal(0,2,(n,h,2))
    elif kind=='motion':
        base=1000+150*np.sin(xx/4)*np.cos(yy/5)+30*ndimage.gaussian_filter(rng.normal(size=(h,w)),.5)
        raw=np.repeat(base[None],n,0)+rng.normal(0,3,(n,h,w));raw[90:125]=np.roll(raw[90:125],2,axis=2)
    elif kind=='noise':pass
    elif kind=='missing':raw-=120*pulse(t,100,36)[:,None,None]*g;raw[96:103,24:37,22:35]=np.nan
    elif kind=='recording_start':raw-=140*np.maximum(0,1-t/35)[:,None,None]*g
    elif kind=='recording_end':raw-=140*np.clip((t-215)/20,0,1)[:,None,None]*g
    elif kind=='sampling_coordinates':
        raw-=120*pulse(t,120,60)[:,None,None]*g
    else:raise AssertionError(kind)
    # This denoising is synthetic only; acquired denoised TIFFs are not refit.
    finite=np.isfinite(raw)
    num=ndimage.gaussian_filter(np.where(finite,raw,0).astype(np.float32),(1,.7,.7))
    den=ndimage.gaussian_filter(finite.astype(np.float32),(1,.7,.7))
    smooth=np.divide(num,den,out=np.full_like(num,np.nan),where=den>.5);smooth[~finite]=np.nan
    return raw.astype(np.float32),smooth


def run(destination):
    started=time.monotonic();S=Settings();rows=[];invariants=[]
    names=['localized','shared','spreading_persistent','local_with_field_drift','weak_gradual',
           'recurrent_changed_state','recurrent_without_intervening_return','changing_mask_bias',
           'split_merge','vascular_gap','motion','noise','missing','recording_start','recording_end','sampling_coordinates']
    for i,name in enumerate(names):
        raw,dense=scene(name,72310+i);fs=2. if name=='sampling_coordinates' else 1.
        R=detect(raw,dense,fs,S);C=R['Catalogue'];maps=R['TrackMaps']
        assert maps.shape==(2,*raw.shape) and R['Coverage'].shape==(len(raw),2,6)
        assert sum(len(T['frames']) for T in R['Tracks'].values())==int(R['Coverage'][:,:,3].sum())
        for tid,T in R['Tracks'].items():
            for f,area in zip(T['frames'],T['areas']):assert np.count_nonzero(maps[T['ChannelIndex'],f]==tid)==area
        assert all(not c['MeasurementReady'] and not c['ScientificBurdenAvailable'] for c in C)
        assert all(1<=c['SpatialFirstFrame']<=c['SpatialLastFrame']<=len(raw) for c in C)
        counts={}
        for c in C:counts[c['Status']]=counts.get(c['Status'],0)+1
        local=[c for c in C if c['Status'].startswith('local_reversible_candidate')]
        behaviour={}
        if name in ['localized','local_with_field_drift']:behaviour['local_candidate_found']=bool(local)
        if name in ['shared','spreading_persistent','changing_mask_bias','noise','motion']:behaviour['no_complete_local_candidate']=not local
        if name=='recurrent_changed_state':behaviour['more_than_one_candidate_episode']=len(local)>=2
        if name=='split_merge':behaviour['contacts_reported']=any(c.get('Split') or c.get('Merge') for c in R['Contacts'])
        if name=='missing':behaviour['missingness_retained']=any('missing' in c['Status'] or 'missing_observations_in_episode_context' in c['Flags'] for c in C)
        if name=='recording_start':behaviour['left_censoring_reported']=any(c['Status']=='incomplete_preceding_state' for c in C)
        if name=='recording_end':behaviour['right_censoring_reported']=any(c['Status']=='incomplete_recovery' for c in C)
        if name=='motion':behaviour['motion_reported']=bool(np.any(R['Evidence']['MotionFlag']))
        if name=='vascular_gap':behaviour['static_gap_not_filled']=not np.any(R['Evidence']['Domain'][:,29:31])
        rows.append({'Scene':name,'Candidates':len(C),'Tracks':len(R['Tracks']),'Statuses':counts,'MotionFrames':int(R['Evidence']['MotionFlag'].sum()),'BehaviourChecks':behaviour})
        invariants.append({'Scene':name,'PixelCountsAndFrameCoverage':True,'ScientificIsolation':True})
        print(name,len(C),counts,behaviour,flush=True)
    # Independent fixed-cohort safeguard, intentionally hostile dynamic mask.
    raw=np.full((180,64,64),1000.,np.float32);mask=np.zeros((64,64),bool);mask[27:34,27:34]=True
    raw[70:,mask]=800.;domain=np.ones((64,64),bool)
    a,tr=assess_episode(raw,domain,mask,75,120,1.,S)
    assert not a['Status'].startswith('local_reversible_candidate') and np.all(tr['Raw'][100:]==800.)
    raw[90:95,28,28]=np.nan
    missing,missing_trace=assess_episode(raw,domain,mask,75,120,1.,S)
    assert np.all(np.isnan(missing_trace['Raw'][90:95])) and missing['Status']=='uncertain_missing_data'
    idx=native_indices(np.array([7*128+9]),(128,128),4)
    rows1=(idx-1)%512+1;cols1=(idx-1)//512+1
    assert len(idx)==16 and (rows1.min(),rows1.max(),cols1.min(),cols1.max())==(29,32,37,40)
    assert S.frame_count(5,2)==10 and S.frame_count(20,.5)==10
    passed=sum(v for r in rows for v in r['BehaviourChecks'].values());total=sum(len(r['BehaviourChecks']) for r in rows)
    result={'Schema':'boi-video-synthetic-1','Scenes':rows,'InvariantChecks':invariants,
            'FixedCohortChangingMaskSafeguard':True,'MissingPixelCannotChangeCohort':True,'NativeCoordinateConversion':True,'SampleClockConversion':True,
            'BehaviourChecksPassed':passed,'BehaviourChecksTotal':total,'BehaviourFailures':[{ 'Scene':r['Scene'],'Check':k} for r in rows for k,v in r['BehaviourChecks'].items() if not v],
            'BiologicalValidation':False,'ElapsedSec':time.monotonic()-started}
    Path(destination).write_text(json.dumps(result,indent=2)+'\n')
    print(f'16 scene geometry/coverage invariants pass; desired behaviour {passed}/{total}.',flush=True)


if __name__=='__main__':run(sys.argv[1])
