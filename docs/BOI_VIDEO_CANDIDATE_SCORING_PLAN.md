# Preserve temporal candidates while qualifying their context

9 November 2026. Proposed milestone **POCKET-VIDEO-DETECTOR-07**. Owner: Codex (root), without delegation. This is a concrete follow-up proposal from the requested continuation/review of the completed phase prototype. No new implementation or numerical fit is authorized by this document.

## Review decision

Retain the flexible phase representation, source-bound spatial evidence, conditional return contract and censoring causes. Do not retain the current event-versus-context decision as a production classifier. [Completed results](BOI_VIDEO_PHASE_TIMING_RESULTS.md) and [cards](../../reference-validation/boi-video-phase-timing-20261109/review.html) remain preserved.

The saved FB2413 target result contains an unselected episode beginning at 679, low at 790–806 and post-state from 816. It does not isolate the later target. Frames around the target are assigned to the post/context state, whose freely changing levels can follow another complete dip. The null model also permits free level changes. The failure therefore occurs inside phase allocation as well as at the final score gate; lowering the gain threshold alone is insufficient.

The full-window correlation proxy reaches its cap and triples the target scale, from 15.6 to 46.9 input units. Genuine temporal structure can influence that estimate. The saved pass establishes those calculations, but does not isolate their causal contributions. This proposal introduces no claim that one parameter adjustment will recover the known target.

## Intended correction

Make a complete decline–low–rise sequence an explicit temporal candidate. Then preserve the existing spatial/regional qualifications when judging whether that candidate supports a localized pocket. A raw temporal candidate, a responding regional patch and an accepted biological pocket remain distinct. Unavailable context should produce an uncertain interpretation rather than a confirmed negative.

### 1. Constrain context without forcing pocket identity

Use the same restricted nuisance-context family in the phase graph and no-added-episode comparison. Context may be stable, drifting or continuing recovery, but it must not hide a resolved decline-and-return cycle as arbitrary level changes. Such a cycle belongs to the candidate phases. Apply admissibility constraints before selecting the best path.

This does not mean every observed fluctuation becomes an accepted pocket. Observation noise can remain unexplained by a state transition; small or weak patterns can remain unsupported. Regional cycles can be explicit temporal candidates while retaining their regional or uncertain spatial status. Do not replace the old null with an artificially rigid constant baseline merely to force the expected result.

Keep decline, optional flat low phase and asymmetric rise. Preserve no-added-pattern, linked, left/right-censored and unresolved alternatives. A boundary at an observation/search limit remains qualified. The previously frozen spatial masks, comparator roles and regional components do not change.

### 2. Separate variation estimates from the candidate trajectory

Replace automatic full-window correlation inflation with a recorded, candidate-independent context/noise assessment. Estimate candidate-specific variation from usable observed context and innovations/residuals, explicitly excluding proposed episode evidence from any background-only calibration. Use saved comparison traces as consistency checks, not as interchangeable noise measurements for a different ROI.

Choose the estimator and admissible-context rule on the constructed cases, record them, and freeze them before evaluating either recording. Reviewed frame numbers and desired recording outcomes cannot enter that choice. If sufficient independent context is unavailable, expose `noise_context_unresolved` and retain an uncertain candidate; do not manufacture a precise scale or a confirmed absence. No new acquisition-noise calibration or universal physiological drift model is proposed.

### 3. Preserve observed preceding-state information

An initial continuing rise can be observed without establishing a previous pocket or a stable baseline. It must not erase the available pre-decline samples merely because no earlier post-state was identified. Characterize those samples as recovering, changing, short or unavailable as appropriate. Keep event-specific reference candidates before the surviving onset alternatives, with explicit contamination/separation limits.

This is a correction to diagnostic context bookkeeping, not approval of a new scientific baseline. FB2413's measurement baseline remains unresolved. FB2412's accepted original-ROI baseline 104–113 and timing 114–182 remain unchanged. No return target is derived from a three-sample turning peak.

### 4. Carry uncertainty through the candidate decision

Store temporal-pattern support, noise/context adequacy, frozen spatial/regional status, reference eligibility and return qualification separately. A failed or unavailable background comparison cannot by itself mean “no pocket.” A strong raw temporal fit cannot by itself mean “localized hypoxic pocket.” Every dependent endpoint remains conditional when onset/reference/context is unresolved; no measurement-ready or burden-ready result is produced.

## Fixed source set and proposed work items

Reuse the same eight trace cohorts and nine signal channels from the completed phase prototype:

- FB2413 diagnostic IDs 21173/15040 and saved comparison patches 50/68.
- FB2412 diagnostic IDs 2763/2348, the existing qualified core-local residual and saved comparison patches 144/82.
- Full saved windows 608–1114 and 5–839, with the existing external 1 Hz authority.
- Original-ROI raw/corrected traces and existing movies remain display-only context.

No new source pixels, recording, footprint, patch selection or regional fit is included. The archived 72,732 hypotheses and 17-recording batch remain untouched. Existing source identities and mask hashes carry forward; reviewed labels are post-inference comparisons.

| Item | Work | Acceptance evidence |
| --- | --- | --- |
| VCAND-01 | Correct the shared context/null family and preserve explicit temporal cycles. | The graph cannot conceal a later complete dip inside a post/context state; flexible flat/asymmetric episodes remain possible. Regional identity is not inferred from shape alone. |
| VCAND-02 | Implement candidate-independent variation and honest preceding-state characterization. | Correlated-noise controls remain conservative; episode structure does not silently become background noise. Missing or recovering context stays explicit and does not become a scientific reference. |
| VCAND-03 | Freeze one configuration and repeat the finite source comparison. | Nine saved-signal fits plus the same 60 declared aligned residual-block stress fits. Report improvements, misses and false candidates without post-freeze tuning. |
| VCAND-04 | Independently verify and deliver two whole-episode cards plus a keep/replace assessment. | Verify legal context/candidate transitions, costs, source identities, dependency/censoring fields and selected boundaries. Explain retained candidates and unresolved pocket identity without another frame-by-frame labelling exercise. |

## Finite development checks

Reuse the sixteen constructed fixtures and their independent small-problem checks from the phase prototype, with expected semantics recorded before evaluation. Add exactly two constructed failures exposed by the review:

17. A later, smaller decline–flat–rise episode following an earlier episode and observed return: it must not disappear inside the post/context state.
18. A rectangular decline–hold–return cycle: a free two-level context explanation must not silently establish biological absence. The output must distinguish temporal candidate support from spatial pocket qualification.

These **18 fixtures** remain computational/behavioural checks, not biological ground truth. Record the expected distinction between noise-only, a temporal dip in regional tissue and an accepted localized pocket. Do not tune to the known FB2413 or FB2412 frame numbers.

Preserve the existing noise-only no-added-pattern expectations. A failed noise control cannot be made to pass merely by renaming its false positive as an uncertain candidate. Record any context-quality uncertainty expectations before the first check run, and report changed assertions separately from changed method behaviour.

After the fixtures, freeze one configuration before all new recording evaluations. Reuse the previously specified **nine fits to saved signals and 60 stability fits**: twelve perturbations for each of four diagnostic raw channels and one qualified local channel, with aligned raw/local index sequences and fixed seeds/block rules. These are stability stress checks, not confidence intervals or independent biological validation. No additional ablation/configuration sweep is included.

## Scientific contract, limits and stop

Preserve the burden formula, normalization, strict complete-burden missingness rule, spatial evidence, original recordings, scientific references, original automatic/reviewed results, exports and production MATLAB workflow. Compute no new accepted amplitude, event area, burden contribution, partial sum or recording total. Findings remain local; no GUI integration, source-image analysis, package installation, Git transport or publication is included.

Proposed limits: **six active engineering hours, four batches, 18 constructed fixtures, nine saved-signal fits plus 60 fixed stability fits, one frozen configuration, two engineering repairs, 2 GiB measured worker memory and 256 MiB new evidence**. Owner is root with no delegation. Reuse the existing environment and evidence mechanisms.

The four batches cover contract/fixture preparation, implementation and constructed checks, frozen source/stability fits, and independent verification/cards/closeout. Scientific model repairs occur before freezing. Post-freeze numerical/source defects produce a preserved checkpoint; an output-preserving engineering repair requires exact numerical parity and counts toward the repair limit.

Stop after the two cards, verification receipt and explicit assessment of whether the correction preserves the known target while retaining appropriate regional/noise uncertainty. Report honest failures under the frozen configuration. A resource, source-integrity, effort or repair boundary stops work with a preserved partial checkpoint. No further diagnostic campaign, recording expansion or production adoption follows automatically. Deferral leaves the current cards and measurements unchanged.

The preceding milestone is closed. Implementation of this proposed correction requires approval under [existing-analysis/AGENTS.md](../AGENTS.md): “Before implementation, obtain approval for the milestone and its bounded work items.”

## Approval record

The researcher explicitly approved this complete bounded correction on 9 November 2026: “Approve this bounded correction.” Implementation is authorized within the limits above. The proposed-state text above is retained as the reviewed scope.


## Delivery record

Delivered and stopped on 9 November 2026: four batches, eighteen constructed fixtures, nine saved-signal fits, sixty fixed stability fits, one frozen configuration and two pre-freeze model repairs. Numerical verification passes; saved-target acceptance does not. [Results](BOI_VIDEO_CANDIDATE_SCORING_RESULTS.md) and [cards](../../reference-validation/boi-video-candidate-scoring-20261109/review.html) record the FB2413 miss and FB2412 local-channel regression. Do not adopt this scoring or its automatic timings. Scientific outputs are preserved; no follow-on implementation is active.
