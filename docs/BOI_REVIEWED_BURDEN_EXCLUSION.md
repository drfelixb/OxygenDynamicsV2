# Saved pocket rejection and reviewed burden

## Authorized work

REVIEW-BURDEN-01, 16 October 2026. Owner: root; no delegation.
Felix explicitly requests that FB2317 sink site 13/event 5 be marked as not a
pocket in the existing review workflow, preserving the automatic result and
excluding that detection from the reviewed burden calculation.

User benefit: a saved researcher rejection actually governs the corresponding
reviewed burden export, with its reason and original detection retained.

Bounded scope: save one immutable `not_recognized` boundary-review revision
using the existing viewer/service. Add a separate, opt-in saved-results burden
export which consumes validated saved review revisions, excludes only rejected
sink detections, and invokes the existing burden calculation and workbook
writer. Export the burden tables for the same 17 saved recordings into a new
folder; do not rerun combined statistics or copy the large original bundle.
Unreviewed and uncertain detections remain included and explicitly identified.
This export does not establish that every retained detection is a true pocket.

Preserve formula, normalization, individual event ingredients, baseline rules,
automatic files, movies and previous exports. Other unavailable contributions
still withhold complete totals. No partial sums or general detector changes.

Acceptance: saved exact event identity/status/reason, reload in the viewer,
one excluded detection in a separate decision ledger, unchanged retained event
products/exposure, strict totals and workbook readback. Bound testing to eight
focused synthetic cases and this named saved example; use the running MATLAB
session, no restart. Allow two targeted repair passes, 30 minutes active work
and 256 MiB new output/evidence. Stop after verified export and handoff.

## Delivered

The existing viewer saved and reloaded a new immutable `not_recognized`
revision for FB2317 sink site 13/event 5 (audit row 89), with Felix's explicit
"not a pocket" reason and empty endpoints. The saved status, reason, actor,
revision path and history were visually verified in the MATLAB Researcher
boundaries tab. Automatic measurements and masks remain intact.

`exportBOIReviewedBurden` now accepts explicit saved review files and an
existing stats MAT bundle. Its separate reviewed calculation excludes saved
rejections before calling the existing burden calculator. Audit checksum,
recording/raw-source identity, event identity, saved bounds, clock and revision
history are checked. Drafts, conflicting snapshots and mismatched sources are
blocked. Rejected automatic rows remain in a separate table. This opt-in
export does not silently apply review files to ordinary automatic batch stats.

Delivered workbook:
`reference-validation/boi-fb2317-not-pocket-review-20261016/ReviewedBurden/ReviewedHypoxicBurden.xlsx`
with the existing seven burden sheets plus ReviewSummary, ReviewDecisions and
ExcludedDetections. A MAT file, CSVs, portable saved review copy, status/provenance
and the existing selected-event evidence export accompany it.

- All 17 original recording identities/exposures remain.
- Automatic detections: 5,407; rejected: one; reviewed retained: 5,406.
- FB2317 retains 256 of 257 detections: 136 available and 120 missing contributions.
- Across all recordings: 3,256 available and 2,150 missing contributions.
- Complete recording burdens remain unavailable for all 17. No partial sums.
- Retained event ingredients, products and normalization are unchanged.
- Eight focused synthetic cases pass, including strict missingness, exact
  recording identity, saved revision precedence, unchanged automatic input,
  draft/tamper/ambiguity rejection and the known empty reviewed event set.
- MATLAB independently checks products, strict totals and normalization for
  17 recordings and reads the exported workbook back.
- Independent XLSX readback compares all 5,406 retained rows / 583,848 cells
  against the original workbook, with zero error cells. The original workbook
  checksum is unchanged; the large source MAT checksum is checked before/after
  preparation. All 574 previously protected MATLAB files remain unchanged.
- New output/evidence occupies approximately 105 MiB, below the 256 MiB limit.

Evidence: `final-verification.json`, `independent-workbook-verification.json`,
`focused-test-results.json` and `original-code-preservation.json` in the named
reference-validation folder. The first save recipe stopped before writing
because a display-name check incorrectly expected FB2317 inside its UUID-based
RecordingID; it was corrected to use the exact saved recording selection.
The delivered revision and export each completed once. No MATLAB restart,
detector/correction/statistics rerun, new baseline rule, package or Git transport.

Status: delivered and stopped. Further detection judgments require researcher
review; the other retained detections have not been adjudicated by this action.
