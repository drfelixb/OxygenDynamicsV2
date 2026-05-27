# Oxygen Dynamics Pipeline User Manual

This manual describes how to run the oxygen dynamics pipeline from a fresh MATLAB session, how to prepare input data, what outputs to expect, and how to diagnose common problems.

For a visual overview of the coded workflow, open `Pipeline_FlowMap.svg` in the project root. For a detailed view of hypoxic-pocket signal detection, tracking/refinement, and raw quantification, open `Detection_Processing_FlowMap.svg`.

## 1. What The Pipeline Does

The pipeline detects and analyses oxygen dynamics in cortical imaging recordings.

Main analyses:

- Detect oxygen sinks and oxygen surges in TIFF recordings.
- Use a denoised TIFF for event detection when available.
- Always quantify signal amplitudes from the original/raw TIFF.
- Export recording-level, ROI-level, and event-level tables.
- Optionally analyse behaviour traces.
- Optionally compare raw and denoised outputs for QC.
- Optionally compute vascular-distance metrics from artery/vein annotation masks.

The denoised/raw split is important. Denoised recordings can improve event detection, but denoising or scaling can distort signal amplitudes. Therefore detection may use `denoised.tif`, while `NormOxySinkAmp`, raw sink traces, and related amplitude outputs are calculated from the original recording.

## 2. Project Layout

The project root contains the scripts users normally run:

- `Start_OxygenPipeline.m`
- `OxygenDynamics_Config.m`
- `OxygenDynamics_GUI.m`
- `OxygenPipeline_VerificationReport.m`
- `Run_Verification_Then_Wrapper.m`
- `Run_Verification_Then_Stats.m`
- `OxygenDynamics_Wrapper.m`
- `OxygenDynamics_Stats.m`
- `OxygenDynamics_VascularAnalysis.m`
- `OxygenDynamics_VascularAnalysis_IndividualEvents.m`
- `runOxygenPipelineSmokeTest.m`
- `checkOxygenPipelineHealth.m`
- `reviewLatestStatsAcceptance.m`

Support code is organized in folders:

- `helpers/`: project helper functions, including GUI preview helpers, stats acceptance helpers, and lower-level per-recording run functions used by wrappers and compatibility scripts.
- `external/`: bundled third-party/shared file I/O helpers such as `loadtiff.m` and `saveastiff.m`.
- `Legacy_Archive/`: older script versions and retired standalone workflows.
- `Run_Logs/`: wrapper run manifests and failure logs.
- `QC_Output/`: raw/denoised QC output.
- `Stats_Runs/`: timestamped stats output folders.
- `Verification_Reports/`: non-destructive dataset readiness reports.

Most main scripts call `setupOxygenDynamicsPath` automatically. If you call helper functions directly, first run:

```matlab
setupOxygenDynamicsPath
```

For occasional cleanup of generated root-level output files, preview moves first:

```matlab
archiveOldOutputs('dryRun',true)
```

If the preview looks correct, run:

```matlab
archiveOldOutputs
```

## 3. Recording Folder Requirements

Each recording folder should contain exactly one original/raw TIFF stack.

Example:

```text
Data/control/FB237/
  FB237_bin2_1hz_baseline_1.tif
  denoised.tif                         optional
  Posture.csv                          optional behaviour
  Pupil.csv                            optional behaviour
  Puffs.abf                            optional behaviour
  FB237_Arteries.png                   optional vascular annotation
  FB237_Veins.png                      optional vascular annotation
```

TIFF rules:

- Keep exactly one non-denoised TIFF in the recording folder.
- If a denoised TIFF exists, its filename must contain `denoised`.
- Keep at most one denoised TIFF in the folder.
- Raw and denoised TIFFs must have the same width, height, and frame count.

Vascular annotation rules:

- Artery annotation image filename must contain `Arteries`.
- Vein annotation image filename must contain `Veins`.
- Annotation images are expected to be readable image files, for example PNG.

## 4. Input CSV Format

The wrapper, stats, and verification scripts use a metadata CSV.

Required columns:

```text
Paths
PostureFile
PupilFile
PuffsFile
Mouse
Genotype
Condition
DrugID
Promoter
SampleF
Pixelsize
```

Column meaning:

- `Paths`: recording folder path, relative to the project root or absolute.
- `PostureFile`: behaviour movement/posture filename without extension.
- `PupilFile`: pupil CSV filename without extension.
- `PuffsFile`: puff ABF filename without extension.
- `Mouse`: mouse or recording ID.
- `Genotype`: genotype label.
- `Condition`: condition label.
- `DrugID`: drug/group label.
- `Promoter`: promoter/virus label.
- `SampleF`: imaging sampling frequency in Hz.
- `Pixelsize`: micrometers per pixel.

Example row:

```text
Paths,PostureFile,PupilFile,PuffsFile,Mouse,Genotype,Condition,DrugID,Promoter,SampleF,Pixelsize
Data/control/FB237,Posture,Pupil,Puffs,FB237,WT,Anesthetized,KX,GFAP,1,2.5
```

## 5. Central Configuration

Edit routine settings in:

```matlab
OxygenDynamics_Config.m
```

Important sections:

```matlab
Config.OxygenWrapper.inputCsv = 'GFAP_GeNL_Ctrl.csv';
Config.OxygenWrapper.interactive = false;
Config.OxygenWrapper.reanalyseExisting = true;
Config.OxygenWrapper.overwritePreviousAnalysis = false;
Config.OxygenWrapper.analysisMode = 'All analysis';
Config.OxygenWrapper.runRawDenoisedQC = true;
```

Stats:

```matlab
Config.Stats.inputCsv = 'GFAP_GeNL_Ctrl.csv';
Config.Stats.useCuratedSinks = false;
Config.Stats.imagingMode = 'BLI';
Config.Stats.sinkFolderSelection = 'Recent';
Config.Stats.surgeFolderSelection = 'Recent';
Config.Stats.behaviourFolderSelection = 'Recent';
Config.Stats.outputRoot = 'Stats_Runs';
```

Verification:

```matlab
Config.Verification.inputCsv = Config.Stats.inputCsv;
Config.Verification.outputRoot = 'Verification_Reports';
Config.Verification.requireBehaviour = false;
Config.Verification.requireVascularAnnotations = false;
```

Set `requireBehaviour` or `requireVascularAnnotations` to `true` when missing behaviour or vascular files should force review before downstream steps.

## 6. Recommended Workflow

### Option A: Stepwise GUI Workflow

For the easiest guided workflow, run:

```matlab
Start_OxygenPipeline
```

This sets up the project path and opens the GUI.

You can also open the GUI directly:

```matlab
OxygenDynamics_GUI
```

The GUI lets you:

- choose an input CSV with a file browser
- use the CSV folder as the dataset working folder
- run verification
- review `Status`, `IssueSummary`, and `RecommendedAction`
- run the oxygen wrapper when no recording is blocked
- automatically refresh verification after wrapper outputs are created
- run stats when no recording is blocked
- generate first-pass summary figures after stats
- open the latest verification report, wrapper log, stats workbook, and figure folder
- inspect the `Results Preview` tab for recording/table counts, generated figure previews, and lightweight stats QC rows
- open this manual

This is the recommended entry point for users who do not want to edit working folders manually.

### Lock A Known-Good Reference Run

Once a stats run has been inspected and accepted, save it as the regression baseline:

```matlab
createOxygenRegressionBaseline('Stats_Runs/Stats_Output_YYYYMMDDTHHMMSS')
```

This writes both a `.mat` baseline used by the regression checker and an `.xlsx` workbook that can be inspected manually. If a previous baseline already exists, it is archived under `Regression_Baselines/Archive/<timestamp>/` before the new baseline is written.

After future edits, run stats again and compare the new output:

```matlab
runOxygenRegressionTest('Stats_Runs/Stats_Output_YYYYMMDDTHHMMSS')
```

For a simpler command-line entry point, run:

```matlab
Run_Regression_Check
```

or:

```matlab
runOxygenRegressionCheck
```

This finds the latest stats output, reports whether a baseline is available, and runs the regression when ready. To inspect readiness without running the comparison:

```matlab
getOxygenRegressionStatus
```

Passing means the selected core outputs still match the locked reference within tolerance. Failing means the scientific output changed, the input data changed, or the baseline should be intentionally replaced after review.

In the GUI, the same workflow is available in the `Latest outputs` panel:

- `Create Baseline` saves the currently selected/latest stats output as the known-good reference.
- `Run Regression` compares the latest stats output against that reference and opens a report when available.
- If a baseline already exists, the GUI asks for confirmation before overwriting it.
- After a regression run, the `Results Preview` table shows pass/fail plus the first summary messages.

The GUI also has a dedicated `Regression` tab. Use it to refresh baseline/report readiness, inspect the latest stats folder and archived baseline count, review `ReviewFirst` action rows, review archived baselines, choose a specific `Stats_Output_*` folder, run regression, open the baseline workbook, open the latest regression report, open the regression folder, open the archive folder, or choose an archived baseline to restore. Restoring an archived baseline asks for confirmation and archives the current baseline before replacing it.

Regression passing also requires strict scientific guardrails: hypoxic burden must use true event rows, every burden row must have event-specific area matched, ROI-area fallback rows must be zero, and the `OxySinksPer1mm2` FOV normalization factors must be finite.

The regression Excel report contains:

- `RegressionSummary`: readable pass/fail summary, failure categories, and largest numeric changes.
- `ReviewFirst`: the first failed or informational rows to inspect, with recommended actions.
- `NumericChecks`: full expected vs actual metric comparison.
- `TextChecks`: input CSV, master folder, and mouse-list comparisons.
- `ScientificGuardrails`: event-area and normalization safety checks.
- `BaselineMetadata` and `ActualMetadata`: source paths, MATLAB version, recording count, and related provenance.
- `CodeManifestDiff`: MATLAB code files that were added, removed, or changed since the baseline.
- `FileManifestDiff`: key input/output files whose content hash, existence, or path changed since the baseline.

Only refresh the baseline after you have inspected the new stats output and decided that the change is scientifically expected. For batch scripts that should continue after a failed regression and inspect the returned result:

```matlab
Result = runOxygenRegressionTest('Stats_Runs/Stats_Output_YYYYMMDDTHHMMSS', ...
    'Regression_Baselines/OxygenRegressionBaseline.mat', ...
    'ThrowOnFailure',false);
```

To inspect archived baselines:

```matlab
Archived = listOxygenRegressionBaselines('Regression_Baselines/OxygenRegressionBaseline.mat')
```

To restore one deliberately:

```matlab
restoreOxygenRegressionBaseline(Archived.MatPath(1), ...
    'Regression_Baselines/OxygenRegressionBaseline.mat')
```

### Option B: Command-Line Workflow

#### Step 1: Open MATLAB In The Project Root

Start MATLAB in the folder containing `OxygenDynamics_Config.m`.

Then run:

```matlab
setupOxygenDynamicsPath
```

#### Step 2: Edit Configuration

Open `OxygenDynamics_Config.m` and set the input CSV and run choices.

For most routine oxygen runs:

```matlab
Config.OxygenWrapper.inputCsv = 'YourInput.csv';
Config.Stats.inputCsv = 'YourInput.csv';
Config.Verification.inputCsv = 'YourInput.csv';
```

#### Step 3: Run Verification

Before a long wrapper or stats run:

```matlab
OxygenPipeline_VerificationReport
```

The console prints:

```text
Pipeline verification summary
Recordings: N
Ready: N
Partial: N
Blocked: N
```

The Excel report is written to:

```text
Verification_Reports/PipelineVerification_*.xlsx
```

Important sheets:

- `RunSummary`: input file, timestamp, ready/partial/blocked counts.
- `RecordingSummary`: one row per recording.
- `NeedsReview`: only recordings that are `Partial` or `Blocked`.

Key columns:

- `Status`
- `IssueSummary`
- `RecommendedAction`
- `PreflightValid`
- `RawTiffCount`
- `DenoisedTiffCount`
- `DetectionSource`
- `QuantificationSource`
- `CanExportEventMetrics`
- `HasBehaviourOutput`
- `HasVascularAnnotations`

#### Step 4: Run Wrapper

Recommended safe launcher:

```matlab
Run_Verification_Then_Wrapper
```

This runs the verification report first. If any recording is `Blocked`, the wrapper does not start.

You can also run the wrapper directly:

```matlab
OxygenDynamics_Wrapper
```

Wrapper modes are controlled by `Config.OxygenWrapper.analysisMode`:

- `All analysis`: imaging analysis plus TIFF output/behaviour depending on settings.
- `Only df/f tifs`: only TIFF output step.
- `Preflight only`: validation without heavy analysis.

#### Step 5: Manual Curation

Some sink detections may require manual curation.

Run the curation workflow after the wrapper has produced sink outputs:

```matlab
OxygenDynamics_Sinks_Curation
```

Curated files are saved in `ManualCurOxySinksData*` folders.

#### Step 6: Run Stats

Recommended safe launcher:

```matlab
Run_Verification_Then_Stats
```

This runs verification first and stops if any recording is blocked.

You can also run stats directly:

```matlab
OxygenDynamics_Stats
```

Stats outputs are written under:

```text
Stats_Runs/Stats_Output_YYYYMMDDTHHMMSS/
```

#### Step 7: Optional Vascular Analysis

ROI-level vascular distance:

```matlab
OxygenDynamics_VascularAnalysis
```

This calls:

```matlab
runOxygenDynamicsVascularAnalysis
```

Event-level vascular distance:

```matlab
OxygenDynamics_VascularAnalysis_IndividualEvents
```

This calls:

```matlab
runOxygenDynamicsVascularEventAnalysis
```

Vascular analysis requires artery and vein annotation images in each recording folder.

#### Step 8: Optional Summary Figures

After stats have produced `DataOutput.mat`, generate first-pass summary figures with:

```matlab
runOxygenSummaryFigures
```

Or pass a stats result/folder explicitly:

```matlab
runOxygenSummaryFigures(StatsResult)
runOxygenSummaryFigures('Stats_Runs/Stats_Output_YYYYMMDDTHHMMSS')
```

The GUI runs this from the `4. Figures` button after stats.

When the required stats tables are present, the first-pass figures include sink summary metrics, event-level hypoxic burden distributions, recording/group-level hypoxic burden summaries, an event area vs amplitude plot with duration encoded by marker size and burden contribution encoded by color, `OxySinksPer1mm2` summaries, and `OxySinksPer1mm2` group time courses with SEM bands. The time-course x-axis uses seconds or minutes when `SampleF` is available in the stats metadata; otherwise it uses frame number.

Current first-pass figures include supported sink metrics such as:

- `MeanOxySinkEvent_NormAmp`
- `MeanOxySinkEvent_Duration`
- `NumOxySinkEvents_Norm`
- `MeanOxySinkArea_um`

If hypoxic burden data are present in `DataOutput.mat`, the same command also writes:

- `HypoxicBurden_PerEventContribution`
- `HypoxicBurden_EventAmplitude`
- `HypoxicBurden_EventArea`
- `HypoxicBurden_EventDuration`
- `HypoxicBurden_ByRecording`

If `NumOngoingOxysinksPerMm2` traces are present, it also writes:

- `OxySinksPer1mm2_Mean`
- `OxySinksPer1mm2_Max`
- `OxySinksPer1mm2_Sum`

Figures are grouped by available `DrugID`, `Condition`, and `PuffStim` columns and saved as PNG/FIG files. `OxygenSummaryFigureMetrics.xlsx` includes a `MetricSummary` sheet and a `FigureManifest` sheet listing figure type, metric, label, and file path.

## 7. Denoised TIFF Handling

If the recording folder contains a denoised TIFF:

- detection source: denoised TIFF
- quantification source: original/raw TIFF

If no denoised TIFF is present:

- detection source: original/raw TIFF
- quantification source: original/raw TIFF

The denoised TIFF is detected by filename. The name must contain:

```text
denoised
```

The wrapper prints which file is loaded and whether denoised data are used.

## 8. Main Outputs

### Per-Recording Outputs

Inside each recording folder:

```text
OxygenSinks_Output*
ManualCurOxySinksData*
OxygenSurges_Output*
Images_Processed*
Behaviour_Output*
```

Important sink outputs:

- `OxygenSinks_Urefined*.mat`
- `IM_OxySinks_BW*.tif`
- sink summary table
- sink event table
- raw and detection trace outputs

Important surge outputs:

- `OxygenSurges*.mat`
- `IM_OxySurges_BW*.tif`
- surge summary table
- surge event table

### Stats Outputs

Inside `Stats_Runs/Stats_Output_*`:

- `FilteredData_<inputcsv>.xlsx`
- `DataOutput.mat`
- `SinkEventTable.mat`
- `SurgeEventTable.mat`
- `SortedSinkEventMetrics.xlsx`
- `HypoxicEventSpecificMetrics4LME.mat`

`FilteredData_<inputcsv>.xlsx` includes a `MetricBasis` sheet to clarify whether outputs are ROI/sink-based, ROI event summaries, or true event-based metrics. It also includes a `MetricDefinitions` sheet with formulas, units, output locations, and analysis basis for key values such as `PerEventBurdenContribution`, `HypoxicBurden`, and `OxySinksPer1mm2`.

The same workbook includes hypoxic burden sheets:

- `HypoxicBurden_Basis`: formula and metric basis.
- `HypoxicBurden_EventBased`: true individual oxygen-sink event rows with burden contribution.
- `HypoxicBurden_ByRecording`: summed hypoxic burden per recording/FOV.
- `HypoxicBurden_GroupSummary`: grouped recording summaries by available `DrugID`, `Condition`, `PuffStim`, `Genotype`, and `Promoter`, including recording count, event count, mean/SEM/median/sum burden, and event-specific area match rate.

`PerEventBurdenContribution` is calculated as positive drop amplitude percent x event area in um^2 x event duration in seconds. The preferred area source is the true event-specific `Area_um` from the event-specific hypoxic metrics table. If that event-specific table is unavailable or cannot be matched, the workbook marks the area source as a fallback to the site-level `MeanOxySinkArea_um`. `HypoxicBurden` is the sum of event contributions within each recording/FOV.

The hypoxic burden sheets include provenance columns such as `BurdenAmplitudeSource`, `BurdenAreaSource`, `BurdenDurationSource`, `BurdenAreaEventSpecificMatched`, and `BurdenContributionFormula`.

The workbook also includes `SinkCountNormFactors`, which documents the recording-area correction used for the `OxySinksPer1mm2` time-series export. The correction uses `FOVEdge_um = sqrt(RecordingArea_um2)`, `kappa = 1000 / FOVEdge_um`, and `AreaCorrectionFactor_1mm2 = kappa^2`. The normalized trace is `NumOngoingOxysinksPerMm2 = NumOngoingOxysinks * AreaCorrectionFactor_1mm2`. This sheet also includes provenance columns such as `NormalizationSource`, `NormalizedTrace`, and `Formula`.

`SortedSinkEventMetrics.xlsx` contains event-based hypoxic sink metrics. Sheets are prefixed with `EventBased_`.

After stats, the workbook includes a `StatsAcceptance` sheet and the GUI `Results Preview` adds a matching acceptance summary plus `QC:` rows. The GUI keeps acceptance, review, and regression rows near the top and highlights statuses when supported by the MATLAB version. These summarize whether hypoxic burden used event-specific area rows, whether per-event burden contributions are finite, whether the area-normalization factors are finite and positive, and whether configured behaviour inputs loaded behaviour traces. The `WhereToLook` column points to the relevant workbook sheet, such as `HypoxicBurden_EventBased`, `SinkCountNormFactors`, or `StatsLoadIssues`. Treat `REVIEW` rows as a prompt to inspect the workbook before accepting the stats run or replacing a regression baseline.

When you click `Create Baseline` in the GUI, this same acceptance status is checked first. A `PASS` stats output can be locked directly. If the stats output has `REVIEW` rows, the GUI asks you to confirm that you have inspected and accepted them before creating or replacing the regression baseline.

In new stats workbooks, `StatsAcceptance` is written as the first sheet. Use `Open Acceptance` in the GUI output panel to open the current stats workbook and inspect that sheet directly.

For a command-line check without opening the GUI or Excel, run:

```matlab
reviewLatestStatsAcceptance
```

You can also pass a project folder, a specific `Stats_Output_*` folder, or a `DataOutput.mat` path:

```matlab
reviewLatestStatsAcceptance('Stats_Runs/Stats_Output_YYYYMMDDTHHMMSS')
```

For a broader lightweight status check of the code installation, latest stats acceptance, and regression readiness, run:

```matlab
checkOxygenPipelineHealth
```

To check a specific dataset folder:

```matlab
checkOxygenPipelineHealth('D:\path\to\dataset')
```

### Verification Outputs

Inside `Verification_Reports/`:

- `PipelineVerification_*.xlsx`
- `PipelineVerification_*.mat`

### QC Outputs

Inside `QC_Output/`:

- `RawDenoisedQC_*.xlsx`
- `RawDenoisedQC_*.mat`

These compare raw/denoised provenance and summarize event counts and amplitude sanity checks.

### Run Logs

Inside `Run_Logs/`:

- `OxygenDynamics_WrapperRunInfo.mat`
- `iOSDynamics_WrapperRunInfo.mat`
- copied input CSVs
- failure logs when failures occur

## 9. Common Commands

Run verification only:

```matlab
OxygenPipeline_VerificationReport
```

Run the stepwise GUI:

```matlab
OxygenDynamics_GUI
```

Run verification, then wrapper:

```matlab
Run_Verification_Then_Wrapper
```

Run verification, then stats:

```matlab
Run_Verification_Then_Stats
```

Run wrapper directly:

```matlab
OxygenDynamics_Wrapper
```

Run stats directly:

```matlab
OxygenDynamics_Stats
```

Generate first-pass summary figures:

```matlab
runOxygenSummaryFigures
```

Run smoke test:

```matlab
runOxygenPipelineSmokeTest
```

Run broad static check manually:

```matlab
setupOxygenDynamicsPath
files = [dir('*.m'); dir(fullfile('helpers','*.m'))];
issues = 0;
for k = 1:numel(files)
    f = fullfile(files(k).folder,files(k).name);
    msgs = checkcode(f);
    if ~isempty(msgs)
        fprintf('\n%s\n',f);
        for j = 1:numel(msgs)
            fprintf('L%d: %s\n',msgs(j).line,msgs(j).message);
        end
        issues = issues + numel(msgs);
    end
end
fprintf('\ncheckcode issue count: %d\n',issues);
```

## 10. Troubleshooting

### No TIFF Files Found

Message:

```text
No tif files were found in this recording folder.
```

Fix:

- Put the original/raw TIFF in the recording folder listed in `Paths`.
- Check that the path in the CSV is correct.

### No Original/Raw TIFF Found

Message:

```text
No original/raw tif was found.
```

Cause:

- All TIFF filenames may contain `denoised`.

Fix:

- Keep one original TIFF whose filename does not contain `denoised`.

### More Than One Raw TIFF

Message:

```text
More than one original/raw tif was found.
```

Fix:

- Keep only one non-denoised TIFF in the recording folder.
- Move extra raw TIFFs elsewhere or rename/store them outside the recording folder.

### More Than One Denoised TIFF

Message:

```text
More than one denoised tif was found.
```

Fix:

- Keep only one TIFF with `denoised` in the filename.

### Raw/Denoised Dimension Mismatch

Message:

```text
The original and denoised tif stacks do not have matching width, height, and frame count.
```

Fix:

- Make sure the denoised TIFF was generated from the same original recording.
- Width, height, and frame count must match exactly.

### Missing Behaviour Output

This is usually not fatal unless strict verification requires behaviour.

Fix:

- Run wrapper with behaviour analysis enabled and required behaviour files present.
- Or leave `Config.Verification.requireBehaviour = false` if behaviour is optional.

### Missing Vascular Annotation Files

This only affects vascular analysis unless strict verification requires annotations.

Fix:

- Add artery annotation image with `Arteries` in the filename.
- Add vein annotation image with `Veins` in the filename.
- Or leave `Config.Verification.requireVascularAnnotations = false` if vascular analysis is optional.

### Missing Sink Or Surge Outputs For Stats

Stats requires sink and surge output folders.

Fix:

- Run `Run_Verification_Then_Wrapper`.
- Confirm `OxygenSinks_Output*` and `OxygenSurges_Output*` exist in each recording folder.

### Event-Based Metrics Are Not Produced

Event-specific metrics require:

- sink MAT file with `Table_OxygenSinks_Out`
- `OxySinkArea_all`
- sink binary TIFF such as `IM_OxySinks_BW*.tif`

Fix:

- Check the verification report columns `CanExportEventMetrics`, `OxygenSinksMat`, and `OxygenSinksBinaryTiff`.

### Very Large Normalized Amplitudes

Likely cause:

- amplitude calculated from denoised/scaled data in older workflows.

Current behaviour:

- detection can use denoised data
- quantification uses original/raw data

Fix:

- Re-run with the current wrapper/master scripts.
- Check `AnalysisInfo` and raw/denoised QC outputs.

### Missing `corr`, `zscore`, Or Toolbox Functions

The core pipeline now uses local helpers for many formerly toolbox-dependent operations:

- `safeCorr`
- `safeCorrMatrix`
- `safeZScore`
- `safeMat2Gray`
- `safeCoeffVariation`
- `safeShannonEntropy`

If you still see toolbox-related errors, run:

```matlab
setupOxygenDynamicsPath
which safeCorr
which safeZScore
```

Then run:

```matlab
runOxygenPipelineSmokeTest
```

### Old Output Folders

If output folders already exist:

- wrapper may create timestamped output folders
- stats selects recent or oldest folders depending on config

Relevant settings:

```matlab
Config.OxygenWrapper.reanalyseExisting = true;
Config.OxygenWrapper.overwritePreviousAnalysis = false;
Config.Stats.sinkFolderSelection = 'Recent';
Config.Stats.surgeFolderSelection = 'Recent';
Config.Stats.behaviourFolderSelection = 'Recent';
```

Use the verification report to see exactly which folders stats will use.

## 11. Recommended Routine

For normal oxygen datasets:

```matlab
setupOxygenDynamicsPath
OxygenPipeline_VerificationReport
Run_Verification_Then_Wrapper
OxygenDynamics_Sinks_Curation
Run_Verification_Then_Stats
```

For a quick health check after code edits:

```matlab
setupOxygenDynamicsPath
runOxygenPipelineSmokeTest
```

For vascular analysis after sink outputs and annotations are ready:

```matlab
OxygenDynamics_VascularAnalysis
OxygenDynamics_VascularAnalysis_IndividualEvents
```

For first-pass figures after stats:

```matlab
runOxygenSummaryFigures
```
