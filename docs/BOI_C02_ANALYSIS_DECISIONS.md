# C02: proposed analysis decisions

21 September 2026 · R4-C02-CONSOLIDATION-119 · **Proposed, not researcher-approved.**

This is a finite decision sheet for the seven completed awake/isoflurane pairs.
It carries forward the measurement hierarchy in working specification 089;
the observed direction of these results is not a reason to select an outcome.
It does not reopen the accepted working detector or correction.

## Recommended descriptive analysis package

| Decision | Concrete proposal | Rationale and limitation |
|---|---|---|
| Comparison | Retain all seven candidate pairs: FB2312, FB2314, FB2315, ID400–ID403, one recording per state per mouse. | All fourteen recordings have verified current-method runs and accepted working tissue support. This proposes measurement-specific admission; run completion alone does not constitute final scientific inclusion. |
| Main sink outputs | Keep occupied tissue fraction (M01) and detected onset rate (M02) as the two candidate primary outputs. | Coverage addresses tissue involvement; onset rate addresses frequency. Neither substitutes for the other. Final confirmatory status and any multiplicity rule remain open. |
| Observation window | Use each full stored recording: frames 1–1200 for FB mice and 1–600 for ID mice, with paired equal duration within mouse at exact 1 Hz. | Uses measured exposure without inventing stabilization periods. Report duration and effective sign-specific tissue-time. Unequal duration across mice and possible time trends remain limitations; normalization does not make them disappear. No common ten-minute trimming or additional sensitivity run is authorized by this proposal. |
| Pairing and weighting | Compute isoflurane minus awake for each mouse and metric. Display every pair, then use the equal-mouse mean of those paired differences as the descriptive cohort contrast. | Each mouse contributes once. Do not pool events, weight by event count, or replace a missing pair with an unpaired state value. No group mean has been added in phase 119 while this choice is pending. |
| Onsets at the first frame | Retain them in the current **detected onset** rate, with their counts shown separately. | A detected beginning at frame 1 need not be a physiological onset inside the recording. A claim about incident physiological onset requires a separately approved boundary rule; that question remains open. |
| Companion outputs | Report concurrent event density, saved duration and mean native event area; retain separate surge coverage/rate and other surge summaries as secondary descriptive outputs. | Both signs stay visible. Preserve source-local event/site history. Do not equate duration with physiological recovery or event area with the fixed optical footprint. |
| Optical outcomes | Report amplitude and signed integral only for their finite subsets, with finite/total counts, negative values and unavailable reasons by mouse/state/sign. | No imputation, alternative reference search or amplitude-based removal from coverage/rates. All sink composites are currently unavailable and remain so; no surge composite is defined. |
| Permitted interpretation | Describe within-mouse differences associated with the recorded state, conditional on this detection method and its support. | Awake-first order, unmeasured pre-recording transition, exposure/preprocessing unknowns, uncertain ROI boundaries, acquisition-scale differences and publication/development use remain explicit. No isolated causal anesthesia effect, pO2, oxygen debt or detection-accuracy claim. |

## Statistical decisions that remain separate

The proposed equal-mouse mean defines a descriptive contrast, not a completed
inferential analysis plan. No p-values, confidence intervals, significance labels
or resampling claims are produced here. Before inferential reporting, decide:

1. Whether C02 is intended for descriptive reporting only or inferential claims
   within this already publication/development-exposed reanalysis.
2. If inferential reporting is intended, the uncertainty method and its
   assumptions for seven paired animals, the hypothesis family and multiplicity
   treatment across the two candidate sink outcomes and intended comparisons.
3. Whether the full-recording detected-onset estimand is the intended scientific
   target, or whether a different window/boundary estimand is required. Any change
   must have a scientific rationale, preserve the current results and avoid
   selection for a preferred direction.

Do not label a decision made after viewing these data as prospective or untouched
validation. The FB/ID acquisition split is context to show, not a newly proven
biological subgroup or an invitation to optimize settings independently.

## Bounded next work after a decision

If the descriptive package is accepted, record that acceptance explicitly, add
the equal-mouse contrasts and a paired results figure, and draft the C02 methods
and limitations from the existing verified exports. If only windows or an onset
boundary rule change, recalculate the affected summaries from saved ingredients
and preserve both versions; do not rerun detection without a demonstrated need.

The wider BOI project still needs decisions for the other comparison families,
the independent researcher workflow/numerical replay, and the final versioned
freeze and release. Those are separate from this completed C02 consolidation.

[Seven-mouse overview](BOI_C02_MOUSE_SUMMARY.md).
