# Event-specific references: eight-example preview of 20 versus 10 seconds

16 October 2026. **Separate preview; no production method or original result changed.**

Felix approved the eight-example reference preview and added two requirements:
remember the individual baseline for each event, including events within a
shared ROI, and evaluate whether 10 seconds could replace the required 20.

The preview supports assessing each event's own local state. Ten seconds can
provide a more recent reference and occasionally a complete window where 20
cannot, but these examples do not establish a universal 10-second default.
The clearest new numerical value from shortening the window remains
scientifically unresolved. No complete recording burden or partial sum was
calculated.

## What “individual baseline” means here

The supplied `quantifyOxygenSinkEvent` function recomputed `Baseline` around
each event's `StartIndx`, even when the input ROI trace was shared. It did not
assign one common baseline to every event in that ROI. Its permissive handling
of contamination, boundary fallback and original timing remains historical;
the preview does not reinstate those behaviors.

The current original automatic measurement also has a separate immediate
reference for every event. The added pre-episode method uses each target
event's own fixed pixels, so it never copies another event's raw mean. However,
it can reuse the same **time period before the episode head** for subsequent
events. Measuring each footprint individually and updating the reference time
for each event are different choices. Felix's reminder concerns the latter too.

The proposed direction is an event-specific reference to a comparable local
state, with a pre-episode reference retained where the intervening signal has
not recovered. An independent event baseline does not require using a preceding
dip as the reference. A shared ROI does not justify freezing the reference
through a changing recording.

The [published protocol](https://pmc.ncbi.nlm.nih.gov/articles/PMC11460448/)
describes event amplitudes relative to the 20 seconds before each event.
It does not validate either 10 seconds or indefinite sharing of one earlier
reference. The [Science paper](https://pmc.ncbi.nlm.nih.gov/articles/PMC11251491/)
limits BOI to relative short-term oxygen changes. Reference suitability remains
a scientific choice, separate from successful arithmetic.

## Fair comparison

Use the same eight target events, their saved fixed footprints, original
measurement intervals, areas, observed durations and full recording exposures.
Sampling is the supplied 1 Hz, so the candidates contain 20 or 10 samples.
The 20-second native episode-gap rule and the 20-second reference displacement
limit remain unchanged; shortening the average does not relax either guard.

Each event has ten candidate windows: immediate, nearest complete clean,
pre-episode, first post-episode and adjacent post-episode, each at 20 and
10 seconds. The nearest clean search chooses the first full contiguous window
within 0–20 seconds of the event's usual reference end, by time alone. It does
not optimize brightness, drop amplitude or burden. Both native event signs
and all sites are checked on the target's footprint. No contaminated pixels
are removed from that footprint.

Post windows start after the observed end of the linked series. They are
sensitivity context, not automatically recovered states. Showing them on
non-boundary cases helps detect why a universal post-event fallback would fail.
No window is marked scientifically accepted. Cleanliness, finite samples and
positive raw reference permit arithmetic only. Signed wrong-direction values
are retained diagnostically, with their event products unavailable. Old
pre-episode windows can show diagnostic amplitudes, but their products remain
withheld by the unchanged age limit.

## All eight examples

The table compares the **closest complete clean pre-event window** under each
duration. Values are candidate raw drop percentages on unchanged event intervals.
“—” means no complete eligible window within the permitted search. Negative
values retain the wrong direction and cannot contribute to burden.

| Recording / site / event | 20 s reference | 10 s reference | Interpretation |
|---|---:|---:|---|
| FB2412 / 1 / 1 | — | — | Acquisition starts inside the event; shortening cannot create pre-recording samples. |
| FB2412 / 1 / 3 | 6.012181% | 5.868218% | Both references must end at frame 658, before the preceding dip; 10 s does not make the immediate window clean. |
| FB2412 / 1 / 4 | 7.465060% | 7.900654% | Both immediate windows are clean; the current 20 s result replays exactly. |
| FB2413 / 3 / 6 | 11.232914% | 10.390575% | Both immediate windows are clean; event-specific timing avoids the contaminated inherited episode window. Recovery suitability remains a separate decision. |
| FB2317 / 13 / 5 | — | 1.029012% | Ten seconds provides a full immediate window, but corrected context disagrees with a fresh downward excursion. Keep unresolved. |
| FB2412 / 20 / 1 | 4.219118% | 2.504513% | Both windows must shift nine seconds earlier. The reference is already falling; a finite value does not establish a suitable non-pocket state. |
| FB2319 / 7 / 2 | −11.499107% | −9.117142% | Both nearby references retain the wrong direction. No contribution is assigned. |
| FB2412 / 3 / 1 | — | — | Only four pre-event samples were acquired; neither duration is satisfied. |

There are two clean immediate windows at 20 seconds and three at 10 seconds.
Allowing the bounded nearest-window search gives five numerically eligible
references at 20 seconds and six at 10; one in each set has the wrong direction.
Thus the only additional positive pre-event candidate from shortening in these
eight examples is FB2317, which remains scientifically unresolved. These are
purposefully selected examples, not an estimate of availability across the 17
recordings.

### Successful recurrence and unchanged control

FB2412 site 1/event 3 has six clean samples in its immediate 20-second window
654–673, and only one in its immediate 10-second window 664–673. The preceding
dip is present in both. The nearest full references are 639–658 and 649–658,
both shifted 15 seconds. Their means are 822.656691 and 821.398540. The 20-second
candidate exactly replays the current approved 6.012181% result.

The 20-second reference's two half means differ by −0.305875%; the ten-second
reference's half means differ by −1.889840%. These are descriptive diagnostics,
not new acceptance thresholds. Here shortening does not visibly improve the
reference.

For isolated event 4, immediate means are 817.667699 over 781–800 and
821.534956 over 791–800. Shortening increases its candidate amplitude by
0.435595 percentage points, or 5.84% relative. Its post-event raw signal rises
strongly: the adjacent 20-second post windows imply 10.992711% versus
31.319381%. This rules out treating “after the detection ends” as a universal
reference-selection rule, even for this isolated control.

### Event-specific reference in FB2413

Site 3/event 6's immediate 815–834 window has 20 clean samples, mean
1,400.636442 and 11.232914% drop. The last ten samples, 825–834, have mean
1,387.470301 and 10.390575% drop. In contrast, the inherited episode reference
766–785 has no clean samples and is 49 seconds displaced; shortening it to
776–785 also gives no clean samples.

The local traces show a rise toward the immediate reference before the target
dip, supporting consideration of a target-specific reference rather than an
invalid inherited one. This preview does not certify full physiological
recovery. The final ten samples are falling (half means −2.266689%, descriptive
slope −0.446561%/s), so a more recent window is not automatically a better
reference. Keep the original 20-second value as preserved evidence until a
reference rule is chosen.

### Why the new 10-second value remains on hold

FB2317 site 13/event 5 has 19/20 clean immediate samples, with the preceding
native event contacting frame 716. Its ten-second window 726–735 is complete,
with raw mean 2,388.973407 and 1.029012% raw drop. But its existing corrected
excursion relative to that same period is **−1.594007%** in drop-oriented units:
even the corrected event minimum is above the corrected reference mean. The
trace continues recovering from a much larger earlier excursion while raw
intensity has a long decline. The small raw drop cannot establish a separate
physiological pocket or resolved reference.

The pre-episode 20-second reference at 490–509 is 226 seconds displaced and
would imply 51.584544% as a diagnostic raw comparison. It remains age-held;
no product is computed from it. The 10-second inherited reference has the same
age problem. This large difference from the local 1.029012% makes individual
reference timing scientifically consequential, not a missing-value convenience.

### Contamination and a developing decline

FB2412 site 20/event 1 contacts another sink at one pre-event frame, rejecting
both immediate durations (19/20 and 9/10 clean). The nearest clean windows both
end at 132, shifted nine seconds: 113–132 has mean 555.637754 and 4.219118%
drop; 123–132 has mean 545.866029 and 2.504513% drop.

The 20-second halves differ by −3.517300%, and the raw/corrected traces are
already declining before the saved start at 142. A shorter baseline may
describe the later level more locally, but it may also include an already
developing pocket. Native-mask absence does not resolve that distinction.
Neither candidate is automatically accepted, and the saved start is not moved.

### Boundary references and wrong direction

For FB2412 site 1/event 1, the first post-event 20-second window gives the
previously demonstrated 7.403022%, and the next gives 9.034434%. Splitting that
first interval into two ten-second windows gives 6.820697% and 7.978114%.
The signal is still changing; shortening has not established recovery.

For FB2412 site 3/event 1, twenty-second post windows give 3.051475% and
3.538951%; ten-second windows give 2.453840% and 3.641831%. Its four acquired
pre-event samples are not padded. These remain conditional later-state
comparisons, not accepted burden values.

FB2319 site 7/event 2 retains negative pre-event drop estimates at either
duration, with corrected companions also negative. A later post-series mean
would manufacture a positive 14.597747% comparison at 20 seconds while the
raw signal rises through the series. That positive number is not evidence
that the post-series level is the correct reference. No absolute value, zero
fill or event exclusion is used to solve the disagreement.

## Consequences for the unchanged burden formula

`xi_i = raw_drop_percent_i * saved_event_area_um2_i * saved_event_duration_sec_i`

`xi_i_normalized = xi_i * (1e6 / saved_recording_area_um2) * (60 / saved_recording_duration_sec)`

Below are **conditional individual-event products** for the clean pre-event
candidates. They are not recording totals or newly adopted outputs. The same
fixed area, duration and exposure multiply each pair, so the relative burden
change is exactly the relative amplitude change.

| Event | Normalized product, 20 s | Normalized product, 10 s | Relative change |
|---|---:|---:|---:|
| FB2412 site 1/event 3 | 2608.970113 | 2546.497826 | −2.39% |
| FB2412 site 1/event 4 | 3041.109598 | 3218.561841 | +5.84% |
| FB2413 site 3/event 6 | 14045.242162 | 12992.011311 | −7.50% |
| FB2412 site 20/event 1 | 47778.746649 | 28361.972058 | −40.64% |

Normalization remains exactly the existing percent·µm²·s per mm² per minute
scaling. It cannot remove baseline-definition differences. If an event-specific
10-second option is later approved, save its duration, reference frames, source,
method version and review flags so that results are not unknowingly pooled
with another reference definition. These are calculated metadata, not new
mandatory CSV inputs.

No event products were summed, no recording totals were computed, and no
imputation or partial burden was used. Wrong-direction and age-held candidate
products remain unavailable. Scientific reference acceptance remains absent
for all new scenarios even when their conditional arithmetic is finite.

## Recommendation for a method decision

1. **Use a separate local reference assessment for every event**, even in a
   shared ROI. Prefer the event's own complete nearby reference when its local
   state is supported. Reuse a pre-episode interval only where a previous dip
   has not recovered and the reference remains applicable; calculate on the
   target event's own pixels. Do not carry one level through a changing series
   solely because whole event footprints intersect.
2. **Keep 20 seconds as the existing default for now.** Ten seconds is a useful
   candidate option for a genuinely shorter clean recovered interval or a
   changing baseline, but the examples do not validate a blanket replacement.
   It does not solve contaminated recurrence or the acquisition boundary and
   can substantially change burden. Do not choose whichever duration yields a
   desired amplitude or complete export.
3. **Do not automate a 10-second rescue based on numerical availability alone.**
   Under independent equal-variance noise, halving the sample count increases
   the standard error of the mean by sqrt(2); real temporal correlation and
   drift make that simple calculation inadequate for these traces. Lower
   observed CV in a shorter window is not proof of a more precise or more
   biological reference. No recovery, noise or slope cutoff has been validated
   here. Local trace context and reference-state suitability must remain visible.
4. **Retain the difficult cases as unresolved until that scientific decision.**
   FB2413 is the clearest candidate for reconsidering the inherited-window
   rule. FB2317 remains held despite a clean ten-second reference; site 20's
   developing decline and the boundary examples also need reference judgment.
   Switching all missing events to post-event means is not supported.

This preview is the agreed stopping point before method adoption. No automatic
rules, GUI defaults, baseline length, original amplitudes, event boundaries,
areas, normalization, event inventory or historical export was changed. A
production milestone and another all-17 export remain unapproved. The next
decision is whether to adopt an event-specific reference workflow, including
the conditions under which a clearly identified ten-second option is allowed.

## Numerical, visual and preservation checks

One headless MATLAB preview completed in 24.94 seconds. It evaluated 80 candidate
windows for the eight examples and 13 analytic synthetic cases. These check a
known stable reference, changing states in one shared ROI, unrecovered recurrence,
drift sensitivity, stable post-event overshoot, acquisition censoring, native
absence without recovery, closest-window selection, insufficient samples,
wrong direction, nonfinite/nonpositive references, unchanged age guard and
strict missingness. Stable post windows can agree while being the wrong state;
that is explicitly demonstrated rather than turned into a recovery criterion.

Independent NumPy checks replay 554 numerical comparisons, verify every window
and closest-window search against saved contact vectors, confirm each event's
area/duration/exposure products and the three current finite signed 20-second results, and match all
eight saved raw/corrected contexts exactly. Existing reviewed optical services
provide a second arithmetic implementation for eligible pre-event references;
their corrected companion is diagnostic and never substituted into burden.

All 595 protected production MATLAB files, selected saved masters/audits,
historical workbook and prior evidence retain their SHA-256 hashes. Both figures
were inspected at original resolution with readable axes and captions. New
evidence is below 100 MiB. There were no source-movie reads, detector runs,
correction fits, statistics/export runs, package/release or Git transport.

Evidence folder at workspace root:
`reference-validation/boi-event-reference-preview-20261016/`.
`reference-comparison.csv` holds all candidates; `preview-results.json` holds
exact source samples and context; `eight-example-summary.csv` provides compact
paired readouts. The two figures are `reference-preview-1.png` and
`reference-preview-2.png`. Native and independent receipts preserve verification.
