# Event-local sink timing

The previous whole-record search could assign the same refined interval to
separate native events at one site. This revision preserves native event identity
and bounds each edge search locally. It does not change candidate detection,
tracking, mask geometry, normalization or the raw event-footprint baseline rule.
The inherited detection-domain amplitude/noise diagnostic is evaluated over the
new measurement window and can consequently change.

## Rule

The timing trace is the existing whole-site filtered trace after fifth-order
detrending. Subtract its existing seventh-order fitted trend to obtain `r`.
A sink excursion lies below `-eventBaselineReturnTolerance` (default 0.015
normalized-score units).

For each native edge:

1. Require a finite edge sample below that return level. Otherwise retain the
   native edge and report `nonfinite_seed` or `seed_not_below_return_level`.
2. Walk outward only through the connected below-level excursion. The first
   sample at or above the level establishes a crossing; the measurement boundary
   is the adjacent below-level sample. A jump across the tolerance band is a
   valid crossing; it need not land within a symmetric band around the trend.
3. Never extend beyond `floor(sinkTimingMaxExtensionSec * fs)` samples from the
   native edge. The default is 20 seconds per side, a provisional development
   safeguard rather than an established biological duration constraint.
4. Partition the gap between adjacent same-site native events at the integer
   midpoint: the earlier event owns frames through that midpoint and the later
   event owns frames after it. Each event's search is constrained to its own
   interval. A sample immediately outside the limit may confirm a crossing at
   the limit; it cannot extend the measurement past the limit.
5. If a return cannot be established within those limits, retain the native
   boundary. Report `search_limit_unresolved`, `recording_boundary_unresolved`
   or `nonfinite_search`; do not silently treat the limit as a resolved onset
   or recovery.

Consequently every measurement window contains its native event, expands by at
most the configured amount on either side, and cannot overlap another window
at the same site. Different sites may overlap in time; that is not automatically
an error.

## Exported interpretation

Sink event tables now retain `NativeStartFrame`, `NativeEndFrame`,
`TimingSearchStartFrame`, `TimingSearchEndFrame`, `StartBoundaryStatus`,
`EndBoundaryStatus`, `TimingResolved`, `NativeTraceCrossesReturnLevel` and
`TimingMaxExtensionFrames`.

`TimingResolved` requires both edge crossings and a finite native trace below
the return level throughout its native interval. A seed containing internal
above-level samples is flagged even when its two edges can be extended.
The frame bounds and `DurationSec` describe the reported measurement window;
unresolved rows are not evidence of a fully observed physiological episode.
These rows and their finite amplitudes remain visible rather than being silently
excluded from the existing descriptive summaries. Publication analyses must
prespecify how unresolved timing is handled. A usable clean baseline does not
by itself resolve event timing.

`EventMeasurementQC` separately counts `TimingResolvedEvents`,
`TimingUnresolvedEvents` and `TimingNotAssessedEvents`. Surge timing is not
assessed by this sink-specific rule; its native bounds remain unchanged. Zero-
event recordings have zero counts. Baseline and amplitude availability counts
retain their existing definitions.

## Version boundary and validation

Measurement identity is `event-footprint-local-timing-2`; statistics identity is
`mouse-strict-3`. Old and new saved analyses cannot be mixed. Reanalysis is
required before using this version's statistics. Prior reference results remain
frozen for comparison.

Focused tests cover skipped tolerance-band samples, opposite excursions,
neighbor separation, search-limit fallback, recording edges, nonfinite samples,
mixed-sign native traces, fractional-frequency limits, inclusive duration and
independent timing/baseline QC. The full reference runner additionally asserts
native containment, configured extension bounds, no same-site timing overlap and
agreement between exported timing-QC counts and event tables.

Remaining validation includes sensitivity to the search limit/return level,
injection/recovery against controlled trends and recurring events, and the
whole-site versus event-footprint timing trace. A bounded rule does not prove
biological onset/recovery accuracy or solve the normalized-contrast/raw-signal
direction disagreement identified in the signal audit.
