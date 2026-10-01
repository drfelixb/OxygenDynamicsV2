# FB2315 awake and isoflurane: paired descriptive summary

21 September 2026 · R1-FB2315-ISO-RUN-096 / R4-FB2315-DESCRIPTIVE-097

Both FB2315 recordings now have separately accepted working tissue outlines and verified current-method runs. These paired values describe one mouse with one recording per state. They do not establish a population or causal effect.

The working window is full frames 1–1200 in each state, modeled [0,1200) seconds (20 minutes) at externally triggered exact 1 Hz. Frame 1 is modeled time 0. Final cohort window approval remains separate. Pre-recording state establishment may be unmeasured; no in-file induction or invented numerical wash-in requirement is imposed.

## Recording-level activity

Differences are isoflurane minus awake. Coverage is native union area-time divided by analyzed tissue-time. Concurrency uses saved event durations, which may differ from native runs. Saved signs remain separate.

| Saved sign | Measure | Awake | Isoflurane | Difference |
|---|---|---:|---:|---:|
| sink | Event onsets (count) | 366 | 162 | -204 |
| sink | Onsets / mm² / min | 17.185 | 7.352 | -9.832 |
| sink | Mean occupied tissue (%) | 0.573 | 0.494 | -0.079 pp |
| sink | Mean concurrent events / mm² | 4.216 | 1.780 | -2.437 |
| surge | Event onsets (count) | 58 | 46 | -12 |
| surge | Onsets / mm² / min | 2.559 | 1.943 | -0.616 |
| surge | Mean occupied tissue (%) | 2.214 | 5.486 | +3.272 pp |
| surge | Mean concurrent events / mm² | 0.743 | 1.569 | +0.827 |

## Denominators and availability

Separate source-specific masks retain dark interior tissue and documented edge uncertainty. Analyzed area also depends on the sign-specific support rules. Each recording keeps its own denominator; anatomical pixel correspondence between states is not assumed.

| State | Sign | Area (mm²) | Tissue-time (mm²·min) | Finite / all amplitudes | Negative finite amplitudes | Unavailable-only share of covered area-time (%) |
|---|---|---:|---:|---:|---:|---:|
| awake | sink | 1.064887 | 21.297742 | 190/366 | 2 | 55.6 |
| awake | surge | 1.133140 | 22.662794 | 23/58 | 3 | 62.8 |
| isoflurane | sink | 1.101678 | 22.033560 | 54/162 | 3 | 77.1 |
| isoflurane | surge | 1.183521 | 23.670429 | 16/46 | 7 | 72.4 |

Missing amplitudes retain events and native coverage. Negative values remain signed. The sink amplitude–area–time composite remains unavailable in both states; no finite-subset sum represents total burden. A surge composite is not defined.

## Event descriptions and conditional optical measurements

Duration and area medians use all saved events. Amplitude and integral medians use only finite measurements, with their sample counts above. Events are within-recording observations, not independent animal replicates. Availability differs between states, so finite optical subsets cannot stand for all activity or an unbiased state contrast.

| State | Sign | Median saved duration (s) | Median mean native event area (µm²) | Median finite amplitude (%) | Median finite signed integral (fraction·s) |
|---|---|---:|---:|---:|---:|
| awake | sink | 13.0 | 1616.1 | 13.383 | -0.8714 |
| awake | surge | 15.0 | 23621.6 | 6.207 | 0.3608 |
| isoflurane | sink | 8.0 | 1612.6 | 4.594 | -0.1903 |
| isoflurane | surge | 18.0 | 17065.3 | 0.154 | -0.1115 |

Optical measures use the preserved-input fixed native-union footprint mean and the original full 20-sample native-screened pre-event reference. Sink amplitude is −min((raw−B)/B), surge amplitude is max((raw−B)/B), and the integral retains the sign of (raw−B)/B. These are relative optical measures, not calibrated oxygen concentration. Original recording-specific correction remains unchanged, without assuming a universal substrate decline. Researcher-reviewed FB2314 alternatives remain separate and are not transferred.

## Interpretation and limits

Biological variability cannot be estimated from one pair alone. FB2314 and FB2315 retain separate mouse-level results; no pooled event-level inference is introduced. Current imperfect automatic labels remain accepted for proceeding. No significance test, confidence interval, new scientific exclusion or detector tuning is added.

Acquisition-frame-1 onsets remain included under the existing descriptive policy (awake sink: 4; awake surge: 1; isoflurane sink: 3; isoflurane surge: 2). Their physiological onset may predate recording. Endpoint censoring, camera exposure, pre-source intensity history and dynamic frame validity remain unresolved. Full-window use is a working descriptive assumption, not a claim that every frame is physiologically valid.

## Verification and traceability

Saved-table aggregation checks cover all 4,800 sign/frame rows and 632 events across the pair. The original phase-095 awake verification is retained. Phase-096 adds the isoflurane source-amplitude audit and independent native-support, frame-timing and selected source-trace replay. Numerical agreement does not certify physiological event identity.

Exact values, denominators, missingness reasons and source/table hashes are in paired-summary.json. paired-verification.json records aggregation checks; verification.json records the separate isoflurane replay. Source identities, original filename discrepancies, support decisions, effective settings and full local output hashes remain traceable. MATLAB recipes in the portable packet use .m.txt to keep archived recipes outside executable code discovery.

Next, extend the same method to the remaining C02 pairs using existing support proposals, starting with ID402. Final outcomes, windows, measurement admission, animal-level weighting, missingness and inference remain open. Further detector diagnostics are not a default prerequisite.

## Isoflurane execution record

The researcher explicitly stated: “i accept the fb2315 isoflurane outline”. This applies
to the original source-specific mask and final five-frame review image bound in
researcher-support-decision.json. Dark interior tissue remains included. Top,
right and bottom field clipping and upper-left boundary uncertainty remain.
Canonical identity is FB2315 despite FB2314 in the original TIFF filename.
Isoflurane source SHA256: `47f05ee5e883e8ff0e52bc7d3ecf3a8477c34f42cfd170bf2197d30e9b77afe2`.

All 208 saved isoflurane events passed the existing MATLAB
source-amplitude audit with zero mismatches. Independent Python verification
checked 2,400 sign/frame native-support rows, all 1,200 frame intervals, the
neighbor-weight map and 2400 selected footprint
source samples. Optical reference membership and signed arithmetic agree.

Master execution: 69.4 s. Statistics: 64.0 s.
Workflow: 158.1 s excluding startup. Output before audit:
3.08 GiB. Audit: 75.0 s.
The first attempt stopped before detection because the full acceptance record
contained more fields than the support writer accepts. That attempt is retained.
Only the runner's field selection was corrected. One detector execution and one
statistics execution completed; no scientific pipeline code or parameter changed.

All 495 repository MATLAB files and previous scientific results are preserved.
The full pending preparation, exact acceptance, failed attempt, successful run,
environment, source checks, resource logs and numerical evidence remain available.
Portable MATLAB recipe copies use text extensions. Bulk data remain local and
are checksum-bound. This packet is internal research provenance, not a public
deidentified release.
