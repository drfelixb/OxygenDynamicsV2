# Recording-wide pocket pattern discovery

**Delivered and stopped, 5 November 2026.** See [findings](BOI_PATTERN_DISCOVERY_FINDINGS.md) and the linked contextual review. The approved catalogue/exploration/montage is complete; the detector prototype described in the findings is a proposal, not active implementation.

5 November 2026. Proposal following Felix's correction of the review strategy.

Felix recognizes pockets from the whole trajectory and questions repeatedly
reviewing isolated seconds to derive one universal timing rule. Stop that
frame-by-frame elicitation. Treat existing judgments as contextual examples,
including uncertain onset826–827 (not earlier) and likely end851 for FB2413
site3/event6. These remain discussion judgments, not new saved boundaries or
adopted detector parameters.

## Practical objective

Study the diversity of pocket-like and non-pocket trajectories across the saved
recordings, then make an explainable candidate model that can adapt to local
background and event shape. Do not assume one fixed pocket duration, symmetry,
baseline length or return-to-exact-level rule. Do not optimize for complete
burden totals, known experimental differences or a particular event's timing.

## Available evidence and limitation

A read-only path/size inventory confirms all 17 selected recordings have their
saved sink master, surge master and event-amplitude audit. The combined export
contains 5,407 automatic sink candidates, which are candidates rather than
5,407 established pockets. The audits contain full-recording raw/corrected
traces on saved event footprints; masters contain native frame support.

Existing saved footprints condition what can be found. Continuous traces can
reveal temporal misses or mistaken splitting at those locations. They cannot
measure sensitivity to events in spatial locations never retained by the
detector. Evaluating that requires an explicitly scoped image-stack pass.
Do not describe a saved-footprint analysis as a whole-image detector evaluation.

## Proposed first milestone

**POCKET-PATTERNS-01**, owner root without delegation. Approved by Felix on
5 November 2026: “Proceed with the recording-wide pass.” Approved scope was the
three bounded items below; five recording/animal IDs are locked before new
numerical evidence is loaded.

1. **Construct a source-bound recording-wide catalogue.** Read each of the
   17 saved audits and native masters once, retaining complete temporal context,
   recording/site/footprint identity, raw/corrected stages, missing samples and
   native support. Deduplicate overlapping examples and keep relationships
   explicit, so repeated views of one episode do not become independent cases.
   Include systematically sampled background and intervals without saved event
   labels at these footprints. Preserve signs; positive excursions remain
   context, not inverted sink labels.
2. **Explore pattern families.** Use a small prespecified set of multiscale
   trajectory representations and similarity/grouping approaches. Preserve
   physical duration, amplitude and spatial evidence alongside any normalized
   shape comparison. Examine isolated dips, repeated dips, incomplete recovery,
   monotonic background, correction disagreement, noise and recording limits.
   These are hypotheses to investigate, not imposed biological cluster labels.
   A cluster is not automatically a pocket. Retain atypical/ambiguous cases.
3. **Produce a compact contextual review and candidate strategy.** Present
   recording overviews, whole-episode exemplars, nearest contrasting examples,
   pattern variation across recordings and a small set of uncertain cases.
   Reuse already supplied recognition judgments. Ask Felix to review a compact
   montage of full episodes, not to label every second or every detection.
   Recommend a candidate detection strategy from the observed structure and
   documented failure modes; no production detector adoption in this milestone.

## Independence and validation

Before fitting or selecting representations, set aside five recordings grouped
by animal identity, retaining previously discussed examples in development.
Lock the partition and analysis choices. Use the remaining recordings for
discovery and report held-out behavior only after those choices are fixed.
Never tune against held-out results. If all recordings are later used for
exploration, call that exploratory and do not claim an independent test set.

Retain background intervals and previously rejected detections. Compare
raw/corrected patterns and saved spatial support. Check robustness to noise,
sampling, drift and reasonable representation choices; do not choose one
universal waveform by averaging unlike events. Do not train on burden values.
Detection accuracy requires independently assessed examples: unlabelled data
alone cannot establish sensitivity, specificity or biological identity. Report
the remaining spatial-selection bias and limited number of recordings.

## Outputs, resources and stop

Deliver one catalogue summary, recording overviews, one representative-pattern
montage and a concrete candidate-model recommendation with failure cases and
remaining uncertainty. Store derived material separately and preserve originals,
current detector, correction, saved scientific reviews, burden formula and
normalization. No partial sums, new cohort burden export, image-stack rerun,
replacement GUI, deployment, package or release.

Initial budget: one engineering day (six active hours), up to four bounded
MATLAB/Python analysis batches, two repair cycles and 2 GiB new derived material.
Process recordings sequentially and avoid copying movies. Estimate actual
runtime/memory from the first recording before scheduling the remaining pass;
return with a concrete checkpoint if this budget is insufficient. Stop at the
catalogue and recommendation. A trained detector implementation, image-stack
search and scientific adoption need their own reviewed impact and scope.

Deferral preserves the existing experimental preview, without more frame-level
review or changes to scientific results.
