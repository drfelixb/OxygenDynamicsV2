# Paired known-signal pilot, 2026-09-09

Seven full master runs completed on the same ID400 awake crop. The production
detector and measurement settings were unchanged. See the
[protocol](../../KNOWN_SIGNAL_VALIDATION.md) for source identity, design and limitations.
An independent Python/Pillow calculation verified all 82,575,360 input pixels.
An independent full-volume MATLAB calculation reproduced all 28 overlap rows.
The analysis test suite passed, and repository checks inspected 341 MATLAB files
with 53 Code Analyzer messages (these messages are not a clean lint result).

## Results at the injected location

Each cell below gives the best native space-time IoU for the first / second
20-second pulse. Zero means no final event of that sign intersects the disk and
window. It does not describe activity elsewhere in the movie.

| Input alteration | Sink IoU | Surge IoU |
|---|---:|---:|
| Paired unmodified control | 0 / 0 | 0 / 0 |
| Local −5% | 0.094 / 0.063 | 0 / 0 |
| Local −20% | 0 / 0.462 | 0 / 0 |
| Local +5% | 0 / 0 | 0.304 / 0 |
| Local +20% | 0 / 0 | 0.588 / 0.491 |
| Uniform −20% | 0.004 / 0 | 0 / 0 |
| Outside −20%, inside −5% | 0 / 0 | 0.661 / 0.782 |

These scores are descriptive overlaps, not a sensitivity estimate. The matching
method deliberately allows the same detected event to be the best match for
multiple windows so a merge remains visible in the row identities.

## Implications

1. **Relative contrast can reverse the interpretation of the imposed change.**
   Both less-dimmed patches were detected as surges, with native timing exactly
   matching the injected windows. Their paired input change was about −5%.
   This demonstrates that detection sign does not necessarily express the sign
   of the imposed local input change. It does not imply those events acquired
   a valid positive raw amplitude: their exported amplitudes were unavailable.
2. **A larger injection did not consistently retain an event.** Both −5% windows
   intersected sink events, but the first −20% window did not. The pilot alone
   cannot identify whether normalization, candidate geometry, tracking or later
   rejection caused the loss. Stage-by-stage tracing is the next investigation.
3. **The percentile rule limits measurable sink area.** The injected disk has
   1,009 pixels. A 256-square crop becomes 216-square after the sink border is
   removed. Its darkest 1% supplies approximately 467 candidate pixels per
   frame, before other rejection. Thus an exact footprint is impossible at this
   candidate stage for this patch, and the 0.462 overlap is near that area budget.
   Cropping materially affects this constraint; repeat at full field size.
4. **Timing and baseline availability remain separate.** Both −5% sink matches
   were timing-resolved; measured onset/offset errors were 0/−1 seconds and
   +1/−1 seconds. The retained −20% second sink had exact native/measurement
   bounds but unresolved timing and unavailable amplitude. All intersecting
   surge amplitudes were unavailable. These are not zero amplitudes or proof
   of a correct physiological boundary. The second injection has only a
   15-second clean gap by design.

Uniform dimming also changed overall counts from 16 sinks / 5 surges in the
control to 13 / 9. Those counts concern the whole crop, and their changes cannot
be labelled false positives or misses without knowing the background events.

## Next action

Trace the first −20% sink through each detector stage, then repeat these fixed
cases on the full original field and duration. Establish which losses are caused
by crop/percentile constraints versus rejection logic before proposing settings
or normalization changes. Expand across recordings, physical sizes and smoother
waveforms after that diagnostic comparison.
