"""Experimental preceding-state and regional-context assessment on fixed cohorts."""
from dataclasses import dataclass

import numpy as np
from scipy import signal

from .separation import (SeparationSettings, Surroundings, lag_variation, rolling_median)
from .service import smooth_trace


SCHEMA = 'boi-video-context-revision-0.1'


@dataclass(frozen=True)
class ContextSettings(SeparationSettings):
    minimum_width_seconds: float = 5
    minimum_patch_support_fraction: float = .60
    nearby_regions_per_quadrant: int = 2
    nearby_distance_blocks: float = 38
    preceding_samples_seconds: float = 10
    onset_cost_noise_units: float = 2
    quiet_strength: float = 2
    model_correlation: float = .65


def increasing_prefix_cost(values):
    """Exact least-squares isotonic costs for every increasing prefix."""
    sums, sizes = [], []
    costs = np.empty(len(values))
    total = 0.
    for i, value in enumerate(values):
        sums.append(float(value))
        sizes.append(1)
        while len(sums) > 1 and sums[-2] / sizes[-2] > sums[-1] / sizes[-1]:
            a, b = sums[-2:]
            na, nb = sizes[-2:]
            total += a * a / na + b * b / nb - (a + b) ** 2 / (na + nb)
            sums[-2:] = [a + b]
            sizes[-2:] = [na + nb]
        costs[i] = max(0., total)
    return costs


def fit_preceding(raw, onset, fs, settings):
    """All fitting samples strictly precede the supplied onset."""
    short = settings.frames(settings.preceding_samples_seconds, fs)
    long = settings.frames(settings.reference_seconds, fs)
    fits = []
    for width in sorted(set((short, long))):
        left = max(0, onset - width)
        x = raw[left:onset]
        if len(x) < short or not np.isfinite(x).all():
            continue
        time = np.arange(len(x), dtype=float)
        time -= time.mean()
        design = np.column_stack((np.ones(len(x)), time))
        weights = np.ones(len(x))
        coefficients = np.linalg.lstsq(design, x, rcond=None)[0]
        for _ in range(2):
            residual = x - design @ coefficients
            scale = max(1e-5, float(1.4826 * np.median(np.abs(residual - np.median(residual)))))
            weights = np.minimum(1., 1.5 * scale / np.maximum(np.abs(residual), 1e-12))
            coefficients = np.linalg.lstsq(design * np.sqrt(weights[:, None]),
                                           x * np.sqrt(weights), rcond=None)[0]
        linear = x - design @ coefficients
        constant_level = float(np.median(x))
        constant = x - constant_level
        linear_loss = float(np.sum(weights * linear ** 2))
        constant_loss = float(np.sum(weights * constant ** 2))
        penalty = max(scale ** 2, 1e-10) * np.log(len(x))
        trend = constant_loss - linear_loss > penalty
        state = ('recovering' if coefficients[1] > 0 else 'changing') if trend else 'stable'
        fits.append({'Range': [left, onset], 'Samples': len(x), 'State': state,
                     'Center': float(left + (len(x) - 1) / 2),
                     'Intercept': float(coefficients[0]), 'SlopePerSample': float(coefficients[1]),
                     'ConstantLevel': constant_level, 'ResidualScale': scale,
                     'ConstantLoss': constant_loss, 'LinearLoss': linear_loss,
                     'TrendPenalty': float(penalty)})
    if not fits:
        return {'State': 'unavailable', 'ReferenceEligibility': 'unresolved', 'Fits': []}
    state = fits[0]['State']
    if state == 'stable' and len(fits) > 1 and fits[-1]['State'] == 'recovering':
        state = 'short_stable_after_recovery'
    eligibility = ('stable_observed_candidate' if state in ('stable', 'short_stable_after_recovery')
                   else 'unresolved')
    return {'State': state, 'ReferenceEligibility': eligibility, 'Fits': fits,
            'Range': fits[0]['Range']}


def raw_phases(raw, motion, hypothesis, fs, settings):
    n = len(raw)
    hold = settings.frames(settings.hold_seconds, fs)
    minimum = settings.frames(settings.minimum_context_seconds, fs)
    ref = settings.frames(settings.reference_seconds, fs)
    smooth_width = settings.frames(settings.smoothing_seconds, fs)
    lag = settings.frames(settings.noise_lag_seconds, fs)
    valid = np.isfinite(raw) & ~motion
    filtered = smooth_trace(np.where(valid, raw, np.nan), smooth_width)
    filtered[~valid] = np.nan
    left, right = hypothesis.band
    result = {'State': 'phase_unavailable', 'HoldSamples': hold, 'RecoveryStart': None,
              'Preceding': {'State': 'unavailable', 'ReferenceEligibility': 'unresolved', 'Fits': []}}
    if not np.isfinite(filtered[left:right]).any():
        return result
    trough = left + int(np.nanargmin(filtered[left:right]))
    lo = max(0, hypothesis.phase[0] - 2 * ref)
    hi = min(n, hypothesis.phase[1] + 2 * ref)
    holes = np.flatnonzero(~valid[lo:hi]) + lo
    previous_holes, later_holes = holes[holes < trough], holes[holes > trough]
    lo = int(previous_holes[-1] + 1) if len(previous_holes) else lo
    hi = int(later_holes[0]) if len(later_holes) else hi
    result.update(Trough=trough, ContiguousSpan=[lo, hi])
    if trough - lo < minimum + hold or hi - trough <= hold:
        return result
    noise = lag_variation(filtered[lo:hi], lag)
    if noise is None:
        return result
    # Follow the last observed preceding valley. A lower value on the current
    # falling limb is not evidence for a previous episode.
    pre_end = max(lo + 1, left - hold)
    previous_peaks, _ = signal.find_peaks(
        -filtered[lo:pre_end], prominence=settings.strength * noise,
        distance=settings.frames(settings.peak_distance_seconds, fs))
    earlier_low = lo + int(previous_peaks[-1]) if len(previous_peaks) else lo
    first_onset = max(earlier_low + minimum, hypothesis.phase[0] - ref)
    last_onset = trough - settings.frames(settings.minimum_width_seconds, fs)
    if first_onset > last_onset:
        return result
    values = filtered[earlier_low:trough + 1]
    ascending = increasing_prefix_cost(values)
    descending = increasing_prefix_cost(values[::-1])[::-1]
    trials = np.arange(first_onset, last_onset + 1)
    split = trials - earlier_low
    losses = ascending[split - 1] + descending[split]
    best = int(np.argmin(losses))
    onset = int(trials[best])
    tolerance = settings.onset_cost_noise_units * noise ** 2
    plausible = trials[losses <= losses[best] + tolerance]
    preceding_raw = np.where(valid, raw, np.nan)
    preceding = fit_preceding(preceding_raw, onset, fs, settings)
    if preceding['State'] == 'unavailable':
        return result
    turn_start = max(lo, onset - smooth_width)
    level = float(np.median(raw[turn_start:onset]))
    depth = level - float(filtered[trough])
    raw_tolerance = max(settings.strength * noise, settings.remaining_deficit_fraction * max(depth, 0))
    # A subsequent raw dip limits recovery to the current phase.
    peaks, _ = signal.find_peaks(-filtered[lo:hi], prominence=settings.strength * noise,
                                 distance=settings.frames(settings.peak_distance_seconds, fs))
    later = peaks + lo
    later = later[later >= right]
    next_trough = int(later[0]) if len(later) else None
    end = hi
    if next_trough is not None:
        shoulder = trough + int(np.nanargmax(filtered[trough:next_trough]))
        end = max(trough + 1, shoulder + 1)
    rolling = rolling_median(np.where(valid, raw, np.nan), hold)
    possible = np.arange(trough + 1, max(trough + 1, end - hold + 1))
    rise = rolling[possible] - filtered[trough] >= settings.strength * noise
    returns = rolling[possible] >= level - raw_tolerance
    found = possible[rise & returns]
    recovery = int(found[0]) if len(found) else None
    prior_state = 'prior_reference_unavailable'
    prior_recovery = None
    if earlier_low - lo >= minimum:
        before = rolling[lo:earlier_low - hold + 1]
        if len(before) and np.isfinite(before).any():
            prior_level = float(np.nanmax(before))
            prior_depth = prior_level - filtered[earlier_low]
            positions = np.arange(earlier_low + 1, max(earlier_low + 1, onset - hold + 1))
            enough_rise = rolling[positions] - filtered[earlier_low] >= settings.strength * noise
            reached = rolling[positions] >= prior_level - max(
                settings.strength * noise, settings.remaining_deficit_fraction * prior_depth)
            prior_found = positions[enough_rise & reached]
            if prior_depth >= settings.strength * noise:
                prior_recovery = int(prior_found[0]) if len(prior_found) else None
                prior_state = ('prior_return_observed' if prior_recovery is not None
                               else 'linked_or_uncertain_prior_return')
    result.update(Onset=onset, OnsetRange=[int(plausible[0]), int(plausible[-1]) + 1],
                  Reference=preceding['Range'], Preceding=preceding,
                  TurnRange=[turn_start, onset], TurnLevel=level,
                  RawAtTrough=float(filtered[trough]), RawDepth=float(depth), RawNoise=float(noise),
                  RawTolerance=float(raw_tolerance), RecoveryStart=recovery,
                  RawRiseObserved=bool(rise.any()), AbsoluteReturnObserved=bool(returns.any()),
                  RecoverySearchStop=int(end), NextTrough=next_trough, PriorTrough=int(earlier_low),
                  PriorComparison=prior_state, InterveningReturnStart=prior_recovery,
                  MonotoneRecoveryLoss=float(ascending[-1]), SplitLoss=float(losses[best]),
                  OnsetAlternatives=len(plausible))
    incoming = filtered[max(lo, trough - hold):trough]
    current_fall_observed = len(incoming) > 0 and float(np.median(incoming)) > filtered[trough]
    if depth < settings.strength * noise or not current_fall_observed:
        result['State'] = 'raw_decline_unsupported'
    elif recovery is None:
        result['State'] = ('raw_rise_absolute_return_unresolved' if rise.any()
                           else 'recovery_unresolved')
    else:
        result['State'] = 'raw_decline_and_return'
    return result


class QualifiedSurroundings(Surroundings):
    def __init__(self, raw, domain, confidence, support_fraction, settings):
        super().__init__(raw, domain, confidence, settings)
        self.coverage = {i: float(support_fraction.ravel()[v[0]].mean())
                         for i, v in self.patches.items()}

    def choose(self, blocks, settings):
        center = np.array([np.mean(blocks // self.width), np.mean(blocks % self.width)])
        eligible = ~np.isin(self.ids, self.patch_map[blocks])
        offset = self.centers - center
        quadrant = 2 * (offset[:, 0] >= 0) + (offset[:, 1] >= 0)
        distance = np.sum(offset ** 2, axis=1)
        chosen = []
        for q in range(4):
            options = np.flatnonzero(eligible & (quadrant == q))
            if not len(options):
                continue
            ranked = options[np.argsort(distance[options], kind='stable')]
            far = int(self.ids[ranked[-1]])
            chosen.append((far, q, 'peripheral_check'))
            near = [int(self.ids[k]) for k in ranked
                    if self.ids[k] != far and distance[k] <= settings.nearby_distance_blocks ** 2]
            supported = [i for i in near if self.coverage[i] >= settings.minimum_patch_support_fraction]
            chosen += [(i, q, 'nearby') for i in supported[:settings.nearby_regions_per_quadrant]]
            unsupported = [i for i in near if self.coverage[i] < settings.minimum_patch_support_fraction]
            if unsupported:
                chosen.append((unsupported[0], q, 'uncertain_support'))
        return chosen


def patch_role(trace, cycle, position, support, fs, settings):
    role = {'Position': position, 'SupportFraction': support, 'Role': 'uncertain',
            'FallNoiseUnits': None, 'RawRiseObserved': False}
    if position == 'peripheral_check':
        role['Role'] = 'peripheral_check'
    elif support < settings.minimum_patch_support_fraction:
        role['Role'] = 'uncertain_support'
    if 'Reference' not in cycle:
        return role
    a, b = cycle['Reference']
    trough, hold = cycle['Trough'], cycle['HoldSamples']
    end = cycle['RecoverySearchStop']
    observed = trace[a:end]
    if not np.isfinite(observed).all() or not trace[a:b].mean() > 0:
        role['Role'] = 'unavailable'
        return role
    filtered = smooth_trace(trace, settings.frames(settings.smoothing_seconds, fs))
    variation = lag_variation(filtered[a:end], settings.frames(settings.noise_lag_seconds, fs))
    if variation is None:
        role['Role'] = 'unavailable'
        return role
    baseline = float(np.mean(trace[a:b]))
    low = float(np.median(trace[max(b, trough - 2):min(len(trace), trough + 3)]))
    fall = baseline - low
    after = trace[trough + 1:end]
    rise = float(np.median(after[-hold:]) - low) if len(after) >= hold else 0.
    role.update(ReferenceMean=baseline, LowMean=low, Noise=variation,
                FallNoiseUnits=float(fall / variation), FallFraction=float(fall / baseline),
                RawRiseObserved=bool(rise >= settings.strength * variation))
    if role['Role'] in ('peripheral_check', 'uncertain_support'):
        return role
    if fall >= settings.strength * variation:
        role['Role'] = 'responding_regional'
    elif max(abs(fall), abs(rise)) <= settings.quiet_strength * variation:
        role['Role'] = 'quiet_supported'
    return role


def correlate(first, second):
    a, b = first - np.mean(first), second - np.mean(second)
    energy = np.linalg.norm(a) * np.linalg.norm(b)
    return float(a @ b / energy) if energy > 1e-12 else 0.


def context_model(raw, controls, roles, cycle, fs, settings, omit=None):
    n = len(raw)
    eligible = [i for i, r in enumerate(roles) if i != omit]
    responding = [i for i in eligible if roles[i]['Role'] == 'responding_regional']
    quiet = [i for i in eligible if roles[i]['Role'] == 'quiet_supported']
    level = cycle['TurnLevel']
    normed = {i: controls[i] / roles[i]['ReferenceMean'] - 1
              for i in responding + quiet}
    validation = {'TrainingRegions': [], 'ValidationRegions': [],
                  'SharedPatternSupported': False, 'Correlation': None}
    prediction = np.full(n, np.nan)
    if len(responding) >= 2:
        train, test = responding[::2], responding[1::2]
        training = np.median(np.stack([normed[i] for i in train]), axis=0)
        testing = np.median(np.stack([normed[i] for i in test]), axis=0)
        lo, hi = cycle['Reference'][0], cycle['RecoverySearchStop']
        correlation = correlate(training[lo:hi], testing[lo:hi])
        validation.update(TrainingRegions=train, ValidationRegions=test,
                          Correlation=correlation,
                          SharedPatternSupported=correlation >= settings.model_correlation)
        prediction = level * (1 + training)
    elif len(quiet) >= 2 and not responding:
        prediction = level * (1 + np.median(np.stack([normed[i] for i in quiet]), axis=0))
        validation['SharedPatternSupported'] = True
        validation['QuietRegions'] = quiet
    local = raw - prediction
    info = {'State': 'context_unresolved', 'RespondingRegions': responding,
            'QuietRegions': quiet, 'Validation': validation,
            'RelativeReturnObserved': False, 'LocalDepth': None}
    if not np.isfinite(prediction).any():
        return info, prediction, local
    turn = slice(*cycle['TurnRange'])
    t, end, hold = cycle['Trough'], cycle['RecoverySearchStop'], cycle['HoldSamples']
    reference = float(np.median(local[turn]))
    smooth = smooth_trace(local, settings.frames(settings.smoothing_seconds, fs))
    noise = lag_variation(smooth[cycle['Reference'][0]:end],
                          settings.frames(settings.noise_lag_seconds, fs))
    if noise is None:
        return info, prediction, local
    depth = reference - float(smooth[t])
    tolerance = max(settings.strength * noise, settings.remaining_deficit_fraction * max(depth, 0))
    rolling = rolling_median(local, hold)
    positions = np.arange(t + 1, max(t + 1, end - hold + 1))
    rel_return = bool(np.any(rolling[positions] >= reference - tolerance))
    info.update(LocalDepth=float(depth), LocalNoise=float(noise),
                LocalReference=reference, LocalTolerance=float(tolerance),
                RelativeReturnObserved=rel_return)
    if not validation['SharedPatternSupported']:
        return info, prediction, local
    extra = depth >= max(settings.strength * noise,
                         settings.minimum_local_fraction * max(0, cycle['RawDepth']))
    if extra and rel_return and cycle['RawRiseObserved']:
        info['State'] = 'local_with_regional_response' if responding else 'local_candidate'
        if cycle['PriorComparison'] == 'linked_or_uncertain_prior_return':
            info['State'] = 'linked_or_uncertain_local_dips'
    elif responding and not extra:
        info['State'] = 'regional_response'
    elif extra:
        info['State'] = 'relative_recovery_unresolved'
    return info, prediction, local


def assess_context(raw, bank, motion, hypothesis, fs, settings, details=False):
    x = raw[:, hypothesis.blocks].mean(axis=1, dtype=float)
    cycle = raw_phases(x, motion, hypothesis, fs, settings)
    result = {'Schema': SCHEMA, 'State': cycle['State'], 'RawCycle': cycle,
              'PrecedingState': cycle['Preceding']['State'],
              'ReferenceEligibility': cycle['Preceding']['ReferenceEligibility'],
              'RegionIDs': [], 'RegionRoles': [], 'RegionalComparison': None,
              'LeaveOneOut': [], 'ContextStable': False, 'MeasurementReady': False}
    roles, regions, controls = [], [], []
    prediction, local = np.full(len(x), np.nan), np.full(len(x), np.nan)
    if 'Reference' in cycle:
        for index, quadrant, position in bank.choose(hypothesis.blocks, settings):
            blocks, _, series = bank.patches[index]
            role = patch_role(series, cycle, position, bank.coverage[index], fs, settings)
            role.update(ID=index, Quadrant=quadrant)
            roles.append(role)
            regions.append({'ID': index, 'Blocks': blocks, 'Role': role['Role'],
                            'Position': position, 'Quadrant': quadrant})
            controls.append(series)
        result['RegionIDs'] = [r['ID'] for r in roles]
        result['RegionRoles'] = roles
        if cycle['State'] in ('raw_decline_and_return', 'raw_rise_absolute_return_unresolved'):
            comparison, prediction, local = context_model(x, controls, roles, cycle, fs, settings)
            result['RegionalComparison'] = comparison
            variants = []
            for i, role in enumerate(roles):
                if role['Role'] not in ('responding_regional', 'quiet_supported'):
                    continue
                variant, _, _ = context_model(x, controls, roles, cycle, fs, settings, omit=i)
                variants.append({'OmittedRegionID': role['ID'], 'State': variant['State']})
            result['LeaveOneOut'] = variants
            result['ContextStable'] = bool(variants) and all(v['State'] == comparison['State'] for v in variants)
            result['State'] = comparison['State'] if result['ContextStable'] else 'context_sensitive'
            result['AllRegionsState'] = comparison['State']
            if result['State'] in ('local_candidate', 'local_with_regional_response'):
                a, b = cycle['TurnRange']
                t, r, hold = cycle['Trough'], cycle['RecoveryStart'], cycle['HoldSamples']
                if r is None:
                    r = max(t + 1, cycle['RecoverySearchStop'] - hold)
                pre = np.median(raw[a:b, hypothesis.blocks], axis=0)
                post = np.median(raw[r:r + hold, hypothesis.blocks], axis=0)
                count = int(np.count_nonzero((pre > raw[t, hypothesis.blocks])
                                             & (post > raw[t, hypothesis.blocks])))
                result['BlocksWithObservedFallAndRise'] = count
                if count < max(settings.minimum_connected_blocks, (len(hypothesis.blocks) + 1) // 2):
                    result['State'] = 'spatial_coherence_unresolved'
    if details:
        result['Traces'] = {'Raw': x, 'RegionalPrediction': prediction,
                            'LocalResidual': local, 'Comparators': controls}
        result['Regions'] = regions
    return result
