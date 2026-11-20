# CC-01 — distinguish detection contrast from optical amplitude

29 September 2026. **Planning only; implementation and validation await approval.**
Owner: Codex assistant. Scientific decision owner: researcher. Release work is
paused at the researcher's request; accepted F07-03I and all open release gates
retain their status. This card proposes one finite reporting slice, not a new
detector, baseline policy or recording campaign.

## Recommended decision

**Keep the existing calculations and make their two different meanings explicit
in one source-bound, saved-example report.** Show the saved detector label and
normalized score separately from preserved-input optical change; show automatic
and already saved exploratory reviewed measurements separately. Keep signed
extrema visible where already available. Do not make the score an oxygen amplitude,
flip a negative amplitude, relabel a surge as a sink, or replace an unavailable
automatic amplitude with a reviewed value.

This is the recommended first correction to reporting because existing evidence
shows internally consistent arithmetic with different quantities being compared.
It does not prove that the existing normalization is the best biological detector.
No default scientific rule needs to change to communicate the current results
correctly. The deliverable is a readable report and companion structured record
for the eight cases below, not an application-wide UI rewrite.

## Current calculation meanings

| Quantity | Current meaning and units | What it does not establish |
|---|---|---|
| Corrected intensity | Detection input after recording-specific pixelwise cubic detrending; primary visual shape/timing view, in input-intensity units. Detection may use a denoised source when explicitly saved. | Neither an optical denominator nor a universal substrate-consumption correction. A removed trend can contain biological variation. |
| Normalized detection score | For detrended intensity D, frame normalization is A(p,t)=(D(p,t)−mean over support D)/sample SD over support D. Temporal normalization is Z(p,t)=(A(p,t)−mean over time A)/sample SD over time A. Spatial averaging and temporal smoothing form the filtered score. Dimensionless normalized contrast. | Not percent intensity change, pO2, or a probability. A mean filtered footprint trace is not the detector's pixel/region admission rule and need not retain unit variance. |
| Saved sink/surge label | Negative/positive dynamics admitted by the saved detection and region/event rules in that normalized representation. Preserve saved support and sign. | Does not guarantee a decrease/increase relative to a local preserved-input baseline, or establish biological recognition. |
| Automatic optical amplitude (BOI-M06) | r(t) is preserved-input mean over the event's fixed native-union footprint; B is its valid pre-event reference; q(t)=(r(t)−B)/B. Sink: −min(q); surge: max(q) over the saved measurement interval. Stored fraction and explicitly ×100 percent are distinct units. | Not calibrated oxygen change, not a corrected-score extremum, and not necessarily positive. Fixed-union averaging differs from a moving active-pixel peak. |
| Reviewed optical result | Same preserved-input footprint, but the exact accepted reference frames and each saved reviewed interval. Existing exploratory results expose min(q), max(q), saved-sign amplitude, integral and availability separately. | Not a replacement for automatic output or a new global reference-length rule; finite arithmetic does not settle recognition or physiology. |

Current `normalizeToZStat.m` divides by **SD, not sqrt(SD)** in both stages.
Zero-variance normalization produces computational zero under its explicit
handling, not evidence of biological absence. The `craniotomy-roi-1` profile
restricts reductions and smoothing neighbors to the saved mask; historical
whole-image runs use different spatial support. Do not reinterpret the old
normalization evidence as proof that every current ROI recording has the same
behavior. Dark interior tissue and uncertain anatomical boundaries stay intact.

Automatic baseline: request the immediately preceding `round(20*fs)` samples
before the **saved measurement start**, screen nonfinite values and overlap with
either-sign native masks on the event footprint, and require the full count.
No earlier replacement, post-event fallback or shortening. Positive finite B and
finite event samples are required. Missingness stays missing and never removes
otherwise available detection counts or native coverage. For the supplied 1 Hz
recordings this is 20 samples; frame 1 is modeled time 0, not a timestamp or
exposure assertion. A manually accepted 12-sample reference is a separate judgment.

Historical-version caution: the 9 September source-audit report describes older
fifth/seventh-order sink trace/timing behavior. Current master code uses
second-order additional sink site-trace detrending; do not call the old timing
problem a newly reproduced current defect. Event-footprint scores, whole-site
traces and native/refined intervals must retain their own labels and versions.

## Saved examples and their numerical consequences

These numbers are quoted from existing evidence, **not newly computed results**.

| Example | Existing evidence | Required reporting consequence |
|---|---|---|
| Historical ID400 awake, sink site 11/event 1 | Raw minimum is +0.350% relative to B, so sink amplitude is −0.350%. Cubic-fit component +3.143 percentage points and residual −2.793 explain the recorded decomposition. | Retain negative sink amplitude and normalized-trough label together. No absolute value or claim that the removed component is instrumental drift. This is not the G2 ID400 event below. |
| Historical FB2312 awake, surge site 1/event 2 | At the raw amplitude extremum, baseline-relative change is −18.580 detrended units, then +0.211 spatial-normalized units and +0.596 final normalized units. Six flagged FB2312 surges show the reported stage-direction change. | Show each stage in its own units. A relatively brighter location can still fall in local intensity. These are not three interchangeable amplitude estimates. |
| G2 ID400 awake, sink site 1/event 3 | Frames 431–457, native 436–440; B=90.908506224066386 from frames 411–430; minimum=85.860995850622402 at frame 435. Saved amplitude 0.055522971205831419 = 5.5522971205831419%. | Positive finite control with exact saved ingredients; preserve its source identity separately from C02 and the historical ID400 audit. |
| FB2314 awake/immobile C02 row 186, sink site 15/event 36 | Automatic 1156–1165: 14/20 clean baseline samples, amplitude unavailable. Separate reviewed onset 1154 with reference 1134–1153: B=3791.7652 and signed minimum −17.7058%, sink amplitude +17.7058%; offsets 1166/1167 remain alternatives. Onset 1149 lacks an accepted reference. | Keep automatic missingness. The already computed exploratory result may be cited separately, never backfilled into automatic output. The G4 bundle deliberately carries no reviewed amplitude; do not rewrite it. |
| C02 row 308, saved surge site 1/event 3 | Automatic → reviewed 496–516: saved-sign amplitude −2.0645% → +1.0779%, while reviewed signed minimum is −9.5218%; reference 476–495. | The positive reviewed maximum is not the downward excursion. Bounds and reference both changed; this comparison does not isolate either effect. |
| C02 row 309, saved surge site 1/event 4 | Automatic → reviewed 536–556: saved-sign amplitude −0.9830% → +1.0196%, reviewed minimum −8.3634%; reference 516–535. | Preserve contact at the preceding recovery frame 516 and the two definitions; no claim of a biological surge from the positive maximum. |
| C02 row 321, saved surge site 5/event 1, described by researcher as a pocket | Automatic amplitude unavailable. Reviewed 177–195, selected reference 165–176 (12 samples): minimum −14.1681%, maximum/saved-surge amplitude +6.0209%; 0/12 samples meet the automatic native-exclusion criterion. | Keep saved surge identity and researcher description distinct. The accepted shorter reference is not a repaired automatic baseline; preceding activity near 155–165 remains context. |
| Saved synthetic falling-background example | Imposed +20-unit component with a simultaneous −30-unit background change from a 100-unit reference gives an observed surge amplitude of −10%. | Numerically correct observed change is not recovery of the imposed component. This is a constructed example, not an explanation of any animal recording. |

The historical source audit found agreement for **1,300 events**, including
17 finite amplitudes opposite the saved direction (7 sinks/10 surges); this is
historical arithmetic evidence, not a current-code pass or a false-positive rate.
The prior baseline challenge passed 34 amplitude and 10 timing cases under its
recorded definitions. Those results support the distinction, not physiological
validation or a reason to rerun the full matrix now.

The earlier ID13 example (three native events sharing one expanded historical
measurement interval) also shows why exact saved timing must accompany amplitude.
It is background evidence only, not a ninth proposed case or authorization to
replace timing. Current biological onset/recovery and general reference suitability
remain unresolved.

## Proposed impact and boundaries

**Expected numerical impact: zero change to scientific outputs.** Original
amplitudes, scores, means, integrals, boundaries, masks, labels, missingness,
counts, occupancy and summaries remain unchanged. A new report can show the
existing fraction as `100 × fraction` with an explicit percent label; this is
unit presentation, not a new estimator. Printed rounding is separate from full
precision. The quoted automatic-to-reviewed differences already exist and are
not numerical changes proposed by this card.

New report fields identify quantity, units, source hash, definition/version,
footprint/support, automatic versus reviewed role, exact baseline membership,
measurement/native bounds and unavailable reason. A negative saved-sign amplitude
is described as opposing the saved detector direction, not automatically a false
event. Zero and unavailable values must not be called directional disagreement.
Do not derive a new reviewed amplitude for C02 row 186 or a new denominator for
any example. No new aggregation, pO2 conversion, composite, corrected-intensity
ratio, universal decline model, relabeling or scientific schema migration.

## Finite validation plan, only after approval

Eight named cases correspond one-for-one to the eight rows above: **CC01-A**
ID400 historical discordance; **B** FB2312 normalization; **C** G2 finite replay;
**D** C02 row 186 (all four existing boundary combinations, with availability);
**E** row 308; **F** row 309; **G** row 321; **H** saved synthetic falling background.

- Budget: eight initial case evaluations, at most **ten evaluations total** to
  permit two affected-case rechecks for ordinary report/import/formatting defects;
  one report candidate and at most one revised report in fresh output directories;
  at most two hours of active work. No automatic extension or additional cases.
- Use existing saved audit MAT data via a read-only offline reader, saved JSON and
  prior verification records; no source TIFF, external acquisition drive, MATLAB
  launch, detector, statistics or recording execution. No reconstruction of a
  full detection stack. Missing required saved ingredients stop the affected
  case as untested; do not regenerate them or substitute another recording.
- Before evaluation, pin exact input and reporting-harness hashes. Resolve and
  verify original checksum associations and source/row identities. Historical
  evidence must retain its version; a fresh hash alone is not provenance proof.
- For C, replay the already approved amplitude from the saved baseline/window
  ingredients to `1e-12 * max(1,abs(saved))`. Do not use rounded report values as
  authoritative inputs. For A/B, compare the report to saved audit stage values
  and units, not a new detector reconstruction. For D–G, preserve full-precision
  saved original/reviewed numbers, frame sets, statuses and all alternatives;
  check displayed rounding and fraction/percent conversion. Do not recompute
  reviewed biology or reinterpret automatic eligibility. H checks the retained
  synthetic arithmetic evidence; no new synthetic detector execution.
- Final check: all source inputs unchanged, no automatic value overwritten or
  missing value filled; rows remain traceable and distinct; one readable report
  and matching structured record. Separate pass/fail/untested per case and state
  self-review honestly. No package rebuild or general regression suite.
- Stop/report on a scientific numerical mismatch, ambiguous identity, missing
  authoritative ingredients, required recording access, scope expansion or
  budget exhaustion. Routine report-only errors may use the remaining rechecks;
  any proposed estimator/source/baseline change needs a separate numerical-impact
  decision before implementation. Passing these cases is bounded arithmetic and
  reporting evidence, not G5 or release acceptance.

## Evidence anchors

Read-only preparation used [source-audit definitions](EVENT_SIGNAL_AUDIT.md),
[historical normalization/source results](reference-results/signal-audit-20260909/README.md),
[baseline challenge](reference-results/boi-baseline-timing-20260912/README.md),
[current working specification](BOI_WORKING_ANALYSIS_SPECIFICATION.md),
[automatic/reviewed comparison](BOI_REVIEWED_AUTOMATIC_COMPARISON.md),
[G4 exact replay ingredients](SOFTWARE_G4_REPLAY_TARGETS.md) and current normalization,
preprocessing, master and measurement-finalizer source. Their planning-time
hashes and exact saved input locations are in
[CC-01 evidence anchors](planning/CC_01_EVIDENCE_ANCHORS.json).
No numerical test or scientific recalculation was performed to prepare this card.

**Decision requested:** approve CC-01's reporting distinction and zero-change
numerical impact, with the bounded eight-case saved-evidence validation above.
Alternatively defer it and keep the current reporting unchanged. Release work
remains paused either way. Approval is not requested for changing the scientific
normalization or baseline rules; those would require a separately stated target
quantity and numerical comparison before adoption.
