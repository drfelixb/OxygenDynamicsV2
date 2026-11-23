"""Seed-connected local phase evidence, independent of measurement references.

Public frames are one-based and inclusive. Diagnostic contexts are explicit
observations; they are neither normoxic truth nor accepted amplitude references.
"""
from dataclasses import dataclass
import numpy as np
from scipy.signal import find_peaks
from boi_episode_identity.numeric import Settings as PreviousSettings
from boi_episode_assembly.numeric import runs, reference
from boi_joint_video_detector.numeric import roughness, temporal_mean, robust_scale


@dataclass(frozen=True)
class Settings(PreviousSettings):
    maximum_rounds: int = 1
    phase_prominence_multiplier: float = 6.
    maximum_channels: int = 4
    maximum_hypotheses_per_channel: int = 2


def empty(anchor, reason):
    return {'Anchor': int(anchor) + 1, 'Start': None, 'End': None,
        'ProvisionalEnd': None, 'ConfirmationThrough': None,
        'FirstSupportedDeficit': None, 'LastSupportedDeficit': None,
        'AnchorConnected': False, 'State': 'unresolved', 'Minima': [],
        'ShortReturns': [], 'Flags': [reason], 'ObservationMissing': False,
        'DetectionContext': None, 'Level': None, 'LowerBand': None,
        'Allowance': None, 'LowValue': None, 'RawDrop': None, 'RawRise': None,
        'LocalRebound': None, 'AbsoluteReturn': None,
        'Reference': None, 'DiagnosticReferences': [], 'ReferenceLength': None,
        'OnsetBracket': None, 'RecoveryBracket': None,
        'MeasurementReferenceUsed': False}


def observed_context(x, stop, noise, settings):
    """A fixed context before a crest, never selected by measurement audit."""
    stop = int(stop); first = max(0, stop - settings.prestate_samples)
    data = np.asarray(x[first:stop], float)
    if len(data) < settings.continuation_samples or not np.all(np.isfinite(data)):
        return None
    half = len(data) // 2
    left, right = float(np.median(data[:half])), float(np.median(data[half:]))
    return {'First': first + 1, 'Last': stop, 'Length': len(data),
        'Median': float(np.median(data)), 'Allowance': float(noise),
        'HalfMedians': [left, right],
        'Stable': abs(right - left) <= settings.allowance_multiplier * noise,
        'Source': 'observed_before_local_crest', 'ScientificReferenceAccepted': False}


def diagnostic_scale(values, settings=None):
    """Include correlated local variation; short differences alone understate it."""
    s = settings or Settings(); x = np.asarray(values, float)
    residual = x - np.asarray(temporal_mean(x, s.prestate_samples), float)
    finite = residual[np.isfinite(residual)]
    return max(roughness(x), float(robust_scale(finite) or 0.))


def phase_hypotheses(values, anchor, span, settings=None, kind='cycle'):
    """Extract local turning-point basins, then retain at most two alternatives.

    Both sides of a dip determine its diagnostic context. No reference audit
    feeds back into this function and no remote maximum is an onset fallback.
    A larger fully returned stable basin contains its unrecovered sub-minima.
    Other nested interpretations remain explicit instead of overwriting it.
    """
    s = settings or Settings(); x = np.asarray(values, float); n = len(x)
    c = int(np.clip(anchor, 0, n - 1)); noise = diagnostic_scale(x, s)
    missing = ~np.isfinite(x)
    if missing[c] or np.sum(~missing) < s.continuation_samples * 2:
        return {'Primary': empty(c, 'anchor_observations_missing'),
            'Alternatives': [], 'ObservedInterpretations': 0, 'Overflow': False}
    y = np.asarray(temporal_mean(x, s.smoothing_samples), float)
    finite = np.flatnonzero(np.isfinite(y))
    if len(finite) < 2:
        return {'Primary': empty(c, 'insufficient_observed_transitions'),
            'Alternatives': [], 'ObservedInterpretations': 0, 'Overflow': False}
    # Interpolation only locates turning points. Raw missing observations are
    # retained and prohibit confirmed recovery; they never become filled area.
    curve = np.interp(np.arange(n), finite, y[finite])
    curve[0], curve[-1] = x[np.flatnonzero(~missing)[0]], x[np.flatnonzero(~missing)[-1]]
    prominence = s.phase_prominence_multiplier * noise
    minima, props = find_peaks(-curve, prominence=prominence,
                               distance=s.continuation_samples)
    crests, _ = find_peaks(curve, prominence=prominence,
                           distance=s.continuation_samples)
    # A flat shoulder before a decline need not be a mathematical maximum:
    # an older, higher state can precede it. Include observed stable-to-decline
    # transitions so that the old high state cannot monopolise its onset.
    width = s.short_prestate_samples
    shoulder_mask = np.zeros(n, bool)
    if n > width + s.continuation_samples:
        rolling = np.convolve(curve, np.ones(width // 2) / (width // 2), mode='valid')
        for t in np.flatnonzero(curve[:-s.continuation_samples] - curve[s.continuation_samples:] > s.allowance_multiplier * noise):
            if t >= width and abs(rolling[t - width + 1] - rolling[t - width // 2 + 1]) <= s.allowance_multiplier * noise:
                shoulder_mask[t] = True
    shoulders = [a for a, b in runs(shoulder_mask)]
    crests = np.unique(np.r_[0, crests, shoulders, n - 1]).astype(int)
    descriptors = []
    for j, trough in enumerate(minima):
        prior = crests[(crests < trough) & (curve[crests] - curve[trough] >= prominence)]
        after = crests[(crests > trough) & (curve[crests] - curve[trough] >= prominence)]
        left = int(prior[-1]) if len(prior) else int(props['left_bases'][j])
        right = int(after[0]) if len(after) else int(props['right_bases'][j])
        pairs = [(left, right, 'local_turning_points'),
                 (int(props['left_bases'][j]), int(props['right_bases'][j]), 'continuing_parent_basin')]
        for lo, hi, origin in pairs:
            if not lo <= c <= hi or not lo < trough < hi:
                continue
            crest_context = observed_context(x, lo + 1, noise, s)
            level = crest_context['Median'] if crest_context and crest_context['Stable'] else float(curve[lo])
            lower = level - s.allowance_multiplier * noise
            deficits = runs(np.isfinite(x[lo:hi + 1]) & (x[lo:hi + 1] < lower), s.continuation_samples)
            if not deficits:
                continue
            components = []; active = []
            for a, b in deficits:
                if active and runs(np.isfinite(x[lo + active[-1][1]:lo + a]) &
                        (x[lo + active[-1][1]:lo + a] >= lower), s.recovery_samples):
                    components.append(active); active = []
                active.append((a, b))
            if active: components.append(active)
            matching = [g for g in components if lo + g[0][0] - s.continuation_samples <= c <= lo + g[-1][1] - 1 + s.continuation_samples
                and lo + g[0][0] <= trough < lo + g[-1][1]]
            if len(matching) != 1:
                continue
            deficits = matching[0]
            first = lo + deficits[0][0]; last = lo + deficits[-1][1] - 1
            onset = max(lo, first - 1)
            if onset > c:
                continue
            # End is local, not a search through a later unrelated recording.
            returned = runs(np.isfinite(x[last + 1:min(n, hi + s.recovery_samples)]) &
                (x[last + 1:min(n, hi + s.recovery_samples)] >= lower), s.recovery_samples)
            end = int(last + 1 + returned[0][0]) if returned else None
            if c >= (end if end is not None else hi):
                continue
            context = observed_context(x, onset, noise, s)
            complete = end is not None and context is not None and context['Stable']
            descriptors.append({'Lo': lo, 'Hi': hi, 'Trough': int(trough),
                'Onset': onset, 'First': first, 'Last': last, 'End': end,
                'Level': level, 'Lower': lower, 'Context': context,
                'Complete': complete, 'Origin': origin,
                'Prominence': float(props['prominences'][j])})
    # An open tail/head has no two-sided peak. Its missing side stays open.
    if not descriptors:
        before = crests[crests < c]
        if len(before):
            lo = int(before[-1]); level = float(curve[lo]); lower = level - s.allowance_multiplier * noise
            tail = runs(np.isfinite(x[lo:]) & (x[lo:] < lower), s.continuation_samples)
            if tail and level - curve[c] >= prominence:
                a, b = next(((a, b) for a, b in tail if lo + a <= c < lo + b), (None, None))
                if a is not None:
                    first, last = lo + a, lo + b - 1
                    later = runs(np.isfinite(x[last + 1:]) & (x[last + 1:] >= lower), s.recovery_samples)
                    end = last + 1 + later[0][0] if later else None
                    onset = max(lo, first - 1)
                    descriptors.append({'Lo': lo, 'Hi': n - 1, 'Trough': int(lo + np.nanargmin(x[lo:])),
                        'Onset': onset, 'First': first, 'Last': last, 'End': end,
                        'Level': level, 'Lower': lower, 'Context': observed_context(x, onset, noise, s),
                        'Complete': False, 'Origin': 'open_tail', 'Prominence': level - float(np.nanmin(x[lo:]))})
        if kind == 'start_censored' and not descriptors:
            later = float(np.nanmax(curve[c:])); lower = later - s.allowance_multiplier * noise
            if later - curve[c] >= prominence:
                returns = runs(np.isfinite(x[c:]) & (x[c:] >= lower), s.recovery_samples)
                end = c + returns[0][0] if returns else None
                descriptors.append({'Lo': 0, 'Hi': end if end is not None else n - 1,
                    'Trough': int(np.nanargmin(x[:c + 1])), 'Onset': None,
                    'First': 0, 'Last': end - 1 if end else n - 1, 'End': None,
                    'Level': later, 'Lower': lower, 'Context': None, 'Complete': False,
                    'Origin': 'open_head', 'Prominence': later - float(curve[c]), 'Rebound': end})
    if not descriptors:
        return {'Primary': empty(c, 'no_seed_connected_local_depression'),
            'Alternatives': [], 'ObservedInterpretations': 0, 'Overflow': False}
    # Stable fully returned parents subsume partial sub-minima, not independently
    # recovered cycles. This selection uses local observations, not audit windows.
    complete = [d for d in descriptors if d['Complete']]
    if complete:
        dominant = max(complete, key=lambda d: (d['Prominence'], d['Hi'] - d['Lo']))
        descriptors = [d for d in descriptors if not (
            not d['Complete'] and dominant['Lo'] <= d['Lo'] and d['Hi'] <= dominant['Hi'])]
        descriptors.sort(key=lambda d: (not d['Complete'], -d['Prominence'], d['Hi'] - d['Lo']))
    else:
        descriptors.sort(key=lambda d: (abs(d['Trough'] - c), d['Hi'] - d['Lo'], -d['Prominence']))
    distinct = []
    seen = set()
    for d in descriptors:
        key = (d['Onset'], d['End'], d['Hi'] if d['End'] is None else None)
        if key not in seen:
            distinct.append(d); seen.add(key)
    retained = distinct[:s.maximum_hypotheses_per_channel]
    result = []
    for d in retained:
        onset, end = d['Onset'], d['End']; stop = end if end is not None else (d.get('Rebound') or d['Hi'])
        lo = onset if onset is not None else 0; hi = int(stop)
        data = x[d['First']:d['Last'] + 1]; valid = data[np.isfinite(data)]
        low = float(np.min(valid)) if len(valid) else None
        short_stop = min(n, hi + s.recovery_samples)
        short = []
        for a, b in runs(np.isfinite(x[lo:short_stop]) & (x[lo:short_stop] >= d['Lower'])):
            following = x[lo + b:min(n, lo + b + s.continuation_samples)]
            if (b - a < s.recovery_samples and a > 0 and b < short_stop - lo and
                len(following) == s.continuation_samples and np.all(np.isfinite(following)) and
                d['Level'] - float(np.min(following)) >= prominence):
                short.append([lo + a + 1, lo + b])
        flags = []
        observations_missing = bool(np.any(missing[lo:min(n, hi + s.recovery_samples)]))
        if observations_missing: flags.append('fixed_cohort_observations_missing')
        if d['Context'] is None: flags.append('diagnostic_detection_context_unavailable')
        elif not d['Context']['Stable']: flags.append('diagnostic_detection_context_changing')
        if short: flags.append('short_recovery_split_merge_ambiguous')
        if end is None: flags.append('absolute_local_return_unresolved')
        if d['Origin'] == 'open_tail': flags.append('recording_end_unrecovered')
        if d['Origin'] == 'open_head': flags.append('recording_start_censored')
        observed = end is not None and d['Context'] is not None and d['Context']['Stable'] and not observations_missing
        p = empty(c, '');p.update(Start=onset + 1 if onset is not None else None,
            End=end + 1 if observed else None, AbsoluteReturn=end + 1 if observed else None,
            ProvisionalEnd=hi + 1 if d['Origin'] != 'open_tail' else (end + 1 if end is not None else None),
            ConfirmationThrough=end + s.recovery_samples if observed else None,
            FirstSupportedDeficit=d['First'] + 1, LastSupportedDeficit=d['Last'] + 1,
            AnchorConnected=True, State='observed_recovery' if observed else 'unresolved',
            Minima=[int(v) + 1 for v in minima if lo <= v <= hi] or [d['Trough'] + 1],
            ShortReturns=short, Flags=flags, ObservationMissing=observations_missing,
            DetectionContext=d['Context'], Level=d['Level'], LowerBand=d['Lower'],
            Allowance=float(noise), LowValue=low, RawDrop=d['Level'] - low if low is not None else None,
            RawRise=float(np.median(x[end:end + s.recovery_samples]) - low) if observed and low is not None else None,
            LocalRebound=hi + 1 if d['Origin'] != 'open_tail' else None,
            OnsetBracket=[d['Lo'] + 1, d['First'] + 1] if onset is not None else None,
            RecoveryBracket=[d['Last'] + 1, hi + 1] if d['Origin'] != 'open_tail' else None,
            Origin=d['Origin'], Prominence=d['Prominence'],
            TurningPointFrames=[d['Lo'] + 1, d['Trough'] + 1, d['Hi'] + 1])
        result.append(p)
    overflow = len(distinct) > s.maximum_hypotheses_per_channel
    return {'Primary': result[0], 'Alternatives': result[1:],
        'ObservedInterpretations': len(distinct), 'Overflow': overflow}


def audit_references(values, hypotheses, settings=None, mode='both'):
    """Pure downstream audit: input hypotheses are never mutated."""
    s = settings or Settings(); x = np.asarray(values, float); records = []
    assert mode in {'both', '20_only', '10_only', 'withheld'}
    for hypothesis_id, p in hypotheses:
        windows = []
        for length in [s.prestate_samples, s.short_prestate_samples]:
            included = mode == 'both' or mode == f'{length}_only'
            onset = p.get('Start'); r = None; reasons = []
            if included and onset is not None and onset - 1 >= length:
                r = reference(x, onset - 1 - length, s.__class__(**{**s.contract(), 'prestate_samples': length}))
            if not included: reasons.append('audit_variant_withheld')
            elif r is None: reasons.append('insufficient_or_missing_predecline_observations')
            else:
                if not r['Stable']: reasons.append('predecline_state_changing')
                if not r['Clean']: reasons.append('predecline_window_contains_deficit')
                before = x[max(0, onset - 1 - s.continuation_samples):onset - 1]
                immediate = float(np.median(before)) if len(before) and np.all(np.isfinite(before)) else None
                if immediate is None or abs(immediate - r['Median']) > s.allowance_multiplier * r['Allowance']:
                    reasons.append('immediate_predecline_level_mismatch')
            windows.append({'Length': length, 'Reference': r, 'Usable': r is not None and not reasons,
                'Reasons': reasons, 'ScientificReferenceAccepted': False,
                'ShortContextConditional': length == s.short_prestate_samples})
        records.append({'HypothesisID': hypothesis_id, 'Windows': windows,
            'ScientificReferenceAccepted': False, 'InfluencesDetection': False})
    return {'Schema': 'boi-measurement-reference-audit-1', 'Mode': mode,
        'Hypotheses': records, 'MeasurementReady': False, 'BurdenReady': False}
