# Spatial evidence for pocket recognition

Analysis dated 5 November 2026; presentation completed 6 November 2026. Both full-field movies and their spatial/local figures are now available on the [local review page](../../reference-validation/boi-spatial-video-preview-20261105/review.html). The missing FB2413 presentation was completed with cached Python/Matplotlib/FFmpeg tools after the original MATLAB milestone stopped at its resource boundary. The frozen calculations, original results and existing FB2317 outputs are unchanged. No production detector or scientific calculation has changed.

## Main finding

The displayed long FB2317 proposal samples a sustained regional loss of signal that grows beyond its small measurement footprint. It is not a uniform whole-field decline. The researcher's rejection of this experimental proposal as a pocket is consistent with the combination of spatial expansion and absent local recovery. Neither its fitted corrected reversal nor the size of its saved footprint establishes a recovered local episode.

The fixed footprint contains 1,664 pixels, 0.635% of the 512×512 image. It originates from saved site 13/event 9 at frames 1174–1179, while the experimental long interval was raw 490–874 and corrected 471–855. The distinction matters: the footprint identifies where the trace was measured, not the extent of that earlier decline. The existing site 13/event 5 rejection is a separate decision. No original event has been newly excluded from scientific export.

## What changes across the field

The following means use fixed display references, frames 470–489 for FB2317 and 806–825 for FB2413. Each regional mean is expressed relative to its own value in that display window. These are image-context comparisons, not adopted amplitude baselines or recalculated event amplitudes.

| Recording and frames | Fixed footprint change | Nearby support change | Distant support change |
| --- | ---: | ---: | ---: |
| FB2317 530–549 | −49.96% | −3.40% | −1.22% |
| FB2317 670–689 | −71.13% | −11.66% | −1.71% |
| FB2317 875–894 | −76.32% | −30.41% | −5.97% |
| FB2413 828–837 | −2.74% | −0.92% | −1.94% |
| FB2413 842–851 | −0.22% | −0.21% | −1.36% |
| FB2413 852–871 | +3.73% | −0.92% | −2.47% |

Nearby support is 25–75 native pixels from the fixed footprint; distant support is at least 150 pixels away. These regions use the existing saved sink-eligible support, which is a static analysis mask and not independently validated anatomy. Whole-field raw images remain visible so this mask cannot conceal the broader context.

For FB2317, the seed-connected region of decline grows with time. Around frames 875–894, it spans approximately 21.6–38.2% of the saved support across the three frozen exploratory noise thresholds; the middle threshold gives 29.1%. These values describe threshold-sensitive change extent on 4×4 block means. They are not validated pocket boundaries or area measurements eligible for burden. They also demonstrate why the original 0.635%-of-image footprint is an inadequate description of the long event's extent.

The FB2413 footprint returns and rebounds while distant tissue remains modestly lower than its preceding state. Its phase means are compatible with a transient local component superimposed on background changes, rather than the sustained FB2317 pattern. This familiar example retains provisional onset 826–827 and likely end 851; this preview does not adopt new timing or establish biological ground truth.

## Detector direction

Use spatial and temporal evidence jointly. Generate possible evolving regions from the image sequence, including regions outside old detector footprints. Then assess the full trajectory of each region against neighbouring and more distant tissue: preceding state, decline, persistence, spatial evolution and recovery. Retain a separate broad regional/shared component where supported, and allow a local transient to occur within it. Automatic field subtraction could erase biological changes, so it should not be the default assumption.

Include area in pixels, area using supplied calibration, fraction of observable support, shape, persistence and boundary uncertainty. Assess their joint pattern rather than using one maximum size as a pocket definition. Keep recognition separate from measurement readiness: a local episode may be recognizable while its individual reference or complete area remains unresolved.

The capillary-network context is biologically relevant. The original study links spatially defined pockets with local capillary flow interruption. BOI alone in these selected runs does not identify the responsible capillary or supply a registered vascular map. Allow irregular visible regions and static vascular gaps; do not infer a capillary boundary or force circular footprints from the intensity pattern. Projection depth and relative intensity remain interpretive limits. [Original study](https://pubmed.ncbi.nlm.nih.gov/38547288/); [protocol and limitations](https://pmc.ncbi.nlm.nih.gov/articles/PMC11460448/).

The recommended next implementation would be an experimental spatial proposal service with whole-episode assessment. Python remains useful for exploration; these findings do not require a production language change. Preserve the MATLAB batch GUI, existing statistics/export formats and one authoritative eventual calculation kernel.

## Verification and practical limits

All 2,378 raw frames are accounted for: 1,200 FB2317 and 1,178 FB2413. Both whole-file SHA256 values match the saved source identities. The independently reconstructed fixed-footprint mean matches every saved raw sample exactly in both recordings. Nine finite synthetic geometry/display checks pass. Both videos pass six independent full-frame TIFF-decoder comparisons each and contain respectively 1,200 and 1,178 encoded samples at 10 frames/s, representing 1 Hz acquisition at 10× playback. The FB2413 video is H.264 at 1024×812 for 117.8 seconds; complete video decoding passes, and three decoded samples agree with the intended composite images with mean RGB error below 1.84/255. Both FB2413 figures and a decoded video sample were visually inspected.

All 626 protected source/scientific files and both selected audits and both-sign masters match their prior hashes. Frozen numerical choices and the image-analysis implementation remain unchanged after source evaluation. No scientific review save, new accepted area, baseline/amplitude change, burden calculation, partial sum, normalization change, export, production adoption or external publication occurred.

The first MATLAB renderer exceeded the proposed 768 MiB bound: approximately 1.81 GB maximum resident set and 0.93 GB peak physical footprint were reported. A monitored no-JVM attempt was stopped at its memory guard. The researcher then approved one final presentation attempt with a 2 GiB cap. The isolated graphics phase was stopped when the conservative sum of the renderer process and descendant resident sizes reached 2,150,137,856 bytes; the main process sample was 921,010,176 bytes. Summed resident sizes can include shared pages and are not a measurement of unique physical memory. The guard enforced the declared cap and the original milestone stopped with incomplete FB2413 presentation. Its historical verification record is preserved.

The original milestone used two repair cycles; the second addressed receipt bookkeeping and memory isolation without numerical tuning. Numerical analysis itself completed in about 15 seconds; its initial resource meter failed under sandbox restrictions, so no measured analysis-memory claim is made. The first video's encoded sample count was independently verified as 1,200.

On 6 November the researcher explicitly authorized finishing the FB2413 presentation with a lighter renderer. POCKET-SPATIAL-RENDER-01 uses cached Python 3.11, NumPy 2.4.6, SciPy 1.17.1, Matplotlib 3.11.1, Pillow 12.3.0 and FFmpeg 8.1.2 through process-local search paths; there is no package installation or change to the production environment. It reuses the frozen plot packet, raw display limits, 806–825 display reference, ±50% change scale and cached area curves. A single streaming raw-TIFF read supplies the native-resolution movie panel; the source hash is verified separately and all 1,178 footprint samples match exactly. One figure-only presentation repair scales focused trace axes to the displayed context; numerical evidence and video remain unchanged. Before/during/after crops use existing phase means, including the saved post-episode phase 852–871.

The successful full rendering takes about 35 seconds including launch/monitoring and reaches 819,396,608 bytes (approximately 781 MiB) sampled process-tree RSS, below the inherited 2 GiB cap. The figure-only repair takes about five seconds and stays below 354 MB. All 636 protected scientific/source/cached-result files match the saved pins. The old partial-delivery record remains intact; the completing verification is `reference-validation/boi-fb2413-light-render-20261106/verification.json`.

These two previously inspected examples demonstrate a missing type of evidence in the trace preview. They do not estimate detector sensitivity or specificity. The supplied 2.35 µm/pixel scale remains independently unverified; calibrated physical area is conditional, and none of the exploratory areas enters the hypoxic burden formula or normalization.

Local evidence and viewable outputs: `reference-validation/boi-spatial-video-preview-20261105/`. The approved finite scope is [the spatial video preview plan](BOI_SPATIAL_VIDEO_PREVIEW_PLAN.md).

## Handoff

The [local review page](../../reference-validation/boi-spatial-video-preview-20261105/review.html) now contains both complete movies, spatial summaries and local detail figures. “Play episode context” presents FB2413 frames 790–900 continuously, with full-recording controls also available. No new biological timing, baseline or pocket-area decision is saved. The presentation follow-up is delivered and stopped; discuss the spatial evidence before any next detector implementation.
