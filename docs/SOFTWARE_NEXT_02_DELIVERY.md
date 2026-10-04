# Duration, area, occupancy and event-rate check delivery

4 October 2026 · NEXT-02 · Delivered within approved software-check scope

## Result

All nine named cases passed on the final harness: eight frozen small fixtures
and the existing saved G2 ID400 result, with both sink and surge paths in each
applicable case. Duration, native event area, union tissue occupancy, onset rate
and concurrent event density agree with independent expected arithmetic.
No production defect was demonstrated. No formula, detector, correction,
footprint, calculation contract, original result or scientific meaning changed.
No old/new adoption decision is required. The short
[calculation guide](BOI_DURATION_AREA_AND_EVENT_RATES.md) explains each formula,
denominator, units, worked examples and remaining scientific qualifications.

## Exact scope and final evidence

[The task record](SOFTWARE_NEXT_02_TASK.md) freezes inputs, F01–F08/S01 and
expected answers before evaluation. The evidence packet is
`reference-validation/software-next02-calculations-20261004/` outside the
Git checkout. `cases.json` fixes all four-frame native masks and measurement
intervals; `saved-ingredients.json` inventories only existing ID400 native
masks/eligible support/event frames. `saved-expected.json` is written by
independent Python arithmetic from those ingredients and the original workbook.
`supplement-expected.json` adds the independent per-frame event count answer
from the same frozen event frames before batch 2. No native ingredient is missing
for these five families; no recording was regenerated or source TIFF opened.

The focused checks reuse calculation/export services and the relevant assertion
patterns in testMeasurementAvailability, testBOISurgeWindows and
testBOIWindowReview rather than launching their larger suites or additional
fixtures. They cover 2 Hz single-frame duration, pixel-size squared, distinct
refined sink/native surge duration, native mean area, intersected mask unions,
fractional exposure, unequal sign-specific support, ongoing events, end-boundary
onset exclusion, valid empty events, unavailable scale/area and invalid clock.
Frame-1 onset counting is preserved; it is descriptive, not proof of new
physiological onset. Missing/negative amplitudes do not remove event timing or
native pixel support from the checked counts and occupancy.

- **Final batch:** batch-02-results.json, 9/9 pass. Frozen expected inputs and
  final batch-02 harness pins remain unchanged.
- **Duration and area:** all 192 saved sink and 54 saved surge event rows match
  inclusive duration and native frame pixel means, and both the original
  workbook and newly written event workbook. Export retains bounds and area.
- **Window arithmetic:** sink and surge helper outputs, original saved metrics,
  per-frame native union areas and per-frame event counts match independent
  answers. Site mean durations and per-minute event rates agree with their
  saved event rows. Sink support is never substituted for surge support.
- **Export:** compact selected-window exports for both signs replay from
  Frames.csv/Events.csv and agree with Metrics.csv and SelectedWindowReview.mat.
  Event workbook round trips preserve duration/area. Valid empty events export
  zeros in the selected-window ledger; invalid inputs are blocked/unavailable.
- **Preservation:** all 18 original G2 packet files match their pre-task SHA-256
  pins. All 2,243 other initially tracked files are unchanged at calculation
  completion; only current status was edited at that point. Subsequent edits
  update the task/plan/backlog/guide records, not production or contracts.

## Existing versus independently replayed saved values

| Quantity | Existing sink → replay | Existing surge → replay |
|---|---|---|
| Event count | 192 → 192 | 54 → 54 |
| Active event time (s) | 2501 → 2501 | 781 → 781 |
| Tissue area (µm²) | 4050555.375 → same | 4339851.75 → same |
| Covered union area-time (µm²·s) | 14815462.5625 → same | 28751664.5 → same |
| Occupied fraction | 0.006096062223113458 → same | 0.011041722988195007 → same |
| Onsets/mm²/min | 4.740090733853997 → same | 1.2442821347526447 → same |
| Mean concurrent events/mm² | 1.029076990049379 → same | 0.29993344050673315 → same |

Spreadsheet arithmetic uses tolerance 1e-10 × max(1, expected), with integer
counts/identity and availability checked exactly. This is numerical correctness
of stated definitions, not biological validation or a new estimation rule.

## Retained failures and routine repairs

The first sandbox MATLAB invocation exited 1 without log/results; it is
conservatively charged against the session limit. The second invocation
performed ingredient inspection and both batches, then exited normally (0).
No extra launch occurred. Batch 1 attempted all nine cases: F08 passed;
F01–F05/S01 failed harness character-array concatenation; F06 failed the
harness's empty 0×0 bounds shape; F07's surge wrapper correctly blocked missing
calibration earlier than the harness expected. Fixes were confined to the
harness. Batch-01 receipts and the pre-repair hashes remain.

F07 now explicitly checks the surge source wrapper's InputContractIdentity
rejection, as well as generic primitive unavailable normalized values and
invalid saved-reader calibration rejection. Both unavailable and blocked
behavior satisfy the frozen requirement; numerical expected answers are
unchanged. No source-bound export is claimed for invalid calibration.

## Budget, identity and stopping condition

- Two validation batches; 18/40 focused case evaluations, including failures.
- Two MATLAB invocation/session attempts charged; one successful saved-data-only
  session. Session ended normally; zero recording, detector or statistics-pipeline
  runs. No package/build/release or containment diagnostics.
- Evidence approximately 42.15 MiB, below 100 MiB. No earlier artifact was removed or compressed.
- Active-work conservative upper bound 42.9 minutes, including a 30-minute pre-record allowance,
  below six hours. Exact counters and timestamps are in budget.json.
- Software version `3.1.0-dev.1`, build `2026-10-04 20:36:05 +02:00`; production
  source remains `b0f6d20be415f9dc64f99c05585147e21633d8db` on
  development-existing-analysis-v3. Documentation and focused harness files
  remain local changes; no commit or branch push was performed in Step 2.
- Calculation/source profile remains `3.1-roi-dev`, detector
  existing-v2-surge-shape-continuity-5_roi-candidates-1, measurement
  event-footprint-contact-ledger-7, statistics mouse-strict-contact-qc-8.
  Window contracts remain boi-window-exposure-1 / boi-surge-window-exposure-1.
  Software identity and calculation identity are distinct.
- Final code manifest SHA-256: `0a3fba90be05c694941509c273ae353325b16b4be0e979468d022cb4ea426250`.

No unresolved numerical implementation decision was found within the named
cases. Camera exposure is unknown; static support does not prove dynamic tissue
validity; acquisition-boundary physiological onset remains unresolved. Reviewed
corrected trough remains exploratory, C02 reference conditional, FB2312 recovery
unresolved and all saved-footprint qualifications retained. They were not
re-evaluated here. Assistant implementation/self-review only; the independent
arithmetic writer is not an independent human reviewer. Broader recording/
platform validity and release readiness are not established.

Step 2 is delivered and execution is stopped. Step 3 needs separate approval.
All prior failures, storage exception and release/containment/licensing blockers
remain. No further phase starts automatically.

## Researcher acceptance — 4 October 2026

The researcher accepted Step 2 within its demonstrated arithmetic/export scope.
All failures, scientific limitations, budget receipts and original evidence remain.
This acceptance does not establish physiological validity or release readiness.
Step 3 is separately approved in the current researcher request; Step 2 is not
reopened or automatically repeated.
