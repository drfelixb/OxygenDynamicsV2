# Corrected intensity is primary; detection score supports interpretation

14 September 2026 · R2-CORRECTED-SCORE-SUPPORT-049

**The researcher reference is now clarified.** The middle corrected-intensity trace mainly guides event and boundary judgments. The bottom detection-score panel is also helpful. The top raw/correction panel is used to check whether the correction has worked. This resolves phase 048's reference-panel question without changing any earlier annotations.

The user's exact clarification is preserved in [researcher-reference-clarification.json](researcher-reference-clarification.json). It describes a primary/supporting hierarchy, not an exclusive corrected-only visual protocol. The orange and dotted bottom curves were not individually singled out; do not infer a preference between them from which better matches a boundary.

The phase 047 comparison used the primary corrected trace correctly. Its narrow-fluctuation selections and overextended recoveries remain relevant method failures. Its automatic rules did not incorporate the supporting detection-score view. That omission does not prove that adding the score will solve those failures.

## What the existing score adds in a bounded check

The check uses the same ten reviewed cases. It compares the saved corrected event-footprint trace with the saved filtered detection score over that same footprint; the dotted site trace is reported separately because its support and sign-dependent processing differ. No filtering, correction, normalization, detector or automatic timing rule was rerun.

The 30 supplied timing combinations, including two frame-296 coordinate sensitivities, remain fixed. The two non-recognized examples use their saved native intervals only as labelled descriptive references, not as invented manual events. Thus there are 32 intervals and **96 trace-interval rows**, independently verified. These are repeated comparisons within cases, not biological replicates.

Within all 30 marked/sensitivity intervals, the filtered event-footprint score contains fewer strictly interior local turning points than corrected intensity. Examples are shown below. Counts include observed maxima and minima, not the interval endpoints. A plateau requires finite, strictly lower or higher immediate neighbors; exact equal-value plateaus remain explicit. These counts are descriptions of the saved representations, not counts of biological events or a measure of physiological accuracy.

| Example | Fixed interval | Corrected interior turns | Filtered-score interior turns | Other visible difference |
|---|---|---:|---:|---|
| 1 · FB2314 sink 15/36 | 1154–1167 | 5 | 1 | Minimum at corrected frame 1163 versus score frame 1162 |
| 3 · ID400 sink 45/1 | All retained onset/offset combinations | 11–14 | 3 | Minimum stays at frame 308; which maximum is largest can change |
| 4 · ID400 surge 4/6 | 529–546 | 7 | 5 | Maximum at corrected frame 537 versus score frame 534 |
| 5 · FB2316 sink 14/6 | 717–772 | 31 | 19 | Minimum at corrected frame 771 versus score frame 770 |
| 8 · HP surge 6/3 | 235–356 | 63 | 27 | Maximum at corrected frame 316 versus score frame 317 |
| 9 · earlier FB2314 anchor | Nominal 496–516 | 5 | 2 | Corrected minimum at 508; score maximum at 508 |
| 10 · earlier FB2314 anchor | Nominal 536–556 | 5 | 1 | Corrected minimum at 544; score maximum at 545 |

Examples 9/10 are important limits on interpretation: the score can emphasize a different signed feature from corrected intensity. It is not simply a smoother copy with interchangeable peaks and troughs. Its preprocessing includes normalization and spatial/temporal operations; this audit does not isolate the contribution of each stage or attribute a time displacement solely to filter delay. The earlier normalization audit already documents why detection direction and original-source behavior must be kept distinct.

The two rejected examples retain 3 versus 3 and 1 versus 1 interior turns on their short saved native intervals. That does not validate their recognition or show that a turning-point count is an adequate event criterion. Fewer turns can hide meaningful short features as well as small fluctuations. The longer HP interval still contains 27 score turns; smoothing already present in the score does not by itself identify a unique full excursion or recovery.

[support-comparison.csv](support-comparison.csv) preserves all interval alternatives, counts and earliest extremum displacements. [The detailed MATLAB results](run-01/support-results.json) retain every extremum plateau, tied minimum/maximum frame, endpoint value and neighboring step direction. Displacements are descriptive differences in which sample is extreme, not estimated physiological delays. No nearest score landmark is selected to replace a corrected-trace mark, and no new acceptance tolerance is introduced.

## Consequence for the method and researcher workflow

Use the detection score as **supporting context for the broader structure** while judging event presence and boundaries primarily on corrected intensity. Keep disagreements visible. It must not silently set the boundary, override a brief corrected recovery peak, validate a rejected candidate, or force the corrected signal into the saved detector sign. The raw panel remains a correction-quality check; it does not become the onset/recovery source by default.

This is a researcher-confirmed reference hierarchy, not an adopted automatic segmentation method. The original per-recording correction is retained, without a substrate-decay explanation. The 20-sample immediate clean raw-source amplitude reference, native masks, labels, prior measurements, ambiguous boundaries and rejected cases remain intact. Missing amplitude does not suppress timing or recognition evidence.

The concrete next implementation step is to carry this hierarchy into the MATLAB event reviewer: a corrected-intensity timing view, aligned detection-score support, and separate raw/correction quality context, with source identities and unavailable-stage reasons. Preserve the current amplitude-inspection view. [The implementation handoff](MATLAB-REVIEW-HANDOFF.md) names the existing integration points and checks. This improves the shared review surface without choosing another automatic threshold or treating manual decisions as exact ground truth.

Any later automatic proposal must state how score-derived structure is confirmed against the primary corrected trace and how disagreements remain unresolved. It must be specified before evaluation, retain both signs, avoid source selection based on agreement, and protect brief, weak, sustained, recurrent and spatially changing events. No numerical joint rule is adopted by this audit.

## Verification and disposition

MATLAB calculated the fixed 96 rows in 1.65 seconds, excluding startup. A separate Python implementation using plateau change points independently verified all extrema, frame ties, counts, ranges and endpoint directions. Source identities, roles and indices match exactly; numerical tolerance is 1e−9 absolute plus 1e−12 relative. All 17 frozen input hashes and 469 production implementation files verify unchanged. See [verification.json](verification.json), [prespecification.json](prespecification.json) and [inputs.json](inputs.json).

Decision: record the confirmed researcher reference roles; retain production timing and correction. The supporting-score structural check is complete. It establishes descriptive differences in these development cases, not independent biological validity. Three identified animals and provisional HP remain separate, with existing anatomical, acquisition, cohort and evaluation holds. BOI-only scope, biological variability, physiological relevance, feasibility, usability and traceability remain standing requirements.

Next: implement the primary/supporting signal view in the MATLAB reviewer and verify its export traceability, before another automated timing-method comparison.
