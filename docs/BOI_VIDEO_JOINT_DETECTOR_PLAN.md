# Detect local episodes within changing video backgrounds

9 November 2026. Proposed milestone **POCKET-VIDEO-DETECTOR-09**. Owner: root,
without delegation. **Planning delivered; implementation is not approved or
active.**

## Practical outcome

Build one offline detector prototype that proposes a spatial region together
with its decline, low period and return. Evaluate it across all twelve existing
development recordings, rather than fitting another rule to FB2413 and FB2412.
Deliver a comparison with the thirty prepared views and an explicit account of
misses, excessive proposals, regional/local ambiguity and missing recovery.

This is a recognition experiment. It cannot make the seventeen recordings'
burdens complete: measurement baselines and full-event area require their own
accepted evidence. The existing MATLAB application and statistics/export
workflow remain the working software. The intended user journey remains load
CSV, run and use the existing exports. This prototype review adds no mandatory
frame-by-frame task to routine batch processing.

## What the researcher review establishes

The separate [review revision 3](../../reference-validation/boi-broad-video-benchmark-review-20261109/benchmark-review-03.json)
contains four new window/episode judgments. The
[evaluation basis](../../reference-validation/boi-video-joint-detector-proposal-20261109/review-basis.json)
keeps those distinct from prior scientific judgments and unlabelled material.

| Evidence | Authority and appropriate use |
| --- | --- |
| FB2413 site 3/event 6 and FB2412 site 20/event 1 | Two prior recognized, located pockets. Preserve their references and uncertainty; do not optimize only these two. |
| FB2407 site 12/event 7 | Newly recognized local pocket in the whole-episode view. The old 634–639 marker identifies the discussion target, not its accepted full duration. |
| FB2410 site 66/event 2 | Newly recognized pocket **from the trace**. Spatial extent and local return were not separately accepted. Weak visual contrast must remain a reported limitation rather than an automatic rejection. |
| FB2402 frames 122–481 | Local pockets are present somewhere in the displayed window. This is not an exhaustive event list, a probe-specific segmentation or exact timing truth. |
| FB2419 frames 721–1080 | No pocket seen in this displayed window. This is not a recording-wide absence claim, nor a judgment about the earlier site-27 clip. |
| FB2317 site 13/event 5; FB2319 site 7/event 2; FB2412 site 1/event 1 | Three prior rejected targets, not declarations that their complete clips contain no pockets. |
| FB2412 site 1/event 2 | Saved 651–693 discussion and unsaved 659–672 preview remain distinct. Use as a timing/extent ambiguity check, not exact positive/negative timing truth. |
| Other twenty benchmark views | Unlabelled. In particular, FB2311, FB2403, FB2405 and FB2408 have no confirmed new label. Do not turn our provisional interpretations into researcher decisions. |

There are four located positive examples, one positive-presence window, three
rejected targets, one no-pocket-seen window, one contested-timing view and twenty
unlabelled views. These are overlapping development observations, not thirty
independent biological events or a training set of precise masks.

The practical requirements are to retain subtle trace-supported changes, show
spatial extent through time, distinguish local return from field movement, and
preserve uncertainty when those explanations cannot be separated. A small saved
ROI is not proof that the complete response is small. A shared response is not
automatically disposable background, and a broad response is not rejected by an
invented universal size cutoff.

## Fixed source scope and reuse

Reuse the verified 4 × 4 native-pixel block-mean caches for **FB2412, FB2413,
FB2419, FB2311, FB2317, FB2319, FB2402, FB2403, FB2405, FB2407, FB2408 and
FB2410**. Together these contain 14,378 samples of the full 128 × 128 block
field. Process complete cached recordings so the thirty existing windows do
not create artificial onset or recovery boundaries.

The [source registry](../../reference-validation/boi-broad-video-benchmark-20261109/registry.json),
cache receipts, source/footprint identities, case dependencies and researcher
review hash are already listed in the
[proposal record](../../reference-validation/boi-video-joint-detector-proposal-20261109/proposal.json).
Validate them before processing. The supplied external 1 Hz applies to these
sources only; retain the supplied calibration and its qualification without
making either a universal default.

**FB2420, FB2316, FB2320, FB2404 and FB2406 stay reserved.** No new reserved
pixels, traces, proposals or case selection are included. No new original TIFF
decoding, denoised input, recording expansion, raw copying or movie encoding
is included. Coarse caches are numerical inputs; compressed review movies and
display-reference difference maps are not numerical detector inputs.

The existing native movies remain the visual evidence. Cases 25 and 29 retain
their compression-quality limitation and before-compression snapshots. New
coarse results cannot repair that limitation or establish native pocket borders.

## Proposed detector architecture

### 1. Generate complete-cycle proposals throughout the field

Search every finite block trajectory at several spatial and temporal scales.
Propose a low interval relative to both its preceding and following context,
with separate decline and return evidence. Do not reduce the entire recording
to a single strongest cycle: an earlier larger event must not consume a later
smaller one. Preserve censored declines lacking an observed pre-state or return
as unresolved/persistent proposals, with the missing side recorded.

Use two proposal routes: raw-cycle evidence and local-versus-surrounding cycle
evidence. Keep their union and source identity. A failure of the second route
cannot veto the first. Do not seed the search with old ROIs, target frame markers
or researcher labels. Those enter only the subsequent comparison.

A finite starting bank uses temporal spans 4, 8, 16, 32, 64 and 128 seconds and
spatial smoothing scales 0, 1, 2 and 4 coarse blocks. These are search resolutions,
not biological duration/size limits. Refine proposals on the actual sample grid;
flag structures extending beyond the search bank instead of declaring absence.
The smallest route retains a single coarse block as a possible observation.
Dim finite tissue is searched; the old intensity-based eligibility mask is not
reused. Missingness and weak observability receive explicit coverage entries.

### 2. Assess regional change and a local episode jointly

For each proposed space-time component compare three explanations on the same
raw block observations:

- Regional/common activity plus local drift, without a separate local cycle.
- The same regional/common activity plus a spatially supported local cycle.
- The same activity plus a persistent or recording-edge local change.

The local-cycle representation has a decline, optional flat low period and an
independently shaped return. Monotone phase fits permit unequal fall/rise rates;
do not require a symmetric triangle or a fixed recovery duration.

Estimate a candidate's drift and regional loadings from flanking observations
outside that candidate interval. Evaluate the shared regional prediction using
surrounding observations during the interval. Use the same nuisance family and
observations for competing explanations; do not allow a free interior drift
knot or unrelated null model to absorb a complete pocket. Report dependence on
which surrounding observations are used. If flanks are contaminated or local
and regional signals are indistinguishable, return an unresolved comparison.

Use several geometric surrounding comparisons rather than assuming one ring
is quiet. Responding patches remain responding evidence. Preserve the prior
FB2412 patch-82 regional role. A local cycle may coexist with a regional response;
the model must not require an independently quiet neighboring ROI or a
significant pre-subtracted residual before retaining a raw-cycle candidate.

Fast within-block variation is a diagnostic roughness allowance, not calibrated
camera noise. Estimate it outside proposed cycles and compare short-lag and
flanking estimates. Keep instability or contaminated context explicit. Do not
reuse the twenty-second context-residual maximum as a universal rejection gate.
Freeze the loss, complexity penalties, variation checks and decision mapping
using the constructed scenes before the first new cached-recording run. No
per-recording threshold adjustment or calibration against saved positive labels.

### 3. Require consistent observations for spatial support and return

Group neighboring changes using their temporal behavior and retain scale/contact
alternatives. Keep capillary gaps, split/merge contacts and separated lobes
explicit; neither hole filling nor a union of every dark pixel supplies anatomy.
Record diagnostic block extent, field fraction and temporal agreement. Size is
evidence about the explanation, not an automatic large-event exclusion.

Assess fall and return on a **fixed comparison cohort** across phases. A changing
support mask or disappearance of dim pixels cannot manufacture recovery. Keep
the original-ROI raw and saved corrected traces separate from these experimental
block cohorts. The corrected trace is supporting/disagreement evidence, not a
mandatory detection gate or a refitted correction.

Distinguish observed raw rise, restoration of the preceding raw level, relative
local return against a changing field, interrupted return and censored/unresolved
return. Relative return alone does not establish a recovered scientific baseline.
Report alternative onset/return locations as diagnostic ranges, not confidence
intervals. Mark displacement-like evidence without motion-correcting inputs.

### 4. Separate recognition from scientific measurement

Each experimental proposal carries its source, routes, spatial support,
regional comparison, temporal phases, uncertainty and comparison matches.
Possible recognition states are local-cycle candidate, regional/persistent
change, uncertain and unsupported. Missing observations or unresolved context
cannot establish biological absence.

The new proposal outputs always have measurement-ready and burden-ready false.
No scientific amplitude baseline, accepted area, hypoxic contribution or total
is calculated. In particular:

- FB2412 site 20 keeps original-ROI baseline 104–113 and timing 114–182.
- FB2413 keeps the 823–825 timing cue and unresolved measurement baseline.
- FB2412 site 1's saved longer interval and shorter preview stay separate.
- Recurrent pockets do not acquire a shared scientific baseline. Recognition
  context windows are not replacements for individual event/ROI baselines.

## Evaluation without another two-example tuning loop

After the constructed checks, freeze one implementation/settings manifest.
Run it identically on all twelve cached development recordings. Include one
prespecified component comparison: raw-route proposals only, with the same
regional assessment and settings. This measures what the additional local
proposal route contributes; it is not a search over alternate configurations.

Produce one comparison row for every existing view, including zero matches,
uncertainty and quality limitations. Keep old automatic markers as association
cues, not exact true boundaries. Report spatial/time overlap and competing
associations; do not award a hit merely because some unrelated candidate falls
somewhere in the clip. Report duplicate/split/merge alternatives and candidate
counts per recording/minute, so covering known examples with an excessive
catalogue cannot be presented as success.

For the four located positives report proposal coverage and recognition state
separately. For the three rejected targets report whether that target was
promoted, without labelling other events in the clip false. FB2402 permits a
window-presence comparison with user review of the proposed locations; it does
not permit an event-recall denominator. FB2419 permits comparison with no pocket
seen in that window, not automatic negative labels for every block or a camera
noise calibration. Unlabelled views remain descriptive. Do not calculate
whole-field sensitivity/specificity or independent validation accuracy from
these incomplete labels and dependent windows.

Keep passes, misses and ambiguous cases in the final report. Do not change
settings after viewing recording outcomes or replace difficult cases. A miss
on FB2413 or weak FB2412/FB2410 support is reported across the broader set,
rather than starting another special repair on those two recordings. Engineering
completion and biological recognition success are separate outcomes. A later
frozen test on the five reserved recordings needs a separate bounded proposal;
production adoption is not part of this experiment.

## Bounded work items, checks and stopping condition

| Item | User benefit and scope; owner root | Acceptance and stop |
| --- | --- | --- |
| JDET-01 | Pin the twelve caches, thirty view identities, prior decisions and new review without importing false labels. | Cache/source/sample identity and evaluation units agree; twenty unlabelled views stay unlabelled. Stop for source, split or provenance conflicts. |
| JDET-02 | Implement the joint-cycle service beside the existing prototype, using the cached Python environment. | Twenty declared scenes below, coverage/identity safeguards and one frozen settings manifest before recording runs. No package installation, production-code rewrite or scientific measurement. |
| JDET-03 | Apply the frozen primary and the declared raw-route component comparison to all twelve recordings. | At most 24 planned recording runs; all thirty comparison rows and full candidate/coverage accounting, including failures. No recording-specific tuning or reserved data. |
| JDET-04 | Independently verify calculations, preserve sources and present a compact review. | Eight declared verification groups, all-recording summary and at most six expanded cards, linked to existing movies. Report unmet checks and stop before new implementation/adoption. |

Twenty constructed scenes cover: (1) quiet heteroscedastic variation;
(2) coherent regional decline; (3) static capillary structure with intensity
variation; (4) broad reversible field response; (5) local fall/return;
(6) flat trough; (7) slow fall/fast return; (8) fast fall/slow return;
(9) partial neighboring response; (10) local cycle on regional decline;
(11) indistinguishable local/regional changes; (12) local return on a moving
background level; (13) earlier large cycle followed by a small cycle;
(14) recurrence with incomplete intervening recovery; (15) recording-start
truncation; (16) recording-end truncation; (17) dim valid signal;
(18) displacement-like changes; (19) split/merge contacts with capillary gaps;
and (20) missing observations/changing support. Declare the expected coverage,
recognition/uncertainty and return behavior before running them. The checks
test the constructed meaning, not biological accuracy.

The eight verification groups are input/review/split identity; exhaustive
finite/missing domain coverage; independent proposal-score/phase arithmetic;
regional/local ambiguity and model comparability; fixed-cohort return and
missingness; source/frame/coordinate association; primary/component-comparison
and duplicate accounting; and isolation/preservation of scientific outputs.
Independent arithmetic replays are limited to twelve records and the twenty
constructed scenes. Select one record per recording: the first identity-sorted
proposal intersecting its first ID-sorted benchmark window, falling back to the
first recording proposal or a zero-result coverage replay. Freeze this selection
rule before outcomes. These are verification reads, not additional detector
configurations or fits.

Proposed ceiling: **eight active engineering hours, four batches, twenty
constructed scenes, one primary configuration, one component comparison,
twelve recordings, thirty existing views, two engineering repairs, 2 GiB worker
memory and 512 MiB new evidence**. There are 24 planned recording runs and at
most 36 recording-pipeline attempts including repairs. Keep at most 100,000
ledger candidates per configuration across all recordings; reaching this or
another source/time/space/effort/repair limit stops with an explicit preserved
checkpoint, not a silent shortlist or a relaxed threshold.

Use one fixed realization per constructed scene and at most three executions
per scene including repairs (sixty scene executions total); do not expand a
failed fixture into a parameter or random-seed search.

Process one recording and spatial representation at a time, using read-only
cache access and bounded temporaries. Freeze before recording runs; an allowed
repair corrects implementation/memory faults within the agreed method, records
affected outputs and replays within the attempt cap. It does not authorize
post-outcome scientific retuning. Additional repairs, new image reads or broader
analysis require a new decision at the boundary.

The six expanded cards are fixed as cases 01, 02, 14, 19, 23 and 30, spanning the
four located positive examples and the two new whole-window judgments. All
thirty rows remain accessible, with rejected/ambiguous targets highlighted in
the summary. Do not require another frame-by-frame baseline/boundary exercise.
Use existing native media; generate no new videos. Keep findings local, with
no Git transport, external publication, GUI integration or platform migration.

## Scientific preservation and approval

Preserve the burden formula, normalization, strict complete-contribution rule,
source-specific tissue support, individual scientific references, sink/surge
separation, original recordings, automatic results, prior reviews, workbooks,
export formats and MATLAB workflow. Unknown area remains unknown; no partial
burden or imputed zero. Proposed coarse support is not accepted segmentation.

The previous benchmark is closed at its documented quality checkpoint; its
limits are not reset. This proposal is a distinct experimental milestone.
[AGENTS.md](../AGENTS.md) requires: **“Before implementation, obtain approval for
the milestone and its bounded work items.”** The researcher's “continue”
authorizes this promised proposal, not these new detector runs. Approval of the
scope above is needed before implementation. Deferring it leaves the prepared
benchmark and existing workflow available without further processing.

## Approval record

The researcher explicitly approved this bounded milestone on 9 November 2026:
“I approve.” JDET-01 through JDET-04 are authorized within the limits above.
Root works without delegation. The original proposal text is retained as the
reviewed scope; its opening status describes the proposal when written.

## Preserved ledger checkpoint

The twenty constructed scenes pass after two pre-freeze repairs and sixty
executions. An exact full-field-mean cache equivalence check preserves the
tested arithmetic. One numerical configuration then froze before recording
arrays were loaded. Four primary catalogues are complete; the fifth calculation
stopped at 105,921 cumulative seeds (43,811 consolidated candidates), before its
catalogue was written. The frozen guard applies the 100,000 ledger cap to both
counts. No post-outcome detector tuning followed. This is an incomplete
experimental checkpoint, not a completed biological comparison. The separate
[capacity amendment](BOI_JOINT_DETECTOR_LEDGER_AMENDMENT.md) awaits approval;
source processing is stopped and the frozen numerical files remain unchanged.

## Numerical completion and reporting checkpoint

The approved ledger-capacity amendment allowed all 24 numerical passes to finish
in 25 attempts while preserving the earlier four outputs. The detector and
settings stayed frozen. The comparison-table worker then reached the 2 GiB
memory guard while loading nested catalogue metadata; no comparison file was
written. Numerical outputs remain complete, but independent arithmetic reporting
and six-card delivery are incomplete. A separately prepared
[reporting-only memory repair](BOI_JOINT_DETECTOR_REPORTING_REPAIR.md) awaits
approval; it does not authorize another detector run or scientific change.

## Final delivery

The separately approved capacity amendment and reporting-only repair are now
complete. All 24 numerical passes, thirty comparison rows, independent checks
and six fixed cards are delivered. The detector remains frozen and unadopted;
the [results assessment](BOI_VIDEO_JOINT_DETECTOR_RESULTS.md) documents short
model intervals, competing proposals and unresolved spatial/biological
discrimination. Both configurations associate with all four recognized target
locations; neither establishes complete event detection or burden readiness.
All preserved input/numerical/output hashes match. Six reporting workers,
25 recording attempts, sixty constructed executions and four batches were
used, with two pre-freeze numerical repairs and the approved reporting repair.
No further implementation, reserved-recording test or scientific adoption is
active. Earlier proposed/checkpoint language above is retained as history.
