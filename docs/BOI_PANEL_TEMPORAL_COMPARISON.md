# Existing 48-event panel: fixed-interval temporal comparison

**R3-PANEL-TEMPORAL-COMPARISON-086 — completed, 15 September 2026.**
The unchanged phase085 diagnostic has been applied to all 48 original events
across four recordings. All 170 two-scale rows passed independent verification.
It provides inspectable context, but does not establish an automatic recognition
rule. Existing detection, correction, optical measurements, researcher judgments
and accepted references remain unchanged.

## Population and annotation history

Each recording contributes its original 12 selected events: FB2314 awake,
FB2316 KX, ID400 awake, and the provisional HP ECS recording whose identity and
preparation remain unresolved. These are previously exposed development examples;
they are not a new cohort, a random sample or independent evaluation. Preserve
recording-specific support: FB2314's reviewed restricted ROI and the other
recordings' historical support are not treated as anatomically interchangeable.

The 85 interval records comprise 48 original automatic measurement intervals,
30 earlier alternatives (including two explicitly coordinate-only frame-296
sensitivities), and seven later saved FB2314 alternatives. At two context scales,
these yield 170 diagnostic rows, not 170 biological events. The original panel
contains ten reviewed cases: eight with timing annotations, two with no recognized
event, and 38 with no human reference. No judgments were invented for the latter.

Latest FB2314 choices remain separate from history: preferred sink onset 1154,
alternative onset 1149, recovery alternatives 1166/1167, pocket 177–195, and surges
496–516 and 536–556. The full saved history retains the earlier 1153 choice and
its subsequent revision. All four latest saved annotation statuses remain
`uncertain`. Historical superseded alternatives and frame-296 coordinate checks
are calculated for traceability but excluded from the current human-contact layer.
Unresolved 295-seconds/frame-origin wording remains visible.

## Context availability

The table below covers only the 48 original automatic intervals, each assessed
at 10 and 20 samples per side. Native contact is a separate flag; it never removes
samples or establishes contamination or physiological quietness.

| Recording | Samples/side | Complete both sides / 12 | Before unavailable | After unavailable | Before native contact | After native contact |
|---|---:|---:|---:|---:|---:|---:|
| FB2314 awake | 10 | 10 | 1 | 1 | 5 | 6 |
| FB2314 awake | 20 | 10 | 1 | 1 | 7 | 7 |
| FB2316 KX | 10 | 12 | 0 | 0 | 4 | 4 |
| FB2316 KX | 20 | 11 | 1 | 0 | 7 | 4 |
| HP ECS, provisional | 10 | 12 | 0 | 0 | 7 | 7 |
| HP ECS, provisional | 20 | 12 | 0 | 0 | 9 | 9 |
| ID400 awake | 10 | 12 | 0 | 0 | 5 | 3 |
| ID400 awake | 20 | 12 | 0 | 0 | 6 | 3 |

Thus 91/96 original-interval rows have complete flanks. The five unavailable rows
are FB2314 1–6 (preceding flank at both scales), FB2314 1180–1200 (following flank
at both scales), and FB2316 20–23 (preceding flank at 20 samples). Across all
annotations and alternatives, 165/170 rows have complete flanks. No incomplete
window was shortened, moved, padded or filled with zero.

## Scientific reading

**FB2314 pocket 177–195: context is not the accepted reference.** Your accepted
165–176 reference remains 12 explicitly selected samples, including shared frame
165. The ten-sample diagnostic window uses 167–176; the twenty-sample window uses
157–176 and therefore contacts the approximate preceding pocket at 155–165 on
frames 157–165. That contact remains approximate human context, separate from
native occupancy. Neither window replaces the accepted reference or recalculates
an optical baseline. Changing the preceding diagnostic window changes its decline
contrast from 774.20 to 579.77 corrected-intensity units and its unscaled MAD from
239.52 to 295.55. The source detector label remains surge; the researcher describes
a pocket. Both signed contrasts remain available without relabeling the native event.

**ID400 surge 529–546: useful context without an acceptance rule.** Rise contrasts
against the preceding median are 6.31 and 6.61 units for 10/20 samples; against the
following median they are 5.81 and 5.05. The recovery sample is 0.23 and 0.99 units
below those following medians. These values describe the supplied interval; they
do not establish exact recovery or rescue the earlier unsuccessful automatic
shoulder/range-screen candidates. No such candidate was rerun or adopted here.

**Nonrecognized intervals retain their judgments.** For FB2316 surge site 10/event
3, which the researcher did not recognize, the maximum is nevertheless 68.14 and
68.43 units above its preceding medians. A positive directional contrast alone is
therefore not equivalent to recognition. The HP sink nonrecognition and its stated
variability rationale also remain intact. No threshold was fitted to these cases.
Intensity values are specific to their recording and footprint; they are not
pooled across animals or compared as calibrated oxygen changes.

These observations support keeping return/context relationships visible and
preserving local reference decisions. They do not identify a universal decline
model, context duration, event threshold or physiological baseline. The original
recording-specific correction is unchanged.

## Inspect and reproduce

The [complete table](reference-results/boi-panel-temporal-comparison-20260915/run-02/comparison-summary.csv) and
[structured results](reference-results/boi-panel-temporal-comparison-20260915/run-02/comparison.json) contain all rows, both signed
contrasts, exact frame memberships, corrected samples, tied extrema, missingness
reasons, native contributors and human-contact sources. Per-recording files save
unchanged automatic rows, corrected traces and one-based footprint pixel IDs.
[Availability by recording and annotation role](reference-results/boi-panel-temporal-comparison-20260915/run-02/availability-by-recording-and-role.json)
keeps historical alternatives separate from the original population.

The two illustrations were selected before execution:
[FB2314 pocket and accepted reference](reference-results/boi-panel-temporal-comparison-20260915/run-02/fb2314-reviewed-pocket-context.png)
and [ID400 recognized surge](reference-results/boi-panel-temporal-comparison-20260915/run-02/id400-reviewed-surge-context.png).
Blue/green bands show preceding/following ranges, medians and unscaled MAD.
Red dashed lines are automatic bounds; purple dotted lines are supplied bounds.
Orange frame markers retain the accepted 165–176 reference where applicable.
The figures do not request another round of labeling.

All formulas are unchanged from phase085: side medians, extrema, range and
unscaled MAD; interval extrema and tied frames; both signed contrasts; and endpoint
relationships. All required samples must be observed and finite. The external
clock remains exactly 1 Hz, frame 1 at modeled zero seconds. No new smoothing,
correction, boundary search, denominator, optical amplitude, baseline or classifier
was introduced. Runnable diagnostic files remain outside the production MATLAB
path; portable `.m.txt` copies are evidence, not installed production functions.

## Technical verification and one corrective round

The same 12 known-shape fixtures were independently replayed before execution,
and all three arithmetic/contact helper hashes match phase085. Result verification
reproduced all 170 rows and source-bound intervals, 50,400 saved corrected samples,
243,193 footprint pixel IDs, 10,153 repeated native frame records and 336 human
contact records. Native union pixel counts were separately checked against the
prior saved replay; per-frame contact flags also match the earlier trace exports.
Numerical tolerance remains 1e-9 absolute plus 1e-12 relative; integer frame sets
and availability statuses are exact. Both rendered illustrations were inspected.

The initial run completed FB2314, then stopped because two legacy audits lack
`AnalysisInfo.FrameSize`. Their saved native site tables contain that geometry.
One local compatibility correction obtains dimensions from those tables, checks
every site from both signs, and keeps original AnalysisInfo equality checks and
all identity/support/measurement checks. The production loader was not changed.
This exposes a separate legacy GUI-compatibility limitation, not a scientific
schema or metadata rewrite.

The failed attempt and completed FB2314 exports remain in `run-01`. The resumed
`run-02` copies those exports byte-for-byte and reconstructs FB2314's previously
unpersisted descriptor rows from them; its native calculation is not repeated.
The remaining recordings complete their first native calculations. The successful
resume took 27.93 MATLAB seconds and wrote about 10.08 MB; the earlier completed
FB2314 source pass took 4.62 seconds. Startup, stopped-loader and schema-inspection
logs are also preserved; these timings are not a full wall-clock benchmark.
The frozen five-minute-per-recording/100-MiB output budget was respected. There
were no movie reads, detector runs, correction fits or parameter searches.

All 485 repository MATLAB files, all 131 preceding sealed artifacts, the 136 bound
sources, dictionary, saved automatic results and cumulative judgments remain
unchanged. The compatibility adapter and corrected runner are separately hashed;
the original freeze and failed script/log remain inspectable.

## Next step and limits

This bounded comparison is complete. Next is an optional MATLAB review view that
shows these context descriptors alongside the corrected trace, with accepted
references displayed separately and historical/current annotations distinguished.
The legacy geometry compatibility needs explicit handling in that work. No new
recognition rule or default exclusion should be inferred from this diagnostic.

Any subsequent detector/timing change still needs its own recorded decision and
original measurement regression. Biological coverage, precise onset/recovery,
spatial candidate completeness, dynamic validity, anatomical/calibration and HP
identity uncertainty, physiological meaning and cohort eligibility remain open.
BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements.

[Evidence packet](reference-results/boi-panel-temporal-comparison-20260915/README.md).
