"""Independent NumPy pulse profiles, selected-template checks and paired metrics."""
import argparse
import itertools
import json
from pathlib import Path
import h5py
import numpy as np
from verify_surge_separation import rows, require, sha, read_pixels, SESSIONS
from verify_surge_onset_trace_panel import envelope, diagnostics, compare, summary, write_csv

GRID=(2,5,10,15,20,30,45,60)
HOLD=(0,5,10,20,40,60)


def pulse(t, params):
    p=np.asarray(params)
    up=np.clip(t[:,None]/p[:,0],0,1)
    down=np.clip((p[:,0]+p[:,1]+p[:,2]-t[:,None])/p[:,2],0,1)
    h=np.minimum(up,down);smooth=p[:,3]==2
    h[:,smooth]=np.sin(np.pi*h[:,smooth]/2)**2
    return h


def fit_batch(traces,start,end,blocked):
    traces=np.asarray(traces,float);first=max(1,start-60)
    neighbors=np.flatnonzero(blocked[first-1:start-1])
    if len(neighbors):first+=int(neighbors[-1])+1
    lo=max(start-40,first+20);last=min(end,start+4)
    names=('OnsetFrame BestCandidateFrame ScoreImprovement ProfileStartFrame ProfileEndFrame ProfileSpanSec '
           'BaselineStartFrame BaselineEndFrame BaselineMean ProvisionalAmplitude').split()
    results=[dict.fromkeys(names,np.nan) for _ in traces]
    for r in results:r.update(Status='unassessed',BaselineStatus='onset_unresolved',FitStartFrame=first,FitEndFrame=last)
    if lo>=start-1:
        for r in results:r['Status']='insufficient_clean_context'
        return results
    scale=np.median(np.abs(traces[:,first-1:last]),axis=1)
    valid=np.all(np.isfinite(traces[:,first-1:last]),axis=1)
    for i,r in enumerate(results):
        if not valid[i]:r['Status']='nonfinite_fit'
        elif scale[i]<=0:r['Status']='nonpositive_scale';valid[i]=False
    if not np.any(valid):return results
    frames=np.arange(first,last+1);n=len(frames);d=np.column_stack((np.ones(n),frames-start))
    q=np.linalg.qr(d,mode='reduced')[0]
    params=np.array([(r,h,f,s) for s in (1,2) for f in GRID for h in HOLD for r in GRID])
    banks=[];groups=[];count=0
    for k in range(lo,start+1):
        h=pulse(frames-k+1,params);active=pulse(np.array([start-k+1]),params)[0]>0
        h=h-q@(q.T@h);norm=np.linalg.norm(h,axis=0);keep=active&(norm>1e-10)
        u=h[:,keep]/norm[keep];banks.append(u);groups.append(slice(count,count+u.shape[1]));count+=u.shape[1]
    u=np.concatenate(banks,axis=1);y=traces[valid,first-1:last].T/scale[valid];z=y-q@(q.T@y)
    base=np.maximum(np.sum(z*z,axis=0),n*1e-20);a=np.maximum(0,u.T@z)
    sse=np.maximum(base-a*a,n*1e-20)
    for j in range(y.shape[1]):
        tiny=np.flatnonzero(sse[:,j]<1e-10*base[j])
        if len(tiny):sse[tiny,j]=np.maximum(np.sum((z[:,j,None]-u[:,tiny]*a[tiny,j])**2,axis=0),n*1e-20)
    score=n*np.log(base/sse)-5*np.log(n)-2*np.log(2)
    profile=np.array([np.max(score[g],axis=0) for g in groups]);candidates=np.arange(lo,start+1)
    for j,i in enumerate(np.flatnonzero(valid)):
        r=results[i];v=profile[:,j];k=int(np.argmax(v));onset=int(candidates[k]);near=candidates[v>=v[k]-2]
        r.update(BestCandidateFrame=onset,ScoreImprovement=v[k],ProfileStartFrame=near[0],ProfileEndFrame=near[-1],ProfileSpanSec=near[-1]-near[0])
        if v[k]<10:r['Status']='insufficient_improvement'
        elif onset in (lo,start):r['Status']='search_boundary_unresolved'
        elif near[-1]-near[0]>10:r['Status']='broad_profile_unresolved'
        else:
            b=np.mean(traces[i,onset-21:onset-1]);r.update(Status='resolved',OnsetFrame=onset,BaselineStartFrame=onset-20,
                BaselineEndFrame=onset-1,BaselineMean=b,BaselineStatus='nonpositive_baseline')
            if not np.all(np.isfinite(traces[i,start-1:end])):r['BaselineStatus']='missing_native_signal'
            elif b>0:r.update(BaselineStatus='provisional_valid',ProvisionalAmplitude=np.max(traces[i,start-1:end])/b-1)
    return results


def selected_template(record,x):
    """Equivalent nuisance templates may tie: verify the exported one directly."""
    if not np.isfinite(float(record['ScoreImprovement'])):
        require(record['TemplateShape']=='unassessed','Spurious template without fit');return
    first,last,k=map(lambda name:int(record[name]),('FitStartFrame','FitEndFrame','BestCandidateFrame'))
    params=[float(record[name]) for name in ('TemplateRiseSec','TemplatePlateauSec','TemplateRecoverySec')]
    require(params[0] in GRID and params[1] in HOLD and params[2] in GRID,'Template grid changed')
    require(record['TemplateShape'] in ('linear','sine_squared'),'Unknown shape');params.append(1 if record['TemplateShape']=='linear' else 2)
    f=np.arange(first,last+1);d=np.column_stack((np.ones(len(f)),f-np.mean(f)))
    y=x[first-1:last]/np.median(np.abs(x[first-1:last]));h=pulse(f-k+1,np.array([params]))[:,0]
    z=y-d@np.linalg.lstsq(d,y,rcond=None)[0];v=h-d@np.linalg.lstsq(d,h,rcond=None)[0]
    coefficient=max(0,np.dot(v,z)/np.dot(v,v));sse=max(np.sum((z-coefficient*v)**2),len(f)*1e-20)
    baseline=max(np.sum(z*z),len(f)*1e-20)
    expected=len(f)*np.log(baseline/sse)-5*np.log(len(f))-2*np.log(2)
    require(np.isclose(float(record['ScoreImprovement']),expected,atol=1e-7,rtol=1e-10),'Selected template score mismatch')
    require(np.isclose(float(record['PulseCoefficientOverFitMedian']),coefficient,atol=1e-9,rtol=1e-9),'Pulse coefficient mismatch')


def verify(cache, prior, output):
    cache,prior,output=map(Path,(cache,prior,output))
    inputs=rows(output/'input-manifest.csv');require(len(inputs)==16,'Input coverage')
    for r in inputs:require(sha(r['Path'])==r['SHA256'],'Changed input')
    current=rows(output/'panel-results.csv');old=[r for r in rows(prior/'panel-results.csv') if r['Context']=='available']
    key=lambda r:tuple(r[n] for n in ('Session','EventRow','AmplitudeFraction','RiseFrames','Shape','DelayFrames'))
    actual={key(r):r for r in current};require(len(actual)==len(current)==5520,'Panel coverage')
    ctrls=rows(output/'source-controls.csv');controlmap={(r['Session'],r['EventRow']):r for r in ctrls}
    require(len(ctrls)==len(controlmap)==115,'Control coverage')
    checked=0;fitted=0
    for session in SESSIONS:
        folder=cache/session/'growing_clean'
        backgrounds=[r for r in rows(prior/'backgrounds.csv') if r['Session']==session]
        with h5py.File(folder/'audit-inputs.mat') as h:
            traces=h['XTrace'][()].T;pxrefs=h['Pixels'][()].ravel();maskrefs=h['AllDetectedPixels'][()].ravel()
            for b in backgrounds:
                i=int(b['LocalRow'])-1;x=traces[i];start=int(b['NativeStartFrame']);end=int(b['NativeEndFrame']);n=len(x)
                px=read_pixels(h,h[pxrefs[i]]);blocked=np.zeros(n,bool)
                for f in range(max(0,start-61),start-1):blocked[f]=np.intersect1d(px,read_pixels(h,h[maskrefs[f]])).size>0
                recipes=[r for r in old if r['Session']==session and r['EventRow']==b['EventRow']];require(len(recipes)==48,'Recipe coverage')
                possible=[int(r['TruthOnsetFrame'])>20 and np.all(np.isfinite(x)&(x>0)) for r in recipes]
                yy=[x];envs={}
                for j,r in enumerate(recipes):
                    if possible[j]:
                        envs[j]=envelope(n,int(r['TruthOnsetFrame']),int(r['RiseFrames']),r['Shape'])
                        yy.append(x*(1+float(r['AmplitudeFraction'])*envs[j]))
                fits=fit_batch(np.array(yy),start,end,blocked);control=fits[0]
                c=controlmap.pop((session,b['EventRow']));compare(c,dict(control,Context='pulse',Session=session,EventRow=int(b['EventRow']),LocalRow=i+1,NativeStartFrame=start,NativeEndFrame=end));selected_template(c,x)
                cursor=0
                for j,r in enumerate(recipes):
                    a=actual.pop(key(r));compare(a,dict(Context='pulse',Constructible=bool(possible[j])))
                    for name in ('Session','EventRow','LocalRow','NativeStartFrame','NativeEndFrame','AmplitudeFraction','RiseFrames','Shape','DelayFrames','TruthOnsetFrame','PulseTruncated'):
                        require(a[name]==r[name],'Changed recipe metadata: '+name)
                    y=env=None
                    if possible[j]:cursor+=1;result=fits[cursor];y=yy[cursor];env=envs[j];fitted+=1
                    else:
                        result={name:(np.nan if not isinstance(v,str) else v) for name,v in control.items()}
                        result.update(Status='construction_unavailable',BaselineStatus='construction_unavailable')
                    compare(a,result);selected_template(a,y if y is not None else x)
                    compare(a,dict(ControlResolved=control['Status']=='resolved',ControlOnsetFrame=control['OnsetFrame']))
                    compare(a,diagnostics(x,y,env,start,end,int(r['TruthOnsetFrame']),result,control));checked+=1
        print('VERIFIED PULSE',session,flush=True)
    require(not actual and not controlmap and fitted==5136,'Missing rows')
    flat=rows(output/'flat-calibration.csv');require(len(flat)==48,'Noiseless coverage')
    flatold=[r for r in rows(prior/'flat-calibration.csv') if r['Context']=='available']
    for a,b in zip(flat,flatold):
        for name in ('AmplitudeFraction','RiseFrames','Shape','DelayFrames','TruthOnsetFrame'):require(a[name]==b[name],'Calibration recipe changed')
    yy=np.array([100*(1+float(r['AmplitudeFraction'])*envelope(240,int(r['TruthOnsetFrame']),int(r['RiseFrames']),r['Shape'])) for r in flat])
    fits=fit_batch(yy,120,180,np.zeros(240,bool))
    for r,x,f in zip(flat,yy,fits):
        compare(r,f);selected_template(r,x);error=f['OnsetFrame']-int(r['TruthOnsetFrame'])
        compare(r,dict(Context='pulse',PosthocCalibration=False,OnsetErrorSec=error,WithinFiveSec=bool(abs(error)<=5)))
    require(rows(output/'backgrounds.csv')==rows(prior/'backgrounds.csv'),'Background ledger changed')
    expected=dict(SourceRecordings=4,FixedSupports=115,PlannedConstructedRows=5520,ConstructedFits=5136,SourceFits=115,
                  NoiselessFits=48,CodeAndInputFreezeVerified=True,ProductionChanged=False,NewDetectionOrMasterRuns=0)
    require(json.loads((output/'completion.json').read_text())==expected,'Completion scope')
    combined=old+current
    for name,fields in [('method-summary',['Context']),('source-summary',['Session','Context']),
                         ('recipe-summary',['Context','AmplitudeFraction','RiseFrames','Shape','DelayFrames'])]:
        write_csv(output/(name+'.csv'),summary(combined,fields))
    previous={key(r):r for r in old};paired=[]
    for r in current:
        b=previous[key(r)];paired.append(dict(Session=r['Session'],EventRow=r['EventRow'],AmplitudeFraction=r['AmplitudeFraction'],
            RiseFrames=r['RiseFrames'],Shape=r['Shape'],DelayFrames=r['DelayFrames'],Constructible=r['Constructible'],
            PreviousStatus=b['Status'],PulseStatus=r['Status'],PreviousErrorSec=b['OnsetErrorSec'],PulseErrorSec=r['OnsetErrorSec'],
            PreviousWithinFiveSec=b['WithinFiveSec'],PulseWithinFiveSec=r['WithinFiveSec']))
    write_csv(output/'paired-transitions.csv',paired)
    return dict(PlannedRowsVerified=checked,ConstructedFitsVerified=fitted,SourceFitsVerified=115,NoiselessFitsVerified=48,
                IndependentPulseProfiles=True,SelectedTemplatesVerified=True,ProductionChanged=False)


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('cache');p.add_argument('prior');p.add_argument('output');a=p.parse_args()
    result=verify(a.cache,a.prior,a.output);(Path(a.output)/'independent-verification.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
