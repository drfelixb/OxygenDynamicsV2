# OxygenDynamicsV2

[![MATLAB CI](https://github.com/drfelixb/OxygenDynamicsV2/actions/workflows/matlab-ci.yml/badge.svg)](https://github.com/drfelixb/OxygenDynamicsV2/actions/workflows/matlab-ci.yml)

OxygenDynamicsV2 is a MATLAB pipeline for detecting, curating, quantifying, and
summarising spatiotemporal oxygen dynamics recorded in the murine cortex with
bioluminescence oxygen imaging.

> **Research software notice:** This software is intended for research use. Its
> outputs require scientific review and should not be treated as clinical or
> diagnostic results.

Known-signal stress testing is described in [the validation protocol](docs/KNOWN_SIGNAL_VALIDATION.md), with [stage tracing and full-recording comparisons](docs/reference-results/known-signal-full-20260909/README.md).

## Development version: existing analysis V3

Development branch: `development-existing-analysis-v3`. This is an unpublished,
breaking revision of the existing V2 detector and analysis. Reanalyze all input
recordings; earlier saved analyses are rejected. The alternative detector is
maintained separately.

- Temporal standardization now divides by SD, correcting the former sqrt(SD).
- [Close sink runs are retained and flagged](docs/SINK_RECURRENCE.md); a short
  gap no longer deletes an otherwise duration-qualified BOI detection. Counts
  describe native runs, with recurrence uncertainty separate from baseline QC.
- Individual events, recurring spatial sites, recordings and animals have
  distinct identities and aggregation rules, including zero-event recordings.
- Amplitudes use each event's fixed footprint in the preserved input movie and
  a complete pre-event baseline excluding overlapping detected events. Missing baselines produce
  unavailable amplitudes while retaining detections.
- [Surge tracking follows motion and groups recurring sites explicitly](docs/SURGE_TRACKING.md).
  The minimum surge area is in µm²; adjacent-frame matching uses fractional
  coverage with bounded isolated growth/contraction. Outputs distinguish retained
  events from rejected short candidates and flag possible short-gap continuations
  without filling gaps. Possible split/merge contacts and ambiguous site assignments
  remain visible.
- [Surge amplitude and detection audit](docs/SURGE_ANALYSIS_AUDIT.md): remove the
  obsolete normalized-trace ratio export, correct terminal-event seeding for
  both trackers, and expose surge native timing/boundary and recurrence status.
  Surge experimental-baseline and mouse-summary analysis still needs parity.
- Native masks determine event morphology and occupied eligible tissue.
  Inclusive frame timing uses N/fs recording exposure.
- Sink recording/window baseline comparisons are explicit; animal summaries give
  equal weight to mice and expose missing measurements.
- Sink and surge site recurrence both use explicit events/minute columns.
  `EventMeasurementQC` and `EventBaselineStatusCounts` expose amplitude
  availability per recording and event type, including zero-event recordings.
- Source hashes, calibration, settings and pipeline identities are checked
  before statistics. Output schema is currently `3.0-dev`.

Current development validation: **114 focused tests**, smoke checks and synthetic
master-to-statistics integration passed in MATLAB R2025a. The
[shape-continuity validation](docs/reference-results/surge-shape-continuity-20260909/README.md)
adds 117 prescribed size-change/gap scenarios and repeats twenty full-movie cases
on four source recordings: ID400, ID401, FB2312 and the separate FB2411
fluorescence control. Candidate ledgers are retained separately from event
statistics. All 3,905 event baseline/amplitude records agree with independent
recalculation; all twenty same-input comparisons preserve sink masks/timing.
These are four source recordings, not twenty independent samples.
The preceding [physical tracking sweep](docs/reference-results/surge-physical-adjacent-20260909/README.md)
remains a historical-contract result.

The [expanding/contracting signal audit](docs/SURGE_SIGNAL_EVIDENCE.md) adds eight
full-movie challenges on those same four sources. All 1,508 additional event
measurements match independent arithmetic. Detailed reconstruction identifies
candidate split/merge identity, spatial averaging and undetected rising tails
inside nominally valid baselines as separate limitations. Production rules remain
unchanged during this experiment; see its [results](docs/reference-results/surge-shape-evidence-20260909/README.md).

The [split/merge policy comparison](docs/SURGE_BRANCH_POLICY.md) replays six
complete challenge movies from the same four sources under four linking rules.
A majority extension recovers the selected 14-second missed pulse, but controlled
contacts can mix signal identities under both that extension and the current
primary rule. All candidate branches, including rejected siblings, are exported
in the comparison evidence. Production linking remains unchanged.

[Contact records](docs/SURGE_CONTACT_PROVENANCE.md) are now integrated into normal
master and statistics outputs: every candidate connection, contact endpoint
frames, native-event exposure and contacts to rejected fragments. Six cached
case replays preserve previous masks and identities; one full ID401 challenge
rerun preserves both-sign measurements, with 141 event records independently
checked. See the [integration evidence](docs/reference-results/surge-contact-provenance-20260909/README.md).
Measurement/statistics contracts advance, so reanalysis is required before
pooling.

The [local candidate-separation experiment](docs/SURGE_CONTACT_SEPARATION.md)
tests persistent, spatially resolved intensity peaks inside merged surge regions.
It preserves all admitted pixels and keeps partition exposure explicit. The
prototype is confined to validation code; it is not enabled in normal analysis.
Full-image challenges compare stationary, approaching and crossing pairs with a
single expanding profile and unchanged recordings. The scores describe imposed
optical signals, not independently labelled physiological events.
The [completed comparison](docs/reference-results/surge-separation-20260909/README.md)
covers twenty full movies on four sources. Stationary-pair gains in ID400/ID401
do not generalize across the tested geometries/acquisitions. Independent Python
checks verify 2.62 billion constructed pixels and all 112 coverage records;
nineteen Python tests pass. The prototype remains experimental.

The branch verifier also passes **10 Python regression tests**, including
deliberately corrupted exports under normal and optimized Python. It requires
the complete six-movie/four-policy comparison matrix. All archived graph results
pass in all three execution modes; saved detections and support scores are unchanged.

**Surge detection remains provisional.** Geometry tests support the tracking
correction, but full-movie results are mixed. Stage reconstruction identifies
candidate geometry/dropouts and the ten-second minimum as causes of missed
smooth signals. These unlabelled reference results do not establish biological
accuracy. Earlier reference reports retain their original contracts and are not
current reruns or additional independent biological samples.
See [calculation definitions](docs/EXISTING_ANALYSIS_CORRECTIONS.md),
[validation evidence](docs/EXISTING_ANALYSIS_VALIDATION.md),
[remaining work](docs/PUBLICATION_READINESS.md),
[DANDI metadata audit](docs/DANDI_METADATA_RECONCILIATION.md),
[multi-recording reference protocol](docs/REFERENCE_SET_PHASE1.md),
[per-recording results and limitations](docs/reference-results/phase1-20260909/README.md),
[signal-audit findings](docs/reference-results/signal-audit-20260909/README.md),
[event-local timing rules](docs/LOCAL_SINK_TIMING.md),
[completed timing rerun and remaining limitations](docs/reference-results/local-timing-20260909/README.md)
and [changelog](CHANGELOG.md).

## Overview

The pipeline detects oxygen sinks and oxygen surges, quantifies signal changes
on the original image data, supports optional behavioural and vascular
analyses, and exports event-level and recording-level results for statistics
and visualisation. It includes preflight validation, manual sink curation,
acceptance checks, regression baselines, and a synthetic smoke test.

The software was originally developed by Felix R. M. Beinlich and Antonios
Asiminas. The current repository is maintained as a research codebase and is
being prepared for broader reuse and contribution.

## Why This Project Exists

Oxygen dynamics in awake cortex can be spatially localised and brief. Analysing
these events requires consistent handling of large TIFF recordings, metadata,
event tracking, raw-signal quantification, manual review, and reproducible
summary exports. OxygenDynamicsV2 brings those steps into one traceable
workflow.

## Key Capabilities

- Detect oxygen sinks and surges in imaging recordings.
- Use denoised TIFFs for detection while retaining raw TIFFs for amplitude
  quantification.
- Curate putative oxygen sinks with a MATLAB app.
- Calculate event-level metrics and hypoxic-burden summaries.
- Integrate optional behaviour, vascular-distance, and amyloid-distance data.
- Generate readiness, acceptance, QC, regression, and summary-figure outputs.

## Scientific Context

The software builds on the analysis developed for:

Beinlich, F. R. M., et al. (2024). Oxygen imaging of hypoxic pockets in the
mouse cerebral cortex. *Science*, 383(6690), 1471-1478.
[https://doi.org/10.1126/science.adn1011](https://doi.org/10.1126/science.adn1011)

## Compatibility With the 2024 Publication Analysis

The current amplitude definition differs from the public script associated
with the 2024 *Science* paper. In the current pipeline, `NormOxySinkAmp`
represents fractional raw-signal change (0.10 means 10%); the older detection-domain quantity
is retained as `DetectionOxySinkAmp`. Do not compare identically named
`NormOxySinkAmp` values across those code versions without accounting for this
change.

Read [Amplitude_Definition_Comparison.pdf](Amplitude_Definition_Comparison.pdf)
and
[Science_vs_Current_Analysis_Differences_20260601.pdf](Science_vs_Current_Analysis_Differences_20260601.pdf)
before comparing results. The detailed mapping is also repeated in
[Important Amplitude Definition Change](#important-amplitude-definition-change).

## Quick Start

Clone the repository, open MATLAB in the repository root, and run:

```matlab
setupOxygenDynamicsPath
checkOxygenPipelineHealth
runOxygenPipelineSmokeTest
Start_OxygenPipeline
```

`Start_OxygenPipeline` opens the stepwise GUI. See
[USER_MANUAL.md](USER_MANUAL.md) before analysing experimental data.

## Requirements

- MATLAB. Development validation used R2025a; the existing CI targets R2025b.
- Image Processing Toolbox for the core imaging workflow.
- Statistics and Machine Learning Toolbox for selected optional statistical,
  vascular, and hypoxia-amyloid analyses.
- A desktop MATLAB session for the App Designer curation and pipeline GUI.
- Windows is required only for optional Outlook COM email notifications.
  Core MATLAB analysis is not intended to depend on Outlook.

No Python, ImageJ, or external command-line runtime is required by the main
pipeline. ABF and multipage-TIFF helpers are bundled; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Inputs and Outputs

The main input is a metadata CSV containing recording paths and acquisition
metadata. Each recording folder must contain an original motion-corrected TIFF;
an optional denoised TIFF can be used for detection. Outputs include per-event
MAT/TIFF data, curated sink data, verification reports, statistics workbooks,
hypoxic-burden tables, regression reports, and summary figures.

Experimental recordings and generated results are intentionally excluded from
version control by [.gitignore](.gitignore).

## Validation and Reproducibility

Run `runOxygenPipelineSmokeTest` locally for the synthetic end-to-end smoke
test and `runRepositoryChecks` for repository-level checks. GitHub Actions runs
the repository checks automatically. For experimental datasets, use the
verification and acceptance reports before accepting results or refreshing a
regression baseline.

## Documentation

- [User manual](USER_MANUAL.md)
- [Pipeline flow map](Pipeline_FlowMap.svg)
- [Detection and processing flow map](Detection_Processing_FlowMap.svg)
- [Contributing guide](CONTRIBUTING.md)
- [Release process](RELEASING.md)
- [Changelog](CHANGELOG.md)

## Citation

Use the metadata in [CITATION.cff](CITATION.cff) to cite the software. Cite the
2024 *Science* article as well when the software is used in work that builds on
the published oxygen-dynamics analysis.

## Licence Status

The project-level licence is under review by the original developers. Until a
top-level `LICENSE` file is added, the repository is publicly viewable source
code but should not be described as open-source software. Bundled third-party
components retain their own licences and notices; see
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Contributing and Support

Please use GitHub issues for reproducible bugs, feature proposals, and
documentation gaps. Read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a
pull request. Security-sensitive reports should follow
[SECURITY.md](SECURITY.md).

## Detailed Pipeline Documentation

## Current Version Highlights

Current pipeline version: `1.01`, build timestamp `2026-06-15 09:50:08 +02:00`.

Release metadata is centralized in `getOxygenPipelineVersion.m`; the GUI,
wrapper provenance, health report, release manifest, and analysis manifest use
this shared value.

This working version is organized around reproducible, user-guided oxygen-dynamics analysis:

- Launch daily use with `Start_OxygenPipeline`, which sets up paths and opens the stepwise GUI.
- Use denoised TIFFs for event detection while quantifying amplitudes on the original raw TIFF.
- Run verification before wrapper/stats work to catch blocked recordings early.
- Export true event-based hypoxic sink metrics, event-based hypoxic burden, recording-level burden, and grouped burden summaries.
- Export the fixed burden interface columns `Burden_Occupancy`, `Burden_RankAmplitude`, and `Burden_AmplitudeComposite` in `HypoxicBurden_ByRecording`.
- Normalize ongoing hypoxic pocket counts to 1 mm2 using recorded FOV area.
- Review the `StatsAcceptance` sheet, GUI acceptance rows, or `reviewLatestStatsAcceptance()` before accepting stats output.
- Lock known-good outputs with regression baselines and compare future runs against them.
- Run `checkOxygenPipelineHealth()` for a lightweight install/latest-output status check.

## Recommended Daily Workflow

For routine use, start from the GUI and keep the selected CSV as the anchor for the whole analysis:

1. Run `Start_OxygenPipeline`.
2. Choose the metadata CSV in the GUI. The folder containing that CSV becomes the working dataset folder.
3. Run verification and inspect blocked or review rows before starting long runs.
4. Run the wrapper analysis. Detection uses `denoised.tif` when present, while amplitudes are quantified from the original/raw TIFF.
5. Run stats and inspect `StatsAcceptance`, `NormalizationGuide`, `MetricDefinitions`, `HypoxicBurden_EventBased`, `HypoxicBurden_ByRecording`, and `HypoxicBurden_TimeSeries`.
6. Generate summary figures and inspect the figures folder, especially `HypoxicBurdenPerMm2OverTime_TimeCourse.png` when time-resolved burden is relevant.
7. Open `AnalysisManifest.md` in the stats output folder for a compact run summary with paths, acceptance/QC rows, burden summaries, and figure outputs.
8. Refresh the regression baseline only after the stats workbook and figures have been scientifically reviewed.

## Main Workflow

`OxygenDynamics_Wrapper.m` imports a CSV file with recording paths and metadata. Each recording folder should contain the original motion-corrected TIFF recording. If a denoised TIFF is present in the same folder, the wrapper and master analysis can use it for event detection while keeping the original TIFF for quantification.

`Start_OxygenPipeline.m` is the simplest entry point for routine use. It adds the project folders to the MATLAB path and opens `OxygenDynamics_GUI.m`.

`OxygenDynamics_GUI.m` provides a stepwise MATLAB control panel for choosing an input CSV with a file browser, using the CSV folder as the dataset working folder, running verification, then launching wrapper analysis, stats, and first-pass summary figures from the selected dataset. The GUI refreshes verification after wrapper runs, keeps quick-open buttons for the latest verification report, wrapper log, stats workbook, and figures folder, and includes a `Results Preview` tab with stats counts, generated figure previews, and lightweight stats QC rows.

The wrapper can call:

1. `runOxygenDynamicsMaster.m` for oxygen sink and oxygen surge detection and quantification.
2. `runOxygenDynamicsTiffout.m` for dF/F TIFF export.
3. `runOxygenDynamicsBehaviour.m` for behavioural data analysis, when behaviour files are available.
4. `runHypoxiaAmyloidRecordingAnalysis.m` when the optional CSV column `AmyloidFile` identifies a registered methoxy-X04 image.

The hypoxia-amyloid step uses only amplitude-independent pocket properties:
event duration, event area, and tracked-pocket recurrence. Its primary distance
is nearest event-edge to plaque-edge in calibrated micrometers. It also exports
centroid-to-plaque distance, within-animal Spearman correlations, a 50 um
near/far comparison, and sensitivity analyses at 25, 50, 75, and 100 um.
Recurrence is analyzed once per tracked pocket rather than repeated once per
event.

Some oxygen sink detections require manual curation. `OxygenDynamics_Sinks_Curation` uses the unrefined output from `OxygenDynamics_Master.m` and allows the user to accept or reject putative oxygen sinks. The curated result can then be used by the statistics script.

`OxygenDynamics_Stats.m` imports the same metadata CSV used by the wrapper, finds the selected oxygen sink, oxygen surge, and behaviour output folders, collates recording-level and event-level tables, and exports summary data for downstream analysis.

`OxygenPipeline_VerificationReport.m` runs a non-destructive readiness check before long analysis/statistics runs. It reports TIFF pairing, preflight status, selected output folders, event-metric readiness, behaviour-output presence, and vascular annotation readiness. The console prints ready/partial/blocked counts, and the Excel report puts `Status`, `IssueSummary`, and `RecommendedAction` near the front and adds a `NeedsReview` sheet when recordings are blocked or partial. `Run_Verification_Then_Stats.m` and `Run_Verification_Then_Wrapper.m` run the same verification first and only start stats or the oxygen wrapper if no recording is blocked.

`OxygenDynamics_VascularAnalysis.m` is a compatibility script for ROI-level vascular-distance analysis. It calls `runOxygenDynamicsVascularAnalysis.m`, which reads `DataPathsExample.csv`, loads artery/vein annotation masks from each recording folder, computes distances from curated hypoxic pockets to the vasculature, amends the manual-curation MAT file, and exports `Vascular_Analysis.xlsx`.

`OxygenDynamics_VascularAnalysis_IndividualEvents.m` is a compatibility script for event-level vascular-distance analysis. It calls `runOxygenDynamicsVascularEventAnalysis.m`, which reads `VasculatureData.csv`, reconstructs individual hypoxic sink event pixels from the sink binary TIFF and `OxySinkArea_all`, computes event-to-vasculature distances, and exports `Vascular_Analysis_Events.xlsx`.

## Expected Outputs

Typical wrapper outputs are written inside each recording folder:

- `OxygenSinks_Output*` with oxygen sink MAT/TIFF outputs and event tables.
- `ManualCurOxySinksData*` with curation-ready sink outputs.
- `ManualCurOxySinksData*/Vascular_Analysis.xlsx` when ROI-level vascular-distance analysis is run.
- `OxygenSurges_Output*` with oxygen surge MAT/TIFF outputs and event tables.
- `OxygenSinks_Output*/Vascular_Analysis_Events.xlsx` when event-level vascular-distance analysis is run.
- `Images_Processed*` with processed TIFF stacks.
- `Behaviour_Output*` when behaviour analysis is run.
- `HypoxiaAmyloid_Output*` with event distances, pocket recurrence, per-recording correlations, threshold sensitivity tables, a MAT result, and QC figure when `AmyloidFile` is configured.

Typical batch-level outputs are written in the project root:

- `Stats_Runs/Stats_Output_*/FilteredData_<inputcsv>.xlsx` for ROI/sink-level and summary stats exports.
- `Stats_Runs/Stats_Output_*/AnalysisManifest.md` for a compact per-run review report linking the stats workbook, `DataOutput.mat`, figures, acceptance/QC summaries, and hypoxic-burden summaries.
- `Stats_Runs/Stats_Output_*/SortedSinkEventMetrics.xlsx` for true event-based hypoxic sink metrics.
- `Stats_Runs/Stats_Output_*/HypoxicEventSpecificMetrics4LME.mat` for event-based hypoxic sink metrics in MAT format.
- `HypoxicBurden_EventBased`, `HypoxicBurden_ByRecording`, `HypoxicBurden_GroupSummary`, and `HypoxicBurden_TimeSeries` sheets in the stats workbook for event-level, recording-level, grouped, and frame-wise hypoxic burden.
- `HypoxicBurden_ByRecording` includes the burden-interface contract columns `Burden_Occupancy`, `Burden_RankAmplitude`, and `Burden_AmplitudeComposite`, each with a units descriptor. `Burden_Occupancy` is the default amplitude-free burden variant for cross-genotype/cross-cohort comparisons; `Burden_RankAmplitude` is a within-recording relative-amplitude sensitivity variant; `Burden_AmplitudeComposite` is the original amplitude x area x duration composite for matched-acquisition cohorts.
- `Stats_Runs/Stats_Output_*/SinkEventTable.mat` and `SurgeEventTable.mat` for collated event tables.
- `Verification_Reports/PipelineVerification_*.xlsx` and `.mat` for non-destructive dataset readiness checks.
- `Stats_Runs/Figures_Output_*` or `Summary_Figures/` with first-pass summary figures generated by `runOxygenSummaryFigures.m`, including sink metrics, event-level and grouped hypoxic burden plots, FOV-normalized hypoxic burden per 1 mm2, an event area/amplitude/duration burden relationship plot, `OxySinksPer1mm2` summary metrics, and `OxySinksPer1mm2` group time courses when those data are present. Time-course figures use seconds or minutes when `SampleF` is available in the stats metadata, otherwise they fall back to frame number. `OxygenSummaryFigureMetrics.xlsx` includes `MetricSummary` and `FigureManifest` sheets.
- `QC_Output/RawDenoisedQC_*.xlsx` for raw/denoised comparison summaries.
- `Run_Logs/*WrapperRunInfo.mat` and failure logs for wrapper provenance.
- `HypoxiaAmyloid_Cohort_*` with animal-level correlations, near/far medians, sensitivity results, permutation tests, FDR values, and a main-figure-ready plot.
- `Regression_Baselines/OxygenRegressionBaseline.mat` and per-run `Regression_Reports/OxygenRegressionReport_*.xlsx` when validation/regression checks are used.

After stats, the workbook includes a `StatsAcceptance` sheet and the GUI `Results Preview` shows a matching acceptance summary. The GUI pins acceptance, review, and regression rows near the top and highlights statuses when supported by the MATLAB version. It reports whether the run is ready for scientific review or regression-baseline refresh, then lists QC rows for hypoxic-burden event-area matching, finite burden contributions, `OxySinksPer1mm2` area-normalization factors, and configured behaviour inputs that did not load behaviour traces. Acceptance rows include `WhereToLook` guidance such as `HypoxicBurden_EventBased` or `SinkCountNormFactors`. Rows marked `REVIEW` should be checked before accepting a stats run or refreshing a regression baseline.

When creating a regression baseline from the GUI, the same acceptance status is checked first. Baseline creation proceeds directly for `PASS` runs and asks for confirmation when the selected stats output contains `REVIEW` rows. `StatsAcceptance` is written as the first sheet in new stats workbooks, and the `Open Acceptance` button opens the current stats workbook and logs that this sheet should be inspected.

From the MATLAB command line, use `reviewLatestStatsAcceptance()` to print the newest stats acceptance summary under the current folder. You can also pass a project folder, `Stats_Output_*` folder, or `DataOutput.mat` path.

## Validation And Regression Checks

After a wrapper and stats run has been reviewed and accepted as correct, lock it as the known-good reference:

```matlab
createOxygenRegressionBaseline('Stats_Runs/Stats_Output_YYYYMMDDTHHMMSS')
```

This creates both `Regression_Baselines/OxygenRegressionBaseline.mat` for automated comparison and `Regression_Baselines/OxygenRegressionBaseline.xlsx` for human inspection. If a previous baseline already exists, it is moved into `Regression_Baselines/Archive/<timestamp>/` before the new baseline is written.

For the safer command-line path, use the accepted-output wrapper:

```matlab
refreshAcceptedOxygenRegressionBaseline('Stats_Runs/Stats_Output_YYYYMMDDTHHMMSS')
```

This first checks `StatsAcceptance` and refuses to replace the baseline if the selected stats output has `REVIEW` rows.

After later code changes, rerun stats and compare the new output against that reference:

```matlab
runOxygenRegressionTest('Stats_Runs/Stats_Output_YYYYMMDDTHHMMSS')
```

For the common case, `Run_Regression_Check.m` or `runOxygenRegressionCheck()` finds the latest stats output, checks whether a baseline exists, prints regression readiness, and runs the comparison when possible. `getOxygenRegressionStatus()` can be used to inspect baseline/report readiness without running the comparison.

If no stats folder is supplied, both commands use the newest `Stats_Output_*` folder found under the current dataset. The regression test compares stable scientific outputs including sink/event counts, hypoxic burden totals, event-specific area match counts, ongoing sink/surge traces, `OxySinksPer1mm2`, and recording-area normalization factors. The regression report is written inside the checked stats output folder under `Regression_Reports/`.

The GUI also exposes this workflow in a dedicated `Regression` tab and in the `Latest outputs` panel. The tab shows baseline readiness, latest or selected stats output, latest regression report, archived baseline count, `ReviewFirst` action rows when available, and a table of archived baselines. It also provides buttons to refresh status, create a baseline, choose a specific `Stats_Output_*` folder, run regression, open the baseline workbook, open the latest report, open the regression folder, open the archive folder, or choose an archived baseline to restore. If a baseline already exists, the GUI asks for confirmation before overwriting it, and restoring an archive also requires confirmation. Regression tests include strict scientific guardrails: hypoxic burden must contain true event rows, all burden-area values must be matched to event-specific areas, ROI-area fallback rows must be zero, and the recording-area normalization factors for `OxySinksPer1mm2` must be finite. Reports include a `ReviewFirst` sheet with the first rows to inspect, a readable `RegressionSummary` sheet with categories such as `ScientificGuardrail`, `NumericMetricDrift`, `AreaNormalization`, `CodeChange`, and `InputOutputFileChange`, plus full `NumericChecks`, `TextChecks`, `ScientificGuardrails`, baseline/actual metadata sheets, `CodeManifestDiff`, and `FileManifestDiff`.

Only refresh the baseline after inspecting and accepting the new output. In command-line automation where you want a result object instead of an error on failure, call:

```matlab
Result = runOxygenRegressionTest('Stats_Runs/Stats_Output_YYYYMMDDTHHMMSS', ...
    'Regression_Baselines/OxygenRegressionBaseline.mat', ...
    'ThrowOnFailure',false);
```

Archived baselines can be inspected and restored:

```matlab
Archived = listOxygenRegressionBaselines('Regression_Baselines/OxygenRegressionBaseline.mat');
restoreOxygenRegressionBaseline(Archived.MatPath(1), ...
    'Regression_Baselines/OxygenRegressionBaseline.mat')
```

## Project Layout

The root folder now keeps the scripts that users normally run, such as `Start_OxygenPipeline.m`, `OxygenDynamics_GUI.m`, `OxygenDynamics_Wrapper.m`, `iOSDynamics_Wrapper.m`, `OxygenDynamics_Stats.m`, the legacy master/tiffout compatibility scripts, QC/status commands, and the smoke test.

Support functions have been moved out of the root folder:

- `helpers/` contains project helper functions for validation, TIFF inspection, wrapper manifests, output-folder handling, path resolution, statistics utilities, GUI preview/acceptance table construction, lower-level per-recording run functions, and failure logging.
- `external/` contains bundled third-party/shared file I/O helpers such as `abfload.m`, `loadtiff.m`, and `saveastiff.m`.
- `Legacy_Archive/` contains old version snapshots, MATLAB autosave backups, and the former standalone `GetHypoxicEventsStats.m` script now that its event-based export has been integrated into the normal stats run.
- `Run_Logs/` contains wrapper run manifests and failure logs generated by batch wrapper runs.
- `QC_Output/` contains raw/denoised QC summary MAT/XLSX files generated by `compareRawDenoisedOutputs.m` or by the oxygen wrapper QC step.
- `setupOxygenDynamicsPath.m` adds the root, `helpers/`, and `external/` folders to the MATLAB path.

The main scripts call `setupOxygenDynamicsPath.m` automatically, so normal wrapper/stats usage should not require manual path setup. If you call individual helper functions directly from a fresh MATLAB session, run `setupOxygenDynamicsPath` once first.

For occasional folder cleanup, run `archiveOldOutputs('dryRun',true)` to preview generated root-level outputs that can be moved into `Run_Logs/`, `QC_Output/`, or `Stats_Runs/`. Run `archiveOldOutputs` without `dryRun` only after checking the preview.

To create a clean source/documentation release without raw data or generated outputs, run:

```matlab
createOxygenReleasePackage
```

This writes `Release_Packages/OxygenDynamics_Release_<timestamp>/`, a matching `.zip`, and `RELEASE_MANIFEST.txt`. The package includes root entry-point scripts, `helpers/`, `external/`, documentation, flow maps, and the smoke test, while excluding `Data/`, `Stats_Runs/`, `QC_Output/`, `Run_Logs/`, `Verification_Reports/`, `Regression_Baselines/`, `Legacy_Archive/`, and prior release packages.

Batch configuration can now be edited in `OxygenDynamics_Config.m`. The wrappers and stats script still define internal defaults, then override matching fields from `OxygenDynamics_Config.m`. This keeps routine run settings in one place.

The same config file now also contains `Config.Verification`, which controls the default input CSV, report output folder, selected sink/surge/behaviour output age, overwrite-preflight assumption, and whether behaviour output or vascular annotations are required rather than optional notes.

## Earlier V2 Update: Denoised Detection, Raw Quantification, And Pipeline Robustness

The earlier V2 update introduced a major change to how denoised recordings are handled. The development-version definitions above and linked methods document supersede its baseline and aggregation details. A denoised TIFF can now be used for event detection, while all signal-amplitude quantification is performed on the original raw TIFF. This avoids inflated percent-change or normalized-amplitude outputs caused by denoising/scaling while still allowing denoised data to improve event detection.

### Important Amplitude Definition Change

The current `NormOxySinkAmp` is not directly comparable to the `NormOxySinkAmp` reported by the Science 2024 public script or the older v1 script. In the Science 2024/v1 code, `NormOxySinkAmp` was calculated from the processed detection trace (`Mean_OxySink_Trace_Convo`) as the event's distance from a polynomial trend line. That value is a detection-domain amplitude, not a raw percent fluorescence change.

In the current pipeline, `NormOxySinkAmp` is calculated from the original/raw TIFF trace as:

```matlab
NormOxySinkAmp = (mean(raw baseline) - min(raw event window)) / mean(raw baseline)
```

This means a value of `0.10` corresponds to an approximately 10 percent raw signal drop. The old detection-domain amplitude is still preserved separately as `DetectionOxySinkAmp`. Therefore, when comparing current outputs to the Science 2024 public script or older v1 outputs, compare:

```text
old Science/v1 NormOxySinkAmp  <->  current DetectionOxySinkAmp
current NormOxySinkAmp         <->  raw percent-change amplitude
```

For a plain-language summary of this change, see `Amplitude_Definition_Comparison.pdf` in the project root.

### Key Analysis Changes

- Added automatic TIFF inspection with `inspectOxygenTiffs.m`.
- Added `loadOxygenStacks.m` to identify one original/raw TIFF and an optional denoised TIFF in each recording folder.
- Added `loadRawTiffStack.m` for raw-only iOS loading.
- Added shared `loadtiff.m` and `saveastiff.m` helper files so scripts no longer depend on duplicated local TIFF functions.
- `OxygenDynamics_Master.m` now uses the denoised TIFF only for detection when it is available.
- Oxygen sink and surge quantification is performed on the original TIFF.
- `Mean_OxySink_Trace_Raw` is saved and now matches the final refined sink ROIs.
- `NormOxySinkAmp` is calculated from the original raw trace around events.
- Detection-based amplitude is retained separately as `DetectionOxySinkAmp`.
- Added event-level sink and surge output tables for downstream event-by-event analysis.
- Oxygen and iOS surge frame scaling now uses local `safeMat2Gray` helpers instead of toolbox-dependent `mat2gray`.
- Repeated sink/surge candidate filtering was consolidated into `filterRegionCandidates`, covering area, circularity, recording-area mask, and edge-exclusion checks while preserving previous defaults.
- Additional detection thresholds are now stored in `AnalysisParams`, including outside-recording-area fraction, oxygen surge circularity, and iOS putative-event-mask fraction.

### Wrapper And Validation Changes

- Added a `RunConfig` block to `OxygenDynamics_Wrapper.m` for non-interactive batch operation.
- The wrapper now reports which recording is being processed, including mouse/file ID and folder.
- The wrapper reports whether a denoised TIFF was found and whether it will be used for detection.
- `OxygenDynamics_Wrapper.m` can now run the raw/denoised QC summary automatically after a full analysis batch with `RunConfig.runRawDenoisedQC`.
- Wrappers now support `analysisMode = 'Preflight only'` to validate metadata, recording paths, TIFF pairing, and output status without running imaging or behaviour analysis.
- The oxygen wrapper and GUI also support `analysisMode = 'Hypoxia-amyloid only'`, which loads existing sink outputs and runs only the optional methoxy-X04 analysis.
- Added preflight validation with `validateOxygenRecording.m`.
- Validation checks for raw TIFF presence, denoised TIFF conflicts, frame dimensions, sampling frequency, pixel size, and metadata issues.
- Added `validateInputTableColumns.m` so wrappers fail early with clear messages when required metadata CSV columns are missing.
- Added `requiredWrapperInputColumns.m` so oxygen and iOS wrappers share the same required metadata-column definition.
- Added `unpackWrapperInputTable.m` so oxygen and iOS wrappers share metadata-table unpacking while preserving the workspace variables expected by downstream scripts.
- Added `validateRecordingPaths.m` so wrappers fail early with clear messages when CSV recording folders do not exist.
- Added `readInputTable.m` to centralize CSV reading with delimiter fallback for wrapper, stats, and QC scripts.
- Added `makeFullRecordingPath.m` to centralize relative/absolute recording path resolution across wrappers, stats, and QC scripts.
- Added shared wrapper helpers `firstTiffName.m` and `appendFailure.m` to avoid duplicated TIFF-status and failure-log utility code.
- Added `createWrapperRunInfo.m` to centralize wrapper run-manifest initialization for oxygen and iOS wrappers.
- Added `printWrapperRecordingStatus.m` to centralize wrapper progress, TIFF-source, and preflight-validation reporting.
- Added `handleWrapperFailure.m` and shared `sendolmail.m` to centralize wrapper catch-block failure handling and optional email alerts.
- Added `shouldRunOutputStep.m` to centralize wrapper run/skip decisions for existing output folders.
- Added `updateWrapperRecordingInfo.m` to centralize per-recording wrapper manifest updates from validation/TIFF provenance.
- Added `createRecordingMetadata.m` to centralize wrapper metadata struct creation for validation.
- Added `saveFailureLog.m` to centralize saving non-empty wrapper failure logs while preserving existing MAT variable names.
- Removed stale wrapper email setup comments now that both wrappers use the shared Outlook-based `sendolmail.m` helper.
- Added `resolveWrapperRunChoices.m` and `getWrapperEmailDestination.m` so oxygen and iOS wrappers share run-mode/reanalysis/overwrite selection and optional email-recipient handling.
- Added `printWrapperConfiguration.m` so oxygen and iOS wrappers share startup configuration reporting.
- Added `finalizeWrapperRun.m` so oxygen and iOS wrappers share manifest finalization, failure-log saving, optional final email, and oxygen raw/denoised QC triggering.
- Added `createWrapperFinalizeOptions.m` so oxygen and iOS wrappers share finalization-option construction while preserving their different output filenames and failure-field names.
- Wrapper finalization now copies the exact input CSV used for the run into `Run_Logs/` and stores the copy path in `WrapperRunInfo.InputCsvCopy`.
- Oxygen analysis failures are logged and skipped without necessarily stopping behaviour analysis.
- Wrapper run/skip checks for imaging and behaviour outputs are now recording-folder-specific, so root-level output folders cannot accidentally cause a recording to be skipped.
- Error dialogs are now gated behind interactive mode.
- `OxygenDynamics_Wrapper.m` now saves `OxygenDynamics_WrapperRunInfo.mat` with the run configuration, required CSV columns, validated path list, recording-level validation status, TIFF files used, processing status, and failures.

### Output Folder And Reproducibility Changes

- Added `createOxygenOutputFolders.m`.
- Oxygen output folders are now created consistently with safer overwrite/timestamp behaviour.
- Analysis metadata and parameter provenance are saved with outputs through `AnalysisInfo` and `AnalysisParams`.
- Output paths now use `fullfile` more consistently.
- dF/F TIFF names were corrected so global/frame-normalized outputs do not overwrite each other.

### Statistics Updates

- `OxygenDynamics_Stats.m` now has a `StatsConfig` block for non-interactive batch use.
- Statistics output folders are timestamped for reproducibility and now write under `Stats_Runs/`.
- `StatsInfo` is saved with statistics outputs, including required CSV columns and the validated recording path list.
- The stats Excel workbook now includes the input CSV base name, for example `FilteredData_GFAP_GeNL_Ctrl.xlsx`, and contains `StatsRunSummary` and `StatsLoadSummary` sheets listing recording sources and loaded data counts.
- Stats workbooks now include a `MetricDefinitions` sheet with explicit formulas, units, and ROI/event/recording basis for key outputs such as hypoxic burden and `OxySinksPer1mm2`.
- Stats workbooks now include a `NormalizationGuide` sheet that marks major outputs as raw totals, area-normalized, time-normalized, area-and-time-normalized, partly normalized, or not applicable, with recommended comparison use.
- Hypoxic burden and sink-count normalization sheets now carry row-level provenance columns, including contribution formula, duration source, normalization source, and normalized trace name.
- The stats Excel workbook now contains a `MetricBasis` sheet indicating which outputs are ROI/sink-based, ROI-level summaries of events, or true event-based metrics.
- The stats Excel workbook now contains hypoxic burden sheets calculated from true individual oxygen-sink event rows: positive drop amplitude percent x event-specific area x event duration, plus recording-level sums. The event-specific area source is `EventSpecificMetrics.Area_um` when available and matched.
- Hypoxic burden now keeps total-FOV, FOV-normalized, time-normalized, and combined FOV/time-normalized outputs. `HypoxicBurden` is the summed burden inside the recorded FOV, `HypoxicBurden_per_mm2` scales burden to a common 1 mm2 recording area, and `HypoxicBurden_per_min` / `HypoxicBurden_per_mm2_per_min` report burden rates for recordings with different durations.
- Hypoxic burden now also includes `HypoxicBurden_TimeSeries`, a long-format frame-wise output for EEG/ECG/sleep-state alignment. `HypoxicBurdenOverTime` sums active event burden density in the recorded FOV, and `HypoxicBurdenPerMm2OverTime` applies the 1 mm2 FOV normalization without converting the trace to a per-minute rate.
- The stats export now includes `OxySinksPer1mm2`, an area-normalized hypoxic pocket count trace using `kappa = 1000 / sqrt(RecordingArea_um2)` and `AreaCorrectionFactor_1mm2 = kappa^2`, with factors documented in the `SinkCountNormFactors` sheet.
- Event-level sink and surge tables are collated and exported.
- The hypoxic event-specific analysis from `GetHypoxicEventsStats.m` has been integrated into the normal stats run. When sink binary TIFFs are available, stats now also exports `SortedSinkEventMetrics.xlsx` and `HypoxicEventSpecificMetrics4LME.mat` with one row per hypoxic event and event-specific morphology recalculated from the event frames.
- Sheets in `SortedSinkEventMetrics.xlsx` are prefixed with `EventBased_`, and the workbook includes a `MetricBasis` sheet plus an `EventBased_AllEvents` sheet to make the analysis unit explicit.
- Missing behaviour output is now treated as optional: the script warns and skips behaviour traces instead of stopping oxygen statistics.
- Missing sink or surge output folders still stop with explicit errors.
- Missing or ambiguous MAT files now produce clearer errors or warnings.
- The stats script now validates required metadata CSV columns before analysis starts.
- The stats script now validates that all CSV recording paths exist before looking for output folders.
- Empty event cells now return `NaN` instead of failing or producing misleading means.
- Puff-list parsing was made safer by replacing `str2num` usage.
- Toolbox-dependent stats calls were replaced with local helpers: `safeZScore`, `safeCorr`, `safeMat2Gray`, `safeCoeffVariation`, and `safeShannonEntropy`.
- `OxygenDynamics_Stats.m` now uses shared toolbox-free helpers (`safeZScore.m`, `safeCorr.m`, `safeMat2Gray.m`, `safeCoeffVariation.m`, and `safeShannonEntropy.m`) instead of carrying duplicate local implementations.
- Small generic stats utilities (`safeCellMean.m`, `vertcatCellTables.m`, `uniqueStrCell.m`, `xlscol.m`, `hex2rgb.m`, `plot_areaerrorbar.m`, and `peakfinder.m`) were moved from the stats script into `helpers/`.
- Removed an unused embedded Excel sheet cleanup helper block from `OxygenDynamics_Stats.m`.
- Stats-specific support utilities (`loadStatsMatVars.m`, `findStatsSidecarFile.m`, `statsRecordingsToTable.m`, and `parseNumericList.m`) were moved into `helpers/`, leaving `OxygenDynamics_Stats.m` without a local helper-function tail.
- Removed stale commented plotting scratchpad text from the end of `OxygenDynamics_Stats.m`.
- Added the function entry point `runOxygenDynamicsStats.m`; `OxygenDynamics_Stats.m` now remains as a thin backward-compatible script shim.
- Pupil-dilation smoothing in stats now uses the shared `movingAverageShrink.m` helper instead of the optional `smooth` function.
- Repeated stats metric-sheet export calls were centralized in `writeStatsMetricSheets.m`.
- Stats metric workbook sheet-name construction and sink/surge metric writing were centralized in `writeStatsMetricWorkbookSheets.m`.
- Repeated grouped stats table export calls were centralized in `writeStatsGroupedTables.m`.
- Stats grouped workbook output orchestration, including BLI-only aligned traces, trace correlations, binned traces, pooled traces, event snippets, and puff figures, was centralized in `writeStatsAnalysisWorkbookOutputs.m`.
- Extracted BLI-only stats workbook/figure export option construction into `createStatsWorkbookOptions.m`.
- Repeated binned behaviour trace export calls were centralized in `writeStatsBinnedTraceSheets.m`.
- Repeated pooled-trace and optional event-snippet export calls were centralized in `writeStatsPooledTraceSheets.m` and `writeOptionalStatsSheets.m`.
- Puff-aligned stats trace plotting was moved into `writeStatsPuffTraceFigures.m`.
- Repeated behavioural event trace-snippet extraction in stats was centralized in `extractBehaviourEventMeanTraceSnips.m`.
- Stats behaviour-event time windows are now configurable through `Stats.behaviourTimeWindows` in `OxygenDynamics_Config.m`, with non-interactive defaults of 3 seconds for each event type.
- Event-snippet export table preparation was centralized in `createEventSnippetExportTable.m` and `createManualEventSnippetExportTable.m`.
- Aligned sink trace export preparation and sheet writing were centralized in `createAlignedSinkTraceExport.m` and `writeAlignedSinkTraceSheets.m`.
- Toolbox-dependent master trace-correlation calls were replaced with shared `safeCorrMatrix.m`, so oxygen and iOS master analyses no longer require MATLAB's `corr` function.
- Whisking CSV import in `OxygenDynamics_Stats.m` now uses the shared delimiter-fallback reader and no longer checks the wrong metadata table width.
- Whisking sidecar-file lookup in `OxygenDynamics_Stats.m` now searches the behaviour output folder and parent recording folder explicitly instead of changing folders with `cd ..`.
- Sink/surge MAT loading and `FilteredData.xlsx` export in `OxygenDynamics_Stats.m` now use explicit full paths instead of changing into output folders.
- The main per-recording loop in `OxygenDynamics_Stats.m` now resolves each recording folder explicitly instead of changing into each recording folder with `cd`.
- The former standalone `GetHypoxicEventsStats.m` workflow has been retired into `Legacy_Archive/`; its event-specific output is now produced by the normal stats run.
- Added `runOxygenPipelineVerificationReport.m` and `OxygenPipeline_VerificationReport.m` for non-destructive dataset readiness reporting before long wrapper/statistics runs.
- Verification reports now include action-first `Status`, `IssueSummary`, and `RecommendedAction` columns plus a `NeedsReview` sheet for blocked or partial recordings.
- Verification reports now print ready/partial/blocked counts in the MATLAB console and support strict mode through `Config.Verification.requireBehaviour` and `Config.Verification.requireVascularAnnotations`.
- Added `Run_Verification_Then_Stats.m` to run the readiness report first and stop before stats if any recording is blocked.
- Added `Run_Verification_Then_Wrapper.m` to run the readiness report first and stop before the oxygen wrapper if any recording is blocked.
- Added `assertNoBlockedVerificationRows.m` so gated workflow scripts share the same verification stop condition.
- Added `OxygenDynamics_GUI.m`, a stepwise MATLAB GUI for CSV selection, verification, wrapper launch, stats launch, summary-figure generation, report table display, logging, automatic post-wrapper verification refresh, latest-output quick-open buttons, stats overview preview, and generated figure preview.
- Added `runOxygenSummaryFigures.m` for first-pass grouped sink metric plots from stats `DataOutput.mat`; it now also writes optional hypoxic burden plots and a figure manifest.
- Added `Config.Verification` to `OxygenDynamics_Config.m` for verification-report defaults.
- `OxygenDynamics_VascularAnalysis.m` and `OxygenDynamics_VascularAnalysis_IndividualEvents.m` are now thin compatibility scripts backed by `runOxygenDynamicsVascularAnalysis.m` and `runOxygenDynamicsVascularEventAnalysis.m`.
- Vascular analysis now uses shared annotation loading, file discovery, and distance-computation helpers, and both ROI-level and event-level vascular analyses are covered by the smoke test.
- `OxygenDynamics_Wrapper.m` and `iOSDynamics_Wrapper.m` now resolve recording folders explicitly and use an `onCleanup` guard to return to the master folder after each recording.
- `OxygenDynamics_Wrapper.m` and `iOSDynamics_Wrapper.m` now share small utility helpers for TIFF-name reporting and failure-log appending.
- `OxygenDynamics_Wrapper.m` and `iOSDynamics_Wrapper.m` now share the same run-manifest initialization helper.
- `OxygenDynamics_Wrapper.m` and `iOSDynamics_Wrapper.m` now share the same recording-status/preflight-reporting helper.
- `OxygenDynamics_Wrapper.m` and `iOSDynamics_Wrapper.m` now share catch-block failure handling and Outlook email helper code.
- `OxygenDynamics_Wrapper.m` and `iOSDynamics_Wrapper.m` now share the same helper for deciding whether to run or skip existing imaging/behaviour outputs.
- `OxygenDynamics_Wrapper.m` and `iOSDynamics_Wrapper.m` now share per-recording manifest update logic.
- `OxygenDynamics_Wrapper.m` and `iOSDynamics_Wrapper.m` now share metadata struct creation for preflight validation.
- `OxygenDynamics_Wrapper.m` and `iOSDynamics_Wrapper.m` now share failure-log saving logic.
- `OxygenDynamics_Wrapper.m` and `iOSDynamics_Wrapper.m` now share run-choice and email-recipient resolution logic.
- `OxygenDynamics_Wrapper.m` and `iOSDynamics_Wrapper.m` now share metadata-table unpacking logic.
- `OxygenDynamics_Wrapper.m` and `iOSDynamics_Wrapper.m` now share startup configuration printing.
- `OxygenDynamics_Wrapper.m` and `iOSDynamics_Wrapper.m` now share wrapper finalization and failure-log persistence.
- `OxygenDynamics_Wrapper.m` and `iOSDynamics_Wrapper.m` now share wrapper-finalization option construction.
- Added function entry points `runOxygenDynamicsMaster.m`, `runiOSDynamicsMaster.m`, and `runOxygenDynamicsBehaviour.m`. These are now the wrapper-facing calls for master and behaviour analysis.
- The new master and behaviour entry points still execute the legacy script bodies through `runLegacyAnalysisScript.m`, which runs them inside an isolated function workspace with an explicit recording context instead of exposing the whole wrapper workspace.
- TIFF export now uses function entry points: `runOxygenDynamicsTiffout.m` and `runiOSTiffout.m` are called directly by the wrappers, while the older `OxygenDynamics_Tiffout.m` and `iOS_Tiffout.m` scripts remain as thin direct-run shims.

### iOS Pipeline Updates

- `iOSDynamics_Master.m` and `iOS_Tiffout.m` now use shared raw TIFF loading helpers.
- iOS output folder creation was aligned with the oxygen pipeline helper.
- Fixed a surge `DrugID` table sizing issue.
- Added safer bounded indexing for iOS surge baseline windows.
- Added analysis metadata/provenance saving to iOS outputs.
- Moved repeated iOS sink correlation, noise-percentile, overlap-fraction, and recording-area thresholds into `AnalysisParams` without changing their values.
- Moved iOS putative-event-mask filtering and outside-recording-area filtering thresholds into `AnalysisParams` without changing their values.
- Added a `RunConfig` block to `iOSDynamics_Wrapper.m` for non-interactive batch runs.
- `iOSDynamics_Wrapper.m` now prints the current recording, mouse/file ID, TIFF status, and whether a denoised TIFF is being ignored for iOS raw analysis.
- `iOSDynamics_Wrapper.m` now uses preflight validation before iOS analysis and logs failed imaging recordings without blocking optional behaviour analysis.
- Email alerts and warning dialogs in `iOSDynamics_Wrapper.m` are now gated behind config/interactive mode.
- `iOSDynamics_Wrapper.m` now saves `iOSDynamics_WrapperRunInfo.mat` with the run configuration, required CSV columns, validated path list, recording-level validation status, TIFF files used, processing status, and failures.
- Fixed failure-log saving in `iOSDynamics_Wrapper.m`.

### Code Quality And Static Checks

- Added `setupOxygenDynamicsPath.m` and moved support functions into `helpers/` and file-I/O dependencies into `external/` to keep the project root focused on runnable scripts.
- Wrapper run manifests/failure logs now write to `Run_Logs/`, and raw/denoised QC summaries now write to `QC_Output/` by default.
- Added `OxygenDynamics_Config.m` and `applyOxygenDynamicsConfig.m` so routine oxygen wrapper, iOS wrapper, and stats settings can be edited in one central file.
- Added `archiveOldOutputs.m` to move generated root-level outputs into `Run_Logs/`, `QC_Output/`, and `Stats_Runs/`; use `archiveOldOutputs('dryRun',true)` to preview moves.
- Updated `getlatestfile.m` so it no longer changes MATLAB's current folder while looking for the newest matching file or folder.
- Added `createLegacyRecordingContext.m`, `addValidationToLegacyContext.m`, `mergeStructs.m`, and `runLegacyAnalysisScript.m` as the first migration step from shared-workspace scripts toward function-based execution.
- Added shared TIFF-output processing helpers `detrendOxygenStack.m`, `normalizeToDfof.m`, `normalizeToZStat.m`, and `scaleStackToUint16.m`.
- Added function-based TIFF export entry points `runOxygenDynamicsTiffout.m` and `runiOSTiffout.m`; wrappers now use these instead of running the TIFF-out scripts in a shared workspace.
- Added function-based master and behaviour entry points `runOxygenDynamicsMaster.m`, `runiOSDynamicsMaster.m`, and `runOxygenDynamicsBehaviour.m`; wrappers now call these names instead of directly naming the master/behaviour scripts.
- Extracted master-analysis parameter setup into `createOxygenMasterParams.m` and `createiOSMasterParams.m`.
- Extracted master-analysis TIFF loading/provenance setup into `loadOxygenMasterInputs.m` and `loadiOSMasterInputs.m`.
- Extracted shared recording-area mask, area, and optional ROI-bin calculation into `computeRecordingArea.m`.
- Extracted shared detection preprocessing into `preprocessDetectionStack.m`, including z-scoring, convolution, smoothing, and optional uint8 scaling for iOS.
- Removed unused local z-score helper copies from the master scripts now that `normalizeToZStat.m` is shared.
- Extracted common master TIFF saving into `saveMasterImageStacks.m`.
- Extracted oxygen and iOS master output persistence into `saveOxygenMasterOutputs.m` and `saveiOSMasterOutputs.m`.
- Extracted shared frame-wise region detection into `detectFrameRegionCandidates.m`, with shared `filterRegionCandidates.m` and `safeMat2Gray.m` helpers.
- Extracted the iOS frame-difference putative-event mask into `computeFrameDifferenceEventMask.m`.
- Extracted shared sink and surge candidate tracking into `trackSinkCandidates.m` and `trackSurgeCandidates.m`, with `isRemovedRegion.m` for removed-region markers.
- Extracted repeated master output metadata-vector construction into `currentLegacyMetadata.m` and `createOutputMetadataVectors.m`, preserving the legacy wrapper metadata names while reducing duplicated table setup in the oxygen and iOS masters.
- Extracted shared recording-level sink and surge summary table construction into `createOxygenSinkSummaryTable.m` and `createOxygenSurgeSummaryTable.m`, making the output column schema explicit for both oxygen and iOS masters.
- Extracted oxygen event-level sink and surge table construction into `createOxygenSinkEventTable.m` and `createOxygenSurgeEventTable.m`, including preservation of the `DetectionOxySinkAmp` event column.
- Extracted repeated oxygen/iOS trace-correlation sink-region merging into `refineSinkRegionsByTraceCorrelation.m`, preserving the existing correlation, noise-percentile, and spatial-overlap criteria while removing three duplicated refinement passes from each master.
- Moved shared sink trace extraction and sink-map construction into `extractSinkTraces.m`, so oxygen and iOS masters use the same clipped-region-to-full-image pixel conversion and trace averaging logic.
- Extracted final trace potential-noise masking into `computeTracePotentialNoise.m` and oxygen spatial-bin trace extraction into `extractSpatialBinTraces.m`.
- Extracted repeated event-metric cell preallocation and tracked-event counting into `initializeEventMetricCells.m` and `countTrackedEvents.m`.
- Moved the duplicated legacy polynomial detrending helper into `detrend_custom.m`, so oxygen and iOS masters share the same stack and trace detrending implementation.
- Extracted oxygen sink event boundary, detection-domain amplitude, and raw-domain normalized-amplitude calculation into `quantifyOxygenSinkEvent.m`.
- Extracted event size modulation into `computeEventSizeModulation.m` and oxygen sink/surge event-vector preallocation into `initializeOxygenSinkEventVectors.m` and `initializeOxygenSurgeEventVectors.m`.
- Extracted legacy iOS sink event boundary and detection-domain amplitude calculation into `quantifyiOSSinkEvent.m`.
- Extracted oxygen/iOS surge event timing and baseline-normalized amplitude calculation into `quantifyOxygenSurgeEvent.m`, with an explicit option preserving oxygen's absolute-ratio behavior.
- Extracted oxygen sink and surge event-vector row assignment into `setOxygenSinkEventVectorRow.m` and `setOxygenSurgeEventVectorRow.m`.
- Extracted the full oxygen sink event collation loop into `collateOxygenSinkEvents.m`, returning sink event summary cells, the event-level output table, and the updated potential-noise mask.
- Extracted the full oxygen surge event collation loop into `collateOxygenSurgeEvents.m`, returning surge event summary cells and the event-level surge output table.
- Extracted the iOS sink and surge event collation loops into `collateiOSSinkEvents.m` and `collateiOSSurgeEvents.m`, preserving the legacy iOS detection-domain sink amplitude and non-absolute surge-ratio behavior.
- Extracted shared oxygen/iOS surge trace extraction into `extractSurgeTraces.m`, replacing duplicate inline loops in both master scripts.
- Updated `iOSDynamics_Master.m` to use the shared `normalizeToDfof.m` helper instead of carrying a duplicate local dF/F function.
- Extracted iOS master save-payload assembly into `createiOSMasterOutputData.m`, keeping output fields centralized before `saveiOSMasterOutputs.m`.
- Extracted oxygen master save-payload assembly into `createOxygenMasterOutputData.m`, matching the iOS output-packaging pattern while preserving oxygen-specific event tables and raw traces.
- Removed unused embedded helper functions from `OxygenDynamics_Master.m` and `iOSDynamics_Master.m` after their active logic had been moved into shared helpers.
- Updated legacy `OxygenDynamics_Tiffout.m` and `iOS_Tiffout.m` to use shared preprocessing helpers and removed their duplicate local detrending, z-scoring, and dF/F helper definitions.
- Replaced repeated manual TIFF-output scaling in the legacy TIFF scripts with the shared `scaleStackToUint16.m` helper.
- Centralized processed-stack TIFF saving in `saveOxygenTiffoutStacks.m` and `saveiOSTiffoutStacks.m`, shared by both legacy scripts and function wrappers.
- Reused `preprocessDetectionStack.m` from all TIFF-output entry points, removing duplicate z-score, convolution, and smoothing loops.
- Removed stale, unused setup variables from the legacy TIFF-output scripts so their headers now reflect the values actually used by TIFF export.
- Converted legacy `OxygenDynamics_Tiffout.m` and `iOS_Tiffout.m` into thin shims that delegate to `runOxygenDynamicsTiffout.m` and `runiOSTiffout.m`, leaving the function wrappers as the single maintained TIFF-export implementation.
- Started restructuring `runOxygenPipelineSmokeTest.m` by extracting temporary recording, negative TIFF fixtures, metadata, wrapper input-table setup, event-helper assertions, table/morphology assertions, and wrapper/config/QC assertions into local helper functions.
- Extracted tracked-candidate duration refinement into `refineTrackedSinkCandidates.m` and `refineTrackedSurgeCandidates.m`.
- Extracted tracked sink/surge morphology, binary-map, and mean metric calculation into `computeTrackedRegionMorphology.m`.
- Removed duplicated local `loadtiff` and `saveastiff` implementations from analysis scripts.
- Cleaned and modernized `OxygenDynamics_Master.m`, `OxygenDynamics_Tiffout.m`, `OxygenDynamics_Wrapper.m`, and `OxygenDynamics_Stats.m`.
- Cleaned and modernized `iOSDynamics_Master.m`, `iOS_Tiffout.m`, and `iOSDynamics_Wrapper.m`.
- Vectorized final oxygen sink trace extraction in `OxygenDynamics_Master.m`.
- Reduced fragile table growth in `OxygenDynamics_Stats.m`.
- Extracted repeated stats trace/correlation export-table padding into `createPaddedTraceExportTable.m`, `createNanTraceExportTable.m`, and `createTraceCorrelationExportTable.m`.
- Extracted grouped stats trace and trace-correlation export construction into `createStatsTraceExports.m`.
- Extracted grouped stats trace and binned-trace export preparation into `prepareStatsTraceExportData.m`.
- `prepareStatsTraceExportData.m` now takes named input structs instead of a long positional argument list.
- Extracted repeated stats percentile-binned trace export construction into `createBinnedTraceExport.m`, shared by left-paw, right-paw, and pupil binned outputs.
- Extracted BLI-only stats binned trace export orchestration into `createStatsBinnedTraceExports.m`.
- Extracted stats behaviour-percentile bin calculations into `computeBehaviourPercentileBins.m`, with shared trace-source and NaN-placeholder helpers.
- Extracted stats left-paw, right-paw, and pupil percentile-bin orchestration into `createStatsBehaviourPercentileBins.m`.
- Extracted stats behaviour analysis preparation into `prepareStatsBehaviourAnalysisData.m`, bundling time-window selection, behaviour logicals, and percentile-bin setup.
- `prepareStatsBehaviourAnalysisData.m` now takes named input structs instead of a long positional argument list.
- Extracted stats behaviour event-window construction and short-event filtering into `createWindowedEventMask.m` and `removeShortLogicalEvents.m`, reducing duplicated left/right paw and whisking logic while avoiding `regionprops` for this cleanup step.
- Extracted stats grouped sink/surge metric filtering and per-mouse export-table construction into `filterStatsMetricData.m` and `createStatsMetricExportTables.m`.
- Extracted puff-aligned pooled trace windowing into `extractPuffAlignedTraceRows.m` with `labelLogicalRuns.m`, reducing repeated puff trace slicing and removing the hidden `nearest` dependency.
- Extracted pooled puff-trace normalization and Excel-table formatting into `formatPooledTracesForExport.m`.
- Extracted stats group-level pooled puff-trace orchestration into `createStatsPooledPuffTraces.m`.
- Extracted stats pooled trace export title/header preparation into `prepareStatsPooledTraceExports.m`.
- `prepareStatsPooledTraceExports.m` now takes named input structs instead of a long positional argument list.
- Began splitting `runOxygenPipelineSmokeTest.m` into local smoke assertion helpers, starting with `runMasterOutputSmokeAssertions.m`-style local organization for master output folder/save checks.
- Continued splitting `runOxygenPipelineSmokeTest.m` into focused local smoke assertion helpers for TIFF/input checks, utility helpers, behaviour trace/snippet helpers, stats workbook/export helpers, stats input loading, sink/surge recording fixtures, full-recording stats loading, stats curation row loading, and metric/time-series checks.
- Extracted stats group-filter construction into `createStatsGroupFilters.m`, shared by sink metrics, surge metrics, and ROI/time-series exports while preserving their legacy stimulation labels.
- Extracted stats analysis-specific sink, surge, and ROI/event filter orchestration into `createStatsAnalysisFilters.m`.
- Extracted derived sink/surge stats metric calculations into `createAdditionalOxygenSinkMetrics.m` and `createAdditionalOxygenSurgeMetrics.m`.
- Extracted stats sink/surge table metric augmentation into `augmentStatsOxygenMetricTables.m`, so derived metrics are calculated and appended in one step.
- Extracted aligned oxygen-sink event trace preparation into `createAlignedOxygenSinkEventTraces.m`, preserving the legacy 3-150 frame duration filter and start-normalized event traces.
- Extracted stats aligned sink-event trace attachment into `addAlignedSinkEventTraces.m`, preserving experiment/mouse matching before export.
- Extracted recording-level ongoing sink/surge count, area, and raster time-series construction into `computeOngoingSinkTimeSeries.m` and `computeOngoingSurgeTimeSeries.m`.
- Extracted the stats-level ongoing sink/surge time-series orchestration into `createOngoingStatsTimeSeries.m`, including BLI trace-correlation updates.
- Extracted BLI ROI trace feature calculation into `computeROITraceFeatures.m`, covering ROI mean, coefficient of variation, entropy, differential traces, and their trace-correlation summaries.
- Extracted manual-event ROI snippet extraction into `extractManualEventMeanTraceSnips.m` and shared boundary-padded trace windows through `extractCenteredTraceWindow.m`.
- Extracted stats behaviour event-snippet orchestration into `extractStatsBehaviourEventSnips.m`, keeping left paw, right paw, grooming, pupil, puff, and whisking outputs consistent.
- Extracted BLI stats manual/behaviour event-snippet collection into `extractStatsBLIEventSnippets.m`.
- Extracted stats event-snippet export table and sheet-name construction into `createStatsEventSnippetExports.m`.
- Extracted BLI-only stats event-snippet and aligned-sink export preparation into `prepareStatsBLIExportData.m`.
- Extracted grouped sink/surge stats metric workbook preparation into `createStatsMetricWorkbookData.m`.
- Extracted stats core table MAT saving and optional sink/surge event-sheet writing into `saveStatsCoreTables.m` and `writeStatsEventTables.m`.
- Extracted main stats `DataOutput.mat` saving into `saveStatsDataOutput.m`, preserving common fields and BLI-only fields explicitly.
- Extracted main stats `DataOutput.mat` struct construction into `createStatsDataOutput.m`, preserving the legacy saved variable names before writing.
- Extracted common stats export bundle assembly into `createStatsCoreData.m`.
- Extracted BLI-only stats export bundle assembly into `createStatsBLIData.m`.
- Extracted BLI-only stats workbook export bundle assembly into `createStatsBLIWorkbookData.m`.
- Extracted final stats export bundle orchestration into `prepareStatsExportBundles.m`.
- `prepareStatsExportBundles.m` now takes named input structs instead of a long positional argument list, reducing argument-order fragility.
- Extracted stats MAT/workbook export orchestration into `exportStatsResults.m`.
- Extracted timestamped stats output-folder creation into `createStatsOutputFolders.m`, including the stats and figures output paths stored in `StatsInfo.OutputFolders`.
- Extracted stats source-folder selection into `selectStatsOutputFolder.m`, shared by sink, surge, and optional behaviour output folder discovery.
- Extracted stats MAT-file selection into `selectStatsMatFile.m`, centralizing required MAT discovery and multiple-match warnings for sink/surge stats loading.
- Extracted optional stats MAT variable loading into `loadOptionalMatVar.m`, used for optional event tables and curated sink filters.
- Extracted stats recording-cell initialization into `initializeStatsRecordingCells.m`.
- Extracted loaded stats recording-cell collation into `createStatsLoadedRecordingData.m`.
- Extracted stats grouping-level normalization and reporting into `summarizeStatsGroupingLevels.m`.
- Extracted stats behaviour-event time-window selection into `selectStatsBehaviourTimeWindows.m`.
- Extracted BLI ROI trace-feature orchestration into `prepareStatsROITraceFeatures.m`, including a defined empty correlation output for non-BLI stats runs.
- Extracted per-recording stats metadata construction into `createStatsRecordingMetadata.m`, including mouse ID normalization and `PuffStim` detection.
- Extracted stats recording-metadata decoration and legacy event-table `PuffStim` backfilling into `addStatsRecordingMetadata.m` and `ensureStatsEventPuffStim.m`.
- Replaced several workspace-style stats `load(...)` calls with `loadRequiredMatVar.m`, reducing stale-variable risk during multi-recording stats runs.
- Extracted curated oxygen-sink filtering into `applyStatsSinkCuration.m`, applying the same curated inclusion vector to sink summary and event tables.
- Extracted repeated stats metadata cell-row assembly into `createStatsMetadataCellRow.m` for sink areas, sink traces, surge areas, and ROI traces.
- Extracted stats sink area/trace MAT loading and curated filtering into `loadStatsSinkArrayRows.m`.
- Added `loadStatsSinkRecordingData.m` to orchestrate per-recording sink MAT selection, curation, table preparation, and area/trace row loading.
- Added `storeStatsSinkRecordingData.m` to centralize storing prepared sink tables, events, area rows, and trace rows into aggregation cells.
- Extracted stats surge area and optional BLI ROI-trace MAT loading into `loadStatsSurgeArrayRows.m`.
- Added `loadStatsSurgeRecordingData.m` to orchestrate per-recording surge MAT selection, table preparation, area loading, and optional BLI ROI trace loading.
- Added `storeStatsSurgeRecordingData.m` to centralize storing prepared surge tables, events, area rows, and optional BLI ROI traces into aggregation cells.
- Added `isStatsOptionalInputConfigured.m` to centralize optional behaviour-input detection across numeric, text, string, and empty CSV values.
- Extracted posture, pupil, and puff behaviour MAT loading into `loadStatsBehaviourMatRow.m`.
- Extracted whisking sidecar lookup, `RTrace_var` loading, and duration clipping into `loadStatsWhiskingRow.m`.
- Added `createStatsBehaviourInputs.m` to bundle optional posture, pupil, puff, and whisking inputs before behaviour loading.
- Added `loadStatsBehaviourRow.m` as the per-recording behaviour-loading orchestrator used by the stats script.
- Added `createStatsRecordingInput.m` and `loadStatsRecordingIntoCells.m` to extract the full per-recording stats loading loop into a reusable helper.
- Extracted sink and surge summary-table schema selection into `selectStatsSinkSummaryColumns.m` and `selectStatsSurgeSummaryColumns.m`.
- Extracted sink summary/event table preparation into `prepareStatsSinkTables.m`, including schema selection, metadata decoration, duration capture, and legacy event `PuffStim` backfilling.
- Extracted surge summary/event table preparation into `prepareStatsSurgeTables.m` and standalone BLI ROI-trace loading into `loadStatsROITraceRow.m`.
- Extracted per-recording stats source-folder discovery and `StatsInfo.Recordings` bookkeeping into `createStatsRecordingSourceInfo.m`.
- Added selected sink/surge MAT-file paths and `HasSinks`/`HasSurges` flags to each `StatsInfo.Recordings` entry for reproducible stats runs.
- Extended the stats recording summary table to include selected sink/surge MAT files and sink/surge presence flags.
- Added post-load stats QC warnings and `StatsInfo.LoadSummary` via `warnStatsLoadedDataIssues.m`.
- Stats behaviour-load warnings now distinguish existing behaviour folders from configured behaviour inputs, avoiding noisy warnings when behaviour columns are intentionally empty.
- Added `statsLoadSummaryToTable.m` and exports the load summary to a `StatsLoadSummary` workbook sheet.
- Extracted stats run/load summary workbook export into `writeStatsRunSummarySheets.m`.
- Extracted stats behaviour logical-vector construction into `createBehaviourLogicalTraces.m`, covering paw movement, grooming, pupil, puff, and whisking event traces.
- Reduced duplicated candidate-region filtering logic in `OxygenDynamics_Master.m` and `iOSDynamics_Master.m`.
- Centralized repeated metadata CSV import fallback logic in `readInputTable.m`.
- Reduced dependency on optional MATLAB toolboxes for core stats and frame-scaling operations.
- Reduced dependency on optional MATLAB toolboxes in master trace-correlation refinement by replacing `corr` with `safeCorrMatrix.m`.
- Verified the main oxygen and iOS scripts with MATLAB `checkcode`.
- Added `runOxygenPipelineSmokeTest.m`, a quick synthetic TIFF smoke test for TIFF inspection, validation, loading, raw/denoised pairing, raw-only loading, output-folder creation, and expected failure cases such as mismatched raw/denoised dimensions or multiple raw TIFFs.
- Added `compareRawDenoisedOutputs.m`, a post-analysis QC helper that scans analysed recording folders and exports `RawDenoisedQC_*.xlsx` and `RawDenoisedQC_*.mat` with raw/denoised provenance, bit depth, event counts, raw-normalized sink amplitudes, detection-domain amplitudes, and counts of unusually large normalized amplitudes.
- The smoke test now also creates a minimal synthetic oxygen-sink output, checks that `compareRawDenoisedOutputs.m` can summarize it correctly, and verifies shared CSV/path, metadata-table unpacking, wrapper metadata, master parameter/input helpers, recording-area/preprocessing helpers, shared detrending, frame-detection/tracking/refinement/morphology helpers, sink trace extraction, trace-correlation refinement, trace-noise masking, spatial-bin trace extraction, event setup helpers, event size modulation, oxygen and iOS sink/surge event quantification, oxygen sink/surge event collation, stats utility helpers, event-vector and event-vector-row helpers, metadata-vector helpers, summary-table helpers, event-table helpers, master output-saving helpers, run-manifest, run-choice, email-recipient, configuration-printing, run/skip, recording-info, wrapper-finalization options, wrapper-finalization, and failure-log helpers.

## Practical Notes

- Keep exactly one original/non-denoised TIFF in each recording folder.
- Metadata CSV files must include the required columns used by the wrappers/stats script; missing columns now produce an explicit error naming the missing column(s).
- CSV `Paths` entries must point to existing recording folders; missing folders now produce an explicit error before analysis starts.
- If using denoised detection, place exactly one TIFF with `denoised` in the filename in the same folder as the original TIFF.
- The denoised TIFF must have the same frame dimensions and frame count as the original TIFF.
- Use the original TIFF outputs for amplitude interpretation.
- Use `DetectionOxySinkAmp` only when you specifically want the denoised/detection-domain amplitude.
- After analysing a small batch with denoised detection, run `compareRawDenoisedOutputs('metadata.csv')` to verify that each recording used the expected raw and denoised files and that raw-normalized amplitude summaries are in a plausible range.
- To independently audit both signs, run `auditOxygenEventAmplitudeSource(recordingFolder)`. It verifies the source TIFF checksum and independently reconstructs each event footprint, clean pre-event baseline, missingness status and signed amplitude. Both saved sink and surge outputs are required to check contamination.
- For diagnostic plots and full-precision detection reconstruction, use `auditOxygenEventAmplitudeSource(recordingFolder,'reconstructDetection',true,'outputFolder','/path/to/new/audit')`. The saved processed TIFFs are display-scaled and are not numerical audit inputs. See [signal audit definitions](docs/EVENT_SIGNAL_AUDIT.md).
- `auditOxygenSinkAmplitudeSource(recordingFolder,'writeXlsx',true)` uses the same corrected audit and exports sink rows to a new workbook. It no longer uses whole-site raw traces or post-event fallback baselines.
- If passing recording folders directly to `compareRawDenoisedOutputs.m`, use the optional `baseFolder` setting when the paths are relative to a folder other than the current MATLAB folder. QC files are written to `QC_Output/` by default unless you pass an explicit `outputFolder`.
- For batch runs, configure `RunConfig` in `OxygenDynamics_Wrapper.m` or `iOSDynamics_Wrapper.m`, and stats settings in `OxygenDynamics_Config.m`. Advanced batch code can also call `runOxygenDynamicsStats(configStruct)` directly.
- For routine batch runs, prefer editing `OxygenDynamics_Config.m`; use `analysisMode = 'Preflight only'` to validate a dataset before a full run.
- After code changes, run `runOxygenPipelineSmokeTest` in MATLAB to verify the shared TIFF handling, validation failure checks, and output-folder helpers still work.
