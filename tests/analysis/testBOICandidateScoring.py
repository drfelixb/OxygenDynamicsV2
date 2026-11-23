"""Eighteen predeclared shapes and independent finite-grid recurrence checks."""
from pathlib import Path
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'prototypes'))
from boi_video_detector.candidate_scoring import (CandidateSettings, fit_timing, graph_solve, observed_entry, variation)


from testBOIPhaseTiming import EXPECTATIONS as OLD_EXPECTATIONS, fixtures as old_fixtures

EXPECTATIONS = OLD_EXPECTATIONS + [
    ('later_smaller_flat_episode', 'Retain both complete dips; later smaller flat dip cannot hide in post context'),
    ('rectangular_cycle', 'Retain temporal decline-hold-return evidence; do not infer spatial pocket identity'),
]


def fixtures():
    t = np.arange(240)
    later = np.interp(t, [0, 25, 45, 65, 100, 115, 140, 160, 239],
                     [112, 112, 92, 112, 112, 106, 106, 112, 112])
    rectangle = np.full(180, 112.)
    rectangle[60:95] = 92.
    extra = [later, rectangle]
    return old_fixtures() + [(name, expectation, values, np.zeros(len(values), bool), None)
                            for (name, expectation), values in zip(EXPECTATIONS[16:], extra, strict=True)]


def recurrence_check(values, settings):
    # Same named fixture, reduced to a tiny observed prefix. Enumerate every
    # legal predecessor level independently of the optimized prefix minima.
    x = np.asarray(values, float)[np.linspace(0, len(values) - 1, 32).astype(int)]
    x = x[np.isfinite(x)]
    grid = np.linspace(x.min(), x.max(), 7) if np.ptp(x) else np.full(7, x[0])
    sigma = max(variation(x), np.ptp(x) / 6, 1e-6)
    z = np.abs((x[:, None] - grid) / sigma)
    emission = np.where(z <= settings.huber_delta, .5 * z * z,
                        settings.huber_delta * (z - .5 * settings.huber_delta))
    entry = observed_entry(x, settings.frames(settings.transition_evidence_seconds, 1.))
    fast = graph_solve(emission, entry, settings, 1.)
    independent = graph_solve(emission, entry, settings, 1., naive=True)
    np.testing.assert_allclose(fast['Score'], independent['Score'], atol=1e-9)
    np.testing.assert_allclose(fast['ForwardEnd'], independent['Forward'][-1], atol=1e-9)
    return True


def constructed_checks():
    settings = CandidateSettings()
    checks = []
    for name, expectation, x, motion, local in fixtures():
        fit = fit_timing(x, motion, 1., settings)
        episodes = [ep for ep in fit['Episodes'] if ep['ContrastSupported']]
        passed = not fit['MeasurementReady'] and not fit['ScientificBurdenAvailable']
        if name in ('short_v', 'fast_fall_slow_rise', 'slow_fall_fast_rise', 'rounded_floor', 'correlated_noise_episode'):
            passed &= bool(episodes) and any(ep['RiseStart'] is not None for ep in episodes)
        elif name == 'flat_floor':
            passed &= any(ep['LowPhasePresent'] and ep['LowRange'][1] - ep['LowRange'][0] >= 15 for ep in episodes)
        elif name == 'double_low':
            passed &= bool(episodes) and (len(episodes) == 1 or any(ep['SeparationFromPrevious'] == 'linked_or_uncertain' for ep in episodes))
        elif name == 'separated_episodes':
            passed &= len(episodes) >= 2 and any(ep['ReferenceReturn'] in ('compatible_with_observed_reference', 'above_observed_reference') for ep in episodes[:-1])
        elif name == 'renewed_during_recovery':
            passed &= bool(episodes) and any(ep['Reference']['State'] != 'supported_observed' for ep in episodes)
        elif name in ('recovery_only', 'isolated_spike', 'correlated_noise_control'):
            passed &= not episodes and fit['State'] == 'no_added_episode_supported'
        elif name == 'local_return_in_depressed_region':
            relative = fit_timing(local, motion, 1., settings)
            passed &= any(ep['ReferenceReturn'] == 'below_observed_reference' for ep in episodes)
            passed &= any(ep['ReferenceReturn'] in ('compatible_with_observed_reference', 'above_observed_reference') for ep in relative['Episodes'])
        elif name == 'left_censored':
            passed &= fit['MissingPrecedingHistoryPossible'] or any(ep['LeftCensored'] for ep in episodes)
        elif name == 'right_censored':
            passed &= bool(episodes) and any(ep['RightCensored'] for ep in episodes)
        elif name == 'later_smaller_flat_episode':
            passed &= len(episodes) >= 2 and any(ep['Onset'] is not None and ep['Onset'] > 80
                                               and ep['LowRange'][1] - ep['LowRange'][0] >= 10 for ep in episodes)
        elif name == 'rectangular_cycle':
            passed &= bool(episodes) and any(ep['RiseStart'] is not None for ep in episodes)
            passed &= all(ep['PocketIdentity'] == 'not_inferred_from_temporal_shape' for ep in episodes)
        elif name == 'missing_motion':
            passed &= len(fit['InvalidSamples']) == 8
            passed &= any('motion' in b.get('RightCauses', []) and 'missing_sample' in b.get('RightCauses', []) for b in fit['Blocks'])
            passed &= not any(ep['PostRange'] and ep['PostRange'][0] < 87 < ep['PostRange'][1] for ep in episodes)
        for ep in fit['Episodes']:
            passed &= (ep['IsConditional'] or (ep['OnsetStatus'] == 'identified' and ep['Reference']['State'] == 'supported_observed'))
            passed &= not ep['MeasurementReady'] and not ep['ScientificRecoveredBaselineEligible']
        for block in fit['Blocks']:
            assessment = block.get('NoiseAssessment')
            if assessment:
                excluded = set(assessment['ExcludedSamples'])
                passed &= all(not excluded.intersection(range(*w['Range'])) for w in assessment['Windows'])
                passed &= not assessment['CrossROITransfer']
                if assessment['State'] == 'noise_context_unresolved':
                    passed &= all(e['IsConditional'] for e in block['Episodes'])
        proof = recurrence_check(x, settings)
        checks.append({'Case': name, 'Expectation': expectation, 'Passed': bool(passed and proof),
                       'IndependentRecurrenceMatched': proof, 'State': fit['State'],
                       'Episodes': episodes, 'BlockStates': [b['State'] for b in fit['Blocks']],
                       'NoiseStates': [b.get('NoiseAssessment', {}).get('State') for b in fit['Blocks']]})
    return checks


def test_eighteen_candidate_shapes():
    checks = constructed_checks()
    assert len(checks) == 18 and all(c['Passed'] for c in checks), checks
