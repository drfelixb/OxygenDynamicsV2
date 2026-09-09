# Preserve close native sink runs and expose recurrence uncertainty

The BOI master now filters native tracked runs by duration only. It no longer
arbitrarily deletes one of two duration-qualified same-site runs because their
gap is short. Existing frame thresholds, tracking, and correlation processing
remain unchanged. The separate iOS master retains its previous helper; this
change targets the BOI path.

## Meaning of the new fields

Each final sink event receives:

- `PreviousNativeGapSec` and `NextNativeGapSec`: empty frames between neighboring
  native runs at the same final site, divided by the actual sampling frequency.
  Missing neighbor = NaN. Native bounds, not refined measurement windows, define
  the gap. Events at other sites do not trigger this flag.
- `CloseNativeRun`: true for BOTH members of a neighboring pair with a gap
  strictly less than `sinkCloseNativeGapSec` (20 seconds in this development
  profile). A chain can flag multiple events.
- `CloseNativeGapThresholdSec`: the applied review threshold.
- `RecurrenceStatus`: `close_native_runs_review` or `no_close_native_neighbor`.
  Neither value confirms a separate physiological event.

The gap definition is now explicit. Twenty completely empty seconds is not
flagged. The old deletion compared a start/end sample difference, which was
one frame longer than the empty gap. The new flag is not an exact re-expression
of that old off-by-one convention.

Flags are calculated after site correlation/merging, from the final native runs.
The same short gap can arise from true recurrence or from noise temporarily
interrupting detection of one sustained event. No automatic merging, deletion,
or assertion of physiological independence is made from this flag.

## Counts, timing and baseline availability

Event counts remain **counts of retained native detection runs**. Flagged runs
remain included in descriptive event totals and in amplitude summaries when
those amplitudes are otherwise valid. Do not interpret that as confirmation of
independent biological episodes. `EventMeasurementQC` adds `CloseNativeRunEvents`
and `RecurrenceNotAssessedEvents` alongside amplitude and timing counts. The
latter distinguishes absent recurrence assessment from zero
flagged events. Zero-event recordings have zero such event counts.

Timing refinement still partitions gaps between same-site native events, so
neighboring measurement windows do not overlap. A single prolonged excursion
split into two candidate runs can have unresolved inner boundaries. That is a
useful diagnostic, not a guaranteed classifier: a noisy trace can itself cross
the return level and appear resolved. `TimingResolved` is not a biological
separation label.

The complete clean pre-event baseline rule is unchanged and independent. A
nearby event can invalidate an amplitude when its detected pixels overlap the
measurement footprint. A different footprint can still yield a valid baseline.
The new flag alone neither invalidates nor fabricates an amplitude.

## Validation design

`testSinkRecurrence` exercises a gap/frame-rate sweep, duration limits, different
sites, unordered rows, zero-event QC and two controlled timing fixtures:

1. Two known separate excursions with a short gap: both runs remain, both are
   flagged, and their boundaries can resolve.
2. One smooth excursion with a prescribed candidate dropout: both native runs
   remain flagged, with unresolved inner boundaries and no overlapping windows.

The dropout fixture tests behavior after candidate formation. It is not an
end-to-end estimate of how often recorded noise causes fragmentation.
The full-recording injection runner tests the complete detector on the same
seven fixed source alterations as the prior comparison. Its result rows now
also expose the matched event's close-run flag and baseline status.
The master-to-statistics integration checks that flags survive saved tables and
that the exported recording QC retains both known runs, including zero-event
recordings. Increasing event count is not the validation objective.

## Migration

Reanalysis is required. Current contract:

- Detector: `existing-v2-retain-close-terminal-3`
- Measurement: `event-footprint-sign-qc-4`
- Statistics: `mouse-strict-sign-qc-5`
- Schema: `3.0-dev`; normalization unchanged.

The existing contract/settings validator rejects earlier saved masters before
pooling. Historical reference results remain historical and are not new-contract
outputs. Do not infer that the earlier eight-recording reference set has already
been rerun with this correction.

Completed full-recording results, native-mask checks and QC counts are in [the validation evidence](reference-results/retain-close-20260909/README.md). The exported workbook also defines the recurrence fields in `MetricDefinitions`.

The [surge audit](SURGE_ANALYSIS_AUDIT.md) extends the same native-gap status to surges, using `surgeCloseNativeGapSec`; surge timing remains native and unrefined. The recurrence evidence linked above predates that audit contract.
