"""Complete-cycle proposals with joint regional/local evidence, preview only.

All masks use row-major coarse indices. All public times are one-based source
frames. No original TIFF, native segmentation, scientific reference or burden IO.
"""
from dataclasses import dataclass, asdict
import warnings
import numpy as np
from scipy import ndimage
from .numeric import (roughness, strict_mean, spatial_mean, flank_contrast,
                      monotone_cycle, knots, correlation, context_fit, best_persistent)

SCHEMA = 'boi-joint-video-proposals-1'


@dataclass(frozen=True)
class Settings:
    temporal_seconds: tuple = (4., 8., 16., 32., 64., 128.)
    spatial_sigmas: tuple = (0., 1., 2., 4.)
    surrounding_sigma: float = 8.
    seed_roughness_units: float = 4.
    cycle_roughness_units: float = 3.
    minimum_joint_gain: float = 6.
    complexity_per_level: float = 1.
    search_complexity_multiplier: float = 2.
    spatial_complexity_multiplier: float = 2.
    maximum_model_rms_ratio: float = 4.
    minimum_flank_samples: int = 6
    return_remaining_fraction: float = .25
    return_hold_samples: int = 3
    patch_blocks: int = 8
    merge_containment: float = .6
    maximum_merge_size_ratio: float = 4.
    same_cycle_time_fraction: float = .5
    shared_field_correlation: float = .95
    shared_field_contrast_fraction: float = .8
    maximum_roughness_ratio: float = 4.
    motion_shift_blocks: float = 1.
    maximum_ledger_candidates: int = 100000

    def contract(self):
        return asdict(self)


def coverage(raw):
    assert raw.ndim == 3 and len(raw) > 2
    finite = np.isfinite(raw)
    return {'TotalBlockFrames': int(raw.size), 'FiniteBlockFrames': int(finite.sum()),
            'MissingBlockFrames': int((~finite).sum()),
            'BlocksEverFinite': int(np.any(finite, axis=0).sum()),
            'BlocksNeverFinite': int((~np.any(finite, axis=0)).sum()),
            'DimIntensityExclusions': 0,
            'Rule': 'all finite observations searched; no anatomical/intensity mask',
            'NativeAreaMeasured': False}


def components(active, score, route, sigma, span, kind='cycle'):
    labels, count = ndimage.label(active, structure=np.ones((3, 3, 3), bool))
    slices = ndimage.find_objects(labels)
    h, w = active.shape[1:]
    results = []
    for number, box in enumerate(slices, 1):
        if box is None:
            continue
        tt, yy, xx = np.nonzero(labels[box] == number)
        tt += box[0].start; yy += box[1].start; xx += box[2].start
        index = int(np.argmax(score[tt, yy, xx]))
        mask = np.unique(yy * w + xx).astype(np.int32)
        results.append({'ID': f'{route}-s{sigma:g}-w{span}-{kind}-{number:06d}',
            'Route': route, 'Sigma': float(sigma), 'Span': int(span), 'Kind': kind,
            'Trough': int(tt[index]), 'FirstPeak': int(tt.min()), 'LastPeak': int(tt.max()),
            'Score': float(score[tt[index], yy[index], xx[index]]), 'Mask': mask,
            'PeakVoxelCount': len(tt),
            'Bounds': [int(yy.min()), int(yy.max()), int(xx.min()), int(xx.max())]})
    return results


def generate(raw, fs, settings, progress=None):
    """Search raw and local diagnostic routes; no old-ROI or target-frame input."""
    assert np.isfinite(fs) and fs > 0
    raw = np.asarray(raw, np.float32)
    bank = []
    background = spatial_mean(raw, settings.surrounding_sigma)
    for sigma in settings.spatial_sigmas:
        smooth = spatial_mean(raw, sigma)
        for route in ['raw', 'local']:
            values = smooth if route == 'raw' else smooth - background
            scale = roughness(values)
            for seconds in settings.temporal_seconds:
                span = max(2, int(round(seconds * fs)))
                if len(raw) < 3 * span:
                    continue
                score = flank_contrast(values, span)
                score /= scale[None]
                safe = np.where(np.isfinite(score), score, -np.inf)
                maximum = ndimage.maximum_filter1d(safe, max(3, span // 2 * 2 + 1), axis=0,
                                                   mode='constant', cval=-np.inf)
                active = (safe >= settings.seed_roughness_units) & (safe >= maximum - 1e-6)
                seeds = components(active, safe, route, sigma, span)
                bank.extend(seeds)
                if len(bank) > settings.maximum_ledger_candidates:
                    raise RuntimeError('candidate_ledger_boundary; no seed shortlist was applied')
                if progress:
                    progress({'Route': route, 'Sigma': sigma, 'Span': span, 'NewSeeds': len(seeds),
                              'TotalSeeds': len(bank), 'Kind': 'cycle',
                              'SearchableBlockFrames': int(np.isfinite(score).sum()),
                              'InvalidOrBoundaryBlockFrames': int(score.size - np.isfinite(score).sum()),
                              'PeakVoxels': int(active.sum()),
                              'AccountedPeakVoxels': sum(x['PeakVoxelCount'] for x in seeds)})
                del score, safe, maximum, active
            # Explicit source-edge contrasts retain incomplete episodes.
            span = min(max(4, int(round(128 * fs))), len(raw) // 3)
            early = np.mean(values[:max(2, span // 4)], axis=0)
            later = np.mean(values[span:2 * span], axis=0)
            previous = np.mean(values[-2 * span:-span], axis=0)
            final = np.mean(values[-max(2, span // 4):], axis=0)
            for kind, frame, difference in [('start_censored', 0, later - early),
                                             ('end_censored', len(raw) - 1, previous - final)]:
                score2 = difference / scale
                score3 = np.full_like(raw, -np.inf)
                score3[frame] = score2
                active = np.zeros(raw.shape, bool)
                active[frame] = np.isfinite(score2) & (score2 >= settings.seed_roughness_units)
                seeds = components(active, score3, route, sigma, span, kind)
                bank.extend(seeds)
                if len(bank) > settings.maximum_ledger_candidates:
                    raise RuntimeError('candidate_ledger_boundary; no seed shortlist was applied')
                if progress:
                    progress({'Route': route, 'Sigma': sigma, 'Span': span, 'Kind': kind,
                              'NewSeeds': len(seeds), 'TotalSeeds': len(bank),
                              'SearchableBlockFrames': int(np.isfinite(score2).sum()),
                              'InvalidOrBoundaryBlockFrames': int(score2.size - np.isfinite(score2).sum()),
                              'PeakVoxels': int(active.sum()),
                              'AccountedPeakVoxels': sum(x['PeakVoxelCount'] for x in seeds)})
                del score3, active
            if route == 'local':
                del values
        del smooth
    return sorted(bank, key=lambda x: x['ID'])


def group(seeds, settings):
    """Consolidate comparable scale/route proposals, retaining every seed identity."""
    if not seeds:
        return []
    seeds = sorted(seeds, key=lambda x: x['ID'])
    count = len(seeds)
    parent = list(range(count))
    bounds = np.asarray([x['Bounds'] for x in seeds])
    times = np.asarray([x['Trough'] for x in seeds])
    spans = np.asarray([x['Span'] for x in seeds])
    sizes = np.asarray([len(x['Mask']) for x in seeds])

    def find(i):
        while parent[i] != i:
            parent[i] = parent[parent[i]]; i = parent[i]
        return i

    for i, seed in enumerate(seeds):
        box = bounds[i]
        candidates = np.flatnonzero((np.arange(count) > i) &
            (np.abs(times - times[i]) <= settings.same_cycle_time_fraction * np.minimum(spans, spans[i]) + 2) &
            (bounds[:, 0] <= box[1]) & (bounds[:, 1] >= box[0]) &
            (bounds[:, 2] <= box[3]) & (bounds[:, 3] >= box[2]) &
            (np.maximum(sizes, sizes[i]) <= settings.maximum_merge_size_ratio * np.minimum(sizes, sizes[i])))
        for j in candidates:
            if seeds[j]['Kind'] != seed['Kind']:
                continue
            common = len(np.intersect1d(seed['Mask'], seeds[j]['Mask'], assume_unique=True))
            if common >= settings.merge_containment * min(sizes[i], sizes[j]):
                a, b = find(i), find(int(j))
                if a != b:
                    parent[max(a, b)] = min(a, b)
    members = {}
    for i in range(count):
        members.setdefault(find(i), []).append(seeds[i])
    result = []
    for number, key in enumerate(sorted(members), 1):
        rows = members[key]
        best = sorted(rows, key=lambda x: (-x['Score'], x['Sigma'], x['Span'], x['ID']))[0]
        result.append({'ID': f'J{number:06d}', 'SeedIDs': [x['ID'] for x in rows],
                       'Routes': sorted({x['Route'] for x in rows}), 'Representative': best,
                       'ScaleAlternatives': sorted({(x['Sigma'], x['Span']) for x in rows}),
                       'TroughAlternatives': [min(x['Trough'] for x in rows), max(x['Trough'] for x in rows)]})
    return result


def patch_bank(raw, block):
    n, h, w = raw.shape
    traces, centers, members = [], [], []
    for y in range(0, h, block):
        for x in range(0, w, block):
            yy, xx = np.mgrid[y:min(y + block, h), x:min(x + block, w)]
            indices = (yy * w + xx).ravel()
            traces.append(strict_mean(raw, indices))
            centers.append([float(yy.mean()), float(xx.mean())])
            members.append(indices)
    return {'Traces': np.asarray(traces), 'Centers': np.asarray(centers), 'Members': members,
            'Field': np.mean(raw, axis=(1, 2), dtype=np.float64)}


def comparisons(raw, cohort, bank):
    h, w = raw.shape[1:]
    mask = np.zeros(h * w, bool); mask[cohort] = True; mask = mask.reshape(h, w)
    distance = ndimage.distance_transform_edt(~mask)
    external = np.asarray([not np.any(mask.ravel()[indices]) for indices in bank['Members']])
    centers = np.rint(bank['Centers']).astype(int)
    d = distance[centers[:, 0], centers[:, 1]]
    selectors = {'near': external & (d >= 2) & (d <= 20),
                 'far': external & (d >= 38), 'field': external}
    values, metadata = {}, {}
    for role, selected in selectors.items():
        if np.any(selected):
            samples = bank['Traces'][selected]
            values[role] = np.where(np.all(np.isfinite(samples), axis=0), np.mean(samples, axis=0), np.nan)
        else:
            values[role] = np.full(len(raw), np.nan)
        metadata[role] = np.flatnonzero(selected).tolist()
    field = bank['Field']
    return values, metadata, field


def motion_evidence(raw, threshold):
    n, h, w = raw.shape
    shifts = np.zeros((n, 2), np.float32)
    strength = np.zeros(n, np.float32)
    window = np.outer(np.hanning(h), np.hanning(w))
    previous = None
    for i in range(n):
        frame = np.nan_to_num(raw[i]).astype(float)
        frame = (ndimage.gaussian_filter(frame, 1) - ndimage.gaussian_filter(frame, 4)) * window
        ft = np.fft.fft2(frame)
        if previous is not None:
            cross = ft * np.conj(previous)
            correlation_map = np.fft.fftshift(np.fft.ifft2(cross / np.maximum(np.abs(cross), 1e-9)).real)
            y, x = np.unravel_index(np.argmax(correlation_map), correlation_map.shape)
            shifts[i] = [y - h // 2, x - w // 2]
            strength[i] = correlation_map[y, x] / max(float(np.sqrt(np.mean(correlation_map**2))), 1e-9)
        previous = ft
    moving = (np.linalg.norm(shifts, axis=1) >= threshold) & (strength >= 8)
    return {'Shifts': shifts, 'Strength': strength, 'Frames': np.flatnonzero(moving) + 1}


def first_run(values, width):
    for i in range(max(0, len(values) - width + 1)):
        if np.all(values[i:i + width]):
            return i
    return None


def assess(raw, group_row, bank, motion, fs, settings):
    seed = group_row['Representative']
    cohort = seed['Mask']
    target = strict_mean(raw, cohort)
    n, h, w = raw.shape
    c, span = seed['Trough'], seed['Span']
    first, last = max(0, c - 2 * span), min(n - 1, c + 2 * span)
    phase_first, phase_last = max(0, c - span), min(n - 1, c + span)
    region, region_members, field = comparisons(raw, cohort, bank)
    flags = []
    result = {'ID': group_row['ID'], 'SeedIDs': group_row['SeedIDs'], 'Routes': group_row['Routes'],
        'RepresentativeSeedID': seed['ID'], 'Kind': seed['Kind'], 'SeedScore': seed['Score'],
        'SeedSpanFrames': span, 'SeedTroughFrame': c + 1,
        'ScaleAlternatives': group_row['ScaleAlternatives'],
        'TroughAlternatives': [x + 1 for x in group_row['TroughAlternatives']],
        'CoarseMask': cohort.tolist(), 'CoarseShape': [h, w],
        'DiagnosticBlocks': len(cohort), 'DiagnosticFieldFraction': len(cohort) / (h * w),
        'ObservationWindow': [first + 1, last + 1], 'ProposedInterval': [phase_first + 1, phase_last + 1],
        'ExternalPatches': region_members, 'Recognition': 'uncertain', 'Flags': flags,
        'MeasurementReady': False, 'BurdenReady': False, 'NativeAreaMeasured': False,
        'Coordinates': 'row-major coarse indices; one-based source frames',
        'CorrectedTraceUsedForDecision': False}
    if seed['Kind'] != 'cycle':
        result.update(Recognition='regional_or_persistent' if seed['Kind'] == 'end_censored' else 'uncertain',
            Return={'State': 'censored', 'Frame': None}, Phases=None, ModelScores=None)
        flags.append(seed['Kind'])
        return result
    window = np.arange(first, last + 1)
    phase = np.arange(phase_first, phase_last + 1)
    flank = (window < phase_first) | (window > phase_last)
    left_count = int(np.sum((window < phase_first) & np.isfinite(target[window])))
    right_count = int(np.sum((window > phase_last) & np.isfinite(target[window])))
    result['FlankCounts'] = [left_count, right_count]
    if min(left_count, right_count) < settings.minimum_flank_samples:
        flags.append('flank_context_incomplete')
    if not np.all(np.isfinite(target[phase])):
        flags.append('fixed_cohort_observations_missing')
    time = (window - c) / max(span, 1)
    fits = {}
    for role, values in region.items():
        fit = context_fit(target[window], values[window], time, flank)
        if fit is not None:
            fits[role] = fit
    if not fits:
        # An unobserved regional comparator is not replaced by a fabricated quiet trace.
        result.update(Return={'State': 'unresolved', 'Frame': None}, Phases=None, ModelScores=None)
        flags.append('regional_context_unavailable')
        return result
    role = min(fits, key=lambda k: (fits[k]['FlankMeanSquare'], k))
    fit = fits[role]
    prediction = fit['Prediction']
    result['RegionalModels'] = {key: {k: v for k, v in row.items() if k != 'Prediction'}
                                for key, row in fits.items()}
    result['SelectedRegionalModel'] = role
    offset = phase_first - first
    raw_phase = target[phase]
    deficit = prediction[offset:offset + len(phase)] - raw_phase
    search_lo = max(0, c - span // 2 - phase_first)
    search_hi = min(len(phase), c + span // 2 - phase_first + 1)
    safe = np.where(np.isfinite(deficit), deficit, -np.inf)
    peak = search_lo + int(np.argmax(safe[search_lo:search_hi]))
    cycle = monotone_cycle(deficit, peak)
    finite = np.isfinite(deficit) & np.isfinite(cycle)
    if finite.sum() < 6:
        result.update(Return={'State': 'unresolved', 'Frame': None}, Phases=None, ModelScores=None)
        flags.append('phase_observations_insufficient')
        return result
    flank_sigma = roughness(target[window][flank])
    outside = np.ones(n, bool); outside[phase_first:phase_last + 1] = False
    other_sigma = roughness(target[outside])
    sigma = other_sigma
    ratio = max(flank_sigma, other_sigma) / max(min(flank_sigma, other_sigma), 1e-6)
    if ratio > settings.maximum_roughness_ratio:
        flags.append('roughness_context_unstable')
    rss0 = float(np.sum(deficit[finite]**2))
    rss1 = float(np.sum((deficit[finite] - cycle[finite])**2))
    persistent = best_persistent(deficit)
    rss2 = max(0., rss0 - persistent['Gain'])
    levels = max(3, int(np.sum(np.abs(np.diff(cycle[np.isfinite(cycle)])) > sigma * .25)))
    complexity = settings.complexity_per_level * levels * np.log(max(3, int(finite.sum())))
    opportunities = raw.size * len(settings.temporal_seconds) * len(settings.spatial_sigmas) * 2
    effective_mask_units = max(1., len(cohort) / (2 * seed['Sigma'] + 1)**2)
    search_allowance = (settings.search_complexity_multiplier * np.log(max(3, opportunities)) +
                       settings.spatial_complexity_multiplier * effective_mask_units * np.log(max(3, h * w)))
    costs = {'RegionalOnly': rss0 / sigma**2,
             'RegionalPlusCycle': rss1 / sigma**2 + complexity + search_allowance,
             'RegionalPlusPersistent': rss2 / sigma**2 + 2 * np.log(max(3, int(finite.sum()))) + search_allowance}
    model_rms_ratio = np.sqrt(rss1 / max(1, int(finite.sum()))) / sigma
    if model_rms_ratio > settings.maximum_model_rms_ratio:
        flags.append('regional_model_inadequate')
    gain = costs['RegionalOnly'] - costs['RegionalPlusCycle']
    depth = float(np.nanmax(cycle))
    hold = settings.return_hold_samples
    before = target[max(first, phase_first - max(hold, span // 2)):phase_first]
    after = target[phase_last + 1:min(last + 1, phase_last + 1 + max(hold, span // 2))]
    finite_before, finite_after = before[np.isfinite(before)], after[np.isfinite(after)]
    low_frames = phase[np.isfinite(cycle) & (cycle >= depth * .8)]
    low_values = target[low_frames]
    raw_low = float(np.median(low_values[np.isfinite(low_values)])) if np.any(np.isfinite(low_values)) else None
    raw_before = float(np.median(finite_before)) if len(finite_before) else None
    raw_after = float(np.median(finite_after)) if len(finite_after) else None
    raw_drop = raw_before - raw_low if raw_before is not None and raw_low is not None else None
    raw_rise = raw_after - raw_low if raw_after is not None and raw_low is not None else None
    raw_cycle = min(raw_drop, raw_rise) if raw_drop is not None and raw_rise is not None else None
    relative = np.isfinite(cycle) & (cycle <= settings.return_remaining_fraction * depth + sigma)
    return_offset = first_run(relative[peak + 1:] & np.isfinite(raw_phase[peak + 1:]), hold)
    return_index = peak + 1 + return_offset if return_offset is not None else None
    observed_rise = raw_rise is not None and raw_rise >= settings.cycle_roughness_units * sigma
    restored_raw = (raw_before is not None and raw_after is not None and raw_after >= raw_before - 2 * sigma)
    if return_index is None:
        return_state = 'not_observed'
    elif observed_rise and restored_raw:
        return_state = 'observed_raw_return'
    elif observed_rise:
        return_state = 'raw_rise_relative_return'
    else:
        return_state = 'relative_only'
    onset_candidates = np.flatnonzero(np.isfinite(cycle[:peak + 1]) &
                                      (cycle[:peak + 1] <= .1 * depth + sigma))
    onset_index = int(onset_candidates[-1]) if len(onset_candidates) else 0
    if not len(onset_candidates):
        flags.append('decline_start_unresolved')
    onset_band = np.flatnonzero(np.isfinite(cycle[:peak + 1]) &
                                (np.abs(cycle[:peak + 1] - .1 * depth) <= sigma))
    return_band = np.flatnonzero(np.isfinite(cycle[peak:]) &
                                 (np.abs(cycle[peak:] - settings.return_remaining_fraction * depth) <= sigma)) + peak
    proposed_start = phase_first + onset_index + 1
    proposed_end = phase_first + return_index + 1 if return_index is not None else phase_last + 1
    result['ProposedInterval'] = [proposed_start, proposed_end]
    result['Phases'] = {'OnsetFrame': proposed_start, 'PeakDeficitFrame': phase_first + peak + 1,
        'LowFrames': [int(low_frames.min()) + 1, int(low_frames.max()) + 1] if len(low_frames) else None,
        'ReturnFrame': phase_first + return_index + 1 if return_index is not None else None,
        'OnsetRange': [phase_first + int(onset_band.min()) + 1, phase_first + int(onset_band.max()) + 1] if len(onset_band) else None,
        'ReturnRange': [phase_first + int(return_band.min()) + 1, phase_first + int(return_band.max()) + 1] if len(return_band) else None,
        'RangesAreConfidenceIntervals': False, 'CycleKnots': knots(cycle, phase_first + 1)}
    result['Return'] = {'State': return_state, 'Frame': result['Phases']['ReturnFrame'],
                        'ObservedRawRise': observed_rise, 'RestoredPrecedingRawLevel': restored_raw,
                        'MeasurementReferenceAccepted': False}
    result['Roughness'] = {'FlankShortLag': flank_sigma, 'OtherShortLag': other_sigma,
                            'DecisionScale': sigma, 'Ratio': ratio,
                            'Role': 'candidate-excluded short-lag allowance, not calibrated camera noise'}
    result['ModelScores'] = {'RSSRegionalOnly': rss0, 'RSSRegionalPlusCycle': rss1,
        'RSSRegionalPlusPersistent': rss2, 'Costs': costs, 'JointGain': gain,
        'CycleComplexity': complexity + search_allowance, 'ShapeComplexity': complexity,
        'SearchAllowance': search_allowance, 'SearchOpportunities': opportunities,
        'EffectiveMaskUnits': effective_mask_units, 'ModelRMSRatio': model_rms_ratio,
        'SearchAllowanceIsCalibratedFalsePositiveProbability': False,
        'Levels': levels, 'DiagnosticContrastInputUnits': depth,
        'Persistent': persistent}
    result['RawCycle'] = {'Before': raw_before, 'Low': raw_low, 'After': raw_after,
                          'DropInputUnits': raw_drop, 'RiseInputUnits': raw_rise,
                          'CycleContrastInputUnits': raw_cycle}
    field_phase = field[phase]
    field_before = field[max(first, phase_first - max(hold, span // 2)):phase_first]
    field_after = field[phase_last + 1:min(last + 1, phase_last + 1 + max(hold, span // 2))]
    field_low = field[low_frames]
    field_cycle = None
    if len(field_before) and len(field_after) and len(field_low):
        field_cycle = float(min(np.mean(field_before), np.mean(field_after)) - np.mean(field_low))
    field_corr = correlation(raw_phase, field_phase)
    shared = (field_corr is not None and field_corr >= settings.shared_field_correlation and
              raw_cycle is not None and raw_cycle > 0 and field_cycle is not None and
              field_cycle >= settings.shared_field_contrast_fraction * raw_cycle)
    result['SharedFieldEvidence'] = {'Correlation': field_corr, 'FieldCycleContrast': field_cycle,
                                   'ComparableToCohortCycle': shared}
    variant_depths = {}
    for key, alternative in fits.items():
        change = alternative['Prediction'][offset:offset + len(phase)] - raw_phase
        fitted = monotone_cycle(change, peak)
        variant_depths[key] = float(np.nanmax(fitted)) if np.any(np.isfinite(fitted)) else None
    result['RegionalDependence'] = {'CycleContrasts': variant_depths,
                                    'GeometricComparisonsAreVerifiedQuiet': False}
    finite_depths = [x for x in variant_depths.values() if x is not None]
    if finite_depths and max(finite_depths) - min(finite_depths) > max(depth * .5, 3 * sigma):
        flags.append('regional_comparison_dependent')
    motion_frames = np.asarray(motion['Frames'])
    moving = motion_frames[(motion_frames >= proposed_start - 2) & (motion_frames <= proposed_end + 2)]
    result['DisplacementLikeFrames'] = moving.tolist()
    if len(moving):
        flags.append('displacement_like_evidence')
    if group_row['TroughAlternatives'][1] - group_row['TroughAlternatives'][0] > max(span, 8):
        flags.append('scale_contact_or_multiple_cycle_identity')
    severe = any(x in flags for x in ['flank_context_incomplete', 'fixed_cohort_observations_missing',
                     'roughness_context_unstable', 'regional_comparison_dependent', 'displacement_like_evidence',
                     'regional_model_inadequate'])
    cycle_supported = (gain >= settings.minimum_joint_gain and
                       costs['RegionalPlusPersistent'] - costs['RegionalPlusCycle'] >= settings.minimum_joint_gain and
                       depth >= settings.cycle_roughness_units * sigma)
    if severe:
        result['Recognition'] = 'uncertain'
    elif shared:
        result['Recognition'] = 'regional_or_persistent'
    elif cycle_supported and observed_rise and return_index is not None:
        result['Recognition'] = 'local_cycle_candidate'
    elif costs['RegionalPlusPersistent'] < costs['RegionalPlusCycle'] and return_index is None:
        result['Recognition'] = 'regional_or_persistent'
    elif raw_cycle is not None and raw_cycle >= settings.cycle_roughness_units * sigma:
        # Retain raw-route support even when conditional regional subtraction removes it.
        result['Recognition'] = 'uncertain'
        flags.append('raw_cycle_retained_regional_explanation_unresolved')
    else:
        result['Recognition'] = 'unsupported'
    return result


def detect(raw, fs=1., settings=None, seeds=None, raw_only=False, progress=None):
    settings = settings or Settings()
    assert raw.ndim == 3 and len(raw) >= 12 and fs > 0
    domain = coverage(raw)
    seeds = generate(raw, fs, settings, progress) if seeds is None else seeds
    if raw_only:
        seeds = [s for s in seeds if s['Route'] == 'raw']
    groups = group(seeds, settings)
    bank = patch_bank(raw, settings.patch_blocks)
    motion = motion_evidence(raw, settings.motion_shift_blocks)
    results = []
    for i, item in enumerate(groups):
        results.append(assess(raw, item, bank, motion, fs, settings))
        if progress and (i % 50 == 0 or i == len(groups) - 1):
            progress({'Assessed': i + 1, 'Groups': len(groups)})
    return {'Schema': SCHEMA, 'Settings': settings.contract(), 'Coverage': domain,
            'SeedCount': len(seeds), 'CandidateCount': len(results), 'Candidates': results,
            'SeedGroups': {s: g['ID'] for g in groups for s in g['SeedIDs']},
            'MotionFrames': motion['Frames'].tolist(), 'RawOnly': raw_only,
            'MeasurementReady': False, 'BurdenReady': False}, seeds
