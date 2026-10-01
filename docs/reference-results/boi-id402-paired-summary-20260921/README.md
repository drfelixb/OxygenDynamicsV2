# ID402 awake and isoflurane: paired descriptive summary

21 September 2026 · R1-ID402-AWAKE-RUN-099 / R1-ID402-ISO-RUN-100 / R4-ID402-DESCRIPTIVE-101

Both ID402 recordings now have separately accepted working tissue outlines and verified current-method runs. These paired values describe one mouse with one recording per state. They do not establish a population or causal effect.

The working window is full frames 1–600 in each state, modeled [0,600) seconds (10 minutes) at externally triggered exact 1 Hz. Frame 1 is modeled time 0. Final cohort window approval remains separate. Pre-recording state establishment may be unmeasured; no in-file induction or invented numerical wash-in requirement is imposed.

## Recording-level activity

Differences are isoflurane minus awake. Coverage is native union area-time divided by analyzed tissue-time. Concurrency uses saved event durations, which may differ from native runs. Saved signs remain separate.

| Saved sign | Measure | Awake | Isoflurane | Difference |
|---|---|---:|---:|---:|
| sink | Event onsets (count) | 141 | 35 | -106 |
| sink | Onsets / mm² / min | 3.986 | 1.059 | -2.927 |
| sink | Mean occupied tissue (%) | 0.626 | 0.026 | -0.600 pp |
| sink | Mean concurrent events / mm² | 0.946 | 0.143 | -0.802 |
| surge | Event onsets (count) | 73 | 2 | -71 |
| surge | Onsets / mm² / min | 2.051 | 0.060 | -1.990 |
| surge | Mean occupied tissue (%) | 3.033 | 0.017 | -3.016 pp |
| surge | Mean concurrent events / mm² | 0.571 | 0.011 | -0.561 |

## Denominators and availability

Separate source-specific masks retain dark interior tissue and documented edge uncertainty. Analyzed area also depends on the sign-specific support rules. Each recording keeps its own denominator; anatomical pixel correspondence between states is not assumed.

| State | Sign | Area (mm²) | Tissue-time (mm²·min) | Finite / all amplitudes | Negative finite amplitudes | Unavailable-only share of covered area-time (%) |
|---|---|---:|---:|---:|---:|---:|
| awake | sink | 3.537371 | 35.373713 | 44/141 | 0 | 79.9 |
| awake | surge | 3.559776 | 35.597759 | 23/73 | 1 | 80.6 |
| isoflurane | sink | 3.305767 | 33.057673 | 33/35 | 0 | 4.3 |
| isoflurane | surge | 3.306015 | 33.060154 | 2/2 | 0 | 0.0 |

Missing amplitudes retain events and native coverage. Negative values remain signed. The sink amplitude–area–time composite remains unavailable in both states; no finite-subset sum represents total burden. A surge composite is not defined.

## Event descriptions and conditional optical measurements

Duration and area medians use all saved events. Amplitude and integral medians use only finite measurements, with their sample counts above. Events are within-recording observations, not independent animal replicates. Availability differs between states, so finite optical subsets cannot stand for all activity or an unbiased state contrast.

| State | Sign | Median saved duration (s) | Median mean native event area (µm²) | Median finite amplitude (%) | Median finite signed integral (fraction·s) |
|---|---|---:|---:|---:|---:|
| awake | sink | 12.0 | 6877.1 | 10.754 | -0.6937 |
| awake | surge | 13.0 | 32713.4 | 3.329 | 0.1351 |
| isoflurane | sink | 8.0 | 4219.2 | 3.211 | -0.0996 |
| isoflurane | surge | 10.5 | 15897.6 | 1.618 | 0.0611 |

Optical measures use the preserved-input fixed native-union footprint mean and the original full 20-sample native-screened pre-event reference. Sink amplitude is −min((raw−B)/B), surge amplitude is max((raw−B)/B), and the integral retains the sign of (raw−B)/B. These are relative optical measures, not calibrated oxygen concentration. Original recording-specific correction remains unchanged, without assuming a universal substrate decline. ID402 uses its own 4.75 µm/pixel calibration; the same parameter factory retains pixel-based defaults and converts the physical surge-area minimum. Its numeric parameter struct is not copied from the 2.35 µm/pixel FB recordings. Researcher-reviewed FB2314 alternatives remain separate and are not transferred.

## Interpretation and limits

Biological variability cannot be estimated from one pair alone. FB2314, FB2315 and ID402 retain separate mouse-level results; no pooled event-level inference is introduced. Current imperfect automatic labels remain accepted for proceeding. No significance test, confidence interval, new scientific exclusion or detector tuning is added.

Acquisition-frame-1 onsets remain included under the existing descriptive policy (awake sink: 1; awake surge: 1; isoflurane sink: 0; isoflurane surge: 0). Their physiological onset may predate recording. Endpoint censoring, camera exposure, pre-source intensity history and dynamic frame validity remain unresolved. Full-window use is a working descriptive assumption, not a claim that every frame is physiologically valid.

## Verification and traceability

Saved-table aggregation checks cover all 2,400 sign/frame rows and 251 events across the pair. Phases 099 and 100 each include the source-amplitude audit and independent native-support, frame-timing and selected source-trace replay. Numerical agreement does not certify physiological event identity.

Exact values, denominators, missingness reasons and source/table hashes are in paired-summary.json. paired-verification.json records aggregation checks; each run’s verification.json records its independent replay. Source identities, original filenames, support decisions, effective settings and full local output hashes remain traceable. MATLAB recipes in the portable packet use .m.txt to keep archived recipes outside executable code discovery.

Next, extend the same method to the remaining C02 pairs using existing support proposals, starting with ID403. Final outcomes, windows, measurement admission, animal-level weighting, missingness and inference remain open. Further detector diagnostics are not a default prerequisite.

## Execution and acceptance record

The researcher explicitly answered **“i accept both”** after both ID402 outlines were embedded directly in the conversation. Each decision is bound to its own source, mask and preview. Awake edge diffuseness and possible rim/spillover ambiguity remain recorded. All isoflurane perimeter segments retain weak-boundary uncertainty. Acceptance is for working support, not certified anatomy. Dark interior tissue remains included.

| Recording | Saved events | Source-amplitude mismatches | Master (s) | Statistics (s) | Workflow excluding startup (s) | Output before audit (GiB) |
|---|---:|---:|---:|---:|---:|---:|
| awake | 214 | 0 | 35.0 | 38.7 | 84.8 | 1.42 |
| iso | 37 | 0 | 31.2 | 18.4 | 58.6 | 1.38 |

Each recording completed one detector run and one statistics export. Both independent verifiers checked the native union/availability arithmetic for 1,200 sign/frame rows, all 600 frame intervals, source/staged hashes, ROI containment, neighbor weights and source traces for the available first finite examples. The full event source-amplitude audits have zero mismatches. Verification establishes computational agreement, not event physiology or anatomical truth.

Both original local TIFFs are uint8; previous archive equivalence established unchanged numeric values stored as uint16. Pre-source intensity processing and camera exposure remain unknown. No quantization reversal or calibrated oxygen interpretation is assumed.

The original correction, parameter factory and all 495 repository MATLAB files are unchanged. Original sources, prior outputs, reviewed alternatives and unresolved questions are preserved. This pair uses ten minutes per state, whereas the earlier FB pairs used twenty; final cohort windows and comparability rules remain open.
