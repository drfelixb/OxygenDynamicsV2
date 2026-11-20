# CC-02U: bounded usability-completion decision card

Original decision card: 30 September 2026. **Approved by the researcher on 30 September; bounded delivery completed and accepted by the researcher on 1 October 2026 within the named usability scope.** See [delivery and retained evaluation history](SOFTWARE_CC_02_USABILITY_COMPLETION_DELIVERY.md). The researcher has accepted CC-02’s bounded numerical/integration delivery and demonstrated main-window workflow. This decision card addressed standalone viewer layout and researcher interaction with native folder choosers; both items are now closed within the accepted scope. Overall usability, G5 and release remain unaccepted.

## Outcome and authority

Deliver a readable standalone saved-pocket viewer at **1120 × 800** and **900 × 650 logical pixels**, and guide the researcher through native save, reopen and export folder selection, including cancellation. The smaller size is the supported target for this slice; arbitrary smaller sizes, other displays/platforms and DPI settings are not claimed tested. Record actual MATLAB window sizes and display scaling.

Owner: assistant for implementation, focused checks, preservation and self-review; researcher for the native interactions and final usability decision. No independent reviewer is presumed. One approval would include routine layout, wrapping, scrolling, chooser-message, destination handling and cancellation repairs, plus affected focused rechecks within the budget. It does not authorize a new scientific method or broader product redesign.

The alternatives are approving this complete slice or deferring the two items with the present limitations explicit. Delivery will present the finished viewer and walkthrough evidence for researcher acceptance; it will not automatically grant overall usability or release acceptance.

## Exact saved fixtures and protected meaning

Reuse only the final existing CC-02 examples under workspace-root `reference-validation/cc-02-completion-extension-20260930/`, with `cases.json` providing the original audit/metadata paths. Use `batch-02-T01-saved`, `batch-02-T02-saved` and `batch-02-T03-saved`, including their `ReviewedPocket.mat`, JSON, definition, exact-sample/footprint/measure CSVs, methods and manifests. Prior packets and inputs remain immutable. No source recording needs opening.

| Fixture | Explicit episode / reference frames | Primary corrected / raw companion (%) | Qualifications that must remain readable and unchanged |
|---|---|---|---|
| ID400, row 41; saved sink site 11/event 1; 1,100 pixels | 82–98 / 73–81 | −5.0523405688433565 / −4.328656254545948 | Accepted local-state reference; saved sink footprint; reviewed extent not independently established. |
| FB2312, row 194; saved surge site 1/event 2; 3,684 pixels | 398–417 / 378–397 | −8.362579856515431 / −8.138502968125097 | Recovery unresolved; 417 is observation end, not confirmed recovery or duration. Saved surge footprint; pocket extent not independently established. |
| C02, row 321; saved surge site 5/event 1; 5,086 pixels | 177–195 / 165–170 | −12.383756977559301 / −11.104931801071126 | Conditional provisional six-frame reference; automatic amplitude unavailable; saved surge footprint; pocket extent not independently established. |

These decimals identify the accepted comparison targets; preservation checks compare actual full-precision stored fields, not rounded labels. Retain recording-specific external-trigger 1 Hz authority, automatic versus reviewed distinctions, missingness, all reference/endpoint flags and provenance. These are exploratory optical percentages, not oxygen percentages or absolute pO2. No new physiological judgment is requested.

## Implementation boundary

Primary file: `openBOIReviewedPocketEvidence.m`. Repair its grid sizing, wrapping, readable summary and scrollable detail area so traces, values and qualifications never overlap. Keep the matching saved corrected trace and exact reference markers; event boundaries and one-based frame axis remain clear. Target readable 12-point body text, a plot area at least 220 logical pixels high, a visible primary/raw summary and visible conditional/unresolved/footprint qualification, with full provenance available by scrolling. Do not solve overlap by hiding scientific qualifications or shrinking text to illegibility. Keep native buttons reachable at both named sizes. Record native visual inspection and screenshots; assess any exportapp capture separately from actual display, and retain discrepancies rather than claiming screenshot parity.

Chooser repairs, if needed, are confined to the pocket save/reopen/export callbacks in `openBOIEventReview.m`, their presentation in `helpers/createBOIReviewedPocketPanel.m`, and the standalone viewer export callback. The native prompts must explain **parent folder for a newly generated child** for save/export and **completed evidence folder itself** for reopen. Cancel must return without writing, changing selected saved evidence, discarding an existing preview or displaying a success message.

Existing arithmetic, calculation helpers, definitions, schemas, source/correction association, immutable writers/loaders and original measurements remain unchanged. If a routine defect appears to require changing those services, stop the dependent checks and report a material blocker. No silent migration or recalculation on open/export. For the save walkthrough only, one ordinary ID400 **Preview draft** is necessary because the current Save NEW revision control requires it; use exactly the saved judgment choices, frames, correction and footprint. This is replay of the existing unchanged arithmetic, not a new calculation rule or reference. The new revision may have a new revision ID, timestamp and implementation provenance; its scientific ingredients, values and qualifications must equal the saved fixture. Cancel and subsequent successful save reuse this same preview; no second preview is planned. FB2312 and C02 require no preview or arithmetic replay.

## Six named focused checks

One named check may contain the stated interactions/examples below; these are disclosed here, not extra hidden cases. Final passing results must correspond to the final code for their affected paths. Prior passes on changed code remain historical. Record case evaluations and batches explicitly.

| ID | Check and exact actions | Acceptance |
|---|---|---|
| CC-02U-01 | Standalone normal layout: open each of the three saved artifacts at 1120 × 800; inspect native display and capture it. Do not press Verify saved arithmetic. | Correct saved curve/reference samples and bounds; readable axes, primary/raw values, statuses, footprint origin and limitations; no overlap/clipping; full details scrollable and controls usable. |
| CC-02U-02 | Standalone smaller layout: resize those same three views to 900 × 650 and back to normal. Inspect all mandatory summaries and scroll the full details. | Same scientific content and usable controls at both sizes; plot and text do not overlap; qualifiers are visible alongside values, not available only in hidden provenance. Native display and screenshot findings reported separately. |
| CC-02U-03 | Native save walkthrough, ID400: load its saved choices, make the single unchanged preview; click Save NEW revision → Cancel; click again → select disposable SaveParent → confirm. | Cancel writes nothing and retains the preview/state; confirm creates one new child, visibly reports its actual path and preserves the fixture’s scientific fields/values. Original artifact unchanged. |
| CC-02U-04 | Native reopen walkthrough: click Reopen saved revision → Cancel; then choose the new ID400 child, the original FB2312 saved folder and the original C02 saved folder for their respective selected events. | Cancel leaves current evidence/state unchanged; each completed folder opens with stored values and qualifications, no arithmetic replay; clear distinction between parent folder and evidence folder. |
| CC-02U-05 | Native export walkthrough, C02: main-window Export SAVED revision → Cancel → retry and choose ExportParent; then standalone Export to NEW folder → Cancel → retry and choose PortableExportParent. | Each cancellation writes nothing and preserves selected evidence/state; each confirmation creates a distinct child with the saved conditional payload, exact frames/footprint and unavailable automatic measure preserved. Neither path exports a draft. Actual paths shown. |
| CC-02U-06 | Final preservation and traceability: compare all three opened scientific payloads with their originals; compare the new ID400 saved scientific fields and both C02 exported complete documents with the originals; check original input/artifact hashes and final code pins. | Exact stored measure/array/frame/flag/footprint equality; ID400 revision/provenance differences explicitly identified; C02 exports retain complete saved document equality. No original source/result changes. Retain hashes, paths, screenshots, native click/cancel observations and counts. |

CC-02U-06 depends on successful artifact creation in 03/05; do not inspect absent/failed artifacts as if they were successful prerequisites. Repair an ordinary UI defect before retrying its affected check. Missing native researcher interaction is **untested**, never replaced with a programmatic callback pass.

## Researcher walkthrough after approval

Prepare exact absolute paths and show the current example before each step. The researcher uses the native dialogs; the assistant handles setup, captures and preservation observations in the same saved-data session. Provide one instruction at a time:

1. ID400: after the unchanged preview, click **Save NEW revision**, then **Cancel**. Confirm the preview remains. Click again; select the prepared **SaveParent** and confirm. Point out the generated child folder and its displayed absolute path.
2. Click **Reopen saved revision**, then **Cancel**. Confirm the display is unchanged. Click again and select the generated **ID400 child folder itself**, not SaveParent. Repeat successful reopen for the exact FB2312 and C02 original evidence folders, after selecting their matching saved events.
3. C02: click **Export SAVED revision**, then **Cancel**. Repeat, select **ExportParent**, confirm, and identify the new child. In its standalone saved viewer, repeat Cancel and successful **Export to NEW folder** using **PortableExportParent**.
4. Show the standalone viewer at both named sizes; ask for the researcher’s assessment of trace, value and qualification readability. Store their actual feedback separately from assistant verification. Acceptance may remain pending if they are unavailable.

No researcher needs to type frame choices, redefine a reference, or judge the science again during this walkthrough.

## Finite budget and evidence

- **At most two active implementation/verification hours** (120 minutes). Record active elapsed time; waiting for researcher input does not authorize extra work and is recorded separately. Stop active work at the limit.
- **One saved-data-only MATLAB session total**, either one newly started interactive session or one explicitly designated existing session; no second session or restart. No engine entry points, recording analysis, correction refit or release caller. After any repair, close/reopen only affected viewer windows and refresh that session’s relevant cached UI functions before rechecking; never clear the researcher’s unrelated workspace. If final code cannot be loaded safely in this session, report incomplete.
- **Six named focused checks; at most twelve evaluations in total**, including affected repeats following routine repair. No separate batch ceiling. Opening the disclosed three examples or multiple disclosed dialog actions within a check does not create unnamed checks. Record every failed/untested evaluation. Recheck only paths affected by a change, and include a final code/source preservation gate in 06.
- **At most 100 MiB new disposable evidence**, at a newly created `reference-validation/cc-02-usability-completion-20260930/` (stop if it already exists; do not overwrite). Native destinations are new empty `SaveParent`, `ExportParent` and `PortableExportParent` beneath it. No deletion of prior outputs; preserve new incomplete evidence if a write fails.
- Before implementation, pin the three original artifact contents/manifests, original audits and metadata used by these examples, cases.json, relevant definitions/calculation/persistence dependencies and UI/harness files. Record revised executable/harness hashes before affected checks and confirm final hashes afterwards. Hash reading is preservation, not a new scientific evaluation. Do not assert the historical 14/14 matrix validates revised UI code.

The existing 14-case numerical matrix is **not repeated by default**. The focused equality checks protect this presentation-only change. If inspection finds an affected calculation/persistence dependency that makes broader numerical regression necessary, identify it, stop and report why the six-check/twelve-evaluation scope cannot safely finish; do not silently spend a full matrix outside this budget. No calculation/persistence implementation change is included.

## Stop conditions and completion report

Routine UI failures may be repaired and affected checks repeated within this one approval, without per-error permission requests. Stop dependent checks until their prerequisite passes. Stop the slice for budget exhaustion, changed/missing original fixtures, unexplained stored-value/qualification drift, a required scientific/schema/persistence change, unsafe cache refresh, an unavailable second session requirement or any action that would run an engine/recording or resume release work. Mark unfinished checks failed or untested accurately; do not automatically retry after a material blocker or budget exhaustion.

Return the working viewer, short exact-path walkthrough, six-case results/repeat counts, code/input hashes, before/after layout evidence, cancel-state/file observations, new artifact paths, preservation results and remaining limitations. Self-review is labelled as such. Native interactions and visual acceptance are not arithmetic or physiology validation; success does not close G5, real-acquisition/resource/containment blockers or release. Historical `containment_failure`, consumed approvals and all original outputs remain unchanged.

Suggested scope decision: **“I approve CC-02U as one bounded presentation and native-chooser slice, including routine repairs, at most two active hours, one saved-data-only MATLAB session, six named checks and twelve total evaluations. Preserve all scientific values and qualifications; no calculation changes, recording runs, refits, footprint changes or release work.”**
