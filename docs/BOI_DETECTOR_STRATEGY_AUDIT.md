# Detector strategy audit: evidence, concerns and decision gate

11 November 2026. **Initial retrospective self-audit; final strategy discussion
follows the proposed original-versus-new comparison.** Root, no delegation.
No independent expert validation or further detector work is claimed here.
The [bounded comparison plan](BOI_ORIGINAL_VS_NEW_COMPARISON_PLAN.md) defines the
evidence to collect before deciding how to continue. These initial concerns
are ready for discussion before any evaluation is approved. Preparing these
records does not start that evaluation or another implementation milestone.

## Present assessment

The detector research has established useful software contracts and exposed
real failure mechanisms. It has **not established that the new detector is
biologically better than the original MATLAB approach**. The appropriate next
activity is a paired evaluation and a decision about the strategy, not another
automatic cycle of timing/reference fixes.

The usable batch editor, saved-run inspection, existing statistics/export
connection and protected scientific calculations are separate deliverables.
Their value should not be confused with the unresolved detector replacement.
They remain available while detector research is stopped.

## What the record supports

- The [original MATLAB pipeline](../OxygenDynamics_Master.m) already uses
  processed images, size/shape/support filtering, spatial overlap, trace
  correlation and trace/trend-based timing refinement. A rationale that it
  was merely trace-based is incorrect. A replacement must improve on this
  actual baseline, including the scientist's CSV → run → export workflow.
- The [joint video prototype](BOI_VIDEO_JOINT_DETECTOR_RESULTS.md) broadened
  proposal coverage across twelve recordings and thirty views. Its four
  located positive targets also had raw-route-only associations. That did not
  demonstrate an added coverage benefit from the extra local route on those
  targets, nor complete-pocket timing or validated area.
- [Episode assembly](BOI_VIDEO_EPISODE_ASSEMBLY_RESULTS.md) represented multiple
  minima but exposed overmerging, reference dependency and ambiguous membership.
  Fewer proposals did not establish fewer false pockets.
- The [latest separation revision](BOI_VIDEO_LOCAL_REGIONAL_BASELINE_RESULTS.md)
  demonstrates separate local/regional/reference records and correct arithmetic.
  All twelve recordings were processed, but full episode identity/recovery
  still fails on the fixed examples. A consistent implementation is not proof
  that its biological model is suitable.

The current metadata contains 3,530 original sink rows and 40,270 new dependent
episode proposals. These are different units and operating policies. Their
ratio is neither a sensitivity improvement nor a false-positive estimate.

## Weaknesses in our development and reporting strategy

**The original-versus-new benchmark came too late.** Recent comparisons mainly
contrasted successive prototypes. They showed changing failure modes but did
not establish a net gain over the original saved detector. More implementation
could therefore look like progress without a clear scientific benefit.

**Biological feedback remained much narrower than execution coverage.** Running
twelve complete cached recordings is broader computation. It is not equivalent
to validating all their pockets. Existing authority consists of four located
positives, three rejected targets, two window judgments, one timing discussion
and twenty unlabelled views. Reporting only the difficult FB2413/FB2412/FB2410
examples made that distinction harder to understand.

**Fixed-source failures were sometimes described too broadly.** An unresolved
displayed candidate does not prove that no other proposal covers the same
pocket. Conversely, an overlapping proposal does not prove correct detection.
The comparison must examine the full catalogues and distinct episode identities,
not grade the detector from one selected source ID or any-overlap counts.

**Footprint, preprocessing and timing changes have been entangled.** Original
native ROIs and new fixed coarse cohorts often contain different pixels.
Different traces can imply different boundaries. A longer new interval cannot
be called a timing improvement without establishing the same biological episode
and showing the support difference. The original's corrected images and the
prototype's raw/local comparisons also represent different signals.

**Repeated timing fixes may be downstream of the main problem.** Recent
revisions reuse the saved proposal bank and fixed cohorts. If that support
does not represent the pocket or loses native capillary/tissue context,
adjusting its baseline or return rule may never recover a suitable event.
The paired comparison should identify this possibility before another fit.
It cannot establish the cause without a later controlled test.

**Withholding uncertainty is necessary but is not detection improvement.**
An unresolved pocket, a rejected misleading interval and a newly correct
detection are different outcomes. The new method must not gain apparent
accuracy by withholding most difficult cases. Review load and useful automatic
coverage matter for the researcher's workflow.

**Correctness evidence has dominated biological acceptance evidence.**
Constructed scenes, scalar replay, source hashes and resource guards protect
the software and originals. They do not replace native-video reference
judgments or a fair comparison of genuine misses, false detections and timing.
Tests should verify a chosen comparison contract, not become the main evidence
that the detector works.

**The path to complete burden remains unfinished.** Coarse proposal support
does not establish native pocket area or a recovered per-event scientific
baseline. A new detector that produces many review obligations without usable
complete episodes may make postprocessing harder. Partial burden is not an
acceptable fallback; the existing formula and normalization are preserved.

**The development process has accumulated decision and repair cycles.**
Per-milestone bounds prevented uncontrolled work and protected the sources, but
repeated bounded revisions and repair approvals did not by themselves answer
whether the direction was worthwhile. The audit should review documented
effort and researcher attention cumulatively. Nominal budgets are ceilings,
and elapsed times may include approval waits; neither should be misreported
as measured active engineering time. Existing approval rules remain in force.

## What to retain

Retain the original working MATLAB workflow and scientific measurements;
immutable automatic/reviewed separation; individual event/ROI reference
assessment; explicit missingness and recording-edge censoring; source identity
and coordinate checks; and the distinction between local and regional response.
Preserve all prior outputs and the five reserved recordings. No cleanup,
deletion, language migration or adoption follows from this audit.

## Decision questions after the paired comparison

1. Which confirmed pockets does each method recognize, miss, split or merge?
   Does any new benefit persist across recordings and event types, with losses
   and withheld cases included?
2. Which asserted detections are confirmed non-pockets, regional responses or
   unresolved? How much review does each method create under explicit readouts?
3. Does the new method improve full episode timing, rather than just extending
   an interval or overlapping a known event? Is its footprint observing the
   same local phenomenon?
4. Which failures plausibly originate in missing proposals, unsuitable spatial
   support, correction/preprocessing, grouping or context selection? Which
   explanations remain untested?
5. Is there a credible, affordable route to native event area and individual
   measurement references while preserving complete normalized burden?
6. What evidence would change the decision, and what finite effort/review
   budget would be justified? Is new reference annotation the limiting need?

## Real options and stopping decision

- **Retain the original and stop/defer replacement** if the new method has no
  clear practical benefit or introduces unacceptable missed/merged episodes.
- **Make a targeted improvement to the original** if the comparison identifies
  a specific failure that can be corrected without replacing the entire chain.
- **Retain a narrow prototype component** if it supplies useful additional
  candidate evidence, while other stages remain better served by the original.
- **Redesign the video approach** only if the paired evidence supports that
  investment and its spatial-resolution, reference-data and native-area
  requirements are explicit. A data-driven model is an option to evaluate,
  not a default solution or a claim that the present prototype learned biology.

The final audit should record the selected option, evidence against it,
remaining uncertainty and a stopping condition. MATLAB-versus-Python is a later
engineering decision after scientific benefit is established. Even a promising
development comparison does not authorize production use or opening the five
reserved recordings.

**Current recommendation:** hold detector implementation, perform the bounded
paired evaluation if approved, then discuss these options with the researcher.
No next detector revision is presumed, and stopping is a valid outcome.


## Researcher decision and scope reset — 11 November 2026

The researcher accepts the original detector as the foundation and authorizes
only the planned twelve-recording saved-output comparison. They reaffirm the
initial calculation-correctness and compact Excel goals and identify drift
into detector research. The [original-goals handoff](BOI_PROJECT_HANDOFF_20261111.md)
records delivered scoped arithmetic checks and the undelivered compact main
workbook. Restarting elsewhere remains their choice.

The [computational comparison](../../reference-validation/boi-original-new-comparison-20261111/RESULTS.md)
is delivered, with biological reference review incomplete. All four located
positive examples were already original detections; incomplete timing is not
evidence that the original missed them entirely. No demonstrated comparative
biological benefit supports adopting the replacement. Preserve it as inactive
experimental evidence. No new detector revision is authorized, and optional
reference review must not block unrelated calculation/export improvements.
