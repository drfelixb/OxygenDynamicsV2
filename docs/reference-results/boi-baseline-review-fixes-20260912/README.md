# Baseline diagnostic code-review fixes

R2-BASELINE-REVIEW-FIXES-039 · 12 September 2026 · Both reproduced P2 findings corrected and verified.

The **Baseline diagnostic** tab now separates saved-versus-audited disagreement from reference sensitivity and keeps both native event bounds visible. Open a saved event audit, select an event and choose the tab. The [researcher workflow](../../BOI_EVENT_REVIEW_WORKFLOW.md) describes the updated display and export.

## Audit disagreement and reference sensitivity

The tab displays three amplitudes: the original saved result, the audited constant-reference result and the fitted-line diagnostic. **Reference sensitivity is line minus audited amplitude**, in percentage points, using the same preserved source and measurement window. A saved-versus-audited mismatch is explicitly flagged. The earlier line-minus-saved difference remains in the metric table and export, labeled as potentially including audit disagreement. It is not relabeled or silently changed into the new comparison.

The plot labels the audited mean correctly. When the stored baseline differs, it draws a separate stored baseline; both numeric values are retained in the table. Older supported audits without a stored baseline leave that value unavailable. Disagreement remains visible even when a separate problem makes the diagnostic unavailable. No original measurement is replaced.

The review fixture has baseline samples of 100 and event samples of 80. Both audited mean and line yield a 20% drop, whereas the saved result is 40% with a stored baseline of 90. The fixed display shows **zero reference sensitivity**, the mismatch warning and both reference identities. The original −20 percentage-point line-minus-saved difference remains in the export.

![Corrected mismatch display](screenshots/fixed-case-2.png)

## Native interval visibility

The x-limits include both native endpoints as well as the baseline and measurement interval. A native end at +6 seconds is now visible when the measurement ends at +2 seconds. Repeated event selection clears prior interval markers. Expanding the display does not add baseline samples, extend the fitted line beyond its original calculation interval or change the measurement footprint.

![Native bounds retained in view](screenshots/fixed-case-1.png)

## Validation and preservation

- **31/31 MATLAB tests passed** across event, connected-event and window-review suites. The two new tests cover serialized mismatches for both signs, export/reload and hashes, absent historical stored baseline, unavailable diagnostics, clearing a mismatch on event reselection, and native bounds before or after the displayed source samples. [Test summary](test-summary-01.json).
- The exact saved code-review fixtures were reopened without modification, and six actual MATLAB screenshots were inspected: both corrected fixtures, the same three FB2314 events and the existing unavailable-baseline event. [Visual review](visual-review.json).
- The FB2314 cases retain identical all-frame quantitative data, event rows, native-union footprints and every prior diagnostic field except the incremented schema. Twelve trace/footprint/dictionary files are byte-identical to the prior exports. The original biological audit SHA256 remains `c6ff9c10021068a659053da9be9e8a2092843c7caf19ad9ee8c14086df04776b`. [Saved-case validation](validation.json).
- Independent Python checks verify all **48 manifested export artifacts**, comparison arithmetic and roles, implementation hashes and original selected-event identities. [Verification](verification.json).
- Only four MATLAB review/test files changed; **465 other MATLAB files remain unchanged**. The detector, quantifier, statistics, measurement dictionary and fitted-line arithmetic are preserved. Phase-start snapshots and focused patches retain existing worktree changes. All **229 phase-038 sealed files** and **18 code-review evidence files** verify, using preserved pre-edit versions where repository files were updated. [Preservation record](preservation.json).

The MATLAB views/export validation took 31.69 seconds. No detector/statistics run or biological movie copy was needed. Final full exports remain in local evidence; this portable report copies the smaller diagnostic records, screenshots, verification and source snapshots. This avoids repeating the large existing acquisition metadata receipts in the report. No new memory benchmark was performed.

## Versioning and evidence

Diagnostic schema is `boi-baseline-diagnostic-2`; export schema is `boi-event-review-export-4`. The unchanged fit method is `boi-baseline-linear-review-1`. New fields identify saved/audited agreement and references, `DifferenceFromAuditedAmplitude_pp`, and explicit roles for both differences. `DifferenceFromSavedAmplitude_pp` keeps its prior numeric meaning. Old exports remain intact and may lack the new fields.

Local evidence is `reference-validation/boi-baseline-review-fixes-20260912/` from the workspace root. `runTests.m` executes the suites; `validateViews.m` compares against preserved phase-038 snapshots and writes new exports; `verify.py` independently checks those exports and preservation. Choose fresh output names to rerun validation; existing folders intentionally reject replacement. Executed scripts and implementation copies in this report end in `.txt` to avoid adding duplicate MATLAB functions to the repository. `artifact-record.json` records hashes of local evidence, this report and the changed repository files.

The machine-generated view validation says pending visual review because the subsequent screenshot inspection is recorded separately in `visual-review.json`. The previous review findings and failing-behavior screenshots remain in their original evidence directory.

## Scientific scope

These are review and traceability corrections. Original 20-sample baselines at externally triggered 1 Hz, negative and unavailable values, event windows and tissue support remain unchanged. No embedded timestamps, substrate kinetics, automatic correction, stability cutoff or event exclusion is introduced. BOI-only scope, biological variability, physiological relevance, feasibility, usability and traceability remain standing requirements. The three selected examples are from one mouse; independent researcher usability, cross-mouse generalization and the scientific baseline choice remain open.

What’s next: researcher walkthrough of the corrected diagnostic alongside the original saved event evidence, before any production baseline decision.
