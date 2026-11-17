# FB2312 awake and isoflurane: paired descriptive summary

21 September 2026 · R1-FB2312-AWAKE-RUN-108 / R1-FB2312-ISO-RUN-109 / R4-FB2312-DESCRIPTIVE-110

Both FB2312 recordings now have separately accepted working tissue outlines and verified current-method runs. These paired values describe one mouse with one recording per state. They do not establish a population or causal effect.

The working window is full frames 1–1200 in each state, modeled [0,1200) seconds (20 minutes) at externally triggered exact 1 Hz. Frame 1 is modeled time 0. Final cohort window approval remains separate. Pre-recording state establishment may be unmeasured; no in-file induction or invented numerical wash-in requirement is imposed.

## Recording-level activity

Differences are isoflurane minus awake. Coverage is native union area-time divided by analyzed tissue-time. Concurrency uses saved event durations, which may differ from native runs. Saved signs remain separate.

| Saved sign | Measure | Awake | Isoflurane | Difference |
|---|---|---:|---:|---:|
| sink | Event onsets (count) | 309 | 219 | -90 |
| sink | Onsets / mm² / min | 16.855 | 11.498 | -5.356 |
| sink | Mean occupied tissue (%) | 0.445 | 0.337 | -0.108 pp |
| sink | Mean concurrent events / mm² | 3.177 | 1.890 | -1.287 |
| surge | Event onsets (count) | 35 | 42 | +7 |
| surge | Onsets / mm² / min | 1.800 | 2.068 | +0.268 |
| surge | Mean occupied tissue (%) | 1.191 | 2.415 | +1.223 pp |
| surge | Mean concurrent events / mm² | 0.411 | 1.010 | +0.598 |

## Denominators and availability

Separate source-specific masks retain dark interior tissue and documented edge uncertainty. Analyzed area also depends on the sign-specific support rules. Each recording keeps its own denominator; anatomical pixel correspondence between states is not assumed.

| State | Sign | Area (mm²) | Tissue-time (mm²·min) | Finite / all amplitudes | Negative finite amplitudes | Unavailable-only share of covered area-time (%) |
|---|---|---:|---:|---:|---:|---:|
| awake | sink | 0.916663 | 18.333264 | 157/309 | 4 | 56.3 |
| awake | surge | 0.972275 | 19.445496 | 14/35 | 0 | 70.6 |
| isoflurane | sink | 0.952305 | 19.046108 | 89/219 | 3 | 66.4 |
| isoflurane | surge | 1.015278 | 20.305570 | 17/42 | 0 | 70.8 |

Missing amplitudes retain events and native coverage. Negative values remain signed. The sink amplitude–area–time composite remains unavailable in both states; no finite-subset sum represents total burden. A surge composite is not defined.

## Event descriptions and conditional optical measurements

Duration and area medians use all saved events. Amplitude and integral medians use only finite measurements, with their sample counts above. Events are within-recording observations, not independent animal replicates. Availability differs between states, so finite optical subsets cannot stand for all activity or an unbiased state contrast.

| State | Sign | Median saved duration (s) | Median mean native event area (µm²) | Median finite amplitude (%) | Median finite signed integral (fraction·s) |
|---|---|---:|---:|---:|---:|
| awake | sink | 9.0 | 1779.6 | 9.417 | -0.4916 |
| awake | surge | 12.0 | 25888.4 | 7.823 | 0.4632 |
| isoflurane | sink | 6.0 | 1449.1 | 3.349 | -0.0935 |
| isoflurane | surge | 14.0 | 21414.6 | 2.646 | 0.0589 |

Optical measures use the preserved-input fixed native-union footprint mean and the original full 20-sample native-screened pre-event reference. Sink amplitude is −min((raw−B)/B), surge amplitude is max((raw−B)/B), and the integral retains the sign of (raw−B)/B. These are relative optical measures, not calibrated oxygen concentration. Original recording-specific correction remains unchanged, without assuming a universal substrate decline. FB2312 uses the canonical 2.35 µm/pixel calibration and unchanged parameter factory, matching the earlier FB recording settings. Pixel-based defaults retain a different physical scale from ID400–403 at 4.75 µm/pixel. Researcher-reviewed FB2314 alternatives remain separate and are not transferred.

## Interpretation and limits

Biological variability cannot be estimated from one pair alone. FB2312, FB2314, FB2315, ID402 and ID403 retain separate mouse-level results; no pooled event-level inference is introduced. Current imperfect automatic labels remain accepted for proceeding. No significance test, confidence interval, new scientific exclusion or detector tuning is added.

Acquisition-frame-1 onsets remain included under the existing descriptive policy (awake sink: 2; awake surge: 1; isoflurane sink: 3; isoflurane surge: 2). Their physiological onset may predate recording. Endpoint censoring, camera exposure, pre-source intensity history and dynamic frame validity remain unresolved. Full-window use is a working descriptive assumption, not a claim that every frame is physiologically valid.

## Verification and traceability

Saved-table aggregation checks cover all 4,800 sign/frame rows and 605 events across the pair. Phases 108 and 109 each include the source-amplitude audit and independent native-support, frame-timing and selected source-trace replay. Numerical agreement does not certify physiological event identity.

Exact values, denominators, missingness reasons and source/table hashes are in paired-summary.json. paired-verification.json records aggregation checks; each run’s verification.json records its independent replay. Source identities, original filenames, support decisions, effective settings and full local output hashes remain traceable. MATLAB recipes in the portable packet use .m.txt to keep archived recipes outside executable code discovery.

Next, review the existing source-specific tissue-support proposals for ID400 and ID401, then run the accepted pairs with the current method. Final outcomes, windows, measurement admission, animal-level weighting, missingness and inference remain open. Further detector diagnostics are not a default prerequisite.

## Execution and acceptance record

The researcher explicitly answered **“bot are suitable”** after both FB2312 outlines were embedded directly in the conversation. Each decision is bound to its own source, mask and preview. Upper/lower-left margins remain diffuse. Both recordings have clipped top/left fields; isoflurane also reaches the lower image edge. Dark transverse bands remain included. Acceptance is for working support, not certified anatomy. Dark interior tissue remains included.

| Recording | Saved events | Source-amplitude mismatches | Master (s) | Statistics (s) | Workflow excluding startup (s) | Output before audit (GiB) |
|---|---:|---:|---:|---:|---:|---:|
| awake | 344 | 0 | 65.1 | 48.6 | 140.0 | 3.04 |
| iso | 261 | 0 | 59.1 | 45.4 | 128.1 | 3.04 |

Each recording completed one detector run and one statistics export. Both independent verifiers checked the native union/availability arithmetic for 2,400 sign/frame rows, all 1200 frame intervals, source/staged hashes, ROI containment, neighbor weights and source traces for the available first finite examples. The full event source-amplitude audits have zero mismatches. Verification establishes computational agreement, not event physiology or anatomical truth.

Both original local TIFFs are uint16. All awake pixels match the preserved archive-derived TIFF. All isoflurane pixels match the checksum-verified NWB after the explicit spatial transpose documented in phase 106. No numeric intensity transformation is applied. Pre-source intensity processing and camera exposure remain unknown. No quantization reversal or calibrated oxygen interpretation is assumed.

The original correction, parameter factory and all 495 repository MATLAB files are unchanged. Original sources, prior outputs, reviewed alternatives and unresolved questions are preserved. This pair uses twenty minutes per state, matching the earlier FB pairs; the ID402/ID403 descriptive windows used ten minutes. Final cohort windows and comparability rules remain open.
