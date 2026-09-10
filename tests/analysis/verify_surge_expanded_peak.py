"""Independent peak expansion, paired diagnostics and fixed-onset challenges."""
import argparse
import json
from collections import Counter
from pathlib import Path
import h5py
import numpy as np
from verify_surge_amplitude_eligibility import assess, key
from verify_surge_model_selection import unseen
from verify_surge_separation import rows, sha, require, read_pixels
from verify_surge_onset_trace_panel import compare, write_csv


def expand(y,start,end,onset,status,blocked,fs=1):
    r=assess(y,start,end,onset,status,blocked,fs)
    r.update(ExpandedStatus=r['AmplitudeStatus'],ExpandedArithmeticValid=False,
        ExpandedPositiveEligible=False,ExpandedSignedAmplitude=np.nan,
        ExpandedPositiveAmplitude=np.nan,ExpandedPeakFrame=np.nan,ExpandedPeakValue=np.nan,
        AddedFrameCount=np.nan,AddedNeighborFrames=np.nan,AddedNonfiniteFrames=np.nan,
        PeakPrecedesNative=False,AmplitudeIncrease=np.nan)
    if not r['ArithmeticValid']:
        return r
    onset=int(onset);added=slice(onset-1,start-1)
    r.update(AddedFrameCount=start-onset,AddedNeighborFrames=int(np.count_nonzero(blocked[added])),
        AddedNonfiniteFrames=int(np.count_nonzero(~np.isfinite(y[added]))))
    if r['AddedNeighborFrames']:
        r['ExpandedStatus']='added_interval_neighbor_overlap';return r
    if r['AddedNonfiniteFrames']:
        r['ExpandedStatus']='nonfinite_added_interval';return r
    p=onset-1+int(np.argmax(y[onset-1:end]));a=float(y[p]/r['ReferenceMean']-1)
    r.update(ExpandedPeakFrame=p+1,ExpandedPeakValue=float(y[p]),ExpandedSignedAmplitude=a)
    if not np.isfinite(a):
        r['ExpandedStatus']='nonfinite_amplitude';return r
    r.update(ExpandedArithmeticValid=True,PeakPrecedesNative=p+1<start,AmplitudeIncrease=a-r['SignedRawAmplitude'])
    if a<0:r['ExpandedStatus']='raw_direction_conflict'
    elif a==0:r['ExpandedStatus']='no_positive_raw_change'
    else:r.update(ExpandedStatus='positive_raw_change_provisional',ExpandedPositiveEligible=True,ExpandedPositiveAmplitude=a)
    return r


def challenges(root):
    results=rows(root/'neighbor-challenges.csv');traces=rows(root/'neighbor-challenge-traces.csv')
    names=['clean','detected_surge','detected_sink','undetected_surge','undetected_sink',
        'reference_neighbor','before_reference_neighbor','nonfinite_added']
    require([r['Challenge'] for r in results]==names and len(traces)==1280,'Challenge scope')
    t=np.arange(1,161);env=np.where((t>=75)&(t<=85),(t-74)/11,np.where((t>=86)&(t<=110),(111-t)/26,0))
    for j,(name,row) in enumerate(zip(names,results)):
        x=np.full(160,100.);mask=np.zeros(160,bool)
        if j in (1,3):x[90:93]=150
        if j in (2,4):x[90:93]=70
        if j in (1,2):mask[90:93]=True
        if j==5:x[64:67]=150;mask[64:67]=True
        if j==6:x[44:47]=150;mask[44:47]=True
        y=x+20*env
        if j==7:y[79]=np.nan
        r=expand(y,100,120,75,'resolved',mask)
        compare(row,r)
        compare(row,dict(TargetFractionAtExpandedPeak=env[int(r['ExpandedPeakFrame'])-1] if r['ExpandedArithmeticValid'] else np.nan))
        samples=[s for s in traces if s['Challenge']==name]
        require(len(samples)==160,'Challenge trace scope')
        for k,s in enumerate(samples):compare(s,dict(Frame=k+1,Source=x[k],Observed=y[k],Blocked=bool(mask[k]),TargetEnvelope=env[k]))
    return len(results)


def verify(selector,eligibility,root):
    selector,eligibility,root=map(Path,(selector,eligibility,root))
    inputs=rows(root/'input-manifest.csv');require(len(inputs)==8,'Input scope')
    for r in inputs:require(sha(r['Path'])==r['SHA256'],'Changed input '+r['Path'])
    original=rows(eligibility/'amplitude-eligibility-results.csv');output=rows(root/'expanded-peak-results.csv')
    old={key(r):r for r in original};new={key(r):r for r in output}
    require(len(old)==len(new)==len(output)==11433 and old.keys()==new.keys(),'Panel row scope')
    B=rows(selector/'backgrounds.csv');count=0
    for session in dict.fromkeys(b['Session'] for b in B):
        group=[b for b in B if b['Session']==session];h=None
        if session!='flat':
            h=h5py.File(group[0]['CachePath']);xx=h['XTrace'][()].T
            prefs=h['Pixels'][()].ravel();mrefs=h['AllDetectedPixels'][()].ravel()
        try:
            for b in group:
                n,start,end=(int(b[k]) for k in ('Frames','NativeStartFrame','NativeEndFrame'));mask=np.zeros(n,bool)
                if session=='flat':x=np.full(n,100.)
                else:
                    i=int(b['LocalRow'])-1;x=xx[i];px=read_pixels(h,h[prefs[i]])
                    for f in range(max(0,start-61),start-1):mask[f]=np.intersect1d(px,read_pixels(h,h[mrefs[f]])).size>0
                rr=[r for r in original if r['Session']==session and r['EventRow']==b['EventRow']]
                require(len(rr)==37,'Support coverage')
                for source in rr:
                    row=new[key(source)];require(all(source[k]==row[k] for k in source),'Changed frozen measurement')
                    env=np.zeros(n)
                    if source['Constructible']=='1':env,_=unseen(n,int(source['TruthOnsetFrame']),int(source['RiseFrames']),source['Shape'])
                    y=x*(1+float(source['AmplitudeFraction'])*env)
                    r=expand(y,start,end,float(source['OnsetFrame']),source['Status'],mask)
                    if source['Status']=='construction_unavailable':r.update(AmplitudeStatus='construction_unavailable',ExpandedStatus='construction_unavailable')
                    compare(row,r)
                    d=dict.fromkeys(('NativeEnvelopeFraction','ExpandedEnvelopeFraction','ExpandedOracleSource',
                        'ExpandedOracleImposed','ExpandedOracleReferenceEffect','ExpandedDecompositionResidual','OracleSourceOnlyWindowGain'),np.nan)
                    if source['Constructible']=='1' and r['ArithmeticValid']:
                        d['NativeEnvelopeFraction']=env[int(r['NativePeakFrame'])-1]/max(env)
                        if r['ExpandedArithmeticValid']:
                            p=int(r['ExpandedPeakFrame'])-1;pre=slice(int(r['ReferenceStartFrame'])-1,int(r['ReferenceEndFrame']))
                            bx=np.mean(x[pre]);by=np.mean(y[pre]);src=(x[p]-bx)/bx;imp=(y[p]-x[p])/bx;eff=y[p]*(bx-by)/(bx*by)
                            d.update(ExpandedEnvelopeFraction=env[p]/max(env),ExpandedOracleSource=src,ExpandedOracleImposed=imp,
                                ExpandedOracleReferenceEffect=eff,ExpandedDecompositionResidual=r['ExpandedSignedAmplitude']-src-imp-eff,
                                OracleSourceOnlyWindowGain=(max(x[int(source['OnsetFrame'])-1:end])-max(x[start-1:end]))/bx)
                            require(abs(d['ExpandedDecompositionResidual'])<1e-10,'Decomposition identity');count+=1
                    compare(row,d)
        finally:
            if h is not None:h.close()
        print('VERIFIED EXPANDED PEAK',session,flush=True)
    nc=challenges(root)
    summaries=[]
    for fields in (('Cohort',),('Session',),('Cohort','Shape'),('Cohort','Shape','RiseFrames','DelayFrames')):
        for group in sorted({tuple(r[k] for k in fields) for r in output}):
            rr=[r for r in output if tuple(r[k] for k in fields)==group and r['Constructible']=='1']
            available=[r for r in rr if r['ExpandedArithmeticValid']=='1']
            f=lambda k:sum(float(r[k])>=.9 for r in available)
            summaries.append(dict(Grouping='+'.join(fields),Group='|'.join(group),Constructible=len(rr),
                NativeAvailable=sum(r['ArithmeticValid']=='1' for r in rr),ExpandedAvailable=len(available),
                NativePositive=sum(r['PositiveAmplitudeEligible']=='1' for r in rr),ExpandedPositive=sum(r['ExpandedPositiveEligible']=='1' for r in rr),
                PeakMovesEarlier=sum(r['PeakPrecedesNative']=='1' for r in available),
                NativeEnvelopeAtLeast90Percent=f('NativeEnvelopeFraction'),ExpandedEnvelopeAtLeast90Percent=f('ExpandedEnvelopeFraction'),
                NearPeakGained=sum(float(r['NativeEnvelopeFraction'])<.9 and float(r['ExpandedEnvelopeFraction'])>=.9 for r in available),
                NearPeakLost=sum(float(r['NativeEnvelopeFraction'])>=.9 and float(r['ExpandedEnvelopeFraction'])<.9 for r in available),
                NativeOutsideImposed=sum(float(r['NativeEnvelopeFraction'])==0 for r in available),ExpandedOutsideImposed=sum(float(r['ExpandedEnvelopeFraction'])==0 for r in available),
                NewOutsideImposed=sum(float(r['NativeEnvelopeFraction'])>0 and float(r['ExpandedEnvelopeFraction'])==0 for r in available),
                ExpandedPeakBeforeTruth=sum(float(r['ExpandedPeakFrame'])<float(r['TruthOnsetFrame']) for r in available),
                SourceOnlyWindowGain=sum(float(r['OracleSourceOnlyWindowGain'])>1e-12 for r in available),
                BaselineAboveOnePercent=sum(float(r['OracleBaselineImposedFraction'])>.01 for r in available)))
    write_csv(root/'peak-summary.csv',summaries)
    counts=Counter((r['Cohort'],'control' if r['Shape']=='control' else 'recipe',r['ExpandedStatus']) for r in output)
    write_csv(root/'status-summary.csv',[dict(Cohort=k[0],Kind=k[1],Status=k[2],Count=v) for k,v in sorted(counts.items())])
    controls=[r for r in output if r['Shape']=='control'];write_csv(root/'source-controls.csv',controls)
    cs=[]
    for cohort in ('development','additional','noiseless'):
        rr=[r for r in controls if r['Cohort']==cohort];valid=[r for r in rr if r['ExpandedArithmeticValid']=='1']
        increases=[100*float(r['AmplitudeIncrease']) for r in valid]
        cs.append(dict(Cohort=cohort,Controls=len(rr),Available=len(valid),
            LargerMaximum=sum(a>1e-10 for a in increases),
            MaximumIncreasePP=max(increases) if increases else np.nan))
    write_csv(root/'control-summary.csv',cs)
    negatives=[r for r in output if r['AmplitudeStatus']=='raw_direction_conflict'];require(len(negatives)==18,'Negative-case scope')
    write_csv(root/'previous-negative-cases.csv',negatives)
    expected=dict(Rows=11433,SourceRecordings=6,RecordedSupports=308,NoiselessSupports=1,ConstructibleRecipes=10476,
        SourceControls=309,FixedOnsetChallenges=8,CodeAndInputFreezeVerified=True,ProductionChanged=False,OnsetRefits=0)
    require(json.loads((root/'completion.json').read_text())==expected,'Completion scope')
    for r in inputs:require(sha(r['Path'])==r['SHA256'],'Input changed during verification')
    return dict(RowsVerified=len(output),ExpandedDecompositionsVerified=count,NeighborChallengesVerified=nc,
        PreviousNegativeCasesVerified=len(negatives),InputHashesVerified=len(inputs),ProductionChanged=False,OnsetRefits=0)


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('selector');p.add_argument('eligibility');p.add_argument('root');a=p.parse_args()
    result=verify(a.selector,a.eligibility,a.root)
    (Path(a.root)/'independent-verification.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
