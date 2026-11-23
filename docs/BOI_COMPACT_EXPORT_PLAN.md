# BOI measurement and compact export specification

See [Current delivery status](SOFTWARE_DEVELOPMENT_PLAN.md#current-delivery-status)
for the active milestone, delivery evidence and next authorized step.

13 November 2026, revision 31. **Signed-contribution adoption implemented and
verified locally; compact workbook delivered and verified locally.** This is the
current measurement/reporting contract. Finite signed contributions are included,
negative values are flagged and subtract, and no individual-example investigation
is resumed. Revision 31 supersedes revision 30's nonnegative eligibility clause.
Earlier wording is preserved in the
[pre-revision snapshot](../../reference-validation/boi-signed-contribution-contract-20261113/before/docs/BOI_COMPACT_EXPORT_PLAN.md).

The researcher normally batch-analyzes multiple recordings from different
mice and conditions. The intended workflow remains: load the batch CSV, run
the existing analysis, then export identifiable data for postprocessing.
Retain the original detector as the foundation, the burden formula and
normalization, original data/results and the existing detailed export formats.
Do not start a subsequent implementation, verification or real-data regeneration/export scope without the applicable explicit approval. The compact milestone itself is complete.

## Historical delivery and planning record

The [bounded compact-workbook proposal](BOI_COMPACT_WORKBOOK_IMPLEMENTATION_PLAN.md)
initially held implementation and numerical testing and limited fixtures to
constructed tables and existing synthetic revision-31 exports. The later
[core delivery](BOI_COMPACT_WORKBOOK_DELIVERY.md) records eight passing families,
four MATLAB starts, 26 evaluations, five XLSX dispatches and three repairs
under the original approval and two explicit extensions. The subsequent saved-batch
preview exposed oversized status reporting. The
[summary-layout and formatting proposal](BOI_COMPACT_BATCH_USABILITY_PLAN.md)
awaited approval at that checkpoint. Its execution and results are recorded in the
[saved-batch delivery](BOI_COMPACT_BATCH_USABILITY_DELIVERY.md).

The [machine-readable bounded handover](planning/boi-reconciled-delivery-plan-20261112.json)
records the original planning sequence and limits.

| Delivery, in sequence; owner root | Practical result | Existing cap and approval state |
| --- | --- | --- |
| Baseline integration | Versioned original event-specific 20-second amplitude, independent flags, preserved old values and consistent existing burden selection. | BREF-01 to BREF-04 completed locally on 13 November under the former sign eligibility. Historical cap: four active hours, three batches, one repair, twelve constructed scenarios/24 executions, up to 48 existing synthetic regression evaluations, two MATLAB starts, one predefined saved comparison plus one retry, 2 GiB RSS and 100 MiB evidence. This cap is not reset or transferable. |
| Recording-reference flag supplement | Earlier first-20-second mean evaluated on each event footprint, explicit optional override/quality and not-assessable status; no burden denominator or eligibility change from this descriptive comparator. | BREF-05 was explicitly approved and completed with the baseline work within the same combined cap. It is not a pending supplement and creates no additional allowance. |
| Signed-contribution adoption | Include each retained event's finite signed product, flag negative values and retain strict completeness. | Explicitly approved, implemented and verified locally under the separate bounded four-hour scope; all 36 synthetic checks pass. Two launches, one repair and eight workbook attempts used. No real recording input; no further automatic run. |
| Compact export | Six core tables plus optional Phases metadata, identifiable automatic/reviewed source values, normalized/conditional-comparison labels and agreed secondary outputs. | Original proposal for CEX-01 to CEX-04, before approval and extensions: six active hours, four batches, two repairs, eight scenario families/24 executions, two MATLAB starts, four named-workbook export attempts, 4 GiB RSS, 100 MiB evidence and 25 MiB total new compact-workbook output. |

Only one implementation milestone may run at a time. The four-hour baseline
cap and six-hour compact cap are separate and do not transfer unused fixtures,
repairs or tests between milestones. If the supplement or reporting additions
cannot fit, stop at the boundary and report remaining work; no implicit budget
increase or wider dataset check is authorized. The signed-inclusion policy is
settled; do not reopen it through individual examples or a new baseline search.
Explicit applicable authorization is required before held implementation or
verification resumes. Do not request repeat approval of the settled scientific
contract or imply that the completed baseline work has not run.

### Ownership and minimal input workflow

- The upstream baseline/evidence layer computes new amplitude/reference flags.
  The compact exporter copies completed saved values. In particular, calculating
  the earlier-recording comparison is not hidden in workbook projection.
- Keep existing manually prepared batch CSV/editor entry, confirmed shared
  acquisition settings and row overrides. Optional session, field, camera,
  treatment and source-reference metadata remain optional. Preserve original
  measurement labels/calibration; later annotations retain separate provenance.
- Before analysis, explicit control links and phase annotations can bind to
  existing BatchRowID; afterwards they can use the saved RecordingID. Resolve
  through the existing saved Included BatchRowID-to-RecordingID crosswalk.
  Friendly GUI labels must store an exact selected identity, never a filename
  guess. Outside-export/unresolved references keep status, without opening an
  additional recording to resolve them or creating contrast calculations.
- Proposed minimal phase entry is an optional PhaseAnnotationsFile CSV pointer
  on a batch row. Its simple table holds PhaseName, StartSec and EndSec, with
  optional interval identity/source/notes. Existing explicitly identified
  RecordingID/WindowID/StartSec/EndSec tables can be mapped to the same metadata.
  Copy to Phases in recording-relative seconds with identity/source; no event
  assignment, clipping, protocol inference, phase editor or phase calculation.
- Signed AUC retains its original reference/window/version even after the new
  amplitude policy is selected. New-reference or reviewed integral generation
  is not added to baseline integration or the compact copier. An absent matching
  scalar remains unavailable; an original finite scalar remains labelled as such.

### Finite acceptance and protected sources

The twelve baseline scenario families and eight compact-export scenario families
are listed in the handover JSON. They include sampling/time units, independent
reference-quality flags, original-value preservation, typed metadata/keys,
unknown/excluded/zero states, strict completeness, AUC source identity, automatic
native gaps, matching saved burden curves, optional phase metadata and existing
GUI recovery. All initial and retry executions count toward the applicable limits.
The completed baseline scenarios remain historical evidence under the former
sign gate. Revision-31 signed inclusion/flags are now verified separately by the
linked finite synthetic suite; no individual examples were reopened. The compact
core used eight scenario families under the approved limits and extensions. No
spent launch, repair, source or test allowance resets or transfers.

**No further individual-example investigation:** do not reopen pocket traces,
ROIs, images or videos, or ask for event-by-event biological judgments. Future
verification is limited to contract-level constructed/table checks under an
explicitly authorized finite scope. The earlier saved-trace fixture is historical
evidence, not an instruction to revisit its events. The two already named
FB2412/FB2413 single-recording workbooks remain the only real compact-export
fixtures; this revision does not open them or authorize additional source reads.
Synthetic metadata/review fixtures cover new reporting branches; do not fetch
real Labguru/note data or other review files as extra development fixtures.
Missing saved reference/frame metadata stays unavailable/not assessable; no raw
movie or alternate recording is opened to manufacture it.

A full 17-recording regeneration/export, detector/image/timing/mask changes,
phase-specific burden, protocol/KX work, new-reference AUC, comprehensive fresh
arithmetic certification and five reserved recordings remain outside these
milestones. Current support/version/evidence qualifications remain explicit
technical limitations rather than new biological method choices.

## Recording, mouse and condition identity

Every data sheet repeats identity and biological metadata on every row. A row
must remain identifiable when copied, filtered or imported independently.

Lead with **RecordingID, Experiment, Mouse, SessionID when known, Condition**, followed by the row's
EventType and its site/event/frame identifiers as applicable. Preserve original
column names and values. `Experiment` retains its original recording/datafile
label; it is not substituted for Mouse or Condition. Retain **DrugID, Genotype,
Promoter and PuffStim**, and other available descriptive metadata. Metadata
that were optional remain optional; add no new mandatory CSV fields.

Use the saved `RecordingRegistry` as the authoritative per-recording crosswalk.
The existing metadata path already carries these fields into event tables:
[stats metadata](../helpers/createStatsRecordingMetadata.m),
[recording row](../helpers/createAnalysisRecordingRow.m), and
[event metadata](../helpers/addStatsRecordingMetadata.m). The original event
output also carries Experiment, Mouse, Condition, DrugID, Genotype, Promoter
and PuffStim. This consolidation inspected source text only, not cohort data.

- A mouse may have multiple recordings and multiple conditions. A condition
  may contain multiple mice. Preserve the recording-level association on each
  event, site, time-series and availability row.
- Join by saved identities, never by mouse alone, condition alone, row order,
  a display label or an inferred filename pattern. Do not pool recordings or
  conditions while building the compact tables.
- The event key is **RecordingID + EventType + SiteID + EventIndex**. Map SiteID
  explicitly from SinkID/SurgeID. Retain original source EventID and the
  documented EventID fallback when EventIndex is absent. Do not parse or
  renumber identifiers to make ambiguous rows appear unique.
- Local site/event numbers can repeat between recordings and event signs.
  Duplicate RecordingID with conflicting metadata, ambiguous keys or a review
  claiming another recording's event must stop that source join.
- Preserve identifiers as text when writing, including leading zeros that
  exist in the source. Missing metadata stay visibly missing/not recorded;
  do not invent a mouse or condition. Unknown mice must not be silently pooled.
- Source analysis/export identity and review version stay traceable. A new
  analysis of the same recording is not silently substituted for its saved
  predecessor. Use a source BatchID/name when available without making a new
  CSV field mandatory.

Illustrative identities, not analyzed data:

| RecordingID | Mouse | Condition | EventType | SiteID | EventIndex |
| --- | --- | --- | --- | ---: | ---: |
| rec-A | mouse-01 | control | sink | 1 | 1 |
| rec-B | mouse-01 | treatment | sink | 1 | 1 |
| rec-C | mouse-02 | control | sink | 1 | 1 |

These are three different events. The second recording remains associated with
the same mouse under a different condition. Each time series keeps its own
recording-relative clock; combined export does not concatenate animals in time.

### Optional treatment details: field set confirmed

The researcher selects **optional treatment-detail columns for information
held in Labguru/notes** because the original labels do not always carry all
intended comparison context. Preserve Condition, DrugID and the existing
stimulation/biological labels exactly. The current mouse/group summarizer still
groups by DrugID, Condition, PuffStim, Genotype and Promoter; no new grouping,
renaming, pooling or weighting rule is adopted. No actual recording labels or
Labguru/note payloads have been read in this interview.

The researcher confirms that the following optional set covers their usual
comparisons:

- Drug concentration and/or administered dose, each with its own unit and
  unambiguous quantity meaning; do not conflate concentration with dose.
- Administration route.
- Time since treatment administration at recording start, in minutes when known.
- Short stimulation description, retained as descriptive metadata only.
- Labguru entry link/reference and free notes.

These treatment descriptors are selected requirements. All remain optional;
unknown quantities/units/times stay unknown rather than inferred.
Use explicit entered/pasted notes via the chosen CSV/editor workflow. Drug
elapsed time must not be silently mapped from acquisition
TimeSinceApplicationSec, whose meaning may refer to substrate administration.
No new importer, automatic unit/dose normalization, stimulation-window
reconstruction, protocol inference, physiological correction or scientific
calculation is introduced. Treatment descriptors are context, not factors in
the unchanged burden formula or recording area/time normalization.

### Session, subject scope and analysis versions

The researcher defines a **session as one experimental visit/preparation for
one mouse**. A visit can contain several recordings and different conditions.
Keep Mouse → Session → Recording → Site → Event explicit; Condition remains
attached to each recording. A session is not automatically one movie, one date
or one batch. Session labels are interpreted within the mouse/subject scope,
not as a way to combine different animals.

The selected first-twenty-second comparison reference remains per recording,
not silently moved to the first recording of a visit. Each recording's burden
continues using its own saved analyzed area and recording duration. Session
identity alone authorizes no new pooling, denominator or weighting change.
The researcher selects **recording-level rows with SessionID**, leaving session
aggregation to postprocessing. Do not add a session summary table, pool
recordings within a visit or change the existing mouse/group aggregation.
Never combine different conditions merely because they share a visit. The
original recording calculations and detailed outputs remain intact.

For session comparisons, retain **SessionID** and its source when explicitly
supplied/saved, with **SessionMappingStatus**. Add that identity column to all
data rows; absent mapping stays not recorded. BatchID, Experiment and recording
filename are not automatically a session. Multiple recordings may belong to
one session, and one mouse may have multiple sessions within a condition.
Source metadata currently do not establish this mapping; do not invent it or
claim a session-specific result from a one-recording row.

The researcher confirms that **Mouse IDs are unique and stable across all
sessions and batches to be combined**: one ID always denotes the same animal
and is not reused for another animal. Use the original Mouse value as that
stable animal identity, preserving its text. Do not split one mouse into new
animals by batch/session, or infer Mouse from a recording/site label. This is
a researcher-declared identity convention, not a numerical/data verification.

StudyID/DatasetID can remain optional provenance; no extra subject namespace
or mandatory CSV field is required for the confirmed identity scope. If future
sources violate it, flag the conflict for explicit mapping rather than silently
merge or rename animals. Session membership still needs its own supplied/saved
mapping; do not treat unknown sessions as one session.

The four-part event key is unique within its source analysis. Preserve a
SourceAnalysisID/SourceExportID context when combining outputs from several
runs. A reanalysis of one recording is not a new biological replicate. Same
SiteID across sessions is not evidence of anatomical registration; do not infer
a longitudinal ROI match from that number.

### Field of view and confirmed session terminology

The researcher reports several recordings under different conditions (for
example drug, stimulation or no stimulation). The field of view is usually the
same within the overall experimental visit, but it can change after drug
application, refocusing or other adjustments. Do not assume identical spatial
coverage from a shared mouse/visit label, or infer anatomical registration from
recording-local site numbers. Area/time normalization retains its existing
meaning; it does not establish spatial correspondence or equivalent sampling.

The researcher confirms **SessionID for the overall experimental visit** and
**RecordingID for each individual movie**. A visit can contain control, drug,
stimulation and unstimulated recordings. This resolves the earlier use of
"session" for both levels. Session membership remains explicit optional metadata;
no new mandatory CSV field, pooling or weighting change is introduced.

The researcher selects **optional FieldOfViewID per recording, with optional
notes when needed**. Scope the field label by Mouse and SessionID. Reuse a label
only when the researcher judges the field to be the same, use a different label
for a changed field, and retain missing/unknown when it cannot be established.
Notes can describe refocusing, repositioning or uncertainty. Retain supplied
field identity in linked data rows and notes in the recording metadata; no new
mandatory CSV field is introduced. A change flag alone was not selected.

Matching labels record researcher-declared context, not pixel/ROI registration
or a guarantee of biological comparability. No field identity is inferred from
condition, file order, image dimensions or recording-local site numbers. Field
metadata do not automatically exclude measurements, change weighting or alter
normalization. Optional fields and their future GUI/export handling remain
requirements only; implementation has not started.

The researcher confirms that they **stop recording before repositioning or
refocusing**, then start a new movie. Such adjustments are between-recording
context for FieldOfViewID and notes. This is a statement about acquisition
practice, not a data-verified claim that every movie is free of motion, drift
or focus variation. No within-movie segmentation or new processing rule is
introduced. Existing quality evidence remains distinct from this declaration.

The researcher confirms that **acquisition settings can vary, usually between
mice**: exposure time, frame rate, gain, camera and/or binning. "Usually" is not
a guarantee of identical settings within one mouse or visit. Preserve actual
recording-specific settings/calibration and their evidence where available;
do not assign one mouse-level or batch-level setting to all movies without an
explicit source. Unknown values remain unknown. Acquisition changes are
comparison qualifications, not automatic exclusion or a new signal correction.
Keep the burden formula, normalization and original results unchanged.

The existing source carries SampleF and PixelSize in the recording registry
(createAnalysisRecordingRow) and can preserve declared CameraExposureSec with
its evidence in the captured acquisition metadata
(captureBOIAcquisitionMetadata / resolveBOIAcquisitionMetadata). The current
structured acquisition declaration does not define camera model, gain or
binning fields. This is source inspection only: no saved recording metadata
was inspected and no acquisition values were verified. Reuse compatible saved
provenance; do not retroactively apply live declarations to original outputs.

The researcher identifies **Labguru and the specific recording's filename**
as sources for acquisition information. This establishes where information is
recorded, not that every setting/calibration is present, unambiguous or
consistent across both sources. No Labguru records or recording payloads were
opened, and no filename interpretation has been verified. Preserve metadata
source and any uncertainty when carrying supplied values forward. Automatic
Labguru access, a filename parser and a source-conflict precedence have not
been selected. Do not infer mouse/condition identity, retroactively change
original analysis inputs or introduce mandatory CSV fields from this answer.

The researcher confirms that calibrated **micrometres per pixel for each
camera/binning setup are available in their notes**, referring to the analyzed
images. The values and their mapping to individual movies have not been read
or verified. Availability does not establish that previous runs used matching
values; retain the original analysis inputs and results unchanged.

Source inspection shows that the existing batch editor already supports
explicitly confirmed shared SampleF/Pixelsize values and per-recording overrides
(openBOIBatchEditor / resolveBOIBatch; BOI_BATCH_EDITOR guide). Shared values
fill only blank rows after confirmation; row values take precedence. This is
source/document inspection, not a GUI or numerical verification run.

The researcher selects **reuse of the existing CSV/editor entry**, with
acquisition/calibration values entered or pasted from notes. Use explicitly
confirmed shared frame rate and pixel size only where applicable, retaining
per-recording overrides. Camera, exposure, gain and binning remain optional
metadata. Filename-derived suggestions and automatic Labguru integration are
not part of the selected first version. Keep metadata source/unknowns visible;
no new mandatory CSV fields or calibration procedure is introduced.

For existing completed runs, retain the calibration actually used with the
saved measurements. A newly entered note/reference must not relabel, rescale or
replace those measurements. If an actual discrepancy with notes is established
later, report it as a descriptive calibration mismatch with the saved versus
declared values/source; no automatic recalculation or exclusion is adopted.
This follows the existing preservation/comparability contract. No discrepancy
has been investigated or demonstrated during this interview.

The researcher reports **no additional intensity preparation besides motion
correction (output from "normcore")** before input to this script. Their intended
workflow is denoised data for detection and non-denoised motion-corrected images
for quantitative intensities. Record this history as researcher-declared; no
external motion-correction implementation, camera export or saved movie was
inspected, and it does not establish undocumented automatic camera processing.

At the researcher's explicit request, a **source-code-only check** confirms the
current separation. loadOxygenStacks loads the non-denoised TIFF as IM_Raw and
the optional denoised TIFF separately. The TIFF loader reads pixel values and
casts to single, without an intensity rescaling operation. The master preserves
IM_Raw while creating a detrended/normalized detection branch from denoised
input when supplied. Both sink and surge finalizers receive IM_Raw. Their
fixed-event-footprint raw trace supplies the reference, event extremum, relative
amplitude and raw-reference optical integral. The existing pre-episode reference
and saved reviewed single-event burden amplitude likewise use raw-source traces.
Burden selection changes the reference version, not the image intensity source.
This historical source-only check preceded implementation of the baseline/reference
work and revision 31's signed-inclusion policy.

Denoising is therefore on the **detection side**, but its influence is wider
than event presence alone: it affects native masks, morphology, timing and the
automatic tissue-area estimate used in normalization. Corrected/z-scored traces
and exploratory preview measures retain their own definitions; not every numeric
output is a raw-intensity measurement. Record quantitative-intensity source and
detection/geometry/timing/support source separately. This is not a calculation
error or a proposed method change. See the source-only follow-up in
[the normalization review](BOI_NORMALIZATION_COMPARABILITY_REVIEW.md).

No image, MAT/workbook result payload, actual filename assignment or file hash
was inspected; no MATLAB, numerical replay, test, correction or export ran.
Source inspection establishes the current code path, not that each historical
run used the correctly named files or that motion correction preserved every
camera value. Formula, normalization and original results remain unchanged.

The first twenty seconds, event references and burden denominators remain
recording-specific. Formula, normalization and original results stay unchanged.
Implementation and verification were held at the time of this source review.

## Normalization and comparability contract

The [source/specification review and full metric catalogue](BOI_NORMALIZATION_COMPARABILITY_REVIEW.md)
is part of this specification. Reuse the existing NormalizationGuide and
MetricDefinitions; expose their source-specific meaning per field. A normalized
cell is not automatically biologically comparable, and a physical measurement
need not be divided by A/T to be compared. This review adds reporting
requirements, not numerical changes or current data certification.

| Metric family | Normalization/calibration | Cross-recording/mouse/session use |
| --- | --- | --- |
| Primary normalized burden; onset rate | Existing analyzed-area and recording-time factors | Conditional primary comparison across different A/T, with compatible definitions, source support, reference/review policies and full required ingredients. |
| Concurrent density; tissue occupancy fraction | Area-normalized; recording means time-averaged | Conditional comparison; pointwise values are not additionally per-minute rates. Tissue union fraction differs from event-time/count density. |
| Event duration, mean area, diameter/perimeter | Saved fs and pixel-size calibration to s/µm²/µm | Conditional physical event comparison. Do not divide intrinsic event size/duration by recording A/T. |
| Local amplitude percent | Event-reference normalization | Conditional relative optical comparison; reference type/quality, footprint, calibration/exposure and policy matter. Not calibrated oxygen deficit. |
| Raw counts, raw occupied area, raw composite totals | No relevant recording-exposure normalization, or only partial scaling | Matched exposure only or use the existing rate/density/fraction counterpart. Area-only totals still depend on recording time; time-only totals still depend on area. |
| Detector z scores, ranks and raw reference levels | Within-recording standardization/rank, or raw a.u. | Not a common absolute response/oxygen scale across mice. Source-local/descriptive use; no biological severity guarantee. |
| Above-recording-reference flag | Per-recording descriptive reference comparison | No absolute cross-session severity meaning. Reference policy/override and ascertainment remain visible. |
| Per-event contribution divided by recording A/T | Contribution to a recording-normalized rate | Context-dependent decomposition, not intrinsic event severity. Preserve raw event product alongside it. |

In **Definitions**, every numeric field must identify its quantity/observation
unit, units and fraction/percent scale, NormalizationStatus, AreaNormalization,
TimeNormalization, SignalNormalization, ComparisonScope, restrictions,
NormalizedCounterpart and evidence status. IDs and quality flags are explicitly
not biological magnitude measurements. Unknown/unmapped definitions are marked
not assessed rather than assigned a generic comparable flag.

In **Availability**, preserve metric-specific ComparisonStatus/ComparisonReasons
with recording/mouse/condition/session identity. Recordings/Events must expose
or link the corresponding status next to the relevant quantities. Do not assign
one comparable Boolean to a row containing both raw counts and normalized
burden. Useful labels are conditional cross-recording comparison, matched
exposure only, within-recording reference only, not directly comparable, not
assessed/unknown and not applicable. This task does not evaluate those statuses
on actual recording payloads.

Expose actual analyzed A, recording/window T, their units/sources, sign-specific
support profile, geometry/time basis, PixelSize, sampling/frame-time and camera
exposure status where known, measurement/reference/detector/normalization policy,
review coverage and source identity. Record reference-type/quality mixes and
contributing/required counts. Unknown calibration, session mapping, support or
current evidence is not certified by a finite numeric value.

Distinguish these conditions without silently changing calculations:

- Event morphology can include full native masks while occupancy is clipped
  to eligible tissue. The support relation to the burden denominator must be
  visible or not assessed. Do not silently clip or recompute event area.
- Native area over detected frames does not establish area throughout extended
  duration. Keep area/time support qualification; retain saved product values.
- Primary recording burden can use matched event-specific area while window
  composites use native EventArea_um2. They are interchangeable only when the
  saved ingredients agree, not merely because both divide by A/T.
- A post-event reference is a recovery-reference contrast, not an observed
  predecline baseline. Keep that mode, its quality and contribution counts
  visible in normalized burden; no new automatic exclusion is introduced.
- A percentage ratio does not remove additive camera offsets, within-window
  signal change or detection/sampling differences. Keep raw/corrected/reference
  measurement families distinguishable.
- A complete numeric total and compatible normalization are not proof of
  physiological validity or equal review coverage. No partial sums or
  quality-driven rescaling are adopted.

Exact source identity is required when pairing automatic and reviewed versions
of the **same** recording. Cross-mouse comparison instead requires compatible
measurement definitions, not identical raw data or mask hashes. Mouse and
Condition can deliberately differ; normalized rate comparison permits different
A/T values. Do not construct a comparison grouping that makes different mice,
conditions or denominators automatically incomparable just because they differ.

Keep the current aggregation contract explicit: equal recording means within
mouse/condition, then equal valid mouse means in existing group summaries.
This is not area-time exposure pooling or SessionID aggregation. Repeated events,
recordings and source versions are not extra mice. Retain metric-specific
valid/total mouse, recording and event counts; no new inferential model or
weighting change is authorized. Individual-recording rates remain separate in
the compact tables for appropriate later postprocessing.

Comparability warnings are descriptive, not a new scientific exclusion gate.
Preserve computable values and original results. No per-mouse z standardization,
extra FOV division, automatic session pooling or formula/normalization change
is authorized by requiring explicit comparison labels.

### Optional control-recording links: selected with explicit same-mouse scope

The researcher selects an **optional explicit link from a comparison movie to
its control movie** in the compact export. Keep the selected control identity
and source with recording metadata; missing/unselected links remain missing.
This is between-movie identity metadata, separate from the twenty-second
per-event baseline and first-twenty-second within-recording reference. Each
movie keeps its own area/time-normalized results.

Reuse the existing BaselineRecordingID and ComparisonRecordingID source roles.
createOxygenBaselineContrasts already requires explicit same-mouse recording
pairs and produces detailed contrasts only when supplied with pairs.
runOxygenDynamicsStats.m:555-559 reads the optional baselinePairsCsv;
helpers/exportStatsResults.m:39 preserves PairedBaselineContrasts in the detailed
export. No actual pair table or saved recording payload has been inspected.
The selected metadata link authorizes no new calculation or sheet.

Do not infer controls from file order, condition names, session membership or
field labels. One control can be explicitly linked to several comparison
movies. No new percent-change normalization, pooled control, session
aggregation, weighting, seventh sheet or formula change is adopted. Existing
detailed paired outputs remain preserved.

The researcher selects **any explicitly chosen control recording from the
same mouse**, including another visit or field of view. Retain differences and
unknowns in SessionID, FieldOfViewID and acquisition context as comparison flags;
do not impose a same-visit/same-field restriction or automatically omit values.
A selected control is an intended comparison, not certification of biological
comparability or registered site identity. Do not infer matching context when
metadata are missing, or create pair links automatically. The existing same-
Mouse source rule remains unchanged; no cross-mouse link is adopted.

### Mixed experimental phases: optional supplied annotations selected

The researcher confirms that some movies contain baseline, stimulation and
recovery phases, and selects **optional phase names and start/end times supplied
by the researcher**, carried as annotation metadata alongside the existing
outputs. The main compact burden remains explicitly whole-recording, using the
full saved interval/duration. Preserve recording-level condition labels; do not
assume they describe every event/frame's treatment state.

Use a separate optional Phases annotation table when supplied, retaining exact
RecordingID association, phase name/interval identity, recording-relative start
and end times, units/origin, source/reference and any uncertainty/notes. Repeat
the agreed recording/mouse/session/condition identity. A table supports repeated
phases without fixed baseline/stimulation/recovery columns. Reuse the existing
RecordingID/WindowID/StartSec/EndSec roles where compatible; freeze the exact
annotation crosswalk during the later reporting plan reconciliation. This adds
one optional metadata sheet to the six agreed core sheets when needed; it is
an ordinary reporting arrangement, not a new scientific window calculation.

Do not infer phase boundaries from traces, names, stimulus files or a presumed
protocol. Missing phase information stays unknown. Do not automatically assign
events to phases, split events/contributions, crop durations, change denominators
or calculate phase-specific burden. Existing event and frame times remain
available for external postprocessing. Supplying annotation intervals must not
automatically invoke analysisWindowsCsv. Existing detailed window calculations
and their formats remain preserved under their own original rules.

No stimulation-window reconstruction, protocol inference or new scientific
analysis starts. The metadata requirement still needs reconciliation with the
bounded export plan before execution; it does not expand effort/data budgets
or lift the implementation/verification hold.

### Uniform within-movie timing: researcher-declared practice

The researcher states **constant frame rate within each analyzed movie, with
no known missing or removed frames**. Retain the actual supplied frame rate for
each recording; it can differ between recordings/setups. This is declared
acquisition/processing practice, not a numerical timestamp check or confirmation
of a particular saved metadata contract. No movie/timestamp payload has been
inspected or original acquisition declaration modified.

Current frame-count/supplied-rate calculations for durations, baseline windows
and recording-time normalization remain unchanged. The acquisition contract's
uniform-assumed/confirmed and declared-nonuniform distinctions remain preserved;
this interview does not automatically promote every recording to verified timing.
No new time model, resampling, frame removal, denominator correction or test
run is adopted. The external 1 Hz authority for supplied examples remains
specific to those examples, not a universal future acquisition rate.

### Equal horizontal/vertical image scale: researcher-declared setup

The researcher states **equal horizontal and vertical micrometres-per-pixel
scale within each camera/binning setup**. Retain the correct setup-specific
value for each recording; values may differ between setups. This declaration
addresses the current scalar/equal-axis assumption, not whether each saved run
used the correct calibration. Actual calibration notes, input values and image
payloads remain unread/unverified.

The source continues using one positive scalar PixelSize: native pixel area is
multiplied by PixelSize squared and physical length by PixelSize. No anisotropic
geometry method, resampling, new calibration/normalization rule or numerical
recalculation is adopted. Existing evidence/qualification distinctions stay intact.

## Agreed measurements and references

### Event-specific local amplitude

Retain the original nominal **20-second mean before each individual event's
saved or explicitly reviewed onset**, using raw signal on the current fixed
per-event footprint. Each recurrent event receives its own temporal reference;
do not inherit the first event's baseline across the series.

`local amplitude percent = 100 * (local reference mean - event minimum) / local reference mean`

The sink convention is positive for a drop. For BLI, relative optical change is
ΔB/B; do not describe it as calibrated oxygen pressure or silently exchange its
sign with a signed delta signal. Preserve older saved amplitudes, strict-baseline
fields and pre-episode measurements as separately versioned values. New derived
results do not overwrite historical outputs or claim to have been calculated
by the original software version.

| Reference situation | Agreed behavior |
| --- | --- |
| Full preceding window | Compute its mean and the amplitude. |
| Short prehistory | Use available preceding samples and flag short reference; report requested/observed/finite counts. |
| Native detection starts at frame 1 | Use available samples after the saved event end, up to the configured duration; flag post-event reference and unverified recovery. |
| Overlapping native activity of either sign | Retain those reference samples, flag overlap and report overlapping-frame count. Assess all saved sites before statistics curation. |
| Missing reference samples | Use the original omit-missing mean where finite samples remain and flag/count missing samples. |
| No usable reference or nonpositive/nonfinite mean | Keep amplitude unavailable with a specific reason. Do not use an event sample as a fictitious pre/post-event reference. |

Keep existing event-signal availability requirements. A full clean window is
not a new minimum eligibility gate. Use saved sampling information, not a
universal assumption of 20 frames or 1 Hz. Record actual bounds, reference type,
mean, sample counts, source, quality flags, numerical availability and version.
No ten-second default, peak selection, trend fit, correction refit, global
boundary search or change to the current footprint is adopted.

### Separate recording reference for the above-reference flag

Use the **first 20 seconds of each recording**, with quality flags and an
optional explicitly identified override interval. Share the time interval
across that recording, but evaluate its mean on each event's own footprint.

`above recording reference = event minimum > mean on that footprint during recording-reference interval`

Keep reference bounds, mean, default/override identity and quality visible.
For events without a temporally preceding comparison interval or usable
comparison evidence, use **not assessable**, not false. This descriptive flag
must not withhold local amplitude, alter burden inclusion or change normalization.
It is not a declaration of healthy/normoxic tissue or a biological severity
class. The possible weaker consequence of a pocket remaining above this
reference is the researcher's hypothesis for future dual imaging.

A local decline remains a pocket even when above the earlier recording
reference. Do not reject it or demand manual review solely for that flag.
Finite negative amplitudes relative to the event's own local mean also remain
signed, are included in burden when the other required ingredients are available,
and receive a separate negative-value flag. Sign alone must not replace a finite
amplitude or contribution with NaN or classify a detection as not a pocket. No
absolute value, zero fill, sign reversal or new reference is adopted. Genuine
missing ingredients can still make a recording total unavailable.

### Size and duration

- **Size:** retain per-event mean native area in µm². Peak area and new peak
  columns are deferred. The original separate event-specific stats output
  already calculated this mean; the old main event table's inherited site
  mean is a different quantity. Preserve the exact selected saved burden-area
  ingredient and its source, rather than silently replacing it.
- **Duration:** retain the actual saved numeric duration, with recording-boundary
  and onset/recovery flags. Do not blank it solely for uncertainty, change its
  window or extrapolate unseen portions. Unknown historical timing assessment
  stays not assessed. A flagged interval is not proof of a full physiological
  episode. Native area does not establish area throughout extended/reviewed
  bounds beyond its measured support.
- Keep saved event diameter and circularity for the paper's output families.
  Their presence/value preservation is distinct from independent arithmetic
  coverage or biological validation. Other exploratory descriptors remain in
  the detailed outputs unless already part of the agreed core.

## Burden: formula, normalization and completeness

Keep the existing event product and recording normalization:

`contribution_i = amplitude_percent_i * event_mean_area_um2_i * duration_s_i`

`normalized_burden = sum(contribution_i) * 1e6 / recording_area_um2 * 60 / recording_duration_s`

The amplitude ingredient retains the event-specific local-reference definition
and sign. The separate earlier recording-reference flag is not an alternative
denominator or severity weight. For each retained event with finite amplitude,
mean area and duration satisfying the existing ingredient-availability rules,
include the signed product unchanged. Short/overlap/post-event reference flags,
the above-recording-reference flag and a negative sign do not withhold a
computable contribution. A finite zero remains zero, not missing.

**Signed inclusion, agreed 13 November 2026:** negative contributions subtract
from positive contributions in the complete recording sum. The normalized result
can therefore be positive, zero or negative. Label it as a signed burden composite;
it is not guaranteed to be a nonnegative hypoxic deficit or a calibrated oxygen
quantity. Do not clamp, take absolute values, drop negative terms, replace them
with zero or publish a positive-only/partial total as the complete burden. The
event product and area/time normalization above remain unchanged and apply once.

Show negative-amplitude and negative-contribution flags beside the selected
automatic and review-applied values. Distinguish negative, nonnegative and not
assessable when a required value is unavailable. Recordings must expose negative
contributor counts and the sign of any finite total, separately from quality,
numerical availability and explicit review exclusions. These are descriptive
flags and counts, not exclusion gates or biological severity weights.

Version the future signed-inclusion selection/provenance separately from the
already saved nonnegative-eligibility outputs. Never relabel an old total or
source workbook as revision-31 compliant; the compact exporter copies the actual
saved policy/value and does not repair or recalculate it while projecting tables.

All required retained contributions must be available for a complete total.
No partial sum, coverage rescaling, imputed zero area/amplitude or substituted
normalization. Quality flags and numerical completeness remain separate.
A complete numeric total may include flagged references; show flagged counts
rather than label all references physiologically validated. A successfully
analyzed zero-event recording remains present with its existing zero total;
unprocessed/missing data are not treated as analyzed zero.

Keep automatic and review-applied event ingredients and totals separately
identified. Preserve explicit saved reviewed references, timing, measured area
and not-pocket exclusions. If an extended reviewed event lacks required area,
retain that missingness. Do not silently reuse partial native support as full
reviewed area. No accepted surge hypoxic composite is introduced; surge burden
cells remain not applicable. Signed optical integral remains its own saved
measurement, not another name for the composite.

## One Events table and side-by-side recording results

### Events

Use **one row per original automatic detection**, including detections later
marked not a pocket. Keep the recording/mouse/condition metadata at the left
and preserve every original automatic row and its identity.

Show separate automatic and review-applied amplitude, duration, mean area and
burden contribution. Include numerical availability, reference/timing/area
qualification, negative-value flags, review status, inclusion/exclusion, reason and selected review
version. A reviewed value is not a silent overwrite of its automatic counterpart.
When the burden-used ingredient differs from a displayed measurement, export
the exact burden-used value and its source as well; do not assume equality.

- Not-pocket detections remain visible for traceability, are explicitly
  **excluded from reviewed burden**, and can be filtered using the inclusion
  column. A missing reviewed contribution on an excluded row is explained as
  excluded/not applicable, not missing area or a zero-valued retained event.
- For a retained event without a saved manual change, preserve its actual saved
  automatic/review-applied ingredients and use **No manual review**. No decision
  does not mean rejection or scientific acceptance.
- A partially reviewed recording is not labelled wholly reviewed. Other
  automatic morphology, counts or occupancy are not relabelled reviewed just
  because burden has selected review decisions applied.
- Do not add automatic new events, merge episodes or change masks/timing while
  projecting this table. Existing measurement and review services supply values.

### Recordings and review selection

Show automatic normalized burden and burden after selected saved reviews
**side by side in Recordings**, with retained/excluded counts, valid/missing and
negative contribution counts, total-sign flags, numerical availability and
review-source identity. Negative values retain their sign in both paths.

Remember the explicitly selected saved review revisions for each batch, show
their version and allow changes. Do not silently switch to a newer file.
A remembered selection still must match the exact automatic source snapshot,
its recording/event inventory and compatible measurement/normalization policy.

When a compatible saved reviewed snapshot contains a recording with no manual
decisions/corrections, retain its unchanged saved value with **No manual review**
clearly labelled. Preserve unavailable numeric values and their reasons. If
there is no compatible reviewed source at all, the reviewed value remains
unavailable; do not manufacture it from an unrelated source or label an automatic
fallback as reviewed.

### Batch selection: reuse the existing manually prepared workflow

The researcher says the inventory-presentation choice is not important because
they manually prepare the CSV and preselect the recordings before analysis.
This is workflow clarification, not an explicit selection of either earlier
layout option. Do not keep asking about this low-priority distinction or add
an expanded all-batch inventory feature.

Use the existing selected-recording/export scope. Recordings focuses on included
compatible completed results; preserve existing Included/Excluded identities
and reasons in available reporting/Availability rather than add a new selection
or inventory-management step. prepareBOIBatchStats already provides this
information. Actual analyzed zero remains distinct from unavailable/unprocessed;
missing results never become zero. If a selected result cannot be included,
retain the existing failure/exclusion explanation. No extra payload inspection,
aggregation, burden calculation, source/fixture campaign or normalization rule
is adopted. Do not invent absent batch inventory for standalone source exports.

## Workbook structure and fields

Keep flat tables with one header row, filters, readable units and identifying
columns frozen appropriately so recording, mouse and condition remain visible.
Place the Events sheet in the user's initial working view. No repeated tabs
for every mouse/condition are necessary: retain those labels on every row.
Keep the six core sheets below, with an optional Phases metadata sheet only
when explicit phase annotations are supplied.

| Sheet | Row meaning and principal contents |
| --- | --- |
| `Events` | One original detection; RecordingID, Experiment, Mouse, Condition and other available metadata; EventType, SiteID, EventIndex, original EventID; separate automatic/review-applied amplitude, duration, mean area and signed contribution with negative-value flags; exact burden-used ingredients when different; reference bounds/flags, above-recording-reference flag, timing/area availability, native/saved/reviewed bounds, saved diameter/circularity, source-bound signed optical integral and its own reference/version, automatic native-gap QC, review status/inclusion/reason/version. |
| `Recordings` | One recording and event type; all recording/mouse/condition metadata; exposure and sign-specific analyzed tissue area; counts, count/mm²/recording (area-normalized only), active sites, onset rate, concurrent density and occupancy; side-by-side automatic/review-applied signed burden with negative-contributor counts, total-sign flags, contributor/exclusion/quality counts and source statuses. |
| `Sites` | One recording/type/site; repeat recording/mouse/condition metadata; saved site identity, event count, events/minute, source basis and availability. Retain sites with unavailable amplitude. |
| `TimeSeries` | One recording/type/frame; repeat recording/mouse/condition metadata; recording-relative frame/time, concurrent count and count/mm², native union area, tissue fraction, sign-specific area and timing/occupancy status; saved area-normalized sink burden signal with source/completeness and compatible automatic/reviewed identity. No cross-recording time concatenation or mouse averaging. |
| `Availability` | Recording/type/metric/reason or event-level reason where available; repeat recording/mouse/condition metadata and relevant event identity; distinguish quality, absent review, exclusion, missing ingredient, not assessed and not applicable. Overlapping reasons are not added as disjoint counts. |
| `Definitions` | Column meaning, units/scale, normalization type and area/time/signal basis, comparison scope/restrictions/counterpart, sign, observation/aggregation level, source mapping and versions/evidence; recording/subject/session/source/review crosswalk. Unknown versions and comparability evidence remain unknown. |
| `Phases` (optional metadata) | One explicitly supplied phase interval with recording/mouse/session/condition identity; phase name and interval identity, start/end time and units/origin, source/reference and notes. No derived phase metrics or automatic event assignment. |

Suggested display column families (exact source crosswalk frozen in CEX-01):

- Identity first: `RecordingID`, `Experiment`, `Mouse`, `SessionID` and mapping
  status, `Condition`, available
  `DrugID`, `Genotype`, `Promoter`, `PuffStim`; then `EventType`, `SiteID`,
  `EventIndex` and original `SourceEventID` where applicable.
- Events: `AutomaticAmplitude_pct`, `ReviewedAmplitude_pct`,
  `AutomaticDuration_s`, `ReviewedDuration_s`, `AutomaticMeanArea_um2`,
  `ReviewedMeanArea_um2`, automatic/review-applied contribution and availability.
  Keep original saved/alternative amplitudes and exact burden-used
  amplitude/area/duration/source fields distinct when their meanings differ.
- References/timing: local reference bounds/value/type/version/flags; recording
  reference bounds/value/override/quality; above-reference state; native,
  saved and reviewed frame bounds; onset/recovery/boundary assessment.
- Sign: separate negative-amplitude and negative-contribution states for each
  automatic/review-applied value, plus recording negative-contributor counts and
  finite-total sign. Exact display aliases are frozen with the source crosswalk;
  missing is not falsely labelled nonnegative.
- Reviews: `ReviewStatus`, `IncludedInReviewedBurden`, `ReviewReason`,
  `ReviewVersion`, source identity and area/timing qualification.
- Recordings: `AutomaticBurden_per_mm2_per_min`,
  `ReviewedBurden_per_mm2_per_min`, automatic detections, reviewed retained/
  excluded counts, available/required contributions and quality/review status.

These are display aliases, not new numerical definitions. Use numbers as
numbers and metadata IDs as text. Preserve source precision; formatting changes
display only. Percent-valued amplitudes such as 6.94 must not receive another
factor of 100 from Excel percent formatting. Blank numeric cells need an
explicit status/reason; zero stays zero. Do not collapse not assessed,
unavailable, excluded and not applicable into one flag.

## Paper output coverage and original data already available

The original [Science paper](https://pubmed.ncbi.nlm.nih.gov/38547288/),
Beinlich et al. (2024), doi:10.1126/science.adn1011, supplies the output-family
checklist: event size/duration/relative amplitude/diameter/circularity (Fig. 2L–P),
site recurrence (Fig. 2Q–S), concurrent counts/density and covered tissue over
time (Fig. 2G–K; Fig. 4D–G), and event/recording burden (Fig. 4H–M). This is a
figure-output crosswalk, not a claim that all current methods reproduce the
paper or that every physiological reference is validated.

The event dataset already exists in MAT tables and `OxySinkEvents` /
`OxySurgeEvents`. Original true event-specific mean area also exists in
`SortedSinkEventMetrics.xlsx` / `EventBased_AllEvents` as `Area_um`; its legacy
name means µm². The old main event table could instead carry a site mean and
the old burden could fall back to it. Preserve the source distinction.
Filled area and end-versus-start size modulation are not peak area. Peak area
is deferred; do not add calculation or columns to obtain it.

The prior read-only review of two 14 October automatic workbooks found all
478 sink rows had duration/area/diameter/circularity, with 254 finite original
amplitudes; all 224 missing amplitudes had insufficient clean prebaseline.
Those are historical strict-policy values, not a test or availability forecast
for the new policy or the later 17-recording combined export. The original
results remain unchanged. See [source findings](../../reference-validation/boi-paper-output-review-20261112/event-table-findings.json),
[original size source reading](../../reference-validation/boi-event-baseline-flags-plan-20261112/original-event-size-source/source-reading-notes.json),
and [calculation coverage](BOI_CALCULATION_COVERAGE.md). Export presence does
not close the documented arithmetic/physiological coverage gaps.

## Saved source mapping and read limits

The compact exporter copies completed compatible automatic/reviewed source
snapshots with their existing manifests/receipts. It does not calculate new
baselines, geometry, integrals, burden or review changes while copying a file.
The completed baseline integration supplies its actual versioned measurements.
The separate signed-inclusion revision is implemented and verified on synthetic
inputs. New BOI statistics can supply its versioned source artifacts; no real
recording export was regenerated by that delivery. Copying an older workbook
does not recalculate or adopt either a new baseline or sign policy.

| Output | Source/rule |
| --- | --- |
| Metadata | RecordingRegistry via exact RecordingID; original event/source labels remain traceable. Review metadata must not silently move an event to another mouse/condition. |
| Recording exposure/counts/occupancy | RecordingWindowMetrics and SurgeRecordingWindowMetrics at `whole_recording`; preserve each sign's saved area, clock, onsets and occupancy. |
| Automatic burden | HypoxicBurden_ByRecording and HypoxicBurden_EventBased, including selected amplitude/source, BurdenArea_um2, BurdenDuration_sec and saved contributions; never sum only available cells. |
| Saved burden time course | HypoxicBurden_TimeSeries from the matching automatic or selected compatible reviewed snapshot; area-normalized saved signal and its original clock/source/availability only. Do not recalculate, time-normalize each point, or replace an absent reviewed curve with automatic values. |
| Reviewed burden and decisions | Compatible saved reviewed export's recording/event tables, review decisions, excluded detections and summary/provenance. Exact parent automatic source required. Reuse the existing reviewed-export workflow separately if a new compatible result must be prepared. |
| Native event measurements | OxySinkEvents / OxySurgeEvents; copy actual event area, diameter/circularity, native/saved bounds and SignedTraceAUC_sec with its own reference/source/version. Do not substitute inherited site morphology or relabel an automatic integral as reviewed. |
| Site recurrence | Saved identified site counts or exact saved-event grouping; retain existing count × 60 / recording_seconds definition. Counts do not depend on amplitude availability. |
| Frame occupancy | Whole-recording WindowFrameIngredients / SurgeWindowFrameIngredients; native union area, analyzed area and time/status. Never sum overlapping event areas to replace the union. |
| Frame counts | Identified existing per-recording aggregates: NumOngoingOxysinks, NumOngoingOxysinksPerMm2, NumOngoingOxysurges. Prefer saved workbook tables; selective small aggregate MAT fields allowed only with validated recording association. |
| QC/provenance | EventMeasurementQC, EventBaselineStatusCounts, saved reference/review summaries, source policy/calculator metadata and receipt. Include saved PreviousNativeGapSec/NextNativeGapSec and close-run threshold/flag as automatic QC where present. Join recording metadata explicitly; do not recompute reviewed gaps. |

Only declared elementary count groupings, existing area/time unit conversions
and vector-to-row projection are allowed in this exporter. They must preserve
existing definitions and reconcile with source values. No new scientific
estimator or mouse/group weighting. Recording count density, concurrent-event
density, onset rate and occupied tissue fraction remain separate quantities.

Read selected workbook tables/receipts and whitelisted small aggregate MAT
variables only. Never load giant site/MAT tables with raw/ROI traces, rasters,
native masks or pixel lists. Missing/ambiguous recording association stops that
source join; do not infer it from a mouse header or row position. A legitimate
zero-event sheet can be represented as zero rows only when registry/QC establish
an analyzed zero; missing positive/unknown inventory is an incomplete source.

## Core output coverage and secondary reporting additions agreed

The researcher confirms no essential routinely used original-export output is
missing from the agreed core and asks whether other already calculated outputs
would be useful. The core remains:

- Per event: amplitude percent, duration, mean native area, diameter and circularity.
- Per site: event count and recurrence rate.
- Per recording: count, onset rate/density, tissue occupancy and normalized burden.
- Time courses: existing frame-level event counts/density and tissue coverage.

Automatic/review-applied values, inclusion/review/availability flags, biological
identity, calibration/acquisition provenance and optional treatment/phase
annotations remain as agreed. Detailed legacy formats stay available. The
[original Science paper's figure captions](https://pubmed.ncbi.nlm.nih.gov/38547288/)
confirm these core event, recurrence, coverage and burden output families
(Figures 2 and 4). The researcher agrees to the source-based reporting additions
below and requests review. They are **agreed reporting requirements**, not new
scientific methods or paper requirements. At that review, implementation was held
and no workbook, measurement or calculation had changed.

### Agreed secondary output: saved burden time course

The existing createHypoxicBurdenMetrics.m:253-384 produces
HypoxicBurdenOverTime and HypoxicBurdenPerMm2OverTime, exported by
writeHypoxicBurdenWorkbookSheets.m:31-32. The area-normalized saved series is to
be included alongside phase annotations for external postprocessing.

Its source definition spreads each event's existing contribution uniformly
across its exported duration, summing active contributions. It is a derived
composite time course, not a measurement of continuously changing optical depth
or native area in each frame. HypoxicBurdenPerMm2OverTime is area-normalized to
1 mm2 with units percent * um2 / mm2; it is not a per-minute recording total.
Do not apply an additional time-rate factor to each displayed point. The
existing complete recording total keeps its original area/time normalization.
No phase-specific totals, extra integration or new sums are proposed here.

Copy only the matching saved source/version, preserving automatic/reviewed
identity, numerical missingness and recording-level completeness. Unavailable
active contributions must not be filled, interpolated or skipped to claim a
complete result. Do not invent a zero time course for missing positive-event
inventory. No saved trace was opened or availability/reconciliation tested.

### Agreed secondary output: saved signed optical integral

finalizeOxygenEventMeasurements.m:89-93 already computes the fixed-footprint raw
relative signal d=(I-B)/B and SignedTraceAUC_sec=sum(d)/fs. This event descriptor
uses the full saved interval and can complement an extremum and duration.
Its units are fraction * seconds: signal-reference normalized and integrated
with the saved sampling interval. Do not divide an intrinsic event integral by
recording area/time or silently relabel it percent-seconds. Preserve its sign;
above-reference/rebound portions can offset below-reference portions. It is
separate from amplitude * mean area * duration burden.

It needs its own reference value/mode/window/version and availability flag.
The stored automatic integral uses the original strict baseline path; selecting
a pre-episode or reviewed amplitude does not automatically update that integral.
Do not assume it shares the selected burden amplitude's reference, recompute it
inside the compact exporter, or manufacture a reviewed integral when none is
saved. Align source meaning or retain unavailable/different-reference status.
The reporting agreement does not authorize a new baseline-integral method.

### Agreed automatic QC context: native detection gaps at the same site

annotateOxygenEventRecurrence.m:8-23 saves PreviousNativeGapSec,
NextNativeGapSec and close-native-run flags. Gap seconds are
(next native start - preceding native end - 1) / fs. This can help describe
clustering or review possible fragmentation, but is not physiological recovery
time or proof that detections represent independent pocket episodes. It is a
time-calibrated source-local gap, with no extra recording-area/time division.
First/last-event gaps with no neighbor are not applicable. Retain this as
automatic QC/reference context, not as a primary biological endpoint.

### Source-review findings and reporting safeguards

1. **A reviewed table can contain an automatic integral.**
   createBOIReviewedBurdenMetrics.m:60-65 preserves automatic event columns.
   applyBOIReviewedBurdenEvents.m:29-30,47-60 updates the burden ingredients but
   does not update SignedTraceAUC_sec. Its presence in a reviewed workbook must
   not be labelled a reviewed/new-reference integral. Keep the original value
   with its own reference/window/footprint/version; a different selected burden
   reference is a qualification, not a reason to erase the saved original.
   A genuinely missing reviewed integral remains unavailable. Exploratory
   ReviewedOpticalIntervals.csv values must not be promoted to an accepted
   reviewed quantity merely because they contain an integral scalar.
2. **Use the actual saved reviewed time course.**
   applyBOIReviewedBurdenEvents.m:68-72 retains automatic StartFrame/EndFrame
   evidence while providing BurdenStartFrame/BurdenEndFrame and a newly derived
   upstream TimeSeriesTable for approved reviewed ingredients. Copy the latter
   from the selected compatible saved snapshot; do not rebuild it from original
   automatic bounds or substitute the automatic curve under a reviewed label.
   ReviewedHypoxicBurden.xlsx and HypoxicBurden_TimeSeries.csv are existing
   reviewed-export routes (exportBOIReviewedBurden.m:20-32).
3. **Keep automatic gaps automatic.** Native-gap fields describe the original
   detection inventory and native bounds. Manual exclusions, reviewed onsets or
   recovered endpoints do not convert them into gaps between reviewed pockets.
   Carry the saved close-gap threshold/version if the close-run flag is shown.
   Do not infer recovery, merge events or recompute a reviewed gap in the exporter.
4. **Keep normalization and numerical states field-specific.** The saved
   area-normalized burden signal is percent * um2 / mm2 at each time point;
   signed optical integral is fraction * seconds; native gap is seconds. Use
   ordinary numeric cells and explicit units, not Excel percentage formatting.
   Preserve finite negative integrals. No second factor of 100, extra A/T
   division, absolute-value conversion, zero fill or interpolation is adopted.
5. **Retain completeness independently of finite curve points.** Some saved
   time points can be finite while a recording total is unavailable. Keep that
   total unavailable, with its existing reason/counts; do not integrate only
   finite samples to produce a replacement total. Missing positive-event source
   inventory or an absent curve is not a zero-event recording. Copy full clock,
   source, support and original/reviewed membership identity with the curve.
6. **Keep event signs separate.** The hypoxic composite time course is sink-only;
   surge composite cells are not applicable. Signed optical integrals may be
   copied for either sign only where that source provides them. Native-gap QC
   is available only for the event type/source that actually saved those fields.

For later finite acceptance, a complete saved normalized time course should
reconcile with its matching recording burden using the same frame intervals,
area and event membership: sum(area_normalized_signal * 1/fs) * 60/T equals the
recording per-mm2-per-minute total under that source definition. Use inclusive
frame intervals and the saved full recording T; treating start timestamps as
trapezoid endpoints can change edge weighting. This is a future acceptance
condition inferred from source formulas, **not a numerical check performed now**.
AUC source-value/reference identity and unchanged native-gap context likewise
need future finite checks. Keep these within the existing scenario/execution
limits; do not silently add a broader test or recording campaign.

No new numerical error in the original scientific calculations is demonstrated
by this review. It identifies source/label compatibility risks. No data/result
payload, MATLAB, numerical test, calculator or export was run. The source review
supports the reporting additions with these safeguards; it does not certify
reference suitability, anatomical masks or cross-recording biological equivalence.

### Other calculated families retained in detailed exports

Do not elevate filled-area/perimeter variants, end-versus-start size modulation,
rank-amplitude burden, detector z scores, CV or entropy to compact primary
outputs merely because they are calculated. They add either overlapping shape
information or source/method-dependent exploratory meaning. FOV-divided event
area describes relative field occupancy, not an intrinsic size correction.
Peak area remains deferred. This recommendation removes no existing output.

The source review recorded technical questions for the proposed verification:
reconcile version coverage;
assess native event versus eligible-tissue spatial support; retain native-area
versus extended-time qualifications; establish recording/window ingredient
identity before equating composites; and reconcile definitions/source versions.
The review did not certify a numerical error or data comparability. At that stage,
the added reporting metadata and secondary fields still required reconciliation
with the bounded plan before execution.

The researcher settled the reporting requirements in that review. Its remaining
source and verification concerns went into the bounded planning record. Agreement
to reporting fields did not authorize implementation, MATLAB, tests, source-data
reads, recalculation or export. No such execution occurred during the review.

## Workflow and execution boundaries

Use the existing batch and Stats/export services. One compact-export action,
a new destination filename, the remembered review selection/version with a
change option, and direct access to the resulting file. No additional mandatory
review of every event. Preserve selection on cancel/error and restore controls.
Keep the detailed legacy workbook, companion CSV/MAT files and prior results.
Save a new snapshot with its own receipt and source identities. No macros,
external workbook links, merged data cells or duplicated scientific Excel
formulas. Original export formats/calculations stay available.

Baseline integration BREF-01 through BREF-05 was completed under the former sign
eligibility, as recorded in the [bounded baseline plan](BOI_EVENT_BASELINE_FLAGS_PLAN.md)
and its delivery. Its historical cap remains four
active hours, three batches, one repair, twelve constructed scenarios/24
executions, at most 48 existing synthetic regression evaluations, two MATLAB
starts, one predefined saved-trace comparison plus one retry, 2 GiB RSS and
100 MiB evidence, shared with BREF-05. These are spent-work limits, not fresh
allowances; no individual examples are revisited. Signed-inclusion adoption was
subsequently explicitly approved and completed under its separate bounded scope.
No further effort, source, repair or execution allowance follows automatically.

### Historical compact-export proposal and verification limits

This is the proposal for CEX-01 through CEX-04 before approval. See the core and
saved-batch delivery records above for the checks actually run.

| Item; owner root | Scope and planned acceptance |
| --- | --- |
| CEX-01 | Freeze the six core sheets and optional supplied Phases metadata mapping, including multi-mouse/multi-condition identity, paired automatic/reviewed signed values and sign flags, reference versions and zero/missing/excluded states. Reconcile added reporting requirements within the held bounded plan; stop on conflicting source authority. |
| CEX-02 | Implement saved-value projection and writing. One original detection row, separate automatic/reviewed fields, exact compatible burden sources, retained metadata and precision. No scientific calculator called. |
| CEX-03 | Connect the existing GUI action, remembered per-batch review selection, visible version/change option, source compatibility and cancel/failure recovery. |
| CEX-04 | Finite preservation/usability checks, source immutability and short usage record. Within existing scenario limits, include signed-value/flag preservation, saved-curve/total reconciliation, integral source/reference identity and unchanged automatic-gap context. Use constructed/table-level checks, no individual biological examples. Then stop; no next campaign starts automatically. |

The original proposed limits were six active hours, four batches, two routine
repairs, eight constructed scenario families/at most 24 executions, two MATLAB starts,
at most four named-workbook export attempts, 4 GiB RSS, 100 MiB evidence and
25 MiB new compact-workbook output. Planned scenarios cover: multi-recording/
multi-mouse/multi-condition identity with repeated local IDs; true empty versus
missing data; signed inclusion/negative flags, missing ingredients and strict burden; original/derived/reviewed
references; duplicate/conflicting keys or source versions; typed IDs/units/
precision/provenance; six-core-plus-optional-Phases reader/field restrictions; existing GUI saved-
source route and file/selection behavior. Paired reviewed cases use constructed
saved fixtures, not a new cohort run.

The earlier planning review named the single-recording `FilteredData_input.xlsx`
files for FB2412 and FB2413, indexed in the [planning inventory](../../reference-validation/boi-calculation-export-plan-20261111/evidence-inventory.json).
The previous read-only review opened their three selected measurement sheets;
the other mappings are planned checks, not completed workbook verification.
A constructed multi-recording case must include the same mouse across different
conditions, multiple mice within a condition and repeated site/event IDs.
The proposal specified `1e-10 * max(1,abs(source))` for export round trips and
exact agreement for identities, counts and statuses. These checks were outside
the planning review itself.

Five reserved recordings remain excluded from development fixtures. The planning
scope excluded the existing 17-recording workbook, raw movies and reserved
payloads. A later user-requested full-batch export is a separate execution/data-use
step. The planning scope also excluded package installation, platform migration,
detector revision, Git transport, release, publication and new inferential analysis.
