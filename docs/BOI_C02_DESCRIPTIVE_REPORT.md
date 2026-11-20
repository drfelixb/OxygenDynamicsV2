# C02 paired descriptive results and methods

21 September 2026 · R4-C02-DESCRIPTIVE-120 · Working descriptive report

## Scope and decision record

Following the phase-119 overview and proposal, the researcher instructed **“go on”**. This authorizes continuation with the stated working descriptive package: full stored intervals, the existing two candidate sink outcomes, equal-mouse contrasts and paired figure. It is not recorded as approval of a final confirmatory statistical plan or all BOI release gates. The phase-119 proposed sheet remains preserved. No prospective or untouched-validation claim is made.

Seven mice contribute one awake and one isoflurane recording each. Sink coverage and detected onset rate are lower in isoflurane in every pair. Surge coverage rises in the three FB pairs and falls in the four ID pairs. These are within-mouse descriptive observations conditional on the working detector. The acquisition-scale and duration split between FB and ID mice prevents interpreting that split alone as a biological subgroup effect.

## Paired figure

![Seven mouse pairs](reference-results/boi-c02-descriptive-report-20260921/paired-results.png)

**Figure 1.** Each colored line joins one mouse’s awake and isoflurane values. Circles identify FB mice (20 minutes/state; 2.35 µm/pixel), squares identify ID mice (10 minutes/state; 4.75 µm/pixel). The black dashed line and diamonds show equal-mouse state means; their difference equals the mean of the seven within-mouse differences. Coverage is expressed in percent; its change is in percentage points. There are no confidence intervals or significance tests. Axes start at zero and use panel-specific scales.

## Equally weighted contrasts

For each metric, subtract awake from isoflurane within each mouse, then average the seven differences with weight 1/7 each. Means use each recording’s own sign-specific exposure normalization first. Do not combine events or tissue-time across mice to compute these means. All seven pairs have finite coverage/rate/concurrency values. Count contrasts retain the unequal recording-duration limitation.

| Sign | Measure | Awake mean | Isoflurane mean | Mean paired change | Individual change range |
|---|---|---:|---:|---:|---:|
| sink | Count (events/recording) | 218.857 | 118.571 | -100.286 | -204.000 to -43.000 |
| sink | Detected onsets (events/mm²/min) | 9.994 | 5.683 | -4.310 | -9.832 to -1.308 |
| sink | Coverage (%; change in pp) | 0.487 | 0.230 | -0.257 | -0.600 to -0.052 |
| sink | Concurrent density (events/mm²) | 2.102 | 0.958 | -1.144 | -2.437 to -0.312 |
| surge | Count (events/recording) | 42.571 | 19.571 | -23.000 | -71.000 to +7.000 |
| surge | Detected onsets (events/mm²/min) | 1.635 | 0.959 | -0.676 | -1.990 to +0.268 |
| surge | Coverage (%; change in pp) | 1.488 | 1.633 | +0.145 | -3.016 to +3.272 |
| surge | Concurrent density (events/mm²) | 0.432 | 0.534 | +0.102 | -0.561 to +0.827 |

The individual change range shows observed heterogeneity; it is not a confidence interval. Exact values and all individual contrasts are saved in descriptive-contrasts.json.

## Recording-level companion measurements

Duration and area medians summarize all saved events within each recording. Optical medians use only finite subsets. No equal-mouse optical contrast is presented as a substitute for complete event availability.

| Mouse | State | Sign | Events | Median duration (s) | Median native event area (µm²) | Finite amplitude / total | Median amplitude (%) | Median signed integral (fraction·s) |
|---|---|---|---:|---:|---:|---:|---:|---:|
| FB2312 | awake | sink | 309 | 9.000 | 1779.626 | 157/309 | 9.417 | -0.492 |
| FB2312 | awake | surge | 35 | 12.000 | 25888.375 | 14/35 | 7.823 | 0.463 |
| FB2312 | isoflurane | sink | 219 | 6.000 | 1449.104 | 89/219 | 3.349 | -0.093 |
| FB2312 | isoflurane | surge | 42 | 14.000 | 21414.647 | 17/42 | 2.646 | 0.059 |
| FB2314 | awake | sink | 305 | 10.000 | 1550.595 | 143/305 | 10.478 | -0.643 |
| FB2314 | awake | surge | 41 | 13.000 | 25934.291 | 10/41 | 5.219 | 0.195 |
| FB2314 | isoflurane | sink | 203 | 6.000 | 2046.086 | 68/203 | 7.504 | -0.083 |
| FB2314 | isoflurane | surge | 33 | 20.000 | 28355.276 | 9/33 | 8.399 | 0.682 |
| FB2315 | awake | sink | 366 | 13.000 | 1616.126 | 190/366 | 13.383 | -0.871 |
| FB2315 | awake | surge | 58 | 15.000 | 23621.621 | 23/58 | 6.207 | 0.361 |
| FB2315 | isoflurane | sink | 162 | 8.000 | 1612.649 | 54/162 | 4.594 | -0.190 |
| FB2315 | isoflurane | surge | 46 | 18.000 | 17065.281 | 16/46 | 0.154 | -0.111 |
| ID400 | awake | sink | 192 | 11.000 | 7193.677 | 94/192 | 8.176 | -0.538 |
| ID400 | awake | surge | 54 | 12.000 | 30039.713 | 27/54 | 3.153 | 0.210 |
| ID400 | isoflurane | sink | 89 | 8.000 | 5557.896 | 64/89 | 4.685 | -0.176 |
| ID400 | isoflurane | surge | 3 | 13.000 | 36660.302 | 1/3 | 0.864 | -0.044 |
| ID401 | awake | sink | 96 | 7.000 | 5960.260 | 50/96 | 4.865 | -0.161 |
| ID401 | awake | surge | 17 | 12.000 | 25775.400 | 12/17 | 4.346 | 0.182 |
| ID401 | isoflurane | sink | 53 | 6.000 | 6105.413 | 37/53 | 5.086 | -0.188 |
| ID401 | isoflurane | surge | 5 | 15.000 | 41840.545 | 1/5 | 0.850 | -0.099 |
| ID402 | awake | sink | 141 | 12.000 | 6877.050 | 44/141 | 10.754 | -0.694 |
| ID402 | awake | surge | 73 | 13.000 | 32713.369 | 23/73 | 3.329 | 0.135 |
| ID402 | isoflurane | sink | 35 | 8.000 | 4219.188 | 33/35 | 3.211 | -0.100 |
| ID402 | isoflurane | surge | 2 | 10.500 | 15897.640 | 2/2 | 1.618 | 0.061 |
| ID403 | awake | sink | 123 | 8.000 | 7306.866 | 60/123 | 6.939 | -0.341 |
| ID403 | awake | surge | 20 | 13.500 | 25149.129 | 11/20 | 2.974 | 0.021 |
| ID403 | isoflurane | sink | 69 | 6.000 | 5204.417 | 52/69 | 4.855 | -0.155 |
| ID403 | isoflurane | surge | 6 | 10.500 | 18467.527 | 5/6 | 1.373 | 0.006 |

## Methods draft

**Inputs and timing.** BOI recordings from FB2312, FB2314, FB2315 and ID400–ID403 were paired by mouse and recorded state. The source identities, filename corrections, archive/local equivalence evidence, source-specific tissue outlines and execution records were inherited from the seven verified current-method pair exports. No new source conversion or detection was performed for this report. The external trigger sets sampling to exactly 1 Hz; embedded recording timestamps do not define analysis time. Frame 1 is modeled time 0 s. All 1,200 FB frames or 600 ID frames were used, corresponding to [0,1200) or [0,600) s. The isoflurane state was established before recording; the preceding unmeasured period is not an in-file baseline or a recoverable induction interval. Camera exposure and unresolved pre-source processing remain unknown.

**Detection and spatial support.** The existing detector, recording-specific correction and parameter factory were retained with the accepted craniotomy support for each source. Dark interior tissue and uncertain/clipped boundaries remained represented. Sink and surge results were kept separate with their saved sign-specific effective analysis areas. Native spatial calibration was 2.35 µm/pixel for FB recordings and 4.75 µm/pixel for ID recordings. Pixel-based defaults therefore have different physical scales; the factory’s physical surge-area minimum conversion was retained. No cross-recording outline transfer, acquisition-specific retuning or universal substrate-consumption model was introduced. Effective settings and code hashes remain in the source run exports linked by the consolidated provenance.

**Coverage, onsets and concurrency.** For each sign, occupied-tissue fraction equals native union covered area-time divided by valid effective tissue-time, multiplied by 100 for percent. Overlapping native events contribute only once to coverage. Detected onset rate equals saved event onsets in the working interval divided by effective tissue-time in mm²·min. Frame-1 detections remain included and their counts are available separately; their physiological onset may predate observation. Concurrent-event density sums saved event duration overlap and divides by effective tissue-time in mm²·s, yielding events/mm². It does not use native mask union coverage. Saved durations are inclusive: (end frame − start frame + 1)/1 Hz. Native event area is the active-frame mean native support area; it is distinct from the fixed union optical footprint. Existing event-area summaries are not tissue-intersected in the same way as occupancy. Truncation and boundary uncertainty remain; saved duration is not a physiological recovery estimator.

**Optical measurements and missingness.** For each saved event, quantitative intensity is the preserved-input mean over its fixed native-union footprint. The original full immediate 20-sample native-screened pre-event reference B is retained. With relative signal r=(I−B)/B, sink amplitude is −min(r), surge amplitude is max(r), and the signed integral retains the sign of r using the existing saved calculation. Reported amplitudes are percentages and integrals are fraction·seconds. Insufficient clean reference context produces an unavailable optical measurement, with no fallback or imputation. Those events remain in counts and coverage. Negative finite amplitudes remain present. The finite/total counts, baseline-status reasons and unavailable coverage share are retained for every recording/sign. All sink amplitude–area–time composites are unavailable for these recordings; no surge composite is defined. The original automatic branch is used throughout; researcher-reviewed event intervals and local references remain a separate exploratory branch.

**Animal aggregation.** Each mouse contributes one paired difference per complete metric. The cohort descriptive contrast is the arithmetic mean of those seven differences, with equal animal weight. No event-weighted or exposure-weighted animal pooling is used. The existing candidate sink outcomes are coverage and detected onset rate; surge and companion outputs remain separate descriptive results. No p-values, confidence intervals, multiplicity adjustment or causal effect estimates are calculated.

## Interpretation limits and remaining decisions

The detector is useful but imperfect, and its events are not certified physiological truth. Awake-first order, recording-specific trends, spatial resolution, source processing and support uncertainty limit attribution of state differences. Full intervals are matched within mouse but differ across mice; rate normalization does not establish temporal stationarity. Optical subsets differ in availability and cannot represent every event or calibrated oxygen concentration. Recurrence/site history stays available in source-local exports; neither a cohort recurrence estimator nor physiological recovery is frozen here.

These data have publication/development exposure, and these analysis choices follow inspection. Final confirmatory outcome status, uncertainty and multiplicity choices remain open. This report completes the authorized working descriptive C02 package, not the full BOI reanalysis or final release. Other comparison families, the independent researcher walkthrough/second-person replay and final versioned code/settings/input freeze remain on the project closure checklist.

## Reproduction and evidence

Run build_report.py with Python 3 to reproduce JSON and readable results from the checksum-linked phase-119 export. Run plot_pairs.m in MATLAB R2025a to export the PNG/SVG figure from figure-data.json. The portable archive stores that recipe as plot_pairs.m.txt; copy it as plot_pairs.m beside the two JSON inputs in a separate output folder before running it. The plotting script checks its points against descriptive-contrasts.json and exports figure-verification.json. The packet retains software versions, visual review and the previous artifact chain. All 495 analysis MATLAB files remain unchanged. These checks establish calculation/provenance agreement, not detection accuracy.

[Exact contrasts](reference-results/boi-c02-descriptive-report-20260921/descriptive-contrasts.json). [Vector figure](reference-results/boi-c02-descriptive-report-20260921/paired-results.svg). [Per-mouse exposure and provenance](BOI_C02_MOUSE_SUMMARY.md). [Measurement dictionary](BOI_MEASUREMENT_DICTIONARY.md).
