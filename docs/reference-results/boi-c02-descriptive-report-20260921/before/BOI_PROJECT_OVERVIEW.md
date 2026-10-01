# BOI reanalysis: project overview and closure checklist

Updated 21 September 2026. This summarizes the full project after the fixed-interval
context comparison on the existing 48-event development panel (R3-086), alongside
the optional context-view implementation (R5-087). Detailed earlier evidence and
unsuccessful experiments remain in the chronological status and decision records.

**Latest completed step (119):** all seven C02 pairs are consolidated in the [mouse-level overview](BOI_C02_MOUSE_SUMMARY.md). The [analysis decision sheet](BOI_C02_ANALYSIS_DECISIONS.md) is proposed and ready for review.

**We have a working, traceable MATLAB analysis and review workflow. We have not
yet frozen the scientific analysis or completed the eligible-cohort reanalysis.**
Recent progress has concentrated on R2/R3 event interpretation and R5 usability.
Closing a numbered diagnostic phase does not close the whole work package.

| Work package | Established work | Remaining completion requirement |
|---|---|---|
| R0 — scope and outcomes | BOI-only scope, cohort records, versioned shared measurement dictionary, meanings and limits. | Select final primary/secondary/exploratory outcomes and permitted claims; freeze measurement-specific admission. |
| R1 — inputs and validity | Common archive/local input workflow; external-trigger 1 Hz authority; selected DANDI/source equivalence checks; source, preparation and craniotomy evidence; local workflow executions. | Complete unresolved identity/calibration/preparation decisions and valid tissue/frame support for each intended comparison; decide measurement-specific eligibility. |
| R2 — detection and measurement | Existing formulas and saved source support audited; original and reviewed intervals/references kept separately; amplitude and signed-integral replay; known timing/recognition failures documented. | Decide defensible event/timing/reference rules, required manual review and explicit limitations. Essential validity issues must be resolved for their affected outcomes. |
| R3 — variability and robustness | Prior-use histories, development challenges, local FB2420 review and completed 48-event context comparison; missingness and both signs retained. | Map remaining coverage gaps to primary-outcome risks, freeze acceptance/regression criteria and evaluation roles, then complete only the necessary bounded validation. Exposed data cannot become untouched evaluation. |
| R4 — statistics | Candidate comparisons, pairing, denominators and availability implications documented. | Prespecify valid experimental windows, animal-level contrasts, repeated sessions, weighting, exclusions, missingness and multiplicity. |
| R5 — researcher workflow | MATLAB import/review/run/inspect/export, saved annotations, exact calculation ingredients and implementation checks; extensive guided researcher feedback. | Finish the independent researcher walkthrough and second-person numerical replay on eligible input; resolve essential usability/compatibility issues. |
| R6 — freeze and reanalysis | Development runs and immutable evidence packets are available. | Freeze code, settings, environment, inputs and curation; run the eligible cohort; inspect QC; deliver final analyses, methods and accepted limitations. |

## Current researcher direction: proceed with the useful detector

The researcher explicitly considers the present detection useful enough to move
forward: substantial activity is detected, the signal is intrinsically difficult
to identify, and some mislabeled detections are acceptable at this stage. Record
this as **R0-PROCEED-CURRENT-DETECTION-088**. It is a qualitative acceptance of
current imperfections for the next analysis stage, not a measured error rate or
an assertion that all detected activity is physiological ground truth.

Keep the current detector and recording-specific correction as the working method.
Do not initiate further recognition/timing optimization or another broad diagnostic
panel solely because an ambiguous or mislabeled event exists. Preserve known
limitations, automatic labels, human judgments and uncertainty. Manual review
should be targeted and feasible; do not make exhaustive event relabeling an
implicit prerequisite for progress.

Move to usable outputs, recording eligibility and planned animal-level analyses.
Reopen a method issue only for a concrete failure that prevents a required output
or threatens the intended comparison, and state its consequence before proposing
bounded additional work. Traceability, correct calculations and source integrity
remain required. This decision does not resolve unrelated identity, calibration,
experimental-baseline or final-claim questions by assumption.

## What the recent work established

Your observations and revisions are preserved: corrected intensity is primary,
detection score supports interpretation, and the raw trace checks the existing
correction. Event-specific references, the preferred onset 1154, recovery
alternatives, the 165–176 reference before the 177–195 pocket, and approximate
preceding pockets remain distinct from automatic masks and measurements.

FB2420 review and the four-recording panel demonstrated why fixed context windows
cannot automatically replace a selected local reference or establish recognition.
The panel comparison contains 48 original events and 85 interval records including
historical/current alternatives, assessed at two scales: 170 verified rows.
These are development diagnostics, not biological replicates or accuracy estimates.
No new recognition threshold, universal baseline, substrate-decline model or
automatic boundary rule was adopted. The original correction remains unchanged.

The optional context view makes these completed calculations inspectable in MATLAB.
It contributes to R5; it does not establish physiological timing or close R2/R3.
The legacy-context path takes missing geometry from matching saved native tables,
retaining original metadata and its provenance.

## Finite closure checklist

1. **Completed: optional context-view delivery.** Display, missingness,
   current/history separation, accepted-reference preservation, exports and
   legacy handling are verified. Retain descriptive context; no classifier adopted.
   See the [usage guide](BOI_TEMPORAL_CONTEXT_VIEW.md).
2. **Completed: working analysis specification.** The
   [consolidated specification](BOI_WORKING_ANALYSIS_SPECIFICATION.md) covers all
   14 measurements, automatic/reviewed/context roles and accepted limitations.
   Final primary claims and statistical choices remain explicit; no new method
   was adopted. Proceed to the recording eligibility matrix using existing evidence.
3. **C02 evidence matrix completed; eligibility decisions remain.** The
   [seven-pair matrix](BOI_C02_ELIGIBILITY_MATRIX.md) covers 14 recordings and
   196 measurement entries. No new exclusions were made. The [FB2314 isoflurane run](BOI_FB2314_ISO_RUN.md)
   is now verified: both FB2314 states have accepted working support and matching
   scientific processing. The [first paired descriptive summary](BOI_FB2314_PAIRED_SUMMARY.md)
   is complete over full frames 1–1200 in both states as a working window. Final cohort
   windows remain open. [FB2315 now has both verified runs and a paired descriptive summary](BOI_FB2315_PAIRED_SUMMARY.md).
   [ID402 now has both verified runs and a paired summary](BOI_ID402_PAIRED_SUMMARY.md).
   [ID403 now has both verified runs and a paired summary](BOI_ID403_PAIRED_SUMMARY.md).
   [FB2312 now has both verified runs and a paired summary](BOI_FB2312_PAIRED_SUMMARY.md).
   [ID400 now has both verified runs and a paired summary](BOI_ID400_PAIRED_SUMMARY.md).
   [ID401 now has both verified runs and a paired summary](BOI_ID401_PAIRED_SUMMARY.md).
   All seven C02 candidate pairs now have current-profile summaries and all fourteen
   recordings have accepted working support. This paired execution phase is complete.
   Mouse-level consolidation is complete (119). Next is the proposed analysis decision package, then paired figures and methods.
   Source correspondence and frame counts are verified; other scientific uncertainties remain.
   Extend the remaining R1 eligibility decisions to the other comparison families. List each recording/comparison as included,
   excluded or unresolved for each affected measurement, with source evidence and
   reasons. Separate missing experimental baselines from unmeasured pre-recording
   baselines, and retain unresolved identity/calibration/support questions.
4. **Use existing R3 evidence and accepted limitations.** No further detector
   optimization is planned. Add a challenge only for a concrete blocker to a
   required output or intended comparison, with frozen cases, acceptance criteria,
   regression checks, resource limits and an adopt/retain/restrict/defer stopping
   decision. Establish evaluation roles before inspecting new outcomes.
5. **Freeze R4 analysis plans.** Resolve animal-level comparisons and missingness
   after measurement rules and eligibility are sufficiently stable. Planning can
   proceed alongside R1–R3; final inference cannot assume those decisions away.
6. **Complete the R5 release walkthrough.** An independent researcher imports,
   reviews, runs, inspects, explains and exports an eligible result; a second
   person reproduces a number and sees how a changed setting/judgment is preserved.
7. **Execute R6.** Freeze the complete release, rerun the eligible cohort, inspect
   exclusions/availability and deliver results with reproducible methods and the
   remaining accepted limitations.

The critical path is a concise working analysis specification, recording
eligibility, final statistical design, then the cohort freeze and rerun. Engineering and
statistical preparation can proceed in parallel with the scientific decisions.
There is no defensible single percentage-complete estimate while outcome admission
and validation criteria remain open. A replacement detector is an optional bounded
comparison, not an automatic requirement to finish the project.

The assistant can prepare decision packets, implement authorized rules, audit
sources, run bounded tests and produce exports. Scientific outcome/claim choices,
local biological judgments and acceptance of essential limitations need explicit
researcher decisions on concrete evidence. The independent usability/replay gate
requires independent participation. No additional decision is requested merely
to finish the currently authorized optional view.

Standing requirements: BOI-only; biological variability; physiological relevance;
feasibility; usability; traceability; preservation of unresolved questions and
existing changes.

See the [original plan](REANALYSIS_UPDATE_PLAN.md),
[chronological status](REANALYSIS_STATUS.md),
[measurement dictionary](BOI_MEASUREMENT_DICTIONARY.md),
[cohort resolution](BOI_COHORT_RESOLUTION.md),
[researcher contract](RESEARCHER_WORKFLOW_AND_TRACEABILITY.md), and
[48-event comparison](BOI_PANEL_TEMPORAL_COMPARISON.md).
