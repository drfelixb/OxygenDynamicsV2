# CC-02 integration: partial delivery, validation limit reached

30 September 2026. **CC-02-01 through CC-02-05 remain incomplete.** The approved four-validation-batch ceiling was reached. No more checks or MATLAB starts are authorized by this delivery. This is neither usability acceptance nor release approval.

## Implemented candidate

A separately versioned `boi-reviewed-pocket-optical-0.2.0-exploratory` definition and `boi-reviewed-pocket-evidence-1` record connect explicit reviewed episode/reference frames to the existing event reviewer. The primary quantity is corrected signed trough as percent of positive raw reference intensity; the raw signed trough is a separate companion. Original automatic columns, saved detector sign, old raw-only 0.1.0 definition and completed-run index remain separate.

`Reviewed optical` contains new pocket controls and a retained legacy view. Explicit interpretation, recording-specific external 1 Hz authority, reviewer, reason, exact reference frames, suitability and endpoint status are required. Selection creates no judgment. Preview, new immutable revision, reopen and saved-only export actions are wired. A new portable reader displays stored values; arithmetic verification is an explicit action. The selected-event export has a separate `ReviewedPocket/` artifact, not replacement automatic columns.

The record embeds full saved fixed-footprint traces, exact selected samples, raw/corrected reference means, minima and tied frames, correction association, audit/source/footprint/judgment/definition hashes, original automatic row, and suitability/recovery/footprint qualifications. Historical dimension adapters require explicitly selected source-matched conversion reports and operate in memory. No correction fitting, replacement references, score substitution, footprint redefinition or automatic relabelling is added.

**This candidate does not yet have a demonstrated working save–reopen–export journey.** Controls and storage services are implemented, but the three primary round trips did not complete. Do not use the new workflow as validated scientific output.

## Named validation results

The detailed attempts and exact executable/source manifests are in `reference-validation/cc-02-integration-20260930/` at the workspace root. Initial failures are retained, not replaced by final classifications.

| Case | Observed result | Final evidence/limitation |
|---|---|---|
| T01 ID400 row 41 | Initial failure: row/column correction comparison. Final recheck: preview arithmetic and exact frame/footprint assertions passed, then Save failed with `OxygenDynamics:PocketPreviewRequired`. | Corrected −5.0523405688433565%, raw −4.328656254545948%, both minima 88. Save/reopen/export **failed/incomplete**. |
| T02 FB2312 row 194 | Initial correction-orientation failure. | Final recheck **untested** after T01 stopped batch 4. Unresolved recovery and saved surge footprint remain required. |
| T03 C02 row 321 | Initial automatic-amplitude display failed on a missing string. | Formatting repaired; final recheck **untested**. Conditional six-frame reference and saved surge footprint remain required. |
| T04 G2/G4/legacy compatibility | Initial display failed on an unavailable automatic amplitude. | Formatting repaired; final compatibility recheck **untested**. No new pocket calculation was inferred before this failure. |
| T05 missing correction | **Passed on batch-3 hashes**: corrected primary unavailable, raw companion separate; immutable save/load and explicit arithmetic replay passed. | Historical pass only. Not repeated on the final repaired code. |
| T06 correction/source mismatch | Attempt failed because its prerequisite T01 saved artifact was absent. | Intended identity rejection **untested**. |
| T07 changed footprint | Same missing prerequisite. | Intended footprint rejection **untested**. |
| T08 changed judgment/boundary revision | Same missing prerequisite. | Intended stale-revision rejection **untested**. |
| T09 overlapping reference/event | Same missing prerequisite before intended assertion. | Intended frame rejection **untested**. |
| T10 nonfinite reference | Correction-orientation failure before the target assertion. | Nonfinite-sample handling **untested** on repaired code. |
| T11 nonpositive reference mean | Correction-orientation failure before target assertion. | Nonpositive-mean handling **untested** on repaired code. |
| T12 unsuitable revised judgment | Missing prerequisite. | Withholding/history preservation **untested**. |
| T13 empty reference | Missing prerequisite. | No-inference unavailable handling **untested**. |
| T14 incompatible reviewed export schema | Missing prerequisite. | Unsupported-schema reopening **untested**. |

A failed prerequisite is not evidence that its intended rejection guard passed. The prior CC-01 three-pair comparison remains accepted historical evidence; it does not substitute for these application-level round trips.

## Repairs and exact evidence limits

1. One-dimensional JSON decoded the case list as a column; the harness treated all 14 IDs as one grouped evaluation. Two dispatch attempts failed. Both count against the budget. The second still used MATLAB's cached executable. The source was restored to its original executable hash, and an explicit two-dimensional row dispatch then ran the 14 named cases. The dispatch history and two disposable prerequisite aliases are documented in `dispatch-repair.json`.
2. The saved correction association subtracted a column from a row and formed a matrix. Both arrays are now explicit columns before comparison. No saved trend or scientific rule was changed. T01's final preview passed this corrected path.
3. `string(NaN)` formatted as a missing string and caused `sprintf` to fail in the event heading. The heading now says `unavailable`. The repaired C02/G2 display remains untested.
4. The panel exposed `@()current`, which captured its initial empty value. Its getter is now a nested function reading the current preview. **This final repair was made after the batch ceiling and is untested.** The final candidate manifest is distinct from the batch-4 tested hashes. A test pass is not transferred onto changed code.

Four batches used, **17/20 evaluation attempts used**: two malformed dispatch attempts, 14 first named attempts, one T01 recheck. Remaining three evaluations cannot be spent because the independent four-batch ceiling is exhausted. Two MATLAB starts used: first exited 134 before the harness due sandbox startup permissions; second ran saved-data checks and was told to exit through its close-session flag. Its tool handle subsequently closed; the exit code was not captured. No child-process containment claim is made. The already-open MATLAB desktop was reused for batch 4 without a third launch. Only the CC-02 idle test process was interrupted during cache handling; no unrelated process was signalled. No independent reviewer participated: implementation and review are assistant self-review.

The 526 executable/contract/harness pins and 44 preservation input pins passed the recorded batch-3 and batch-4 post-test gates for their own hashes. The new final-candidate hash manifest includes the untested getter repair. All preservation inputs still match. Evidence is below the 500 MiB ceiling. Active work remained below four hours.

**Zero** recording/movie analyses, detector/master/statistics engine executions, correction refits, footprint changes, automatic relabelling, package builds or release actions. Source MATs, automatic/legacy outputs, G2/G4 evidence and prior scientific packets were not overwritten. The legacy real-acquisition `containment_failure`, consumed approvals and three deferred live/resource blockers remain unchanged. Release work remains paused.

## Unfinished work and next bounded decision

CC-02-01 and CC-02-02 have implemented candidate contracts/calculation and one verified primary preview. CC-02-03 usability, CC-02-04 three primary immutable round trips, and CC-02-05 export integration acceptance remain open. The final getter repair and final C02/G2 display need verification; all unsuccessful/blocked named cases need appropriate final-code rechecks before claiming completion. T05's earlier pass remains tied to its original hashes.

The next decision should be **one bounded continuation of this same integration slice**, not a new scientific investigation. It should cover final-code verification of all 14 existing named cases, correct dispatch/cache handling, routine fixes and affected rechecks, and an actual researcher walkthrough of all three saved examples. It should retain zero engine/recording/refit/footprint/relabel runs and preservation requirements. No extension, new session or further check has been started or approved here.
