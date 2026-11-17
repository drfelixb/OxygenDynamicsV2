# Saved amplitude and baseline comparison

15 October 2026. Felix explicitly requested comparison of the supplied and
current amplitude/baseline calculations on saved isolated, recurrent and
recording-start examples, retaining the burden formula and normalization and
showing what needs fixing before any method change.

## Authorized scope and stopping condition

Work item AMP-BASELINE-REVIEW-01. User benefit: identify the source of unavailable
or changed amplitudes before proposing scientific-output changes. Owner: root
Codex, no delegation. Comparison only; no production implementation is active.

Use FB2412 saved site 1 events 1, 3 and 4: recording-start, close recurrence
and clean-baseline event with long same-site gaps, respectively. Event 2 is
preceding-event context for event 3, not an extra primary comparison. Selection
uses saved timing/baseline flags before calculating alternative amplitudes.

Separate baseline eligibility on the same event trace and event bounds, then
spatial footprint on the same bounds, then the original timing algorithm. The
original method is replayed on the current saved detections/traces; this is not
regeneration of historical recording outputs or of the old detector pipeline.

Read the existing saved audit and selected master-table/trace variables only.
No source movie read, detector, correction refit, statistics run, cohort replay,
amplitude adoption, burden change or original-output write. Preserve all source
hashes. Budget: two active hours, one headless MATLAB invocation of at most
five minutes, up to one targeted repair/retry if necessary, under 100 MiB of
new evidence. No new MATLAB desktop or package installation. Save a compact
comparison table, trace figure and limitations, and stop after delivery.

Acceptance: the three current amplitudes/baseline statuses and clean sample
indices replay their saved audits; original quantifier results match the pinned
original source; event identities, source mapping and hash preservation pass;
method differences have separate labels and no fitted replacement reference.

## Result

The three current measurements, baseline sample sets and saved timing replay
their saved audits. No arithmetic mismatch was found in these examples. The
comparison identifies reference eligibility, spatial averaging and event timing
as distinct sources of disagreement. It does not establish which reference is
physiologically correct or justify replacing unavailable amplitudes.

All examples are FB2412, site 1. The isolated example is event 4 (native frames
801–804), the recurrence is event 3 (674–677), and the recording-start example
is event 1 (1–35). Event 4 is well separated from the adjacent native same-site
events; this is not a claim that the whole field or reference is physiologically
constant.

## Hold the event footprint and timing fixed

Both columns below use the same saved raw event-footprint trace and the same
current event interval. Only the baseline rule changes. The old-rule column is
therefore a controlled comparison, not the full original quantifier output.

| Example | Current amplitude | Original baseline rule on the same trace/bounds | Reference explanation |
| --- | ---: | ---: | --- |
| Isolated, event 4 | 7.465060% | 7.465060% | Same 20 clean frames, 781–800 |
| Recurrence, event 3 | Unavailable | 2.561716% | Original mean uses 654–673, including the preceding event |
| Recording start, event 1 | Unavailable | 7.403022% | Original fallback uses post-event frames 36–55 |

For the isolated example, the baseline mean is 817.667699 source units and the
minimum during the four current event frames is 756.628319. Both rules compute
`100 * (baseline - minimum) / baseline` identically.

For recurrence, the preceding site-1 event 2 occupies native frames 659–672.
It spatially overlaps the current event's footprint on all 14 of those frames.
Those are exactly the 14 excluded baseline frames. The remaining six saved
clean frames are 654–658 and 673. The current complete-20-frame rule withholds
the amplitude. The old unfiltered mean is 793.524939, giving 2.561716% from a
minimum of 773.197080. The plotted preceding dip depresses that reference; a
finite result is not proof that it estimates the intended event deficit. No
shortened or earlier substitute reference was calculated or adopted.

At recording start there are no pre-event samples. The old post-event reference
mean is 864.040568, with minimum 800.075454 during the current event interval.
The resulting 7.403022% is a contrast against later signal, not a measured drop
from an observed pre-event baseline. The trace alone does not distinguish a
stable recovered reference from other time-dependent signal changes. The
pre-recording onset and full event duration are also unobserved.

## Hold timing fixed, change spatial support

The supplied method uses a site's union of pixels across its events. The current
measurement uses the individual event footprint. The saved site union contains
2,398 pixels; these three footprints contain 452, 411 and 2,094 pixels,
respectively. Each is contained within the site union. Using the old baseline
rule on the same current event intervals:

| Example | Event-footprint amplitude | Site-union amplitude |
| --- | ---: | ---: |
| Isolated | 7.465060% | 2.629011% |
| Recurrence | 2.561716% | 0.300324% |
| Recording start | 7.403022% | 6.908069% |

Changing the spatial average alone changes the amplitude substantially, especially
for small event footprints. The numbers are measurements of different spatial
supports. This review does not label the old site average as a ground truth or
silently exchange it for the accepted event-footprint definition.

## Replay the complete original quantifier

The original `8cf3f03` function was copied with only its function name changed,
to prevent shadowing current code. It was run against the current saved native
detections, saved site timing trace, degree-seven timing trend and saved site
raw trace. No historical detector/correction pipeline was regenerated.

| Example | Current event interval | Original selected interval | Original quantifier amplitude |
| --- | --- | --- | ---: |
| Isolated | 801–804 | 678–903 | 1.656927% |
| Recurrence | 674–677 | 673–678 | 0.371073% |
| Recording start | 1–35 | 1–177 | 10.835708% |

The original timing search scans globally for agreement with its fitted trend.
The current search is limited to 20 frames and partitioned same-site gaps,
retaining native edges when a return cannot be established. In the isolated
case the old start moves to 678, immediately after the preceding same-site
event, so its baseline becomes 658–677 and its minimum is selected over 678–903.
That is a different measurement interval and baseline context. In the start
case the old reference moves to 178–197. These values cannot serve as direct
targets for restoring the current amplitudes.

The old duration field is `end - start`; the current inclusive frame duration
is `end - start + 1`. For example, the old isolated interval spans 226 samples
but reports 225 frames, while the current four-sample interval reports four.
No duration or burden calculation was changed in this comparison.

Current timing is resolved for the recurrence example. The isolated and
recording-start examples retain unresolved timing flags. A finite isolated-event
amplitude and a clean baseline do not establish that its native interval is the
complete physiological excursion.

## What needs resolution before a method change

1. **Reference for recurrent events.** The current all-or-nothing immediate
   baseline rule loses this event; the old mean includes the preceding dip.
   Define whether a closely spaced series has a common reference and how
   recovery separates events. An earlier/shared reference would be a candidate
   scientific rule, not an automatic repair or a reference validated here.
2. **Recording-boundary events.** Distinguish an event already active at the
   start, its observed portion and its unknown full onset/duration. A later
   reference needs explicit scientific justification and separate provenance;
   it cannot silently be presented as observed pre-event signal.
3. **Consistent spatial basis.** Retain the accepted event-footprint amplitudes
   while comparing like with like. Document site-union historical differences;
   do not swap averages merely to restore finite numbers.
4. **Meaning and uncertainty of duration.** Preserve bounded timing. Decide
   explicitly whether the burden duration represents native detection support
   or a reviewed complete optical excursion, retaining unresolved flags.
   Restoring the global old boundary search would reintroduce the interval
   expansion demonstrated here.

The intended burden remains the sum of amplitude × event area × event duration,
with the existing recording-area/time normalization. No partial-burden endpoint,
coverage inflation, missing-value zero fill, new baseline model, correction fit
or method adoption follows from this comparison. The reference and boundary
decisions must precede a concrete candidate fix and impact review.

## Verification and delivery

The first headless launcher attempt exited without diagnostic output after
2.78 seconds. The single permitted retry completed in 17.58 seconds outside
the sandbox; the failed receipt/log are retained. No further MATLAB invocation
was made. Three current amplitude/baseline/sample-set and timing replays pass;
the original quantifier agrees with explicit reference arithmetic. Independent
NumPy arithmetic verifies all 12 readouts and transcribes the original boundary
search against the exported trend at tolerance 0.015 for all three events.
The pinned original helper differs in its executable copy only by function name.

All 11 protected source/audit/master/helper hashes remain unchanged, including
both burden helpers. The source raw file was identified by its saved SHA-256 but
not opened. No detector, correction, statistics run, production code change,
new package installation or original-output write occurred. The one completed
MATLAB comparison was headless. No scientific method was adopted.

Evidence is in `reference-validation/boi-amplitude-baseline-comparison-20261015/`
at workspace root: `amplitude-comparison.csv`, `comparison-results.json`,
`baseline-comparison.png`, original helper snapshot, execution receipts and
`independent-verification.json`. The trace figure was visually inspected.
The authorized three-example comparison is complete; implementation remains
stopped pending scientific definition and review of any proposed change.
