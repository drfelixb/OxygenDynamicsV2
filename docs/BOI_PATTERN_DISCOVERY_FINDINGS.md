# Pocket patterns across the saved recordings

5 November 2026. The approved recording-wide exploration is complete.

**The next detector should compare complete episodes with local background, while retaining several pocket shapes and an uncertain outcome. The exploratory clusters are useful for finding contrasting examples, but are too sensitive to representation and background drift to serve as pocket labels.** This supports moving away from repeated second-by-second rule setting. It does not yet establish a better detector.

Start with the [contextual review gallery](../../reference-validation/boi-pattern-discovery-20261105/review.html). It includes both traces, native support, representative patterns, contrasts and all 17 recording overviews. Orange lines show the original automatic interval, not a newly accepted pocket boundary.

## What was examined

The saved evidence contains 5,407 automatic sink candidates across 17 recordings. Each candidate retains its full raw trace, saved corrected trace, fixed footprint, original timing and native frame masks. Both sink and surge support remain available as context. No source movies were read.

The catalogue has 17,447 contextual views: 5,401 candidate views after limited view deduplication, and 12,046 systematic comparison views at one-quarter, halfway and three-quarters through each footprint-group trace. There are 4,055 overlap groups. Every original candidate maps exactly once to a retained candidate view. Six duplicate views were combined for weighting; no biological events were merged or rejected.

Systematic views are **unlabelled**, not verified background or negative examples. Their source site/event identifiers name the footprint from which the full trace was extracted; they do not assert that that event occurred at the systematic centre. Nearby views and overlapping footprints remain dependent observations. Transitive overlap grouping is a weighting device, not an anatomical ROI definition.

All saved raw and corrected samples were finite. The 466 views with less than 90% multiscale bin availability remain in the catalogue and projections but were ineligible for fitting; recording-edge windows contain unobserved positions rather than fabricated samples.

## What the patterns show

The fixed primary model groups raw and corrected shapes at 60, 120 and 240 seconds into six exploratory families. The table describes the selected representative only; family members vary and the names are not biological diagnoses.

| Family | Development views | Representative | Appearance of this representative |
| --- | ---: | --- | --- |
| 1 | 1,264 | FB2412 site 39/event 1 | Local trough amid fluctuations; much larger recording-scale changes elsewhere |
| 2 | 2,237 | FB2412 site 82/event 1 | Falling signal after a higher period; corrected signal also trends down |
| 3 | 2,018 | FB2403 site 90/event 1 | Broad raw decline with a pronounced corrected trough and partial return |
| 4 | 1,832 | FB2319 site 63/event 1 | Local dips within a larger rising context, followed by a marked rise |
| 5 | 2,108 | FB2410 site 82/event 3 | Raw decline alongside a corrected dip and rebound |
| 6 | 2,047 | FB2311 site 36, footprint from event 9; systematic frame 301 | Rising raw context with corrected curvature; no target detection at the centre |

Every family appears in all 12 development recordings, but that recurrence does not confirm pockets. Systematic contexts make up 21%, 92%, 51%, 52%, 81% and 97% of the respective families. These percentages describe this sampling scheme, not biological prevalence.

The prior judgments are particularly informative:

- **FB2413 site 3/event 6** shares family 4 with the excluded **FB2319 site 7/event 2** and **FB2412 site 1/event 1**. Shape similarity alone does not reproduce the recognition decisions. The provisional FB2413 onset 826–827 and likely end 851 remain discussion judgments.
- **FB2317 site 13/event 5** lies on a sustained raw decline while the corrected trace rises through the saved interval. Its existing exclusion remains intact. A nearby clean reference cannot by itself establish an episode.
- **FB2412 site 1/event 2** retains the local raw depression and return that motivated the longer-pocket review, while the corrected context does not show the same return. This disagreement needs an explicit outcome rather than an automatic corrected-trace veto. The saved 651–693 review remains; 659–672 remains a preview.
- **FB2412 site 20/event 1** remains recognized with its saved 114–182 interval and 104–113 reference. Its placement in family 1 does not establish that other family-1 candidates are pockets.

The native masks can support the temporal interpretation, but they were produced by the existing detector. Strong native support also occurs at rejected detections, so it cannot independently validate them.

## How stable the grouping was

All preprocessing and model fitting used development views only. The fitting sample was capped separately at 200 candidate and 200 systematic views per recording, yielding 4,758 views. The primary shape model retained 12 principal components, explaining 70.9% of fitting variation. Shape centering/scaling serves similarity comparison only; it does not replace the amplitude reference or burden normalization.

The agreement statistic below is adjusted Rand agreement: 1 means identical grouping and approximately 0 means chance-level agreement. Different cluster counts can legitimately split existing groups, so these are descriptive robustness comparisons, not significance tests.

| Comparison against six shape families | Agreement on development views |
| --- | ---: |
| Ten shape families | 0.376 |
| Six descriptor families | 0.019 |
| Ten descriptor families | 0.055 |

Descriptors include drift, roughness, autocorrelation, raw/corrected agreement and native support. Their weak agreement with shape grouping means that this pass does not reveal one stable biological taxonomy.

On a fixed development-only sample of 120 fitting views, the frozen shape family was unchanged in 119/120 cases with added noise at one-quarter of the measured difference-noise scale, 114/120 after every-other-frame sampling and linear reconstruction, and 90/120 with a linear drift spanning four noise units per 240 seconds. These probes test representation stability, not detector accuracy. Drift remains a material confounder.

## What the held out recordings tell us

FB2316, FB2320, FB2404, FB2406 and FB2420 were assigned by an identifier-only rule before new numerical loading. Their 5,941 views were projected only after all four models and development summaries were frozen. Each recording contains assignments to all six primary families. There were 187 views above the global fitting-sample 99th-percentile centroid distance; this flags unfamiliar representations, not non-pockets.

All these recordings had appeared in earlier exports. They are held out from this model development, not historically unseen data. Unlabelled nearest-centroid assignments do not estimate sensitivity or specificity. Saved footprints also exclude spatial locations never retained by the original detector, so this pass cannot establish whole-image detection sensitivity.

## Recommended detector prototype

Use continuous traces to propose and assess **whole episodes**, comparing a locally changing background alone against background plus a negative excursion and recovery. Allow asymmetric, short, long and recurrent episodes. Retain competing explanations such as a broad transition or an unresolved recording edge. A broad or spatially shared depression must remain eligible: shared behaviour is not automatically artefact or disqualifying background.

Jointly assess the pre-episode state, decline, trough and recovery rather than requiring return to one exact intensity or a universal five-sample plateau. Report an onset/end interval when timing is ambiguous. Recurrence can share episode context while each separately measured event retains its own reference. Recording-start/end episodes remain censored when the missing state cannot be inferred defensibly.

Keep raw and corrected traces as separate evidence channels. A corrected recovery without a raw recovery, or a raw pocket removed by correction, should trigger explanation and uncertainty. Preserve the current correction during the first prototype. Add saved spatial persistence as supporting evidence, qualified by its dependence on the original detector.

Use several representative shapes and nearby contrasting examples to explain proposals. Repeated-subsequence discovery provides a way to retrieve recurring shapes, but similarity does not establish biology. [Zhu and colleagues describe this motif-search approach.](https://epsci.ucr.edu/sites/default/files/2019-04/zhu_etal_2016_ieee_icdm_stomp_gpu.pdf) A segment model with explicit variable durations is one candidate for joining the phases without imposing one fixed length; [Johnson and Willsky describe explicit-duration semi-Markov models.](https://www.jmlr.org/beta/papers/v14/johnson13a.html) These are candidate tools, not implementations or validated methods for these pockets.

Separate **recognition** from **measurement readiness**. A recognized pocket may still lack a valid amplitude reference, recovery or complete area. Choosing 10 versus 20 reference seconds belongs to event-specific measurement suitability, not a substitute for recognizing the whole episode. Preserve the burden formula, normalization and complete-contribution requirement; no partial sum should be presented as a recording burden.

The next proposed milestone is a saved-trace prototype with broad whole-episode proposals, explicit competing background explanations and a compact comparison against the existing detector and prior judgments. Keep model choices within the 12 development recordings, then freeze before evaluating the five held-out recordings. Review a small diverse set of full episodes once; do not request exact boundaries for every candidate. A separate spatial-search milestone would be needed to evaluate locations missing from the saved footprints.

## Verification and stopping point

An independent Python replay reproduced all 17,447 assignments for each of four frozen MATLAB models, with centroid-distance differences below 1e-10. An independently reconstructed source example matched the 150 shape features. All 5,407 candidate memberships and native active-frame bounds passed checks. Four separated synthetic groups were recovered exactly; held-out perturbation did not change fitted parameters.

All 51 selected source files and 34 protected source/scientific files match their original hashes, with some overlap between these sets. No detector, correction, scientific review, amplitude, area, burden calculation, existing export or original recording was changed. The evidence is in [independent-verification.json](../../reference-validation/boi-pattern-discovery-20261105/independent-verification.json).

Used four bounded analysis batches, one repair cycle and approximately 155 MiB of derived files, within six active hours. The repair completed figure rendering from already frozen models after a structure-initialization error; it did not refit them. All 17 overviews and seven montage/projection figures were generated; representative, contrasting, prior-judgment and development/held-out overview layouts were visually inspected. Source code from earlier milestones remains uncommitted and preserved. This milestone stops at the catalogue and recommendation; a detector prototype or production adoption requires its own agreed scope.
