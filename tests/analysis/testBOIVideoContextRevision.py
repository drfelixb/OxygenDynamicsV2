"""Eight bounded constructed checks for recovering context and regional roles."""
from pathlib import Path
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'prototypes'))
from boi_video_detector.context_revision import (
    ContextSettings, QualifiedSurroundings, assess_context, fit_preceding)
from boi_video_detector.separation import Hypothesis


def constructed_checks():
    frames = np.arange(160)
    rows, cols = np.indices((32, 32))
    core = (rows >= 14) & (rows <= 17) & (cols >= 14) & (cols <= 17)
    core_ids = np.flatnonzero(core.ravel())
    shared = np.interp(frames, [0, 29, 56, 68, 119, 144, 159], [0, 0, -.55, -.65, -1, 0, 0])
    broad = 112 + (4 + .2 * rows + .3 * cols)[None] * shared[:, None, None]
    recovery = np.interp(frames, [0, 30, 48, 120, 159], [0, 0, -22, 0, 0])
    local = -18 * np.maximum(0, 1 - np.abs(frames - 89) / 13)
    linked = np.interp(frames, [0, 32, 45, 65, 83, 99, 120, 159],
                       [0, 0, -15, -10, -10, -20, 0, 0])
    clean = 112 + core[None] * local[:, None, None]
    misleading = clean.copy()
    misleading[:, 8:16, 0:8] += local[:, None, None]
    poor_support = np.ones((32, 32))
    poor_support[8:16, 0:8] = .03
    missing = clean.copy()
    missing[84:95, core] = np.nan
    scenes = [
        ('stable_local', clean, 89, np.ones((32, 32)), 'local_candidate'),
        ('recovering_local', 112 + core[None] * (recovery + local)[:, None, None],
         89, np.ones((32, 32)), 'linked_or_uncertain_local_dips'),
        ('recovery_without_event', 112 + core[None] * recovery[:, None, None],
         89, np.ones((32, 32)), 'raw_decline_unsupported'),
        ('linked_dips', 112 + core[None] * linked[:, None, None],
         99, np.ones((32, 32)), 'linked_or_uncertain_local_dips'),
        ('uneven_regional', broad, 119, np.ones((32, 32)), 'regional_response'),
        ('nested_local', broad + core[None] * local[:, None, None],
         89, np.ones((32, 32)), 'local_with_regional_response'),
        ('poorly_supported_comparator', misleading, 89, poor_support, 'local_candidate'),
        ('unavailable_phase', missing, 89, np.ones((32, 32)), 'phase_unavailable'),
    ]
    settings = ContextSettings()
    results = []
    for name, raw, mode, support, expected in scenes:
        raw = raw.astype(np.float32).reshape(len(frames), -1)
        bank = QualifiedSurroundings(raw, np.ones((32, 32), bool), np.full((32, 32), 100),
                                     support, settings)
        h = Hypothesis(1, mode, (mode - 3, mode + 4), (25, 134), core_ids, 'whole_phase', 32, (0,))
        result = assess_context(raw, bank, np.zeros(len(frames), bool), h, 1., settings)
        invariants = not result['MeasurementReady']
        cycle = result['RawCycle']
        if name == 'stable_local':
            invariants &= result['PrecedingState'] in ('stable', 'short_stable_after_recovery')
            onset = cycle['Onset']
            x = raw[:, core_ids].mean(axis=1, dtype=float)
            before = fit_preceding(x, onset, 1., settings)
            changed = x.copy()
            changed[onset:] += np.arange(len(changed) - onset) * 1000
            invariants &= before == fit_preceding(changed, onset, 1., settings)
        if name == 'recovering_local':
            invariants &= result['PrecedingState'] == 'recovering'
            invariants &= result['ReferenceEligibility'] == 'unresolved'
            local_evidence = result['RegionalComparison']
            invariants &= cycle['RawDepth'] >= settings.strength * cycle['RawNoise']
            invariants &= cycle['RawRiseObserved']
            invariants &= local_evidence['LocalDepth'] >= settings.strength * local_evidence['LocalNoise']
            invariants &= local_evidence['RelativeReturnObserved']
        if name == 'linked_dips':
            invariants &= cycle.get('PriorComparison') == 'linked_or_uncertain_prior_return'
        if name in ('uneven_regional', 'nested_local'):
            shared_evidence = result['RegionalComparison'] or {}
            invariants &= shared_evidence.get('Validation', {}).get('SharedPatternSupported', False)
        if name == 'poorly_supported_comparator':
            bad = [r for r in result['RegionRoles'] if r['SupportFraction'] < settings.minimum_patch_support_fraction]
            invariants &= bool(bad) and all(r['Role'] in ('uncertain_support', 'peripheral_check') for r in bad)
        if name == 'unavailable_phase':
            invariants &= result['ReferenceEligibility'] == 'unresolved'
        results.append({'Case': name, 'Expected': expected, 'Observed': result['State'],
                        'PrecedingState': result['PrecedingState'],
                        'ReferenceEligibility': result['ReferenceEligibility'],
                        'Invariants': bool(invariants),
                        'Passed': bool(invariants) and result['State'] == expected,
                        'Assessment': result})
    return results


def test_eight_constructed_checks():
    checks = constructed_checks()
    assert len(checks) == 8 and all(c['Passed'] for c in checks), checks
