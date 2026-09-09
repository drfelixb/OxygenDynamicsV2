"""Reconstruct mean-trace pulses and verify every context fit and denominator."""
import argparse
import csv
import itertools
import json
from collections import Counter
from pathlib import Path
import h5py
import numpy as np
from verify_surge_separation import require, rows, sha, read_pixels, SESSIONS
from verify_surge_local_onset import estimate
from verify_surge_amplitude_support import same


def envelope(n, onset, rise, shape):
    require(1<=onset<=n and rise>0 and shape in ('linear','sine_squared'),'Invalid pulse')
    j=np.arange(1,n+1)-onset+1;out=np.zeros(n)
    up=(j>=1)&(j<=rise);hold=(j>rise)&(j<=rise+20);down=(j>rise+20)&(j<2*rise+20)
    if shape=='linear':out[up]=j[up]/rise;out[down]=1-(j[down]-rise-20)/rise
    else:out[up]=np.sin(np.pi*j[up]/(2*rise))**2;out[down]=np.cos(np.pi*(j[down]-rise-20)/(2*rise))**2
    out[hold]=1
    return out


def compare(record, expected):
    for key,value in expected.items():
        if isinstance(value,str):require(record[key]==value,'Mismatch: '+key)
        elif isinstance(value,(bool,np.bool_)):require(record[key] in ('0','1') and (record[key]=='1')==value,'Mismatch: '+key)
        else:same(record[key],value,key)


def diagnostics(x, y, env, start, end, onset, result, control):
    r=dict.fromkeys(('OnsetErrorSec ShiftFromControlSec NativeBaselineImposedFraction NativeBaselineEffectPP '
                     'ProposedBaselineImposedFraction BaselineEffectPP PositiveBaselineFrames').split(),np.nan)
    r.update(WithinFiveSec=False,SameOnsetAsControl=False,BaselineUnderOnePercent=False)
    if y is None:return r
    pre=slice(start-21,start-1);bx=np.mean(x[pre]);by=np.mean(y[pre]);peak=np.max(y[start-1:end])
    r.update(NativeBaselineImposedFraction=by/bx-1,NativeBaselineEffectPP=100*(peak/by-peak/bx))
    if result['Status']=='resolved':
        k=result['OnsetFrame'];r.update(OnsetErrorSec=k-onset,WithinFiveSec=abs(k-onset)<=5)
        if control['Status']=='resolved':
            shift=k-control['OnsetFrame'];r.update(ShiftFromControlSec=shift,SameOnsetAsControl=shift==0)
        pre=slice(k-21,k-1);bx=np.mean(x[pre]);by=np.mean(y[pre])
        r.update(ProposedBaselineImposedFraction=by/bx-1,BaselineEffectPP=100*(peak/by-peak/bx),
                 PositiveBaselineFrames=np.count_nonzero(env[pre]>0),BaselineUnderOnePercent=by/bx-1<=.01)
    return r


def summary(records, fields):
    groups={}
    for r in records:groups.setdefault(tuple(r[f] for f in fields),[]).append(r)
    out=[]
    for key,items in sorted(groups.items()):
        possible=[r for r in items if r['Constructible']=='1'];resolved=[r for r in possible if r['Status']=='resolved']
        good=sum(r['WithinFiveSec']=='1' for r in resolved)
        clean=sum(r['BaselineUnderOnePercent']=='1' for r in resolved)
        both=sum(r['WithinFiveSec']=='1' and r['BaselineUnderOnePercent']=='1' for r in resolved)
        row=dict(zip(fields,key));row.update(Planned=len(items),Constructible=len(possible),Resolved=len(resolved),
            WithinFiveSec=good,BaselineUnderOnePercent=clean,WithinFiveSecAndClean=both,
            AvailableAmplitudes=sum(r['BaselineStatus']=='provisional_valid' for r in resolved),
            SameOnsetAsControl=sum(r['SameOnsetAsControl']=='1' for r in resolved),
            ResolvedFraction=len(resolved)/len(possible) if possible else np.nan,
            WithinFiveSecFractionAll=good/len(possible) if possible else np.nan,
            WithinFiveSecFractionResolved=good/len(resolved) if resolved else np.nan)
        for field,label in [('OnsetErrorSec','OnsetErrorSec'),('ProposedBaselineImposedFraction','BaselineImposedFraction'),
                            ('BaselineEffectPP','BaselineEffectPP')]:
            v=np.array([float(r[field]) for r in resolved]);row['Median'+label]=float(np.median(v)) if len(v) else np.nan
        v=np.abs([float(r['OnsetErrorSec']) for r in resolved]);row['MedianAbsoluteErrorSec']=float(np.median(v)) if len(v) else np.nan
        row['P90AbsoluteErrorSec']=float(np.percentile(v,90)) if len(v) else np.nan
        out.append(row)
    return out


def write_csv(path, records):
    require(bool(records),'Empty summary')
    with Path(path).open('w',newline='') as f:
        w=csv.DictWriter(f,fieldnames=list(records[0]),lineterminator='\n');w.writeheader();w.writerows(records)


def verify_flat(output):
    records=rows(Path(output)/'flat-calibration.csv')
    keys={(r['Context'],float(r['AmplitudeFraction']),int(r['RiseFrames']),r['Shape'],int(r['DelayFrames'])):r for r in records}
    require(len(keys)==len(records)==96,'Flat calibration coverage')
    for context,amplitude,rise,shape,delay in itertools.product(('fixed','available'),(.02,.05,.1,.2),(5,15,30),('linear','sine_squared'),(10,25)):
        k=120-delay;x=np.ones(240)*100;y=x*(1+amplitude*envelope(240,k,rise,shape))
        result=estimate(y,120,180,np.zeros(240,bool),context);error=result['OnsetFrame']-k
        result.update(Context=context,AmplitudeFraction=amplitude,RiseFrames=rise,Shape=shape,DelayFrames=delay,
                      TruthOnsetFrame=k,OnsetErrorSec=error,WithinFiveSec=bool(abs(error)<=5),PosthocCalibration=True)
        compare(keys.pop((context,amplitude,rise,shape,delay)),result)
    require(not keys,'Unexpected calibration row')
    return 96


def verify(cache, output):
    cache,output=Path(cache),Path(output)
    manifests=rows(output/'input-manifest.csv');require(len(manifests)==12,'Input coverage')
    for r in manifests:require(sha(r['Path'])==r['SHA256'],'Changed cache')
    allrows=rows(output/'panel-results.csv');controls=rows(output/'source-controls.csv');backgrounds=rows(output/'backgrounds.csv')
    keys={(r['Session'],int(r['EventRow']),r['Context'],float(r['AmplitudeFraction']),int(r['RiseFrames']),r['Shape'],int(r['DelayFrames'])):r for r in allrows}
    controlkeys={(r['Session'],int(r['EventRow']),r['Context']):r for r in controls}
    backgroundkeys={(r['Session'],int(r['EventRow'])):r for r in backgrounds}
    require(len(keys)==len(allrows)==11040 and len(controlkeys)==len(controls)==230 and len(backgroundkeys)==len(backgrounds)==115,'Duplicated or missing rows')
    constructed=0;fits=0;controls_checked=0
    for session in SESSIONS:
        folder=cache/session/'growing_clean';m=json.loads((folder/'provenance.json').read_text())
        require(m['SampleHz']==1 and m['BaselineFrames']==20,'Sampling/reference changed')
        supports=[r for r in rows(folder/'support-results.csv') if r['Support']=='full_event']
        with h5py.File(folder/'audit-inputs.mat') as h:
            traces=h['XTrace'][()].T;maskrefs=h['AllDetectedPixels'][()].ravel();pixelrefs=h['Pixels'][()].ravel()
            for row in supports:
                i=int(row['LocalRow'])-1;event=int(row['EventRow']);start=int(row['StartFrame']);end=int(row['EndFrame'])
                x=traces[i];n=len(x);px=read_pixels(h,h[pixelrefs[i]]);blocked=np.zeros(n,bool)
                # Neither rule consults exclusions outside these 60 preceding frames.
                for f in range(max(0,start-61),start-1):
                    blocked[f]=np.intersect1d(px,read_pixels(h,h[maskrefs[f]])).size>0
                compare(backgroundkeys.pop((session,event)),dict(Session=session,EventRow=event,LocalRow=i+1,Frames=n,
                    NativeStartFrame=start,NativeEndFrame=end,SupportPixels=len(px),EligibleSupportFraction=float(row['EligibleSupportFraction'])))
                for context in ('fixed','available'):
                    control=estimate(x,start,end,blocked,context)
                    base=dict(Session=session,EventRow=event,LocalRow=i+1,Context=context,NativeStartFrame=start,NativeEndFrame=end)
                    compare(controlkeys.pop((session,event,context)),dict(control,**base));controls_checked+=1
                    for amplitude,rise,shape,delay in itertools.product((.02,.05,.1,.2),(5,15,30),('linear','sine_squared'),(10,25)):
                        k=start-delay;possible=k>20 and np.all(np.isfinite(x)&(x>0));y=env=None
                        if possible:
                            env=envelope(n,k,rise,shape);y=x*(1+amplitude*env);r=estimate(y,start,end,blocked,context);fits+=1
                        else:
                            r={f:(np.nan if not isinstance(v,str) else v) for f,v in control.items()}
                            r.update(Status='construction_unavailable',BaselineStatus='construction_unavailable')
                        expected=dict(r,**base,AmplitudeFraction=amplitude,RiseFrames=rise,Shape=shape,DelayFrames=delay,
                            TruthOnsetFrame=k,Constructible=bool(possible),PulseTruncated=k+2*rise+19>n,
                            ControlResolved=control['Status']=='resolved',ControlOnsetFrame=control['OnsetFrame'])
                        expected.update(diagnostics(x,y,env,start,end,k,r,control))
                        compare(keys.pop((session,event,context,amplitude,rise,shape,delay)),expected);constructed+=1
        print('VERIFIED PANEL',session,flush=True)
    require(not keys and not controlkeys and not backgroundkeys,'Unexpected rows')
    completion=json.loads((output/'completion.json').read_text())
    require(completion==dict(SourceRecordings=4,FixedSupports=115,RecipesPerSupport=48,PlannedConstructedTraces=5520,
                            ConstructibleTraces=fits//2,PlannedConstructedEvaluations=11040,ConstructedFitsRun=fits,
                            SourceFitsRun=230,CodeAndInputFreezeVerified=True,ProductionChanged=False,NewDetectionOrMasterRuns=0),'Completion mismatch')
    for name,fields in [('method-summary',['Context']),('source-summary',['Session','Context']),
                        ('recipe-summary',['Context','AmplitudeFraction','RiseFrames','Shape','DelayFrames']),
                        ('source-recipe-summary',['Session','Context','AmplitudeFraction','RiseFrames','Shape','DelayFrames'])]:
        write_csv(output/(name+'.csv'),summary(allrows,fields))
    counts=Counter((r['Context'],r['Status']) for r in allrows)
    write_csv(output/'status-summary.csv',[dict(Context=k[0],Status=k[1],Evaluations=v) for k,v in sorted(counts.items())])
    counts=Counter((r['Session'],r['Context'],r['Status']) for r in controls)
    write_csv(output/'control-status-summary.csv',[dict(Session=k[0],Context=k[1],Status=k[2],Evaluations=v) for k,v in sorted(counts.items())])
    return dict(ConstructedRowsVerified=constructed,ConstructedFitsVerified=fits,SourceFitsVerified=controls_checked,
                FixedSupportsVerified=115,IndependentMaskExclusions=True,IndependentPulseConstruction=True,ProductionChanged=False)


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('cache');p.add_argument('output');a=p.parse_args()
    result=verify(a.cache,a.output)
    result['SeparatePosthocFlatFitsVerified']=verify_flat(a.output)
    (Path(a.output)/'independent-verification.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))
