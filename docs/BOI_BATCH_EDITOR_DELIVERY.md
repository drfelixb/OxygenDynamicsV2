# Batch editor delivery

14 October 2026 · BATCH-SETUP-01 through BATCH-SETUP-04

The first approved batch editor milestone is delivered locally as
**3.1.0-dev.4**, build **2026-10-14 11:04:10 +02:00**. Open
`openBOIBatchEditor` in MATLAB or choose **Batch recordings** in the existing
launcher. The [user guide](BOI_BATCH_EDITOR.md) covers CSVs, shared acquisition
settings, optional metadata, row checks and linked saved results.

Felix approved the field set and first milestone with “Go ahead with the first
batch editor milestone as proposed.” This delivery stops at preparation and
saved-result inspection. Queue execution and live CSV status writeback remain
the next milestone, requiring its concrete scope and approval. Researcher
usability acceptance of this new editor has not yet been received.

## Delivered behavior

| Work item | Demonstrated outcome |
|---|---|
| BATCH-SETUP-01 | Paths-only drafts, resolved four-column CSVs and legacy verbose CSVs import through a text-preserving adapter. Shared or row settings reach the existing request preparation boundary; verbose compatibility fields are generated internally. |
| BATCH-SETUP-02 | The table adds folders/pasted paths, accepts explicit shared settings and row overrides, edits optional/custom fields, preserves leading-zero IDs and multiline Unicode notes, moves rows and saves/reopens CSVs. |
| BATCH-SETUP-03 | Each row reports readiness and remedies independently. Linked results use saved requests, completion records and artifact hashes. Input/settings changes, failed/incomplete attempts and changed artifacts remain explicit. Exact verified selected results reopen through the existing viewer. |
| BATCH-SETUP-04 | Guide, three repository example CSVs, ten focused acceptance cases and separate static Codex technical review are complete. Tests are registered in the existing BOI runner; two GUI cases are desktop-only. |

Save As retains old source links and rebases subsequent relative entries to
the new CSV directory. Saving an opened CSV checks its original hash, keeps a
prior copy and publishes a temporary file atomically. A conflicting writer or
unrelated existing destination stops the save. Explicit duplicate-ID recovery
creates identities for copied rows and clears their result/review associations.
Empty CSVs cannot silently discard entered shared settings.

Completion and scientist review remain separate. CSV outcome cells are
unchecked until reconciled. A persisted running status displays **Incomplete**;
this editor does not determine worker liveness. Changed saved biological labels
are reported separately, and additional metadata absent from an older run is
not claimed as its original snapshot. Existing run requests/exports are unchanged.

## Verification and repairs

The final ten-case matrix passes **10/10** on macOS/Apple silicon with MATLAB
R2025a. Cases cover draft/minimal/legacy inputs, shared settings and overrides,
metadata/row identity, duplicates and missing sources, calibration/source-bound
support, completion/failure/incomplete states, changed inputs/metadata/artifacts,
and write conflicts/backups/recovery. GUI checks include recovery of the Busy
state after a thrown check and opening the exact selected saved-run fixture.

Four recorded test invocations used **31 case evaluations**: initial 9/10,
one repaired GUI case passing, then two complete 10/10 passes. The initial
failure was MATLAB's refusal of an empty dropdown item. The repaired display
uses **Use shared** while retaining a blank CSV value. Later UI changes fix
button/header widths, simplify hints and use an explicit cleanup wrapper;
the last full matrix checks the final MATLAB code. Earlier failures and
superseded screenshots remain in the evidence packet.

Both the details and metadata tabs were captured and inspected at
**1120 × 800** and **900 × 650**. The table scrolls horizontally for later
columns and long paths; full values/settings and errors are available in the
scrollable selected-row details. Narrow viewports can truncate table headings
or cells. Native chooser clicking and the duplicate-recovery confirmation
dialog were not manually exercised; shared continuations and explicit APIs
were checked. This is programmatic desktop/presentation evidence, separate from
Felix's usability acceptance and from a second user review, which he skipped.

Separate Codex static review found and checked repairs for Save As rebasing,
empty shared-save loss, incomplete-run source association, honest saved status,
duplicate-ID recovery and row support choices. Final re-review reports no
remaining high-confidence blocker. Code Analyzer has no parse errors; remaining
messages concern style and unused UI handles. This is not an independent human
or all-platform review.

Evidence is local at
`reference-validation/boi-batch-setup-20261014` in the workspace parent.
`results04-final.csv`, `matrix04-final.log`, `editor-final-*.png`,
`metadata-final-*.png`, `matlab-session-summary.json` and
`final-verification.json` identify results and preservation. Final MATLAB and
desktop-selection hashes match the pre-final-check pins. The future-package
source-list JSON was subsequently corrected to retain its existing CSV
exclusion, then validated separately without a build. Public editor code and
guide are included in that future list; CSV templates remain repository-only.

## Budget and preserved behavior

One of two permitted MATLAB starts was used. Four test invocations and two
presentation/static passes were recorded, with no separate batch-count ceiling.
New evidence is below 2 MiB against 100 MiB; elapsed engineering time is below
the eight-hour ceiling. The final receipt gives exact storage/time bounds.
No detector, statistics pipeline or recorded movie ran. No package, commit,
push, hosted CI, merge, tag or publication occurred.

Of the 544 pre-existing MATLAB files, **541 are byte-identical**. The three
changed files add the launcher entry, register focused checks and identify the
new development snapshot. New preparation/editor services leave detector,
correction, measurement rules and old results intact. Source staging/copy
behavior, actual queue completion writeback, live interruption/retry and batch
performance have not been demonstrated by this milestone.

What's next: Felix tries the batch editor; then agree the bounded sequential
queue and durable status/history milestone before its implementation.
