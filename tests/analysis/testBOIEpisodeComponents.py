"""32 fixed physical scenarios for local/regional/reference separation.

Previous realizations are reused verbatim. Assertions map their physical
expectations to the new records, not obsolete reference-dependent labels.
"""
import copy
import numpy as np
from testBOIEpisodeIdentity import fixture as previous_fixture, EXPECTATIONS as PREVIOUS
from boi_episode_components.numeric import Settings
from boi_episode_components.service import Assembler, clean, fingerprint

EXPECTATIONS = PREVIOUS + [
    {'ID': 'low_earlier_high_immediate_prestate', 'Meaning': 'Earlier low state does not imply recording-start onset'},
    {'ID': 'earlier_activity_later_cycle_missing_measurement_baseline', 'Meaning': 'Later cycle and spatial assessment survive withheld reference audit'},
    {'ID': 'small_context_change_remote_crest', 'Meaning': 'Local identity is not silently relocated to the remote crest'},
    {'ID': 'local_cycle_on_strong_regional_decline', 'Meaning': 'Regional response and local episode coexist'},
    {'ID': 'regional_only_with_local_path_assessed', 'Meaning': 'Positive broad evidence; no manufactured local episode'},
    {'ID': 'conditional_scale_unavailable_raw_observed', 'Meaning': 'Unsupported conditional scaling leaves raw/spatial route available'},
    {'ID': 'multiminimum_partial_branch_return', 'Meaning': 'Continuing branch prevents false spatial recovery'},
    {'ID': 'measurement_reference_audit_invariance', 'Meaning': '20-only/10-only/withheld variants preserve all detection outputs'},
]


def fixture(number):
    if number <= 24: return previous_fixture(number)
    if number == 29: return previous_fixture(12)
    if number == 28: return previous_fixture(11)
    n = 400; t = np.arange(n)
    raw = np.broadcast_to((1000. + 2. * np.sin(t * .43))[:, None, None], (n, 16, 16)).copy().astype(np.float32)
    yy, xx = np.mgrid[6:10, 6:10]; mask = (yy * 16 + xx).ravel().astype(np.uint16)
    points = [(0,1000),(199,1000),(225,900),(260,900),(300,1000),(399,1000)]
    if number == 25:
        points = [(0,800),(119,800),(160,1000),(199,1000),(225,850),(250,850),(280,1000),(399,1000)]
    elif number in [26,32]:
        points = [(0,1000),(69,1000),(90,850),(120,850),(150,1000),(239,1000),(260,900),(295,900),(330,1000),(399,1000)]
    elif number == 27:
        points = [(0,1200),(59,1200),(130,1000),(219,1000),(240,900),(270,900),(300,1000),(399,1000)]
    elif number == 30:
        raw[:] = 0.
    elif number == 31:
        points = [(0,1000),(79,1000),(100,880),(125,950),(145,870),(180,1000),(399,1000)]
    raw.reshape(n,-1)[:,mask] = (np.interp(t,[p[0] for p in points],[p[1] for p in points]) + 2.*np.sin(t*.43))[:,None]
    if number == 31:
        raw.reshape(n,-1)[180:,mask[:4]] -= 100.
    anchor = {25:235,26:280,27:250,30:240,31:145,32:280}[number]
    rows = [{'ID':'J000001','CoreMask':mask,'SupportMask':mask,'Anchor':anchor,'Span':16,
        'Kind':'cycle','SeedCount':1,'ScaleAlternatives':[[1.,16]],'DisplacementLikeFrames':[],
        'OriginalRecognition':'unlabelled_fixture'}]
    return raw, rows


def evaluate(number, diagnostic=None):
    raw, rows = fixture(number); assembler = Assembler(raw, Settings())
    mode = 'withheld' if number == 26 else 'both'
    branches = [assembler.assess(r, audit_mode=mode) for r in rows]
    result = assembler.assemble(branches); episodes = result['Episodes']
    facts = {'Episodes':len(episodes),'Intervals':[b['Interval'] for b in branches],
        'Recognitions':[b['Recognition'] for b in branches], 'RecoveryStates':[b['RecoveryState'] for b in branches],
        'IdentityConnected':[b['IdentityConnected'] for b in branches], 'Flags':[b['Flags'] for b in branches],
        'RegionalStates':[b['RegionalChange']['State'] for b in branches]}
    if diagnostic: diagnostic(result, branches, facts)
    assert len(result['Membership']) == len(rows)
    for b in branches:
        assert not b['MeasurementReady'] and not b['BurdenReady']
        assert b['SpatialEvidence']['Attempted'] and b['RegionalChange']['Assessed']
        assert b['ChannelAssessments'] == 4 and b['HypothesisAssessments'] <= 8
        assert b['ReferenceWindowAssessments'] <= 16
        assert not b['LocalEpisode']['MeasurementReferenceUsed']
        assert not b['MeasurementReferenceAudit']['InfluencesDetection']
        assert b['DetectionFingerprint'] == fingerprint(b['LocalEpisode'], b['RegionalChange'], b['SpatialEvidence'])
        if b['IdentityConnected']:
            assert b['Interval'][0] is None or b['Interval'][0] <= b['SourceAnchor']
            assert b['Interval'][1] is None or b['SourceAnchor'] < b['Interval'][1]
    if number in [1,2]:
        assert len(episodes) == 1, facts
        assert len(episodes[0]['Minima']) >= (2 if number == 1 else 3), facts
    elif number == 3:
        assert len(episodes) == 2 and all(b['RawProfile']['End'] for b in branches), facts
    elif number == 4:
        assert any(b['RawProfile']['ShortReturns'] for b in branches), facts
        assert all(b['Recognition'] != 'complete_episode_candidate' for b in branches), facts
    elif number in [5,8]: assert len(episodes) == 2, facts
    elif number == 6:
        assert branches[1]['Recognition'] == 'regional_context' and len(episodes) >= 2, facts
        assert all(len(e['MemberIDs']) < 3 for e in episodes), facts
    elif number == 7:
        assert len(episodes) == 1 and 'spatial_gap_supported_not_filled' in episodes[0]['Flags'], facts
        assert len(episodes[0]['SupportMask']) == sum(len(r['SupportMask']) for r in rows), facts
    elif number == 9:
        assert len(episodes) == 1 and episodes[0]['Interval'][1] >= 190, facts
        assert branches[0]['SpatialEvidence']['AllBranchesRecovered'], facts
    elif number == 10:
        assert branches[0]['SpatialEvidence']['Missing'] and branches[0]['Recognition'] != 'complete_episode_candidate', facts
    elif number in [11,18,28]:
        b = branches[0]
        assert b['IdentityConnected'] and b['RecoveryState'] == 'relative_recovery', facts
        assert b['RawProfile']['End'] is None and b['RegionalChange']['LocalEpisodeCoexists'], facts
    elif number in [12,29]:
        assert not episodes and branches[0]['Recognition'] == 'regional_context', facts
        assert branches[0]['SpatialEvidence']['Attempted'], facts
    elif number == 13:
        assert 'displacement_like_evidence' in branches[0]['Flags'] and branches[0]['Recognition'] != 'complete_episode_candidate', facts
    elif number == 14:
        assert len(episodes) == 1 and branches[0]['Recognition'] == 'complete_episode_candidate', facts
    elif number == 15:
        assert branches[0]['Interval'][0] < 110 and branches[0]['Interval'][1] > 200, facts
    elif number == 16:
        assert branches[0]['Interval'][0] is None and 'recording_start_censored' in branches[0]['Flags'], facts
    elif number == 17:
        assert branches[0]['Interval'][1] is None and 'recording_end_unrecovered' in branches[0]['Flags'], facts
    elif number == 19:
        assert branches[0]['IdentityConnected'] and branches[0]['Interval'][0] > 180 and branches[0]['Interval'][1] > 230, facts
    elif number == 20:
        assert not branches[0]['IdentityConnected'] and branches[0]['Interval'] == [None,None], facts
    elif number == 21:
        b = branches[0]
        assert b['RawProfile']['Start'] > 150 and (b['RawProfile']['End'] is None or b['RawProfile']['End'] >= 230), facts
    elif number == 22:
        audit = next(h for h in branches[1]['MeasurementReferenceAudit']['Hypotheses'] if h['HypothesisID']=='J000002:raw:1')
        refs = {r['Length']:r for r in audit['Windows']}
        assert not refs[20]['Usable'] and refs[10]['Usable'], facts
        assert branches[1]['Recognition'] != 'complete_episode_candidate', facts
    elif number == 23:
        assert 'boundary_geometry_unresolved' in branches[0]['Flags'] and branches[0]['Recognition'] != 'complete_episode_candidate', facts
        assert branches[1]['Recognition'] == 'complete_episode_candidate', facts
    elif number == 24:
        m = result['Membership']['J000003']
        assert len(m['AlternativeEpisodeIDs']) == 2 and m['FinalRecognition'] != 'complete_episode_candidate', facts
    elif number == 25:
        assert branches[0]['IdentityConnected'] and branches[0]['Interval'][0] > 180, facts
    elif number == 26:
        assert branches[0]['IdentityConnected'] and branches[0]['Interval'][0] > 220, facts
        assert all(not w['Usable'] for h in branches[0]['MeasurementReferenceAudit']['Hypotheses'] for w in h['Windows']), facts
    elif number == 27:
        assert branches[0]['IdentityConnected'] and branches[0]['Interval'][0] > 180, facts
        variant = raw.copy();variant[:100] += .5
        other = Assembler(variant, Settings()).assess(rows[0])
        assert other['IdentityConnected'] and other['Interval'][0] > 180, facts
        assert abs(other['Interval'][0] - branches[0]['Interval'][0]) <= 5, facts
    elif number == 30:
        assert branches[0]['IdentityConnected'] and branches[0]['SpatialEvidence']['AssessmentState'] == 'observed', facts
        assert all(not r['ConditionalScaleAvailable'] for r in branches[0]['RegionalComparisons'].values()), facts
    elif number == 31:
        assert not branches[0]['SpatialEvidence']['AllBranchesRecovered'], facts
        assert branches[0]['Recognition'] != 'complete_episode_candidate', facts
    elif number == 32:
        snapshots = []; memberships = []; audits = []
        for variant in ['20_only','10_only','withheld']:
            a = Assembler(raw, Settings());b = a.assess(rows[0], audit_mode=variant)
            grouped = a.assemble([b]);snapshots.append(clean([b['LocalEpisode'],b['RegionalChange'],b['SpatialEvidence']]))
            memberships.append(clean(grouped));audits.append(b['MeasurementReferenceAudit'])
        assert snapshots[0] == snapshots[1] == snapshots[2], facts
        assert memberships[0] == memberships[1] == memberships[2], facts
        assert audits[0] != audits[1] != audits[2], facts
    return {'ID':EXPECTATIONS[number-1]['ID'],'Passed':True,'Facts':facts}
