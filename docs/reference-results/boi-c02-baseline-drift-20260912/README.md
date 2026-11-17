# FB2314 pre-event baseline drift

**R2-C02-BASELINE-DRIFT-036 — descriptive audit complete; baseline choice remains open.**
12 September 2026. BOI only. These are three previously selected events in **one FB2314 awake recording**, not three mice or independent biological replicates.

The actual 20-second baselines contain substantial fluctuations. Two local full-window slopes are negative and the third is nearly zero, but one straight line describes little of their variation. Expected substrate consumption remains experimental context; these short traces do not identify its contribution or justify a uniform decay correction.

## Exact events and preserved measurement

| Saved event | Original baseline frames | Measurement frames | Native detection frames | Native union footprint | Original amplitude |
|---|---|---|---|---:|---:|
| Sink site 10, event 1 | 42–61 | 62–76 | 67–71 | 434 pixels | −0.395% |
| Surge site 1, event 3 | 483–502 | 503–514 | 503–514 | 10,951 pixels | −2.064% |
| Surge site 1, event 4 | 520–539 | 540–552 | 540–552 | 11,565 pixels | −0.983% |

All baselines have **20 finite, nonoverlapping samples at externally triggered 1 Hz** on the unchanged native union footprint. No earlier samples replace them. The first and last samples are 19 seconds apart; the baseline covers 20 one-second samples. These are event amplitude baselines, distinct from establishing an experimental condition before recording.

Negative amplitudes are the saved sign-specific results: a sink's original-source minimum remains above its baseline, or a surge's maximum remains below it. They are not silently converted to positive amplitudes or relabeled. The saved values replay exactly in MATLAB and within numerical export precision independently.

## Observed baseline slopes and variability

Each signal is normalized to its own mean over the same 20 frames. Slopes are percentage points of that mean per second. The last column is the fitted difference between the first and last baseline sample, not the measured event amplitude or an estimate of substrate loss.

| Event | Local slope (%/s) | Whole-ROI slope (%/s) | Local slope, first 10 samples (%/s) | Local slope, last 10 samples (%/s) | Local fitted change across 19 s |
|---|---:|---:|---:|---:|---:|
| Sink 10/1 | −0.1027 | −0.0882 | −0.8534 | +0.1862 | −1.952% |
| Surge 1/3 | −0.1634 | +0.0466 | −0.4848 | −0.5623 | −3.104% |
| Surge 1/4 | +0.0056 | +0.1913 | +0.1022 | −0.2036 | +0.106% |

The sink and surge 1/4 reverse local slope direction between their halves. Surge 1/3 declines within each half but rises around their boundary; its full-window slope is therefore much less negative than either within-half slope. This is visible in the samples and does not indicate an arithmetic inconsistency.

| Event | Local peak-to-trough variation | Local residual RMS about the line | Local descriptive R² | Local/ROI baseline correlation |
|---|---:|---:|---:|---:|
| Sink 10/1 | 9.961% | 2.289% | 0.0628 | −0.135 |
| Surge 1/3 | 8.329% | 2.054% | 0.1739 | +0.746 |
| Surge 1/4 | 3.788% | 1.136% | 0.0008 | +0.642 |

The full-window line explains about 6.3%, 17.4% and 0.08% of local sample variation, respectively. These are descriptive fit measures, not hypothesis tests or thresholds for accepting a trend model. The first-five versus last-five mean changes are −2.284%, −3.268% and +0.229%, preserving a second descriptive summary that does not depend on the fitted slope.

The ROI reference does not follow the local slope uniformly. In both surge baselines its full-window slope is positive, despite a negative or nearly flat local slope. The ROI includes the event footprint and may include activity elsewhere; it is not an independent, event-free substrate monitor. Positive correlation can coexist with different slopes. No shared ROI component was subtracted here.

## Trace inspection

Top panels show the fixed context from 60 seconds before measurement start to 30 seconds after its end, clipped to recording bounds. Green marks the original baseline, yellow the measurement window and the black bar the native detection span. Bottom panels show only the 20 baseline samples and full-window linear fits; the dotted vertical divider separates the two ten-sample subsets. All fits stop at the baseline boundary.

![Sink 10/1](sink-site10-event1/baseline-drift.png)

![Surge 1/3](surge-site1-event3/baseline-drift.png)

![Surge 1/4](surge-site1-event4/baseline-drift.png)

## Calculation and traceability

The [prespecification](prespecification.json) froze cases, frames and descriptive calculations before execution. MATLAB used the saved source-audit native footprint traces and phase-034 original-source ROI means. No detector, tracking, timing refinement, production quantification or cohort statistics was rerun. The original amplitude was independently recomputed from its saved raw trace and fixed baseline only to check preservation.

For baseline samples `(t_i, y_i)`, the fitted line is `B + beta*(t_i - mean(t))`, with `B = mean(y)` and `beta = sum((t_i-mean(t))*(y_i-B)) / sum((t_i-mean(t))^2)`. MATLAB computes the fit using `polyfit`; independent Python uses this centered-sum formula. Normalized slope is `100*beta/B`; the per-minute column simply rescales that unit and is **not a one-minute forecast**. The two half-window slopes use their own centered times and the same full-window mean B for normalization. Residual RMS uses `sqrt(mean(residual^2))`; sample SD uses the N−1 denominator.

[Case identities and preserved amplitudes](case-summary.csv), [all baseline metrics](baseline-drift-metrics.csv), and each case's `baseline-samples.csv` expose the numerical ingredients. Each `source-and-baseline.csv` retains all 1,200 raw local/ROI samples and baseline, native and measurement flags. Fit values outside the baseline are NaN. `native-footprint-pixels.csv` uses one-based MATLAB indices in the unchanged 512×512 source, with 2.35 µm/pixel. Local evidence additionally retains the source-trace MAT records and executable script; [the copied generator](executed-generator.m.txt) is available for inspection in this portable packet.

Source SHA256 remains `08381f8ef4cb0da80a09645aeffc9416188cf7937eaf207c0536f1f997494cf8`. The preserved source TIFF content hash was checked; source pixels were not reloaded because the saved traces already have the phase-033/034 source replay and this audit verifies their identity. Input paths and content hashes are frozen in the prespecification. No source copy was created.

## Checks and feasibility

[Independent verification](verification.json) passed 114 metric comparisons with maximum absolute discrepancy 5.92e−12. All 7,200 local/ROI trace values exactly match the earlier exported traces. Native footprints match the earlier per-pixel normalization files. Baselines, measurement/native windows and original amplitudes remain unchanged. All 467 MATLAB implementation files match phase 034, and all 347 sealed phase-035 files were preserved before standing-record updates. The measurement dictionary remains 0.3.0-draft.

The main process completed in 30.49 seconds, with maximum resident memory about 1.32 GiB and no parallel workers. The compact evidence meets the 120-second and 100-MiB targets. One initial dispatch failed because the script was addressed from the wrong working directory; no analysis ran in that dispatch, and its logs are retained. After the path correction, the audit completed in one analysis run. All three figures were visually reviewed without a measurement or display rerun.

## Meaning and next step

The synthetic challenge established a possible bias from smooth decline. This real-trace audit shows that fitting a line to 20 seconds can also reflect fluctuations and their phase. The slopes cannot identify a substrate half-life, distinguish physiological activity from optical contributions, or establish how much of each event amplitude is biased. Those questions remain open.

BOI-only scope, biological variability, physiological relevance, feasibility, researcher usability and traceability remain standing requirements. These deliberately selected signed-disagreement cases do not establish behavior across mice. No event is excluded, ROI boundary changed or baseline correction adopted.

Next: execute the [bounded baseline comparison specification](next-baseline-comparison.md), comparing the fixed 20-second mean with a clearly labeled pre-event linear reference on the existing synthetic fixtures and a fixed fluctuating-background extension. Preserve both results and known constructed components; test the danger of extrapolating a short fluctuation before considering a production change.
