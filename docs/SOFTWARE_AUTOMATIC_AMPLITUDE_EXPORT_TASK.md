# Automatic amplitude and summary export clarification

1 October 2026 · AMP-EXPORT-01 · Owner: assistant (implementation and self-review)

Approved by researcher: complete task, including ordinary repairs and necessary verification.
Benefit: scientists can distinguish optical amplitude, its reference, units, sign, summary level and actual contributing population without decoding development names.

## Bounded scope and budget (recorded before implementation)

Preserve formulas, all existing numerical results and column identifiers. Add companion definition, average-count and availability tables to BOI statistics exports and saved export data, with a readable report. Explain site means, recording event means, within-mouse recording means and equal-mouse group means. Keep unavailable amplitudes, negative amplitudes excluded from burden, and unavailable event composites separate; expose overlapping categories honestly.

Maximum 3 active hours, 2 MATLAB starts, 4 verification batches, 36 named-case evaluations including repeats, 150 MiB new evidence. No recording analysis/statistics pipeline reruns, correction refits, detector/footprint changes or release operations. Saved-table export and pure summary helpers only. Ordinary repairs included within the same budget. Stop when named final-code checks pass and example export is delivered, or report incomplete at a budget ceiling.

## Fixed acceptance cases

Six synthetic cases: mixed positive/negative/missing amplitudes; unequal site event counts; all amplitudes missing; all negative with zero burden contributors; zero events; percentage conversion with explicit older negative-drop provenance. Include differing composite availability from missing area/duration and unequal recordings per mouse, strict within-mouse missingness and zero contributing mice.

Three saved examples: ID400 G2 automatic statistics and G4 saved arithmetic ingredients; historical FB2312 and C02 from the accepted saved comparison packets (preserve automatic/reviewed distinction). Check export persistence and exact existing-table preservation. At most nine cases per batch; maximum 36 evaluations across four batches, including routine repair repeats.

Numerical preservation: unchanged calculation-source hashes; exact isequaln comparisons of old table columns before/after export; saved ID400 amplitude replay within its existing 1e-12 tolerance; unchanged saved-input hashes. Export verification includes CSV, MAT and workbook round trip, count reconciliation and readable report. No independent human review is claimed.

Evidence: `reference-validation/automatic-amplitude-exports-20261001/` outside the repository. Delivery status and consumed budget recorded at completion.

## Completion

Delivered: [report](SOFTWARE_AUTOMATIC_AMPLITUDE_EXPORT_DELIVERY.md). Final 9/9 cases pass. Four batches/36 evaluations consumed. Two working MATLAB starts plus one unsuccessful invocation. Calculation and saved-input hashes unchanged. The 150 MiB storage ceiling was exceeded before a lossless compression repair; this exception is disclosed, not waived. No further tests or launches; release work stays paused.

## Researcher acceptance — 4 October 2026

The researcher accepted the automatic amplitude export clarification **within its demonstrated scope**. The storage-budget exception, earlier failures, scientific limitations and historical execution evidence remain unchanged. This acceptance does not establish all-metric validity, physiological interpretation or release readiness. Development and release are paused. No further verification, MATLAB launches or new analysis task is authorized automatically; await a new explicit researcher requirement. This record is a documentation-only update.
