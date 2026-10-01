# Representative BOI MATLAB workflow

10 September 2026. R0/R5 development walkthrough and implementation audit.
This does not close the researcher release walkthrough or biological validation.
Read alongside the [measurement dictionary](BOI_MEASUREMENT_DICTIONARY.md),
[plan](REANALYSIS_UPDATE_PLAN.md), [resolution record](BOI_COHORT_RESOLUTION.md)
and [researcher contract](RESEARCHER_WORKFLOW_AND_TRACEABILITY.md).

## Case and decision before execution

Use ID400 / M400-01-baseline-awake, asset
`8ba82dc1-aaba-411d-a196-ff8ef0b61fc3`, selected series
`/acquisition/1hz_mcor.tif`: all 600 frames, 512 × 512 pixels, 1 Hz,
4.75 µm/pixel. Source identity and conversion evidence are in
`reference-set-phase1.json` and the existing phase-1 conversion report. The
converted TIFF checksum is fixed by the runner. This is a local TIFF import
from DANDI, not an independent non-DANDI acquisition transfer test. No fresh
NWB conversion/equivalence check is claimed.

This animal and recording were already used for development. This walkthrough
adds whole-movie detection/measurement/export inspection and one event trace
inspection to that history. Neither this recording nor another recording from
this animal may subsequently be called an untouched animal-level evaluation.
Selection is for a tractable, known complete workflow, not representation of all
biological signal families, experimental states or acquisition variants.

Decision: identify gaps in source-to-result explanation and confirm that saved
ingredients reproduce existing calculations. Freeze the current detector and
measurement settings; no parameter tuning or method comparison. Use one master
run and two statistics runs, with only the diagnostic analysis window changed.
The second window is fixed at [30,600) seconds before reading outcomes; it has
no experimental interpretation. Select the first finite sink amplitude in saved
row order as the worked event, while retaining all-event availability for both
signs. This example selection cannot establish typical amplitude validity.

Arithmetic acceptance: absolute error ≤ 1e-12 + 1e-10 × absolute reported value
for occupancy fraction, baseline, amplitude fraction and signed integral.
CSV roundtrip must meet the same tolerance. This is a numerical replay tolerance,
not a proposed physiological accuracy threshold. Require unchanged event tables
between statistics runs, preserved run-A MAT checksum, matching dictionary in
source/workbook export, and unchanged MATLAB code checksums during execution.

Feasibility budget for this development pass: one full master and two stats
exports; a 600-second soft elapsed-time gate checked between costly stages;
5 GiB output review target; record process peak memory externally. No new
scientific detector iterations. The time gate does not interrupt a MATLAB stage,
and the storage target is reviewed after completion; neither is a hard resource
limit. Cohort runtime/memory/review limits still require an R3/R5 decision.
Failure preserves the partial output/report; fix a demonstrated execution defect
or restrict the walkthrough claim rather than retune biology.

## Reproduce in MATLAB

From the `existing-analysis` project folder:

```matlab
setupOxygenDynamicsPath;
addpath(fullfile(pwd,'tests','analysis'));
source = fullfile('..','reference-validation','phase1-optimized-20260909', ...
    'M400-01-baseline-awake','Recording','archive_original.tif');
% Choose a new absolute output directory; an existing directory is rejected.
output = fullfile(fileparts(pwd),'reference-validation','boi-workflow-new-run');
report = runBOIWorkflowWalkthrough(source,output);
```

This fixed-recording runner rejects a different TIFF checksum. It is development
evidence, not a generic researcher import tool. It copies the complete TIFF,
uses the public `runOxygenDynamicsMaster` and `runOxygenDynamicsStats` entry
points, and preserves prior automatic and curated outputs. Existing full
outputs are not used as fresh master results. The current GUI calls the same
master via the wrapper and the same statistics function; this establishes code
path reuse, not a completed GUI usability test.

## Source-to-result path and current limitations

| Researcher step | Current calculation/evidence | Walkthrough output or remaining gap |
|---|---|---|
| Import | `inspectOxygenTiffs`, `validateOxygenRecording`, `loadOxygenMasterInputs`; one non-denoised TIFF and optional separately named denoised TIFF; dimensions/calibration and input checksums | Byte-identical staged TIFF; portable archive ID and private source mapping; input review MAT. Source metadata conflicts/preprocessing history still need a normal readable import review. |
| Review | Resolution overlay preserves original/corrected metadata; this case uses known reference metadata | No unresolved metadata is guessed. Unknown prior intensity preparation and acquisition exposure remain explicit. Metadata validity alone is not scientific eligibility. |
| Configure | `createOxygenMasterParams`; wrapper supplies sampling and metadata, but scientific defaults are created in the master | Actual master parameters exported. Scientific default/override provenance is not yet unified; arbitrary context fields do not constitute supported parameter overrides. |
| Detect | Preserved TIFF → detrending for detection → spatial/temporal normalization and smoothing → per-frame threshold/shape/tissue filters → tracking/refinement, separately for both signs | Default filters retained. They condition observed distributions and require a biological variability challenge before validation acceptance. |
| Measure | `finalizeOxygenEventMeasurements` uses preserved input, union of native event footprints, pre-event baseline and saved event bounds | Event footprint indices and complete quantitative trace; baseline/event frame indicators; amplitude and signed-integral replay. Detection z-scores are not amplitude inputs. |
| Save | `saveOxygenMasterOutputs` saves native frame pixels, eligible tissue pixels, event/site tables, analysis parameters and checksums; surge candidate/contact ledgers survive | Raw/source paths and technical artifacts remain local. Master RecordingID is still a canonical directory path; stats remaps to the explicit portable CSV RecordingID. The mapping must not be confused with stable native run identity. |
| Summarize | Registry retains successful zero-event recordings. `createOxygenAnalysisWindows` combines native mask unions with static tissue area and frame-interval weights | Frame-by-frame covered area-time and valid tissue-time exported independently for numerical reproduction. Dynamic validity is not implemented by this walkthrough. |
| Inspect | First finite sink selected by row order, with full footprint and trace; all-event sink/surge QC retained | Static image/trace panel and readable guide. Normal GUI event-to-source navigation, baseline explanation and accessible decisions remain R5 work. |
| Export | Existing `MetricDefinitions`, `MetricBasis`, registry, QC, code contracts and manifests reused; shared dictionary adds BOI purpose, limits and status | Workbook `BOIMeasurementDictionary`, matching JSON and Markdown guide. Legacy guidance can still contain stronger recommendations; dictionary does not silently confer scientific acceptance on them. |
| Rerun | Second stats run changes only the diagnostic window, uses same master outputs, retains first run | `decision.json`, `window-comparison.csv`, before/after MAT hashes and event-table equality. This demonstrates a recorded setting change; manual curation actor/reason/history is not yet end-to-end. |

`portable-audit/` contains the numerical CSV ingredients, dictionary, event
inspection image, decision and compact report. `local-only/`, the staged
recording and ordinary statistics outputs retain private paths and input
metadata; do not publish the entire run directory by default. The portable
folder still contains the chosen research example and requires an intentional
sharing decision. Its portable IDs link to the local-only source map.

## Reproduce values without development history

For the selected event, read `event-trace-ingredients.csv`. Average
`ObservedMeanIntensity` where `IsBaseline` is true to obtain B0. Within `IsEvent`,
calculate q = (intensity − B0) / B0. Sink amplitude is −min(q); percentage is
100 times this fraction. The signed integral is sum(q)/1 Hz. Compare with the
reported fields in `walkthrough-report.json`. `event-footprint.csv` gives
one-based MATLAB linear image indices for checking the trace against the
preserved TIFF. Native support and refined event bounds remain distinct.

For the recording, sum `CoveredAreaTimeUm2Sec` in
`occupancy-ingredients.csv` and divide by the sum of
`ValidTissueTimeUm2Sec`. Overlapping native sink pixels count once and only
inside eligible tissue. This produces BOI-M01, not legacy `Burden_Occupancy`.
The runner reloads these CSV files and verifies numerical reproduction. A second
researcher has not yet independently performed this exercise.

The run also preserves native-union pixel counts before tissue intersection;
these explain why event footprints and coverage can differ. Absence of a
baseline measurement does not remove a detected event from descriptive counts.
Availability fractions accompany the worked example to make this visible.

## Assumptions requiring scientific decisions

| ID | Current assumption/evidence | Consequence and next decision |
|---|---|---|
| A01 / R1 | One uniform frame interval and a static intensity-derived tissue mask | Validate image timing, exposure and moving/border support before physiological exposure claims. Preserve unknown history; do not silently treat frame spacing as camera exposure. |
| A02 / R1–R3 | Smoothing half-width 10 pixels and sink border 20 pixels; at 4.75 µm/pixel these are 47.5 and 95 µm | Sampling-dependent support must be assessed across acquisitions, not tuned for count agreement. |
| A03 / R2–R3 | Sink candidate area 100–6400 pixels, circularity 0.3, duration settings 3–150 s; surge minimum area 9025 µm² and duration 10 s | Empirical selection, not biological limits. Test brief/sustained, irregular/spatially changing signals beyond boundaries; preserve losses as well as gains. Exact retention comparisons are implemented in filter helpers. |
| A04 / R2 | Baseline requests 20 clean preceding seconds on fixed native footprint; both detected signs contaminate it | Missing context remains unavailable; clean detection context does not prove unperturbed physiology. Do not move baseline to obtain expected direction. |
| A05 / R2–R4 | Trace-refined sink intervals, native surge timing, provisional site/identity rules; 20 s close-run review flag | Separate event count, native coverage, recurrence and recovery. Decide acquisition-start onset censoring and unresolved split/merge policy before primary-outcome admission. |
| A06 / R4 | Current group summary averages recordings within mouse then weights mice equally | Prespecify each comparison, pairing/order/exposure weighting, repeated measures, missingness and multiplicity. Primary hierarchy remains proposed. |
| A07 / R3–R5 | This is one familiar, complete archive-derived recording | Does not cover biological variability, local non-DANDI transfer, naive-user usability or held-out accuracy. Freeze evaluation roles before selecting additional cases. |

The standing cohort holds remain unchanged: four baseline records retain their
calibration/label holds; FB2315 identity follows folder/table evidence while
archive payload equivalence remains open; six KX pulse trains still require
image correspondence and trial QC; gas intervals are not approved windows;
FB2360 switch times remain unknown; calibration validity and preparation/control
questions remain open. Microspheres remain corrected to 4 µm. IOSI is excluded.

## Release gates not closed by this pass

A researcher unfamiliar with development must still complete the normal MATLAB
GUI import/review/run/inspect/export path, explain one QC issue and one summary,
and reproduce a value from exported ingredients. Include a genuinely local
non-DANDI acquisition and capture confusion, manual review time and failures.
Stable result/run identity and automatic/manual decision lineage must survive
all paths, including curation. Scientific acceptance, outcome selection,
independent evaluation roles, resource limits and final cohort eligibility
remain unresolved decisions under the original plan.

## Executed evidence

The [10 September execution record](reference-results/boi-workflow-20260910/README.md)
reports the complete recording's numerical replay, both-sign availability,
separate statistics-window run and resource observations. It also preserves a
presentation correction discovered during visual review. Technical success does
not promote any of the open scientific or researcher-usability gates.

## Subsequent R1 implementation

The [recording input/QC contract](BOI_RECORDING_INPUT_CONTRACT.md) now adds
normal-export denominator ingredients, a read-only MATLAB preflight, saved
acquisition declarations/unknowns and actionable QC. This advances some export
and import gaps identified above. The first walkthrough and its version 0.1
dictionary remain historical evidence; current dictionary version 0.2 and the
R1 verification do not retrospectively establish scientific validity.
