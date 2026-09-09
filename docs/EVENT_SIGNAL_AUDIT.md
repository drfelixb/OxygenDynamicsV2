# Event signal and amplitude audit

The current measurement is the signed fractional change over an individual
event's fixed footprint relative to a complete, uncontaminated pre-event
baseline. The detection label refers to a spatially and temporally normalized
signal after detrending and filtering. These are different quantities. A
wrong-direction preserved-input amplitude is a diagnostic flag; it does not
alone establish an arithmetic error or a biologically false detection.

## Corrected audit calculation

`auditOxygenEventAmplitudeSource` loads both saved event/site tables and the
checksum-matched preserved-input TIFF. It rejects incompatible contracts and
ambiguous saved files. It independently reconstructs the union footprint of
each event's native mask run, averages the original pixels, excludes baseline
frames overlapping either event sign, and recomputes baseline status and
amplitude. It compares these against stored values, including NaN status and
clean sample counts. It does not call the measurement finalizer or change its
outputs. NaN is not treated as zero. A zero-event input remains an empty audit.

The former sink audit used whole-site raw traces, accepted shortened baselines,
and could substitute post-event samples. Those rules were inconsistent with
the revised event measurements and could report false discrepancies. It now
calls the corrected event audit and selects sink rows. No master reanalysis is
required solely because this diagnostic tool changed.

## Signal reconstruction and interpretation

With `reconstructDetection=true`, the audit repeats pixelwise cubic detrending,
frame spatial SD normalization, pixel temporal SD normalization, spatial
averaging and temporal smoothing from the preserved source (or checksum-matched
denoised input, when used by the saved analysis). It does not read the
quantized/display-scaled processed TIFFs as measurements.

Before producing diagnostic plots, it checks reconstructed site traces against
saved traces within a relative/absolute tolerance of 1e-5. The follow-up audit also retains the
frame-wise spatial-normalized event trace before temporal standardization. The sink normalized
and filtered site traces have additional fifth-order detrending; both are
verified. Surge normalized site traces do not receive that extra detrending.
Sink timing uses a seventh-order trend of the fifth-order-detrended filtered
site trace to expand native bounds. Surge timing remains at native mask bounds.

Each plot distinguishes:

1. Preserved-input event-footprint intensity, full-record cubic fit and the
   clean baseline samples.
2. Event-footprint intensity after detection-input cubic detrending.
3. Event-footprint normalized and filtered scores.
4. The actual whole-site timing trace; sinks also show the seventh-order trend.

Both native detection bounds and measurement bounds are marked. Panels use
separate units. Event-footprint mean filtered score is descriptive: the detector
thresholds individual pixels/regions, not this mean trace. A cubic-fit component
is an algorithmic decomposition, not proof of instrumental drift; it may also
contain biological variation.

For events with valid amplitudes, the audit decomposes the preserved-input
change at the raw amplitude extremum into full-record cubic-fit and residual
components, using the same baseline samples and denominator. Their sum is
asserted to equal the raw change. This diagnoses how detrending can alter sign;
it does not define a replacement physiological amplitude or pO2 estimate.

## Reference execution

```matlab
setupOxygenDynamicsPath;
addpath('tests/analysis');
Summary = runDandiSignalAudit('/path/to/completed/reference-run', ...
    '/path/to/new/signal-audit');
assert(all(Summary.Status=="passed"));
```

The runner requires passed reference reports, writes all-event audit tables and
per-recording status/errors, and checks that MATLAB source hashes remained
unchanged. It plots every wrong-direction event and up to three evenly spaced
rows per event sign in acquisitions explicitly labelled mNeonGreen/fluorescence.
Those control examples are illustrative selections, not random validation labels.
The original master/statistics outputs are never overwritten.

The [completed reference investigation](reference-results/signal-audit-20260909/README.md)
shows why passing this audit does not by itself establish correct event timing
or physiological interpretation. `tests/analysis/compareNativeEventWindows.m`
quantifies a native-bound counterfactual without updating master/statistics data.
It asserts unchanged surge measurements as an internal control.

Run `python3 tests/analysis/summarize_audit_timing.py /path/to/signal-audit`
to reproduce the within-site overlap counts from the all-event audit CSV.
It uses only the Python standard library.
