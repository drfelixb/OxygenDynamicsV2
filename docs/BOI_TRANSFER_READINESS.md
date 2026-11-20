# Additional local BOI recordings: transfer preparation

15 September 2026 · R3-TRANSFER-READINESS-070

This increment selects four local source candidates and checks their readiness
for the existing MATLAB import workflow. It extends the transfer preparation
beyond the four guided FB2314 events. It does not test event detection,
physiological accuracy or generalization of the reviewed optical measurements.

## Selection fixed before new source access

The rule selects the first row in the existing HP inventory with no recorded
identity issue in each of three CSV expression groups. FB2410 is added as the
documented trigger-metadata conflict case. No new event appearance, amplitude,
yield or timing agreement is used to select cases. A failed case is retained
without replacement. “No recorded identity issue” is not verified animal identity.

| Candidate label | CSV line / label | Purpose | Prior source relationship |
|---|---|---|---|
| FB2420 | 7 / GFAP-ECS | First ECS candidate without a recorded identity conflict | No matching mouse in the existing archive ledger |
| FB2311 | 8 / GFAP-GeNL | Comparable local import with an archive-series link | Baseline series matches asset `06dec506-92c2-40e0-b4a7-9a023a2e1da3` by recorded name; whole-movie equivalence is unverified |
| FB2402 | 14 / hSyn-GeNL | Additional CSV expression stratum | No matching mouse in the existing archive ledger |
| FB2410 | 21 / hSyn-GeNL | Conflicting internal-trigger tag | No matching mouse in the existing archive ledger |

The six GFAP-GeNL HP entries overlap the archive inventory. Local storage does
not make FB2311 a new biological replicate. Absence of the other labels from
the ledger is not a verified assertion of complete DANDI absence. Source/header
inspection already occurred in earlier phases; outside-workspace outcome
inspection and V2/AQuA2 tuning history remain unknown. All four candidates have
a **descriptive transfer-preparation role**, with no untouched or independent
evaluation assignment. The earlier FB2416/FB2417 duplicate-source issue and all
other identity conflicts remain preserved in the full inventory.

This purposive set spans CSV expression labels and metadata variants. All four
have 512 × 512 × 1,200 stored samples, 16-bit TIFF storage and provisional CSV
scale 2.35 µm/pixel. It does not span the broader cohort's pixel scales, awake
states, motion, frame counts or actual signal variability. No pooling across
expression labels or state inference from the repeated CSV fields is justified.

## Source and import checks

All four files are present and match the earlier recorded byte counts and
dimensions. Full-file checksums were recorded before MATLAB import and matched
the import review's independently read source hashes. None had a prior full
source hash in this inventory: this establishes current source identity, not
historical byte-for-byte equivalence. The original metadata CSV matches its
earlier checksum. Each candidate's one named reference image matches the
previous reference inventory's checksum. Reference pixels and alignment have
not yet been assessed; neither old output figures nor AQuA2 files are anatomical
ground truth.

Workspace staging uses links to the exact earlier source TIFFs, with separate
source-bound acquisition declarations. No source movie is copied or modified;
no top-level denoised movie is silently substituted. The stage relies on the
connected drive and should be checked again before a later run. The declaration
and source paths/checksums are recorded separately from the original files.

Timing uses the researcher's confirmed **external 1 Hz trigger**. Embedded
clock fields are retained as unreliable provenance. FB2410's first-page
`Internal` tag remains a visible source-QC item; it neither overrides the
confirmation nor creates a new timing hold. Frame 1 is modeled time zero,
and inclusive sample duration remains distinct from endpoint span.

FB2420, FB2402 and FB2410 have a 960 ms first-page exposure setting; FB2311 lacks
that inspected camera field. No all-frame exposure consistency has been checked,
and exposure is not set equal to the one-second sample interval. The declarations
therefore leave analytical exposure unknown and link to the available first-page
evidence. Camera `PixelSizeUm=0` is not usable calibration and does not replace
the provisional CSV scale.

The existing MATLAB import function is used unchanged. Its result and every QC
message are preserved in the [evidence packet](reference-results/boi-transfer-readiness-20260915/README.md).
All four returned `descriptive_input_requires_scientific_review`: FB2420 in
5.74 seconds, FB2311 in 3.75, FB2402 in 4.09 and FB2410 in 4.06, excluding
MATLAB startup. Source/header hashing took under one second per candidate.
The first three emitted eight QC rows each; FB2410 emitted nine, including
the trigger conflict. All 485 existing MATLAB files and all 36 sealed phase-069
artifacts were preserved. The preparation and import-readiness phase is complete.

Technical readability permits further source review; it does not approve tissue,
frame validity, physiological baseline, event identity or biological comparisons.
No new image pixels were interpreted, no legacy event outcomes were read, and
no detector or reviewed optical calculation was run in this increment.

## Bounded next stage

Proceed with source/tissue and preparation assessment on the selected cases,
starting with FB2420, before freezing any new event comparison queue. Retain the
same four cases and log a hold instead of substituting an attractive recording.
Use same-recording source/reference evidence to assess the craniotomy, grid
alignment and observable tissue. A smaller craniotomy may occupy only part of
the field; corners or intensity alone do not establish a tissue boundary.
Unresolved anatomy restricts the affected area-normalized or physiological claim.

Before accessing new event outcomes, specify a fixed queue covering both saved
signs, missing automatic baselines, recurrence and recording-specific variability,
along with review effort and stopping rules. Do not transfer the four FB2314
reference windows, durations or recognition judgments to another recording.
Actual reviewed onsets, recoveries and reference frames require new explicit
judgments. The corrected intensity trace remains primary for those judgments,
the filtered score supporting and the raw/trend view correction QA.

Any later reviewed optical result must retain the original fixed native union
footprint and preserved-input denominator under the separate pinned draft
definition. Preserve original automatic results, native overlaps, unknown
recognition, all accepted alternatives and unavailable values. Do not fit a
common substrate decline, repair signs, equate different reference precision,
or change production settings to obtain agreement. An inconclusive result
retains the current rule and restricts the claim. Later detector/timing changes
still require the existing 48-event challenge and a distinct decision.

The readiness budget is four candidates, one source/header pass plus one import
pass per candidate, at most ten minutes per candidate, 256 MiB of new evidence,
zero movie copies and zero detector runs. No manual annotation is needed to
complete readiness. Numerical integrity/import failures stop the affected case;
scientific unknowns stay in QC and remain measurement-specific restrictions.
These are feasibility limits, not invented biological acceptance thresholds.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Physical calibration,
label semantics, preparation, substrate timing, anatomical support, native sign
versus pocket morphology, reference precision/duration, independent validation
and cohort eligibility remain unresolved where not explicitly established.
