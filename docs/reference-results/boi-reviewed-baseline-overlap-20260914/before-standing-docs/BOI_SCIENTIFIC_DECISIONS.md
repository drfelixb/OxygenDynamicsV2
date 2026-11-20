# Scientific decisions remaining after workflow implementation

12 September 2026. This is a decision queue, not scientific sign-off. The
[reanalysis plan](REANALYSIS_UPDATE_PLAN.md), [cohort resolution](BOI_COHORT_RESOLUTION.md)
and original evidence remain authoritative. Confirmed HP external **1 Hz** timing
is resolved; its incorrect embedded clocks are not a remaining timing hold.
Camera exposure remains separate. AQuA2 exploration is not anatomical evidence.

| Decision | What is established | What remains necessary |
|---|---|---|
| Comparison priority (R0/R4) | C01 state association, C02 paired awake–isoflurane and response families are proposed separately. | Researcher preference was requested. No priority has been inferred from silence or from observed outcomes. |
| Outcome admission (R0/R2) | Occupancy, onset rate, concurrency, amplitude, signed integral and composites have distinct definitions. | Freeze primary/secondary roles and claim limits; the dictionary hierarchy remains a proposal. |
| Observable tissue and acquisition (R1) | Source/support inspection and source-bound reviewed-mask declarations work. HP references/AQuA2 did not establish a valid anatomical mask. | Resolve relevant identity, calibration, preparation and anatomical/dynamic support with experimental evidence. A technically readable file is not eligible tissue. |
| Amplitude missingness (R2/R4) | The [saved-support audit](reference-results/boi-measurement-support-20260912/README.md) quantifies the coverage missing from finite-amplitude subsets in two development recordings. | Choose a scientifically justified baseline/missingness policy before interpreting amplitude/composite comparisons. Do not shorten a baseline merely to increase availability or substitute amplitude-complete coverage for all detections. |
| Onset, duration and recovery (R2) | Native and measurement intervals, boundary contacts and recurrent-site history are separately saved. Sink measurement intervals often extend beyond native runs. | Establish physiological onset/recovery and censoring policies. Neither a trace-refined boundary nor absence of native mask is itself proof of recovery. |
| Independent evaluation and variability (R3) | The [prior-use audit](BOI_PRIOR_USE_AUDIT.md) identifies five analytically used BOI animals, a separate fluorescence control and the identity-pending HP development recording; C02 source-inspection histories are distinguished. | Reconcile use outside the searched workspace, then freeze animal roles, acquisition strata, challenge families and acceptance criteria. No untouched role has been assigned. |
| Biological replication and models (R4) | Recording/event/frame denominators are distinguishable; comparison-specific pairing and confounds are documented. | Specify animal-level repeated-measures handling, exposure/weighting, missingness and contrasts after choosing the scientific comparison. No pooling of these two examples supplies that plan. |
| Researcher release (R5) | The connected MATLAB implementation and developer walkthrough are complete. | An independent researcher, second-person replay and an eligible recording are still required by the original contract. Use the [handoff](BOI_RESEARCHER_WALKTHROUGH.md). |
| Freeze and cohort rerun (R6) | Historical results, failed attempts and correction records are preserved. | Close the dependent scientific/evaluation/usability gates before release freeze and eligible-cohort execution. |

The [measurement-policy proposal](BOI_MEASUREMENT_POLICY_PROPOSAL.md)
(R0-R2-R4-POLICY-015) now makes five review positions concrete: optical reference,
missingness, timing, outcome admission and a worked C02 paired contrast. Its
seven-pair ledger applies current issue resolutions, preserves known development
animals and leaves eligibility/evaluation roles unapproved. C02 follows the
plan's proposed preparation order; final researcher priority is still unset.

The fixed [baseline/timing challenge](reference-results/boi-baseline-timing-20260912/README.md)
is complete. All 34 amplitude and 10 timing cases matched current-rule analytic
expectations, with 23 existing regression tests passing. Unmarked precursors,
background changes and moving footprints still separate measured optical peaks
from the imposed component. Missing context remains unavailable, and numerical
timing resolution does not establish physiological recovery.

The next scientific decision is to accept or revise the proposal's intended
amplitude reference, missingness handling and permissible timing claims for the
chosen comparison. Each reviewer decision is explicitly unfilled.
Any proposed replacement rule needs its own bounded comparison with explicit
gains/losses before adoption. Current rules and proposed outcome priorities are
retained. No new detector, broad search, untouched cohort evaluation or automatic
follow-on method experiment is implied by this completed challenge.

The existing-evidence audit is now complete as R3-PRIOR-USE-016. Its
[animal and acquisition ledgers](BOI_PRIOR_USE_AUDIT.md) preserve analytical,
source-only and metadata-only histories. ID13/FB2316's historical additional
onset-panel role does not establish untouched animals; the event-first prototype
also used ID400. Remaining independence decisions need outside-workspace history
and explicit scientific role assignment before new evaluation outcomes are read.

The [evaluation-freeze preparation](BOI_EVALUATION_FREEZE.md) now contains the
seven C02 pairs, documented development roles and explicit outside-history fields
for FB2314, FB2315, ID402 and ID403. The researcher has been asked about original
analysis, later V2/AQuA2 setting selection and event/outcome inspection outside
this workspace. Responses, final roles and all freeze decisions remain unfilled.

The user subsequently confirmed that the questioned archive files belong to the
Science publication. All eight sessions are present in the pinned DANDI ledger;
[the publication-history overlay](planning/boi-publication-history-20260912.json)
resolves original-publication membership for FB2314, FB2315, ID402 and ID403.
Treat these as published-data reanalysis candidates. Publication history is not
automatic exclusion or evidence of later tuning in this reanalysis; those claims
remain distinct. Existing role/eligibility decisions are unchanged.

[R1-C02-INPUT-019](reference-results/boi-c02-input-20260912/README.md) completes
technical preflight for these eight local sources and inventories 24 external
legacy MAT outputs. The two acquisition strata retain 1,200-frame/16-bit/2.35 µm
and 600-frame/8-bit/4.75 µm source properties, all at the confirmed 1 Hz. Archive
name/shape/metadata correspondence is checked; whole-pixel equivalence and
pre-source intensity history remain open. Missing sidecars are not proof of
missing historical evidence. Next R1 work should trace conversion/preparation
and resolve tissue, valid time and window requirements per intended measurement.
The input audit changes no scientific policy, outcome role or evaluation approval.

The subsequent [R1-C02-PROVENANCE-020](reference-results/boi-c02-provenance-20260912/README.md)
resolves whole-pixel local-to-archive equivalence for these eight sources under
the explicit spatial mapping used by the current MATLAB importer. All archive
checksums and independent comparisons pass; there is no intensity change from
the preserved local TIFF to its archived array. Pre-TIFF preparation remains
unknown. R1 can now concentrate on observable tissue, dynamic frame validity,
exposure and experimental alignment/windows for the affected measurements.
These are published-data reanalysis candidates; prior use remains distinct from
scientific eligibility and does not automatically exclude them.

[R1-C02-OBSERVABILITY-021](reference-results/boi-c02-observability-20260912/README.md)
now provides per-recording source sheets, full-frame diagnostic timelines and
unfilled support/frame/window review decisions. The scan found no blank,
constant or exact adjacent-repeat frames; these checks do not establish motion
or tissue validity. Changing dark regions remain signal/support questions, not
automatic mask holes. Stored-class ceiling values are not proven camera saturation.
The remaining concrete inputs are a justified observable-support decision,
temporal validity evidence and experimental stabilization/alignment for windows.
The user's precise 1 Hz correction remains resolved; no flat-looking interval or
20-second event baseline has been promoted to an experimental analysis window.

**Context correction:** [R1-C02-CONTEXT-022](BOI_C02_EXPERIMENTAL_CONTEXT.md)
checks the exact mice against Figure 4/S13 and records the researcher's explicit
clarification: for the separate-state files, state establishment preceded
recording and was unmeasured. Recovering a numerical stabilization period or
locating an induction baseline inside these recordings is no longer a requirement
for the C02 state comparison. Leave the duration unmeasured, retain order and
preparation limits, and do not claim induction kinetics. Actual observable
support, frame validity and analysis exposure remain measurement decisions.

[R1-C02-SUPPORT-023](reference-results/boi-c02-support-20260912/README.md) makes
the current default support decision concrete for the eight additional C02
sources. Its approximately 70% selected image fraction is imposed by a temporal
occupancy percentile, not anatomical validation. Reviewed source overlays show
peripheral inclusion and internal gaps. Do not infer non-tissue from changing
BOI darkness, or tune the percentile to an expected treatment effect. Justified
outer-field support, internal exclusions and temporal validity remain scientific
decisions; no replacement support is adopted by this audit.

The sign-specific 20-pixel sink crop has different physical widths across the
two acquisition scales (47 versus 95 µm). Preserve its denominator and geometry
consequences until a justified rule change is recorded. The four awake/iso pairs
already match nominal observation duration within mouse; between-mouse duration
differences do not themselves require trimming. Animal weighting, any common-
duration sensitivity design and actual analysis exposure remain explicit choices.
The calculation audit passes; it supplies evidence without closing these questions.

[R1-C02-OUTLINE-024](reference-results/boi-c02-outline-proposals-20260912/README.md)
now supplies actual draft outer-field polygons for all eight recently audited
sources. Native coordinates, specifically uncertain segments and source/mask
hashes make the proposed choices reviewable. No internal dark-region holes were
introduced. Draft areas can increase or decrease relative to the automatic mask;
neither direction is an acceptance criterion, and old event numerators cannot
be combined with these proposed denominators as though support had no effect on
candidate admission. All ID402 iso perimeter segments have weak evidence; a
source/preparation/reference-based boundary decision is still needed. No mask is
adopted, no scientific role assigned, and no temporal validity or window is
established by a static polygon or a passing arithmetic check.

[R1-C02-TEMPORAL-025](reference-results/boi-c02-temporal-20260912/README.md)
adds all-frame apparent translation and projected-intensity evidence for the
eight C02 sources. Explicit gradient-correlation estimates are diagnostic
corrections, not independently measured movement. Larger awake ID402/ID403
estimates coincide with low peak scores; no numerical cutoff becomes a validity
rule. Biological intensity-pattern changes remain a competing explanation.
All-frame numerical checks and selected-source visual review do not certify
every frame, anatomy, local deformation, focus or occlusion. The report identifies
original frames for focused sequence review while retaining every source frame
and the confirmed 1 Hz grid. No mask, exclusion, analysis window or outcome role
is adopted. Previously clarified pre-recording state establishment remains
unmeasured; brightness stability is not a substitute for experimental timing.

[R1-C02-SEQUENCES-026](reference-results/boi-c02-sequences-20260912/README.md)
completes the prespecified neighbouring-frame review of the 025 targets. Fixed
vessel/perimeter crops retain recognizable structure; no supported exclusion
is established from these flags. Reference-dependent translation estimates,
including ID403 frame 546, do not by themselves establish physical motion.
Brightness/texture variation is not assigned a physiological or acquisition
cause. No absence-of-motion claim or full-recording validity follows from these
limited clips. The selected review intervals are not analysis windows; native
source frames, exact external 1 Hz indices and all unadopted mask proposals remain
intact. Stop this bounded review without tuning toward a binary outcome, and
carry the uncertainty into measurement-specific support/exposure decisions.

[R1-C02-READINESS-027](reference-results/boi-c02-measurement-readiness-20260912/README.md)
consolidates those decisions without changing dictionary 0.3.0-draft. Direct
area-time normalization is distinguished from support-dependent event admission:
uncertain anatomical area does not alone prevent descriptive duration or optical
amplitude arithmetic, and finite amplitude does not validate tissue-time.
Preserve uncomputed, unavailable, successful zero and scientifically unassessed
as distinct states. Whole-file modeling is not window approval, nominal matching
is not valid exposure, and source equality does not recover pre-source processing.

The record specifies one conditional default-support FB2314 awake workflow to
obtain actual both-sign availability and numerical traceability. This technical
execution route does not adopt the draft anatomy, declare every frame valid,
freeze outcomes or approve a C02 contrast. Reviewed static support, event
admission/censoring, physiological recovery, comparison-specific pairing and
independent researcher usability remain scientific/release decisions with their
existing evidence requirements. No new blanket acquisition or stabilization
prerequisite is introduced.

[R1-C02-WORKFLOW-028](reference-results/boi-c02-workflow-20260912/README.md)
supplies fresh descriptive outputs for FB2314 awake only. This supersedes the
027 "not computed" status for this recording's realized measurements, while
preserving that dated snapshot and leaving other recordings unchanged. The
finite-amplitude proportions (109/219 sinks; 13/49 surges) differ materially from
the covered-support availability: unavailable-amplitude events occupy 76.6% and
89.6% of the respective detected covered area-time. Do not substitute finite
event means for the full detected population or discard their coverage.

The first finite surge occupies a peripheral, weakly justified field region and
has a rising baseline/full-recording optical context. An algorithmically clean
baseline is not physiological stationarity or independent anatomical validity.
Two negative directional surge amplitudes remain negative; missing contributions
keep the sink composite unavailable, and no surge composite is defined. Native
versus refined sink timing remains explicit. Numerical/source agreement passes
without deciding anatomy, physiological onset/recovery, censoring, missingness
or C02 inference. All source frames, prior changes and scientific uncertainties
are preserved; no automatic follow-on state or comparison is adopted.

[R1-C02-EVENT-029](reference-results/boi-c02-event-review-20260912/README.md)
closes a six-case source/native-mask/baseline review of the saved FB2314 awake
outputs. Both negative surges are site 16 events 1 and 7 in the dim upper-left
margin. Their entire measurement intervals lie below their respective valid
20-sample baseline means; the signed amplitudes are numerically correct. Keep
detector-label disagreement visible rather than relabelling, rectifying the sign
or moving the reference. Anatomical identity and the cause of the disagreement
are unresolved. The finite positive peripheral example likewise shows that
clean detected context need not isolate a transient from a broader optical rise.

The largest unavailable-amplitude sink and surge have explicit preceding
same-site and other-site overlap, respectively. They account for 21.34% and
22.88% of all within-sign detected covered area-time in this recording. Preserve
that coverage and the unavailable amplitudes together. The source's first-frame
sink has no observed pre-event baseline or observed earlier onset; its existing
descriptive inclusion is not evidence of a newly arising physiological event.
None of these event-local reference questions reinstates an intrafile induction
baseline requirement for the established-state C02 comparison.

Disposition: **retain current numerical rules/results; restrict interpretation
to conditional detector and optical measurements; defer anatomical acceptance**.
No masks, thresholds, baselines, exclusions, windows or outcome roles are adopted.
The purposeful six-case selection is not an estimate of artifact prevalence.
The 268-event native-support ranking, 7200 selected source samples and exact
baseline-overlap attributions pass independent replay; this does not certify
physiological identity. Stop the bounded review here. The existing tissue-support
and measurement-specific admission decision should use these source-bound cases
and the unadopted outer-field proposals, with any adopted support change requiring
a versioned fresh workflow rather than replacement of a denominator alone.

[R1-C02-CRANIOTOMY-030](reference-results/boi-c02-craniotomy-20260912/README.md)
records the user's anatomical clarification: true BOI signal is limited to the
craniotomy, which can occupy only part of the field of view. Adopt this spatial
requirement for defining eligible anatomy, while retaining uncertainty in each
recording's exact boundary. The user's statement does not confirm the vertices
of any existing proposal or prescribe a rectangular margin or intensity cutoff.

Against the unchanged prior FB2314 awake outline, the two negative surges are
approximately 99.9% outside by native detected area-time; the large peripheral
sink is 99.66% outside and both interior sink examples are entirely inside.
This supports an outside-craniotomy explanation of the flagged event locations,
without establishing the optical mechanism or changing their numerical values.
Internal dark tissue remains included. Crossing-event geometry and the full
268-event diagnostic are retained; none is converted to a revised outcome.

Use a source-supported recording-specific ROI. The existing reviewed-support
implementation does not fully restrict operations to it: full accepted event
footprints and whole-image normalization remain. Final ROI coordinates and
boundary-crossing/normalization rules require an explicit reproducible decision
before claiming a craniotomy-restricted reanalysis. No threshold, mask, event
exclusion, new baseline, window or comparison is adopted by this spatial check.

[R1-C02-ROI-RUN-031](reference-results/boi-c02-reviewed-roi-20260912/README.md)
uses the user's acceptance of the displayed FB2314 craniotomy comparison as
authorization for one working-ROI development run. The exact prior polygon is
source-bound and applied through the existing reviewed-support writer in a
fresh stage. This is a working static support decision for FB2314 awake only;
prior boundary uncertainty and the absence of independent surgical annotation
remain visible. It does not accept other masks or freeze scientific eligibility.

The inspected interior sink support is retained while the five peripheral
examples have zero native overlap with the new same-sign union. Both-sign
measurement/source replay agrees, but 5.13%/7.85% of full native detected area-time
still falls outside the ROI. Preserve the new and old results and this residual
limitation. No count reduction or disappearance of negative amplitudes is used
as a biological acceptance criterion; conditional baseline availability and
global/local optical interpretation remain unresolved.

The next method candidate is specified separately: ROI-only spatial
normalization and thresholds, support-weighted smoothing and candidate
restriction before components, with final native-footprint containment. It
requires explicit versioning, exterior-independence and arithmetic checks before
a new development comparison. This is a proposed implementation specification,
not a silent change to the current pipeline, outcome hierarchy or baseline.

## R1-C02-STRICT-032 — opt-in restricted ROI implementation

12 September 2026. User continuation authorizes implementing the
[031 restricted-support specification](reference-results/boi-c02-reviewed-roi-20260912/strict-roi-specification.md).
The new profile is implemented and synthetically checked; whole-image replay
is preserved. This is technical development acceptance only. It does not settle
global-response suppression, ROI boundary uncertainty, physiological event
identity, baseline admission, biological transfer or independent usability.

[Evidence and retained corrections](reference-results/boi-strict-roi-implementation-20260912/README.md)
record exact exterior independence, final native containment, source arithmetic
and version separation. Spatial-bin means were additionally corrected to omit
exterior computational fill. One FB2314 awake comparison with 031 is the next
bounded evaluation; no animal role or cohort decision changes here.

## R1-C02-STRICT-RUN-033 — bounded comparison complete

[R1-C02-STRICT-RUN-033](reference-results/boi-c02-strict-roi-20260912/README.md)
executes the prespecified single FB2314 awake development comparison. The source,
working ROI, metadata, 1 Hz cadence and unrelated parameters are unchanged.
All 346 native events are exactly contained in their sign support; all source
measurement audits agree. There are 305 sinks and 41 surges, with 143/10 finite
amplitudes, 162/31 unavailable and 1/2 negative finite amplitudes.

This changes interior detection as well as removing exterior support. Occupied
fractions increase from 0.274% to 0.500% for sinks and from 0.893% to 2.244% for
surges on unchanged denominators. Availability does not uniformly improve.
The three negative amplitudes remain supported by original-source replay and
are preserved; two surge examples show raw dips alongside positive normalized
scores. Exact ROI containment does not resolve normalization, anatomical
boundaries or physiological relevance. No further mask edits, thresholds,
baselines, cohort roles or exclusions are adopted.

The comparison phase is complete. Next: audit the ROI reference and detrending
contributions to the signed-disagreement cases and specify a fixed global/local
signal challenge before any further detector change or cohort expansion.

## R2-C02-NORMALIZATION-034 — exact arithmetic attribution

[R2-C02-NORMALIZATION-034](reference-results/boi-c02-normalization-audit-20260912/README.md)
reconstructs the three 033 cases on unchanged source, support, native/measurement
windows and original 20 clean baseline frames. No detector/statistics run or
method change occurs. All saved stages replay; the exact spatial decomposition
closes within 4e-14 in independent CSV arithmetic. All 193,344 saved native
pixel-time samples satisfy their sign-specific percentile rule.

At the strongest native surge frames, local residuals decline by 173.67 and
124.44 input units while the ROI residual declines by 377.14 and 340.86 units.
Subtracting that larger reference decline makes the local scores rise. In the
first case, raw local and ROI means fall by nearly the same fraction (9.165%
and 9.130%) despite the positive detection score. For the sink, removed local
trend and a rising ROI residual push the score negative while raw intensity
remains above its event baseline. Temporal weighting strengthens the changes;
spatial-SD variation is not the dominant contribution at these anchors.

The audit distinguishes relative spatial contrast from source-baseline change.
It does not settle the physiological meaning of either quantity, uncertain
boundaries or the wider cohort. Next: execute the prespecified synthetic
shared/global versus local signal and baseline-brightness challenge before
choosing a normalization change. Existing scientific questions remain open.

## User clarification — substrate-related decline

12 September 2026. The user states that bioluminescence signal decreases over
time as reaction substrate is consumed. Treat that mechanism as expected context
when assessing slow trends. Its kinetics, rate and spatial uniformity are not
quantified here; do not infer a specific decay law or attribute every shared
change to substrate consumption. This is user-provided experimental context,
not a newly measured kinetic result.

The current event amplitude baseline is the mean original-source signal over
the event's fixed native union footprint during the 20 seconds immediately
before its measurement start. All 20 finite, nonoverlapping samples are required
at 1 Hz; missing/overlapping samples do not trigger an earlier search. Detection
uses a per-pixel cubic fit over the full recording, whereas amplitude uses the
original signal. Assess substrate-related drift and the local baseline together
in subsequent controlled challenges. No method or baseline change is adopted
by this clarification, and previously frozen evidence remains unchanged.


## R2-SUBSTRATE-CHALLENGE-035 — decay and baseline challenge complete

[R2-SUBSTRATE-CHALLENGE-035](reference-results/boi-substrate-challenge-20260912/README.md)
executes the original 24 shared/local controls, 18 separately frozen decay
stage inputs and 144 known-support event measurements. All use 1 Hz. The
20-second original-source baseline and every production parameter remain
unchanged. Exponential half-lives of 10, 20 and 40 minutes are illustrative;
actual substrate kinetics were not estimated.

At a 10-minute half-life, a supplied 20-second window with decay alone measures
as a 3.35% sink; an injected 2% drop measures 5.29%, and a 2% rise measures 0.77%.
The quantifier's original-source baseline can therefore exaggerate drops and
attenuate rises. These are known-window arithmetic fixtures, not detected
biological events. Shared fractional changes on heterogeneous brightness also
produce relative spatial candidates without local injections. Noise-free
near-zero residual variance can amplify numerical structure; all zero-SD and
unavailable decomposition cases remain explicitly recorded.

Independent checks replay all 144 measurements, 25,200 candidate-frame rows
and all 21 noise-free source stacks with exact hashes. All 467 MATLAB files and
the measurement dictionary match the prior phase. The main run took 4.29 minutes
with two threads; existing changes and prior evidence are preserved. The phase
is complete; physiological acceptance, empirical kinetics, biological variability,
cross-mouse transfer and independent researcher usability remain open.

Next: quantify observed local and ROI pre-event slopes for the same three
source-audited FB2314 cases, preserving their native footprints and original
20 clean samples. Do not assign a substrate half-life from short baselines or
adopt a correction before a bounded comparison of baseline approaches.


## R2-C02-BASELINE-DRIFT-036 — actual pre-event drift audited

[R2-C02-BASELINE-DRIFT-036](reference-results/boi-c02-baseline-drift-20260912/README.md)
checks the same three signed-disagreement events from one FB2314 awake
recording. Native footprints, original 20 clean baseline samples at 1 Hz,
measurement windows and negative amplitudes are preserved. No production
method, detector or cohort analysis was rerun or changed.

Local full-window slopes are −0.1027, −0.1634 and +0.0056 percent of baseline
per second for sink 10/1, surge 1/3 and surge 1/4. A straight line explains
6.3%, 17.4% and 0.08% of local variation. The sink and surge 1/4 reverse slope
direction between the two ten-sample halves; the ROI also differs from local
behavior. These fluctuations do not identify substrate half-lives or establish
which component is physiological. A uniform decay correction is not adopted.

Independent checks reproduce 114 metrics, 7,200 saved raw trace values and
all three native footprints. All 467 MATLAB implementation files remain
unchanged, and the 347 sealed files from phase 035 are preserved. The MATLAB
process completed in 30.49 seconds. A failed initial path dispatch is retained.
This completes the descriptive audit; biological variability, physiological
acceptance, cross-mouse transfer and independent researcher usability remain open.

Next: execute the prespecified comparison of the unchanged 20-second mean
with a pre-event linear reference on 144 existing synthetic fixtures and 64
fixed fluctuating-background inputs. Preserve both answers and test the risk
of extrapolating a short fluctuation before any production baseline decision.


## R2-BASELINE-COMPARISON-037 — controlled reference comparison complete

[R2-BASELINE-COMPARISON-037](reference-results/boi-baseline-comparison-20260912/README.md)
compares the existing 20-second mean with a line fitted only to the same
pre-event samples: 144 unchanged saved fixtures plus 64 frozen fluctuating
inputs, for 416 readouts at 1 Hz. No detector, cohort analysis or production
baseline change occurs. All original constant-reference results replay exactly.

The line reduces smooth-decay error: a noise-free 2% drop over a 20-second
window at an illustrative 10-minute half-life measures 1.995% with the line
versus 5.286% with the mean. Fluctuations can instead produce much larger
errors. One zero-injection control measures a 9.967% drop with the line; the
line reverses the injected direction in 8 of 32 fluctuating cases with a
nonzero component. These are fixed synthetic outcomes, not biological error
rates or an automatic baseline-selection rule.

Independent arithmetic and all 64 new native input hashes agree. Three
zero-change controls have a machine-precision strict sign-flag disagreement
(about −1.14e−16 fraction versus zero); the values, flags and initial failed
verification are retained explicitly. No amplitude is rounded or threshold
tuned. All 467 MATLAB files and prior evidence are preserved. The main process
completed in 22.54 seconds. This closes the controlled comparison, while
physiological interpretation, variability across mice and independent usability
remain open.

Next: make baseline variation and reference sensitivity inspectable in the
existing MATLAB event review, retaining the original saved measurement and
labeling alternatives as diagnostics. Do not automatically correct or exclude
events, or infer substrate kinetics from a short fitted segment.


## R2-BASELINE-REVIEW-038 — diagnostic event review implemented

[R2-BASELINE-REVIEW-038](reference-results/boi-baseline-review-20260912/README.md)
adds a **Baseline diagnostic** tab to the existing MATLAB saved-event review.
It shows the actual clean samples, saved mean, pre-event-only fitted line and
extrapolation interval, full/two-half slopes, variation and reference-sensitive
amplitude. The original measurement remains visible and unchanged. New exports
version and hash the diagnostic, preserve its ingredients and retain negative
and unavailable values. Missing samples are never replaced by an earlier search;
invalid extrapolations are withheld without clipping or automatic correction.

All 29 event, connected-review and window-review tests pass. Three saved FB2314
awake cases and one unavailable-baseline case pass reopening/export checks;
independent arithmetic agrees and the source audit is unchanged. Four corrected
MATLAB screenshots have been inspected. The combined final verification process
took 44.88 seconds. An initial test-discovery failure and an interval-marker
display defect are retained with the correction and passing regression checks.

Only four existing review/test MATLAB files changed, with two new review helpers;
463 prior MATLAB files, the detector, quantifier, statistics and measurement
dictionary remain unchanged. Phase-start versions of edited files and all 64
sealed phase-037 artifacts are preserved. This completes implementation and
verification, not physiological acceptance or independent researcher usability.
BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Substrate consumption
does not establish the origin or kinetics of each local fluctuation.

Next: perform a researcher walkthrough of the diagnostic alongside the saved
event evidence, checking that reference sensitivity and unavailable values are
understood before choosing a production baseline method. Cross-mouse validation
and the distinction between net source change and deviation from an expected
or shared signal remain open.


## R2-BASELINE-REVIEW-FIXES-039 — code-review findings corrected

[R2-BASELINE-REVIEW-FIXES-039](reference-results/boi-baseline-review-fixes-20260912/README.md)
corrects the two reproduced phase-038 review defects. The diagnostic now flags
saved-versus-audited disagreement and separates the saved amplitude, audited
mean-reference amplitude and fitted-line amplitude. Reference sensitivity is
line minus audited amplitude on the same source. The earlier line-minus-saved
difference is preserved with an explicit warning that it can include audit
disagreement. Stored and audited baselines retain their distinct identities;
missing historical values are not filled from the audit. Native bounds now
remain visible outside the measurement interval without extending the fit.

All 31 review tests pass, including serialized mismatch checks for both signs,
missing historical baseline, unavailable diagnostic and native bounds on either
side of the plotted samples. Six MATLAB views were inspected. The same three
FB2314 cases and one unavailable-baseline case retain identical quantitative
frames, footprints, saved rows and prior diagnostic arithmetic. All 48 export
artifacts verify. Diagnostic schema 2 and export schema 4 record the new roles;
the fitted-line method remains version 1 because its arithmetic is unchanged.

Four review/test files changed; the other 465 MATLAB files and all earlier
outputs are preserved. The 229 phase-038 sealed files verify using phase-start
snapshots for subsequently edited files; all 18 code-review evidence files
also verify. These fixes do not resolve the scientific baseline choice,
physiological interpretation, biological variability or cross-mouse transfer.
BOI-only scope, feasibility, usability and traceability remain requirements.

Next: researcher walkthrough of the corrected diagnostic alongside original
event evidence; independent usability and any production baseline decision
remain open.


## R2-GUIDED-REVIEW-040 — researcher feedback and timing question

The guided MATLAB diagnostic walkthrough received user feedback on all three
examples: tentative understanding of reference sensitivity, clear unavailability
when no pre-event samples exist (also not definable manually for that case),
and clear separation of audit disagreement. The live reviewer opened and the
user reported successful export and usability. The resulting surge site 1/event 4
export was found beside the source audit. All eight artifact checksums and
implementation/source-audit hashes verify; both amplitudes reproduce from CSV.
Individual researcher clicks were not observed. Guided feedback and assistant
replay do not complete independent release validation.

The user would place onset earlier in both examples and judge pocket duration
from onset to recovery, considering the signal level after the excursion. This
is preserved as a scientific timing proposal, with no manual frame boundaries
or production-method adoption inferred. The two examples are provisionally
interpreted as surge site 1/events 3 and 4; event 4 is confirmed by the export.
These surges currently use native-mask bounds without trace refinement. Existing
sink timing uses a different, bounded detection-trace return rule, not a
post-event reference on the fixed preserved-source footprint.

Next: review wider before/after traces and record researcher onset/recovery
annotations alongside original bounds. Keep post-event timing evidence separate
from the pre-event amplitude reference. Substrate consumption does not imply a
return to the original intensity or identify a local background trajectory.
An earlier onset also changes which 20 clean samples precede it; compare the
resulting baseline availability and amplitudes before any method decision.
Biological variability, physiological relevance, BOI-only scope, feasibility,
usability and traceability remain requirements.

Evidence: workspace `reference-validation/boi-baseline-guided-review-20260913/`
contains verbatim feedback, successive records, export verification and the
wider timing-context plot. No original analysis or code has been changed.


## Researcher correction and timing annotations — 13 September 2026

The user explicitly cautions against overinterpreting substrate decline: each
recording can behave differently, which motivated the original baseline
correction. Treat this as a correction to the emphasis of the preceding guided
explanation. A local slope is not assigned a substrate cause. The original
external-drive `HP_indepth/OxygenDynamics_Master.m` was inspected read-only and
copied with its hash into the guided-review evidence. It uses recording-derived
polynomial detrending (degree 3 per pixel, degree 5 per trace) and a degree-7
processed-site trace trend for sink return-level timing, not a substrate-decay
model. This source inspection does not establish which exact historical file
version generated every saved output, or adopt a new measurement method.

The researcher marks FB2314 surge site 1/event 3 approximately **496–516**
(saved 503–514), and event 4 approximately **536–556** (saved 540–552).
They explicitly allow onset a little later and offset earlier, by around
1–2 seconds, and describe the judgment as biologically difficult. Preserve the
nominal bounds and this uncertainty. A working comparison envelope includes
onsets 496–498 / 536–538 and recoveries 514–516 / 554–556; these are annotated
possibilities, not confidence limits, accepted algorithm thresholds or exact
biological boundaries. Original event and mask labels remain unchanged.

Each nominal pair has 20 seconds between marked sample times, whereas the
current inclusive-frame convention counts 21 samples. Preserve both meanings
until the timing convention is resolved. A nominal earlier onset would move
the candidate 20-sample amplitude baselines to frames 476–495 and 516–535;
cleanliness/overlap has not been re-audited, so no alternative amplitude or
baseline availability is asserted. Post-event recovery evidence does not
silently replace the pre-event amplitude reference.

Next: compare the existing recording-specific correction and timing with these
annotation ranges, preserving biological uncertainty and all previous results.
No decay model, baseline correction or production event boundary was changed.
Evidence: `reference-validation/boi-baseline-guided-review-20260913/`
`feedback-05.json`, `researcher-timing-annotations.json`, and
`original-correction-reference.json`.


## R2-C02-TIMING-COMPARISON-041 — annotated timing comparison complete

[Comparison and evidence](reference-results/boi-c02-timing-comparison-20260913/README.md)
retain the existing recording-specific correction and compare FB2314 awake
surge site 1/events 3 and 4 with the researcher's uncertain annotations.
The cubic-corrected local trace crosses zero between frames 499–500 and
514–515 for event 3, and 536–537 and 554–555 for event 4. Event 3's onset
falls later than the working annotation range. These are descriptive landmarks;
no physiological boundary, sink return algorithm or causal substrate trend
is inferred. Historical and current surge bounds are native-mask based.

All 18 annotation alternatives retain 20 finite immediate pre-event samples
without saved native-event overlap, checked against all 346 events of both
signs on the original footprints. This does not prove a biologically quiet
baseline. Boundary shifts change both the reference samples and the included
raw-source maximum: diagnostic surge amplitudes range from −1.315211% to
+1.077856% (event 3) and −0.597962% to +1.316485% (event 4). Original negative
amplitudes, labels and masks remain unchanged. Marked sample-time separation
and inclusive-frame duration are exported separately.

Independent replay verifies 2,400 samples per trace column, all 20 comparison
rows, both saved amplitudes, native overlaps and crossing brackets. Seven
frozen inputs, all 469 MATLAB implementation files and the 143 preserved
phase-039 artifacts verify unchanged. Two final plots were visually inspected.
No detector/statistics run, new movie read or production-code change occurred.

Decision: close this bounded experiment, retain current production rules and
defer adoption of a physiological timing definition. Before selecting a rule,
specify a small comparison across already development-exposed recordings and
both signs, preserving variable backgrounds, morphology, recurrence, overlap,
incomplete recovery and unavailable measurements. BOI-only scope, biological
variability, physiological relevance, feasibility, usability and traceability
remain requirements. These two annotations remain uncertain development
examples; formal independent validation and cohort scientific decisions stay open.


## R2-TIMING-PANEL-042 — broader development comparison prepared

[The frozen timing panel](reference-results/boi-timing-panel-20260913/README.md)
contains 48 unique events (12 per recording) from FB2314 awake, ID400 awake,
FB2316 KX and HP_ECS_CSV2_identity_pending. All are already development-exposed;
HP is not a fourth verified animal. Fixed detector-magnitude, native-duration,
baseline-context and recurrence slots were declared before selection; both
signs and the two existing researcher anchors are retained. No case was selected
for a new timing result or agreement with manual marks.

All required saved traces and 48 native-mask associations verify. Sixteen frozen
inputs and all 469 MATLAB implementation files remain unchanged. The old ID400
and FB2316 audits lack AnalysisInfo.FrameSize, required by the current GUI
reviewer; direct read-only checks verified dimensions from their saved site
tables without rewriting historical records. The failed GUI-loader attempt is
preserved. Thirty-one selected amplitudes are unavailable under the saved
baseline rule and remain included; this is a selection characteristic, not a
new biological result. The initial researcher review queue has at most10 cases.

This closes panel preparation, not the timing comparison. Next execute one
bounded saved-trace/native-mask replay per recording, preserving original
correction, tissue-support differences, opposite signs, crossing uncertainty,
censoring and missingness. No pooling, new decay model, production timing change
or scientific validation is implied. BOI-only scope, biological variability,
physiological relevance, feasibility, usability and traceability remain standing
requirements. The cohort evaluation freeze and independent release walkthrough
remain open.


## R2-TIMING-EXECUTION-043 — frozen timing comparison completed

[The completed comparison](reference-results/boi-timing-execution-20260913/README.md)
replays all 48 selected events from four development recordings using their
existing correction. Of 96 positive/negative diagnostic branches, 35 have two
crossings, 25 are censored and 36 lack the requested sign inside native support.
Twenty of the 35 bracketed branches cover only part of the native event. These
are diagnostic branch counts, not independent biological observations or
condition effects. Only 11 bracketed branches also provide the required clean
20-sample baseline; saved 17 finite and 31 unavailable amplitudes remain intact.

Decision: retain production correction/timing, keep new crossings as diagnostic
landmarks and defer a general physiological duration rule. No substrate-decay
model, source change, relabeling, fallback reference or scientific tuning was
introduced. Restricted ROI and historical whole-field contexts remain separate.
The HP identity and anatomy holds remain; the fixed HP sink review case has
small support near the upper-right image edge and is not physiologically
validated by its successful numerical replay.

Independent replay verifies 144 rows, 50,400 full-trace samples per column,
48 native footprints, overlap, timing/censoring and saved measurements. All 16
frozen inputs and 469 MATLAB implementation files retain their hashes. Four
recordings completed in 5.86–19.82 seconds each excluding startup. Ten trace
plots and ten native-mask montages were inspected. Initial queue-format failure
and a saved-row coverage-flag reporting correction are preserved with their
exact scope; scientific calculations and selection are unchanged.

Next: [review the ten fixed examples](reference-results/boi-timing-execution-20260913/REVIEW.md),
beginning with the first two, to distinguish complete excursions, partial
fluctuations and unresolved recovery. Approximate ranges or an unresolved
judgment are acceptable. No further automatic parameter search follows from
inconclusive evidence. BOI-only scope, biological variability, physiological
relevance, feasibility, usability and traceability remain requirements;
independent physiological/workflow validation and cohort eligibility stay open.


## R2-TIMING-GUIDED-REVIEW-044 — fixed researcher review completed

[The consolidated guided review](reference-results/boi-timing-guided-review-20260914/SUMMARY.md)
records eight new judgments: six with timing marks and two without a
recognizable event. The two earlier FB2314 anchors complete the ten-case queue
with their original uncertainty; they were not newly confirmed. Example 6 (FB2316
KX surge 10/3) is not seen as a surge. Example 7 (HP sink 15/4) is not distinguished
from surrounding temporal variability; that rationale remains separate from
its unresolved upper-right anatomical support.

The annotated boundaries follow local decline/rise and recovery, including a
brief recovery peak and alternative plausible onsets. Example 3 preserves 295 s
as an additional onset alongside 297, with 312–313 offset; the plot-frame versus
elapsed-time origin remains explicit. No fixed prominence, variability or
duration threshold is inferred. Existing correction, both detector signs,
biological variability and physiological relevance remain standing requirements.

All eight feedback chains and exact ten-case queue coverage verify. Production
code, timing, baselines and amplitudes are unchanged. The phase 043 narrative
correction is retained: example 1's onset was censored, while recovery was
bracketed at 1166–1167. Prior sealed evidence remains preserved. This is guided
development feedback, not an independent accuracy or release validation.

Next: a bounded measurement-impact audit of the supplied intervals and
alternatives, including the same 20-sample immediate baseline, both-sign native
overlap and unavailable values. Keep non-recognized candidates' original
outputs without assigning manual timing. Define testable candidate rules only
after this audit; do not automatically retune the detector. BOI-only scope,
feasibility, usability, traceability, HP identity/anatomical holds and cohort
scientific questions remain in force.


## R2-MARKED-INTERVAL-IMPACT-045 — researcher interval consequences checked

[The verified measurement-impact audit](reference-results/boi-marked-interval-impact-20260914/README.md)
checks 12 explicit variants from six new annotations against eight saved
comparators; the two non-recognized examples receive no manual intervals.
Two new annotated events retain an available amplitude; four still lack the
required 20 immediate finite pre-event samples free of both-sign native overlap.
ID400 sink 45/1 gives 7.6787–8.0248% across onsets 295, 296 (coordinate
sensitivity only), and 297, versus saved 7.8838%. Offsets 312/313 do not change
its amplitude. FB2316 sink 14/6 gives 6.6592%, versus saved 6.7268%.

The HP surge 235–356 remains recognizable to the researcher despite unavailable
amplitude; its fixed original footprint and native extension through frame 389
remain explicit. The rejected HP sink retains its finite saved 1.5316%
amplitude: measurability does not establish event recognition. No substrate
mechanism, revised correction, event relabeling or baseline fallback is adopted.
Frame 295 versus elapsed second 295 remains an explicit alternative rather than
a silently resolved annotation. Earlier anchor grids are reused by hash.

Independent arithmetic/native-overlap verification passes all 20 new rows,
reproduces all eight saved comparators, verifies 33 frozen inputs and confirms
469 unchanged implementation files. Prior evidence and standing document
versions are preserved. This is a bounded development audit, not physiological
validation or final cohort eligibility. BOI-only scope, both signs, biological
variability, physiological relevance, feasibility, usability and traceability
remain requirements; HP identity/anatomy and other scientific holds stay open.

Decision: retain production rules and defer final recognition/timing policy.
Next: prespecify a small candidate set of event-recognition and onset/recovery
rules with local variability, boundary uncertainty, recurrence and sustained
signals represented. Keep amplitude availability separate and preserve the
original recording-specific correction; no automatic threshold adoption or
relaxation of the reference rule follows from this audit.


## R2-RECOGNITION-TIMING-CANDIDATES-046 — bounded candidate definitions prepared

[The candidate comparison](reference-results/boi-recognition-timing-candidates-20260914/README.md)
specifies two diagnostic timing rules: nearest observed turning points and the
strongest shoulders within the same saved search limits. Both operate on the
existing corrected trace, retain both directional branches and allow brief
recovery peaks. Seed/plateau conventions, partial boundaries, nonfinite barriers,
competing excursions and native-support disagreement are explicit.

A separate recognition diagnostic compares directional shoulder prominence
with preceding/following ranges at fixed 10- and 20-sample context scales.
Its factor-one screen is an unvalidated comparison hypothesis, not an event
admission threshold. Active context is retained and flagged. The 20-clean-sample
raw amplitude reference remains separate and unchanged; unavailable amplitudes
do not suppress recognition evidence. No correction fit, substrate model,
automatic exclusion, event relabeling or production policy is adopted.

The same 48 development events and ten reviewed cases are bound to source
hashes. Eight have uncertain timing references, two are not recognized, and 38
have no human reference. The future budget is 192 timing rows and at most 384
context-scale diagnostics, one pass per recording, ten minutes per recording,
250 MiB new evidence and the existing ten-case review limit. Existing comparator
outputs are reused. Technical verification and explicit gains/losses are
required; no scientific winner score or automatic tuning loop is defined.

Preparation is complete; the candidate comparison has not run. All prior
evidence and 469 implementation files remain unchanged. BOI-only scope, both
signs, biological variability, physiological relevance, feasibility, usability,
traceability and unresolved cohort/anatomical/HP identity questions remain.
Next: implement and verify these diagnostic-only candidates, bind their code,
then run the fixed saved-panel comparison. Final physiological rules and
production changes remain deferred pending evidence.


## R2-RECOGNITION-TIMING-EXECUTION-047 — fixed candidate comparison complete

[The verified comparison](reference-results/boi-recognition-timing-execution-20260914/README.md)
implements the frozen nearest-turn and strongest-shoulder diagnostics on all
48 events in both directions. Known-shape checks pass 89 groups, and independent
Python verification checks all 192 nested timing/context/amplitude rows and
reproduces 48 original comparators. There are 154 complete intervals, 34
unbracketed seeds and four partial-shoulder rows. Complete intervals generate
308 context-scale diagnostics; these are repeated calculations, not biological
replicates. Recording, saved sign, direction and candidate remain separate.

The strongest-shoulder decline matches example 1 at 1154–1167, but can begin too
early or extend recovery too far: the HP surge becomes 233–417 versus the user's
235–356. Nearest turns frequently capture small internal fluctuations. The
recognized ID400 surge fails the proposed range screen at both context scales;
the rejected HP dip passes at 10 samples and fails at 20 for the strongest
decline candidate. No branch, context scale or manual alternative is selected
to rescue agreement. Both candidates and the range screen remain unadopted.

All ten fixed figures and every supplied annotation alternative are retained,
including the coordinate sensitivity for example 3. Original saved/zero-crossing
comparators, slot mappings, native geometry and source links are reused. A
reporting-only correction marks unassessed baseline counts unavailable instead
of zero; original run outputs and initial figures are preserved. No detector,
correction, movie, statistics or production rerun occurred. All 469 implementation
files and prior evidence remain unchanged or explicitly snapshotted.

Decision: retain production rules and defer scientific recognition/timing policy.
The fixed comparison stops; do not automatically adjust smoothing, thresholds,
context lengths or search limits. Next clarify what distinguishes a full
excursion from nested fluctuations and what constitutes local recovery when
later activity follows, using these failure cases before another method proposal.
BOI-only scope, both signs, biological variability, physiological relevance,
feasibility, usability, traceability and unresolved anatomical/cohort/HP identity
and independent-validation requirements remain in force. Existing recording-
specific correction remains the starting reference; no substrate mechanism is
inferred and amplitude availability remains separate from recognition.


## R2-REVIEW-TRACE-AUDIT-048 — displayed signal identity checked

[The review-trace audit](reference-results/boi-review-trace-audit-20260914/README.md)
verifies all ten original guided-review plot hashes and all 10,800 corrected
samples against the saved array used by phase 047. No trace-identity or
frame-order mismatch was found: the candidates used the displayed middle blue
corrected trace as specified. The original displays also contain raw and
filtered event-footprint traces and a differently supported/processed site
trace. The researcher did not consistently specify which panel guided the marks.

The intended human reference is therefore an explicit open provenance question;
do not treat phase 047 as comparison against a confirmed corrected-trace-only
annotation protocol. Its numerical results remain valid and preserved. This
audit does not establish that switching traces would solve its failures.
Exact endpoint neighborhoods are copied for inspection without ranking traces,
new landmark searches or invented tolerances. Prior judgments already support
full-excursion review, brief recovery where appropriate and local variability;
no universal numerical criterion is inferred.

The source audit is complete. The researcher has been asked which original
panel or combination mainly guided the marks; no answer is assumed. Clarify
that before another scientific method proposal, without asking for reannotation
or silently replacing the timing trace. No candidate/detector/amplitude rerun,
new correction, production change or substrate mechanism follows. BOI-only
scope, both signs, biological variability, physiological relevance, feasibility,
usability, traceability and existing scientific/cohort/anatomical holds remain.


## R2-CORRECTED-SCORE-SUPPORT-049 — researcher reference clarified and score support checked

The researcher confirms that the middle corrected-intensity trace mainly guides
the judgments, the bottom detection-score view also helps, and the top raw view
is used to check whether the correction has worked. [The recorded clarification
and bounded support audit](reference-results/boi-corrected-score-support-20260914/README.md)
resolve phase 048's reference-panel question without changing earlier marks.
This is a primary/supporting hierarchy, not an exclusive corrected-only protocol;
orange versus dotted bottom traces were not individually specified.

The 32 fixed intervals comprise 30 supplied timing combinations (including two
coordinate sensitivities) and two saved-native references for non-recognized
examples. All 96 corrected/filtered/site-trace rows are independently verified.
The filtered event-footprint score has fewer interior turns in every marked
combination, including 5 versus 1 in example 1 and 63 versus 27 in the HP surge.
It can also emphasize a different signed feature from corrected intensity in
the earlier FB2314 anchors. Fewer turns or shifted extrema are not biological
validation, an automatic boundary criterion, or a pure temporal-filter-delay
estimate. The separately supported site trace remains distinct.

Keep corrected intensity primary and detection score as supporting structure;
keep the raw view for correction quality. Phase 047 used the primary trace and
its failures remain relevant; adding score support is not yet a validated
automatic solution. No source switching by agreement, new filter/correction,
threshold, event exclusion, relabeling or amplitude change was introduced.
All 469 implementation files and earlier evidence remain preserved.

Decision: record the confirmed researcher reference roles and retain production
timing. Next implement this hierarchy as a timing-review view in the existing
MATLAB reviewer, preserving the amplitude-inspection view and exporting signal
roles, source/support identity, availability and frame/time coordinates. The
handoff names existing integration points and bounded checks. No new automatic
timing rule is adopted. BOI-only scope, biological variability, physiological
relevance, feasibility, usability, traceability and unresolved anatomical,
cohort, HP identity and independent-validation requirements remain in force.


## R5-TIMING-REVIEW-UI-050 — saved-stage timing view implemented

The existing MATLAB event reviewer now includes **Timing review**, with corrected
intensity primary, separately labeled event-footprint and site detection scores
as supporting context, and optional raw/correction-quality inspection. Event and
frame selection are synchronized with amplitude inspection. Saved one-based
sample bounds and modeled elapsed time are explicit; the external 1 Hz clock
remains authoritative and exposure duration remains separate.

Missing or malformed stages remain unavailable; nonfinite samples remain gaps.
The already removed trend is raw minus saved corrected intensity only when their
shared input is recorded, with no new fit or substrate model. Saved amplitudes,
baselines, event signs, researcher marks and uncertainty are unchanged. No
recognition threshold, boundary snapping or phase 047 candidate is adopted.

[Implementation evidence](reference-results/boi-timing-review-ui-20260914/README.md)
records 27 passing event/connected-review tests, final timing-specific checks,
exact preservation of every previous measurement field across 346 FB2314 events,
1,245,600 exact saved-stage samples, independent export verification and rendered
current/historical views. The actual older HP audit with absent stages opens
and exports with those stages explicitly unavailable. These are developer
checks, not physiological validation or an independent researcher walkthrough.

New event exports use schema 5 and include timing signal roles, input/support
identity, availability, selected event/bounds and frame/time provenance. The
measurement dictionary and baseline diagnostic retain their existing definitions.
Four existing MATLAB files change and two helpers are added; the remaining 465
are unchanged. Prior evidence and phase-start versions remain preserved.

The bounded UI phase is complete. Use the new view for subsequent researcher
boundary review. Biological variability, physiological relevance, feasibility,
usability, traceability, BOI-only scope and unresolved cohort, anatomical,
HP identity and independent-validation requirements remain in force.


## R2-TIMING-UI-FEEDBACK-051 — first researcher review in the new tab

The researcher confirms the MATLAB timing view is open. For FB2314 awake,
sink site 15 / event 36 (audit row 186), onset **1154 remains preferred**, with
**1149** a defensible alternative. Offset is **1166 or 1167**, with the detection
score mentioned as context; no unique offset or specific score curve is inferred.
[The verbatim feedback and provenance](reference-results/boi-timing-ui-feedback-20260914/README.md)
preserve these as discrete frame alternatives alongside the earlier 1154–1167
judgment. The earlier marks were shown in the review prompt, so this is not
blinded or independent evaluation. No production timing, correction, amplitude,
label or application annotation storage changes. The broader timing criterion
and existing scientific holds remain unresolved; further researcher review is
pending.


### Timing-view feedback 02 — saved surge site 5 / event 1

The researcher replies **177–195** for FB2314 awake audit row 321 in the
MATLAB timing view: onset frame 177, offset frame 195. The earlier onset
177-or-178 / offset 195 judgment remains preserved; no additional rationale or
tolerance is inferred. [Feedback 02 and provenance](reference-results/boi-timing-ui-feedback-20260914/feedback-02.md)
record the conversational event association, exact saved evidence and earlier
annotation. No direct screen inspection, independent validation, event relabeling,
automatic timing update or amplitude recalculation occurred.


### Timing-view feedback 03 — saved surge site 1 / event 3

The researcher replies **496–516** for FB2314 awake audit row 308: onset
frame 496, offset frame 516. This repeats the earlier nominal bounds;
the prior possible onset 496–498 and recovery 514–516 remain preserved.
[Feedback 03 and provenance](reference-results/boi-timing-ui-feedback-20260914/feedback-03.md)
retain the exact reply and conversational event association. No new rationale,
withdrawal of uncertainty, independent validation or production change is inferred.


### Timing-view feedback 04 — saved surge site 1 / event 4

The researcher replies **526–556** for FB2314 awake audit row 309: onset
frame 526, offset frame 556. Onset is 10 frames earlier than the prior nominal
536–556 judgment and outside its earlier 536–538 onset envelope; offset is
unchanged. [Feedback 04 and provenance](reference-results/boi-timing-ui-feedback-20260914/feedback-04.md)
preserve both judgments. No typo, new rationale, curve reference or tolerance
is inferred. The feature supporting onset 526 remains an open researcher
question. No production timing, correction, amplitude or label changes occur.


### Timing-view feedback 05 — explicit correction to 536–556

The researcher explicitly corrects the preceding entry: **536, not 526**.
The current annotation for FB2314 awake, saved surge site 1 / event 4 (audit
row 309), is **536–556**, matching the original nominal judgment.
[The correction and revision history](reference-results/boi-timing-ui-feedback-20260914/feedback-05.md)
supersede feedback 04's onset 526; it remains historical, not a current
alternative. The question about a feature supporting 526 is withdrawn.
Earlier uncertainty is preserved. No production calculation or label changes.


## R2-TIMING-UI-SYNTHESIS-052 — four follow-up reviews compared

[The comparison](reference-results/boi-timing-ui-synthesis-20260914/README.md)
resolves the current references to sink 15/36: onset 1154 preferred or 1149,
offset 1166 or 1167; saved surge 5/1: 177–195; surge 1/3: 496–516; surge 1/4:
536–556. The explicitly corrected entry 526 is excluded from the current
comparison while its history remains preserved. These are four familiar events
from one FB2314 awake recording, not independent validation.

The existing wider T3 declining branch reaches a supplied offset in all four,
but begins 1, 3 and 5 frames early in the latter three cases. Both directional
branches and all 28 comparisons with the seven current boundary combinations
remain visible. At anchor offsets 516 and 556, corrected intensity has a local
maximum while both supporting scores have a local minimum. Score peak snapping
is therefore unsupported. T2 often captures only part of the marked excursion.
Neither T3 nor a human-selected endpoint hybrid is adopted. Earlier cross-recording
failures, including the long HP surge offset and two non-recognized examples,
remain binding.

All 90 copied boundary-neighbor values and all endpoint differences are checked;
32 prior feedback artifacts and every MATLAB implementation file remain unchanged.
No candidate, detector, correction or amplitude rerun was performed. The bounded
next step is a saved-trace diagnostic exposing competing corrected shoulders,
their score context and barriers across the ten existing reviewed examples,
without ranking, new smoothing or automatic boundary assignment. Its scope,
outputs, verification and feasibility limits are specified in NEXT-STEP.md.
BOI-only scope, biological variability, physiological relevance, usability,
traceability, anatomical/identity/cohort uncertainty and independent validation
remain requirements.


## R2-BOUNDARY-AMBIGUITY-053 — competing shoulders inventoried

[The completed diagnostic](reference-results/boi-boundary-ambiguity-20260914/README.md)
exposes 323 eligible shoulders across 20 directional branches in the ten
previously reviewed examples. The frozen seeds, search limits and exact plateau
rules are retained. All 668 extrema, 76 observed T2/T3 boundary selections,
10,800 source rows and 3,876 shoulder sample values are verified. One branch
retains an unbracketed seed; neither negative recognition case receives human
boundaries. Ten final labeled figures are inspected. This is numerical/display
verification, not independent biological validation.

The first case's plausible 1149 onset is outside the neighbor-partition search
start 1151. Several supplied marks are beside rather than on exact turns.
For the anchors, higher earlier shoulders compete with the researcher's later
onsets; at 531 versus 536, about 0.30 corrected source units decide T3's earlier
choice. The long HP surge has many eligible recoveries, including the marked
356, but the strongest rule chooses the later 417. The non-recognized examples
also contain many eligible extrema. Existence of a turn does not establish event
presence, and the current evidence does not justify a universal ranking rule.

Production timing remains unchanged. Search-window eligibility, exact sample
selection and grouping fluctuations into a full excursion remain distinct
scientific questions. The next useful implementation is editable researcher
boundaries/alternatives/reasons with revision history in the MATLAB reviewer,
kept alongside automatic results and without silent amplitude recalculation.
Any later automatic selection hypothesis must be frozen and evaluated against
all 48 existing events with both signs and every earlier failure retained.
All 471 MATLAB files and prior evidence remain preserved. BOI-only scope,
biological variability, physiological relevance, feasibility, usability,
traceability and unresolved anatomy, HP identity, cohort eligibility and
independent-validation requirements remain in force.

## R5-RESEARCHER-BOUNDARIES-054 — 14 September 2026

**Bounded implementation complete; no new scientific acceptance.** Add explicit
researcher judgments alongside saved automatic evidence. Recognition status,
discrete onset/recovery alternatives, preferred choices, actor, reason and
old/new revision history now have an editable MATLAB workflow with new-file
persistence, explicit reopen and checksum-bound export. Blank endpoints remain
unresolved, and not-recognized judgments retain earlier marks only in history.
Input and plot coordinates are one-based recording frames with the confirmed
external 1 Hz clock. No peak snapping, automatic initialization, tolerance,
substrate fit or new amplitude baseline is introduced.

Only saved judgments appear as distinct purple overlays and in export schema
6. Drafts stay with their event in the current session and require explicit
save. Native/measurement bounds, amplitude, baseline diagnostics and statistics
are unchanged. The dictionary and scientific method versions are unchanged.
Thirty developer tests pass; all prior review data for 346 representative events
remain exact, and two exported trace CSVs are byte-identical to the preceding
implementation. Both exported histories reload; four rendered views are checked.
[Evidence and limits](reference-results/boi-researcher-boundaries-20260914/README.md)
include retained failed verification attempts and preservation checks.

The saved demonstration revisions are developer fixtures, not new researcher
feedback. Earlier feedback remains in its original records, including the
536 correction and all uncertainty/supersession. No automatic transfer or new
reviewer attribution is performed. Next is an independent researcher
save/reopen walkthrough; a future migration must preserve original sources,
quotes and review dates. This does not resolve the distinction between exact
sample turns and physiological event grouping, nor justify any universal
boundary ranking rule. Both signs, non-recognized cases, the 48-event evaluation
requirement, anatomical uncertainty, HP identity and cohort/normalization gates
remain preserved.

## R5-RESEARCHER-BOUNDARIES-054-W4 — guided saves and explicit 1153 clarification

Four actual researcher entries are persisted and verified with history/export:
536–556, 496–516, 177–195, and onset alternatives 1149/1153 (1153 preferred)
with recovery alternatives 1166/1167 (no preference). All remain saved as
`uncertain`. On 14 September 2026 the researcher explicitly confirmed that
1153 is intentional after being asked about its difference from earlier 1154.
Treat it as a recording-frame choice, not a seconds-to-frame conversion.
Earlier 1154 evidence is preserved; it is not silently added to current
alternatives or rewritten. The reason and direct clarification retain their
original wording and separate timestamps/provenance.

The bounded guided persistence check is complete. Assistant validation matched
event/source/audit identity and preserved previous entries. Four exports
reopened with exact MAT snapshots and 44 verified artifact checksums. No
production code, baseline, amplitude, native-mask, detector-label or statistics
change occurred. [Evidence and limits](reference-results/boi-researcher-boundary-walkthrough-20260914/revision-04/README.md)
distinguish actual researcher files from developer fixtures and guided review
from independent physiological/usability validation. Next is an explicit
comparison of duration conventions and saved/reviewed intervals; no automatic
timing adoption or amplitude use of manual marks follows from their storage.
All standing BOI scientific uncertainty and eligibility gates remain open.

## R2-REVIEWED-DURATIONS-055 — 14 September 2026

**Diagnostic duration comparison complete; no new measurement policy adopted.**
Retain endpoint span `(End-Start)/Hz`, inclusive frame count `End-Start+1`, and
the existing BOI-M04 inclusive duration `(End-Start+1)/Hz` as distinct reported
quantities. They differ by one frame interval, not by biological evidence.
At the authoritative 1 Hz clock, manual spans 20, 20 and 18 s compare with
saved measurement spans 12, 11 and 10 s in the three selected saved surges.
For the sink, preferred onset 1153 yields spans 13 or 14 s versus saved 9 s;
alternative onset 1149 yields 17 or 18 s. Native detection spans 7 s and is
reported separately. Recovery alternatives are unranked; no midpoint, single
preferred duration, continuous uncertainty range or automatic extension rule
is inferred. Earlier 1154 remains historical, not a current alternative.

The same-convention increases are 8, 9, 8 and 4/5 s (8/9 s for the sink's
alternative onset). These four guided events do not establish cohort timing
accuracy. All recognition statuses remain `uncertain`, and saved event labels
remain unchanged. Independent MATLAB arithmetic verification covers all seven
reviewed alternatives, eight automatic/native intervals and 127 sample
memberships. All existing measurement data and 476 MATLAB files are unchanged.
[Source-bound results and limits](reference-results/boi-reviewed-duration-comparison-20260914/README.md)
retain the dictionary, saved review, clarification and implementation hashes.

Next is compatibility of the saved prebaseline with actual manual interval
choices, retaining existing reference values and flags rather than silently
recalculating amplitudes. No amplitude, mask, area-time, composite, baseline,
correction, cohort admission or biological zero is changed here. Manual-duration
release policy and automatic timing selection remain explicit open questions.
