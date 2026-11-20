# Surge shape continuity validation, 2026-09-09

Current rules and output definitions: [SURGE_TRACKING.md](../../SURGE_TRACKING.md).
This revision extends the preceding mutual-coverage tracker (`73415d6`) with a
bounded, isolated containment fallback. The alternative detector is separate.

## Fixed design and interpretation

The three limits were set before viewing this rerun: primary mutual coverage
0.6; fallback smaller-region coverage 0.8; maximum larger/smaller area ratio 2.
Fallback requires exactly one nonzero-overlapping candidate partner at each
endpoint. The ten-second contiguous minimum remains unchanged. Gap review
covers up to two empty seconds and never fills masks or joins events.

The 117 prescribed cases comprise thirteen geometries/gap patterns at three
pixel calibrations (2.35, 4.75, 6.75 µm/pixel) and three sampling rates (0.5, 1,
2 Hz). Each is compared against mutual-only linking with identical candidates
and duration rules (fallback disabled by maximum area ratio 1). These are
candidate-mask tests, not image preprocessing or biological accuracy tests.

| Prescribed signal | Mutual-only result | Shape-continuity result |
|---|---|---|
| Stationary or smooth growth/shrinkage | One complete 24-second event | Same |
| Isolated abrupt radius 60→82 µm or reverse | Two 12-second events | One complete 24-second event |
| Radius alternates 60/82 µm every two seconds | No duration-qualified event | One complete 24-second event |
| Extreme radius 60→120 µm | Two 12-second events | Same; outside fallback bound |
| Two neighboring regions contact one merged region, or reverse | Three separate 12-second runs | Same; fallback blocked |
| One-frame dropout or true return, identical masks | Two 12-second events | Same; gap-review pair recorded |
| Six seconds + blank frame + six seconds | Two rejected candidates, zero events | Same; gap-review pair recorded |
| Two 12-second runs separated by ≥3 seconds | Two events | Same; outside short-gap review |

These results hold across all nine calibration/sampling combinations. The
neighbor cases are flagged as ambiguous contacts; neither tracker reconstructs
biological split/merge lineage. The blank interval in the dropout/true-return
fixtures is intentionally indistinguishable from candidate masks alone.

## Complete archived backgrounds

The twenty inputs reproduce all five previous recipes on the same four
recordings. Exact source asset IDs, series, hashes, calibration and injection
ledgers are saved under `manifests/`. Inputs are compared against the previous
movies and independently verified against the archived pixel values and saved
injection factors. The previous [report](../surge-physical-adjacent-20260909/README.md)
describes the fixed pulse, motion and correlated-intensity-noise recipes.

| Session | Role | Complete image dimensions | Pixel size | Sampling |
|---|---|---|---|---|
| M400-01-baseline-awake | BOI reference, ID400 | 512 × 512 × 600 | 4.75 µm | 1 Hz |
| M401-01-baseline-awake | BOI reference, ID401 | 512 × 512 × 600 | 4.75 µm | 1 Hz |
| FB2312-baseline-awake | BOI reference, FB2312 | 512 × 512 × 1,200 | 2.35 µm | 1 Hz |
| FB2411 | Separate fluorescence control | 221 × 394 × 301 | 6.75 µm | 1 Hz |

Cases per source: unchanged control, six smooth paired pulses, one clean smooth
pulse, its noisy counterpart, and one clean moving pulse. Both signs are injected
at separate locations. These are **four source recordings**, not twenty
independent biological samples. No manually reviewed natural-event labels exist.

## Completed full-movie results

All twenty runs passed. **3,905 retained-event baseline/amplitude records**
(3,327 sinks and 578 surges) agree with independent recalculation, including
1,943 unavailable amplitudes. There are 1,962 finite amplitudes: 1,637 sink and
325 surge measurements. Ten sink and 26 surge amplitudes are negative in their
respective expected-direction convention; their signed values and QC remain
visible. Raw optical baseline change can differ in sign from normalized spatial
contrast. No absolute-value correction or baseline imputation is applied.

All twenty byte-identical input comparisons preserve sink native masks, timing
and identities. Sink finite-amplitude availability changes from 1,656 to 1,637
through the existing cross-sign baseline exclusion. Surge runs increase from
446 to 578, with finite amplitudes increasing from 240 to 325. Of the 578 retained
surges, 270 contain at least one shape fallback and 110 have a possible short-gap
continuation (possibly with a rejected candidate). These totals pool technical
challenge runs for validation accounting; they are not biological sample sizes.

Unmodified recordings, with events and recurring spatial sites separated:

| Source | Previous surge events / sites | Current surge events / sites | Previous → current finite surge amplitudes |
|---|---:|---:|---:|
| ID400 | 32 / 27 | 50 / 41 | 19 → 28 |
| ID401 | 4 / 4 | 9 / 8 | 3 → 7 |
| FB2312 | 35 / 16 | 39 / 17 | 16 → 20 |
| FB2411 fluorescence control | 6 / 6 | 7 / 7 | 2 → 2 |

The full-background improvement is **limited**, despite clear improvement in
prescribed expansion/contraction masks. Of 36 imposed surge supports across the
four sources, 34 have unchanged best native space-time IoU. Only two change:

- ID400 smooth-pair window 1 increases from 0.4141 to 0.4305.
- FB2312 clean stationary singleton changes from no intersection to IoU 0.1347,
  with retained frames 133–142 inside the imposed 101–160 support. The matched
  event reports a 0.0933 fractional optical increase; the local imposed peak is
  near 0.20. This fixed-footprint, recorded-background measurement is not a
  direct estimate of the injection coefficient or calibrated oxygen change.

None of the previously missed paired-pulse windows gains a retained intersecting
run: ID400 remains 3/6, ID401 3/6, FB2312 2/6 and fluorescence control 0/6.
All four moving-singleton best overlaps remain unchanged. In particular, ID400
still retains only frames 107–116 for its imposed 101–160 moving support.
A nonzero overlap is not an accuracy threshold; unchanged overlap does not imply
all event metadata or background detections are unchanged.

Every generated movie was checked against archived source pixels and the saved
injection ledger: **3,276,774,370 pixels verified**. All 136 support-score rows
and saved surge geometry/provenance checks pass. Noise-free pulses and motion
are independently reconstructed analytically; MATLAB's noise RNG sequence is
not independently regenerated. All 78 focused tests, smoke and master/statistics
integration passed. Repository checks inspect 365 MATLAB files; 73 Code Analyzer
messages remain, including style/performance suggestions. The changed production
tracking/QC helpers inspected separately have no analyzer messages.

## Candidate provenance and remaining stage losses

Across the twenty technical runs, 42,732 contiguous surge candidates were
tracked: 578 passed duration and 42,154 were rejected. The separate gap table
contains 1,511 possible short-gap pairs. These are candidate/QC accounting
figures, not physiological event counts. Complete candidate ledgers are retained
in compressed form with the report.

Three production-stage reconstructions reproduce final saved surge masks
exactly. ID400 missed pair windows 3/4/5 still have longest intersecting tracks
of 6/6/8 frames despite accepted candidate pixels in 12/13/10 frames. ID401's
first window has 14 consecutive frames with accepted pixels, now divided into
two seven-frame tracks (44–50 and 51–57); neither qualifies. This is an adjacent
geometry/assignment break, not an empty-frame gap that the short-gap flag could
resolve. Its other missed windows have longest intersecting tracks of 3 and 7
frames. The ID400 moving support still intersects accepted candidates in 50 of
60 frames, divided into 18 tracks; one ten-frame run survives.

The first three stage summaries operate on the union of pixels per frame.
Their native row bounds must not be interpreted as one region's lifetime.
These reconstructions reuse production preprocessing; they localize failure
without providing independent biological truth.

## What to do next

The bounded fallback is justified by controlled geometry, but it does not solve
the dominant remaining smooth-signal failures on these backgrounds. Use the
stage traces and candidate ledgers to inspect preserved-input versus normalized
signals in the still-missed windows. Test signal-supported candidate continuity
and surge onset/baseline definitions with complete-movie expanding/contracting
signals before further relaxation of tracking or duration. A six-second fragment
plus a gap plus six seconds must not silently become twelve observed seconds.

An algorithmically valid pre-event baseline can still contain an undetected
smooth rise, and fixed event-union footprints can dilute moving/local signals.
These limitations require explicit signal-definition work before interpreting
surge amplitudes and experimental-baseline contrasts for publication. More
retained background runs are not evidence of increased biological sensitivity.

## Evidence scope

- `candidate-qc-by-recording.csv` separates rejected candidates, retained events,
  recurring sites and short-gap pairs. Complete per-recording candidate tables
  are preserved losslessly as gzip-compressed CSV under `candidate-ledgers/`;
  the runtime folders contain ordinary CSV. They never become pooled event observations.
- `recording-qc.csv` and `independent-amplitude-audit.csv` cover all retained
  events, including unrelated background detections and unavailable amplitudes.
  Arithmetic agreement tests the saved definition, not physiological accuracy.
- `tracking-signal-results.csv` measures native space-time intersection/union
  against each imposed support. Nonzero intersection is not an accuracy cutoff.
- Saved masks independently establish adjacent coverage/containment/area ratios,
  exact fallback frame lists, physical area, duration, fixed site-anchor coverage
  and unique pixel ownership. The audit checks fallback isolation against other
  retained masks. Rejected candidate masks are not saved, so full candidate-graph
  isolation is checked by controlled tests and production reconstruction rather
  than claimed as an independent reconstruction from the saved ledgers.
- Candidate-ID joins, keep/reject decisions, missing rejected event/site IDs,
  gap lengths and review-flag counts are checked independently. Endpoint overlap
  is recomputed from saved pixels when both linked candidates were retained.
- Stage traces reuse production preprocessing to localize losses and must
  reproduce final saved masks exactly. The first three stages summarize unions
  of candidate pixels by frame; their row bounds are not individual region lives.
- Code hashes are checked before/after the full run and against the committed
  MATLAB sources. This report does not freeze future development revisions.

## Reproduction

From the repository root, with the pinned converted sources present:

```matlab
setupOxygenDynamicsPath;
addpath('tests/analysis');
runSurgeContinuitySweep('NEW_SWEEP_ROOT');
runSurgeTrackingValidation('../reference-validation/phase1-optimized-20260909', 'NEW_RUN_ROOT');
auditSurgeTrackingOutputs('NEW_RUN_ROOT', 'NEW_AUDIT_ROOT');
compareSurgeContinuityReference('../reference-validation/surge-physical-adjacent-20260909', 'NEW_RUN_ROOT', 'NEW_COMPARISON_ROOT');
```

Run `tests/analysis/verify_tracking_signal_inputs.py NEW_RUN_ROOT` with NumPy and
Pillow. Large TIFF/MAT outputs remain under
`reference-validation/surge-shape-continuity-20260909` beside the repository;
compact evidence is committed here. Reanalysis is required for the new detector
`existing-v2-surge-shape-continuity-5`, measurement
`event-footprint-candidate-ledger-6` and statistics `mouse-strict-shape-gap-qc-7`.
