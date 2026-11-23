"""Numerical primitives for the isolated joint video experiment."""
import warnings
import numpy as np
from scipy import ndimage, optimize


def robust_scale(x):
    x = np.asarray(x, float)
    x = x[np.isfinite(x)]
    if not len(x):
        return None
    return float(1.4826 * np.median(np.abs(x - np.median(x))))


def roughness(x):
    """Short-lag variability proxy, not an independent camera-noise estimate."""
    x = np.asarray(x, float)
    if x.ndim == 1:
        differences = np.diff(x)
        value = robust_scale(differences)
        level = np.nanmax(np.abs(x)) if np.any(np.isfinite(x)) else 0.
        return max((value or 0.) / np.sqrt(2.), level * 1e-7, 1e-6)
    flat = x.reshape(len(x), -1)
    result = np.empty(flat.shape[1], np.float32)
    for start in range(0, flat.shape[1], 256):
        values = flat[:, start:start + 256]
        with warnings.catch_warnings():
            warnings.simplefilter('ignore', RuntimeWarning)
            difference = np.diff(values, axis=0)
            center = np.nanmedian(difference, axis=0)
            scale = 1.4826 * np.nanmedian(np.abs(difference - center), axis=0) / np.sqrt(2.)
            level = np.nanmax(np.abs(values), axis=0)
        scale = np.maximum(scale, np.maximum(level * 1e-7, 1e-6))
        scale[~np.any(np.isfinite(values), axis=0)] = np.inf
        result[start:start + len(scale)] = scale
    return result.reshape(x.shape[1:])


def strict_mean(raw, indices):
    if not len(indices):
        return np.full(len(raw), np.nan)
    values = raw.reshape(len(raw), -1)[:, indices]
    return np.where(np.all(np.isfinite(values), axis=1),
                    np.mean(values, axis=1, dtype=np.float64), np.nan)


def spatial_mean(raw, sigma):
    if sigma == 0:
        return np.asarray(raw, np.float32).copy()
    finite = np.isfinite(raw)
    value = ndimage.gaussian_filter(np.where(finite, raw, 0).astype(np.float32),
                                    (0, sigma, sigma), mode='nearest')
    if np.all(finite):
        return value
    weight = ndimage.gaussian_filter(finite.astype(np.float32), (0, sigma, sigma), mode='nearest')
    np.divide(value, weight, out=value, where=weight > 1e-6)
    value[~finite] = np.nan
    return value


def temporal_mean(values, width):
    finite = np.isfinite(values)
    result = ndimage.uniform_filter1d(np.where(finite, values, 0).astype(np.float32),
                                     width, axis=0, mode='constant', cval=0)
    count = ndimage.uniform_filter1d(finite.astype(np.float32), width, axis=0,
                                    mode='constant', cval=0)
    result[count < 1 - 1e-6] = np.nan
    return result


def flank_contrast(values, width):
    low = temporal_mean(values, width)
    before = np.full_like(low, np.nan)
    after = np.full_like(low, np.nan)
    before[width:] = low[:-width]
    after[:-width] = low[width:]
    score = np.minimum(before - low, after - low)
    return score


def pava(values, increasing=True):
    """Exact unweighted least-squares isotonic regression on finite observations."""
    x = np.asarray(values, float)
    if not increasing:
        return -pava(-x)
    assert np.all(np.isfinite(x))
    sums, counts = [], []
    for value in x:
        sums.append(float(value)); counts.append(1)
        while len(sums) > 1 and sums[-2] / counts[-2] > sums[-1] / counts[-1]:
            last, count = sums.pop(), counts.pop()
            sums[-1] += last; counts[-1] += count
    return np.repeat(np.asarray(sums) / counts, counts)


def monotone_cycle(deficit, peak):
    """Independent monotone fall/return with a permitted flat maximum deficit."""
    value = np.asarray(deficit, float)
    result = np.full(len(value), np.nan)
    left = np.flatnonzero(np.isfinite(value[:peak + 1]))
    right = np.flatnonzero(np.isfinite(value[peak:])) + peak
    if not len(left) or not len(right):
        return result
    a = np.maximum(0, pava(value[left]))
    b = np.maximum(0, pava(value[right], increasing=False))
    top = max(float(a[-1]), float(b[0]))
    a[-1] = b[0] = top
    result[left] = a; result[right] = b
    return result


def knots(values, first):
    values = np.asarray(values, float)
    valid = np.isfinite(values)
    indices = np.flatnonzero(valid & np.r_[True, (~valid[:-1]) | (values[1:] != values[:-1])])
    return {'Frames': (indices + first).tolist(), 'Values': values[indices].tolist(),
            'LastFrame': first + len(values) - 1,
            'MissingFrames': (np.flatnonzero(~valid) + first).tolist()}


def correlation(a, b):
    valid = np.isfinite(a) & np.isfinite(b)
    if valid.sum() < 4 or np.std(np.asarray(a)[valid]) < 1e-9 or np.std(np.asarray(b)[valid]) < 1e-9:
        return None
    return float(np.corrcoef(np.asarray(a)[valid], np.asarray(b)[valid])[0, 1])


def context_fit(target, comparison, time, flank):
    """Robust external-comparator loading and linear drift, estimated on flanks only."""
    valid = flank & np.isfinite(target) & np.isfinite(comparison)
    if valid.sum() < 6:
        return None
    center = float(np.mean(comparison[valid]))
    scale = max(float(np.std(comparison[valid])), roughness(comparison[valid]), 1e-6)
    design = np.column_stack([np.ones(len(time)), time, (comparison - center) / scale])
    x, y = design[valid], target[valid]
    weights = np.ones(len(y))
    beta = np.zeros(3)
    for _ in range(3):
        # Numerical stabilization must not shrink a shared physiological signal
        # into an apparent local deficit on the interval withheld from fitting.
        matrix = np.vstack([x * np.sqrt(weights[:, None]), [0, 0, 1e-6]])
        rhs = np.r_[y * np.sqrt(weights), 0.]
        beta = optimize.lsq_linear(matrix, rhs,
                    bounds=([-np.inf, -np.inf, 0.], [np.inf, np.inf, np.inf]), method='bvls').x
        residual = y - x @ beta
        sigma = max(robust_scale(residual) or 0., roughness(target[valid]), 1e-6)
        weights = np.minimum(1., 1.5 * sigma / np.maximum(np.abs(residual), 1e-9))
    prediction = design @ beta
    residual = target[valid] - prediction[valid]
    return {'Prediction': prediction, 'Coefficients': beta.tolist(), 'ComparatorCenter': center,
            'ComparatorScale': scale, 'FlankMeanSquare': float(np.mean(residual**2)),
            'FlankSamples': int(valid.sum()), 'FlankRank': int(np.linalg.matrix_rank(x)),
            'FlankResidualScale': robust_scale(residual), 'ValidFlankFrames': np.flatnonzero(valid).tolist()}


def best_persistent(deficit):
    """Best nonnegative late step or early truncated low, using identical null prediction."""
    value = np.asarray(deficit, float)
    valid = np.isfinite(value)
    sums = np.r_[0., np.cumsum(np.where(valid, value, 0.))]
    counts = np.r_[0, np.cumsum(valid)]
    best = {'Gain': 0., 'Split': None, 'Side': None, 'Level': 0.}
    for split in range(1, len(value)):
        for lo, hi, side in [(0, split, 'early'), (split, len(value), 'late')]:
            count = counts[hi] - counts[lo]
            if count < 3:
                continue
            level = max(0., (sums[hi] - sums[lo]) / count)
            gain = level**2 * count
            if gain > best['Gain']:
                best = {'Gain': float(gain), 'Split': split, 'Side': side, 'Level': float(level)}
    return best
