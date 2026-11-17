# C02 eligibility evidence matrix

R1-C02-ELIGIBILITY-090, 21 September 2026. Existing-evidence inventory, not a
new biological evaluation, method change or cohort admission decision.

- `build_matrix.py`: joins canonical assets, the eight-source readiness record,
  five historical reference reports, later ID400 workflow, accepted FB2314 support
  and restricted-profile verification. No new movie reads or MATLAB runs.
- `source-bindings.json`: exact consulted source versions and hashes.
- `matrix-counts.json`: 14 recordings, 7 mice, 196 recording/measurement entries;
  6 recordings with run evidence, 1 accepted ROI, 7 unaccepted drafts, no new exclusions.
- `before/`, `code-before.json`, `preservation.json`: cumulative-document snapshots,
  all 495 unchanged MATLAB files and all 25 prior sealed artifacts.
- `verification.json`: identity/pair/measurement coverage, source, run and link checks.
- `artifact-record.json`, `completion.json`: final inventory and completion.

The installed readable report and structured JSON are the deliverables. Run evidence
is historical and profile-specific. Absence from the selected evidence corpus does
not prove that no other run exists. No mounted-source availability or full payload
check is claimed. Previously resolved source correspondence is reused as evidence.
No recording is removed because the current detector is imperfect. Next is the
existing FB2314 isoflurane working-outline review, followed by comparable analysis.
