# Prespecified surge-onset trace panel

This experiment tests timing and reference placement conditional on fixed raw
spatial support. It does not run or modify the production detector, measurement
or statistics pipeline. This protocol precedes inspection of panel outcomes.

## Backgrounds and construction

Use all full-event supports in the **growing-case cache only** from the previous
amplitude audit: 51 ID400, 12 ID401, 40 FB2312, and 12 FB2411 fluorescence-control
supports (115 total, four source recordings). Use their original source traces,
not the previously injected traces. Omitting the shrinking-case cache limits
duplication but does not make supports or time samples independent. Support and
native interval selection still comes from the earlier constructed movies.

Keep each existing native start/end and full spatial support fixed. Set the
known first positive sample to 10 or 25 seconds before the native start. Cross:

- peak mean-trace increments: 2%, 5%, 10%, 20% of the same-frame source;
- rise lengths: 5, 15, 30 seconds;
- rise shape: linear or sine-squared;
- native-start delay from first positive sample: 10 or 25 seconds.

This is 48 recipes per support, 5,520 planned constructed traces. For first
positive sample `k`, rise length `r`, and `j = frame-k+1`, the rise is `j/r` or
`sin(pi*j/(2*r))^2` for `1 <= j <= r`. Hold one for the next 20 seconds, then
fall to zero over `r` seconds using `1-j/r` or `cos(pi*j/(2*r))^2` with a new
fall index. Outside this pulse the contribution is exactly zero. Construct
`Y = X*(1 + amplitude*envelope)` in double precision with no rounding/clipping.

Require a complete positive finite 20-second source reference before the known
start and a finite positive source trace. Otherwise retain every recipe/method
row with an explicit construction-unavailable status; do not move the known
start to make it fit. A terminally truncated pulse remains allowed and is
reported; the estimator and amplitude peak remain limited to recorded frames.
The estimator receives no known onset, recipe, or source subtraction.

These are optical mean-trace increments, not oxygen-concentration changes.
There is no spatial dilution, new photon noise, candidate admission or tracker
in this construction. Results cannot establish movie detection sensitivity or
predict all biological waveform shapes. FB2411 is a separate background stratum,
not an oxygen-positive sample; tissue eligibility is not tested by a trace panel.

## Two context rules, one fit

Compare the frozen fixed-context rule with one change: use the **available
contiguous context**. Start at the later of the recording start, 60 seconds
before native start, or the frame after the last overlapping retained detection
before native start in that interval. Move the earliest onset candidate forward
enough to retain 20 preceding baseline samples. Still search at most 40 seconds
backward, and require at least three candidate frames so an interior solution
exists. Too little context remains unresolved.

Both methods otherwise use identical data, fixed peak interval, broken-line
model, score threshold 10, profile threshold 2, ten-second profile-span limit,
and boundary/nonfinite/rising-slope requirements. Do not change these thresholds
after seeing the panel. No gaps, excluded frames or earlier intensity minima are
used to assemble a reference. The detection-exclusion ledger is inherited from
the growing movie, identically for both methods and all controls; it is not a
new detection run on the source or each constructed trace. Undetected source
activity remains possible, and inherited exclusions may be conservative.

Evaluate one unchanged source control per support/method (230 evaluations),
separately from the 11,040 planned constructed evaluations. Controls may contain
physiology and cannot supply a biological false-positive rate.

## Outcomes and decision

Keep planned, constructible, resolved, and amplitude-available denominators
separate, stratified by source, amplitude, rise shape/length, and delay.
For resolved constructed cases report signed onset error against the first
positive sample, absolute error, and the fraction within five seconds (a
prespecified descriptive tolerance, not a physiological accuracy criterion).
Report conditional summaries alongside success counts over **all constructible
cases**, so rejecting difficult cases cannot inflate apparent recovery.

At the proposed reference frames report mean imposed increment divided by mean
source, positive-contribution frame count, and the baseline-induced amplitude
change in percentage points relative to a source-only reference at those same
frames and the same observed native peak. Preserve background changes in the
measured amplitude. Compare with the native reference and with the paired
control's estimated onset; an identical control estimate is not automatically
evidence of detecting the injection. Baseline contamination of <=1% is a
descriptive screen, not a validated publication exclusion threshold.

Increasing the resolved count alone does not justify promotion. Assess timing,
baseline contamination, waveform dependence and control shifts together. This
panel is development evidence on reused recordings, not held-out validation.
