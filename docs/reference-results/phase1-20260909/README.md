# Eight-recording reference results — 9 September 2026

All eight complete recordings from six animals passed lossless conversion,
master analysis, statistics export and numerical QC. Seven recordings are BOI;
FB2411 is a separately analyzed mNeonGreen fluorescence control. These are
technical reference results, not biological accuracy estimates or inferential
comparisons between conditions.

Executed MATLAB source: commit `95ef10c` on `development-existing-analysis-v3`.
The batch verified an unchanged MATLAB source hash manifest at completion.
MATLAB R2025a; all recordings 1 Hz; no additional denoising or detector retuning.
Exact assets, selected series, metadata and SHA-256 values are pinned in
[`reference-set-phase1.json`](../../reference-set-phase1.json). Full local outputs
are in the sibling workspace directory
`reference-validation/phase1-optimized-20260909/`.

## Per-recording results

Amplitude columns show finite amplitudes / all detected events. Counts are not
pooled across recordings or animals. Wrong-direction counts concern finite
preserved-input amplitudes relative to the detection label.

| Session | Minutes | Sink sites / events | Sink amplitude available | Surge sites / events | Surge amplitude available | Wrong direction: sink / surge |
|---|---:|---:|---:|---:|---:|---:|
| M400-01-baseline-awake | 10.00 | 56 / 137 | 92 / 137 | 14 / 40 | 21 / 40 | 1 / 0 |
| M400-03-baseline-iso | 10.00 | 56 / 84 | 72 / 84 | 2 / 2 | 1 / 2 | 0 / 0 |
| M401-01-baseline-awake | 10.00 | 49 / 92 | 74 / 92 | 1 / 1 | 0 / 1 | 1 / 0 |
| M401-03-baseline-iso | 10.00 | 33 / 43 | 33 / 43 | 1 / 3 | 2 / 3 | 0 / 1 |
| FB2312-baseline-awake | 20.00 | 59 / 192 | 149 / 192 | 19 / 58 | 36 / 58 | 3 / 6 |
| FB2316-baseline | 20.00 | 81 / 193 | 134 / 193 | 32 / 62 | 31 / 62 | 1 / 3 |
| ID13-20200917 | 20.00 | 60 / 235 | 169 / 235 | 34 / 131 | 53 / 131 | 1 / 0 |
| FB2411 | 5.02 | 20 / 26 | 24 / 26 | 1 / 1 | 0 / 1 | 0 / 0 |

## Baseline exclusions

`baseline-cause-summary.csv` classifies unavailable baselines from saved native
masks and refined event timing. `baseline-cause-events.csv` retains event-row
identifiers and frame counts. Causes are **not mutually exclusive**: a truncated
window can also overlap one or both signs. The audit reconstructed clean frame
counts and asserted equality to every exported `BaselineValidSamples` value.
All unavailable baselines in this set were explained by recording-start
truncation and/or overlap with another detected event. No own-event overlap or
unexplained exclusions were found. Cross-sign overlap is common; causes overlap
and must not be summed as independent event counts.
This does not validate whether the contaminating detections are biological.
The local `reproducibility/` folder retains the diagnostic MATLAB helper.

## Interpretation and next work

- Inspect wrong-direction events in both normalized detection traces and
  preserved-input event-footprint traces. Detection of a local normalized
  fluctuation and change relative to a raw pre-event baseline are different
  measurements; their disagreement requires explanation before choosing a
  publication endpoint.
- Assess baseline availability against recurrence and cross-sign overlap.
  Missing amplitudes must remain visible; do not silently condition biological
  comparisons on whichever events happen to have clean baselines.
- Resolve archived intensity preparation, particularly the ID400/ID401
  frame maxima of exactly 255. These observations do not prove per-frame
  normalization. Higher-range FB movies are also not automatically raw camera
  data. See `intensity-diagnostics.json`.
- Evaluate spatial smoothing and minimum region areas in physical units using
  controlled resampling and seeded injections. Current fixed pixel settings
  impose different physical selection thresholds. Keep this reference frozen
  for comparison; do not tune to its event counts.
- Keep the fluorescence control separate. Detected control fluctuations are
  a diagnostic finding, not an estimate of biological false-positive rate.

## Optimization verification and retained evidence

Both ID400 recordings matched the previous tracker exactly for native masks
and event timings, duration, areas, baselines and amplitudes. See
`tracking-real-data-equivalence.json`. The synthetic microbenchmark yielded
11.9× faster tracking with identical output; this does not describe the entire
pipeline (`tracking-benchmark.json`). Before this batch, all 32 focused tests,
the full smoke suite and repository checks passed (329 MATLAB files inspected;
51 Code Analyzer messages remain).

The superseded first attempt was intentionally stopped after two completed
recordings, during the third, to apply the tested optimization. It is preserved
locally at `reference-validation/phase1-20260909/` with an explicit attempt-status
note. Its incomplete remainder is not included as zero-event recordings.
