# FB2314 awake and isoflurane: paired descriptive summary

21 September 2026 · R4-FB2314-DESCRIPTIVE-093

**Both saved signs have fewer onsets per tissue-time under isoflurane. Surge coverage and concurrency are higher; sink coverage and concurrency are lower.** These are observations from one mouse with one recording per state, using automatic labels. They do not establish a population or causal effect.

The working window is the full 1,200 frames in each recording: modeled [0,1200) seconds (20 minutes), external trigger exactly 1 Hz, frame 1 at 0 seconds. This descriptive choice is not final C02 observation-window approval. No unmeasured pre-recording baseline is fabricated or required to appear inside the recording.

## Recording-level activity

Difference means isoflurane minus awake. Coverage is the native union area-time divided by analyzed tissue-time. Concurrency uses saved event durations, which can differ from native runs. Saved sink and surge labels remain separate.

| Saved sign | Measure | Awake | Isoflurane | Difference |
|---|---|---:|---:|---:|
| sink | Event onsets (count) | 305 | 203 | -102 |
| sink | Onsets / mm² / min | 21.339 | 14.568 | -6.772 |
| sink | Mean occupied tissue (%) | 0.500 | 0.449 | -0.052 pp |
| sink | Mean concurrent events / mm² | 4.261 | 2.147 | -2.114 |
| surge | Event onsets (count) | 41 | 33 | -8 |
| surge | Onsets / mm² / min | 2.831 | 2.306 | -0.525 |
| surge | Mean occupied tissue (%) | 2.244 | 3.217 | +0.973 pp |
| surge | Mean concurrent events / mm² | 0.770 | 1.059 | +0.289 |

## Denominators and availability

Each state uses its own accepted working outline. The analyzed area also depends on saved sign-specific support; it is not simply the polygon area. The area differences below are retained in normalization. No anatomical pixel correspondence between states is assumed. Dark interior tissue remains included and uncertain edges remain uncertain.

| State | Sign | Analyzed area (mm²) | Tissue-time (mm²·min) | Finite / all amplitudes | Negative finite amplitudes | Covered area-time attributable only to unavailable amplitudes (%) |
|---|---|---:|---:|---:|---:|---:|
| awake | sink | 0.714650 | 14.293003 | 143/305 | 1 | 56.0 |
| awake | surge | 0.724193 | 14.483861 | 10/41 | 2 | 77.6 |
| isoflurane | sink | 0.696752 | 13.935035 | 68/203 | 8 | 76.7 |
| isoflurane | surge | 0.715622 | 14.312442 | 9/33 | 0 | 84.6 |

Amplitude availability is limited and differs between states. Missing amplitudes retain their events and native coverage. No unavailable value becomes zero; negative finite values remain signed. The sink amplitude–area–time composite remains unavailable in both states; no finite-subset sum substitutes for total burden. No surge composite is defined.

## Event descriptions and conditional optical measurements

These medians describe events within each recording. They are not independent biological replicates. Duration and area use all saved events. Optical summaries use only the finite subset counted above and cannot represent all detected activity or an unbiased state contrast.

| State | Sign | Median saved duration (s) | Median mean native event area (µm²) | Median finite amplitude (%) | Median finite signed integral (fraction·s) |
|---|---|---:|---:|---:|---:|
| awake | sink | 10.0 | 1550.6 | 10.478 | -0.6428 |
| awake | surge | 13.0 | 25934.3 | 5.219 | 0.1946 |
| isoflurane | sink | 6.0 | 2046.1 | 7.504 | -0.0828 |
| isoflurane | surge | 20.0 | 28355.3 | 8.399 | 0.6822 |

Amplitude and signed integral retain the existing preserved-input footprint trace, original reference denominator, and full 20-sample native-screened pre-event reference. For sinks amplitude is −min((raw−B)/B); for surges it is max((raw−B)/B). The integral keeps the sign of (raw−B)/B. These are optical measures, not calibrated oxygen concentration. Researcher-adjusted example boundaries/references remain a separate branch and do not overwrite these automatic summaries.

## Interpretation and limits

Fewer surge onsets can coexist with greater native coverage and longer aggregate saved event time. This pair therefore illustrates why activity should not be reduced to an event count alone. Biological variability cannot be estimated from this one mouse. No significance test, confidence interval, new exclusion, detector threshold, baseline correction or substrate-decline model is introduced.

Onsets at acquisition frame 1 remain included under the existing descriptive policy: awake sink 3, awake surge 1, isoflurane sink 1, isoflurane surge 2. Their physiological onset may predate the recording. Endpoint censoring, unknown camera exposure, unmeasured pre-source intensity history and static tissue/frame-validity assumptions remain unresolved. The full interval is not a declaration that every frame is physiologically valid.

## Traceability and next step

The reproducible `summarize.py` reads the phase-033 awake and phase-092 isoflurane audit tables. `paired-summary.json` contains exact values, denominators, missingness reasons, source/movie and MATLAB-output identities, plus SHA256 hashes for every table read. `verification.json` records aggregation checks for all 4,800 sign/frame rows and 582 saved event rows. The previous all-event source-amplitude audits remain the source-level verification; this step does not rerun detection or reopen event recognition.

The method settings match across states. MATLAB code and all prior results are preserved. The remaining six candidate pairs keep their existing eligibility status. Next, extend the same working method to the next C02 pair, beginning with the existing FB2315 recording-specific outline proposals. Final cohort windows, primary outcomes, animal-level weighting, missingness and inference remain decisions for the cohort analysis.

[Exact results and provenance](reference-results/boi-fb2314-paired-summary-20260921/paired-summary.json). [Aggregation verification](reference-results/boi-fb2314-paired-summary-20260921/verification.json).
