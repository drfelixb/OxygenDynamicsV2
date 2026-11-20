# Read-only reviewed-reference preview

14 September 2026. **R5-REVIEWED-REFERENCE-PREVIEW-060 — implementation and
bounded verification complete.** The existing MATLAB event reviewer now has
a **Reviewed reference** tab. It explains candidate samples, native exclusions
and reviewed interval contacts from saved evidence. It calculates no new
reviewed baseline mean, amplitude or integral and adopts neither policy option.

## Open the actual saved example

In MATLAB:

```matlab
addpath('/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-reviewed-reference-preview-20260914');
[Fig,UI] = openReviewedReferenceExample;
```

This opens a fresh figure on sink site 15/event 36 with intentional preferred
onset 1153, loads the actual fourth researcher revision and attaches both
matching native masters. It checks the frozen example input hashes and does
not close existing figures or discard their drafts. Already-open figures retain
their older callbacks; a fresh figure is needed to use the updated code.

Use the onset selector to inspect 1149 without changing the saved preference.
Recovery alternatives 1166/1167 remain separate and have no preferred value.
For the other examples use `UI.Select(309)`, `UI.Select(308)` or
`UI.Select(321)`. Select an evidence row and use **Open selected contributor in
timing review** to inspect the saved detection or reviewed contact. This is
navigation, not an acceptance/reclassification action.

For other saved BOI audits, use `openBOIEventReview(auditPath)`, load the desired
saved boundary revision and choose both matching native masters in the new tab.
Programmatic attachment is `UI.AttachReferenceSources(sinkPath,surgePath)`.
Missing support stays unknown; a single selected-event native attachment cannot
establish absence of other native activity across the recording.

## What the researcher sees

- Exact immediate 20-second candidate reference on the external sample grid;
  one-based frame indices, modeled seconds and missing pre-recording samples.
- Counts for proposed A (native screening) and B (additional reviewed-interval
  veto), visibly separate from any adopted measurement. No reference substitution.
- The corrected trace, with A-eligible samples green, exclusions red, reviewed
  contact amber and selected onset/recovery alternatives purple. Missing
  corrected stages are not replaced by other signals. The existing timing
  panel provides supporting scores and raw/correction QA.
- Per-frame eligibility and native union intersection counts, with unknown
  support represented as NaN rather than zero.
- Contributor identities and navigation. Native overlap pixels and shared
  fixed-footprint pixels have separate columns and evidence labels; frame 516's
  contact does not become a native detection.

![Frame 516 remains A-eligible, with explicit contact to preceding event](final/preview-row-309.png)

![Preferred onset 1153 and the five native exclusions](final/preview-row-186.png)

The other two final views are `final/preview-row-308.png` and
`final/preview-row-321.png`. All four final images were visually inspected.
The GUI uses saved revisions only; session drafts never affect preview/export.
Changing onset selection revalidates saved input hashes. A stale source or
annotation clears/withholds preview evidence and prevents export into a new
folder. Failed source replacement clears the old attachment. Empty reviews
and unavailable stages are explicit states.

## Implementation and export

Three helpers were added: `attachBOIReferenceSources.m`,
`buildBOIReviewedReferencePreview.m` and `createBOIReviewedReferencePanel.m`.
`openBOIEventReview.m` integrates the tab and contributor navigation;
`exportBOIEventReview.m` adds the evidence to export schema 7. Four focused
cases were added to `tests/analysis/testBOIEventReview.m`, with the existing
schema assertion updated. No detection, correction, source-amplitude,
baseline-diagnostic or dictionary formula was changed.

Native attachment loads both masters once, validates all run/event identities,
original measurement/status/baseline values, frame grids, native run bounds
and fixed unions against the actual audit, then retains the checked native
samples in the session. Completeness is required across every audit event and
every native master run. Union counts do not double-count overlapping signs.
The legacy absence of master checksums at audit creation remains explicit;
current hashes are captured at attachment and checked for use/export. A saved
creation receipt, when available, also constrains the master hashes.

Export adds `ReviewedReferencePreview.json`, and when onsets exist,
`ReviewedReferenceFrames.csv` and `ReviewedReferenceContributors.csv`. Exact
typed preview tables are saved as a separate `ReviewedReferencePreview`
variable in `SelectedEventReview.mat`. The original `Data` object remains
unchanged; the receipt adds the new preview and implementation identities.
Contacts include the other event, revision, endpoints, shared frames and
fixed support size. Original saved stages and legacy diagnostic arithmetic
are still replayed by the existing export; none is recalculated on a reviewed
interval. All output artifacts receive checksums.

The dictionary remains 0.3.0-draft and both policy choices remain proposed.
Implementation of a read-only preview is not adoption of derived amplitude
calculation or a physiological baseline definition.

## Verification and limits

**34 focused MATLAB tests passed** across event and connected review suites
(`tests-02.log`/`.mat`). Seven affected GUI/empty-state tests were repeated
after final presentation/navigation changes and passed (`tests-ui-final.mat`,
`final-ui.log`). New cases cover both signs, union counting, event identity,
recording-start truncation including onset 1, discrete alternatives, nonfinite
samples, incomplete/wrong/changed sources, saved-only drafts, contributor
navigation and export reconstruction. Existing diagnostic snapshots and source
amplitudes remain compatible.

Initial test failures exposed an anonymous callback capturing the empty initial
preview and an extra field added to the old MAT `Data` snapshot. Both were
fixed: a nested callback returns current state and preview data is saved in a
separate MAT variable. The first diagnostic runner had invalid MATLAB indexing;
its failed log and source snapshot remain preserved. First renderings and
successful preliminary exports are also retained separately from `final/`.
No failed attempt is counted as passing verification.

**Actual FB2314 evidence:** all 346 native events associate with the audit.
The four current researcher annotations reproduce all five expected windows
and seven interval alternatives, checking 100 candidate memberships and 26
native contributor memberships. A counts are 20/20 before 536, 20/20 before
496, 0/20 before 177, 15/20 before preferred 1153, and 19/20 before alternative
1149. B differs only at 516, leaving 19/20 before 536. Both native contributor
navigation to row 312 and contact navigation to row 308 were checked.

All 346 audit rows and saved trace structures, original audit/review/master
hashes and the four actual annotations remain unchanged. Four final exports
replay exact memberships and verify every listed artifact hash.
`final/real-verification.json` and `final/real-preview-evidence.mat` retain
results and exact preview tables. Native association took about 2.54 seconds;
the four previews/exports took about 8.16 seconds in that run. These are local
stage times, excluding MATLAB startup/GUI rendering, not cohort throughput or
a memory benchmark.

The code inventory is now 479 MATLAB files: 473 prior files unchanged, three
prior files modified with their previous bytes preserved, and three added.
All 46 sealed phase-059 artifacts are preserved, including prior standing-ledger
bytes under `before/docs`. Source snapshots, change diff, preservation and
artifact manifests accompany this report. Portable MATLAB copies use `.m.txt`.

This remains guided development on the same BOI recording/animal. Numerical
completeness is not physiological quietness or recognition acceptance. No
surge is rejected for an intensity/score direction disagreement; insufficient
references stay unavailable. Existing anatomical support, biological
variability, physiological relevance, feasibility, usability, traceability,
normalization, cohort and independent-evaluation questions remain in force.
The wider timing challenge and non-recognized cases are unchanged.

Next is researcher inspection of the preview and explicit baseline-policy
selection before implementing separate reviewed-interval optical calculations.
Independent researcher usability and scientific acceptance are not claimed by
these developer GUI checks.
