# Changelog

This file records user-visible changes from the point at which structured
release notes were introduced. Earlier repository history has not been
reconstructed into releases.

## Unreleased

### Experimental amplitude eligibility and failure decomposition

- Add explicit arithmetic and raw-direction conditions for provisional surge
  amplitudes, retaining signed diagnostics and missing/unresolved states. Export
  reference-half sensitivity without introducing a new exclusion threshold.
  Production detection, measurement, statistics and contracts remain unchanged.
- Replay all 11,433 frozen selector recipe/control rows on six recordings plus
  a separate noiseless support. Independently verify every row and 2,534 exact
  paired-source decompositions; inspect all 89 previously flagged measurements.
- Explain 18 negative cases on nine supports: source fluctuations outweigh the
  imposed increment in 15, while reference contamination changes the sign in
  three. All share a prescribed peak 19 seconds before the native interval.
  Reference-half positivity fails to flag all 71 cases above the one-percent
  contamination screen. Keep these checks diagnostic pending interval/reference
  validation; do not force positive values or discard detected events.
- Pass 175 MATLAB and 61 Python tests, including optimized Python execution.
  Update the README, roadmap, [protocol](docs/SURGE_AMPLITUDE_ELIGIBILITY.md), and
  [results with trace examples](docs/reference-results/surge-amplitude-eligibility-20260910/README.md).

### Experimental onset selection and new waveform/background evaluation

- Add a prespecified comparison of rising-only and pulse fits with a two-family
  score penalty, explicit disagreement/uncertainty states and unchanged signed
  raw baseline/amplitude arithmetic. Keep all production rules unchanged.
- Replay selection on the previous 5,520 planned recipes; evaluate 36 unseen
  waveform recipes on 308 frozen event supports from six source recordings,
  including 193 supports from ID13 awake/mobile and FB2316 under KX. Historical
  supports remain historical; this is measurement validation, not a detector rerun.
- Independently verify all 33,372 new result rows, 21,570 component fits including
  controls, 231,600 additional raw support-frame means and 193 native mask unions.
  Pass 167 MATLAB and 56 Python tests, including optimized Python execution.
- On the additional backgrounds, estimates within five seconds increase 966 to
  1,004 of 6,588 constructible cases, with 84 gains and 46 losses relative to pulse.
  Source-control resolutions rise seven to thirteen. Retain three noiseless
  timing failures, 71 baseline-contamination flags and 18 negative raw amplitudes.
- Keep the selector experimental pending an explicit amplitude/reportability
  definition. Update the README, roadmap and
  [results and review list](docs/reference-results/surge-model-selection-20260910/README.md).

### Experimental rise, plateau and recovery fit

- Add a batch pulse-template fit with independent rise/plateau/recovery lengths,
  two shape families, a nonnegative pulse component and linear background.
  Preserve the available contiguous context, strict raw reference and native
  peak interval. Template coefficients/durations remain diagnostics; production
  measurement, detection, statistics and default experimental fit are unchanged.
- Specify the grid and conservative complexity penalty before evaluation.
  Recompute near-exact residuals directly to avoid cancellation. Test all 48
  noiseless recipes, recovering each first positive sample exactly.
- Verify all 5,520 planned rows, 5,136 constructed fits and 115 source controls
  against independent NumPy profiles and selected-template residuals. Estimates
  within five seconds increase 856 to 1,056; median resolved absolute error falls
  4 to 2 seconds. Paired results also expose 190 previously within-tolerance cases
  that no longer meet that criterion, with losses concentrated in slow rises.
- Keep the pulse fit experimental pending model-selection and out-of-family
  validation. Pass 151 MATLAB focused tests and 48 Python tests, including
  optimized execution. Update the README, roadmap and
  [complete comparison](docs/reference-results/surge-pulse-onset-20260910/README.md).

### Surge onset information and available clean context

- Add an experimental context option that begins after the latest preceding
  overlapping detection, while preserving a contiguous 20-second reference,
  bounded search, score/profile thresholds and explicit unresolved states.
  The default fixed-context method and production pipeline are unchanged.
- Specify a mean-trace panel on 115 source supports from three BOI recordings
  and a separate fluorescence control: 48 recipes per support varying optical
  increment, rise length/shape and delay. Retain all 5,520 planned cases, including
  384 without enough known pre-onset reference; evaluate 5,136 constructed traces
  under both methods plus 230 source controls.
- Independently verify 10,272 constructed fits, 230 source fits and all 11,040
  planned result rows. The available-context option preserves all 878 fixed-rule
  resolutions and adds 425; estimates within five seconds increase 564 to 856.
  Neither count establishes biological accuracy or supports production promotion.
- Separately document 96 post-hoc noiseless fits: short rises followed by a late
  native start expose the rising-line model's own limitation. Prioritize a model
  allowing rise, plateau and recovery, with the same clean-context safeguard.
- Pass 145 MATLAB focused tests and 42 Python tests (also under optimization);
  keep README, provenance, result tables and a scientific overview plot current.
  See the [protocol](docs/SURGE_ONSET_TRACE_PANEL.md) and
  [results](docs/reference-results/surge-onset-trace-panel-20260909/README.md).

### Experimental bounded surge onset

- Specify and implement a validation-only raw-trace broken-line onset estimate
  with fixed full-event support, bounded timing, neighboring-event exclusions,
  score/profile diagnostics and explicit unresolved states. Proposed baselines
  precede the estimate; native peak windows remain fixed. Missing native signal
  or a nonpositive reference prevents a provisional amplitude.
- Evaluate 228 frozen events on constructed and paired source traces (456 fits)
  across eight movies from four sources. Independently reconstruct exclusions,
  fits, baseline arithmetic, paired-source effects and case/match coverage.
- Resolve none of the five preselected imposed surges. Eight other event rows
  resolve on identical source signals; this does not validate physiological
  onset. Do not promote the rule or change production calculations.
- Pass 135 MATLAB focused tests and 34 Python tests, including optimized Python
  execution. See the [protocol](docs/SURGE_LOCAL_ONSET.md) and
  [results](docs/reference-results/surge-local-onset-20260909/README.md).

### Surge amplitude support and baseline decomposition

- Add a validation-only comparison of full-event footprints and fixed 50%/75%
  occupancy cores. Preserve the full-footprint clean-baseline frame list across
  supports and retain unavailable measurements. Recipe common cores are marked
  as oracles rather than deployable estimators.
- Decompose paired constructed/source traces into background, imposed signal
  and baseline effects at the same observed peak. Account for the changed
  denominator and preserve positive/negative imposed contributions separately.
  Clearly distinguish unscreened diagnostics from reportable amplitudes.
- Audit all 228 retained surges from eight frozen growing/shrinking movies on
  four sources; reproduce 130 available and 98 unavailable full-event amplitudes.
  Independently reconstruct 537,371 support-frame samples and verify 692 support
  rows. No new detection/master/statistics runs or production formula changes.
- Pass 123 MATLAB and 26 Python tests, including nine new MATLAB and seven new
  Python checks. Results show that tighter support can worsen rising-phase
  baseline contamination. Prioritize event-local onset/reference validation
  before adopting a core amplitude. See the
  [protocol](docs/SURGE_AMPLITUDE_SUPPORT.md) and
  [complete evidence](docs/reference-results/surge-amplitude-support-20260909/README.md).

### Experimental local surge separation

- Add a validation-only candidate partition requiring two persistent predecessors,
  separated peaks, a connecting intensity valley and valid child regions. Preserve
  every admitted pixel and retain partition exposure separately from graph contact.
  Normal detection, measurement and statistics rules are unchanged.
- Add a prespecified full-image protocol with stationary, approaching and crossing
  Gaussian pairs, a single expanding profile, and unchanged source controls. Score
  distinct retained runs against imposed light; one merged event cannot count as
  recovery of both sources. See the [protocol](docs/SURGE_CONTACT_SEPARATION.md).
- Add twelve MATLAB checks and nine Python verifier tests. Independently rebuild
  challenge pixels, check full-frame candidate conservation and native run bounds,
  recalculate light inside saved masks, and verify distinct-run score assignment.
- Complete twenty full-movie evaluations on four source recordings, with zero
  master/statistics reruns. All 114 MATLAB and 19 Python tests pass; independent
  checks verify 2,621,419,496 constructed pixels and 112 coverage records. Trace
  960 prescribed peak-location frames. Stationary-pair gains do not generalize
  to contact trajectories or the finer source, so the prototype is not promoted.
  Document controls, admission limitations and the
  [full comparison](docs/reference-results/surge-separation-20260909/README.md).

### Production surge contact provenance

- Export `SurgeTrackingEdges` and `SurgeContactFrames` in normal per-recording
  CSV/MAT outputs. Preserve all nonzero candidate overlaps, actual link choices,
  rejected siblings and recording-local candidate/event/site joins.
- Add unique contact frames, duration and footprint exposure, incident-edge
  counts and rejected-neighbor flags to candidate QC and retained surge events.
  Preserve linking, duration qualification, site grouping and amplitude rules.
- Add explicit contact assessment and retained-event exposure totals to
  `EventMeasurementQC`; distinguish event-frames/event-seconds from recording
  time and keep rejected candidates outside event totals. Update workbook
  definitions and [contact-output documentation](docs/SURGE_CONTACT_PROVENANCE.md).
- Advance measurement/statistics contracts to require complete reanalysis before
  pooling. The detector and normalization identities are unchanged.
- Pass 102 MATLAB tests, smoke and synthetic master/statistics integration, and
  ten Python verifier tests. Independently audit six cached candidate replays
  with unchanged masks and identities. Complete one ID401 challenge master and
  statistics rerun: 123 sink events and 18 surge events across 11 surge sites;
  all existing masks/timing/measurements match, and 141 event measurements pass
  independent checks. These scopes are distinguished in the
  [integration report](docs/reference-results/surge-contact-provenance-20260909/README.md).

### Branch verifier review corrections

- Replace optimization-sensitive Python assertions with explicit validation
  errors. Checks remain active with `-O` and `PYTHONOPTIMIZE=1`.
- Require the exact frozen six-movie/four-policy comparison matrix, unique
  recording/case/policy identities and consistent completion counts. Reject
  duplicate, missing or unexpected comparisons before checking their ledgers.
- Add ten Python regression tests (28 CLI executions), including corrupted
  durations and flags, incomplete matrices, compressed input and valid exports.
- Reverify the archived graph in normal and both optimized execution modes:
  identical results for 24 comparisons, 44,193 run rows and 69,508 edge rows.
  Refresh verification provenance and artifact hashes; detector outputs,
  support scores and production calculations are unchanged.

### Explicit surge branch-policy evidence

- Compare the existing tracker with a strict-majority shape extension, a
  split-only extension and stopping at every contact. Keep all sibling
  candidates and export every nonzero overlap edge with recording/policy-local
  run IDs, contact geometry and chosen-link status in test-only output.
- Replay six complete frozen challenge movies from four reference recordings;
  reproduce saved production masks and candidate/gap ledgers exactly. Production
  detection, measurements and statistics contracts remain unchanged.
- Recover the selected ID401 pulse as a 14-frame run under both extensions.
  The broader majority extension improves three of eleven imposed support
  windows but adds 276 contact links. Controlled tests demonstrate potential
  identity changes through contact under both the extension and the current
  primary rule; neither relaxation nor stopping all contacts is adopted.
- Pass 94 focused tests and repository checks. Independently verify 44,193 run
  rows and 69,508 edge rows across 24 movie/policy comparisons. These are
  diagnostic replays, not new amplitude audits or biological accuracy estimates.
- Update the [branch-policy decision and dependency plan](docs/SURGE_BRANCH_POLICY.md)
  and retain [compact reproducible evidence](docs/reference-results/surge-branch-replay-20260909/README.md).

### Full-movie shape and signal-attribution audit

- Add fixed-support traces through detrending, both SD normalization steps and
  smoothing, per-region rejection evidence, and an independent explanation of
  candidate tracking edges, including rejected runs.
- Add growing/shrinking full-movie challenges, rescoring of unchanged controls,
  independent pixel and space-time-score verification, and source-versus-injected
  baseline/footprint diagnostics. Production rules and contracts are unchanged.
- Complete eight new master runs on four previously used sources, with 1,508
  event measurements independently checked and zero mismatches; verify 1.31
  billion constructed pixels and 32 support-score rows. Reconstruct three prior
  failures with exact saved-mask and candidate-ledger agreement.
- Pass 85 focused tests. A post-experiment decomposition verifies twelve matched
  surge footprints and rules out imposed sink cancellation in those examples.
- Document candidate identity breaks, event-footprint dilution and known rising
  tails inside production-valid baselines. Rank proposed corrections and their
  dependencies in [the signal evidence report](docs/SURGE_SIGNAL_EVIDENCE.md).

### Bounded surge shape continuity and rejected-candidate provenance

- Allow an isolated surge to expand or contract when mutual coverage fails,
  provided at least 80% of the smaller region is covered, area changes by no
  more than a factor of two, and neither endpoint has another overlapping
  candidate. Keep one-to-one ownership and the existing primary 60% rule.
- Record every contiguous candidate run, including short terminal fragments,
  before the ten-second duration filter. Export recording-local candidate IDs,
  keep/reject reasons and exact fallback-link frames in per-recording MAT/CSV.
  Rejected candidates remain outside retained-event and site statistics.
- Flag possible continuations across up to two empty seconds in a separate
  candidate-pair table. Never fill missing masks or combine short runs to meet
  duration. Export retained-event shape/gap counts and explicit assessment
  coverage in measurement QC; document their distinction from same-site
  20-second native-recurrence review.
- Advance detector, measurement and statistics contracts; reanalysis is required.
  Keep README, workbook definitions and the publication-readiness plan aligned.
- Pass 78 focused tests, smoke, saved-output/statistics integration and 117
  prescribed geometry/gap scenarios at three pixel sizes and three sampling
  rates. Bounded rapid changes stay continuous; neighboring candidates block
  the fallback; dropout and real-return fixtures remain deliberately ambiguous.
- Repeat the twenty complete movie cases on the same four archived sources;
  retain independent arithmetic, native-mask, candidate-ledger and overlap
  checks (3,905 event records, zero arithmetic mismatches; unchanged sink masks
  and timing in all twenty comparisons) in the [continuity report](docs/reference-results/surge-shape-continuity-20260909/README.md).
  This is development validation, not an estimate of biological accuracy.

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
