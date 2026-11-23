# Broader BOI workflow plan

**Current strategy, 5 November 2026:** Felix prioritizes complete-event detection
quality and approves the optional baseline–dip–recovery implementation preview.
[GitHub issue #3](https://github.com/drfelixb/OxygenDynamicsV2/issues/3) was updated
before coding. [Active scope](BOI_WHOLE_EVENT_PREVIEW.md): existing reviewer,
explicit experimental settings, synthetic checks and eight cached examples.
Production adoption, spatial-detector replacement and cohort reruns remain
separate. Earlier proposed-next-milestone sections below are historical.

Reviewed 30 October 2026 against development checkpoint `5408db9` and the
current implementation. Planning only: no implementation is approved by this
review. The scientific inspection stays stopped. The shorter FB2412 659–672
candidate remains a preview, and the saved longer review and area draft remain
preserved. Experimental area cutoffs are not adopted.

**First milestone approved, 30 October 2026:** Felix approved the two-item export handoff/reopening scope below. It is being implemented under WORKFLOW-CLOSE-01; following milestones remain proposals. The source review itself did not authorize them.

**First milestone delivered, 31 October 2026:** Both approved items are verified in local dev.11: automatic postprocessing handoff and reopening a completed original export folder. Current portable 214/214, focused desktop 3/3 and native selection/cancel checks pass; the saved 17-recording export opens in 0.484 s with unchanged availability and scientific artifacts. See `reference-validation/boi-workflow-close-20261030/verification.json`. Implementation is stopped. The reviewed-burden GUI and following work below remain proposals requiring their own approval. No additional commit/push or package was performed.

## Intended scientist workflow

**Load CSV → check setup → run ready rows → export together → postprocess.**

Individual-pocket review is optional. Reviewing every recording, event,
reference or frame must not become a prerequisite for exporting available
measurements. An unresolved required contribution still withholds the complete
recording burden and every normalized version. Other measurements and missingness
can be exported without resolving every scientific question.

Reuse the existing editor, queue, saved-run services, stats engine and export
formats. Keep the approved detector, correction, reference policy, burden formula
and normalization frozen during workflow work. No new pipeline or export family.

## What the plan review changed

The original proposal was too broad for a finishing milestone. It mixed already
working features, optional reviewed exports, basic reopening and future
reliability work. It is replaced by the narrower scope below.

| Finding from current source | Consequence for the plan |
|---|---|
| Minimal CSV/shared settings, optional metadata, queue execution/history and automatic combined export already exist. | Treat these as compatibility requirements, not new development tasks. |
| The GUI stores the last combined export in `State.StatsResult`; its opening controls depend on that window state. The completed export has a saved receipt, but no existing-export load action was found. | Add an explicit way to open a completed export after reopening MATLAB, without running statistics again. |
| `exportBOIReviewedBurden` writes a separate burden workbook/CSV/MAT bundle. It does not revise every table in the automatic combined statistics workbook. No caller connects it to the batch GUI. | Make the distinction clear now; give optional reviewed-burden GUI integration its own following milestone. |
| Existing inputs, execution and result matching already have separate states. Analysis completion does not establish burden completeness. | Keep setup readiness, execution completion, export completion and burden availability visibly separate. Do not replace them with one ambiguous “Complete” flag. |
| Queue/export plans bind explicit selections and invalidate confirmation when inputs change. | Keep these source/selection safeguards. Do not turn wording about fewer clicks into permission to remove them. Scientific pocket review is a different activity. |

Source anchors: `openBOIBatchEditor.m`, `readBOIBatchCSV.m`,
`prepareBOIBatchQueue.m`, `runBOIBatchStats.m`, `loadBOIBatchHistory.m`,
`exportBOIReviewedBurden.m` and `helpers/aggregateOxygenRecordingBurden.m`.
These are source-review findings; no new native GUI walkthrough or numerical
reanalysis was performed for this plan review.

## Already implemented: preserve rather than rebuild

- Only `Paths` is mandatory in the CSV. Sampling rate, pixel size and explicit
  support choice can be supplied once in shared settings or as row overrides.
- Biological/descriptive labels, custom fields and stimulation metadata remain
  optional. Text identifiers and leading zeros remain text.
- Row checks, source holds, explicit Run, sequential attempts, completion
  receipts, retry/history and stop-after-current already exist.
- Selected saved recordings can be reopened without checking unrelated rows.
- Completed runs can be collected through the existing automatic stats/export
  service. This uses the current approved calculations, including versioned
  pre-episode references when applicable, without applying manual decisions.
- Saved manual recognition/event results can be applied by the separate
  reviewed-burden exporter. Drafts/previews are not saved decisions.
- Complete burden remains unavailable when an included contribution is missing.

Do not add mandatory fields or another review stage as a side effect of this
work. Keep input readiness, run completion, exported-file availability and
measurement completeness distinct, using existing contracts and values.

## Delivered first milestone: export handoff and reopening

Internal ID WORKFLOW-CLOSE-01; proposed owner root, without delegation.
User benefit: obtain the normal automatic combined export, understand which
existing outputs to use, and reopen that export in a later session.

There are two implementation items only:

**1. Clarify the existing automatic export handoff.** Label the current batch
export as automatic results under the approved calculations. Explain that saved
manual decisions are applied only by the separate reviewed-burden exporter.
Use the existing export details/status/path controls and analysis manifest to
identify recording and event outputs, units, reference source, area/time
normalization and unavailable-value counts. Give a short “start here for
postprocessing” route based on the existing measurement dictionary and sheets;
do not add new endpoints, rename existing fields or choose a new scientific
measurement definition. A failed export, completed export and unavailable
burden must have different messages. Successful export must remain possible
when burden is unavailable.

**2. Reopen an existing completed combined export.** Let the scientist select a
previous combined-export folder/receipt and use the existing workbook/folder
opening controls. Validate the completion receipt, required files, contained
paths and saved identities before presenting it as a completed saved export.
Give an actionable error for missing/incomplete or incompatible receipts. Do
not rerun statistics, overwrite files, read source movies or silently re-export.
Distinguish receipt/file validation from revalidation of original recordings;
do not claim that source bytes were rechecked when they were not. A portable
export-history database or automatic folder search is not part of this item.

Compatibility requirements: the minimal CSV route, optional labels, explicit
shared settings, source/selection confirmation invalidation, row holds and
existing output formats/calculations must continue to work. Navigation and
wording can be adjusted where needed for these two items. Broad layout redesign,
queue/CSV schema redesign, changes to confirmation guards, new metadata fields,
reviewed full-statistics calculation and scientific method changes are outside
this milestone.

Acceptance uses a finite set of cases:

1. A minimal CSV with blank optional fields reaches the existing ready/export
   route without introducing mandatory descriptive labels or pocket review.
2. A completed synthetic combined export opens its exact workbook/folder in the
   current session and after reopening the editor.
3. Missing, incomplete or incompatible saved-export receipts are rejected with
   an actionable message and no new export directory or stats run.
4. Complete and unresolved-burden examples show the correct existing values or
   unavailable reasons; no partial sum, false zero or rejection of the whole
   export merely because burden is unavailable.
5. The handoff correctly distinguishes automatic combined statistics from the
   optional burden-only reviewed bundle. Drafts/previews are never applied.
6. Existing source-selection, hold, metadata roundtrip and no-overwrite checks
   remain passing. Reuse those checks rather than adding duplicate tests.

Proposed budget: four active engineering hours, at most three bounded MATLAB
check starts, one ordinary desktop walkthrough, two repair passes and 100 MiB
new synthetic/test evidence. Use existing synthetic fixtures and at most one
named existing combined-export receipt for integration. No new source-image
reads, copying of full recordings, cohort/detector rerun or 17-recording export.
If existing evidence is insufficient, report that limit without expanding the
campaign. Stop at the two verified deliverables and researcher feedback.

## Delivered: optional reviewed-burden export from the GUI

Internal ID WORKFLOW-REVIEWED-EXPORT-01; approved by Felix on 31 October 2026. Delivered 1 November 2026 in local dev.12 with 222 portable, six focused desktop and a native synthetic workflow passing. See `reference-validation/boi-reviewed-export-gui-20261031/verification.json`. The following describes the delivered scope. Four engineering hours, finite synthetic checks and one native walkthrough; no new 17-recording export. Connect the existing
`exportBOIReviewedBurden` service with a small, explicit selection/summary of the
source combined results, saved review revisions, approved event artifacts and a
fresh destination. Preserve automatic outputs and show exactly what is applied.
Do not silently pick a “latest” judgment, use a draft/preview, or imply that all
pockets have been adjudicated. Unreviewed/uncertain detections remain included
under the current policy; retained missing contributions withhold strict totals.

This produces the existing **reviewed burden-only companion**, not a replacement
for all automatic statistics. Recomputing reviewed counts, summaries or unrelated
sheets across the full analysis would need a separate explicit scope. Prepare
its finite checks and budget before implementation. It does not block ordinary
automatic batch export.

## Following proposal: reliability and reproducible handoff

Internal ID WORKFLOW-RELIABILITY-01; not approved. Review evidence already
covering resume/reopen, stop-after-current, failure, changed settings, long paths
and output collisions. Repair demonstrated gaps only; do not rebuild working
history/queue services. Moved or unavailable storage and future installation
handoff can be considered here with a finite agreed fixture set. Package,
release/licensing and broader platform claims remain separate decisions. Propose
a budget after the first milestone, without launching an infrastructure project.

## Separate scientific track: comparable hypoxic burden

Internal ID BURDEN-METHOD-PLAN-01; not approved. Retain the formula and
normalization. Establish one explicit measurement contract for event boundaries,
individual-event references and time-varying area, grounded in the original
publication/script and approved changes. Distinguish detector-defined duration
from full trace recovery, and raw/local signal from correction/background effects.

Any method proposal needs prespecified representative examples and acceptance
criteria: recurrent and recording-start cases, clear negatives, clear pockets
and recovered context. Do not select a cutoff to rescue one pocket or obtain
complete totals. Adoption requires numerical impact review and explicit
scientific agreement. A later all-recording export is a separate request; never
use partial sums or discard genuine but difficult events to complete burden.

The last preserved reviewed 17-recording export has no complete recording
burdens. Workflow changes do not fill those measurements or guarantee that every
recording can yield a valid complete burden.

## Decision and stopping point

Recommended next implementation is **export handoff and reopening**, limited to
the two items above. The reviewed-burden GUI, broader reliability and scientific
tracks remain separate proposals. This review edits planning only and starts no
implementation, MATLAB run, scientific review or new Git transport.
