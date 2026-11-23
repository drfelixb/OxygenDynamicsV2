"""Anchored observed excursions and event-local diagnostic references.

Arrays are source samples; internal positions are zero-based, public frames
one-based. No nearest-unrelated-cycle fallback or scientific measurement IO.
"""
from dataclasses import dataclass, asdict, replace
import numpy as np
from scipy.signal import find_peaks
from boi_episode_assembly.numeric import reference, runs
from boi_joint_video_detector.numeric import roughness, temporal_mean


@dataclass(frozen=True)
class Settings:
    prestate_samples: int = 20
    short_prestate_samples: int = 10
    continuation_samples: int = 3
    recovery_samples: int = 10
    allowance_multiplier: float = 2.
    numerical_floor: float = 1e-6
    relative_floor_fraction: float = 1e-7
    smoothing_samples: int = 3
    initial_context_multiplier: int = 2
    maximum_rounds: int = 2
    gap_blocks: int = 1
    compatible_correlation: float = .8
    shared_contrast_fraction: float = .8
    shared_correlation: float = .95
    minimum_spatial_blocks: int = 3
    minimum_coherent_fraction: float = .6
    boundary_gradient_ratio: float = 3.
    boundary_level_fraction: float = .5
    observed_boundary_margin_blocks: int = 1
    index_tile_blocks: int = 8
    index_time_samples: int = 64

    def contract(self):
        return asdict(self)


def empty(anchor, reason):
    return {'Anchor': anchor + 1, 'Start': None, 'End': None,
            'ConfirmationThrough': None, 'FirstSupportedDeficit': None,
            'LastSupportedDeficit': None, 'AnchorConnected': False,
            'State': 'unresolved', 'Minima': [], 'ShortReturns': [],
            'Reference': None, 'DiagnosticReferences': [], 'Flags': [reason],
            'LowerBand': None, 'Level': None, 'RawDrop': None, 'RawRise': None,
            'ObservationMissing': reason == 'anchor_observations_missing'}


def excursion(values, anchor, level, allowance, settings):
    """Only select the supported episode containing the originating anchor.

The crest/return interval can contain the anchor before a sustained deficit;
no qualifying earlier/later episode is substituted if this interval is absent.
"""
    s = settings; x = np.asarray(values, float); n = len(x)
    if not np.isfinite(x[anchor]) or level is None or not np.isfinite(level):
        return empty(anchor, 'anchor_observations_missing')
    lower = level - s.allowance_multiplier * allowance
    below = np.isfinite(x) & (x < lower)
    deficits = runs(below, s.continuation_samples)
    if not deficits:
        return empty(anchor, 'no_anchored_sustained_deficit')
    groups = []; active = []
    for a, b in deficits:
        if active and runs(np.isfinite(x[active[-1][1]:a]) &
                           (x[active[-1][1]:a] >= lower), s.recovery_samples):
            groups.append(active); active = []
        active.append((a, b))
    if active:
        groups.append(active)
    smooth = temporal_mean(x, s.smoothing_samples)
    selected = []
    for group in groups:
        first, last = group[0][0], group[-1][1]
        prior = [(a, b) for a, b in runs(np.isfinite(x[:first]) &
                   (x[:first] >= lower), s.recovery_samples)]
        onset = None
        if prior:
            previous = prior[-1][0]
            crest = x[previous:first + 1]
            finite = np.isfinite(crest)
            if np.any(finite):
                top = float(np.max(crest[finite]))
                crest_allowance = roughness(x)
                near_top = np.flatnonzero(finite & (crest >= top - s.allowance_multiplier * crest_allowance))
                onset = previous + int(near_top[-1])
        returns = runs(np.isfinite(x[last:]) & (x[last:] >= lower), s.recovery_samples)
        end = last + returns[0][0] if returns else None
        lo = onset if onset is not None else first
        hi = end if end is not None else n
        if lo <= anchor < hi and (first <= anchor or onset is not None):
            selected.append((group, onset, end))
    if len(selected) != 1:
        return empty(anchor, 'anchor_episode_unresolved')
    group, onset, end = selected[0]
    first, last = group[0][0], group[-1][1]
    lo = onset if onset is not None else first
    hi = end if end is not None else n - 1
    valid = x[first:last][np.isfinite(x[first:last])]
    lowest = float(np.min(valid))
    short = [[first + a + 1, first + b] for a, b in
             runs(np.isfinite(x[first:last]) & (x[first:last] >= lower))
             if b - a < s.recovery_samples]
    local = np.where(np.isfinite(smooth[lo:hi + 1]), smooth[lo:hi + 1], np.inf)
    peaks = find_peaks(-local, distance=s.continuation_samples,
                       prominence=s.allowance_multiplier * allowance)[0] + lo
    if not len(peaks):
        peaks = np.asarray([first + int(np.nanargmin(x[first:last]))])
    missing = bool(np.any(~np.isfinite(x[lo:min(n, hi + s.recovery_samples)])))
    flags = []
    if onset is None: flags.append('recording_start_or_prior_state_unresolved')
    if end is None: flags.append('recording_end_unrecovered')
    if short: flags.append('short_recovery_split_merge_ambiguous')
    if missing: flags.append('fixed_cohort_observations_missing')
    rise = float(np.median(x[end:end + s.recovery_samples]) - lowest) if end is not None else None
    return {'Anchor': anchor + 1, 'Start': onset + 1 if onset is not None else None,
            'FirstSupportedDeficit': first + 1, 'LastSupportedDeficit': last,
            'End': end + 1 if end is not None else None,
            'ConfirmationThrough': end + s.recovery_samples if end is not None else None,
            'AnchorConnected': True, 'State': 'unresolved',
            'Minima': (peaks + 1).astype(int).tolist(), 'ShortReturns': short,
            'Reference': None, 'DiagnosticReferences': [], 'Flags': flags,
            'LowerBand': float(lower), 'Level': float(level), 'Allowance': float(allowance),
            'LowValue': lowest, 'RawDrop': float(level - lowest), 'RawRise': rise,
            'ObservationMissing': missing}


def local_references(values, profile, settings):
    """Exactly 20/10 adjacent windows; never search for an older stable level."""
    s = settings; x = np.asarray(values, float); results = []
    onset = profile.get('Start')
    for length in [s.prestate_samples, s.short_prestate_samples]:
        r = None; reasons = []
        if onset is not None and onset - 1 >= length:
            r = reference(x, onset - 1 - length, replace(s, prestate_samples=length))
        if r is None:
            results.append({'Length': length, 'Reference': None, 'Usable': False,
                            'Reasons': ['insufficient_or_missing_predecline_observations']})
            continue
        boundary = x[max(0, onset - 1 - s.continuation_samples):onset]
        boundary = boundary[np.isfinite(boundary)]
        immediate = float(np.median(boundary)) if len(boundary) else None
        compatible = immediate is not None and abs(immediate - r['Median']) <= s.allowance_multiplier * r['Allowance']
        if not r['Stable']: reasons.append('predecline_state_changing')
        if not r['Clean']: reasons.append('predecline_window_contains_deficit')
        if not compatible: reasons.append('predecline_level_mismatch')
        first, last = r['First'] - 1, r['Last']
        initial_overlap = runs(np.isfinite(x[first:last]) & (x[first:last] < profile['LowerBand']), s.continuation_samples)
        if initial_overlap: reasons.append('prior_deficit_or_rebound_overlap')
        results.append({'Length': length, 'Reference': r, 'Usable': not reasons,
                        'ImmediateBoundaryMedian': immediate, 'LevelCompatible': compatible,
                        'PriorDeficitRuns': [[first + a + 1, first + b] for a, b in initial_overlap],
                        'TrendPerSample': float(np.polyfit(np.arange(length), x[first:last], 1)[0]),
                        'Reasons': reasons, 'ScientificReferenceAccepted': False})
    return results


def anchored_profile(values, anchor, span, settings=None):
    """Two bounded refinement rounds, all references tied to the same cycle."""
    s = settings or Settings(); x = np.asarray(values, float); n = len(x)
    anchor = int(np.clip(anchor, 0, n - 1))
    smooth = temporal_mean(x, s.smoothing_samples)
    look = max(s.prestate_samples, s.initial_context_multiplier * int(span))
    prefix = smooth[max(0, anchor - look):anchor]
    finite = prefix[np.isfinite(prefix)]
    if not len(finite) or not np.isfinite(x[anchor]):
        p = empty(anchor, 'anchor_observations_missing' if not np.isfinite(x[anchor]) else 'prestate_unavailable')
        p['Rounds'] = []; p['RoundCount'] = 0
        return p
    level = float(np.max(finite)); allowance = roughness(x)
    # A crest maximum is biased upward by fluctuations. Its immediately
    # preceding observed context supplies an allowance/level, without a remote
    # stable-window search. This is provisional; final windows follow onset.
    crest_first = max(0, anchor - look)
    crest_position = crest_first + int(np.nanargmax(prefix))
    if crest_position + 1 >= s.prestate_samples:
        crest_ref = reference(x, crest_position + 1 - s.prestate_samples, s)
        if crest_ref is not None:
            allowance = max(allowance, crest_ref['Allowance'])
            if crest_ref['Stable'] and crest_ref['Clean']: level = crest_ref['Median']
    extended = False
    if level - x[anchor] < s.allowance_multiplier * allowance:
        # A seed in a long flat trough can outlast its narrow scale context.
        # Widen the observed pre-context once, then still require the SAME
        # anchor-containing unrecovered interval. No other cycle is substituted.
        earlier = smooth[:anchor]
        valid_earlier = earlier[np.isfinite(earlier)]
        if len(valid_earlier):
            higher = float(np.max(valid_earlier))
            if higher - x[anchor] >= s.allowance_multiplier * allowance:
                level = higher; extended = True
    rounds = []; current = None
    for number in range(s.maximum_rounds):
        current = excursion(x, anchor, level, allowance, s)
        references = local_references(x, current, s) if current['AnchorConnected'] else []
        usable = [r for r in references if r['Usable']]
        chosen = usable[0] if usable else None
        current['DiagnosticReferences'] = references
        current['Reference'] = chosen['Reference'] if chosen else None
        current['ReferenceLength'] = chosen['Length'] if chosen else None
        current['LevelSource'] = ('event_local_20' if chosen and chosen['Length'] == s.prestate_samples else
                                  'event_local_10_conditional' if chosen else 'provisional_crest_unresolved')
        flags = current['Flags']
        if not chosen: flags.append('absolute_predecline_reference_unresolved')
        elif chosen['Length'] != s.prestate_samples: flags.append('short_predecline_reference_conditional')
        rise = current.get('RawRise')
        endpoint = x[current['End'] - 1:current['End'] - 1 + s.recovery_samples] if current.get('End') else np.asarray([])
        reference_return = (chosen is not None and len(endpoint) == s.recovery_samples and
            np.all(np.isfinite(endpoint)) and np.all(endpoint >= chosen['Reference']['LowerBand']))
        observed = (current['AnchorConnected'] and current['Start'] is not None and current['End'] is not None and
                    chosen is not None and chosen['Length'] == s.prestate_samples and not current['ObservationMissing'] and
                    rise is not None and rise >= s.allowance_multiplier * chosen['Reference']['Allowance'] and reference_return)
        current['State'] = 'observed_recovery' if observed else 'unresolved'
        rounds.append({k: current.get(k) for k in ['Start', 'End', 'AnchorConnected', 'Level', 'LowerBand',
            'Allowance', 'LevelSource', 'ReferenceLength', 'DiagnosticReferences', 'Flags']})
        if not current['AnchorConnected'] or number + 1 == s.maximum_rounds:
            break
        if chosen:
            level = chosen['Reference']['Median']; allowance = chosen['Reference']['Allowance']
    valid_rounds = [r for r in rounds if r['AnchorConnected']]
    current['Rounds'] = rounds; current['RoundCount'] = len(rounds)
    starts = [r['Start'] for r in valid_rounds if r['Start'] is not None]
    ends = [r['End'] for r in valid_rounds if r['End'] is not None]
    current['RefinementEnvelope'] = {'Onset': [min(starts), max(starts)] if starts else None,
                                     'Recovery': [min(ends), max(ends)] if ends else None}
    current['OnsetBracket'] = [current['Start'], current['FirstSupportedDeficit']] if current.get('Start') else None
    current['RecoveryBracket'] = [current['End'], current['End']] if current.get('End') else None
    if valid_rounds and not current['AnchorConnected']:
        current['Flags'].append('reference_refinement_lost_anchor_identity')
    if len(valid_rounds) > 1 and (len(set(starts)) > 1 or len(set(ends)) > 1):
        current['Flags'].append('boundary_reference_dependency')
    current['Flags'] = sorted(set(current['Flags']))
    current['ContextExtendedForContinuingDepression'] = extended
    return current
