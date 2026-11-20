# Recurrence-preserving BOI validation, 2026-09-09

This update removes automatic deletion based on short same-site sink gaps.
Native runs must still meet duration requirements and pass the existing
correlation processing. [The recurrence specification](../../SINK_RECURRENCE.md)
defines the new flags, physical gap convention, count interpretation and
breaking analysis contract.

## Controlled challenges and integration

The six new function-based tests cover 33 gap/frame-rate combinations (1, 1.01
and 2 Hz), duration limits, different sites, unordered event rows, zero-event QC,
and separate-versus-fragmented excursions. All duration-qualified prescribed
runs survive regardless of their gap. Both sides of a gap shorter than 20
seconds are flagged. Timing remains independent of that flag.

The single-pulse fragmentation fixture prescribes a gap in the candidate mask
while the underlying smooth signal stays in one excursion. Both resulting runs
remain flagged and their inner timing boundaries are unresolved. The two-pulse
fixture has resolved boundaries but the same proximity flag. These checks do
not estimate the rate of noise fragmentation in real movies, nor guarantee
that timing resolution can distinguish every fragmented signal.

The full master-to-statistics integration passed, including saved event flags,
recording QC, and a zero-event recording. The recording totals still include
flagged runs; the tests do not silently reclassify them as confirmed biological
episodes. Strict amplitude-baseline requirements remain in effect.

## Full-recording comparisons

Source and injections are identical to the [previous full-recording comparison](../known-signal-full-20260909/README.md):
ID400 awake, all 512 × 512 pixels and 600 frames, seven paired-input cases,
1 Hz, 4.75 µm/pixel, disk radius 18 pixels at source (256,256), pulses at
61–80 and 96–115 inclusive. Only the detector/measurement/statistics contract
and its associated recurrence policy change.

The unmodified control now contains 196 sink runs versus 137 previously;
surge event count remains 40. This is a change in retained detections, not
59 newly confirmed physiological events. No manually reviewed truth exists
for the natural background. These seven altered inputs belong to one source
recording; they are not seven biological replicates.

Both −20% sinks are now retained, with native and measured windows exactly
matching the injected frames. Their best space-time IoUs are 0.697 and 0.785,
versus 0 and 0.785 previously. Both have the close-run review flag and resolved
algorithmic timing. Both amplitudes remain unavailable for insufficient clean
pre-event baseline. We do not substitute the known injection percentage for a
missing measured amplitude.

For the first −5% sink, native overlap is unchanged but measurement timing and
baseline availability change when neighboring runs are retained. Its measured
onset is 11 seconds late, timing is unresolved, and its amplitude is unavailable.
Thus this correction fixes one identified deletion policy; it does not establish
accurate boundaries for all weak events.

## Recording-level measurement and recurrence QC

These rows are sink-run counts, not numbers of independent biological events.
Close-run, timing and amplitude categories overlap; they must not be summed.

| Input | Sink runs | Close-run flags | Finite amplitudes | Unresolved timing |
|---|---:|---:|---:|---:|
| control | 196 | 104 | 97 | 92 |
| sink05 | 198 | 104 | 97 | 93 |
| sink20 | 178 | 95 | 89 | 84 |
| surge05 | 196 | 104 | 97 | 92 |
| surge20 | 203 | 111 | 99 | 100 |
| global_drop20 | 176 | 97 | 80 | 82 |
| global20_local05 | 158 | 91 | 65 | 75 |

## Verification

- All 1,101,004,800 pixels in the seven current inputs match independent
  construction, including rounding; previous/current input designs and the
  actual imposed local fractions match exactly.
- All 28 overlap rows match independent sparse-volume computation.
- Every saved native gap and recurrence flag was independently checked against
  site/frame masks for all cases. Same-site measurement windows never overlap.
- The strong-sink stage trace reconstructs exact final masks and retains both
  native runs through all correlation passes, covering 96.48% and 98.44% of
  their injected space-time volumes.
- Surge native masks and event identities are exactly unchanged across all seven
  cases. This is not an assertion that every surge amplitude remains unchanged:
  newly retained sink masks participate in the shared clean-baseline check.
- The master-run code manifest identifies the numerical run. Workbook field
  definitions were then expanded and verified separately through integration.

## Remaining work

The gap sweep and prescribed dropout fixture do not establish a false-splitting
rate in natural recordings. Next, inject smooth single and repeated pulses with
controlled noise and a range of gaps into multiple complete reference movies.
Measure splitting, merging, native count changes, timing error and amplitude
availability separately. The earlier eight-recording reference evidence predates
this contract and needs reanalysis. No default threshold was optimized to these
seven cases, and no publication-grade detector accuracy is claimed.

Final checks: **52 analysis tests passed**, full smoke suite passed, and final master-to-statistics integration verified the workbook recurrence definitions. Repository checks passed with 346 MATLAB files inspected and 57 Code Analyzer messages (not a clean lint result).
