# Signed integrals, composites, summaries and export identity

4 October 2026 · NEXT-03 · Owner: implementation assistant

Researcher approved Step 3 as one complete calculation-and-repair task and
accepted Step 2 within its arithmetic/export scope, retaining failures/limits.
Preserve all uncommitted Step 2 checks/documents (initial-worktree-pins.json).
Benefit: researchers can reproduce signed integrals, composite normalization
and recording/mouse/group averages and identify which code calculated a result.

Start: development-existing-analysis-v3, production commit
b0f6d20be415f9dc64f99c05585147e21633d8db, version 3.1.0-dev.1.
Scope: signed rectangular optical trace integrals, sink amplitude-area-duration
composite, its area/time factors, strict/finite summaries and zero events, plus
original-versus-current reader/exporter identity. Correct definitions stay.

Exact saved statistics packets:
- software-g2-workflow-20260923/gui-run/statistics/Stats_Output_20260923T102730
- boi-c02-strict-roi-20260912/run-01/statistics/Stats_Output_20260912T155949
under reference-validation. Associated saved trace ingredients only:
- software-g2-workflow-20260923/gui-run/Recording/BOIReview/event-amplitude-audit.mat
- boi-c02-strict-roi-20260912/audit-01/source-amplitude-audit/event-amplitude-audit.mat

All saved files are SHA-256 pinned before work. Ingredient-only inventory precedes
independent expected answers; no source movie is opened. Missing ingredients
are reported, never regenerated. Six tiny fixtures plus two saved cases max.
Frozen numerical values/case names will be recorded before evaluation.

Budget: five active hours, four batches, 32 focused case evaluations, two
saved-data-only MATLAB sessions and 100 MiB total new evidence. One case is
one frozen scenario, its relevant signs/calculations/export checks; a repeat
consumes another evaluation. Eight cases maximum per full batch. No accepted
whole test matrix is repeated. Routine harness/metadata repairs use this budget.

Static provenance finding: writeOxygenAnalysisManifest labels current code as
Pipeline version without distinguishing historical calculation identity. Add
explicit original calculation software/contract and current reader/exporter
metadata, using unknown if original software is absent. Retain original metadata
and values. This is a metadata repair, not a scientific-output change. Adopt
3.1.0-dev.2 for the changed development snapshot with a current build timestamp;
keep historical tags/contracts and saved software metadata unchanged.

Any numerical defect requires old/new scientific values and researcher review
before adoption. No automatic replacement, correction refit, detector or
statistics pipeline, recording, cohort comparison, release, Step 4 or commit/push.
Stop with a short guide, worked summary, final named checks and precise open
decision if any; update current status.

## Frozen cases and expected answers — before evaluation

Eight named cases, six small fixtures F01–F06 plus saved S01/S02. Exact registry
rows, event ingredients, clock/frame bounds and independent Python answers are
frozen in cases.json and saved-expected.json. Raw saved trace slices from the
source-matched audits support signed-integral replay; no source movie is needed.
Numeric EventIndex joins the separate event-area companion; display EventID
labels are not parsed. Inventory-dispatch failures/repairs remain recorded.

| Case | Exact focus / independent expected example |
|---|---|
| F01 | Reference [100,100], event [80,90,110,120], 2 Hz: signed integral 0 fraction-seconds despite nonzero excursions; both signs |
| F02 | Reference [100,100], event [80,90,100,90], 2 Hz: −0.2 fraction-seconds = −20 percent-seconds. Composite 20% × 4 µm² × 2 s = 160; area 2 mm², duration 4 s gives 80 per mm², 40/s, 2400/min, 20/mm²/s, 1200/mm²/min. Explicit saved original software 1.01 remains distinct from exporter |
| F03 | Mouse m1 recordings with 1 event at 10% and 2 at 20%; m2 recording with 5 at 100%. Strict within-mouse means 15 and 100; group 57.5%, SEM 42.5, 2 contributing mice. Pooled event mean 68.75% differs and is not substituted |
| F04 | Five-event recording with missing amplitude, area and duration plus excluded negative drop; two other recordings at 40% and 50%. Strict first total unavailable, finite event mean contribution 10 from 1/5; incomplete mouse composite withheld; group total from only complete m2 = 50, SEM unavailable. Amplitude mean group 40% from 2 mice |
| F05 | Three empty valid recordings (two m1, one m2): totals/rates 0, equal-mouse total 0 with 2 mice and SEM 0; event amplitude means unavailable with 0 contributors |
| F06 | Explicit older negative_drop_percent −10 and 0 become 10/0 only for composite; original amplitudes remain. Area 0.25 mm² and exposure 30 s: composite 40, 160/mm², 80/min, 320/mm²/min. Missing original software explicitly unknown |
| S01 | ID400 saved statistics: 94/192 valid composites, finite mean 1003036.007446943; strict total unavailable. First finite signed sink integral site 1/event 3 = −0.6169236773099568 fraction-seconds |
| S02 | C02 saved statistics: 142/305 valid composites, finite mean 288766.1237564371; strict total unavailable. First finite signed sink integral site 1/event 2 = −0.14716353205427493 fraction-seconds |

Expected signed integrals retain negative, positive, cancellation and unavailable
values separately for sinks/surges. Recording totals are strict; each mean has
its own finite contributing count, mouse completeness and equal-mouse weighting.
Workbook/CSV/MAT, time-series integration and provenance checks belong to each
case. No whole accepted matrix is repeated. Relative tolerance 1e-10 ×
max(1,expected); identity/counts and finite-versus-unavailable exact.

Both saved StatsInfo records lack CalculationSoftware. Their original software
version is unknown; recorded contract 3.1-roi-dev is a calculation identity.
Old manifests reported v1.01 when written, but that reporter label is not a
verified original calculator identity. Keep those manifests unchanged.

Frozen source/expectation hashes are in pre-evaluation-pins.json.

## Completion

Final 8/8 pass after three batches/24 evaluations; both saved-data sessions
exited 0. See [delivery](SOFTWARE_NEXT_03_DELIVERY.md). No scientific numerical
change or commit/push. Approval is consumed; Step 4 does not start.
