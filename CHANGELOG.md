# Changelog

This file records user-visible changes from the point at which structured
release notes were introduced. Earlier repository history has not been
reconstructed into releases.

## Unreleased

### DANDI metadata reconciliation (2026-09-09)

- Inspect acquisition/subject headers for all 87 assets in the pinned release.
  Match all 83 annotated-workbook records; numerical calibration and grouping
  metadata agree for those matched records.
- Explicitly select the uniquely named BLI series in six multiseries files.
  Preserve fluorescence-control identity; do not pool it as a BOI experiment.
- Keep four asset/session mappings unresolved: F120, F134, F136 and M189.
  Their NWB calibration is 1.54 µm/pixel versus 1.55 in candidate CSV rows.
  No baseline/stimulation segment boundaries are inferred.
- Correct the ID400 reference harness genotype from unspecified to WT and
  include subject/group labels in future reference reports. Previously saved
  reports remain historical records; no numerical detection rule changed.

### Breaking analysis changes — existing V3 development (2026-09-09)

- Require reanalysis under schema `3.0-dev`; reject older output contracts,
  changed source TIFFs, inconsistent calibration and mixed source runs.
- Correct temporal normalization from sqrt(SD) to SD. Detection populations
  can change; default thresholds require further validation.
- Quantify raw amplitude over individual-event footprints with complete,
  clean pre-event baselines; retain events with unavailable amplitudes.
- Use native event masks, inclusive frame durations and explicit eligible
  tissue intersections for occupied area.
- Separate site, event, recording and animal summaries; retain zero-event
  recordings and apply strict missingness to composite totals/animal summaries.
- Add explicit recording/window baseline comparisons, physical puff timestamps
  and graceful handling of unavailable summary figures.

### Consistent recurrence units and measurement availability (2026-09-09)

- Replace ambiguous `NumOxySinkEvents_Norm` / `NumOxySurgeEvents_Norm`
  columns and sheets with `SinkSiteEventRate_per_min` /
  `SurgeSiteEventRate_per_min`. Both are events/minute; the previous surge
  metric was events/second. Update figure and workbook consumers.
- Export per-recording/per-event-type `EventMeasurementQC` and
  `EventBaselineStatusCounts` in MAT and Excel, including zero-event rows.
  Count unavailable and wrong-direction amplitudes separately.
- Advance statistics identity to `mouse-strict-2`; mixed contracts are rejected.
- Add recurrence-unit and measurement-provenance regression tests; extend the
  synthetic integration to verify QC and renamed workbook sheets. All 28 tests,
  full smoke, repository checks and synthetic integration passed.
- Repeat the full DANDI reference: detection counts unchanged; QC exposes one
  wrong-direction sink amplitude and 64 events lacking clean baselines.
- Define a validation route without exhaustive manual labels. Simulation and
  robustness evidence do not establish biological detection accuracy.

### Development validation and documentation

- Add 24 focused calculation/regression tests and synthetic integration.
- Add checksum-pinned full-resolution DANDI reference runner and numerical QC.
  One awake recording completed master and statistics; no accuracy labels exist.
- Add detailed calculation definitions, validation results and publication
  readiness plan. Update README to describe the breaking development version.

### Added

- Public-facing project overview, requirements, citation metadata, and
  contribution guidance.
- Issue forms, pull request template, security policy, and release process.
- Third-party provenance and licence notices.
- Open-source program application notes based on verifiable repository facts.

### Changed

- Release manifests no longer expose machine-specific absolute paths.

### Pending

- Select and approve a project-level licence.
- Reconcile the Git tag and internal pipeline version before the next release.
