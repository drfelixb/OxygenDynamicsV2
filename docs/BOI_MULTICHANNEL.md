# Multichannel recordings in MATLAB

Open the extracted software folder in MATLAB and run `openBOIMultichannel`, or choose **Multichannel recordings** in `OxygenDynamics_GUI`. Use **Two bioluminescent channels** for independent GeNL and Antares detection. Use **Oxygen plus fluorescence** with oxygen in A and the fluorescence reporter in B.

## Run a batch from CSV

Open **Imaging mode → Multichannel batch from CSV…** in the RC1 Batch recordings window, or run `openBOIMultichannelBatch`. The BOI recording menu in the main launcher and the single-pair setup also open this window.

1. Choose the CSV imaging mode and **Add CSV files…**. Each recording has an **Include** checkbox. Review the two sensor labels, promoters, calibration, TIFF paths and mode before starting. Changing the mode in an existing row clears the previous channel B assignment so you can select its new sensor and movie. You can edit a path or select its cell and choose **Choose TIFF for cell…**.
2. In **dual-bli**, A and B run independent RC1 analyses and the paired result compares sinks. In **bli-fluorescence**, A runs RC1 and B supplies preserved fluorescence intensities on the oxygen footprints. Channel B must have a preserved movie and an empty denoised field in fluorescence mode.
3. **Check included rows** rescans the recording folder for blank preserved TIFF cells and prefers a complete motion-corrected pair. It matches the sensor names and any existing channel selection, then verifies headers and calibration before filling the blanks. Ambiguous pairs stay open for manual selection. Review newly assigned movies before confirming alignment. **Save list as CSV…** saves edited settings to a new file. Confirm the shared grid and frame timing for the included rows. Choose **Run included recordings…** and select one output parent. The software creates a new batch folder, displays the recording, channel and stage, and runs the checked rows in order.
4. Each successful row gets its own independent outputs, paired viewer and workbook. **Open selected result** reopens it. The batch also writes `Paired_recordings.xlsx` for all successes from that invocation. The **Recording summaries** sheet contains independent counts, rates, arithmetic means and medians for duration, area and optical depth or rise, plus the number of measurable depths. Sinks and surges have separate rows.
5. The batch folder's `Queue.csv` records results and errors after each attempt. Completed rows are unchecked. A failed row stays included and the next recording proceeds. **Stop after this recording** leaves the remaining rows queued. To retry or continue, open that CSV, correct any issues and run the included rows into a new batch folder. **Combine saved results…** can combine successes from different runs.

### CSV layouts

A standard RC1 folder list with one **Paths** row per recording can also be imported. **SampleF** and **Pixelsize** supply its calibration. The batch window suggests known sensor names where the prepared TIFF filenames identify them. Fill any remaining sensor, promoter, movie or calibration fields in the table. A single-channel promoter label does not establish the promoter for both channels. Optional **SensorA**, **SensorB**, **PromoterA** and **PromoterB** can provide these assignments in the folder list.

The existing `HP_dual.csv` layout uses two rows sharing `Paths`, with `Sensor_Promoter`, `SampleF` and `Pixelsize`. Rows can appear in any order. Existing GeNL/Antares recordings use GeNL as A and Antares as B. For oxygen plus fluorescence, choose that imaging mode before importing. If a pair has one known oxygen sensor (GeNL or Antares), it becomes A. For other labels, add a **Channel** column with `A` and `B`. Optional **RawFile** and **DenoisedFile** columns select each row's TIFF explicitly. Relative paths in these two columns start at the recording folder. Missing or ambiguous TIFF assignments are shown as blank for review.

Alternatively, use one row per recording. **Mode** can be set per row, including both modes in a single CSV. Here is a two-recording example using paths relative to the CSV.

```csv
RecordingID,Mode,SensorA,SensorB,PromoterA,PromoterB,SampleHz,PixelSizeUm,RawA,RawB
Pair01,dual-bli,GeNL,Antares,hSyn,hSyn,1,2.35,Pair01/GeNL.tif,Pair01/Antares.tif
Pair02,bli-fluorescence,GeNL,GCaMP,hSyn,hSyn,1,2.35,Pair02/oxygen.tif,Pair02/calcium.tif
```

Optional columns include `DenoisedA`, `DenoisedB`, `Include`, `Mouse`, `Condition`, `Genotype` and `DrugID`. If Mode is blank or omitted, the window's import mode applies. Full paths are also accepted. Use distinct recording IDs for rows in the same run.

## Run a recording

1. Choose **Import recording CSV** for the paired GeNL/Antares list and select a recording. Rows are grouped by recording path. The importer reads the promoter and sensor from each row and puts GeNL in A and Antares in B. It keeps the original CSV path. The confirmed FB25049 alias resolves the original `FB25047_49` entry to the `FB25047_2` folder.
2. Alternatively choose **Find prepared TIFF pair** or select each preserved TIFF manually. Folder discovery prefers two `_coupledMC` stacks, then two aligned stacks; averaged images are excluded. Check camera identity, sensor and promoter. A blank path requires an explicit file selection. Multi-page grayscale TIFFs must have equal frame counts and dimensions.
3. Optionally select a matched denoised TIFF for detection in either oxygen channel. The preserved TIFF supplies all optical measurements. Enter the sampling frequency and the pixel size of the **final aligned grid**. For the supplied dual recordings these are **1 Hz** and **2.35 µm/pixel**. Confirm that exposure frames correspond and the pixels are aligned. Registration and synchronized acquisition take place upstream.
4. Choose **Run selected pair…** and an output parent outside the input folders with space for the movies and RC1 outputs. Each run gets a new folder. The workflow stages both preserved movies and optional detection movies. Each oxygen run also retains its own RC1 copy. The bold progress line above the output folder shows the recording ID, active channel and sensor, followed by the current stage. Each oxygen channel advances through input checks, copying, sink and surge analysis, statistics and saved measurements. After the channels finish, the line shows paired measurements, verification, workbook writing and completion. Fluorescence contributes a movie for paired measurements; it has no independent oxygen detection stage. A failure is recorded in `PairStatus.json`; completed independent channel folders can be inspected separately.

To follow an already running pair, call `openBOIMultichannelProgress` and select its output folder. The progress window reads the saved pair and channel stages every two seconds and stops refreshing at completion or failure. You can close that window while analysis continues.

Each oxygen channel uses RC1's automatic tissue estimate, or its corresponding source-bound reviewed tissue declaration when supplied. The shared folder can contain one conventional RC1 declaration of each type. Recordings with distinct declarations for both channels can use separate source directories. A fluorescence movie is measured on oxygen footprints. Its intensities remain in the supplied camera units.

## Read the paired output

| Output | What it contains |
|---|---|
| `Multichannel.xlsx` | Channel identities and source hashes, independent event measurements, common-tissue frequencies, candidate links and within-recording differences |
| `Multichannel.mat` | The workbook tables, fixed footprints, common reference-frame indices, time axis and both preserved-intensity traces for every anchor event |
| `Runs/Channel1`, `Runs/Channel2` | Independent RC1 results, including both signs, saved evidence and statistics. The fluorescence mode produces one oxygen run |
| `PairStatus.json` | Completion state and checksums for the paired MAT and workbook |

**Open saved paired result** loads the MAT file without rerunning either detector. Open **Event traces and links**, choose an anchor, then choose a candidate overlay. The anchor footprint is red, the candidate is green and their intersection appears yellow. The plot always samples both channels on the selected anchor's fixed footprint. Select the other channel's event as the anchor to inspect its footprint instead. **Event window** focuses on the selected intervals; **Full recording** shows context. **Export selected trace…** writes both intensities, percent changes, time, reference frames and anchor-event membership to CSV.

### Four pocket measurements

- **Frequency** is reported in events/mm²/min, separately for sinks and surges. The independent count uses the full RC1 channel result. The comparison gives the intersection of the two saved eligible tissue masks for each sign. It reports counts wholly inside this intersection and counts crossing its boundary. Two clearly labeled rates show the effect of including boundary events. Empty shared tissue gives an unavailable rate. The exposure is frame count divided by the confirmed sample rate.
- **Duration** uses RC1's inclusive measurement bounds in seconds. **Mean native area** is the average native mask area over detected frames, in µm².
- **Optical depth** for sinks, or rise for surges, uses RC1's signed optical measurement on the preserved source, in percent relative to its own event reference. The event table includes reference status. The summary reports the number of available depths and the median. An unavailable depth leaves the count and other available measurements visible.

### Channel traces and calcium signals

For each oxygen anchor, A and B use the same fixed pixels and the same pre-event frames. Each trace is scaled by its own mean on those frames. Change is `100 × (intensity / reference mean − 1)`. This is percent ΔF/F₀ for fluorescence. Reference-frame eligibility comes from the anchor's RC1 pre-event window. Activity in the other channel during that reference can affect its normalization. An incomplete reference, nonpositive reference mean or missing sample leaves the affected quantity unavailable. Raw traces remain available.

The Sinks and Surges sheets report **MeanChangePctA/B** during the anchor interval and **ChangeAtAnchorExtremePctA/B** at the anchor minimum (sink) or maximum (surge). Paired change preserves direction, so a drop is negative. RC1 sink depth uses its positive-drop convention. Fluorescence receives no independent oxygen-event label or inferred onset. The footprint inherits the oxygen channel's support; the user confirms fluorescence covers the corresponding tissue.

### Possible counterparts and timing

The **Candidate sink links** sheet enumerates all sink pairs sharing at least one fixed footprint pixel across the recording. It preserves many-to-many relationships, including widely separated episodes at recurring sites. Each row reports shared pixels, intersection divided by union (Jaccard overlap), overlap of the modeled event intervals, intervening time and the number of native frames with at least one coincident pixel. A gap of zero can also mean adjacent frame intervals. Temporal overlap and native coincident pixels have separate columns.

Both lags are **B minus A in seconds**. Positive means A was earlier. Onset uses the RC1 measurement start. Minimum uses the preserved-intensity minimum on each event's own footprint within its RC1 bounds. A tied minimum uses the first such frame and is flagged in the independent event table. A link describes a candidate. Deciding which overlap or delay constitutes a shared pocket remains a review decision. An isolated detection still has both intensity traces and has no assigned partner lag.

### Compare recordings

Choose **Combine saved recordings** and add completed MAT files, then finish selection to write a new workbook. Each recording contributes its own paired summary and retains its independent events. **Paired differences** lists same-promoter comparisons first, with Antares minus GeNL when both are present. Mixed-promoter comparisons follow, with GFAP minus hSyn for those assignments. Column labels always identify the actual first and second sensors and promoters. Differences are second minus first. The rates use common tissue. The duration, area and optical-depth summaries use each channel's independently detected population. These are descriptive comparisons per recording.

For scripted use, `importBOIMultichannelCSV` returns one settings structure per pair. Set `AlignedAndSynchronized=true` after checking the preparation, supply a fresh `OutputFolder`, and pass the chosen structure to `runBOIMultichannel`. Direct callers can set `Mode` to `"dual-bli"` or `"bli-fluorescence"`, and specify the two `RawFiles`, optional `DenoisedFiles`, `Sensors`, `Promoters`, `RecordingID`, `SampleHz` and `PixelSizeUm`. Use `viewBOIMultichannel` to reopen a result and `exportBOIMultichannelComparison(files,workbook)` to combine saved recordings.
