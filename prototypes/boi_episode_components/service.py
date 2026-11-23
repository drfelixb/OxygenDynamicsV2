"""Independent local/regional evidence followed by a read-only reference audit."""
import hashlib
import json
from collections import defaultdict
import numpy as np
from scipy import ndimage
from scipy.spatial import cKDTree
from boi_episode_identity.service import Assembler as PreviousAssembler
from boi_joint_video_detector.numeric import correlation
from boi_joint_video_detector.numeric import roughness
from boi_joint_video_detector.service import comparisons
from .numeric import Settings, phase_hypotheses, observed_context, audit_references, runs, diagnostic_scale

SCHEMA = 'boi-episode-components-1'


def clean(value):
    if isinstance(value, dict): return {k: clean(v) for k, v in value.items()}
    if isinstance(value, (list, tuple)): return [clean(v) for v in value]
    if hasattr(value, 'tolist'): return clean(value.tolist())
    if isinstance(value, float) and not np.isfinite(value): return None
    return value


def fingerprint(local, regional, spatial):
    return hashlib.sha256(json.dumps(clean([local, regional, spatial]),
        sort_keys=True, separators=(',', ':'), allow_nan=False).encode()).hexdigest()


class Assembler(PreviousAssembler):
    def __init__(self, raw, settings=None):
        super().__init__(raw, settings or Settings())

    def spatial_observations(self, support, core, p, anchor, field=None, scale_context=None):
        """Attempt observations even when onset or a scientific reference is absent."""
        s = self.s
        result = {'Attempted': True, 'AssessmentState': 'unresolved', 'UnavailableReason': None,
            'CoherentMask': [], 'Tracks': [], 'ChildCohorts': [], 'Missing': False,
            'AllBranchesRecovered': False, 'RecoveryFrame': None, 'SpatialGapPresent': False,
            'IdentityConnected': False, 'Signal': 'raw' if field is None else 'conditional_comparison',
            'NativeAreaMeasured': False, 'TemporalSpatialLinks': 0,
            'ContextFrames': None, 'ContextMeaning': 'diagnostic_only',
            'DiagnosticContextStable': bool(p.get('DetectionContext') and p['DetectionContext']['Stable']),
            'SelectedPhaseAvailable': bool(p.get('AnchorConnected'))}
        values = self.raw.reshape(self.n, -1)[:, support].astype(float)
        if not np.any(np.isfinite(values)):
            result.update(AssessmentState='unavailable', UnavailableReason='all_source_observations_missing', Missing=True)
            return result
        context = p.get('DetectionContext')
        if context is None:
            # This fallback records visible changes, not a claimed pre-event state.
            stop = max(s.continuation_samples, anchor - s.prestate_samples)
            context = {'First': max(1, stop - s.prestate_samples + 1), 'Last': stop}
            result['ContextMeaning'] = 'anchor_context_no_predecline_claim'
        first, last = context['First'] - 1, context['Last']
        result['ContextFrames'] = [first + 1, last]
        loading = np.zeros(len(support))
        if field is not None:
            if scale_context is None:
                result.update(AssessmentState='unavailable', UnavailableReason='conditional_scale_context_unavailable')
                return result
            a, b = scale_context['First'] - 1, scale_context['Last']
            other = field[a:b]; pre = values[a:b]
            if not np.all(np.isfinite(other)) or abs(float(np.median(other))) <= s.numerical_floor:
                result.update(AssessmentState='unavailable', UnavailableReason='conditional_comparison_observations_missing')
                return result
            loading = np.median(pre, axis=0) / float(np.median(other))
            values -= field[:, None] * loading[None]
        pre = values[first:last]
        if len(pre) < s.continuation_samples:
            result.update(AssessmentState='unavailable', UnavailableReason='diagnostic_context_too_short')
            return result
        finite = np.all(np.isfinite(pre), axis=0)
        safe = np.where(np.isfinite(pre), pre, 0.)
        level = np.median(safe, axis=0)
        observed_variation = 1.4826 * np.median(np.abs(safe - level[None]), axis=0)
        scale = np.maximum(np.maximum(self.noise.ravel()[support], observed_variation), s.numerical_floor)
        if field is not None:
            # Conditional short-lag scale, without estimating a target trend.
            diff = np.diff(safe, axis=0); center = np.median(diff, axis=0)
            scale = np.maximum(1.4826 * np.median(np.abs(diff - center[None]), axis=0) / np.sqrt(2.),
                np.maximum(s.numerical_floor, np.max(np.abs(safe), axis=0) * s.relative_floor_fraction))
        half = len(pre) // 2
        stable = finite & (np.abs(np.median(safe[:half], axis=0) -
            np.median(safe[half:], axis=0)) <= s.allowance_multiplier * scale)
        lower = level - s.allowance_multiplier * scale
        below = np.isfinite(values) & (values < lower[None])
        lo = max(0, (p.get('Start') or p.get('FirstSupportedDeficit') or anchor + 1) - 1)
        hi = p.get('ProvisionalEnd') or p.get('End') or min(self.n, anchor + s.prestate_samples + 1)
        if 'recording_end_unrecovered' in p.get('Flags', []): hi = self.n
        active = []; columns = []
        for j, index in enumerate(support):
            if not finite[j]: result['Missing'] = True; continue
            periods = runs(below[:, j], s.continuation_samples)
            relevant = [(a, b) for a, b in periods if max(a, lo) + s.continuation_samples <= min(b, hi)]
            if not relevant: continue
            a, end = relevant[0]; tail = end
            for c, d in periods:
                if c < a: continue
                if runs(np.isfinite(values[tail:c, j]) & (values[tail:c, j] >= lower[j]), s.recovery_samples): break
                tail = max(tail, d)
            returns = runs(np.isfinite(values[tail:, j]) & (values[tail:, j] >= lower[j]), s.recovery_samples)
            recovery = tail + returns[0][0] + 1 if returns else None
            stop = min(self.n, (recovery + s.recovery_samples - 1) if recovery else self.n)
            absent = bool(np.any(~np.isfinite(values[a:stop, j])))
            result['Missing'] |= absent
            active.append({'Block': int(index), 'FirstDeficit': a + 1, 'LastDeficit': tail,
                'RecoveryFrame': recovery, 'ReferenceStable': bool(stable[j]),
                'ReferenceMedian': float(level[j]), 'LowerBand': float(lower[j]),
                'ReferenceAllowance': float(scale[j]), 'ConditionalLoading': float(loading[j]),
                'Missing': absent})
            columns.append(j)
        result['Tracks'] = active
        result['AssessmentState'] = 'observed' if active else 'observed_no_supported_deficit'
        if not active: return result
        points = np.asarray([[r['Block'] // self.w, r['Block'] % self.w] for r in active])
        parent = list(range(len(active)))
        def find(i):
            while parent[i] != i: parent[i] = parent[parent[i]]; i = parent[i]
            return i
        for a, b in cKDTree(points).query_pairs(s.gap_blocks + 1, p=np.inf):
            both = below[lo:hi, columns[a]] & below[lo:hi, columns[b]]
            if not runs(both, s.continuation_samples): continue
            aa, bb = find(a), find(b)
            if aa != bb: parent[max(aa, bb)] = min(aa, bb)
            result['TemporalSpatialLinks'] += 1
        groups = defaultdict(list)
        for i in range(len(active)): groups[find(i)].append(i)
        core_set = set(int(v) for v in core)
        anchor_columns = {i for i, r in enumerate(active) if r['Block'] in core_set and
            np.any(below[max(0, anchor - s.continuation_samples):min(self.n, anchor + s.continuation_samples + 1), columns[i]])}
        kept = []
        for members in groups.values():
            connected = bool(set(members) & anchor_columns)
            result['ChildCohorts'].append({'Blocks': [active[i]['Block'] for i in members],
                'AnchorConnected': connected, 'FirstDeficit': min(active[i]['FirstDeficit'] for i in members),
                'LastDeficit': max(active[i]['LastDeficit'] for i in members)})
            if connected and len(members) >= min(s.minimum_spatial_blocks, len(support)): kept += members
        result['CoherentMask'] = [active[i]['Block'] for i in kept]
        result['IdentityConnected'] = bool(kept) and bool(p.get('AnchorConnected'))
        topology = np.zeros(self.h * self.w, bool); topology[result['CoherentMask']] = True
        result['SpatialGapPresent'] = bool(kept) and ndimage.label(topology.reshape(self.h, self.w))[1] > 1
        result['AllBranchesRecovered'] = bool(kept) and len(kept) == len(active) and result['DiagnosticContextStable'] and not result['Missing'] and all(
            r['RecoveryFrame'] is not None and r['ReferenceStable'] for r in active)
        if result['AllBranchesRecovered']: result['RecoveryFrame'] = max(r['RecoveryFrame'] for r in active)
        return result

    def assess(self, item, audit_mode='both'):
        s = self.s; core, support = item['CoreMask'], item['SupportMask']; c = int(item['Anchor'])
        x = self.trace(core); kind = item.get('Kind', 'cycle')
        raw = phase_hypotheses(x, c, item['Span'], s, kind)
        around, external, _ = comparisons(self.raw, core, self.bank)
        channels = {'raw': raw}; comparisons_summary = {}; values_by_channel = {'raw': x}
        scale_context = raw['Primary'].get('DetectionContext')
        scale_context_origin = 'raw_primary_detection_context'
        if scale_context is not None and not scale_context.get('Stable'):
            stable_alternatives = [p['DetectionContext'] for p in raw['Alternatives']
                if p.get('DetectionContext') and p['DetectionContext']['Stable'] and
                p['DetectionContext']['Last'] < (raw['Primary'].get('Start') or c + 1)]
            if stable_alternatives:
                scale_context = stable_alternatives[0]
                scale_context_origin = 'retained_parent_detection_context'
        if scale_context is None:
            earliest = min([e['FirstEvidence'] - 1 for e in item.get('SeedEvidence', [])] or [max(0, c - item['Span'])])
            scale_context = observed_context(x, earliest, float(np.median(self.noise.ravel()[core])), s)
            scale_context_origin = 'source_seed_precontext_no_scientific_reference'
        shared = len(support) == self.h * self.w; raw_p = raw['Primary']
        lo = max(0, (raw_p.get('Start') or c + 1 - max(item['Span'], s.prestate_samples)) - 1)
        hi = min(self.n, (raw_p.get('ProvisionalEnd') or c + max(item['Span'], s.prestate_samples)) + s.recovery_samples)
        for role in ['near', 'far', 'field']:
            comp = around[role]; loading = None; available = False; reason = 'diagnostic_scale_context_unavailable'
            if scale_context is not None and scale_context.get('Stable'):
                a, b = scale_context['First'] - 1, scale_context['Last']
                target_pre, other_pre = x[a:b], comp[a:b]
                if np.all(np.isfinite(target_pre)) and np.all(np.isfinite(other_pre)) and len(other_pre) >= s.continuation_samples and abs(float(np.median(other_pre))) > s.numerical_floor:
                    loading = max(0., float(np.median(target_pre)) / float(np.median(other_pre)))
                    available = True; reason = None
            corr = correlation(x[lo:hi], comp[lo:hi])
            drop = None
            if available:
                data = x - loading * comp
                q = phase_hypotheses(data, c, item['Span'], s, kind)
                channels[role] = q; values_by_channel[role] = data
                drop = loading * (float(np.median(comp[a:b])) - float(comp[c])) if np.isfinite(comp[c]) else None
                if role == 'field' and corr is not None and drop is not None and raw_p.get('RawDrop') is not None:
                    shared |= corr >= s.shared_correlation and drop >= s.shared_contrast_fraction * raw_p['RawDrop']
            comparisons_summary[role] = {'Assessed': True, 'SignalAvailable': bool(np.any(np.isfinite(comp))),
                'ConditionalScaleAvailable': available, 'UnavailableReason': reason, 'Loading': loading,
                'FitFrames': [scale_context['First'], scale_context['Last']] if available else None,
                'ScaleContextOrigin': scale_context_origin,
                'Correlation': corr, 'ComparatorDrop': drop, 'PatchIDs': external[role],
                'VerifiedQuiet': False, 'InteriorFitSamples': 0, 'DriftDegrees': 0,
                'Profile': channels[role]['Primary'] if available else None}
        field_evidence = comparisons_summary['field']
        regional_response = bool(shared or (field_evidence['ComparatorDrop'] is not None and
            field_evidence['ComparatorDrop'] > s.allowance_multiplier *
            max(s.numerical_floor, (field_evidence['Loading'] or 0.) * diagnostic_scale(around['field'], s))))
        relative_role = next((r for r in ['field', 'near', 'far'] if r in channels and channels[r]['Primary']['AnchorConnected']), None)
        chosen_role = 'raw'
        if relative_role and (regional_response or not raw_p.get('End') or not raw_p['AnchorConnected']): chosen_role = relative_role
        chosen = channels[chosen_role]['Primary']
        spatial = self.spatial_observations(support, core, chosen, c,
            field=around[chosen_role] if chosen_role != 'raw' else None,
            scale_context=scale_context if chosen_role != 'raw' else None)
        geometry = self.geometry(support, chosen, c)
        flags = list(chosen['Flags'])
        if kind == 'start_censored': flags.append('recording_start_censored')
        if item.get('DisplacementLikeFrames'): flags.append('displacement_like_evidence')
        if geometry['BoundaryConfounded']: flags.append('boundary_geometry_unresolved')
        if len(support) < s.minimum_spatial_blocks: flags.append('limited_spatial_observability')
        if spatial['Missing']: flags.append('spatial_observations_missing')
        if spatial['SpatialGapPresent']: flags.append('spatial_gap_supported_not_filled')
        if not spatial['IdentityConnected']: flags.append('spatial_identity_unresolved')
        if not spatial['AllBranchesRecovered']: flags.append('continuing_branch_or_spatial_clearance_unresolved')
        if channels[chosen_role]['Overflow']: flags.append('episode_alternative_capacity_unresolved')
        if chosen_role != 'raw':
            flags.append('regional_reference_dependency')
            a, b = comparisons_summary[chosen_role]['FitFrames']
            if chosen.get('Start') is not None and max(a, chosen['Start']) <= min(b, chosen.get('ProvisionalEnd') or self.n):
                flags.append('conditional_context_overlaps_episode')
        # Spatial completion extends detection timing before the measurement audit.
        if spatial['AllBranchesRecovered'] and chosen.get('End'):
            proposed = max(chosen['End'], spatial['RecoveryFrame'])
            data = values_by_channel[chosen_role][proposed - 1:proposed - 1 + s.recovery_samples]
            if len(data) == s.recovery_samples and np.all(np.isfinite(data)) and np.all(data >= chosen['LowerBand']):
                chosen['CoreOnlyReturnBeforeSpatialClearance'] = chosen['End']
                chosen['End'] = proposed; chosen['AbsoluteReturn'] = proposed
                chosen['ProvisionalEnd'] = proposed; chosen['ConfirmationThrough'] = proposed + s.recovery_samples - 1
            else:
                chosen['State'] = 'unresolved'; chosen['End'] = None; chosen['AbsoluteReturn'] = None
                chosen['ConfirmationThrough'] = None; flags.append('continuing_branch_or_spatial_clearance_unresolved')
        connected = chosen['AnchorConnected'] and spatial['IdentityConnected'] and not channels[chosen_role]['Overflow']
        field_local = bool('field' in channels and channels['field']['Primary']['AnchorConnected'])
        regional_only = bool(shared and not field_local and (len(support) == self.h * self.w or comparisons_summary['field']['ConditionalScaleAvailable']))
        # This source's local assessment was executed before regional-only disposition.
        if regional_only: connected = False
        start = chosen.get('Start') if connected else None
        end = (chosen.get('End') or chosen.get('ProvisionalEnd')) if connected else None
        if 'recording_end_unrecovered' in flags: end = None
        if kind == 'start_censored': start = None
        severe = {'fixed_cohort_observations_missing','spatial_observations_missing','boundary_geometry_unresolved',
            'displacement_like_evidence','limited_spatial_observability','short_recovery_split_merge_ambiguous',
            'continuing_branch_or_spatial_clearance_unresolved','spatial_identity_unresolved',
            'diagnostic_detection_context_unavailable','diagnostic_detection_context_changing',
            'episode_alternative_capacity_unresolved','recording_start_censored','conditional_context_overlaps_episode'}
        complete = connected and chosen_role == 'raw' and chosen['State'] == 'observed_recovery' and spatial['AllBranchesRecovered'] and not (set(flags) & severe)
        recognition = ('regional_context' if regional_only else 'complete_episode_candidate' if complete else
            'uncertain_episode_candidate' if connected else 'unresolved')
        recovery = ('regional_context' if regional_only else 'relative_recovery' if connected and chosen_role != 'raw' and chosen.get('End') else
            'observed_recovery' if complete else 'unresolved')
        hypotheses = []
        for role, group in channels.items():
            for j, p in enumerate([group['Primary']] + group['Alternatives']):
                if p['AnchorConnected']:
                    hypotheses.append({'ID': f"{item['ID']}:{role}:{j + 1}", 'Channel': role, 'Profile': p,
                        'RetainedAlternative': role != chosen_role or j != 0})
        local = {'Schema': 'boi-local-episode-evidence-1', 'SourceCandidateID': item['ID'],
            'IdentityConnected': bool(connected), 'SelectedChannel': chosen_role,
            'SelectedHypothesisID': f"{item['ID']}:{chosen_role}:1" if chosen['AnchorConnected'] else None,
            'Interval': [start, end], 'Recognition': recognition, 'RecoveryState': recovery,
            'Hypotheses': hypotheses, 'ChannelInterpretationCounts': {r: q['ObservedInterpretations'] for r, q in channels.items()},
            'CapacityUnresolved': channels[chosen_role]['Overflow'], 'SpatialAssessmentAttempted': True,
            'MeasurementReferenceUsed': False, 'MeasurementReady': False, 'BurdenReady': False}
        regional = {'Schema': 'boi-regional-change-evidence-1', 'Assessed': True, 'SharedChangeObserved': bool(shared),
            'RegionalResponseObserved': regional_response,
            'RegionalOnly': regional_only, 'LocalEpisodeCoexists': bool(regional_response and connected),
            'State': 'regional_with_local_episode' if regional_response and connected else 'regional_only' if regional_only else
                'shared_change_local_unresolved' if regional_response else 'regional_change_not_established',
            'Comparisons': comparisons_summary, 'LocalAssessmentExecutedBeforeDisposition': True,
            'SupportFractionOfObservedField': len(support) / (self.h * self.w),
            'ExtentIsValidatedTissueFraction': False}
        digest = fingerprint(local, regional, spatial)
        audits = []
        for role, group in channels.items():
            records = [(h['ID'], h['Profile']) for h in hypotheses if h['Channel'] == role]
            audits.extend(audit_references(values_by_channel[role], records, s, audit_mode)['Hypotheses'])
        audit = {'Schema': 'boi-measurement-reference-audit-1', 'Mode': audit_mode, 'Hypotheses': audits,
            'ScientificReferenceAccepted': False, 'InfluencesDetection': False,
            'ReviewedScientificReference': 'not_loaded_into_detector', 'MeasurementReady': False, 'BurdenReady': False}
        assert fingerprint(local, regional, spatial) == digest
        return {'ID': item['ID'], 'CoreMask': np.asarray(core, np.uint16), 'SupportMask': np.asarray(support, np.uint16),
            'CoreHash': hashlib.sha256(np.asarray(core, np.uint16).tobytes()).hexdigest(),
            'SeedCount': item.get('SeedCount', 1), 'SeedIDs': item.get('SeedIDs', []), 'SeedEvidence': item.get('SeedEvidence', []),
            'SourceAnchor': c + 1, 'Anchor': c + 1, 'SourceSpan': item['Span'], 'ScaleAlternatives': item.get('ScaleAlternatives', []),
            'OriginalRecognition': item.get('OriginalRecognition'), 'RawProfile': raw_p,
            'RegionalComparisons': comparisons_summary, 'RelativeProfile': channels[relative_role]['Primary'] if relative_role else None,
            'SelectedRelativeComparison': relative_role, 'SpatialEvidence': spatial, 'GeometryEvidence': geometry,
            'LocalEpisode': local, 'RegionalChange': regional, 'MeasurementReferenceAudit': audit,
            'DetectionFingerprint': digest, 'ReferenceAuditIndependenceChecked': True,
            'IdentityConnected': bool(connected), 'IdentitySignal': 'raw' if chosen_role == 'raw' else 'conditional_' + chosen_role,
            'Recognition': recognition, 'RecoveryState': recovery, 'Interval': [start, end], 'Flags': sorted(set(flags)),
            'OnsetBracket': chosen.get('OnsetBracket'), 'RecoveryBracket': chosen.get('RecoveryBracket'),
            'ChannelAssessments': 4, 'HypothesisAssessments': len(hypotheses), 'ReferenceWindowAssessments': 2 * len(hypotheses),
            'MeasurementReady': False, 'BurdenReady': False, 'NativeAreaMeasured': False}

    def compatible(self, a, b):
        if not a['IdentityConnected'] or not b['IdentityConnected']: return False, 'identity_unresolved'
        lo = max(a['Interval'][0] or 1, b['Interval'][0] or 1) - 1
        hi = min(a['Interval'][1] or self.n, b['Interval'][1] or self.n)
        if hi - lo < self.s.continuation_samples: return False, 'separated_or_recovered'
        aa, bb = a['SpatialEvidence']['CoherentMask'], b['SpatialEvidence']['CoherentMask']
        if not aa or not bb: return False, 'spatial_identity_unresolved'
        pa = np.asarray([[v // self.w, v % self.w] for v in aa]); pb = np.asarray([[v // self.w, v % self.w] for v in bb])
        if np.min(cKDTree(pa).query(pb, k=1, p=np.inf)[0]) > self.s.gap_blocks + 1: return False, 'unsupported_spatial_gap'
        corr = correlation(self.trace(a['CoreMask'])[lo:hi], self.trace(b['CoreMask'])[lo:hi])
        if corr is None or corr < self.s.compatible_correlation: return False, 'different_local_progression'
        ap = a['RawProfile'] if a['IdentitySignal'] == 'raw' else a['RelativeProfile']
        bp = b['RawProfile'] if b['IdentitySignal'] == 'raw' else b['RelativeProfile']
        left = max(ap.get('FirstSupportedDeficit') or self.n, bp.get('FirstSupportedDeficit') or self.n)
        right = min(ap.get('LastSupportedDeficit') or 0, bp.get('LastSupportedDeficit') or 0)
        if right - left + 1 < self.s.continuation_samples: return False, 'no_common_continuing_depression'
        return True, 'observed_local_spatial_time_continuation'

    def assemble(self, branches, edge_callback=None):
        result = super().assemble(branches, edge_callback)
        result['Schema'] = SCHEMA
        result['MeasurementReferenceInfluencesMembership'] = False
        result['RegionalAndLocalCanCoexist'] = True
        return result
