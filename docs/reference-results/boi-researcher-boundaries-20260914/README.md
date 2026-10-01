# Editable researcher boundaries: phase 054

Decision **R5-RESEARCHER-BOUNDARIES-054**. Bounded implementation and developer
verification complete, 14 September 2026. Scientific eligibility, independent
researcher usability and physiological validation remain open.

The existing MATLAB event reviewer now has a **Researcher boundaries** tab.
Researchers can record recognized, uncertain or not-recognized judgments,
discrete onset/recovery alternatives, an optional preferred frame at each end,
a reviewer name and a reason. Empty endpoints mean unresolved. Current
not-recognized judgments contain no endpoints; earlier endpoints remain in
history. No automatic detector interval initializes the editor.

All entries are one-based recording frames. At the externally controlled 1 Hz
clock, frame 1154 corresponds to modeled time 1153 s. Embedded recording
timestamps are not substituted. Existing per-recording correction is retained;
there is no additional substrate model or baseline fit. Corrected intensity
remains primary, detection scores supporting, and raw intensity correction QA.

## Save, reopen and traceability

Each save writes a NEW JSON snapshot with complete loaded history across
reviewed events. Old snapshots are not overwritten. The snapshot binds each
revision to audit/source hashes, event identity, saved native/measurement
bounds and frame clock. It records old/new judgments, per-event previous
revision, reviewer, reason, UTC revision time, save/validation implementation
hashes and the preceding artifact's path/hash. The format is
`boi-researcher-boundaries-1`. It is a provenance record, not a digital signature.

A changed loaded file or audit blocks saving/export. Wrong event identity,
wrong source/audit binding, malformed revision links, invalid frames, missing
reviewer/reason and invalid preference choices are rejected. Integer frame
choices are neither snapped nor rounded. Every onset alternative must be at
or before every recovery alternative; correlated alternative interval pairs
are not represented by this first format.

Drafts are retained per event during a session, including event switching and
loading a saved review. Saving clears only that event's draft. Closing warns
about drafts and offers to continue or discard. Only saved judgments appear
as purple overlays and in exports. Choosing an older snapshot explicitly
resumes that contained history; parallel branches are separate files with no
automatic merge. Moving a self-contained snapshot does not require the old
parent path to exist. Load it explicitly against the matching audit.

Export version **6** adds selected `ResearcherBoundaries.json` and, when a
review is attached, self-contained `ResearcherBoundaryHistory.json`. The latter
contains all events in that loaded history, not just the selected event. The
MAT snapshot and receipt include the selected annotation. Artifact checksums
cover new files. The frame CSV and all existing measurement calculations are
unchanged. No dictionary or scientific method version has changed. The timing
metadata remains version 1 and the baseline diagnostic version remains 2.

## Verification and preservation

- **30/30 focused MATLAB tests passed**: 24 event-review and 6 connected-review
  tests. Tests cover old/revised/non-recognized history, reopening, export,
  invalid inputs, wrong identities, changed files, overwrite refusal,
  event-specific drafts, saved-only overlays, missing stages and legacy data.
- All **346** rows in the representative FB2314 strict-ROI audit have exactly
  the same prior review fields: table row, frame table, baseline diagnostic,
  replayed amplitude and baseline, details and timing metadata. Only the new
  researcher annotation metadata is added. This preserves **1,245,600** saved
  corrected/filtered/site stage values.
- Two 1200-frame exports, rows 186 and 309, have **byte-identical trace CSVs**
  relative to the phase-start implementation. The existing CSV serialization
  round-trip differs from the in-memory doubles by at most
  **4.996003610813204e-16**; it introduces no new export change. MAT data remain
  exact. Both exported complete histories reload and all checksums verify.
- Four final UI images were inspected: editor with alternatives/history,
  corrected-primary overlay at row 186, saved-surge overlay at row 309 and an
  unreviewed historical HP audit. Inputs, actions, history and trace axes are
  readable without overlap. Historical missing stages remain unavailable;
  no old detector stages, biological identity or tissue support were invented.
- Of the prior **471 MATLAB files**, **466 are unchanged**, five existing
  review/test files changed and five annotation helpers were added. No file
  was removed. The previous phase's **70 sealed artifacts** are preserved,
  including phase-start snapshots of the two standing ledgers before append.
- The final representative recording verification took **29.68 seconds**.
  This is a saved-evidence workflow with zero detector/statistics reruns and
  no new baseline fits; it does not require rereading the full source movie.

The first focused test run exposed inconsistent empty-vector shape and a
non-scalar history assertion. Empty endpoints were normalized consistently;
the assertion was corrected. The second full focused run passed. The first
recording verification incorrectly demanded bit-exact CSV-to-double equality;
the final check compares CSV bytes against the previous implementation and
records the numerical round-trip error. Failed logs, first-run files and the
first verification script are retained. These were verification/serialization
issues, not changed biological measurements.

All revision files under `run-*` are labelled **developer QA fixtures**. Their
coordinates exercise real saved trace displays but are not new researcher
judgments. Existing feedback from phase 051, including 1149/1154 with 1154
preferred, 1166/1167 alternatives, 177–195, 496–516 and corrected **536–556**,
remains in its original evidence files. Superseded 526 is not restored as a
current alternative. No historical feedback was silently imported or given
new researcher attribution/timestamps.

## Scope and next step

The updated entry point is `existing-analysis/openBOIEventReview.m`; reopen
that reviewer to obtain the new tab. The usage guide is
`existing-analysis/docs/BOI_EVENT_REVIEW_WORKFLOW.md`. The controls are directly
available through `UI.Boundaries`, with programmatic `UI.SaveBoundaries(path)`
and `UI.LoadBoundaries(path)` for explicit, tested persistence.

Next is a researcher walkthrough of one saved/reopened revision. Any later
migration of the existing feedback must explicitly retain original quotes,
coordinates, uncertainty, supersession and source records; the QA fixtures
must not be used as that migration. Automatic boundary selection remains a
separate unresolved scientific question. No new ranking rule, score snapping,
label change, amplitude recalculation, eligibility decision or biological
zero is adopted. Any later timing hypothesis still needs a frozen evaluation
against all 48 existing events with both branches and all prior failures.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Craniotomy/FOV
uncertainty, reviewed tissue support, HP identity, cohort eligibility,
normalization questions and independent validation remain open.
