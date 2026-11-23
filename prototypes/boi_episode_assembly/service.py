"""Assemble saved proposals without changing originals or scientific measurements."""
from collections import OrderedDict, defaultdict
import hashlib
import numpy as np
from scipy import ndimage
from boi_joint_video_detector.numeric import correlation, strict_mean
from boi_joint_video_detector.service import patch_bank, comparisons
from .numeric import Settings, profile, reference, reference_bank, runs

SCHEMA = 'boi-episode-assembly-1'


def consensus(masks, shape):
    """All seed masks contribute; unsupported pixels are never hole-filled."""
    count = np.zeros(int(np.prod(shape)), np.uint32)
    for mask in masks:
        count[np.asarray(mask, int)] += 1
    support = np.flatnonzero(count)
    core = np.flatnonzero(count >= (len(masks) + 1) // 2)
    return core if len(core) else support, support


def spatial_evidence(raw, support, p, settings):
    n, h, w = raw.shape
    output = {'CoherentMask': [], 'Tracks': [], 'Missing': False, 'AllBranchesRecovered': False,
              'RecoveryFrame': None, 'SpatialGapPresent': False, 'BoundaryConfounded': False}
    if p.get('Reference') is None or p.get('Start') is None:
        return output
    source = raw.reshape(n, -1)
    lo = p['Start'] - 1; hi = p.get('End') or n
    ref_start = p['Reference']['First'] - 1
    active = []
    for index in support:
        x = source[:, int(index)]
        r = reference(x, ref_start, settings)
        if r is None:
            output['Missing'] = True
            continue
        below = np.isfinite(x) & (x < r['LowerBand'])
        intervals = runs(below, settings.continuation_samples)
        relevant = [(a, b) for a, b in intervals if max(a, lo) + settings.continuation_samples <= min(b, hi)]
        if not relevant:
            continue
        a, b = relevant[0]
        last = b
        for c, d in intervals:
            if c < a:
                continue
            if runs(np.isfinite(x[last:c]) & (x[last:c] >= r['LowerBand']), settings.recovery_samples):
                break
            last = max(last, d)
        returned = runs(np.isfinite(x[last:]) & (x[last:] >= r['LowerBand']), settings.recovery_samples)
        recovery = last + returned[0][0] + 1 if returned else None
        missing = bool(np.any(~np.isfinite(x[a:(recovery + settings.recovery_samples - 1) if recovery else n])))
        output['Missing'] |= missing
        active.append((int(index), a + 1, last, recovery, r['Stable']))
    if not active:
        return output
    image = np.zeros(h * w, bool); image[[r[0] for r in active]] = True; image = image.reshape(h, w)
    # Group only actual active cells; dilation is a gap diagnostic, never measured area.
    from scipy.spatial import cKDTree
    points = np.asarray([[r[0] // w, r[0] % w] for r in active])
    parent = list(range(len(active)))
    def find(i):
        while parent[i] != i:
            parent[i] = parent[parent[i]]; i = parent[i]
        return i
    for a, b in cKDTree(points).query_pairs(settings.gap_blocks + 1, p=np.inf):
        a, b = find(a), find(b)
        if a != b:
            parent[max(a, b)] = min(a, b)
    groups = defaultdict(list)
    for i, row in enumerate(active):
        groups[find(i)].append(row)
    minimum = min(settings.minimum_spatial_blocks, len(support))
    accepted = [r for group in groups.values() if len(group) >= minimum for r in group]
    output['CoherentMask'] = [r[0] for r in accepted]
    output['Tracks'] = [{'Block': r[0], 'FirstDeficit': r[1], 'LastDeficit': r[2],
                         'RecoveryFrame': r[3], 'ReferenceStable': r[4]} for r in accepted]
    output['AllBranchesRecovered'] = bool(accepted) and all(r[3] is not None and r[4] for r in accepted) and not output['Missing']
    if output['AllBranchesRecovered']:
        output['RecoveryFrame'] = max(r[3] for r in accepted)
    output['SpatialGapPresent'] = ndimage.label(image)[1] > 1 and bool(accepted)
    pre = np.mean(raw[ref_start:ref_start + settings.prestate_samples], axis=0, dtype=float)
    finite = np.isfinite(pre)
    pre_safe = np.where(finite, pre, 0.)
    gy, gx = np.gradient(pre_safe)
    gradient = np.hypot(gy, gx)
    typical = max(float(np.median(gradient[finite])) if np.any(finite) else 0., settings.numerical_floor)
    ys, xs = np.asarray(support) // w, np.asarray(support) % w
    surrounding = ndimage.binary_dilation(np.isin(np.arange(h * w), support).reshape(h, w), iterations=3)
    surrounding.ravel()[support] = False
    nearby = pre[surrounding & finite]
    if len(nearby):
        output['BoundaryConfounded'] = bool(np.median(gradient[ys, xs]) > settings.boundary_gradient_ratio * typical and
            np.median(pre[ys, xs]) < settings.boundary_level_fraction * np.median(nearby))
    return output


class Assembler:
    def __init__(self, raw, settings=None):
        self.raw = raw
        self.s = settings or Settings()
        self.n, self.h, self.w = raw.shape
        self.bank = patch_bank(raw, min(8, max(1, min(self.h, self.w) // 4)))
        self.traces = OrderedDict()

    def trace(self, mask):
        key = np.asarray(mask, np.uint16).tobytes()
        if key not in self.traces:
            self.traces[key] = strict_mean(self.raw, mask)
            if len(self.traces) > 128:
                self.traces.popitem(last=False)
        self.traces.move_to_end(key)
        return self.traces[key]

    def assess(self, item):
        s = self.s
        core, support = item['CoreMask'], item['SupportMask']
        x = self.trace(core)
        c = int(item['Anchor'])
        radius = max(2, item['Span'] // 2)
        lo, hi = max(0, c - radius), min(self.n, c + radius + 1)
        anchor = lo + int(np.argmin(np.where(np.isfinite(x[lo:hi]), x[lo:hi], np.inf)))
        # Context is outside the earliest candidate span, with half a reference
        # window of margin. This limits reference selection, never event timing.
        widest = max([item['Span']] + [int(v[1]) for v in item.get('ScaleAlternatives', [])])
        before = anchor - widest - s.prestate_samples // 2
        bank = [r for r in reference_bank(x, s) if r is not None and r['Last'] <= before]
        p = profile(x, anchor, s, bank=bank)
        region, external, field = comparisons(self.raw, core, self.bank)
        flags = list(p['Flags'])
        if item.get('Kind') == 'start_censored':
            flags.append('recording_start_censored')
        if item.get('DisplacementLikeFrames'):
            flags.append('displacement_like_evidence')
        # Pre-context scale is a conditional comparator loading, never a quiet control.
        rel = None; selected = None; shared = False; comparisons_summary = {}
        if p.get('Reference'):
            r = p['Reference']; a, b = r['First'] - 1, r['Last']
            first, end = (p.get('Start') or anchor + 1) - 1, min(self.n, (p.get('End') or self.n) + s.recovery_samples)
            for role, values in region.items():
                pre = values[a:b]
                if len(pre) != s.prestate_samples or not np.all(np.isfinite(pre)):
                    continue
                center = float(np.median(pre))
                if abs(center) < s.numerical_floor:
                    continue
                loading = r['Median'] / center
                difference = x - loading * values
                relative_bank = [q for q in reference_bank(difference, s) if q is not None and q['Last'] <= before]
                candidate = profile(difference, anchor, s, bank=relative_bank)
                raw_low = p.get('LowValue')
                comp_low = values[anchor]
                contrast = loading * (center - comp_low) if np.isfinite(comp_low) else None
                corr = correlation(x[first:end], values[first:end])
                comparisons_summary[role] = {'LoadingFromPrestate': loading,
                    'Correlation': corr, 'DropAtAnchorInputUnits': contrast,
                    'ReferenceIsVerifiedQuiet': False, 'RelativeProfile': candidate}
                if role == 'field' or selected is None:
                    selected, rel = role, candidate
                if role == 'field' and p.get('RawDrop') is not None and contrast is not None:
                    shared = bool(corr is not None and corr >= s.shared_correlation and
                                  contrast >= s.shared_contrast_fraction * p['RawDrop'])
        # A full-field cohort has no external patch and cannot become a local pocket by subtraction.
        if len(support) == self.h * self.w:
            shared = True
        spatial = spatial_evidence(self.raw, support, p, s) if not shared else {
            'CoherentMask': [], 'Tracks': [], 'Missing': False, 'AllBranchesRecovered': False,
            'RecoveryFrame': None, 'SpatialGapPresent': False, 'BoundaryConfounded': False}
        if spatial['Missing']:
            flags.append('spatial_observations_missing')
        if spatial['SpatialGapPresent']:
            flags.append('spatial_gap_supported_not_filled')
        if spatial['BoundaryConfounded']:
            flags.append('boundary_geometry_unresolved')
        if len(support) < s.minimum_spatial_blocks:
            flags.append('limited_spatial_observability')
        if spatial['AllBranchesRecovered'] and p.get('End') is not None:
            p['End'] = max(p['End'], spatial['RecoveryFrame'])
            p['ConfirmationThrough'] = p['End'] + s.recovery_samples - 1
        elif p.get('End') is not None and not shared:
            flags.append('continuing_branch_or_spatial_clearance_unresolved')
            p['State'] = 'unresolved'
        state = p['State']
        if state != 'observed_recovery' and rel and rel.get('End') is not None and p.get('RawDrop', 0) > 0:
            state = 'relative_recovery'
            flags.append('regional_reference_dependency')
        severe = any(v in flags for v in ['fixed_cohort_observations_missing', 'spatial_observations_missing',
            'boundary_geometry_unresolved', 'displacement_like_evidence', 'limited_spatial_observability',
            'short_recovery_split_merge_ambiguous', 'prestate_unavailable', 'prestate_drifting',
            'continuing_branch_or_spatial_clearance_unresolved'])
        coherent = len(spatial['CoherentMask']) >= min(s.minimum_spatial_blocks, len(support))
        if shared:
            recognition = 'regional_context'
        elif p.get('Start') is None:
            recognition = 'unresolved' if state != 'unsupported' else 'unsupported'
        elif coherent and state == 'observed_recovery' and not severe:
            recognition = 'complete_episode_candidate'
        else:
            recognition = 'uncertain_episode_candidate'
        end = p.get('End') or (rel.get('End') if rel else None)
        start = p.get('Start') or (rel.get('Start') if rel else None)
        return {'ID': item['ID'], 'OriginalRecognition': item.get('OriginalRecognition'),
            'CoreMask': np.asarray(core, np.uint16), 'SupportMask': np.asarray(support, np.uint16),
            'CoreHash': hashlib.sha256(np.asarray(core, np.uint16).tobytes()).hexdigest(),
            'SeedCount': item.get('SeedCount', 1), 'ScaleAlternatives': item.get('ScaleAlternatives', []),
            'Anchor': anchor + 1, 'RawProfile': p, 'RegionalComparisons': comparisons_summary,
            'SelectedRelativeComparison': selected, 'RelativeProfile': rel,
            'SpatialEvidence': spatial, 'Recognition': recognition, 'RecoveryState': state,
            'Interval': [start, end], 'Flags': sorted(set(flags)),
            'MeasurementReady': False, 'BurdenReady': False, 'NativeAreaMeasured': False}

    def compatible(self, a, b):
        if a['Recognition'] in {'regional_context', 'unsupported', 'unresolved'} or b['Recognition'] in {'regional_context', 'unsupported', 'unresolved'}:
            return False, 'nonconnecting_disposition'
        if a['Interval'][0] is None or b['Interval'][0] is None:
            return False, 'onset_unresolved'
        lo = max(a['Interval'][0], b['Interval'][0]) - 1
        hi = min(a['Interval'][1] or self.n, b['Interval'][1] or self.n)
        if hi - lo < self.s.continuation_samples:
            return False, 'separated_or_no_supported_overlap'
        common = len(np.intersect1d(a['SupportMask'], b['SupportMask'], assume_unique=True))
        # Similar raw trajectories are checked for every member, not just a graph bridge.
        xa, xb = self.trace(a['CoreMask']), self.trace(b['CoreMask'])
        corr = correlation(xa[lo:hi], xb[lo:hi])
        same_core = common >= .6 * min(len(a['SupportMask']), len(b['SupportMask']))
        if not same_core and (corr is None or corr < self.s.compatible_correlation):
            return False, 'distinct_signal_progression'
        ra, rb = a['RawProfile'].get('Reference'), b['RawProfile'].get('Reference')
        if not ra or not rb:
            return False, 'reference_compatibility_unresolved'
        both = (np.isfinite(xa[lo:hi]) & np.isfinite(xb[lo:hi]) &
                (xa[lo:hi] < ra['LowerBand']) & (xb[lo:hi] < rb['LowerBand']))
        if not runs(both, self.s.continuation_samples):
            return False, 'no_common_continuing_depression'
        return True, 'same_core' if same_core else 'compatible_branch'

    def assemble(self, branches, edge_callback=None):
        """Spatial/time index plus whole-group compatibility prevents union chaining."""
        tile, tick = self.s.index_tile_blocks, self.s.index_time_samples
        index = defaultdict(set); groups = []; primary = {}; edges = []
        order = sorted(range(len(branches)), key=lambda i: (branches[i]['Interval'][0] or 0, branches[i]['ID']))
        for number in order:
            row = branches[number]
            start, end = row['Interval']
            if row['Recognition'] in {'regional_context', 'unsupported', 'unresolved'} or start is None:
                continue
            mask = row['SupportMask']; yy, xx = mask // self.w, mask % self.w
            keys = [(t, y, x) for t in range((start - 1) // tick, (end or self.n) // tick + 1)
                    for y in range(max(0, int(yy.min()) - 2) // tile, min(self.h - 1, int(yy.max()) + 2) // tile + 1)
                    for x in range(max(0, int(xx.min()) - 2) // tile, min(self.w - 1, int(xx.max()) + 2) // tile + 1)]
            possible = sorted(set.union(*(index[k] for k in keys))) if keys else []
            accepted = []
            for g in possible:
                members = groups[g]
                local_link = False; compatible = True
                for other in members:
                    previous = branches[other]
                    a, b = row['SupportMask'], previous['SupportMask']
                    ay, ax = a // self.w, a % self.w; by, bx = b // self.w, b % self.w
                    near = (max(int(ay.min()), int(by.min())) <= min(int(ay.max()), int(by.max())) + 2 and
                            max(int(ax.min()), int(bx.min())) <= min(int(ax.max()), int(bx.max())) + 2)
                    match, reason = self.compatible(row, previous)
                    if not match:
                        compatible = False; break
                    local_link |= near
                if compatible and local_link:
                    accepted.append(g)
            if len(accepted) == 1:
                g = accepted[0]; groups[g].append(number)
                edges.append([row['ID'], branches[groups[g][0]]['ID'], 'whole_group_compatible'])
                if edge_callback:
                    edge_callback(len(edges))
            else:
                g = len(groups); groups.append([number])
                if len(accepted) > 1:
                    row['Flags'].append('multiple_episode_membership_ambiguous')
            primary[number] = g
            for key in keys:
                index[key].add(g)
        episodes = []; membership = {}
        for g, members in enumerate(groups):
            rows = [branches[i] for i in members]
            identity = f'E{g + 1:06d}'
            for row in rows:
                membership[row['ID']] = {'Disposition': 'episode_member', 'EpisodeID': identity}
            flags = sorted(set(v for row in rows for v in row['Flags']))
            observed = all(row['RecoveryState'] == 'observed_recovery' for row in rows)
            start = min(row['Interval'][0] for row in rows)
            ends = [row['Interval'][1] for row in rows]
            end = max(ends) if all(v is not None for v in ends) else None
            mask = np.unique(np.concatenate([row['SupportMask'] for row in rows]))
            topology = np.zeros(self.h * self.w, bool); topology[mask] = True
            if ndimage.label(topology.reshape(self.h, self.w))[1] > 1 and len(rows) > 1:
                flags = sorted(set(flags + ['spatial_gap_supported_not_filled']))
            complete = observed and all(row['Recognition'] == 'complete_episode_candidate' for row in rows)
            episodes.append({'ID': identity, 'MemberIDs': [row['ID'] for row in rows],
                'Interval': [start, end], 'RecoveryState': 'observed_recovery' if observed else 'relative_or_unresolved',
                'Recognition': 'complete_episode_candidate' if complete else 'uncertain_episode_candidate',
                'SupportMask': mask, 'BranchCohorts': [row['ID'] for row in rows],
                'Minima': sorted(set(v for row in rows for v in row['RawProfile']['Minima'])),
                'Flags': flags, 'ConfirmationThrough': max((row['RawProfile'].get('ConfirmationThrough') or 0 for row in rows)) or None,
                'AlternativeShortSeparators': sorted({tuple(v) for row in rows for v in row['RawProfile']['ShortReturns']}),
                'MeasurementReady': False, 'BurdenReady': False, 'NativeAreaMeasured': False})
        for row in branches:
            if row['ID'] not in membership:
                membership[row['ID']] = {'Disposition': row['Recognition'], 'EpisodeID': None}
        assert len(membership) == len(branches)
        return {'Schema': SCHEMA, 'Episodes': episodes, 'Membership': membership,
                'Associations': edges, 'Settings': self.s.contract(),
                'SourceCandidateCount': len(branches), 'EpisodeCountIsBiologicalTruth': False,
                'MeasurementReady': False, 'BurdenReady': False}
