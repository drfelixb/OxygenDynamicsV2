# Next implementation: primary and supporting signals in the existing reviewer

This is an implementation handoff based on the researcher's confirmed visual workflow. It does not adopt an automatic timing or recognition rule. No production files were edited in phase 049.

## Existing integration points

- `openBOIEventReview.m` currently displays preserved-source and signed-fraction axes in the inspection tab. Event selection and frame selection are already coordinated there. Keep that measurement view and its meaning.
- `helpers/buildBOIEventReviewData.m` builds the event frame table and explanatory text from the saved audit traces. Add saved timing-signal data and explicit availability/lineage fields through that data path rather than re-reading a movie or recomputing detection stages.
- Saved audit traces can contain `DetectionDetrended`, `Filtered`, `TimingTrace` and `TimingTrend`. Historical audits may omit stages; show an unavailable reason, not zeros, a substituted trace or a new fit. Existing full-trace length and identity checks must remain intact.
- `helpers/exportBOIEventReview.m` and the existing event-review tests provide the export and verification path. Inspect the current export contract before making a versioned addition; preserve existing fields and measurement definitions.

## Bounded behavior to implement

Add a timing-review view with corrected intensity as the primary plot and aligned detection-score context below. Label the fixed event-footprint filtered score and the saved site trace separately; their processing/support are not interchangeable. Keep native and saved measurement bounds distinct from any manual annotation and show their provenance. Show both sign interpretations without relabelling an event.

Provide raw/correction quality context separately. Where raw and saved corrected means are available on the same footprint, their difference can display the already removed trend, explicitly labelled as such. It is not a new fitted reference and does not replace the amplitude baseline. Do not add a new detrending model or fit to a partial window.

Show one-based recording frames as used during the guided marks, with their modeled elapsed time available explicitly: frame 1 is time 0 at external 1 Hz. Do not silently shift existing annotations or conflate camera exposure with frame interval. Existing measurement-view seconds remain correctly labelled. Data export must carry both coordinates and the authoritative clock provenance.

Keep score support informative rather than authoritative: no snapping marks to its extrema, automatic event exclusion, acceptance badges from the failed range screen, or acceptance of T2/T3. In this bounded UI step, do not introduce a new annotation storage format or retrospectively insert the development examples into general application state. Existing annotation/export behavior must be inspected and preserved; adding editable annotation persistence is separate work if absent.

## Checks before completion

Verify synchronization when changing events/frames, exact saved-source values and frame/time coordinates, graceful missing-stage behavior, correct separation of site/event support, explicit signal roles in readable and structured exports, and unchanged raw amplitude/baseline results. Include one current reconstructed audit and a historical audit lacking a stage. Inspect the rendered MATLAB view on representative saved evidence. Reuse existing meaningful event-review tests and add only checks for these new behaviors; do not rerun detection or the whole biological cohort.

The completed view should let the researcher follow the same corrected-primary, score-supported reasoning used in the guided figures while retaining the existing measurement-inspection workflow. Scientific recovery criteria, cohort eligibility, anatomical holds and independent release validation remain open.
