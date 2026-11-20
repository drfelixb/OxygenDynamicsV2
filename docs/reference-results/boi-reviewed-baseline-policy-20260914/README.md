# Reviewed-event baseline policy proposal

14 September 2026. **R2-REVIEWED-BASELINE-POLICY-059 — proposal preparation
complete; scientific adoption and implementation remain open.**

The readable proposal is `existing-analysis/docs/BOI_REVIEWED_BASELINE_POLICY_PROPOSAL.md`;
the structured version is `existing-analysis/docs/planning/boi-reviewed-baseline-policy-20260914.json`.
The latter is also retained here as [proposal.json](proposal.json). The readable
document's exact bytes are preserved as `proposal.md.txt`.

The recommendation retains the original immediate 20-sample rule at external
1 Hz, both-sign native-overlap screening, original fixed footprint and
preserved-input amplitude source. A future reviewed calculation would be a
separate exploratory result anchored to the reviewed onset, with all boundary
alternatives and recognition uncertainty intact. Anchoring to reviewed onset
is a new derived definition and needs versioning before calculation/export.

The proposal explicitly distinguishes numerical eligibility, physiological
reference suitability and the original automatic measurement. It does not
require a flat trace, infer a substrate model or discard biological variation.
Reviewed recovery contact is flagged rather than automatically excluded under
recommended option A. The stricter option B is shown as an unadopted alternative.

| Reviewed onset | Reference | A: native-eligible samples | B: additionally veto shared reviewed intervals |
|---|---|---:|---:|
| 536 | 516–535 | 20/20; contact at 516 flagged | 19/20; 516 additionally excluded |
| 496 | 476–495 | 20/20 | 20/20 |
| 177 | 157–176 | 0/20 | 0/20 |
| 1153, preferred | 1133–1152 | 15/20 | 15/20 |
| 1149, alternative | 1129–1148 | 19/20 | 19/20 |

A's counts are reused from phase 057 and its native contributors verified in
phase 058. B subtracts the single verified contact at 516 from the eligible
set. Neither option has been applied to production. These are set counts,
not new means or amplitudes. Full-count windows still need finite-positive
reference and finite-event-signal checks before any derived amplitude can be
reported; physiological suitability is a separate unresolved question.

All five rule decisions remain `proposed`; adoption reviewer, decision, date,
rationale and scope are empty. Current human annotations retain onset 1153
as intentional and preferred, 1149 as its alternative, and recovery 1166/1167
without a preference. All four saved recognition statuses remain `uncertain`.
No new human annotation or scientific assessment has been recorded.

The first implementation increment is a read-only reference preview with exact
frame lists, excluded-event links and context flags. It needs no new amplitude,
raw movie processing, detector rerun or blanket manual review. Subsequent
derived calculations require policy selection and versioned measurement
definitions. Cohort admission, automatic timing changes and composites remain
separate work.

## Verification and preservation

`generateProposal.py` builds five reference-window cases from frozen source
records and includes the four actual annotations unchanged. `verifyProposal.py`
checks the exact candidate/excluded lists, contributor identities, seven
reviewed combinations, current preferences, option-B set subtraction, absence
of adoption, formula guard specification, source bindings and document links.
There is no signal-mean, amplitude, correction or detector calculation in this
phase, so no MATLAB execution or new production tests were needed.

All 476 MATLAB files and the original dictionary, earlier policy and review
remain unchanged. All 78 sealed phase-058 artifacts are preserved; the prior
bytes of the two appended standing ledgers are in `before-standing-docs`.
`inputs.json` binds ten exact source snapshots. `verification.json` and
`preservation.json` record the completed checks. The current readable/structured
proposal, standing ledgers and evidence copies are sealed in
`artifact-record.json`; completion status is in `completion.json`.

This is BOI development evidence from the same guided FB2314 recording.
Biological variability, physiological relevance, feasibility, usability,
traceability and all earlier anatomical, normalization, cohort, recognition
and independent-validation uncertainties remain standing requirements.
