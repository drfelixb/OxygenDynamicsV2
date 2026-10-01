# BOI cohort and comparison proposal

Prepared 10 September 2026. Planning inventory only: not a frozen cohort,
statistical analysis plan, executable batch, or new signal-quality assessment.

**Current issue status:** consult the [resolution record](BOI_COHORT_RESOLUTION.md)
and its linked evidence. The inventory below preserves the original proposal;
the resolution record adds the confirmed 4 µm microsphere correction, local
source correspondence, recovered KX timing, explicit role decisions, and
remaining holds. Do not interpret the original issue wording as reversing a
subsequent correction.

This table assigns every archive asset a role using the existing reconciled
metadata. It does not infer missing sessions, experimental windows, event counts,
or acquisition equivalence. The current round is BOI-only; IOSI is excluded.

## What is available

| Role | Recordings | Meaning |
| --- | --- | --- |
| Candidate biological comparisons | 71 | Provisional BOI assignments; final QC and comparison eligibility pending |
| Calibration | 7 | 6 animals; separate from spontaneous-event comparisons |
| Expression/support BOI | 1 | Scientific role unresolved |
| Held BOI records | 4 | Mapping/calibration unresolved |
| Fluorescence support | 1 | Optional artifact assessment; not a BOI biological observation |
| Excluded IOSI | 3 | No work or release dependency |

The 83 metadata-consistent assets are not 83 eligible BOI experiments: they
include the three IOSI recordings and the fluorescence control. There are 79
metadata-consistent BOI assets (71 comparison candidates + 7 calibration + 1
support), plus four unresolved BOI assets. None is automatically approved by
this table. Recordings and animals are different denominators; animals recur
across some comparison families.

## Comparisons to decide and validate

IDs identify proposed analyses, not accepted primary contrasts. Candidate primary
pocket outcomes are mean occupied tissue fraction and onset rate; concurrent
count density is a distinct required companion. Duration, area, amplitude,
recurrence, recovery, and composite burden explain differences. Evoked-response
and calibration analyses need their own primary measurement definitions.

| ID / question | Recording support | Design and proposed outputs | Outstanding requirements |
| --- | --- | --- | --- |
| C01: How do pocket patterns differ across KX, quiet awake and mobile awake? | B01: 9; B02: 7; B03: 10 (26 distinct canonical mice) | Between-animal state association; coverage/onsets plus explanatory metrics | G1/G2/U7; surgery-to-imaging time and acquisition confounds; actual running epochs need behavior data; no paired or isolated causal-state claim |
| C02: How do pocket patterns change from awake to isoflurane? | B02 + B04: 14 recordings, 7 candidate mouse pairs | Within-mouse contrast; coverage/onsets and components | U2/U8; verify FB2315 source identity, sequence, wash-in and comparable exposure |
| C03: How do 30-second whisker trials change pocket activity under KX? | B05: 6 stimulation recordings; 6 same-mouse B01 baselines | Within-recording trial windows; separate baseline session is a candidate companion, not a substituted pre-trial reference | U3; exact onset/clock/trial validity; keep 30/90-second protocol distinct |
| C04: How does the 10-second evoked response differ between awake and KX? | B06 + B07: 16 recordings, 8 candidate mouse pairs | Compare within-recording evoked responses across states; global/ROI optical response plus pocket metrics | U3/U6; timing, order, consistent reference definition and nm200423 preparation |
| C05-CO2: What changes during hypercapnia and recovery? | B08: 6 recordings / 6 mice | Within-recording intervention contrast; global response and local coverage/onsets | U9; all 6 descriptions state 300-600 s, but no windows approved |
| C05-O2: What changes during hyperoxia? | B09: 5 recordings / 5 mice | Within-recording intervention contrast; global response and local coverage/onsets | U4/U9; 4 descriptions state 600-1200 s; FB2360 timing missing; recovery only if observed |
| C06: How does microsphere-associated BOI activity differ from compatible controls? | B10: 5 recordings; B01 controls remain candidates | Unpaired comparison only if controls justified; coverage, area, identity and amplitude | U5; particle-size conflict and control/acquisition comparability; no pre-injection recording inferred |
| K01: Does recorded optical response follow the calibration manipulation? | 7 recordings / 6 mice | Separate method-response analysis, with aligned electrode data if available | U10; step sequence, alignment and valid calibration; no universal pO2 conversion |
| S01 / F01: What method support can be obtained? | 1 expression-labelled BOI asset; 1 fluorescence-only control | Optional support roles with distinct signal interpretation | U11/U13; no automatic baseline inclusion or biological false-positive labels |

For C05, FB2359 and FB2360 contribute to both gas families. The combined
inventory is 11 recordings from 9 canonical mice, not two independent cohorts.
No head-to-head gas comparison is assigned. Different protocol, timing and
acquisition groups require a separate design if that comparison is wanted.

## Recording assignments

Each session appears once below. JSON preserves its asset ID, selected series,
canonical metadata, source description, reported archive hash, timing evidence,
and source row references. A group assignment is a planning role, not a QC pass.
Every non-IOSI row also carries G1 and G2. An empty additional-issue cell does
not imply there are no outstanding requirements.

### B01: KX baseline

9 recordings; 9 canonical mice. Status: `candidate_biological`.

| Session | Mouse | Pixel size (um/pixel) | Comparison role | Additional issues |
| --- | --- | --- | --- | --- |
| FB2311-baseline | FB2311 | 2.35 | C01, C03-control-candidate, C06-control-candidate | U7 |
| FB2316-baseline | FB2316 | 2.35 | C01, C03-control-candidate, C06-control-candidate | U7 |
| FB2317-baseline | FB2317 | 2.35 | C01, C03-control-candidate, C06-control-candidate | U7 |
| FB2318-baseline | FB2318 | 2.35 | C01, C03-control-candidate, C06-control-candidate | U7 |
| FB2319-baseline | FB2319 | 2.35 | C01, C03-control-candidate, C06-control-candidate | U7 |
| FB2320-baseline | FB2320 | 2.35 | C01, C03-control-candidate, C06-control-candidate | U7 |
| FB237 | FB237 | 1.58 | C01, C03-control-candidate, C06-control-candidate | U7 |
| FB238 | FB238 | 1.58 | C01, C03-control-candidate, C06-control-candidate | U7 |
| FB239 | FB239 | 1.58 | C01, C03-control-candidate, C06-control-candidate | U7 |

### B02: Quiet-awake baseline

7 recordings; 7 canonical mice. Status: `candidate_biological`.

| Session | Mouse | Pixel size (um/pixel) | Comparison role | Additional issues |
| --- | --- | --- | --- | --- |
| FB2312-baseline-awake | FB2312 | 2.35 | C01, C02 | U7, U8 |
| FB2314-baseline-awake | FB2314 | 2.35 | C01, C02 | U7, U8 |
| FB2315-baseline-awake | FB2315 | 2.35 | C01, C02 | U2, U7, U8 |
| M400-01-baseline-awake | ID400 | 4.75 | C01, C02 | U7, U8 |
| M401-01-baseline-awake | ID401 | 4.75 | C01, C02 | U7, U8 |
| M402-01-baseline-awake | ID402 | 4.75 | C01, C02 | U7, U8 |
| M403-01-baseline-awake | ID403 | 4.75 | C01, C02 | U7, U8 |

### B03: Mobile awake

10 recordings; 10 canonical mice. Status: `candidate_biological`.

| Session | Mouse | Pixel size (um/pixel) | Comparison role | Additional issues |
| --- | --- | --- | --- | --- |
| ID01-20201204 | ID01_Geriatric | 2.8 | C01 | U7 |
| ID02-20201204 | ID02_Geriatric | 2.8 | C01 | U7 |
| ID03-20201204 | ID03_Geriatric | 2.8 | C01 | U7 |
| ID13-20200917 | ID13 | 2.38 | C01 | U7 |
| ID14-20200929 | ID14 | 2.38 | C01 | U7 |
| ID18-20201008 | ID18 | 2.38 | C01 | U7 |
| ID20-20201013 | ID20 | 2.38 | C01 | U7 |
| ID23-20201013 | ID23 | 2.38 | C01 | U7 |
| ID25-20201020 | ID25 | 2.38 | C01 | U7 |
| ID26-20201020 | ID26 | 2.38 | C01 | U7 |

### B04: Isoflurane baseline

7 recordings; 7 canonical mice. Status: `candidate_biological`.

| Session | Mouse | Pixel size (um/pixel) | Comparison role | Additional issues |
| --- | --- | --- | --- | --- |
| FB2312-baseline-iso | FB2312 | 2.35 | C02 | U8 |
| FB2314-baseline-iso | FB2314 | 2.35 | C02 | U8 |
| FB2315-baseline-iso | FB2315 | 2.35 | C02 | U2, U8 |
| M400-03-baseline-iso | ID400 | 4.75 | C02 | U8 |
| M401-03-baseline-iso | ID401 | 4.75 | C02 | U8 |
| M402-03-baseline-iso | ID402 | 4.75 | C02 | U8 |
| M403-03-baseline-iso | ID403 | 4.75 | C02 | U8 |

### B05: KX whisker 30 s / 90 s

6 recordings; 6 canonical mice. Status: `candidate_biological`.

| Session | Mouse | Pixel size (um/pixel) | Comparison role | Additional issues |
| --- | --- | --- | --- | --- |
| FB2311-whisker | FB2311 | 2.35 | C03 | U3 |
| FB2316-whisker | FB2316 | 2.35 | C03 | U3 |
| FB2317-whisker | FB2317 | 2.35 | C03 | U3 |
| FB2318-whisker | FB2318 | 2.35 | C03 | U3 |
| FB2319-whisker | FB2319 | 2.35 | C03 | U3 |
| FB2320-whisker | FB2320 | 2.35 | C03 | U3 |

### B06: Awake whisker 10 s / 60 s

8 recordings; 8 canonical mice. Status: `candidate_biological`.

| Session | Mouse | Pixel size (um/pixel) | Comparison role | Additional issues |
| --- | --- | --- | --- | --- |
| leica191115-A1-awake | leica191115_A1 | 4.99 | C04 | U3 |
| leica191118-A2-awake | leica191118_A2 | 5.38 | C04 | U3 |
| nm200109-A3-awake | nm200109_A3 | 2.82 | C04 | U3 |
| nm200113-A1-awake | nm200113_A1 | 2.82 | C04 | U3 |
| nm200330-A2-awake | nm200330_A2 | 2.82 | C04 | U3 |
| nm200416-A1-awake | nm200416_A1 | 2.82 | C04 | U3 |
| nm200417-A2-awake | nm200417_A2 | 2.82 | C04 | U3 |
| nm200423-A2-awake | nm200423_A2 | 3.25 | C04 | U3, U6 |

### B07: KX whisker 10 s / 60 s

8 recordings; 8 canonical mice. Status: `candidate_biological`.

| Session | Mouse | Pixel size (um/pixel) | Comparison role | Additional issues |
| --- | --- | --- | --- | --- |
| leica191115-A1-KX | leica191115_A1 | 4.99 | C04 | U3 |
| leica191118-A2-KX | leica191118_A2 | 5.38 | C04 | U3 |
| nm200109-A3-KX | nm200109_A3 | 2.82 | C04 | U3 |
| nm200113-A1-KX | nm200113_A1 | 2.82 | C04 | U3 |
| nm200330-A2-KX | nm200330_A2 | 2.82 | C04 | U3 |
| nm200416-A1-KX | nm200416_A1 | 2.82 | C04 | U3 |
| nm200417-A2-KX | nm200417_A2 | 2.82 | C04 | U3 |
| nm200423-A2-KX | nm200423_A2 | 3.25 | C04 | U3, U6 |

### B08: Hypercapnia

6 recordings; 6 canonical mice. Status: `candidate_biological`.

| Session | Mouse | Pixel size (um/pixel) | Comparison role | Additional issues |
| --- | --- | --- | --- | --- |
| FB2359-Hypercapnia | FB2359 | 6.75 | C05-CO2 | U9 |
| FB2360-Hypercapnia | FB2360 | 6.75 | C05-CO2 | U9 |
| M441 | M441 | 1.63 | C05-CO2 | U9 |
| M442 | M442 | 1.63 | C05-CO2 | U9 |
| M443 | M443 | 1.63 | C05-CO2 | U9 |
| M444 | M444 | 1.63 | C05-CO2 | U9 |

### B09: Hyperoxia

5 recordings; 5 canonical mice. Status: `candidate_biological`.

| Session | Mouse | Pixel size (um/pixel) | Comparison role | Additional issues |
| --- | --- | --- | --- | --- |
| FB2356 | FB2356 | 6.75 | C05-O2 | U9 |
| FB2357 | FB2357 | 6.75 | C05-O2 | U9 |
| FB2358 | FB2358 | 6.75 | C05-O2 | U9 |
| FB2359-Hyperoxia | FB2359 | 6.75 | C05-O2 | U9 |
| FB2360-Hyperoxia | FB2360 | 6.75 | C05-O2 | U4, U9 |

### B10: Microsphere BOI

5 recordings; 5 canonical mice. Status: `candidate_biological`.

| Session | Mouse | Pixel size (um/pixel) | Comparison role | Additional issues |
| --- | --- | --- | --- | --- |
| FB2352 | FB2352 | 4.75 | C06 | U5 |
| FB2353 | FB2353 | 4.75 | C06 | U5 |
| FB2354 | FB2354 | 4.75 | C06 | U5 |
| FB2355 | FB2355 | 4.75 | C06 | U5 |
| FB2364 | FB2364 | 4.75 | C06 | U5 |

### K01: Oxygen calibration

7 recordings; 6 canonical mice. Status: `calibration`.

| Session | Mouse | Pixel size (um/pixel) | Comparison role | Additional issues |
| --- | --- | --- | --- | --- |
| nm190819 | nm190819 | 3.25 | K01 | U10 |
| nm190823 | nm190823 | 3.25 | K01 | U10 |
| nm190906 | nm190906 | 3.25 | K01 | U10 |
| nm190910-01001 | nm190910 | 3.25 | K01 | U10 |
| nm190910-01002 | nm190910 | 3.25 | K01 | U10 |
| nm190911 | nm190911_A1 | 3.25 | K01 | U10 |
| nm190912 | nm190912_A1 | 3.25 | K01 | U10 |

### S01: Expression/support BOI

1 recordings; 1 canonical mice. Status: `support_role_unresolved`.

| Session | Mouse | Pixel size (um/pixel) | Comparison role | Additional issues |
| --- | --- | --- | --- | --- |
| nm200420-A1 | nm200420_A1 | 6.92 | S01 | U11 |

### H01: Unresolved BOI

4 recordings; 4 canonical mice. Status: `held_unresolved`.

| Session | Mouse | Pixel size (um/pixel) | Comparison role | Additional issues |
| --- | --- | --- | --- | --- |
| F120 | F120 | unresolved | unassigned | U1 |
| F134 | F134 | unresolved | unassigned | U1 |
| F136 | F136 | unresolved | unassigned | U1 |
| M189 | M189 | unresolved | unassigned | U1 |

### F01: Fluorescence support only

1 recordings; 1 canonical mice. Status: `non_BOI_support_only`.

| Session | Mouse | Pixel size (um/pixel) | Comparison role | Additional issues |
| --- | --- | --- | --- | --- |
| FB2411 | FB2411 | 6.75 | F01 | U13 |

### X01: IOSI excluded

3 recordings; 3 canonical mice. Status: `excluded_IOSI`.

| Session | Mouse | Pixel size (um/pixel) | Comparison role | Additional issues |
| --- | --- | --- | --- | --- |
| FB2328 | FB2328 | 3.37 | excluded | - |
| FB2361 | FB2361 | 3.37 | excluded | - |
| FB2362 | FB2362 | 3.37 | excluded | - |

## Candidate recording pairs

These are metadata-supported candidates, not accepted analysis pairs. Matching
animal IDs, dates, and pixel sizes does not verify common field of view, source
identity, intensity comparability, or event-level anatomical correspondence.
C03 lists separate baseline sessions alongside stimulation sessions; it does not
define trial baseline windows.

| Comparison | Mouse | First recording | Second recording | Same source date / pixel size |
| --- | --- | --- | --- | --- |
| C02 | FB2312 | FB2312-baseline-awake | FB2312-baseline-iso | True / True |
| C02 | FB2314 | FB2314-baseline-awake | FB2314-baseline-iso | True / True |
| C02 | FB2315 | FB2315-baseline-awake | FB2315-baseline-iso | True / True |
| C02 | ID400 | M400-01-baseline-awake | M400-03-baseline-iso | True / True |
| C02 | ID401 | M401-01-baseline-awake | M401-03-baseline-iso | True / True |
| C02 | ID402 | M402-01-baseline-awake | M402-03-baseline-iso | True / True |
| C02 | ID403 | M403-01-baseline-awake | M403-03-baseline-iso | True / True |
| C03 | FB2311 | FB2311-baseline | FB2311-whisker | True / True |
| C03 | FB2316 | FB2316-baseline | FB2316-whisker | True / True |
| C03 | FB2317 | FB2317-baseline | FB2317-whisker | True / True |
| C03 | FB2318 | FB2318-baseline | FB2318-whisker | True / True |
| C03 | FB2319 | FB2319-baseline | FB2319-whisker | True / True |
| C03 | FB2320 | FB2320-baseline | FB2320-whisker | True / True |
| C04 | leica191115_A1 | leica191115-A1-awake | leica191115-A1-KX | True / True |
| C04 | leica191118_A2 | leica191118-A2-awake | leica191118-A2-KX | True / True |
| C04 | nm200109_A3 | nm200109-A3-awake | nm200109-A3-KX | True / True |
| C04 | nm200113_A1 | nm200113-A1-awake | nm200113-A1-KX | True / True |
| C04 | nm200330_A2 | nm200330-A2-awake | nm200330-A2-KX | True / True |
| C04 | nm200416_A1 | nm200416-A1-awake | nm200416-A1-KX | True / True |
| C04 | nm200417_A2 | nm200417-A2-awake | nm200417-A2-KX | True / True |
| C04 | nm200423_A2 | nm200423-A2-awake | nm200423-A2-KX | True / True |

## Timing evidence and what it does not establish

| Group | Evidence available | Still missing |
| --- | --- | --- |
| B01-B04 baseline/state recordings | State and preparation descriptions; awake-before-isoflurane explicitly stated | Final valid observation intervals, transitions/exclusions, actual behavior epochs; no whole-recording eligibility assumed |
| B05 | 30 s stimulus every 90 s | First onset, actual trial count, channel identity, synchronization and valid trials |
| B06/B07 | 10 s stimulus every 60 s | First onset, actual trial count, synchronization and valid trials |
| B08 | All 6 descriptions: 10% CO2 from 300 to 600 s | Clock and boundary verification, transition/plateau definition, baseline/recovery QC |
| B09 | FB2356/57/58 and FB2359-Hyperoxia: 30% O2 from 600 to 1200 s | FB2360 interval absent; all clocks, boundaries and recovery coverage unverified |
| B10 | Microspheres injected before imaging according to descriptions | Compatible controls, actual intervention protocol, aligned auxiliary channel if used |
| K01 | One-minute gas steps; electrode inserted | Actual gas sequence, alignment, electrode data/calibration and valid plateaus |
| H01 | Generic preparation descriptions and uninformative analog channel labels in the prior audit | Which recording/segments correspond to baseline or stimulation; no one-to-two mapping established |

All `approved_analysis_windows` arrays in the companion JSON are empty. The
intervals recorded as evidence are not baseline definitions or machine-ready
window files. No time-axis interpretation or recording duration was inferred
from the stored array shapes.

## Issues and required evidence

| ID | Issue / evidence needed |
| --- | --- |
| G1 | All candidates: input integrity, quantitative intensity provenance, calibration, timing/axes, eligible tissue, motion/borders, exposure and measurement availability need final release QC. Metadata consistency alone does not establish eligibility. |
| G2 | Development/evaluation assignment is not frozen. Known reference use is flagged, but absence from that list does not establish an untouched recording or animal. |
| U1 | F120/F134/F136/M189: unresolved baseline-versus-whisker mapping; NWB pixel size 1.54 versus candidate CSV 1.55 um/pixel. Keep canonical fields unavailable. Do not split a single asset into two recordings without timing evidence. |
| U2 | FB2315 awake/isoflurane: selected series names contain FB2314, while archive subject and reconciled workbook identify FB2315. Preserve canonical FB2315 and verify original acquisition identity/file contents before accepting independent-animal and pairing claims. |
| U3 | Whisker groups: descriptions state repetition and stimulus duration but not first onset, exact valid trial count, or clock alignment. No trial windows are approved here. |
| U4 | FB2360-Hyperoxia: description only says Hyperoxia; intervention start/end are unspecified. Its stored selected-series shape is [512,512,1200], unlike the [512,512,1800] arrays in the other four hyperoxia records. Do not copy their window or assume recovery coverage. |
| U5 | All five microsphere descriptions state 1 um particles, whereas the Science paper methods state 4 um. Resolve protocol provenance and compatible controls before interpreting an induced-obstruction comparison; do not silently replace either value. |
| U6 | nm200423-A2 pair: awake description states KX surgery and brainwide expression; KX description states isoflurane surgery and local somatosensory expression. Canonical promoter is GFAP.PHP in both. Verify preparation and correspondence without overwriting source descriptions. |
| U7 | State comparison: KX immediately after surgery, quiet awake 5-6 h after, and mobile 24 h after on a sphere according to descriptions. Preparation, acquisition, elapsed time, and behavior availability differ. State association is not an isolated causal effect of locomotion/anesthesia. |
| U8 | Awake/isoflurane descriptions specify awake first. Verify session matching and any wash-in/exclusion windows; do not infer within-day timing from date-only midnight timestamps or ignore order effects. |
| U9 | Gas intervals are description-level evidence only. Verify recording clock, actual exposures, intervention transitions and usable baseline/recovery before making executable windows. FB2359 and FB2360 each occur in both gas families; these are not independent animals across families. |
| U10 | Calibration: gas steps of one minute and electrode insertion are described, but sequence, electrode signal availability/calibration, alignment and usable plateaus require verification. nm190910 has two recordings from one animal. |
| U11 | nm200420-A1: expression-labelled dual-series asset. BLI.tif is selected; reserve as support pending a defined scientific role. It is not automatically another spontaneous KX baseline. |
| U12 | Twenty supplied CSV rows have no matching archive session. Keep them as an external-acquisition search list, not archive cohort members; same-mouse candidates are not replacements. |
| U13 | Fluorescence FB2411 is an optional BOI artifact-support control only, not a BOI biological observation or automatically a labelled false-positive benchmark. |

The 1-versus-4 um microsphere conflict refers to the existing NWB descriptions
versus the Science paper (main text / Supplementary Methods, microsphere
injection). It does not establish which source is wrong. Filename/identity and
preparation discrepancies above are likewise flags for verification, not silent
corrections to canonical metadata.

## External acquisitions not yet available in this archive inventory

The supplied CSV has 20 unmatched recording rows, listed below as leads for a
later local-data inventory. Paths are source labels, not verified local files.
Eight additional candidate-only CSV rows concern the four H01 assets and must
not become eight independent recordings. No new local acquisition was inspected.

| CSV row | Source recording label | Mouse | Original condition |
| --- | --- | --- | --- |
| 20 | ID32_20201126 | ID32_Geriatric | Awake_mobile |
| 21 | ID34_20201126 | ID34_Geriatric | Awake_mobile |
| 22 | ID38_20201126 | ID38_Geriatric | Awake_mobile |
| 23 | ID52_20201127 | ID52_Geriatric | Awake_mobile |
| 24 | ID54_20201127 | ID54_Geriatric | Awake_mobile |
| 25 | ID60_20201127 | ID60_Geriatric | Awake_mobile |
| 27 | M401\04_whisker_iso | ID401 | Anesthetized_stim30s |
| 29 | M403\04_whisker_iso | ID403 | Anesthetized_stim30s |
| 31 | M400\04_whisker_iso | ID400 | Anesthetized_stim30s |
| 33 | M402\04_whisker_iso | ID402 | Anesthetized_stim30s |
| 35 | M401\02_whisker_awake | ID401 | Awake_immobile_stim30s |
| 37 | M403\02_whisker_awake | ID403 | Awake_immobile_stim30s |
| 39 | M400\02_whisker_awake | ID400 | Awake_immobile_stim30s |
| 41 | M402\02_whisker_awake | ID402 | Awake_immobile_stim30s |
| 58 | FB2312\whisker_awake | FB2312 | Awake_immobile_stim30s |
| 60 | FB2312\whisker_iso | FB2312 | Anesthetized_stim30s |
| 62 | FB2314\whisker_awake | FB2314 | Awake_immobile_stim30s |
| 64 | FB2314\whisker_iso | FB2314 | Anesthetized_stim30s |
| 66 | FB2315\whisker_awake | FB2315 | Awake_immobile_stim30s |
| 68 | FB2315\whisker_iso | FB2315 | Anesthetized_stim30s |

## Development and evaluation status

Known prior reference recordings are M400-01-baseline-awake,
M400-03-baseline-iso, M401-01-baseline-awake, M401-03-baseline-iso,
FB2312-baseline-awake, FB2316-baseline, ID13-20200917 and FB2411, documented
in [the reference-set record](REFERENCE_SET_PHASE1.md). The companion JSON
flags these and other recordings from the same animals. This is a minimum known
list, not a complete audit of all previous use. No row is labelled untouched or
held-out. Final development/evaluation partitioning must account for animals and
all earlier investigations.

## Decisions needed to freeze the cohort

1. Accept or revise comparison priorities and primary outcomes. Proposed order:
   C02 paired state contrast and C01 state association, followed by separately
   specified C03/C04/C05 responses; C06 requires control/protocol resolution.
   This is planning order, not approval to ignore acquisition confounds.
2. Resolve identity/mapping issues, starting with U2 and H01, or explicitly hold
   affected comparisons/records. Confirm whether missing CSV acquisitions can be
   located for a separate local transfer sample.
3. Establish actual stimulus/gas timing from acquisition records or identified,
   synchronized channels. Approve baseline/intervention/recovery windows only
   after checking coverage and transitions.
4. Complete acquisition and signal QC, record metric-specific eligibility, and
   freeze development/evaluation roles before new tuning or final evaluation.
5. Select final statistical contrasts and models with animal-level replication;
   preserve repeated measures and per-metric missingness. Only then freeze the
   cohort manifest and batch configuration.

## Sources and reproducibility

- [Existing reconciliation summary](DANDI_METADATA_RECONCILIATION.md).
- Local source: `metadata-reconciliation/recording-manifest.json`, pinned below.
- [Complete planning ledger](planning/boi-cohort-20260910.json): 87 unique asset
  assignments, 21 candidate recording pairs, 20 unmatched CSV leads, and issues.
- [Update-round plan](REANALYSIS_UPDATE_PLAN.md).

Source manifest SHA-256: `4fe790ecde8b131551e2ec36cbda2d0a2c6bbd8e375aab5cf969dd76ef4901dc`.

Counts and assignments were checked against the source manifest. No source
metadata, analysis code, detector output, or manuscript was changed. No new
movie download, detection run, signal QC, or power calculation was performed.
