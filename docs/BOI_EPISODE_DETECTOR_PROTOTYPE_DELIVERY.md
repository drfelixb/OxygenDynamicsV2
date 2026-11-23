# Whole episode prototype results

5 November 2026. Local development version 3.1.0-dev.14.

**The optional whole-episode prototype is implemented and numerically verified. It is not ready to replace the working detector.** It finds a wider plausible interval for the reviewed FB2412 site20 example, but misses the localized FB2413 site3/event6 pattern. It can also reward apparent recovery created by a falling fitted background. These failures matter more than the number of proposed intervals.

Open the [12-example contextual review](../../reference-validation/boi-episode-prototype-20261105/review.html). It shows the full raw trajectory, both nearby traces, fitted episode/background alternatives and saved native support. All findings remain local.

## What is available

Open a saved sink event in the existing event reviewer, choose **Episode prototype**, and click **Scan full saved trace**. Choose a proposal row to inspect it, or **Show full recording** to restore context. The scan searches the entire saved temporal trace on that footprint; the selected old event does not restrict it. Opening the tab or changing selection does not run the model. The previous Whole-event preview remains separate.

Table outcomes and scores are experimental model outputs, not accepted event membership. A fit on the footprint associated with one saved event may propose an episode elsewhere in the recording. A default selected row may require scrolling the table to see it. The panel has no scientific Save or export control. [User guide](BOI_WHOLE_EPISODE_PROTOTYPE.md).

## Comparison with the existing judgments

The intervals below are the nearby proposals selected for the fixed montage by temporal overlap with the saved or provisional review interval. They are not accepted replacements or independently labelled ground truth.

| Example | Prior decision or context | Primary prototype near that context | Interpretation |
| --- | --- | --- | --- |
| FB2412 site20/event1 | Recognized, saved114–182; reference104–113 | Raw and corrected candidate107–179 | Captures a wider episode than original142–172, but timing differs from the accepted review and remains grid-limited. |
| FB2413 site3/event6 | Provisional onset826–827, likely end851 | Nearby767–863 proposal is background-like in both stages | Does not isolate the pocket you identified. The earlier broad depression dominates the displayed alternative. This is a meaningful miss, not a reason to reverse your judgment. |
| FB2317 site13/event5 | Excluded | Raw background-like666–810; corrected uncertain649–793 | Preserves disagreement/uncertainty around the sustained decline. Existing exclusion remains authoritative. |
| FB2319 site7/event2 | Excluded | No nearby complete-episode proposal at45–51 | Consistent with withholding a separate episode here; absence of a proposal is not proof of a biological negative. |
| FB2412 site1/event1 | Excluded recording-start example | No nearby complete episode; boundary cautions remain | Does not substitute a later reference or claim an observed preceding baseline. |
| FB2412 site1/event2 | Recognized, saved651–693; shorter659–672 remains preview | Raw629–701, corrected630–702 candidates | Extends too far into the preceding change relative to your saved interpretation. Its fitted background supplies a return that is not the same as raw absolute recovery. |
| FB2412 site1/event3 | Excluded as a separate pocket next to event2 | Similar broad629–701/630–702 interval on this separate saved footprint | Shows a shared longer temporal interpretation across footprints, not a newly accepted separate event. Cross-footprint episode consolidation remains unresolved. |

The additional five examples follow fixed coverage rules: strongest available model gain, strongest competing background, a strong raw/corrected mismatch, widest timing alternatives and a deterministic cap-limited/boundary context. They are deliberately not a gallery of successes.

In the strongest-score examples, the raw signal can continue declining while the fitted background declines faster, producing a return *relative to that fitted background*. The model can then score a pocket highly without a clear observed raw upturn or recovered state. This is an inspection-based failure risk, not an accepted biological exclusion of every broad decline. Broad/shared pockets must remain eligible. The next model must distinguish observed recovery evidence from recovery supplied by a background assumption and retain ambiguity when it cannot.

## Fixed recording evaluation

The service scanned the 4,055 existing overlap-group representative footprints across all 17 saved recordings. All 5,407 original candidates retain their source-group membership exactly once. There were 2,684 development traces and 1,371 held-out traces. Source, settings, choices and development summaries were frozen before the one held-out pass. No configuration was chosen to match the prior judgments or held-out outputs.

The primary search used 13 durations from6 to384 seconds, four triangular/trapezoid/asymmetric profiles, a jointly fitted linear background and curved/step/slope-change competitors. Scores penalize model complexity; they are not calibrated probabilities. Timing alternatives describe nearby screened fits, not confidence intervals. A single timing pair still has grid uncertainty. Source sampling rates remain explicit; the supplied recordings use1 Hz.

| Stage | Pocket-candidate proposal views | Background-like views | Uncertain views | Traces reaching120-seed screening cap |
| --- | ---: | ---: | ---: | ---: |
| Raw | 21,811 | 20,524 | 7,978 | 4,033 /4,055 |
| Corrected | 27,178 | 22,794 | 5,695 | 4,055 /4,055 |

These 105,980 proposal views include overlapping temporal alternatives, related footprints and both stages. **They are not independent pockets, accepted events, prevalence or burden contributions.** The first pass filtered the complete temporal traces but fitted only the strongest120 seeds per stage; weaker episodes can be missed. High cap saturation means the resulting proposal list is not an exhaustive episode catalogue. Old detection overlap and model proposals outside related old intervals are retained as comparisons, not false-positive/false-negative labels.

The five held-out recordings retained the same limitations: their raw results contain7,016 candidate,6,835 background-like and2,871 uncertain views; corrected results contain8,502/6,997/1,986 respectively. Without independent labels these counts do not establish improved sensitivity or specificity. These recordings are held out from this development, not historically unseen data; their prior exports and unlabelled pattern overviews were already inspected.

## Robustness and computational cost

Three fixed alternatives were compared on120 development traces only. The table gives the median overlap of time assigned to pocket candidates, excluding pairs where neither model proposed a candidate. This is representation/model stability, not biological accuracy.

| Alternative | Raw time overlap | Corrected time overlap |
| --- | ---: | ---: |
| Quadratic joint episode background | 0.760 | 0.850 |
| Offset duration grid | 0.634 | 0.699 |
| Double complexity penalty | 0.924 | 0.988 |

Duration and background choices materially affect the result. The prespecified primary remains unchanged. Local coefficients/noise are estimated per trace; no cross-recording classifier was trained on the sparse prior judgments.

The ten-trace benchmark took0.76 seconds. The development pass, including the limited alternatives, took177.8 seconds; the held-out pass took81.0 seconds. These timings describe the prototype on extracted saved evidence, not full movie processing. Full temporal context cannot recover spatial locations absent from the saved footprints, and native masks are evidence from the old detector rather than independent confirmation.

## Software verification and preservation

- All23 focused synthetic/reviewer checks passed after the bounded pre-source repair. Fixtures cover asymmetric/short/long episodes, recurrence, overshoot, drift, trend/step/curved backgrounds, stage disagreement, recording edges, gaps, acquisition rate and input guards.
- The current portable gate passes260/260; four focused programmatic desktop checks pass. The existing whole-event preview and new reviewer integration remain available, and selection/settings invalidate stale results.
- Independent Python replay verifies68 sampled stage hypotheses across all17 recordings: competing scores, episode coefficients, screening statistics, classification and residual sums. Maximum scalar score/RSS difference is1.20e-7. This checks arithmetic, not biological validity.
- All4,055 group outputs and5,407 original memberships pass checks. The619 protected files,88 pinned derived inputs and51 selected original saved-evidence files match their hashes; some sets overlap.
- The actual panel reproduces the saved FB2413 raw/corrected model results exactly. Captures at1280×900 and1120×800 and all four montage pages were visually inspected. Native desktop inspection was blocked by the locked Mac; human usability acceptance is not claimed.
- The505-file future source inventory validates. Code Analyzer reports16 style/performance advisories across the five inspected source/test files, with no reported parse errors; successful tests establish runtime coverage only for their cases.

Two repair cycles are retained: synthetic checks exposed long-context/transition-fit issues and an incomplete synthetic audit schema; a summary adapter then omitted SciPy list-form structures before the held-out pass. The latter repair corrected summaries from unchanged saved model results. Superseded records remain in the evidence folder. No tuning or core change followed held-out evaluation.

No original movie was read or modified. Production detection/correction, original automatic and reviewed outputs, accepted reference decisions, amplitude/area calculations, burden formula/normalization and export formats remain unchanged. No prototype proposal entered a scientific save or export, and no partial burden was calculated. No commit, push, external publication, package or release occurred.

## Decision and stopping point

The approved prototype milestone stops at this implementation and reviewable comparison, within six active hours, four analysis batches, two repairs and1 GiB. This is a delivered experimental tool with documented recognition failures, not scientific adoption or an accepted replacement detector.

The recommended next scope is to address fair temporal proposal coverage and the distinction between observed recovery and model-created recovery, then compare competing whole-episode interpretations. It should include consolidation across overlapping footprints so one episode cannot be counted repeatedly. Reuse the present failures as development examples; because held-out behaviour has now been inspected, a later tuned model cannot claim this packet as an untouched independent validation. No further implementation or recording evaluation is active under this delivery.
