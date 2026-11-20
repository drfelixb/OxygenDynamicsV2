# ID401 awake and isoflurane: paired descriptive summary

21 September 2026 · R1-ID401-AWAKE-RUN-116 / R1-ID401-ISO-RUN-117 / R4-ID401-DESCRIPTIVE-118

Both ID401 recordings now have separately accepted working tissue outlines and verified current-method runs. These paired values describe one mouse with one recording per state. They do not establish a population or causal effect.

The working window is full frames 1–600 in each state, modeled [0,600) seconds (10 minutes) at externally triggered exact 1 Hz. Frame 1 is modeled time 0. Final cohort window approval remains separate. Pre-recording state establishment may be unmeasured; no in-file induction or invented numerical wash-in requirement is imposed.

## Recording-level activity

Differences are isoflurane minus awake. Coverage is native union area-time divided by analyzed tissue-time. Concurrency uses saved event durations, which may differ from native runs. Saved signs remain separate.

| Saved sign | Measure | Awake | Isoflurane | Difference |
|---|---|---:|---:|---:|
| sink | Event onsets (count) | 96 | 53 | -43 |
| sink | Onsets / mm² / min | 3.033 | 1.589 | -1.444 |
| sink | Mean occupied tissue (%) | 0.328 | 0.153 | -0.175 pp |
| sink | Mean concurrent events / mm² | 0.549 | 0.237 | -0.312 |
| surge | Event onsets (count) | 17 | 5 | -12 |
| surge | Onsets / mm² / min | 0.523 | 0.145 | -0.378 |
| surge | Mean occupied tissue (%) | 0.299 | 0.157 | -0.142 pp |
| surge | Mean concurrent events / mm² | 0.111 | 0.042 | -0.070 |

## Denominators and availability

Separate source-specific masks retain dark interior tissue and documented edge uncertainty. Analyzed area also depends on the sign-specific support rules. Each recording keeps its own denominator; anatomical pixel correspondence between states is not assumed.

| State | Sign | Area (mm²) | Tissue-time (mm²·min) | Finite / all amplitudes | Negative finite amplitudes | Unavailable-only share of covered area-time (%) |
|---|---|---:|---:|---:|---:|---:|
| awake | sink | 3.165203 | 31.652029 | 50/96 | 0 | 66.1 |
| awake | surge | 3.249474 | 32.494738 | 12/17 | 0 | 38.1 |
| isoflurane | sink | 3.334941 | 33.349406 | 37/53 | 0 | 36.6 |
| isoflurane | surge | 3.439766 | 34.397659 | 1/5 | 0 | 79.0 |

Missing amplitudes retain events and native coverage. Negative values remain signed. The sink amplitude–area–time composite remains unavailable in both states; no finite-subset sum represents total burden. A surge composite is not defined.

## Event descriptions and conditional optical measurements

Duration and area medians use all saved events. Amplitude and integral medians use only finite measurements, with their sample counts above. Events are within-recording observations, not independent animal replicates. Availability differs between states, so finite optical subsets cannot stand for all activity or an unbiased state contrast.

| State | Sign | Median saved duration (s) | Median mean native event area (µm²) | Median finite amplitude (%) | Median finite signed integral (fraction·s) |
|---|---|---:|---:|---:|---:|
| awake | sink | 7.0 | 5960.3 | 4.865 | -0.1610 |
| awake | surge | 12.0 | 25775.4 | 4.346 | 0.1822 |
| isoflurane | sink | 6.0 | 6105.4 | 5.086 | -0.1878 |
| isoflurane | surge | 15.0 | 41840.5 | 0.850 | -0.0985 |

Optical measures use the preserved-input fixed native-union footprint mean and the original full 20-sample native-screened pre-event reference. Sink amplitude is −min((raw−B)/B), surge amplitude is max((raw−B)/B), and the integral retains the sign of (raw−B)/B. These are relative optical measures, not calibrated oxygen concentration. Original recording-specific correction remains unchanged, without assuming a universal substrate decline. ID401 uses its own 4.75 µm/pixel calibration; the same parameter factory retains pixel-based defaults and converts the physical surge-area minimum. Its numeric parameter struct is not copied from the 2.35 µm/pixel FB recordings. Researcher-reviewed FB2314 alternatives remain separate and are not transferred.

## Interpretation and limits

Biological variability cannot be estimated from one pair alone. FB2312, FB2314, FB2315, ID400, ID401, ID402 and ID403 retain separate mouse-level results; no pooled event-level inference is introduced. Current imperfect automatic labels remain accepted for proceeding. No significance test, confidence interval, new scientific exclusion or detector tuning is added.

Acquisition-frame-1 onsets remain included under the existing descriptive policy (awake sink: 2; awake surge: 0; isoflurane sink: 1; isoflurane surge: 0). Their physiological onset may predate recording. Endpoint censoring, camera exposure, pre-source intensity history and dynamic frame validity remain unresolved. Full-window use is a working descriptive assumption, not a claim that every frame is physiologically valid.

## Verification and traceability

Saved-table aggregation checks cover all 2,400 sign/frame rows and 171 events across the pair. Phases 116 and 117 each include the source-amplitude audit and independent native-support, frame-timing and selected source-trace replay. Numerical agreement does not certify physiological event identity.

Exact values, denominators, missingness reasons and source/table hashes are in paired-summary.json. paired-verification.json records aggregation checks; each run’s verification.json records its independent replay. Source identities, original filenames, support decisions, effective settings and full local output hashes remain traceable. MATLAB recipes in the portable packet use .m.txt to keep archived recipes outside executable code discovery.

All seven C02 candidate pairs now have current-method descriptive summaries. Next, consolidate the mouse-level results and resolve the final analysis choices. Final outcomes, windows, measurement admission, animal-level weighting, missingness and inference remain open. Further detector diagnostics are not a default prerequisite.

## Execution and acceptance record

The researcher explicitly answered **“both are suitable”** after both ID401 outlines were embedded directly in the conversation. Each decision is bound to its own source, mask and preview. Both upper/left boundaries remain diffuse. The lower field is clipped, and isoflurane lower-left continuity has weak evidence, especially in the later faint frames. Broad dark interior regions remain included. Acceptance is for working support, not certified anatomy. Dark interior tissue remains included.

| Recording | Saved events | Source-amplitude mismatches | Master (s) | Statistics (s) | Workflow excluding startup (s) | Output before audit (GiB) |
|---|---:|---:|---:|---:|---:|---:|
| awake | 113 | 0 | 32.0 | 25.3 | 66.7 | 1.39 |
| iso | 58 | 0 | 30.8 | 19.4 | 59.3 | 1.38 |

Each recording completed one detector run and one statistics export. Both independent verifiers checked the native union/availability arithmetic for 1,200 sign/frame rows, all 600 frame intervals, source/staged hashes, ROI containment, neighbor weights and source traces for the available first finite examples. The full event source-amplitude audits have zero mismatches. Verification establishes computational agreement, not event physiology or anatomical truth.

Both original local TIFFs are uint8. Every local pixel matches its checksum-verified earlier archive-derived uint16 TIFF, as established in phase 106. Numeric values are unchanged. Pre-source intensity processing and camera exposure remain unknown. No quantization reversal or calibrated oxygen interpretation is assumed.

The original correction, parameter factory and all 495 repository MATLAB files are unchanged. Original sources, prior outputs, reviewed alternatives and unresolved questions are preserved. This pair uses ten minutes per state, whereas the earlier FB pairs used twenty; final cohort windows and comparability rules remain open.

[Exact paired results](reference-results/boi-id401-paired-summary-20260921/paired-summary.json). [Evidence packet](reference-results/boi-id401-paired-summary-20260921/README.md).
