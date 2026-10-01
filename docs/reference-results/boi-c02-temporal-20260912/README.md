# C02 full-frame temporal diagnostic

12 September 2026 — **R1-C02-TEMPORAL-025: diagnostic pass complete; temporal validity remains unresolved.**
All 7,200 original frames from the eight published C02 BOI sources have diagnostic
rows at the researcher-confirmed external **1 Hz**, with time = original frame − 1.
No embedded file timestamp is used. The largest apparent corrections occur in
awake ID402 and ID403, where peak correlation scores are low; they need focused
source review before interpretation as physical motion or observation loss.

This follows the [unadopted outer-field proposals](../boi-c02-outline-proposals-20260912/README.md)
and retains the [experimental-context correction](../../BOI_C02_EXPERIMENTAL_CONTEXT.md):
these awake/isoflurane files compare separate established states. Pre-recording
state establishment was unmeasured. No numerical stabilization duration or
intra-file induction baseline is imposed. Both BOI signs remain in scope.

## Method and meaning

One fixed MATLAB R2025a pass used native single source pixels and explicit
`imregcorr(moving,fixed,'translation','Method','gradcorr')`, against frame 1 and
against the preceding frame. The method was fixed before the scan; no masks,
smoothing, intensity threshold, source resampling or method tuning was applied.
The returned x/column and y/row values are estimated corrections taking the moving
image into reference coordinates, **not independently measured tissue movement**.
See the [MathWorks method documentation](https://www.mathworks.com/help/images/ref/imregcorr.html).

Peak scores and unregistered Pearson correlation to frame 1 accompany the
estimates. Low scores weaken interpretation; no score or displacement cutoff is
an exclusion rule. Small estimates also cannot rule out local deformation,
focus changes or occlusion. Signal changes may themselves alter registration.
Whole-image row/column intensity sums are retained for every frame, providing
continuous projected structure without defining tissue support.

## Recording-specific clues

Values below are algorithm estimates in **native pixels**; @ denotes the original
one-based frame. The FB scale is 2.35 µm/pixel and ID402/ID403 is 4.75 µm/pixel.
The CSV also preserves micrometres, source checksums and every original frame.

| Mouse / state | Maximum to frame 1, px @ frame | Maximum to previous, px @ frame | Minimum fixed peak @ frame | Review figures |
|---|---:|---:|---:|---|
| FB2314 / awake | 0.271 @ 1105 | 0.242 @ 435 | 0.4172 @ 351 | [traces](FB2314-baseline-awake/TemporalOverview.png) · [profiles](FB2314-baseline-awake/ProjectionTimeline.png) · [source frames](FB2314-baseline-awake/SelectedSourceReview.png) |
| FB2314 / iso | 0.266 @ 420 | 0.054 @ 201 | 0.3920 @ 871 | [traces](FB2314-baseline-iso/TemporalOverview.png) · [profiles](FB2314-baseline-iso/ProjectionTimeline.png) · [source frames](FB2314-baseline-iso/SelectedSourceReview.png) |
| FB2315 / awake | 0.272 @ 109 | 0.705 @ 420 | 0.3435 @ 1179 | [traces](FB2315-baseline-awake/TemporalOverview.png) · [profiles](FB2315-baseline-awake/ProjectionTimeline.png) · [source frames](FB2315-baseline-awake/SelectedSourceReview.png) |
| FB2315 / iso | 0.503 @ 930 | 0.102 @ 601 | 0.3761 @ 624 | [traces](FB2315-baseline-iso/TemporalOverview.png) · [profiles](FB2315-baseline-iso/ProjectionTimeline.png) · [source frames](FB2315-baseline-iso/SelectedSourceReview.png) |
| ID402 / awake | 2.121 @ 315 | 2.967 @ 503 | 0.0227 @ 505 | [traces](M402-01-baseline-awake/TemporalOverview.png) · [profiles](M402-01-baseline-awake/ProjectionTimeline.png) · [source frames](M402-01-baseline-awake/SelectedSourceReview.png) |
| ID402 / iso | 0.504 @ 458 | 0.509 @ 304 | 0.0279 @ 587 | [traces](M402-03-baseline-iso/TemporalOverview.png) · [profiles](M402-03-baseline-iso/ProjectionTimeline.png) · [source frames](M402-03-baseline-iso/SelectedSourceReview.png) |
| ID403 / awake | 3.664 @ 546 | 1.637 @ 450 | 0.0156 @ 269 | [traces](M403-01-baseline-awake/TemporalOverview.png) · [profiles](M403-01-baseline-awake/ProjectionTimeline.png) · [source frames](M403-01-baseline-awake/SelectedSourceReview.png) |
| ID403 / iso | 0.503 @ 377 | 0.529 @ 259 | 0.0402 @ 318 | [traces](M403-03-baseline-iso/TemporalOverview.png) · [profiles](M403-03-baseline-iso/ProjectionTimeline.png) · [source frames](M403-03-baseline-iso/SelectedSourceReview.png) |

For each recording the source sheet contains frame 1 plus the frames before/at
the maximum fixed correction, maximum adjacent correction and minimum fixed peak
(excluding frame 1 for the minimum). There are 56 unique selected frames overall.
These are diagnostic selections, not an exhaustive visual review or approved
windows. Each recording directory contains `FrameDiagnostics.csv` and
`ReviewSelection.csv` to recover the original index and selection reason.

**FB2314-baseline-awake:** Broad spatial bands persist across the row/column profiles while brightness rises then falls. Selected vascular structures remain recognizable. Subpixel correction estimates do not establish absence of local motion or changing observability.

**FB2314-baseline-iso:** Broad bands remain recognizable, with brightness and oscillation changes over time. Selected frames show no obvious gross field jump at contact-sheet scale. This is an established-state recording; brightness does not define stabilization.

**FB2315-baseline-awake:** The adjacent-estimate maximum at frame 420 coincides with a brightness dip and lower similarity. Broad spatial bands persist; internal dark patterns change. Motion versus changing signal remains ambiguous.

**FB2315-baseline-iso:** Slowly changing intensity profiles and internal dark regions accompany subpixel correction changes. Broad projected structure persists. These observations do not justify carving out dark tissue or choosing a flat interval.

**M402-01-baseline-awake:** Apparent corrections show repeated steps and a large adjacent estimate at frame 503, with low peak scores. The grainy selected source frames retain recognizable broad vessel positions, but contact sheets cannot resolve whether the estimated two-to-three-pixel correction represents rigid motion. Brightness declines; projected bands mostly persist.

**M402-03-baseline-iso:** The source is faint at the fixed display range [1,40]; boundaries remain uncertain despite predominantly small correction estimates. Broad projected bands persist during gradual brightness decline. Low intensity is not automatic invalidity.

**M403-01-baseline-awake:** The largest fixed-reference estimate occurs at frame 546, with low peak scores throughout much of the recording. Broad vessel structure remains recognizable in selected frames; small rigid shifts cannot be established from this contact sheet. Profiles show persistent bands and brightness decline.

**M403-03-baseline-iso:** Branching and transverse dark structures remain visible while brightness rises and falls. Broad projected bands persist. Small correction estimates do not certify tissue boundaries or frame validity.

## Verification and feasibility

The one-pass MATLAB scan completed in 145.527 seconds with four thread workers,
processing one source at a time. All 14,392 registration calls returned without
algorithm errors. Three deterministic synthetic checks verified correction
orientation, including a gain/offset case; maximum error was below 0.003 pixel.
The prespecified 0.15-pixel harness tolerance is not a physiological tolerance.

Independent Python checks verified all 7,200 frame indices/time points and
exported displacement arithmetic, conservation of every row/column projection
against the independently verified earlier pixel sums, and exact replay of all
56 selected TIFF frames and their Pearson correlations. Eight source hashes and
460 implementation files remain unchanged. This does **not** independently
reimplement the registration algorithm or certify biological validity.

All eight source sheets, eight full projection timelines and eight initial
trace figures were visually inspected. A legend-only repair removes accidental
selection-line legend entries; two corrected representative layouts were checked.
Initial images and numeric results are preserved. See [verification](verification.json),
[visual observations](visual-review.json), [summary](summary.csv),
[synthetic results](synthetic-check.csv) and [prespecification](prespecification.json).

## Reference search and remaining decision

A scoped filename/path search enumerated 41,123 files under the publication
folder and found 80 animal-named image/log candidates: 64 legacy derived images,
the eight baseline sources, and eight other whisker BOI sources. No independent
anatomical reference was identified by this search. This is not evidence of its
absence under generic names or elsewhere. Whisker source content was not reviewed
or registered as reference evidence. The [inventory](reference-search.json)
preserves relative paths and search limits. A separate search within the eight
recording subtrees found no filenames suggesting saved motion transforms or
reference images; historical correction parameters remain unknown.

Next substantive review should inspect native-resolution local sequences around
ID402 awake frames **315, 503 and 505**, ID403 awake **546, 450 and 269**, and the
FB2315 awake brightness/estimate change at **420**. Compare persistent landmarks
and field edges across neighbouring frames; do not classify global BOI intensity
changes as motion by themselves. Source-only evidence may remain inconclusive,
especially for ID402 iso boundaries. Record unresolved observations explicitly.

No masks, frame exclusions, validity declarations, windows, detector reruns,
scientific eligibility or evaluation roles were adopted. Preserve biological
variation and changing dark regions. Any later justified support change requires
a fresh analysis stage; existing event numerators cannot be combined with a new
denominator retrospectively. If invalid frames are demonstrated, the contiguous-
time pipeline limitation must be addressed without deleting or renumbering frames.
R1 support/temporal eligibility and the broader measurement decisions remain open.

The local evidence packet retains the executed MATLAB/Python harnesses, full
row/column arrays, selected source pixels, runtime and original render attempt.
The [artifact record](artifact-record.json) binds local and portable results and
checks the preceding proposal artifacts remain unchanged.
