# FB2420 discrepancy audit

15 September 2026 · R3-FB2420-DISCREPANCY-AUDIT-083

**The bounded read-only audit is complete.** The saved pipeline faithfully
reproduces its measurements, but its spatial-contrast candidates and temporal
grouping do not consistently correspond to the corrected-intensity events used
in researcher review. The discrepancies have several sources; this audit does
not support a single threshold adjustment, sign repair or new substrate model.
No production code, source correction, detector output or human judgment changed.

## What was checked

The scope remained the same nine frozen cases, the three previously described
pocket observations (four interval records because 84/85 are recovery alternatives),
and reference eligibility for the recognized surge. We read the full-precision
stages already saved by phase 074 and matched all 330 event identities, native
runs and fixed footprints to both masters. Processed display TIFFs were not used
as numerical input. No detector, full-stack reconstruction or polynomial fit ran.

Each case has a full 1200-frame table containing preserved input, saved removed
trend, corrected intensity, spatial normalization, temporal normalization,
filtered score, saved site trace and native support counts. Stage figures use the
original measured bounds plus 40 frames of context, expanded to include saved
human bounds where needed. The full-trace overview remains available. Correlations
below describe those windows; they do not measure recognition accuracy or causality.

## 1. Spatial normalization can change the temporal pattern

The existing workflow first removes a cubic trend from each pixel, then performs:

1. Within each frame, subtract the accepted ROI's mean corrected intensity and
   divide by its sample standard deviation.
2. For each included pixel, subtract its temporal mean and divide by its temporal
   sample standard deviation.
3. Smooth across included spatial neighbors (21 × 21 pixels here), then apply
   temporal Gaussian smoothing with the saved `smooth/2` setting (5 here).
4. Select spatial percentile extremes per frame, followed by morphology, tracking
   and duration rules: 99th percentile after inversion for sinks and 90th percentile
   for surges. This spatial selection does not directly test a corrected-trace
   excursion against nearby biological variability.

The code and its hash-bound snapshots document this intended calculation.
The spatial normalization is relative to other ROI pixels at each frame; it
need not preserve the temporal shape of a fixed footprint's corrected intensity.

| Case | Human recognition | Corrected vs spatial Z | Spatial Z vs temporal Z | Temporal Z vs filtered | Corrected vs filtered |
|---|---|---:|---:|---:|---:|
| 1 | No | 0.649 | 1.000 | 0.899 | 0.609 |
| 2 | No, marked interval | 0.890 | 1.000 | 0.991 | 0.896 |
| 3 | No, marked interval | 0.118 | 0.999 | 0.961 | −0.021 |
| 4 | No | 0.974 | 0.999 | 0.996 | 0.972 |
| 5 | No | 0.965 | 1.000 | 0.975 | 0.966 |
| 6 | Yes, about 130–150 | 0.028 | 0.992 | 0.960 | −0.187 |
| 7 | No | 0.892 | 0.999 | 0.987 | 0.885 |
| 8 | No | 0.783 | 0.999 | 0.975 | 0.727 |
| 9 | No | −0.860 | 1.000 | 0.982 | −0.865 |

Rounded 1.000 is not exact equality; full precision is retained in the tables.
In **case 9**, the near-opposite pattern is already present at spatial
normalization, before smoothing. **Case 3** likewise loses much of its corrected
trace's local shape at that step. This identifies a stage where correspondence
changes; it does not isolate the physiological or acquisition source of the ROI
mean/variance changes or establish what any replacement would recover.

**Cases 4 and 5 are counterexamples to a correlation filter:** their scores follow
the corrected traces closely, yet the researcher did not recognize the marked
pockets. The recognized surge in case 6 also has low correlation over its broader
window. Recognition therefore requires temporal context, not merely score/trace
agreement. Eight rejected cases are not eight proven false positives.

![Case 9 stage comparison](run-01/case-09-stages.png)

## 2. Two contextual intervals lack retained native coverage

Both-sign native pixels were intersected with the exact footprint on which each
human observation was made, frame by frame. No cross-footprint identity was assumed.

| Observation | Native contact on that original footprint |
|---|---|
| Case 2, tentative 2–28 | Sink site 1/event 1 overlaps all 27 frames; mean coverage 57.81% of the fixed 744-pixel footprint. No other event contributes. |
| Case 2, tentative 65–84 or 65–85 | No retained sink or surge pixels overlap that footprint in either alternative. |
| Case 3, around 7 to likely 27 | No retained sink or surge pixels overlap the fixed 618-pixel footprint during these 21 frames. |

The early case-2 observation may involve temporal grouping/boundary mismatch
inside a longer native event (1–44, measured 1–48); overlap alone does not confirm
identity. The other two intervals expose a coverage gap on the displayed
footprints. They cannot be recovered simply by rejecting existing candidates.
This is **absence from retained native output**, not proof that no intermediate
candidate existed or that the observations are calibrated physiological events.
The audit does not determine whether percentile selection, morphology, duration,
tracking or another retention step caused their absence. Candidate-level replay
would be a separate diagnostic.

![Contextual pockets and native coverage](run-01/contextual-pockets.png)

## 3. Spatial support and timing traces are distinct

The fixed event footprints range from 119 to 19139 pixels. Six of nine are
smaller than their lifetime site unions: event/site fractions range from 0.373
to 0.793 for those six. For case 2 the event uses 744 pixels while the site uses
1996; for case 9 these are 19139 versus 26841 pixels. Exact per-frame native
area is smaller again and varies during each event.

Sink timing uses the lifetime-site filtered trace after a fifth-order trend
removal and a seventh-order timing return-level fit. These existing operations
are different from the original pixelwise cubic correction. The event review's
primary trace uses the fixed event-union footprint. Case 1 has the same event
and site footprint, yet filtered-event versus saved-site correlation is −0.112
in the local window; the extra site detrending remains relevant even when
footprints match. No new fit was performed here. For surges the saved site trace
uses the normalized, unsmoothed lifetime-site signal; native runs determine the
saved surge interval.

The map shows case 9 extending into the dim left part of the accepted working
ROI. The recognized case 6 is also toward the upper-left region. Brightness or
edge proximity alone cannot justify deleting support. Registration, surgical
boundary and time-varying validity remain unresolved; the accepted mask is intact.

![Fixed event and lifetime site footprints](run-01/footprint-map.png)

Native recurrence is also a grouping property: case 5 follows a one-frame gap,
case 8 a four-frame gap, and case 9 a one-frame gap. Such gaps do not demonstrate
biological separation or a recovered reference level. Exact same-site event
records and native coverage traces are retained for all nine cases.

## 4. Existing correction and reference evidence

Preserved input minus its saved cubic trend agrees with the stored corrected
footprint trace to within 0.000049 input units in all nine cases, consistent with
the pipeline's single-precision stage storage. This is arithmetic agreement,
not physiological validation of correction. The full traces retain broad shared
temporal structure (pairwise corrected correlations 0.516–0.967 in this selected
set). This alone cannot identify substrate effects, physiology or common artifacts.
The recording's original correction remains unchanged; no universal decay model
or new detrending was fitted.

For the recognized surge, the default 20-frame reference candidate before human
onset 130 is **110–129**. All 20 frames are finite and have no native-event overlap
under the existing preview. No human reference has been selected. The corrected
trace still varies within that window, so native eligibility does not establish
physiological quietness or adequate reference precision. Automatic amplitude used
its original reference before 134; that measurement is not substituted for a
reviewed quantity using the human interval.

Missing amplitudes remain missing. Cases 2, 3, 5 and 7 have truncated pre-event
context; case 5 additionally loses four samples to native overlap. Cases 8 and 9
retain only four and one of their original 20 candidate baseline frames because
of overlap. Missingness is distinct from recognition and must not remove these
cases from the audit denominator.

## Verification, feasibility and next decision

MATLAB completed the main audit in 33.53 seconds with about 4.19 MB of initial
output, inside the fixed 10-minute/200-MiB bound. A second invocation only rendered
the contextual overview from saved tables. Python independently reproduced 54
stage correlations, compared 32400 raw/corrected/filtered values with phase-074
exports, checked native bounds/counts and all contact summaries, and verified the
20 reference-eligibility rows. All nine stage figures and both overview maps were
visually inspected; the contextual overview is also checked. No new biological
validation claim follows from these technical checks.

All 485 MATLAB files and the preceding 35 sealed phase-082 artifacts are preserved,
with append-only ledger updates and prior snapshots. The full source-bound packet
retains the frozen diagnostic plan, scripts, stage tables, contacts, reference
preview, code snapshots, independent checks and hashes.

**Recommended next step:** specify one bounded, separate temporal-evidence
comparison on the original corrected traces. It should cover both retained
spatial candidates and the already reviewed footprints with absent native output,
retain uncertainty and missing-reference states, and compare explicit local
variability/return context without using correlation as a pass/fail threshold.
Treat it as a development diagnostic with outputs separate from the original
pipeline. Before implementation, record the exact reference assumptions,
comparison rule, resource/iteration limit and regression requirements. The
existing 48-event challenge remains required for any later detector/timing change.
No such rule, threshold, replacement normalizer or scientific policy is adopted
by this audit. There is no evidence here that a single normalization removal or
smoothing adjustment would solve all discrepancies.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Event identity, temporal
reference precision, anatomy/calibration, dynamic validity, transient effects and
independence remain open. This completes the discrepancy-audit phase, not the
scientific reanalysis or release gates.
