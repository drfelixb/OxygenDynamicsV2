# Joint video-and-trace detector: results and keep/change assessment

9 November 2026. POCKET-VIDEO-DETECTOR-09, owner root, no delegation.
Experimental delivery; **not adopted in the MATLAB workflow or scientific exports**.

The frozen prototype completed twelve development recordings and all thirty
comparison views. It proposes local cycles at each of the four previously
recognized target locations, including FB2413. That is useful progress in
proposal coverage. It does **not** yet identify reliable complete pockets:
intervals can describe only the deep core, spatial supports are provisional,
and a window where the researcher saw no pocket still contains many proposals.
Do not use its proposed counts, intervals or footprints to calculate burden.

Open the [six comparison cards and existing movies](../../reference-validation/boi-video-joint-detector-20261109/review.html)
or the [overview image](../../reference-validation/boi-video-joint-detector-20261109/comparison-board.png).
The [comparison CSV](../../reference-validation/boi-video-joint-detector-20261109/candidate-comparison.csv)
is a detector diagnostic, **not** a replacement statistics or burden export.

## What was evaluated

The same frozen primary configuration scanned the full 128 × 128 cached raw
field of twelve recordings, comprising 14,378 supplied 1 Hz samples. Each block
is a 4 × 4 native-pixel mean. A prespecified comparison used the raw proposal
route alone with the same subsequent regional/local assessment. The primary
configuration also proposes cycles from local spatial comparisons. Neither
route uses the old saved correction as its decision signal. Existing native
512 × 512 movies and snapshots provide context; there was no new native
segmentation, original image decoding or video encoding.

Development recordings: FB2311, FB2317, FB2319, FB2402, FB2403, FB2405, FB2407,
FB2408, FB2410, FB2412, FB2413 and FB2419. The five reserved recordings
(FB2420, FB2316, FB2320, FB2404 and FB2406) had no new pixel/trace-array reads.
They are reserved for subsequent development decisions, not historically unseen
biological material.

Review authority remains four located positives, one positive-presence window,
three rejected targets, one no-pocket-seen window, one contested-timing view and
twenty unlabelled views. The new FB2410 judgment is recognition from the trace;
its spatial extent is unresolved. Old automatic intervals and discussion cues
are association markers, not exact timing truth. Weak window judgments do not
label every proposal or pixel. No sensitivity, specificity, false-positive
rate or independent biological accuracy is calculated.

## Located examples: coverage is not complete event detection

These counts are local-cycle proposals overlapping both the saved footprint at
coarse resolution and its timing marker. Several proposals can describe one
biological episode. They are not independent hits or event counts.

| Previously recognized target | Primary associations | Raw-route-only associations | Displayed primary proposal |
| --- | ---: | ---: | --- |
| FB2413 site 3/event 6 | 3 | 3 | 832–840, 30 coarse blocks |
| FB2412 site 20/event 1 | 2 | 2 | 117–169, 32 coarse blocks |
| FB2407 site 12/event 7 | 10 | 4 | 611–652, 45 coarse blocks |
| FB2410 site 66/event 2 | 1 | 1 | 682–702, 6 coarse blocks |

**FB2413:** the later dip is now represented, but the displayed 832–840 interval
is much shorter than the discussed approximately 826–851 episode. It describes
the deeper core rather than establishing the full decline and recovery. Its
return is explicitly relative to the fitted changing background. Frames
823–825 remain only a timing cue; the scientific measurement baseline is still
unresolved.

**FB2412:** the new 117–169 proposal uses a smaller, different cohort of pixels.
It does not reproduce the reviewed 114–182 interval of the original 2,511-pixel
event footprint. Those are different supports, so the discrepancy is not a
same-ROI timing-error measurement. The accepted baseline at 104–113 and recovery
at 182 remain unchanged. Surrounding responding tissue is not promoted to a
quiet measurement reference.

**FB2407:** the model captures a later, deeper component. The original trace
shows a longer decline and a rise around 660; 611–652 is not an accepted
whole-event duration. The ten competing associations also show the need to
give one coherent episode a stable identity.

**FB2410:** a small local dip is represented on a broader falling signal.
Recognition from its trace does not validate the six-block proposed support
as pocket area. Spatial extent and the interpretation of the broad decline
remain open.

The orange regional/drift prediction in the cards is a fitted counterfactual,
not measured oxygen background. It can follow slower parts of a decline and
thus leave only a shorter residual cycle. This is a plausible explanation of
the short intervals visible in these cards, not proof that the slower change
is non-biological.

## Recovery labels require care

The frozen algorithm proposes an endpoint when its fitted deficit is at most
25% of its depth, with a short-lag variation allowance, for three samples.
Its serialized `observed_raw_return` state also checks that the **later
after-flank** raw level has returned. It does not establish restoration at the
reported endpoint. The cards therefore say “later raw-level return; endpoint
model-based.” No numerical state, fit or threshold was changed for this label
clarification.

An observed later rise and a good fitted cycle are evidence for a proposal;
they are insufficient to assign a scientific recovery frame. Reported onset
and return ranges are conditional model alternatives, not confidence intervals.
This distinction prevents using an early model endpoint to shorten duration
and burden silently.

## Rejections, weak windows and catalogue size

The three previously rejected target markers—FB2317 site 13/event 5, FB2319
site 7/event 2 and FB2412 site 1/event 1—receive **zero local-cycle promotions**
at their saved location/timing markers in either configuration. Other proposals
exist in their surrounding clips. This does not establish whole-clip absence
or validated specificity.

| Researcher window judgment | Primary local proposals intersecting window | Fully contained | Crossing window boundary | Raw-route-only intersecting |
| --- | ---: | ---: | ---: | ---: |
| FB2402, 122–481: local pockets present | 2,295 | 1,914 | 381 | 1,518 |
| FB2419, 721–1080: no pocket seen | 63 | 41 | 22 | 49 |

The FB2402 presence judgment cannot validate 2,295 proposed locations or provide
a recall denominator. Its displayed proposal is selected by the fixed first-ID
rule, not because the researcher recognized that particular spot. It uses one
coarse block near a dark vascular structure and has unresolved onset; it is a
review example, not a confirmed pocket. Its 115–239 proposal starts before the
reviewed movie window. The card extends cached trace context to frame 51 and
labels the frame-301 native snapshot as orientation only.

FB2419 exposes the remaining discrimination problem. The 63 intersecting
proposals include 41 wholly within the displayed no-pocket-seen window and
22 crossing its boundary. They can overlap or fragment one change; **63 is not
a count of confirmed false biological events**. The fixed displayed proposal
690–751 begins before that window, lies near the tissue edge and is shown with
extended trace context from 595. Its native frame 900 is orientation only.
The geometric probe trace is not the trace of every proposed location and is
not an exhaustive negative label.

| Full development-catalogue diagnostic | Primary | Raw route only |
| --- | ---: | ---: |
| Seed proposals | 320,824 | 102,620 |
| Candidate records after initial consolidation | 128,931 | 57,939 |
| Classified as local-cycle candidates | 31,191 | 19,309 |
| Uncertain | 49,986 | 31,367 |
| Regional or persistent | 1,711 | 1,038 |
| Unsupported | 46,043 | 6,225 |

Both configurations cover the same four located positive targets. On those
four, the additional local route has no demonstrated coverage benefit while
increasing the catalogue substantially. Its value elsewhere is unresolved:
twenty views remain unlabelled, and there is no exhaustive pocket catalogue.
Do not infer that all added proposals are false, or that the raw-only route has
validated whole-field recall. Full association lists, recognition flags and
per-recording proposal rates remain available for inspecting competing,
overlapping, split or merged alternatives.

## Engineering checks and practical limits

Twenty predeclared constructed scenes pass on the third and final execution
after two pre-freeze numerical repairs: sixty scene executions total. They
exercise regional changes, local cycles, flat troughs, unequal decline/return,
recurrence, truncation, dim signal, displacement and changing observations.
They test declared software behavior, not biological truth. One numerical
implementation and settings manifest froze before recording arrays were read.

All twelve primary and twelve raw-route-only passes completed in 25 recording
attempts. One earlier capacity stop is preserved; its approved ledger increase
did not change scientific settings, and the initial four completed outputs
remain byte-identical. There was no recording-specific retuning.

The [independent checks](../../reference-validation/boi-video-joint-detector-20261109/independent-verification.json)
cover all 24 input/domain ledgers and all thirty source-coordinate/association
lists. The fixed selection rule replays twelve saved records plus twenty
constructed outputs without another detector fit. Twenty-six contain score
arithmetic; others verify zero/censored coverage. Independent isotonic
interval-mean arithmetic checks phase/model scores, complexity, short-lag
variation, geometry and fixed-cohort returns. There are 533 scalar comparisons,
with maximum relative difference about 1.76 × 10⁻¹⁴. Conditional nuisance
predictions are checked from their serialized coefficients; numerical optimizer
optimality is not independently re-proved. The checks do not validate a
background as a biological control or provide independent detection accuracy.

The initial table reporter exceeded the 2 GiB guard at approximately 2,056 MiB
and stopped; that failed attempt is preserved. The approved reporting-only
repair streams metadata without changing the frozen numerical files or saved
pass outputs. Its six guarded workers completed, including presentation wording
corrections, under the same 2 GiB cap. No detector was rerun for reporting.
Four batches, two numerical repairs and one reporting repair were used. Final
resource/preservation accounting is recorded in the
[delivery verification](../../reference-validation/boi-video-joint-detector-20261109/verification.json).
Successful recording workers peaked at about 2,008 MiB; the streaming reporting
workers peaked at about 806 MiB. Derived evidence is about 265 MiB, below the
512 MiB ceiling. All 2,640 protected input hashes, fourteen frozen numerical
files, sixty saved-pass artifacts and twelve original recording hashes/file
statistics match. The two earlier boundary stops remain part of the record;
their failures are not erased by successful completion.

All six cards and their overview image were visually inspected. Local assets,
links, source identities and preserved hashes were checked. Live browser
interaction was not verified: the local-file browser route was blocked, and
no alternate route was used. Two inherited compressed movies, FB2412 site
88/event 2 and FB2419 site 27/event 2, remain flagged with original snapshots;
the six expanded cards reuse movies that passed the earlier compression checks.

## Keep, change and stop

Keep full-field raw proposals, finite dim observations, explicit missingness,
fixed-pixel comparison traces, flexible cycle shapes, regional/local competing
explanations and complete context. Preserve separate recognition and measurement
readiness. These are useful design elements rather than proof of a finished
detector.

Before production, event identity must be consolidated across scales and nearby
proposals; complete onset and sustained raw recovery must be assessed on a
coherent spatial support; and vascular/edge activity and responding regional
tissue must be distinguished without declaring a changing surround to be a
quiet control. A scientific measurement reference and native area require their
own evidence. Another threshold adjustment on only FB2413 and FB2412 would not
resolve these requirements.

This experiment is delivered and stopped. No production detector, MATLAB
integration, new five-recording test or further diagnostic campaign is active.
The next decision is to review the six cards and agree which episode-identity,
boundary and spatial-support requirements a subsequent bounded revision must
meet before using the reserved recordings.

The burden formula, normalization, strict complete-contribution rule, original
recordings/results, reviewed decisions/references, source-specific tissue
support, sink/surge separation, workbook formats and existing exports remain
unchanged. Every new proposal remains measurement/burden-unready. No partial
sums, imputed zero area, new amplitude or scientific totals were produced.
