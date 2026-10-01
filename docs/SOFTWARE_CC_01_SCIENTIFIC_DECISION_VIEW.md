# CC-01: three traces for a scientific decision

29 September 2026; researcher interpretation added 30 September 2026 · Saved evidence only · **No method adopted or production output changed**

## Researcher selection, 30 September 2026

The researcher accepted the three-pair numerical comparison within its stated limits and selected **corrected signed trough as percent of positive raw reference intensity** as the primary exploratory optical quantity for researcher-reviewed pockets, with raw signed trough alongside it. C02 remains conditional, FB2312 recovery unresolved, and saved footprint qualifications persist. This records the selected reviewed-measure semantics; it does not implement or validate a production default or automatic label change. The [CC-02 integration proposal](SOFTWARE_CC_02_REVIEWED_POCKET_IMPLEMENTATION_PROPOSAL.md) connects exact frames, suitability and provenance to review/save/reopen/export under a separate bounded implementation decision. The earlier “no adoption” statements remain historical descriptions of evidence generation and production changes.

## Approved three-pair numerical comparison, 30 September 2026

**Delivered for one scientific decision; exploratory results only.** The researcher approved calculation for the three exact proposed pairs with routine arithmetic verification. Approval retained C02's provisional reference and conditional result, FB2312's unresolved recovery, and both saved surge footprints. Three named case evaluations completed; no alternative samples or support were introduced. Earlier recommendation and comparison evidence are preserved below.

### All three together

| Example | Approved comparison W / R | Raw signed trough (%) | Corrected signed trough (%) | Trough frame, both |
|---|---|---:|---:|---:|
| Historical ID400 | 82–98 / 73–81 | -4.3287 | -5.0523 | 88 |
| FB2312 | 398–417 / 378–397 | -8.1385 | -8.3626 | 404 |
| C02 row 321 — conditional | 177–195 / 165–170 | -11.1049 | -12.3838 | 186 |

Negative numbers indicate a downward optical excursion, not absolute oxygen loss. Raw and corrected quantities use **identical W, R and fixed footprints** for each example, and the same positive raw denominator B. Formulas are `100×min_W[(r−mean_R(r))/B]` and `100×min_W[(c−mean_R(c))/B]`, with `B=mean_R(r)` and saved `c=r−T`. No new trend was fitted. Corrected minus raw is −0.7237, −0.2241 and −1.2788 percentage points respectively; this difference reflects the saved correction within the selected context, not isolated substrate consumption or proof of biological specificity.

### Effect against earlier results on a common signed-trough basis

| Example | Earlier raw signed trough (%) | Earlier corrected signed trough (%) | New−earlier raw (pp) | New−earlier corrected (pp) |
|---|---:|---:|---:|---:|
| Historical ID400 | +0.3497 | -2.7930 | -4.6783 | -2.2594 |
| FB2312 | -7.1979 | -7.3532 | -0.9406 | -1.0093 |
| C02 row 321 — conditional | -14.1681 | -15.1948 | +3.0632 | +2.8110 |

“Earlier” means ID400 W58–98/R38–57, FB2312 W403–412/R383–402, and C02's reviewed W177–195/R165–176. The same raw and corrected trough frames remain 88, 404 and 186 in every old/new comparison. For these particular minima, the numerical differences therefore arise from changed reference levels and denominator scaling; the longer/shorter windows do not select another trough. This does not validate durations or show that endpoint choices cannot matter in other events.

The original **saved-sign amplitude columns are different quantities and remain visible**:

| Example | Original automatic A1 with saved label | Existing reviewed A1 | Previous exploratory A2 with saved label |
|---|---|---|---|
| Historical ID400 | **sink −0.3497%** | — | sink-convention **+2.7930%** |
| FB2312 | **surge −2.3881%** | — | surge-convention **−2.6306%** |
| C02 row 321 | **surge unavailable**, 0/20 clean samples | surge-convention **+6.0209%**, R165–176 | surge-convention **+5.5765%**, same reviewed R |

A sink-convention amplitude is the negative of the signed minimum; a surge-convention amplitude uses the maximum. Neither saved surge maximum is being overwritten by the new signed minimum. C02's automatic missingness remains unchanged; its conditional calculation does not fill the unavailable automatic field.

### Reference effects and limits

| Example | Raw reference mean, earlier → new | Corrected reference mean, earlier → new |
|---|---:|---:|
| Historical ID400 | 72.8199 → 76.3808 | -0.9633 → 0.8618 |
| FB2312 | 706.3026 → 713.5350 | 19.7550 → 27.4888 |
| C02 row 321 — conditional | 5137.8256 → 4960.7850 | 611.9478 → 445.5971 |

Reference means are in each recording's own input intensity units and must not be compared across recordings as oxygen levels. Ordinary fluctuations are allowed. The calculations demonstrate the consequences of these selected references; they do not establish their physiological suitability.

- **ID400:** the new nearby nine-frame reference turns the raw signed trough from +0.3497% into −4.3287%; corrected excursion becomes −5.0523%. This is consistent with the researcher's late-pocket recognition. Suitability still depends on regarding 73–81 as the local pre-episode state rather than distinct preceding activity. Proposed onset/return remain approximate.
- **FB2312:** excluding the researcher-identified decline from the reference deepens the corrected trough from −7.3532% to −8.3626%. The saved footprint still originates from **surge site 1/event 2 (3,684 pixels)**, not a newly outlined pocket. Frame **417 remains a provisional observation end with incomplete/uncertain recovery**, so no validated full episode duration is reported. The rebound is not classified as a separate positive event.
- **C02:** shortening R165–176 to **165–170 (six frames)** lowers both reference means and reduces the corrected trough magnitude from 15.1948% to **12.3838%**. This is consistent with a reference affected by later rising activity, but does not prove a preceding biological surge or make 165–170 suitable. Its status remains **conditional on this short segment representing the local pre-episode state**. If it includes earlier-pocket recovery or the suspected surge, this is not an endorsed amplitude. Support remains the saved **surge site 5/event 1 footprint (5,086 pixels)**. The researcher-recognized pocket has not received a new spatial mask.

### Saved spatial context

The [three-example figure](../../reference-validation/cc-01-episode-recommendation-20260930/three-example-recommendation.png) shows the exact footprints and eligible support already saved, including ID400's 1,100-pixel sink footprint. It remains a proposal-era display using OLD reference normalization; its curves must not be read as the newly computed percentages. FB2312's footprint reaches the image-edge region; C02's lies near the tissue-support edge. Physical pixel sizes differ. These facts support review of the fixed measurement support, but do not establish the extent of reference/surge/pocket phases, a new exclusion, or a blood-flow mechanism. Broader hyperemia with a local pocket remains a hypothesis.

### Arithmetic and preservation

The [structured results](../../reference-validation/cc-01-three-pair-comparison-20260930/results.json) retain every reference/event frame, reference mean, footprint checksum, source identity, trough frame, prior value and difference at full precision. Final [harness and six saved-input hashes](../../reference-validation/cc-01-three-pair-comparison-20260930/pins.json) were pinned before calculation and matched afterward. Each raw/corrected trace uses the same unchanged fixed union; saved correction association passed the earlier 0.0001-input-unit tolerance.

Routine verification within these three cases compared vector calculations with independent scalar accurate summation for all selected samples, checked troughs and reference means, replayed the three corresponding old signed troughs, and verified the raw=corrected+trend decomposition. Scalar tolerance was `1e−10×max(1,abs(expected))`; largest scalar discrepancy was **1.91e−14 percentage point** and largest decomposition discrepancy **4.45e−14 percentage point**. All checks passed. This was assistant self-review, without an independent reviewer. No named case was left arithmetically untested; reference suitability, episode-specific spatial extent and physiological specificity remain unresolved.

The [execution record](../../reference-validation/cc-01-three-pair-comparison-20260930/execution.json) records three case evaluations and zero MATLAB launches, recording runs, correction refits, footprint redefinitions or production changes. No detector/statistics engine ran and no source movie was opened. The prior 18-case evidence was used for comparison without replaying its consumed matrix. Existing outputs, prior figures and packets remain intact.

**Recommendation for this one scientific decision:** the signed corrected trough is a coherent common quantity for the three researcher-recognized pockets, with the raw signed trough beside it. Accepting these numbers as exploratory evidence is separate from endorsing the exact references or adopting a production measure. Retain C02 as conditional and FB2312's recovery as unresolved. No automatic label replacement or production rule is justified by arithmetic agreement alone. Release work remains paused.

## Concrete three-example recommendation, 30 September 2026

**For scientific review only.** The researcher requested one recommendation for these same three examples. A suitable reference represents the **local pre-episode state and may contain normal fluctuations**. Flatness is not required. A suspected separate episode or the beginning of the target decline is a suitability concern; ordinary variability is not itself contamination. This clarifies the earlier “quiet reference” wording below. None of these proposed samples, boundaries or quantities has been adopted or written into a saved review.

![Proposed episodes and references with saved spatial support for all three examples](../../reference-validation/cc-01-episode-recommendation-20260930/three-example-recommendation.png)

The curves keep their original A1/A2 display normalization. Moving the purple reference band **does not re-zero the trace or calculate a replacement amplitude**. Green marks the proposed episode; dashed gray marks the original saved measurement window. Frame numbers are inclusive and one-based, at the supplied external 1 Hz.

| Same saved example | Proposed episode W | Candidate reference R | Suitability and uncertainty |
|---|---|---|---|
| Historical ID400, saved sink site 11/event 1 | **82–98**; onset approximately 82–84, return approximately 97–99 | **73–81** (9 frames) | This targets the later decline from the peak near 82, trough at 88 and return near 98. The nearby fluctuating state precedes that decline and avoids the earlier prominent peak near 69 and older reference 38–57. Nine frames provide limited context; the smaller excursions in 73–81 still need your judgment as ordinary variability versus separate activity. This interval is preferable for the proposed late episode, conditional on that judgment. |
| FB2312, saved surge site 1/event 2 | **398–417**; **417 is a provisional observation end**, not a verified full-recovery boundary | **378–397** (20 frames) | Honors your approximate onset 398 and excludes 398–402 from the saved reference 383–402. The reference retains the preceding fluctuations, including the rise near 391–393; suitability does not require a flat segment. The trough is near 404 and rebound is visible through 417, but recovery remains below much of the pre-episode state and further fluctuation/another decline follows. Treat duration as unresolved rather than claiming full recovery at 417. No separate surge is assigned to this rebound. |
| C02 row 321, saved surge site 5/event 1 | **177–195**; onset approximately 177–178, recovery near 194–195 | **165–170** (6 frames), **provisional lower-confidence reference** | Retains the existing reviewed episode bounds and your recognition of its pocket. This candidate uses the local state after the earlier 155–165 pocket and before the clearer rise near 171–177, shortening the earlier reviewed reference 165–176. It contains normal fluctuation rather than a flat plateau. However, if the suspected positive episode already begins in 165–170, or recovery from the earlier pocket still affects this segment, it is unsuitable. Six samples are fragile; if you cannot identify them as the intervening state, the amplitude remains unresolved rather than replacing the reference automatically. |

The specific reference counts are deliberately visible. Twenty preceding frames are a current automatic rule, not proof of physiological suitability; the shorter candidates are proposed reviewed choices only. These three references are not interchangeable with resting oxygen or an unmeasured intervention baseline. Offset markers describe the trajectory, not a forced crossing of the saved zero line. A pocket can be recognizable with incomplete recovery or an unresolved reference.

### One amplitude recommendation across all three

Recommend the **signed corrected trough excursion**, expressed as a percentage of the positive preserved-input reference mean:

`E = 100 × min over W of [c(t) − mean(c(R))] / mean(r(R))`

Here r is the saved raw fixed-footprint trace and c is that recording's source-matched saved corrected trace. A downward excursion has a negative E. If a positive “pocket depth” is needed, it is exactly `−E` and should be explicitly named. Use the same signed quantity for all three researcher-recognized pockets regardless of their saved detector label. Require a suitable R, finite traces and a positive raw denominator before computing it; unresolved reference suitability means no endorsed amplitude.

This is the earlier exploratory A2 numerator/reference formulation with a **pocket-oriented minimum**, rather than the surge maximum used by two original saved labels. It follows the corrected-trace interpretation and avoids counting an onset maximum or recovery as the pocket magnitude. Keep the raw signed trough change using the same R/W as a secondary optical check, retain both extrema for review, and retain original A1/detector labels as historical outputs. Interval mean and integral are secondary descriptors because uncertain recovery and mixed activity change their meaning. No new numerator correction, universal decline model or corrected-mean denominator is proposed.

The recommendation is a choice of quantity to compare, **not new numerical validation**. The candidate-reference amplitudes have not been calculated. Current saved values remain visible:

| Example | Original automatic amplitude and sign | Existing reviewed A1 where applicable | Previous exploratory A2 under the OLD reference/window |
|---|---|---|---|
| Historical ID400 | sink **−0.350%**, W58–98, R38–57 | — | sink-convention **+2.793%** |
| FB2312 | surge **−2.388%**, W403–412, R383–402 | — | surge-convention **−2.631%** |
| C02 row 321 | surge amplitude **unavailable**, W183–193; 0/20 clean samples | surge-convention **+6.021%**, W177–195, R165–176 | surge-convention **+5.577%**, using that reviewed W/R |

Those numbers must not be reused as results for the new candidates. Source correction remains the existing saved cubic decomposition; this recommendation does not establish that detrending preserves every biological component or that optical percentage equals tissue oxygen percentage.

### Saved spatial context and limits

The panels are reconstructed from each audit's saved **fixed union footprint** and sink/surge eligible tissue pixels. Historical ID400 has 1,100 footprint pixels, FB2312 3,684 and C02 5,086. The first is saved sink support; the other two originate from saved surge detection, so they are not validated spatial outlines of the proposed pockets. Frame size is 512×512; pixel sizes are 4.75 µm for ID400 and 2.35 µm for FB2312/C02. Equal displayed map size therefore does not mean equal physical extent. Gray shows the existing support categories, not a newly estimated active-area threshold.

FB2312's footprint lies near the bottom image boundary; C02's lies near the lower tissue-support edge. That location is useful review context, but does not establish artifact or invalidate your recognition. Historical masks and C02's declared tissue support are different generations of support evidence. No new outline or footprint has been inferred. In particular, no matched phase maps in this packet show whether the possible C02 positive event extends beyond this footprint. Broader hyperemia with a superimposed local pocket remains a hypothesis; these maps do not demonstrate hyperemia, capillary obstruction or causality.

### Preparation and stopping boundary

Only the three existing saved audit rows and their source-matched metadata were read. ID400/FB2312 dimensions were checked against the saved conversion reports with matching raw-source checksums; C02 supplies FrameSize in its audit. The [preparation record](../../reference-validation/cc-01-episode-recommendation-20260930/provenance.json) pins those inputs, the prior CC-01 results, figure and scripts. Input hashes remained unchanged. Plotting extended context around the saved traces; it did not refit correction, replay the consumed 18-case matrix, compute candidate-reference amplitudes, or inspect a source recording. No MATLAB, detector, statistics or recording execution occurred.

**Review requested as one decision:** are these candidate episodes/references suitable for a subsequent bounded comparison of the signed corrected trough? In particular, is C02 165–170 an intervening local state, and should FB2312 retain an unresolved recovery endpoint? No automatic scientific adoption follows from this recommendation. Release remains paused.

## Earlier saved-window comparison (preserved)

![Raw and corrected optical traces for historical ID400, FB2312, and C02 row 321](../../reference-validation/cc-01-decision-view-20260929/three-event-decision-view.png)

The black curve is preserved-input change **A1**. The blue curve is the exploratory corrected excursion **A2**. Each uses the *same event footprint, exact saved reference frames, and positive preserved-input reference mean* for its percentage scale. Blue subtracts the saved source-matched cubic trend; no correction was refitted. These are relative optical changes, **not percentages of tissue oxygen**. Purple marks reference frames, green the measured event window, and dashed green lines the native detector bounds. The ID400 and FB2312 references were selected by the automatic clean-sample rule; C02's 12 frames were explicitly accepted for its separate reviewed result.

| Saved example | What the trace establishes | What it does not decide |
|---|---|---|
| **Historical ID400, sink** · reference 38–57; window 58–98; native 85–96 | The raw window never falls below its reference: its minimum is **+0.350%** at frame 88, producing the saved sink amplitude **−0.350%**. Corrected minimum is **−2.793%** at 88, while corrected maximum is **+6.239%** at 69. The corrected window has both signs and a **+1.446%** mean. | Whether the late trough alone constitutes a sink, or whether the 41-frame window combines distinct activity. |
| **FB2312, surge** · reference 383–402; window/native 403–412 | Corrected values remain below the reference throughout: **−7.353%** at 404 to **−2.631%** at 411. The trace rises from its trough even though it never exceeds the pre-event level. Saved surge amplitude is **−2.388%**; candidate A2 surge-convention amplitude is **−2.631%**. | Whether “surge” means an above-reference event or a local rebound while still below reference. |
| **C02 row 321, reviewed surge** · accepted reference 165–176; window 177–195; native 183–193 | Corrected maximum is **+5.577%** at reviewed onset 177 and minimum **−15.195%** at 186; mean is **−6.077%**. Raw extrema are **+6.021%** and **−14.168%** at those frames. The original automatic amplitude is unavailable because it had **0/20** clean pre-event samples; the separate reviewed result uses 12 accepted frames. Its saved recognition status is **uncertain**. | Whether the positive onset belongs to one surge, the later trough to another event, or the whole interval should stay mixed/uncertain. The reviewed reference needs scientific acceptance on its own merits. |

## Researcher interpretation, 30 September 2026

The researcher sees a **sink/pocket in the green measured phase of all three examples**. For FB2312, the researcher places the beginning of the sink at **approximately frame 398**, before the saved 403–412 window. The lilac reference phase in C02 row 321 **may contain a surge**. These are qualitative judgments on the displayed traces; they do not yet specify replacement boundaries or reference sets, and the plotted saved bounds remain as evidence of the existing calculation.

The researcher expects surges associated with functional hyperemia to have broader spatial coverage and sinks associated with local capillary obstruction to be more spatially restricted. This is recorded as a biological interpretation and spatial hypothesis, not a size threshold or a causal diagnosis for these three events. The [Science paper](https://pmc.ncbi.nlm.nih.gov/articles/11251491/) supports a link between pockets and interruption of capillary flow, and reports suppression of pockets during functional hyperemia. It also reports enlarged pockets after induced capillary obstruction, so spatial size alone cannot establish event identity. The present plots average a fixed saved event footprint and do not demonstrate the spatial extent of either phase.

The interpretation has two immediate consequences for measurement semantics. In FB2312, the current reference **383–402 includes frames 398–402 of the researcher-identified decline**. In C02, **165–176 may sample a preceding positive event rather than the local pre-episode state**. A downward excursion and its recovery can therefore be one sink episode despite a saved surge label or a positive segment. Quantifying the sink requires an explicit choice of its pre-decline reference and boundaries; selecting a new set automatically would change the scientific comparison.

## Proposed scientific rule framed by these judgments

30 September 2026 · **Interpretive proposal only; no replacement rule adopted.**

**Recognize an episode by its local trajectory and context.** A pocket is a temporally coherent local decrease, distinguishable from the variability around it, followed by recovery when that recovery is observable. Its decline, trough and recovery belong to the same candidate episode. Recognition does not require the whole displayed green window to be negative relative to the saved reference, nor a negative interval mean or a crossing of the corrected trace's arbitrary zero. The researcher's pocket judgments apply to activity within all three green phases; they do not certify every frame of each saved window or its current reference. A censored or overlapping episode can remain recognizable while its bounds or amplitude remain unresolved.

**Treat recovery and a separate positive event as different interpretations.** A rising segment after a pocket is consistent with recovery toward the surrounding local state. Positive slope, a positive normalized detector score, or an endpoint maximum alone does not establish a surge. A separate positive event would need evidence of its own upward excursion beyond the relevant local background variability, considered with its onset, persistence and return or censoring. An overshoot is supporting evidence, not by itself a second event. Where recovery, overshoot and a possible overlapping surge cannot be separated, preserve that ambiguity rather than automatically counting two events. No duration, amplitude or separation threshold is selected here.

**Reference suitability is separate from event recognition.** A reference can pass a native-mask screen yet contain biologically relevant activity missed by that screen. Conversely, a researcher can recognize a pocket while the automatic amplitude remains unavailable. For FB2312, the saved reference 383–402 includes approximately 398–402 of the decline identified by the researcher; its mean can therefore already be depressed and attenuate a comparison with the trough. Frame 398 remains an approximate onset anchor, not an adopted new bound. For C02, the possible positive event in 165–176 can elevate the reference and make the later fall appear larger than a comparison with the local pre-episode state. Neither effect has been newly quantified.

A fall from a preceding positive peak and a depression below the local pre-episode state are different quantities. The possible lilac-phase surge could precede a genuine pocket, or its termination could contribute to the measured fall; the fixed-footprint trace alone does not settle their separation. The researcher's pocket recognition is retained, while the amplitude interpretation remains conditional. Recovery samples can inform recognition of the surrounding state without automatically becoming denominator samples. If no defensible local pre-episode reference is identifiable, retain the recognized episode and report its intended pre-episode-reference amplitude as unresolved. Do not search backward, shorten the reference, use a post-event fallback or fit a replacement background without a separate approved rule. Existing saved A1/A2 values remain visible with their actual references and limitations; none is recomputed here.

**Use spatial extent to support the interpretation, not dictate it.** In a later authorized review, comparable phase-specific maps could show whether an upward change extends across more tissue while a decrease is spatially restricted, or whether both are restricted to the same footprint. The comparison would need the same valid craniotomy support and scale, retained dark interiors/edge uncertainty, and a distinction between observed signal and threshold-dependent detected area. These event-footprint averages cannot establish the extent of a preceding phase outside that footprint. Broader hyperemia with a superimposed local pocket is a hypothesis consistent with the researcher's interpretation; no blood-flow mechanism or causal diagnosis is demonstrated by these traces. There is no proposed mandatory size cutoff, spatial veto, new ROI or local-versus-global subtraction.

**Recommended separation in a future rule:** keep (1) saved detector sign, (2) researcher episode recognition and approximate boundaries, (3) reference suitability, and (4) amplitude definition as distinct, traceable decisions. A recognized pocket must not automatically acquire a finite amplitude or overwrite a saved surge label. A2 remains exploratory and cannot fix reference contamination merely by changing the numerator. The immediate scientific decision is the episode/reference meaning, before choosing a replacement numerical estimator.

## Remaining choices before changing calculations or labels

The researcher agreed to the episode and reference semantics above on 30 September 2026 (“i agree”). This accepts the interpretive foundation: decline and recovery belong to a pocket episode, separate positive activity needs its own evidence, reference suitability is independent of recognition, and spatial extent is supporting evidence. It does not adopt numerical thresholds, exact replacement boundaries/references, an amplitude estimator or a production label rule. The broader-hyperemia/local-pocket explanation remains a hypothesis.

1. **Operational event definition.** Translate the agreed episode meaning into explicit onset/recovery and separate-positive-event criteria before any implementation. Normalized detector sign remains candidate provenance; it does not settle this episode-level judgment.
2. **Temporal and spatial support.** Select the reviewed boundaries and inspect spatial extent before adopting a broader-surge/local-pocket rule. FB2312's approximate onset 398 is a review anchor, not an exact replacement bound. Historical ID400's early positive phase and C02's possible preceding surge need distinct treatment if they belong to separate episodes. The fixed saved footprints must remain identifiable when a different event interpretation is proposed.
3. **Primary magnitude.** For a scientifically confirmed direction, should the primary number be the signed raw peak, corrected peak, interval mean/integral, or a clearly named combination? The positive C02 onset peak and deeper negative trough show why a lone surge-convention maximum is insufficient. Retain A1 and A2 as distinct quantities while deciding.
4. **Reference authority.** Keep the automatic requirement for 20 complete clean samples unless an approved scientific rule changes it. Choose a pre-decline reference for the reviewed sinks, considering the FB2312 decline within 383–402 and the possible C02 surge within 165–176. Accepting a reviewed reference must not silently fill an unavailable automatic amplitude.

**Suggested interim interpretation:** retain the original labels as *detector labels* and the original A1 outputs as saved measurements. Show both signed extrema and the exact reference during review. Do not call A2 a validated oxygen amplitude or use it to relabel automatically. A later rule change needs an explicit definition of direction, mixed windows, reference authority and primary magnitude, followed by versioned numerical-impact review.

## Evidence and limits

The plot was generated from the three saved audit rows used by the [CC-01 comparison](SOFTWARE_CC_01_COMPARISON_REPORT.md). Its [plotted samples](../../reference-validation/cc-01-decision-view-20260929/plotted-samples.csv), [source/hash record](../../reference-validation/cc-01-decision-view-20260929/provenance.json), and [read-only plotting code](../../reference-validation/cc-01-decision-view-20260929/build_view.py) are retained. The script checked each audit hash against the comparison's pins and reproduced all raw/corrected window extrema to `1e−8` percentage point tolerance. The original audit files and CC-01 results were not modified. No source movie, MATLAB session, detector, statistics run or new correction fit was used.

These three examples expose interpretive choices; they are not an estimate of error rates or biological ground truth. In particular, subtraction of the saved trend may remove biological variation as well as nuisance variation.
