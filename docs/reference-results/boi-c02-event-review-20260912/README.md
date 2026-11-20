# FB2314 awake: targeted event and baseline review

12 September 2026 · **R1-C02-EVENT-029** · BOI both signs · descriptive development.

The six prespecified cases from the [completed single-recording workflow](../boi-c02-workflow-20260912/README.md)
have been inspected against preserved-input traces, native masks and the exact
baseline overlap history. The negative surge values agree with the optical
measurements. The missing baselines arise from observed preceding detections or
recording-start truncation. Neither result establishes anatomical admission or
physiological event identity. **Retain the calculations and restrict their claims;
do not replace baselines, remove events or infer biological acceptance.**

This review changes no detector, measurement definition, mask, frame, window,
onset rule, animal role or comparison. Dictionary **0.3.0-draft** remains unchanged.
The recording is FB2314 awake, portable ID `dandi000891_FB2314_awake_028`, DANDI
000891 asset `9ce94e52-e1d9-446d-a758-66db41a698e6`; its published/archive relationship
is retained from the preceding provenance work. This is a review of fresh 028
outputs, not a reinterpretation of values in the old v2 output files.

## Selection and evidence

The [prespecification](prespecification.json) fixes the first previously inspected
finite peripheral surge, both negative finite surges, the largest unavailable-
amplitude event by native area-time inside existing automatic support for each
sign, and the first saved sink already present at frame 1. Ties use saved row
order. These are **purposively selected cases**, not a prevalence sample.

All 268 events were ranked using saved native per-frame masks. Their within-sign
intersected area-time sums exactly match the respective recording unions: no
same-sign overlap excess occurs in this recording. The event-specific shares
below are therefore additive here; this property must not be presumed elsewhere.
See [all-event ranking](event-ranking.csv), [selected identities](selected-events.csv)
and [review calculation report](review-report.json).

| Sign, site/event | Native frames | Measurement frames | Clean baseline / 20 | Amplitude | Included native area-time (µm²·s) | Figure |
|---|---:|---:|---:|---:|---:|---|
| sink 1/1 | 1–18 | 1–27 | 0 | unavailable | 49,973.10 | [review](sink-site01-event01/review.png) |
| sink 5/4 | 496–643 | 496–643 | 1 | unavailable | 1,314,167.24 | [review](sink-site05-event04/review.png) |
| surge 1/1 | 108–118 | 108–118 | 20 | +9.0038% | 243,950.92 | [review](surge-site01-event01/review.png) |
| surge 4/1 | 136–249 | 136–249 | 4 | unavailable | 8,329,233.31 | [review](surge-site04-event01/review.png) |
| surge 16/1 | 501–514 | 501–514 | 20 | −1.4504% | 538,526.59 | [review](surge-site16-event01/review.png) |
| surge 16/7 | 650–665 | 650–665 | 20 | −1.7567% | 518,899.62 | [review](surge-site16-event07/review.png) |

Frames are original one-based indices. At user-confirmed external **1 Hz**, frames
a–b represent modeled interval [a−1,b) seconds; the sample at frame a is plotted
at a−1 seconds. Embedded recording clocks are not used. Camera exposure and actual
frame validity remain separately unknown.

Each case folder contains `summary.json`, all 1200 source means in `trace.csv`,
one-based MATLAB column-major coordinates in `footprint.csv`, and an exact
`baseline-overlap-events.csv`. Empty overlap tables are genuinely empty for that
selected candidate interval, not claims of no detections anywhere in the movie.
Large native replay MATs and original-source frames remain in local evidence.

## What the cases establish

**Both negative surges are at site 16 in the dim upper-left field margin.**
Their union footprints have 47.9% and 44.1% of pixels outside the current automatic
support; those percentages describe fixed union footprints, not the detector's
candidate-filter inputs or independently validated non-tissue. The native masks
are largely above the recognizable tissue edge in the displayed frames.

For event 1, B0 is 1052.497356 input units and the largest event sample is
1037.232268; for event 7, B0 is 810.723994 and the largest event sample is
796.481675. Thus max((I−B0)/B0) is negative in both cases. Each has 20 overlap-free
baseline samples. The local traces dip and partly return against a longer decline;
the whole event interval remains below B0. This is a real disagreement between
the detector label and this preserved-input amplitude definition. It is not a
missing-baseline error or a reason to take an absolute value. The cause of the
label disagreement is not established by this review: detection preprocessing
was not reconstructed, and no physiological or artifact class is assigned.

**The finite peripheral surge 1/1 is embedded in a broader rise.** Its clean
baseline ranges from 3303.10 to 3881.18 input units. Its native interval contains
a dip and return, while every event sample remains above the preceding baseline
mean of 3583.54. The +9.0038% amplitude therefore does not identify an isolated
positive transient or prove a stationary physiological reference. The existing
baseline status `valid` means the calculation's requirements were met; no new
flatness threshold is introduced. Its evolving footprint reaches the dim right
margin, so source support remains a separate question.

**The largest unavailable-amplitude sink, site 5/event 4, overlaps its history.**
Its candidate baseline is frames 476–495. The preceding same-site sink 5/3
overlaps the fixed footprint at all frames 476–494; only frame 495 is clean.
Sinks 6/5 and 6/6 also overlap at frames 476–479 and 487–490, respectively,
within those already excluded samples. No surge causes baseline exclusion here.
The current event spans 148 native seconds in the right margin, with local
fluctuations during a broad decline. Its 1,314,167.24 µm²·s contributes **21.34% of
all sink covered area-time**, or **27.84% of unavailable-amplitude sink covered
area-time** under the saved support. The missing amplitude does not erase it.

**The largest unavailable-amplitude surge, site 4/event 1, overlaps other sites.**
Its candidate interval is frames 116–135. Surge 3/1 overlaps frames 116–131;
surges 1/1 and 2/1 overlap portions of those same excluded frames. Frames 132–135
are clean. There is no same-site or sink overlap in this candidate interval.
Its large, evolving footprint spans recognizable tissue and the dim right
margin, reaching column 512. Its 8,329,233.31 µm²·s contributes **22.88% of all
surge covered area-time**, or **25.54% of unavailable-amplitude surge covered
area-time**. These are within-sign detected-coverage shares, not fractions of
all modeled tissue-time and not a cross-sign combined burden.

**Sink 1/1 is present when observation starts.** Its interior footprint already
has native support at frame 1, with no preceding samples. The preserved-input
trace rises during the observed interval, and the refined measurement end at
frame 27 differs from native end 18. Neither an earlier onset nor a pre-event
amplitude can be recovered from these data. Retain the existing descriptive
count and acquisition-start flag; a claim of a newly arising physiological event
requires an explicit onset/censoring decision.

The missing **event-local optical baseline** in these examples is distinct from
the experimentally established awake/isoflurane state before recording. The
[user's experimental clarification](../../BOI_C02_EXPERIMENTAL_CONTEXT.md) remains
in force: pre-recording state establishment was unmeasured, and an intrafile
isoflurane induction baseline is not required for an established-state comparison.

## Scientific disposition

| Question | Disposition from this review |
|---|---|
| Arithmetic defect in these amplitudes/baseline statuses? | No disagreement found in the selected independent source replay; retain current numerical outputs. |
| Are negative surges positive preserved-input optical excursions? | No: every event sample is below its recorded B0. Retain the detector label and signed value together, with the disagreement visible. |
| Can a clean baseline certify an isolated physiological transient? | No. The finite peripheral example demonstrates broad changing context; mechanism and event identity remain unresolved. |
| Can unavailable events be dropped from coverage? | No under the current definitions. Their native coverage remains measured and contributes materially. |
| Which marginal pixels are defensible anatomical support? | Defer anatomical acceptance. The automatic mask and existing unadopted outer-field proposals require a source/preparation-based decision. Darkness alone is insufficient. |
| Does frame-1 detection establish a new onset? | No. Preserve the existing descriptive result and boundary flag; scientific onset/censoring is still open. |

This closes the bounded six-case review. It does not initiate another baseline
search or method experiment. The next existing decision is anatomical support
and measurement-specific event admission, informed by these actual cases and
the [unadopted outer-field proposals](../boi-c02-outline-proposals-20260912/README.md).
A support change requires a versioned fresh workflow because it can change
candidate admission as well as the denominator. Old event numerators must not
be normalized by a newly proposed mask. No second mouse/state or paired C02
interpretation was run here.

## Researcher replay in MATLAB

The six figures use original full-frame geometry with first, middle and last
native frames. Orange is the **fixed union footprint**; cyan is the **native mask
at that exact frame**. White in the support panel is the existing automatic
included support. Source display limits remain [245,22493], inherited from the
earlier source review; they are display limits only and can conceal weak details.
Green trace points are clean baseline samples, red points are excluded candidate
baseline samples, magenta lines bound measurement time and the orange bar marks
native time. Traces use preserved-input intensity; no detrended trace substitutes
for the quantitative source. All six panels received [visual review](visual-review.json).

For interactive inspection, start in the `existing-analysis` repository folder
and use the existing [saved event viewer](../../BOI_EVENT_REVIEW_WORKFLOW.md):

```matlab
base = fullfile(fileparts(pwd), 'reference-validation', ...
    'boi-c02-workflow-20260912');
[fig, ui] = openBOIEventReview(fullfile(base, 'audit-01', ...
    'source-amplitude-audit', 'event-amplitude-audit.mat'));
ui.Select(246); % surge site 16/event 1; row in the combined saved audit
ui.AttachNative(fullfile(base, 'run-01', 'Recording', ...
    'OxygenSurges_Output', 'OxygenSurgesRecording.mat'));
```

The six combined audit rows are **1, 17, 220, 225, 246, 252** in table order above.
These differ from the sign-specific statistics row numbers in `selected-events.csv`.
For sinks, attach the saved sink master through **Attach native masks**. Choose
the saved 028 measurement dictionary when exporting review evidence. This is
the existing interface; no new viewer or claim of an independent researcher
walkthrough is introduced by this packet. The original audit's historical
master-checksum limitation remains as described in the viewer documentation.

For finite amplitudes, use `trace.csv` to calculate B0 from `CleanBaseline == 1`,
then q=(RawMean−B0)/B0 over `MeasurementWindow == 1`; take −min(q) for sinks or
max(q) for surges. If fewer than 20 clean samples are present, B0 and amplitude
remain unavailable. A shorter or earlier baseline is not an equivalent replay.

## Verification, resources and preservation

[Independent verification](verification.json) replays all 268 event area-time
rankings, their exact selection, the native masks against all 2400 saved sign/frame
unions, all **7200 selected footprint samples** from the original TIFF, all 18
displayed source/mask pairs and every selected baseline-overlap attribution.
The checks bind the original/staged source, saved statistics and audit to hashes;
all 461 existing MATLAB implementation files and the dictionary are unchanged.
Passing these checks establishes numerical/source traceability, not anatomical
validity, physiological identity, local motion absence or scientific acceptance.

The corrected MATLAB review took **24.48 s** inside the harness and **29.51 s**
process wall time, with **1.85 GiB** maximum process RSS. Independent Python replay
time and evidence size are recorded in [resource summary](resource-summary.json).
It reuses compact saved data and reads source frames without rerunning detection
or statistics. No new full-movie processing stack was created.

The first review export failed because MATLAB reserves `Row` as a table dimension
name. Its code, partial ranking/masks and logs are preserved. The corrected export
uses `NativeRow`/`NativeColumn` in a new `run-02` folder. The [failure record](failure-record.json)
documents this export-only correction; both attempts have identical rankings.
The [artifact record](artifact-record.json) binds local and portable evidence and
checks the prior 028 files without rewriting their dated records. The complete
executed harnesses, native replay MATs, selected source frames and logs remain
under local `reference-validation/boi-c02-event-review-20260912`.
