"""Independent selector, out-of-family waveforms, raw traces and fit verification."""
import argparse
import json
from collections import Counter
from pathlib import Path
import h5py
import numpy as np
from PIL import Image
from verify_surge_separation import rows, sha, require, read_pixels
from verify_surge_local_onset import estimate
from verify_surge_pulse_onset import fit_batch
from verify_surge_onset_trace_panel import compare, diagnostics, summary, write_csv


def select(a,b,fs=1):
    require(all(np.isclose(a[k],b[k],equal_nan=True) for k in ('FitStartFrame','FitEndFrame')),'Fit contexts differ')
    r=dict(Status='no_model_evidence',OnsetFrame=np.nan,BaselineStartFrame=np.nan,BaselineEndFrame=np.nan,
        BaselineMean=np.nan,ProvisionalAmplitude=np.nan,BaselineStatus='onset_unresolved',SelectedModel='none',SelectedScore=np.nan,
        RisingScore=a['ScoreImprovement']-2*np.log(2),PulseScore=b['ScoreImprovement']-2*np.log(2),RisingStatus=a['Status'],PulseStatus=b['Status'],
        ModelGapSec=np.nan,CombinedProfileSpanSec=np.nan,PlausibleModels=0,FitStartFrame=a['FitStartFrame'],FitEndFrame=a['FitEndFrame'])
    models=[a,b];scores=np.array([r['RisingScore'],r['PulseScore']]);statuses=[a['Status'],b['Status']]
    plausible=np.isfinite(scores)&(scores>=10)&np.isin(statuses,['resolved','broad_profile_unresolved','search_boundary_unresolved'])
    r['PlausibleModels']=int(sum(plausible))
    if not np.any(plausible):
        if statuses[0]==statuses[1] and statuses[0] in ('insufficient_clean_context','construction_unavailable','nonfinite_fit','nonpositive_scale'):
            r['Status']=statuses[0]
            if statuses[0]=='construction_unavailable':r['BaselineStatus']='construction_unavailable'
        return r
    j=int(np.argmax(np.where(plausible,scores,-np.inf)));winner=models[j];r['SelectedScore']=scores[j]
    if winner['Status']!='resolved':r['Status']='best_model_unresolved';return r
    other=1-j
    if plausible[other] and scores[other]>=scores[j]-2:
        challenger=models[other]
        if challenger['Status']!='resolved':r['Status']='model_uncertainty';return r
        r['ModelGapSec']=abs(winner['OnsetFrame']-challenger['OnsetFrame'])/fs
        r['CombinedProfileSpanSec']=(max(winner['ProfileEndFrame'],challenger['ProfileEndFrame'])-min(winner['ProfileStartFrame'],challenger['ProfileStartFrame']))/fs
        if r['ModelGapSec']>5:r['Status']='model_disagreement';return r
        if r['CombinedProfileSpanSec']>10:r['Status']='model_uncertainty';return r
    r.update(Status='resolved',SelectedModel=('rising','pulse')[j])
    for name in ('OnsetFrame','BaselineStartFrame','BaselineEndFrame','BaselineMean','ProvisionalAmplitude','BaselineStatus'):r[name]=winner[name]
    return r


def unseen(n,k,r,shape):
    j=np.arange(1,n+1)-k+1;e=np.zeros(n)
    if shape=='gamma':
        active=(j>0)&(j<=8*r);u=j[active]/r;e[active]=u*np.exp(1-u);last=k+8*r-1
    else:
        require(shape in ('exponential','quadratic'),'Unknown waveform');up=(j>0)&(j<=r);hold=(j>r)&(j<=r+11);e[hold]=1
        if shape=='exponential':
            e[up]=-np.expm1(-3*j[up]/r)/(-np.expm1(-3));down=(j>r+11)&(j<=13*r+11)
            e[down]=np.exp(-(j[down]-r-11)/(2*r));last=k+13*r+10
        else:
            e[up]=(j[up]/r)**2;down=(j>r+11)&(j<=3*r+11);e[down]=(1-(j[down]-r-11)/(2*r))**2;last=k+3*r+10
    return e,last


def fit_record(row):
    strings=('Status','BaselineStatus');numbers=('ScoreImprovement OnsetFrame FitStartFrame FitEndFrame ProfileStartFrame ProfileEndFrame '
        'BaselineStartFrame BaselineEndFrame BaselineMean ProvisionalAmplitude').split()
    return {**{k:row[k] for k in strings},**{k:float(row[k]) for k in numbers}}


def verify_additional(root):
    samples=0
    for session,count in [('ID13-20200917',131),('FB2316-baseline',62)]:
        folder=root/'additional-backgrounds'/session;m=json.loads((folder/'provenance.json').read_text())
        for key in ('Source','SurgeMat','SinkMat','ReferenceReport'):
            path=m['SourceTiff'] if key=='Source' else m[key]
            require(sha(path)==m[key+'SHA256'],'Changed historical source '+key)
        require(m['EventSupports']==count and m['Frames']==1200 and m['SampleHz']==1,'Additional recording scope')
        bg=rows(folder/'backgrounds.csv');require(len(bg)==count,'Additional support coverage')
        with h5py.File(folder/'background-inputs.mat') as h:
            x=h['XTrace'][()].T;refs=h['Pixels'][()].ravel();natives=h['NativePixels'][()].T
            px=[read_pixels(h,h[z]) for z in refs];require(x.shape==(count,1200),'Trace shape')
            for j,b in enumerate(bg):
                a=int(b['NativeStartFrame'])-1;z=int(b['NativeEndFrame'])
                cells=[read_pixels(h,h[q]) for q in natives[j,a:z]];require(all(len(c)>0 for c in cells),'Empty native frame')
                require(np.array_equal(px[j],np.unique(np.concatenate(cells))),'Changed native union')
            with Image.open(m['SourceTiff']) as movie:
                require(movie.n_frames==1200,'Raw frame count')
                for f in range(1200):
                    movie.seek(f);frame=np.asarray(movie)
                    require(frame.shape==(m['Height'],m['Width']),'Raw spatial axes')
                    flat=frame.reshape(-1,order='F');actual=np.array([np.mean(flat[p],dtype=np.float64) for p in px])
                    require(np.allclose(actual,x[:,f],atol=1e-10,rtol=1e-12),'Raw support mean mismatch');samples+=count
        print('VERIFIED ADDITIONAL RAW TRACES',session,flush=True)
    return samples


def cached_replay(prior,pulse,root):
    a=[r for r in rows(prior/'panel-results.csv') if r['Context']=='available'];b=rows(pulse/'panel-results.csv');out=rows(root/'cached-selection-results.csv')
    ca=[r for r in rows(prior/'source-controls.csv') if r['Context']=='available'];cb=rows(pulse/'source-controls.csv');co=rows(root/'cached-selection-controls.csv')
    require(len(a)==len(b)==len(out)==5520 and len(ca)==len(cb)==len(co)==115,'Cached coverage')
    controls={}
    for x,y,z in zip(ca,cb,co):
        require((x['Session'],x['EventRow'])==(y['Session'],y['EventRow'])==(z['Session'],z['EventRow']),'Control join')
        r=select(fit_record(x),fit_record(y));compare(z,r);controls[x['Session'],x['EventRow']]=r
    for x,y,z in zip(a,b,out):
        for name in ('Session','EventRow','AmplitudeFraction','RiseFrames','Shape','DelayFrames'):require(x[name]==y[name]==z[name],'Cached recipe join')
        r=select(fit_record(x),fit_record(y));compare(z,r)
        compare(z,dict(Constructible=x['Constructible']=='1'))
        diag=dict(OnsetErrorSec=np.nan,WithinFiveSec=False,ProposedBaselineImposedFraction=np.nan,BaselineEffectPP=np.nan,BaselineUnderOnePercent=False,SameOnsetAsControl=False)
        if r['Status']=='resolved':
            source=x if r['SelectedModel']=='rising' else y
            for k in ('OnsetErrorSec','ProposedBaselineImposedFraction','BaselineEffectPP'):diag[k]=float(source[k])
            for k in ('WithinFiveSec','BaselineUnderOnePercent'):diag[k]=source[k]=='1'
            c=controls[x['Session'],x['EventRow']];diag['SameOnsetAsControl']=c['Status']=='resolved' and c['OnsetFrame']==r['OnsetFrame']
        compare(z,diag);z['Context']='selection'
    write_csv(root/'cached-method-summary.csv',summary(a+b+out,['Context']))
    return len(out)


def check_row(row,f,selection,meta,kind,control,recipe=None,x=None,y=None,env=None):
    common=('Status OnsetFrame FitStartFrame FitEndFrame BaselineStartFrame BaselineEndFrame BaselineMean ProvisionalAmplitude BaselineStatus').split()
    compare(row,{k:f[k] for k in common})
    fields=('RisingScore PulseScore SelectedScore SelectedModel ModelGapSec CombinedProfileSpanSec PlausibleModels').split()
    compare(row,{k:selection[k] for k in fields});compare(row,dict(SelectorStatus=selection['Status'],Context=kind,Session=meta['Session'],EventRow=int(meta['EventRow']),Cohort=meta['Cohort'],
        NativeStartFrame=int(meta['NativeStartFrame']),NativeEndFrame=int(meta['NativeEndFrame']),ControlResolved=control['Status']=='resolved'))
    if recipe is None:
        compare(row,dict(AmplitudeFraction=0,RiseFrames=0,Shape='control',DelayFrames=0,TruthOnsetFrame=np.nan,Constructible=False,PulseTruncated=False,
            OnsetErrorSec=np.nan,WithinFiveSec=False,NativeBaselineImposedFraction=np.nan,NativeBaselineEffectPP=np.nan,ProposedBaselineImposedFraction=np.nan,
            BaselineEffectPP=np.nan,PositiveBaselineFrames=np.nan,BaselineUnderOnePercent=False,SameOnsetAsControl=False,ShiftFromControlSec=np.nan));return
    compare(row,recipe)
    compare(row,diagnostics(x,y,env,int(meta['NativeStartFrame']),int(meta['NativeEndFrame']),recipe['TruthOnsetFrame'],f,control))


def verify(prior,pulse,root):
    prior,pulse,root=map(Path,(prior,pulse,root))
    inputs=rows(root/'input-manifest.csv');require(len(inputs)==19,'Input coverage')
    for r in inputs:require(sha(r['Path'])==r['SHA256'],'Changed benchmark input')
    cached=cached_replay(prior,pulse,root);rawsamples=verify_additional(root)
    allrows=rows(root/'unseen-results.csv');controlrows=rows(root/'unseen-controls.csv');backgrounds=rows(root/'backgrounds.csv')
    key=lambda r:(r['Session'],int(r['EventRow']),r['Context'],float(r['AmplitudeFraction']),int(r['RiseFrames']),r['Shape'],int(r['DelayFrames']))
    records={key(r):r for r in allrows};ctrls={(r['Session'],int(r['EventRow']),r['Context']):r for r in controlrows}
    require(len(backgrounds)==309 and len(records)==len(allrows)==33372 and len(ctrls)==len(controlrows)==927,'Unseen coverage')
    sessions=list(dict.fromkeys(b['Session'] for b in backgrounds));possible_count=0;component_fits=0
    for session in sessions:
        group=[b for b in backgrounds if b['Session']==session];h=None
        if session!='flat':
            h=h5py.File(group[0]['CachePath']);traces=h['XTrace'][()].T;pxrefs=h['Pixels'][()].ravel();maskrefs=h['AllDetectedPixels'][()].ravel()
        try:
            for b in group:
                n=int(b['Frames']);start=int(b['NativeStartFrame']);end=int(b['NativeEndFrame']);blocked=np.zeros(n,bool)
                if session=='flat':x=np.ones(n)*100
                else:
                    i=int(b['LocalRow'])-1;x=traces[i];px=read_pixels(h,h[pxrefs[i]])
                    for f in range(max(0,start-61),start-1):blocked[f]=np.intersect1d(px,read_pixels(h,h[maskrefs[f]])).size>0
                cases=[];yy=[x]
                for amp in (.02,.1,.2):
                    for rise in (7,23):
                        for shape in ('gamma','exponential','quadratic'):
                            for delay in (10,25):
                                k=start-delay;possible=k>20 and np.all(np.isfinite(x)&(x>0));env=None;idx=None;truncated=False
                                if possible:
                                    env,last=unseen(n,k,rise,shape);yy.append(x*(1+amp*env));idx=len(yy)-1;truncated=last>n;possible_count+=1
                                recipe=dict(AmplitudeFraction=amp,RiseFrames=rise,Shape=shape,DelayFrames=delay,TruthOnsetFrame=k,Constructible=bool(possible),PulseTruncated=truncated)
                                cases.append((recipe,idx,env))
                p=fit_batch(np.array(yy),start,end,blocked);a=[estimate(y,start,end,blocked,'available') for y in yy];s=[select(u,v) for u,v in zip(a,p)];component_fits+=2*len(yy)
                controls=[a[0],p[0],s[0]];names=('rising','pulse','selection')
                for kind,c in zip(names,controls):check_row(ctrls.pop((session,int(b['EventRow']),kind)),c,s[0],b,kind,c)
                for recipe,idx,env in cases:
                    if idx is None:
                        pair=[]
                        for c in controls[:2]:
                            f={k:(np.nan if not isinstance(v,str) else v) for k,v in c.items()};f.update(Status='construction_unavailable',BaselineStatus='construction_unavailable');pair.append(f)
                        fits=pair+[select(*pair)];y=None
                    else:fits=[a[idx],p[idx],s[idx]];y=yy[idx]
                    for kind,f,c in zip(names,fits,controls):
                        k=(session,int(b['EventRow']),kind,recipe['AmplitudeFraction'],recipe['RiseFrames'],recipe['Shape'],recipe['DelayFrames'])
                        check_row(records.pop(k),f,fits[2],b,kind,c,recipe,x,y,env)
        finally:
            if h is not None:h.close()
        print('VERIFIED UNSEEN',session,flush=True)
    require(not records and not ctrls,'Unexpected records')
    expected=dict(SourceRecordings=6,DevelopmentSupports=115,AdditionalSupports=193,NoiselessSupports=1,RecipesPerSupport=36,PlannedUnseenRows=33372,
        ConstructibleCasesIncludingNoiseless=possible_count,SourceControlRowsIncludingNoiseless=927,CachedSelectorRows=5520,CachedSelectorControls=115,
        CodeAndInputFreezeVerified=True,ProductionChanged=False,NewDetectorOrMasterRuns=0)
    require(json.loads((root/'completion.json').read_text())==expected,'Completion scope')
    for name,fields in [('unseen-cohort-summary',['Cohort','Context']),('unseen-source-summary',['Session','Context']),
                       ('unseen-shape-summary',['Cohort','Context','Shape']),('unseen-recipe-summary',['Cohort','Context','Shape','RiseFrames','DelayFrames','AmplitudeFraction'])]:
        write_csv(root/(name+'.csv'),summary(allrows,fields))
    counts=Counter((r['Cohort'],r['Context'],r['Status']) for r in controlrows)
    write_csv(root/'unseen-control-summary.csv',[dict(Cohort=k[0],Context=k[1],Status=k[2],Count=v) for k,v in sorted(counts.items())])
    return dict(CachedSelectorRowsVerified=cached,AdditionalRawSupportMeansVerified=rawsamples,AdditionalNativeUnionsVerified=193,
        UnseenRowsVerified=len(allrows),ConstructibleCasesIncludingNoiseless=possible_count,ComponentFitsIncludingControls=component_fits,
        IndependentModelSelection=True,ProductionChanged=False)


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('prior');p.add_argument('pulse');p.add_argument('root');a=p.parse_args()
    r=verify(a.prior,a.pulse,a.root);(Path(a.root)/'independent-verification.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2))
