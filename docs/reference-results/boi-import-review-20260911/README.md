# MATLAB BOI import-review verification

Decision R1-IMPORT-007, 11 September 2026. The [import-review workflow](../../BOI_IMPORT_REVIEW_WORKFLOW.md)
now exposes acquisition and tissue evidence through normal MATLAB verification.
This is a developer verification record, not an independent researcher usability
test or scientific acceptance.

## Implemented behavior

The GUI's **BOI Input Review** tab uses the same preflight builder as individual
MATLAB review and batch verification. It distinguishes import failures,
unsupported inputs and readable inputs with scientific questions. Held inputs
block gated wrapper/statistics steps; warnings remain visible without a new
approval dialog. Technical readiness and scientific eligibility are separate.

Selecting a recording shows issues, affected measurements, evidence and actions.
Source issues and holds precede general review notes; original issue order is
retained in structured exports. **Open full review** opens a larger, scrollable
snapshot of the selected review. The snapshot is labelled with its update
limitation; it does not change if inputs are subsequently edited. Selecting a
new CSV or starting verification clears the active panel/report. A failed
verification cannot leave the previous successful report active for gated steps.

Verification writes a BOIInputReview workbook sheet, captured reviews/issues in
the MAT file, and an adjacent JSON review export. These retain source checksums,
original valid declarations and issue details. Malformed declarations retain a
failure message and the file fingerprint when readable. Existing master input
guards and statistics source/settings checks remain in place.

The researcher clarified that the AQuA2 outputs were exploratory detection work.
They are not treated as acquisition references, reviewed tissue masks or ground
truth. The original files and earlier observations remain preserved.

## Checks and observed results

- All **59 targeted MATLAB checks** passed in the initial run: seven new
  import/report/panel checks plus the 52 existing input, support, calculation,
  pipeline and availability checks. The seven affected import/UI checks were
  rerun successfully after the final display refinements.
- Synthetic checks cover unknown input evidence, confirmed sampling with an
  unreliable source clock, source identity warnings, unsupported timing,
  malformed declarations, unreadable input, and a declared reviewed mask with
  actor/alignment evidence. Readable and held rows remain correctly separated
  in the batch report and workbook. GUI row selection, full-review opening and
  clearing the panel are exercised.
- The **actual GUI verification callback** was run on a copied CSV pointing to
  the preserved staged HP recording. The GUI reported confirmed uniform **1 Hz**
  sampling, separate **0.96 s** exposure, seven review issues, automatic unreviewed
  tissue support and scientific eligibility not established. No incorrect
  timestamp-derived sampling hold was introduced.
- The HP source identity, calibration and static-tissue issues survived the
  GUI-driven verification export. The existing output folders made the technical
  summary Ready; that did not change the distinct scientific-status field.
- Native GUI screenshots were rendered for visual review. The initial display
  exposed cramped reading space, prompting the full-review window and clearer
  ordering. Earlier screenshots and reports remain intact.

The HP detector and statistics were **not rerun**. This work changes preflight,
presentation and verification export, not detector thresholds, normalization,
event quantification or prior tissue decisions. The source and earlier workflow
and event-review artifacts were checked against their recorded hashes.

## Evidence and limits

The portable [verification report](verification-report.json) and
[artifact record](artifact-record.json) identify the retained evidence. Final
local files are under workspace `reference-validation/boi-import-review-20260911-final/`;
the first GUI run remains under `boi-import-review-20260911/`. Logs retain the
initial 59-test result and subsequent focused checks. The live test used MATLAB
R2025a and did not run a detector, statistics job or cohort batch.

The UI does not perform anatomical reference discovery or mask drawing. It
cannot resolve missing experimental facts. The HP reference/identity/calibration
questions, dynamic validity, physiological interpretation and the independent
researcher release walkthrough remain open. A current-input review is distinct
from the declaration snapshots in an earlier master; no prior run is silently
updated with new scientific decisions.
