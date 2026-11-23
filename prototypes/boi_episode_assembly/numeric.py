"""Detection-only state arithmetic on fixed observed cohorts."""
from dataclasses import asdict, dataclass
import numpy as np
from boi_joint_video_detector.numeric import robust_scale, strict_mean, roughness


@dataclass(frozen=True)
class Settings:
    prestate_samples: int = 20
    continuation_samples: int = 3
    recovery_samples: int = 10
    allowance_multiplier: float = 2.
    gap_blocks: int = 1
    compatible_correlation: float = .8
    shared_contrast_fraction: float = .8
    shared_correlation: float = .95
    minimum_spatial_blocks: int = 3
    minimum_coherent_fraction: float = .6
    numerical_floor: float = 1e-6
    relative_floor_fraction: float = 1e-7
    index_tile_blocks: int = 8
    index_time_samples: int = 64
    boundary_gradient_ratio: float = 3.
    boundary_level_fraction: float = .5

    def contract(self):
        return asdict(self)


def runs(mask, minimum=1):
    x = np.asarray(mask, bool)
    edges = np.flatnonzero(np.diff(np.r_[False, x, False]))
    return [(int(a), int(b)) for a, b in zip(edges[::2], edges[1::2]) if b - a >= minimum]


def reference(values, first, settings=None):
    """Reference is diagnostic only; sample indices are zero-based internally."""
    s = settings or Settings()
    p = np.asarray(values, float)[first:first + s.prestate_samples]
    if len(p) != s.prestate_samples or not np.all(np.isfinite(p)):
        return None
    half = len(p) // 2
    left, right = float(np.median(p[:half])), float(np.median(p[half:]))
    x = np.arange(len(p), dtype=float)
    centers = [(half - 1) / 2, (half + len(p) - 1) / 2]
    trend = left + (right - left) * (x - centers[0]) / (centers[1] - centers[0])
    floor = max(s.numerical_floor, float(np.max(np.abs(p))) * s.relative_floor_fraction)
    allowance = max(robust_scale(p - trend) or 0.,
                    (robust_scale(np.diff(p)) or 0.) / np.sqrt(2.), floor)
    center = float(np.median(p))
    return {'First': first + 1, 'Last': first + len(p), 'Median': center,
            'Allowance': float(allowance), 'HalfMedians': [left, right],
            'Stable': abs(right - left) <= s.allowance_multiplier * allowance,
            'LowerBand': center - s.allowance_multiplier * allowance,
            'Clean': bool(np.all(p >= center - s.allowance_multiplier * allowance)),
            'ScientificReferenceAccepted': False}


def reference_bank(values, settings=None):
    s = settings or Settings()
    value = np.asarray(values, float)
    if len(value) < s.prestate_samples:
        return []
    p = np.lib.stride_tricks.sliding_window_view(value, s.prestate_samples)
    half = s.prestate_samples // 2
    finite = np.all(np.isfinite(p), axis=1)
    safe = np.where(np.isfinite(p), p, 0.)
    left = np.median(safe[:, :half], axis=1); right = np.median(safe[:, half:], axis=1)
    position = (np.arange(s.prestate_samples) - (half - 1) / 2) / (s.prestate_samples / 2)
    residual = safe - (left[:, None] + (right - left)[:, None] * position)
    residual_scale = 1.4826 * np.median(np.abs(residual - np.median(residual, axis=1)[:, None]), axis=1)
    difference = np.diff(safe, axis=1)
    short_scale = 1.4826 * np.median(np.abs(difference - np.median(difference, axis=1)[:, None]), axis=1) / np.sqrt(2.)
    floor = np.maximum(s.numerical_floor, np.max(np.abs(safe), axis=1) * s.relative_floor_fraction)
    scales = np.maximum(np.maximum(residual_scale, short_scale), floor)
    medians = np.median(safe, axis=1)
    return [None if not finite[i] else
            {'First': i + 1, 'Last': i + s.prestate_samples, 'Median': float(medians[i]),
             'Allowance': float(scales[i]), 'HalfMedians': [float(left[i]), float(right[i])],
             'Stable': bool(abs(right[i] - left[i]) <= s.allowance_multiplier * scales[i]),
             'LowerBand': float(medians[i] - s.allowance_multiplier * scales[i]),
             'Clean': bool(np.all(safe[i] >= medians[i] - s.allowance_multiplier * scales[i])),
             'ScientificReferenceAccepted': False} for i in range(len(p))]


def profile(values, anchor, settings=None, bank=None):
    """Follow one raw depression beyond its seed window, permitting many minima."""
    s = settings or Settings()
    x = np.asarray(values, float)
    n = len(x)
    anchor = int(np.clip(anchor, 0, n - 1))
    refs = bank if bank is not None else reference_bank(x, s)
    low = x[anchor]
    eligible = [(i, r) for i, r in enumerate(refs)
                if r is not None and r['Last'] <= anchor - s.continuation_samples + 1
                and np.isfinite(low) and r['Median'] - low >= s.allowance_multiplier * r['Allowance']]
    stable = [(i, r) for i, r in eligible if r['Stable'] and r.get('Clean', True)]
    chosen = (stable or eligible)
    ref = chosen[-1][1] if chosen else None
    if ref is None:
        return {'Reference': None, 'Start': None, 'End': None, 'ConfirmationThrough': None,
                'State': 'unresolved', 'Anchor': anchor + 1, 'Minima': [anchor + 1],
                'ShortReturns': [], 'Flags': ['prestate_unavailable'], 'ObservationMissing': bool(np.any(~np.isfinite(x)))}
    lower, scale = ref['LowerBand'], ref['Allowance']
    depressed = np.isfinite(x) & (x < lower)
    start_scan = ref['Last']
    supported = [(a, b) for a, b in runs(depressed, s.continuation_samples) if b > start_scan]
    if not supported:
        return {'Reference': ref, 'Start': None, 'End': None, 'ConfirmationThrough': None,
                'State': 'unsupported', 'Anchor': anchor + 1, 'Minima': [], 'ShortReturns': [],
                'Flags': ['no_sustained_raw_deficit'], 'ObservationMissing': False}
    groups, current = [], []
    for interval in supported:
        if current:
            a = current[-1][1]; b = interval[0]
            recovered = runs(np.isfinite(x[a:b]) & (x[a:b] >= lower), s.recovery_samples)
            if recovered:
                groups.append(current); current = []
        current.append(interval)
    if current:
        groups.append(current)
    group = min(groups, key=lambda g: (0 if g[0][0] <= anchor < g[-1][1] else
                                       min(abs(anchor - g[0][0]), abs(anchor - (g[-1][1] - 1))), g[0][0]))
    first_low, last_low = group[0][0], group[-1][1]
    previous = max(ref['Last'] - 1, max((b for a, b in supported if b < first_low - s.recovery_samples), default=ref['Last'] - 1))
    preceding = x[previous:first_low + 1]
    finite = np.isfinite(preceding)
    onset = previous + int(np.argmax(np.where(finite, preceding, -np.inf))) if np.any(finite) else first_low
    lowest = float(np.min(x[first_low:last_low][np.isfinite(x[first_low:last_low])]))
    recovery = None
    for a, b in runs(np.isfinite(x[last_low:]) & (x[last_low:] >= lower), s.recovery_samples):
        a += last_low
        if float(np.median(x[a:a + s.recovery_samples])) - lowest >= s.allowance_multiplier * scale:
            recovery = a; break
    short = []
    for a, b in runs(np.isfinite(x[first_low:last_low]) & (x[first_low:last_low] >= lower)):
        if b - a < s.recovery_samples:
            short.append([first_low + a + 1, first_low + b])
    end = recovery if recovery is not None else n - 1
    missing = bool(np.any(~np.isfinite(x[onset:min(n, end + s.recovery_samples)])))
    flags = []
    if not ref['Stable']:
        flags.append('prestate_drifting')
    if missing:
        flags.append('fixed_cohort_observations_missing')
    if short:
        flags.append('short_recovery_split_merge_ambiguous')
    if recovery is None:
        flags.append('recording_end_unrecovered')
    state = 'observed_recovery' if recovery is not None and ref['Stable'] and not missing else 'unresolved'
    # Local minima are descriptive; no new episodes are created from them.
    from scipy.signal import find_peaks
    local = np.where(np.isfinite(x[onset:end + 1]), x[onset:end + 1], np.inf)
    minima = find_peaks(-local, distance=s.continuation_samples,
                        prominence=s.allowance_multiplier * scale)[0] + onset
    if not len(minima):
        minima = np.asarray([first_low + int(np.nanargmin(x[first_low:last_low]))])
    return {'Reference': ref, 'Start': onset + 1, 'FirstSupportedDeficit': first_low + 1,
            'LastSupportedDeficit': last_low, 'End': recovery + 1 if recovery is not None else None,
            'ConfirmationThrough': recovery + s.recovery_samples if recovery is not None else None,
            'State': state, 'Anchor': anchor + 1, 'Minima': (minima + 1).astype(int).tolist(),
            'ShortReturns': short, 'Flags': flags, 'ObservationMissing': missing,
            'LowValue': lowest, 'RawRise': float(np.median(x[recovery:recovery + s.recovery_samples]) - lowest) if recovery is not None else None,
            'RawDrop': ref['Median'] - lowest}
