# ID400 awake and isoflurane: paired descriptive summary

21 September 2026 · R1-ID400-AWAKE-RUN-112 / R1-ID400-ISO-RUN-113 / R4-ID400-DESCRIPTIVE-114

Both ID400 recordings now have separately accepted working tissue outlines and verified current-method runs. These paired values describe one mouse with one recording per state. They do not establish a population or causal effect.

The working window is full frames 1–600 in each state, modeled [0,600) seconds (10 minutes) at externally triggered exact 1 Hz. Frame 1 is modeled time 0. Final cohort window approval remains separate. Pre-recording state establishment may be unmeasured; no in-file induction or invented numerical wash-in requirement is imposed.

## Recording-level activity

Differences are isoflurane minus awake. Coverage is native union area-time divided by analyzed tissue-time. Concurrency uses saved event durations, which may differ from native runs. Saved signs remain separate.

| Saved sign | Measure | Awake | Isoflurane | Difference |
|---|---|---:|---:|---:|
| sink | Event onsets (count) | 192 | 89 | -103 |
| sink | Onsets / mm² / min | 4.740 | 2.206 | -2.534 |
| sink | Mean occupied tissue (%) | 0.610 | 0.090 | -0.519 pp |
| sink | Mean concurrent events / mm² | 1.029 | 0.321 | -0.708 |
| surge | Event onsets (count) | 54 | 3 | -51 |
| surge | Onsets / mm² / min | 1.244 | 0.068 | -1.176 |
| surge | Mean occupied tissue (%) | 1.104 | 0.083 | -1.021 pp |
| surge | Mean concurrent events / mm² | 0.300 | 0.024 | -0.276 |

## Denominators and availability

Separate source-specific masks retain dark interior tissue and documented edge uncertainty. Analyzed area also depends on the sign-specific support rules. Each recording keeps its own denominator; anatomical pixel correspondence between states is not assumed.

| State | Sign | Area (mm²) | Tissue-time (mm²·min) | Finite / all amplitudes | Negative finite amplitudes | Unavailable-only share of covered area-time (%) |
|---|---|---:|---:|---:|---:|---:|
| awake | sink | 4.050555 | 40.505554 | 94/192 | 0 | 67.2 |
| awake | surge | 4.339852 | 43.398517 | 27/54 | 0 | 53.6 |
| isoflurane | sink | 4.034423 | 40.344232 | 64/89 | 0 | 34.1 |
| isoflurane | surge | 4.381119 | 43.811186 | 1/3 | 0 | 85.8 |

Missing amplitudes retain events and native coverage. Negative values remain signed. The sink amplitude–area–time composite remains unavailable in both states; no finite-subset sum represents total burden. A surge composite is not defined.

## Event descriptions and conditional optical measurements

Duration and area medians use all saved events. Amplitude and integral medians use only finite measurements, with their sample counts above. Events are within-recording observations, not independent animal replicates. Availability differs between states, so finite optical subsets cannot stand for all activity or an unbiased state contrast.

| State | Sign | Median saved duration (s) | Median mean native event area (µm²) | Median finite amplitude (%) | Median finite signed integral (fraction·s) |
|---|---|---:|---:|---:|---:|
| awake | sink | 11.0 | 7193.7 | 8.176 | -0.5377 |
| awake | surge | 12.0 | 30039.7 | 3.153 | 0.2105 |
| isoflurane | sink | 8.0 | 5557.9 | 4.685 | -0.1758 |
| isoflurane | surge | 13.0 | 36660.3 | 0.864 | -0.0444 |

Optical measures use the preserved-input fixed native-union footprint mean and the original full 20-sample native-screened pre-event reference. Sink amplitude is −min((raw−B)/B), surge amplitude is max((raw−B)/B), and the integral retains the sign of (raw−B)/B. These are relative optical measures, not calibrated oxygen concentration. Original recording-specific correction remains unchanged, without assuming a universal substrate decline. ID400 uses its own 4.75 µm/pixel calibration; the same parameter factory retains pixel-based defaults and converts the physical surge-area minimum. Its numeric parameter struct is not copied from the 2.35 µm/pixel FB recordings. Researcher-reviewed FB2314 alternatives remain separate and are not transferred.

## Interpretation and limits

Biological variability cannot be estimated from one pair alone. FB2312, FB2314, FB2315, ID400, ID402 and ID403 retain separate mouse-level results; no pooled event-level inference is introduced. Current imperfect automatic labels remain accepted for proceeding. No significance test, confidence interval, new scientific exclusion or detector tuning is added.

Acquisition-frame-1 onsets remain included under the existing descriptive policy (awake sink: 2; awake surge: 0; isoflurane sink: 0; isoflurane surge: 0). Their physiological onset may predate recording. Endpoint censoring, camera exposure, pre-source intensity history and dynamic frame validity remain unresolved. Full-window use is a working descriptive assumption, not a claim that every frame is physiologically valid.

## Verification and traceability

Saved-table aggregation checks cover all 2,400 sign/frame rows and 338 events across the pair. Phases 112 and 113 each include the source-amplitude audit and independent native-support, frame-timing and selected source-trace replay. Numerical agreement does not certify physiological event identity.

Exact values, denominators, missingness reasons and source/table hashes are in paired-summary.json. paired-verification.json records aggregation checks; each run’s verification.json records its independent replay. Source identities, original filenames, support decisions, effective settings and full local output hashes remain traceable. MATLAB recipes in the portable packet use .m.txt to keep archived recipes outside executable code discovery.

Next, review the existing ID401 awake/isoflurane tissue-support proposals, then run the accepted final candidate pair with the current method. Final outcomes, windows, measurement admission, animal-level weighting, missingness and inference remain open. Further detector diagnostics are not a default prerequisite.
