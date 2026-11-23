"""Eighteen fixed, deterministic episode-meaning checks declared before execution."""
import numpy as np
from boi_episode_assembly.service import Assembler
from boi_episode_assembly.numeric import Settings

EXPECTATIONS = [
    {'ID': 'unrecovered_two_minima', 'Meaning': 'one episode; at least two descriptive minima'},
    {'ID': 'flat_multiple_minima', 'Meaning': 'one flat-low episode; multiple descriptive minima'},
    {'ID': 'recovered_same_location_recurrence', 'Meaning': 'two episodes separated by observed recovery'},
    {'ID': 'short_clear_return_ambiguity', 'Meaning': 'short return retained as split/merge uncertainty'},
    {'ID': 'adjacent_distinct_origins', 'Meaning': 'two spatially adjacent but distinct progressions'},
    {'ID': 'regional_chain_bridge', 'Meaning': 'regional bridge cannot merge the two local episodes'},
    {'ID': 'supported_capillary_gap', 'Meaning': 'compatible lobes merge; unobserved gap not measured'},
    {'ID': 'distant_correlated_lobes', 'Meaning': 'correlation alone does not merge distant local origins'},
    {'ID': 'changing_support_continuing_branches', 'Meaning': 'episode persists until the later branch recovers'},
    {'ID': 'missing_pixels_false_recovery', 'Meaning': 'missing observations prevent certified recovery'},
    {'ID': 'local_on_regional_decline', 'Meaning': 'local episode retained with regional dependency'},
    {'ID': 'broad_field_cycle', 'Meaning': 'field cycle remains regional context'},
    {'ID': 'boundary_displacement_ambiguity', 'Meaning': 'source displacement ambiguity prevents complete classification'},
    {'ID': 'dim_valid_local_cycle', 'Meaning': 'dim valid observations remain eligible'},
    {'ID': 'narrow_seed_slow_asymmetric_edges', 'Meaning': 'timing extends beyond a narrow seed phase window'},
    {'ID': 'recording_start_censored', 'Meaning': 'no invented preceding state or onset'},
    {'ID': 'recording_end_censored', 'Meaning': 'no invented recovery'},
    {'ID': 'relative_only_recovery', 'Meaning': 'relative restoration does not certify absolute recovery'},
]


def rectangle(y, x, height=3, width=3):
    yy, xx = np.mgrid[y:y + height, x:x + width]
    return (yy * 16 + xx).ravel().astype(np.uint16)


def fixture(number):
    n = 320
    base = 5. if number == 14 else 1000.
    noise = .01 if number == 14 else 2.
    raw = np.broadcast_to((base + noise * np.sin(np.arange(n) * .43))[:, None, None], (n, 16, 16)).copy().astype(np.float32)
    rows = []
    a = rectangle(5, 5, 4, 4)
    depth = 2. if number == 14 else 100.

    def dip(mask, points):
        values = np.interp(np.arange(n), [p[0] for p in points], [p[1] for p in points])
        raw.reshape(n, -1)[:, mask] -= values[:, None]

    def row(mask, anchor, span=16, kind='cycle', moving=None):
        rows.append({'ID': f'J{len(rows) + 1:06d}', 'CoreMask': mask, 'SupportMask': mask,
                     'Anchor': anchor, 'Span': span, 'Kind': kind,
                     'DisplacementLikeFrames': moving or [], 'SeedCount': 1,
                     'ScaleAlternatives': [[1., span]], 'OriginalRecognition': 'unlabelled_fixture'})

    normal = [(0, 0), (79, 0), (100, depth), (150, depth), (175, 0), (319, 0)]
    if number == 1:
        dip(a, [(0, 0), (79, 0), (100, 120), (120, 40), (140, 130), (180, 0), (319, 0)])
        row(a, 100); row(a, 140)
    elif number == 2:
        dip(a, [(0, 0), (79, 0), (95, 80), (105, 120), (112, 80), (125, 120), (132, 80), (145, 120), (155, 80), (185, 0), (319, 0)])
        row(a, 125)
    elif number in [3, 4]:
        second = 170 if number == 3 else 125
        dip(a, [(0, 0), (79, 0), (90, 100), (110, 100), (120, 0), (second - 1, 0), (second + 10, 100), (second + 25, 100), (second + 40, 0), (319, 0)])
        row(a, 100); row(a, second + 20)
    elif number == 5:
        a, b = rectangle(5, 3), rectangle(5, 7)
        dip(a, [(0, 0), (79, 0), (95, 100), (110, 100), (125, 0), (319, 0)])
        dip(b, [(0, 0), (104, 0), (120, 100), (145, 100), (165, 0), (319, 0)])
        row(a, 100); row(b, 135)
    elif number == 6:
        a, b = rectangle(5, 2), rectangle(5, 11)
        field = np.arange(16 * 16, dtype=np.uint16)
        dip(field, [(0, 0), (59, 0), (90, 50), (170, 50), (210, 0), (319, 0)])
        dip(a, normal); dip(b, [(0, 0), (99, 0), (120, 100), (170, 100), (195, 0), (319, 0)])
        row(a, 120); row(field, 130, 64); row(b, 160)
    elif number in [7, 8]:
        a, b = rectangle(5, 4, 3, 2), rectangle(5, 7 if number == 7 else 12, 3, 2)
        dip(a, normal); dip(b, normal)
        row(a, 120); row(b, 120)
    elif number == 9:
        a, b = rectangle(5, 4), rectangle(5, 7)
        dip(a, [(0, 0), (79, 0), (100, 100), (125, 100), (145, 0), (319, 0)])
        dip(b, [(0, 0), (114, 0), (135, 100), (165, 100), (195, 0), (319, 0)])
        row(np.r_[a, b], 135, 32)
    elif number == 10:
        dip(a, normal); raw.reshape(n, -1)[130:150, a[:3]] = np.nan
        row(a, 100)
    elif number in [11, 18]:
        field = np.arange(16 * 16, dtype=np.uint16)
        points = [(0, 0), (59, 0), (319, 260)] if number == 11 else [(0, 0), (59, 0), (85, 200), (319, 200)]
        dip(field, points); dip(a, normal); row(a, 125)
    elif number == 12:
        a = np.arange(16 * 16, dtype=np.uint16); dip(a, normal); row(a, 125, 32)
    elif number == 13:
        dip(a, normal); row(a, 125, moving=[100])
    elif number == 14:
        dip(a, normal); row(a, 125)
    elif number == 15:
        dip(a, [(0, 0), (69, 0), (110, 100), (130, 100), (230, 0), (319, 0)])
        row(a, 120, 4)
    elif number == 16:
        dip(a, [(0, 100), (70, 100), (115, 0), (319, 0)]); row(a, 30, 16, 'start_censored')
    elif number == 17:
        dip(a, [(0, 0), (79, 0), (100, 100), (319, 100)]); row(a, 125)
    return raw, rows


def evaluate(number, diagnostic=None):
    raw, rows = fixture(number)
    assembler = Assembler(raw, Settings())
    branches = [assembler.assess(r) for r in rows]
    result = assembler.assemble(branches)
    episodes = result['Episodes']
    facts = {'Episodes': len(episodes), 'Recognitions': [r['Recognition'] for r in branches],
             'RecoveryStates': [r['RecoveryState'] for r in branches],
             'Intervals': [r['Interval'] for r in branches], 'Flags': [r['Flags'] for r in branches]}
    if diagnostic:
        diagnostic(result, branches, facts)
    assert len(result['Membership']) == len(rows)
    assert all(not r['MeasurementReady'] and not r['BurdenReady'] for r in branches + episodes)
    if number in [1, 2]:
        assert len(episodes) == 1, facts
        assert len(episodes[0]['Minima']) >= (2 if number == 1 else 3), facts
    elif number == 3:
        assert len(episodes) == 2 and all(r['RecoveryState'] == 'observed_recovery' for r in branches), facts
    elif number == 4:
        assert any(r['RawProfile']['ShortReturns'] for r in branches), facts
        assert all(r['Recognition'] != 'complete_episode_candidate' for r in branches), facts
    elif number in [5, 8]:
        assert len(episodes) == 2, facts
    elif number == 6:
        assert branches[1]['Recognition'] == 'regional_context' and len(episodes) >= 2, facts
        assert all(len(e['MemberIDs']) < 3 for e in episodes), facts
    elif number == 7:
        assert len(episodes) == 1 and 'spatial_gap_supported_not_filled' in episodes[0]['Flags'], facts
        assert len(episodes[0]['SupportMask']) == len(rows[0]['SupportMask']) + len(rows[1]['SupportMask'])
    elif number == 9:
        assert len(episodes) == 1 and episodes[0]['Interval'][1] >= 190, facts
        assert branches[0]['SpatialEvidence']['AllBranchesRecovered'], facts
    elif number == 10:
        assert branches[0]['Recognition'] != 'complete_episode_candidate' and branches[0]['SpatialEvidence']['Missing'], facts
    elif number in [11, 18]:
        assert branches[0]['RecoveryState'] == 'relative_recovery' and branches[0]['Recognition'] != 'regional_context', facts
        assert branches[0]['RawProfile']['End'] is None, facts
    elif number == 12:
        assert not episodes and branches[0]['Recognition'] == 'regional_context', facts
    elif number == 13:
        assert branches[0]['Recognition'] != 'complete_episode_candidate' and 'displacement_like_evidence' in branches[0]['Flags'], facts
    elif number == 14:
        assert len(episodes) == 1 and branches[0]['Recognition'] == 'complete_episode_candidate', facts
    elif number == 15:
        assert branches[0]['Interval'][0] < 110 and branches[0]['Interval'][1] > 200, facts
    elif number == 16:
        assert branches[0]['Interval'][0] is None and 'recording_start_censored' in branches[0]['Flags'], facts
    elif number == 17:
        assert branches[0]['Interval'][1] is None and 'recording_end_unrecovered' in branches[0]['Flags'], facts
    return {'ID': EXPECTATIONS[number - 1]['ID'], 'Passed': True, 'Facts': facts}
