# Detector preview: onset placement and sustained recovery

9 November 2026. Approved milestone POCKET-VIDEO-DETECTOR-05. Owner: Codex (root), without delegation. The researcher said “do that” after the recommendation to address onset placement and sustained recovery before using automatic timings for burden. That confirms the direction. The researcher subsequently approved these bounded work items and limits. The milestone is delivered and stopped; see the delivery record below.

## Practical outcome

Show whether the prototype can place the beginning of the actual decline and distinguish a returning signal from sustained recovery. Keep a recognizable candidate available when its timing or measurement reference remains unresolved. Compare complete episodes with the saved videos, without asking the researcher to label each second again.

The [previous two-recording revision](BOI_VIDEO_CONTEXT_REVISION_RESULTS.md) is delivered and stopped. Its code, frozen configuration, cards, hypotheses and scientific inputs are protected. This is an additional experimental boundary assessment, with no production adoption or recalculated burden.

## Problems to address

| Problem | Required behaviour |
| --- | --- |
| Many onset splits fit a flat plateau equally well; the current method chooses the earliest. | Locate supported departure into decline. Retain uncertainty when the turn cannot be distinguished, instead of treating an arbitrary early split as a precise onset. |
| An earlier decline can be included in a later episode's onset fit. | Distinguish preceding activity, intervening recovery and the target decline in full context. Retain linked-episode uncertainty when separation is unsupported. |
| A five-frame median can pass while individual samples remain low. | Assess persistence and immediate relapse using the observed trajectory, carrying fluctuations and missing data into uncertainty. A successful median alone does not establish sustained recovery. |
| The return tolerance can be large relative to the event's drop. | Assess remaining deficit relative to the observed drop as well as variation. Large variation should increase uncertainty rather than silently broaden the meaning of recovery. |
| Raw, regional and additional local signal can return at different times. | Report their return evidence separately. Use the existing qualified regional comparison only where it was supported; preserve uncertainty elsewhere. |
| The diagnostic cohort and original reviewed ROI differ. | Show their saved traces with their identities and distinguish a rule change from a footprint effect. Never transfer a diagnostic cohort's reference or timing into reviewed measurements. |

The recovery clarification from the walkthrough must remain explicit: the existing rule requires both rise from the trough and return toward the turning level. FB2413's 852–856 median is close to its turning level despite its wide return tolerance. FB2412's 173–177 median retains about 38% of its raw drop. Both five-frame windows include two samples below their respective combined thresholds. Those readouts describe the frozen diagnostic cohorts, not the reviewed native-ROI measurements.

## Proposed implementation

1. **Assess the full turn into decline.** Compare a stable or recovering preceding trajectory, a decline and the following return using a low-complexity segmented trajectory model. Require observed decline evidence adjoining the candidate turn. Use the existing trough/proposal neighbourhood and fixed cohort; do not force reviewed frame numbers into the fit. Distinguish similar-fit boundaries from an identifiable turn. Report a range or an unresolved boundary when several interpretations remain supported. No extrapolated preceding trajectory becomes a scientific amplitude reference.

2. **Separate return from sustained recovery.** Retain the old return window for comparison. Add observed deficit closure, persistence of the returning state and evidence of immediate renewed decline. A single high sample or a favourable five-frame median must not establish sustained recovery. Explicitly qualify unavailable post-event data, gaps, motion and continued trends. Report return toward the observed preceding state separately from evidence for a stable recovered baseline; the latter stays unresolved when the pre-event measurement reference is unresolved.

3. **Hold the spatial and regional experiment fixed.** Reuse archived hypotheses, masks, sample-rate authority, quality flags and the existing comparator roles/regional components. Assess raw boundaries and, where the frozen comparison supports it, additional local return separately. Preserve the previous recognition states alongside new boundary assessments. This isolates the boundary change; it does not reselect comparison patches, refit a new background model or create new spatial proposals. Output-changing spatial or regional revisions are outside this milestone.

4. **Freeze before recording evaluation.** Select and record loss penalties, variation estimates and persistence settings using the constructed cases below. These are experimental engineering choices within this scope. Freeze one configuration before the two-window comparison; report discrepancies without tuning to the familiar recordings. Precise timing and measurement adoption remain subject to later scientific review.

## Work items and acceptance

| Item | Work | Acceptance evidence |
| --- | --- | --- |
| VBOUND-01 | Add an isolated onset assessment with stable/recovering preceding states and explicit boundary uncertainty. | Constructed known-onset cases expose plateau ambiguity and prevent borrowing an earlier decline. Recovery-only controls do not acquire a new dip. The existing prototype and scientific routines remain unchanged. |
| VBOUND-02 | Add separate first-return, sustained-return and unresolved-recovery evidence. | Constructed partial-return, spike and relapse cases do not become fully recovered solely through a median. Observed sustained return remains detectable with fluctuations; raw/local differences and unavailable data remain explicit. |
| VBOUND-03 | Apply one frozen assessment to the same two windows and deliver two comparison cards plus a short report. | Preserve all archived identities/masks and previous assessments. Independently replay selected onset costs, closure/persistence decisions and source-trace identities. Show old/new timings and every unresolved case. Verify hashes, resources and presentation. |

Use FB2413 frames **608–1114** and FB2412 frames **5–839**. Reuse the 30,108 and 42,624 archived hypotheses, respectively; these include overlapping alternatives and are not event counts. The four displayed cohorts stay fixed: FB2413 IDs 21173 (later) and 15040 (earlier); FB2412 IDs 2763 (core) and 2348 (wider). This prevents apparent improvement through selecting a more convenient match.

For the original-ROI context, reuse the existing `SavedTraceEvidence.mat`, `Events.json` and footprint mappings in `reference-validation/boi-pattern-discovery-20261105/recordings/FB2413/` and `FB2412/`. The saved arrays include raw and corrected traces and footprint identities. Only the two named target events are displayed. These traces are post-inference comparisons, not fitting labels. If an exact identity cannot be verified from existing saved data, expose that gap and omit that overlay; no new movie decoding is authorized.

## Ten constructed checks

1. Flat baseline followed by a localized dip: onset must not become the beginning of an arbitrarily long plateau.
2. Gradual decline after stable context: retain supported onset uncertainty without discarding the early falling portion.
3. Renewed dip during continuing recovery: retain the turn and unresolved measurement reference.
4. Earlier activity followed by a later dip: prevent borrowing the earlier decline; retain linked status if there is no supported separation.
5. Continuing recovery without a new dip: do not invent a new event.
6. Partial return with a favourable five-frame median: do not label the remaining deficit as complete recovery.
7. Brief high excursion followed by relapse: do not establish sustained recovery.
8. Sustained return with realistic fluctuations: retain supported recovery without demanding a perfectly flat trace.
9. Local return while the region remains depressed: distinguish local and absolute raw return explicitly.
10. Incomplete post-event evidence containing a gap and recording truncation: retain unresolved/censored recovery without filling missing samples.

These ten named fixtures are the finite development set. Their expectations are recorded before the first check run. A constructed pass does not establish biological validity, calibrated confidence intervals or event-area accuracy. These two familiar recordings remain regression examples, not an independent performance evaluation.

## Protected scientific contract

Preserve the burden formula, normalization, complete-burden missingness rule, original recordings, automatic and reviewed measurements, accepted references, exports and production MATLAB workflow. In particular:

- FB2413 823–825 remains a timing cue, with measurement baseline unresolved. The previous 826–827 onset judgment and approximate endpoint near 851 are comparison annotations, not fitting targets.
- FB2412 reviewed onset 114, recovery 182 and baseline 104–113 remain unchanged. Patch 82 retains its reviewed regional-comparison annotation.
- No new scientific amplitude, event area, burden contribution, partial sum or recording total is computed or adopted. Earlier preview outputs remain available unchanged.

## Limits, outputs and stop

Approved limits: **four active engineering hours, three batches, ten constructed checks, one frozen configuration, one engineering repair, 2 GiB measured worker memory and 256 MiB new derived evidence**. The batches are (1) implementation and constructed checks, (2) frozen two-window comparison, and (3) selected independent verification and presentation. Use isolated workers and the existing cached Python environment, with no package installation or production-language decision.

Deliver two updated cards with existing videos, old/new boundary evidence, original-ROI context where verified, recognition/reference uncertainty, a short comparison report and a preservation/verification receipt. Reuse media instead of rendering new movies. Findings remain local. No GUI integration, Git transport, publication, new recording, image-stack processing, area method or burden export is included.

Stop after those deliverables, including honest unresolved or failed cases. A source-integrity, memory, storage, repair or effort boundary produces a preserved partial checkpoint. No post-freeze tuning to reviewed endpoints or new diagnostic campaign follows automatically. Deferring implementation leaves the current cards and reviewed measurements available.

The researcher approved this bounded implementation under [existing-analysis/AGENTS.md](../AGENTS.md): “Before implementation, obtain approval for the milestone and its bounded work items.” Approval received: “Approve this bounded revision.”


## Delivery record

Delivered and stopped on 9 November 2026: three batches, ten constructed cases, one configuration and zero repairs. [Results](BOI_VIDEO_BOUNDARY_REVISION_RESULTS.md) and [two cards](../../reference-validation/boi-video-boundary-revision-20261109/review.html) record improvements, rejected fits, conditional return evidence and remaining defects. No scientific measurement or production adoption occurred.
