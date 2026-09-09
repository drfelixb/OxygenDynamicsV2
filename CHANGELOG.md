# Changelog

This file records user-visible changes from the point at which structured
release notes were introduced. Earlier repository history has not been
reconstructed into releases.

## Unreleased

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
