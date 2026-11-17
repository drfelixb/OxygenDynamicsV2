# Fixed mean versus pre-event linear reference

**R2-BASELINE-COMPARISON-037 — controlled comparison complete; production baseline unchanged.**
12 September 2026. BOI only. These are synthetic known-support measurements, not detected biological events or a cohort analysis.

A line fitted to the preceding 20 seconds reduces amplitude error for the smooth-decay examples, but extrapolating a fluctuation can create substantially larger errors and reverse the measured direction of an injected event. This comparison does not support replacing the current mean baseline with an automatic linear correction.

## What was run

The [phase-036 specification](original-036-specification.md) is preserved unchanged, with a [machine-readable specification](prespecification.json) frozen before execution. The run compares two references on **208 inputs, producing 416 readouts**:

- **Constant 20-second reference:** the existing original-source mean over frames 280–299.
- **Linear 20-second reference:** a line fitted only to those same 20 samples, evaluated over the supplied event window. No event or post-event sample contributes to the fit.

All inputs use 1 Hz, a known 16-pixel native footprint in an 8×8 image and event start at frame 300. The first 144 source traces and metadata are read from the saved phase-035 fixtures unchanged: no decay or illustrative half-lives of 10, 20 and 40 minutes; 5-, 20- and 60-second windows; −10%, −2%, zero as each sign, +2% and +10% components; zero or fixed noise.

The remaining 64 inputs use a 3% shared sinusoid with a 30-second period and four fixed phases, with no decay or a 20-minute half-life, a 20-second supplied event and −2%, zero as each sign or +2% local components. Noise is absent or uses the **same saved per-pixel draw** as phase 035, at SD 10 initial-intensity units. The sinusoid's amplitude, period and phases are illustrative conditions, not empirical estimates or a claim that such fluctuations are artifacts.

Each synthetic no-event source is known by construction. Source arrays are formed in double, then cast once to single before their native footprint means are taken. For both references, the same signed fractional-change, sign-specific extremum and signed integral formulas are evaluated. All negative results remain visible. No spatial detector, tracking, production event correction or cohort statistics is run.

## Results against the injected local component

For a noise-free 10-minute half-life and a 20-second supplied event:

| Injected component | Existing mean reference | Pre-event linear reference |
|---|---:|---:|
| 2% drop | 5.286% drop amplitude | 1.995% drop amplitude |
| 2% rise | 0.768% rise amplitude | 2.058% rise amplitude |

Thus the line largely removes the bias of a smooth decline in these constructed cases. It is still a finite-window approximation; its accuracy depends on curvature, noise and how far it is extrapolated.

The following table summarizes **absolute amplitude error**, in percentage points, across each fixed synthetic stratum. It includes zero-component controls and is not a biological error rate, a validation threshold or an estimate from independent noise realizations.

| Background | Noise SD (% initial signal) | Cases per reference | Mean reference: median / maximum error | Linear reference: median / maximum error |
|---|---:|---:|---:|---:|
| Smooth | 0 | 72 | 0.642 / 7.717 pp | 0.001 / 0.373 pp |
| Smooth | 0.5 | 72 | 0.547 / 7.615 pp | 0.269 / 0.768 pp |
| Fluctuating | 0 | 32 | 3.087 / 4.967 pp | 5.675 / 12.169 pp |
| Fluctuating | 0.5 | 32 | 3.255 / 5.217 pp | 5.833 / 12.332 pp |

The line's behavior changes with fluctuation phase. In a no-decay, noise-free control with **no local injection**, phase pi/2 yields a sink amplitude of **9.967% with the line**, compared with **2.286% with the mean**. Both arise from applying a supplied measurement window to a fluctuating source. Neither establishes that an event detector would select that window.

The line also reverses the injected direction in **8 of the 32 fluctuating cases with a nonzero local component**, across the two fixed noise conditions; the mean does so in zero of those cases. For example, W001 contains a 2% local drop but yields a **−1.486% sink amplitude** under the line. Zero-component controls have no injected direction and are excluded from that denominator. These counts describe this fixed matrix only.

![Paired absolute amplitude errors](amplitude-error-comparison.png)

## Why the fluctuating examples differ

A line estimated on one segment of a wave continues rising or falling after that wave turns. The extrapolated reference can therefore diverge from the true source even with no local injection. The four panels below were selected by phase before execution; they contain no decay, noise or injected event. Green marks the 20 baseline samples. The supplied measurement window begins at zero seconds.

![Four fixed fluctuation phases](fluctuation-phase-references.png)

The result is not uniformly unfavorable to the line in every phase. The complete [paired table](paired-reference-comparison.csv) retains improvements and deteriorations, and the [stratified summary](stratified-summary.csv) separates duration, decay, noise, phase and reference. No condition was tuned after seeing outcomes, and no automatic winner is selected.

Signed integrals show the same need for caution. With fluctuating, noise-free inputs, the median absolute signed-integral error is **0.236 fraction-seconds for the mean** and **1.308 fraction-seconds for the line**. With smooth, noise-free inputs, the respective medians are **0.0913 and 0.000374 fraction-seconds**. The units are integrals of fractional source change, not oxygen concentration or biological burden.

## Two comparators and their limits

The injected component supplies a known ideal step magnitude and signed integral. Separately, the known noiseless no-event source serves as a reference for the actual noisy, single-cast source trace. The latter exposes reference error separately from noise and sample-extremum effects. Both signed error definitions are exported; they are not conflated.

A shared fluctuation may itself be physiologically relevant. Labeling the sinusoid a constructed background does not justify removing an analogous biological signal. Whether the scientific outcome should describe net local source change, deviation from an expected background, or separately named versions of both remains unresolved. This comparison cannot supply that scientific choice or establish substrate kinetics.

All 416 required event references were finite and positive, with minimum 1,316.89 input units. There were no unavailable readouts. The specified invalid-reference policy therefore was not challenged by these inputs and is not newly validated here. The 5-, 20- and 60-second event windows extrapolate a 20-s fit over duration/baseline ratios of 0.25, 1 and 3. Longer prediction horizons are explicitly recorded; no earlier baseline search, clipping or denominator floor was added.

## Verification and numerical precision

MATLAB completed all 208 inputs and 416 readouts in one run. The 144 constant-reference amplitudes and signed integrals reproduce phase 035 **exactly**, and the saved source traces are unchanged. Independent Python arithmetic checks 8,320 metric values and all 9,520 saved baseline/event reference-sample rows; maximum numeric discrepancies are 1.14e−11 and 1.37e−11 respectively, within the frozen 1e−9 tolerance. All 64 new native source arrays reproduce with exact SHA256 matches using the exported saved noise draw.

**Three strict sign flags differ at machine precision.** For the no-decay, noise-free, zero-sink controls B005, B017 and B029, MATLAB's fitted-line amplitude is −1.1369e−16 fraction, whereas the independent centered-sum fit gives zero. An exact `amplitude < 0` flag consequently differs. The initial check failed on that binary comparison; its log and verifier are preserved. Follow-up verification records the three disagreements explicitly while confirming the arithmetic tolerance. No amplitude was rounded to zero, no scientific significance threshold was added and the run was not repeated. These controls have no injected direction, so they do not enter the eight substantive direction disagreements above.

[Verification details](verification.json) therefore state **arithmetic passed with near-zero sign-flag disagreements**, rather than claiming every binary flag replayed identically. These flags illustrate why numerical sign alone cannot establish physiological meaning.

All 467 MATLAB implementation files and the measurement dictionary remain unchanged. The 68 sealed phase-036 files and 347 phase-035 files were checked before updating standing records; prior versions are preserved. The main process took **22.54 seconds**, with no workers and maximum resident memory about **1.23 GiB**. Evidence remains below the frozen 100-MiB target. No biological source was copied or reprocessed.

## Reading and reproducing the evidence

- [Input cases](input-cases.csv) link original B001–B144 and new W001–W064 IDs to construction, source hashes and the original phase-035 values.
- [Source traces](source-traces.csv) retain all 600 original-source and known no-event source samples per input, with explicit case/frame columns.
- [Sample references](sample-references.csv) retain both references and fractional changes at every baseline and event sample. Baseline is frames 280–299; the first event sample is 300. The original 20 samples span 19 seconds from first to last sample.
- [Reference readouts](reference-readouts.csv) contain every amplitude, mean, integral, error, sign flag, reference minimum and availability reason. Fields named `Fraction` use fractions; multiply by 100 for percent. Amplitude error in percentage points differs from percent relative error.
- [Stratified summary](stratified-summary.csv) and [overview](overview-summary.csv) summarize the fixed matrix. The paired-table difference is `absolute error with line − absolute error with mean`; tiny differences remain unrounded in the export.

The [executed MATLAB generator](executed-generator.m.txt) and [independent verifier](independent-verification.py.txt) are inspectable copies. Local evidence additionally retains the executable scripts, shared-noise binary in little-endian float64 MATLAB column-major order, MAT fixture, logs and original failed verification. A fresh evidence folder is required for reproduction: the MATLAB script refuses to overwrite `run-01`. Input identities, software versions and evidence locations are retained in the prespecification and artifact manifest.

## Next step

BOI-only scope, biological variability, physiological relevance, feasibility, usability and traceability remain standing requirements. No biological event is reclassified, no ROI is changed and no correction is adopted. Transfer across mice, independent researcher usability and the scientific interpretation of the reference remain open.

Next: use the [review integration handoff](review-integration-handoff.md) to make baseline variation and reference sensitivity inspectable in the existing MATLAB event review. Preserve the original measurement as the saved result, label any alternative reference as a diagnostic and avoid automatic correction or exclusion.
