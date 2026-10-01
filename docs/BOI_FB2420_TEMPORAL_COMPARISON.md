# FB2420 fixed-interval temporal comparison

**R3-FB2420-TEMPORAL-COMPARISON-085 — bounded comparison complete, 15 September 2026.**
All 28 specified diagnostic rows were computed and independently reproduced.
The results show why a local contrast alone cannot decide whether a pocket or
surge is recognizable. They preserve your judgments and approximate boundaries;
no detector, boundary rule, baseline or scientific acceptance threshold is adopted.

The comparison uses the original corrected-intensity trace on each saved event's
fixed footprint. Its 14 interval records comprise nine automatic intervals, your
recognized surge at approximately 130–150, and three previously described pockets
with 84/85 retained as alternatives for the same recovery. These are repeated
measurements on exposed development examples, not 14 independent biological events.
The clock remains external 1 Hz, with frame 1 at modeled 0 seconds.

## What the comparison shows

**Recognized surge, approximately 130–150.** With 10 versus 20 preceding samples,
the maximum exceeds the preceding median by 128.75 versus 139.77 corrected-intensity
units. Relative to the following median, the same maximum is 80.00 versus 64.11
units higher. Frame 150 is 63.70 versus 79.58 units below those following medians.
The side levels and endpoint relationships describe the local context; they do
not establish one shared baseline, invalidate recognition, or make the approximate
recovery exact. In the original 134–144 interval, the automatic flanks also include
parts of your wider 130–150 annotation. That human contact is visible separately
from native occupancy.

**Tentative pocket, 65–84/85.** Both recovery alternatives contain the same
minimum (frame 68) and maximum (frame 84), so their extrema-based contrasts are
identical at each context scale. The recovery sample differs by 25.55 units.
For the 20-sample following context, changing recovery from 84 to 85 changes the
range from 295.06 to 381.83 and unscaled MAD from 53.53 to 62.75, despite leaving
the median unchanged. This preserves the uncertainty you expressed; it provides
no reason to select an alternative automatically. Neither interval has retained
native sink/surge occupancy on its original footprint, as the previous audit found.

**Intervals you did not recognize also have directional contrasts.** For example,
automatic case 4 has decline contrasts of 234.91 and 836.77 against its two
20-sample flanks, whose medians differ by 601.86 units. Automatic case 8 has rise
contrasts of 98.78 and 267.16 while its following median is 168.39 units lower than
its preceding median. Large contrasts, or a saved sink/surge sign, are therefore
insufficient to establish event recognition. Values use each case's own footprint;
this is not a pooled comparison of optical amplitudes or animals. Local level
changes are not assigned to a universal substrate-consumption model.

**Missing context remains missing.** Seventeen of 28 rows have complete context
on both sides; eleven lack the full preceding acquisition window. This affects
automatic cases 2, 3 and 7 and contextual pockets 2–28 and 7–27 at both scales,
and automatic case 5 at 20 samples. Every following context is complete. Native
contact occurs in 10 preceding and 7 following contexts; human/context association
occurs in 2 preceding and 7 following contexts. These flags neither remove samples
nor establish contamination or physiological quietness.

## Reading the outputs

The [two-scale table](reference-results/boi-fb2420-temporal-comparison-20260915/run-01/comparison-summary.csv) retains every row, including
unavailable values and both signed directions. Blank numeric cells mean unavailable;
side status and missing-acquisition count state why. They do not mean zero.
The [complete record](reference-results/boi-fb2420-temporal-comparison-20260915/run-01/comparison.json) includes exact frames, corrected
samples, tied extrema, descriptor dependency statuses, native contributors and
human contacts. Original automatic rows and cumulative researcher reviews are
saved separately in `run-01/`. Source hashes and one-based footprint pixel IDs
bind every calculation to its recording and spatial support.

The two illustrations were chosen before calculating the new descriptors:
[recognized surge](reference-results/boi-fb2420-temporal-comparison-20260915/run-01/recognized-surge-context.png) and
[tentative recovery alternatives](reference-results/boi-fb2420-temporal-comparison-20260915/run-01/tentative-pocket-recovery-context.png).
Blue shading shows preceding context; green shows following context. Pale bands
span its minimum/maximum, darker bands show median plus/minus unscaled MAD, and
horizontal lines show the median. Red dashed lines are original automatic bounds;
purple dotted lines are researcher/context bounds. Bottom contact ticks are flags,
not exclusions. These plots do not request another round of labeling.

For a complete side with median m, rise contrast is interval maximum minus m;
decline contrast is m minus interval minimum. Both signed values are retained,
including negative values. Endpoints stay inside the interval, outside both
flanks. Each flank needs all 10 or 20 finite observed samples. No shortening,
finite-value omission, padding, correction fit, smoothing, normalization by the
corrected trace or pass/fail screen is used. These corrected-intensity descriptors
are separate from raw optical amplitudes and accepted reference calculations.

## Verification and feasibility

Twelve known-shape fixtures passed before source execution, including rise,
decline, zero spread, changing context, tied extrema, missing/nonfinite samples
and alternative recovery. Native union and human overlap assertions also passed;
Python independently reproduced 651 numerical ingredients/descriptors in those
checks. The single FB2420 MATLAB pass took **18.20 seconds** and initially wrote
**1,868,980 bytes**, within the frozen five-minute/50-MiB budget.

Independent result verification reproduced all descriptors, exact frame
memberships and availability statuses across all 28 rows. It also checked 10,800
corrected-trace values against the previous audit, 1,443 native frame records and
28 human-contact records. Native pixel unions/contributor counts were checked by
a second MATLAB membership/boolean-union calculation; native contact memberships
match the frozen preflight. The numeric tolerance is 1e-9 absolute plus 1e-12
relative. Both rendered illustrations were visually inspected.

One implementation-only corrective round addressed the independent verifier:
MATLAB roundtrips a null `ParentObservation` as an empty array for automatic
intervals. The corrected verifier accepts that metadata equivalence only;
numeric unavailable descriptors still require null. The original verifier,
implementation freeze and failure record remain preserved. No source calculation
was rerun, and no scientific setting changed.

All 485 repository MATLAB files, all 31 preceding sealed artifacts, the
source-bound original automatic outputs, saved cumulative review, and measurement
dictionary remain unchanged. The new MATLAB helpers live only in the local
comparison packet; they are not wired into the production GUI or detector.

## Remaining decision

This phase establishes a traceable descriptive calculation, not an automatic
recognition method, physiological timing validity or independent accuracy.
The 10/20-sample contexts are diagnostic scales, not approved universal baselines.
Approximate boundaries, fixed-footprint candidate coverage, recovery interpretation,
dynamic validity, anatomy/calibration uncertainty and cohort eligibility remain
open. BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability continue to govern the work.

Next planned step: carry the unchanged descriptors into the existing 48-event
development timing panel, binding its original automatic intervals and already
recorded human alternatives before execution. This would test how these context
limitations recur across the existing recordings without fitting a threshold.
That panel was **not rerun in this phase**. Any later detector or timing change
still needs a separately recorded decision and the original measurement regression.

[Evidence packet](reference-results/boi-fb2420-temporal-comparison-20260915/README.md).
