# Cohort reanalysis update round

Date: 10 September 2026

Status: Scope and direction agreed in planning discussion. The user has
authorized resolution of the identified issues. Scientific acceptance thresholds
and final cohort eligibility remain open; this document does not declare
validation complete.

## Agreed objective

Complete a defensible reanalysis of the present cohort using frozen methods,
reproducible outputs, and documented limitations. Demonstrate that representative,
comparable local recordings outside DANDI can enter and run through the same
pipeline with interpretable outputs.

This round is BOI-only. IOSI recordings are excluded from cohort reanalysis,
validation, method comparisons, and release requirements. No IOSI analysis or
calibration work is required to complete this round. The same BOI-only boundary
applies to transfer checks on older and future local acquisitions. Separately
labelled fluorescence controls may support BOI artifact assessment; they are
never pooled as BOI biological observations.

The present cohort is the release target. Older and future acquisitions are an
explicit design consideration. They are expected to be similar, but similarity
in intensity preparation, pixel size, timing, motion correction, tissue coverage,
and experimental metadata must be checked rather than inferred from appearance.
DANDI is an input source, not a scientific assumption of the pipeline.

The product remains MATLAB software for researchers. Simple use, understandable
calculations, and complete result traceability are standing requirements for
this round, including batch runs. They must shape implementation now; visual
polish can follow later. The [researcher workflow and traceability contract](RESEARCHER_WORKFLOW_AND_TRACEABILITY.md)
defines the required evidence and the work that is still to be implemented.

## Standing boundaries

Craniotomy support clarification (12 September 2026): the user states that the
relevant BOI signal is limited to the craniotomy, which can be smaller than the
camera field. Define the anatomical analysis field for each recording from that
preparation, preserve internal dark tissue and source coordinates, and retain
boundary uncertainty. Automatic image support is not an anatomical craniotomy
mask. [R1-C02-CRANIOTOMY-030](reference-results/boi-c02-craniotomy-20260912/README.md)
checks actual saved events against an unchanged prior outline. The principle
is established; exact ROI vertices and boundary-crossing/normalization rules
remain explicit decisions rather than silently adopted defaults.

1. Preserve biological variability. Challenge weak and strong, brief and
   sustained, irregular, recurrent, overlapping, and spatially changing signals.
   Report performance by animal and acquisition stratum. Unusual morphology or
   timing alone is not sufficient evidence for exclusion.
2. Justify physiological assumptions. Record the rationale and evidence for
   spatial/temporal scales and exclusions. Historical event counts and expected
   treatment effects are never tuning targets. Proposed biological ranges are
   revisable assumptions, not immutable facts.
3. Respect measurement limits. Distinguish relative optical signal, detected
   events, projected area, and composites. Oxygen concentration, depth, and
   measured volume claims require additional validated evidence.
4. Preserve quantitative meaning. Keep quantitative sources distinct from
   detection preprocessing. Record baseline definitions, masks, physical units,
   valid exposure, and missingness. Do not silently move a baseline or alter a
   signal to obtain an expected direction.
5. Retain uncertainty. Valid zeros, failed recordings, ambiguous events, missing
   clean context, and unavailable measurements are separate outcomes. Report
   measurement availability alongside summaries.
6. Protect evaluation independence. Track development use by recording and
   animal. Inspected data cannot later be described as untouched evaluation.
   Synthetic recovery and numerical correctness do not establish biological
   detection accuracy. Report gains and losses together.
7. Make feasibility explicit. Set practical limits for runtime, memory, manual
   review, calibration needs, and experimental iterations before major work.
8. Investigate acquisition differences before tuning. Different results may
   reflect acquisition, preprocessing, measurement failure, or biological
   variability. Any acquisition-specific adjustment needs a rationale and
   validation, rather than merely improving agreement.
9. Make results explainable and traceable. A researcher must be able to follow
   a reported value back to its source recording, selected frames/tissue,
   calculation, settings, software version, and automatic or manual decisions.
   Retain original metadata alongside corrections, evidence and reasons. A
   technical log alone is insufficient: show plain-language explanations,
   units, limitations and an inspectable calculation. Unavailable values must
   explain why they are unavailable.

Enforce arithmetic, identity, provenance, and exposure invariants with automated
checks where practical. Review physiological relevance, biological coverage,
interpretation, and feasibility using a scientific checklist and an assumption
register. Changes to standing boundaries need an explicit decision and impact
assessment; they must not occur incidentally during implementation.

## Agreed scientific priorities after source reading

The Science paper, its supplement, and the detailed STAR Protocols method were
read during planning. The author's opinion draft provided further conceptual
background; its proposed mechanisms and future predictions are not validation
targets or established properties of this cohort. Primary versus secondary
outcome selection remains open.

The analysis should preserve local event history, spatial coverage, and recovery
alongside recording-level summaries. A single event count or composite cannot
represent all of these dimensions.

| Biological question | Measurements to preserve and assess |
|---|---|
| How much tissue is affected over time? | Instantaneous occupied tissue fraction and its time average, using valid observable tissue and native mask unions. |
| How often do events arise and how long do they persist? | Onset rate, concurrent-event density, duration, and boundary uncertainty as distinct quantities. |
| How pronounced is each event? | Relative optical amplitude, signed trace integral, baseline quality, and measurement availability. |
| Does activity repeatedly concentrate at particular locations? | Site membership and ambiguity, recurrence intervals, local event history, recovery between events, and observation coverage. |
| How do local events relate to experimental state? | Explicit experimental windows, preserved broader signal changes, and within-animal comparisons where the design supports them. |
| What does combined burden represent? | An explicitly defined composite accompanied by its components and availability; biological harm is not established by a composite value alone. |

Recurring sites are recording-local projected locations unless registration and
additional evidence support stronger anatomical correspondence. Recurrence
intervals and recovery estimates must account for truncation, observation length,
and unresolved event separation. These priorities do not commit to a new
mechanistic model or an unbounded search for precise event boundaries.

Positive signals remain in scope. Distinguish spontaneous positive events,
recovery from a preceding sink, and stimulus-associated or widespread increases
where evidence permits. Positive direction alone cannot identify the mechanism;
uncertain classification remains visible. Opposite signs must not be collapsed
into a net burden that conceals their separate contributions.

The original size, circularity, and duration filters were empirical. Published
event distributions therefore describe observations conditional on the method,
not immutable biological limits. Validation should include realistic examples
both within and beyond the original selection boundaries.

References: Beinlich et al., Science (2024),
[main paper and supplement](https://doi.org/10.1126/science.adn1011);
Asiminas et al., STAR Protocols (2024),
[detailed method](https://doi.org/10.1016/j.xpro.2024.103334).
This source reading is scientific context, not a fresh pipeline validation.

## Proposed work packages

| ID | Scope | Completion evidence |
|---|---|---|
| R0 | Scientific scope and outcomes: identify the cohort, biological questions, primary versus exploratory outputs, and permitted claims. | Cohort manifest and measurement dictionary with purpose, units, and interpretation limits. |
| R1 | Acquisition and signal validity: metadata, intensity preparation, tissue eligibility, motion/borders, physical sampling and smoothing, global responses; common internal input contract for DANDI and local data. | Supported acquisition range, entry checks, provenance limitations, and explicit comparison restrictions. |
| R2 | Event detection and measurement for both signs: identity, recurrence, onset/recovery, footprint, baseline, amplitude, sustained activity, and unresolved outcomes. | Coherent frozen rules selected through bounded comparisons, with known failure modes. |
| R3 | Variability and robustness: fixed challenges across signal families, backgrounds, acquisition settings, noise, drift, and event density; small representative local-recording check. | Stratified recovery, error, availability, and instability results against prespecified criteria; explicit development/evaluation roles. |
| R4 | Statistics: appropriate sink/surge coverage, experimental baselines, repeated recordings, animal-level inference, exclusions, and condition-dependent missingness. | Prespecified analysis for each primary comparison with auditable denominators. |
| R5 | MATLAB researcher workflow: guided import/review/run/inspect/export, plain-language calculation explanations, trace/mask inspection, recorded decisions, batch summaries, output naming, and resource use. | A researcher can run, inspect, explain and reproduce a result without reconstructing development history; complete the traceability walkthrough in the linked contract. |
| R6 | Freeze and reanalysis: code, settings, environment, inputs, curation, complete eligible cohort rerun, and methods/limitations record. | Reproducible final outputs and a closed list of accepted limitations. |

Dependency order: R0, then R1/R2, then R3 and final R4, then R6. R4 planning
starts early so biological questions inform measurement choices. R5 develops
alongside the scientific work. R3 challenge design precedes evaluation and
relevant tuning. Exact task boundaries and numerical acceptance criteria remain
to be agreed.

## Comparable recordings outside DANDI

Use one internal recording contract and the same scientific pipeline. Do not
derive biological condition from archive-specific filenames or identifiers.
Include a small selection of representative older local recordings before
release, covering the principal acquisition variants where available. This is
a transfer check, not a commitment to a second complete cohort study or proof
of broad generalization.

Future recordings pass the same entry checks and recording-level QC. A material
departure from the supported acquisition range triggers a focused assessment;
future data cannot be validated in advance.

The acquisition inventory should also record substrate identity and time since
application, exposure duration separately from frame interval, and available
preparation/QC information. Missing historical metadata remains explicitly
unknown; its effect on eligibility is assessed for each intended measurement.

## Alternative detector

Proposed role: retain the separate event-first prototype as a bounded comparison
option. It is not a prerequisite for this release. Replacement of the main
detector requires a distinct evidence-based decision considering benefit,
calibration effort, and feasibility. Do not mix its outputs with the main path.

## Experiment and stopping rules

Before each experiment, record:

- The decision it will inform and its dependency on a primary outcome.
- Frozen cases, denominators, metrics, and development/evaluation roles.
- What counts as improvement and unacceptable regression.
- Effort/iteration budget and stopping point.
- The consequence of an inconclusive result.

Close each experiment with adopt, retain current rule, restrict claim/output,
or defer. Inconclusive evidence does not automatically launch another method.
An unresolved essential validity issue can block the affected output; it need
not keep unrelated work open. A primary outcome cannot be silently demoted to
make a release pass: any scope revision must be explicit.

Maintain stable work-package IDs, decision records, a concise current-status
record, and links to detailed evidence. Preserve unsuccessful experiments as
history without treating each report's next suggestion as a standing mandate.

## Proposed outcome hierarchy

This hierarchy is a planning proposal, not a frozen statistical analysis plan.
All measurements remain conditional on the detector's validated operating range.

| Tier | Outcome | Definition and admission requirement |
|---|---|---|
| Candidate primary | Mean occupied tissue fraction for sinks | Integral of eligible native sink-mask union area over time divided by valid tissue-time. Measures detected spatial coverage; not absolute hypoxic volume. Verify tissue eligibility, overlap handling, and threshold sensitivity. |
| Candidate primary | Sink onset rate | New event onsets per mm2 per minute of valid exposure. Requires defensible event identity and split/merge rules; ongoing events at a window start are not new onsets. |
| Required companion | Mean concurrent sink-event density | Active event-time divided by valid tissue-time, in events/mm2. Distinct from onset rate and sensitive to event separation. |
| Secondary explanatory | Event duration, projected area, relative amplitude, and signed trace integral | Retain distributions and animal-level summaries, baseline availability, timing uncertainty, and truncation. No silent complete-case interpretation. |
| Secondary explanatory | Recurrence, local event history, and recovery | Preserve site uncertainty and censoring. Numerical recovery definitions and minimum observation support must be specified before confirmatory use. |
| Secondary composite | Amplitude-area-duration burden | Export explicit units and component definitions, distinguish fractions from percentages, and report unavailable contributions. It is not a validated damage score or measured oxygen-deficit integral. |
| Comparison-specific | Experimental response and positive dynamics | Preserve global/ROI responses and positive-event measures separately. Their priority depends on the biological comparison; e.g. a calibration or evoked-response analysis need not use pocket coverage as its primary outcome. |
| Exploratory | Spatial heterogeneity, vascular association, and cross-sign temporal relationships | Require clearly defined support, appropriate spatial/temporal nulls, and available auxiliary data. No mechanistic or anatomical identity is inferred from correlation alone. |

The proposed pair of primary outcomes distinguishes affected tissue from new
event occurrence. Neither can substitute for the other. Occupied area can remain
stable when tracking splits one region into several events, while counts can
fall when regions merge. Validation must report both types of behavior. If onset
identity is insufficiently supported, the primary-outcome proposal must be
explicitly revised before final biological evaluation, not rescued by tuning
toward expected group differences.

Use animals as biological replication units. Specify repeated recording, event,
site, and time dependencies per comparison; do not count frames or events as
independent animals. Choose models for the actual outcome distribution, pairing,
and exposure rather than automatically applying one model to every output.
Prespecify contrasts and multiple-comparison handling, and report effect sizes,
uncertainty, and per-metric animal counts.

## Present archive: comparison candidates and eligibility

The [recording-level cohort and comparison proposal](BOI_COHORT_COMPARISONS.md)
now assigns all 87 archive assets, lists 21 candidate recording pairs, separates
description-level timing from approved windows, and records unresolved issues.
Its [planning ledger](planning/boi-cohort-20260910.json) preserves source IDs and
evidence. Neither document is an executable batch or a final cohort freeze.

The subsequent [issue-resolution record](BOI_COHORT_RESOLUTION.md) is the current
source for corrections and remaining holds. It documents the confirmed 4 µm
microspheres, distinct FB2314/FB2315 local files, supported baseline mapping for
four held animals, recovered KX puff timing and located external acquisitions.
The original source manifest remains intact; the resolution overlay must be
consulted when preparing the final executable cohort.

Planning inventory checked against the existing local metadata reconciliation
manifest on 10 September 2026. Counts below describe metadata, not final QC
eligibility, independent validation, or statistical power. They are not additive
animal counts because some animals contribute to multiple experiments.

| Candidate family | Available inventory | Intended role and prerequisites |
|---|---|---|
| KX, awake immobile, awake mobile | 9 KX baseline, 7 resolved awake-immobile baseline, 10 awake-mobile recordings | Characterize state-associated pocket coverage and occurrence. Group preparation/acquisition differences must be assessed; this is not a uniformly paired design. Four unresolved records must not be added merely to reproduce paper sample sizes. |
| Awake versus isoflurane | 7 recordings per state with the same 7 mouse IDs | Candidate within-mouse contrast. Verify session order, matching, exposure, and preparation; pairing does not remove order effects. |
| Whisker responses, awake versus KX | 8 recordings per state with the same 8 mouse IDs | Candidate paired evoked-response analysis. Verify stimulation timing, synchronization, and trial structure before constructing windows. |
| KX 30-second whisker stimulation | 6 recordings from 6 mice | Candidate within-recording stimulation comparison, with separate baseline recordings also inventoried. Keep distinct from the other stimulation protocol. |
| Hypercapnia and hyperoxia | 6 and 5 recordings respectively | Candidate baseline/intervention/recovery comparisons where supported. All six hypercapnia and four hyperoxia descriptions state intervals; FB2360-Hyperoxia does not. These are evidence to reconcile per recording, not approved windows. Two mouse IDs occur in both groups. |
| Microsphere-associated BOI | 5 recordings | Candidate coverage, size, and event-identity challenge and biological comparison. Define compatible controls and channel alignment; do not assume more obstruction must yield more detected events. |
| Oxygen calibration | 7 recordings from 6 mice | Separate method-response analysis requiring electrode alignment and suitable reference windows; not interchangeable spontaneous-event observations. |
| Other/control acquisitions | 1 fluorescence control, 1 expression-labelled dual-series recording | Potential BOI method/support roles; no automatic pooling with the biological cohort. Resolve the expression-labelled recording's role explicitly. |
| Excluded from this round | 3 IOSI recordings | Out of scope by user decision; no analysis, validation, or release dependency. |

The manifest contains 87 assets: 83 with consistent reconciled metadata and four
unresolved mappings (F120, F134, F136, M189). This does not imply 83 eligible BOI
recordings. In particular, FB2328, FB2361, and FB2362 have generic BOI reference
labels but their NWB session descriptions identify IOSI, and their selected series
names specify 525 nm imaging. These three recordings are explicitly excluded
from this round: FB2328, FB2361, and FB2362. Their generic reference labels must
not cause inclusion in a BOI batch. This scope exclusion resolves their role for
the current plan; broader IOSI classification or method work is deferred. The
source reconciliation manifest is left unchanged during this planning step.

## Proposed release gates and bounded validation

1. Freeze a manifest identifying inclusion, exclusion, unresolved status,
   modality, comparison role, pairing, and development/evaluation use. Metadata
   resolution and signal eligibility remain separate checks.
2. Freeze definitions for the selected primary outcomes and the minimum
   companion measurements needed to interpret them. Record limits for any
   secondary output that remains unreliable.
3. Complete a fixed challenge matrix covering both signs, weak/strong and
   brief/sustained signals, expanding/shrinking shapes, recurrence, contact,
   drift, noise, acquisition scaling, and global changes. Start with existing
   evidence; add cases only to address a specified coverage gap.
4. Separate detection recovery from measurement accuracy on known support.
   Test both end-to-end performance and exact arithmetic. Report errors and
   unavailable fractions by stratum, including changed event identities.
5. Prespecify numerical tolerance and acceptable regression for each outcome
   after examining measurement resolution and pilot feasibility, but before
   evaluating held-out cases. No invented universal accuracy target is adopted
   here, and pilot data cannot be relabelled as independent evaluation.
6. Permit one planned candidate comparison and one bounded corrective round
   per defined issue as an initial effort-budget proposal. Further iterations
   require a recorded decision identifying the primary-outcome risk, expected
   information gain, and revised budget. This iteration limit remains proposed.
7. Demonstrate the same pipeline on representative comparable local recordings
   and measure runtime, memory, storage, and review effort on a representative
   full-length input. Agree resource limits before expensive cohort reruns.
8. Freeze the release and rerun the eligible cohort with complete QC, exclusions,
   provenance, and analysis outputs. Do not claim biological detection accuracy
   from synthetic recovery alone, or broader acquisition validity from a small
   transfer check.
9. Complete a researcher walkthrough in MATLAB: import an eligible recording,
   understand its QC decisions, run it, inspect an event and a summary value,
   explain their calculation, and export their provenance. Reproduce one value
   from exported ingredients and demonstrate that a changed setting or manual
   decision remains visible in a separate, comparable run. GUI and batch paths
   must use the same calculations and resolved settings. This gate cannot be
   deferred with cosmetic UI work.

Current surge experiments should be assessed against these gates rather than
treated as an indefinite sequence. A measurement that cannot be justified may
remain unavailable with a stated scope restriction; essential validity failures
cannot be waived solely to finish the round.

## Next planning decisions

1. Identify the exact present cohort and intended biological comparisons.
2. Choose primary, secondary, and exploratory measurements.
3. Inventory available local recordings and acquisition variants for transfer
   checks; establish evaluation roles before inspecting outcomes.
4. Set feasible validation and resource budgets, then acceptance criteria.
5. Reconcile ongoing surge experiments with R2 and decide which are necessary
   to reach its stopping point.

## Existing evidence

This plan complements [publication readiness](PUBLICATION_READINESS.md) and
[existing-analysis corrections](EXISTING_ANALYSIS_CORRECTIONS.md). Those files
describe implementation and evidence; their historical next-step suggestions
must be reconciled with the bounded work packages before implementation begins.
The alternative prototype's report is maintained in the separate event-first
worktree. No fresh validation was performed to create this planning document.
