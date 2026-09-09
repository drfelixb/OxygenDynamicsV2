"""Independently verify occupancy supports, paired pixels and amplitude algebra.

Run from the repository root with NumPy, Pillow and h5py. This validates frozen
mask measurements, not physiological detection accuracy or a baseline correction.
"""
import argparse
import json
from pathlib import Path
import h5py
import numpy as np
from PIL import Image
from verify_surge_separation import SESSIONS, require, rows, sha, read_pixels


def same(actual, expected, name):
    require(np.isclose(float(actual), expected, atol=1e-9, rtol=1e-10, equal_nan=True), 'Mismatch: '+name)


def metrics(x, y, pos, neg, event, pre, clean, window, required=20):
    inside = np.intersect1d(event, window)
    result = dict(CleanBaselineFrames=len(clean), PrebaselineFrames=len(pre), NativePeakFrame=np.nan,
                  NativeIntersectionFrames=len(inside), PreFramesWithPositiveIncrement=np.count_nonzero(pos[pre]>0),
                  PreFramesWithNegativeIncrement=np.count_nonzero(neg[pre]<0), StrictMeasuredPeakFraction=np.nan)
    names = ('UnscreenedObservedBaseline UnscreenedSourceBaseline UnscreenedObservedPeakFraction '
             'UnscreenedCounterfactualPeakFraction UnscreenedSourcePeakFraction UnscreenedBaselinePositiveFraction '
             'UnscreenedBaselineNegativeFraction UnscreenedBaselineImposedFraction UnscreenedBaselineEffectFraction '
             'UnscreenedBackgroundAtObservedPeak UnscreenedAppliedAtObservedPeak '
             'PeakPositiveAppliedVsSameFrameSource MinimumNegativeAppliedVsSameFrameSource '
             'PeakNetAppliedVsSameFrameSource PeakPositiveAppliedInNativeIntersection').split()
    result.update(dict.fromkeys(names, np.nan))
    status = 'insufficient_clean_prebaseline'
    if np.all(x[window]>0):
        result.update(PeakPositiveAppliedVsSameFrameSource=np.max(pos[window]/x[window]),
                      MinimumNegativeAppliedVsSameFrameSource=np.min(neg[window]/x[window]),
                      PeakNetAppliedVsSameFrameSource=np.max((y[window]-x[window])/x[window]))
        if len(inside):
            result['PeakPositiveAppliedInNativeIntersection'] = np.max(pos[inside]/x[inside])
    if len(pre) == required:
        b, bx = np.mean(y[pre]), np.mean(x[pre])
        at = event[np.argmax(y[event])]
        result.update(UnscreenedObservedBaseline=b, UnscreenedSourceBaseline=bx, NativePeakFrame=at+1)
        if b>0:
            result['UnscreenedObservedPeakFraction'] = (y[at]-b)/b
        if bx>0:
            result.update(UnscreenedCounterfactualPeakFraction=(y[at]-bx)/bx,
                          UnscreenedSourcePeakFraction=(np.max(x[event])-bx)/bx,
                          UnscreenedBaselinePositiveFraction=np.mean(pos[pre])/bx,
                          UnscreenedBaselineNegativeFraction=np.mean(neg[pre])/bx,
                          UnscreenedBaselineImposedFraction=(b-bx)/bx,
                          UnscreenedBackgroundAtObservedPeak=(x[at]-bx)/bx,
                          UnscreenedAppliedAtObservedPeak=(y[at]-x[at])/bx)
            result['UnscreenedBaselineEffectFraction'] = result['UnscreenedObservedPeakFraction']-result['UnscreenedCounterfactualPeakFraction']
        if len(clean) == required:
            status = 'valid' if b>0 else 'nonpositive_baseline_or_missing_event_signal'
            if b>0:
                result['StrictMeasuredPeakFraction'] = result['UnscreenedObservedPeakFraction']
    return result, status


def verify(root):
    root = Path(root)
    expected = {(s, c) for s in SESSIONS for c in ('growing_clean', 'shrinking_clean')}
    manifests = sorted(root.glob('*/*/provenance.json'))
    require(len(manifests) == 8, 'Expected eight frozen movies')
    seen, hashes, event_count, row_count, empty_count, samples = set(), {}, 0, 0, 0, 0
    root_rows = rows(root/'support-results.csv')
    for path in manifests:
        m = json.loads(path.read_text());key = m['SourceProfile']['Session'], m['Case']
        require(key in expected and key not in seen, 'Duplicate or unexpected case');seen.add(key)
        require(m['BaselineFrames'] == 20 and m['SampleHz'] == 1 and m['Windows'] == [101,160]
                and m['OccupancyFractions'] == [0,.5,.75], 'Changed measurement protocol')
        for file, expected_hash in ((m['SourceTiff'],m['SourceSHA256']), (m['InputTiff'],m['InputSHA256']),
                                    (m['SavedSurgeMat'],m['SavedSurgeMatSHA256']), (m['SavedSinkMat'],m['SavedSinkMatSHA256'])):
            if file not in hashes:hashes[file] = sha(file)
            require(hashes[file] == expected_hash, 'Changed input: '+file)
        records = rows(path.parent/'support-results.csv')
        require(records == [r for r in root_rows if (r['Session'],r['Case']) == key], 'Root and per-case result mismatch')
        ids = {(int(r['EventRow']),r['Support']) for r in records}
        n_events = (len(records)-1)//3
        require(len(records) == 3*n_events+1 and len(ids) == len(records), 'Duplicate/incomplete support rows')
        require(ids == {(e,s) for e in range(1,n_events+1) for s in ('full_event','persistent_50','persistent_75')} | {(0,'recipe_common_core_oracle')}, 'Wrong support identity matrix')
        event_count += n_events;row_count += len(records)
        n, h, w = m['Frames'],m['Height'],m['Width'];window = np.arange(100,160)
        with h5py.File(path.parent/'audit-inputs.mat') as handle:
            require(handle['NativePixels'].shape == (n,n_events), 'Native mask dimensions')
            pixel_refs = handle['Pixels'][()].ravel();clean_refs = handle['CleanFrames'][()].ravel()
            require(len(pixel_refs) == len(records) == len(clean_refs), 'Support cache length')
            pixels = [read_pixels(handle,handle[ref]) for ref in pixel_refs]
            cached_clean = [read_pixels(handle,handle[ref]) for ref in clean_refs]
            traces = [handle[k][()].T for k in ('XTrace','YTrace','PositiveTrace','NegativeTrace')]
            require(all(a.shape == (len(records),n) for a in traces), 'Trace dimensions')
            all_detected = [read_pixels(handle,handle[ref]) for ref in handle['AllDetectedPixels'][()].ravel()]
            supports, baselines = {}, {}
            for e in range(1,n_events+1):
                r = next(r for r in records if int(r['EventRow']) == e and r['Support'] == 'full_event')
                frames = np.arange(int(r['StartFrame'])-1,int(r['EndFrame']))
                values = [read_pixels(handle,handle[handle['NativePixels'][f,e-1]]) for f in frames]
                require(all(len(v)>0 and len(np.unique(v))==len(v) for v in values), 'Empty or duplicate native mask')
                px, counts = np.unique(np.concatenate(values),return_counts=True)
                supports[e,'full_event'] = px
                for fraction in (.5,.75):
                    supports[e,f'persistent_{round(100*fraction)}'] = px[counts>=np.ceil(fraction*len(frames))]
                pre = np.arange(max(0,frames[0]-20),frames[0])
                baselines[e] = pre[[not np.intersect1d(px,all_detected[f]).size for f in pre]]
            yy,xx = np.mgrid[1:h+1,1:w+1];cx,cy = m['CentersXY'][1]
            radius = min(np.asarray(m['RadiusUmByFrame'])[window])/m['SourceProfile']['PixelSize']
            oracle = np.flatnonzero((((xx-cx)**2+(yy-cy)**2)<=radius**2).ravel(order='F'))
            supports[0,'recipe_common_core_oracle'] = oracle
            baselines[0] = np.array([f for f in range(80,100) if not np.intersect1d(oracle,all_detected[f]).size],dtype=int)
            for i,r in enumerate(records):
                e=int(r['EventRow']);identity=e,r['Support']
                require(int(r['LocalRow']) == i+1 and np.array_equal(pixels[i],supports[identity]), 'Occupancy/oracle support mismatch')
                require(np.array_equal(cached_clean[i],baselines[e]), 'Baseline exclusions not shared with full support')
                same(r['SupportPixels'],len(pixels[i]),'SupportPixels')
                same(r['SupportAreaUm2'],len(pixels[i])*m['SourceProfile']['PixelSize']**2,'SupportAreaUm2')
                same(r['SharedCleanBaselineFrames'],len(baselines[e]),'SharedCleanBaselineFrames')
                require((r['IsPreselectedMatch'] in ('1','true')) == (e>0 and e==m['PreselectedEventRow']), 'Changed preselected match')
                if not len(pixels[i]):
                    empty_count+=1
                    require(r['SupportStatus']=='empty_support' and r['StrictBaselineStatus']=='empty_support'
                            and all(np.all(np.isnan(a[i])) for a in traces), 'Empty support fallback')
            # Pixel means and signed contributions independently reconstructed
            # from complete source/challenge movies, with fixed support per row.
            with Image.open(m['SourceTiff']) as source, Image.open(m['InputTiff']) as challenge:
                require(source.n_frames==challenge.n_frames==n and source.size==challenge.size==(w,h),'TIFF dimensions')
                for f in range(n):
                    source.seek(f);challenge.seek(f)
                    x=np.asarray(source,dtype=float).ravel(order='F');y=np.asarray(challenge,dtype=float).ravel(order='F');delta=y-x
                    for i,px in enumerate(pixels):
                        if not len(px):continue
                        expected_trace = [x[px].mean(),y[px].mean(),np.maximum(delta[px],0).mean(),np.minimum(delta[px],0).mean()]
                        require(np.allclose([a[i,f] for a in traces],expected_trace,atol=1e-8,rtol=1e-10),'Raw support trace mismatch')
                        samples+=1
            for i,r in enumerate(records):
                if not len(pixels[i]):continue
                event=np.arange(int(r['StartFrame'])-1,int(r['EndFrame']));pre=np.arange(max(0,event[0]-20),event[0])
                result,status=metrics(*(a[i] for a in traces),event,pre,cached_clean[i],window)
                for field,value in result.items():same(r[field],value,field)
                require(r['StrictBaselineStatus']==status and r['SupportStatus']=='available','Baseline/support status mismatch')
                if r['Support']=='full_event':same(r['StoredFullEventAmplitude'],result['StrictMeasuredPeakFraction'],'StoredAmplitude')
        print('VERIFIED',*key,flush=True)
    require(seen==expected and row_count==len(root_rows),'Incomplete case matrix')
    original=rows(root/'original-amplitude-audit.csv')
    require(len(original)==event_count and all(r['MeasurementMatches'] in ('1','true') for r in original),'Original audit mismatch')
    completion=json.loads((root/'completion.json').read_text())
    require(completion['RetainedSurgeEventsAudited']==event_count and completion['SupportRowsIncludingOracles']==row_count
            and completion['CodeFreezeVerified'] and completion['NewDetectionRuns']==0,'Completion mismatch')
    result=dict(FrozenMoviesVerified=8,SourceRecordings=4,RetainedSurgeEventsVerified=event_count,
                SupportRowsIncludingOraclesVerified=row_count,EmptySupportsVerified=empty_count,
                SupportFrameMeansRebuilt=samples,SharedBaselineExclusionsVerified=True,
                IndependentOccupancySupportsVerified=True,OriginalAmplitudeMismatches=0,IndependentImageSegmentation=False)
    (root/'independent-verification.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))


if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('root');verify(parser.parse_args().root)
