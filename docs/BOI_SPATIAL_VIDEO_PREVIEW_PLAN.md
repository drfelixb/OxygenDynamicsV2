# Spatial video preview for pocket recognition

5 November 2026. Approved scope. The researcher explicitly approves: “Proceed with the two-recording video preview (Recommended).” The Python trace preview is complete and stopped. The researcher rejects the displayed long FB2317 proposal as a pocket and asks whether the change extends across a large region. The next useful comparison is full-field spatial and temporal evidence, with traces supporting interpretation and measurement.

## What the FB2317 curve represents

The displayed experimental interval is raw frames 490–874 and corrected frames 471–855. Its full-recording trace averages a fixed 1,664-pixel footprint in a 512×512 image: 0.635% of the full image. Those pixels come from the original saved site 13/event 9 at 1174–1179, far later than the experimental interval. The internal group 62 label identifies overlapping saved footprints; it is not an anatomical ROI name.

A small measurement footprint does not establish a small event. It can sample a larger regional change, and the saved mask does not measure the area of the earlier decline. The full-image fraction is not tissue-normalized area. All saved sink footprints together cover 28.73% of the image and are selected by the existing detector. Their trace overview cannot establish what happened across the entire field.

Record the researcher's rejection of this long experimental proposal as a discussion judgment. Do not transfer it to the unrelated original event 9 or confuse it with the previously saved site 13/event 5 exclusion. No scientific review revision or export is changed. Exact source identity, geometry and source availability are recorded in `reference-validation/boi-spatial-strategy-review-20261105/source-geometry-review.json`.

## Biological interpretation to test

The published study describes spatially defined pockets linked to local capillary flow interruption. The protocol describes spatially restricted events and reports area as well as amplitude and duration. This supports testing spatial locality together with the complete temporal episode; it does not supply a universal maximum area. [Original study](https://pubmed.ncbi.nlm.nih.gov/38547288/); [published protocol](https://pmc.ncbi.nlm.nih.gov/articles/PMC11460448/).

Evaluate whether a coherent region falls and recovers relative to surrounding tissue, how its area evolves, and whether the surrounding field undergoes the same change. A broad shared component and a superimposed local pocket may coexist. Keep their evidence separate rather than automatically subtracting the field signal. Area, extent, persistence and relative local contrast are continuous evidence; a broad change can be biologically meaningful without being classified as a pocket.

Allow irregular or fragmented visible support. Do not impose a circle, a uniform intensity floor or one fixed footprint throughout an episode. Consider the researcher's capillary-network interpretation, but do not infer an anatomical capillary map from BOI brightness or the saved binary support. A separately acquired, registered vascular image can provide context if already available; acquiring or reconstructing a new vascular map is outside this preview. The protocol's depth and intensity limitations also constrain interpretation of the 2D projection.

## Finite sources and budget

Use only two named development examples, neither an independent validation set:

| Recording | Raw frames | Purpose |
| --- | --- | --- |
| FB2317 | 1–1200 | Establish the spatial extent and context of the rejected long proposal without cropping away the rest of the recording. |
| FB2413 | 1–1178 | Contrast with the previously discussed pocket near 826–851; examine whole-field context before presenting a focused clip. |

The exact raw TIFF copies already exist in the completed run folders: 2,378 frames and 1,253,816,824 file bytes in total. Availability was checked by file metadata only; no image pixels were read for this planning review. Use existing saved masks, metadata and traces as overlays/context. Do not treat a file named denoised as the corrected detection stage without verifying its provenance; new processed image-stack analysis is deferred in this first preview.

Owner: root, no delegation. Budget: four active engineering hours, three analysis/render batches, two repair cycles, 768 MiB working memory and 512 MiB new derived material. Stream source frames rather than loading both movies. At most three sequential reads of the two raw stacks for integrity, extraction and rendering, with exact read/frame counts recorded. No package installation, environment change, GPU or remote image service.

## Bounded work and acceptance

Implementation record: POCKET-SPATIAL-01. User benefit: distinguish a local pocket from a broad intensity change before refining temporal detection.

| Item | Work | Acceptance |
| --- | --- | --- |
| SP-01 | Verify source hashes, dimensions, sample clock, supplied spatial calibration and existing tissue-support provenance. Inspect available structural-image metadata without searching other animals. | Selected sources and axes are explicit; no unverified vessel map. Physical sizes use the supplied 2.35 µm/pixel calibration with its independently-unverified status retained. |
| SP-02 | Inspect both complete raw movies at full field. Produce fixed-scale playback, before/during/after images and explicitly labelled display-reference change maps. Show the measured footprint location and surrounding regions, including regions outside old detections. | FB2317's spatial extent can be judged directly. Rendering does not autoscale each frame or hide broad changes through field normalization. Display references are not adopted amplitude baselines. |
| SP-03 | Quantify exploratory spatial extent and local-versus-surrounding temporal behaviour around the two named episodes. Retain full-field context, possible motion/illumination effects and uncertainty at boundaries. | Report pixels, size using supplied calibration, fraction of full image and, where eligible, fraction of saved tissue support with its qualification. Show extent across a small frozen sensitivity range instead of one asserted true boundary. Diagnostic masks/areas are kept out of scientific results and burden. |
| SP-04 | Deliver two compact whole-episode video comparisons, one spatial summary and a recommendation for the next detector design. | The researcher can assess locality, regional background and dip/recovery together. Any unresolved extent or correction conflict remains explicit. No repeated second-by-second boundary elicitation. |

Freeze display references and the small spatial sensitivity comparison after source staging and before evaluating the two target episodes. Permit no iterative parameter search to force FB2317 negative or FB2413 positive. Use a small synthetic image sequence with a local dip within a shared field change to check coordinates, frame identity, area accounting and display preservation. A synthetic check establishes software behaviour, not biological validity.

The output should answer whether a spatially coherent localized event is visible, whether the decline is regional/shared, or whether the images are insufficient. Do not require a binary answer from ambiguous data. These familiar examples assess feasibility and explanation; they cannot establish detector sensitivity or specificity.

## Preservation and stopping condition

No production detector or correction change, adopted size cutoff, new scientific label, original recording change, measurement baseline/amplitude change, accepted area, burden calculation, partial sum, normalization change, export, cohort run, GUI replacement, platform adoption, commit/push, package or external publication. Findings remain local.

Stop after the two source-bound spatial/video comparisons and detector recommendation, or at a source/resource boundary. The alternative is to defer image analysis and retain the existing optional trace preview; it leaves the central spatial question unresolved. A larger spatial detector implementation or broader evaluation would be a separately agreed milestone.

## Approved rendering resource extension

After both numerical image comparisons and the first movie/figures were complete, the renderer exceeded the original memory limit and the monitored lighter attempt stopped. The researcher explicitly approves “Finish the remaining rendering with 2 GiB (Recommended).” Finish only the remaining FB2413 video and figures with a 2 GiB cap and one final presentation attempt, using isolated graphics/video phases if needed. Reuse the completed FB2317 outputs and frozen analysis. All other scope, output and scientific preservation boundaries remain in force.
