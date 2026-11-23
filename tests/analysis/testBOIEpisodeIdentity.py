"""Twenty-four fixed constructed scenes for the approved identity revision."""
import copy
import numpy as np
from testBOIEpisodeAssembly import fixture as preceding_fixture, EXPECTATIONS as PRECEDING
from boi_episode_identity.numeric import Settings
from boi_episode_identity.service import Assembler, confidence

EXPECTATIONS = PRECEDING + [
    {'ID': 'later_seed_preserves_cycle_identity', 'Meaning': 'No attachment to an earlier recovered cycle'},
    {'ID': 'weak_later_seed_no_nearest_cycle_substitution', 'Meaning': 'Unresolved later target, no older substitute'},
    {'ID': 'older_low_reference_vs_immediate_decline', 'Meaning': 'Older low state cannot certify later recovery'},
    {'ID': 'recurrent_changed_levels_short_reference_uncertainty', 'Meaning': 'Individual references; short alternative flagged'},
    {'ID': 'small_boundary_vs_small_supported_interior', 'Meaning': 'Spatial identity, not size/brightness alone'},
    {'ID': 'source_confidence_and_alternative_identity_contract', 'Meaning': 'Explicit competing IDs and consistent certainty'},
]


def fixture(number):
    if number <= 18:
        return preceding_fixture(number)
    n = 360; noise = 0. if number in [20, 22] else 2.
    raw = np.broadcast_to((1000. + noise * np.sin(np.arange(n) * .43))[:, None, None], (n, 16, 16)).copy().astype(np.float32)
    rows = []
    def rect(y, x, h=3, w=3):
        yy, xx = np.mgrid[y:y+h, x:x+w]
        return (yy * 16 + xx).ravel().astype(np.uint16)
    def dip(mask, points):
        raw.reshape(n, -1)[:, mask] -= np.interp(np.arange(n), [p[0] for p in points], [p[1] for p in points])[:, None]
    def row(mask, anchor, span=16, moving=None):
        rows.append({'ID': f'J{len(rows)+1:06d}', 'CoreMask': mask, 'SupportMask': mask,
            'Anchor': anchor, 'Span': span, 'Kind': 'cycle', 'SeedCount': 1,
            'ScaleAlternatives': [[1., span]], 'OriginalRecognition': 'unlabelled_fixture',
            'DisplacementLikeFrames': moving or []})
    a = rect(6, 6, 4, 4)
    if number == 19:
        dip(a, [(0,0),(79,0),(90,160),(110,160),(125,0),(199,0),(210,100),(235,100),(255,0),(359,0)])
        row(a, 220)
    elif number == 20:
        dip(a, [(0,0),(79,0),(90,160),(110,160),(125,0),(359,0)])
        row(a, 240)
    elif number == 21:
        raw.reshape(n,-1)[:,a] = np.interp(np.arange(n), [0,119,155,174,190,210,240,359], [800,800,1000,1000,850,850,1000,1000])[:,None]
        row(a, 200)
    elif number == 22:
        raw.reshape(n,-1)[:,a] = np.interp(np.arange(n), [0,79,95,120,130,134,135,145,160,185,215,359], [1000,1000,900,900,1000,1000,1100,1100,950,950,1100,1100])[:,None]
        row(a, 110); row(a, 172)
    elif number == 23:
        edge, interior = rect(0, 4, 1, 3), rect(8, 8, 1, 3)
        for mask in [edge,interior]: dip(mask, [(0,0),(79,0),(100,100),(150,100),(175,0),(359,0)])
        row(edge,125,moving=[100]);row(interior,125)
    elif number == 24:
        a,b=rect(5,2),rect(5,11)
        for mask in [a,b]: dip(mask,[(0,0),(79,0),(100,100),(150,100),(175,0),(359,0)])
        row(a,125);row(b,125);row(np.r_[a,b],125)
    return raw,rows


def evaluate(number, diagnostic=None):
    raw,rows=fixture(number); a=Assembler(raw,Settings())
    branches=[a.assess(r) for r in rows];result=a.assemble(branches);episodes=result['Episodes']
    facts={'Episodes':len(episodes),'Recognitions':[b['Recognition'] for b in branches],
        'RecoveryStates':[b['RecoveryState'] for b in branches], 'Intervals':[b['Interval'] for b in branches],
        'Anchors':[b['SourceAnchor'] for b in branches], 'IdentityConnected':[b['IdentityConnected'] for b in branches],
        'Flags':[b['Flags'] for b in branches]}
    if diagnostic:diagnostic(result,branches,facts)
    assert len(result['Membership'])==len(rows)
    assert all(not b['MeasurementReady'] and not b['BurdenReady'] for b in branches+episodes)
    assert all(b['IdentityReferenceRounds']<=2 for b in branches)
    for b in branches:
        if b['IdentityConnected']:
            assert b['Interval'][0] is None or b['Interval'][0]<=b['SourceAnchor']
            assert b['Interval'][1] is None or b['SourceAnchor']<b['Interval'][1]
    if number in [1,2]:
        assert len(episodes)==1,facts
        assert len(episodes[0]['Minima'])>=(2 if number==1 else 3),facts
    elif number==3:
        assert len(episodes)==2 and all(b['RecoveryState']=='observed_recovery' for b in branches),facts
    elif number==4:
        assert any(b['RawProfile']['ShortReturns'] for b in branches),facts
        assert all(b['Recognition']!='complete_episode_candidate' for b in branches),facts
    elif number in [5,8]:assert len(episodes)==2,facts
    elif number==6:
        assert branches[1]['Recognition']=='regional_context' and len(episodes)>=2,facts
        assert all(len(e['MemberIDs'])<3 for e in episodes),facts
    elif number==7:
        assert len(episodes)==1 and 'spatial_gap_supported_not_filled' in episodes[0]['Flags'],facts
        assert len(episodes[0]['SupportMask'])==sum(len(r['SupportMask']) for r in rows),facts
    elif number==9:
        assert len(episodes)==1 and episodes[0]['Interval'][1]>=190,facts
        assert branches[0]['SpatialEvidence']['AllBranchesRecovered'],facts
    elif number==10:
        assert branches[0]['Recognition']!='complete_episode_candidate' and branches[0]['SpatialEvidence']['Missing'],facts
    elif number in [11,18]:
        assert branches[0]['RecoveryState']=='relative_recovery' and branches[0]['Recognition']!='regional_context',facts
        assert branches[0]['RawProfile']['End'] is None,facts
    elif number==12:assert not episodes and branches[0]['Recognition']=='regional_context',facts
    elif number==13:assert branches[0]['Recognition']!='complete_episode_candidate' and 'displacement_like_evidence' in branches[0]['Flags'],facts
    elif number==14:assert len(episodes)==1 and branches[0]['Recognition']=='complete_episode_candidate',facts
    elif number==15:assert branches[0]['Interval'][0]<110 and branches[0]['Interval'][1]>200,facts
    elif number==16:assert branches[0]['Interval'][0] is None and 'recording_start_censored' in branches[0]['Flags'],facts
    elif number==17:assert branches[0]['Interval'][1] is None and 'recording_end_unrecovered' in branches[0]['Flags'],facts
    elif number==19:
        b=branches[0];assert b['IdentityConnected'] and b['Interval'][0]>180 and b['Interval'][1]>230,facts
        assert b['RawProfile']['Reference'] is not None and b['RawProfile']['Reference']['First']>150,facts
    elif number==20:
        assert not branches[0]['IdentityConnected'] and branches[0]['Interval']==[None,None],facts
    elif number==21:
        p=branches[0]['RawProfile'];assert p['Reference'] is None or p['Reference']['First']>140,facts
        assert p['End'] is None or p['End']>=230,facts
    elif number==22:
        p=branches[1]['RawProfile'];refs={r['Length']:r for r in p['DiagnosticReferences']}
        assert not refs[20]['Usable'] and refs[10]['Usable'],facts
        assert 'short_predecline_reference_conditional' in branches[1]['Flags'],facts
        assert branches[1]['Recognition']!='complete_episode_candidate',facts
    elif number==23:
        assert branches[0]['Recognition']!='complete_episode_candidate' and 'boundary_geometry_unresolved' in branches[0]['Flags'],facts
        assert branches[1]['Recognition']=='complete_episode_candidate',facts
    elif number==24:
        m=result['Membership']['J000003'];assert len(m['AlternativeEpisodeIDs'])==2,facts
        assert m['FinalRecognition']!='complete_episode_candidate',facts
        assert all(e['Recognition']!='complete_episode_candidate' or not(set(e['Flags'])&{'multiple_episode_membership_ambiguous','spatial_identity_unresolved'}) for e in episodes),facts
        bad=copy.deepcopy(branches[0]['RawProfile']);bad['Reference']['Clean']=False
        assert confidence(bad,branches[0]['SpatialEvidence'],[],True)!='complete_episode_candidate'
    return {'ID':EXPECTATIONS[number-1]['ID'],'Passed':True,'Facts':facts}
