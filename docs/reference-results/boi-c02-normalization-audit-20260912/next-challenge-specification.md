# Fixed shared/global versus local signal challenge

R2-C02-NORMALIZATION-034 handoff. **Specified, not executed.** This is a synthetic
mechanism check prompted by the exact 034 attribution, not an independent
biological validation or a proposal to replace the event baseline.

## Fixed input and execution scope

- Native array: 256×256×600, 1 Hz, 2.35 µm/pixel. Logical circular ROI centered
  at MATLAB row/column (128,128), radius 100 pixels; full image retained.
- Heterogeneous baseline: within the ROI, a left-to-right linear gradient from
  1000 to 5000 input units, using columns 28 through 228. Exterior baseline 1000.
  Uniform-brightness control: 1000 everywhere.
- Shared pulse shape: `p(t)=exp(-0.5*((t-300)/12)^2)` at one-based frames 1:600.
  This fixes timing and width without fitting to the biological examples.
- Local support: disk centered at (128,68), radius 14 pixels, wholly inside ROI.
- Noise: each case is run with zero noise and a matched fixed realization of
  independent Gaussian noise with SD 0.5% of each pixel's baseline. MATLAB seed
  3401, `twister`; generate once and reuse across cases. The uniform control
  uses the same standardized noise draw with its own baseline scale.
- Construct source arrays in double precision, then cast once to single for
  the detection input. Do not quantize to uint16, clip values or resize the ROI.
  Generate the standardized noise once as `randn(256,256,600)` after the fixed
  seed; apply baseline-scaled noise across the full retained image.
- Use the unchanged 032/033 preprocessing, weighted smoothing, support and
  sign-specific percentile/component helpers. Preserve exact profile hashes.
  Do not run tracking, timing refinement, quantification or cohort statistics.
- Save configuration, source construction, stage/ROI/footprint traces, candidate
  support counts and selected native images. No stack output is required; use
  compact MAT/CSV plus source-generation hashes. Two workers, 10-minute process
  target, 1 GiB evidence target. Stop and retain evidence on an execution failure.

## Frozen cases

All unqualified cases use the heterogeneous baseline. Shared changes apply to
all ROI pixels; local changes are separately declared rather than inferred from
the detector. Additive changes are in input units. Multiplicative changes are
fractions of each pixel's baseline.

| Case | Shared component | Additional local component |
|---|---|---|
| C01 | None | None |
| C02 | Uniform-brightness control, −10% × p | None |
| C03 | −10% × p | None |
| C04 | +10% × p | None |
| C05 | −2% × p | None |
| C06 | +2% × p | None |
| C07 | −200 × p additive | None |
| C08 | +200 × p additive | None |
| C09 | None | −10% × p of baseline |
| C10 | None | +10% × p of baseline |
| C11 | −10% × p | −2% × p of baseline |
| C12 | −10% × p | +2% × p of baseline |

C11/C12 add the local baseline-scaled term to the shared term; do not multiply
the two pulse gains. C12 therefore has a known positive local component while
its total local raw change remains negative. All 12 cases have both noise
conditions, for 24 fixed inputs. Exterior perturbation and containment are
already separate implementation checks; do not expand this matrix adaptively.

## Readout and interpretation

1. Reproduce constructed raw means and component amplitudes from the saved
   formula. Keep shared component, additional local component and net raw
   source change separately visible.
2. Export per-pixel/footprint source, cubic residual, ROI reference and SD,
   spatial score, temporal score and filtered score. Use fixed dark and bright
   comparison disks at (128,68) and (128,188), radius 14 pixels.
3. At frames 264:336 inclusive and the full pulse, record sign percentile
   membership and candidate areas inside and outside the injected local disk.
   Absence of a candidate remains a result. Never tune a percentile, area rule,
   brightness profile or pulse to force detection.
4. For cases with no local component, any localized candidates are responses
   to shared input, baseline structure, noise or numerical processing—not
   recovered injected local events. This is a construction-based diagnostic,
   not a validated biological false-positive rate.
5. Compare uniform versus heterogeneous brightness and additive versus
   multiplicative shared input. Record finite precision and near-zero residual
   variance explicitly. Reproduce the 034 reference decomposition where defined;
   do not invent a scale when ROI SD is zero.

Before using results to choose a production normalization change, distinguish
whether the desired biological measurement concerns net local source change,
local deviation from shared change, or both as separately named outcomes.
Preserve the existing dictionary's unresolved physiological and inference
questions. This challenge supplies mechanism evidence; it does not settle the
scientific estimand, final detector acceptance thresholds, transfer across mice
or independent researcher usability.
