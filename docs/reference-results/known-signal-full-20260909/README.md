# Known-signal stage trace and full-recording comparison

The [first pilot](../known-signal-pilot-20260909/README.md) found no final sink
intersecting the first −20% injection. This follow-up reconstructs every sink
stage and restores the full 512 × 512 × 600 reference movie. The two injections
remain at exactly the same source pixels and times; production settings are
unchanged. Source: ID400 awake, DANDI 000891, version 0.240215.0831, as specified
in the source/checksum manifest and [protocol](../../KNOWN_SIGNAL_VALIDATION.md).

## Why the first strong sink disappeared in the crop

| Stage | First pulse: injected volume covered | Second pulse: injected volume covered |
|---|---:|---:|
| Percentile selection | 46.13% | 46.21% |
| Geometry and tissue filtering | 46.13% | 46.20% |
| Tracking | 46.13% | 46.20% |
| Duration alone (diagnostic) | 46.13% | 46.20% |
| Production duration + spacing | **0%** | 46.20% |
| All three correlation passes | 0% | 46.20% |

Tracking produced two 20-frame runs, frames 61–80 and 96–115, at the same site.
Both satisfy the duration limits. The existing spacing criterion compares
`96 - 80 = 16` with `20 * fs = 20`, and deletes one event. There are 15 completely
empty frames between the runs. The helper's equal-duration tie ultimately
removes the earlier event.

This identifies the operative rule, not merely an association with injection
strength. Reconstructing the entire sink sequence produced exact agreement with
every final saved site/frame pixel list. The first sink is already gone before
correlation processing. A duration-only diagnostic retains both runs.

This is a **detection/recurrence exclusion**, separate from the 20-second clean
baseline requirement for amplitude. An event can be real and countable while
its preceding amplitude baseline is unavailable. The spacing rule currently
removes such an event before that distinction can be made. The pilot supplies
known repeated inputs; it does not establish that every nearby native candidate
is a separate biological event.

## The same rejection on the full recording

The full stage trace reproduces both tracked runs exactly at frames 61–80 and
96–115. They cover 96.48% and 98.44% of their injected space-time volumes,
respectively, before spacing rejection. Duration alone preserves both. The
production spacing rule then reduces first-window coverage to zero, while the
second remains at 98.44% through all correlation passes. Every reconstructed
final site/frame pixel list matches the saved master output exactly.

This resolves the crop hypothesis for this loss: the same deletion occurs after
tracking on both input extents. The cropped percentile budget reduced footprint
coverage, but was not the reason this first event disappeared.

## Interpretation limits

The full comparison restores field size and duration together. It checks whether
observations persist on the original input extent, but does not independently
attribute changed results to spatial versus temporal context. Pulse waveform,
size, location, background, and animal remain fixed. No accuracy rate for natural
events follows from these runs.

## Full-recording outcomes

All seven master runs completed. The unmodified control reproduced 137 sink
events at 56 sites and 40 surge events; neither target window overlapped a final
event of either sign at the injection location.

| Input alteration | Sink IoU (first / second) | Surge IoU (first / second) | Whole-record sink / surge count |
|---|---:|---:|---:|
| control | 0.000 / 0.000 | 0.000 / 0.000 | 137 / 40 |
| sink05 | 0.089 / 0.019 | 0.000 / 0.000 | 138 / 40 |
| sink20 | 0.000 / 0.785 | 0.000 / 0.000 | 125 / 36 |
| surge05 | 0.000 / 0.000 | 0.000 / 0.000 | 137 / 39 |
| surge20 | 0.000 / 0.000 | 0.583 / 0.376 | 138 / 41 |
| global_drop20 | 0.000 / 0.000 | 0.000 / 0.000 | 122 / 42 |
| global20_local05 | 0.000 / 0.000 | 0.000 / 0.000 | 109 / 44 |

The missing first −20% sink persists at full field size and duration. The second
sink's native IoU rises from 0.462 to 0.785. Weak sink intersections persist but
remain small (0.089 / 0.019); the second weak sink has a measured onset eight
seconds later than the imposed onset despite an algorithmic resolved status.
For +20% surges, the second native onset is seven seconds late.

**The cropped relative-contrast surge result does not reproduce at full extent.**
Both less-dimmed windows had intersecting surges in the crop, but neither does
in the full movie. The same applies to the first +5% surge. This qualifies the
pilot's conclusion: relative-contrast surges are demonstrated in that crop,
not established as a stable full-recording outcome for these injections.
This comparison does not isolate the responsible surge stage.

The counts outside the target patch also change. These are not labelled
false positives/misses: the background events have unknown truth. A matching
recording-level total alone would also not establish identical detections.

## Verification

- All 1,101,004,800 pixels across seven full inputs match independent Python/Pillow
  construction, including uint16 rounding. The generalized verifier also passed
  again on all 82,575,360 cropped input pixels.
- All 28 full-recording overlap rows match independent MATLAB sparse-volume
  computation.
- The crop/full comparison verifies equal source checksum, absolute injection
  position/times, physical calibration, injection fractions, case definitions
  and pipeline contract before comparing rows.
- Both stage traces passed exact final site/frame mask agreement with saved master
  results, beyond count agreement.
- The analysis test suite and repository checks passed (342 MATLAB files,
  54 Code Analyzer messages; this is not a clean lint result).

## Recommended correction and next validation

Replace unconditional deletion of close successive sinks with an explicit
close-event flag while retaining native runs that meet duration criteria.
Keep amplitude-baseline availability and boundary uncertainty separate. Before
adopting that change, test it on known repeated inputs with a gap sweep and on
single smooth events that noise might fragment. Compare changes on the full
reference movies; do not infer that all adjacent native runs are separate
physiological events. The current update changes diagnostics only.
