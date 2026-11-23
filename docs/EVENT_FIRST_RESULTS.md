# Implementation and validation report — 7 September 2026

Implemented in the isolated `event-first/` checkout on branch `feature/event-first`, based on `8cf3f036b41e16b2c472bcee7e5cfaeab41433eb`. The surrounding audit artifacts were preserved. Changes are local and uncommitted; nothing was published, deployed or sent to others.

## What is implemented

The standalone `runOxygenEventFirst` API, configuration factory, validated YXT recording contract, narrow checksummed NWB adapter, preserved TIFF loading, robust baseline/noise scoring at physical spatial scales, seeded signed growth, native masks, ambiguous-component policy, fixed-footprint raw quantification, complete-link recurring sites, valid area-time metrics, explicit contrasts, batch failure/zero-recording capture, lossless MAT/portable CSV export, native legacy correspondence, and a mouse-partitioned benchmark runner are available. See [usage and definitions](EVENT_FIRST.md).

`legacy` remains the default. Legacy scientific algorithms and outputs are unchanged, including their historical timing/z-score limitations. The only shared runner change is opt-in native-list capture for comparison. `compare` runs both independently in separate output namespaces and restores the legacy sink crop in an explicitly labeled comparison envelope. Alternative outputs never use legacy site-union quantifiers or TIFF reconstruction. Legacy statistics reject requests to ingest the alternative schema. Legacy and alternative observable-support policies still differ, so their comparison is descriptive.

Run manifests include detector/schema/configuration, IDs, source metadata, dependency versions, pinned legacy commit, working-tree state, and SHA256 hashes of effective quantitative arrays, valid masks and MATLAB source files. Public input file SHA256 is separately verified. No mandatory Python or neural-network dependency was introduced.

## Verification actually run

MATLAB R2025a on macOS, with the installed Image Processing Toolbox and existing repository dependencies:

```matlab
setupOxygenDynamicsPath;
addpath('tests/eventFirst');
T=testOxygenEventFirst(); assert(all(T.Passed));
addpath('examples/eventFirst');
runEventFirstExamples('fresh-synthetic-output');
runEventFirstExamples('fresh-public-output','/path/to/dandi-awake.nwb');
runEventFirstLegacyComparison('fresh-comparison-output');
runRepositoryChecks();
runOxygenPipelineSmokeTest();
```

- **18/18 numerical/structural tests pass**, including constant/dark/all-invalid inputs, signed noisy events, exact noiseless quantification on prescribed support, later-event isolation, recording-ID isolation, touching/recovery/opposite signs, boundary/missing exposures, window conservation, physical resampling, retained global steps, detection/quantification source separation, persistence, complete-link site chaining, matching/partition leakage, batch failures, asymmetric NWB axes/checksums, singleton pixels/frames, and legacy default/schema rejection.
- **Repository checks pass:** 323 MATLAB files inspected, 44 Code Analyzer messages, existing focused hypoxia–amyloid tests passed. The analyzer message count is not a zero-warning claim.
- **Existing legacy smoke suite passes.** Its log deliberately contains expected failing scientific-guardrail fixtures; the suite asserts those failures and finishes successfully. No regression acceptance was refreshed.
- An initial all-pairs recurring-site implementation was too slow on the public sample. Representative-footprint indexing reduced that stage to approximately 3 seconds. The complete frozen synthetic benchmark was rerun and its event counts, precision/recall, matching and amplitude-error columns were identical before/after this exact pruning optimization.
- Reviewed the rendered synthetic, native legacy/alternative comparison and public overlays. Asymmetric synthetic HDF5 conversion also verifies axis handling numerically. Visual review checks gross coordinate consistency, not anatomical registration correctness.

Evidence: [test table](../examples/eventFirst/tests.csv), [final validation log](../examples/eventFirst/validation.log), [legacy smoke log](../examples/eventFirst/legacy-smoke.log), [benchmark CSV](../examples/eventFirst/verified-results/synthetic-benchmark.csv).

## Controlled results, including adverse findings

The small seed-17 fixture uses explicit overrides (scale 0, 30-second baseline, one-second minimum duration). It detects the two injected events with correct signs and three-second durations. Its noisy peak fractions are approximately 0.183 and 0.273 against injection magnitudes 0.2 and 0.3. Extra edge pixels in the detected union dilute the fixed-footprint amplitudes; this is retained, not concealed. Exact prescribed-support tests recover 0.2/0.3 and signed AUC −0.6/+0.9 seconds to numerical precision.

The frozen 3×3 window/seed grid uses `[20,30,45]` seconds and `[4,5,6]` SD. At IoU 0.25, all nine settings recover both injections; precision ranges from 0.25 to 1. The separate null fixture produces 0–7 false detections depending on settings. Even the 30-second/5-SD setting produces two null detections. These tiny synthetic recordings do not establish a calibrated operating point.

A larger controlled TIFF comparison produces **1 legacy event and 186 event-first candidates**, with no matches at the stated 0.1 spatiotemporal IoU rule. This demonstrates functioning independent dispatch and native support correspondence; it does **not** establish improved detection. Do not use detector outputs as ground truth or tune toward desired counts.

![Native detector comparison](../examples/eventFirst/comparison-results/detector-comparison.png)

## Public data actually used

Only the already-downloaded DANDI asset `8ba82dc1-aaba-411d-a196-ff8ef0b61fc3`, `sub-ID400/sub-ID400_ses-M400-01-baseline-awake_image.nwb`, was used. Full-file SHA256 verified:

`dbdb847b52a501eaf826b191f0affb2bcfc7078c95cddf035aa785e1aac3b23f`

The example reads the **first 120 of 600 full 512×512 frames**, at 1 Hz and supplied 4.75×4.75 µm calibration, from `/acquisition/1hz_mcor.tif`. MATLAB TXY axes are explicitly permuted to YXT. There is no spatial crop or rescaling. Source attributes are retained; values are labeled preserved input intensity, not original camera counts. Motion correction is suggested by the series name; registration support and camera offset remain unverified. No new downloads or manual annotations were created.

With the unmodified exploratory factory thresholds/scales, the prefix produces **22,407 candidates: 1,002 sinks and 21,405 surges**. Of these, 10,410 have ambiguous-component flags; 2,711 lack sufficient clean pre-event baselines. The temporal-median-positive tissue proposal includes the entire image, including obvious background. This is an intentionally exported proposal that needs replacement by reviewed tissue/registration support before scientific use. The high candidate count and spatially widespread overlay are substantial evidence that defaults need independent calibration for this processed dataset, not evidence of biological improvement. The baseline-adequacy flag is false here, showing that it alone cannot certify a useful baseline/noise model.

Final detection plus content hashes takes **28.62 seconds**; site assignment is approximately 3 seconds. MATLAB `whos` reports approximately **63.2 MB input** and **163.5 MB result** structures. A prior process sample observed roughly 1.1 GB resident memory during processing; this is not a measured peak-memory bound. Lossless per-pixel CSV export is large (hundreds of MB) and is excluded from Git by an explicit generated-output ignore rule, but retained locally. Full-stack/chunk scalability is not established.

Artifacts: [public overlay/traces](../examples/eventFirst/results/public-review.png), [runtime log](../examples/eventFirst/public-runtime.log), and local native outputs under `examples/eventFirst/results/eventFirst/public-verified120/`. Large files can be regenerated with the command above and are not included as Git source changes.

![Public review](../examples/eventFirst/results/public-review.png)

## Validated claims and remaining work

Validated here: arithmetic on controlled support, structural identity/mask/timing invariants, raw-source isolation, exposure conservation, deterministic matching and site rules, checksum/axis import, persistence, batch/default dispatch, benchmark execution, and runnable legacy compatibility.

**Not validated:** biological superiority, real-data precision/recall, comparable false-detection operating points across detectors, annotation agreement, calibrated pO2, treatment effects, depth or 3D hypoxic volume. No blinded biological annotations were supplied. The public data and controlled false detections specifically argue against treating the defaults as scientifically calibrated.

Known limitations include a rudimentary automatic tissue proposal, unknown camera offset/scaling, centered baseline sensitivity to sustained activity, MAD/noise behavior requiring empirical validation, ambiguous touching components, no irregular-exposure or temporal-chunk support, no gap linking, no calibrated spatial BLI integral, no across-recording anatomical site identity and no hierarchical biological inference. Use reviewed common masks, frozen development thresholds and mouse-separated independent annotations before a held-out biological comparison.
