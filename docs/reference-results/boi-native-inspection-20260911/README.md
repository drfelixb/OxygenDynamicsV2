# Native-mask inspection in the MATLAB event viewer

R5-NATIVE-009, 11 September 2026. This extends the saved-event viewer without
changing detection, measurement rules, event identities or scientific decisions.
See the [researcher workflow](../../BOI_EVENT_REVIEW_WORKFLOW.md).

## Association and display

The selected event can be associated with a saved sink/surge master. Attachment
requires exact `AnalysisInfo` agreement with the audit, including source,
settings and acquisition snapshot; unique recording/site/event identity;
matching stored measurement and timing; matching native run bounds; and the
same union footprint used for amplitude. Invalid pixel indices and incomplete
frame support are rejected. The source master is hashed before and after loading.

The old audit did not capture a master-file checksum. This operation records a
newly attached snapshot and its evidence; it cannot retrospectively prove the
original per-frame masks from bounds/union agreement alone. That limitation is
visible and exported. No anatomical or scientific acceptance is inferred.

Native masks are isolated to the selected contiguous event run. Another event
at the same site does not enter the selected event's frame view or export.
Outside the native run, support is known empty; unavailable attachment remains
distinct. Orange denotes the fixed amplitude footprint; cyan denotes the native
mask for the displayed frame. The quantitative trace stays on the original fixed
footprint. A gray dash-dot trace marker identifies the displayed image frame.

Changing the frame clears the previous image. Changing or losing the attached
master blocks native display and attached export; failed replacement removes
the old selected attachment. Earlier exports remain preserved. The fixed view
does not depend on native-mask attachment.

## Verification

Focused tests cover shrinking/expanding support, both signs, native versus union
pixels, recurrence isolation, unavailable versus known empty support, mismatched
source/identity/union, invalid indices, changed master, pre-write export rejection,
GUI attachment/selection and CSV replay. Existing amplitude and viewer checks
remain part of the targeted run.

An initial GUI test found that an anonymous accessor captured the review before
attachment. It was replaced with a nested accessor to return the live review.
The failed test log is retained alongside the corrected execution evidence.

The HP walkthrough attaches the preserved sink and surge masters to the saved
audit. It inspects first/middle/last native frames, an outside-run frame and the
fixed-footprint comparison for a finite sink and the previously flagged surge
at site 1, event 4. Native coordinate CSVs reproduce per-frame counts and the
fixed union. Original amplitudes and baselines remain unchanged; the negative
surge is retained. No detector or statistics run is performed.

The [verification report](verification-report.json) records actual event
counts, native pixel ranges, hashes and execution results. The
[artifact record](artifact-record.json) identifies tests, snapshots and exported
ingredients. Local files live under workspace
`reference-validation/boi-native-inspection-20260911/`.

## Remaining scope

User-confirmed external 1 Hz timing remains authoritative; embedded clock values
remain unreliable provenance. Native event masks do not resolve observable
tissue, identity/calibration questions or physiological relevance. Per-recording
denominator navigation, cohort release and the independent researcher usability
walkthrough remain open. AQuA2 outputs remain exploratory detection artifacts.
