# Separate local episodes, regional changes and measurement baselines

11 November 2026. **Delivered and stopped; experimental, unadopted.**
POCKET-VIDEO-DETECTOR-12; owner root, no delegation. One bounded experimental
Python revision beside the current prototype. The previous
[episode-identity experiment](BOI_VIDEO_EPISODE_IDENTITY_REVISION_RESULTS.md)
remains closed, unadopted and preserved. This plan does not authorize its own
implementation, MATLAB integration or scientific adoption.

## User benefit and problem

Recognize a local pocket episode even when surrounding tissue also changes or
its measurement baseline cannot yet be established. Show those three facts
separately, so an unresolved burden contribution does not erase spatial event
evidence and a regional response does not automatically exclude a local pocket.
Several minima within one spatially coherent, unrecovered depression remain
one episode.

The saved decisions expose a coupled failure: an intensity band defines an
episode; that onset selects a reference; the reference changes the episode;
the resulting onset and regional label control whether spatial analysis runs.
FB2413 expands to 481–940 with reference 461–480; FB2412 is connected back to
frame 1 and loses its onset; FB2410 first proposes 682–707, then moves onset to
185 and becomes regional before spatial evaluation. These are observed
prototype failures, not changes to the researcher's pocket judgments.

The revision replaces that dependency structure. It is not another search for
one absolute intensity threshold or a universal pocket waveform.

## Three separate outputs and order of inference

| Output | Evidence and meaning | Dependency boundary |
| --- | --- | --- |
| Local episode | Seed-connected spatial decline, low period and rebound on explicit fixed pixel cohorts; timing, continuation and recovery uncertainty. | Must be assessed without an accepted measurement reference or a regional veto. A diagnostic comparison state is still needed and may be uncertain. |
| Regional change | Observed near, far and external-field trajectories, spatial extent and agreement/disagreement with the target. | Can coexist with a local episode. Failed local fitting alone is not affirmative evidence of a regional-only event. |
| Measurement-reference assessment | Per-episode diagnostic 20/10-sample windows and an immutable link to any already reviewed scientific reference. | Runs after episode hypotheses are fixed. Cannot change their IDs, boundaries, membership or regional interpretation. Cannot accept a new scientific reference. |

Store these as separate versioned records linked by source/episode IDs, rather
than one mutually exclusive label. Distinguish episode identity, observed local
return, absolute raw return, spatial clearance and measurement readiness.
All experimental outputs remain `MeasurementReady=false` and `BurdenReady=false`,
including well-supported detection candidates.

### 1. Establish local episode hypotheses from spatial and temporal evidence

Retain original source candidate IDs, seed IDs/times, masks, scales, routes and
fixed consensus-core hashes. Reuse the existing proposals; no new seed search.
Keep original reviewed ROI traces separate from the experimental cohorts.

Replace full-trace grouping under one historical level with a bounded,
seed-connected interpretation of local decline, low phase and rebound. Reuse
the existing phase/continuation and sparse spatial-graph components where
appropriate. Allow flat troughs, asymmetric recovery, baseline-level changes
and several minima. A remote maximum or an earlier low signal is not sufficient
to join activity to the target. A seed anchor inside a long interval is only
an accounting check, not proof of episode identity.

Use observed temporal transitions and the existing seed/scale alternatives to
establish diagnostic before/low/after states. These states are detector context,
not assertions of normoxia or scientific measurement baselines. Longer context
can support a slowly developing or continuing episode, but extending through
earlier activity requires observed spatial/time continuation. Do not impose a
narrow seed-duration ceiling or substitute the nearest better-looking dip.

Evaluate the raw fixed cohort first. Form near, far and external-field
comparison signals independently of whether a raw onset or clean pre-state was
found. Assess raw/local-contrast alternatives on the same source identity;
none is the automatically correct channel. Primary spatial assessment must
remain available when a conditional comparison cannot be scaled reliably.

Any scaled conditional comparison needs its own explicit diagnostic-context
samples, scale and missingness. No target-fitted trend through the depression
or recovery is permitted; it could absorb the event being assessed. No quiet
control is presumed. A comparison without a defensible scale stays unavailable
with a reason; it does not veto the raw/spatial route. Freeze the diagnostic
context-selection and scaling rules on constructed cases before development
signal arrays are opened.

Use at most four channels: raw plus the three existing surrounding comparisons.
Retain at most two seed-connected episode alternatives per channel. Record all
retained boundaries and why they agree or conflict. If more plausible
interpretations remain, record their count, the capacity reason and unresolved
identity; do not silently choose a winner or claim exhaustive enumeration.

There is no measurement-reference feedback loop. Reinterpreting timing must
retain the originating decline and continuing spatial branches. A move such as
682 to 185 needs an explicit competing identity and supporting observations;
it cannot silently overwrite the local interpretation. Unsupported joins stay
ambiguous. Preserve full-group compatibility, not a chain of pairwise links.

### 2. Assess regional change and spatial recovery without suppressing episodes

Run spatial observations for every source with usable image samples, including
sources with unresolved onset/reference and strong regional responses. Record
attempted, observed, unavailable and unresolved states separately; an empty
track list must not conceal a skipped assessment.

Use the existing 128 × 128 block movies for branch-local changes, connected
support, continuation, expansion/contraction and returns. Keep fixed cohorts
and child branches explicit. Retain the existing supported one-block-gap
mechanism without filling gaps as measured area. Missing observations, mask
disappearance or recovery of only one lobe cannot certify spatial clearance.

Record shared regional behaviour and any additional local cycle together.
Extent and temporal correlation are contextual evidence, not a blanket veto
or a tissue-hypoxia area fraction. A regional-only interpretation requires
positive shared-response evidence and a completed assessment of the local
alternative; missing reference information alone cannot produce that label.

Distinguish a local rebound, a sustained local return and return to the same
episode's observed raw pre-decline state. Compare continuing branches in their
own local context alongside surrounding responses. A return relative to a
changing region does not establish absolute recovery or a recovered scientific
baseline. Retain the existing ten-sample confirmation as a diagnostic check,
with its confirmation-through frame. Failure to cross an old absolute band
for ten samples must not automatically concatenate the whole preceding trace.
Short returns and conflicting branch observations retain split/merge ambiguity.

Keep coarse vascular/boundary/displacement observations as possible confounders.
Neither small size nor uncertainty establishes an artifact. Reuse prepared
native movies to inspect physical plausibility; coarse blocks cannot supply
anatomically validated boundaries or accepted native pocket area. If that
resolution prevents a decision, report the limitation and stop at this scope.

### 3. Audit measurement references after episode hypotheses are fixed

For each retained interpretation, assess the adjacent 20- and 10-sample
diagnostic windows independently on its fixed pixels. Record exact frames,
level, noise, trend, earlier-episode/rebound overlap, missingness and agreement
with the immediate pre-decline context. An uncertain onset may yield explicit
alternative windows or no window; do not search backward for the most useful
depth or borrow a different episode's reference.

Twenty samples remain the starting diagnostic context; ten samples are a
flagged shorter-context alternative. Numerically stable does not mean
biologically recovered. Neither result accepts a scientific baseline or
changes existing reference-age limits or recording-start holds. Recurrent
episodes retain individual reference assessments; multiple minima within a
single unrecovered episode do not reset the reference repeatedly.

The reference audit can lower measurement readiness, never rewrite detection.
Verify this directly by withholding reference results and changing the 20/10
audit selection: episode IDs, boundaries, spatial evidence and regional states
must remain identical. Detection-context uncertainty remains visible separately.

## Finite source and review scope

Use only **FB2311, FB2317, FB2319, FB2402, FB2403, FB2405, FB2407, FB2408,
FB2410, FB2412, FB2413 and FB2419**: the same twelve development caches,
14,378 supplied 1 Hz samples and 4 × 4 native-pixel block means. Account for all
**128,931 original primary candidate records and 320,824 seeds**. This is a named
software acceptance benchmark, not a cohort reanalysis or a comparison of
biological conditions. The supplied sampling authority is not a future default.

Keep **FB2420, FB2316, FB2320, FB2404 and FB2406** reserved: zero new image,
trace-array or payload reads. Existing split IDs/receipts suffice for protection;
do not inspect reserved movies for design decisions.

Retain all thirty benchmark views and current review authority: four located
positives, one positive-presence window, three rejected targets, one
no-pocket-seen window, one contested-timing view and twenty unlabelled views.
Reviewed boundaries/references and researcher labels are evaluation evidence,
not inputs to detector timing, masks, reference selection or parameter tuning.
Existing judgments suffice; no new comprehensive annotation or second-by-second
boundary review is a prerequisite.

Freeze the same six displayed sources: FB2413 **J002459**, FB2412 **J001599**,
FB2402 **J011922**, FB2407 **J006434**, FB2410 **J004342**, FB2419 **J000386**.
Keep the previous twelve recording-wide audit selections plus these six sources
for independent replay. Exact IDs and input receipts are retained in the
[machine-readable proposal](../../reference-validation/boi-local-regional-baseline-proposal-20261111/proposal.json).
Do not substitute a more successful candidate for a failed fixed source.

## Work items; owner root throughout

| Item | User benefit and bounded work | Acceptance and stopping condition |
| --- | --- | --- |
| LRB-01 | Pin source/review identities, separate record contracts and counters. | Prior outputs preserved; three outputs have explicit dependencies and unavailable states. Stop on a source/split conflict. |
| LRB-02 | Implement the separated local/regional paths and downstream reference audit in an isolated module. | Missing references and regional response cannot skip spatial assessment; reference-audit changes cannot alter episodes. Pass the fixed constructed checks before development arrays. |
| LRB-03 | Apply one frozen configuration to all twelve caches. | Account for every original candidate/seed and all thirty views, without recording-specific tuning; retain failed/unresolved sources and alternatives. Stop at declared limits. |
| LRB-04 | Independently verify and present the six fixed cards, thirty-view comparison and failure assessment. | Eighteen saved-source replays, thirty association lists, constructed readout checks and preservation receipts. Report remaining biological failures and stop before adoption. |

Add `prototypes/boi_episode_components` and focused tests beside the preserved
previous modules, reusing existing readers, resource guards and provenance.
No previous numerical module is edited. Freeze one numerical configuration,
contracts and selection rules before the first development-array read.

### Checks before the frozen twelve-recording application

Reuse the twenty-four preceding deterministic scenes with their physical
expectations, rather than requiring obsolete mutually exclusive output labels.
Record any schema mapping explicitly without weakening those expectations.
Add eight deterministic adversarial scenes, with realizations and expected
outcomes frozen before the first execution:

25. An earlier low level, higher immediate pre-state and later local dip: do
    not infer that the local episode began at recording start.
26. Earlier activity plus a later local decline/rebound, with measurement
    baseline withheld: preserve the later identity and its spatial assessment.
27. A small context-level change exposes a remote crest: retain the local
    interpretation or explicit alternatives, never silently jump identity.
28. A local spatial dip on a strong regional decline: both evidence records
    survive, with absolute versus relative return distinguished.
29. A broad shared cycle without additional supported local depression: do
    not manufacture a local pocket; prove the local path was assessed.
30. No defensible conditional-comparison scale: raw/spatial assessment still
    runs, while relative inference remains unavailable with a reason.
31. Multi-minimum spatial depression with one branch still low or missing
    during a mean rebound: no premature split or complete spatial recovery.
32. Identical detection evidence with 20-only, 10-only and withheld reference
    audit results: episode identities/bounds/regional states are identical.

Include fixed correlated noise, changing levels and unequal slopes where
relevant. These are 32 fixed scenarios, not a parameter sweep; the three audit
variants in case 32 are one declared contract check. At most three suite
executions: **96 scene executions total**. Failed expectations cannot be
rewritten to obtain a pass. Repairs consume the shared repair budget.

### Real-example acceptance and honest failure reporting

- **FB2413:** assess the later decline/rebound connected to anchor 839; a
  481–940 interval containing it is not sufficient. Explain evidence for any
  connection to earlier activity. Keep cue 823–825 and the unresolved
  scientific measurement baseline unchanged.
- **FB2412:** assess local decline/return and spatial identity despite an
  unresolved automatic baseline. Earlier lower intensity alone cannot impose
  recording-start censoring. Preserve reviewed baseline 104–113 and interval
  114–182; compare pixel cohorts explicitly rather than enforcing exact
  original-ROI timings on a different cohort. Patch 82 stays a responding
  regional comparison, not a quiet reference.
- **FB2410:** retain and evaluate a seed-connected local interpretation within
  the regional trajectory. Explain any departure from the saved first-pass
  682–707 hypothesis; do not treat that interval as exact ground truth.
- **FB2407:** assess the full continuing multi-minimum depression and all
  branches through rebound; do not claim 611–651 is complete merely because
  its local core returns. Keep alternative membership and timing visible.
- **FB2402:** show the fixed source's anchor 91 and sufficient earlier trace
  context in the new card. The existing native clip starts later and remains
  labelled accordingly. Window-level pocket presence does not validate every
  selected location.
- **FB2419 and rejected targets:** retain all associations and explicit local,
  regional, confounded or unresolved evidence. Do not force the weak negative
  window to zero or convert small size to an artifact diagnosis. Preserve all
  three scientific not-pocket exclusions regardless of experimental overlaps.

Independently replay the eighteen preselected saved sources without fitting
new models, and all 32 constructed readouts. Check candidate/seed accounting,
source masks, every readiness/dependency invariant and all thirty association
lists. Audit reference independence for every saved source using record-level
readout checks; the constructed metamorphic check exercises the actual paths.

Report detection suitability separately from arithmetic correctness. A target
left unresolved is an explicit detection failure, not a successful detection.
Reduced proposal counts, more uncertainty flags and approximate anchor
containment are not accuracy evidence. These dependent, incompletely labelled
development views cannot establish sensitivity, specificity or a false-positive
rate. Biological acceptance may remain unmet after a complete engineering run.

## Effort, resource and execution limits

Propose **eight active engineering hours, four sequential batches, two repair
cycles total including reporting, one frozen configuration, 2 GiB worker RSS
and 512 MiB new derived evidence**. Batches: source/contracts; implementation,
constructed checks and freeze; twelve frozen applications; verification and
presentation. Owner root only. Stream one recording/process at a time, counting
child memory if any is introduced. Approval waits do not reset used effort.
Reuse caches/media in place, keep alternative records compact and stream
sparse associations; do not duplicate full movies or retain dense
candidate-by-frame-by-pixel arrays.

Allow twelve planned full-recording passes and **eighteen attempts maximum**,
six reporting-worker attempts, 32 constructed scenes/96 executions, six expanded
cards and one overview. Cap candidate pipeline invocations at **257,862**,
including retries and conservatively charged numerical reconstructions.
At most four channel assessments and eight local episode-hypothesis assessments
per invocation: **1,031,448 channel and 2,062,896 hypothesis assessments**.
At most two downstream diagnostic windows per retained hypothesis, bounded by
**4,125,792 window assessments**. Store at most **2,000,000 association links**.
Count attempted/unavailable assessments; no hidden extra refinement loop,
configuration, ablation or outcome-triggered sweep is included.

No new proposal generation, source TIFF decoding, native segmentation, movie
encoding, reserved-data payload read, MATLAB run, statistics/export run, package
installation or platform choice. Existing prepared media are reused in place;
new static plots/maps use only approved caches and prepared trace evidence.

After freeze, memory/IO repairs require numerical parity. Development outcomes
cannot trigger a method/threshold change. Every retry, failed partial attempt
and repair consumes the same counters. Stop at any source, effort, attempt,
memory, storage, graph or repair boundary, preserving completed work and exact
unprocessed IDs. A repair that changes method after real outcomes needs a new
decision; do not reopen the preceding experiment or expand into native data.

## Scientific protection, deliverables and decision

Preserve the burden formula, normalization, strict complete-contribution rule,
source-specific tissue support, sink/surge separation, original recordings,
automatic and reviewed results, scientific references, workbooks and export
formats. No new accepted amplitude, native area, duration, burden or recording
total is calculated. No partial sum, imputed zero area or scientific default
change. FB2412 site 1's saved longer interval and shorter unsaved preview remain
distinct; no scientific review revision is saved.

Before approved execution, verify the inherited protected-input/cache/review
receipts and pin current sources. At closure verify protected scientific inputs
and original development recording byte hashes/stats. Planning only checks
delivery/source/receipt hashes and development file metadata; it does not load
signal arrays, rehash all original recording payloads or inspect reserved data.
Reserved protection uses existing receipts, without fresh reserved-payload
hashing or decoding.

Deliver a versioned local-episode/regional/reference ledger, all-thirty-view
comparison, six fixed-source cards with reused videos, independent arithmetic
and dependency checks, preservation receipts and a concise keep/change report.
Show full timing context, same-pixel comparisons and unresolved alternatives.
Report native-resolution limitations instead of claiming accepted area or
measurement readiness. No production adoption, commit/push or publication.

The alternative is to retain the current evidence and defer implementation.
This request authorizes planning only. [AGENTS.md](../AGENTS.md) states:
**“Before implementation, obtain approval for the milestone and its bounded
work items.”** Approval of LRB-01 through LRB-04 is required before work starts.
No implementation is active.

## Approval record

The researcher explicitly approves LRB-01 through LRB-04 on 11 November 2026.
The exact original plan is pinned as `approved-plan.md` in
`reference-validation/boi-local-regional-baseline-20261111`. Root works without
delegation; no resource or scientific boundary is expanded.

## Execution checkpoint

All 32 constructed scenes passed on execution three (96 total) after two
pre-freeze repairs. The first FB2311 development attempt stopped after 1,244
saved source records: J001245 proposed an onset after its source anchor 760.
Zero recordings completed; eleven development caches remain unopened by the
detector. The first freeze, failed attempt and unprocessed source IDs remain
preserved. No scientific results or reserved payloads were touched. Further
execution awaits approval of the [narrow guard correction](BOI_VIDEO_COMPONENT_IDENTITY_REPAIR.md);
the patch is prepared but not applied.

## Completion record

The approved guard amendment passes all 35 checks, with exact saved-output
parity on the 32 existing scenes. Twelve full recording passes complete in
thirteen attempts; the initial failed attempt remains preserved. Independent
verification reports 34,198 scalar comparisons with no arithmetic, narrow
anchor-contract or source-confidence failures. Scientific episode identity
and full recovery remain unmet on the saved real examples. See the
[results and limits](BOI_VIDEO_LOCAL_REGIONAL_BASELINE_RESULTS.md). No further
implementation or scientific adoption is active.
