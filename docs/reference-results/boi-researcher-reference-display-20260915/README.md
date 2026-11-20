# Researcher reference display

15 September 2026. **R5-RESEARCHER-REFERENCE-DISPLAY-066** — implementation and
verification complete. No global baseline policy or new quantity is adopted.

Open a fresh MATLAB reviewer from the local workspace:

```matlab
addpath('/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-researcher-reference-display-20260915');
[Fig,UI] = openResearcherReferenceExample;
```

The launcher verifies all eight saved input hashes, loads boundary revision
05 and both native masters, attaches the four separate reference judgments,
and selects the pocket starting at 177. Earlier figures and the sealed older
launcher are preserved; already-open figures retain their previous callbacks.
The runnable launcher is in the local reference-validation folder; portable
MATLAB source copies here have `.m.txt` extensions.

Blue rings mark researcher-selected baseline frames. Native green/red marks
and amber reviewed contacts remain visible. The separate summary shows the
actual selected interval/count and native eligibility within that selection.
The frame table adds Researcher selected: 1 included, 0 outside the attached
selection, NaN for an onset without a judgment. No acceptance is inferred for
other onset alternatives. In particular, 1149 remains unjudged.

| Row | Onset | Reference | Selected samples | Native eligible within selection |
|---|---:|---|---:|---:|
| 186 | 1154 | 1134–1153 | 20 | 14 |
| 309 | 536 | 516–535 | 20 | 20 |
| 308 | 496 | 476–495 | 20 | 20 |
| 321 | 177 | 165–176 | 12 | 0 |

Use `UI.Select(row)` to navigate. The GUI button Load reference judgments
accepts saved JSON files after matching boundaries are loaded. Programmatic
`UI.LoadReferenceJudgments(paths)` accepts one path or a cell array. Loading
replaces the attached set; duplicate event/onset records are rejected. The
loader verifies boundary-file checksum, audit/event identity, annotation and
strict integer frame membership. Partial frame-acceptance records are not
silently treated as complete references. This increment supports selections
within the displayed preceding 20-second candidate only; wider selections
produce an explicit error. A failed replacement clears the old attachment.
Changed sources withhold preview/export until the appropriate files are loaded.

Export schema 8 / preview schema 2 retain exact original judgment documents,
paths and checksums alongside the separate membership column and typed MAT
preview. Original Data, automatic measurements, native support, event signs,
recognition statuses, correction, dictionary and statistics remain unchanged.
No reviewed reference mean, amplitude or integral is calculated. Twelve samples
remain twelve; the original twenty-sample requirement is not weakened or
silently applied to a new measurement. Missing judgments/count sufficiency
remain unknown. Guided examples are not independent biological validation.

Verification: 37 regression tests passed, then four focused tests passed on
final code, covering 38 distinct tests. Coverage includes both native signs,
shorter selections, onset alternatives, unknown native support, partial and
malformed records, duplicate/stale files, failed GUI replacement and exact
unchanged original MAT Data. Final real verification checks all 346 native
event associations, the four selected frame sets, alternative 1149, contributor
navigation, four fresh exports and all 56 export artifact hashes. All four
final screenshots were visually inspected. Final outputs are in `final/`;
`real-01/` preserves the earlier successful rendering/export pass. Local MAT
files retain exact typed evidence; portable copies omit MAT binaries.

Initial `tests-01` failures are preserved: JSON array orientation needed the
existing boundary canonicalizer, and two assertions expected the old export
schema. Both were fixed. Final missing-judgment count handling remains NaN;
a dedicated complete-versus-partial frame-judgment test verifies that branch.
The before snapshots and code-changes.patch document five changed MATLAB
files and the added loadBOIReferenceJudgments helper. 474 prior MATLAB files
are unchanged, for 480 current files. All 30 phase-065 sealed artifacts and
eight source hashes are preserved; standing documents are appended with prior
bytes saved. No commits, source-data edits or older artifact overwrites.

Next: inspect the updated display, then define and version any proposed
reviewed optical calculation, including how shorter researcher references
would be handled. Local reference judgments are not global policy adoption,
proof of resting oxygen or contributor false-positive labels. BOI-only scope,
biological variability, physiological relevance, feasibility, usability,
traceability and all unresolved scientific requirements remain in force.
