"""Experimental whole-video episode proposals; never scientific measurements.

Every image location is searched at overlapping spatial scales. Temporal valley
prominence is accumulated before spatial grouping, so a location need not first
pass an instantaneous segmentation threshold. Original service.py is unchanged.
"""
from dataclasses import dataclass, asdict, replace
import warnings

import numpy as np
from scipy import ndimage, signal

from .service import (Settings, assess_episode, global_motion, mad, noise_of,
                      spatial_mean, temporal_mean)

SCHEMA = 'boi-video-episode-revision-0.1'
SEED_COLUMNS = ('Frame0', 'Row0', 'Column0', 'Start0', 'End0', 'LeftBase0',
                'RightBase0', 'ProminenceNoiseUnits', 'StageIndex', 'ScaleIndex',
                'ChannelIndex', 'BoundaryCode')


@dataclass(frozen=True)
class EpisodeSettings:
    block_pixels: int = 4
    spatial_sigma_blocks: tuple = (0., 1., 2.)
    surrounding_sigma_blocks: float = 12.
    smoothing_seconds: float = 3.
    noise_lag_seconds: float = 3.
    minimum_width_seconds: float = 5.
    minimum_peak_distance_seconds: float = 5.
    prominence_noise_units: float = 4.
    grouping_time_radius_seconds: float = 1.
    grouping_space_radius_blocks: int = 1
    minimum_finite_fraction: float = .9
    minimum_signal_confidence: float = 2.
    boundary_context_seconds: float = 60.
    reference_context_seconds: float = 20.
    assessment_gap_seconds: float = 2.
    minimum_context_seconds: float = 10.
    recovery_hold_seconds: float = 5.
    minimum_local_fraction_of_raw_decline: float = .25
    minimum_raw_deficit_recovered: float = .5
    native_seed_noise_units: float = 4.
    native_grow_noise_units: float = 2.

    def frames(self, seconds, fs):
        return max(1, int(round(seconds * fs)))

    def sensitivity(self):
        return replace(self, prominence_noise_units=3.)

    def contract(self):
        return asdict(self)


def search_context(raw, fs, settings):
    """Eligibility is valid observed data, not a field-wide brightness cutoff."""
    valid = np.isfinite(raw) & (raw >= 0) & (raw < 65535)
    fraction = valid.mean(axis=0)
    with warnings.catch_warnings():
        warnings.simplefilter('ignore', RuntimeWarning)
        level = np.nanmedian(np.where(valid, raw, np.nan), axis=0)
        high = np.nanpercentile(np.where(valid, raw, np.nan), 95, axis=0)
    domain = (fraction >= settings.minimum_finite_fraction) & (high > 0)
    noise = noise_of(np.where(valid, raw, np.nan))
    finite_levels = level[np.isfinite(level)]
    dark = float(np.percentile(finite_levels, 10)) if len(finite_levels) else 0.
    confidence = np.maximum(0., (high - dark) / np.maximum(noise, 1e-6))
    confidence = np.nan_to_num(confidence, nan=0.).astype(np.float32)
    motion_settings = Settings()
    shifts, ratios, motion = global_motion(np.where(valid, raw, np.nan), domain,
                                           motion_settings)
    return {'Domain': domain, 'Valid': valid, 'FiniteFraction': fraction,
            'Level': level, 'RawNoise': noise, 'SignalConfidence': confidence,
            'MotionFlag': motion, 'GlobalShiftBlocks': shifts,
            'GlobalMotionPeakRatio': ratios,
            'Quality': {'Method': 'valid finite nonnegative unsaturated block observations; no brightness gate',
                        'EligibleBlocks': int(domain.sum()), 'TotalBlocks': int(domain.size),
                        'DarkReferenceForConfidenceOnly': dark,
                        'ConfidenceIsAnatomy': False, 'NormalizationSupportChanged': False,
                        'SaturationCheck': 'whole-block mean at sensor maximum; native samples checked separately'}}


def lag_noise(movie, lag):
    """Empirical variation of the actually smoothed signal at the stated lag.

    No independent-pixel or white-noise standard-error scaling is assumed.
    """
    delta = movie[lag:] - movie[:-lag]
    result = mad(delta, axis=0)
    positive = result[np.isfinite(result) & (result > 0)]
    floor = max(float(np.median(positive)) * .1, 1e-5) if positive.size else 1e-5
    return np.maximum(np.nan_to_num(result, nan=floor), floor).astype(np.float32)


def trace_seeds(x, noise, fs, settings):
    """All qualified valleys and explicit recording-edge states, no shortlist."""
    n = len(x)
    finite = np.isfinite(x)
    if finite.sum() < settings.frames(settings.minimum_context_seconds, fs):
        return [], (0, 0, 0)
    filled = np.interp(np.arange(n), np.flatnonzero(finite), x[finite])
    distance = settings.frames(settings.minimum_peak_distance_seconds, fs)
    peaks, properties = signal.find_peaks(
        -filled, prominence=settings.prominence_noise_units * noise,
        distance=distance)
    minimum_width = settings.frames(settings.minimum_width_seconds, fs)
    seeds = []
    if len(peaks):
        widths, _, left, right = signal.peak_widths(
            -filled, peaks, rel_height=.8,
            prominence_data=(properties['prominences'], properties['left_bases'],
                             properties['right_bases']))
        # Width at half prominence is recorded separately from 80% phase bounds.
        half_widths = signal.peak_widths(
            -filled, peaks, rel_height=.5,
            prominence_data=(properties['prominences'], properties['left_bases'],
                             properties['right_bases']))[0]
        for i, peak in enumerate(peaks):
            if half_widths[i] < minimum_width:
                continue
            seeds.append((int(peak), max(0, int(np.floor(left[i]))),
                          min(n - 1, int(np.ceil(right[i]))),
                          int(properties['left_bases'][i]),
                          int(properties['right_bases'][i]),
                          float(properties['prominences'][i] / noise), 0))
    # Boundary changes are retained as incomplete evidence, not closed valleys.
    width = min(n, settings.frames(settings.boundary_context_seconds, fs))
    hold = min(n, settings.frames(settings.recovery_hold_seconds, fs))
    early = float(np.mean(filled[:hold]))
    later = int(np.argmax(filled[:width]))
    drop = filled[later] - early
    if drop >= settings.prominence_noise_units * noise and later >= minimum_width:
        end = int(np.flatnonzero(filled[:later + 1] >= early + .8 * drop)[0])
        seeds.append((int(np.argmin(filled[:hold])), 0, end, 0, later,
                      float(drop / noise), 1))
    late = float(np.mean(filled[-hold:]))
    earlier = int(np.argmax(filled[:-hold])) if n > hold else 0
    drop = filled[earlier] - late
    if drop >= settings.prominence_noise_units * noise and n - 1 - earlier >= minimum_width:
        remaining = np.flatnonzero(filled[earlier:] >= filled[earlier] - .2 * drop)
        start = earlier + int(remaining[-1]) if len(remaining) else earlier
        seeds.append((n - hold + int(np.argmin(filled[-hold:])), start, n - 1,
                      earlier, n - 1, float(drop / noise), 2))
    extrema = int(np.count_nonzero((filled[1:-1] < filled[:-2]) &
                                  (filled[1:-1] <= filled[2:])))
    return seeds, (extrema, len(peaks), sum(s[-1] == 0 for s in seeds))


class _SeedRows:
    """Append exact float64 rows without retaining millions of Python tuples."""
    def __init__(self, width, chunk_size=8192):
        self.width = width
        self.chunk_size = chunk_size
        self.count = 0
        self.chunks = []

    def __len__(self):
        return self.count

    def append(self, values):
        position = self.count % self.chunk_size
        if position == 0:
            self.chunks.append(np.empty((self.chunk_size, self.width), np.float64))
        self.chunks[-1][position] = values
        self.count += 1

    def finish(self):
        if not self.count:
            return np.empty((0, self.width), np.float64)
        chunks = self.chunks[:-1] + [self.chunks[-1][:(self.count-1) % self.chunk_size+1]]
        result = np.concatenate(chunks, axis=0)
        self.chunks = []
        return result


def generate_seeds(raw, denoised, fs, settings, context, progress=None):
    n, h, w = raw.shape
    domain = context['Domain']
    lag = min(n - 1, settings.frames(settings.noise_lag_seconds, fs))
    records = _SeedRows(len(SEED_COLUMNS))
    stages = []
    smoothing = settings.frames(settings.smoothing_seconds, fs)
    for stage_index, source in enumerate((raw, denoised)):
        source = np.where(context['Valid'], source, np.nan)
        for scale_index, sigma in enumerate(settings.spatial_sigma_blocks):
            patch = spatial_mean(source, domain, sigma)
            with warnings.catch_warnings():
                warnings.simplefilter('ignore', RuntimeWarning)
                level = np.nanmedian(patch, axis=0)
            fraction = np.divide(100 * patch, level[None], out=np.full_like(patch, np.nan),
                                 where=level[None] > 0)
            fraction -= 100.
            surrounding = spatial_mean(fraction, domain,
                                       settings.surrounding_sigma_blocks)
            for channel_index in (0, 1):
                movie = fraction if channel_index == 0 else fraction - surrounding
                smooth = temporal_mean(movie, smoothing)
                noise = lag_noise(smooth, lag)
                totals = np.zeros(3, dtype=np.int64)
                start_count = len(records)
                for row, column in np.argwhere(domain):
                    found, counts = trace_seeds(smooth[:, row, column],
                                                float(noise[row, column]), fs, settings)
                    totals += counts
                    for frame, a, b, left, right, strength, edge in found:
                        records.append((frame, row, column, a, b, left, right,
                                        strength, stage_index, scale_index,
                                        channel_index, edge))
                entry = {'Stage': stage_index, 'Scale': scale_index,
                         'SpatialSigmaBlocks': sigma, 'Channel': channel_index,
                         'LocationsSearched': int(domain.sum()), 'FramesPerLocation': n,
                         'AllLocalMinima': int(totals[0]),
                         'ProminencePassed': int(totals[1]),
                         'WidthPassedInteriorSeeds': int(totals[2]),
                         'SeedsIncludingBoundaries': len(records) - start_count}
                stages.append(entry)
                if progress:
                    progress(entry)
                del smooth, noise, movie
            del patch, fraction, surrounding
    seeds = records.finish()
    return seeds, stages


def group_seeds(seeds, shape, fs, settings):
    """Space-time adjacency groups phase evidence, without inventing area.

    Dilation is used only for association. Returned masks consist of original
    seed centres, never the dilated pixels. Channels remain distinct.
    """
    n, h, w = shape
    groups = []
    assignment = np.full(len(seeds), -1, np.int32)
    time_radius = settings.frames(settings.grouping_time_radius_seconds, fs)
    radius = settings.grouping_space_radius_blocks
    labels_at_seeds = []
    for channel in (0, 1):
        indices = np.flatnonzero(seeds[:, 10] == channel)
        occupied = np.zeros(shape, bool)
        coordinates = seeds[indices, :3].astype(int)
        if not len(coordinates):
            continue
        occupied[tuple(coordinates.T)] = True
        expanded = ndimage.maximum_filter(occupied, size=(2*time_radius+1,
                                                         2*radius+1, 2*radius+1),
                                           mode='constant')
        labels, count = ndimage.label(expanded, structure=np.ones((3, 3, 3)))
        values = labels[tuple(coordinates.T)]
        order = np.argsort(values, kind='stable')
        cuts = np.r_[0, np.flatnonzero(np.diff(values[order])) + 1, len(order)]
        for a, b in zip(cuts[:-1], cuts[1:]):
            members = indices[order[a:b]]
            group_id = len(groups)
            assignment[members] = group_id
            groups.append(members)
        labels_at_seeds.append({'Channel': channel, 'Groups': int(count),
                                'OccupiedFrameLocations': int(occupied.sum())})
        del occupied, expanded, labels
    assert np.all(assignment >= 0) if len(seeds) else True
    return groups, assignment, labels_at_seeds


def assess_group(raw, fs, settings, context, seeds, members, identity):
    part = seeds[members]
    best = part[int(np.argmax(part[:, 7]))]
    # Local phase neighbourhood prevents a long transitive chain from silently
    # making all of its spatial locations one fixed comparison cohort.
    tolerance = max(settings.frames(5., fs), .2 * (best[4] - best[3] + 1))
    selected = part[np.abs(part[:, 0] - best[0]) <= tolerance]
    mask = np.zeros(raw.shape[1:], bool)
    mask[selected[:, 1].astype(int), selected[:, 2].astype(int)] = True
    mask &= context['Domain']
    start, stop = int(best[3]), int(best[4])
    assessment = Settings(reference_context_seconds=settings.reference_context_seconds,
                          preceding_gap_seconds=settings.assessment_gap_seconds,
                          minimum_context_seconds=settings.minimum_context_seconds,
                          recovery_hold_seconds=settings.recovery_hold_seconds)
    result, traces = assess_episode(raw, context['Domain'], mask, start, stop,
                                    fs, assessment, context['MotionFlag'])
    if result['Status'].startswith('local_reversible'):
        # Search with the complete qualification. Post-classifying only the
        # first tolerant return would hide a later well-supported recovery.
        x, contrast = traces['Raw'], traces['Contrast']
        trough = result['TroughFrame']-1
        nx, nc = result['RawNoiseInputUnits'], result['ContrastNoisePercent']
        raw_depth = result['RawDeclineNoiseUnits']*nx
        local_depth = result['LocalContrastNoiseUnits']*nc
        bx = result['RecognitionRawContextMean']
        bc = result['RecognitionContrastContextMean']
        tolerance = max(4*nc, .25*max(0, local_depth))
        required_rise = max(4*nx, settings.minimum_raw_deficit_recovered*raw_depth)
        hold = settings.frames(settings.recovery_hold_seconds, fs)
        qualified = None
        for left in range(trough+1, len(raw)-hold+1):
            right = left+hold
            if not np.all(np.isfinite(x[left:right])) or not np.all(np.isfinite(contrast[left:right])):
                continue
            post_x, post_c = float(np.median(x[left:right])), float(np.median(contrast[left:right]))
            if post_c >= bc-tolerance and post_x >= bx-raw_depth+required_rise:
                qualified = left, right, post_x, post_c
                break
        result['QualifiedRawRecoveryFound'] = qualified is not None
        if qualified:
            left, right, post_x, post_c = qualified
            result['RecoveryFrameRange'] = [left+1, right]
            result['ObservedPostRawMean'] = post_x
            result['ObservedPostContrastMean'] = post_c
            result['RawPreviousStateReturn'] = bool(abs(post_x-bx) <= max(4*nx, .25*max(0, raw_depth)))
            result['Flags'] = [f for f in result['Flags'] if f != 'raw_preceding_state_not_restored']
            if not result['RawPreviousStateReturn']:
                result['Flags'].append('raw_preceding_state_not_restored')
            first_context = result['PrecedingContextFrames'][0]-1
            if not np.all(np.isfinite(x[first_context:right])):
                result['Status'] = 'uncertain_missing_data'
                if 'missing_observations_in_episode_context' not in result['Flags']:
                    result['Flags'].append('missing_observations_in_episode_context')
            elif np.any(context['MotionFlag'][first_context:right]):
                result['Status'] = 'uncertain_motion'
                if 'global_motion_evidence' not in result['Flags']:
                    result['Flags'].append('global_motion_evidence')
        else:
            result['Status'] = 'uncertain_relative_recovery_in_changing_field'
            result['Flags'].append('raw_rise_small_relative_to_observed_deficit')
    # The original assessor retains raw rise and local return separately. A
    # small residual during a field change, or regression from a selected noisy
    # trough, is insufficient for a recovered local nomination in this revision.
    if 'RawDeclineNoiseUnits' in result:
        raw_depth = result['RawDeclineNoiseUnits'] * result['RawNoiseInputUnits']
        raw_percent = 100 * raw_depth / result['RecognitionRawContextMean']
        local_percent = result['LocalContrastNoiseUnits'] * result['ContrastNoisePercent']
        local_fraction = local_percent / raw_percent if raw_percent > 0 else None
        recovered_fraction = None
        if result.get('ObservedPostRawMean') is not None and raw_depth > 0:
            trough_level = result['RecognitionRawContextMean'] - raw_depth
            recovered_fraction = (result['ObservedPostRawMean']-trough_level)/raw_depth
        result['LocalFractionOfRawDecline'] = local_fraction
        result['RawDeficitRecoveredFraction'] = recovered_fraction
        if result['Status'].startswith('local_reversible'):
            if local_fraction is None or local_fraction < settings.minimum_local_fraction_of_raw_decline:
                result['Status'] = 'shared_change'
                result['Flags'].append('shared_change_dominates_small_local_residual')
            elif recovered_fraction is None or recovered_fraction < settings.minimum_raw_deficit_recovered:
                result['Status'] = 'uncertain_relative_recovery_in_changing_field'
                result['Flags'].append('raw_rise_small_relative_to_observed_deficit')
    edge = int(best[11])
    if edge == 1:
        result['Status'] = 'incomplete_preceding_state'
        result['RecoveryFrameRange'] = None
        result['Flags'].append('recording_start_no_observed_preceding_state')
    elif edge == 2:
        result['Flags'].append('recording_end_future_recovery_unknown')
        if result['Status'].startswith('local_reversible'):
            result['Status'] = 'uncertain_boundary_closure'
    confidence = context['SignalConfidence'][mask]
    confidence = float(np.median(confidence)) if len(confidence) else 0.
    if confidence < settings.minimum_signal_confidence:
        result['Flags'].append('low_signal_confidence_not_excluded_from_search')
        if result['Status'].startswith('local_reversible'):
            result['Status'] = 'uncertain_low_signal'
    spread = float(np.max(part[:, 0]) - np.min(part[:, 0]))
    if spread > max(settings.frames(10., fs), .5 * (best[4] - best[3] + 1)):
        result['Flags'].append('phase_chain_identity_uncertain')
        if result['Status'].startswith('local_reversible'):
            result['Status'] = 'local_reversible_candidate_identity_uncertain'
    if len(selected) < len(part):
        result['Flags'].append('comparison_cohort_uses_local_phase_subset')
    result.update({'CandidateID': f'e{identity:06d}', 'Schema': SCHEMA,
                   'SeedChannel': 'absolute' if int(best[10]) == 0 else 'local',
                   'SeedStage': 'raw' if int(best[8]) == 0 else 'provided_denoised',
                   'SeedScaleIndex': int(best[9]), 'SeedTroughFrame': int(best[0])+1,
                   'ProposedPhaseFrames': [start+1, stop+1],
                   'ValleyBaseFrames': [int(best[5])+1, int(best[6])+1],
                   'BoundaryCode': edge, 'ProminenceNoiseUnits': float(best[7]),
                   'SeedCount': len(members), 'SelectedSeedCount': len(selected),
                   'SeedFrameSpread': spread, 'SignalConfidence': confidence,
                   'ComparisonFootprintBlocks': int(mask.sum()),
                   'NativeDiagnosticComparisonPixels': int(mask.sum()) * settings.block_pixels**2,
                   'DynamicAreaAvailable': False,
                   'MeasurementReady': False, 'ScientificAreaAvailable': False,
                   'ScientificBurdenAvailable': False,
                   'RejectionStage': ('none_experimental_candidate' if result['Status'].startswith('local_reversible')
                                      else 'whole_episode_or_quality_evidence')})
    return result, np.flatnonzero(mask), traces


def detect_episodes(raw, denoised, fs=1., settings=None, context=None, progress=None):
    settings = settings or EpisodeSettings()
    assert raw.ndim == 3 and raw.shape == denoised.shape and len(raw) > 10 and fs > 0
    context = context or search_context(raw, fs, settings)
    seeds, stages = generate_seeds(raw, denoised, fs, settings, context, progress)
    groups, assignment, grouping = group_seeds(seeds, raw.shape, fs, settings)
    catalogue, masks = [], {}
    for i, members in enumerate(groups):
        candidate, indices, _ = assess_group(raw, fs, settings, context, seeds, members, i+1)
        catalogue.append(candidate)
        masks[candidate['CandidateID']] = indices.astype(np.uint32)
    coverage = np.zeros((len(raw), 4), np.int64)
    coverage[:, 0] = context['Domain'].sum()
    coverage[:, 1] = (context['Valid'] & context['Domain'][None]).sum(axis=(1, 2))
    if len(seeds):
        coverage[:, 2] = np.bincount(seeds[:, 0].astype(int), minlength=len(raw))
        occupied = np.unique(seeds[:, :3].astype(int), axis=0)
        coverage[:, 3] = np.bincount(occupied[:, 0], minlength=len(raw))
    return {'Schema': SCHEMA, 'Catalogue': catalogue, 'ComparisonMasks': masks,
            'Seeds': seeds, 'SeedColumns': SEED_COLUMNS, 'SeedGroup': assignment,
            'Coverage': coverage, 'StageCoverage': stages, 'Grouping': grouping,
            'Context': context, 'Settings': settings.contract(),
            'ScientificSaves': 0, 'BurdenCalculations': 0}


def native_support(reference, current, later, noise, seed_mask, valid,
                   seed_threshold=4., grow_threshold=2.):
    """Diagnostic connected native support; missing pixels are never zero area.

    A recovered episode needs decline and later rise at each pixel. A persistent
    episode passes later=None and has no assertion of future recovery.
    """
    observed = valid & np.isfinite(reference) & np.isfinite(current) & np.isfinite(noise)
    drop = reference - current
    if later is not None:
        observed &= np.isfinite(later)
        drop = np.minimum(drop, later-current)
    score = np.divide(drop, np.maximum(noise, 1e-6),
                      out=np.full_like(drop, np.nan, dtype=float), where=observed)
    high = observed & (score >= seed_threshold) & seed_mask
    low = observed & (score >= grow_threshold)
    support = ndimage.binary_propagation(high, mask=low, structure=np.ones((3, 3)))
    return support, score, observed
