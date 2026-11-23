"""Sixteen finite synthetic scenes for the approved video detector revision."""
from pathlib import Path
import json
import sys
import time

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'prototypes'))
sys.path.insert(0, str(Path(__file__).resolve().parent))
from testBOIVideoDetectorPrototype import scene
from boi_video_detector.service import mean_trace, native_indices
from boi_video_detector.revision import (EpisodeSettings, detect_episodes,
                                         native_support, trace_seeds, search_context)


def run(destination):
    start = time.monotonic()
    settings = EpisodeSettings()
    names = ['localized', 'shared', 'spreading_persistent', 'local_with_field_drift',
             'weak_gradual', 'recurrent_changed_state',
             'recurrent_without_intervening_return', 'changing_mask_bias',
             'split_merge', 'vascular_gap', 'motion', 'noise', 'missing',
             'recording_start', 'recording_end', 'sampling_coordinates']
    results = []
    for i, name in enumerate(names):
        raw, denoised = scene(name, 72310+i)
        fs = 2. if name == 'sampling_coordinates' else 1.
        detected = detect_episodes(raw, denoised, fs, settings)
        candidates = detected['Catalogue']
        seeds = detected['Seeds']
        coverage = detected['Coverage']
        assert coverage.shape == (len(raw), 4)
        assert coverage[:, 2].sum() == len(seeds)
        assert len(detected['SeedGroup']) == len(seeds)
        assert len(detected['StageCoverage']) == 12
        assert all(s['LocationsSearched'] == int(detected['Context']['Domain'].sum())
                   and s['FramesPerLocation'] == len(raw) for s in detected['StageCoverage'])
        for c in candidates:
            index = detected['ComparisonMasks'][c['CandidateID']]
            assert len(index) == c['ComparisonFootprintBlocks']
            assert np.all(detected['Context']['Domain'].ravel()[index])
            assert 1 <= c['SpatialFirstFrame'] <= c['SpatialLastFrame'] <= len(raw)
            assert not c['MeasurementReady'] and not c['ScientificBurdenAvailable']
        local = [c for c in candidates if c['Status'].startswith('local_reversible')]
        central = []
        target = np.zeros(raw.shape[1:], bool)
        target[24:37, 22:35] = True
        for c in local:
            idx = detected['ComparisonMasks'][c['CandidateID']]
            if target.ravel()[idx].sum() >= max(1, .25*len(idx)):
                central.append(c)
        checks = {}
        if name in ['localized', 'local_with_field_drift', 'weak_gradual']:
            checks['central_episode_proposed_and_raw_supported'] = bool(central)
        if name in ['shared', 'spreading_persistent', 'changing_mask_bias', 'noise', 'motion']:
            checks['no_closed_local_candidate'] = not local
        if name == 'recurrent_changed_state':
            checks['both_central_episode_periods_found'] = (
                any(c.get('TroughFrame', 0) < 100 for c in central)
                and any(c.get('TroughFrame', 0) > 145 for c in central))
        if name == 'recurrent_without_intervening_return':
            checks['no_early_closed_central_recovery'] = not any(
                c.get('RecoveryFrameRange') and c['RecoveryFrameRange'][1] < 140
                for c in central)
        if name == 'vascular_gap':
            checks['unobservable_gap_not_in_search_cohort'] = not np.any(
                detected['Context']['Domain'][:, 29:31])
        if name == 'motion':
            checks['motion_observation_flagged'] = bool(detected['Context']['MotionFlag'].any())
        if name == 'missing':
            checks['missing_evidence_retained'] = any(
                'missing' in c['Status'] or any('missing' in f for f in c['Flags'])
                for c in candidates)
        if name == 'recording_start':
            checks['left_boundary_retained_as_incomplete'] = any(
                c['Status'] == 'incomplete_preceding_state' for c in candidates)
        if name == 'recording_end':
            checks['right_boundary_retained_as_incomplete'] = any(
                c['BoundaryCode'] == 2 and not c['Status'].startswith('local_reversible')
                for c in candidates)
        counts = {}
        for c in candidates:
            counts[c['Status']] = counts.get(c['Status'], 0)+1
        row = {'Scene': name, 'Seeds': len(seeds), 'Candidates': len(candidates),
               'Statuses': counts, 'GeometryAndCoverageInvariants': True,
               'BehaviourChecks': checks}
        results.append(row)
        print(json.dumps(row), flush=True)
    # Missing matched-cohort pixels cannot be silently discarded.
    x = np.ones((20, 8, 8), np.float32)
    cohort = np.zeros((8, 8), bool)
    cohort[2:5, 2:5] = True
    x[7, 3, 3] = np.nan
    assert np.isnan(mean_trace(x, cohort)[7])
    # A dim but valid patch stays searchable in a brighter field and dark offset.
    dim = np.ones((40, 16, 16), np.float32)*1000
    dim[:, :4] = 400
    dim[:, 6:10, 6:10] = 600
    dim[15:25, 6:10, 6:10] = 500
    context = search_context(dim, 1., settings)
    assert context['Domain'][6:10, 6:10].all()
    # Connected native support keeps a static gap and an isolated weak region out.
    ref = np.ones((24, 24))*100
    current = ref.copy()
    current[5:18, 3:10] = 90
    current[5:18, 12:20] = 90
    native_seed = np.zeros_like(ref, bool)
    native_seed[10, 6] = True
    valid = np.ones_like(ref, bool)
    valid[:, 10:12] = False
    mask, score, observed = native_support(ref, current, ref, np.ones_like(ref), native_seed, valid)
    assert mask[:, 3:10].sum() == 13*7 and not mask[:, 10:].any()
    assert np.isnan(score[:, 10:12]).all() and not observed[:, 10:12].any()
    # With no later rise, a reference decline cannot be called recovered support.
    mask2, _, _ = native_support(ref, current, current, np.ones_like(ref), native_seed, valid)
    assert not mask2.any()
    native = native_indices(np.array([7*128+9]), (128, 128), 4)
    assert len(native) == 16
    assert ((native-1) % 512).min() == 28 and ((native-1)//512).min() == 36
    t = np.arange(120)
    wave = 100-10*np.maximum(0, 1-np.abs(t-60)/20)
    found, _ = trace_seeds(wave, .5, 2., settings)
    assert any(s[0] == 60 and s[-1] == 0 for s in found)
    total = sum(len(r['BehaviourChecks']) for r in results)
    passed = sum(sum(r['BehaviourChecks'].values()) for r in results)
    output = {'Schema': 'boi-video-revision-synthetic-1', 'Scenes': results,
              'BehaviourChecksPassed': passed, 'BehaviourChecksTotal': total,
              'Failures': [{'Scene': r['Scene'], 'Check': k}
                           for r in results for k, v in r['BehaviourChecks'].items() if not v],
              'MissingCohortSafeguard': True, 'NativeConnectedGapSafeguard': True,
              'NativeReturnRequiresObservedRise': True, 'NativeCoordinateConversion': True,
              'SamplingConversion': True, 'ScientificIsolation': True,
              'DimValidTissueRemainsSearchable': True,
              'BiologicalValidation': False, 'ElapsedSec': time.monotonic()-start}
    Path(destination).write_text(json.dumps(output, indent=2)+'\n')
    print(f'Geometry/safeguards pass; specified behaviour {passed}/{total}', flush=True)


if __name__ == '__main__':
    run(sys.argv[1])
