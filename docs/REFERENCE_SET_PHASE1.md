# Phase 1 reference set: existing detector

The profile `reference-set-phase1.json` pins eight complete recordings from six animals in DANDI `000891/0.240215.0831`. Selection was based on verified metadata and acquisition coverage, before inspecting event counts. This is technical reference validation, not an adequately powered biological comparison or a ground-truth accuracy benchmark.

| Session | Mouse | Condition | µm/pixel | Frames at 1 Hz | Role |
|---|---|---|---:|---:|---|
| M400-01-baseline-awake | ID400 | Awake immobile | 4.75 | 600 | BOI reference |
| M400-03-baseline-iso | ID400 | Isoflurane | 4.75 | 600 | Within-mouse paired reference |
| M401-01-baseline-awake | ID401 | Awake immobile | 4.75 | 600 | Second animal |
| M401-03-baseline-iso | ID401 | Isoflurane | 4.75 | 600 | Within-mouse paired reference |
| FB2312-baseline-awake | FB2312 | Awake immobile | 2.35 | 1200 | Finer spatial sampling |
| FB2316-baseline | FB2316 | KX anesthesia | 2.35 | 1200 | Different anesthesia |
| ID13-20200917 | ID13 | Awake mobile | 2.38 | 1200 | Different behavioral condition |
| FB2411 | FB2411 | mNeonGreen fluorescence, KX | 6.75 | 301 | Separate fluorescence control |

The four unresolved metadata cases (F120, F134, F136, M189) are not included. No stimulation time windows are inferred. All data are full duration and full spatial resolution. The acquisition-specific HDF5 time-last layout is explicit in each profile and checked against dimensions; it is not an automatic assumption for arbitrary NWB files. Selected input values are converted losslessly to TIFF and every converted pixel is compared with the NWB. No added denoising, gain normalization, cropping or detector retuning is applied. Spatial axes follow the MATLAB HDF5 reader order; no cross-modality registration is asserted.

## Execution and reporting

```matlab
setupOxygenDynamicsPath;
addpath('tests/analysis');
results = runtests('tests/analysis');
assertSuccess(results);
Summary = runDandiReferenceSet('docs/reference-set-phase1.json', ...
    '/private/tmp/oxygen-reference-cache', '/path/to/new/reference-run');
```

The cache contains `<AssetID>.nwb`, verified against the profile SHA-256. A new output root is required for every run. Conversion, master analysis, statistics export and numerical QC are tracked separately. Each recording gets independent statistics; the fluorescence control is not pooled with BOI. Failures are retained with their stage and exception rather than omitted. Failed metrics remain unavailable, not zero. The batch writes a summary after each attempted recording, so partial progress survives later failures.

QC checks recording exposure, positive eligible area, occupied-tissue fraction bounds, event bounds and inclusive durations, and agreement between event tables and recording-level measurement-availability counts. The summary includes sites, events, finite amplitudes and wrong-direction amplitudes for both signs. These checks do not validate biological detections. A fluorescence-control detection measures the algorithm's response in that acquisition; it is not an automatically labelled biological false positive or an estimate of population specificity.

## Physical-scale limitation to test next

`smooth=10` defines a 21 × 21 pixel spatial averaging kernel; temporal Gaussian smoothing uses five samples. Candidate minimum areas are 100 pixels for sinks and 400 pixels for surges. The following consequences follow directly from the current implementation:

| µm/pixel | Spatial kernel width (µm) | Minimum sink area (µm²) | Minimum surge area (µm²) |
|---:|---:|---:|---:|
| 2.35 | 49.35 | 552.25 | 2209.00 |
| 2.38 | 49.98 | 566.44 | 2265.76 |
| 4.75 | 99.75 | 2256.25 | 9025.00 |
| 6.75 | 141.75 | 4556.25 | 18225.00 |

Thus, area-normalizing outputs alone does not equalize detection sensitivity across these acquisitions. Differences in animal, condition, intensity scaling and optical resolution are also confounded with sampling. Do not interpret the reference counts as isolated effects of pixel size or anesthesia. All selected recordings are 1 Hz, so this set does not exercise cross-frequency detector equivalence; fractional-frequency calculation tests are separate.

After this baseline is complete, use controlled resampling and known-signal injections to evaluate physical-unit parameterization, baseline availability and event matching. Preserve these unchanged-setting results for comparison before modifying detector rules.

## Archived intensity provenance

Independent inspection of the selected NWB series found uint16 storage in all
cases, but very different value ranges. Every frame of all four ID400/ID401
movies reaches exactly 255. ID13 spans 0–255 but reaches 255 in only one frame.
FB2312 and FB2316 reach 61192 and 62483 respectively; the fluorescence control
spans 9450–31414. These observations suggest differing preparation/scaling,
but do not distinguish clipping, fixed scaling or per-frame rescaling. A uint16
container alone does not establish original camera dynamic range.

The converter preserves these archived values exactly. Until preprocessing
provenance is resolved, qualify amplitude interpretation and avoid treating
cross-acquisition amplitude comparisons as validation. A larger numeric range
also does not by itself prove unprocessed camera data. BOI relative optical
changes are not calibrated oxygen concentration changes.

## Tracking optimization evidence

The cache optimization preserves the original overlap rule and matching order.
Both ID400 awake and isoflurane outputs were compared against a preserved run
of the original tracker: native sink/surge masks and event timing, duration,
area, baseline and amplitude columns matched exactly. A seeded 60-frame,
five-regions-per-frame microbenchmark also matched exactly and took 0.727 s
with the original tracker versus 0.061 s with cached membership (11.9× in this
fixture). This is not a whole-pipeline speedup estimate. Focused tests include
40 randomized fixtures plus explicit strict-threshold/first-match cases.
