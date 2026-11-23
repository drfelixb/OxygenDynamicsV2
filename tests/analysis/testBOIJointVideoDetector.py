"""Twenty fixed constructed scenes; labels here never come from recording outcomes."""
import hashlib
import numpy as np
from boi_joint_video_detector.service import (Settings, detect, assess, patch_bank, motion_evidence)
from boi_joint_video_detector.numeric import strict_mean

EXPECTATIONS = [
    {'ID': '01-quiet', 'Expected': 'No local-cycle promotion in quiet heteroscedastic observations'},
    {'ID': '02-regional-decline', 'Expected': 'Persistent/edge evidence without a recovered local promotion'},
    {'ID': '03-static-network', 'Expected': 'Static capillary-like darkness and common variation do not establish local pockets'},
    {'ID': '04-field-cycle', 'Expected': 'Shared reversible field cycle retained as regional or uncertain, not local'},
    {'ID': '05-local-cycle', 'Expected': 'Localized fall and return retained as local-cycle candidate'},
    {'ID': '06-flat-low', 'Expected': 'Localized cycle with a low interval of at least eight samples'},
    {'ID': '07-slow-fall', 'Expected': 'Independent slow fall and faster return represented'},
    {'ID': '08-slow-return', 'Expected': 'Independent faster fall and slow return represented'},
    {'ID': '09-responding-neighbor', 'Expected': 'Core cycle retained with responding surroundings; no quiet-control claim'},
    {'ID': '10-cycle-on-decline', 'Expected': 'Localized cycle retained on a declining regional background'},
    {'ID': '11-collinear-field', 'Expected': 'Indistinguishable common/local explanations are not promoted as an established local cycle'},
    {'ID': '12-moving-level', 'Expected': 'Local-route proposal retained; relative return does not accept a raw reference'},
    {'ID': '13-earlier-larger', 'Expected': 'Later smaller cycle remains proposed despite an earlier larger cycle'},
    {'ID': '14-recurrence', 'Expected': 'Evidence of both low periods or an explicit contact alternative; no accepted shared baseline'},
    {'ID': '15-start-truncated', 'Expected': 'Start-censored evidence with no fabricated preceding scientific state'},
    {'ID': '16-end-truncated', 'Expected': 'End-censored evidence with no fabricated recovery'},
    {'ID': '17-dim-valid', 'Expected': 'All finite dim signal searched and a local-cycle proposal retained'},
    {'ID': '18-displacement', 'Expected': 'Global displacement-like frame evidence is flagged without motion correction'},
    {'ID': '19-gaps-contacts', 'Expected': 'Both lobes have unsmoothed seed evidence; their static gap is not filled'},
    {'ID': '20-missing-cohort', 'Expected': 'A missing fixed-cohort observation prevents certain recovery/promotion'},
]


def cycle(n, start, fall, low, rise):
    q = np.zeros(n)
    end = start + fall + low + rise
    q[start:start + fall] = np.linspace(0, 1, fall, endpoint=False)
    q[start + fall:start + fall + low] = 1
    q[start + fall + low:end] = np.linspace(1, 0, rise, endpoint=False)
    return q


def scene(number):
    n, h, w = 240, 32, 32
    rng = np.random.default_rng(91000 + number)
    yy, xx = np.mgrid[:h, :w]
    level = 200 + 8 * np.sin(xx / 3) + 12 * np.cos(yy / 4)
    level[(xx % 9 == 0) | (yy % 11 == 0)] -= 40
    raw = level[None] + rng.normal(size=(n, h, w)) * (.7 + xx[None] / 40)
    mask = (yy >= 12) & (yy < 18) & (xx >= 12) & (xx < 18)
    q = cycle(n, 70, 12, 8, 14)
    facts = {'Mask': np.flatnonzero(mask.ravel()), 'Target': [70, 105], 'Q': q}
    if number == 1:
        pass
    elif number == 2:
        raw -= np.arange(n)[:, None, None] * .25
    elif number == 3:
        raw += (1.8 * np.sin(np.arange(n) / 3))[:, None, None]
    elif number == 4:
        raw -= 30 * q[:, None, None]
    elif number == 5:
        raw[:, mask] -= 30 * q[:, None]
    elif number == 6:
        q = cycle(n, 65, 10, 30, 10)
        raw[:, mask] -= 30 * q[:, None]; facts['Target'] = [65, 116]
    elif number == 7:
        q = cycle(n, 60, 35, 4, 6)
        raw[:, mask] -= 30 * q[:, None]; facts['Target'] = [60, 106]
    elif number == 8:
        q = cycle(n, 65, 6, 4, 35)
        raw[:, mask] -= 30 * q[:, None]; facts['Target'] = [65, 111]
    elif number == 9:
        near = (yy >= 8) & (yy < 22) & (xx >= 8) & (xx < 22) & ~mask
        raw[:, near] -= 10 * q[:, None]
        raw[:, mask] -= 30 * q[:, None]
    elif number == 10:
        raw -= .12 * np.arange(n)[:, None, None]
        raw[:, mask] -= 30 * q[:, None]
    elif number == 11:
        raw -= 30 * q[:, None, None]
        raw[:, mask] -= 3 * q[:, None]
    elif number == 12:
        raw -= .55 * np.arange(n)[:, None, None]
        raw[:, mask] -= 30 * q[:, None]
    elif number == 13:
        first = cycle(n, 35, 15, 20, 15)
        q = cycle(n, 145, 7, 5, 8)
        raw[:, mask] -= 50 * first[:, None] + 22 * q[:, None]
        facts['Target'] = [145, 166]
    elif number == 14:
        first = cycle(n, 40, 10, 8, 12)
        second = cycle(n, 78, 10, 8, 15)
        residual = np.zeros(n); residual[65:82] = .35
        raw[:, mask] -= 30 * np.maximum(np.maximum(first, second), residual)[:, None]
        facts['Target'] = [40, 112]; facts['Centers'] = [55, 93]
    elif number == 15:
        q = np.ones(n); q[50:80] = np.linspace(1, 0, 30); q[80:] = 0
        raw[:, mask] -= 30 * q[:, None]; facts['Target'] = [1, 80]
    elif number == 16:
        q = np.zeros(n); q[170:200] = np.linspace(0, 1, 30); q[200:] = 1
        raw[:, mask] -= 30 * q[:, None]; facts['Target'] = [170, 240]
    elif number == 17:
        raw = .003 * raw
        raw[:, mask] -= .09 * q[:, None]
    elif number == 18:
        raw[80:125] = np.roll(raw[80:125], 2, axis=2)
        facts['Target'] = [80, 125]
    elif number == 19:
        left = (yy >= 12) & (yy < 19) & (xx >= 8) & (xx < 13)
        right = (yy >= 12) & (yy < 19) & (xx >= 15) & (xx < 20)
        gap = (yy >= 12) & (yy < 19) & (xx >= 13) & (xx < 15)
        raw[:, left] -= 30 * q[:, None]
        raw[:, right] -= 30 * q[:, None]
        facts.update(Mask=np.flatnonzero((left | right).ravel()), Left=np.flatnonzero(left.ravel()),
                     Right=np.flatnonzero(right.ravel()), Gap=np.flatnonzero(gap.ravel()))
    elif number == 20:
        raw[:, mask] -= 30 * q[:, None]
        raw[90, 14, 14] = np.nan
    facts['Q'] = q
    return raw.astype(np.float32), facts


def associated(rows, mask, target):
    matches = []
    for row in rows:
        common = len(np.intersect1d(row['CoarseMask'], mask))
        a, b = row['ProposedInterval']
        if common >= max(1, .15 * len(mask)) and a <= target[1] and b >= target[0]:
            matches.append(row)
    return matches


def evaluate(number, settings=None, diagnostic=None):
    settings = settings or Settings()
    raw, facts = scene(number)
    before = hashlib.sha256(raw.tobytes()).hexdigest()
    result, seeds = detect(raw, settings=settings)
    assert hashlib.sha256(raw.tobytes()).hexdigest() == before, 'Input mutation'
    assert result['Coverage']['FiniteBlockFrames'] + result['Coverage']['MissingBlockFrames'] == raw.size
    assert result['Coverage']['DimIntensityExclusions'] == 0
    assert result['MeasurementReady'] is False and result['BurdenReady'] is False
    assert set(result['SeedGroups']) == {x['ID'] for x in seeds}, 'Unaccounted seeds'
    for row in result['Candidates']:
        assert row['MeasurementReady'] is False and row['BurdenReady'] is False
        assert 1 <= row['ProposedInterval'][0] <= row['ProposedInterval'][1] <= len(raw)
        assert row['NativeAreaMeasured'] is False
        if row.get('Return'):
            assert not row['Return'].get('MeasurementReferenceAccepted', False)
    rows = associated(result['Candidates'], facts['Mask'], facts['Target'])
    local = [x for x in rows if x['Recognition'] == 'local_cycle_candidate']
    if diagnostic is not None:
        diagnostic(result, seeds, facts)
    if number in [1, 2, 3, 4, 11]:
        assert not [x for x in result['Candidates'] if x['Recognition'] == 'local_cycle_candidate'], 'False local promotion'
    elif number in [5, 6, 7, 8, 10, 17]:
        assert local, 'Constructed local cycle not retained'
        if number == 6:
            assert any(x['Phases']['LowFrames'] and x['Phases']['LowFrames'][1] - x['Phases']['LowFrames'][0] >= 8 for x in local)
        if number in [7, 8]:
            differences = [(x['Phases']['PeakDeficitFrame'] - x['Phases']['OnsetFrame'],
                            x['Phases']['ReturnFrame'] - x['Phases']['PeakDeficitFrame']) for x in local]
            assert any(a > b if number == 7 else b > a for a, b in differences), 'Asymmetry lost'
    elif number == 9:
        assert any(x['Recognition'] in ['local_cycle_candidate', 'uncertain'] for x in rows)
        assert all(not x.get('RegionalDependence', {}).get('GeometricComparisonsAreVerifiedQuiet', False) for x in rows)
    elif number == 12:
        assert rows and any('local' in x['Routes'] for x in rows), 'Local route failed to retain moving-level cycle'
        assert any(not x['Return'].get('RestoredPrecedingRawLevel', False) for x in rows)
    elif number == 13:
        assert any(abs(s['Trough'] - 155) <= 15 and len(np.intersect1d(s['Mask'], facts['Mask'])) >= 6 for s in seeds), 'Later cycle consumed'
    elif number == 14:
        times = [s['Trough'] for s in seeds if len(np.intersect1d(s['Mask'], facts['Mask'])) >= 6]
        assert all(any(abs(t - c) <= 15 for t in times) for c in facts['Centers']), 'Recurrent low evidence lost'
    elif number in [15, 16]:
        kind = 'start_censored' if number == 15 else 'end_censored'
        assert any(x['Kind'] == kind and x['Return']['State'] == 'censored' for x in rows), 'Censored side invented'
    elif number == 18:
        assert any(abs(f - 81) <= 2 for f in result['MotionFrames'])
        assert any(abs(f - 126) <= 2 for f in result['MotionFrames'])
    elif number == 19:
        simple = [s for s in seeds if s['Route'] == 'raw' and s['Sigma'] == 0 and abs(s['Trough'] - 90) <= 20]
        assert all(any(len(np.intersect1d(s['Mask'], facts[key])) >= 6 for s in simple) for key in ['Left', 'Right'])
        assert all(not len(np.intersect1d(s['Mask'], facts['Gap'])) for s in simple if len(np.intersect1d(s['Mask'], facts['Mask'])) >= 6), 'Static gap filled'
    elif number == 20:
        assert np.isnan(strict_mean(raw, facts['Mask'])[90]), 'Fixed-cohort missing value was omitted'
        seed = {'ID': 'invariant-cohort', 'Mask': facts['Mask'], 'Trough': 90, 'Span': 32,
                'Score': 10., 'Kind': 'cycle', 'Sigma': 0.}
        item = {'ID': 'invariant', 'Representative': seed, 'SeedIDs': [seed['ID']], 'Routes': ['raw'],
                'ScaleAlternatives': [(0., 32)], 'TroughAlternatives': [90, 90]}
        check = assess(raw, item, patch_bank(raw, settings.patch_blocks),
                       motion_evidence(raw, settings.motion_shift_blocks), 1., settings)
        assert check['Recognition'] == 'uncertain' and 'fixed_cohort_observations_missing' in check['Flags']
    return {'ID': EXPECTATIONS[number - 1]['ID'], 'Passed': True, 'SeedCount': len(seeds),
            'CandidateCount': result['CandidateCount'], 'AssociatedStates': [x['Recognition'] for x in rows],
            'InputSHA256': before, 'SourceImagesRead': 0}
