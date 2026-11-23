"""Revisit archived proposals using fixed blocks and competing episode evidence."""
from collections import Counter
from dataclasses import dataclass

import numpy as np
from scipy import ndimage, signal

from .service import smooth_trace


SCHEMA = 'boi-video-episode-separation-0.1'


@dataclass(frozen=True)
class SeparationSettings:
    patch_blocks: int = 8
    patch_halo_blocks: int = 2
    phase_radius_seconds: float = 3
    peak_distance_seconds: float = 5
    smoothing_seconds: float = 3
    noise_lag_seconds: float = 3
    reference_seconds: float = 20
    minimum_context_seconds: float = 10
    hold_seconds: float = 5
    strength: float = 4
    remaining_deficit_fraction: float = .25
    minimum_local_fraction: float = .25
    minimum_context_signal_confidence: float = 2
    minimum_shared_regions: int = 3
    minimum_shared_correlation: float = .65
    minimum_shared_explained_fraction: float = .50
    minimum_connected_blocks: int = 2
    minimum_comparator_blocks: int = 4

    def frames(self, seconds, fs):
        return max(1, round(seconds * fs))


@dataclass(frozen=True)
class Hypothesis:
    group: int
    mode: int
    band: tuple
    phase: tuple
    blocks: np.ndarray
    role: str
    seed_rows: int
    archived_edge_codes: tuple


def seed_modes(time, blocks, size, distance):
    """Count each block once per frame across the archived stages and scales."""
    t = np.unique(time * size + blocks) // size
    start, stop = int(t.min()), int(t.max()) + 1
    counts = np.bincount(t - start, minlength=stop - start)
    blurred = np.convolve(np.pad(counts, 2), [1, 2, 3, 2, 1], mode='valid')
    peaks, _ = signal.find_peaks(np.pad(blurred, 1), distance=distance)
    return peaks - 1 + start


def archived_hypotheses(seeds, groups, first_frame, n_frames, domain, fs, settings,
                        coverage, progress=None):
    """Retain phase modes within groups, including spatial subsets of wide groups."""
    first0 = first_frame - 1
    h, w = domain.shape
    selection = np.flatnonzero((seeds[:, 0] >= first0)
                               & (seeds[:, 0] < first0 + n_frames))
    coverage['WindowSeedRows'] = len(selection)
    labels = groups[selection]
    order = np.argsort(labels, kind='stable')
    selection, labels = selection[order], labels[order]
    cuts = np.r_[0, np.flatnonzero(np.diff(labels)) + 1, len(labels)]
    radius = settings.frames(settings.phase_radius_seconds, fs)
    distance = settings.frames(settings.peak_distance_seconds, fs)
    tile = settings.patch_blocks
    halo = settings.patch_halo_blocks
    for a, b in zip(cuts[:-1], cuts[1:]):
        if a == b:
            continue
        coverage['WindowArchivedGroups'] += 1
        if progress and coverage['WindowArchivedGroups'] % 2000 == 0:
            progress(dict(coverage))
        part = seeds[selection[a:b]]
        time, row, col = part[:, :3].astype(np.intp).T
        time -= first0
        usable = domain[row, col]
        coverage['InDomainSeedRows'] += int(usable.sum())
        if not usable.all():
            part, time, row, col = part[usable], time[usable], row[usable], col[usable]
        if not len(time):
            coverage['GroupsWithoutHypothesis'] += 1
            continue
        flat = row * w + col
        if np.unique(flat).size < settings.minimum_connected_blocks:
            coverage['GroupsWithoutHypothesis'] += 1
            coverage['IsolatedSeedGroups'] += 1
            continue
        # Tiles contribute possible cores. The whole group is always considered,
        # so the tile width does not impose a maximum extent on a phase.
        regions = [('whole_phase', np.ones(len(flat), dtype=bool))]
        if np.ptp(row) >= tile or np.ptp(col) >= tile:
            for r, c in np.unique(np.column_stack((row // tile, col // tile)), axis=0):
                region = ((row >= r * tile - halo) & (row < (r + 1) * tile + halo)
                          & (col >= c * tile - halo) & (col < (c + 1) * tile + halo))
                if not region.all():
                    regions.append(('local_core', region))
        seen = set()
        for role, region in regions:
            if np.unique(flat[region]).size < settings.minimum_connected_blocks:
                continue
            for mode in seed_modes(time[region], flat[region], h * w, distance):
                band = max(0, mode - radius), min(n_frames, mode + radius + 1)
                use = np.flatnonzero(region & (time >= band[0]) & (time < band[1]))
                rr, cc = row[use], col[use]
                r0, c0 = rr.min(), cc.min()
                occupied = np.zeros((rr.max() - r0 + 1, cc.max() - c0 + 1), bool)
                occupied[rr - r0, cc - c0] = True
                patches, count = ndimage.label(occupied, structure=np.ones((3, 3), bool))
                member = patches[rr - r0, cc - c0]
                for label in range(1, count + 1):
                    chosen = use[member == label]
                    blocks = np.unique(flat[chosen])
                    if len(blocks) < settings.minimum_connected_blocks:
                        coverage['IsolatedPhaseComponents'] += 1
                        continue
                    key = (int(mode), blocks.tobytes())
                    if key in seen:
                        coverage['DuplicatePhaseComponents'] += 1
                        continue
                    seen.add(key)
                    start, end = np.median(part[chosen, 3:5], axis=0).astype(int) - first0
                    phase = max(0, min(start, band[0])), min(n_frames, max(end + 1, band[1]))
                    coverage['Hypotheses'] += 1
                    coverage[role] += 1
                    yield Hypothesis(int(labels[a]) + 1, int(mode), band, phase, blocks,
                                     role, len(chosen), tuple(np.unique(part[chosen, 11]).astype(int)))
        coverage['GroupsWithHypothesis' if seen else 'GroupsWithoutHypothesis'] += 1


class Surroundings:
    """Fixed disjoint grid patches, selected by position and archived observability."""

    def __init__(self, raw, domain, confidence, settings):
        h, w = domain.shape
        rr, cc = np.indices((h, w))
        tile = settings.patch_blocks
        self.width = w
        self.patch_map = ((rr // tile) * ((w + tile - 1) // tile) + cc // tile).ravel()
        self.patches = {}
        usable = (domain & (confidence >= settings.minimum_context_signal_confidence)).ravel()
        for index in np.unique(self.patch_map):
            blocks = np.flatnonzero((self.patch_map == index) & usable)
            if len(blocks) >= settings.minimum_comparator_blocks:
                center = np.array([np.mean(blocks // w), np.mean(blocks % w)])
                self.patches[int(index)] = (blocks, center, raw[:, blocks].mean(axis=1, dtype=float))
        self.ids = np.array(list(self.patches), dtype=int)
        self.centers = np.array([entry[1] for entry in self.patches.values()]).reshape(-1, 2)

    def choose(self, blocks):
        center = np.array([np.mean(blocks // self.width), np.mean(blocks % self.width)])
        eligible = ~np.isin(self.ids, self.patch_map[blocks])
        offset = self.centers - center
        quadrant_ids = 2 * (offset[:, 0] >= 0) + (offset[:, 1] >= 0)
        distance = np.sum(offset ** 2, axis=1)
        chosen = []
        for quadrant in range(4):
            options = np.flatnonzero(eligible & (quadrant_ids == quadrant))
            if len(options):
                near = int(self.ids[options[np.argmin(distance[options])]])
                reverse = options[::-1]
                far = int(self.ids[reverse[np.argmax(distance[reverse])]])
                chosen.append((near, quadrant, 'nearby'))
                if far != near:
                    chosen.append((far, quadrant, 'distant'))
        return chosen


def lag_variation(values, lag):
    """Empirical variation of filtered observations, in their original units."""
    delta = values[lag:] - values[:-lag]
    delta = delta[np.isfinite(delta)]
    if not len(delta):
        return None
    return max(1e-5, float(1.4826 * np.median(np.abs(delta - np.median(delta)))))


def preceding_window(rolling, start, trough, hold, minimum, noise):
    if trough - start < minimum:
        return None
    possible = rolling[start:trough - hold + 1]
    finite = np.isfinite(possible)
    if not finite.any():
        return None
    peak = np.max(possible[finite])
    return start + int(np.flatnonzero(finite & (possible >= peak - noise))[-1])


def rolling_median(trace, hold):
    return np.median(np.lib.stride_tricks.sliding_window_view(trace, hold), axis=-1)


def decline_start(filtered, reference, trough, tolerance, hold):
    begin = reference + hold
    above = np.flatnonzero(filtered[begin:trough] >= np.median(filtered[reference:begin]) - tolerance)
    return begin + int(above[-1]) + 1 if len(above) else begin


def recovery_evidence(rolling, rolling_raw, t, stop, ref, hold, depth, raw_depth,
                      noise, raw_noise, settings):
    tolerance = max(settings.strength * noise, settings.remaining_deficit_fraction * depth)
    raw_tol = max(settings.strength * raw_noise, settings.remaining_deficit_fraction * raw_depth)
    possible = np.arange(t + 1, max(t + 1, stop - hold + 1))
    rel = rolling[possible] >= rolling[ref] - tolerance
    rise = rolling_raw[possible] >= rolling_raw[ref] - raw_depth + settings.strength * raw_noise
    absolute = np.abs(rolling_raw[possible] - rolling_raw[ref]) <= raw_tol
    qualified = possible[rel & rise]
    return {
        'RelativeReturnObserved': bool(rel.any()),
        'RawRiseObserved': bool(rise.any()),
        'AbsoluteReturnObserved': bool(absolute.any()),
        'RelativeReturnStart': int(possible[rel][0]) if rel.any() else None,
        'RecoveryStart': int(qualified[0]) if len(qualified) else None,
        'RawWithinPrecedingAtRecovery': bool(absolute[rel & rise][0]) if len(qualified) else None,
        'RelativeTolerance': float(tolerance),
        'AbsoluteTolerance': float(raw_tol),
    }


def cycle_evidence(trace, raw, motion, band, span, fs, settings):
    """Use one observed cohort through its own pre-state, dip and bounded return."""
    lo, hi = span
    hold = settings.frames(settings.hold_seconds, fs)
    minimum = max(hold, settings.frames(settings.minimum_context_seconds, fs))
    width = settings.frames(settings.smoothing_seconds, fs)
    lag = settings.frames(settings.noise_lag_seconds, fs)
    usable = np.isfinite(trace) & np.isfinite(raw) & ~motion
    s = smooth_trace(np.where(usable, trace, np.nan), width)
    sr = smooth_trace(np.where(usable, raw, np.nan), width)
    s[~usable], sr[~usable] = np.nan, np.nan
    left, right = band
    result = {'State': 'phase_unavailable', 'PriorComparison': 'unavailable',
              'RecoveryStart': None, 'HoldSamples': hold}
    if len(trace) < hold or not np.isfinite(s[left:right]).any():
        return result
    trough = left + int(np.nanargmin(s[left:right]))
    holes = np.flatnonzero(~usable[lo:hi]) + lo
    prior_holes, later_holes = holes[holes < trough], holes[holes > trough]
    start = int(prior_holes[-1] + 1) if len(prior_holes) else lo
    stop = int(later_holes[0]) if len(later_holes) else hi
    result.update(Trough=trough, ContiguousSpan=(start, stop))
    if trough - start < minimum or stop - trough <= hold:
        return result
    noise, raw_noise = lag_variation(s[start:stop], lag), lag_variation(sr[start:stop], lag)
    if noise is None or raw_noise is None:
        return result
    rolling = rolling_median(np.where(usable, trace, np.nan), hold)
    rolling_raw = rolling_median(np.where(usable, raw, np.nan), hold)
    peaks, _ = signal.find_peaks(-s[start:stop], prominence=settings.strength * noise,
                                 distance=settings.frames(settings.peak_distance_seconds, fs))
    peaks += start
    # A potential neighbouring phase needs its own raw dip on the same blocks.
    raw_peaks, _ = signal.find_peaks(-sr[start:stop], prominence=settings.strength * raw_noise,
                                     distance=settings.frames(settings.peak_distance_seconds, fs))
    raw_peaks += start
    if len(raw_peaks):
        peaks = peaks[(np.abs(peaks[:, None] - raw_peaks) <= width).any(axis=1)]
    else:
        peaks = peaks[:0]
    previous, following = peaks[peaks < left], peaks[peaks >= right]
    prior = int(previous[-1]) if len(previous) else None
    after = int(following[0]) if len(following) else None
    ref = preceding_window(rolling, start if prior is None else prior + 1,
                            trough, hold, hold if prior is not None else minimum, noise)
    if ref is None:
        return result
    raw_depth, depth = float(rolling_raw[ref] - sr[trough]), float(rolling[ref] - s[trough])
    onset = decline_start(s, ref, trough, max(2 * noise, .20 * depth), hold)
    limit = stop
    if after is not None:
        next_ref = preceding_window(rolling, trough + 1, after, hold, hold, noise)
        limit = after if next_ref is None else decline_start(
            s, next_ref, after, max(2 * noise, .20 * (rolling[next_ref] - s[after])), hold)
    result.update(Reference=(ref, ref + hold), Onset=onset, RecoverySearchStop=int(limit),
                  PriorTrough=prior, NextTrough=after, RawDepth=raw_depth,
                  RelativeDepth=depth, RawNoise=raw_noise, RelativeNoise=noise,
                  RawReference=float(rolling_raw[ref]), RelativeReference=float(rolling[ref]),
                  RawAtTrough=float(sr[trough]), RelativeAtTrough=float(s[trough]))
    result.update(recovery_evidence(rolling, rolling_raw, trough, limit, ref, hold, depth,
                                    raw_depth, noise, raw_noise, settings))
    result['PriorComparison'] = 'no_supported_prior_dip'
    if prior is not None:
        prior_ref = preceding_window(rolling, start, prior, hold, minimum, noise)
        if prior_ref is None or onset - prior <= hold:
            result['PriorComparison'] = 'unresolved_prior_state'
        else:
            earlier_raw = float(rolling_raw[prior_ref] - sr[prior])
            earlier_rel = float(rolling[prior_ref] - s[prior])
            earlier = recovery_evidence(rolling, rolling_raw, prior, onset, prior_ref, hold,
                                        earlier_rel, earlier_raw, noise, raw_noise, settings)
            result['PriorReference'] = (prior_ref, prior_ref + hold)
            result['InterveningReturnStart'] = earlier['RecoveryStart']
            if earlier_raw < settings.strength * raw_noise or earlier_rel < settings.strength * noise:
                result['PriorComparison'] = 'unresolved_prior_state'
            else:
                result['PriorComparison'] = ('returned_before_renewed_decline'
                                             if earlier['RecoveryStart'] is not None
                                             else 'linked_without_observed_return')
    if raw_depth < settings.strength * raw_noise:
        result['State'] = 'raw_decline_unsupported'
    elif depth < max(settings.strength * noise, settings.minimum_local_fraction * raw_depth):
        result['State'] = 'relative_decline_unsupported'
    elif result['RecoveryStart'] is None:
        result['State'] = 'recovery_unresolved'
    else:
        result['State'] = {
            'no_supported_prior_dip': 'local_cycle',
            'returned_before_renewed_decline': 'separated_local_cycle',
            'linked_without_observed_return': 'linked_dips',
            'unresolved_prior_state': 'prior_state_unresolved',
        }[result['PriorComparison']]
    return result


def regional_fit(raw, comparators, lo, hi, fs, settings):
    """Fit a nonnegative loading on a common waveform with per-patch scaling."""
    section = slice(lo, hi)
    matrix = comparators[:, section]
    scale = np.diff(np.quantile(matrix, [.10, .90], axis=1), axis=0)[0]
    centered = (comparators - np.median(matrix, axis=1)[:, None]) / np.maximum(scale[:, None], 1e-5)
    shared = np.median(centered, axis=0)
    g = shared[section] - shared[section].mean()
    y = raw[section] - raw[section].mean()
    gg, yy = float(g @ g), float(y @ y)
    beta = max(0., float(g @ y) / gg) if gg > 1e-12 else 0.
    base = float(raw[section].mean() - beta * shared[section].mean())
    prediction = base + beta * shared
    error = raw[section] - prediction[section]
    explained = max(0., 1 - float(error @ error) / yy) if yy > 1e-12 else 0.
    controls = matrix - matrix.mean(axis=1)[:, None]
    energy = np.sqrt(np.sum(controls ** 2, axis=1) * gg)
    correlation = np.divide(controls @ g, energy, out=np.zeros(len(controls)), where=energy > 1e-12)
    lag = settings.frames(settings.noise_lag_seconds, fs)
    variation = np.array([lag_variation(trace, lag) or np.inf for trace in matrix])
    supports = ((correlation >= settings.minimum_shared_correlation)
                & (scale >= settings.strength * variation))
    return prediction, {'Loading': beta, 'Intercept': base, 'ExplainedFraction': explained,
                        'CoherentRegions': int(supports.sum()),
                        'RegionCorrelations': correlation.tolist()}


def assess_hypothesis(raw, surroundings, motion, hypothesis, fs, settings, details=False):
    """Compare shared-only and shared-plus-local explanations and remove each control."""
    n = len(raw)
    blocks = hypothesis.blocks
    x = raw[:, blocks].mean(axis=1, dtype=float)
    ref_width = settings.frames(settings.reference_seconds, fs)
    left, right = hypothesis.phase
    span = max(0, left - 2 * ref_width), min(n, right + 2 * ref_width)
    fit = max(0, left - ref_width), min(n, right + ref_width)
    raw_cycle = cycle_evidence(x, x, motion, hypothesis.band, span, fs, settings)
    complete = np.isfinite(x[fit[0]:fit[1]]) & ~motion[fit[0]:fit[1]]
    choices = [choice for choice in surroundings.choose(blocks)
               if np.isfinite(surroundings.patches[choice[0]][2][fit[0]:fit[1]]).all()]
    comparators = (np.stack([surroundings.patches[index][2] for index, _, _ in choices])
                   if choices else np.empty((0, n), dtype=float))
    result = {'State': 'context_unavailable', 'RawCycle': raw_cycle, 'FitRange': fit,
              'RegionIDs': [index for index, _, _ in choices], 'RelativeCycle': None,
              'SharedModel': None, 'LeaveOneOut': [], 'ContextStable': False}
    prediction, residual = np.full(n, np.nan), np.full(n, np.nan)
    if not complete.all():
        result['State'] = 'phase_unavailable'
    elif len(choices) >= settings.minimum_shared_regions:
        states = []
        for omitted in [None, *range(len(choices))]:
            other = comparators if omitted is None else np.delete(comparators, omitted, axis=0)
            curve, shared = regional_fit(x, other, *fit, fs, settings)
            residual_cycle = cycle_evidence(x - curve, x, motion, hypothesis.band, span, fs, settings)
            state = residual_cycle['State']
            if (state in ('raw_decline_unsupported', 'relative_decline_unsupported')
                    and raw_cycle.get('RawDepth', 0.) > 0.
                    and raw_cycle['RawDepth'] >= settings.strength * raw_cycle['RawNoise']
                    and residual_cycle['RelativeDepth'] < max(
                        settings.strength * residual_cycle['RelativeNoise'],
                        settings.minimum_local_fraction * raw_cycle['RawDepth'])
                    and shared['CoherentRegions'] >= settings.minimum_shared_regions
                    and shared['ExplainedFraction'] >= settings.minimum_shared_explained_fraction):
                state = 'regional_explains_decline'
            states.append(state)
            if omitted is None:
                result['RelativeCycle'], result['SharedModel'] = residual_cycle, shared
                prediction, residual = curve, x - curve
            else:
                result['LeaveOneOut'].append({'OmittedRegionID': choices[omitted][0], 'State': state,
                                              'Trough': residual_cycle.get('Trough'),
                                              'RecoveryStart': residual_cycle.get('RecoveryStart')})
        result['ContextStable'] = all(s == states[0] for s in states)
        result['State'] = states[0] if result['ContextStable'] else 'context_sensitive'
        result['AllRegionsState'] = states[0]
        if result['State'] in ('local_cycle', 'separated_local_cycle'):
            cycle = result['RelativeCycle']
            a, b = cycle['Reference']
            t, r, hold = cycle['Trough'], cycle['RecoveryStart'], cycle['HoldSamples']
            pre = np.median(raw[a:b, blocks], axis=0)
            post = np.median(raw[r:r + hold, blocks], axis=0)
            coherent = int(np.count_nonzero((pre > raw[t, blocks]) & (post > raw[t, blocks])))
            result['BlocksWithObservedFallAndRise'] = coherent
            if coherent < max(settings.minimum_connected_blocks, (len(blocks) + 1) // 2):
                result['State'] = 'spatial_coherence_unresolved'
    if details:
        result['Traces'] = {'Raw': x, 'SharedPrediction': prediction, 'LocalResidual': residual,
                            'Comparators': comparators}
        result['Regions'] = [
            {'ID': index, 'Quadrant': quadrant, 'Role': role, 'Blocks': surroundings.patches[index][0]}
            for index, quadrant, role in choices]
    return result


def evaluate_window(raw, seeds, groups, first_frame, domain, confidence, motion, fs, settings,
                    progress=None):
    """Yield all assessed fixed-cohort hypotheses and an explicit coverage ledger."""
    coverage = Counter()
    flat = raw.reshape(len(raw), -1)
    surroundings = Surroundings(flat, domain, confidence, settings)

    def assessments():
        for h in archived_hypotheses(seeds, groups, first_frame, len(raw), domain, fs,
                                     settings, coverage, progress):
            yield h, assess_hypothesis(flat, surroundings, motion, h, fs, settings)

    return assessments(), coverage, surroundings
