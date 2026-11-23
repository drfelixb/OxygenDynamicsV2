**Delivered locally, 13 November 2026.** The compact workbook milestone is complete after its explicitly approved corrections. All eight frozen families have passing latest results; source preservation and final sheet layouts are recorded. See [delivery and limits](BOI_COMPACT_WORKBOOK_DELIVERY.md). No active follow-on run; historical scope/checkpoint entries below are preserved.

**Current checkpoint, 13 November 2026:** seven of eight final families pass after the explicitly approved launch extension. Both synthetic exports and GUI checks pass, but a contradictory-review guard and body text layout still need the [prepared final correction](BOI_COMPACT_WORKBOOK_FINAL_CORRECTION_PLAN.md). All cumulative allowances are spent; further execution is held. This milestone is not complete. Earlier dated entries preserve approval history.

**Current checkpoint, 13 November 2026:** implementation is present but acceptance is incomplete. Both approved MATLAB starts are used. A one-line assertion correction is prepared, not applied; [the narrow verification extension](BOI_COMPACT_WORKBOOK_VERIFICATION_EXTENSION.md) awaits approval. No further implementation or numerical verification proceeds at this boundary. The original approved scope below remains the historical contract; no budget resets.

# Compact Excel workbook: bounded implementation and tests

13 November 2026. **Explicitly approved; implementation and testing active.** COMPACT-EXPORT-01, owner root, four sequential batches,
no delegation. This puts the existing six-hour scope into an execution-ready
plan; it does not add a new budget or reopen completed baseline/signed-selection
work. The [revision-31 contract](BOI_COMPACT_EXPORT_PLAN.md) governs values and
interpretation. [Signed selection is delivered](BOI_REVISION31_DELIVERY.md).
The [finite manifest](planning/boi-compact-workbook-execution-proposal-20261113.json)
records the frozen tests, source boundaries and unchanged limits. The researcher explicitly approved this scope on 13 November 2026.

## Practical result

From an opened completed automatic export, choose or retain compatible saved
reviewed results, choose a new destination, and export one compact workbook for
postprocessing. Show the source/review version and allow changes. Open the result
on Events, with a direct open-file/folder action. Reuse existing batch and export
services; no extra mandatory CSV fields or individual-event review.

This is a **saved-value exporter**. It does not run detection, select a baseline,
calculate amplitude, geometry, AUC or burden, apply new review decisions, or
regenerate source statistics. Original files and detailed export formats remain
available and unchanged. Older sources retain their actual values/policy; they
are not relabelled revision 31. A later request to obtain fresh revision-31 values
for real completed recordings is an upstream statistics/export step, separate
from this workbook milestone.

## Workbook contract

| Sheet | Contents |
| --- | --- |
| Events | One row per original automatic detection, including reviewed exclusions. Repeat recording/mouse/session/condition identity; show automatic and reviewed amplitude, saved duration, mean area and contribution side by side, with exact burden-used ingredients when different. Retain sign, reference/timing/area flags, diameter/circularity, source-bound signed AUC, automatic native-gap QC and review provenance. |
| Recordings | One recording and event type; metadata, saved exposure/calibration/support, counts/rates/density/occupancy, automatic/reviewed normalized burden, negative/available/required/excluded counts and source/comparison status. |
| Sites | Recording/type/site identity, automatic saved event counts/recurrence and availability. Counts do not disappear because amplitude is unavailable; automatic recurrence is not relabelled reviewed. |
| TimeSeries | Recording/type/frame identity, original clock, counts/density, union area/tissue fraction and matching saved automatic/reviewed area-normalized sink burden series. No concatenation across recordings or extra per-minute factor on each point. |
| Availability | Metric-specific missingness, quality, sign, excluded/not-applicable/not-assessed states, absent reviews, source failures and comparison reasons, with identity. Overlapping reasons are not summed as disjoint counts. |
| Definitions | Column meanings, units/scale/sign, area/time/signal normalization, comparison scope/restrictions/counterparts, source mapping and versions/evidence. IDs and flags are not biological magnitudes. |
| Phases, optional | Only explicitly supplied phase names and recording-relative bounds, with identity/source/notes. No event assignment, splitting, protocol inference or phase burden. |

Keep one header row, filters, legible widths/units and frozen header/identity
columns. Put primary paired measurements near the identifying fields and detailed
qualifications/provenance to the right. Freeze the exact column/source map in
CEX-01. IDs remain text, including leading zeros; numerical values retain source
precision. Percent-valued amplitudes are ordinary numbers, without another factor
of 100 from Excel percentage formatting. No macros, external links, merged data
cells, scientific Excel formulas, extra summary sheets or per-mouse tabs.

## Four implementation batches

| Item; owner root | Bounded work and user benefit | Acceptance and stop |
| --- | --- | --- |
| CEX-01, batch 1 | Freeze source/table/column mapping, typed keys, metadata associations, reference/review/version rules and the small-data read whitelist. Reuse existing registry and batch-row/recording crosswalk. | Every output quantity has an exact source and definition; ambiguous/conflicting joins stop. Missing optional information has an explicit status. No scientific calculator is needed. |
| CEX-02, batch 2 | Implement the small saved-source adapter, pure table projection and native MATLAB XLSX writer/formatting, plus a source-bound receipt at a new destination. | Preserve every original detection and actual saved value/sign/missingness; pair only compatible reviews. Source files stay byte-identical. No calculation or source overwrite is hidden in writing. |
| CEX-03, batch 3 | Connect one compact-export action to the existing editor/stats source and export controls. Remember compatible review choices per batch and allow changes. Reuse optional metadata entry rather than build a new editor. | Correct source/version is visible; changing it invalidates stale prepared output. Cancel/error restores controls and the prior successful export. No event-by-event interaction or new analysis run. |
| CEX-04, batch 4 | Run the eight frozen constructed/table-level test families, existing-format input/readback checks and programmatic GUI checks; inspect the synthetic workbook layout and report preservation. | All selected checks pass within the limits below, then stop. No broader regression/case campaign, real-data export, package or release follows automatically. |

Only this milestone can be active if explicitly approved. Scientific code for
the detector, correction, references, masks/timing, event measurements, burden
product, normalization and statistical weighting is protected from edits.
Production additions are limited to source validation/projection, workbook
writing/formatting, GUI binding, selection persistence and provenance. Reuse
existing MATLAB table/XLSX and export services; no package installation, Python
production dependency, platform migration or new scientific framework.

## Identity, sources and review behavior

- Every data row retains RecordingID, Experiment, Mouse, supplied SessionID and
  Condition plus event type and relevant site/event/frame IDs. Keep available
  DrugID/Genotype/Promoter/PuffStim and optional field, acquisition, treatment,
  control and note metadata. Unknown remains unknown; no filename/Labguru inference.
- Join by exact saved recording/source context and event key, never by mouse,
  display label or row position. Preserve source-analysis/export identity; do not
  turn another analysis of the same movie into another mouse or biological replicate.
- Use selected workbook tables, receipts and explicitly whitelisted small MAT
  aggregates only. Prefer scalar event metrics from saved burden/native-event
  tables. Do not load raw/ROI traces, site matrices, masks, images or whole MAT
  files. Missing positive-event core inventory stops that source join. Missing
  optional secondary fields remain unavailable with reasons.
- Only the contract's elementary count groupings, existing unit conversions and
  vector-to-row projections are permitted when a saved scalar is absent. For
  example, site counts/rates must name their exact saved-event inventory and
  unchanged count/time definition. Do not replace a different saved count basis,
  create mouse/session averages, or derive a new burden total in the exporter.
- Keep the original twenty-second local-reference meaning, separate earlier
  recording reference, mean native area, saved duration, signed contribution and
  original-reference AUC distinct. Do not replace an event area by an inherited
  site mean, relabel an automatic AUC reviewed, or turn native gaps into recovery.
- A selected reviewed snapshot must match its parent automatic source, event
  inventory and compatible policy. Copy selected values, exclusions and matching
  reviewed curve; do not call the reviewed calculator or choose the newest file.
  An excluded row remains visible with reviewed contribution excluded/not applicable.
- In a compatible reviewed snapshot, retained unchanged values carry **No manual
  review**. If no compatible reviewed snapshot exists for a recording, reviewed
  values remain unavailable with that reason; do not fabricate an automatic fallback.
- Remember selected snapshot/revision identities and hashes per batch and automatic
  source. Use existing state storage, or a separate compact-selection sidecar
  beside the batch CSV if needed. Updating UI selection never edits the CSV's
  scientific rows, original results or saved review artifacts. Changed sources
  require explicit reselection/validation; an unwritable selection store is reported.
- Control links and supplied phase annotations remain optional metadata, with
  explicit batch-row/recording association. No contrasts, grouping changes,
  session pooling, inferred phase timing or automatic event assignment.

## Normalization and comparability acceptance

Copy these existing saved quantities without recalculating them:

`contribution_i = amplitude_percent_i * event_mean_area_um2_i * duration_s_i`

`normalized_burden = sum(contribution_i) * 1e6 / recording_area_um2 * 60 / recording_duration_s`

Retain finite signed contributions and negative flags under their saved policy.
Copy complete positive/zero/negative totals and genuinely unavailable totals;
never create a partial or positive-only total. Show actual analyzed area/time,
calibration, support/reference/selection versions and contributor counts.

Definitions/Availability distinguish recording-area/time-normalized burden and
rates, area-only density/occupancy/curve values, calibrated intrinsic event
size/duration, reference-normalized optical amplitudes, and unnormalized counts
or raw intensities. A normalized value is not automatically biologically
comparable. Do not divide event area/duration by recording exposure, apply a
second factor of 100, time-normalize a saved pointwise curve again, or change
equal-recording/equal-mouse weighting. Comparison warnings are descriptive,
not new scientific exclusion gates. Preserve source qualifications rather than
claim comparability of actual mice/recordings from these software tests.

## Eight frozen test families; at most 24 total evaluations

The manifest names one planned function per family. First run each once;
rerun only failed/affected functions within the same limits. Do not rerun the
revision-31 suite or historical saved-example drivers.

| Family | Required checks |
| --- | --- |
| S1 Identity and metadata | Multiple constructed mice/recordings/sessions/conditions, repeated local IDs, leading-zero IDs, optional fields/control/phase mappings and unknowns. Each exported row keeps exact identity. |
| S2 Zero, missing and review states | Analyzed zero differs from unavailable/unprocessed. Not applicable, excluded, not assessed and missing remain distinct. No compatible review differs from a compatible unchanged value labelled No manual review. |
| S3 Signed completeness | Copy positive/negative/zero contributions and sign/count fields exactly. Retained missing ingredients keep the saved total unavailable; explicit reviewed exclusions remain separate. No finite-only or positive-only sum. |
| S4 Reference and secondary provenance | Original/derived/reviewed versions, actual burden ingredients, own-reference signed AUC, absent reviewed AUC and unchanged automatic native gaps retain their meaning. |
| S5 Conflicts and source preservation | Duplicate/conflicting keys, wrong review parent/policy, tampering, source changes and invalid optional links are rejected or explicitly reported as specified, before writing incompatible output. No original bytes change. |
| S6 Units, precision and definitions | Every numeric output has units/normalization/comparison meaning; exact IDs/counts/statuses, signed values and numerical tolerance; typed strings/leading zeros; no extra 100 or A/T factor and no scientific formulas in XLSX. |
| S7 Source/clock/sheet contract | Six core sheets, optional Phases only when supplied, allowed source reads, native format compatibility, original clocks and the matching reviewed curve. A complete constructed saved curve reconciles with its matching saved total in tests only; finite points cannot replace an unavailable total. |
| S8 GUI and file recovery | Existing opened-source route, remembered per-batch review selection/change, fresh destination, cancel, stale selection and validation failure restore state/controls and preserve the previous successful export. Inspect the synthetic layout; no pocket viewer or biological review. |

Use independent declared source tables/scalars as the expected values. Test the
exporter with scientific-calculator/image-reader entry points disabled so an
accidental call cannot pass. Source fixtures may supply table objects directly
and small native MAT/CSV/JSON bundles; workbook input compatibility can reuse the
already produced synthetic revision-31 export. Source/table maps are frozen before
the first numerical run. Maximum per constructed fixture: four recordings,
32 events and 300 frames per recording. No real recording payload is a fixture.

For complete XLSX input-route coverage, at most one small constructed detailed
source workbook may be written; it counts against the same four-attempt cap.
Plan two compact output files (automatic-only six sheets; selected reviewed values
with supplied Phases metadata) and reserve the fourth attempt for a failed/affected
writer retry. GUI validation/cancel tests do not dispatch the XLSX writer; any
actual writer dispatch counts, even if it fails. No extra fixture workbooks or
routine comfort reruns. Upstream signed tests and unused budgets do not transfer.

Numerical round trips use `1e-10 * max(1,abs(source))`; IDs, counts, states,
versions and source-preservation hashes match exactly. Readback checks cover
values as well as sheet order/headers/filters/frozen identity columns and source
links in the receipt. Preserve source precision; readable formatting is display
only. These tests validate exporting, not fresh scientific arithmetic, detection
performance, anatomical support or biological reference suitability.

## Unchanged proposed limits

| Limit | Maximum |
| --- | --- |
| Active engineering effort, including repairs/tests/closeout | 6 hours |
| Sequential work batches | 4 |
| Combined routine code/test/harness repairs | 2 |
| Constructed scenario families / total evaluations including retries | 8 / 24 |
| MATLAB starts, initial plus any restart | 2 |
| New XLSX writer attempts, including source fixture, failures and retries | 4 |
| Worker process-tree RSS | 4 GiB |
| New evidence/scratch, including fixture inputs and metadata | 100 MiB |
| Total new compact-workbook output | 25 MiB |
| Real recording inputs / individual biological reviews | 0 / 0 |

Count all attempts from the outset. Use the known short isolated scratch-path
launcher with memory/time/output guards. Check aggregate storage as well as
per-output size; no whole-MAT loads. These are independent ceilings, not promises
of an extra launch for every repair. Stop if any limit is reached, even if another
allowance remains. No automatic reset, transfer, new case, new scope or extension.

## Delivery and stopping condition

Deliver the existing-GUI export action, native writer and source/column map,
one understandable workbook route with an immutable source receipt, short usage
notes, finite synthetic test/layout evidence and source-preservation report.
An output is complete only after write/readback succeeds; failures cannot replace
the previous completed export. Keep original detailed files, source snapshots
and scientific results unchanged.

Stop after acceptance passes or a source/resource/attempt/repair/effort boundary.
No full 17-recording regeneration/export, individual examples, detector work,
scientific recalculation, source-result overwrite, protocol inference, package,
Git commit/push, release or publication is included. A later real batch export
is an explicit separate use of the completed feature. The alternative is to keep
the existing detailed export unchanged until this plan is explicitly resumed.

**Current state: plan and document review only. No implementation/test code,
MATLAB start, numerical evaluation, recording payload read or workbook write
has been authorized or performed by preparing this plan.**
