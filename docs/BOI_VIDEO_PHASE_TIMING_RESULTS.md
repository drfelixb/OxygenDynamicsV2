# Replacement phase timing: flat troughs and asymmetric recovery

9 November 2026. The approved phase-model prototype is delivered. It represents FB2412's low floor and independent decline/rise more flexibly than the previous three-line model, but it misses the known FB2413 target under the frozen scoring. Neither recording gains an accepted duration or measurement reference. [Open the two whole-episode cards](../../reference-validation/boi-video-phase-timing-20261109/review.html).

## Implemented model

`prototypes/boi_video_detector/phase_timing.py` implements a finite-grid state graph with preceding, declining, optional low, rising and post-event phases. Each phase has independent duration; declining and rising levels can change slope. A renewed decline can interrupt a returning phase and retain linked/uncertain separation. No-added-episode alternatives allow regularized context changes or a continuing monotone trend.

The model uses 97 data-dependent levels, Huber data-fit loss, transition/change penalties and finite phase-observation minima. It is a bounded adaptation of graph-constrained changepoint ideas, not the GFPOP implementation or an established biological pocket detector. Its discrete optimum does not establish the optimum of an unrestricted continuous model. Phase cost alternatives are not calibrated confidence intervals.

The first constructed pass succeeded in 15/16 cases. A correlated-noise-only control produced two apparent episodes. Before freezing, a bounded correlation proxy was added to the noise scale. It uses first-difference correlation, capped at 0.8, to inflate the second-difference/quantization scale. It is a conservative stationary-AR proxy; real trends can affect it. The same sixteen cases then passed. The original source and failed result are preserved.

Reference characterization follows inference and uses observed 10/20-second candidates before the earliest comparable onset, with intervening episode separation respected. These are diagnostic candidates, not accepted scientific references or a new 10-versus-20-second measurement policy. Recovery-phase observation, return relative to a supported reference and scientific recovered-baseline eligibility have separate fields. Conditional dependencies and missing/motion/renewed-decline causes are explicit in the data.

## FB2413: known target remains missed

The 73-block target and 55-block earlier cohort both receive the model's no-added-episode explanation. Their window-level episode-path gains are 0.91 and 1.14, below the frozen minimum of 4. The raw and saved original-ROI traces retain the renewed dip. This is a miss on the named software example, not evidence that the pocket is absent.

For the target, the correlation proxy reaches 0.8 and raises the model scale from 15.6 to 46.9 input units. The selected context-only and unselected episode-path fits have similar costs. Those facts explain the rejection rule and suggest that the correlation/regularization treatment is too conservative for this case. The frozen pass does not isolate every assumption's causal effect; no post-freeze tuning or ablation was performed.

The selected null uses freely changing context levels and can itself follow the visible dip. It is therefore a computational context model, not an established biological no-pocket model. The present penalized comparison does not distinguish that explanation from an added episode reliably. Its winning score cannot exclude a pocket; this limitation extends beyond merely selecting a better numeric threshold.

The target associates with its frozen proposal neighbourhood in only 1/12 residual-block stress runs. That run starts at 835 and reaches a conditional post-state at 955, well beyond the discussed local episode. The earlier cohort has no association in 12 runs. These stress outcomes do not establish confidence in absence, existence or true duration.

The existing 823–825 timing cue, prior 826–827 onset judgment and approximate endpoint near 851 remain post-inference annotations. The scientific measurement baseline remains unresolved. The previously unsupported regional decomposition remains unsupported, with no inferred local return substituted for it.

## FB2412: flat low phase captured, complete timing unresolved

| Fixed channel | Best onset and comparable paths | Fitted low phase / rise | Post-state interpretation |
| --- | --- | --- | --- |
| Core raw, 125 blocks | 116; alternatives 116–120 | Low 147–168; rise from 169 | Interrupted by renewed decline before a separated post-state. Reference unavailable; no accepted endpoint. |
| Qualified additional local component of the same core | 116; alternatives 116–118 | Low 133–168; rise from 169 | Also interrupted before separated post-state. Reference unavailable. |
| Wider raw, 2,024 blocks | 114; alternatives 114–123 | Low 147–171; rise from 172 | Post-state from 183, explicitly conditional on unresolved onset/reference evidence. |

An initial rising phase connects into the decline without adequate intervening separation. The model consequently supplies no supported common preceding reference for these matched episodes. This qualification belongs to the diagnostic phase path and does not invalidate the accepted original-ROI reference.

The core and wider associations persist in 12/12 stress runs; the local association persists in 11/12. Core stress onsets span 110–116. Eight core stress returns remain interrupted; four reach conditional post-states at 185–188. Wider stress onsets span 110–120; ten reach conditional post-states at 179–184 and two remain interrupted. All eleven associated local stress runs remain interrupted. These spans are perturbation results, not confidence intervals or new acquisitions.

The low floor and asymmetric phases are represented without forcing a single triangular fit. Their exact labels and boundary ranges remain model-dependent. Original-ROI onset 114, recovery 182 and baseline 104–113 remain unchanged. The core's 125 diagnostic blocks and the native 2,511-pixel reviewed footprint remain different supports. Patch 82 keeps its responding-regional role; its fitted temporal dip is not promoted into a localized pocket.

## Verification, scope and repairs

The sixteen named fixtures cover asymmetric slopes, flat/rounded floors, linked/separated lows, preceding recovery, no-added-event controls, correlated noise, a regional/local return difference, left/right censoring and an internal missing/motion span. Each has an independent tiny finite-grid recurrence check. Their passing behaviour does not establish biological validity or representative detection performance.

One configuration was frozen before all nine fits to saved signals and sixty predeclared residual-block stress fits. The same four diagnostic cohorts and four saved comparison patches were used; no other recording, patch, spatial proposal or regional model was introduced. Original-ROI raw/corrected traces are display-only and existing videos are reused.

Independent checks match all nine saved signal identities, five full graph/null solutions and their 14,076 cost-profile points, and 48,362 chosen graph transitions across the 69 results. Sixty perturbation inputs are regenerated from the declared rule and hashes. All twelve core raw/local index sequences align. Sixty-one diagnostic reference candidates have their source ranges and summary values replayed. Conditional/censoring contracts and source invalid-sample causes are checked. [Verification receipt](../../reference-validation/boi-video-phase-timing-20261109/verification.json).

Two approved engineering repairs were used. The first changed the noise treatment before freezing. The second corrected arithmetic grouping in the independent perturbation generator: an exact grid comparison had differed by at most 2.2737367544323206e-13. That checker correction changes no model code, parameter or fitted output. All 69 saved fit files match exact hashes recorded before the correction. Initial failures remain recorded. A label-position adjustment during figure preparation changes presentation only; the initial figure and all model outputs are preserved.

The work uses four batches, one configuration, sixteen unique constructed fixtures and exactly 69 recording-based fits. Peak recorded worker memory is about 238 MiB, below 2 GiB; derived evidence remains below 256 MiB. Final preservation covers 1,425 protected files, including four original movie files. The full 72,732-hypothesis catalogue and 17-recording batch were not refitted. No new movie decoding, pixel analysis, dependency installation or production-language change occurred.

## Assessment and protected measurements

Retain the flexible phase representation, explicit conditional return contract and observed-support cause propagation as useful design elements. Do not adopt this frozen scoring as the production timing model. The FB2413 miss and FB2412 reference/separation problems remain material failures. Window-level gain is not per-pocket significance; a finite-grid cost range can still be precise under incorrect assumptions. The correlation proxy may absorb genuine dynamics, and these familiar cases supply no independent sensitivity/specificity estimate.

The burden formula, normalization, strict complete-burden missingness rule, spatial masks, tissue-support qualification, comparator roles, regional components, original recordings, accepted references, automatic/reviewed measurements, export formats and production MATLAB workflow are unchanged. Diagnostic phase contrasts are not scientific amplitude measurements. No event area, amplitude reference, burden contribution, partial sum, recording burden, GUI integration, Git transport or publication was produced.

The bounded experiment is delivered and stopped, including its negative results. Further calibration, model replacement, independent validation or batch adoption requires a separate agreed scope. The two cards provide the evidence for that decision without another frame-by-frame labelling exercise.
