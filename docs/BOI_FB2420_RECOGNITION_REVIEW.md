# FB2420 frozen recognition review — complete

15 September 2026 · R3-FB2420-RECOGNITION-COMPLETE-082

All nine frozen examples now have researcher recognition judgments. The final
reply **“no surge”** applies to case 9, surge site 2/event 4 (audit row 283,
automatic frames 105–126). Revision 9 adds `not_recognized` with empty boundaries
and preserves the preceding eight judgments verbatim.

| Case | Saved sign/site/event | Automatic measured frames | Researcher judgment |
|---|---|---|---|
| 1 | Sink 6/1 | 25–31 | Not recognized |
| 2 | Sink 1/1 | 1–48 | Not recognized within marked interval |
| 3 | Sink 3/1 | 2–4 | Not recognized; fluctuation in surrounding context |
| 4 | Sink 17/1 | 86–171 | Not recognized |
| 5 | Sink 5/2 | 18–26 | Not recognized |
| 6 | Surge 3/1 | 134–144 | Recognized; approximate human bounds 130–150 |
| 7 | Surge 1/1 | 1–10 | Not recognized |
| 8 | Surge 11/5 | 971–1034 | Not recognized |
| 9 | Surge 2/4 | 105–126 | Not recognized |

Thus one of nine selected automatic cases was recognized and eight were not.
These are descriptive counts for a purposive, source-exposed development queue,
not a detector accuracy estimate, false-positive rate or physiological ground
truth. Technical source replay passed earlier; it does not establish biological
event identity. Automatic output cannot yet be treated as researcher-endorsed
biological events based on this transfer review.

## Separate observations remain visible

The researcher also described pockets on the displayed corrected-intensity traces:

- Case 2's footprint: **possibly around 2–28** and **65–84/85**, retaining “might,”
  “around” and “maybe” from the exact reply.
- Case 3's footprint: a pocket **starting around 7 until likely 27**. Recognition
  and approximate timing remain separate; the user identified a pocket here.

These three source-bound observations are not silently assigned to rejected
native events, merged across different footprints, treated as exhaustive missed-
event truth or used for quantitative measurements. Cases 2 and 3 use different
footprints; similar timing does not establish biological identity. Acquisition
start limits preceding context. No reviewed reference baseline has been selected.

The recognized surge's human 130–150 bounds remain approximate annotation;
automatic 134–144 bounds, native mask, fixed footprint and original measurements
are unchanged. Frames are one-based under external 1 Hz sampling; modeled seconds
are frame minus one. Corrected intensity remains primary, detection score
supporting, and raw/removed trend is correction QA. No universal substrate-decline
model or new correction is introduced.

## Verification and next step

MATLAB saved/reloaded cumulative revision 9, checked all nine queue rows, retained
the first eight revisions, confirmed the recognized surge's 130/150 marks and
rendered the final case. Python independently joined all nine queue identities to
saved annotations and checked the counts and three prior context observations.
All automatic source hashes, 485 MATLAB files and 32 preceding sealed artifacts
verified unchanged; pre-append ledgers are retained. No new detector or measurement
run occurred. Earlier failed rendering and its tested fix remain in phase 074.

The recognition phase is complete. Next is the **bounded read-only discrepancy
audit** in [diagnostic plan](reference-results/boi-fb2420-recognition-review-20260915/revision-09/next-diagnostic-plan.json): compare the existing correction, normalized
and filtered stages, temporal grouping and spatial support for these same nine
cases and the three already identified contextual intervals. Distinguish source
evidence from possible explanations before proposing a change. This diagnostic
has not yet been executed; no parameter fitting, new source correction or cohort
rerun is authorized by a nonrecognition label alone. Any later detector/timing
change needs a separate recorded decision and the existing 48-event challenge.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Physiology, reference
precision, anatomy/calibration, dynamic validity, transient impact and evaluation
independence remain unresolved. The overall scientific reanalysis is not complete.

## Files and live review

`recognition-summary.json` joins automatic identities and intervals to the saved
human judgments and binds earlier context feedback. `BOI-researcher-review-09.json`
is the cumulative immutable annotation. `feedback.json` is the exact final reply.
`verification.json`, `preservation.json` and `artifact-record.json` retain checks
and hashes. All original source/audit data remain in the local phase-074 packet.

```matlab
addpath('/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-recognition-review-20260915/revision-09');
[Fig,UI] = openFB2420FinalReview(6);
```

Use positions 1–9. This wrapper checks the explicit final review hash; earlier
launchers remain intact. Portable `.m.txt` files are snapshots of local scripts.

[Complete evidence packet](reference-results/boi-fb2420-recognition-review-20260915/revision-09/README.md).
