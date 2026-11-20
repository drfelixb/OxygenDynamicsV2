# Four-example researcher review: saved history and exports verified

Record **R5-RESEARCHER-BOUNDARIES-054-W4**, 14 September 2026. The guided
four-example entry/persistence check is complete. Assistant-performed reopen
and export verification passed. Independent physiological validation, blinded
review, a complete independent usability walkthrough and release acceptance
are not established by this exercise.

The actual researcher file `BOI-researcher-review-04.json` contains four
revisions. The first three are exactly preserved from revision-file 03.
All entries are recorded by Felix and retain status `uncertain`.

| Saved event | Audit row | Current onset choices | Preferred onset | Recovery choices | Preferred recovery |
|---|---:|---|---:|---|---|
| Surge site 1 / event 4 | 309 | 536 | 536 | 556 | 556 |
| Surge site 1 / event 3 | 308 | 496 | 496 | 516 | 516 |
| Surge site 5 / event 1 | 321 | 177 | 177 | 195 | 195 |
| Sink site 15 / event 36 | 186 | 1149, 1153 | 1153 | 1166, 1167 | Unspecified |

These are discrete one-based recording frames. At the externally controlled
1 Hz clock, frame 1153 is modeled time 1152 s; it is not elapsed time 1153 s.
No amplitude, baseline, native mask, saved detector label or statistics method
has been recalculated from these judgments.

## Explicit change from the earlier review

The saved fourth revision used 1153 instead of the earlier preferred onset
1154. Its reason also names 1153. Before treating this as reconciled, the
assistant asked whether it was an intentional frame choice or a confusion
with modeled elapsed seconds. The researcher replied verbatim:

> 1153 is intentional, on the figures you had shown me it was hard ot distinguish if 1153 or 1154, it was no more clear to define.

The current preferred onset is therefore **frame 1153**. No correction to the
application file was needed or made. 1149 remains the current alternative;
1154 remains in the preserved earlier conversation evidence, rather than
being silently added to the current alternatives. The current recovery
choices remain 1166 and 1167 with no preference. The saved `uncertain` status
is not promoted to recognition or physiological acceptance.

`researcher-original-04.json` is an exact copy of the actual file, retaining
its original save time 2026-09-14T11:13:10Z. `onset-clarification.json` records
the direct reply separately. `earlier-feedback-01.json` preserves the earlier
review with its original wording/provenance, and its original path and
checksum are in `earlier-feedback-reference.json`. The application history
begins with these newly entered judgments; it does not pretend that earlier
conversation reviews were originally saved through this interface.

## Checks performed

The production MATLAB loader matched source/audit hashes, event identity,
frame clock, revision sequence and parent artifact checksum. The latest file
has four valid entries, and all prior measurement fields for all four selected
events are exactly unchanged when review metadata are attached.

Each `reviewed-event-row-*` folder contains an export of one selected event
using schema `boi-event-review-export-6`. Each export includes its selected
annotation plus the complete four-entry application history. All four
histories reopen against the matching audit; each MAT snapshot exactly
matches the selected review data, and all **44 exported artifact checksums**
pass. These exports represent the current researcher judgments, not the
phase-054 developer fixtures. Original audit and revision files are unchanged.

The first verification record accurately retains its then-pending
clarification state. The subsequent explicit clarification and export report
resolve the current frame choice without rewriting that earlier log. No
production code changed. The preceding phase's 179 sealed artifacts and the
65 sealed artifacts from the preceding walkthrough records remain preserved;
standing-ledger originals are snapshotted before appending the outcome.

The researcher explicitly confirmed event 4's line placement and reported
seeing event 3's purple lines. The other saves were reported as completed;
no extra visual or independent restart confirmation is inferred. This was a
guided check of previously discussed examples, not an unbiased evaluation of
detection or timing accuracy across the cohort.

## Next bounded analysis step

Compare the four reviewed intervals with their saved automatic intervals,
reporting elapsed endpoint spans and inclusive sample counts separately.
Preserve discrete alternatives instead of imposing a single offset. Any
later amplitude use of manual boundaries still requires an explicit policy;
no silent baseline change or amplitude recalculation is authorized by saving
these marks. Automatic boundary ranking remains unresolved and requires the
previously specified frozen 48-event evaluation, with both branches and all
prior non-recognized/failure cases retained.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Original per-recording
correction, external 1 Hz timing, anatomical/craniotomy uncertainty, unresolved
HP identity, cohort eligibility and normalization questions are unchanged.
