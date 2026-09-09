# Changelog

This file records user-visible changes from the point at which structured
release notes were introduced. Earlier repository history has not been
reconstructed into releases.

## Unreleased

### Physical surge tracking and explicit recurring sites

- Replace the BOI fixed-seed, 390-pixel surge tracker with adjacent-frame mutual
  coverage (default 0.6), one-to-one candidate ownership and no gap filling.
- Express minimum surge area as 9,025 µm² (the previous 400-pixel cutoff at
  4.75 µm/pixel); derive integer pixel cutoffs from each recording's calibration.
- Filter contiguous runs by the ten-second minimum before grouping recurring
  sites using fixed first-event footprints. Site grouping preserves event counts.
- Export tracking/site methods, thresholds, possible split/merge and ambiguous
  site-assignment flags. Add assessed/unassessed recording QC counts and workbook
  definitions. Primary amplitude arithmetic is unchanged; changed surge masks
  can affect both-sign baseline exclusion.
- Isolate the previous fixed-seed tracker for the separate iOS path. Advance
  detection/measurement/statistics contracts and require reanalysis.
- Add ownership, motion, frame-rate, recurrence and metadata tests; a physical
  candidate sweep; and full-background static/noisy/moving signal comparisons.
  Complete 720 candidate cases and twenty full-movie runs on four source
  recordings. All 3,773 baseline/amplitude records match independent arithmetic;
  all thirteen identical-input comparisons preserve sink masks/timing/identities.
- Pass 67 focused tests, smoke and statistics integration. Independently verify
  constructed pixels, overlap scores, physical area, adjacent coverage, site
  anchors and unique pixel ownership. Reconstruct three cases to localize
  remaining failures to candidate continuity/geometry and duration qualification.
  Full-movie results remain mixed; see [tracking rules and limitations](docs/SURGE_TRACKING.md).

### Surge-path audit and smooth-signal validation

- Remove the obsolete z-score site-ratio computation from BOI surge construction
  and remove `SiteTraceAmplitude` from both BOI event exports. Final preserved-input
  event-footprint amplitudes already used the correct signed fractional-change
  formula; that primary formula is unchanged. Isolate the legacy iOS ratio helper.
- Include the last valid start frame in both candidate trackers, using the ceiling
  of fractional-duration thresholds. Preserve the existing overlap/matching rules.
- Add surge native bounds, unrefined timing method and recording-edge contact
  flags. Apply native-gap review flags to both signs and document their units.
- Advance detection/measurement/statistics contracts; require reanalysis. Audit
  the remaining fixed-overlap, timing and sink-only statistical-summary gaps.
- Extend validation to smooth pairs, single pulses and controlled intensity noise
  on two complete BOI movies plus a separate fluorescence control; independently
  recalculate every resulting event's baseline and amplitude. Complete 12 runs
  plus an unchanged FB2312 recheck: 1,973 event/status records agree numerically,
  including unavailable values. Preserve two negative raw surge amplitudes in
  FB2312 and document inconsistent smooth-surge detection across backgrounds.
- Pass 57 focused tests, smoke and master-to-statistics integration checks.
  Save source hashes, exact injected fractions, QC and independent pixel/overlap
  verification; keep earlier-contract reference results labelled historical.


### Retain close native BOI sink runs

- Remove spacing-based deletion from the BOI master. Preserve native runs that
  pass duration filtering and annotate close neighbors after site merging.
- Export previous/next empty-frame gaps in seconds, a 20-second development
  proximity flag and recurrence review status. Add close-run and unassessed
  recurrence counts to recording measurement QC without excluding flagged runs
  from descriptive totals or conflating them with invalid baselines.
- Advance detector, measurement and statistics identities; require reanalysis.
  Keep the separate iOS path unchanged.
- Add a gap/frame-rate sweep and controlled true-recurrence versus single-pulse
  fragmentation fixtures, plus saved-table/statistics export assertions and
  workbook definitions explaining native-run counts and recurrence uncertainty.
- Complete seven fixed full-recording reruns: both known strong sinks now survive
  with exact native/measurement bounds and close-run flags; missing amplitudes
  remain unavailable. The unmodified ID400 recording changes from 137 to 196
  sink runs, 104 flagged, with 97 finite amplitudes. This is not biological truth.
- Independently verify constructed inputs, all overlap rows, every saved native
  gap/flag, nonoverlapping same-site windows, and unchanged surge native masks.



### Full-recording known-signal comparison and sink-stage tracing

- Extend the fixed paired-input runner to all source pixels/frames while keeping
  injection source coordinates, windows and settings unchanged. Generalize the
  independent pixel/overlap audits to the recorded manifest geometry.
- Trace sink candidates, tracking, duration/spacing filtering and correlation
  passes, accepting the reconstruction only when final saved masks match exactly.
- Identify the crop's missing first −20% sink at the existing minimum-spacing
  rule: both native runs are 20 frames, but the 15-frame empty gap causes deletion
  of the earlier run. A duration-only diagnostic preserves both.
- Complete seven full-recording cases and confirm the same spacing deletion by
  exact-mask stage reconstruction. Qualify the earlier crop finding: the
  less-dimmed patches do not overlap retained surges at full extent.
- Independently verify all 1,101,004,800 constructed full-input pixels and all
  28 overlap rows; check that crop/full comparisons use identical source-space
  injections and settings.
- Keep this recurrence exclusion distinct from measurement-baseline availability;
  no production detector parameters or event rules change in this update.

### Paired known-signal validation pilot

- Add seven paired-input full-master runs with repeated local sinks/surges,
  uniform dimming and a less-dimmed patch on a global decrease, using a
  checksum-verified ID400 awake crop. Production settings are unchanged.
- Report native space-time overlap for both signs, retained event identities,
  timing errors and amplitude availability. Independently verify constructed
  pixels and overlap calculations; document the limits of cropped, unlabelled
  background experiments.
- Record evidence of relative-contrast surges during local input decreases,
  non-monotonic retention of stronger sink injections, and the candidate-area
  constraint imposed by the sink percentile rule. These are diagnostic findings,
  not validated detector-accuracy estimates.
- Correct stale measurement/statistics identities in the migration notes.

### Event-local sink timing

- Replace the unbounded whole-record search with connected, sign-aware edge
  searches. Split gaps between neighboring native events and apply an explicit
  20-second development search limit per side. Retain native edges when
  unresolved; preserve native event identities and masks.
- Export native bounds, search bounds and boundary-resolution statuses. Add
  timing-resolved/unresolved/not-assessed counts to EventMeasurementQC without
  conflating timing quality with baseline availability.
- Advance measurement identity to `event-footprint-local-timing-2` and statistics
  identity to `mouse-strict-3`; require reanalysis and reject mixed old outputs.
- Add nine timing/QC tests and reference-run invariants for containment,
  extension limits and nonoverlap. All 46 focused tests and the full smoke suite
  passed. All eight recordings passed the complete rerun with exact native masks,
  event identities and surge measurements preserved; 1,300 amplitudes/baselines
  matched independent recomputation.
- Eliminate same-site measurement-window overlaps in the reference set. Report
  621/976 BOI sink timings resolved and 355 unresolved at the provisional 20-second
  limit, plus a prespecified 5/10/20/40-second sensitivity sweep. Retained unresolved
  windows must not be interpreted as complete physiological event durations.
- Fix relative-path handling in the reference runner by canonicalizing its roots.
  Preserve the superseded failed-path attempt separately from the successful rerun.

### Independent event signal audit and timing findings

- Replace the stale sink amplitude audit (whole-site traces and fallback
  baselines) with independent event-footprint reconstruction for both signs.
  Check source hashes, full clean pre-event baselines, missingness and amplitudes.
- Add exact-stage reconstruction, saved-site trace checks, readable diagnostic
  plots and a native-window counterfactual harness. Preserve the original outputs.
- Audit all 1,300 reference events with zero measurement mismatches. Document
  17 raw/detection direction disagreements and the spatial-normalization sign
  reversal in the six flagged FB2312 surges.
- Identify unbounded sink timing as the next correction: 207/976 BOI sink starts
  extend more than 20 seconds before native detection; 111 events overlap another
  measurement window at the same site, with 60 sharing identical windows.
- All 37 focused tests and full smoke passed; final repository checks inspected
  335 MATLAB files with 51 Code Analyzer messages. Update publication priorities
  around event-local timing and explicit signal definitions.

### Multi-recording reference validation and tracking performance

- Add a pinned eight-recording reference set across six animals, with two
  awake/isoflurane pairs, finer spatial sampling, KX, awake-mobile and a
  separately reported fluorescence control.
- Add lossless NWB conversion with explicit axes, checksum/calibration checks,
  complete pixel roundtrip verification and failure-preserving batch reports.
- Cache surge pixel membership instead of repeatedly sorting intersections.
  Preserve strict overlap thresholds, first-match order, start-footprint
  matching and returned pixel lists. Exact equivalence tests cover randomized
  inputs, duplicate pixels, removed regions and threshold ties.
- All 32 focused tests, full smoke and repository checks passed; all eight
  reference recordings then completed conversion, master, statistics and numerical
  QC with an unchanged MATLAB source manifest. Both ID400 recordings matched
  original-tracker masks and event measurements exactly.
- Retain per-recording counts, amplitude availability, wrong-direction flags and
  separate fluorescence-control results. Document physical-scale and intensity
  provenance limitations separately from runtime/numerical success.

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
