"""Sixteen predeclared shapes and independent finite-grid recurrence checks."""
from pathlib import Path
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'prototypes'))
from boi_video_detector.phase_timing import (PhaseSettings, fit_timing, graph_solve, observed_entry, variation)


EXPECTATIONS = [
    ('short_v', 'Observed decline and returning phase'),
    ('fast_fall_slow_rise', 'Independent short decline and long recovery'),
    ('slow_fall_fast_rise', 'Independent long decline and short recovery'),
    ('flat_floor', 'A low state covers a substantial part of the flat trough'),
    ('rounded_floor', 'Represent the rounded dip without a forced unique trough'),
    ('double_low', 'Retain the lows as one episode or linked/uncertain episodes'),
    ('separated_episodes', 'Retain two dips and observed intervening return evidence'),
    ('renewed_during_recovery', 'Retain a later dip with unresolved preceding reference'),
    ('recovery_only', 'No added episode'),
    ('isolated_spike', 'No full episode or recovered-baseline claim from an outlier'),
    ('correlated_noise_episode', 'Retain an episode in correlated varying noise'),
    ('correlated_noise_control', 'Do not confirm an episode from the matched noise alone'),
    ('local_return_in_depressed_region', 'Separate local return from below-reference raw post-state'),
    ('left_censored', 'Missing prehistory; no invented onset or accepted baseline'),
    ('right_censored', 'No completed return at the recording end'),
    ('missing_motion', 'No bridge across the gap; preserve missing and motion causes'),
]


def fixtures():
    t = np.arange(180)
    interp = lambda points, levels: np.interp(t, points, levels)
    clean = interp([0, 60, 80, 100, 179], [112, 112, 92, 112, 112])
    v = interp([0, 60, 70, 110, 179], [112, 112, 92, 112, 112])
    slow = interp([0, 40, 90, 105, 179], [112, 112, 92, 112, 112])
    flat = interp([0, 55, 75, 110, 135, 179], [112, 112, 92, 92, 112, 112])
    rounded = 112 - 20 * np.maximum(0, 1 - ((t - 85) / 25) ** 2)
    double = interp([0, 50, 70, 84, 97, 125, 179], [112, 112, 92, 98, 92, 112, 112])
    two = interp([0, 35, 50, 68, 112, 127, 148, 179], [112, 112, 92, 112, 112, 92, 112, 112])
    renewed = interp([0, 25, 60, 80, 110, 179], [95, 95, 112, 92, 112, 112])
    only = interp([0, 30, 130, 179], [95, 95, 112, 112])
    spike = np.full(180, 112.)
    spike[82] = 90
    rng = np.random.default_rng(50411)
    innovations = rng.normal(0, .14, 180)
    ar = np.zeros(180)
    for i in range(1, 180):
        ar[i] = .65 * ar[i - 1] + innovations[i]
    noise = ar * np.linspace(.7, 1.3, 180)
    region = interp([0, 60, 80, 179], [0, 0, -8, -8])
    left = interp([0, 25, 80, 179], [92, 92, 112, 112])
    ending = clean[:90].copy()
    missing = clean.copy()
    missing[87:95] = np.nan
    motion = np.zeros(180, bool)
    motion[87:95] = True
    raw = [clean, v, slow, flat, rounded, double, two, renewed, only, spike,
           clean + noise, 112 + noise, clean + region, left, ending, missing]
    return [(name, expectation, values, motion if name == 'missing_motion' else np.zeros(len(values), bool),
             clean - 112 if name == 'local_return_in_depressed_region' else None)
            for (name, expectation), values in zip(EXPECTATIONS, raw, strict=True)]


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
    settings = PhaseSettings()
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
            passed &= not episodes
        elif name == 'local_return_in_depressed_region':
            relative = fit_timing(local, motion, 1., settings)
            passed &= any(ep['ReferenceReturn'] == 'below_observed_reference' for ep in episodes)
            passed &= any(ep['ReferenceReturn'] in ('compatible_with_observed_reference', 'above_observed_reference') for ep in relative['Episodes'])
        elif name == 'left_censored':
            passed &= fit['MissingPrecedingHistoryPossible'] or any(ep['LeftCensored'] for ep in episodes)
        elif name == 'right_censored':
            passed &= bool(episodes) and any(ep['RightCensored'] for ep in episodes)
        elif name == 'missing_motion':
            passed &= len(fit['InvalidSamples']) == 8
            passed &= any('motion' in b.get('RightCauses', []) and 'missing_sample' in b.get('RightCauses', []) for b in fit['Blocks'])
            passed &= not any(ep['PostRange'] and ep['PostRange'][0] < 87 < ep['PostRange'][1] for ep in episodes)
        for ep in fit['Episodes']:
            passed &= (ep['IsConditional'] or (ep['OnsetStatus'] == 'identified' and ep['Reference']['State'] == 'supported_observed'))
            passed &= not ep['MeasurementReady'] and not ep['ScientificRecoveredBaselineEligible']
        proof = recurrence_check(x, settings)
        checks.append({'Case': name, 'Expectation': expectation, 'Passed': bool(passed and proof),
                       'IndependentRecurrenceMatched': proof, 'State': fit['State'],
                       'Episodes': episodes, 'BlockStates': [b['State'] for b in fit['Blocks']]})
    return checks


def test_sixteen_phase_shapes():
    checks = constructed_checks()
    assert len(checks) == 16 and all(c['Passed'] for c in checks), checks
