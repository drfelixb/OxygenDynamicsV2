"""Spatially checked anchored episodes; experimental, never burden ready."""
from collections import OrderedDict, defaultdict
import hashlib
import numpy as np
from scipy import ndimage
from scipy.spatial import cKDTree
from boi_joint_video_detector.numeric import strict_mean, roughness, correlation
from boi_joint_video_detector.service import patch_bank, comparisons
from .numeric import Settings, anchored_profile, runs

SCHEMA = 'boi-episode-identity-1'
UNCERTAINTY = {'fixed_cohort_observations_missing', 'spatial_observations_missing',
    'boundary_geometry_unresolved', 'displacement_like_evidence', 'limited_spatial_observability',
    'short_recovery_split_merge_ambiguous', 'absolute_predecline_reference_unresolved',
    'short_predecline_reference_conditional', 'continuing_branch_or_spatial_clearance_unresolved',
    'spatial_identity_unresolved', 'reference_refinement_lost_anchor_identity',
    'multiple_episode_membership_ambiguous', 'raw_local_episode_disagreement',
    'boundary_reference_instability', 'recording_start_censored',
    'regional_reference_dependency', 'conditional_context_overlaps_episode'}


def confidence(raw, spatial, flags, connected, regional=False):
    """One source-level certainty contract, including group membership flags."""
    if regional: return 'regional_context'
    if not connected: return 'unresolved'
    reference = raw.get('Reference')
    usable = reference is not None and reference['Stable'] and reference['Clean'] and raw.get('ReferenceLength') == 20
    complete = (raw.get('Start') is not None and raw.get('End') is not None and
                raw['State'] == 'observed_recovery' and usable and spatial['AllBranchesRecovered'] and
                not (set(flags) & UNCERTAINTY))
    return 'complete_episode_candidate' if complete else 'uncertain_episode_candidate'


class Assembler:
    def __init__(self, raw, settings=None):
        self.raw = raw; self.s = settings or Settings(); self.n, self.h, self.w = raw.shape
        self.bank = patch_bank(raw, min(8, max(1, min(self.h, self.w) // 4)))
        self.noise = roughness(raw)
        self.traces = OrderedDict(); self.images = OrderedDict()

    def trace(self, mask):
        key = np.asarray(mask, np.uint16).tobytes()
        if key not in self.traces:
            self.traces[key] = strict_mean(self.raw, mask)
            if len(self.traces) > 128: self.traces.popitem(last=False)
        self.traces.move_to_end(key)
        return self.traces[key]

    def preimage(self, onset):
        first = onset - 1 - self.s.prestate_samples
        if first < 0: return None
        if first not in self.images:
            self.images[first] = np.median(self.raw[first:onset - 1], axis=0)
            if len(self.images) > 64: self.images.popitem(last=False)
        self.images.move_to_end(first)
        return self.images[first]

    def geometry(self, support, profile, anchor):
        s = self.s
        result = {'BoundaryConfounded': False, 'OpposingNeighbourFraction': None,
                  'HighGradientRatio': None, 'TouchesObservedFieldBoundary': False,
                  'FieldResponseFraction': None, 'SupportFractionOfObservedField': len(support) / (self.h * self.w),
                  'AnatomyValidated': False}
        onset = profile.get('Start')
        pre = self.preimage(onset) if onset is not None else None
        if pre is None: return result
        ys, xs = np.asarray(support) // self.w, np.asarray(support) % self.w
        finite = np.isfinite(pre); safe = np.where(finite, pre, 0.)
        gy, gx = np.gradient(safe); gradient = np.hypot(gy, gx)
        typical = max(float(np.median(gradient[finite])) if np.any(finite) else 0., s.numerical_floor)
        ratio = float(np.median(gradient[ys, xs]) / typical)
        touches = bool(np.any((ys <= s.observed_boundary_margin_blocks) | (ys >= self.h - 1 - s.observed_boundary_margin_blocks) |
                              (xs <= s.observed_boundary_margin_blocks) | (xs >= self.w - 1 - s.observed_boundary_margin_blocks)))
        mask = np.zeros(self.h * self.w, bool); mask[support] = True; mask = mask.reshape(self.h, self.w)
        annulus = ndimage.binary_dilation(mask, iterations=3) & ~mask & finite
        image = np.mean(self.raw[max(0, anchor - 1):min(self.n, anchor + 2)], axis=0, dtype=float)
        change = image - pre; valid = finite & np.isfinite(image) & np.isfinite(self.noise)
        result['FieldResponseFraction'] = float(np.mean(change[valid] < -s.allowance_multiplier * self.noise[valid])) if np.any(valid) else None
        opposing = float(np.mean(change[annulus] > s.allowance_multiplier * self.noise[annulus])) if np.any(annulus) else None
        darker = bool(np.any(annulus) and np.median(pre[ys, xs]) < s.boundary_level_fraction * np.median(pre[annulus]))
        confounded = touches or (ratio > s.boundary_gradient_ratio and (darker or (opposing is not None and opposing > .5)))
        result.update(HighGradientRatio=ratio, TouchesObservedFieldBoundary=touches,
                      OpposingNeighbourFraction=opposing, BoundaryConfounded=confounded)
        return result

    def spatial(self, support, core, profile, anchor, field=None, loading=None):
        s = self.s
        result = {'CoherentMask': [], 'Tracks': [], 'ChildCohorts': [], 'Missing': False,
                  'AllBranchesRecovered': False, 'RecoveryFrame': None, 'SpatialGapPresent': False,
                  'IdentityConnected': False, 'Signal': 'raw' if field is None else 'conditional_field',
                  'NativeAreaMeasured': False}
        onset = profile.get('Start')
        if onset is None or onset - 1 < s.prestate_samples: return result
        first = onset - 1 - s.prestate_samples
        values = self.raw.reshape(self.n, -1)[:, support].astype(float)
        pre = values[first:onset - 1]
        if field is not None:
            fref = float(np.median(field[first:onset - 1]))
            if not np.isfinite(fref) or abs(fref) <= s.numerical_floor: return result
            load = np.median(pre, axis=0) / fref
            values -= field[:, None] * load[None]
            pre = values[first:onset - 1]
        finite = np.all(np.isfinite(pre), axis=0)
        safe = np.where(np.isfinite(pre), pre, 0.)
        half = s.prestate_samples // 2
        left, right = np.median(safe[:half], axis=0), np.median(safe[half:], axis=0)
        position = (np.arange(s.prestate_samples) - (half - 1) / 2) / half
        residual = safe - (left[None] + position[:, None] * (right - left)[None])
        deviation = 1.4826 * np.median(np.abs(residual - np.median(residual, axis=0)[None]), axis=0)
        diff = np.diff(safe, axis=0)
        short = 1.4826 * np.median(np.abs(diff - np.median(diff, axis=0)[None]), axis=0) / np.sqrt(2.)
        scale = np.maximum(np.maximum(deviation, short), np.maximum(s.numerical_floor, np.max(np.abs(safe), axis=0) * s.relative_floor_fraction))
        level = np.median(safe, axis=0); lower = level - s.allowance_multiplier * scale
        stable = finite & (np.abs(right - left) <= s.allowance_multiplier * scale) & np.all(safe >= lower[None], axis=0)
        below = np.isfinite(values) & (values < lower[None])
        lo, hi = onset - 1, profile.get('End') or self.n
        active = []; track_columns = []
        for j, index in enumerate(support):
            if not finite[j]: result['Missing'] = True; continue
            periods = runs(below[:, j], s.continuation_samples)
            relevant = [(a, b) for a, b in periods if max(a, lo) + s.continuation_samples <= min(b, hi)]
            if not relevant: continue
            a, last = relevant[0]
            for c, d in periods:
                if c < a: continue
                if runs(np.isfinite(values[last:c, j]) & (values[last:c, j] >= lower[j]), s.recovery_samples): break
                last = max(last, d)
            returned = runs(np.isfinite(values[last:, j]) & (values[last:, j] >= lower[j]), s.recovery_samples)
            recovery = last + returned[0][0] + 1 if returned else None
            stop = min(self.n, (recovery + s.recovery_samples - 1) if recovery else self.n)
            missing = bool(np.any(~np.isfinite(values[a:stop, j])))
            result['Missing'] |= missing
            active.append({'Block': int(index), 'FirstDeficit': a + 1, 'LastDeficit': last,
                           'RecoveryFrame': recovery, 'ReferenceStable': bool(stable[j]),
                           'ReferenceMedian': float(level[j]), 'LowerBand': float(lower[j]),
                           'ReferenceAllowance': float(scale[j]), 'Missing': missing})
            track_columns.append(j)
        if not active: return result
        points = np.asarray([[r['Block'] // self.w, r['Block'] % self.w] for r in active])
        parents = list(range(len(active)))
        def find(i):
            while parents[i] != i: parents[i] = parents[parents[i]]; i = parents[i]
            return i
        link_count = 0
        for a, b in cKDTree(points).query_pairs(s.gap_blocks + 1, p=np.inf):
            common = below[lo:hi, track_columns[a]] & below[lo:hi, track_columns[b]]
            if not runs(common, s.continuation_samples): continue
            aa, bb = find(a), find(b)
            if aa != bb: parents[max(aa, bb)] = min(aa, bb)
            link_count += 1
        groups = defaultdict(list)
        for i in range(len(active)): groups[find(i)].append(i)
        core_set = set(int(v) for v in core)
        anchor_columns = {i for i, r in enumerate(active) if r['Block'] in core_set and
            np.any(below[max(0, anchor - 1):min(self.n, anchor + 2), track_columns[i]])}
        minimum = min(s.minimum_spatial_blocks, len(support))
        kept = []
        for members in groups.values():
            connected = bool(set(members) & anchor_columns)
            mask = [active[i]['Block'] for i in members]
            result['ChildCohorts'].append({'Blocks': mask, 'AnchorConnected': connected,
                'FirstDeficit': min(active[i]['FirstDeficit'] for i in members),
                'LastDeficit': max(active[i]['LastDeficit'] for i in members)})
            if connected and len(members) >= minimum: kept += members
        result['CoherentMask'] = [active[i]['Block'] for i in kept]
        result['MultipleUnlinkedOrigins'] = sum(bool(set(m) & set(kept)) for m in groups.values()) > 1
        result['Tracks'] = active; result['IdentityConnected'] = bool(kept)
        result['TemporalSpatialLinks'] = link_count
        topology = np.zeros(self.h * self.w, bool); topology[result['CoherentMask']] = True
        result['SpatialGapPresent'] = bool(kept) and ndimage.label(topology.reshape(self.h, self.w))[1] > 1
        result['AllBranchesRecovered'] = bool(kept) and len(kept) == len(active) and not result['Missing'] and all(r['RecoveryFrame'] is not None and r['ReferenceStable'] for r in active)
        if result['AllBranchesRecovered']: result['RecoveryFrame'] = max(r['RecoveryFrame'] for r in active)
        return result

    def assess(self, item):
        s = self.s; c = int(item['Anchor']); core, support = item['CoreMask'], item['SupportMask']
        x = self.trace(core)
        raw = anchored_profile(x, c, item['Span'], s)
        around, external, full = comparisons(self.raw, core, self.bank)
        conditional = {}; relatives = {}; round_counts = [raw['RoundCount']]
        onset = raw.get('Start'); shared = len(support) == self.h * self.w
        if onset is not None and onset - 1 >= s.prestate_samples:
            a, b = onset - 1 - s.prestate_samples, onset - 1
            for role, comp in around.items():
                target_pre, other_pre = x[a:b], comp[a:b]
                if not np.all(np.isfinite(target_pre)) or not np.all(np.isfinite(other_pre)): continue
                center = float(np.median(other_pre))
                if abs(center) < s.numerical_floor: continue
                loading = max(0., float(np.median(target_pre)) / center)
                values = x - loading * comp
                p = anchored_profile(values, c, item['Span'], s)
                relatives[role] = p; round_counts.append(p['RoundCount'])
                end = min(self.n, (raw.get('End') or self.n) + s.recovery_samples)
                corr = correlation(x[onset - 1:end], comp[onset - 1:end])
                drop = loading * (center - comp[c]) if np.isfinite(comp[c]) else None
                overlap = bool(p.get('Start') is not None and
                    max(a, p['Start'] - 1) < min(b, p.get('End') or self.n))
                conditional[role] = {'Loading': loading, 'FitFrames': [a + 1, b],
                    'VerifiedQuiet': False, 'InteriorFitSamples': 0, 'DriftDegrees': 0,
                    'Correlation': corr, 'ComparatorDrop': drop, 'Profile': p,
                    'FitOverlapsRefinedEpisode': overlap, 'PatchIDs': external[role]}
                if role == 'field' and corr is not None and drop is not None and raw.get('RawDrop') is not None:
                    shared |= corr >= s.shared_correlation and drop >= s.shared_contrast_fraction * raw['RawDrop']
        relative = relatives.get('field')
        local = bool(relative and relative['AnchorConnected'])
        regional = bool(shared and not local)
        chosen = raw if raw['AnchorConnected'] else (relative if local else raw)
        relative_spatial = False
        if (raw.get('State') != 'observed_recovery' or shared) and local and relative.get('End') is not None:
            chosen = relative; relative_spatial = True
        spatial = self.spatial(support, core, chosen, c,
            field=around.get('field') if relative_spatial else None) if not regional else {
                'CoherentMask': [], 'Tracks': [], 'ChildCohorts': [], 'Missing': False,
                'AllBranchesRecovered': False, 'RecoveryFrame': None, 'SpatialGapPresent': False,
                'IdentityConnected': False, 'Signal': 'regional_context', 'NativeAreaMeasured': False}
        geometry = self.geometry(support, chosen, c)
        flags = list(chosen['Flags'])
        if item.get('Kind') == 'start_censored': flags.append('recording_start_censored')
        if item.get('DisplacementLikeFrames'): flags.append('displacement_like_evidence')
        if geometry['BoundaryConfounded']: flags.append('boundary_geometry_unresolved')
        if spatial['Missing']: flags.append('spatial_observations_missing')
        if len(support) < s.minimum_spatial_blocks: flags.append('limited_spatial_observability')
        if spatial['SpatialGapPresent']: flags.append('spatial_gap_supported_not_filled')
        if spatial.get('MultipleUnlinkedOrigins'): flags.append('spatial_identity_unresolved')
        if chosen['AnchorConnected'] and not spatial['IdentityConnected'] and not regional: flags.append('spatial_identity_unresolved')
        if chosen['AnchorConnected'] and not spatial['AllBranchesRecovered'] and not regional: flags.append('continuing_branch_or_spatial_clearance_unresolved')
        for p in [raw] + list(relatives.values()):
            valid = [r['Reference'] for r in p['DiagnosticReferences'] if r['Usable']]
            if len(valid) > 1 and abs(valid[0]['Median'] - valid[1]['Median']) > s.allowance_multiplier * max(r['Allowance'] for r in valid):
                flags.append('boundary_reference_instability')
        if raw['AnchorConnected'] and local and raw.get('End') and relative.get('Start') and raw['End'] < relative['Start']:
            flags.append('raw_local_episode_disagreement')
        if relative_spatial:
            flags.append('regional_reference_dependency')
            if conditional['field']['FitOverlapsRefinedEpisode']:
                flags.append('conditional_context_overlaps_episode')
        # Every reported complete raw return must hold on the plotted cohort
        # after extending to the last continuing branch's return.
        if spatial['AllBranchesRecovered'] and raw.get('End') is not None and not relative_spatial:
            proposed = max(raw['End'], spatial['RecoveryFrame'])
            check = x[proposed - 1:proposed - 1 + s.recovery_samples]
            band = raw['Reference']['LowerBand'] if raw['Reference'] else raw['LowerBand']
            if len(check) == s.recovery_samples and np.all(np.isfinite(check)) and np.all(check >= band):
                raw['CoreOnlyReturnBeforeSpatialClearance'] = raw['End']
                raw['End'] = proposed; raw['ConfirmationThrough'] = proposed + s.recovery_samples - 1
                raw['RecoveryBracket'] = [proposed, proposed]
            else:
                raw['State'] = 'unresolved'; flags.append('continuing_branch_or_spatial_clearance_unresolved')
        connected = bool(chosen['AnchorConnected'] and spatial['IdentityConnected'])
        state = 'relative_recovery' if relative_spatial and connected else raw['State']
        start, end = chosen.get('Start'), chosen.get('End')
        if item.get('Kind') == 'start_censored': start = None
        if not chosen['AnchorConnected']: start = end = None
        if connected: assert (start is None or start <= c + 1) and (end is None or c + 1 < end)
        recognition = confidence(raw, spatial, flags, connected, regional)
        if regional: state = 'regional_context'
        raw['ProvisionalEnd'] = raw.get('End')
        raw['ProvisionalConfirmationThrough'] = raw.get('ConfirmationThrough')
        if raw['State'] != 'observed_recovery':
            raw['End'] = None; raw['ConfirmationThrough'] = None
        return {'ID': item['ID'], 'CoreMask': np.asarray(core, np.uint16), 'SupportMask': np.asarray(support, np.uint16),
            'CoreHash': hashlib.sha256(np.asarray(core, np.uint16).tobytes()).hexdigest(),
            'SeedCount': item.get('SeedCount', 1), 'SeedIDs': item.get('SeedIDs', []),
            'SeedEvidence': item.get('SeedEvidence', []), 'SourceAnchor': c + 1, 'Anchor': c + 1,
            'SourceSpan': item['Span'], 'ScaleAlternatives': item.get('ScaleAlternatives', []),
            'OriginalRecognition': item.get('OriginalRecognition'), 'RawProfile': raw,
            'RegionalComparisons': conditional, 'SelectedRelativeComparison': 'field' if relative is not None else None,
            'RelativeProfile': relative, 'SpatialEvidence': spatial, 'GeometryEvidence': geometry,
            'IdentityConnected': connected, 'IdentitySignal': 'conditional_field' if relative_spatial else 'raw',
            'Recognition': recognition, 'RecoveryState': state, 'Interval': [start, end],
            'Flags': sorted(set(flags)), 'IdentityReferenceRounds': max(round_counts),
            'OnsetBracket': chosen.get('OnsetBracket'), 'RecoveryBracket': chosen.get('RecoveryBracket'),
            'MeasurementReady': False, 'BurdenReady': False, 'NativeAreaMeasured': False}

    def compatible(self, a, b):
        if not a['IdentityConnected'] or not b['IdentityConnected']: return False, 'identity_unresolved'
        lo = max(a['Interval'][0] or 1, b['Interval'][0] or 1) - 1
        hi = min(a['Interval'][1] or self.n, b['Interval'][1] or self.n)
        if hi - lo < self.s.continuation_samples: return False, 'separated'
        aa, bb = a['SpatialEvidence']['CoherentMask'], b['SpatialEvidence']['CoherentMask']
        if not len(aa) or not len(bb): return False, 'spatial_identity_unresolved'
        pa = np.column_stack([np.asarray(aa) // self.w, np.asarray(aa) % self.w])
        pb = np.column_stack([np.asarray(bb) // self.w, np.asarray(bb) % self.w])
        nearby = np.min(cKDTree(pa).query(pb, k=1, p=np.inf)[0]) <= self.s.gap_blocks + 1
        if not nearby: return False, 'unsupported_spatial_gap'
        xa, xb = self.trace(a['CoreMask']), self.trace(b['CoreMask'])
        corr = correlation(xa[lo:hi], xb[lo:hi])
        if corr is None or corr < self.s.compatible_correlation: return False, 'different_progression'
        ap = a['RelativeProfile'] if a['IdentitySignal'] == 'conditional_field' else a['RawProfile']
        bp = b['RelativeProfile'] if b['IdentitySignal'] == 'conditional_field' else b['RawProfile']
        # Simultaneous observed deficit on actual continuing blocks, not boxes.
        left = max(ap.get('FirstSupportedDeficit') or self.n, bp.get('FirstSupportedDeficit') or self.n)
        right = min(ap.get('LastSupportedDeficit') or 0, bp.get('LastSupportedDeficit') or 0)
        if right - left + 1 < self.s.continuation_samples: return False, 'no_continuing_overlap'
        return True, 'observed_spatial_time_continuation'

    def assemble(self, branches, edge_callback=None):
        s = self.s; index = defaultdict(set); groups = []; associations = []; alternatives = {}
        order = sorted(range(len(branches)), key=lambda i: (branches[i]['Interval'][0] or 0, branches[i]['ID']))
        def store_edge(edge):
            associations.append(edge)
            if edge_callback: edge_callback(len(associations))
        for number in order:
            row = branches[number]; start, end = row['Interval']
            if row['Recognition'] in {'regional_context', 'unresolved', 'unsupported'} or not row['IdentityConnected'] or start is None: continue
            yy, xx = row['SupportMask'] // self.w, row['SupportMask'] % self.w
            keys = [(t, y, x) for t in range((start - 1) // s.index_time_samples, (end or self.n) // s.index_time_samples + 1)
                for y in range(max(0, int(yy.min()) - 2) // s.index_tile_blocks, min(self.h - 1, int(yy.max()) + 2) // s.index_tile_blocks + 1)
                for x in range(max(0, int(xx.min()) - 2) // s.index_tile_blocks, min(self.w - 1, int(xx.max()) + 2) // s.index_tile_blocks + 1)]
            possible = sorted(set.union(*(index[k] for k in keys))) if keys else []
            accepted = [g for g in possible if all(self.compatible(row, branches[i])[0] for i in groups[g])]
            if len(accepted) == 1:
                g = accepted[0]; groups[g].append(number)
                store_edge([row['ID'], f'E{g + 1:06d}', 'primary_member'])
            else:
                g = len(groups); groups.append([number])
                if len(accepted) > 1:
                    row['Flags'].append('multiple_episode_membership_ambiguous')
                    alternatives[row['ID']] = [f'E{a + 1:06d}' for a in accepted]
                    for identity in alternatives[row['ID']]: store_edge([row['ID'], identity, 'alternative_at_decision'])
            for key in keys: index[key].add(g)
        episodes = []; membership = {}
        for g, numbers in enumerate(groups):
            rows = [branches[i] for i in numbers]; identity = f'E{g + 1:06d}'
            flags = sorted({v for row in rows for v in row['Flags']})
            alt = sorted({v for row in rows for v in alternatives.get(row['ID'], [])})
            complete = all(r['Recognition'] == 'complete_episode_candidate' for r in rows) and not (set(flags) & UNCERTAINTY)
            for row in rows:
                membership[row['ID']] = {'Disposition': 'episode_member', 'EpisodeID': identity,
                    'AlternativeEpisodeIDs': alternatives.get(row['ID'], []),
                    'FinalRecognition': 'uncertain_episode_candidate' if alternatives.get(row['ID']) else row['Recognition']}
            starts = [r['Interval'][0] for r in rows]; ends = [r['Interval'][1] for r in rows]
            mask = np.unique(np.concatenate([r['SupportMask'] for r in rows]))
            topology = np.zeros(self.h * self.w, bool); topology[mask] = True
            if ndimage.label(topology.reshape(self.h, self.w))[1] > 1 and len(rows) > 1: flags.append('spatial_gap_supported_not_filled')
            episodes.append({'ID': identity, 'MemberIDs': [r['ID'] for r in rows], 'Interval': [min(starts), max(ends) if all(v is not None for v in ends) else None],
                'Recognition': 'complete_episode_candidate' if complete else 'uncertain_episode_candidate',
                'RecoveryState': 'observed_recovery' if complete else 'relative_or_unresolved',
                'SupportMask': mask, 'BranchCohorts': [r['ID'] for r in rows], 'AlternativeEpisodeIDs': alt,
                'Flags': sorted(set(flags)), 'Minima': sorted({v for r in rows for v in r['RawProfile']['Minima']}),
                'ConfirmationThrough': max((r['RawProfile'].get('ConfirmationThrough') or 0 for r in rows)) or None,
                'MeasurementReady': False, 'BurdenReady': False, 'NativeAreaMeasured': False})
        for row in branches:
            if row['ID'] not in membership:
                membership[row['ID']] = {'Disposition': row['Recognition'], 'EpisodeID': None,
                    'AlternativeEpisodeIDs': [], 'FinalRecognition': row['Recognition']}
        assert len(membership) == len(branches)
        return {'Schema': SCHEMA, 'Episodes': episodes, 'Membership': membership,
            'Associations': associations, 'SourceCandidateCount': len(branches), 'Settings': s.contract(),
            'EpisodeCountIsBiologicalTruth': False, 'MeasurementReady': False, 'BurdenReady': False}
