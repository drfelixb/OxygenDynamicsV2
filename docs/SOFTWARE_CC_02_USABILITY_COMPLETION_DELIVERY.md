# CC-02U usability-completion delivery

1 October 2026. **Six named focused checks passed; the researcher accepted the bounded usability workflow on 1 October 2026.** This is a bounded presentation/native-chooser delivery, self-reviewed by the assistant. No independent reviewer participated. Release work remains paused; overall usability, G5 and release are not accepted by this delivery.

## Finished workflow

The standalone viewer uses separate readable value/qualification areas, a saved corrected-intensity trace with exact reference samples, scrollable full provenance and reachable export controls. Normal size is 1120 × 800 and the smaller supported size is 900 × 650 logical pixels. Body text is 12-point; the smaller trace area is at least 220 pixels high. Display-only y limits fit the visible saved samples without changing the trace or arithmetic.

Native prompts distinguish a **parent for a newly generated save/export child** from the **completed saved folder itself for reopen**. Generated paths appear in the details and tooltip. Save, reopen, main export and standalone export cancellation preserve state and write nothing. The researcher performed the native chooser selections/cancellations; programmatic callbacks were not substituted for those interactions.

At handoff, **C02 — CC-02U standalone** is open at the already-tested 900 × 650 size, with its conditional reference and saved surge-footprint qualification visible. ID400 and FB2312 standalone viewers remain available at normal size. This final resizing is presentation for acceptance, not a new evaluation. No additional test is authorized under the consumed 12-evaluation budget.

## Results and evaluation history

| Check | Final result | Evaluations | Evidence |
|---|---|---:|---|
| CC-02U-01: normal standalone layout, all three | Pass: native and structural inspection | 5 | evaluation-05.json; earlier iterations retained |
| CC-02U-02: 900 × 650 and return, all three | Pass: native and structural inspection; full details scrolled | 1 | evaluation-06.json; native-small-positions.json |
| CC-02U-03: ID400 native Save → Cancel → Save | Pass: same one preview retained, exact saved scientific contents | 1 | evaluation-07.json |
| CC-02U-04: native Reopen → Cancel; ID400, FB2312, C02 | Pass: exact folders/documents, no replay | 3 | evaluation-10.json retains verified ID400/cancellation from 08; 09 records rejection |
| CC-02U-05: C02 main and standalone native export, each Cancel then success | Pass: both complete export documents equal original C02 | 1 | evaluation-11.json |
| CC-02U-06: final preservation/traceability | Pass: 71 protected inputs, 528 final code/harness pins, all scientific payloads | 1 | evaluation-12.json; delivery-post-hash-gate.json |

**12/12 evaluations used, not 12 passes.** Evaluation 01 failed on unsettled layout coordinates; 02 failed in the harness with `MATLAB:heterogeneousStrucAssignment`. Evaluation 03 exposed exportapp overlap despite passing structural assertions; 04 was superseded by the final axes-margin repair. Evaluation 05 is the final passing normal-layout result; 06 is the final smaller-layout result.

Evaluation 08 verified native reopen cancellation and exact ID400 reopening, then was interrupted when all CC-02U windows were deleted before FB2312 observation. Evaluation 09 records `OxygenDynamics:PocketIdentityMismatch`: the ID400 window was still active when a foreign review was selected. That was a foreground-handoff failure; the identity guard correctly rejected the mismatch. The walkthrough was repaired by explicit native Window-menu activation. The deleted viewers were restored from saved files in the same MATLAB session without another preview. Evaluation 10 completes the remaining FB2312/C02 native reopens and exact payload checks, retaining earlier verified observations rather than claiming unobserved success. Lock-related interruptions and failed native-coordinate actions are documented separately in native-observations.md; they did not execute a preview, engine or extra session.

The cancellation harness was repaired to compare JSON-persisted snapshots in their common serialized representation. The ID400 live preview additionally retained an exact MATLAB `isequaln` check. That harness-only change was pinned before cancellation observations; layout production hashes were unchanged, and earlier harness hashes remain in the packet. The historical 14-case numerical matrix was not repeated or asserted to validate revised UI code.

Five recorded phase groups B01–B05 are listed in batches.json; there was no separate batch ceiling. Active work is below the approved two-hour limit (about 51.4 minutes at report preparation; final ledger 3170.87 seconds (52.85 minutes) in budget.json). Waiting for researcher interaction was excluded. **One existing MATLAB R2025a desktop session was used, zero starts, one unchanged authorized ID400 preview, zero recording/detector/statistics runs, correction refits, footprint changes or automatic relabelling.** New disposable evidence is 3.49 MiB, below 100 MiB; exact ledger is in budget.json.

## Scientific contents preserved

| Saved example | Episode / exact reference | Corrected / raw trough (%) | Qualifications retained |
|---|---|---|---|
| ID400 | 82–98 / 73–81 | −5.0523405688433565 / −4.328656254545948 | Accepted local reference; 1,100 saved sink-footprint pixels; extent not independently established |
| FB2312 | 398–417 / 378–397 | −8.362579856515431 / −8.138502968125097 | Recovery unresolved; 417 is an observation end; 3,684 saved surge-footprint pixels |
| C02 | 177–195 / 165–170 | −12.383756977559301 / −11.104931801071126 | Conditional provisional six-frame reference; automatic amplitude unavailable; 5,086 saved surge-footprint pixels |

Comparisons used exact stored fields/arrays, not rounded display text. These are exploratory optical percentages scaled by raw reference intensity, not oxygen percentages or absolute pO2. No confirmed pocket duration is established by these artifacts. Existing automatic/legacy measures and detector signs are unchanged. ID400's new revision has expected revision/timestamp/link/hash metadata and presentation provenance differences, explicitly listed in evaluation-12.json; its scientific contents equal the original. Both C02 exports retain complete original document equality.

## New artifact destinations

- ID400 revision 2: `/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/cc-02-usability-completion-20260930/SaveParent/ReviewedPocket_tpff1203a4_fb81_43d2_9bd7_0b483c9f480e`
- C02 main export: `/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/cc-02-usability-completion-20260930/ExportParent/ReviewedPocketExport_tp04d5b379_133d_497d_9e0a_bcd562370985`
- C02 standalone export: `/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/cc-02-usability-completion-20260930/PortableExportParent/ReviewedPocket_tp4cc796d1_38d3_4b81_a714_5d3d49c05dd0`

Each contains ReviewedPocket.mat/JSON, exact sample, measure and footprint CSVs, Evidence.md, Manifest.json and Definition.json. Original artifacts/audits/metadata are preserved; all 71 input pins match.

## Changed files and final hashes

Only three production presentation files were changed in this slice. Calculation, definition, immutable save/load/export services and schemas were not repaired or altered. The packet's final-presentation-repairs.patch compares against the untouched three before copies.

| File | SHA-256 |
|---|---|
| `existing-analysis/openBOIReviewedPocketEvidence.m` | `d80bb129514f901b864a63c175c3a9394e46694f52f3edf49ee4032beaf4ce5b` |
| `existing-analysis/openBOIEventReview.m` | `7353ca2ef05013fa481b04e2c397aeebab6631184a58b8325709c2ce32b701ce` |
| `existing-analysis/helpers/createBOIReviewedPocketPanel.m` | `b3c33f1dbed44fc2f5817a24b919d541446055a22607b70aa00aa016a31bf98b` |
| `reference-validation/cc-02-usability-completion-20260930/cc02uStep.m` | `0cbc500ae590921fff7df061bb2a309bb9550b494992e13addaa50298edb7c30` |

Final 528-entry manifest SHA-256: `19ea020b18b7088351cc75fb4132d44de5bd79ffdd43f72acea7e043220401ef`. All listed code/dependency/harness pins matched during the final MATLAB gate and subsequent read-only delivery hash gate. Prior pin files and failure receipts remain historical. The protected pre-implementation inventory and original input manifest are in before-code-pins.json and original-input-pins.json.

## Layout evidence and limits

All three native views were inspected at both named sizes, including scrolling the full details. The original target used MATLAB R2025a/macOS, ScreenPixelsPerInch 96 and retina scaling; actual logical window sizes are recorded. Display movement during the walkthrough was observed, but other monitors/DPI/platforms have no new layout-validation claim. Arbitrarily smaller sizes are unsupported by this evidence.

| Example | Normal exportapp capture | Smaller exportapp capture |
|---|---|---|
| ID400 | [normal](/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/cc-02-usability-completion-20260930/evaluation-05-ID400-normal-exportapp.png) | [smaller](/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/cc-02-usability-completion-20260930/evaluation-06-ID400-small-exportapp.png) |
| FB2312 | [normal](/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/cc-02-usability-completion-20260930/evaluation-05-FB2312-normal-exportapp.png) | [smaller](/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/cc-02-usability-completion-20260930/evaluation-06-FB2312-small-exportapp.png) |
| C02 | [normal](/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/cc-02-usability-completion-20260930/evaluation-05-C02-normal-exportapp.png) | [smaller](/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/cc-02-usability-completion-20260930/evaluation-06-C02-small-exportapp.png) |

**Capture limitation:** immediate smaller exportapp images retain larger canvas padding, although the native windows were verified at 900 × 650. These PNGs are MATLAB exportapp captures, not saved native screenshots; native images appeared in the conversation. Screenshot parity is not claimed. Full paths/provenance remain scrollable rather than all visible simultaneously.

## Acceptance and remaining limits

The researcher completed the disclosed native save/reopen/export interactions and cancellations and accepted the bounded workflow at both named sizes on 1 October 2026. The two CC-02 usability items are closed within that scope. The assistant's six focused checks and all documented limitations remain as recorded. This delivery does not infer overall usability acceptance, scientific/physiological validity or release approval. No further testing or diagnostic phase starts with this report.

Licensing, hosted CI, broader runtime/package integration and the deferred successful live acknowledgement, containment and real-acquisition/resource blockers remain open. The previously accepted local package candidate predates these UI changes and was not rebuilt here. Historical `containment_failure` and consumed launch approvals are unchanged. Release remains paused.


## Researcher acceptance — 1 October 2026

The researcher accepts CC-02U’s bounded usability workflow at **1120 × 800 and 900 × 650**, including the demonstrated native selections and cancellations. **Standalone viewer layout and native chooser interaction are closed within that scope.** This resolves the two usability items left open by the 30 September CC-02 acceptance.

C02’s conditional reference, FB2312’s unresolved recovery and all footprint qualifications are preserved. All documented limits, self-review status, earlier failures, original outputs and execution evidence remain unchanged. This acceptance does not extend evidence to other sizes/displays/platforms, establish physiological validity or grant overall software usability or release acceptance.

Acceptance was recorded through documentation changes only. **No further checks, MATLAB sessions, launches, calculation changes or implementation were performed or authorized. G5 and release remain unaccepted; release work remains paused.** Historical `containment_failure`, consumed launch approvals and open release blockers are unchanged. The next execution or work slice requires separate researcher direction; no automatic continuation is proposed.


**Researcher pause confirmation — 1 October 2026:** CC-02 is closed within its accepted scope. Development and release remain paused. The researcher will provide the next requirement after using the workflow; no validation phase will be prepared automatically. This documentation update performs no checks or launches and changes no scientific output, qualification or limitation.
