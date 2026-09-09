# Existing analysis corrections: schema 3.0-dev

This work changes normalization, measurement and aggregation in the existing V2 detector. It does not implement the alternative detector. The implementation is isolated in the `existing-analysis` checkout, based on upstream main `8cf3f036b41e16b2c472bcee7e5cfaeab41433eb`.

## Measurement hierarchy

| Output | One row represents | Interpretation |
|---|---|---|
| Sink/surge summary tables | A recurring spatial site | Site morphology and summaries of events within that site |
| Sink/surge event tables | An individual event at a site | Event timing, raw-footprint amplitude, native event morphology |
| RecordingRegistry | An analyzed recording, even with no events | Independent exposure time, eligible tissue area, sampling rate, animal and condition |
| HypoxicBurden.RecordingTable | A recording | Event totals and exposure-normalized rates |
| HypoxicBurden.GroupSummaryTable | A complete biological group | Equal mouse means, after averaging recordings within each mouse |
| RecordingWindowMetrics | An explicitly bounded recording window | Onsets, concurrent event time, occupied tissue fraction and amplitude-area-time composite |

`RecordingID + SinkID/SurgeID + EventID` identifies an event. Local numeric IDs repeat across recordings. `SiteID` survives curation; row position is not identity. CSV metadata refreshes both event and site rows. RecordingID defaults to the canonical recording directory, so a stable explicit `RecordingID` CSV column is preferable when moving datasets.

`FramePixels` stores the native, full-image pixel indices for every site and frame. Morphology is calculated from these masks, never from display TIFFs or a site's lifetime union. Event area is mean instantaneous area during that individual detection run. Equivalent diameter is the diameter of a circle with the same total per-frame area. Perimeters sum connected components; circularity averages component circularities; centroid coordinates are area-weighted across components, then averaged across frames. Coordinates are pixels, lengths are micrometres and areas are square micrometres. `Site...` event columns preserve the former parent-site descriptors.

Detection-mask bounds and trace-refined bounds are different measurements. Event-specific exports label both `DetectionStartFrame/DetectionEndFrame` and refined `StartFrame/EndFrame`. Native area exists on detection frames; refined duration may extend beyond them.

## Time and area

For N frames at fs Hz, recording duration is N/fs seconds. MATLAB frame f represents the interval [(f-1)/fs, f/fs). An event from frame a through b has duration (b-a+1)/fs. Ongoing event counts can exceed one for overlapping events within one site; the site raster remains Boolean.

Sink normalization uses eligible tissue within the detector's border crop. Surge normalization uses its own eligible tissue search area. Count density is count × 1e6/area_um2. Occupied area is the union of native active masks intersected with the saved eligible tissue support, counted once per pixel and scaled by pixel_size². Accepted detector regions can extend outside tissue; those pixels are excluded from occupancy, while event morphology continues to describe the full detected region. Dividing that union area by tissue area yields a tissue fraction. A missing or nonpositive area cannot support a normalized result.

`SinkSiteEventRate_per_min` and `SurgeSiteEventRate_per_min` both equal site event count × 60 / recording duration in seconds. They are site recurrence rates, not recording event density. The ambiguous `NumOxySinkEvents_Norm` and `NumOxySurgeEvents_Norm` columns/sheets have been removed; the former surge value was per second and differs by a factor of 60. Site mean durations use seconds.

## Local amplitude baseline

Each event uses a fixed footprint: the spatial union of its own detection masks. The mean signal across that footprint is measured in the preserved input stack. Neither the site's lifetime footprint nor the standardized detection trace supplies the new amplitude.

The baseline is the complete contiguous window immediately before the trace-refined event start. Its length comes from `quantBaselineWindowSec` for sinks and `surgeBaselineWindowSec` for surges. Every baseline frame must have finite signal, and no detected sink or surge may overlap the event footprint during that window. No post-event fallback is used. A truncated or contaminated window produces a missing amplitude while retaining the event, timing and area. Baseline columns record value, usable sample count, bounds and status.

For signal F and pre-event mean B:

- Signed fractional trace: (F-B)/B.
- Sink peak drop fraction: -min((F-B)/B).
- Surge peak increase fraction: max((F-B)/B).
- Percent columns are 100 times those fractions.
- `MeanSignedChangeFraction` and `SignedTraceAUC_sec` retain signed responses.

B must be positive; missing event signal prevents amplitude quantification. Wrong-direction sink amplitudes are unavailable for hypoxic burden. Cohort composition never determines a sign flip. Current pipeline outputs use explicitly signed measurements; old saved analyses are rejected.

These are relative optical-signal changes. They are not calibrated oxygen concentrations or a depth-resolved oxygen deficit. A local pre-event baseline also does not establish the baseline recording for a treatment comparison.

## Burden is three different quantities

1. **Concurrent event-time density**: sum(event durations) × 1e6/area × 60/recording seconds. The legacy name `Burden_Occupancy` remains, but its units are event-seconds/mm²/min. It is not a tissue fraction.
2. **Occupied tissue fraction**: integrate the instantaneous native-mask union area over a window, then divide by tissue area × window duration. Exported as `MeanOccupiedTissueFraction`.
3. **Amplitude-area-time composite**: sum(peak drop percent × event mean area × refined duration). This rectangular approximation is the legacy `HypoxicBurden`/`Burden_AmplitudeComposite`; it is not the integral of the measured oxygen trace. `SignedTraceAUC_sec` is a separate signal integral.

Overlapping events contribute separately to event-time density and the composite. Occupied tissue uses a union to avoid double counting. Burden traces integrate back to event contributions when multiplied by the frame interval. Rank-amplitude burden remains a within-recording sensitivity descriptor, unsuitable for interpreting absolute changes in response magnitude across recordings.

A valid zero-event recording has zero counts and total burden. Mean event amplitude is undefined when there are no events. If a detected event lacks a required composite measurement, the recording's composite total is NaN, not the sum of the remaining events. Valid-event counts accompany totals. Group summaries report separate animal, recording, site and event counts and valid animal counts per metric; SEM needs at least two valid animals. Scalar figures use the same strict within-mouse missingness policy as the tables. Unavailable site metrics are skipped and recorded in the figure metrics workbook with `UnavailableReason`; zero-event recordings can still produce valid recording-level figures.

## Measurement availability

`EventMeasurementQC` in the workbook and `DataOutput.mat` contains one row per recording and event type, including zero-event rows. It reports detected event count, valid baseline count, finite/unavailable amplitude counts, wrong-direction finite amplitude count, and fractions of all detected events with valid baselines/finite amplitudes. For zero detected events, counts are zero and availability fractions are undefined (NaN), not 100%. `EventBaselineStatusCounts` reports the reasons assigned by the event quantifier. A finite amplitude requires a valid baseline. Wrong-direction amplitude is counted separately from missing amplitude and is not relabelled as missing by QC.

These tables describe measurement availability among detections. They do not estimate true/false detections, sensitivity or specificity. Missingness may depend on event recurrence, time or experimental condition; site means of available amplitudes must be interpreted alongside these counts.

## Explicit baseline comparisons

Three optional `Config.Stats` fields (also accepted by `runOxygenDynamicsStats`) accept CSV paths:

| Field | CSV columns |
|---|---|
| `baselinePairsCsv` | BaselineRecordingID, ComparisonRecordingID |
| `analysisWindowsCsv` | RecordingID, WindowID, StartSec, EndSec |
| `windowPairsCsv` | RecordingID, BaselineWindowID, ComparisonWindowID |

No baseline is inferred from condition names or row order. Recording pairs must resolve to distinct recordings from the same mouse. Windows use half-open physical intervals [start,end); events crossing a boundary contribute their overlapping duration, while onset counts use the onset timestamp. With no window CSV, whole-recording metrics are exported.

Differences and relative changes are exported with both source values and status. Relative percent change is 100 × (comparison-baseline)/baseline. A zero baseline does not define a ratio and does not receive a pseudocount. A positive baseline followed by zero is -100%.

Puff-aligned traces use the pre-onset mean from -30 seconds up to, but excluding, onset. Positive count/area measurements use fractional change; standardized ROI features use additive change. Incomplete baselines remain unavailable. Different sampling rates are aligned in seconds on the highest input sampling rate using frame-held values. The actual sample-time vector is passed to normalization and export; timestamps are never reconstructed from the number of columns. Native recording traces remain available. Summary traces average recordings within mouse before averaging mice. Missing measurements within a recording invalidate that mouse at that time point; padding beyond the end of a shorter recording is tracked separately as absent coverage.

## Migration and remaining scientific limitations

All recordings must be reanalyzed. The statistics loader requires the exact current pipeline contract, saved analysis settings, calibration and tissue support. It checks source TIFF SHA-256 hashes and rejects changed sources, mixed sink/surge sources, old schemas and mismatched settings. Moving an intact recording folder is supported by resolving the recorded source basename in its current folder. No compatibility promise applies to older analysis outputs.

Temporal standardization now divides by temporal SD rather than sqrt(SD), after spatial standardization. Finite constant inputs produce neutral detector values; nonfinite inputs are rejected. Tests establish unit temporal SD on nonconstant synthetic signals and invariance to a positive global gain and offset. This correction changes detector scores and potentially the detected event population. Default thresholds have **not yet been scientifically revalidated**. Spatial/temporal filtering, thresholding and correlation rejection otherwise remain the existing V2 path.

The saved contract is currently `3.0-dev`, detector `existing-v2-sd-1`, measurement `event-footprint-1`, statistics `mouse-strict-2`. These are development identities, not a frozen publication release. Rule changes require contract updates. The current identity is manually maintained; it is not a source-code checksum.

Standardized ROI mean/CV/entropy and derivative descriptors remain exploratory signal features, not oxygen concentration measurements. No new inferential model, ground-truth sensitivity validation, depth reconstruction or correction for motion/illumination drift is claimed. Historical names and low-level helper conventions still require a final consistency audit even though the main loader rejects old analyses.

The new window and burden comparison outputs currently concern sinks. Surge event timing, native morphology and raw fractional amplitude are corrected, but an equivalent surge recording/window composite has not been introduced.

## Reproducible checks

From the checkout root in MATLAB:

```matlab
setupOxygenDynamicsPath;
results = runtests('tests/analysis');
assertSuccess(results);
runRepositoryChecks;
runOxygenPipelineSmokeTest;
addpath('tests/analysis');
runExistingAnalysisIntegration;
```

The integration check first runs the actual master on a synthetic movie. It then injects explicitly known event masks and raw signals into temporary saved outputs to test measurement/export independently of detector sensitivity. It pools two events in one site with a second, zero-event recording and verifies 25%/40% amplitudes, exposure, zero-event trace coverage, paired -100% change and workbook creation. This is a runtime and calculation check, not validation against biological ground truth.
