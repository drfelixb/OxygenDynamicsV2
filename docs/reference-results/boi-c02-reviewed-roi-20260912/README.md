# FB2314 awake: reviewed working ROI run

12 September 2026 · **R1-C02-ROI-RUN-031** · one fresh BOI master/statistics pair.

The user reviewed the [craniotomy comparison](../boi-c02-craniotomy-20260912/README.md)
and replied **“Looks good. Go on.”** The displayed FB2314 awake outline is now
applied as the **working static ROI for this bounded development run**. Its
uncertain segments remain explicit; this is not independent surgical-edge
annotation, acceptance of other recordings' masks or a final cohort freeze.

The run retains the inspected interior sink support and has no same-sign native
overlap with the five flagged peripheral examples. It also demonstrates why the
current reviewed-mask implementation is insufficient for strict craniotomy
restriction: **5.13% of sink and 7.85% of surge native detected area-time remains
outside the working ROI**. Whole-image normalization and full accepted footprints
were deliberately unchanged in this comparison.

## What changed

One exact source copy, all 1200 frames, external **1 Hz**, 2.35 µm/pixel, both signs,
two MATLAB workers and unchanged default parameters. `writeBOITissueSupport`
captured the source-bound 024 mask in a new recording stage. All 461 existing
MATLAB files and dictionary **0.3.0-draft** remain unchanged. The sole analysis
change is reviewed eligible support in the existing implementation.

The [prespecification](prespecification.json) records scope, selection, limits
and stopping rules. [Captured acquisition metadata](BOIInputMetadata.json) retains
unreliable file clocks, unknown camera exposure/intensity history and undeclared
frame validity. It records the working ROI and remaining limitations; no source
folder was edited. The full `BOITissueSupport.json` and its native pixel indices
are saved in the fresh stage and normal statistics contracts. The original
automatic-support [028 workflow](../boi-c02-workflow-20260912/README.md) is preserved.

## Actual before/after results

These are **method/support differences within the same recording**, not a
biological treatment contrast or evidence that fewer events are inherently better.

| Measurement | Automatic sinks | Working-ROI sinks | Automatic surges | Working-ROI surges |
|---|---:|---:|---:|---:|
| Detected events | 219 | 175 | 49 | 21 |
| Finite amplitudes | 109 | 100 | 13 | 11 |
| Unavailable amplitudes | 110 | 75 | 36 | 10 |
| Negative finite amplitudes | 0 | 0 | 2 | 0 |
| Modeled tissue area (µm²) | 894,810.675 | 714,650.158 | 1,002,090.760 | 724,193.038 |
| Detected covered area-time (µm²·s) | 6,159,398.88 | 2,353,358.15 | 36,404,154.33 | 7,761,824.05 |
| Occupied fraction, expressed as % | 0.5736% | 0.2744% | 3.0274% | 0.8932% |
| Unavailable-amplitude share of detected covered area-time | 76.63% | 57.14% | 89.59% | 61.54% |

Each occupied fraction uses its own realized native numerator and sign-specific
modeled tissue-time denominator. The existing 20-pixel image-border exclusion
still applies to sinks. All 1200 intervals remain modeled; no temporal exclusion
or physiological validity was inferred. The sink onset rate is essentially
unchanged (12.2372 versus 12.2438 events/mm²/min) despite the count change, because
the area also changes. This illustrates why event counts alone cannot assess a
support revision. Scientific onset/censoring remains unresolved.

All missing amplitudes retain `insufficient_clean_prebaseline`; the required
20 samples were not shortened, moved or imputed. Missing amplitudes continue to
contribute native coverage. The sink composite remains unavailable; a surge
composite remains undefined. Baseline-local uncertainty is separate from the
user's established-state-before-recording clarification.

## Location-based comparison, not ID matching

New site/event numbers are local to the new run. The comparison therefore uses
native pixel/time intersections with the seven old examples from 030.

- Old interior sinks **1/1 and 1/2 retain 100%** of their native pixel-time in the
  new same-sign union. The finite sink has the same 361-pixel union footprint,
  baseline 6053.483795 and **9.346906%** amplitude.
- Old peripheral sink **5/4** and surges **1/1, 4/1, 16/1 and 16/7** have **zero
  native pixel-time overlap** with the new same-sign union. No manual event
  deletion or sign rectification was used.

See [old-example overlap](old-example-overlap.csv), [sink frame comparison](sink-frame-comparison.csv)
and [surge frame comparison](surge-frame-comparison.csv). These relationships
describe spatial support at the same original times, not proof of one-to-one
biological event identity. Across the complete recording, both old-only and
new-only native pixels exist; the change is not equivalent to filtering old
event rows or swapping a denominator.

## Residual boundary support and source review

The new saved native masks contain **23,053 / 449,193 sink pixel-seconds** and
**119,739 / 1,525,230 surge pixel-seconds** outside the working ROI. These give
5.13% and 7.85%, respectively, using full native event support rather than the
tissue-intersected coverage numerator. No event is wholly outside, but **44/175
sinks and 15/21 surges** contain at least one exterior native pixel. The full
[sink geometry](sink-event-geometry.csv) and [surge geometry](surge-event-geometry.csv)
preserve these distinctions; any-outside counts are not severity thresholds.

Four new cases were selected by the recorded rules and inspected:

| New case | Selection | Finding | Figure |
|---|---|---|---|
| sink 1/2 | first finite sink | Interior, unchanged optical example; local drop within broad changing context | [review](sink-site01-event02/review.png) |
| sink 5/1 | first sink with any exterior native pixel | 15.03% native pixel-time outside; only 17/20 clean baseline samples, amplitude unavailable | [review](sink-site05-event01/review.png) |
| surge 1/1 | first finite surge | Interior; +7.8627%, with a rising baseline/broader trace | [review](surge-site01-event01/review.png) |
| surge 3/1 | first surge with any exterior native pixel | Only four exterior pixel-seconds (0.0155%); +5.7573%, not a representative large exterior case | [review](surge-site03-event01/review.png) |

Figures show the working ROI in green, exact displayed-frame native mask in cyan
and fixed quantitative footprint in light gray. Traces use original input means,
green clean baseline samples and red measurement bounds. Display limits remain
[245,22493]. Green denotes the applied working ROI; prior uncertain perimeter
segments are retained in the source outline record, not resolved by this display.
Each folder includes its 1200-sample trace, fixed footprint and source-bound
summary. Clean numerical baselines still do not establish stationarity or
isolated physiological event identity inside the ROI.

## Decision and next method specification

Retain this working-ROI run as an explicit comparison arm. The support change
addresses the inspected peripheral detections, but **does not implement strict
craniotomy restriction**. The current candidate rule allows crossing regions,
accepted footprints are not clipped, and spatial normalization and percentile
selection still use image-wide values.

The [next restricted-support specification](strict-roi-specification.md) defines
the proposed operations and checks before a separately versioned method run:
ROI-only normalization and thresholds, support-weighted spatial smoothing,
candidate restriction before component formation and final native-footprint
containment. It preserves raw quantitative source, both signs and existing
baseline/timing rules. Its scientific effects and edge behavior require an
explicit comparison; no new calculation is silently installed here. This
single-recording phase is complete. No second state/mouse or biological contrast
was run, and no new threshold was tuned to the observed counts.

## Verification, feasibility and reproduction

- One master: **51.12 s**; one statistics run: **31.11 s**; whole execution process
  **118.21 s**. Initial output **3.00 GiB**, below the 5 GiB review target;
  peak process RSS **13.72 GiB**. Detailed process measurements are in
  [resource summary](resource-summary.json).
- Separate source audit: **196/196** event amplitudes/baseline statuses agree.
  [Workflow verification](verification.json) independently reproduces all 2400
  sign/frame native coverage/availability rows and both first-finite 1200-frame
  traces, with the actual ROI and sink crop checked exactly.
- [Comparison verification](comparison-verification.json) reproduces all 196
  native event geometries, 2400 before/after frame unions, seven old-example
  overlaps and **4800 source samples** for the four prespecified new examples.
- All four source/ROI/trace panels were visually inspected. No automated
  physiological acceptance or independent researcher walkthrough is claimed.

The source audit completed successfully, but the subsequent comparison dispatch
failed because the audit left a variable named `run`, shadowing MATLAB's command.
The comparison then completed in a fresh MATLAB process; no detector, statistics
or source audit was rerun. The [dispatch record](dispatch-failure.json) preserves
that failure and its logs. This reinforces using separate execution contexts for
standalone evidence scripts; the normal isolated master API was unaffected.

The local evidence folder `reference-validation/boi-c02-reviewed-roi-20260912`
contains the executed runners, exact input mapping, working support declaration,
full master/statistics outputs, source audit and native replay MATs. Run the
existing MATLAB event viewer on its `audit-01/source-amplitude-audit/` file to
inspect new combined audit rows **2, 14, 176, 180**. Attach masters from this fresh
stage, not the old automatic-support stage. The saved dictionary and readable
guide accompany the portable packet. [Artifact checks](artifact-record.json)
bind the new evidence and verify preservation of preceding artifacts and
original legacy files.
