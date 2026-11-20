# Connected MATLAB workflow — implementation phase completion

11 September 2026. **R5-CONNECT-012** completes the current connected
review implementation and its developer verification. It does not close formal
R5 release, which requires independent researchers and scientific eligibility
under the original workflow contract. The [handoff packet](../../BOI_RESEARCHER_WALKTHROUGH.md)
is ready; its observation record is intentionally unfilled.

## Implemented path

From a saved recording/window, select a sign and event, choose a saved audit,
and open that exact event's baseline, trace, source frame and native support.
The connection uses `StatsRecordingIndex → StatsInfo.Recordings.Folder` when
portable and original IDs differ. It also checks source hash, frame grid,
sampling, scale, both-sign tissue support, acquisition declarations and the
selected event's saved bounds/baseline/amplitude. Similar filenames do not
establish identity. Missing/mismatched evidence remains unavailable.

The event view retains the selected window's onset membership and overlap.
**Return to window** preserves selection. Event exports retain a `WindowLink`
with both IDs, results/audit/source hashes and actual contributions. An unrelated
event does not inherit that link; changed statistics block connected export.
This is a checked review-time association, not a historical checksum claim.

**Create event source audit** is now available in the main BOI Measurements tab.
It explicitly reads the full preserved source with a runtime notice, reuses the
existing amplitude/baseline audit, preserves prior folders and records source/master
hashes. A creation failure leaves an incomplete marker that the viewer rejects.
New audits can bind native-master attachment to creation-time hashes; older audits
retain their original absence of that evidence. Scientific decisions are not inferred.

## Bounded execution and results

- **31 targeted MATLAB tests passed**: six connected-workflow/audit cases plus
  25 existing event/window/surge review cases. Coverage includes both signs,
  recurrence, partial windows, source/identity/calibration/support/measurement
  mismatches, result mutation, GUI return navigation, new audit receipts,
  immutable output folders and failed audit creation.
- One new **source-only HP audit** read all 1,200 frames, completed in **11.93 s**,
  and retained **249 events with zero measurement mismatches**. All 27 shared
  columns match the prior audit exactly. One negative surge amplitude remains.
  No detector or statistics run occurred in this phase.
- The connected HP developer walkthrough completed in **58.32 s** inside MATLAB,
  including source auditing, GUI inspection/exports and the actual input-verification
  callback. Peak memory was not separately measured for this pass. Prior full
  workflow resource observations remain in their original evidence record.
- Sink site 1/event 3 was selected through the window: 46 s overlap, amplitude
  **0.043430622645630072** fraction. Surge site 1/event 4: 13 s overlap, amplitude
  **−0.0026630285807158357** fraction. Both native displays matched source/master
  checksums; neither value or event identity changed.
- Preserved A [0,1200) and B [30,1200) statistics retain exactly identical event
  tables. Both occupancy values replay from their own saved window ingredients.
  This is diagnostic setting evidence, not an experimental baseline decision.
- Developer screenshots were inspected for the import/QC view, launcher,
  window-event selection and both-sign source/native-mask/trace views. The import
  view shows confirmed 1 Hz, 0.96 s integration, automatic unreviewed tissue and
  scientific eligibility not established.

The [structured report](verification-report.json) records independent Python
CSV replay, storage, code hashes and prior-file preservation. Tests and the HP
walkthrough passed without a failed execution correction in this phase. The
expected wrong-master warnings come from rejection tests. Synthetic audit failure
is intentional and verifies incomplete-output handling.

## Artifacts and completion boundary

Local evidence is under
`workspace/reference-validation/boi-workflow-phase-20260911/`: the new source
audit/creation receipt, connected event and window exports, screenshots, test
results, code manifest, preserved A/B comparison and verification script/log.
The actual GUI input-verification reports were generated as new files under the
original HP workflow's `Verification_Reports`; copies are included in this phase's
artifact record. No earlier file was overwritten.

[Artifact manifest](artifact-record.json) and
[decision record](../../planning/boi-workflow-phase-20260911.json) preserve the
implementation and execution account. Local evidence deliberately retains original
paths/metadata; it is not a public sanitized dataset.

The current implementation checklist is complete. The **formal R5 gate is open**:
no independent researcher or second-person release replay has yet been observed,
and the HP recording is still development/training data. Source identity/labels,
physical calibration, anatomical/dynamic support, broad image changes, onset/
recovery interpretation, outcome hierarchy and animal-level inference remain open.
AQuA2 exploratory detection is not anatomical evidence. No tissue mask, physiological
claim, evaluation independence, cohort admission or R6 release has been invented.
