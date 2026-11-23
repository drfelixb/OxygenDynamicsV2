# Build a broader video benchmark before revising detection again

9 November 2026. Proposed milestone **POCKET-VIDEO-DETECTOR-08**. Owner: root,
without delegation. Planning only; implementation has not started.

## Why the next step must be broader

The researcher asks to see the two current cards, understand the remaining
failures and plan a better approach with more examples. The most recent
iterations have indeed been limited to two recordings. Nine signal channels
and sixty perturbation runs are not nine or sixty independent pocket examples.

Reuse the work already completed: the [recording-wide catalogue](BOI_PATTERN_DISCOVERY_FINDINGS.md)
contains 5,407 old automatic sink candidates across all seventeen recordings.
The [initial video prototype](BOI_VIDEO_DETECTOR_PROTOTYPE_RESULTS.md) processed
four complete movies. Those candidates are not biological truth, and the
systematic comparison windows are unlabelled, not confirmed negatives. The
latest [scoring experiment](BOI_VIDEO_CANDIDATE_SCORING_RESULTS.md) did not
retest its decision across that broader material.

Retain the known examples as regression anchors. Stop treating them as the
main evidence that a proposed detector generalizes. Do not choose another
threshold from these same two pockets and then call repeat perturbations
independent validation.

## The two current failures

FB2413 has an earlier trough near 794, a rise, and a later trough near 837.
The new graph puts the later decline/return into post/context rather than a
separate episode. Its strongest decoded cycle is the earlier one: drop 193.14
input units versus a required 222.32 at the final context scale of 74.11.
The reported innovation scale is 13.09. The context allowance can include
structured tissue activity; it has not established independent measurement
noise. Lowering the final cost-gain gate cannot create the missing later phase
allocation. The 193.14 value is not the later pocket's scientific amplitude.

For the FB2412 target, diagnostic raw contrast is 37.53, above its required
33.22; the core-local contrast is 23.70, below its required 31.39. Regional
subtraction reduces the observed dip while the residual variability allowance
remains similar. These are the prototype's recognition contrasts, not revised
scientific amplitudes or burdens. The loss of support is not independent
biological rejection. A real shared component may be removed by subtraction;
the saved calculation does not establish whether that is appropriate.

Both failures concern representation of tissue variation and competing spatial
explanations. They do not justify another final-cutoff adjustment. Recognition,
measurement-reference suitability and complete burden availability must remain
separate.

## Proposed next delivery: a finite, diverse video benchmark

Use the existing seventeen-recording source inventory. The next implementation
would prepare evidence on the existing **twelve development recordings**:

FB2412, FB2413, FB2419, FB2311, FB2317, FB2319, FB2402, FB2403, FB2405,
FB2407, FB2408 and FB2410.

Keep **FB2420, FB2316, FB2320, FB2404 and FB2406** reserved for evaluating a
later frozen detector. Do not inspect new holdout pixels, select holdout cases,
tune on their traces or expose their new outcome cards in this benchmark
milestone. The split is inherited from the earlier discovery pass, not newly
optimized. These recordings were used in older analysis/exports, so they are
reserved from this new development, not historically unseen biological data.
Check available animal/session metadata and keep related recordings together;
if grouping conflicts with the inherited split, record the conflict and pause
before changing membership. Do not infer independent animals from filenames.

Prepare **at most thirty whole-episode cases**:

- Six existing anchors: FB2413 site 3/event 6; FB2412 site 20/event 1;
  FB2317 site 13/event 5; FB2319 site 7/event 2; FB2412 site 1/event 1; and
  the FB2412 site 1/event 2 longer/shorter-interval discussion.
- Twenty-four new views, two per development recording: one drawn from the
  old candidate catalogue with duration/size diversity, and one full-field
  time window selected independently of the old detector and its ROIs.
  The latter can reveal activity at locations the old detector never saved.

Freeze the source registry, deterministic sampling rule, seed and case quotas
before new pixels are loaded. Use existing metadata to span small/large,
short/long, quiet/changing and recurrent/edge contexts. Candidate membership
and coarse size are sampling descriptors, not pocket labels. Avoid duplicate
views of the same overlapping episode. Retain reasons for unavailable or
ambiguous cases; do not replace them to improve the apparent success rate.

Default views should include several minutes around the episode and a full
recording overview. Extend a view when needed to show an earlier rise or later
return, within the recording and total frame budget. If that context cannot be
shown, label it incomplete. Preserve capillary gaps and dim valid tissue;
do not invent anatomical tissue masks or treat excluded pixels as zero area.

Each card should show the raw full field, fixed-location trajectories, saved
correction where a matching original footprint exists, spatial extent through
time, surrounding tissue and observed return. Reuse the four existing coarse
movie caches after identity checks. Stream the eight additional development
raw movies; do not copy the TIFFs or refit the production correction. Show
native-resolution playback for the selected clips so coarse averaging cannot
silently decide a boundary. The new systematic full-field clips do not receive
an invented saved corrected ROI trace.

The FB2317 regional movie previously used an event-9-associated footprint;
do not present it as the site-13/event-5 footprint. The FB2412 longer-pocket
display also has historical event-2/event-3 footprint distinctions. Verify and
label the actual source/revision for every anchor. The saved 651–693 interval
and the 659–672 preview remain separate scientific records.

## Researcher review and benchmark labels

Deliver all thirty cards and a compact first board of at most twelve varied
examples. Use whole-episode judgments: **pocket, regional/persistent change,
no pocket, or uncertain**, with a separate note on observed local return and
approximate extent. These judgments need no exact onset second, hand-drawn
boundary or scientific baseline decision. Unreviewed cases remain unlabelled.

Existing scientific judgments are carried forward as provenance, not overwritten.
New benchmark judgments live in a separate versioned file and do not modify
automatic results, saved review revisions or exports. Do not call old detector
outputs positive truth, systematic samples negative truth, or uncertainty an
error-free detection. The initial deliverable is a reviewable benchmark, not a
complete biological gold standard.

Only reviewed, adequately observed cases can later support recognition
comparisons. Uncertain and unreviewed counts stay visible. Recall for a whole
field can only be claimed within clips that have been reviewed exhaustively;
checking selected old ROIs does not establish whole-image sensitivity.

## Direction for the subsequent detector, not yet implementation scope

After the benchmark review, write a concrete detector specification using the
observed range of patterns. The intended direction is:

1. Propose complete spatial-temporal changes at several durations/scales from
   the raw video. Keep flat troughs, asymmetric recovery, recurrence and incomplete
   recording edges. Size, occupied field fraction, surrounding response and
   recovery belong in the evidence together. Do not impose one universal maximum
   pocket size or infer artifact merely because a response is shared.
2. Distinguish fast observation variability from structured capillary/tissue
   activity and slower regional changes. Do not let a missed episode silently
   become calibration noise. Any usable context or nuisance prediction needs
   checks outside the proposed pocket and an unresolved outcome when unavailable.
3. Compare a regional-change explanation with regional change plus a local
   episode using both space and time. Keep responding surrounding patches as
   responding evidence, not quiet controls. A local pocket can coexist with a
   regional response. Local correction should supply additional evidence and
   model uncertainty, rather than a mandatory veto on a raw/video candidate.
4. Infer recognition and approximate timing before asking whether the scientific
   amplitude reference, recovery and area are adequate for burden. A recognized
   pocket may legitimately have unavailable burden. Do not adopt a three-frame
   peak or invent a recovered baseline to complete a sum.
5. Freeze one detector specification and settings after development; evaluate
   the five reserved recordings once without retuning. Compare reviewed misses,
   false candidates, regional/local confusion, extent and timing uncertainty,
   with denominators limited to the reviewed material. Keep software checks
   separate from biological acceptance. Failure on those recordings is reported,
   not repaired and then re-described as an untouched test.

This benchmark milestone includes **zero new detector fits or parameter sweeps**.
The joint detector and reserved-recording evaluation require a subsequent
bounded implementation proposal informed by this broader evidence. Python remains
an offline evidence tool; MATLAB production integration and final platform
selection are deferred.

## Bounded work items and acceptance

| Item | User benefit and scope | Acceptance and stop |
| --- | --- | --- |
| VBENCH-01 | Root: register all seventeen sources and preserve the 12/5 split; pin source/review identities and sample rules. | Disjoint source registry, exact original-ROI identities and before/after hashes; no holdout pixel reads. Stop for conflicting sampling/source/animal metadata. |
| VBENCH-02 | Root: prepare full development overviews and thirty whole-episode video cases using existing caches plus streamed raw movies. | Full-field views include dim valid tissue and native playback; no cropped apparent recovery or fabricated zero area. Stay within twelve sources and frame/resource caps. |
| VBENCH-03 | Root: produce the diverse board and a separate unlabelled/review-state manifest. | Six anchors plus twenty-four new views, deduplication and selection provenance; no invented biological labels or frame-by-frame mandatory review. |
| VBENCH-04 | Root: independent source/frame/coordinate checks, visually checked cards and a detector-requirements summary. | Six finite QA checks below and preservation receipt. Deliver the benchmark and stop before another detector implementation. |

Six QA groups: source/split identity; inherited-cache byte/hash identity; native
versus coarse means and frame/coordinate agreement on 96 declared samples;
case/selection and anchor-ROI provenance; complete playable media plus missing/
edge-state handling; and original scientific/source preservation with review-state
separation. These are engineering checks, not pocket-recognition tests.

Proposed ceiling: **eight active engineering hours, four batches, twelve
development raw movies, thirty cases, at most twelve cases on the initial
review board, two engineering repairs, 2 GiB memory per worker and 2 GiB new
derived evidence**. No package installation or delegation. Read development
raw images at most twice per unique source frame, including cache/native clip
preparation and verification, and create at most 12,000 new native clip frames.
Frame totals must reconcile with existing source metadata before processing.
Hashing source bytes does not decode images. No new denoising, motion correction,
full-resolution segmentation, accepted area or detector model fit is included.

The four batches cover registry/sampling, development evidence preparation,
cards/review manifest, and verification/requirements/closeout. This is a fixed
software benchmark, not a cohort reanalysis or experimental group comparison.
Report actual time, resource use, missing cases and failed checks. Stop at any
source/resource/effort/repair boundary with a preserved checkpoint; no silent
expansion or replacement of difficult examples.

## Scientific preservation and approval

Keep the burden formula, normalization, strict complete-contribution rule,
event-specific scientific references, sink/surge separation, original recordings,
automatic results, saved review decisions, combined workbooks, exports and MATLAB
workflow unchanged. Compute no new accepted amplitude, area, contribution,
partial burden or recording total. The accepted FB2412 original-ROI baseline
104–113 and timing 114–182 stay saved; FB2413's measurement baseline remains
unresolved. Findings remain local; no Git transport or publication.

The researcher has authorized this planning, not the new movie processing.
[AGENTS.md](../AGENTS.md) requires: “Before implementation, obtain approval for
the milestone and its bounded work items.” Approval of the scope above is needed
before loading additional image pixels or building this benchmark. Deferring it
leaves the current cards, detector and all scientific outputs as they are.


## Approval record

The researcher approved this bounded benchmark on 9 November 2026: “I approve the broader benchmark plan.” The five reserved recordings and all scientific results are protected. The proposed text above is retained as the reviewed scope.


## Delivery at quality checkpoint

Thirty cases and native movies are prepared, with a twelve-view starting board. Source/coordinate checks pass; two compressed previews fail the unchanged quality tolerance and are flagged with snapshots. All twelve starting-board movies pass. The benchmark stops at this explicit quality checkpoint after the approved second rendering repair. [Results and limitations](BOI_BROAD_VIDEO_BENCHMARK_RESULTS.md) and [review board](../../reference-validation/boi-broad-video-benchmark-20261109/review.html) are delivered. Scientific results were not recalculated or overwritten; reserved recordings have no new pixel or trace-array reads. No further implementation is active.
