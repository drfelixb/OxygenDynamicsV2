# Original versus new pocket detection, followed by a strategy audit

11 November 2026. **Proposed evaluation; execution approval pending.**
POCKET-COMPARE-01; owner root, no delegation. The
[previous prototype experiment](BOI_VIDEO_LOCAL_REGIONAL_BASELINE_RESULTS.md)
remains closed and unadopted. This is a comparison of saved results, with no
detector revision, parameter tuning or production adoption.

The sequence is **paired comparison → strategy audit with the researcher →
explicit decision about further work**. Preparing or later approving this
comparison does not authorize another detector implementation. The
[initial strategy audit and decision questions](BOI_DETECTOR_STRATEGY_AUDIT.md)
are part of this proposal; their final assessment needs the paired results.

## Question and comparison units

Determine where the new prototype retains real pockets missed by the original,
loses original detections of real pockets, creates or removes false detections,
and improves or worsens onset/recovery and episode identity. Include review
burden and unresolved cases. Software arithmetic passing is not evidence of
better biological detection.

“Original” means the saved automatic MATLAB results from the completed batch,
before manual exclusions or timing edits. Freeze the exact per-recording source
hashes; do not rerun today's MATLAB code and call it the historical original.
Keep native detected intervals and automatically refined measurement intervals
separate. Existing reviewed decisions remain an evaluation reference, not the
original detector output. Original automatic QC/export-eligibility flags, where
saved, must be retained as their own readout; missing flags are unknown, not
silently assumed to pass. Baseline/amplitude availability is not detection QC.

“New” means the frozen local/regional/reference prototype's twelve completed
outputs, freeze revision two. Retain episode groups, source members, alternatives,
uncertain and unresolved branches. Evaluate its complete-labelled assertions
and its wider proposal coverage separately. An uncertain proposal can provide
coverage or require review; it is not an accepted complete detection.

Planning metadata accounts for **3,530 original automatic sink records**, versus
**40,270 new dependent episode proposals** and 128,931 source candidates. These
are not comparable biological counts. The existing six displayed source IDs
remain diagnostic examples, not the test of whether any candidate detected the
same pocket. Search all saved outputs for associations.

## Fixed recordings, sources and media

Use only **FB2311, FB2317, FB2319, FB2402, FB2403, FB2405, FB2407, FB2408,
FB2410, FB2412, FB2413 and FB2419**. Preserve the five reserved recordings
**FB2420, FB2316, FB2320, FB2404 and FB2406**, with no reserved payload hashing,
array reads, movie review or use in selection. Existing split receipts suffice.

Use the original `Events.json`, `Info.json` and saved `Footprints`/`NativeCounts`
for these twelve recordings, plus the current prototype's episode/branch
ledgers. Selectively read original saved detector QC variables only if needed
to reconstruct its existing automatic eligibility; no new QC calculation.
Raw/corrected saved traces can explain a disputed comparison, but no correction,
baseline fit or amplitude is recomputed. Reuse prepared native media in place.

The [planning inventory](../../reference-validation/boi-original-new-comparison-proposal-20261111/input-inventory.json)
pins the source identities and thirty existing views. Their available media
cover **8,044 unique frames of 14,378**, after removing overlapping time windows.
The twelve detector-independent systematic windows cover 4,320 frames: one
360-frame full-field clip per recording. Available media are not equivalent to
expert-reviewed coverage. Do not imply every pocket in every full recording
has been biologically validated.

## 1. Associate outputs across complete recordings

Run one fixed, read-only association pass per recording. Match source clocks,
recording IDs and native coordinates before comparing outcomes. Preserve all
original/new objects, including no association, one-to-one, split, merge,
duplicate, ambiguous and unavailable spatial/timing evidence.

Map original native indices to the 128 × 128 comparison grid explicitly, with
the original row/column convention verified. Retain native footprint hashes
and original pixel occupancy within each 4 × 4 block. Prefer observed connected
new support and its observed deficit times; keep core and nominal union support
as separately named diagnostics. A nominal mask or bounding-box intersection
does not establish the same pocket. Missing observed support remains unknown.

Candidate associations require nonzero observed spatial intersection and time
overlap. Store spatial Dice/containment and temporal overlap/IoU continuously.
A predeclared quarter-overlap flag (Dice and temporal IoU both at least 0.25)
is only a technical correspondence/review-selection aid, not a biological hit
criterion. Do not tune it after outcomes or use a huge containing interval to
claim successful full-episode detection. Open/censored endpoints do not get
filled with the whole recording; use known observed support for association
and retain endpoint missingness.

Retain the association graph instead of forcing one-to-one assignments.
Several old fragments within one real pocket count as one recognized pocket
plus a split/timing problem. A new proposal merging distinct recovered pockets
does not become several correct complete detections merely by overlapping them.
Multiple proposals for one pocket do not increase the true-pocket count.
Do not derive false detections or misses from disagreement alone.

## 2. Establish a limited video reference before judging the methods

Reuse existing judgments at their actual authority: four located positives,
three rejected targets, two window-presence/absence judgments, one contested
timing view and twenty unlabelled views. A window where no pocket was seen
does not label every small proposal as false; a pocket-present window does
not validate every source. Preserve prior familiarity in the review record.

Propose a reference-first inspection of the **twelve existing systematic
full-field clips**, before showing either method's overlays. Record visible
pocket episodes, broad regional responses and uncertainty; mark approximate
location and onset/recovery brackets where observable. Recording-edge or
incomplete recovery stays censored. These are benchmark annotations, not
scientific baseline choices, accepted area masks or saved event-review edits.
Do not ask for a universal exact frame or another second-by-second rule.

Then inspect at most **24 paired disagreement examples**, up to one from each
method per recording, inside the already prepared media. Freeze deterministic
ID-hash ordering and fallback rules before reading association outcomes. Select
weak/no-correspondence original events and new complete-labelled proposals;
if a stratum is empty, use an explicitly labelled shared/timing-disagreement
fallback, then an uncertain proposal. Never replace a failed example with an
attractive success. A/B method names can be hidden during comparison, without
claiming full blinding: footprints and familiar examples may reveal the method.

Reuse the existing review pages/media; no new standalone GUI or video renderer.
At most **36 paired review cards**, **60 new episode judgments** and **90 minutes
of researcher review**. Inspect the twelve systematic clips before spending
the remaining review budget on detailed disagreements. Existing labels are
reused without demanding they be annotated again. Stop at the review cap;
unreviewed regions, dense/partly annotated windows and uncertain references
remain explicit. Do not infer their labels or treat unanswered review as approval.

## 3. Report paired detection and timing outcomes honestly

For confidently identified reference pockets, report each method's located
episode, split, merged, proposal-only/withheld or missing result. Include pockets
visible in the systematic clips that **both methods miss**. A new unresolved
branch or withheld complete detection is not a successful automatic detection.

For reviewed detector assertions, report confirmed local pocket, confirmed
non-pocket/regional response, and unresolved biological interpretation. Count
false proposals needing review separately from falsely asserted complete
detections. Show original saved automatic/QC states and new complete/uncertain
states together; do not make one method look better by discarding its failures.
Withheld predictions remain in the automatic-coverage accounting. Uncertain
human references remain unknown and their number is reported.

Compare timing only for the same recognized episode, with pixel-support
differences visible. Preserve original native and refined intervals. Relative
to human onset/recovery brackets, report whether a boundary lies inside the
bracket and its signed distance outside it; do not invent an exact truth frame.
Show truncated duration, excessive extension, splitting and overmerging. Missing
or censored boundaries stay unavailable. Detection context is not a scientific
measurement reference; a missing amplitude baseline cannot erase a real pocket.

Deliver a twelve-row recording overview, the complete association ledger,
all-thirty-view comparison, scoped review outcomes and paired timing plots.
Report reviewed spatial/time coverage, unresolved fractions and review time.
Summarize per recording before pooling. Distinguish systematic-window results
from deliberately selected disagreement/challenge cases. Do not estimate
whole-recording sensitivity, precision, false-positive rate or confidence
intervals from incompletely labelled or purposively selected material. This
is a development comparison, not an independent test on the reserved recordings.

## 4. Audit the strategy before any detector work resumes

Complete the [audit decision record](BOI_DETECTOR_STRATEGY_AUDIT.md) with the
paired results. Ask whether the new method delivers a useful gain over the
original, where it regresses, and whether remaining errors originate in proposal
coverage, pixel selection, preprocessing, episode assembly, regional context or
measurement readiness. Cause categories are hypotheses unless a controlled
comparison supports them; no ablation or new fit is included here.

Examine cumulative effort, repeated repair/approval cycles, reliance on familiar
examples, the difference between code checks and biological validation, coarse
resolution limits and the practical CSV → run → export goal. Record measured
worker time separately from unknown engineering/researcher time; do not sum
nominal milestone budgets as actual effort.

Present genuine options: keep the original and stop/defer detector replacement;
target a demonstrated failure in the original; retain a narrowly useful part
of the prototype; or propose a different video-based approach with explicit
reference-data and native-area requirements. Language/platform selection comes
after demonstrated scientific benefit. No option is implemented automatically.
The researcher reviews the audit before any subsequent method proposal.

## Bounded work items and acceptance

| Item; owner root | User benefit and scope | Acceptance and stopping condition |
| --- | --- | --- |
| OVC-01 | Freeze the historical original, new readout policies, split, coordinates and selection rules. | Hashes/identities match; automatic/reviewed and native/refined timing remain distinct. Stop on missing or conflicting source authority. |
| OVC-02 | Associate all saved outputs over the twelve complete recordings. | Every source object accounted for; splits/merges/unknowns retained. Associations are not labelled biological hits. Stop at graph/resource limits. |
| OVC-03 | Prepare the bounded reference-first and paired review using existing media. | All twelve systematic clips represented, selection frozen and missing labels explicit; no unbounded annotation request. |
| OVC-04 | Summarize confirmed misses, false detections, timing and review burden. | Common reference units and coverage denominators; eighteen deterministic saved association/readout checks plus all thirty coordinate/view checks. No invented global accuracy. |
| OVC-05 | Audit the detector strategy and stop for discussion. | Evidence, limitations, cumulative cost and keep/narrow/stop/redesign options are explicit. No next detector milestone or adoption starts. |

Use **six active engineering hours**, four sequential batches (sources/matching;
review preparation; paired outcomes; strategy audit/report), **one engineering
repair**, **2 GiB worker RSS** and **256 MiB new evidence**. Researcher review is
separately capped above; waits are recorded without resetting used effort.
Use one fixed association configuration, twelve planned recording passes/
eighteen attempts, six reporting-worker attempts, at most 1,500,000 saved
object/hypothesis readouts and 2,000,000 association links. Stream one recording
at a time; do not copy caches or existing movies.

Freeze sixteen constructed association/readout cases before execution: exact
match, no spatial match, no time match, partial-block coordinate mapping,
column-major conversion, one-to-many split, many-to-one merge, duplicates,
nominal-support-only overlap, unresolved source with a retained hypothesis,
uncertain versus asserted detection, missing/QC-unknown input, left censoring,
right censoring, timing brackets and overlapping-window denominator accounting.
At most two executions each: **32 constructed checks**. These test comparison
arithmetic, not biological validity. Select one saved verification unit per
recording plus the six original fixed examples, with an explicit missing-unit
check rather than a substitute. No detector/profile/grouping fit is run.

Stop at source, effort, memory, storage, attempt, graph, repair or review caps;
preserve completed output and unprocessed IDs. After freeze, IO/memory repairs
require decision parity. No threshold/rule tuning against comparison outcomes.
No new original-image decoding, native segmentation, movie encoding, MATLAB
analysis/statistics/export run, package install, commit/push or publication.

## Protected science and approval

Preserve the burden formula, normalization, strict complete contributions,
source-specific support, sink/surge separation, original recordings, automatic
and reviewed results, individual references, reference-age/recording-start
rules, workbooks and export formats. No accepted amplitude, native area,
duration, burden, total, partial sum or imputed zero area is calculated. Keep
FB2412 site 20's baseline 104–113 and timing 114–182, FB2413's cue 823–825 and
unresolved measurement baseline, and all saved not-pocket exclusions unchanged.

The alternative is to stop detector research now and retain the existing
MATLAB workflow. A smaller existing-label-only comparison can be deferred as
an option, but cannot answer broader miss/false-detection questions.
This request authorizes planning and the initial strategy review only.
[AGENTS.md](../AGENTS.md) states: **“A request for a plan authorizes planning,
not implementation of the plan.”** Approval of OVC-01 through OVC-05 is required
before running the comparison. Further detector implementation additionally
requires the subsequent strategy discussion and a separate explicit decision.
