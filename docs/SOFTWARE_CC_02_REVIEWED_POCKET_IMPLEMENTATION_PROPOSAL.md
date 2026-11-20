# CC-02 — reviewed pocket quantities in the existing workflow

30 September 2026 · **Bounded proposal; implementation and checks await approval.**
Owner: Codex assistant. Scientific/usability acceptance: researcher. Review reporting: assistant self-review unless an independent reviewer actually participates. Release remains paused.

## Decision already made and user benefit

The researcher accepted the [three-pair numerical comparison](SOFTWARE_CC_01_SCIENTIFIC_DECISION_VIEW.md#approved-three-pair-numerical-comparison-30-september-2026) within its limits and selected **corrected signed trough, as percent of positive raw reference intensity**, as the primary *exploratory* optical quantity for researcher-reviewed pockets, with raw signed trough alongside it. This is a selected scientific meaning for the reviewed workflow; it is not an implemented default, validation of physiology, an automatic-label rule or release acceptance.

This slice would let a researcher save an explicit pocket interpretation, exact episode/reference samples and suitability qualifications, reopen the same reviewed result and export understandable evidence without reconstructing scripts. Existing automatic measurements and detector provenance remain visible. It does not infer frames or convert every saved sink/surge into a reviewed pocket.

## Named scope and working behavior

Only the existing BOI event review, saved-result inspection and selected-evidence export are extended. Work items share one reviewed data service and existing trace/hash/revision mechanisms. No new application, batch/cohort feature, recording run, source-image reconstruction, detector/statistics execution, correction fit, footprint inference or package/release work.

| Item | Concrete change | Acceptance |
|---|---|---|
| CC-02-01 — definition and review record | Add a versioned exploratory pocket definition and a revisioned judgment linked to exact audit/event identity, boundary revision and selected frames. Record reference suitability and endpoint status explicitly. | Review choices survive save/reopen; old records remain readable without silently acquiring new semantics. |
| CC-02-02 — calculation and saved correction binding | Calculate the two signed minima on identical explicit W/R and unchanged fixed footprint; bind saved correction and its origin/hash. Add a narrowly verified historical-metadata adapter if needed for the two named legacy audits. | Three named numbers replay within tolerance; missing/mismatched ingredients produce explicit unavailable/rejected results. No regenerated correction or modified historical audit. |
| CC-02-03 — review usability | Extend existing Researcher boundaries/Reviewed reference/Reviewed optical controls for pocket interpretation, exact samples, suitability, reason and observed-end status. Show primary/companion quantities and warnings together with automatic results. | Explicit action is needed to save a revision. Event selection alone does not calculate/adopt a pocket judgment or suggest replacement frames. |
| CC-02-04 — persistence and saved-result reopen | Save reviewed evidence as a separate immutable local artifact linked to the selected audit/result; attach/reopen it using existing review and saved-result routes. | The saved values, frames, flags and correction/footprint identity reopen without the recording or detector. Changed dependencies cannot silently reuse stale values. |
| CC-02-05 — selected-evidence export | Extend existing export with readable methods/results, structured reviewed evidence and exact sample ingredients; show automatic/legacy and new exploratory quantities separately. | Export/reopen retains conditional/unavailable status, unresolved recovery and saved footprint origin. Automatic sheets, audit and RunIndex are preserved. |

Implementation should reuse or extend `buildBOIReviewedOpticalPreview`, `createBOIReviewedOpticalPanel`, `createBOIReviewedReferencePanel`, `openBOIEventReview`, `exportBOIEventReview` and the saved-result review entry. Introduce only small helpers where the old raw definition cannot be extended compatibly. Keep `computeBOIReviewedOpticalInterval`/the hash-bound 0.1.0 draft available for legacy raw results. Do not rewrite the hard-coded G4 demonstration bundle or its two replay targets as a general review store.

The current boundary validator has a strict field list and a `RecoveryFrame` concept; the current reference loader accepts only accepted judgments. A **new versioned reviewed payload**, rather than unknown fields silently added to old contracts, must represent conditional reference and unresolved recovery. The existing reference preview's need for both native masters remains its native-overlap contract. The new saved-quantity calculation must not claim native-overlap validation when those masters are absent: use the source-bound saved footprint/correction for calculation and report native context as unavailable where necessary. Do not launch a recording or require missing overlap context to be reconstructed.

## Exact numerical and suitability contract

Proposed new definition ID: `boi-reviewed-pocket-optical-0.2.0-exploratory`. New reviewed payload schema: `boi-reviewed-pocket-evidence-1`. Both are proposal names, not files already implemented.

For explicitly recorded event frames W and reference frames R:

- `B = mean(r(R))`, finite and strictly positive.
- Primary: `100 × min((c(W) − mean(c(R))) / B)`.
- Companion: `100 × min((r(W) − B) / B)`.
- c is the matching saved corrected trace, or raw minus its matching **saved** trend. Keep the exact source and transformation in provenance. Never use normalized/filtered score as c or fit a missing trend.
- Retain all tied minimum frames for each quantity; same footprint and selected R/W, though raw/corrected extrema may occur at different frames. Negative denotes decrease; no absolute value, sign clipping or saved-sign-dependent extremum choice.
- Fractions and percents have explicit fields/units. These are optical changes, not percentages of tissue oxygen or absolute pO2.

Separate arithmetic status from scientific suitability. Reference states are `accepted_local_state`, `provisional_local_state`, `unsuitable`, `not_assessed`; require reviewer, revision time and reason. A provisional state may produce a **conditional** exploratory number. Unsuitable/not-assessed/empty reference produces no new usable measurement. Ordinary fluctuations are allowed; short sample count is reported, not silently extended or promoted to a 20-clean-frame pass. Existing automatic eligibility and both-sign overlap are context, not an automatic filter on explicitly selected samples. This slice supports the externally triggered 1 Hz clock already evidenced for the named recordings; unsupported or unverified clocks remain unavailable rather than being assumed from file timestamps. Reject nonfinite derived arithmetic, including overflow, and preserve unavailable values as JSON null / MATLAB NaN with an explicit reason.

Endpoint states include `recovery_observed`, `recovery_unresolved`, `recording_censored`. With unresolved recovery, a selected observation end bounds the saved calculation but must not be labelled a confirmed recovery time. Show observed sample span separately; withhold confirmed pocket duration. No local state or precise endpoint is inferred from a zero crossing, trough, saved detector sign or positive rebound. No new duration/integral estimator is included in this slice.

An explicit researcher pocket interpretation is a separate judgment linked to the saved detector event. It can coexist with `SavedDetectorSign=surge`. The display and export must state **“measured on saved surge footprint; pocket extent not independently established”** for the FB2312 and C02 examples. Original automatic measurement, old exploratory raw measure, source-specific support/edge uncertainty and detector schema remain separate. No derived reviewed number flows into event counts, occupancy, composites, statistics or automatic amplitude columns.

A record must contain: audit/event/source identities; review/boundary/reference revisions; exact W/R arrays; clock authority/frame origin; raw/corrected sample values; reference means and positive denominator; correction source/receipt/origin and hashes; immutable footprint pixel identities/hash and saved origin; scientific interpretation; suitability/endpoint flags and reasons; both quantities/minimum frames; arithmetic status; definition/software hashes; original automatic results/missingness; and preservation/export receipts. Missing correction evidence withholds the corrected quantity with a reason; an otherwise valid raw companion may remain available but must not be presented as the selected primary measure.

## Researcher journey and storage

1. Open the completed saved run or its saved audit and select an event. The automatic result and saved detector sign appear as before.
2. In the existing review controls, explicitly record a pocket interpretation, onset/observation-end frames and endpoint status. Enter exact reference frames with suitability and reason. Existing choices can be viewed; they are never inferred for a different onset/event.
3. Preview both measures with sample count, correction origin, footprint qualification and flags. Conditional is prominent beside the numeric value. Draft changes are clearly unsaved and are excluded from export until an explicit saved revision is selected.
4. Save a new reviewed evidence revision to a **new chosen destination**. Preserve prior revisions/audits/recordings. The saved-result workflow attaches/selects this artifact; do not modify the completed run's automatic index or claim a new completed analysis run.
5. Reopen the saved reviewed artifact and export selected evidence. Reopening displays saved values; replay is a distinct explicit verification operation. Portable exports embed selected ingredients and identities so they can be inspected without old machine paths. They validate internal hashes and report external source verification as unavailable when the original files are absent.

Explicit replacement of a selected judgment revision invalidates/requires a newly computed reviewed result; it does not update an earlier artifact in place. Unknown/incompatible versions fail clearly. Legacy artifacts continue through their old raw-only view; they are not automatically migrated, relabelled or recomputed under the new definition.

## Frozen fixtures and acceptance matrix

Primary source fixtures are the three same saved audits and exact pairs, with the [comparison results](../../reference-validation/cc-01-three-pair-comparison-20260930/results.json) as numerical targets. Required inputs and source identities are in its [pin manifest](../../reference-validation/cc-01-three-pair-comparison-20260930/pins.json). The two historical conversion reports provide saved, source-matched dimensions; C02 declares FrameSize directly. Correction provenance must be checked, not assumed from a field name. Any adapter operates in memory or in a new disposable artifact; original MATs are unchanged.

| Case | Fixture/action | Required outcome |
|---|---|---|
| T01 | Historical ID400 row 41, W82–98/R73–81, 1,100-pixel saved sink footprint | Corrected −5.0523405688433565%, raw −4.328656254545948%, minima at 88; exact frame/footprint save→reopen→export round trip. Local reference is a fixture judgment, not newly established physiology. |
| T02 | FB2312 row 194, W398–417/R378–397, 3,684-pixel saved surge footprint | Corrected −8.362579856515431%, raw −8.138502968125097%, minima at 404; unresolved recovery/observed end and surge-footprint qualification persist through round trip; no confirmed duration. |
| T03 | C02 row 321, W177–195/R165–170, 5,086-pixel saved surge footprint | Corrected −12.383756977559301%, raw −11.104931801071126%, minima at 186; **conditional** six-frame reference everywhere; automatic amplitude stays unavailable. |
| T04 | `reference-validation/software-g2-workflow-20260923/gui-run` plus `reference-validation/software-g4-evidence-20260927/saved-bundle-final` and the retained 0.1.0 raw reviewed definition | Automatic saved-result navigation and legacy raw-only evidence retain old meanings; no automatic new pocket calculation or upgrade. |
| T05 | Small saved-vector copy with correction ingredient removed | Corrected primary unavailable with reason; raw companion may remain explicitly separate. |
| T06 | Copy with correction/source association hash mismatched | Reject computation/save/attach rather than substituting a trend or score. |
| T07 | Copy with fixed-footprint identity altered | Reject identity mismatch; do not resize/redefine support. |
| T08 | Copy with referenced boundary/judgment revision altered | Stale result cannot be silently attached or exported as current. |
| T09 | Small fixture with selected reference overlapping W | Reject malformed frame selection before calculation/save. |
| T10 | Small fixture with one nonfinite selected reference sample | Unavailable; never drop the sample. |
| T11 | Small fixture with nonpositive raw reference mean | Unavailable primary and companion; never divide by corrected mean. |
| T12 | Judgment changed to unsuitable | New reviewed measurements withheld; original automatic and earlier immutable artifacts remain visible as history. |
| T13 | Small fixture with empty reference | Explicit unavailable state; no inferred replacement samples. |
| T14 | Exported reviewed payload with incompatible schema version | Reject as unsupported on attach/reopen; no silent migration. |

These are **14 named cases**. Each case can contain its specified calculation/serialization/UI assertions, but no unlisted scientific variants. T01–03 each include one export and saved-artifact reopen using a new disposable destination. Routine arithmetic includes scalar replay and same-frame/support assertions with `1e−10×max(1,abs(expected))` percent tolerance. Hash gates preserve fixtures and automatic payloads. The GUI walkthrough checks all three qualifications, exact sample membership and the save/reopen/export path. T04's G2 event is compatibility evidence only, not a fourth pocket calculation target.

The old 18-case and three-case CC-01 budgets remain historical/consumed. These future checks belong to CC-02 only after separate approval.

## Finite implementation/verification budget and stops

Recommended approval covers CC-02-01 through CC-02-05 as **one integration-and-repair slice**:

- Four active implementation hours maximum; stop and report remaining work if exhausted.
- At most **20 case evaluations total**: the 14 named cases once plus up to six affected-case rechecks after routine software repairs. At most four validation batches and two ordinary MATLAB session starts, used solely for saved-data tests and GUI review. Session starts are not detector or recorded-movie attempts.
- Zero `ui.Run`, master, detector, statistics engine, real/synthetic movie analyses, new correction fits or footprint changes. Saved-vector arithmetic and UI/export fixtures only.
- Disposable outputs only, at most 500 MiB additional evidence, no overwriting source/prior output/export, no package or publication.
- Routine parsing, serialization, precision, UI wiring and compatibility defects can be repaired and affected checks repeated within the finite budget without per-error approval. Preserve initial failures and report consumed budget accurately.
- Stop on changed/missing source identity or correction provenance in a primary fixture, inability to preserve automatic/legacy outputs, a need to infer scientifically meaningful samples/support, a real-engine execution route, budget exhaustion or any material expansion. Do not fix that by rerunning a recording, silently modifying a contract or loosening acceptance.

Delivery is one working reviewed workflow, named-case pass/fail/untested results, exact pre/post hashes, retained failures, a concise usability walkthrough and the limitations. Acceptance is this bounded exploratory integration; it does not validate physiology, release readiness, every acquisition, broader dependency closure, or deferred live/resource blockers. No independent review is claimed unless it occurs.

## Approval boundary and alternative

The requested decision is approval of the complete CC-02-01–05 scope and finite budget above. This document itself authorizes no code, MATLAB launch, test execution or new calculation. Alternatively, retain the accepted three-pair comparison as standalone exploratory evidence and defer workflow integration. Both choices preserve the selected scientific meaning, prior outputs and paused release work.
