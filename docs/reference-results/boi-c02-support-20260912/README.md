# C02 default spatial-support audit

12 September 2026 — **R1-C02-SUPPORT-023: calculation audit complete.**
The unchanged MATLAB source-loading, cubic detrending and automatic-mask helpers
were replayed on all eight published C02 sources. Both sign masks and their
nominal area-time denominators are now visible and independently checked.
This does not adopt a tissue mask or establish scientific eligibility.

## Main finding

The automatic rule selects **67.47–69.41% of each 512 × 512 image**. It uses
how often each detrended pixel exceeds the detrended whole-frame mean, then
keeps occupancy values strictly above the 30th percentile. The similar area
fractions are largely imposed by that rule, with ties reducing them below 70%.
They are not independent evidence of comparable observable tissue.

The eight sheets show scattered peripheral inclusion and internal exclusions.
These need source/preparation-based review. A lower BOI signal, changing dark
region or vessel-like appearance alone does not justify a non-tissue label.
No percentile search, morphological cleanup or outcome-based masking was done.

| Recording — click for source and mask | Nominal seconds | Automatic native fraction | Sink area (mm²) | Surge area (mm²) |
|---|---:|---:|---:|---:|
| [FB2314-baseline-awake](FB2314-baseline-awake/SupportReview.png) | 1200 | 69.22% | 0.8948 | 1.0021 |
| [FB2314-baseline-iso](FB2314-baseline-iso/SupportReview.png) | 1200 | 68.27% | 0.8756 | 0.9883 |
| [FB2315-baseline-awake](FB2315-baseline-awake/SupportReview.png) | 1200 | 68.32% | 0.8902 | 0.9891 |
| [FB2315-baseline-iso](FB2315-baseline-iso/SupportReview.png) | 1200 | 68.34% | 0.8718 | 0.9894 |
| [M402-01-baseline-awake](M402-01-baseline-awake/SupportReview.png) | 600 | 68.81% | 3.5872 | 4.0698 |
| [M402-03-baseline-iso](M402-03-baseline-iso/SupportReview.png) | 600 | 69.41% | 3.4832 | 4.1056 |
| [M403-01-baseline-awake](M403-01-baseline-awake/SupportReview.png) | 600 | 67.47% | 3.6191 | 3.9907 |
| [M403-03-baseline-iso](M403-03-baseline-iso/SupportReview.png) | 600 | 67.67% | 3.6543 | 4.0022 |

These are **areas selected by the current software**, using the recorded pixel
scale. They are not validated anatomical areas or biological outcomes. Larger
ID402/ID403 physical areas reflect their larger recorded µm/pixel as well as
selected pixel counts; this is not evidence of a physiological difference.

## Sign-specific support and observation time

The default sink crop removes a 20-pixel native border; surge support keeps the
automatic native mask. This removes **8.69–15.16%** of the automatic selected
pixels, depending on the file. The crop is **47 µm** wide at 2.35 µm/pixel and
**95 µm** at 4.75 µm/pixel. Its physical rationale and any associated losses
remain review questions. No border or detector setting changed.

The native border itself is selected at 39.17–70.09%, depending on the source.
The masks have 987–3,764 eight-connected components, with 91.11–97.50% of selected
pixels in their largest component. Fragmentation is a diagnostic observation,
not a component-size rejection rule or proof that a component is non-tissue.

At the confirmed external 1 Hz, nominal area-time equals selected pixel count ×
pixel size² × N seconds. [Exact CSV ingredients](summary.csv) retain both signs.
Acquisition exposure duration is separate and is not supplied by this formula.
Full nominal extents are [0,1200) s for FB2314/FB2315 and [0,600) s for ID402/ID403.
Awake and isoflurane durations already match **within every pair**. Therefore
pairing alone does not require trimming the FB recordings. Any equal-duration
sensitivity analysis needs a stated design; pooled event counts or pooled
tissue-time must not silently give longer/larger recordings more animal weight.

The [experimental-context correction](../../BOI_C02_EXPERIMENTAL_CONTEXT.md)
remains authoritative: state establishment preceded these separate-state
recordings and was unmeasured. Do not infer induction or choose a flat-looking
interval. The exact historical 600-second Figure S13 window within the longer
FB sources remains a reproduction question, separate from reanalysis exposure.
No window or frame-validity declaration is approved here.

## Evidence and practical next step

Each linked sheet shows first/middle/last source frames on the prior fixed display
scale, the temporal above-mean occupancy, the binary automatic mask with sink
crop boundary, and a middle-frame overlay with excluded pixels blue. Native
row/column orientation is preserved. Binary PNGs and uint16 occupancy-count TIFFs
accompany the sheet; local MAT files retain frame means, parameters and spatial
bins. [Per-file observations](review-record.json) distinguish technical visual
review from scientific sign-off.

Prepare justified static outer-field support using native source/preparation
evidence, retaining internal low-signal regions unless a separate reason supports
their exclusion. Compare the resulting proposals with these automatic masks
using the [existing MATLAB review workflow](../../BOI_REVIEWED_TISSUE_SUPPORT.md).
Alignment across awake/iso sessions must be demonstrated before reusing a mask;
identical dimensions are insufficient. Source darkness alone cannot supply the
missing support decision. Keep temporal validity distinct from static support.

MATLAB R2025a completed the eight-recording pass in **76.51 s**, including a
four-thread pool. The [independent Python check](verification.json) reconstructed
the native masks at all **2,097,152 spatial positions**, checked the strict
percentile/ties, sink border, components, areas and nominal area-time. Production
mask output also matched a separate count-map reconstruction inside MATLAB.
The Python check starts from exported temporal counts; it does not independently
reimplement the entire detrending pass. Eight source hashes and 460 MATLAB-file
hashes remained unchanged. The single run completed without a failed attempt.

The [artifact record](artifact-record.json) binds prespecification, executed
runner, source hashes, code snapshots, results, review and verification. Full
local evidence is in `workspace/reference-validation/boi-c02-support-20260912/`.
No source or legacy output was written, no detector was run, and no mask,
exclusion, scientific role or biological contrast was adopted. BOI both signs
remain in scope; this closes the bounded default-support audit, not all of R1.
