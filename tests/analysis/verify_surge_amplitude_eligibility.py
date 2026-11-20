"""Independently replay amplitude eligibility and paired-source decomposition."""
import argparse
import json
from collections import Counter
from pathlib import Path

import h5py
import numpy as np
from verify_surge_separation import rows, sha, require, read_pixels
from verify_surge_onset_trace_panel import compare, write_csv
from verify_surge_model_selection import unseen


def assess(y, start, end, onset, status, blocked, fs=1):
    y = np.asarray(y, dtype=float)
    r = dict(AmplitudeStatus='onset_unresolved', ArithmeticValid=False,
        PositiveAmplitudeEligible=False, SignedRawAmplitude=np.nan,
        ProvisionalPositiveAmplitude=np.nan, ReferenceStartFrame=np.nan,
        ReferenceEndFrame=np.nan, ReferenceMean=np.nan, NativePeakFrame=np.nan,
        NativePeakValue=np.nan, FirstHalfReferenceMean=np.nan,
        SecondHalfReferenceMean=np.nan, ReferenceHalfChangeFraction=np.nan,
        FirstHalfAmplitude=np.nan, SecondHalfAmplitude=np.nan,
        PositiveAcrossReferenceHalves=False)
    if status != 'resolved':
        return r
    count = max(1, int(np.floor(20*fs+.5)))
    if not np.isfinite(onset) or onset != int(onset) or onset > start:
        r['AmplitudeStatus'] = 'invalid_onset'
        return r
    onset = int(onset)
    if onset-count < 1:
        r['AmplitudeStatus'] = 'incomplete_reference'
        return r
    first, last = onset-count-1, onset-1
    r.update(ReferenceStartFrame=first+1, ReferenceEndFrame=last)
    if np.any(blocked[first:last]):
        r['AmplitudeStatus'] = 'overlapping_reference'
        return r
    reference = y[first:last]
    if not np.all(np.isfinite(reference)):
        r['AmplitudeStatus'] = 'nonfinite_reference'
        return r
    baseline = float(np.mean(reference))
    r['ReferenceMean'] = baseline
    if not np.isfinite(baseline):
        r['AmplitudeStatus'] = 'nonfinite_reference_mean'
        return r
    if baseline <= 0:
        r['AmplitudeStatus'] = 'nonpositive_reference'
        return r
    native = y[start-1:end]
    if not np.all(np.isfinite(native)):
        r['AmplitudeStatus'] = 'missing_native_signal'
        return r
    p = start-1+int(np.argmax(native))
    amplitude = float(y[p]/baseline-1)
    r.update(SignedRawAmplitude=amplitude, NativePeakValue=float(y[p]),
        NativePeakFrame=p+1, ArithmeticValid=bool(np.isfinite(amplitude)))
    if not np.isfinite(amplitude):
        r['AmplitudeStatus'] = 'nonfinite_amplitude'
        return r
    if count >= 2:
        a, b = float(np.mean(reference[:count//2])), float(np.mean(reference[count//2:]))
        r.update(FirstHalfReferenceMean=a, SecondHalfReferenceMean=b,
            ReferenceHalfChangeFraction=(b-a)/baseline,
            FirstHalfAmplitude=float(y[p]/a-1) if a > 0 else np.nan,
            SecondHalfAmplitude=float(y[p]/b-1) if b > 0 else np.nan)
        r['PositiveAcrossReferenceHalves'] = bool(all(np.isfinite(r[k]) and r[k] > 0
            for k in ('FirstHalfAmplitude', 'SecondHalfAmplitude')))
    if amplitude < 0:
        r['AmplitudeStatus'] = 'raw_direction_conflict'
    elif amplitude == 0:
        r['AmplitudeStatus'] = 'no_positive_raw_change'
    else:
        r.update(AmplitudeStatus='positive_raw_change_provisional',
            PositiveAmplitudeEligible=True, ProvisionalPositiveAmplitude=amplitude)
    return r


def key(r):
    return (r['Session'], int(r['EventRow']), r['Shape'], int(r['RiseFrames']),
        float(r['AmplitudeFraction']), int(r['DelayFrames']))


def verify(prior, root):
    prior, root = Path(prior), Path(root)
    manifest = rows(root/'input-manifest.csv')
    require(len(manifest) == 10, 'Input scope')
    for r in manifest:
        require(sha(r['Path']) == r['SHA256'], 'Changed input '+r['Path'])
    original = [r for name in ('unseen-results.csv', 'unseen-controls.csv')
        for r in rows(prior/name) if r['Context'] == 'selection']
    output = rows(root/'amplitude-eligibility-results.csv')
    originals, results = {key(r): r for r in original}, {key(r): r for r in output}
    require(len(originals) == len(results) == len(output) == 11433, 'Row scope')
    require(originals.keys() == results.keys(), 'Row identities')
    flagged = {key(r) for r in rows(prior/'resolved-measurement-review.csv')}
    require(len(flagged) == 89, 'Flagged scope')
    trace_samples, review = [], []
    backgrounds = rows(prior/'backgrounds.csv')
    for session in dict.fromkeys(b['Session'] for b in backgrounds):
        group = [b for b in backgrounds if b['Session'] == session]
        h = None
        if session != 'flat':
            h = h5py.File(group[0]['CachePath'])
            traces = h['XTrace'][()].T
            pxrefs, maskrefs = h['Pixels'][()].ravel(), h['AllDetectedPixels'][()].ravel()
        try:
            for b in group:
                n, start, end = (int(b[k]) for k in ('Frames','NativeStartFrame','NativeEndFrame'))
                blocked = np.zeros(n, bool)
                if session == 'flat':
                    x = np.full(n,100.)
                else:
                    i = int(b['LocalRow'])-1
                    x = traces[i]
                    px = read_pixels(h,h[pxrefs[i]])
                    for f in range(max(0,start-61), start-1):
                        blocked[f] = np.intersect1d(px,read_pixels(h,h[maskrefs[f]])).size > 0
                selected = [r for r in original if r['Session']==session and r['EventRow']==b['EventRow']]
                require(len(selected)==37, 'Support scope')
                for old in selected:
                    row = results[key(old)]
                    require(all(old[k] == row[k] for k in old), 'Changed frozen decision')
                    env = np.zeros(n)
                    if old['Constructible'] == '1':
                        env,_ = unseen(n,int(old['TruthOnsetFrame']),int(old['RiseFrames']),old['Shape'])
                    y = x*(1+float(old['AmplitudeFraction'])*env)
                    r = assess(y,start,end,float(old['OnsetFrame']),old['Status'],blocked)
                    if old['Status']=='construction_unavailable':
                        r['AmplitudeStatus']='construction_unavailable'
                    compare(row,r)
                    d = dict.fromkeys(('OracleSourceAtObservedPeak','OracleImposedAtObservedPeak',
                        'OracleBaselineEffect','OracleBaselineImposedFraction',
                        'OracleReferencePositiveFrames','DecompositionResidual'), np.nan)
                    if r['ArithmeticValid']:
                        require(np.isclose(r['SignedRawAmplitude'],float(old['ProvisionalAmplitude']),atol=1e-12), 'Signed arithmetic changed')
                        if old['Constructible']=='1':
                            pre = slice(int(r['ReferenceStartFrame'])-1,int(r['ReferenceEndFrame']))
                            p = int(r['NativePeakFrame'])-1
                            bx, by = np.mean(x[pre]), np.mean(y[pre])
                            source = (x[p]-bx)/bx
                            imposed = (y[p]-x[p])/bx
                            effect = y[p]*(bx-by)/(bx*by)
                            d.update(OracleSourceAtObservedPeak=source,OracleImposedAtObservedPeak=imposed,
                                OracleBaselineEffect=effect,OracleBaselineImposedFraction=(by-bx)/bx,
                                OracleReferencePositiveFrames=int(np.count_nonzero(env[pre])),
                                DecompositionResidual=r['SignedRawAmplitude']-source-imposed-effect)
                            require(abs(d['DecompositionResidual'])<1e-10,'Decomposition identity')
                    compare(row,d)
                    if key(old) in flagged:
                        mechanism = 'reference_contamination_above_one_percent'
                        if r['SignedRawAmplitude'] < 0:
                            mechanism = 'reference_changes_sign' if d['OracleSourceAtObservedPeak']+d['OracleImposedAtObservedPeak'] >= 0 else 'source_fluctuation_dominates'
                        review.append(dict(row,ReviewCase=len(review)+1,OracleFailureMechanism=mechanism))
                        case = len(review)
                        for f in range(max(0,int(old['FitStartFrame'])-21),min(n,end+15)):
                            trace_samples.append(dict(Case=case,Session=session,EventRow=b['EventRow'],
                                Frame=f+1,Source=x[f],Constructed=y[f],Imposed=y[f]-x[f],
                                ReferenceMean=r['ReferenceMean'],TruthOnset=old['TruthOnsetFrame'],
                                EstimatedOnset=old['OnsetFrame'],ReferenceStart=r['ReferenceStartFrame'],
                                ReferenceEnd=r['ReferenceEndFrame'],NativeStart=start,NativeEnd=end))
        finally:
            if h is not None:
                h.close()
        print('VERIFIED AMPLITUDE ELIGIBILITY',session,flush=True)
    require(len(review)==89, 'Review coverage')
    write_csv(root/'flagged-case-decomposition.csv',review)
    write_csv(root/'flagged-trace-samples.csv',trace_samples)
    counts = Counter((r['Cohort'],'control' if r['Shape']=='control' else 'recipe',r['AmplitudeStatus']) for r in output)
    write_csv(root/'status-summary.csv',[dict(Cohort=k[0],Kind=k[1],Status=k[2],Count=v) for k,v in sorted(counts.items())])
    summaries=[]
    for fields in (('Cohort',),('Session',),('Cohort','Shape')):
        groups = sorted({tuple(r[k] for k in fields) for r in output})
        for group in groups:
            rr=[r for r in output if tuple(r[k] for k in fields)==group and r['Constructible']=='1']
            valid=[r for r in rr if r['ArithmeticValid']=='1']
            positive=[r for r in valid if r['PositiveAmplitudeEligible']=='1']
            bad=[r for r in positive if float(r['OracleBaselineImposedFraction'])>.01]
            stable=lambda r:r['PositiveAcrossReferenceHalves']=='1'
            summaries.append(dict(Grouping='+'.join(fields),Group='|'.join(group),Constructible=len(rr),
                ArithmeticValid=len(valid),PositiveEligible=len(positive),DirectionConflict=sum(r['AmplitudeStatus']=='raw_direction_conflict' for r in valid),
                BaselineAboveOnePercent=len(bad),BaselineAboveOnePercentStillPositiveAcrossHalves=sum(stable(r) for r in bad),
                PositiveButHalfSensitive=sum(not stable(r) for r in positive),
                HalfSensitiveWithoutAboveOnePercent=sum(not stable(r) and float(r['OracleBaselineImposedFraction'])<=.01 for r in positive)))
    write_csv(root/'eligibility-summary.csv',summaries)
    expected = dict(Rows=11433,SourceRecordings=6,RecordedSupports=308,NoiselessSupports=1,
        ConstructibleRecipes=10476,SourceControls=309,CodeAndInputFreezeVerified=True,
        ProductionChanged=False,OnsetRefits=0)
    require(json.loads((root/'completion.json').read_text())==expected,'Completion scope')
    for r in manifest:
        require(sha(r['Path'])==r['SHA256'],'Input changed during verification')
    return dict(RowsVerified=len(output),FlaggedCasesVerified=len(review),
        DecompositionsVerified=sum(r['Constructible']=='1' and r['ArithmeticValid']=='1' for r in output),
        TraceSamplesExported=len(trace_samples),InputHashesVerified=len(manifest),OnsetRefits=0,ProductionChanged=False)


if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('prior');parser.add_argument('root');args=parser.parse_args()
    result=verify(args.prior,args.root)
    (Path(args.root)/'independent-verification.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))
