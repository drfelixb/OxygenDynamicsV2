# Validation status — 9 September 2026

Runtime: MATLAB R2025a on macOS. Base: upstream main `8cf3f036b41e16b2c472bcee7e5cfaeab41433eb`. Development branch: `development-existing-analysis-v3` on GitHub.

| Check | Latest completed result |
|---|---|
| Focused calculation/regression tests | 37 passed |
| Full `runOxygenPipelineSmokeTest` | Passed with schema 3.0-dev and statistics identity mouse-strict-2 |
| `runRepositoryChecks` | Passed: 335 MATLAB files; 51 Code Analyzer messages remain |
| Master → statistics synthetic integration | Passed at 2 Hz; includes known measurements and a zero-event recording |

Smoke-suite printed FAIL rows are deliberate negative regression fixtures; the suite itself passed. The DANDI results below distinguish the first reference run from subsequent validation.

Tests cover recording-aware joins, missing composite measurements, native occupied area, inclusive timing, zero-event exposure, explicit paired baselines, event-specific raw footprints, equal mouse weighting, mixed sampling rates, window overlap, contaminated baselines, calibration rejection, unavailable figures, fractional-frequency puff timestamps, temporal SD normalization, affine invariance, constant inputs, source hashing and incompatible contract rejection.

`tests/analysis/runExistingAnalysisIntegration.m` runs the actual master on synthetic data, then injects known event measurements to test aggregation independently of detection. The injected fixture verifies 25%/40% amplitudes and a paired -100% rate change. It does not establish detector accuracy.

## Biological reference

The user selected the paper-cited DANDI recordings and has no manually reviewed event labels. `tests/analysis/runDandiReference.m` is the first reproducible reference harness. It pins the published awake ID400 asset by SHA-256, checks dimensions/calibration, converts all 600 frames at full resolution without intensity rescaling, verifies every converted pixel, and runs master plus statistics. Each run requires a new output directory and writes a machine-readable report. Run completion is a technical check, not a sensitivity/specificity estimate.

```matlab
addpath('tests/analysis');
report = runDandiReference('/private/tmp/oxygen-statistics-audit/dandi-awake.nwb', ...
    '/private/tmp/oxygen-dandi-reference-v3');
```

The downloaded NWB is temporary and is not committed. Asset: `8ba82dc1-aaba-411d-a196-ff8ef0b61fc3`; release: [DANDI 000891 / 0.240215.0831](https://doi.org/10.48324/dandi.000891/0.240215.0831). See `PUBLICATION_READINESS.md` for remaining validation gates.

## Completed full-resolution DANDI run

The 600-frame reference completed master and statistics export on 9 September 2026 (approximately 132 seconds excluding NWB conversion). All converted pixels matched the archived data; the full intensity range was 0–255 stored as uint16. Event bounds and inclusive durations passed checks; eligible recording area was positive and finite. Mean occupied tissue fraction was 0.0050455 (0.50455%). The two new harness files produced no Code Analyzer messages; `git diff --check` passed.

| Detector output | Spatial sites | Individual events | Valid local amplitude baseline | Unavailable local baseline |
|---|---:|---:|---:|---:|
| Sinks | 56 | 137 | 92 | 45 |
| Surges | 14 | 40 | 21 | 19 |

All unavailable baselines were labelled `insufficient_clean_prebaseline`. These events remain detected; their amplitude is unavailable. This substantial missingness requires visual review and assessment by recurrence, timing and condition before amplitude comparisons. It must not be resolved by silently averaging only conveniently measurable events or relaxing baseline rules solely to increase coverage. The single-reference run does not establish representative missingness for the eventual cohort.

Small provenance and QC records are retained in `docs/reference-results/ID400-awake-20260909/`. Large derived outputs remain in `/private/tmp/oxygen-dandi-reference-v3/` and can be recreated with the harness. No manually reviewed accuracy labels were introduced. This milestone is full runtime and numerical QC on one biological recording; broader reference selection, parameter sweeps and visual validation remain outstanding.

## Consistent site rates and measurement availability

Statistics identity `mouse-strict-2` standardizes site recurrence to events/minute for both sinks and surges and exports recording-level baseline/amplitude availability. All **28 focused tests passed**, the full smoke suite passed, and repository checks passed with **325 MATLAB files and 51 Code Analyzer messages**. The synthetic integration verified new QC counts, zero-event handling, MAT export and the renamed surge recurrence sheet.

The full DANDI reference was rerun under `mouse-strict-2` and completed master, statistics, pixel verification and numerical QC. Counts remained 56 sink sites / 137 sink events and 14 surge sites / 40 surge events; 92 sink and 21 surge amplitudes were finite. One of the 92 finite sink amplitudes was wrong-direction; it remains visible in QC and is excluded from the hypoxic amplitude composite by the existing sign guard. No wrong-direction surge amplitude was found. The 45 sink / 19 surge unavailable baselines need further cause-specific investigation, not automatic imputation. New records are in `docs/reference-results/ID400-awake-stats2-20260909/`.

## Eight-recording reference expansion

All eight selected recordings from six animals completed lossless NWB conversion,
master analysis, statistics export and numerical QC under commit `95ef10c`.
The MATLAB source manifest was unchanged at batch completion. Results include
seven BOI recordings and one separately analyzed fluorescence control, covering
600-, 1200- and 301-frame inputs at their native spatial dimensions.

[Per-recording results and machine-readable evidence](reference-results/phase1-20260909/README.md)
include sites/events, amplitude availability, direction flags, baseline exclusions,
intensity diagnostics and exact original-versus-optimized tracking comparisons.
Both ID400 recordings matched native masks and tested event measurement columns
exactly. These results supersede single-recording coverage, but do not establish
biological detection accuracy or comparability across acquisition preparations.

## Independent signal audit

All 1,300 events across the eight-recording reference matched independent
amplitude, baseline-value, missingness and clean-sample calculations. Saved
normalized traces and sink timing traces were reconstructed successfully.
However, the [signal audit](reference-results/signal-audit-20260909/README.md)
identified substantial nonlocal sink timing and direction disagreements between
preserved-input change and normalized spatial contrast. Numerical agreement
must not be interpreted as validation of these event definitions. Address
bounded event-local timing before publication comparisons of durations/amplitudes.
