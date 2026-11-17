# Known-signal validation of the existing detector

This paired-background pilot tests the current detector without changing its
parameters. It does not use the outsourced alternative detector and does not
estimate sensitivity or false-positive rate for natural BOI events.

## Reproducible first pilot

Run `tests/analysis/runKnownSignalPilot.m` with the converted ID400 awake TIFF
and a new output directory. The runner verifies the exact source TIFF SHA-256,
saves a source/code/settings manifest, and runs the complete master detection
and event measurement path for each condition. It does not run group statistics.

Source: DANDI 000891, version 0.240215.0831,
`sub-ID400/sub-ID400_ses-M400-01-baseline-awake_image.nwb`,
series `/acquisition/1hz_mcor.tif`. The pilot uses source rows/columns 129–384
and frames 1–180 (256 × 256 × 180), at 1 Hz and 4.75 µm/pixel.

Two rectangular temporal pulses occupy frames 61–80 and 96–115 inclusive
at the same circular location, center (128,128), radius 18 pixels (85.5 µm).
Each lasts 20 seconds; there are 15 intervening frames. This deliberately
challenges recurrence separation and the clean 20-second amplitude baseline.
It is one fixed shape, size, position, spacing, background and sampling rate.

Seven inputs use exactly the same background samples:

- Unmodified paired control.
- Local 5% and 20% decreases.
- Local 5% and 20% increases.
- Uniform 20% dimming during the two windows.
- Uniform 20% dimming outside the patch and 5% dimming inside it.

Fractions multiply the original pixels during each window; they do not replace
natural fluctuations. No noise is added or independently resampled. Values are
rounded to uint16, with maximum rounding error recorded and out-of-range values
rejected before conversion. The actual mean change in the injected patch is
reported. It is the change relative to the paired original samples, not the
pipeline's pre-event-baseline amplitude. Those two quantities must not be
interpreted as interchangeable ground truth.

## Reading the outputs

For BOTH detected signs, each injection window reports total detected events,
number of events with any space-time intersection, and the highest native
space-time intersection-over-union (IoU). IoU compares the entire detected event
volume with the injected disk × time window; no overlap is zero and exact
agreement is one. The best event row and native bounds expose whether one event
has merged both windows. This is intentionally not a one-to-one accuracy score.
No arbitrary success cutoff is used.

Measurement-boundary errors are reported for the best intersecting event, even
when overlap is poor. They are diagnostic, not proof that the event was recovered.
`TimingResolved` is the production algorithm's status, not a known-truth label.
The paired control is evaluated in the same windows and disk. Naturally present
events may already overlap these windows; extra detected events elsewhere cannot
be called false positives because this background has no reviewed labels.

Cropping changes frame normalization, candidate-percentile selection and tissue
support. Shortening changes polynomial fits and temporal standardization. These
results therefore characterize this pilot, not the full reference recording.
The original camera noise process is not reproduced by scaling recorded samples,
and rectangular pulses do not represent the full range of biological waveforms.

## Next validation stages

1. Repeat on complete reference movies and multiple predetermined positions,
   including the fluorescence control and both physical pixel scales.
2. Vary amplitude, physical diameter, duration, inter-event gap and smooth pulse
   shape; include overlap and slowly changing global signals.
3. Add one-to-one event matching and explicitly report splits/merges; quantify
   changes against each paired control without labelling unknown background
   events as false positives.
4. Evaluate measurement error separately using the known incremental signal and
   an explicitly defined baseline target. Predefine treatment of unresolved
   timing and unavailable baselines before biological group comparisons.
5. Only then propose detector/normalization changes and evaluate them on held-out
   conditions. A high number of resolved events is not an optimization target.

Completed first-pilot findings and manifests are in [the evidence folder](reference-results/known-signal-pilot-20260909/README.md).

## Full-recording comparison and stage tracing

The runner now accepts a third argument, `"crop"` (default) or `"full"`.
Full mode uses every pixel and all 600 frames of the same verified source.
The injected disk stays at the same source coordinates: (256,256), radius 18
pixels, frames 61–80 and 96–115. All seven cases and detector settings are
unchanged. The full-field sink candidate budget is approximately 2,228 pixels
per frame after the 20-pixel border, compared with 467 in the crop.

`traceKnownSignalSinks` reconstructs percentile candidates, geometry/tissue
filtering, tracking, duration/spacing rejection and the three correlation passes.
A diagnostic duration-only call disables the spacing criterion without changing
production outputs; it distinguishes duration rejection from spacing rejection.
Every final reconstructed pixel cell must exactly match the saved production
site/frame masks before a trace report is accepted. Intermediate row numbers
are stage-local; they are not persistent event identifiers.

The trace records the fraction of the injected space-time volume intersected by
all surviving masks, frames intersected, and bounds of intersecting runs. This
coverage differs from the best-event IoU in the paired comparison table.
Threshold-only and candidate-mask summaries describe pixel support, not final
event identities. The independent overlap audit uses sparse logical volumes
for the full recording to keep memory requirements manageable.

Restoring field size and duration together tests whether findings persist on
the original recording. It does not independently estimate the contribution
of field size versus temporal context. No natural-event accuracy is inferred.

Completed full-recording results and the exact-mask stage traces are in [the follow-up evidence folder](reference-results/known-signal-full-20260909/README.md).
