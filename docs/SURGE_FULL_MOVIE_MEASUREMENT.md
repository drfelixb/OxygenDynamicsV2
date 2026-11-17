# Full-movie candidate surge measurement validation

Prespecified bounded comparison: four new complete master runs, an unchanged
control and a composite challenge on each of ID400 awake (600 frames, 4.75 µm/px)
and FB2316 KX (1,200 frames, 2.35 µm/px), both 1 Hz. Reuse verified archive inputs;
these are development recordings, not untouched evaluation data. Production
code and parameters remain frozen. The alternative detector is outside scope.

Choose two overlapping disks of radius 85.5 µm, centers separated horizontally
by approximately one radius. Both disks must have at least 95% coverage by the
intersection of control sink/surge eligible tissue. Among qualifying centers,
choose the pair with target center nearest image center (linear-index tie break).
Use no challenge detection outcomes for placement. Fail explicitly if no position
qualifies. Report eligibility again on the constructed recording.

Six components share these two spatial supports. Target disk: quadratic rise
7 seconds at frame 101; gamma rise scale 23 seconds at frame 201; quadratic
7-second rises at frames 401 and 501. Neighbor disk: quadratic 7-second positive
at frame 409 and negative at 509. All absolute peak fractions are 20%. Use the
previous unseen-envelope functions, including their 11-sample quadratic plateau
and finite tails. The slow pulse ends shortly before the later challenges;
pre-event signal contamination remains an outcome, not an assumed clean state.

At every pixel multiply the original intensity by one plus the sum of component
fractions. Additive fractional superposition is explicit in spatial overlaps.
Reject clipping; round to uint16 and retain the rounding residual separately.
No new noise is added. The composite conditions share a movie's normalization
and are not independent experimental replicates. Controls are scored at the same
potential locations/windows, with no imposed signal and no biological truth label.

Run the unchanged master detector and production measurement path, audit both
signs' production amplitudes, and extract native event masks from these new runs.
For every retained surge, independently of truth matching, compute the two raw
onset fits, select an onset and evaluate native/expanded candidate amplitudes.
Both-sign pre-native masks constrain context and expansion as in the prior rule.
Keep all unavailable states and original event/site identities. No group statistics
or production contract promotion occurs in this experiment.

Export all event/component native space-time intersections, volumes and IoUs for
both signs. Assign same-sign pairs greedily by decreasing positive IoU with
deterministic truth/event tie breaks, at most once per event/component. This is
a correspondence for diagnostics, not a success threshold. Keep no-intersection
components, multiple events intersecting one component, and events intersecting
multiple components visible; do not describe every geometric overlap as recovery.

For assigned positive components, report onset error, amplitude availability,
peak envelope fraction (90% screen retained), strongest positive component at the
chosen peak, and positive/negative reference contamination separately. Exact
decomposition at the same observed peak separates source, positive imposed,
negative imposed, rounding and reference-denominator effects. Truth never enters
the estimator. Missing or merged detections cannot be rescued by measuring an
oracle disk instead. Controls retain potential geometric correspondence only.

Verify all movie pixels against source/recipe, native mask unions and intersections,
trace samples, both onset models, selector and peak/reference calculations using
independent Python reconstruction. Preserve code/input/output hashes, runtime,
recording dimensions and all denominators. Full recording support and outcomes
under two acquisition conditions do not establish biological accuracy, depth or
oxygen concentration calibration.
