# Saved-stage timing review added to MATLAB

14 September 2026. **R5-TIMING-REVIEW-UI-050.** The existing event reviewer now
has a **Timing review** tab following the researcher's confirmed signal roles:
corrected intensity primary, detection scores supporting, raw input for checking
the existing correction. Open a saved audit with `openBOIEventReview(auditPath)`,
select an event, then choose **Timing review**. **View amplitude evidence** returns
to the same event list. The application remains BOI-only for this reanalysis.

The corrected and filtered curves use the fixed event footprint. The site trace
is separately labeled because its support and processing differ. The display
uses the saved arrays without detector reruns or new timing fits. It does not
relabel, reject, accept or retime events. Native and saved measurement bounds
remain distinct from the researcher's uncertain physiological boundaries.

The frame spinner is synchronized with source inspection. One-based recording
frames and modeled elapsed time are explicit: frame 1 is time 0 at the confirmed
external 1 Hz cadence; embedded timestamps and camera exposure are not substituted.
The timing lines denote inclusive first/last samples. The existing amplitude
view retains its half-open duration edges in seconds.

The optional raw panel shows the already removed trend only when the audit
records that raw and corrected values share the input. It is unavailable for a
different denoised detection input or an unknown input relationship. Missing,
malformed and nonfinite saved stages remain unavailable or gaps, never a new
fit, substituted signal or imputed zero. No universal substrate-decline model
is introduced. The original recording-specific correction is retained.

## Verification

- All 27 event-review and connected-review tests pass after the functional and
  layout changes (`final-verification-01.log`, `tests-04.mat`). The three timing
  tests also pass on the final title/legend revision (`final-verification-02.log`,
  `tests-05.mat`). Checks cover both signs, event/frame synchronization, missing
  and malformed stages, nonfinite gaps, input relationships, selected-event
  provenance, exports, unchanged measurements and the connected workflow.
- The current strict-ROI FB2314 audit contains 346 events. Every previous frame
  column, selected measurement row, baseline diagnostic, replayed baseline and
  amplitude matches the phase-start implementation exactly. All 1,245,600
  corrected/filtered/site samples match their saved audit fields.
- The actual earlier HP event audit lacks all three stages. It opens normally,
  explains their absence, exports unavailable values and preserves amplitude
  replay. Historical evidence was not reconstructed to make it pass.
- Independent Python checks compare two 1,200-frame exports with the frozen
  guided-review trace CSVs: 14,400 trace/coordinate values plus 2,400 modeled-time
  pairs. All 27 constituent exported artifacts pass their checksum checks.
- The final MATLAB renders were visually inspected for a sink, a saved surge,
  the primary view with raw context hidden, and the historical missing-stage
  view. Controls, labels, bounds and plots are separated. This is developer
  verification, not an independent researcher usability or release walkthrough.

Final artifacts are under **run-04**. `saved-audit-verification.json` contains
the input identities and hashes. `event-row-186` and `event-row-321` are the
FB2314 examples; `historical-event-row-1` is the older HP audit. Each is a new
version-5 review export with the original quantitative columns, four timing
columns, `TimingReview.json`, selected-event metadata, dictionary context,
source/acquisition provenance and implementation hashes. No old export was
overwritten. The MAT snapshot preserves unavailable values exactly.

![Timing review with correction quality context](run-04/timing-row-186.png)

[Primary view](run-04/timing-primary-view.png),
[saved surge example](run-04/timing-row-321.png), and
[historical missing-stage view](run-04/timing-historical-missing-stage.png).

## Preservation and limits

The phase-start snapshots and changes are preserved. Four existing MATLAB files
change and two helpers are added; the other 465 existing MATLAB files remain
byte-identical. The prior phase's 52 sealed artifacts remain recoverable,
including exact snapshots of the two standing documents extended here.
`code-preservation.json`, `prior-049-preservation.json` and `artifact-record.json`
record the checks. Initial failed test/evidence attempts and layout renders are
retained locally; the first failure was an unsupported test assertion, the
first evidence run stopped while building its summary structure, and initial
mixed control/axes containers overlapped in the rendered UI. The final version
uses separate control and plot containers. Prior attempt exports are diagnostic
artifacts; run-04 is the final implementation snapshot.

The measurement dictionary and baseline-diagnostic method/schema are unchanged.
Export schema advances to `boi-event-review-export-5`; timing metadata uses
`boi-timing-review-1`. Scientific recognition/recovery criteria, cohort eligibility,
HP identity, anatomical/craniotomy uncertainty and independent validation remain
open. Biological variability, physiological relevance, feasibility, usability
and traceability remain standing requirements. This display does not adopt
phase 047 candidates, insert development annotations into application state,
or change the two non-recognized examples or uncertain manual marks.

The bounded UI phase is complete. Next use the new view for researcher boundary
review; any future annotation persistence or automatic timing method requires
its own traceable implementation and scientific evaluation.
