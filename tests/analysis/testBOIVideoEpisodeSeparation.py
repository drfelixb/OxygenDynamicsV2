"""The six constructed checks in the approved episode separation pilot."""
from pathlib import Path
import sys

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / 'prototypes'))
from boi_video_detector.separation import SeparationSettings, evaluate_window


def constructed_checks():
    frames = np.arange(160)
    shape = (32, 32)
    rows, cols = np.indices(shape)
    core = (rows >= 14) & (rows <= 17) & (cols >= 14) & (cols <= 17)
    shared = np.interp(frames, [0, 29, 56, 68, 119, 144, 159], [0, 0, -.55, -.65, -1, 0, 0])
    broad = 112 + (4 + .2 * rows + .3 * cols)[None] * shared[:, None, None]

    def dip(peak, depth, width):
        return -depth * np.maximum(0, 1 - np.abs(frames - peak) / width)

    repeat = dip(45, 15, 11) + dip(99, 19, 12)
    unresolved_repeat = np.interp(frames, [0, 32, 45, 65, 83, 99, 120, 159],
                                  [0, 0, -15, -10, -10, -20, 0, 0])
    local = dip(89, 14, 13)
    missing = 112 + core[None] * local[:, None, None]
    missing[85:94, core] = np.nan
    scenes = [
        ('recovered_repeat', 112 + core[None] * repeat[:, None, None],
         [45, 99], 'separated_local_cycle'),
        ('uninterrupted_decline', 112 + core[None] * unresolved_repeat[:, None, None],
         [45, 99], 'linked_dips'),
        ('uneven_regional', broad, [119], 'regional_explains_decline'),
        ('nested_local', broad + core[None] * local[:, None, None], [89], 'local_cycle'),
        ('contaminated_controls', 112 + ((rows < 16) | core)[None] * local[:, None, None],
         [89], 'context_sensitive'),
        ('unavailable_phase', missing, [89], 'phase_unavailable'),
    ]
    results = []
    for name, raw, modes, expected in scenes:
        # Duplicate proposals across stages to exercise consensus without extra votes.
        seed_rows = [[t, r, c, 25, 133, 0, 154, 8, stage, 0, 0, 0]
                     for t in modes for r, c in zip(*np.nonzero(core)) for stage in range(2)]
        seeds = np.array(seed_rows, dtype=float)
        hypotheses, coverage, _ = evaluate_window(
            raw.astype(np.float32), seeds, np.zeros(len(seeds), int), 1,
            np.ones(shape, bool), np.full(shape, 100.), np.zeros(len(frames), bool),
            1., SeparationSettings())
        outcomes = list(hypotheses)
        matching = [(h, a) for h, a in outcomes if h.mode == modes[-1]]
        actual = matching[0][1] if len(matching) == 1 else {}
        cycle = actual.get('RelativeCycle') or {}
        invariants = (len(outcomes) == len(modes) and coverage['WindowSeedRows'] == len(seeds)
                      and all(np.array_equal(h.blocks, np.flatnonzero(core.ravel())) for h, _ in outcomes))
        if name == 'recovered_repeat':
            invariants &= (cycle.get('PriorTrough') == modes[0]
                           and cycle.get('InterveningReturnStart') is not None
                           and cycle['InterveningReturnStart'] < cycle['Onset'])
        if name == 'uninterrupted_decline':
            invariants &= cycle.get('InterveningReturnStart') is None
        if name == 'nested_local':
            invariants &= bool(cycle.get('RawRiseObserved') and cycle.get('RelativeReturnObserved'))
        if name == 'contaminated_controls':
            invariants &= len({r['State'] for r in actual.get('LeaveOneOut', [])}) > 1
        if name == 'unavailable_phase':
            invariants &= not cycle
        results.append({'Case': name, 'Expected': expected, 'Observed': actual.get('State'),
                        'Invariants': bool(invariants), 'Passed': actual.get('State') == expected and invariants,
                        'RawCycle': actual.get('RawCycle'), 'RelativeCycle': cycle,
                        'LeaveOneOut': actual.get('LeaveOneOut', [])})
    return results


def test_six_constructed_checks():
    results = constructed_checks()
    assert len(results) == 6 and all(r['Passed'] for r in results), results
