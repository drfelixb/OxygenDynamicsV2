# Four-recording detector revision: results and verification checkpoint

6 November 2026. All four recording runs, both preset configurations and all eight video/figure cards are delivered. **The detector remains unsuitable for adoption. Full independent numerical verification is incomplete:** the pooled checker reached the agreed 2 GiB limit after passing the two FB2413 configurations. Processing stops at that resource boundary, as specified in the [approved additional memory repair](BOI_VIDEO_DETECTOR_MEMORY_REPAIR.md).

Open the [local eight-card review](../../reference-validation/boi-video-detector-revision-20261106/review.html). It distinguishes the detector's label from whether its selected group actually follows the discussed episode. The page also flags an invalid recording-start diagnostic panel. The existing MATLAB GUI, CSV/batch/statistics/export workflow, burden formula, normalization and original results remain unchanged.

## Main findings

**The old search exclusions are resolved for these examples.** The revised domain retains valid dim observations and records signal confidence separately. All 57 blocks touching FB2413 site 3/event 6 and all 192 touching FB2412 site 20/event 1 are searchable. The first prototype admitted 57/57 and only 23/192 respectively. These are blocks touching old measurement footprints, not fractions of biological pocket area or validated anatomy.

The old FB2413 failure is now explained numerically: its maximum absolute score was 2.898, below both thresholds. Local scores reached 3.384; the lower threshold admitted six block/frame instances, but touching components were at most two blocks, below the four-block minimum. The revision removes that short-window component gate in favour of full-trajectory proposals at overlapping image scales.

**Proposal coverage does not yet become reliable episode identity.** The revised FB2413 primary produces 522 seed rows in the discussed 826–851 interval and footprint; sensitivity produces 573. Nevertheless, the selected groups follow the earlier trough at 794/796. These seed counts include repeated stages/scales and are not event counts. The important remaining loss is in defining/associating a distinct episode and its comparison cohort, rather than excluding the location entirely.

**Spatial extent remains essential.** FB2412 now produces evidence during the target interval, but the selected primary group follows a different period. One aligned alternative, `e000897`, has trough 171 and bounds 116–191, yet its fixed cohort covers 8,893 coarse blocks: 142,288 native pixels, about 54% of the full image. It is flagged for uncertain phase-chain identity. A second aligned alternative has 692 blocks and the same uncertainty. These do not establish clean isolation of a localized pocket. The automatic label alone is insufficient.

## Named comparisons

Selection was frozen before the comparison runs. It uses spatial-footprint Dice overlap plus target-interval overlap, without selecting an expected class. The fixed primary card can therefore expose an incorrect association rather than quietly show a better-looking alternative.

| Example and discussed interval | Primary selected group | Sensitivity selected group | Meaning |
| --- | --- | --- | --- |
| FB2413 site 3/event 6, 826–851 | Bounds 640–1094; trough 794; nominal local return 809–813 | Bounds 431–916; trough 796; nominal local return 819–823 | Both selected groups follow earlier activity. This is not successful isolation of the discussed pocket. |
| FB2317 long regional decline, 490–874 | Bounds 526–934; trough 629; persistent change, no return | Bounds 802–1116; trough 944; uncertain relative return | Primary retains a persistent interpretation. Sensitivity changes spatial/temporal identity and does not provide stable confirmation. |
| FB2412 site 20/event 1, saved 114–182 | Bounds 37–789; trough 320; raw decline insufficiently supported | Bounds 23–140; trough 133; raw decline insufficiently supported | Eligibility is fixed, but phase grouping/context selection remains poor. The primary context is 15–34, rather than the saved scientific reference 104–113. Neither changes that saved reference. |
| FB2319 site 7/event 2, rejected 45–51 | Trough 16; raw decline insufficiently supported | Trough 147; raw decline insufficiently supported | The selected proposals do not explain the named interval. The existing reviewed exclusion stays unchanged. |
| FB2412 site 1/event 1, recording start | Preceding state unavailable | Preceding state unavailable | Recognition remains incomplete and does not override the saved rejection. The native diagnostic panel has a separate rendering error described below. |
| FB2412 site 1/event 2, discussed 651–693 | Bounds 110–835; trough 802; nominal local return 826–830 | Bounds 633–704; trough 680; raw decline insufficiently supported | Primary associates different activity; sensitivity retains only a tiny uncertain cohort. Saved 651–693 and the shorter 659–672 preview retain their original distinct status. |

The target-seed group audit is retained in [anchor-stage-diagnostics.json](../../reference-validation/boi-video-detector-revision-20261106/anchor-stage-diagnostics.json). For FB2413, its one aligned primary group touches only one of the 57 old blocks and is uncertain. For FB2412, the audit exposes the large aligned alternatives rather than treating a selected-group mismatch as proof that no proposal exists. This audit is a comparison with old footprints and discussion timing, not biological ground truth.

The FB2317 comparison uses the footprint associated with original site 13/event 9. It does not relabel that later original event at 1174–1179 or change the separate site 13/event 5 exclusion.

## Implementation and coverage

The isolated [revision service](../prototypes/boi_video_detector/revision.py) searches every eligible image location through the full recording at three spatial scales, using raw and supplied denoised inputs. Absolute and local-differential trajectories remain separate. Valley and recording-edge evidence is generated before spatial-temporal association. Fixed pixel cohorts qualify raw decline and return; the evolving diagnostic mask cannot manufacture recovery by dropping dark pixels.

The prototype records incomplete boundaries, uncertainty, signal confidence, phase-chain ambiguity, comparison cohorts and full search accounting. Native support is a connected high/low evidence diagnostic on the review cards. There is no accepted full-event segmentation, scientific amplitude reference or burden input. Supplied denoised data is proposal evidence, not an adopted corrected stage or authority for raw recovery.

Full verified caches were reused for 4,778 frames per stage, raw and denoised, across four familiar recordings. Native source/cache parity was checked for every rendered source frame. These are development/regression examples, not independent validation. No other movie was analysed. No parameter tuning followed FB2412/FB2319 outcomes.

| Recording | Primary seeds | Primary groups | Sensitivity seeds | Sensitivity groups |
| --- | ---: | ---: | ---: | ---: |
| FB2413 | 1,370,100 | 21,039 | 2,341,927 | 12,871 |
| FB2317 | 997,519 | 21,877 | 1,995,543 | 18,233 |
| FB2412 | 1,437,427 | 23,846 | 2,434,667 | 16,760 |
| FB2319 | 1,274,585 | 20,740 | 2,344,175 | 16,560 |
| Total | 5,079,631 | 87,502 | 9,116,312 | 64,424 |

These are proposal/group counts, not biological pocket counts. The lower threshold adds seeds while reducing group count through connectivity and merging. That sensitivity itself is a limitation. The two identifier-selected unlabelled examples remain uncertain; they were not chosen as new accepted pockets.

## Memory repair and verification limits

Two synthetic repairs preceded recording evaluation. All 16 scenes satisfy geometry/scientific-isolation checks; all 15 stated primary recognition assertions and matched-cohort, missing-pixel, dim-tissue, native-gap and sampling safeguards pass. Constructed checks do not establish biological validity.

The initial combined FB2413 worker finished primary, then reached the 2 GiB guard during sensitivity. The researcher explicitly approved one additional memory-only repair: compact float64 seed buffers, a fresh process for each configuration, and verified equivalent time-contiguous input copies. Detection settings remained unchanged.

The repaired full FB2413 primary replay matches **all 1,370,100 seeds, all 21,039 candidates and phase values, all cohorts, grouping and coverage exactly**. Original primary files remain byte-identical. Temporary caches were checked field by field against originals, then removed and original pointers restored. The same primary worker fell from about 37.7 minutes to about 9.9 minutes; this is an operational storage/process comparison, not a MATLAB/Python benchmark.

All eight repaired processing workers completed below the 2 GiB cap. However, the pooled independent checker then reached 2,158,411,776 sampled RSS bytes after logging complete cohort and selected proposal-score/phase agreement for FB2413 primary and sensitivity. It was stopped and no final aggregate verification receipt was produced. The other six configurations' full independent replay remains **uncompleted**, not passed. A separate preserved primary checkpoint records every cohort, 123 independent scalar checks and seven proposal-score checks.

At this second resource boundary, no further detector or numerical repair was attempted. The agreed stopping condition is retained. [Final preservation checks](../../reference-validation/boi-video-detector-revision-20261106/preservation-final.json) match all 940 protected existing files, all eight full raw/denoised source hashes, the six original primary files and frozen numerical/selection code. The failed attempts and their receipts remain available.

## Review quality and known diagnostic error

All eight H.264 videos fully decode; three decoded samples per movie agree with the intended composites. There are 3,445 displayed frames and 3,459 native source/cache checks including context neighbours. All eight summary figures and two decoded examples were visually inspected; gallery links, anchors and JavaScript pass static checks. Live browser interaction is not claimed.

The **FB2412 recording-start native extent diagnostic is invalid**. Its renderer used only two preceding samples, yielding an unsupported noise estimate and exaggerated extent. Ignore that card's green boundary/native extent curve. Its raw images and trajectories remain useful, and the detector's incomplete-preceding-state result is retained. The error is disclosed in the gallery; no accepted area, baseline or burden used it. It was not silently corrected or rerun after the resource stop.

The compact FB2317 card ends at frame 1000; its numerical recovery search used all 1200 frames. The gallery links the previously delivered full 1–1200 raw-movie comparison for the remaining context. Other diagnostic boundaries can grow or fluctuate outside the selected episode, and cannot supply event area for burden.

## Preserved workflow and stopping decision

The burden formula, normalization support/exposure, event-specific scientific references, original recordings, automatic and reviewed results, existing exports and MATLAB source are unchanged. No scientific save, new burden, partial normalized sum or imputed zero was produced. Sink/surge separation is preserved. No package installation, production migration, GUI integration, Git transport or external publication occurred; findings remain local.

The recording comparison and media are delivered, while the milestone stops with **incomplete independent verification and unresolved scientific failures**. It is not marked fully accepted or production ready. The next discussion should centre on separating spatial episodes, choosing the relevant preceding state and distinguishing regional changes from local pockets. Further implementation, broader evaluation or adoption is a separate decision; no new phase starts automatically.
