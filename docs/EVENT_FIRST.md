# Opt-in event-first BLI prototype

`legacy` remains the default. `eventFirst-0.1.0` is an exploratory detector and a separate measurement schema, **not a validated improvement in biological sensitivity or specificity**. The immutable historical reference is commit `8cf3f036b41e16b2c472bcee7e5cfaeab41433eb`. No legacy z-score, detection threshold, timing calculation, quantifier, or output table is changed.

## Run

From this checkout in MATLAB R2025a or newer with Image Processing Toolbox:

```matlab
setupOxygenDynamicsPath;
addpath('tests/eventFirst');
[R,C] = makeEventFirstFixture();
X = runOxygenEventFirst(R,C);
saveOxygenEventFirst(X,'my-results');

% Batch of explicit recordings: retains successful zero recordings and failures.
Report = runOxygenEventFirstBatch({R},C,'my-batch');

% Existing TIFF wrapper, with CSV metadata:
OxygenDynamics_Wrapper(struct('DetectorMode','eventFirst', ...
    'inputCsv','my-recordings.csv','analysisMode','All analysis'));
% 'compare' also runs legacy independently and exports correspondence.
```

Configuration is exposed in `OxygenDynamics_Config.m`. The alternative wrapper branch skips legacy behavior and amyloid processing; it does not supply quantitative IOS, vascular, amyloid, or depth outputs. TIFF discovery uses the existing loader, without calling the legacy master for initialization. `EventFirstMetadata` can supply a tissue mask, valid registration support and provenance; for different masks/windows per recording, use the explicit standalone batch API. Existing wrapper preflight still requires positive scalar pixel calibration. Pixel-only and anisotropic recordings use the standalone API.

Outputs live under `OxygenDetectors_Output/eventFirst/<run-id>` for the wrapper, or `<root>/eventFirst/<run-id>` for standalone export. Existing runs are never overwritten. A path-safe supplied run ID must contain letters, digits, `_` or `-`. Legacy keeps its established separate folders. `runOxygenDynamicsStats` explicitly rejects `DetectorMode='eventFirst'`; use the new recording/window CSVs or MAT schema. Legacy statistics never select these files as legacy tables.

## Input contract

`Recording` is a scalar structure. Required: `RecordingID`, `MouseID`, `SourceIdentity`, `SignalProvenance`, `PixelSizeUm` (`[Y X]`), `NFrames`, numeric full-frame `Intensity`, `AxisOrder="YXT"`, logical `ValidMask` (YX or YXT), and `fs` or uniform `FrameTimestampsSec`. Supply `[NaN NaN]` for unknown calibration and choose `SpatialScalesUm=0`, `MinAreaUm2=0`; physical metrics remain NaN. No guessed pixel calibration or epsilon denominator is used.

Optional: `TissueMask`, `Condition`, `Genotype`, `Promoter`, `Windows`, `Contrasts`, `SourceScaling`, `MotionProvenance`, `ExclusionReasons`, `SaturationLevel`, `DarkOffset` plus `DarkOffsetProvenance`, `DenoisedIntensity` plus `DenoisedProvenance`. Source values are converted to double, never min–max remapped. Camera offset is unknown unless explicitly calibrated. Saturation is excluded only when a threshold is supplied; nonfinite values are always excluded. No new motion correction is applied.

The automatic tissue proposal is **temporal median > 0**, intersected with valid support. It is intentionally a conservative review proposal, not anatomical ground truth. Positive background can remain; camera offsets can affect it. Supply a reviewed common tissue/registration mask for scientific comparisons. An all-true TIFF registration mask is explicitly reported as unverified.

Each frame i represents `[(i-1)/fs,i/fs)` relative to the first exposure. Absolute first timestamp is retained separately. Irregular timestamps, skipped timestamps, variable/noncontiguous exposure intervals and non-YXT inputs are rejected. Represent known excluded exposures on a contiguous time grid using false validity; they are unknown, not inactive. There is no crop, temporal chunk processing or gap bridging in this release. Full-frame pixel indices are MATLAB column-major YX indices. Missing exposures split identity and flag neighboring events.

`loadOxygenEventFirstNWB` is a narrow local HDF5 adapter. It requires explicit `Layout.MATLABAxisOrder`; dimensions never determine the time axis by size. Only ImageSeries-like 3D data with `starting_time/rate` are supported. A temporal prefix is allowed and recorded; spatial cropping is not. SHA256 is computed and checked if supplied. Attributes and original dimensions are retained; unit/conversion attributes are not treated as evidence of camera-count calibration. No downloads occur in tests or import.

## Algorithm and definitions

Defaults: 60-second centered moving median, three iterations excluding both signs above 2.5 residual SD with 2-second recovery padding; seed 5 SD, grow 2.5 SD; minimum 2 seconds; minimum area zero (at least one pixel); Gaussian spatial sigma scales `[0,5]` µm. Physical thresholds are rounded upward to frame/pixel counts. Gaussian filtering divides by filtered valid support; each scale has its own residual MAD noise estimate after filtering. No temporal filter or common-mode subtraction is applied. Scores are residual/SD, not probabilities. Max absolute score wins across scales; ties prefer the earlier scale. Signs cannot own the same voxel, and scales do not duplicate events. Multiple-scale search must be calibrated in a future empirical benchmark.

Noise is 1.4826 times the median absolute residual deviation in candidate-excluded intervals. Zero, near-zero or insufficient estimates are masked from scoring and counted in QC. Noiseless fixtures test exact quantification with explicitly constructed masks rather than pretending a zero noise estimate defines an SD score. Optional `intensityBinnedMAD` pools empirical noise SD within five intensity bins and requires at least 100 estimable pixels. Mean–variance correlation is exported. Noise autocorrelation, denoising and threshold selection still require empirical validation; this does not assume a calibrated Poisson or EMCCD model.

26-connected growth components must contain a seed and satisfy duration/area support. More than one disconnected seed component or more than one spatial part on any frame flags ambiguous touching/splitting/merging support. Such a component is retained as one **ambiguous candidate**, not asserted to be one biological event. This deliberately does not solve all touching events. Recovery without growth support creates a new event. No gaps gain occupied pixels. Boundary and adjacent-unknown flags are retained; no upper-duration or circularity rejection is imposed.

The slow baseline is distinct from the immediate pre-event quantification baseline and from experimental control windows. Candidate-exclusion fraction, invalid noise counts and noise–intensity behavior are retained. Excessive excluded fraction or a recording shorter than the baseline window flags baseline adequacy. Sustained/high-occupancy responses can remain unidentified even without a flag; inspect global traces and the baseline-window sweep rather than relying solely on this diagnostic.

Each event's fixed union footprint supplies both its preserved-intensity trace and its baseline. Later events at a site cannot enlarge that footprint. A trace sample requires every footprint pixel to be valid. The default baseline uses up to 10 seconds before onset, excluding any detected activity on its footprint, with at least 3 clean frames and 50% coverage. There is no post-event fallback. B0 must be positive. Missing baselines retain detection/intensity and return missing relative metrics with a reason. Partial invalidity during an event makes the fixed-footprint amplitude/AUC unavailable rather than silently changing support.

For valid B0, signed relative BLI is `(B-B0)/B0`; peak is `max(sign*relativeBLI)` over active frames; mean and signed AUC use active exposures only. Fractions are canonical. Negative mean in the candidate's intended direction gets QC; no unconditional absolute value is taken. Peak extrema are noise sensitive; retain mean/AUC. These quantities are not pO2, oxygen consumption, hypoxic volume, or calibrated oxygen-deficit integrals. A spatially integrated signal burden is deliberately not claimed or calculated.

Sites use complete-link footprint intersection-over-union >=0.25: an event must satisfy overlap with **every** existing member, preventing single-link chains. Compatibility with multiple sites leaves SiteID 0 and an ambiguity flag. Site IDs are recording-local, and assignment never edits geometry or quantification. Site recurrence is events per valid observable recording minute. A representative-footprint spatial index prunes impossible comparisons without changing the complete-link rule.

Windows (`WindowID,StartSec,EndSec`) are half-open and may have fractional frame boundaries. Activity/exposure is clipped by interval intersection; onsets are counted at the first exposure start. Denominators integrate valid observable pixel area over time. Exported quantities include onsets, active event-seconds, occupied pixel-seconds, valid pixel-seconds and calibrated mm²-seconds. Occupancy is a sign-specific union divided by valid exposure. Onset rate is `60*onsets/exposure_mm2_sec`; concurrent density is `event_seconds/exposure_mm2_sec`. No-exposure ratios are NaN, valid zero-event rates are zero. Global preserved BLI means are time-weighted frame means, distinct from area-time weighted occupancy.

Explicit contrasts (`BaselineWindowID,ComparisonWindowID`) calculate difference and, when defined, ratio/percent change for onset rate, occupancy and global preserved BLI. Zero baseline preserves absolute difference and leaves relative change missing. Absent metadata means no experimental contrast is inferred.

## Saved schema and provenance

`EventFirstResult.mat` (`oxygen-event-first/1`) is authoritative: RecordingQC, Events, EventFrameMasks, Sites, EventTraces, RecordingWindowMetrics, BaselineContrasts, TimeSeries, TissueMask, ValidMask, ScoreQC, optional diagnostics, and RunManifest. Native per-event/frame uint32 pixel lists are lossless. Portable CSVs include one-pixel-per-event/frame geometry. Fixed-footprint traces and per-sample baseline frame references remain in MAT. IDs include recording, analysis run, sign and local event index. Detector/version/configuration and source metadata are retained. Effective quantitative input, valid masks, and all MATLAB source files have SHA256 content identities, including dirty/untracked implementation files. Never concatenate detectors without their origin columns.

Comparison mode captures existing native legacy lists only when requested. This adds an opt-in return field path in `runLegacyAnalysisScript`; scientific legacy code is unchanged. Its adapter restores the known sink crop and clips native site/frame lists to existing legacy event bounds. It does not reconstruct TIFFs. Original legacy event tables remain alongside the comparison envelope. Interval conversion exists only in the envelope. Correspondence uses descending spatiotemporal IoU greedy one-to-one assignment, matching signs with deterministic row-order ties. It is not maximum-weight assignment or an accuracy judgment. Legacy and alternative eligibility rules differ; resulting comparisons are descriptive, not calibrated comparisons at common false-positive rates.

## Validation and benchmark

```matlab
addpath('tests/eventFirst');
Report=testOxygenEventFirst(); assert(all(Report.Passed));
addpath('examples/eventFirst');
runEventFirstExamples('fresh-output-folder');
% Optional checksummed local public example; first 120 full frames only:
runEventFirstExamples('another-fresh-folder','/path/to/dandi-awake.nwb');
runRepositoryChecks();
runOxygenPipelineSmokeTest();
% Independent native legacy/eventFirst comparison on a controlled TIFF:
runEventFirstLegacyComparison('fresh-comparison-folder');
```

The frozen synthetic grid varies baseline windows `[20,30,45]` sec and seeds `[4,5,6]` SD. Independent injection schedules supply known support/amplitude; additive noise is generated independently, not multiplied with the event. A separate null mouse/seed is included. Synthetic truth is not manual biological annotation. `runOxygenDetectionBenchmark` accepts local manifest entries (`Recording,Partition,Annotation`) and checks that all sessions of a mouse share a partition. It performs no training or automatic threshold selection. Callers must freeze configurations on development data before held-out evaluation.

Annotations provide `Events`, `EventFrameMasks`, and `Provenance`; optional `UncertainEventIDs` remove uncertain truth and all overlapping detections from evaluation. Run each rater separately to assess disagreement. Matching sensitivity is reported at 3D IoU `[0.1,0.25,0.5]`, with precision/recall, false detections per valid mm²-minute, IoU, onset/offset errors, split/merge candidate counts and amplitude/area/duration errors when reference measurements exist. Empty truth/detection denominators give NaN precision/recall, not invented perfect scores. No annotated biological dataset was supplied. Cross-detector matching is not ground truth.

Remaining limits: full movies are held in memory, centered baselines need sensitivity analysis, touching events can remain ambiguous, automatic tissue/registration support needs review, no common-mode-adjusted option, no variable exposure/chunk reader/gap linking, no calibrated spatial signal integral, no hierarchical biological inference, and no empirical false-positive calibration or held-out biological superiority result. The public prefix is a software/provenance check only. Use reviewed full sessions and blinded mouse-separated annotations for scientific validation.
