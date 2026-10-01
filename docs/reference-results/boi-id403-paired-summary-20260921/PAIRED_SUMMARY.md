# ID403 awake and isoflurane: paired descriptive summary

21 September 2026 · R1-ID403-AWAKE-RUN-103 / R1-ID403-ISO-RUN-104 / R4-ID403-DESCRIPTIVE-105

Both ID403 recordings now have separately accepted working tissue outlines and verified current-method runs. These paired values describe one mouse with one recording per state. They do not establish a population or causal effect.

The working window is full frames 1–600 in each state, modeled [0,600) seconds (10 minutes) at externally triggered exact 1 Hz. Frame 1 is modeled time 0. Final cohort window approval remains separate. Pre-recording state establishment may be unmeasured; no in-file induction or invented numerical wash-in requirement is imposed.

## Recording-level activity

Differences are isoflurane minus awake. Coverage is native union area-time divided by analyzed tissue-time. Concurrency uses saved event durations, which may differ from native runs. Saved signs remain separate.

| Saved sign | Measure | Awake | Isoflurane | Difference |
|---|---|---:|---:|---:|
| sink | Event onsets (count) | 123 | 69 | -54 |
| sink | Onsets / mm² / min | 2.819 | 1.511 | -1.308 |
| sink | Mean occupied tissue (%) | 0.328 | 0.063 | -0.264 pp |
| sink | Mean concurrent events / mm² | 0.533 | 0.187 | -0.346 |
| surge | Event onsets (count) | 20 | 6 | -14 |
| surge | Onsets / mm² / min | 0.438 | 0.123 | -0.315 |
| surge | Mean occupied tissue (%) | 0.333 | 0.057 | -0.277 pp |
| surge | Mean concurrent events / mm² | 0.118 | 0.026 | -0.093 |

## Denominators and availability

Separate source-specific masks retain dark interior tissue and documented edge uncertainty. Analyzed area also depends on the sign-specific support rules. Each recording keeps its own denominator; anatomical pixel correspondence between states is not assumed.

| State | Sign | Area (mm²) | Tissue-time (mm²·min) | Finite / all amplitudes | Negative finite amplitudes | Unavailable-only share of covered area-time (%) |
|---|---|---:|---:|---:|---:|---:|
| awake | sink | 4.363926 | 43.639259 | 60/123 | 0 | 37.6 |
| awake | surge | 4.564755 | 45.647548 | 11/20 | 0 | 47.5 |
| isoflurane | sink | 4.567846 | 45.678458 | 52/69 | 0 | 43.3 |
| isoflurane | surge | 4.878757 | 48.787571 | 5/6 | 0 | 14.5 |

Missing amplitudes retain events and native coverage. Negative values remain signed. The sink amplitude–area–time composite remains unavailable in both states; no finite-subset sum represents total burden. A surge composite is not defined.

## Event descriptions and conditional optical measurements

Duration and area medians use all saved events. Amplitude and integral medians use only finite measurements, with their sample counts above. Events are within-recording observations, not independent animal replicates. Availability differs between states, so finite optical subsets cannot stand for all activity or an unbiased state contrast.

| State | Sign | Median saved duration (s) | Median mean native event area (µm²) | Median finite amplitude (%) | Median finite signed integral (fraction·s) |
|---|---|---:|---:|---:|---:|
| awake | sink | 8.0 | 7306.9 | 6.939 | -0.3412 |
| awake | surge | 13.5 | 25149.1 | 2.974 | 0.0213 |
| isoflurane | sink | 6.0 | 5204.4 | 4.855 | -0.1553 |
| isoflurane | surge | 10.5 | 18467.5 | 1.373 | 0.0058 |

Optical measures use the preserved-input fixed native-union footprint mean and the original full 20-sample native-screened pre-event reference. Sink amplitude is −min((raw−B)/B), surge amplitude is max((raw−B)/B), and the integral retains the sign of (raw−B)/B. These are relative optical measures, not calibrated oxygen concentration. Original recording-specific correction remains unchanged, without assuming a universal substrate decline. ID403 uses its own 4.75 µm/pixel calibration; the same parameter factory retains pixel-based defaults and converts the physical surge-area minimum. Its numeric parameter struct is not copied from the 2.35 µm/pixel FB recordings. Researcher-reviewed FB2314 alternatives remain separate and are not transferred.

## Interpretation and limits

Biological variability cannot be estimated from one pair alone. FB2314, FB2315, ID402 and ID403 retain separate mouse-level results; no pooled event-level inference is introduced. Current imperfect automatic labels remain accepted for proceeding. No significance test, confidence interval, new scientific exclusion or detector tuning is added.

Acquisition-frame-1 onsets remain included under the existing descriptive policy (awake sink: 1; awake surge: 0; isoflurane sink: 0; isoflurane surge: 0). Their physiological onset may predate recording. Endpoint censoring, camera exposure, pre-source intensity history and dynamic frame validity remain unresolved. Full-window use is a working descriptive assumption, not a claim that every frame is physiologically valid.

## Verification and traceability

Saved-table aggregation checks cover all 2,400 sign/frame rows and 218 events across the pair. Phases 103 and 104 each include the source-amplitude audit and independent native-support, frame-timing and selected source-trace replay. Numerical agreement does not certify physiological event identity.

Exact values, denominators, missingness reasons and source/table hashes are in paired-summary.json. paired-verification.json records aggregation checks; each run’s verification.json records its independent replay. Source identities, original filenames, support decisions, effective settings and full local output hashes remain traceable. MATLAB recipes in the portable packet use .m.txt to keep archived recipes outside executable code discovery.

Next, prepare source-specific tissue support for the remaining C02 pairs: FB2312, ID400 and ID401. Final outcomes, windows, measurement admission, animal-level weighting, missingness and inference remain open. Further detector diagnostics are not a default prerequisite.
