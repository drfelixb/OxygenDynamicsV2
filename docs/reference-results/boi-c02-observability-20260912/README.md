# C02 source observability and window review

12 September 2026 — **R1-C02-OBSERVABILITY-021: technical triage complete.**
All 7,200 source frames were scanned for prespecified pixel diagnostics. Eight
source review sheets and eight timelines were visually inspected. No tissue
mask, frame exclusion, window or scientific eligibility decision was adopted.

## Findings and source review

There are **no all-zero frames, spatially constant frames or exact adjacent
repeats** in these eight files. This rules out those particular patterns; it does
not prove acquisition completeness, motion correction, absence of interpolation,
valid observable tissue or physiological signal quality.

The frame sheets preserve native TIFF orientation. Five fixed samples span each
recording; two additional slots show the largest adjacent full-image change.
That data-driven selection is a review clue, with no abnormality threshold.
All samples within a recording use one fixed display scale. Scales differ between
recordings, so image brightness across sheets is not a quantitative state contrast.
Quantitative diagnostics always use unchanged stored pixels. Display clipping
counts and exact sampled frame IDs are retained in each `PreviewFrames.csv`.

| Recording | Review evidence | Largest-change frame pair | Nominal sampled extent |
|---|---|---|---|
| FB2314-baseline-awake | [frames](FB2314-baseline-awake/SourceReview.png) · [timeline](FB2314-baseline-awake/FrameTimeline.png) | 390 → 391 | [0, 1200) s |
| FB2314-baseline-iso | [frames](FB2314-baseline-iso/SourceReview.png) · [timeline](FB2314-baseline-iso/FrameTimeline.png) | 532 → 533 | [0, 1200) s |
| FB2315-baseline-awake | [frames](FB2315-baseline-awake/SourceReview.png) · [timeline](FB2315-baseline-awake/FrameTimeline.png) | 456 → 457 | [0, 1200) s |
| FB2315-baseline-iso | [frames](FB2315-baseline-iso/SourceReview.png) · [timeline](FB2315-baseline-iso/FrameTimeline.png) | 266 → 267 | [0, 1200) s |
| M402-01-baseline-awake | [frames](M402-01-baseline-awake/SourceReview.png) · [timeline](M402-01-baseline-awake/FrameTimeline.png) | 173 → 174 | [0, 600) s |
| M402-03-baseline-iso | [frames](M402-03-baseline-iso/SourceReview.png) · [timeline](M402-03-baseline-iso/FrameTimeline.png) | 1 → 2 | [0, 600) s |
| M403-01-baseline-awake | [frames](M403-01-baseline-awake/SourceReview.png) · [timeline](M403-01-baseline-awake/FrameTimeline.png) | 241 → 242 | [0, 600) s |
| M403-03-baseline-iso | [frames](M403-03-baseline-iso/SourceReview.png) · [timeline](M403-03-baseline-iso/FrameTimeline.png) | 292 → 293 | [0, 600) s |

The source sheets show a recognizable field and branching dark structures,
with changing interior dark regions particularly apparent in FB2315 and ID403.
Whole-frame timelines show broad changes and shorter fluctuations. These
observations do not identify an oxygen mechanism, movement artifact or an
anatomical hole. In particular, **a dim region within observable tissue must not
be excluded just because the BOI signal decreases**. Weak, sustained, irregular
and spatially changing signals remain part of the standing biological requirements.

ID402 isoflurane has limited source contrast in its displayed fixed samples;
the maximum-change selection is frames 1/2. Neither observation is a reason to
delete a frame or reject the recording. Its preserved optical preparation and
measurement sensitivity still need assessment. Session-specific observations
and their limited review scope are in [review-record.json](review-record.json).

## Stored-value limits

| Recording | Frames containing the stored-class maximum | Maximum fraction at that value in a frame | Maximum zero fraction in a frame |
|---|---|---|---|
| FB2314-baseline-awake | 0 | 0.000000% | 0.000000% |
| FB2314-baseline-iso | 0 | 0.000000% | 0.000000% |
| FB2315-baseline-awake | 0 | 0.000000% | 0.000000% |
| FB2315-baseline-iso | 0 | 0.000000% | 0.000000% |
| M402-01-baseline-awake | 600 | 0.363922% | 1.762009% |
| M402-03-baseline-iso | 1 | 0.000381% | 0.408554% |
| M403-01-baseline-awake | 600 | 0.450516% | 0.651932% |
| M403-03-baseline-iso | 600 | 0.527191% | 0.603485% |

For locally uint8 sources, the stored ceiling is 255; for uint16 it is 65,535.
These are storage-value observations, **not demonstrated camera saturation**.
Their locations and pre-TIFF scaling history remain unresolved. Zero-valued
pixels are likewise not automatically invalid tissue or lost frames. No accepted
ceiling/zero fraction threshold has been supplied, and none was invented.

## Observable support and MATLAB use

No additional reference image was found among the recording/animal top-level
files in this bounded [inventory](source-reference-inventory.json). It does not
establish that supporting anatomy is unavailable elsewhere. Legacy event maps,
processed images and exploratory AQuA2 outputs are not anatomical ground truth.

The next support decision should document a defensible observable boundary from
source images and preparation evidence, with an aligned auxiliary reference if
available. Do not substitute an intensity threshold or a dark-region contour for
that decision. Each source needs its own alignment evidence; equal dimensions or
the same animal do not establish cross-session registration. Sparse sheets cannot
certify validity through the movie.

Once a scientifically justified logical native mask is available, use the
existing [MATLAB tissue proposal workflow](../../BOI_REVIEWED_TISSUE_SUPPORT.md):
`reviewBOITissueSupport(recordingFolder, mask, newProposalFolder)` makes a proposal.
Only an actual reviewed decision with actor, rationale and evidence can be passed
to `writeBOITissueSupport` on a fresh staged recording. No such proposal or
declaration was manufactured here. Existing sink border/support and separate
surge denominator rules remain unchanged.

## Experimental windows and frame validity

The full nominal sampled extents are [0,1200) s for FB2314/15 and [0,600) s for
ID402/403. These follow exact external **1 Hz** sampling; the last frame indices
are 1199 and 599 seconds. Sampling exposure is not camera integration time.
No equal-duration truncation, experimental baseline or stable interval was chosen.

The published preparation description states awake-first followed by isoflurane
and fresh substrate before recording onset. Earlier ABF header records exist for
FB2314/15 in both states and ID403 awake; the exact source IDs/hashes are linked
in the review record. They do not establish isoflurane start, wash-in/stabilization,
or corrected absolute image-to-experiment alignment. The user has been asked for
the stabilization period or acquisition evidence; unanswered fields remain null.
Incorrect recording clocks are not used to replace the confirmed time grid.

Choose exposure using experimental evidence and the intended scientific question,
not a flat-looking part of a trace, fewer events, or an expected treatment effect.
The 20-second event-amplitude baseline is not an experimental wash-in interval
and does not authorize dropping the first 20 seconds of coverage.

If review identifies invalid frames, preserve their original indices and reasons.
The current `resolveBOIAcquisitionMetadata` implementation explicitly holds
recordings with declared frame exclusions because its temporal preprocessing
assumes contiguous observation. Do not delete/renumber frames or mark every frame
valid merely to pass import. This is an existing implementation limit, not a new
scientific exclusion rule introduced by this audit.

## Verification, feasibility and disposition

MATLAB scanned the eight files in **52.3 seconds** including initial
plots. The [independent checks](verification.json) verified all 7,200 diagnostic
rows, source hashes, deterministic frame selection and 55
unique sampled-frame pixel calculations, including their adjacent differences.
All 460 MATLAB implementation files remain unchanged. Figures initially had
overlapping headings; layout-only rendering fixed that using the same frames and
scales. Original figures, scan results and executed code are preserved locally.
No scan was repeated to improve its result.

The [prespecified plan](../../planning/boi-c02-observability-20260912.json), source-bound
review record, per-frame diagnostics and [artifact record](artifact-record.json)
preserve traceability. No scientific mask/window/frame approval, detector,
legacy event analysis, biological contrast or statistics run occurred.

**Disposition:** retain all sources and current rules. Close this bounded
source-QC triage. Proceed to the actual observable-support and experimental-window
decisions using the evidence above; recording eligibility and biological claims
remain measurement-specific. These eight published recordings remain reanalysis
candidates, not eight independent animals or an untouched evaluation cohort.
