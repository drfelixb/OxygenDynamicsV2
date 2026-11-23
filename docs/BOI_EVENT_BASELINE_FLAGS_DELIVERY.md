# Event baseline and reference flags: delivery

13 November 2026. BASELINE-FLAGS-01, BREF-01..05. Owner: root; no delegation.
The researcher explicitly approved steps 1–4 including the recording-reference
flag and resumed implementation and verification. These bounded steps are
complete locally. Compact-workbook implementation and cohort re-export remain
outside the authorization. No commit, push or release was performed.

## Behavior

`boi-event-baseline-flags-1` adds a separate local amplitude to each automatic
sink event. The reference is the configured nominal twenty-second mean before
that event's saved onset on its fixed raw/motion-corrected event footprint.
Available short references and both-sign overlapping native detections stay
in the mean with independent flags/counts. Missing reference samples are omitted
where finite samples remain. Native recording-start events use actual available
post-event samples and carry a recovery-unverified flag. No actual/finite
reference, a nonpositive/nonfinite reference or a missing required event signal
keeps the amplitude unavailable. Signed negative amplitudes remain in the new
event column; existing nonnegative sink-burden eligibility is preserved.

The separate `boi-earlier-recording-reference-1` comparator uses the first
twenty seconds on each event footprint, or an explicit source-identified
recording-wide frame override. `AboveRecordingReference` is numeric 0/1 or NaN
with a not-assessable reason. A nonpreceding window or missing required evidence
is not silently false. The comparator never replaces the local denominator,
changes burden inclusion or establishes physiological normality.

The original strict `NormOxySinkAmp*`, `Baseline*`, pre-episode `Episode*`, saved
timing/native mean area and original-reference `SignedTraceAUC_sec` remain
separate evidence. Event, recording and existing window burden share the new
version-aware amplitude selector. Older tables without new fields retain their
actual legacy selector/version; new tables with unavailable measurements never
fall back silently. Explicit reviewed values and not-pocket exclusions retain
authority. Imported reviewed values cannot be overridden by the automatic
selector. Automatic reference QC remains identified as automatic evidence.

The event product remains amplitude-percent × mean-area-µm² × saved-duration-s.
Recording normalization remains the strict complete sum × 1e6/analyzed-area-µm²
× 60/recording-duration-s. There is no partial sum, imputation, coverage rescaling
or new severity weighting. Recording outputs distinguish numerical completeness
from flagged-reference contributors and `IncludesFlaggedReferences`.

## Entry points and exports

- `deriveBOIEventReferences` is the shared upstream calculator.
- `finalizeOxygenEventMeasurements` calls it after the unchanged strict and
  pre-episode measurements for sinks. Surge measurements remain unchanged.
- `attachSavedBOIEpisodeReferences` additionally derives the new fields from
  receipt-bound original saved masters/audits, preserving pre-existing older
  reference fields. No raw movie is reopened by that adapter.
- An optional override is a scalar struct with `StartFrame`, `EndFrame` and
  nonempty `Source`. The live finalizer accepts it as argument 14; the saved
  adapter accepts it as argument 6. `AnalysisParams.recordingReferenceOverride`
  defaults to empty and is passed through the master. An already derived result
  is preserved; a conflicting override is rejected rather than silently applied.
  No new mandatory CSV field or GUI redesign is included here.
- Existing event/burden workbook tables include the new columns, recording QC
  counts and selected reference-policy metadata. Original columns and detailed
  formats remain available. A separate pre-episode policy sheet identifies the
  preserved alternative. The amplitude guide and metric definitions explain
  the references, sign, flags, units and remaining interpretation limits.

## Verification and limits

All **12 frozen constructed scenarios**, **45 selected existing synthetic
regression evaluations** and the **one three-example saved-trace comparison**
passed. The constructed checks cover the temporal branches, non-1-Hz scaling,
live/shared saved calculation, source conflicts, signed values, unchanged AUC,
reviewed-value priority, strict missingness, event/recording/window product and
area/time scaling, and workbook persistence. Existing tests cover pre-episode
compatibility, full statistics loading, strict completeness, reviews, original
amplitude exports and surge behavior.

Two launch allowances were consumed conservatively. The first sandboxed launch
stopped before numerical work when process monitoring was denied; no MATLAB
worker remained. The monitored launch reused its single MATLAB process after
the one permitted repair corrected a test-discovery class mismatch before any
test evaluation. No scientific-calculation repair or numerical rerun was needed.

Usage: 12/24 constructed executions, 45/48 existing evaluations, 1/2 saved
comparison attempts, 2/2 MATLAB launch allowances, 1/1 repair. Peak monitored
process-tree RSS was **1,261,076,480 bytes (1.17 GiB)**, below 2 GiB. All three
sequential batches finished within the four-hour cap. Evidence is below 100 MiB.
No further numerical work or next milestone starts automatically.

The named saved fixture is byte-identical. A before/after inventory preserves
457 untouched production files; changes to the existing master/statistics entry
points add policy metadata/calls only. The accepted detector, correction,
native support, timing resolver, recording/window normalization kernels and
all five reserved recordings are unchanged. Tests use disposable synthetic
sources and only the one approved saved-trace MAT fixture, never real movies,
new recording fixtures or the 17-recording combined workbook.

## Saved numerical examples and limits

These are automatic measurement regressions, not new pocket judgments.

| FB2412 site 1 event | Saved interval | Old strict amplitude | New local amplitude | Reference | Quality |
| --- | --- | --- | --- | --- | --- |
| 4 | 801–804 | 7.46506% | 7.46506% | 781–800 | No native reference overlap |
| 3 | 674–677 | Unavailable | 2.56172% | 654–673 | 14 overlapping reference frames retained |
| 1 | 1–35 | Unavailable | 7.40302% | 36–55 | Post-event; recovery unverified |

All three match the archived original temporal-rule arithmetic on the same
fixed raw trace and saved bounds. A finite automatic amplitude does not reverse
prior not-pocket decisions or accept the unresolved extended-pocket preview.
The fixture lacks the full recording native inventory/pixel identities, so the
earlier-reference overlap is explicitly not assessable for the later examples;
the recording-start example lacks a preceding comparator. No missing evidence
was fabricated, no new burden total was produced from these examples and no
original result/review file was changed.

These checks establish the stated software behavior, not biological suitability
of every reference, anatomical accuracy, complete-episode detection, full current
pipeline correctness or cross-acquisition comparability. Raw intensity remains
acquisition-dependent; calibration, reference/support identity and acquisition
qualifications remain necessary. The compact workbook and any whole-batch source
regeneration require their separately agreed scope.

Evidence: `reference-validation/boi-event-baseline-flags-20261113/` contains the
frozen scope, original-source snapshots/diff, test and worker receipts, saved
example CSV/JSON, source-preservation inventory and GitHub status screenshots.

Next proposed milestone: the compact saved-value workbook, still held.
