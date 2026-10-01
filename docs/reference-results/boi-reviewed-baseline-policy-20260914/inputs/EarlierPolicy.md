# BOI measurement-policy proposal

12 September 2026. **R0-R2-R4-POLICY-015: preparation complete; scientific
decisions proposed.** This document turns the completed measurement challenges
into five concrete decisions. It does not adopt a new rule, freeze the outcome
hierarchy or approve a recording. The [structured proposal](planning/boi-measurement-policy-20260912.json)
contains the same policy positions, evidence hashes, seven candidate pairs and
unfilled reviewer fields. Production calculations and dictionary 0.3.0-draft are
unchanged.

Use **C02 paired awake–isoflurane** as the worked proposal, following the existing
plan's proposed order. The researcher has not selected a final comparison
priority. C01 and the separate response/calibration families retain their roles;
these C02-specific choices must not silently become their analysis plans.

## Five decisions for scientific review

| ID | Proposed position | What accepting the position would mean |
|---|---|---|
| P01 — optical reference | Retain the current 20-second clean pre-event baseline for descriptive amplitude and signed integral. | Interpret a value as change relative to that preceding optical reference over the fixed native-union footprint. A different physiological reference would require a separately specified and tested measurement. |
| P02 — missingness | Keep all detections for descriptive coverage/count/concurrency; preserve unavailable and negative amplitude values. | Report finite-event summaries as conditional subsets, with event counts and native covered-support availability. Missing amplitude alone does not delete exposure or native coverage. |
| P03 — timing | Retain saved-boundary descriptive timing, native support and uncertainty diagnostics. | Do not call trace-refined boundaries physiological onset/recovery. Resolve the scientific onset/censoring policy before admitting the candidate primary onset rate. |
| P04 — outcomes | Carry forward candidate primary sink occupancy and onset rate, required concurrency/availability, explanatory both-sign measures and secondary sink composite. | Preserve the original proposed hierarchy. An essential validity failure requires an explicit outcome decision; a successful arithmetic test cannot waive it. |
| P05 — C02 contrast | Propose one isoflurane-minus-awake difference per eligible mouse and metric, then an equal-mouse mean of available paired differences. | Make a within-mouse state-associated comparison with explicit order/preparation limits, metric-specific pair counts and missingness. Event counts do not supply biological replication. |

Each decision remains `proposed`. Reviewer, decision, date, rationale and scope
are null in the ledger. Preparation by the implementation agent is not a
scientific acceptance or the independent researcher walkthrough.

## Reference and missingness: precise scope of P01/P02

The current amplitude trace averages preserved input values over the union of
the selected event's native pixels. Its baseline is the immediately preceding
`round(20 * SampleF)` samples before the **saved measurement start**, subject to
either-sign footprint overlap and nonfinite-value screening. The entire requested
sample count is required. No earlier replacement, post-event fallback or shorter
window is proposed. Peak and signed integral use the saved measurement interval;
the mean projected event area uses native per-frame masks. These supports differ.

The [fixed challenge](reference-results/boi-baseline-timing-20260912/README.md)
shows why the reference must remain explicit. A 20% imposed positive component
with a simultaneous 30-unit falling background gives a **−10%** observed surge
amplitude relative to the preceding 100-unit baseline. Alternating activity
between two pixels gives 20% at the active pixel and 10% over the fixed union.
Both results match the current arithmetic. These are constructed examples, not
an explanation of the HP signal or a calibrated oxygen measurement.

The [saved-support audit](reference-results/boi-measurement-support-20260912/README.md)
also shows that finite event counts do not describe the fraction of all detected
coverage represented by finite amplitudes. Its two development recordings do not
establish how missingness behaves across C02 mice or states.

For a future admitted summary, preserve these distinct states:

| Situation | Coverage/count/concurrency | Amplitude/integral and paired use |
|---|---|---|
| Successfully analyzed, positive eligible exposure, no events | Valid zero where the relevant support is known. | Event-amplitude mean is undefined; it is not zero. |
| Event present, insufficient baseline | Retain native coverage and event identity; other eligibility requirements still apply. | Keep NaN/status and clean-sample count. Do not impute zero or remove the event from coverage. |
| Finite negative directional amplitude | Retain event and signed optical result. | Do not reinterpret it as a positive drop/rise. Current sink composite rejects wrong-direction contributions; this proposal leaves that rule intact. |
| Missing native mask or invalid tissue/exposure | The affected normalized result is unavailable. | A finite raw optical amplitude cannot validate tissue-time or recording eligibility. |
| Only one state has an admitted metric | Preserve both state records and the unavailable reason. | That mouse has no paired difference for the affected metric; do not substitute an unpaired observation. |

For amplitude, propose a per-mouse/state mean of explicitly identified finite
event-relative values, alongside the event distribution, finite/total counts,
baseline reasons and unavailable covered-support share. This is a **conditional
event-amplitude summary**, not the mean over all biological events. The full
candidate-population effect remains unresolved when pair availability differs.
No numerical availability cutoff or missing-at-random assumption is supplied.

The 20-second event baseline is not a rule to remove the first 20 seconds from
coverage exposure, and it is not an experimental baseline for an evoked response.
Those would be separate window/exposure decisions.

## Timing and primary admission: precise scope of P03/P04

Current sink onset/concurrency use saved event intervals, which may be
trace-refined; occupancy uses native masks. Surges currently retain their saved
native timing. A result beginning at acquisition frame 1 is counted in the
existing descriptive onset calculation. An event already ongoing at a later
analysis-window start contributes overlap time but no new onset in that window.

Keep `AcquisitionStartOnsetsCounted`, `OnsetsAfterAcquisitionStart`,
`OngoingAtWindowStart`, native/measurement bounds and boundary-resolution statuses
visible. The acquisition-start-excluded count is an existing diagnostic, not an
adopted physiological onset estimator. Excluding that boundary alone would not
resolve missed onsets, split/merge identity or detection delay. No new exclusion
is applied here.

P03 proposes descriptive timing until a physiological reference, return/persistence
criterion, observation requirement and censoring policy are specified and
validated. This limits the current claim; it does not quietly demote the candidate
primary onset outcome. If its admission condition cannot be met, P04 needs an
explicit scope/hierarchy revision before final evaluation.

Retain the existing sink composite's unavailable total when required contributions
are missing or wrong-direction. Do not sum only available contributions and label
that number total burden. No surge composite is defined. The composite combines
amplitude, native mean area and potentially refined duration; it is neither native
union coverage nor a measured oxygen-deficit integral.

## C02 biological unit and candidate preparation

The [pair table](reference-results/boi-measurement-policy-20260912/candidate-pairs.md)
resolves all **seven candidate mice / fourteen assets** back to the existing
cohort ledger. Same-date and same-scale metadata are pairing evidence, not field
of view, intensity-comparability or signal-quality approval.

- FB2312, ID400 and ID401 are known development animals from the existing
  reference record. A different session from one of them is not an untouched
  evaluation animal.
- FB2314, FB2315, ID402 and ID403 have no fully audited prior-use assignment in
  that ledger. This does not establish independence. FB2314/FB2315 local source
  inspection is already documented.
- The U2 overlay retains FB2315's resolved local identity and unverified
  archive-payload equivalence. U7 remains a claim restriction. U8 is partly
  resolved; pair windows/wash-in still need evidence. G1/G2 remain open.

For an admitted metric, the proposed contrast is
`d_i = Y_i,isoflurane − Y_i,awake`, summarized by `mean(d_i)` with equal mouse
weight. Show each paired value and difference, metric-specific `N_pair`, and the
reason for every unavailable candidate. This is an association in an awake-first
sequence; it does not isolate anesthesia from order or preparation.

For multiple approved nonoverlapping intervals within a state, combine rate
numerators/exposure before forming the state rate. Do not accidentally average
rates with unequal exposure. Repeated sessions or different fields of view need
their own declared within-state rule. Per-state event-amplitude averaging and
across-mouse pairing are separate aggregation levels.

Uncertainty estimation, multiplicity, repeated-session policy, missing-pair
sensitivity, scientific acceptance criteria and final observation windows remain
unfilled. No significance test, confidence interval, model fit, power claim or
biological contrast has been calculated. All candidate eligibility fields remain
`not_assessed`; all approved-window and evaluation-animal lists are empty.

## Evidence needed before execution

The structured proposal distinguishes calculation availability, recording/metric
eligibility and scientific claim admission. Passing one layer does not approve
the next. It also records five validation requirements: known-support arithmetic,
end-to-end detection/identity, biological/acquisition variability,
measurement-specific eligibility, and feasibility/independent usability.

The deterministic challenge covers selected weak/strong, brief/sustained,
recurrent, cross-sign, drift and moving-support mechanisms. It does not close
animal variability, realistic noise, motion, contact/shape complexity or
end-to-end detection performance. Reuse the earlier reference/injection evidence
before proposing additional experiments; add a case only for a named gap.

HP remains a development example with unresolved identity, calibration and
support. Its confirmed external 1 Hz timing is authoritative; incorrect embedded
clocks and camera exposure remain separate provenance. Exploratory AQuA2 outputs
are not anatomical evidence. The independent MATLAB researcher walkthrough and
second-person replay remain required for R5 release.

Preparation stops at this reviewable proposal. The next independent work is an
animal-level audit of existing prior-use and validation records without opening
new outcomes. Adopting a new measurement, freezing evaluation, or executing a
scientific comparison requires the named scientific decisions and evidence first.

Sources: [reanalysis plan](REANALYSIS_UPDATE_PLAN.md),
[cohort resolution](BOI_COHORT_RESOLUTION.md),
[measurement dictionary](BOI_MEASUREMENT_DICTIONARY.md),
[workflow contract](RESEARCHER_WORKFLOW_AND_TRACEABILITY.md), and
[preparation checks](reference-results/boi-measurement-policy-20260912/README.md).
