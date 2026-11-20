# Candidate event-recognition and timing comparison

14 September 2026 · R2-RECOGNITION-TIMING-CANDIDATES-046

**Preparation complete; two timing candidates and one local-variability diagnostic are specified for a bounded development comparison.** They are proposals to test, not adopted physiological definitions. No new trace calculation, detector run, scientific threshold selection or production change occurs in this phase.

The researcher identified full declines/rises and recoveries, sometimes accepted a brief recovery peak, retained alternative plausible boundaries, and rejected two detections as unrecognizable. The [measurement-impact audit](../boi-marked-interval-impact-20260914/README.md) showed that event recognition and amplitude availability must remain separate. These observations motivate the following comparison; they do not establish an automatic event classifier.

## The three questions to keep separate

1. **Recognition:** how distinct is the candidate excursion from the preceding and following variability? Retain evidence on each side, ambiguous cases and researcher disagreement.
2. **Timing:** which turning points bound a decline or rise and its local recovery? Preserve incomplete boundaries, competing fluctuations and plausible alternatives.
3. **Measurement:** can the existing raw-source amplitude be calculated over that interval with its required reference? An unavailable amplitude must not suppress the recognition or timing result.

Saved native masks, detector sign, original measurement interval and researcher annotations remain separate columns. A negative-direction excursion inside a saved surge is not automatically relabelled. A rejected researcher example retains its original detection and numerical output; it receives no invented manual interval.

## Inputs and fixed comparison population

Use the **same 48 events from four development recordings** selected in phase 042, with all original slot mappings. No event replacement or selection on candidate agreement. This includes the ten already reviewed cases: eight with timing annotations including earlier anchors, and two without a recognized event. The other 38 have no human recognition/timing reference and must not be assigned one. There are three identified animals plus provisional HP, not four verified independent animals. Keep each recording, acquisition/support profile and saved sign separate in reporting.

Use each event's saved mean trace over its original native-union footprint and its existing per-pixel-corrected trace. **Do not fit a new trend, smooth again, normalize the timing signal, or introduce a substrate-consumption model.** Native footprint changes, anatomical holds and differences between whole-field and restricted-ROI preparations remain visible. This comparison cannot settle spatial segmentation or craniotomy membership.

Run both directional branches on the corrected trace: let `z = direction × corrected`, where direction is −1 for a decline and +1 for a rise. A peak of z represents the selected directional excursion. Unlike the earlier zero-crossing diagnostic, the new candidates do not require the excursion to lie on a particular side of corrected zero. This is an explicit candidate difference, not a change to the stored detector sign.

Reuse phase 043's saved search limits for each event: native bounds expanded by at most 30 frames and clipped to acquisition limits and same-site/same-sign neighbor partitions. Do not expand the search after inspecting a mismatch. These are computational inspection limits, not physiological duration limits; a long native event may still produce a long candidate. Both-sign overlaps remain visible but do not silently impose additional timing partitions.

## Timing candidates

Retain the saved measurement interval as comparator T0 and the previously calculated zero-crossing results as comparator T1. Reuse T1 by verified identity rather than rerunning it. T1's sign-existence and censoring rules remain distinct from the new candidates.

The following operations apply independently to each directional branch:

- Select the largest finite z among the saved native frames, using the earliest frame if multiple disjoint equal maxima occur. Export all tied native maxima and a competing-seed flag. With no finite native values, report `missing_native_signal`.
- Within the saved search bounds, find the contiguous finite segment containing that seed; never cross a nonfinite sample. Record the search, acquisition, neighbor and nonfinite barriers independently.
- Treat a plateau as a maximal run of exactly equal finite values. A peak plateau requires a finite lower neighbor on both sides; a trough plateau requires a finite higher neighbor on both sides. Both neighbors must lie within the allowed finite segment. Exact equality is a numerical tie convention, not a new biological tolerance.
- Extend the selected seed through its equal-value plateau. If this plateau is not an observed local peak of z, report `seed_not_bracketed_peak` with the observed barrier or monotonic-extension information. Do not shift the seed to a better-looking peak outside native support.
- Eligible shoulders are observed trough plateaus strictly before or strictly after the seed plateau. A search endpoint is never promoted to a turning point without its outside neighbor. Each missing side remains unresolved with its barriers and `no_observed_shoulder`; a partial observed boundary may still be reported.

| Candidate | Onset shoulder | Recovery shoulder | Question and expected limitation |
|---|---|---|---|
| T2: nearest turning points | Last eligible trough plateau before the seed | First eligible trough plateau after the seed | Does the nearest local turn capture the excursion, or split it at minor fluctuations? |
| T3: strongest shoulders within the same limits | Eligible left trough plateau with the lowest z; ties choose the one nearest the seed | Eligible right trough plateau with the lowest z; ties choose the one nearest the seed | Does a broader excursion match full onset/recovery, or cross distinct neighboring fluctuations? |

For a chosen plateau, export its full start/end range. For the numeric comparison interval use the onset plateau's **last** frame and recovery plateau's **first** frame, the edges facing the seed. This is a deterministic calculation convention, not a claim that a physiological boundary is exact. Singleton turns give one frame. Never average plausible alternative boundaries into a supposedly known onset.

Neither candidate requires sustained recovery, return to a flat baseline, crossing fitted zero, a minimum event duration, or a minimum height. A brief turning point can be a recovery candidate. That allowance does not mean every small fluctuation is an event. Export all intervening local extrema and the number of peaks between shoulders, all competing seed ties, native-interval coverage and both-sign overlap within the candidate. T3 enclosing multiple peaks is explicitly ambiguous, not proof of a single long event. Do not merge events, trim native masks or impose refractory intervals.

## Recognition diagnostic R1: excursion versus surrounding variability

For each complete T2/T3 interval `[a,b]`, evaluate the corrected directional trace using the **10 immediately preceding and following samples**, then repeat with **20 samples** as a prespecified context sensitivity. These are two review scales chosen to expose context dependence at 1 Hz, not established biological timescales or an optimization grid. Keep the two results separately; do not select whichever agrees with the researcher. Context samples are `a−W … a−1` and `b+1 … b+W` for W in {10,20}.

These context windows are **not amplitude baselines**. They retain surrounding activity and both-sign native overlap, since the question concerns actual local variability, including recurrence. Export overlap counts and sample IDs. Do not discard active frames, search further away, extend truncated windows or borrow samples from the opposite side. Each side needs its full W finite samples. If incomplete, mark that side unavailable and preserve the other side's descriptors; the two-sided comparison is unresolved.

For each side, report the median, minimum, maximum, unscaled median absolute deviation and total range of z. Use the ordinary median (average of middle values for an even count). Define directional shoulder prominence:

`Pleft = z(seed) − z(onset shoulder)`

`Pright = z(seed) − z(recovery shoulder)`

`P = min(Pleft, Pright)`

This conservative descriptive height uses both shoulders. It is in corrected signal units and **is not the released relative optical amplitude**. Report the difference between shoulder levels as well; dissimilar levels need not be attributed to substrate decline.

Report `P / range(before)` and `P / range(after)` separately when the denominator is positive. A zero range produces an unavailable ratio with `zero_context_range`, not infinity or an arbitrary epsilon. Also retain the scalar differences `P − range(before)` and `P − range(after)`, so flat-context cases remain inspectable.

The prespecified screen is **P strictly greater than both context ranges**. Its result is named `exceeds_both_context_ranges`, `does_not_exceed_both_context_ranges`, or `context_unresolved`. This is an explicit, conservative comparison hypothesis motivated by the researcher's local-variability judgment. A numerical factor of one defines this particular screen; it is not a validated SNR/significance threshold or a production acceptance rule. Outliers, recurrence and broad changes can make the range large, including for a visible event. The screen's disagreements must be reported rather than repaired with a new multiplier, percentile, smoothing rule or context length.

Also report whether the seed exceeds each context maximum. Keep that level comparison separate from P and range: a local excursion can occur on different pre/post levels. Context-scale disagreement, a successful screen in both directional branches, multiple internal peaks, flat context or overlapping activity remain explicit review flags. Neither a successful screen nor a failed screen assigns biological truth, changes the detector label, or deletes an event.

## Human comparison and biological coverage

Preserve the exact ten-case review order, verbatim feedback provenance and all supplied alternatives. Onset 295 and 297 in ID400 example 3 remain separate marks; frame 296 remains a separate sensitivity for literal elapsed second 295. It is not counted as an accepted human annotation. Compare reported plateau intervals to each stated boundary alternative, and export signed point-convention errors in seconds for every alternative. Do not collapse these to one best-case error or invent a ± tolerance. Report native and candidate time separation and inclusive sample counts separately at external exact 1 Hz.

Timing agreement is evaluated only for the eight annotated cases. No timing error is assigned for examples 6/7 or the 38 unannotated cases. Recognition agreement is descriptive against the researcher's case-specific judgments: separately show the recognized examples, the two non-recognized examples, and unknown-reference cases. Case 2 and the earlier anchors have annotations whose decline/recovery interpretation differs from the saved surge sign; evaluate both directional branches without asserting that the researcher affirmed a surge. Neither branch may be silently chosen using the manual answer. No accuracy, sensitivity/specificity, p-value, animal-level treatment effect or held-out performance claim is appropriate here.

Report results by recording, saved sign, candidate and directional branch, with resolved/partial/missing timing, context completeness, 10/20-sample sensitivity, inter-candidate disagreement, intervening peaks, native coverage and amplitude availability. Retain the original phase 042 slot mapping for weak/strong detector contrast, shortest/longest native events, overlap and recurrence. Those are selection proxies, not physiological labels. Changing native area/support is already documented in phase 043 and should be reused. Annotated irregular and brief-recovery examples remain visible. Coverage of true weak events, ambiguous separation, motion, incomplete acquisitions and physiological sustained activity cannot be declared adequate from those proxies; remaining gaps must be listed.

## Amplitude and output contract

Only for a complete candidate interval, calculate the existing raw-source amplitude over the **unchanged original native-union footprint**, using all 20 immediately preceding finite samples without any native overlap of either sign. Preserve both formulas and stored sign, negative values and unavailable references. No new correction or fallback is permitted. A partial timing result gets `timing_unresolved`; any observed boundary and context diagnostics still remain visible. A broader/narrower interval does not recalculate the native footprint, area, coverage, event count or statistical outcome.

Every row must include recording and event IDs, original sign, candidate ID, directional branch, source/footprint hashes, original/native intervals, search limits, seed and tied seeds, plateau boundary ranges, chosen numeric endpoints, all barriers, recognition descriptors per side/scale, exact context and baseline frame sets, native overlap counts, intervening extrema, raw amplitude and status, and the original comparison value. Tie, context and amplitude statuses are separate. Export a readable explanation alongside the rows and bind it to the frozen candidate version.

For the same ten reviewed cases, generate review panels showing the saved corrected trace, both candidates and directional branches, seed, shoulder plateaus, context windows and barriers, with the raw amplitude reference in a separate panel. Preserve the existing full-record trace and native-mask links. Report all 48 events in tables; do not expand manual review beyond ten examples merely because a case disagrees.

## Verification, budget and stopping decision

Before running on the saved panel, check the proposed implementation on a compact set of known-shape signals: isolated decline and rise; offset/scaled versions; a brief recovery peak followed by another excursion; nested minor fluctuations; equal plateaus and disjoint tied seeds; monotonic/flat traces; a nonfinite gap; acquisition and neighbor truncation; and visible excursions with low/high/flat or overlapping surrounding variability. Verify expected boundaries, invariance to additive offset/positive scaling where defined, status behavior and both directions. These are numerical checks, not biological validation. Add no signal family without identifying a specific uncovered behavior.

Bind the complete source panel, annotations, prior comparison rows, candidate definitions, implementation and environment by hash before new results. Reproduce the original saved comparator values and independently verify arithmetic, plateau selection, overlap and statuses. Require exact identity/status/sample sets and numerical agreement within 1e−9 absolute plus 1e−12 relative. Technical corrections must preserve failed outputs and say whether scientific settings changed.

Maximum new panel calculations: **48 events × 2 candidates × 2 directions = 192 timing rows**. Each complete row has two context-scale diagnostics, at most 384; the amplitude calculation is shared across context scales and is not duplicated. Reuse saved and zero-crossing comparator results. One pass per recording; maximum ten minutes per recording and 250 MiB of new evidence, excluding referenced existing inputs. No movie reads, detector reruns, parameter sweep or production edits. The implementation checks and one independent verifier are within this phase budget. If the budget is exceeded, stop and report what remains without silently reducing the panel.

Evidence favoring a candidate would be closer, interpretable boundaries across the supplied alternatives, fewer unresolved cases without crossing barriers, and recognition descriptors that distinguish the two non-recognized examples without hiding recognized weak/brief/sustained examples. **Report gains and losses separately; no numerical scientific pass threshold or winner-selection score is specified.** Fewer missing amplitudes, preferred amplitude direction, higher event counts or an expected condition effect do not count as improvement. Loss of source identity, hidden missingness, new exclusions, branch selection based on human answers, or unsupported complete-boundary claims is unacceptable.

After the one fixed comparison, stop to report which candidate is informative and where each fails. Retain production rules and defer physiological policy if inconclusive. Any new scientific parameter or changed rule requires a dated follow-up proposal; no automatic tuning loop follows. These development examples cannot freeze final physiological timing, the primary-outcome hierarchy, cohort eligibility or evaluation independence.

**Next:** implement these diagnostic-only candidates, verify their numerical behavior, then execute the frozen comparison. A production change remains a separate evidence-based decision.
