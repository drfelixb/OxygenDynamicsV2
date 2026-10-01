# C02 focused sequence review

12 September 2026 — **R1-C02-SEQUENCES-026: six-interval review complete; no justified frame exclusion established.**

The flagged ID402/ID403 sequences retain recognizable vessel and field structure.
This review does not establish a coherent landmark jump corresponding to the
larger estimates in [the all-frame diagnostic](../boi-c02-temporal-20260912/README.md).
At ID403 awake frame 546, the 3.664-pixel estimate against frame 1 contrasts with
0.057 pixels against the preceding frame. Reference-dependent estimates must not
be interpreted directly as measured motion. Fine motion, local optical changes
and full-recording validity remain unresolved.

FB2315 awake retains recognizable vessel geometry through its brightness change.
Appearance changes are preserved without assigning an acquisition or biological
cause. No frame is excluded, no mask is adopted, and no analysis window is
approved. The scope remains BOI only, preserving both signs and biological
variability. The established-state [experimental context](../../BOI_C02_EXPERIMENTAL_CONTEXT.md)
remains unchanged; no stabilization duration or intrafile induction baseline is
invented.

## Exact review context

The prespecified intervals cover each prior target ±5 frames; overlapping
ID402 intervals around 503/505 are merged. These six clips contain 68 distinct
source frames. Adding each source's first frame yields 71 unique extracted frames.
The external trigger is exactly 1 Hz: time in seconds = original frame − 1.
These are **review clips**, not experimental analysis windows.

Three fixed 96×96 native ROIs per recording were chosen from already viewed
source sheets before loading the additional frames. They cover visible vessels
and peripheral structure, and are visual aids rather than tissue masks.
The review is not blinded. No source registration, smoothing, temporal averaging,
per-frame normalization or adaptive ROI selection was applied. Display limits
remain [0,255] for ID402/ID403 and [252,25824] for FB2315, inherited from 021/025.
The crop canvas uses 2× nearest-neighbour replication before figure export;
viewers may rescale a figure. Exact native integer pixels remain available.

| Recording | Original frames | Every frame at fixed landmarks | Full source before / target / after |
|---|---|---|---|
| M402-01-baseline-awake | 310–320 | [ROI 1](M402-01-baseline-awake/frames-0310-0320/ROI-1.png) · [ROI 2](M402-01-baseline-awake/frames-0310-0320/ROI-2.png) · [ROI 3](M402-01-baseline-awake/frames-0310-0320/ROI-3.png) | [f315](M402-01-baseline-awake/Target-0315.png) |
| M402-01-baseline-awake | 498–510 | [ROI 1](M402-01-baseline-awake/frames-0498-0510/ROI-1.png) · [ROI 2](M402-01-baseline-awake/frames-0498-0510/ROI-2.png) · [ROI 3](M402-01-baseline-awake/frames-0498-0510/ROI-3.png) | [f503](M402-01-baseline-awake/Target-0503.png) · [f505](M402-01-baseline-awake/Target-0505.png) |
| M403-01-baseline-awake | 264–274 | [ROI 1](M403-01-baseline-awake/frames-0264-0274/ROI-1.png) · [ROI 2](M403-01-baseline-awake/frames-0264-0274/ROI-2.png) · [ROI 3](M403-01-baseline-awake/frames-0264-0274/ROI-3.png) | [f269](M403-01-baseline-awake/Target-0269.png) |
| M403-01-baseline-awake | 445–455 | [ROI 1](M403-01-baseline-awake/frames-0445-0455/ROI-1.png) · [ROI 2](M403-01-baseline-awake/frames-0445-0455/ROI-2.png) · [ROI 3](M403-01-baseline-awake/frames-0445-0455/ROI-3.png) | [f450](M403-01-baseline-awake/Target-0450.png) |
| M403-01-baseline-awake | 541–551 | [ROI 1](M403-01-baseline-awake/frames-0541-0551/ROI-1.png) · [ROI 2](M403-01-baseline-awake/frames-0541-0551/ROI-2.png) · [ROI 3](M403-01-baseline-awake/frames-0541-0551/ROI-3.png) | [f546](M403-01-baseline-awake/Target-0546.png) |
| FB2315-baseline-awake | 415–425 | [ROI 1](FB2315-baseline-awake/frames-0415-0425/ROI-1.png) · [ROI 2](FB2315-baseline-awake/frames-0415-0425/ROI-2.png) · [ROI 3](FB2315-baseline-awake/frames-0415-0425/ROI-3.png) | [f420](FB2315-baseline-awake/Target-0420.png) |

Landmark locations: [ID402](M402-01-baseline-awake/LandmarkMap.png),
[ID403](M403-01-baseline-awake/LandmarkMap.png),
[FB2315](FB2315-baseline-awake/LandmarkMap.png).

**M402-01-baseline-awake, frames 310–320:** Upper transverse, right curved and lower vessel structures remain identifiable across every inspected crop. Brightness and grain vary. No clear coordinated landmark jump is established at frame 315. Fine motion cannot be ruled out.

**M402-01-baseline-awake, frames 498–510:** The three vessel structures persist across the interval, including frames 503 and 505. Local texture and brightness change without a clearly established coherent displacement or loss of the field. The 503 adjacent-reference estimate and change in fixed-reference estimates disagree; a rigid-motion interpretation is unresolved.

**M403-01-baseline-awake, frames 264–274:** The broad transverse vessel, left edge and lower perimeter remain recognizable around the minimum-score frame. The grainy, low-contrast appearance does not supply a reliable fine-displacement measurement. No observation-loss event is established.

**M403-01-baseline-awake, frames 445–455:** Vessel and perimeter locations persist through the selected frame; brightness/texture change. No clear coherent jump is established by the fixed crops or before/at/after full frames. The apparent correction depends on reference choice.

**M403-01-baseline-awake, frames 541–551:** All three landmark regions remain recognizable through frame 546. The fixed-reference magnitude is 3.663853 pixels while the adjacent-reference magnitude is 0.056537 pixels; the fixed-estimate change is 3.730457 pixels. This inconsistency and the visual sequence prevent interpreting the fixed-reference outlier as a demonstrated frame-to-frame jump.

**FB2315-baseline-awake, frames 415–425:** The middle and lower vessels and right field structure persist across the clip. Brightness and local appearance change through 420 and neighbouring frames; some structures appear more diffuse, without a demonstrated coherent geometric jump. Biological signal, optical/focus effects and residual motion are not separated by this review.

## What the estimates establish

[TargetContext.csv](TargetContext.csv) retains fixed and adjacent magnitudes and
the change in fixed-reference x/y estimates across each selected transition.
The Euclidean difference between that change and the adjacent-reference correction
is a descriptive check of reference consistency under a rigid-translation model.
It was calculated after visual review from preserved 025 outputs; no registration
was rerun and no cutoff was introduced. See the [formula and limits](target-context-method.json).
Disagreement does not determine which estimate is correct, identify a cause, or
prove absence of motion. It makes an unqualified physical-motion interpretation
unsupported by these estimates alone.

The scientific review used all 18 ordered crop sheets, three landmark maps and
seven full-frame triptychs. It did not manually watch all 7,200 frames or quantify
landmark coordinates. Broad structure persisting is useful evidence but cannot
certify fine motion, focus, anatomy or every measurement's observability.
The [structured observations](visual-review.json) retain these limits and all
unresolved interpretations.

## Review the preserved frames in MATLAB

This packet includes [reviewSequence.m](reviewSequence.m) and each recording's
`SourceFrames.mat`. From this report directory in MATLAB, run:

```matlab
reviewSequence('M402-01-baseline-awake')
```

Choose a clip, step through original frames or play with a nominal one-second
interval. Frame 1 stays visible beside the current full frame and its three
fixed crops. Playback stops at the end of the chosen clip and never bridges a
recording gap. MATLAB timer scheduling is approximate; labels always use the
exact original 1 Hz frame grid. The viewer writes no decisions or source files.
It is a study-specific evidence viewer, not a replacement for the main MATLAB
researcher workflow. Full-frame native arrays and exact-value PNGs are retained
for independent inspection; raw integer PNGs may appear different in generic
viewers because their display mapping is not the study mapping.

## Verification, feasibility and preserved attempts

The successful MATLAB extraction/render pass took **42.953 seconds**. The first
attempt saved FB2315 frames, then failed because JSON display limits were a
column vector where `imagesc` expected a row. The failed code, partial output and
log remain in local `run-01`; `run-02` corrects vector orientation without changing
source pixels, planned intervals, ROIs or display values. Existing TIFF XMP-tag
warnings were logged. No source header was edited.

Independent Python replay verified all **18,612,224 native pixels** in the 71
preserved MAT and PNG frames against their TIFF pages, original frame/time indices,
prior independently checked whole-frame sums, ROI coordinates and all three
source checksums. All 460 existing implementation files remain unchanged.
See [verification](verification.json) and [source summary](summary.csv).

The MATLAB viewer's slider, clip selection, playback advance and timer cleanup
passed for all three recordings: [viewer checks](viewer-verification.json).
Its [axes preview](ViewerAxesPreview.png) was visually inspected; MATLAB omitted
UI controls from that export, so it is not a full screenshot of the interface.

## Consequence for the reanalysis

The focused review is complete with **no supported frame exclusions from these
flags**. That is not a declaration that all frames are valid. Do not keep tuning
registration or selecting new crops merely to force a binary answer. Additional
anatomical/acquisition evidence or a separately justified landmark-validation
method would be needed to resolve fine-motion or weak-boundary claims.

The next useful step is to consolidate the existing source, support and temporal
evidence into measurement-specific R1 decisions: which quantities require a
justified tissue denominator or valid exposure, which choices remain scientific,
and what can proceed as clearly labelled descriptive analysis. In particular,
ID402 iso boundary uncertainty remains unresolved by this awake-sequence review.
Keep proposed masks unadopted and preserve all source indices. Any eventual
support change enters a fresh stage, and demonstrated invalid frames must be
handled without deleting or renumbering the original time grid.

The [artifact record](artifact-record.json) binds this report, local execution
records and preserved preceding 025 artifacts. Neither this review nor passing
numeric checks assign scientific eligibility, an untouched evaluation role,
physiological truth or a final measurement definition.
