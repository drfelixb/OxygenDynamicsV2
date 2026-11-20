# Reference proposal for recurrent and recording-start pockets

**Implementation approved 16 October 2026:** Felix selected the pre-episode reference and withholding beyond a 20-second shift. See [implementation](BOI_PRE_EPISODE_IMPLEMENTATION.md). The dated candidate evidence below remains unchanged.

15 October 2026. Felix requests a biologically sensible reference proposal and
a demonstration on the same saved examples before changing the method. The
amplitude × area × duration burden and its area/time normalization must remain.
The request authorizes a separate numerical preview, not production adoption.

## Scope

Work item AMP-REFERENCE-PREVIEW-01. Owner root Codex, no delegation. Use the same
three FB2412 site-1 events: isolated event 4, recurrent event 3 and recording-start
event 1. Event 2 is preceding-event context for event 3. Preserve all previous
evidence, automatic results, original inputs, current footprints and intervals.
No source-movie read, detector, correction refit, statistics run, cohort analysis
or new recording total. One headless MATLAB invocation of at most five minutes,
with one targeted repair/retry if necessary, two active hours and 100 MiB of
new evidence. No package or new desktop. Deliver the preview and stop.

## Proposed scientific principle

Estimate relative deficit from the local signal before the episode, rather than
from a preceding dip within it. For a short closely spaced series, retain its
individual event IDs, areas and durations, and use one pre-series reference
period sampled separately on each event's existing fixed footprint. Sharing a
time interval does not mean sharing one raw-intensity value across different
footprints. Reset the reference after supported recovery, not after every
detected interruption. Episode grouping and physiological recovery require a
defined rule; proximity and native-mask absence alone do not validate recovery.

For this demonstration, event 2 starts at frame 659 and event 3 follows after
one empty frame. The candidate reference is the same 20-second scale as before,
frames 639–658, on event 3's footprint. This tests a pre-series anchor, not an
unlimited backward search, shortened window or optimized choice of a high mean.
Retain event 4's existing 781–800 window as the isolated control. Verify both-sign
native-mask overlap and finite samples on each proposed window. Numerical
eligibility is separate from physiological reference suitability.

For an event present at acquisition start, a local post-recovery reference can
be considered only if recovery and the reference state are supported. In that
case, burden inside the acquired window can use its observed duration; no
unobserved time before acquisition is added. Unknown onset/full event lifetime
does not itself preclude a clearly defined observed-window contribution, but an
unsupported reference cannot establish it. Keep boundary censoring and the
reference direction explicit.

On event 1, demonstrate the original post-event window 36–55 and the next
adjacent window 56–75 as a sensitivity check. These windows are derived from
the existing end and the existing 20-frame length, not selected for a preferred
amplitude. Do not treat the second window as a new preferred baseline, claim
normoxia, apply a maximum/percentile envelope, or fit/extrapolate a new
substrate/global trend. Descriptive slopes and half-window means are diagnostics,
not new amplitude models or tuned pass/fail thresholds.

This is a proposed relative optical reference, not a calibration to absolute
oxygen or proof of tissue injury. The primary Science study describes recurring
pockets and limits BLI to relative, short-term oxygen changes:
https://pmc.ncbi.nlm.nih.gov/articles/PMC11251491/

Prior local work already found that short-window fitted lines can amplify
fluctuations (see BOI_SCIENTIFIC_DECISIONS.md, R2-BASELINE-COMPARISON-037). No
universal drift correction or automatically extrapolated reference is proposed.
The earlier reviewed-baseline policy remains historical and unadopted; the new
user request explicitly authorizes this separate candidate demonstration only.

## Demonstration on the saved examples

The candidate calculations are separate from automatic results. All event
footprints, event areas, event intervals and the recording exposure remain
unchanged. All four reference windows contain 20 finite samples with no saved
native-mask overlap of either sign. This establishes numerical eligibility,
not physiological normality or recovery.

| Example/reference | Frames | Reference mean, source units | Amplitude | Proposed disposition |
| --- | --- | ---: | ---: | --- |
| Isolated event 4, unchanged immediate reference | 781–800 | 817.667699 | 7.465060% | Control; exactly retains saved amplitude/contribution |
| Recurrent event 3, reference before the series | 639–658 | 822.656691 | 6.012181% | Biologically motivated pre-episode candidate; not adopted |
| Recording-start event 1, first later window | 36–55 | 864.040568 | 7.403022% | Conditional post-recovery assumption only |
| Same recording-start event, adjacent sensitivity window | 56–75 | 879.536605 | 9.034434% | Sensitivity check; not a preferred substitute window |

### Recurrent example

The preceding event 2 ends at 672 and event 3 begins at 674, leaving only one
empty frame. Their fixed footprints intersect on 408 of event 3's 411 pixels.
This supports testing a shared episode reference rather than treating the
preceding dip as normal signal. The numerical/native facts do not by themselves
validate physiological episode grouping or recovery.

The common reference period is 639–658, directly before event 2 starts at 659.
On event 3's footprint it gives `B=822.656691`, compared with `B=793.524939`
for the immediate 654–673 window that includes event 2. The event minimum remains
773.197080. Hence the pre-episode candidate is 6.012181%, whereas the contaminated
immediate-window calculation is 2.561716%. The current accepted rule remains
unavailable because its immediate window has only six eligible samples.

On event 2's own footprint the same reference frames have a different mean,
826.846448; its existing 6.152138% amplitude is unchanged. No raw baseline value
is copied between different footprints and no detection is merged or removed.

The target event's 20 reference samples have CV 1.9664%. Its two ten-frame means
are 823.914842 and 821.398540 (a −0.3059% difference relative to the full mean).
These are descriptive context, not a tuned physiological acceptance threshold.
The baseline window is not assumed perfectly flat, and a constant reference
must not be carried indefinitely through a long or drifting episode.

### Recording-start example

The later windows have means differing by 1.7934%, which changes the inferred
amplitude by 1.631411 percentage points. The first window's two half-means are
858.640735 and 869.440401; the next window's are 885.914183 and 873.159026.
The local signal is still changing. Native-mask cleanliness does not establish
a stable recovered physiological reference, and no independent pre-event level
is observed. I do not recommend selecting either candidate automatically here.
The demonstration supports an explicit unresolved-reference flag for this
example, not a claim that every acquisition-start event must be discarded.

A post-recovery reference is a scientifically interpretable option when the
observed recovery and locally comparable reference state are supported. It
measures deficit relative to that later state. The target can remain burden
inside the recorded interval: if the reference is justified, use the saved
observed 35-second duration and mark the onset as acquisition-censored. Do not
add unobserved event time. This distinction corrects any implication that an
unobserved full onset alone makes within-recording burden impossible.

The present event also retains unresolved timing. Neither changing its baseline
nor obtaining a finite amplitude proves that the current native 1–35 interval
is the complete physiological excursion. No boundary was moved in this preview.

## Burden formula and normalization are unchanged

For event 3, retain its saved area 1,758.91625 µm² and saved four-second duration:

`xi3 = 6.012181174339028 * 1758.91625 * 4 = 42299.692661956 percent*µm²*s`

Use the existing full recording area 810,658.82 µm² and 1,200-second recording
duration, without changing either denominator:

`xi3_normalized = xi3 * (1e6 / 810658.82) * (60 / 1200) = 2608.970112849447`

The normalized unit remains percent·µm²·s per mm² per minute, exactly the supplied
script's scaling. The isolated control retains its saved 49,306.04636812351
event contribution and normalized 3,041.1095982477254. Only the hypothetical
reference changes the recurrence amplitude. No recording-level total is produced
from these examples, and no partial-burden endpoint is adopted.

For transparency, the two start-event assumptions would give normalized event
contributions 101,355.82154418617 and 123,691.70672843848 with the same saved area
and observed duration. Both remain diagnostic assumptions, not accepted burden
values. Their difference is not removed by area/time normalization.

## Recommendation and remaining definition

Use a local pre-episode reference as the candidate default for short recurrent
series. Preserve individual event contributions, including recurrence, while
avoiding rebaselining to a depressed preceding event. Treat a recovered local
post-event reference as a conditional boundary-event option with explicit
reference provenance and acquisition censoring. Leave the reference unresolved
when the saved data do not support that option, as in this example.

Before adoption, specify episode membership, evidence required to reset after
recovery, the permissible reference time horizon and handling of changing
background signal. The existing close-run flag may identify candidates; its
20-second gap is not established as a universal biological boundary. Do not
require a globally flat trace or tune a numerical cutoff on these outcomes.
For longer/drifting series a fixed pre-episode mean may be unsuitable; this
preview does not solve that with an unvalidated fitted trend.

Any implementation should retain the old automatic result and add versioned
reference kind, reference frames and episode/censoring provenance. These can
be calculated output fields; the proposal does not require extra mandatory
batch CSV inputs or manual review of every event. No new GUI or production
reference algorithm has been implemented by this work.

## Verification and delivery

One headless MATLAB invocation completed in 18.39 seconds. The three saved raw
event traces match the prior comparison exactly, the preceding event's amplitude
replays, and 80 candidate reference samples are checked against the saved native
masks of both signs. Independent NumPy calculation verifies all four reference
means, amplitudes, descriptive slopes, half-window means and event burden
products/rates against the unchanged saved areas, durations and exposure.

All 15 protected source/evidence/master/helper/workbook hashes are unchanged,
including the burden helpers and combined export. No movie, detector, correction
or statistics execution, package installation, recording total, production
calculation change or scientific-method adoption occurred. The three-panel
trace figure was visually inspected. Named evidence remains under
`reference-validation/boi-episode-baseline-preview-20261015/` at workspace root.
The candidate preview is complete; production implementation remains stopped.
