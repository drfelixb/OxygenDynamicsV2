# Saved recording/window viewer verification

R5-WINDOW-010, 11 September 2026. The
[MATLAB recording/window workflow](../../BOI_WINDOW_REVIEW_WORKFLOW.md) connects
saved summary values to denominator, native-union area and event-timing evidence.
This is developer verification, not biological acceptance or an independent
researcher usability test.

The viewer reads selected variables from an existing `DataOutput.mat`, validates
recording/window/frame identities and the input-contract source association,
and replays three sink window quantities. It exposes disagreements, unavailable
values, partial-frame intervals, boundary onsets and ongoing events. Tissue
support for both signs remains visible. Surge window outcomes are explicitly
unavailable in the current saved window schema; no zero or substitute is added.

Targeted checks cover partial-frame exposure, unit conversions, window onsets,
ongoing events, camera exposure distinct from frame spacing, missing native
area, zero tissue denominator, completed zero-event analysis, failed-recording
status, missing or duplicated frame rows, source identity, out-of-scope modality,
CSV replay, immutable exports and GUI selection. Existing event-viewer tests
check that the companion inspection workflow remains functional.

The initial arithmetic tests passed; the GUI test exposed a local variable
shadowing MATLAB's `grid` plotting function. The variable was renamed. The
initial unsuccessful log is preserved with the corrected run.
Visual review also replaced the narrow automatic denominator-axis scale with
a zero-based scale for nonnegative tissue-time contributions. The original
screenshots remain preserved.

The actual HP saved-results walkthrough opens the new viewer, selects the
recording window, reads its frame/event/support views and exports its ingredients.
It separately replays occupied fraction, onset rate and concurrent-event density
from the CSVs. The original acquisition-boundary onset remains counted under
the saved descriptive policy. No physiological onset decision is made.

HP timing remains confirmed external 1 Hz, with 0.96 s camera exposure retained
separately. Identity/calibration/tissue questions stay open. No detector or
statistics run is performed; source images and prior results are preserved.

The [verification report](verification-report.json) gives actual values and
test outcomes. The [artifact record](artifact-record.json) identifies logs,
screenshots and exports under workspace
`reference-validation/boi-window-review-20260911/`.
The final display verification is retained separately under
`reference-validation/boi-window-review-20260911-final/`.

Limits remain explicit: arithmetic checks do not reconstruct all native masks,
validate anatomical support or establish physiological meaning. Surge window
exports, independent researcher usability and final scientific/cohort decisions
remain separate work.
