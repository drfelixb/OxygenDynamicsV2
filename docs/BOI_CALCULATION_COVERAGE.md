# Calculation coverage, confirmed corrections and remaining gaps

11 November 2026. Read-only evidence inventory and current-source comparison.
No numerical cases were rerun, no workbook payload was opened and no scientific
code, detector, burden formula, normalization or original result changed.
The researcher chooses to continue here with the original software goals.

## What the checks actually establish

“Checked” below means that a completed report records comparison with a known
answer or separately written arithmetic. It does not establish physiological
validity, full-dataset correctness or a new passing run on today's code.
Automated regression coverage and independent numerical replay are distinct.

| Calculation | Completed check and result | Important limit |
| --- | --- | --- |
| Recording/event time | `N/fs` recording time and inclusive `(last-first+1)/fs` event duration. NEXT-02: eight fixtures plus saved ID400, final 9/9. Includes a single frame at 2 Hz, refined sink versus native surge bounds, fractional windows, ongoing events and excluded window ends. | A descriptive frame interval is not proof of physiological onset/recovery or camera integration time. |
| Native event area | Mean native event pixels times pixel size squared. NEXT-02 independently replays all 192 sink and 54 surge event rows in the saved example, including workbook round trips. | Area describes native detected frames. It does not establish area throughout an extended or manually revised episode. Other shape descriptors are not all independently covered by this packet. |
| Tissue occupancy | Integrate the native-mask union with clipped frame time, then divide by sign-specific tissue area and window duration. Overlapping pixels count once. Separate sink/surge support, partial frames and unavailable geometry are tested. | Saved static tissue support and uniform-clock assumptions remain qualifications. This is different from concurrent event-time density. |
| Event rates and density | Site events/minute; recording onsets/mm²/minute; concurrent events/mm². NEXT-02 known answers cover both event signs, different support areas, 1/2 Hz, recording-start events and valid empty recordings. | Site recurrence, recording onset density and simultaneous density are different measurements. A frame-1 detection does not prove a new biological onset. |
| Automatic amplitude and percent conversion | The raw fixed-footprint reference formula and sign/availability are replayed in the signal/CC-01 records. The October automatic-amplitude export has nine passing cases covering signed, missing and zero values, contributor counts and saved examples. | Correct arithmetic does not make a reference recovered or uncontaminated biologically. Original automatic and corrected reviewed amplitudes remain different quantities. |
| Signed optical integral | `sum((I-B)/B)/fs`, retaining sign and cancellation. NEXT-03: six fixtures plus saved ID400/C02, final 8/8. Negative and cancelling traces, percent conversion and unavailable references are included. | It is an optical fraction-second integral, not the rectangular burden composite or absolute oxygen deficit. |
| Hypoxic burden product and normalization | Amplitude percent × native event area × saved duration; recording normalization by `1e6/area_um2` and `60/recording_seconds`. NEXT-03 known answers verify event products, recording rates and time-series integration. | Input eligibility and reference selection matter separately. This preserves the intended formula; it does not validate every amplitude/area/duration ingredient. |
| Missingness and empty recordings | Strict totals remain unavailable if an included contribution is missing. Valid analyzed empty recordings give zero totals/rates, while event means and zero-denominator fractions stay unavailable. Tested in NEXT-02/03 and amplitude-export fixtures. | An unprocessed or failed recording must never be treated as an analyzed empty recording. Finite-only means need their own contributor counts and are not complete burden sums. |
| Mouse/group summaries | Recordings averaged within mouse, then equal-weight valid mouse means; sample-SD SEM divided by sqrt(N), only for N>1. NEXT-03 known unequal-count and missing-recording examples pass. | The unit of replication is mice, not pooled events or sites. Metric-specific contributing counts remain necessary. |
| Approved pre-episode reference path | October 16 delivery: 15 reference/loader cases and 102 broader compatibility cases, with independent arithmetic on selected FB2412 means/amplitudes/products/scaling. The later saved 17-recording export checked 5,407 event products and 5,424 workbook rows. | These are historical checks. The rule remains event-footprint-specific, with references older than the accepted limit withheld. No reference rule is changed here, and no new 17-recording or reserved-data pass occurred. |
| Export persistence and identity | Event/window workbook/CSV/MAT round trips and the named combined export's 204 table and 136 trace comparisons are recorded. Large-variable serialization and calculation-versus-exporter identity corrections are documented. | A persisted number matching its source is not proof of biological meaning. A compact primary workbook remains undelivered. |

Primary records: [duration/area/rate delivery](SOFTWARE_NEXT_02_DELIVERY.md),
[integral/composite delivery](SOFTWARE_NEXT_03_DELIVERY.md),
[automatic amplitude delivery](SOFTWARE_AUTOMATIC_AMPLITUDE_EXPORT_DELIVERY.md),
[signal audit](EVENT_SIGNAL_AUDIT.md),
[CC-01 comparison](SOFTWARE_CC_01_COMPARISON_REPORT.md),
[pre-episode implementation](BOI_PRE_EPISODE_IMPLEMENTATION.md),
[pre-episode combined export](BOI_PRE_EPISODE_COMBINED_EXPORT.md), and
[combined export delivery](BOI_BATCH_STATS_EXPORT_DELIVERY.md).

## How much of that evidence still matches the current code?

The source comparison is saved in
[the evidence inventory](../../reference-validation/boi-calculation-export-plan-20261111/evidence-inventory.json).

- **14 of 18** production files pinned by the final NEXT-02 packet are still
  byte-identical. The four changed files are the software version helper,
  event finalizer, sink/window calculator and window exporter. The window
  exporter matches its later NEXT-03 provenance-change pin.
- Seven of ten selected numerical/related functions match the NEXT-03 source
  inventory exactly, including recording burden aggregation, mouse summaries,
  complete time series, native union series, both site-rate helpers and the
  surge-window wrapper.
- Three relevant paths changed: `finalizeOxygenEventMeasurements`,
  `createHypoxicBurdenMetrics`, and `createOxygenAnalysisWindows`. The inspected
  diff appends the approved pre-episode evidence/reference fields and selects
  that amplitude for burden/window composites. The product and area/time
  normalization expressions remain the same. Later bounded reference tests
  exist, but this inventory does not claim the complete original 9/8-case
  packets have been freshly replayed against the current source.

Thus the arithmetic evidence is useful and traceable, with an explicit
current-version reconciliation gap. Hash equality supports reuse of evidence;
it is not an independent numerical or biological test.

## Confirmed historical errors and their present status

The broad statement “no errors were found” would be incorrect. The later
October checks found no *new* formula defect within their named cases, while
earlier source corrections had already been made.

| Confirmed issue | Evidence and consequence | Present status |
| --- | --- | --- |
| Temporal standardization divided by sqrt(SD), rather than SD | Local original commit `8cf3f036b41e16b2c472bcee7e5cfaeab41433eb`, `helpers/normalizeToZStat.m`, contains the expression. It does not produce the intended temporal z score. | Current code divides by SD and handles constant inputs explicitly. Recorded synthetic checks cover unit temporal SD and positive-gain/offset invariance. This is detector standardization, not burden area/time normalization. No change is proposed now. |
| Sink/surge site rates used inconsistent time units | Original surge helper divides count by seconds, while current `SurgeSiteEventRate_per_min` explicitly multiplies by 60. Old ambiguous names obscured the difference. | Corrected and explicitly named events/minute. Both current rate helpers and the seconds conversion are visible in source; the relevant site-rate helpers match the October checked source. |
| Site mean event durations were not converted from frames to seconds | Original site helper averages frame counts. Current helpers divide by saved sampling frequency. The discrepancy matters away from 1 Hz. | Corrected; the duration/rate fixtures include non-1-Hz cases. |
| Diagnostic amplitude audit used inconsistent inputs/reference rules | The former sink audit used whole-site traces, shortened references and possible post-event samples, unlike the accepted event-footprint measurement. It could report false discrepancies. | Corrected audit uses the event's saved footprint and matching reference eligibility. This was an audit-tool defect, not evidence that every stored amplitude was numerically wrong. |
| Large MAT variables were omitted during combined export | The first named export used v7 for two variables above the 2 GiB limit. A workbook alone could look successful despite incomplete MAT data. | Fixed with size-aware v7.3 persistence and required-variable checks. The initial incomplete attempt remains preserved. No scientific values were adjusted. |
| Exporter identity was presented as original calculation identity | An older manifest's “Pipeline version” could describe the current reporter rather than the calculator that created the saved result. | Fixed for new outputs. Unknown historical calculator versions remain unknown. Old files were not relabelled. |

The original normalizer/rate excerpts and current source hashes are retained
with this inventory. See [existing corrections](EXISTING_ANALYSIS_CORRECTIONS.md)
for historical definitions; its old execution instructions and development
identities are historical, not current authorization.

Event-specific morphology replacing parent-site descriptors, strict burden
missingness replacing omit-missing totals, raw versus corrected amplitude,
and the approved pre-episode reference are **measurement/aggregation choices**.
They must not be bundled into a list of simple arithmetic fixes or silently
rolled back. A negative raw amplitude or an unavailable burden alone does not
establish a numerical bug. No new current numerical error was established by
this read-only inventory.

## What remains unchecked or unresolved

| Gap | Classification | Useful next action, if requested |
| --- | --- | --- |
| A complete source-to-column audit of every output in the exact initially supplied version versus today's version | Coverage not established | Maintain a finite column/function checklist using these existing records; do not claim the whole script is certified. |
| Full reconciliation of the three later reference-selection entry points with the original independent-answer packets | Current-version coverage incomplete | Replay only the affected existing fixtures and the original/derived/withheld branches in a separately agreed small check. This is not required merely to copy saved values into a compact workbook. |
| Every secondary shape/trace feature: perimeter, circularity, centroid, size modulation, ROI CV/entropy and related descriptors | Independent coverage not mapped in this inventory | Existing unit/regression tests may cover parts. Locate known-answer evidence before marking each as independently checked. The 12 November paper review requires saved diameter/circularity in the compact core; export presence/value checks do not close this arithmetic-coverage gap. Other exploratory metrics stay in the detailed export. |
| Rank-amplitude sensitivity variants and optional paired/behavior-aligned outputs as a complete current end-to-end set | Coverage not established by the reviewed primary packets | Leave them in the detailed export; do not introduce new group statistics, KX/stimulation reconstruction or protocol inference. |
| Whether each event reference is physiologically recovered, each mask is anatomically appropriate, and every onset/recovery is correct | Scientific/data-quality uncertainty | Preserve saved flags and unknowns. These require appropriate biological evidence, not another multiplication check. |
| Native area throughout manually extended/revised events, and complete normalized burden for the 17 recordings | Required inputs unresolved in saved examples | Retain unavailable values where a required retained contribution is missing. No partial sums, imputed zero areas or replacement normalization. |
| Absolute oxygen concentration or calibrated oxygen deficit | Not established by the optical pipeline | Describe amplitudes as relative optical changes and preserve their reference and units. |

## Return to the practical output

The [compact export specification](BOI_COMPACT_EXPORT_PLAN.md), reconciled on
12 November, projects saved values into six core flat sheets plus an optional
Phases metadata table. It includes site recurrence, activity/burden series and
source-bound signed AUC/automatic-gap QC. These additions do not certify new
arithmetic coverage or change existing scientific calculations. Its finite
export checks concern identity, units, missingness, exact source values and
source/reference compatibility. [The held handover](planning/boi-reconciled-delivery-plan-20261112.json)
keeps original implementation limits and named fixtures; no numerical checks
are executed by this reconciliation. Calculation coverage gaps and optional
detector review do not become prerequisites for improving the output layout.
