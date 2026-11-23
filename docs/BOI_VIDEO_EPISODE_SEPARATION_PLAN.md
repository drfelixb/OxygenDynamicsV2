# Two recording pilot for separating video episodes

7 November 2026. The researcher approved this two-recording pilot to assess distinct decline and recovery cycles and to allow local pockets within regional changes. Owner is Codex (root). Milestone ID is POCKET-VIDEO-DETECTOR-03.

## Recording examples

| Example | Full field window | Question for the comparison |
| --- | --- | --- |
| FB2413 site 3/event 6 | Frames 608–1114 | Does the response near frame 794 return sufficiently to support a separate local episode around 826–851? The previous primary grouping followed the earlier trough. |
| FB2412 site 20/event 1 | Frames 5–839 | Does the reviewed 114–182 interval contain a local decline and return that can be distinguished from the surrounding response? One earlier alternative grouped blocks spanning about 54% of the image. |

Use the archived primary proposals, raw 4×4 pixel block means, observation domain, and motion evidence. Consider the full image field in each saved window. Use the familiar event timing and footprints to compare outcomes after grouping. The previous detector used proximity to connect proposals across space and time, then chose one representative phase per group. The pilot tests how much can be recovered from those proposals by reconsidering episode identity and surrounding activity. [Previous results and verification checkpoint](BOI_VIDEO_DETECTOR_REVISION_RESULTS.md) · [Full field videos](../../reference-validation/boi-video-detector-revision-20261106/review.html)

## Work and acceptance checks

| Item | Work | Acceptance evidence |
| --- | --- | --- |
| BSEP-01 | Keep plausible local troughs in each saved group. Compare one linked episode with separate episodes on the same observed blocks wherever the proposed locations overlap. Look for an intervening return and a renewed coherent decline, and constrain each return search to its own episode. | The recovered repeat and the uninterrupted decline have different outcomes in constructed checks. Ambiguous intervening states retain the competing interpretations. The earlier and later FB2413 responses can be inspected separately. |
| BSEP-02 | Estimate the shared change from multiple disjoint fixed surrounding regions, including nearby and distant sectors. Compare a regional change alone with a regional change plus a local decline and return. Recheck the interpretation while leaving out individual surrounding regions. | Report broad and local footprints, comparator agreement, and observed raw rise, absolute return, and relative return as separate evidence. Regional change with spatially varying strength and a nested local change have different outcomes in constructed checks. Unstable comparisons remain unresolved. |
| BSEP-03 | Freeze one configuration, run the two windows, and deliver two comparison cards linked to the existing movies. Show competing time bounds, diagnostic extent in blocks, fixed block raw traces and surrounding traces. | Independently recompute selected traces, coordinates and extent counts, verify input hashes, and record whether each real example was separated, remained linked or regional, or was unresolved. Record a remaining miss explicitly. The examples serve as known regression fixtures. |

The six constructed checks cover a recovered repeat, a second trough without intervening recovery, a broad change with uneven strength, a local event nested in regional change, contaminated surrounding references, and unavailable phase evidence. Define decision criteria with those checks before the real windows. Let observation quality, spatial coherence and recovery evidence inform the comparison. Keep the two recordings' supplied sampling rate and retain uncertainty at the edges of the analysed windows.

The experimental outputs are recognition evidence and comparison cards. Use the production MATLAB workflow, saved scientific measurements and original recordings as read-only references. FB2412's accepted scientific baseline is frames 104–113. Detector context has its own provenance and the footprint counts describe diagnostic support. The burden formula and normalization belong to the existing measurement workflow.

## Budget and stopping conditions

Allow four active engineering hours, three batches, six constructed checks, two recording windows, one configuration and one engineering repair. The batches are implementation and constructed checks, the frozen window comparisons, and selected independent checks with review cards. Use the existing Python environment and isolated workers for each recording and each independent check. The largest saved raw and primary proposal arrays needed by one recording total about 213 MiB before scratch space. The measured process tree cap is 2 GiB and the cap for new derived material is 256 MiB.

Stop after the two cards and verification report, or preserve a partial checkpoint if a resource limit or source integrity check stops the work. Record test failures and remaining recognition gaps. This is a local experiment on the saved primary search, so detection of events absent from that search is outside this pilot's evidence. Deferring leaves the existing video review available for discussion.

The researcher approved the bounded implementation and preservation requirements under the [workspace rules](../AGENTS.md).
