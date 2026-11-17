# BOI recording input, QC and denominator contract

The optional [reviewed static tissue-support path](BOI_REVIEWED_TISSUE_SUPPORT.md)
adds a source-bound mask declaration before a fresh master run. Automatic
support remains the default. Declared review does not establish scientific
eligibility or dynamic validity.

10 September 2026. Implementation version `boi-recording-input-1` and window
export version `boi-window-exposure-1`. This begins R1, with R0/R5 traceability;
it does not establish acquisition validity, independent detector accuracy or
cohort eligibility. The [reanalysis plan](REANALYSIS_UPDATE_PLAN.md) and
[cohort resolution](BOI_COHORT_RESOLUTION.md) remain authoritative for scope and
scientific holds. Both BOI event signs remain in scope; IOSI is excluded.

## What a researcher can do now

Before running the BOI master, review the intended recording folder and explicit
sampling/calibration in MATLAB:

```matlab
review = reviewBOIRecordingInput(recordingFolder, sampleHz, pixelSizeUm);
```

This uses existing TIFF/input validation and reports readable files separately
from an unsupported acquisition and scientific review. It does not run a detector
or write into the recording. The master performs the same acquisition metadata
compatibility check before detrending/detection. Normal statistics exports now
contain `RecordingInputReview.md`, `RecordingInputQC`, complete input contracts,
frame exposure records and window denominator ingredients. Input review issues
also appear in the existing `StatsAcceptance` table and its GUI preview; a
numerically complete export does not silently become scientific acceptance.

The current detector assumes a contiguous movie at a uniform sample rate. An
absent declaration is an explicit assumption for descriptive use, not evidence
that timing or support is valid. A declaration that contradicts this model is
held before the current temporal pipeline runs. The original movie and metadata
are preserved. No implicit resampling, frame deletion, threshold tuning or
scientific exclusion is introduced.

## Optional source-bound acquisition declarations

The additive extension `source-clock-and-source-review-1` distinguishes
unreliable file clocks from confirmed acquisition sampling and retains
structured source-review issues. Earlier sidecars keep their existing behavior.
An explicitly declared incompatible `FrameTimesSec` is still held even if
uniform sampling is confirmed; corrections require a separate, evidence-based
declaration and run. Never change an earlier master's captured declaration.

For HP data, the user confirmed exactly 1 Hz external triggering and stated
that embedded timestamps are incorrect. The corrected declaration sets
`UniformSamplingConfirmed=true`, records that user evidence, and preserves
file timestamps only as `SourceClockTimesSec` with `known_unreliable` status.
`FrameTimesSec` stays absent. Frame exports retain `DeclaredFrameTimeSec=NaN`,
the exact modeled 1 s intervals, and a separate `SourceClockTimeSec` column.
This removes the incorrect source-clock timing hold without relaxing a
numerical tolerance or treating file metadata as measured image timing.

Source issues are decisions supplied with evidence, not automatic scientific
inferences. `review` permits conditional descriptive execution; `hold_recording`
prevents it and is reported as `held_for_source_review` by the preflight.
Measurement-specific eligibility and cohort inclusion remain separate. The HP
development run retains identity/calibration/label issues as review items and
uses a recording-specific provisional identity, with no biological comparisons.

Place `BOIInputMetadata.json` beside the original TIFF before a **new master
run**, when actual acquisition evidence is available. The only required fields
are `Schema: "boi-acquisition-metadata-1"` and `RawSHA256`, the SHA-256 of the
exact preserved TIFF. The master retains the original JSON text and file hash,
not just normalized values. Do not fill unknown fields from appearance or
archive filenames. Omitting the file remains supported with explicit unknowns.

Example construction, deliberately leaving acquisition facts unknown:

```matlab
metadata = struct('Schema','boi-acquisition-metadata-1', ...
    'RawSHA256',oxygenFileSHA256(originalTiff), ...
    'Modality','BOI', ...
    'IntensityHistory','unknown', ...
    'ExposureEvidence','unknown');
% Inspect metadata before saving it to BOIInputMetadata.json in a new run's
% recording folder. Add measured fields only when evidence supports them.
```

| Optional field | Meaning and checks |
|---|---|
| `Modality` | If declared, must be BOI for this pipeline. Other modalities require their separately justified workflow. |
| `SourceID`, `SelectedSeries`, `SourceAxes` | Original source identity/selection/axes as evidenced. These do not replace animal identity or the decoded TIFF axes (`row,column,frame`). |
| `FrameTimesSec` | One finite strictly increasing source-clock timestamp per image; retained exactly, including its origin. Requires `FrameTimeReference` and `TimingEvidence`. |
| `FrameTimeReference`, `TimingEvidence` | Explain timestamp meaning, image correspondence and supporting evidence. Camera edge time alone does not establish exposure start or approved experimental windows. |
| `SamplingRateEvidence`, `PixelSizeEvidence` | Evidence for the supplied rate and physical scale. Absence remains unknown; numerical calibration consistency is a separate check. |
| `UniformSamplingConfirmed` | Boolean confirmation that the supplied sample rate is uniform, with non-unknown `SamplingRateEvidence`. This confirms the modeled grid; it does not manufacture measured timestamps or absolute exposure alignment. |
| `SourceClockTimesSec`, `SourceClockReference`, `SourceClockEvidence`, `SourceClockStatus` | Optional provenance-only source timestamps: one finite value per image, in original page order, with reference/evidence. Status is `unvalidated` (default) or `known_unreliable`. Values may repeat or move backwards. They never drive detection, interval calculations, or the frame-timing compatibility gate. |
| `ReviewIssues` | Source-bound array of issues with `IssueID`, `Disposition`, `AffectedMeasurements`, `Message`, `Action`, `Evidence`. IDs must be unique and start with `SOURCE-`. Disposition is `review` or `hold_recording`; a hold prevents master/statistics execution. Evidence and actions appear in ordinary QC and readable exports. |
| `CameraExposureSec`, `ExposureEvidence` | Positive scalar or one positive duration per image, in seconds. Exposure is retained separately and never copied from the frame interval. |
| `FrameValid` | One Boolean per image. All-false or partly excluded movies are held by the current contiguous-time pipeline; no frames are removed or renumbered. |
| `IntensityHistory`, `MotionCorrectionHistory` | Known preparation and processing before the preserved TIFF. Unknown history stays unknown; a preserved input is not proof of camera-raw intensity. |
| `Substrate`, `TimeSinceApplicationSec` | Recorded substrate identity and nonnegative seconds since application, if known. |
| `EvidenceOrigin`, `RecordedUTC` | Origin/actor and declared recording time of the evidence. These are retained source declarations, not invented by the software. |

Unknown text is represented as `unknown`; omitted/empty numeric arrays remain
unknown. In exported MATLAB tables, unknown numbers are NaN; in JSON they are
null. Unknown fields and misspelled keys are rejected rather than silently
ignored. Measured timestamp intervals must agree with the supplied uniform
sample rate within a 1 µs numerical consistency tolerance after subtracting the
first timestamp. This tolerance tests compatibility with the declared exact
uniform model; it is not a physiological accuracy target or permission to round
measured acquisition jitter. Nonuniform timestamps and excluded frames require
focused method assessment before this temporal pipeline can use them.

The model clock still starts at the first image interval, zero seconds, and its
last interval ends at `NFrames / SampleHz`. Retained source timestamps do not
implicitly align this clock to stimulation or acquisition events. Camera
exposure is not used as the denominator duration: the current summary is an
interval-weighted estimate of observable tissue-time. Its physiological validity
still requires R1 review.

## Provenance and reruns

New masters save `AnalysisInfo.BOIAcquisitionMetadata` and `FrameSize` alongside
source hashes, effective settings and native tissue support. Statistics reads
that saved snapshot; it never applies a live declaration retrospectively.
Changing/removing a captured file, or adding one to a new master that recorded
`not_supplied`, triggers an actionable rerun requirement. Preserve the prior run
and capture the intended declarations in a separate run.

For older compatible outputs without this field, the contract explicitly records
`not_recorded_at_master`. Only decoded image dimensions may be recovered from
the already checksum-verified TIFF; exposure, timing and processing history are
not reconstructed from a newer file. The preflight report describes current
files; the statistics contract describes the historical selected master. These
are intentionally different records. Source and acquisition metadata snapshots
must agree between selected sink and surge outputs.

`RecordingInputContracts.json` and `DataOutput.mat` retain portable recording
IDs, source hashes, declared/original metadata, sampled timing model, physical
scale and the full saved sink/surge tissue-pixel lists. The JSON may include
private source declarations: it is a local research export, not an automatically
public metadata package. Existing source-to-path mappings and curation records
remain in their original outputs.

## Denominators and boundary counts

`RecordingFrameExposure` contains one row per image with modeled interval start,
end and width; declared source-clock time if available; camera exposure if
available; declared frame validity (0/1/NaN, with NaN meaning unknown); an explicit
`ModeledFrameIncluded` flag; and static analyzed area for each sign. Unknown
validity is never labelled as a true declaration merely because the current
model includes every frame.
The analyzed mask is the saved intensity-derived mask by default, or a
source-bound reviewed static mask supplied before a fresh master. The appropriate
sink border is removed. Support is checked against image dimensions, unique one-based
pixel indices, pixel size and saved area. This establishes arithmetic
consistency, not a reviewed dynamic tissue mask.

`WindowFrameIngredients` contains one row for each image interval that overlaps
a selected sink-analysis window. `WindowOverlapSec` clips the interval at window
boundaries. Overlapping native sink masks count once, intersected with the saved
tissue support. It exports:

- `OccupiedArea_um2` and `AnalyzedArea_um2`;
- `CoveredAreaTime_um2_sec = OccupiedArea_um2 * WindowOverlapSec`;
- `AnalyzedTissueTime_um2_sec = AnalyzedArea_um2 * WindowOverlapSec`;
- recording/window/frame IDs and `OccupancyStatus`.

The recording-window table exposes both sums, the denominator in mm²·min,
timing/exposure assumptions and availability status. Their ratio reproduces
`MeanOccupiedTissueFraction`; it does not reproduce legacy `Burden_Occupancy`,
which is event-time density. These new audit fields supplement the existing
formulas and separate trace-refined event intervals from native occupied masks.

`EventOnsets` retains the existing half-open-window counting rule.
`AcquisitionStartEvents` counts events overlapping the window whose **saved
(refined for sinks) start time** is zero. `AcquisitionStartOnsetsCounted` shows
how many of those enter the current onset numerator. `OnsetsAfterAcquisitionStart`
is the remaining onset count, exported as a diagnostic rather than used as a
replacement primary rate. `OngoingAtWindowStart` counts events that started
before the window and end after its start; they contribute active time, not new
onsets. Native acquisition-boundary contact and physiological independence are
still separate questions. No new event exclusion or censoring policy is adopted.

## Availability and usability rules

A successfully analyzed, event-free recording with positive analyzed tissue-time
can have zero detected coverage. Missing native support with event rows is
unavailable, not zero. Zero or invalid tissue denominator makes the normalized
measurement unavailable. A failed/unprocessed recording cannot enter this
window helper as a valid zero. Malformed/truncated saved masks and inconsistent
mask areas fail explicit invariants instead of producing a plausible fraction.
Unavailable occupancy does not erase separately available descriptive event
counts or amplitudes.

Frame CSV/MAT exports are authoritative if row counts exceed Excel worksheet
capacity; the writer omits the oversized frame worksheet instead of truncating
it. Export size grows with recording
length and number of windows. Batch storage, total worker memory and manual
review budgets remain open feasibility decisions. A full cohort rerun is not
needed to test these additive input/export checks.

## Scope of this implementation

Normal GUI/batch statistics share the same calculations and review exports.
The read-only import function provides preflight access in MATLAB; complete GUI
presentation of acquisition evidence, dynamic tissue validity and independent
researcher walkthroughs remain R5 work. The existing detector/measurement
contract is unchanged; new input and window audit version IDs identify this
additive schema and validation behavior. Dictionary version 0.2.0-draft records
the new exports. Older numerical fields on consistent inputs must remain the
same, while inconsistent inputs cannot masquerade as valid observations.

All cohort holds remain: unresolved spatial calibration/labels, frame/trial
alignment, gas switch times, source integrity, preparation/control choices and
calibration validity are not solved by this contract. Biological variability
must still be challenged across animals and acquisition strata. No morphology,
expected effect or historical count is used as an acceptance criterion here.
