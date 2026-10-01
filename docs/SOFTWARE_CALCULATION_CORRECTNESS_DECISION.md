# CC-01 revision 2 — scientific target and calculation choice

29 September 2026. **Revision 2 comparison approved and delivered; scientific adoption remains unapproved.** The original proposal below is retained. The researcher subsequently authorized its bounded saved-evidence comparison and paper-to-code review; see the [delivery](SOFTWARE_CC_01_COMPARISON_REPORT.md). No production scientific-output change or recording run was authorized. Owner: Codex assistant; scientific decision owner: researcher. Release work remains paused.
The [first reporting proposal](CC_01_REPORTING_PROPOSAL_SUPERSEDED.md) is preserved
but superseded, including its eight-case reporting-validation proposal.

## Decision and recommendation

**Recommend local corrected optical excursion as the candidate scientific target
for pocket/surge direction and event magnitude. Retain the existing detector as
candidate generation, and retain preserved-input baseline change as a distinct
observed quantity.** This is a proposal to evaluate a different amplitude
numerator and a local-direction criterion, not merely to rename current outputs.
It is not yet a recommendation to deploy a new estimator or relabel saved events.

A sink/pocket should mean a local downward excursion, and a surge a local upward
excursion, distinguishable from the surrounding variability in the recording's
corrected signal. A spatially relative contrast rise alone is insufficient to
establish that local target. The amplitude reference should represent the local
pre-event state, before the selected onset and with preceding/overlapping activity
explicitly assessed. It should not stand for resting oxygen or an experimental
pre-intervention baseline that was never recorded.

For the candidate magnitude, compare the corrected local excursion with the
corrected reference level, while scaling by the **positive preserved-input
reference mean**, never by the near-zero corrected mean. Keep the correction
already used for that recording; do not introduce a universal substrate decline.
This better matches the researcher's corrected-trace judgments than either a
spatial z-score or an uncorrected change that includes the removed trend. Whether
that correction preserves the relevant biological component remains an open
scientific question, not something the software audit has settled.

**Calculation correctness remains open at the scientific-target level.** The
existing audit establishes arithmetic consistency for saved rules. It does not
establish that those rules measure the intended event. Clearer reporting is
necessary for traceability but cannot resolve this mismatch.

## 1. What is currently calculated

Let r(t) be the preserved-input mean over the fixed union of the event's native
pixels; W the measurement interval; R the reference frame set; B=mean(r(R)).

- **Detection contrast:** detrended pixels undergo frame-wise spatial mean/SD
  normalization, pixelwise temporal mean/SD normalization, spatial averaging and
  temporal smoothing. Current code uses SD, not sqrt(SD). The score is
  dimensionless; sink/surge admission acts in that representation. ROI and
  whole-image spatial references differ. Filtered footprint means are not the
  pixel/region threshold and need not have unit variance.
- **Automatic amplitude:** q_raw(t)=(r(t)−B)/B. Saved sink amplitude is
  −min(q_raw(W)); saved surge amplitude is max(q_raw(W)). It is a fraction,
  or ×100 percent. Automatic R requests the immediate round(20*fs) samples before
  the saved measurement onset, screens both-sign native overlap and nonfinite
  samples, and requires the full count and a positive finite B. No fallback.
- **Reviewed amplitude:** the same raw formula and fixed footprint, using the
  explicitly accepted R and each reviewed W. It is a separate exploratory
  definition, not a repaired automatic result. Both signed extrema are available.

A detector trough, a positive sink amplitude and a recognized biological pocket
are three different statements. Likewise, a saved-surge maximum can be positive
while most of its reviewed event interval is a downward excursion. Neither
missing amplitude nor negative amplitude alone proves a false detection.

## 2. Feasible choices for the event label

| Choice | Scientific target | Consequences and feasibility |
|---|---|---|
| L1: retain normalized sign as the final label | Local contrast relative to changing spatial and temporal references | No numerical change. FB2312's relative brightening qualifies even when its corrected local intensity falls. Defensible for contrast events, but insufficient for the proposed local pocket/surge target. |
| L2: require raw pre-event change in the saved direction | Observed intensity fall/rise from a preceding raw level | Feasible from saved traces, but background changes enter the label. Historical ID400's −0.350% sink amplitude would fail a simple positive-amplitude gate. That does not prove absence of a corrected local trough. |
| L3: normalized candidate plus local corrected direction/context assessment — recommended target | Local transient decrease/increase distinguishable from surrounding corrected variability | Can be investigated without rerunning the detector. Retain original sign and separate local classification: decrease, increase, mixed or unresolved. An opposite extremum alone must not relabel an event; duration, neighboring variability and recovery/censoring matter. A numerical admission threshold is not yet selected or validated. |

For L3, existing researcher judgments provide named examples, not ground-truth
population labels. A default magnitude, persistence or variability threshold must
not be selected by making these examples pass. The finite comparison below can
establish a target mismatch and estimate numerical effects; it cannot establish
sensitivity/specificity or automatically finalize the classifier.

## 3. Feasible reference and amplitude choices

Reference selection and amplitude numerator are separate decisions.

| Reference choice | Meaning and consequence |
|---|---|
| R1: strict automatic 20-second immediate clean reference | Reproducible existing default; incomplete reference stays unavailable. But a delayed automatic onset can place apparent baseline samples inside a researcher-recognized event. Twenty seconds and native exclusion are not proof of physiological quietness. |
| R2: exact locally reviewed pre-onset reference — recommended for the reviewed branch | Uses accepted event-local context, with exact frame membership, length and uncertainty. The existing 165–176 selection has 12 samples; it is not a universal shorter-baseline rule. Keep R1 for untouched automatic results. Do not invent accepted references where none exist. |
| R3: earlier, shortened or post-event fallback; fitted local background through pre/post anchors | Could increase availability or follow slow background, but changes the reference and requires rules for neighboring events, recovery and censoring. Exact new values are not established by the current evidence. Do not adopt automatic fallback or a new fitted background in this slice. |

For the numerical comparison, use **exactly the same R, W and fixed footprint**
when comparing these candidate numerators:

| Amplitude choice | Formula and target | Consequence |
|---|---|---|
| A1: existing preserved-input change | q_raw=(r−B)/B | Observed change including background/trend. Already implemented and audited; retain it. It does not isolate event-related excursion. |
| A2: corrected excursion with preserved-input scale — recommended candidate for evaluation | Let T(t) be the saved, source-matched correction trend and c(t)=r(t)−T(t). q_corr(t)=[c(t)−mean(c(R))]/B. | Subtracts the change of fitted trend relative to the same reference. A new derived measurement, not current BOI-M06. Keeps meaningful positive intensity scale without division by corrected intensity. Its physiological validity depends on correction, and it can remove biological variation. |
| A3: event component relative to an estimated time-varying event-free signal | e.g. [r(t)−b(t)]/b(t), with b(t) a counterfactual local background | Closest to an isolated component if b(t) were known, but b(t) is not identified from these biological traces. New estimation and assumptions needed. Not recommended now. |

Under A2, use −min(q_corr) for an assessed decrease and max(q_corr) for an assessed
increase; keep both signed extrema for mixed/unresolved events rather than forcing
one positive magnitude. Calculate candidate extrema separately from raw extrema:
the frame of the raw minimum need not be the corrected minimum. Original saved
labels and their directional amplitudes remain available unchanged.

The identity q_raw(t)=q_corr(t)+[T(t)−mean(T(R))]/B separates arithmetic from the
scientific interpretation of T. It is exact at each shared sample; it does not
justify subtracting the two separately located peaks as though they coincide.

Source requirement: T and r must refer to the same preserved-input source and
footprint. `DetectionDetrended` may come from denoised input and cannot silently
be combined with a raw denominator. Existing audits save `RawCubicTrend` as a
raw-trace decomposition; that is a feasible offline ingredient where its source,
version and relation to the recording correction are established. No refitting
a different trend to obtain desired signs, no source substitution, no spatial
normalization used as an amplitude numerator. If that association is absent,
A2 is untested for that example.

## 4. Numerical consequences already established

All values below are taken from saved reports; no new recording quantity has
been calculated for this revision. Candidate values not present in those reports
are explicitly unknown.

| Named saved example | Established alternatives | What follows for the rule decision |
|---|---|---|
| Historical ID400 awake, sink site 11/event 1 | Raw change at the raw minimum +0.350%; current sink amplitude −0.350%. Trend contribution +3.143 percentage points; residual contribution −2.793. | At that same frame A2 gives a signed change −2.793%, i.e. a 2.793% downward excursion on that scale. **This is not the newly evaluated corrected peak**; its magnitude could differ. L2 rejects the saved direction; L3/A2 can agree with a local trough. The decomposition does not prove drift is nonbiological. |
| Historical FB2312 awake, surge site 1/event 2 | At the raw amplitude extremum: −18.580 detrended input units, +0.211 spatial-normalized units, +0.596 final normalized units. Six flagged surges have this reported stage-direction change. | L1 sees relative positive contrast. Local direction at this sample opposes it. Neither a whole-event L3 classification nor an A2 percentage is established by these three different-unit values; do not report +0.596 as amplitude or automatically relabel the event. |
| G2 ID400 awake, sink site 1/event 3 | Raw B=90.908506224066386; raw minimum=85.860995850622402 at frame 435; saved amplitude 5.5522971205831419%, W=431–457, R=411–430. | A1 remains a finite comparison anchor. A2 peak and trend contribution are not quantified in the G4 replay. Agreement here must not be presumed. |
| FB2314/C02 row 186, sink site 15/event 36 | R1 automatic: 14/20 clean samples, unavailable. R2 reference 1134–1153: B=3791.7652; reviewed A1 signed minimum −17.7058%, sink amplitude +17.7058%; W=1154–1166 or 1167. | R2 changes availability as well as value; this is not a finite numeric delta from the missing automatic result. Onset 1149 still lacks an accepted reference. A2 extrema are unknown. G4's deliberately unavailable automatic example stays unchanged; the separate reviewed result already exists. |
| C02 row 308, saved surge site 1/event 3 | Automatic A1 −2.0645%; reviewed A1 maximum +1.0779%, minimum −9.5218%; reviewed W=496–516, R=476–495. B changes 1998.3357→2006.2259. | Reporting upward maximum versus downward magnitude on the same reviewed raw trace gives **1.0779% versus 9.5218%**, but choosing the latter as the event amplitude requires a local-decrease classification. It is not an absolute-value fix. A2 is unquantified. |
| C02 row 309, saved surge site 1/event 4 | Automatic A1 −0.9830%; reviewed maximum +1.0196%, minimum −8.3634%; W=536–556, R=516–535. B changes 1857.9871→1866.5308. | Upward maximum versus downward magnitude: **1.0196% versus 8.3634%**, conditional on which local event is recognized. Preserve preceding recovery contact at frame 516. A2 is unquantified. |
| C02 row 321, saved surge site 5/event 1, researcher-described pocket | R1 automatic unavailable; R2 has 12 accepted samples, 165–176, B=5137.8256; W=177–195. Reviewed A1 minimum −14.1681%, maximum +6.0209%; native-eligible reference count 0/12. | A reviewed local-decrease interpretation would use downward magnitude **14.1681%**, not the saved-surge maximum **6.0209%**, under A1. This does not establish the A2 magnitude or authorize relabeling. Preceding pocket near 155–165 remains context; 12 samples do not satisfy R1. |

For rows 308/309, reference and interval changed together in the saved comparison.
The observed changes do not isolate a baseline-only effect. Original reference
samples inside reviewed intervals number 7 and 4 respectively (2 for row 186).
This is direct evidence that onset choice affects whether a pre-event reference
really precedes the event, not a reason to fit a baseline to the desired answer.
Reviewed direction judgments remain uncertain; these examples cannot establish a
general automatic polarity rule by selecting their larger absolute extremum.

The old ID13 example, with three native events assigned one 444–688 interval,
shows another source of amplitude contamination: event identity/timing. Its
native-window counterfactual increased finite BOI sink amplitudes 723→790 but
opposite-direction amplitudes 7→10. Native timing is not an automatic correctness
fix. That historical fifth/seventh-order behavior must not be asserted as a
reproduced defect in the current implementation.

## 5. What the existing synthetic evidence says about the target

| Existing constructed condition | Current A1 result (sink / surge) | Scientific implication |
|---|---|---|
| Clean pulse on constant reference | 20% / 20% | Observed change and imposed component coincide in this simple case. |
| Unmarked same-sign precursor in reference | 16.67% / 15.38% for an imposed 20% component | “Immediately before” is not sufficient evidence of event-free baseline. Changing numerator alone cannot rescue a contaminated reference. |
| Background rises 0.2 units/frame | 16.90% / 21.62% for an imposed 20% component | A1 includes background change. A2 is a plausible comparator, but its peaks under the stored correction have not been established by this table. |
| Background falls 30 units as event starts | 50% / −10%, with a ±20-unit component relative to 100 | A1 measures the observed sum correctly. If the background component were known and removed, the component relative to the original 100-unit scale would be 20%. That does **not** establish that cubic correction recovers 20%, or that dividing by a contemporaneous 70-unit background would yield the same quantity. |
| Activity alternates between two pixels | 10% / 10% fixed-union amplitude; 20% at active pixel | The proposed target remains footprint-averaged; no claim to recover moving-pixel peak amplitude. |

These distinguish a wrong implementation from a correctly implemented but
scientifically different quantity. The 1,300-event source audit and 34-case
amplitude challenge validate their recorded arithmetic, not the preferred target.
Neither evidence establishes a calibrated oxygen concentration or a biological
cause for slow trends. An abrupt biological/global change may be inseparable
from an “event” without additional assumptions; retain that uncertainty.

## 6. Bounded next decision and impact assessment

The immediate decision is **whether L3 + R2 for reviewed events + candidate A2
is the intended direction**, while retaining L1/R1/A1 as historical automatic
outputs and A1 as the observed-change comparator. Automatic baseline shortening,
automatic sign relabeling, new correction fits and replacement of the detector
are not proposed. The current reviewed A1 branch also remains unchanged.

If that direction is approved, prepare one offline numerical comparison, not a
reporting-validation campaign:

- Seven fixed event identities: the two distinct ID400 examples, one FB2312
  example, and C02 rows 186/308/309/321. Use only saved traces/trends, original
  baseline memberships and the already accepted reviewed frames and intervals.
- At most **14 real-event reference/interval combinations**: one per ID400 and
  FB2312 example; original plus four reviewed combinations for row 186; original
  plus reviewed for each of 308, 309 and 321. For each, hold R/W/footprint fixed
  while comparing A1 and A2. Unavailable combinations stay unavailable, not filled.
- At most **four existing synthetic recipes**: constant-background pulse,
  same-sign precursor, linear rising background and falling-background step.
  Retain both signs inside each recipe. Compare saved results/ingredients only;
  if a required correction trace is not saved, report the A2 comparison untested
  rather than reconstruct a movie or silently choose a trend model.
- Maximum 18 comparison cases, one pass plus at most two affected-case rechecks
  for import/arithmetic implementation errors (20 evaluations total), two hours
  active work, no MATLAB launch, detector/statistics run, new recording access,
  threshold tuning or release/package work. None is authorized by this revision.
- Pin inputs, correction provenance and comparison code before execution. Check
  the samplewise decomposition independently with declared double tolerance
  `1e-10 * max(1,abs(expected))`; locate raw/corrected extrema independently;
  retain unavailable reasons, both signs, alternatives and source/support/version
  identity. Percent conversion does not change the underlying fraction.
- The outcome must quantify A1→A2 changes and distinguish those from the already
  joint baseline/timing changes. Show mixed/uncertain direction, trend removal
  and whether each target can be identified. Stop at missing provenance, a
  scientific mismatch, required new source processing or the budget. Do not tune
  rules to produce expected peaks or counts.

**Scientific go/no-go, not just arithmetic pass:** pursue A2 only if its exact
source/correction can be established and its change corresponds to the intended
local excursion on the saved evidence without claiming removal of unknown
biology. If the comparison cannot distinguish event from background, record the
limitation and retain A1 with that limitation; do not declare correctness solved.
A numerical local-direction threshold and representativeness beyond these
examples remain separate unresolved requirements before automated adoption.

Any subsequent adoption would require a new, versioned derived amplitude and
local classification alongside the original fields. It could change amplitudes,
polarity-specific summaries and availability; exact A2 changes are **not yet
known**. No such quantities may silently flow into counts, occupancy, composites
or published summaries. Researcher approval of measured impact is required before
scientific output changes. This request changes documents only.

## Evidence and preserved constraints

Sources: [source audit](EVENT_SIGNAL_AUDIT.md),
[historical signal investigation](reference-results/signal-audit-20260909/README.md),
[baseline/timing challenge](reference-results/boi-baseline-timing-20260912/README.md),
[reviewed/automatic comparison](BOI_REVIEWED_AUTOMATIC_COMPARISON.md),
[G4 exact replay targets](SOFTWARE_G4_REPLAY_TARGETS.md),
[current working specification](BOI_WORKING_ANALYSIS_SPECIFICATION.md), and
[workflow/traceability contract](RESEARCHER_WORKFLOW_AND_TRACEABILITY.md).
The [anchor record](planning/CC_01_EVIDENCE_ANCHORS.json) retains planning-time
sources and distinguishes the superseded reporting proposal from this revision.

No new scientific values, tests, MATLAB launch or recording run were produced.
BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain requirements. Keep source-specific craniotomy
support, dark interior and edge uncertainty; fixed footprints and external 1 Hz
for these supplied recordings; original correction and all saved results and
judgments. No cohort analysis, protocol inference, universal substrate model,
licensing decision or release/containment work. G5 and release remain incomplete.


## 30 September 2026 — researcher-guided rule framing

The [scientific decision view](SOFTWARE_CC_01_SCIENTIFIC_DECISION_VIEW.md#proposed-scientific-rule-framed-by-these-judgments) now frames a proposed episode-level rule using the researcher's pockets in all three green phases, approximate FB2312 onset at 398 and possible preceding C02 lilac-phase surge. Pocket decline and recovery are considered together; a separate positive event needs evidence beyond rebound or a positive detector score. Reference contamination, recognition without an available amplitude and spatial extent as supporting evidence are explicit. Broader hyperemia with local pockets remains a hypothesis. No replacement reference, amplitude estimator, label rule, boundary, spatial threshold or recording run is approved; this addition is planning only and changes no completed CC-01 evidence.

The researcher subsequently agreed (“i agree”) to this interpretive foundation on 30 September 2026. Episode and reference semantics are accepted for framing the next decision; exact boundaries, reference samples, numerical criteria and any replacement amplitude or label implementation remain undecided. No additional calculation or run is authorized by that agreement.
