# Baseline sensitivity in MATLAB event review

R2-BASELINE-REVIEW-038 · 12 September 2026 · Implementation and verification complete; scientific baseline choice open.

The existing saved-event inspector now includes a **Baseline diagnostic** tab. Select an event, open the tab, and compare its original mean reference with a line fitted only to the same clean pre-event samples. **View saved event** returns to the event list. **Export selected evidence** saves both the original result and the labeled diagnostic with calculation and source hashes. The [researcher workflow](../../BOI_EVENT_REVIEW_WORKFLOW.md) documents the complete interaction.

## What the diagnostic means

The plots show the preserved-input trace on the fixed native-union amplitude footprint, clean baseline samples, saved mean, fitted line and its event-window extrapolation. Measurement bounds and native detection bounds remain separate. The table shows full-window/two-half slopes, coefficient of variation, peak-to-trough variation, residual RMS, descriptive R-squared, extrapolation duration, minimum reference and signed integral.

The audit determines the required sample count and sampling rate. These FB2314 examples require **20 immediately preceding clean samples at externally triggered 1 Hz: 20 seconds**. No embedded recording timestamp replaces that cadence. An incomplete, nonlocal, nonfinite or mismatched baseline is not repaired with earlier samples. A line needs at least two samples; each half needs two samples for a half-slope. A flat baseline has unavailable R-squared. Nonpositive or nonfinite event references withhold the entire alternative amplitude and integral; the invalid line can remain visible to explain the reason. Missing values remain NaN in MAT/CSV and null in JSON.

The centered-sum least-squares fit uses only baseline samples. Its fractional trace is `(source-reference)/reference`; the diagnostic sink amplitude is the negative minimum, surge amplitude the maximum, and signed integral the sample sum divided by sampling Hz. The displayed difference from the saved amplitude is in percentage points. No event sample fits the line, no amplitude is clipped, and negative or tiny values remain available for inspection. The method assigns no stable/unstable label or scientific sign cutoff.

Substrate consumption can contribute to declining light output, but a short local slope does not establish its kinetics, spatial uniformity or physiological origin. Phase 037 showed that a line can reduce smooth-decay error and amplify an ordinary fluctuation. This tab exposes that reference dependence. It does not select a correction or relabel events.

## Three fixed examples from one FB2314 awake recording

| Saved event | Clean baseline frames | Saved amplitude (%) | Line diagnostic (%) | Difference (percentage points) |
|---|---|---:|---:|---:|
| Sink site 10, event 1 | 42–61 | −0.394548 | −2.661806 | −2.267258 |
| Surge site 1, event 3 | 483–502 | −2.064493 | +1.329630 | +3.394123 |
| Surge site 1, event 4 | 520–539 | −0.983013 | −1.106822 | −0.123809 |

These are the same source-audited cases from phases 034–036, with unchanged footprints, native bounds and measurement windows. A changed diagnostic sign is **reference sensitivity**, not physiological reclassification. The original audit row 1 supplies a fourth check: zero of 20 clean samples and an unavailable diagnostic. Exact fractions and identities are in [case-summary.csv](representative-02/case-summary.csv) and the per-case exports.

![Sink diagnostic](representative-02/sink-site10-event1-ui.png)

![Unavailable baseline](representative-02/missing-baseline-ui.png)

The two surge captures are [event 3](representative-02/surge-site1-event3-ui.png) and [event 4](representative-02/surge-site1-event4-ui.png). The table scrolls to its remaining metrics. All four final captures were visually reviewed; this is implementation QA, not independent researcher usability validation.

## Verification and preservation

- **29/29 MATLAB tests pass**, including all previous event, connected-review and window-review tests. New checks cover analytic fits, actual baseline lengths/cadences, baseline/source mismatch, nonfinite values, nonpositive extrapolation, flat traces, export identity and UI reselection. [Final test results](test-summary-04.json).
- Three real cases reopen and export with original saved event fields unchanged; the source audit SHA256 remains `c6ff9c10021068a659053da9be9e8a2092843c7caf19ad9ee8c14086df04776b`. Independent CSV arithmetic agrees to maximum absolute error `6.83e-12` across checked diagnostic quantities; original-amplitude replay error is below `1.95e-15` fraction. All 32 manifested export artifacts verify. [Independent checks](verification.json).
- MAT snapshots reload with identical Data and Receipt. Reopening the live inspector uses the **original audit**, not the exported `SelectedEventReview.mat` snapshot. UI closure/reopening and event reselection were checked.
- Four existing review/test MATLAB files changed; two new helpers were added. The other 463 prior MATLAB files remain byte-identical, including the measurement, detector, pipeline and statistics code. The dictionary remains `0.3.0-draft`, SHA256 `1eea8f70f37a0794800f764498f4fefc0e89bfc6b195ee1f3aa198ea810186a2`. Phase-start versions and focused patches preserve existing worktree changes. [Code preservation](code-preservation.json).
- All **64 sealed phase-037 files** verify, using preserved phase-start copies for subsequently appended standing documents. Prior output directories are retained. [Prior evidence record](prior-evidence-preservation.json).

The final combined MATLAB process took **44.88 seconds**, including tests and representative UI/export checks; representative review itself took 16.98 seconds. Maximum resident memory was 2,229,157,888 bytes, with peak memory footprint 1,768,557,664 bytes. There was no detector/statistics rerun or new biological movie copy. These figures establish bounded verification cost, not cohort throughput. [Resources](resource-summary.json).

The initial test dispatch failed because bare suite names were not on the path; full paths corrected discovery. Earlier numerical runs passed. Initial screenshot review then caught hidden interval markers surviving event selection. Clearing axes with reset and explicit marker regression checks fixed that display bug; end-bound visibility and unavailable text were also clarified. Initial logs, screenshots and implementation copies remain in local evidence. Final evidence is **representative-02**, **test-summary-04.json**, **verification.json** and **visual-review.json**. The machine-generated representative report's pending-visual status is retained verbatim; the subsequent visual-review record closes that check. [Verification history](verification-history.json).

## Traceability and reproducibility

The diagnostic identifies method `boi-baseline-linear-review-1`, schema `boi-baseline-diagnostic-1` and role `review_only_not_saved_measurement`. Export schema `boi-event-review-export-3` adds `BaselineDiagnostic.json` and two explicitly diagnostic CSV columns. It records source/audit/event identity, original saved amplitude, units, availability and review implementation hashes. Existing signed-fraction columns and dictionary definitions retain their roles. Old exports are preserved. Full selected MAT/JSON/CSV packets are in `representative-02/`; the original biological movie and audit remain at their existing paths.

Local evidence: `reference-validation/boi-baseline-review-20260912/` from the workspace root. It contains frozen scope, phase-start code hashes and edited-file copies, successive test runs, scripts, earlier screenshots, final exports, independent verification and focused patches. This portable report includes final exports, source copies ending in `.m.txt`, the verification scripts and preservation records. Existing source paths in receipts are historical provenance; relocating this report does not relocate the biological source. `artifact-record.json` hashes this packet, local evidence and current modified repository files, excluding the record itself.

To reproduce from the workspace root in MATLAB R2025a, run the scripts in local evidence after choosing fresh run-specific output names; their final output directories intentionally reject replacement. `runTests.m` runs the three named suites, `runRepresentative.m` performs the selected-audit review/export checks, and `verifyExports.py` independently checks the resulting CSV and manifests using NumPy. No production workflow needs to rerun for this saved-trace review.

## Remaining scientific and usability work

BOI-only scope, biological variability, physiological relevance, feasibility, usability and traceability remain standing requirements. This phase validates a diagnostic implementation on three selected cases from one mouse and synthetic edge cases. It does not establish cross-mouse performance, an anatomical boundary, independent researcher usability or an accepted physiological baseline. Craniotomy support and the prior cohort decisions remain unchanged.

Next: walk through the new tab with the researcher alongside the saved event evidence, confirming that original amplitude, diagnostic reference dependence and unavailable values are understood. Resolve the scientific distinction between net local source change and deviation from an expected/shared signal before considering a production baseline change.
