# C02 figure mapping and pre-recording state establishment

12 September 2026 — R1-C02-CONTEXT-022. This corrects the experimental-context
requirement in the preceding source/window reviews; their dated evidence remains
preserved. [Structured evidence](planning/boi-c02-figure-context-20260912.json)
retains source IDs, workbook rows and PDF hashes.

## Exact recordings under discussion

| Mouse | Local animal folder | Awake session | Isoflurane session |
|---|---|---|---|
| FB2314 | FB2314 | FB2314-baseline-awake | FB2314-baseline-iso |
| FB2315 | FB2315 | FB2315-baseline-awake | FB2315-baseline-iso |
| ID402 | M402 | M402-01-baseline-awake | M402-03-baseline-iso |
| ID403 | M403 | M403-01-baseline-awake | M403-03-baseline-iso |

The annotated source workbook maps each awake session to **Figure 4** and each
isoflurane session to **Figure S13**. The individual animal names come from the
workbook/manifest; they are not printed as animal labels in the figure.
All seven isoflurane records labelled S13 in that manifest are FB2312, FB2314,
FB2315, ID400, ID401, ID402 and ID403. The four above were the additional pairs
in the recent source audits, not the entire seven-mouse comparison.

## Published figure context

The [Science paper](https://pmc.ncbi.nlm.nih.gov/articles/11251491/)
(DOI 10.1126/science.adn1011) identifies **S13A-G** as the isoflurane comparison.
The local NIH supplement, page 21, was read and visually inspected. S13A describes
awake recording followed by recording under isoflurane; C/D show separate awake
and isoflurane traces over 600 seconds, and the caption gives **N = 7 mice**.
This supports the separate-state design. It does not establish a drug-onset
event inside each file or provide a measured stabilization duration.

Figure 4 is the KX/quiet-awake/mobile comparison. Its context was checked in the
local author proof, PDF page 10/printed page 6; the proof status is retained in
the source record. The awake recordings can contribute to that figure and also
serve as the paired awake condition in S13.

The S13 C/D caption contains normoxia/hyperoxia wording inconsistent with its
title, design and condition labels. Treat this as an apparent caption error,
not evidence for an intra-recording gas transition. The original text is preserved.
S13's ten-minute description and 600-second plotted extent do not identify which
historical frames were used from the 1,200-frame FB sources. That is a published-
analysis reproduction question; it does not authorize trimming current sources.

## Correction following the researcher's clarification

For recordings where isoflurane was not applied during the file, the researcher
states that baseline/state establishment occurred beforehand and was not measured.
Apply this to the separate-state C02 interpretation supported above:

- Record **pre-recording state established; establishment interval unmeasured**.
- Do not require or search for an intra-file isoflurane-onset/wash-in period or
  an unrecorded pre-isoflurane baseline. The separate measured awake control is
  distinct from this unmeasured establishment interval.
- Leave the numerical establishment duration unknown without making its recovery
  a prerequisite for a state comparison. Do not infer it from brightness, file
  names, acquisition-clock gaps or the 20-second event-amplitude reference.
- Restrict claims to state comparisons. Induction kinetics or time-since-dose
  effects would need measured administration timing.

The preceding questions about a mandatory numeric stabilization interval are
superseded. The user's short earlier “Confirm” is not used to invent a duration;
the present explicit clarification supplies the interpretation.

Observable support, frame validity, comparison exposure and animal-level pairing
remain relevant. No mask, window or exclusion is adopted by this correction.
Retain the exact external 1 Hz grid, both BOI signs, biological variability and
the known preparation/order limits. No source, prior result or method was changed.
