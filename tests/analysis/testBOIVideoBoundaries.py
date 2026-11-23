"""Ten fixed boundary fixtures; expectations precede any real-window run."""
from pathlib import Path
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'prototypes'))
from boi_video_detector.boundaries import BoundarySettings, assess_boundaries


EXPECTATIONS = [
    ('flat_plateau', 'Onset near 70, not the beginning of the plateau; sustained raw return'),
    ('gradual_decline', 'Onset near 60; preserve early slow decline'),
    ('recovering_prestate', 'Later onset near 70 with recovering pre-state'),
    ('earlier_activity', 'Later onset near 85; do not borrow the earlier dip'),
    ('recovery_only', 'No new decline'),
    ('partial_return', 'No sustained return while about 40% deficit remains'),
    ('spike_then_relapse', 'First return may occur, but no sustained return'),
    ('fluctuating_return', 'Sustained return with observed fluctuations'),
    ('local_before_region', 'Local return supported while absolute raw return remains unresolved'),
    ('gap_and_truncation', 'No sustained recovery across missing/truncated post-context'),
]


def constructed_checks():
    time = np.arange(160)
    wiggle = .15 * np.sin(time * 1.7) + .1 * np.cos(time * .9)
    clean = np.interp(time, [0, 70, 90, 110, 159], [112, 112, 92, 112, 112])
    gradual = np.interp(time, [0, 60, 100, 140, 159], [112, 112, 92, 112, 112])
    recovering = np.interp(time, [0, 35, 70, 90, 115, 159], [95, 95, 112, 92, 112, 112])
    earlier = np.interp(time, [0, 30, 45, 65, 85, 100, 120, 159], [112, 112, 92, 108, 112, 92, 112, 112])
    only = np.interp(time, [0, 35, 159], [95, 95, 120])
    partial = np.interp(time, [0, 70, 90, 110, 159], [112, 112, 92, 104, 104])
    spike = partial.copy()
    spike[111:114] = 113
    region = np.interp(time, [0, 70, 90, 159], [0, 0, -8, -8])
    local = clean - 112
    missing = clean.copy()
    missing[112:] = np.nan
    fixtures = [
        (clean, 90, 0, None), (gradual, 100, 0, None), (recovering, 90, 35, None),
        (earlier, 100, 45, None), (only, 90, 35, None), (partial, 90, 0, None),
        (spike, 90, 0, None), (clean + wiggle, 90, 0, None),
        (clean + region, 90, 0, local), (missing, 90, 0, None),
    ]
    checks = []
    settings = BoundarySettings()
    for (name, expected), (values, trough, prior, relative) in zip(EXPECTATIONS, fixtures, strict=True):
        cycle = {'Trough': trough, 'ContiguousSpan': [0, 160], 'PriorTrough': prior,
                 'RecoverySearchStop': 160}
        result = assess_boundaries(values, np.zeros(160, bool), cycle, 1., settings, relative)
        onset, returning = result['Onset'], result['RawReturn']
        best = onset['BestFitOnset']
        passed = not result['MeasurementReady'] and not result['ScientificBurdenAvailable']
        if name == 'flat_plateau':
            passed &= best is not None and abs(best - 70) <= 2 and returning['State'] == 'sustained_return_observed'
        elif name == 'gradual_decline':
            passed &= best is not None and abs(best - 60) <= 3
        elif name == 'recovering_prestate':
            passed &= best is not None and abs(best - 70) <= 3 and onset['PrecedingState'] == 'recovering'
        elif name == 'earlier_activity':
            passed &= best is not None and abs(best - 85) <= 4
        elif name == 'recovery_only':
            passed &= onset['State'] == 'no_new_decline'
        elif name in ('partial_return', 'spike_then_relapse', 'gap_and_truncation'):
            passed &= returning['SustainedReturnStart'] is None
        elif name == 'fluctuating_return':
            passed &= returning['State'] == 'sustained_return_observed'
        elif name == 'local_before_region':
            passed &= returning['SustainedReturnStart'] is None
            passed &= result['LocalReturn']['State'] == 'sustained_return_observed'
        checks.append({'Case': name, 'Expectation': expected, 'Passed': bool(passed), 'Assessment': result})
    return checks


def test_ten_boundary_cases():
    checks = constructed_checks()
    assert len(checks) == 10 and all(c['Passed'] for c in checks), checks
