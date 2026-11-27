# Automatic pocket and nearby-tissue traces

In the Batch Editor, open **Automatic export**. After a workbook finishes, or after **Open existing export…**, click **Pocket traces**. Open the preview with the original single-channel TIFFs accessible. Check the mouse, condition and sensor group for each recording. Click **Export pocket traces** to create a new `Automatic_PocketTraces_*` folder inside the selected export. Each run has its own folder.

The preview groups byte-identical TIFFs by full SHA-256. Select an alias and use **Confirm mouse ID…** if labels conflict. A completed export records the chosen ID locally for the next preview of that selection in the same output parent. Duplicate rows contribute once after their footprints, detection and measurement bounds, tissue support, pixel scale and references agree. Conflicting conditions or sensors require correction in the source export. **Locate TIFF…** verifies a relocated file by its digest. **Retry sources** checks locally available files again. A partial export requires confirmation of the displayed unavailable rows and lists each one in `Omitted_recordings.csv`.

## What a trace measures

Each automatic sink contributes its saved fixed footprint. On the same original TIFF frames, the analysis averages pixel intensities inside that footprint and within a ring more than 10 and at most 30 µm from its boundary, measured between pixel centers. The ring uses only pixels in the recording’s saved sink-eligible tissue mask. The fixed coordinates also support a 30–50 µm control ring and a tissue-restricted pocket control. The extracted pocket signal is checked against the archived raw trace. Manual review decisions are outside this automatic analysis.

**Figure time zero is the saved automatic measurement onset or offset.** Offset is the last inclusive measurement frame. The first and last native detector frames can differ. The raw CSV records both frame pairs and both pairs of relative time axes. At 1 Hz, if the measurement ends at frame 153 and detection ends at 152, frame 153 has measurement offset time 0 s and native offset time +1 s.

The recording-specific sampling rate defines the window from up to 20 seconds before measurement onset through 60 seconds after measurement offset, clipped to the available frames. Each region’s percent change is 100 × (raw − pre-onset mean) / (pre-onset mean − supplied camera offset). A blank uses the pre-onset mean as the denominator. The pocket must have a valid positive immediate pre-event reference. Raw samples remain available when normalization is unavailable. Missing tissue support gives missing ring values. Positive local excess means the pocket rose more relative to its own baseline than the surrounding tissue did relative to its baseline. The signal is optical intensity in camera units. Converting it to an oxygen concentration requires an independent calibration.

## Reading the output

- `Trace_exports/All_pocket_traces.csv` has one row per distinct pocket per observed frame. Columns include condition, sensor group, mouse, recording, site, event, source digest, acquisition frame, measurement and native timing, raw intensities, normalized signals and flags. `LocalExcess_pp` is pocket minus nearby tissue in percentage points.
- `Pocket_index.csv` records the source, frame bounds, sampling rate, baselines, mask sizes and follow-up for each pocket. `Recording_sources.csv` records every selected alias and its disposition. `AnalysisSettings.json` records timing, distances, software and input selection identity.
- `Conditions.csv` maps each condition to its own folder. Within it, `Aligned_by_mouse.csv`, `Aligned_by_group.csv`, and the three `Windows_by_*.csv` tables contain paired summaries, mouse counts and contributions. The early (+1 to +10 s) and late (+31 to +60 s) summaries require complete paired windows. Flag-screened estimates exclude flagged pocket baselines, potential nearby events in baseline or tested frames, and subsequent same-site sinks.
- `Post_offset_signal_by_mouse.png` shows both optical signals, their difference by sensor group and each mouse’s paired late values. `Example_pocket_and_ring.png` overlays the two masks and plots their raw traces. The example is the first pocket with a full window, falling back to the first available event. Condition-specific `Trace_exports` folders contain the pooled pocket, per-sensor, per-mouse and paired comparison figures and the tables for the pocket-only curves.
- Pockets first contribute to their mouse mean within a condition and sensor group. Each contributing mouse has equal weight in the paired summaries and sensor curves. The descriptive pooled pocket figure weights each pocket equally and shows its interquartile range. Pointwise 95% intervals for local excess resample whole mice 20,000 times within sensors (PCG64 seed 42771). Where a mouse appears in several sensors at a given time, the combined condition estimate pools that mouse’s pockets and resamples whole mice across the condition.
- The per-recording CSVs retain the sampled frames. The geometry MAT files hold one-based MATLAB pixel indices for the three masks and the recording’s tissue support. A missing complete late window yields no late mouse point. A recording with zero pockets remains in the source manifest.

## MATLAB entry points

Run `runPocketNearbyTissue` directly from the project folder. In a fresh session, run `setupOxygenDynamicsPath` before calling the preview or display functions on their own.

```matlab
% Interactive selection and preview
runPocketNearbyTissue

% Inspect the preview from code
plan = preparePocketNearbyTissue(exportFolder);
disp(plan.Rows(:,{'BatchMouse','Mouse','Condition','Group','SourceStatus','SourceSHA256'}))

% Export when all identities and source TIFFs are available
output = runPocketNearbyTissue(exportFolder);

% Inspect any exported pocket, using its actual IDs from the index
events = readtable(fullfile(output,'Pocket_index.csv'),'TextType','string','Delimiter',',');
pocket = events(1,:);
showPocketNearbyTissue(output,pocket.Mouse,pocket.SinkID,pocket.EventID,pocket.SourceSHA256);
```

For a scripted correction, supply `Decisions` as a table with one `SourceSHA256` per affected movie and a `Mouse` or `RawFile` column (or both). Supply `ConfirmedOmissions` as the exact list of unavailable source digests only after reviewing the missing recordings. An optional existing output parent can be passed as the second positional argument. MATLAB with Image Processing Toolbox and Statistics and Machine Learning Toolbox is used. Memory must accommodate one uncompressed imaging volume plus its audit and the accumulated trace tables.

An optional camera dark offset adjusts the reference denominator of intensity-based ratios. Enter it in original counts for each recording or channel. [Camera offset, formulas and dark-frame measurements](CAMERA_OFFSET.md)
