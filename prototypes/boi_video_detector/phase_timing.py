"""Finite-grid phase-graph timing preview; never a scientific measurement service."""
from dataclasses import dataclass

import numpy as np

from .context_revision import ContextSettings, fit_preceding

SCHEMA = 'boi-phase-timing-0.1'


@dataclass(frozen=True)
class PhaseSettings:
    grid_size: int = 97
    huber_delta: float = 2.5
    context_change_penalty: float = 8.
    directional_change_penalty: float = .6
    decline_entry_penalty: float = 10.
    recovery_entry_penalty: float = 8.
    low_entry_penalty: float = 1.
    post_entry_penalty: float = 2.
    directional_occupancy_penalty: float = .15
    initial_incomplete_penalty: float = 8.
    minimum_episode_gain: float = 4.
    profile_cost_delta: float = 6.
    minimum_pre_seconds: float = 8.
    minimum_decline_seconds: float = 3.
    minimum_recovery_seconds: float = 3.
    minimum_post_seconds: float = 5.
    transition_evidence_seconds: float = 3.
    maximum_point_range_seconds: float = 4.
    contrast_variation_units: float = 3.
    correlation_proxy_cap: float = .8
    reference_seconds: float = 20.
    short_reference_seconds: float = 10.
    post_characterization_seconds: float = 20.
    stability_replicates: int = 12
    stability_block_seconds: float = 5.
    stability_seed: int = 734619

    def frames(self, seconds, fs):
        return max(1, int(round(seconds * fs)))


def variation(x):
    second = np.diff(x, n=2)
    second = second[np.isfinite(second)]
    return (float(1.4826 * np.median(np.abs(second - np.median(second))) / np.sqrt(6))
            if len(second) else 0.)


def noise_scale(x, grid_step, settings):
    innovation = max(variation(x), grid_step, 1e-6)
    differences = np.diff(x)
    if len(differences) < 3:
        return innovation, 0., innovation
    center = np.median(differences)
    spread = max(grid_step, 1.4826 * np.median(np.abs(differences - center)), 1e-6)
    d = np.clip(differences - center, -4 * spread, 4 * spread)
    a, b = d[:-1] - np.mean(d[:-1]), d[1:] - np.mean(d[1:])
    energy = float(np.linalg.norm(a) * np.linalg.norm(b))
    lag = float(a @ b / energy) if energy > 1e-20 else -.5
    # A bounded stationary-AR proxy, not an estimate of biological dynamics or
    # calibrated uncertainty. Trend can make it conservative.
    rho = float(np.clip(1 + 2 * lag, 0., settings.correlation_proxy_cap))
    return innovation * np.sqrt((1 + rho) / (1 - rho)), rho, innovation


def phase_graph(settings, fs):
    phases, groups = [], {}
    for name, count in [('P', settings.frames(settings.minimum_pre_seconds, fs)),
                        ('D', settings.frames(settings.minimum_decline_seconds, fs)), ('L', 1),
                        ('R', settings.frames(settings.minimum_recovery_seconds, fs)),
                        ('O', settings.frames(settings.minimum_post_seconds, fs))]:
        groups[name] = list(range(len(phases), len(phases) + count))
        phases.extend([name] * count)
    edges = []

    def add(source, target, kind, cost, entering=False):
        edges.append((source, target, kind, float(cost), entering))

    for name, indices in groups.items():
        for i, source in enumerate(indices):
            target = indices[min(i + 1, len(indices) - 1)]
            add(source, target, 'stay', 0.)
            if name in ('P', 'O'):
                add(source, target, 'free', settings.context_change_penalty)
            elif name in ('D', 'R'):
                add(source, target, 'down' if name == 'D' else 'up', settings.directional_change_penalty)
    for source in (groups['P'][-1], groups['O'][-1]):
        add(source, groups['D'][0], 'down', settings.decline_entry_penalty, True)
    add(groups['R'][-1], groups['D'][0], 'down', settings.decline_entry_penalty, True)
    add(groups['D'][-1], groups['L'][0], 'stay', settings.low_entry_penalty)
    add(groups['D'][-1], groups['R'][0], 'up', settings.recovery_entry_penalty)
    add(groups['L'][0], groups['R'][0], 'up', settings.recovery_entry_penalty)
    add(groups['R'][-1], groups['O'][0], 'stay', settings.post_entry_penalty)
    occupancy = np.array([settings.directional_occupancy_penalty if p in ('D', 'R') else 0. for p in phases])
    initial = np.full(len(phases), np.inf)
    initial[groups['P'][0]] = 0.
    for name in ('D', 'L', 'R'):
        initial[groups[name][0]] = settings.initial_incomplete_penalty
    return phases, groups, edges, occupancy, initial


def transform(values, kind):
    """Strict directed level change, equality, or unconstrained context change."""
    k = len(values)
    if kind == 'stay':
        return values.copy(), np.arange(k)
    if kind == 'free':
        i = int(np.argmin(values))
        return np.full(k, values[i]), np.full(k, i)
    reverse = kind == 'down'
    x = values[::-1] if reverse else values
    cumulative = np.minimum.accumulate(x)
    fresh = np.r_[True, x[1:] < cumulative[:-1]]
    indices = np.maximum.accumulate(np.where(fresh, np.arange(k), 0))
    result = np.r_[np.inf, cumulative[:-1]]
    arguments = np.r_[-1, indices[:-1]]
    if reverse:
        return result[::-1], np.where(arguments[::-1] < 0, -1, k - 1 - arguments[::-1])
    return result, arguments


def graph_solve(emission, entry, settings, fs, naive=False):
    n, k = emission.shape
    phases, groups, edges, occupancy, initial = phase_graph(settings, fs)
    states = len(phases)
    forward = np.full((n, states, k), np.inf)
    previous_state = np.full((n, states, k), -1, dtype=np.int16)
    previous_level = np.full_like(previous_state, -1)
    forward[0] = initial[:, None] + occupancy[:, None] + emission[0]
    source_indices, target_indices = np.indices((k, k))

    def move(vector, kind):
        if not naive:
            return transform(vector, kind)
        allowed = {'stay': source_indices == target_indices,
                   'free': np.ones((k, k), bool),
                   'up': source_indices < target_indices,
                   'down': source_indices > target_indices}[kind]
        costs = np.where(allowed, vector[:, None], np.inf)
        arg = np.argmin(costs, axis=0)
        return costs[arg, np.arange(k)], arg

    for t in range(1, n):
        for source, target, kind, penalty, is_entry in edges:
            if is_entry and not entry[t]:
                continue
            cost, arg = move(forward[t - 1, source], kind)
            cost = cost + penalty
            improved = cost < forward[t, target]
            forward[t, target, improved] = cost[improved]
            previous_state[t, target, improved] = source
            previous_level[t, target, improved] = arg[improved]
        forward[t] += occupancy[:, None] + emission[t]
    state, level = np.unravel_index(np.argmin(forward[-1]), forward[-1].shape)
    score = float(forward[-1, state, level])
    path_state, path_level = np.empty(n, int), np.empty(n, int)
    for t in range(n - 1, -1, -1):
        path_state[t], path_level[t] = state, level
        if t:
            state, level = int(previous_state[t, state, level]), int(previous_level[t, state, level])
            assert state >= 0 and level >= 0
    if naive:
        return {'Score': score, 'States': path_state, 'Levels': path_level, 'Forward': forward}
    backward = np.zeros_like(forward)
    reverse = {'stay': 'stay', 'free': 'free', 'up': 'down', 'down': 'up'}
    for t in range(n - 2, -1, -1):
        backward[t] = np.inf
        for source, target, kind, penalty, is_entry in edges:
            if is_entry and not entry[t + 1]:
                continue
            cost, _ = transform(backward[t + 1, target] + emission[t + 1] + occupancy[target], reverse[kind])
            backward[t, source] = np.minimum(backward[t, source], cost + penalty)
    profiles = {key: np.full(n, np.inf) for key in ('onset', 'low', 'rise', 'post')}
    for source, target, kind, penalty, is_entry in edges:
        pair = phases[source], phases[target]
        key = ('onset' if is_entry else 'low' if pair == ('D', 'L') else
               'rise' if pair in (('D', 'R'), ('L', 'R')) else 'post' if pair == ('R', 'O') else None)
        if key is None:
            continue
        for t in range(1, n):
            if is_entry and not entry[t]:
                continue
            cost, _ = transform(forward[t - 1, source], kind)
            value = float(np.min(cost + penalty + emission[t] + occupancy[target] + backward[t, target]))
            profiles[key][t] = min(profiles[key][t], value)
    return {'Score': score, 'States': path_state, 'Levels': path_level,
            'Phases': [phases[s] for s in path_state], 'Profiles': profiles,
            'ForwardEnd': forward[-1], 'BackwardStart': backward[0]}


def null_solve(emission, settings):
    n, k = emission.shape
    results = []
    for kind, penalty in [('free', settings.context_change_penalty),
                          ('up', settings.directional_change_penalty),
                          ('down', settings.directional_change_penalty)]:
        costs = emission[0].copy()
        history = np.full((n, k), -1, dtype=np.int16)
        for t in range(1, n):
            changed, arg = transform(costs, kind)
            changed += penalty
            change = changed < costs
            history[t] = np.where(change, arg, np.arange(k))
            costs = np.minimum(costs, changed) + emission[t]
        j = int(np.argmin(costs))
        score = float(costs[j])
        path = np.empty(n, int)
        for t in range(n - 1, -1, -1):
            path[t] = j
            if t:
                j = int(history[t, j])
        results.append({'Kind': kind, 'Score': score, 'Levels': path})
    return min(results, key=lambda r: r['Score'])


def observed_entry(x, width):
    result = np.zeros(len(x), bool)
    for i in range(1, len(x)):
        a = x[max(0, i - width):i]
        b = x[i:min(len(x), i + width)]
        result[i] = bool(len(a) and len(b) and np.median(b) < np.median(a))
    return result


def profile_range(profile, score, lo, hi, fallback, settings):
    indices = np.arange(max(0, lo), min(len(profile), hi))
    selected = indices[profile[indices] <= score + settings.profile_cost_delta + 1e-8]
    if not len(selected):
        selected = np.array([fallback], int)
    return {'Range': [int(selected[0]), int(selected[-1]) + 1],
            'Alternatives': selected, 'Costs': profile[selected]}


def reference_evidence(x, alternatives, previous_end, fs, settings):
    stop = int(min(alternatives))
    start = max(previous_end, stop - settings.frames(settings.reference_seconds, fs))
    fits = fit_preceding(x, stop, fs, ContextSettings())
    candidates = []
    for fit in fits['Fits']:
        a, b = fit['Range']
        if a < start or b <= a:
            continue
        values = x[a:b]
        candidates.append({'Range': [a, b], 'State': fit['State'], 'Samples': len(values),
                           'Mean': float(np.mean(values)), 'Median': float(np.median(values)),
                           'MAD': float(1.4826 * np.median(np.abs(values - np.median(values))))})
    if not candidates:
        state = 'unavailable'
    elif any(c['State'] == 'recovering' for c in candidates):
        state = 'recovering'
    elif any(c['State'] != 'stable' for c in candidates):
        state = 'changing'
    elif max(c['Samples'] for c in candidates) < settings.frames(settings.reference_seconds, fs):
        state = 'short_context_only'
    else:
        state = 'supported_observed'
    return {'State': state, 'Candidates': candidates, 'CommonPrecedingEnd': stop,
            'ScientificReferenceAccepted': False}


def decode_episodes(x, fit, grid, sigma, fs, settings):
    phases = fit['Phases']
    n = len(x)
    starts = [i for i in range(n) if phases[i] == 'D' and (i == 0 or phases[i - 1] in ('P', 'O', 'R'))]
    if phases[0] in ('L', 'R'):
        starts.insert(0, 0)
    episodes = []
    previous_end = 0
    latent = grid[fit['Levels']]
    for number, start in enumerate(starts):
        next_start = starts[number + 1] if number + 1 < len(starts) else n
        rise = next((i for i in range(start, next_start) if phases[i] == 'R'), None)
        post = next((i for i in range(start, next_start) if phases[i] == 'O'), None)
        low = next((i for i in range(start, next_start) if phases[i] == 'L'), None)
        floor_end = rise if rise is not None else next_start
        floor_start = low if low is not None else start + int(np.argmin(latent[start:max(start + 1, floor_end)]))
        left = start == 0 and phases[0] != 'P'
        right = post is None or next_start - post < settings.frames(settings.minimum_post_seconds, fs)
        onset = (None if left else profile_range(fit['Profiles']['onset'], fit['Score'],
                                                previous_end, max(start + 1, floor_start + 1), start, settings))
        reference = ({'State': 'unavailable', 'Candidates': [], 'ScientificReferenceAccepted': False}
                     if left else reference_evidence(x, onset['Alternatives'], previous_end, fs, settings))
        limited = left or (not left and onset['Range'][0] <= settings.frames(settings.minimum_pre_seconds, fs))
        onset_status = ('left_censored' if left else 'search_limited' if limited else
                        'range_only' if onset['Range'][1] - onset['Range'][0] - 1 > settings.frames(settings.maximum_point_range_seconds, fs)
                        else 'identified')
        completion = (None if post is None else profile_range(fit['Profiles']['post'], fit['Score'],
                      rise + 1, next_start, post, settings))
        pre_level = (float(np.median(x[max(previous_end, start - 5):start])) if start > previous_end else float(x[start]))
        recognition_drop = pre_level - float(np.min(latent[start:max(start + 1, floor_end)]))
        contrast = recognition_drop >= settings.contrast_variation_units * sigma
        conditional = onset_status != 'identified' or reference['State'] != 'supported_observed'
        post_range, post_state, reference_return = None, 'unavailable', 'unavailable'
        if post is not None:
            end = min(next_start, post + settings.frames(settings.post_characterization_seconds, fs))
            post_range = [post, end]
            values = x[post:end]
            slope = float(np.polyfit(np.arange(len(values)), values, 1)[0]) if len(values) > 1 else 0.
            post_state = 'stable' if abs(slope) * max(1, len(values) - 1) <= 2 * sigma else 'rising' if slope > 0 else 'changing'
            if reference['Candidates']:
                chosen = max(reference['Candidates'], key=lambda c: c['Samples'])
                tolerance = 2 * max(sigma, chosen['MAD'])
                difference = float(np.median(values) - chosen['Median'])
                reference_return = ('below_observed_reference' if difference < -tolerance else
                                    'above_observed_reference' if difference > tolerance else 'compatible_with_observed_reference')
        recovery_status = ('right_censored' if right else 'conditional_phase_return' if conditional else 'observed_phase_return')
        episodes.append({'Onset': None if left else start, 'OnsetStatus': onset_status,
                         'OnsetEvidence': onset, 'LowRange': [floor_start, max(floor_start + 1, floor_end)],
                         'LowPhasePresent': low is not None, 'RiseStart': rise, 'PostStart': post,
                         'PostEvidence': completion, 'PostRange': post_range, 'PostState': post_state,
                         'Reference': reference, 'ReferenceReturn': reference_return,
                         'RecoveryStatus': recovery_status, 'IsConditional': conditional,
                         'ConditionalOn': {'OnsetStatus': onset_status, 'ReferenceState': reference['State']},
                         'LeftCensored': left, 'RightCensored': right,
                         'EndReason': ('renewed_decline' if post is None and next_start < n else
                                       'observed_span_end' if right else 'post_state_observed'),
                         'RecognitionContrast': recognition_drop, 'ContrastSupported': contrast,
                         'MeasurementReady': False, 'ScientificRecoveredBaselineEligible': False})
        previous_end = post if post is not None else next_start
    for i, ep in enumerate(episodes):
        before = episodes[i - 1] if i else None
        ep['SeparationFromPrevious'] = ('not_applicable' if before is None else
            'observed_return' if not before['RightCensored'] and before['Reference']['State'] == 'supported_observed'
            and before['ReferenceReturn'] in ('compatible_with_observed_reference', 'above_observed_reference')
            else 'linked_or_uncertain')
    return episodes


def fit_block(x, fs, settings):
    low, high = float(np.min(x)), float(np.max(x))
    step = max((high - low) / (settings.grid_size - 1), 1e-6)
    grid = np.linspace(low, high, settings.grid_size) if high > low else np.full(settings.grid_size, low)
    sigma, rho, innovation = noise_scale(x, step, settings)
    residual = np.abs((x[:, None] - grid) / sigma)
    delta = settings.huber_delta
    emission = np.where(residual <= delta, .5 * residual ** 2, delta * (residual - .5 * delta))
    entry = observed_entry(x, settings.frames(settings.transition_evidence_seconds, fs))
    fit = graph_solve(emission, entry, settings, fs)
    null = null_solve(emission, settings)
    gain = null['Score'] - fit['Score']
    episodes = decode_episodes(x, fit, grid, sigma, fs, settings)
    supported = gain >= settings.minimum_episode_gain and any(e['ContrastSupported'] for e in episodes)
    explanation = 'episode_path_supported' if supported else 'no_added_episode_supported'
    used_levels = fit['Levels'] if supported else null['Levels']
    return {'State': explanation, 'Score': fit['Score'], 'NullScore': null['Score'],
            'NullKind': null['Kind'], 'EpisodeGain': gain, 'Noise': sigma, 'GridStep': step, 'Grid': grid,
            'CorrelationProxy': rho, 'InnovationScale': innovation,
            'Fit': grid[used_levels], 'GraphFit': grid[fit['Levels']], 'PhasePath': fit['Phases'],
            'GridPath': fit['Levels'], 'StatePath': fit['States'], 'Profiles': fit['Profiles'],
            'EntryEvidence': entry, 'Episodes': episodes if supported else [],
            'UnselectedGraphEpisodes': episodes if not supported else [],
            'MissingPrecedingHistoryPossible': bool(not supported and null['Kind'] == 'up'
                                                  and high - low > settings.contrast_variation_units * sigma)}


def fit_timing(values, motion, fs, settings):
    x, motion = np.asarray(values, float), np.asarray(motion, bool)
    valid = np.isfinite(x) & ~motion
    changes = np.diff(np.r_[False, valid, False].astype(int))
    starts, stops = np.flatnonzero(changes == 1), np.flatnonzero(changes == -1)
    blocks, episodes = [], []
    fitted = np.full(len(x), np.nan)

    def cause(i, boundary):
        if i < 0 or i >= len(x):
            return [boundary]
        return (['motion'] if motion[i] else []) + (['missing_sample'] if not np.isfinite(x[i]) else [])

    for start, stop in zip(starts, stops, strict=True):
        if stop - start < settings.frames(settings.minimum_decline_seconds + settings.minimum_recovery_seconds, fs):
            blocks.append({'Span': [int(start), int(stop)], 'State': 'insufficient_observed_context',
                           'LeftCauses': cause(start - 1, 'window_start'), 'RightCauses': cause(stop, 'window_end')})
            continue
        block = fit_block(x[start:stop], fs, settings)
        fitted[start:stop] = block['Fit']
        block.update(Span=[int(start), int(stop)], LeftCauses=cause(start - 1, 'window_start'),
                     RightCauses=cause(stop, 'window_end'))
        for ep in block['Episodes']:
            ep['SpanOffset'] = int(start)
            ep['CensoringCauses'] = {'Left': block['LeftCauses'] if ep['LeftCensored'] else [],
                                     'Right': (['renewed_decline_before_separation'] if ep['EndReason'] == 'renewed_decline'
                                               else block['RightCauses'] if ep['RightCensored'] else [])}
            episodes.append(ep)
        blocks.append(block)
    return {'Schema': SCHEMA, 'Blocks': blocks, 'Episodes': episodes, 'Fitted': fitted,
            'InvalidSamples': np.flatnonzero(~valid),
            'State': 'episode_path_supported' if episodes else 'no_added_episode_supported' if blocks else 'unavailable',
            'MissingPrecedingHistoryPossible': any(b.get('MissingPrecedingHistoryPossible', False) for b in blocks),
            'MeasurementReady': False, 'ScientificBurdenAvailable': False,
            'ScientificReferencesAccepted': False, 'SpatialClassificationChanged': False}
