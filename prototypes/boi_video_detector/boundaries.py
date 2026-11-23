"""Experimental episode boundaries on fixed raw and qualified local traces.

These assessments do not supply scientific baselines, areas or burden values.
"""
from dataclasses import dataclass

import numpy as np
from numpy.lib.stride_tricks import sliding_window_view

from .context_revision import ContextSettings, fit_preceding
from .service import smooth_trace

SCHEMA = 'boi-video-boundaries-0.1'


@dataclass(frozen=True)
class BoundarySettings:
    smoothing_seconds: float = 3
    minimum_preceding_seconds: float = 10
    minimum_decline_seconds: float = 5
    fit_return_seconds: float = 20
    onset_range_score: float = 2
    maximum_point_range_seconds: float = 4
    decline_strength: float = 4
    preceding_level_seconds: float = 3
    first_return_seconds: float = 5
    confirmation_seconds: float = 10
    minimum_returning_fraction: float = .8
    maximum_consecutive_low: int = 1
    maximum_remaining_deficit_fraction: float = .1
    relapse_variation_units: float = 2

    def frames(self, seconds, fs):
        return max(1, int(round(seconds * fs)))


def empirical_variation(values):
    differences = np.diff(values, n=2)
    differences = differences[np.isfinite(differences)]
    if not len(differences):
        return None
    return max(1e-6, float(1.4826 * np.median(np.abs(differences - np.median(differences))) / np.sqrt(6)))


def segmented_candidates(values, lo, trough, stop, trials, noise):
    """Continuous preceding / decline / return fits; stable and sloped pre-state."""
    time = np.arange(lo, stop, dtype=float) - trough
    targets = values[lo:stop]
    u = time[None, :] - (trials - trough)[:, None]
    before = np.minimum(u, 0)
    fall = np.minimum(np.maximum(u, 0), (trough - trials)[:, None])
    after = np.broadcast_to(np.maximum(time, 0), u.shape)
    ones = np.ones_like(u)
    models = []
    for kind, columns in (('stable', (ones, fall, after)),
                          ('sloped', (ones, before, fall, after))):
        design = np.stack(columns, axis=2)
        normal = np.einsum('tni,tnj->tij', design, design)
        rhs = np.einsum('tni,n->ti', design, targets)
        coefficients = np.linalg.solve(normal, rhs[..., None])[..., 0]
        predicted = np.einsum('tni,ti->tn', design, coefficients)
        loss = np.sum((targets - predicted) ** 2, axis=1)
        pre = np.zeros(len(trials)) if kind == 'stable' else coefficients[:, 1]
        decline = coefficients[:, -2]
        returning = coefficients[:, -1]
        valid = (decline < 0) & (decline < pre)
        score = loss + (design.shape[2] + 1) * noise ** 2 * np.log(len(targets))
        score[~valid] = np.inf
        models.append({'Kind': kind, 'Loss': loss, 'Score': score,
                       'Coefficients': coefficients, 'PreSlope': pre,
                       'DeclineSlope': decline, 'ReturnSlope': returning})
    null = []
    for design in (np.ones((len(time), 1)), np.column_stack((np.ones(len(time)), time))):
        beta = np.linalg.lstsq(design, targets, rcond=None)[0]
        null.append(float(np.sum((targets - design @ beta) ** 2)
                          + design.shape[1] * noise ** 2 * np.log(len(time))))
    return models, min(null)


def assess_onset(raw, motion, old_cycle, fs, settings, details=False):
    result = {'State': 'phase_unavailable', 'Onset': None, 'BestFitOnset': None,
              'OnsetRange': None, 'PrecedingState': 'unavailable'}
    if 'Trough' not in old_cycle or 'ContiguousSpan' not in old_cycle:
        return result
    trough = int(old_cycle['Trough'])
    lo, end = map(int, old_cycle['ContiguousSpan'])
    end = min(end, old_cycle.get('RecoverySearchStop', end), len(raw))
    bad = ~np.isfinite(raw) | np.asarray(motion, bool)
    previous = np.flatnonzero(bad[lo:trough + 1]) + lo
    if len(previous):
        lo = int(previous[-1] + 1)
    later = np.flatnonzero(bad[trough + 1:end]) + trough + 1
    if len(later):
        end = int(later[0])
    prior = max(lo, int(old_cycle.get('PriorTrough', lo)))
    minimum = settings.frames(settings.minimum_preceding_seconds, fs)
    width = settings.frames(settings.minimum_decline_seconds, fs)
    fit_stop = min(end, trough + 1 + settings.frames(settings.fit_return_seconds, fs))
    if prior + minimum > trough - width or fit_stop - trough < 3:
        return result
    noise = empirical_variation(raw[prior:fit_stop])
    if noise is None:
        return result
    filtered = smooth_trace(raw, settings.frames(settings.smoothing_seconds, fs))
    trials = np.arange(prior + minimum, trough - width + 1)
    models, null_score = segmented_candidates(filtered, prior, trough, fit_stop, trials, noise)
    scores = np.stack([m['Score'] for m in models])
    result.update(Trough=trough, SearchSpan=[prior, end], FitSpan=[prior, fit_stop],
                  Noise=noise, NullScore=null_score)
    if not np.isfinite(scores).any():
        result['State'] = 'no_new_decline'
        return result
    which, position = np.unravel_index(np.argmin(scores), scores.shape)
    best = models[which]
    onset = int(trials[position])
    level_count = settings.frames(settings.preceding_level_seconds, fs)
    turn = [max(prior, onset - level_count), onset]
    level = float(np.median(raw[slice(*turn)]))
    drop = level - float(filtered[trough])
    score = float(scores[which, position])
    if drop < settings.decline_strength * noise or score >= null_score:
        result.update(State='no_new_decline', BestFitScore=score, RawDrop=drop)
        return result
    threshold = settings.onset_range_score * noise ** 2 * np.log(fit_stop - prior)
    comparable = trials[np.min(scores, axis=0) <= score + threshold]
    preceding = fit_preceding(raw, onset, fs, ContextSettings())
    near = settings.frames(settings.minimum_decline_seconds, fs)
    adjoining = float(np.median(raw[onset:min(trough + 1, onset + near)])) < level
    identified = comparable[-1] - comparable[0] <= settings.frames(settings.maximum_point_range_seconds, fs)
    result.update(State='onset_supported' if identified and adjoining else 'onset_range_only',
                  Onset=onset if identified and adjoining else None, BestFitOnset=onset,
                  OnsetRange=[int(comparable[0]), int(comparable[-1]) + 1],
                  OnsetAlternatives=comparable.tolist(), BestFitScore=score,
                  Model=best['Kind'], Coefficients=best['Coefficients'][position],
                  PreSlope=float(best['PreSlope'][position]),
                  DeclineSlope=float(best['DeclineSlope'][position]),
                  ReturnSlope=float(best['ReturnSlope'][position]),
                  AdjoiningFallObserved=adjoining, TurnRange=turn, TurnLevel=level,
                  RawAtTrough=float(filtered[trough]), RawDrop=drop,
                  Preceding=preceding, PrecedingState=preceding['State'])
    if details:
        result['TrialScores'] = {'Trials': trials, 'Models': models}
    return result


def assess_return(values, motion, onset, fs, settings):
    result = {'State': 'recovery_unresolved', 'FirstReturnStart': None,
              'SustainedReturnStart': None, 'StableRecoveredStateEvidence': False}
    if 'TurnRange' not in onset:
        result['State'] = 'phase_unavailable'
        return result
    t, end = onset['Trough'], onset['SearchSpan'][1]
    level = float(np.median(values[slice(*onset['TurnRange'])]))
    filtered = smooth_trace(values, settings.frames(settings.smoothing_seconds, fs))
    drop = level - float(filtered[t])
    noise = empirical_variation(values[slice(*onset['FitSpan'])])
    if not np.isfinite(level) or noise is None or drop <= 0:
        result['State'] = 'phase_unavailable'
        return result
    valid = np.isfinite(values) & ~np.asarray(motion, bool)
    bad = np.flatnonzero(~valid[t + 1:end]) + t + 1
    censored_by_gap = bool(len(bad))
    if len(bad):
        end = int(bad[0])
    threshold = level - settings.maximum_remaining_deficit_fraction * drop
    first_width = settings.frames(settings.first_return_seconds, fs)
    width = settings.frames(settings.confirmation_seconds, fs)
    result.update(TurnLevel=level, Drop=drop, Noise=noise, RequiredLevel=float(threshold),
                  MaximumRemainingDeficitFraction=settings.maximum_remaining_deficit_fraction,
                  SearchSpan=[t + 1, end], ConfirmationSamples=width,
                  PostContextEndsAtGap=censored_by_gap,
                  VariationExceedsClosureBand=bool(noise > settings.maximum_remaining_deficit_fraction * drop))
    if end - t - 1 >= first_width:
        initial = sliding_window_view(values[t + 1:end], first_width)
        matched = np.flatnonzero(np.median(initial, axis=1) >= threshold)
        if len(matched):
            result['FirstReturnStart'] = int(t + 1 + matched[0])
    if end - t - 1 < width:
        result['State'] = 'first_return_unconfirmed' if result['FirstReturnStart'] is not None else 'post_context_incomplete'
        return result
    windows = sliding_window_view(values[t + 1:end], width)
    above = windows >= threshold
    count = np.sum(above, axis=1)
    half = width // 2
    halves = (np.median(windows[:, :half], axis=1) >= threshold) & (np.median(windows[:, half:], axis=1) >= threshold)
    longest = np.zeros(len(windows), int)
    run = np.zeros(len(windows), int)
    for column in range(width):
        run = np.where(above[:, column], 0, run + 1)
        longest = np.maximum(longest, run)
    relapse_width = min(3, half)
    relapse = np.median(windows[:, -relapse_width:], axis=1) < (
        np.median(windows[:, :relapse_width], axis=1) - settings.relapse_variation_units * noise)
    enough = count >= int(np.ceil(settings.minimum_returning_fraction * width))
    qualifies = enough & halves & (longest <= settings.maximum_consecutive_low) & ~relapse
    positions = np.flatnonzero(qualifies)
    result.update(WindowsExamined=len(windows), FirstReturnWindowConfirmed=bool(
        result['FirstReturnStart'] is not None and qualifies[result['FirstReturnStart'] - t - 1]
        if result['FirstReturnStart'] is not None and result['FirstReturnStart'] - t - 1 < len(qualifies) else False))
    if len(positions):
        index = int(positions[0])
        left = t + 1 + index
        w = windows[index]
        slope = float(np.polyfit(np.arange(width), w, 1)[0])
        stable = abs(slope) * (width - 1) <= settings.relapse_variation_units * noise
        result.update(State='sustained_return_observed', SustainedReturnStart=left,
                      ConfirmationRange=[left, left + width], SamplesAboveRequired=int(count[index]),
                      LongestLowRun=int(longest[index]), MedianRemainingDeficitFraction=float((level - np.median(w)) / drop),
                      PostSlope=slope, ReturningState='stable' if stable else 'rising' if slope > 0 else 'changing',
                      StableRecoveredStateEvidence=bool(stable and onset['PrecedingState'] == 'stable'))
    elif result['FirstReturnStart'] is not None:
        result['State'] = 'first_return_unconfirmed'
    elif censored_by_gap:
        result['State'] = 'post_context_incomplete'
    return result


def assess_boundaries(raw, motion, old_cycle, fs, settings, local=None, details=False):
    onset = assess_onset(raw, motion, old_cycle, fs, settings, details)
    returning = assess_return(raw, motion, onset, fs, settings)
    relative = (assess_return(local, motion, onset, fs, settings) if local is not None
                else {'State': 'qualified_local_comparison_unavailable', 'SustainedReturnStart': None})
    return {'Schema': SCHEMA, 'Onset': onset, 'RawReturn': returning, 'LocalReturn': relative,
            'MeasurementReady': False, 'ScientificBurdenAvailable': False,
            'ScientificReferenceAccepted': False}
