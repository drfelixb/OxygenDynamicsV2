# Proposed detector improvement: keep dim tissue and evaluate video episodes jointly

6 November 2026. **Recording comparison delivered; stopped at the verification resource boundary.** All four recording runs, both configurations and eight review cards are available. The approved additional memory-only repair passed exact full FB2413 primary parity. The pooled independent checker subsequently reached the unchanged 2 GiB limit after the two FB2413 configurations; the remaining six configurations' full independent verification is incomplete. No further processing or repair is active. See the [results and limitations](BOI_VIDEO_DETECTOR_REVISION_RESULTS.md). The detector is not adopted; formula, normalization, originals and the first prototype remain preserved. The approved scope below is retained as the implementation record.

## Evidence and uncertainty

The [FB2413 site 3/event 6 clip](../../reference-validation/boi-video-detector-prototype-20261106/review/fb2413-local/episode.mp4) covers frames 790–900 continuously across the full image field. Its fixed-footprint trace has earlier activity, a later local decline and return around the discussed 826–851 interval. All 57 coarse blocks touching the old footprint pass the search mask. Neither threshold produces a retained spatial region touching it during that interval. The complete-episode assessor consequently never evaluates that location as a candidate.

The current proposal stage first compares five-second image averages with preceding 30/90-second context, standardizes contrast by its whole-recording median absolute deviation, applies thresholds of four or three noise units and removes components smaller than four coarse blocks. Its actual bottleneck for FB2413 is **not isolated by the saved receipts**. Smoothing, reference context, contrast scaling and component rejection are possible contributors, not established individual causes. The native diagnostic maps use a different, fixed prior-example reference and are not proof that this proposal stage should have passed its thresholds.

The [FB2412 site 20/event 1 clip](../../reference-validation/boi-video-detector-prototype-20261106/review/fb2412-recognized/episode.mp4) covers frames 75–225, including the saved 104–113 reference, 114 onset and 182 recovery. The search mask admits only 23 of 192 blocks touching the saved footprint. Its raw-median brightness cutoff is approximately 648 input units. This is a concrete eligibility failure before episode assessment; it does not establish biological absence. It also does not prove that restoring eligibility alone will recover a valid candidate. Nearby tissue changes strongly, so locality and recovery relative to the surrounding field still need evaluation.

These counts refer to blocks touching an old footprint, not fractions of biological pocket area. Cyan contours are saved measurement footprints. Gray in the video contrast views means unavailable/excluded, and the contrast maps are not accepted segmentation or oxygen calibration. Provisional timing for FB2413 and saved timing for FB2412 keep their existing status.

## Proposed change in recognition

The first prototype still requires a sufficiently strong short-window spatial component before it assesses a complete episode. The next prototype should allow coherent evidence distributed across space and time to propose a location, then jointly evaluate its preceding state, decline, spatial evolution and observed return. Longer computing time should buy more complete evidence, rather than simply a lower threshold applied to every frame.

1. **Separate search eligibility from confidence.** Replace the recording-wide brightness gate with a permissive, source-bound search domain and explicit local signal/noise confidence. Preserve genuine invalid, missing or saturated observations. A dim interval or darkening region must not erase tissue that can be followed from observable preceding/later states. Existing saved support supplies qualified context, not anatomical truth or a new normalization denominator. Pixels whose state cannot be established remain uncertain.

2. **Propose from complete spatial-temporal episodes.** Search overlapping image locations and multiple spatial/temporal scales without requiring old ROIs. Accumulate coherent weak decline across connected pixels and time, and compare reversible local change, persistent regional change, shared field change and noise. Estimate the relevant phases together; a candidate must reach the whole-episode comparison even when no individual short-window component passes the current gate. Freeze the finite scales/search ranges before numerical runs. Detector context remains separate from each event/ROI's scientific amplitude reference.

3. **Estimate extent and assess recovery separately.** Grow native-pixel support from convincing temporal evidence into connected weaker evidence, retaining vascular gaps and tracking split/merge alternatives. Constrained propagation is supported by the existing [SciPy image-processing API](https://docs.scipy.org/doc/scipy/reference/generated/scipy.ndimage.binary_propagation.html); that operator does not validate the biological boundary. Require matched-pixel raw trajectories and spatial contrast to support recovery. Keep absolute raw return, relative local return and unresolved raw/background disagreement separate. Unknown area stays unavailable when the spatial record is incomplete. No universal maximum pocket size is introduced.

4. **Make every loss inspectable.** Record whether a location is excluded by observation quality, lacks temporal evidence, fails spatial coherence/size, loses tracking or fails whole-episode evidence. Keep stage evidence and rejection reasons for these two anchors and systematic locations. This instrumentation should identify FB2413's actual bottleneck before interpreting a modified result as an improvement.

## One bounded follow-up proposal

ID: **POCKET-VIDEO-DETECTOR-02**. Owner: root, no delegation. User benefit: keep dim/local events available for assessment while distinguishing them from persistent and shared change, with a whole-episode comparison the researcher can inspect without repeated second-by-second timing questions.

Proposed budget: eight active engineering hours, four scheduled batches, two repairs, 2 GiB working memory and 1 GiB new derived material. Use existing cached Python tools; no package installation or production migration. One primary and one prespecified sensitivity configuration; at most 16 synthetic scenes and eight review cards. This is a single experimental revision, not an open-ended optimization campaign.

| Item | Work | Acceptance and stopping evidence |
| --- | --- | --- |
| VDI-01 | Instrument proposal stages and qualified search eligibility | Reconcile both anchors' losses with retained source/coordinate evidence. Separate unavailable observations from dim searchable tissue. |
| VDI-02 | Implement joint video-episode proposals and constrained native support | Demonstrate explicit matched-pixel, missingness, regional-change and changing-mask safeguards on finite synthetic scenes. Retain all search coverage or declare a resource boundary. |
| VDI-03 | Apply a frozen configuration and compare outcomes | Develop on FB2413/FB2317; freeze before rerunning FB2412/FB2319. Report every anchor's found/missed status and full-context evidence, plus fixed systematic locations. No retuning after comparison. |
| VDI-04 | Deliver independent checks and compact review | Independently replay selected stage scores, spatial counts and recovery evidence; hash preservation; report runtime, memory, duplicate/uncertain proposals and misses. Stop after the experimental report and review. |

The four batches are stage/eligibility and synthetic preparation; development; frozen known comparisons; and independent verification/rendering. Reuse verified input caches where appropriate and read native pixels only for this finite set. No other recording is included.

These four recordings are now known development/regression examples. Freezing a new round does **not** make FB2412/FB2319 blind or independent validation. The two familiar pockets test whether the identified failure modes are addressed; they cannot establish overall biological sensitivity. Retain FB2317's persistent trajectory and FB2319's rejected example as adverse checks, and keep systematic unlabelled locations so the proposal is not judged only on familiar positives. Report tradeoffs rather than forcing a desired label.

The alternative is to retain the delivered review and defer a detector revision. Merely lowering the existing threshold is not the proposed improvement: the first run already tested three versus four noise units and missed both named pockets.

## Preserved outputs and approval boundary

No production MATLAB/GUI, CSV requirements, event decisions, original recordings, saved automatic/reviewed results, scientific amplitude references, burden formula, normalization support/exposure, statistics or export formats change. The existing 20/10-second baseline policy is not changed by detector context. No new scientific burden, partial sums or imputed zeros are calculated. Experimental masks cannot become burden inputs.

The researcher explicitly approved this bounded follow-up under [the workspace rules](../AGENTS.md). Routine implementation and checks are authorized within the scope above. No cohort expansion, new independent evaluation set, GUI integration, adoption, commit/push, release or external publication is included. Findings remain local. Stop after the stated experimental delivery even if important misses remain; any adoption or further iteration is a separate decision.
