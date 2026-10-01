# BOI cohort issue resolution

10 September 2026. This is the current resolution record for the issues in
[the cohort proposal](BOI_COHORT_COMPARISONS.md). It supplements the original
manifest without erasing conflicting source values. Metadata decisions do not
constitute signal QC, a final cohort freeze or approved analysis windows.

The [structured decisions](planning/boi-cohort-resolution-20260910.json) link
source asset IDs to corrections and remaining requirements. The
[local evidence](planning/boi-local-source-evidence-20260910.json) records source
paths relative to `Lab/Publications/Published Science Oxygen BLI`, acquisition
file hashes, header values, first-frame fingerprints and measured pulse edges.
No biological event detector was run for this audit.

## Findings and decisions

**Microspheres — corrected.** The user explicitly confirmed: “the microspheres
were 4 µm not 1 µm. the paper is right.” Record 4 µm for FB2352, FB2353, FB2354,
FB2355 and FB2364. Retain the archive's original 1 µm descriptions and this
correction's origin/date. This resolves U5's particle-size conflict. Selection
of compatible controls is still a separate scientific requirement under R4.

**FB2315 — distinct local recordings.** Both the containing folder and pooled
recording table identify FB2315, although the TIFF filenames contain FB2314.
The corresponding awake and isoflurane images differ from the FB2314 files
already in the first frame. The acquisition files also differ in content hash,
start time and sample count. Retain FB2315 as the local identity and preserve
the filename discrepancy; do not relabel the animal from the filename alone.

| Folder / condition | ABF | Acquisition start, 20 April 2023 |
|---|---|---|
| FB2314 / awake baseline | 23420000.abf | 14:01:17.453 |
| FB2314 / isoflurane baseline | 23420002.abf | 14:46:20.031 |
| FB2315 / awake baseline | 23420005.abf | 15:36:08.194 |
| FB2315 / isoflurane baseline | 23420007.abf | 16:22:05.180 |

These are acquisition-clock values; no timezone conversion is inferred. This
resolves the concern that the local files are identical. Whole-movie equivalence
between these TIFFs and the archived NWB payloads has not been established.
The broader archive-to-source integrity check remains in G1; it must not be
described as completed based on filename matches or first-frame differences.

**F120, F134, F136 and M189 — baseline correspondence supported.** Each archive
selected-series filename exactly matches a TIFF in that animal's local baseline
folder, which is separate from its whisker folder. All four local baseline
movies have 1,200 frames. For F120/F134/F136, the local ABF start time and sample
count also match the previously cached NWB headers. The M189 cached header
does not contain those analog details. This supports baseline correspondence;
there is no basis for splitting an archive asset into baseline and whisker.

The 1.54 versus 1.55 µm/pixel discrepancy remains: these processed TIFF headers
contain no usable spatial calibration. Original label differences (including
AQP4WT/WT and promoter shorthand) remain visible as well. Keep these four
records on hold for quantitative cohort inclusion until the calibration and
required labels are reconciled. Do not fill all canonical fields merely because
the baseline mapping is now supported.

**Six KX whisker recordings — timing recovered from acquisition signals.** The
original KX stimulation table assigns camera channel 1 and puff channel 5
(one-based). Its historical analysis reads channel 5, despite a conflicting
comment naming channel 4. The original ABFs contain ten trains of 150 pulses
each, with first onsets at 59.997–59.998 s and subsequent trains roughly 90 s
apart. The last train begins at 869.903–869.904 s. These are measured acquisition
times; the last detected pulse end is not equated with a nominal 30-second
protocol endpoint. Per-recording edges are saved, not replaced by rounded times.

Five files contain 1,200 camera rising edges. FB2319 contains a regular first
sequence of 1,200, followed by 123 additional edges starting at 1240.200 s.
Those later edges must not be appended to a 1,200-frame movie. Preserve the
candidate sequence and extra pulses separately. Camera intervals also depart
slightly from an exact one-second grid. Final image-to-camera correspondence,
exposure conventions, trial QC and baseline choices are still required before
executable analysis windows are approved. The separate 10-second awake/KX
protocol remains unresolved by this evidence.

**FB2360 hyperoxia — recording length confirmed, timing still unknown.** The
local motion-corrected TIFF also contains 1,200 frames, matching the archived
shape. Its name supports a 30% oxygen/10-minute protocol but does not establish
the switch times. No local ABF was found beside that TIFF. Do not borrow the
other recordings' 600–1200 s window or infer a recovery period. An acquisition
log or authoritative clarification is still required.

**Local acquisition availability — all 20 search entries located.** Each
previously unmatched CSV entry has an image file in its local session folder.
These are candidates for the planned transfer check, not 20 automatically
eligible additions to the archive cohort. Four separate H01 whisker recordings
also exist locally; they remain distinct from the archived baseline candidates.

## Remaining issues and their disposition

| Issue | Current disposition / requirement |
|---|---|
| G1 | Open: signal/source integrity, axes, tissue, intensity history, exposure and measurement-specific QC. Source inspection is not a biological validation run. |
| G2 | Open: freeze development/evaluation roles. This audit read acquisition signals and selected first frames; preserve that inspection history. |
| U1 | Baseline mapping supported; physical calibration and required labels unresolved. Hold the four records for quantitative cohort inclusion. |
| U2 | Local files established as distinct; retain folder/table identity FB2315. Archive payload equivalence remains unverified under G1. |
| U3 | KX 30-second acquisition pulse timing recovered; final frame/trial alignment pending. Short-protocol timing still open. |
| U4 | Local and archive lengths agree; FB2360 hyperoxia switch times still open. |
| U5 | Particle diameter resolved to 4 µm by user confirmation and published methods. Compatible-control selection remains under R4. |
| U6 | nm200423-A2 preparation conflict still open; do not use this pair in a preparation-matched contrast without clarification. |
| U7 | Resolve by restricting interpretation to state-associated differences, with preparation/acquisition confounds reported. No isolated causal-state claim. |
| U8 | Local headers verify awake-before-isoflurane order for FB2312/14/15. Only an awake ABF was located alongside M403 baseline; neither baseline ABF was found in the inspected M400–402 folders. Wash-in and other pair timing remain open. |
| U9 | Description-level gas intervals retained; no transition/exposure windows promoted to approved analysis windows. Repeated animals remain linked across gas families. |
| U10 | All seven calibration NWB headers name oxygen, raw electrode and calibration-ID channels. Channel presence is established; calibration validity, alignment and usable plateaus remain open. |
| U11 | Resolve role: expression-labelled BOI remains support-only unless a specific analysis is justified; no spontaneous-baseline pooling. |
| U12 | All 20 local search entries located; separate local import/QC needed before transfer use. |
| U13 | Resolve role: fluorescence is optional artifact support, never automatic false-positive ground truth or a BOI biological observation. |

IOSI remains excluded from the round. No IOSI recordings were analyzed here.
Unresolved experimental facts stay visible and block only the affected claims
or measurements; they must not be guessed in order to close an issue list.

## MATLAB fix and verification

Opening an original ABF2 failed in `external/abfload.m` because a protocol path
containing multiple backslashes was used as a vector start for a colon
expression. Selecting the first backslash fixes the intended path extraction.
MATLAB R2025a then read the previously failing file successfully; this audit
also read 17 local ABF headers and decoded all six KX whisker ABFs. Signal scaling
and timing formulas in the reader were not changed. No full pipeline rerun is
claimed for this import fix.

Consistency checks passed for the 87 preserved source records, all five
particle-size corrections, 20 located external sessions, 17 ABF header reads,
nine TIFF inspections, six ten-train puff sequences, and the distinct FB2314/15
fingerprints. Source-manifest and evidence-file hashes were checked. No approved
analysis windows were introduced by the resolution overlay.

A further six-asset remote-header check was stopped after it stalled, with no
completed result. It contributes no evidence to these decisions. The earlier
cached NWB metadata and the completed local audit are the basis reported here.

The [researcher workflow contract](RESEARCHER_WORKFLOW_AND_TRACEABILITY.md)
makes readable calculations, retained original/corrected metadata, inspection
and reproducible exports release requirements. A later UI pass may improve
presentation; provenance must be retained from this work onward.

## Subsequent C02 source-equivalence resolution — 12 September 2026

[R1-C02-PROVENANCE-020](reference-results/boi-c02-provenance-20260912/README.md)
resolves the previously unverified local-to-archive pixel correspondence for
FB2314, FB2315, ID402 and ID403 in both awake and isoflurane sessions. All eight
pinned NWB containers passed SHA256 checks. MATLAB and independent Python
comparisons agree on every pixel in all 7,200 frames under the explicit mapping
`local[row,column,frame] = NWB[column,row,frame]`. The current MATLAB archive
adapter already uses this orientation. No intensity rescaling or frame reordering
is required. ID402/ID403 are locally uint8 and archived as uint16 with unchanged
numeric values. Canonical FB2315 identity and discrepant original names remain.

This closes the source-array equivalence part of U2/G1 for these eight cases;
the earlier negative statement is retained above as dated audit history. It does
not extend to other cohort records. Original upload code and pre-TIFF intensity
preparation remain unlocated/unresolved. Reviewed tissue, dynamic validity,
camera exposure, experimental alignment and eligible windows remain separate
measurement requirements. Exact external 1 Hz timing is retained. No cohort
eligibility, scientific role or new biological analysis is implied.

## U8 interpretation corrected from figure context and researcher clarification

[R1-C02-CONTEXT-022](BOI_C02_EXPERIMENTAL_CONTEXT.md) identifies the four recently
audited pairs and checks their Figure 4/S13 mapping. S13 is a seven-mouse
awake/isoflurane separate-state comparison. The researcher clarifies that,
when isoflurane was not applied during the recording, a baseline/state had been
established beforehand but that interval was not measured. Do not require an
intra-recording induction/wash-in segment or numerical stabilization duration
for these state comparisons. Retain the unmeasured duration and restrict any
kinetic claims accordingly. Valid support/exposure, order and pairing remain
relevant; this correction does not itself select or approve analysis windows.
