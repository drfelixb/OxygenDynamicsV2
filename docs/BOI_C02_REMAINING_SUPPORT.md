# Remaining C02 sources and tissue-outline proposals

21 September 2026 · R1-C02-REMAINING-SUPPORT-106

**Six source-specific proposals are ready for review. None is adopted yet.** The four completed pairs remain unchanged. FB2312, ID400 and ID401 remain candidate pairs; no new exclusion or detector adjustment was made.

All six local TIFFs were found in the original pooled-data folders. Every local pixel in five recordings equals the earlier checksum-verified archive-derived TIFF. For FB2312 isoflurane, the published NWB was downloaded, its file checksum verified, and all 314,572,800 pixels compared: the local TIFF equals the archive after an explicit spatial row/column transpose. Numeric intensities and temporal order are unchanged. This is an axis mapping, not image registration. The original direct-index assertion failure and its diagnostic counts are preserved alongside the resolved mapping.

FB2312 awake and isoflurane each contain 1,200 frames; the ID400 and ID401 files each contain 600. All use the researcher-confirmed external 1 Hz trigger, with frame 1 at modeled time 0. Stored timestamps do not set the analysis clock. Frame-count verification does not approve physiological validity or final comparison windows.

The outlines were estimated separately from five fixed frames per recording, without intensity thresholding or transfer between states. Internal dark bands and dim tissue remain inside each contiguous polygon. Orange segments identify especially uncertain or clipped edges; green segments remain tentative too. Image-edge segments bound the recorded field, not a proven anatomical margin.

| Recording | Frames | Scale (µm/pixel) | Proposed sink area (mm²) | Proposed surge area (mm²) | Review |
|---|---:|---:|---:|---:|---|
| FB2312-baseline-awake | 1200 | 2.35 | 0.916663 | 0.972275 | [Five frames](reference-results/boi-c02-remaining-support-20260921/run-01/FB2312-baseline-awake/FiveFrameOutlineReview.png) |
| FB2312-baseline-iso | 1200 | 2.35 | 0.952305 | 1.015278 | [Five frames](reference-results/boi-c02-remaining-support-20260921/run-01/FB2312-baseline-iso/FiveFrameOutlineReview.png) |
| M400-01-baseline-awake | 600 | 4.75 | 4.050555 | 4.339852 | [Five frames](reference-results/boi-c02-remaining-support-20260921/run-01/M400-01-baseline-awake/FiveFrameOutlineReview.png) |
| M400-03-baseline-iso | 600 | 4.75 | 4.034423 | 4.381119 | [Five frames](reference-results/boi-c02-remaining-support-20260921/run-01/M400-03-baseline-iso/FiveFrameOutlineReview.png) |
| M401-01-baseline-awake | 600 | 4.75 | 3.165203 | 3.249474 | [Five frames](reference-results/boi-c02-remaining-support-20260921/run-01/M401-01-baseline-awake/FiveFrameOutlineReview.png) |
| M401-03-baseline-iso | 600 | 4.75 | 3.334941 | 3.439766 | [Five frames](reference-results/boi-c02-remaining-support-20260921/run-01/M401-03-baseline-iso/FiveFrameOutlineReview.png) |

The proposed areas describe geometry only. Sinks retain the existing 20-pixel border rule; surges use the whole proposed field. There are no new event numerators, cohort results or inferred treatment effects in this packet.

## Recording-specific uncertainty

**FB2312-baseline-awake:** Top and left field are clipped. Upper/lower-left margins are diffuse and approximate; the lower-left wedge retains dim tissue rather than following individual bright patches. Dark branching and transverse interior bands remain included.

**FB2312-baseline-iso:** Top and left field are clipped; the lower margin reaches the recorded boundary. Diffuse upper-left and lower-left transitions are approximate. Interior dark vessel-like bands remain included.

**M400-01-baseline-awake:** Top and bottom are clipped; the dim left field and its image-edge contact have weak boundary evidence. The broad left contour is a working hypothesis, retaining low-signal tissue. The darker central/diagonal band remains inside.

**M400-03-baseline-iso:** Top, bottom and left field are clipped. The upper-left/lower-left perimeter is diffuse and weakly supported. Dark transverse and diagonal interior bands remain included. This is drawn in this source, without transferring the awake mask.

**M401-01-baseline-awake:** Lower field is clipped; upper and left boundaries are diffuse in the grainy frames. The bright right rim helps locate an approximate outer contour but is not anatomical certification. Broad dark interior areas remain included.

**M401-03-baseline-iso:** Lower field is clipped. Upper/left boundaries and lower-left continuity have weak evidence, especially in the later faint frames. The dark interior is retained as a single field; no intensity threshold or awake-mask transfer is used.

## Checks and preservation

Independent Python checks replayed all 1,572,864 polygon pixel centers, connected/hole-free support, 12 retained interior points, sink-border geometry and area units. Sources, saved masks and rendered previews have content hashes. All 495 repository MATLAB files and all 355 artifacts from the previous ID403 completion record were preserved. MATLAB rendered the successful set in about 29 seconds, without detection or statistics execution.

A first rendering attempt failed because the decoded display limits were a column vector. That attempt, its logs and executed recipe are retained. Converting the display limits to a row fixed rendering; polygon coordinates were unchanged. The NWB stays in the local evidence folder and is represented by its checksum in the portable record.

Original recording-specific correction and the current detector remain unchanged. Earlier human event boundaries/references are not transferred. No universal substrate-decline model is assumed. Camera exposure, pre-source processing, dynamic validity, endpoint censoring, final windows, metric admission and animal-level inference remain open. The known publication/development use is retained; these mice are not untouched validation.

**Next:** review the FB2312 awake/isoflurane proposals first, then ID400 and ID401. Record each acceptance against that source, mask and preview before current-profile execution. Working support acceptance is separate from final cohort inclusion and observation-window decisions.
