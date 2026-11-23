# Updated versus original calculations: one-recording test

**Approved and delivered locally, 13 November 2026.** The researcher explicitly
selected “Run this one-recording test.” The [result](BOI_UPDATED_ORIGINAL_COMPARISON_RESULTS.md)
accounts for all 227 automatic sink events and preserves the original files,
production code, detector, burden product and normalization. Updated amplitudes
match the original temporal rule on equal inputs; strict totals stay unavailable
for twelve negative signed amplitudes. The bounded comparison is closed;
compact-export implementation stays held. The proposal text below is preserved
as the approved scope, not a pending request.

13 November 2026. UPDATED-ORIGINAL-COMPARE-01. Owner: root; no delegation.
Prepared for the researcher's requested test run. The completed baseline
milestone is closed; its two MATLAB launch allowances and one repair were used.
This is a separate bounded comparison proposal, not a reset of those counters.

## Practical result

Use **FB2412 only** to compare every saved automatic sink event and the complete
recording burden. Show event identities, amplitude/reference changes, unchanged
area/duration, contribution availability and strict area/time-normalized totals.
Write new comparison outputs and leave original results untouched.

The test reuses accepted saved detections and raw-footprint trace evidence; it
does not decode the movie or rerun the detector. This isolates the updated
calculation/statistics path. It is not a complete raw-movie/master-pipeline run
or a reconstruction of historical detector outputs.

## Reference versions and controlled comparisons

1. **Immediately before the baseline update:** preserved working-source
   snapshots in `reference-validation/boi-event-baseline-flags-20261113/before/`.
   Preserve their hashes and distinguish strict automatic and pre-episode fields.
2. **Updated delivered calculation:** `boi-event-baseline-flags-1`, using the
   same saved events, native mean areas, measurement bounds and exposures.
3. **Originally supplied quantifier:** source at commit `8cf3f03`, matching the
   previously archived June/July quantifier. Its unbounded timing search and
   site-union trace are separate diagnostic comparisons. Differences caused by
   those older spatial/timing rules must not be attributed to the latest update.

Compare the original temporal reference rule on identical event-footprint
traces/bounds with the updated calculation. Separately replay the supplied
quantifier on its saved site/timing inputs. Retain signed amplitudes and flag
missingness/edge/sign differences rather than forcing agreement. Do not restore
the original detector standardization, old site duration/rate units or other
previously corrected behavior.

## Exact finite source scope

The sole recording is the existing FB2412 saved run:

`reference-validation/boi-batch-execution-20261014/BOIBatch_50c02732-cf69-4817-a7df-043fe1f17a42/runs/BOIRun_74bbc0f0-26b3-4cf3-985c-114d6ff80a9c/Recording/`

Read only:

- `OxygenSinks_Output/OxygenSinks_UrefinedRecording.mat`: selected sink site/event
  tables, raw site mean and AnalysisInfo; never whole-MAT or image arrays.
- `OxygenSurges_Output/OxygenSurgesRecording.mat`: selected site native support
  and AnalysisInfo for both-sign overlap QC; no surge remeasurement.
- `BOIReview/event-amplitude-audit.mat`, its CSV and
  `AuditCreationReceipt.json`: receipt-bound raw/timing event means, fixed
  footprints, native intervals, source/clock and saved measurement inventory.
- The already named three-example comparison and baseline-delivery receipts,
  plus pinned program snapshots, as consistency/source references only.

Confirm native event keys, source hashes, clock, calibration, analyzed support
and requested variables before numerical work. If an ingredient is absent or
exceeds the resource limit, stop with an explicit missing-source checkpoint;
do not open the movie, another recording or additional real review artifact.
The five reserved recordings remain untouched.

## Work items, acceptance and stop

| Item | Work and benefit | Acceptance |
| --- | --- | --- |
| CMP-01 | Freeze sources, fields, reference versions and event keys; prepare isolated comparison drivers. | Original and updated paths cannot shadow one another; originals and dirty work are preserved. |
| CMP-02 | Run the updated saved-measurement/statistics calculation and pinned comparison paths for the complete FB2412 sink inventory. | Every automatic event is accounted for once; original temporal arithmetic and updated arithmetic are compared on equal inputs. Areas, saved duration, AUC and denominators stay unchanged in the controlled comparison. |
| CMP-03 | Compare strict contributions, normalized recording totals, saved burden series and existing-format export round trip. | No partial sum, zero filling or coverage scaling. All available products and normalizations match independent arithmetic. Missing totals remain unavailable with counts/reasons. |
| CMP-04 | Deliver a concise side-by-side CSV/workbook and interpretation report, and update GitHub status. | Unexpected differences are localized and reported; no unapproved production fix or adoption. Stop after this one recording. |

The event product and recording normalization remain:

`amplitude_percent * mean_native_area_um2 * saved_duration_sec`

`strict_sum(contributions) * 1e6/analyzed_area_um2 * 60/recording_duration_sec`

Use matching area/duration/exposures for the controlled burden comparison. Older
quantifier timing remains diagnostic; do not invent an area measurement over its
extended bounds or a historical complete burden. If any required contribution is
unavailable, report the complete total as unavailable; contribution counts are
descriptive, never a partial total. Do not compute an omit-missing sum merely to
make an original/new comparison numeric.

This is an **automatic calculation comparison**, not a reviewed export. Finite
automatic amplitudes do not reverse saved not-pocket decisions or accept pending
previews. No saved review is changed. No biological detector validation, new
baseline choice, new-reference AUC or threshold tuning is included.

## Proposed limits and approval boundary

Two active engineering hours; two sequential batches; one routine comparison-
harness repair; at most two MATLAB starts including a single targeted retry;
one recording-wide comparison plus that retry; 2 GiB worker process-tree RSS;
100 MiB new evidence/output combined. No new constructed-case campaign, package
installation, platform migration, compact-export implementation, cohort export,
Git commit/push or release. No automatic budget transfer from earlier work.

The researcher has requested the comparison. This concrete source/resource
extension beyond the closed three-trace milestone awaits explicit approval
under the workspace boundary rule. The alternative is to use the already
completed three-example original-temporal-rule comparison without another run.
Preparation so far reads program/evidence records only, not a new recording
payload. No new MATLAB worker or numerical test has started.
