# MATLAB saved event-viewer verification

Decision R5-INSPECT-008, 11 September 2026. This is developer verification of
the [saved event workflow](../../BOI_EVENT_REVIEW_WORKFLOW.md), not a scientific
acceptance decision or an independent researcher usability test.

## Implemented behavior

The MATLAB launcher now exposes all 14 measurement definitions and opens saved
BOI event audits. Definitions can be read from the current dictionary or a
selected saved snapshot; their role and version remain explicit. A larger
definition window supports reading from the compact launcher.

Event inspection preserves both signs, full saved identities, missing values,
baseline evidence and direction disagreements. Plots use the saved quantitative
trace. A checksum-matched source frame can be displayed with the fixed amplitude
footprint, explicitly distinguished from native frame masks and anatomical
tissue. Missing/changed sources withhold pixels while retaining saved traces.
Selecting an event also selects and scrolls its row into view.

New-folder exports include trace samples, baseline/window flags, footprint
coordinates, original acquisition evidence, selected dictionary, readable
calculation, MAT/JSON provenance and content checksums. Audit/dictionary changes
are detected before GUI export. Outputs are local research artifacts containing
private source paths. Definition-file selection alone is not proof of historical
run correspondence.

## Checks and corrections

The 20 focused checks passed: eight event-inspection/export tests, five existing
independent amplitude-audit tests and seven existing import-review tests. The
eight event-viewer tests were repeated after display changes. Checks cover
both signs, negative surge amplitude, incomplete baseline, numerical replay
disagreement, malformed identity/support, missing/changed source, export replay,
preserved earlier exports, changed audit/dictionary, empty audit, GUI selection
and declared out-of-scope modality rejection.

The first test run found the reserved MATLAB table dimension name `Row` in the
footprint export and a resize callback warning. These were corrected to explicit
pixel coordinate names and appropriate figure resizing. The next replay test
exposed the need to read CSV membership flags as 1/0, rather than logical MATLAB
indices. The export guide and reproduction example now state that convention.
Those unsuccessful logs remain preserved.

Visual review of the first HP screenshots found poor dark-theme trace/table
contrast and limited definition-reading space. The final implementation uses
theme-aware trace colors, explicit readable table colors, selected-row scrolling
and a full-definition reading window. A reconnect check also verifies that a
stale image-error message is cleared when the preserved source becomes available
again. Earlier screenshots remain intact.

## Preserved HP example

The saved HP audit contains 249 events: 168 sinks and 81 surges. Every available
amplitude and baseline replay agrees; unavailable values remain unavailable.
The actual event viewer was exercised on one finite sink and the previously
flagged surge at site 1, event 4. Its exported 13 event samples are all below
the 20-sample baseline; the saved negative amplitude is retained (approximately
−0.2663%). It is not reinterpreted as a physiological oxygen increase.

The source remains confirmed external 1 Hz. Embedded clocks are unreliable
provenance; identity, calibration, tissue and physiological questions remain
open. The selected source image checksum matches the original audit. No
detector or statistics run was performed, and no event was excluded or changed.

The [verification report](verification-report.json) and
[artifact record](artifact-record.json) identify saved checks, hashes and
numerical replay. Initial local artifacts are under workspace
`reference-validation/boi-event-viewer-20260911/`; final display checks and
exports are under `boi-event-viewer-20260911-complete/`. Intermediate display
checks remain in `boi-event-viewer-20260911-final/`.

## Remaining limits

The saved audit does not contain each native frame mask, so the viewer cannot
reconstruct changing morphology or tissue occupancy from it alone. The union
overlay is not substituted for that evidence. Record-level denominator
navigation, final scientific decisions, cohort freeze and independent researcher
walkthrough remain open. Historical detector outputs and exploratory AQuA2
files do not fill these evidence gaps.
