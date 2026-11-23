# Combine proposals into complete pocket episodes

10 November 2026. **Implemented and delivered as an unadopted experimental
quality checkpoint.** See the [results and remaining requirements](BOI_VIDEO_EPISODE_ASSEMBLY_RESULTS.md).
The proposed scope below and its approval history are retained.
POCKET-VIDEO-DETECTOR-10; owner root, no delegation. This is a bounded
experimental addition beside the existing Python prototype. It does not replace
the MATLAB detector or change scientific measurements.

## Outcome and agreed meaning

Produce one traceable episode record for a spatially coherent depression that
can contain several minima before credible recovery. Preserve its constituent
proposals, alternative interpretations, complete available context and uncertain
boundaries. An episode can be recognized while its baseline or measurement
readiness remains unresolved.

The researcher agreed the [working definition](BOI_POCKET_EPISODE_DEFINITION.md):
**Several minima within one spatially coherent, unrecovered depression should
belong to one pocket episode.** This plan proposes how to operationalize it;
the operational settings below are experimental, not established biological
cutoffs. Agreement on the principle was not approval of this implementation.

## Spatial continuity

**Meaning:** the same local depression can be followed through space and time,
including expansion, contraction and separated tissue lobes around capillary
gaps. Its identity does not depend on a circular outline or an identical mask
in every frame.

Evidence required to assemble proposals into one episode:

1. Their supported depressed regions overlap, or have a supported spatial
   continuation, during the same evolving change. Compare actual raw block
   trajectories, not just bounding boxes or proposed timestamps.
2. Fixed comparison pixels in each participating lobe show compatible decline,
   continued depression and return. Multiple minima are permitted. A common
   regional trend alone is insufficient evidence of the same local episode.
3. No credible recovered interval separates the changes in the same local
   branch. A genuinely separate spatial origin can support separate episodes
   even when their times overlap.
4. The whole proposed group is compatible. Pairwise A–B and B–C overlap does
   not automatically establish that A and C belong to one episode. Check for
   independent origins, recovered separators and a regional bridge before
   merging; retain competing interpretations when those checks disagree.

Initial resolution safeguards: require three consecutive supplied 1 Hz samples
of compatible local evidence for a new spatial continuation. Permit a gap of
one coarse block as a possible capillary separation only with compatible
signals on both sides. Do not fill that gap as measured area. Larger gaps or
unobserved links remain explicitly unresolved; they do not force either a split
or a merger. These are prototype support rules, not minimum biological size or
duration. A single coarse block remains searchable, with limited spatial
observability recorded instead of an intensity-based exclusion.

Keep a fixed comparison cohort within each tracked branch. Check all continuing
branches before declaring recovery; a recovering dominant core cannot hide a
smaller persisting lobe. Describe changing coarse support separately, retaining
missingness. Coarse support is not accepted native pocket area.

Record extent in coarse blocks and fraction of the observed field, together
with regional-response, vascular/boundary and displacement-like evidence. Size
alone neither proves a pocket nor excludes a real local component within a
larger response. No new tissue eligibility mask, anatomical ground truth or
motion correction is introduced. Boundary/confounding evidence that the coarse
data cannot distinguish keeps recognition uncertain.

## Credible recovery

**Meaning:** the previously depressed tissue shows a sustained observed return
to a compatible recovered state, on consistent pixels, and the coherent local
depression has cleared. A brief spike, disappearance of pixels, change of mask
or a falling fitted background cannot by itself establish recovery.

The proposed first configuration uses these detection-only rules:

- Assess an observed pre-decline state using twenty contiguous finite samples
  outside the assembled depression. Search earlier context where necessary;
  do not restart this state at every minimum. Check its two halves for a level
  shift. A short, contaminated or drifting pre-state leaves the absolute
  recovery reference unresolved; it does not erase the episode candidate.
- Define a descriptive fluctuation allowance from the larger of robust
  short-lag variation and robust variation about the pre-state trend, with a
  recorded numerical floor. Use a two-allowance lower reference band. A shift
  between the two pre-state halves exceeding two allowances invalidates a
  stable absolute reference. These are empirical diagnostic allowances, not
  calibrated camera noise, confidence intervals or oxygen thresholds.
- Require an observed raw rise of at least two allowances from the depressed
  level on the same branch cohort. Then require ten consecutive finite 1 Hz
  observations at or above its lower recovered-state band, with no continuing
  coherent depressed branch. An overshoot is compatible with sink recovery;
  surge classification remains separate. Any renewed supported deficit resets
  the confirmation interval.
- Save the **start of that qualifying interval** as proposed recovery, and its
  confirmation-through frame separately. Observations after an unrelated later
  flank cannot retrospectively certify an earlier endpoint. Preserve an onset
  or recovery bracket when the evidence does not resolve a unique sample.

Failure to satisfy ten samples is not proof that the tissue remained depressed.
If a shorter interval shows raw restoration and spatial clearance, preserve a
short-recovery split/merge alternative instead of automatically merging the
events. The confirmation rule is a conservative prototype criterion; ambiguous
evidence must not become a biological assertion of uninterrupted hypoxia.

The ten-sample recovery confirmation is separate from the scientific amplitude
baseline and its existing duration/reference rules. This plan does not shorten
that baseline, change accepted custom windows or adopt a shared baseline for
distinct recurrent events.

Every branch retains one of these explicit states:

| State | Interpretation and assembly consequence |
| --- | --- |
| Observed recovery | Raw rise, a usable observed reference, sustained return and spatial clearance agree. A later new depression can be a separate episode. |
| Relative recovery | Local contrast resolves against a changing regional signal, but absolute raw restoration is unestablished. Retain a provisional boundary; do not certify an intervening recovered state or scientific baseline from this alone. |
| Interrupted recovery | A partial rise leaves a continuing spatial depression before renewed decline. Keep compatible minima within the episode. A short apparently cleared state instead retains split/merge uncertainty. |
| Unresolved recovery | Missing/unstable reference, pixels, spatial evidence or competing explanations prevent a decision. Retain split/merge alternatives rather than forcing one complete event. |
| Recording-edge censored | The recording omits the preceding state or sustained return. Preserve an open boundary, not a fabricated onset/recovery at the edge. |

An experimental episode is called complete only when onset context, spatial
identity and observed sustained recovery are supported. Completeness of
detection still does not establish a scientific amplitude reference or native
area. All new outputs remain measurement-ready and burden-ready false.

## Assembly method and the shortening problem

Reuse all saved primary proposal groups and their seed masks, routes and scale
alternatives. Do not rerun proposal generation or keep only current local-cycle
positives. Preserve uncertain, unsupported and censored records in the accounting;
regional-only explanations remain contextual evidence rather than connecting
otherwise separate local episodes.
An old recognition label is not a veto on reassessment of its raw evidence.

Build indexed spatial/time associations, then test group-wide compatibility
against the cached raw fields. Preserve multiple branch cohorts when no common
fixed core exists. Candidate associations are hypotheses; a connected graph
component is not automatically a biological pocket.

Reconstruct the whole episode with states for recovered, depressed and
recovering tissue, allowing several minima, a flat trough and unequal decline
and return. Remove the single-peak monotonic requirement within an episode.
Use context from all member scales and extend assessment through the available
recording until supported pre-state/recovery, an unresolved conflict or the
recording edge. Retain onset/return brackets and the reason for any context
limit; do not take the earliest and latest timestamps of all proposals blindly.

The selected seed's trough ± span must not bound the assembled event. In the
saved examples that restricts FB2413 to 831–847 and FB2412 to 110–174, excluding
the discussed full FB2413 episode and reviewed FB2412 recovery 182. Tests must
demonstrate recovery of slower edges outside a stronger short seed's window.
Reviewed frames remain comparison evidence, never inputs to episode assembly.

Keep raw evidence alongside the existing near/far/field comparisons. Fit any
diagnostic regional contribution on context outside the assembled depression;
do not add interior drift freedom that can explain away its slow edges.
Responding surrounding patches remain responding evidence, not verified quiet
controls. A disappearing residual cannot override a continuing raw depression.
If local and regional explanations are indistinguishable, report uncertainty.

Use deterministic identities and an accounting ledger: every original proposal
has one primary disposition (episode member, regional context, unsupported or
unresolved), with explicit alternative links where needed. Alternatives must
not produce multiple accepted counts for the same evidence. Minima are features
within an episode; this ledger is not a scientific event-count export.

## Fixed source scope

Use only the twelve existing development caches: FB2311, FB2317, FB2319, FB2402,
FB2403, FB2405, FB2407, FB2408, FB2410, FB2412, FB2413 and FB2419. They contain
14,378 supplied 1 Hz samples of 128 × 128 raw means from 4 × 4 native blocks.
Reuse the saved 320,824 primary seed records and 128,931 candidate records.
Keep the saved raw-route-only results as an unchanged comparator; no new
ablation or proposal-generator configuration is included.

All thirty existing views remain in the comparison. The four located positive
targets, one positive-presence window, three rejected targets, one no-pocket-seen
window, one contested-timing view and twenty unlabelled views retain their
different authority. No labels, old ROIs or manually discussed frames select
episode boundaries or supply a missing recovered reference.

No new original TIFF decoding, native segmentation, movie encoding, source
correction, MATLAB integration, package installation or platform decision.
Reuse existing snapshots/movies. FB2420, FB2316, FB2320, FB2404 and FB2406 remain
reserved with zero new image/trace-array reads. This is a finite software test,
not a cohort reanalysis or KX/protocol investigation.

## Work items, acceptance and stopping conditions

| Item; owner root | User benefit and bounded work | Acceptance and stop |
| --- | --- | --- |
| EASM-01 | Pin sources and define episode/member/recovery records, configuration, counters and guards. | Cache/seed/candidate/review identities match; old results and all proposal dispositions remain traceable. Stop for a source/split conflict. |
| EASM-02 | Implement spatial/time assembly and whole-episode boundary assessment beside the frozen prototype. | The eighteen predeclared constructed cases below pass; one configuration freezes before development arrays. Stop at repair/test/resource limits. |
| EASM-03 | Apply that configuration once across all twelve caches and account for all thirty views. | Twelve complete assembly passes or explicit failure/unprocessed ledgers; membership conservation, ambiguity and complete/open states reported. No recording-specific adjustment. |
| EASM-04 | Independently replay arithmetic and present six whole-episode comparisons plus an assessment. | Twelve selected saved-episode replays and eighteen constructed arithmetic replays; complete thirty-view table, preservation proof and six readable cards. Report failures and stop before adoption. |

Declare one deterministic realization and expected outcome for each constructed
case before its first execution:

1. Two minima in one unrecovered local depression: one episode.
2. Several minima and a flat low period: one episode with retained minima.
3. Same location, credible intervening recovery: two episodes.
4. Brief apparently cleared return followed by renewed decline before the
   confirmation interval: unresolved short recovery and split/merge alternatives.
5. Adjacent simultaneous depressions with separate origins: retain separation.
6. An A–B–C chain linked only by a regional response: no automatic group merger.
7. Supported lobes around a one-block gap: retain continuity and the gap flag.
8. Distant lobes with correlated regional drift: no automatic single pocket.
9. Expanding/shrinking support: preserve identity and test each continuing branch.
10. Missing pixels or a changing cohort: do not manufacture recovery.
11. A local cycle on a regional decline: retain local evidence and its dependency.
12. A broad field cycle: retain the regional explanation rather than declaring
    many independent local episodes.
13. A strong boundary/displacement-like signal with inadequate spatial identity:
    uncertain, not a certified complete tissue pocket.
14. Dim valid signal with adequate local evidence: no brightness exclusion.
15. A stronger narrow seed inside a slower asymmetric cycle: include the
    supported outer edges beyond that seed's phase window.
16. Recording-start depression: preserve missing onset/reference.
17. Recording-end depression: preserve missing recovery.
18. Return only relative to a falling background: do not certify absolute recovery.

Use at most three executions per case including repairs (54 total), with no
extra random realizations or parameter sweep. Freeze data contracts, settings,
loss/penalties, support and uncertainty mapping before development arrays.
The numerical allowances above may be corrected only within the declared
pre-freeze repair allowance, with changed expectations never used to disguise
a failed case. No saved recording outcome can trigger retuning in this milestone.

For independent recording replays, freeze this selection rule before outcomes:
the first identity-sorted assembled episode intersecting each recording's first
ID-sorted benchmark view; otherwise the first episode, or a zero/open-result
accounting replay. Replay existing output arithmetic, not another model fit.
Check source traces, cohort missingness, reference allowances, raw rise,
confirmation interval, branch status and proposal membership. Check all thirty
source-coordinate association lists and all input/output counts.

The six cards remain FB2413 site 3/event 6, FB2412 site 20/event 1, FB2402's
reviewed window, FB2407 site 12/event 7, FB2410 site 66/event 2 and FB2419's
no-pocket-seen window. Show constituent proposals, assembled alternatives,
fixed-cohort traces, spatial extent, onset/recovery brackets and confirmation
evidence in full context. Preserve zero matches and failed/ambiguous cases.

FB2419 must show which of the 63 prior local proposals are duplicates, remain
candidate episodes, have regional/boundary explanations or are unresolved.
Do not classify all 63 as false biological events or force zero output from
the window label. FB2402's presence label does not validate its first-ID spot.
FB2410's trace recognition does not validate a proposed area. No sensitivity,
specificity or false-positive rate can be estimated from these incomplete,
dependent labels. Fewer proposals or wider intervals alone do not prove improvement.

## Finite budget

Propose **eight active engineering hours, four batches, one frozen assembly
configuration, two engineering repair cycles total, 2 GiB worker memory and
512 MiB new derived evidence**. The batches are contract/source checks,
constructed implementation/freeze, frozen development comparison, and independent
verification/presentation. Reporting repairs consume the same two-repair budget.
After freeze, memory/IO repairs must prove numerical parity; a method revision
requires a new decision.

There are twelve planned full-recording assembly passes and at most eighteen
attempts including failures/replays, six guarded reporting-worker attempts,
18 constructed scenes/54 executions, and at most six expanded cards. There are
zero new proposal-generator executions, scientific statistics runs or exports.
All repeated episode assessments, including retries, count toward a ceiling of
257,862 hypothesis assessments (twice the existing candidate count). Permit at
most 2,000,000 stored association edges across the run. Record unresolved
alternatives without silently selecting a score-ranked subset if they exceed
the representation/resource limits.

Stream saved records, process one recording at a time and use spatial/time
indexing; do not allocate a dense all-pairs graph or load all full catalogues.
Existing inputs remain referenced in place, not copied into the evidence budget.
Stop at any source, effort, attempt, fit, graph, memory, storage or repair boundary
with the checkpoint, failures, consumed counters and unprocessed IDs preserved.
Do not reset the previous milestone's counters or imply this proposal reopens it.

## Scientific protection, alternative and approval

Preserve the burden formula, normalization, strict complete-contribution rule,
source-specific tissue support, original recordings, automatic and reviewed
results, individual scientific references, sink/surge separation, workbooks and
export formats. No accepted area, amplitude, duration, burden or totals are
recalculated. No partial sums or imputed zero area. In particular, FB2412 site
20 retains baseline 104–113 and timing 114–182; FB2413 retains cue 823–825 with
unresolved measurement baseline; FB2412 site 1's longer saved interval and
shorter unsaved preview remain separate.

Deliver a local experimental episode ledger, all-thirty comparison table, six
cards linked to existing movies, independent verification and a keep/change
assessment. No Git transport, external publication or production adoption.
Engineering correctness, biological recognition and measurement readiness are
separate acceptance questions; unmet biological checks must be reported.

The alternative is to retain the current cards and agreed definitions without
new assembly processing. This request authorizes planning only.
[AGENTS.md](../AGENTS.md) states: **“Before implementation, obtain approval for
the milestone and its bounded work items.”** Explicit approval of this plan is
needed before EASM-01 through EASM-04 begin.

## Approval and implementation record

The researcher explicitly approved this bounded plan on 10 November 2026:
“I approve the bounded episode-assembly plan. Go ahead with implementation,
keeping the five reserved recordings untouched and the burden formula,
normalization and original results unchanged.” Root works without delegation.
The opening proposal and parameter descriptions are preserved as reviewed
scope; the exact approved text is saved in the implementation evidence.

All eighteen constructed cases pass on their second execution (36 total) after
one recorded implementation repair to small-field comparator resolution and
exact one-block gap connectivity. Expectations and fixture realizations remain
unchanged. The numerical sources, settings and source contracts freeze before
the first development array read. The same twelve recording assembly passes
then start; all scientific outputs and reserved arrays remain protected.

## Completion record

All twelve frozen state-assembly passes completed in twelve attempts. All
128,931 candidate records and 320,824 seeds are accounted for, with thirty
comparison views, six expanded cards and an episode/member ledger. The eighteen
constructed scenes pass after the recorded pre-freeze repair; expectations and
the single frozen configuration remain unchanged.

The second and final repair recovers omitted output alternatives and annotates
contradictory display confidence. Eighteen generated grouping-only parity
checks and twelve saved-output metadata replays preserve every original
grouping decision field. No state or proposal fit is repeated. Conservative
counters finish at 54 constructed executions, six report workers, 257,862
hypothesis-equivalent assessments and 299,511 stored links, within the approved
four batches/eight hours/2 GiB/512 MiB. All source-preservation checks pass.

The independent audit has 145 exact scalar comparisons, zero tested return
arithmetic failures and zero remaining annotated delivery-contract gaps. It
preserves 36,734 original classifier metadata gaps and two selected
reference-context warnings. Software checks do not validate the proposed
biological partition, timing or native area. The results report documents
earlier-activity mergers, reference suitability, FB2317 rejected-target
associations and FB2419 overgeneration. These remain unmet biological
requirements, not concealed passes.

The bounded implementation and reporting work is complete and stopped. No
production adoption, scientific save, export, Git transport or further campaign
is active. The five reserved recordings, formula, normalization, strict complete
burden, references, originals and earlier results remain protected.
