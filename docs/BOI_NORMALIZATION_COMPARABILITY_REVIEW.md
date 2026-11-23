# Normalization, identity and comparability review

**Delivery update, 13 November 2026.** Revision-31 signed-selection/flag handling
is [implemented and verified locally](BOI_REVISION31_DELIVERY.md) on the approved
synthetic inputs. Formula, normalization, original references and results remain
unchanged. This does not certify acquisition comparability of real recordings;
the source/specification qualifications and historical hold statements below
retain their original scope. No individual examples or real-data inspection.

**Revision-31 contract note, 13 November 2026.** Finite signed sink contributions
are included when the other required ingredients are available. Negative values
are flagged and subtract in the unchanged complete sum; a finite normalized total
may be positive, zero or negative. Keep the product, area/time factors, optical
reference definition, original results and comparison qualifications below.
There is no absolute value, clipping, positive-only sum or new oxygen calibration.
Future outputs need their actual signed-selection policy/version; old saved
outputs are not relabelled. Implementation and numerical verification remain
explicitly held. No further individual pocket/trace/ROI/video investigations.

12 November 2026. **Source/specification review only. Implementation, numerical
verification, dataset inspection and workbook generation remain held.**
The burden formula, numerical normalization and original results are unchanged.
This report covers the compact specification's scientific fields and the metric
families in the existing `NormalizationGuide`; it does not certify every
optional calculation or establish comparability of the 17 actual recordings.

## Main finding

A value being normalized is not sufficient to make it comparable across mice,
recordings or sessions. Conversely, an event duration in seconds or an area
in square micrometres can be compared without dividing by recording duration
or tissue area. The export needs both **normalization status** and
**comparison scope/reasons**, per metric, with actual exposure and measurement
provenance. A single normalized/comparable Boolean for a whole sheet or row
would be misleading.

The existing export already calls
[NormalizationGuide](../helpers/writeStatsNormalizationGuideSheet.m) and
[MetricDefinitions](../helpers/writeStatsMetricDefinitionsSheet.m), via
[exportStatsResults](../helpers/exportStatsResults.m). Reuse these definitions
and their source mappings; refine version-specific guidance and expose it in
the compact workbook. No new calculation framework is needed for this review.

## Formula and units retained

Let A be the saved analyzed area in µm², T the saved duration in seconds, n an
event count, a_i the drop-positive amplitude in percent, s_i mean event area in
µm², d_i event duration in seconds, and U(t) the native-mask occupied union
inside the selected eligible tissue.

| Quantity | Existing definition | Scaling actually supplied |
| --- | --- | --- |
| Recording area | A_mm2 = A / 1e6 | µm² to mm² |
| Recording duration | T_min = T / 60 | Seconds to minutes |
| Primary normalized burden | sum(a_i * s_i * d_i) / (A_mm2 * T_min) | Area and recording-time normalization; same expression as sum(...) * 1e6/A * 60/T |
| Recording onset rate | n / (A_mm2 * T_min) | Events/mm²/min; includes the saved acquisition-boundary onset policy |
| Site recurrence rate | n_site / T_min | Events/site/min; time-normalized, not recording-area normalized |
| Mean concurrent density | sum(d_i) / (A_mm2 * T) | Average simultaneous events/mm²; T here remains seconds |
| Instantaneous concurrent density | count(t) / A_mm2 | Events/mm² sampled at each frame; not an onset rate |
| Mean occupied fraction | integral U(t) dt / (A * T) | Dimensionless time-averaged tissue fraction |
| Instantaneous occupied fraction | U(t) / A | Dimensionless fraction for a frame; no further division by time |

These expressions are present in
[recording burden aggregation](../helpers/aggregateOxygenRecordingBurden.m),
[window metrics](../helpers/createOxygenAnalysisWindows.m),
[site rates](../helpers/createAdditionalOxygenSinkMetrics.m) and
[native union series](../helpers/computeOngoingRegionSeries.m). Reading their
expressions is not a fresh numerical replay or validation of the actual A/T
values, masks, source identities or acquisition calibration.

The primary burden's units remain the existing optical composite per analyzed
mm² per minute: percent·µm²·seconds/(mm²·minutes). It is not dimensionless,
a tissue-occupancy percentage or calibrated oxygen deficit. Keep the amplitude
percent convention; a stored 6.94 is not an Excel fraction of 6.94 requiring a
second multiplication by 100. No second area/time division is authorized.

## Comparison labels

Use the following field-level vocabulary. These are specification labels,
not newly evaluated labels on any existing workbook.

- **Conditional cross-recording comparison:** the definition has suitable
  units/scaling, provided the source, exposure, acquisition, support, reference,
  measurement and review conditions are appropriate and documented.
- **Matched exposure only:** compare totals/counts only for compatible tissue
  exposure and observation windows, or use the existing normalized counterpart.
- **Within-recording reference only:** local standardization, ranks or raw-level
  comparisons do not establish an absolute cross-animal response scale.
- **Not directly comparable:** the proposed cross-recording use changes the
  quantity or leaves known exposure/scale differences unaccounted for.
- **Not assessed / unknown:** required metadata or independent current evidence
  is absent. Do not call this comparable because the cell is finite.
- **Not applicable:** no accepted metric exists for that case, e.g. surge
  hypoxic composite under the current contract.

Normalization types are separately recorded: none, physical-unit calibration,
local optical-reference ratio, area, time, area plus time, time average,
within-recording z standardization, within-recording rank, or descriptive flag.

## Metric-by-metric comparison catalogue

### Event measurements and reference information

| Metric family | Normalization/calibration | Comparison scope and limitation |
| --- | --- | --- |
| Mean event area, filled area (µm²); event diameter/perimeter (µm) | Pixel-size calibration; area uses pixel size squared, length uses pixel size | Conditional cross-recording event-size comparison. Do not divide intrinsic event size by recording A or T. Match mask/shape definitions and resolution context. Native-event, full-reviewed-event, site-mean and filled-area quantities are not interchangeable. Peak area stays deferred. |
| Event area / analyzed tissue area | Area ratio/fraction | A different phenotype: relative fraction of the analyzed field. Not a replacement for intrinsic event size; the same pocket has a different fraction in different fields. Compare that fraction only for the intended sampling/support context. |
| Event duration (s) | Frame count converted using saved fs; current inclusive duration is (last-first+1)/fs | Conditional cross-recording duration comparison with matching timing definition, sampling and censoring treatment. No division by recording length. Boundary/unresolved windows are observed/reported intervals, not guaranteed full episodes. Older saved durations retain their own version. |
| Local peak drop amplitude (fraction or %) | Relative to each event's 20-second local mean; fraction-to-percent conversion explicit | Conditional relative optical response comparison. Requires known sign, footprint, raw/corrected source, local/pre-episode/post-event/review reference type, window length and quality. Not absolute pO2 or oxygen loss. Local, site-union and old processed amplitudes must not be pooled as the same measurement. |
| Post-event reference amplitude | Relative optical ratio, but reference follows the event | A post-event recovery-reference contrast, not an observed pre-decline level. Preserve its value and flag, but restrict comparisons with ordinary pre-event drop amplitudes and expose its contribution count in recording burden. No automatic exclusion or correction is adopted. |
| Raw minimum or reference mean (a.u.) | No cross-session photometric calibration supplied by the ratio itself | Not directly comparable across mice/camera sessions as absolute oxygen status. Retain for provenance/within-source interpretation. |
| Above first-20-second recording reference | Descriptive within-recording relation, measured on the same footprint | No absolute cross-mouse oxygen/severity meaning. Proportions of such flags would be a separate descriptive analysis requiring common reference/override policy and ascertainment; the flag is not a burden weight. |
| Circularity; size modulation | Dimensionless descriptors; size modulation is (end area-start area)/start area | Conditional descriptor comparison under the same segmentation, component aggregation and temporal definitions; dimensionless does not mean method-independent. Independent arithmetic coverage is not established for every descriptor. |
| Centroid, start/end frames, relative timestamps | Pixels/frames are source coordinates; seconds use saved clock | Source-local positions/times. Same site number or pixel location does not identify the same anatomical site in another session. Cross-session spatial matching requires explicit registration evidence, not normalization. |
| Signed optical AUC (fraction·s) and mean signed change | Local-reference normalization; AUC integrates with dt | Conditional event-level relative-signal comparison under the same reference/timing rules. Not the amplitude×area×duration burden, not area-normalized, and not absolute oxygen deficit. Dividing an AUC by duration creates a different average-response quantity. |

A constant multiplicative gain cancels algebraically from (B-I_min)/B. An
additive offset does not: for I'=gI+c the ratio is g(B-I_min)/(gB+c).
Time-varying gain, noise/extremum sampling, differing exposure and a changing
reference are not repaired merely by reporting percent. This is a limitation
of the defined ratio, not a demonstrated defect in these recordings. The
[original Science article](https://pubmed.ncbi.nlm.nih.gov/38547288/) reports
relative BLI responses and separate oxygen-calibration experiments; the current
saved event ratio does not itself apply a calibrated oxygen-pressure mapping.

### Counts, frequency, coverage and time series

| Metric family | Normalization/calibration | Comparison scope and limitation |
| --- | --- | --- |
| Total detections or active sites per recording | None | Not directly comparable as frequency when A/T differ. Totals describe each analyzed recording. Active-site counts also depend on time available to observe recurrence; dividing unique-site count by time is not automatically an event rate. |
| Detections / mm² per recording | Area only | Matched observation duration/window required for direct count comparison. This is **per recording**, not per session unless SessionID and session membership are explicitly defined. Prefer existing onset rate when A/T differ. |
| Recording event onsets / mm² / min | Area and time | Primary conditional comparison of descriptive onset rate across recordings. Same admission/detection/window policy required; frame-1 detections do not prove biological onset at time zero. |
| Site events / min | Time only | Conditional recurrence comparison for equivalent site definitions. Not events/mm²/min and not spatially matched recurrence across sessions unless sites are registered. |
| Concurrent count(t) | None, frame sample | Not directly comparable across different analyzed areas; use count/mm². Count sampled each second is not an onset count divided by seconds. |
| Concurrent count(t) / mm²; mean concurrent density | Area; mean uses time averaging | Conditional concurrent-density comparison. Do not add another factor of fs, 60 or 1/T to a pointwise value. Align time in seconds and biological windows where appropriate. |
| Occupied native union area U(t) in µm² | Physical area only | Not directly comparable as tissue coverage when A differs; use fraction U(t)/A. Do not add overlapping event areas instead of using the saved union. |
| Instantaneous occupied fraction; mean occupied fraction | Area ratio; mean additionally time-averaged | Primary conditional tissue-coverage comparison with sign-specific matched mask/support and valid clock. A fraction can be displayed as percent once. It is not count-based event-time density. |
| Raster rows or frame/event flags | Boolean/source-local | Descriptive support/quality or timing labels, not exposure-normalized biological magnitudes. Frame rows and pixels are not independent mice. |

### Burden variants and event contributions

| Metric family | Normalization/calibration | Comparison scope and limitation |
| --- | --- | --- |
| Raw recording HypoxicBurden / Burden_AmplitudeComposite | Local-reference amplitude but no recording A/T normalization | Matched recording exposure only; not the primary comparison across unequal A/T. Preserve as raw provenance and pair with the existing normalized burden. |
| HypoxicBurden_per_mm2 | Area only | Matched recording durations/windows required. |
| HypoxicBurden_per_sec / per_min | Recording time only | Matched analyzed-area exposure required. Per-second and per-minute values differ only by the explicit time-unit factor. |
| HypoxicBurden_per_mm2_per_sec / per_min | Recording area plus time | Primary **conditional** cross-recording normalized composite. Same numerator/support, amplitude/reference policy, full retained contribution availability and review basis are required. Per-minute is not a percent or absolute oxygen burden. |
| Raw single-event contribution a_i*s_i*d_i | Relative amplitude and physical event geometry/time | Conditional comparison of this defined event composite under matched event measurement definitions. No recording-exposure division is needed to describe one event's own size/depth/duration product. |
| Per-event contribution divided by recording area/time | Area and/or recording time | Decomposition of a recording-normalized rate. Not an intrinsic event-severity score: the same event gets a different number in a different-sized/length recording. Do not prefer this merely because its name says normalized. |
| Burden_Occupancy | Event-seconds/mm²/min | Conditional concurrent event-time density, **not occupied tissue fraction**. With consistent windows it is the same quantity as mean concurrent events/mm² expressed with the 60-second/minute factor. Avoid treating the two as independent readouts or applying that factor twice. |
| Rank-amplitude burden | Within-recording amplitude ranks plus recording area/time scaling | **Within-recording sensitivity descriptor only** for amplitude magnitude. Exposure scaling does not make ranks an absolute cross-mouse amplitude/burden scale. |
| BurdenOverTime; BurdenPerMm2OverTime | Sum(active event contribution / event duration), optionally per mm² | A composite signal per time point, not yet a per-minute recording total. Integrate with saved dt, then apply the defined recording normalization when appropriate. Gaps from missing active contributions cannot be ignored to claim complete burden. No new integration is performed here. |
| Surge hypoxic composite | Not defined in current accepted contract | Not applicable; do not invent zero, a sign-flipped sink formula or an unapproved surge normalization. |

### Averages, contrasts and secondary legacy outputs

| Metric family | Normalization/calibration | Comparison scope and limitation |
| --- | --- | --- |
| Site mean amplitude; recording event means/medians | Inherit the underlying field's scale; finite-contributor means are not normalization of missingness | State event/site/recording observation unit, eligible subset and contributing/total counts. Site means, pooled event means and mouse means use different weights. A finite event mean can coexist with unavailable complete burden; it must not be described as a partial burden. |
| Mouse/group mean and SEM | Existing equal recording means within mouse/group, then equal valid mouse means; SEM requires >1 valid mouse | Preserve existing aggregation. Not exposure pooling, not session-specific aggregation and not independent event-level replication. Show valid/total mice and recordings per metric. |
| Difference, fold/percent change from a paired baseline recording/window | Relative comparison to an explicit paired value; source units/exposure remain inherited | Same mouse/pair identity and compatible definitions required. A percent change of an unnormalized total does not correct unequal A/T. Zero/nonpositive denominator remains undefined according to existing source rules; no pseudocount. |
| Spatial/temporal detector z scores | Frame/spatial and within-pixel temporal standardization | **Not an absolute response-amplitude scale across recordings.** Variance standardization changes the quantity. Do not use as interchangeable with raw-reference event amplitude or calibrated oxygen. |
| Global-mean/frame-mean delta stacks from normalizeToDfof | Relative to global stack or per-frame spatial mean | Distinct from per-event predecline reference and current burden input. Not interchangeable percent amplitudes; frame normalization can remove shared regional variation. Invalid-data fills belong to that legacy processing path and are not measured signal. |
| ROI mean/CV/entropy and derivative features | Depends on source trace normalization and feature definition | Exploratory signal features; cross-mouse physiological comparability not established by the reviewed coverage. Mark assessment absent rather than certify them with a normalized label. |
| Event-aligned snippets and behavior-binned traces | Inherit source scale, time alignment/reference and binning | Comparable only for compatible source traces, alignment, reference and acquisition/behavior definitions. A within-recording behavior percentile is not an absolute behavioral level matched across mice. No stimulation inference or new behavior analysis is introduced. |

## Gaps and contradictions found

1. **Normalization and comparability were conflated.** Add separate per-field
   labels and conditional comparison reasons. Physical event measures remain
   in µm/µm²/s; no extra division is adopted. Every numeric export field must
   have a definition or be explicitly marked identifier/flag/not assessed.
2. **Session identity was absent.** Existing metadata/registry carry recording,
   mouse and condition, not an explicit SessionID. Add SessionID and mapping
   status when explicitly supplied/saved; otherwise not recorded. BatchID,
   Experiment, recording filename and analysis run are not silently sessions.
   Namespace Mouse by an explicit study/dataset identity when necessary; do
   not invent subjects or use batch membership to split the same mouse.
3. **A recording count was labelled per session.** Revision 4 says
   count/mm²/session in a one-recording row. Correct the specification to
   count/mm²/recording; no session pooling is authorized. A new run/version of
   one recording is not a new biological replicate. The four-part event key
   is scoped to its source analysis; retain that context across workbook merges.
4. **Spatial/temporal support is not uniformly interchangeable.** The event
   finalizer averages full native mask area, while occupancy explicitly clips
   the mask union to eligible tissue. Burden denominator is that analyzed
   tissue area. This is a possible numerator/denominator support mismatch,
   not a measured error in these recordings. Expose source support/basis and
   mark unknown relation when not saved; do not silently clip or recalculate
   event area. Native area also does not prove area during extended timing.
5. **Recording and window composites can select different area inputs.**
   createHypoxicBurdenMetrics can take matched EventSpecificMetrics.Area_um;
   createOxygenAnalysisWindows multiplies EventArea_um2 directly. If they differ,
   normalization cannot make the composites identical. This is a static
   source-selection difference; no actual discrepancy is numerically established
   here. Preserve the primary saved burden authority and require explicit
   ingredient equivalence before treating window composite as the same output.
6. **Reference modes were mixed under one amplitude/burden label.** Keep
   pre-event, post-event, pre-episode and explicit reviewed references visible.
   A post-event contrast is not observed predecline amplitude. Expose counts/
   proportions of reference types and quality among retained contributions;
   do not automatically remove flagged events or introduce a partial sum.
7. **Comparison hierarchy/weighting needed its own contract.** The current
   mouse summarizer averages recording values within mouse/condition, then
   mice equally; it does not pool area-time exposure or group SessionID. Keep
   that behavior explicit. Multiple pockets, recordings or source versions
   from a mouse do not create extra mice. Same SiteID across sessions is not
   evidence of the same registered anatomical site. Independent replication
   depends on design, not number of measured rows.
   [Lazic et al., PLOS Biology](https://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.2005282)
8. **Review and completeness flags cannot certify comparisons.** No manual
   review, partially reviewed, rejected, missing contribution, short reference
   and numerically complete are different statuses. Same declared calculation
   policy can still produce differing reference/quality/review mixes. Keep
   automatic and review-applied bases distinct and show contributor counts.
9. **The existing guide has version-specific ambiguities.** It still suggests
   a site/event morphology distinction that predates current native event
   fields and says surge time-unit naming needs review despite the current
   per-minute formula. Its advice to compare individual events after dividing
   by recording FOV needs the context-dependence qualification above. Preserve
   the existing files; plan a documentation/source-version crosswalk, not a
   covert calculation change.

## Required comparability information in the future export

In **Definitions**, add NormalizationStatus, AreaNormalization, TimeNormalization,
SignalNormalization, ComparisonScope, RequiredMetadata, ComparisonRestrictions,
NormalizedCounterpart, observation/aggregation unit and evidence status. This
extends the existing guide, not a new numerical method.

In recording/source metadata, retain A, T, their units and sources, event sign,
analyzed support/profile and mask provenance when available, native-versus-
measurement area/time basis, PixelSize, sampling rate/frame timing and exposure
status, measurement/detector/reference/normalization policy, analysis/export
identity, review selection/coverage and SessionID/subject scope where supplied.
Unknown metadata stay unknown; no new mandatory CSV fields are introduced.

In **Availability**, record per recording/event type/metric comparison reasons,
with existing identity metadata. Relevant reasons include missing session
mapping, unknown calibration/exposure, reference-type/quality mix, unknown or
mismatched support, native/extended-area mismatch, incomplete contributions,
mixed policy/version and incompatible review source. Reference quality alone
is not a new automatic scientific exclusion or a reason to erase a computable
measurement.

Keep row-specific ComparisonStatus distinct for burden, onset rate, event
measurements and session mapping. A row containing raw counts and normalized
burden cannot receive one universal comparable flag. Finite zeros, numerical
unavailability, exclusions, not applicable and not assessed remain distinct.
Present named paired normalization counterparts: counts with rate/density,
raw occupied area with fraction, raw burden with its area/time-normalized value.

Comparison conditions match the **measurement definitions**, not mouse or
condition labels: those biological factors are deliberately allowed to differ.
Differing A/T values are allowed for the area/time-normalized rates; requiring
equal denominators would defeat that normalization. Different animals naturally
have different mask hashes; require compatible support definitions, not an
identical mask bitmap. Exact raw/source identity is required for automatic/
reviewed pairing of one recording, not for comparing different mice. Differences in sampling/resolution/exposure retain
qualification because unit conversion cannot recover unobserved events.

There is no universal normalization for unequal session designs, missing
calibration, different footprints/references or different anatomical sampling.
Make the appropriate comparison possible when evidence supports it and make
limitations machine-readable. Do not force every field onto a 0–1 scale,
standardize within each mouse, renormalize twice, or claim normalized means
biologically interchangeable.

## Scope and evidence

Read source text for the metric families, existing guide/definitions,
metadata/identity, native support, recording/window burden and mouse aggregation.
Primary article context was consulted for relative optical measurements and
experimental-unit interpretation; it is not a new paper-method reproduction.
The existing historical arithmetic coverage remains in
[BOI_CALCULATION_COVERAGE](BOI_CALCULATION_COVERAGE.md).

No current recording was opened, no source data or original result changed,
no mathematical rule was adopted, and no verification/tests/MATLAB/analysis
or export was run. Source-level concerns are identified as such; no new current
numerical defect is established by this report. This does not close historical
coverage gaps or certify all measurements across the actual sessions.

## Source-only follow-up: non-denoised intensity routing, 12 November 2026

The researcher states there is no deliberate pre-analysis intensity processing
apart from motion correction ("normcore" output), with denoised images for
detection and raw/motion-corrected images for intensity measurements, and asks
for a code check. This follow-up is static source inspection only. It does not
lift the hold on implementation or numerical verification.

- **Input separation:** helpers/inspectOxygenTiffs.m:4-10 classifies TIFFs by the
  denoised filename tag; helpers/loadOxygenStacks.m:23-36 loads IM_Raw and
  IM_NoNoise separately, requiring matching dimensions. No actual recording
  filename or source association was checked.
- **Intensity reading:** external/loadtiff.m:115-132 reads pixel values into
  the image array; lines 155-157 calculate companion summaries and cast oimg
  to single. There is no intensity rescaling step here. Precision and actual
  imported values were not numerically checked.
- **Detection branch:** OxygenDynamics_Master.m:88-110 preserves IM_Raw and
  uses detrended denoised input when present, otherwise detrended IM_Raw.
  Lines 149-175 feed its processed branch into candidate detection. Raw input
  is not replaced by IM_Raw_Notrend for final intensity measurements.
- **Final automatic amplitude:** OxygenDynamics_Master.m:463-468 passes IM_Raw
  to finalizeOxygenEventMeasurements for both signs. That helper's lines 60-100
  construct each event's fixed-footprint raw trace, obtain its reference and
  extrema, and calculate signed relative amplitude/fraction/percent. Lines
  92-93 also use this raw-reference ratio for the saved optical integral.
- **Existing burden reference:** finalizeOxygenEventMeasurements.m:73-75,135-136
  passes raw evidence to deriveBOIPreEpisodeReferences.m, whose lines 50,75-81
  derive the existing pre-episode reference/amplitude from Raw. The selector
  getBOISinkBurdenAmplitude.m:4-20 chooses the applicable saved raw-derived
  amplitude version; createHypoxicBurdenMetrics.m:38-69 multiplies it by the
  saved mean area and duration. The held baseline-and-flags change has not run.
- **Reviewed amplitude:** captureBOIRunReview.m:6-9 receives ReviewRaw, populated
  from IM_Raw at master line 492. auditOxygenEventFootprints.m:28-33,57 saves
  the fixed-footprint raw trace. loadBOIReviewedBurdenEvent.m:26-28 derives
  reviewed amplitude from that Raw trace using computeBOIReviewedOpticalInterval.
  Exploratory corrected-pocket previews retain their separate definitions and
  do not replace the main burden intensity source.
- **Detection-derived geometry/support:** master lines 120-122 use the detection
  branch for the automatic tissue-area estimate; computeRecordingArea.m:17-35
  derives the mask and calibrated area, unless explicitly replaced by saved
  support. Native masks/morphology and trace-refined timing also depend on
  detection. Thus denoising affects geometry, duration and normalization support,
  even though it does not supply final raw optical intensities.

The inspected main source path matches the intended intensity separation; no
new intensity-source calculation error is established. Some old comments about
returning to detrended raw data are less precise than the actual finalizer call,
which receives IM_Raw. No code/comment was edited. This does not certify every
auxiliary metric, external motion correction, camera black level, filename
assignment or historical run. No TIFF/MAT/workbook payload, original result or
file hash was read, and no MATLAB/test/replay/export was run. Keep explicit
intensity-source versus detection/geometry/timing/support provenance; do not
claim denoising has no downstream effect on burden. Formula, normalization and
original results stay unchanged.

## Agreed secondary outputs: source-review follow-up, 12 November 2026

The researcher agrees to the two saved secondary outputs and automatic native-
gap QC, then requests review. Reporting agreement does not lift the execution
hold. Static source reading supports the additions with the following contract:

| Output | Source meaning and normalization | Required reporting safeguard |
| --- | --- | --- |
| HypoxicBurdenPerMm2OverTime | Existing event contributions spread uniformly over their exported duration and summed over active frames; percent * um2 / mm2; area-only pointwise scaling. | Copy the selected automatic/reviewed source curve and clock. Keep recording completeness distinct; no per-minute factor on individual points, finite-only total or absent-source zero fill. |
| SignedTraceAUC_sec | Saved sum((raw-reference)/reference)/fs; fraction * seconds; own raw footprint/reference/window. | Keep sign and original reference/version. Its presence in a reviewed event table is not evidence it was updated for reviewed burden. Preserve original values; genuinely absent compatible reviewed integrals remain unavailable. |
| PreviousNativeGapSec / NextNativeGapSec and saved close-run context | Empty native frames between automatic detections divided by fs; seconds. | Automatic QC only. No recovery/episode-independence inference; no silent recalculation after exclusions or reviewed boundary changes. No neighbor is not applicable. |

Key source findings:

- helpers/finalizeOxygenEventMeasurements.m:89-93 computes the strict-reference
  raw AUC. helpers/getBOISinkBurdenAmplitude.m:13-20 can select a different
  derived amplitude reference. There is no automatic corresponding AUC update.
- helpers/createBOIReviewedBurdenMetrics.m:60-65 deliberately preserves original
  event columns. helpers/applyBOIReviewedBurdenEvents.m:29-30,47-60 changes only
  specified burden inputs/outputs; the original AUC is not made reviewed.
- The same review adapter's lines 68-72 stores explicit burden bounds and uses
  N.TimeSeriesTable. Copy that saved series; do not rebuild it using the retained
  automatic StartFrame/EndFrame columns. exportBOIReviewedBurden.m:20-32 writes
  the same named time-series sheet/CSV in the reviewed source export.
- helpers/exportBOIEventReview.m:58-78 can save exploratory optical integrals.
  Those preview fields are not automatically accepted reviewed quantities.
- helpers/annotateOxygenEventRecurrence.m:8-23 calculates original native gaps
  and threshold flags. It is not rerun as reviewed recurrence here.
- The existing burden time series is sink-only; do not populate surge composite
  values. Source-provided signed AUC remains sign-specific. All three output
  families use numeric cells with explicit units, not Excel percentage format.

A future finite check should reconcile a complete saved area-normalized curve
with its matching full recording total using sum(signal/fs)*60/T and the same
area, membership and inclusive frame intervals. This is a static identity from
the existing source definition, not a replay or numerical verification result.
AUC source/reference checks and automatic-only gap labels belong within the
already bounded future acceptance checks. No new fixtures/campaign or budget
expansion is authorized. Existing source-support/version concerns remain open.

No TIFF/MAT/workbook result payload, source checksum scan, MATLAB session,
calculator, numerical test or export was used. Only source/planning documents
were read/updated. No new current numerical error is established; the review
identifies source/label risks and the future checks needed. Original scientific
code, inputs, outputs, burden formula and normalization remain unchanged.
