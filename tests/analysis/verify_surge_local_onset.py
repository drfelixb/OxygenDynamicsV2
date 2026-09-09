"""Independent NumPy fit and cached-mask exclusion check; no biological labels."""
import argparse
import json
from pathlib import Path
import h5py
import numpy as np
from verify_surge_separation import require, rows, sha, read_pixels, SESSIONS
from verify_surge_amplitude_support import same


def estimate(x, start, end, blocked):
    """Reference protocol for the audited 1 Hz movies. Frames returned 1-based."""
    first, last = start-60, min(end, start+4)
    names = ('OnsetFrame BestCandidateFrame ScoreImprovement ProfileStartFrame ProfileEndFrame '
             'ProfileSpanSec BaselineSlopePerSecOverFitMedian PostSlopePerSecOverFitMedian '
             'BaselineStartFrame BaselineEndFrame BaselineMean ProvisionalAmplitude').split()
    r = dict.fromkeys(names, np.nan)
    r.update(Status='unassessed', BaselineStatus='onset_unresolved', FitStartFrame=first, FitEndFrame=last)
    if first<1:
        r['Status']='recording_boundary_unresolved';return r
    y=x[first-1:last]
    if not np.all(np.isfinite(y)):
        r['Status']='nonfinite_fit';return r
    if np.any(blocked[first-1:start-1]):
        r['Status']='overlapping_detection_in_fit';return r
    scale=np.median(np.abs(y))
    if scale<=0:
        r['Status']='nonpositive_scale';return r
    y=y/scale;t=np.arange(first,last+1)-start;n=len(y)
    d=np.column_stack((np.ones(n),t));q=np.linalg.lstsq(d,y,rcond=None)[0]
    sse0=max(np.sum((y-d@q)**2),n*1e-20)
    candidates=np.arange(start-40,start+1);scores=[];coeff=[]
    for k in candidates:
        h=np.column_stack((d,np.maximum(0,t-(k-1-start))))
        q=np.linalg.lstsq(h,y,rcond=None)[0];coeff.append(q)
        scores.append(n*np.log(sse0/max(np.sum((y-h@q)**2),n*1e-20))-2*np.log(n))
    scores=np.array(scores);j=int(np.argmax(scores));k=int(candidates[j]);q=coeff[j]
    profile=candidates[scores>=scores[j]-2]
    r.update(BestCandidateFrame=k,ScoreImprovement=scores[j],ProfileStartFrame=profile[0],
             ProfileEndFrame=profile[-1],ProfileSpanSec=profile[-1]-profile[0],
             BaselineSlopePerSecOverFitMedian=q[1],PostSlopePerSecOverFitMedian=q[1]+q[2])
    if scores[j]<10:r['Status']='insufficient_improvement'
    elif q[2]<=0 or q[1]+q[2]<=0:r['Status']='not_a_rising_change'
    elif k in (start-40,start):r['Status']='search_boundary_unresolved'
    elif profile[-1]-profile[0]>10:r['Status']='broad_profile_unresolved'
    else:
        b=np.mean(x[k-21:k-1]);r.update(Status='resolved',OnsetFrame=k,BaselineStartFrame=k-20,
                                     BaselineEndFrame=k-1,BaselineMean=b,BaselineStatus='nonpositive_baseline')
        if not np.all(np.isfinite(x[start-1:end])):r['BaselineStatus']='missing_native_signal'
        elif b>0:r.update(BaselineStatus='provisional_valid',ProvisionalAmplitude=np.max(x[start-1:end])/b-1)
    return r


def verify(cache, output):
    cache, output=Path(cache),Path(output)
    for r in rows(output/'input-manifest.csv'):require(sha(r['Path'])==r['SHA256'],'Changed cached input')
    actual=rows(output/'onset-results.csv');keys={(r['Session'],r['Case'],int(r['EventRow']),r['TraceKind']):r for r in actual}
    require(len(keys)==len(actual),'Duplicate result')
    count=0;selected=0;case_rows=[]
    for session in SESSIONS:
        for case in ('growing_clean','shrinking_clean'):
            folder=cache/session/case;m=json.loads((folder/'provenance.json').read_text())
            require(m['SampleHz']==1 and m['BaselineFrames']==20 and m['Windows']==[101,160],'Protocol changed')
            ts=[r for r in rows(folder/'support-results.csv') if r['Support']=='full_event']
            resolutions=dict(constructed=0,source=0)
            with h5py.File(folder/'audit-inputs.mat') as h:
                x=h['XTrace'][()].T;y=h['YTrace'][()].T;p=h['PositiveTrace'][()].T
                masks=[read_pixels(h,h[z]) for z in h['AllDetectedPixels'][()].ravel()]
                for row in ts:
                    i=int(row['LocalRow'])-1;event=int(row['EventRow']);start=int(row['StartFrame']);end=int(row['EndFrame'])
                    px=read_pixels(h,h[h['Pixels'][()].ravel()[i]])
                    blocked=np.array([np.intersect1d(px,mask).size>0 for mask in masks])
                    match=row['IsPreselectedMatch']=='1';selected+=match
                    for kind,trace in (('constructed',y[i]),('source',x[i])):
                        result=estimate(trace,start,end,blocked);r=keys.pop((session,case,event,kind))
                        for name,value in result.items():
                            if isinstance(value,str):require(r[name]==value,'Status mismatch: '+name)
                            else:same(r[name],value,name)
                        require((r['IsPreselectedMatch']=='1')==match,'Changed match selection')
                        same(r['StoredAmplitude'],float(row['StoredFullEventAmplitude']),'Stored amplitude')
                        require(r['StoredBaselineStatus']==row['StrictBaselineStatus'],'Stored baseline status')
                        diag=dict.fromkeys(('OnsetOffsetFromImposedStart NativeBaselineImposedFraction '
                                            'ProposedBaselineImposedFraction ProposedBaselinePositiveFrames '
                                            'CounterfactualPeakFraction BaselineEffectPercentagePoints').split(),np.nan)
                        if kind=='constructed':
                            if start>20:
                                bx=np.mean(x[i,start-21:start-1])
                                if bx>0:diag['NativeBaselineImposedFraction']=np.mean(trace[start-21:start-1])/bx-1
                            if result['Status']=='resolved':
                                k=result['OnsetFrame'];pre=slice(k-21,k-1);bx=np.mean(x[i,pre])
                                diag['ProposedBaselinePositiveFrames']=np.count_nonzero(p[i,pre]>0)
                                if match:diag['OnsetOffsetFromImposedStart']=k-101
                                if bx>0:
                                    counter=np.max(trace[start-1:end])/bx-1
                                    diag.update(ProposedBaselineImposedFraction=np.mean(trace[pre])/bx-1,
                                                CounterfactualPeakFraction=counter,
                                                BaselineEffectPercentagePoints=100*(result['ProvisionalAmplitude']-counter))
                        for name,value in diag.items():same(r[name],value,name)
                        resolutions[kind]+=result['Status']=='resolved';count+=1
            case_rows.append(dict(Session=session,Case=case,Events=len(ts),PreselectedEventRow=m['PreselectedEventRow'],
                                  ConstructedResolved=resolutions['constructed'],SourceResolved=resolutions['source']))
    require(not keys and count==456 and selected==5,'Incomplete event/control coverage')
    cases={(r['Session'],r['Case']):r for r in rows(output/'case-summary.csv')}
    require(len(cases)==8,'Incomplete case ledger')
    for case in case_rows:
        r=cases[(case['Session'],case['Case'])]
        for key in ('Events','PreselectedEventRow','ConstructedResolved','SourceResolved'):same(r[key],case[key],key)
    expected=[r for r in actual if r['IsPreselectedMatch']=='1' and r['TraceKind']=='constructed']
    require(rows(output/'preselected-results.csv')==expected,'Incomplete selected ledger')
    completion=json.loads((output/'completion.json').read_text())
    require(completion==dict(FrozenMovies=8,SourceRecordings=4,RetainedEvents=228,TraceEvaluations=456,
                            PreselectedMatches=5,CodeAndInputFreezeVerified=True,ProductionChanged=False,
                            NewDetectionOrMasterRuns=0),'Completion scope mismatch')
    return dict(TraceFitsVerified=count,FixedSupportsVerified=count//2,CasesVerified=8,
                PreselectedMatches=selected,IndependentMaskExclusions=True,ProductionChanged=False)


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('cache');parser.add_argument('output')
    args=parser.parse_args();result=verify(args.cache,args.output)
    (Path(args.output)/'independent-verification.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))
