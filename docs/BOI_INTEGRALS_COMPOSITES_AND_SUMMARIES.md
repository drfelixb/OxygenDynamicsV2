# Signed optical integrals, composites and summaries

4 October 2026 · Checked development version 3.1.0-dev.2

For reference intensity B > 0, the relative optical trace is q = (I − B)/B.
The saved signed integral is sum(q)/sampling_frequency, using the inclusive
saved sample interval and rectangular sample widths. Units are fraction-seconds;
multiply by 100 for percent-seconds. Negative values and cancellation are
preserved for both sinks and surges. It is not an absolute excursion integral.
At 2 Hz, [−0.2, −0.1, 0.1, 0.2] integrates to 0; [−0.2, −0.1, 0, −0.1]
integrates to −0.2 fraction-seconds, or −20 percent-seconds.

The sink amplitude–area–duration composite multiplies the selected amplitude
in percent, event area in µm² and saved duration in seconds. It is an optical
composite, not a calibrated oxygen deficit. The event-specific area companion
is joined by recording, sink site and numeric event index. Native area stays
in µm². An explicitly identified older negative-drop convention is converted
only for the composite; saved amplitudes retain their original values. Invalid
or wrong-direction ingredients do not become valid contributions. This check
does not introduce a surge composite or replace automatic measurements with
exploratory corrected reviewed troughs.

Recording normalization multiplies by 10⁶/recording area in µm² for per-mm²,
divides by recording exposure in seconds for per-second and multiplies that
rate by 60 for per-minute. Thus 20% × 4 µm² × 2 s = 160 percent·µm²·s.
For 2 mm² and 4 s exposure this gives 80 per mm², 40 per second, 2400 per
minute, 20 per mm² per second and 1200 per mm² per minute. These are the
composite's area/exposure-normalized quantities, not changes to event area or
duration. Integrating the composite frame series with sample width 1/fs
recovers its strict recording total when all contributions are valid.

Recording totals require every event contribution: one missing contribution
makes the strict total unavailable. Finite event means retain their own
metric-specific contributor counts. Within-mouse recording means are strict:
a missing recording value withholds that mouse's value for that metric. Group
means weight each available mouse equally; the contributor count is mice,
not events. SEM is sample standard deviation divided by √N, available only
for N > 1. Empty valid recordings contribute zero to totals/rates; their event
means are unavailable. Missing values are never silently changed to zero.

## Worked summary

Mouse 1 has recordings with one event at 10% and two events at 20%; mouse 2
has five events at 100%. Recording amplitude means are 10, 20 and 100%.
Within-mouse means are 15 and 100%; the equal-mouse group mean is 57.5%,
SEM 42.5%, N = 2. Pooling all eight events would give 68.75%, a different
weighting that is not substituted. With unit area/duration, recording composite
totals are 10, 40 and 500; mouse means are 25 and 500; group mean 262.5,
SEM 237.5. If either mouse-1 recording composite is missing, that mouse is
withheld: group composite 500 from one mouse, SEM unavailable.

## Saved examples and identity

| Saved result | Valid sink composites | Finite mean contribution (percent·µm²·s) | Strict total | Finite mean amplitude |
|---|---:|---:|---|---:|
| G2 ID400 | 94/192 | 1003036.007446943 | Unavailable | 8.90797287875453% (94/192) |
| C02 | 142/305 | 288766.1237564371 | Unavailable | 10.433977889871457% (142/305) |

The saved ID400 site-1/event-3 signed integral is −0.6169236773099568
fraction-seconds; C02 site-1/event-2 is −0.14716353205427493. Both-sign saved
trace checks preserve baseline-invalid integrals as unavailable. Saved audit
slices and event-area companions supplied the needed numerical ingredients;
no recording was regenerated.

Both saved statistics packets lack original calculation software metadata:
their original software version is **unknown**. Their saved contract
3.1-roi-dev is retained separately; it is not a software release version.
New manifests and event/window receipts distinguish original calculation
identity from current reader/exporter 3.1.0-dev.2 and its implementation hashes.
An older manifest's current-at-writing version is not proof of its original
calculator. Future statistics writes capture calculation software identity;
that added metadata line was inspected statically, without a pipeline rerun.

Arithmetic agreement does not validate a reference or biological interpretation.
C02's reference remains conditional, FB2312 recovery remains unresolved, and
corrected reviewed troughs remain exploratory. Original footprints, correction,
automatic/reviewed separation and all prior qualifications are preserved.
See [delivery and limitations](SOFTWARE_NEXT_03_DELIVERY.md).
