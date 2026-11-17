# Substrate decline and the event baseline

**R2-SUBSTRATE-CHALLENGE-035 — controlled challenge complete. Scientific acceptance remains open.**
12 September 2026. BOI only; 1 Hz external-trigger cadence represented throughout.

The user's substrate-consumption clarification matters for measurement as well as detection. A fixed pre-event mean can overstate a drop and understate a rise when the underlying signal is declining. Full-record cubic detrending used for detection does not remove this effect from amplitudes measured on the original source.

## What was tested

The [original 034 specification](original-034-specification.md) was preserved byte-for-byte. Its 24 shared/local Gaussian-pulse inputs were executed unchanged. A [separately frozen extension](prespecification.json) added 18 stage inputs with exponential half-lives of 10, 20 and 40 minutes, each with no local pulse, a local −2% pulse or a local +2% pulse, and zero or fixed 0.5% baseline-scaled noise. These rates and the exponential law are illustrative sensitivity conditions, not measured substrate kinetics.

All 42 stage inputs use the existing MATLAB cubic detrending, strict ROI normalization, included-neighbor smoothing and sign-specific percentile/component helpers. Native arrays are 256×256×600; the craniotomy-like ROI has 31,417 pixels and the local test disk has 613 pixels. The full image is retained, including its exterior. The input gradient, pulse, seeds and all thresholds are fixed. No tracking, timing refinement or event/cohort statistics were run in this arm. A frame candidate is not an accepted biological event.

A separate measurement arm calls the unchanged production event quantifier for 144 known-support fixtures: four decay conditions (including no decay), three durations (5, 20, 60 seconds), six signed component/sign combinations (−10%, −2%, zero as a sink, zero as a surge, +2%, +10%) and two noise conditions. Its 16-pixel footprint and event start at frame 300 are supplied, not detected. These fixtures deliberately include windows that need not meet detection size/duration rules.

The baseline is always **frames 280–299: all 20 seconds immediately before the supplied measurement start**. It is the original-source mean on the fixed native footprint. No baseline sample is missing or overlaps another event. The raw source is constructed in double and cast once to single. Independent per-pixel Gaussian noise has SD 0.5% of initial baseline, not of the declining current signal; one fixed draw is reused within each arm. This does not model shot noise, variable substrate kinetics or empirical noise correlations.

## Effect on the 20-second baseline

The table uses noise-free, supplied 20-second event windows. Percentages are reported sign-specific amplitudes; the known component is relative to the contemporaneous no-event decaying source.

| Illustrative half-life | Decay alone, reported sink | Injected 2% drop, reported sink | Injected 2% rise, reported surge |
|---|---:|---:|---:|
| No decay | 0.00% | 2.00% | 2.00% |
| 10 minutes | 3.35% | 5.29% | 0.77% |
| 20 minutes | 1.69% | 3.66% | 1.38% |
| 40 minutes | 0.85% | 2.83% | 1.69% |

At a 10-minute half-life, decay alone yields sink amplitudes of 1.66%, 3.35% and 7.72% for 5-, 20- and 60-second windows. Longer windows allow more decline to enter the minimum used for sink amplitude. For a constant positive step over a declining background, the surge maximum is at the first event frame, so its noise-free amplitude is identical across these three durations. Noise can change the selected extrema; all noisy cases are retained in [baseline-cases.csv](baseline-cases.csv).

The zero-component surge fixture yields a negative amplitude (−1.21% at a 10-minute half-life). This is preserved. Zero-component fixtures demonstrate the arithmetic bias of supplied windows; they do not establish that an event detector would select such a window.

For the analytic comparator, let `lambda = log(2)/halfLife`, `a` be the signed local step and `j = 1,...,20`. The ratio of the unperturbed first event frame to the pre-event mean is `g = 1 / mean(exp(lambda*j))`. For an event of `d` frames:

- Sink amplitude fraction: `1 - (1+a)*g*exp(-lambda*(d-1))`.
- Surge amplitude fraction: `(1+a)*g - 1`.

These noise-free formulas describe this constructed monotone background and constant step. The production quantifier still evaluates the actual sample extrema. A saved oracle comparator uses the known contemporaneous background to expose the injected component; it is not an available biological measurement or an adopted correction.

![Baseline sensitivity by sign and duration](baseline-decay-reviewed.png)

## Detection-stage findings

Uniform, noise-free shared −10% change produces zero normalized scores and no candidates because the ROI spatial residual SD is zero. With heterogeneous initial brightness, the same fractional decline produces opposite relative scores in the dark and bright disks. For C03-N1 at frame 300, their mean filtered scores are +1.881 and −1.038 even though both source signals decline. During the fixed frames 264–336, this input produces 6,249 sink and 207,720 surge candidate pixel-seconds, with no injected local component. These are spatial/temporal candidate support sums, not counts of events or biological false-positive rates.

Noise-free additive shared pulses expose finite-precision behavior: maximum ROI residual SD is only about 0.00019 input units, yet normalization can produce sizeable scores and candidates. With the fixed noise added, their scores and candidate totals closely reproduce the no-pulse noise control. The no-pulse noisy control itself has 26,135 sink candidate pixel-seconds over 600 frames and no surge candidates. Candidate absence, background responses and both signs are retained without threshold tuning.

Cubic detrending leaves small residual structure for pure exponential decay. The maximum ROI residual SD is about 0.100, 0.00725 and 0.000496 input units for the noise-free 10-, 20- and 40-minute cases. Those residuals can be amplified into spatial candidates. Under the matched 0.5% noise, the three decay-only cases instead produce 27,283, 25,650 and 26,036 sink candidate pixel-seconds, respectively, and zero surge candidate pixel-seconds, close to the fixed-noise control. This dependence on signal/noise scale limits physiological interpretation of ideal noise-free normalized patterns.

The injected local disk is smaller than the unchanged 1,635-pixel surge component minimum. Therefore this challenge cannot establish recovery sensitivity for surges of that native size. Normalization and smoothing may create larger or displaced candidates; those do not automatically constitute recovery of the local injection. No area rule was relaxed to force a result.

![Selected source, score and candidate maps](selected-stage-maps.png)

All displayed maps use the prespecified frame 300. The dotted disk is a reference/test support; the first three rows have no local injection. The first column compares source to its initial noiseless intensity field, not to the event's 20-second baseline. The noise-free shared-fall case has no candidate at frame 300 despite having candidates at other frames in the fixed pulse window.

## Verification, preservation and feasibility

[Independent verification](verification.json) re-evaluates 144 baseline cases from 86,400 exported source-trace samples, checks all 25,200 candidate-frame rows and re-creates all 21 noise-free stage inputs with exact SHA256 matches. Maximum baseline arithmetic discrepancy is 4.1e−12 in exported numeric values. Noiseless production amplitude differs from the double analytic comparator by at most 4.12e−8 fraction, consistent with the preserved single-precision source construction. Available spatial decompositions close to 9.5e−14 in CSV arithmetic.

Zero/near-zero variance is retained explicitly. C01-N0 and C02-N0 have zero ROI residual SD throughout. C07-N0 and C08-N0 have 67 and 70 zero-SD frames. The original stage exporter conservatively leaves each entire footprint decomposition undefined whenever any frame has zero SD, so 4,800 footprint-frame decomposition rows are unavailable across these four cases. The remaining source, residual, spatial/temporal score and candidate readouts are retained. This includes an export limitation: some individually nonzero-SD frames in C07-N0 could support a framewise decomposition, but were not claimed as verified. No artificial denominator floor or stable physiological interpretation was assigned to these precision-sensitive cases.

All 467 MATLAB implementation files match phase 034 before and after execution. The measurement dictionary remains `0.3.0-draft`, with unchanged SHA256 `1eea8f70f37a0794800f764498f4fefc0e89bfc6b195ee1f3aa198ea810186a2`. All 57 previously sealed phase-034 files are preserved; its scientific-decision document was verified against the preserved pre-clarification copy, retaining the subsequent user clarification separately. Earlier worktree changes remain intact.

The main MATLAB process took 257.37 seconds (4.29 minutes), with two thread workers and 4.47 GiB maximum resident memory. Local evidence is approximately 381 MiB before the final readable packet. No source movies were copied or exported. The fixed 10-minute process and 1-GiB evidence targets were met. A sandboxed preflight syntax-check dispatch exited without output; its record is retained. The permitted syntax check completed with preallocation suggestions only. The challenge itself completed in one run. The first plot is retained; a separate reviewed plot fixes its legend and separates sink/surge panels without changing measurements.

The portable packet contains settings, case tables, all per-frame summaries, checks, figures and the report. The local evidence directory additionally contains the executed generator, original-source trace fixtures, per-pixel stage arrays for both comparison disks, selected native source/stage/candidate maps, execution logs and the artifact manifest. Its location is recorded in `artifact-record.json`.

## Scientific interpretation and next step

This phase supports treating expected substrate-related decline as a potential amplitude confound. It also reproduces the distinction between relative ROI contrast and original-source change. It does not show that every shared trend is substrate consumption, establish the real decay law, choose net local change versus local deviation from shared change, or validate a new baseline.

BOI-only scope, biological variability, physiological relevance, feasibility, usability and traceability remain standing requirements. Neither the challenge nor its convenient fixed disk is a basis for excluding unusual biological events or changing craniotomy boundaries. Cross-mouse generalization, physiological acceptance and independent researcher usability remain open.

Next: quantify observed pre-event slopes and baseline variation for the same three source-audited FB2314 events, using their saved native footprints and original 20 clean samples. Display local and ROI trends together, retain the original amplitudes and avoid assigning a substrate half-life from those short windows. Use that evidence to specify a bounded comparison of baseline approaches before any production change or cohort expansion.

## Reproduction and file interpretation

The local run is `reference-validation/boi-substrate-challenge-20260912/runChallenge.m` relative to the workspace. In MATLAB, run that file only in a fresh evidence directory: it refuses to overwrite `run-01`. `executed-generator.m.txt` in this portable packet is an inspectable copy of the exact executed script; the local executable and code-manifest checks identify its original location. The syntax-check, challenge, rendering and independent-verification logs remain in local evidence. `verify.py` uses NumPy and standard Python libraries; it performs read-only comparisons except for its verification JSON output.

`baseline-cases.csv` has one row per B001–B144 fixture. Amplitudes ending in `Fraction` are fractions, not percentages; multiply by 100 for percent. `baseline-traces.csv` has no header: its first column is the one-based frame, followed by B001 through B144 in case-table order. Every row in `stage-cases.csv` links to a same-named folder containing `stage-traces.csv` and `frame-candidates.csv`. Frame pixel counts summed at 1 Hz are pixel-seconds. These counts never stand for animal sample size.

Local `dark-pixels.mat` and `bright-pixels.mat` retain each native footprint index and its source, residual, spatial, temporal and filtered trace. `selected-stages.mat` retains native maps at frames 264, 300 and 336, the masks and case settings. The relevant unchanged production functions are [the event quantifier](../../../helpers/finalizeOxygenEventMeasurements.m), [preprocessing](../../../helpers/preprocessDetectionStack.m) and [frame candidate detection](../../../helpers/detectFrameRegionCandidates.m). The [measurement dictionary](../../../docs/BOI_MEASUREMENT_DICTIONARY.md) remains the shared measurement definition.
