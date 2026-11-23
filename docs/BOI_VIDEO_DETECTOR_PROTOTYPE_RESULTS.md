# Video detector prototype: delivery and limitations

6 November 2026. POCKET-VIDEO-DETECTOR-01 is delivered as an experimental Python service and local review, then stopped. It is **not ready to replace the current detector**. The four-recording implementation completes the [approved scope](BOI_VIDEO_DETECTOR_PROTOTYPE_PLAN.md), including explicit misses and uncertainty; completion does not mean biological acceptance.

Open the [eight whole-episode movie and figure cards](../../reference-validation/boi-video-detector-prototype-20261106/review.html). Start with the discussed FB2413 pocket, the long FB2317 decline, and FB2412 site 20/event 1. Each card provides the raw field, fixed-pixel trajectories, surrounding signals, evolving support and qualified native contrast. Playback is five times the supplied 1 Hz acquisition rate. No new frame-by-frame decisions are required to inspect the comparison.

## What the four recordings show

| Previously discussed example | Primary result | Prespecified sensitivity result | Interpretation and limitation |
| --- | --- | --- | --- |
| FB2413 site 3/event 6, around 826–851 | No overlapping proposal | No overlapping proposal | **Missed.** All 57 of 57 coarse blocks touching the old footprint are eligible. The failure occurs in proposal generation/association, rather than exclusion by the quality mask. Prior discussion timing remains provisional. |
| FB2317 long regional decline | Persistent local or regional change | Relative return only, uncertain in a changing field | The primary match does not manufacture recovery from a declining background. Raw intensity continues falling through the recording. Only 46 of 126 blocks touching the comparison footprint are eligible; tracking represents a narrow edge, not the whole darkening region. The sensitivity match is a different track and does not restore the preceding raw state. |
| FB2412 site 20/event 1, saved 114–182 | No overlapping proposal | No overlapping proposal | **Missed, with a major eligibility problem.** Only 23 of 192 old-footprint blocks are eligible. Dim tissue is removed by the experimental signal-quality rule. This is not evidence that the saved pocket is absent. |
| FB2319 site 7/event 2, previously rejected | Raw decline insufficiently supported | Same status | The selected proposal is not promoted to a recovered local candidate. This does not establish specificity for the rest of the movie. The existing reviewed exclusion remains unchanged. |
| FB2412 site 1/event 1, recording start | Preceding state unavailable | Same status | Missing pre-recording evidence remains explicit. It does not overturn the researcher's saved rejection or adopt a post-recovery measurement baseline. |
| FB2412 site 1/event 2, extended discussion interval | No overlapping proposal | Raw decline insufficiently supported | No reliable recovered local proposal. All 58 old-footprint blocks are eligible. Saved 651–693 and the shorter 659–672 preview keep their existing separate status; neither receives new area or burden. |

The FB2317 long experimental proposal is compared using the footprint associated with original site 13/event 9. It does **not** relabel that original later event at 1174–1179, or change the separate site 13/event 5 exclusion.

Two additional cards use identifier-based systematic selection rather than an expected biological label: a local reversible candidate in FB2413 and an uncertain proposal in FB2319. They are examples for inspection, not newly accepted pockets.

The next detector decision should address **two different failures**: which pixels are allowed into the search, and how proposals are generated within eligible tissue. Simply lowering the threshold did not recover the two important missed examples. Native contrast extent also changes strongly with threshold and can spread after the fixed-pixel local signal has recovered. These maps cannot currently provide biologically accepted event area.

## What was implemented

The isolated [service](../prototypes/boi_video_detector/service.py) provides `Settings`, `build_evidence`, `detect` and episode assessment. It receives source-bound time × row × column block means and returns experimental proposals, fixed comparison footprints, per-frame tracked support, context evidence, contact/identity uncertainty and a complete frame/domain coverage ledger. It has no connection to the scientific burden exporter.

The full 512 × 512 field is represented by 4 × 4 native-pixel blocks. Raw and supplied denoised inputs generate proposals at three spatial scales and two preceding-context lengths. Absolute decline and local differential decline are separate proposal channels. Connected regions are tracked with overlap, limited gaps and displacement alternatives; split/merge contacts remain explicit. The primary threshold is four empirical noise units; the sensitivity threshold is three, with all other settings fixed. Exact settings are recorded in [choices.json](../../reference-validation/boi-video-detector-prototype-20261106/choices.json).

The experimental search mask requires sufficient raw signal and finite observations. It is **not** validated anatomy, accepted tissue support or the denominator for normalization. Its exclusion of dim tissue is a demonstrated limitation, particularly for FB2412 site 20 and the darkening core in FB2317. Gray pixels in the movie contrast view mean excluded or unavailable, not zero pocket area.

Recovery is assessed using a fixed comparison pixel cohort. Losing darker pixels from an evolving mask cannot by itself create recovery, and a missing cohort pixel makes that frame's cohort mean unavailable. Nearby, distant and field trajectories remain separate. Observed raw rise, restoration of the preceding raw state and relative local return are distinguished. A proposed return occurring long after tracked spatial support ends carries an unresolved spatial-gap notice. Display/context references do not become scientific amplitude baselines.

Motion-like displacement is flagged using image correlation; images are not motion corrected. Irregular support and vascular gaps are retained. No capillary anatomy is inferred from brightness. Coarse extent in pixels and conditional physical extent at the supplied calibration remain diagnostic values, not accepted pocket measurements.

## Coverage, frozen comparisons and outputs

All four raw and all four supplied denoised TIFFs were hash/header checked and decoded in full: 4,778 recording frames, or 9,556 input images across the two stages. Source axes and sampling were reconciled with saved evidence; selected old native-footprint means matched the raw source for every frame, with maximum absolute error below 1e−8.

FB2413 and FB2317 were the development examples. Numerical implementation, settings and selection rules were frozen before processing FB2412 and FB2319. They are frozen transfer comparisons, **not independent biological validation**: all four recordings were familiar and belonged to the earlier development partition. The other 13 movies were not analysed in this milestone. No retuning followed the comparison misses.

| Recording | Frames | Primary proposals | Sensitivity proposals |
| --- | ---: | ---: | ---: |
| FB2413 | 1,178 | 738 | 1,913 |
| FB2317 | 1,200 | 1,374 | 3,049 |
| FB2412 | 1,200 | 728 | 1,449 |
| FB2319 | 1,200 | 1,499 | 3,938 |
| Total | 4,778 | 4,339 | 10,349 |

These are **proposal counts, not biological event counts**. Channels, scales and tracking alternatives can duplicate an episode; identity changes with threshold. The large catalogue has not been biologically labelled, consolidated into unique pockets or converted into sensitivity/specificity estimates. Coverage includes explicit quality exclusions and tiny-component accounting, not a capped shortlist.

Evidence lives in [the local prototype directory](../../reference-validation/boi-video-detector-prototype-20261106/). Each recording has an immutable input cache, quality maps and per-configuration `catalogue.json.gz`, `tracks.json.gz`, `contacts.json.gz`, `tracking.npz`, `comparison-masks.npz` and a receipt. Authoritative FB2413 outputs are in `recordings/FB2413/parity-primary` and `parity-sensitivity`; the first outputs remain for exact memory-repair parity. Other recordings use `primary` and `sensitivity` directories. Frames are one-based; native linear pixel conversion follows MATLAB column-major convention. Comparison-mask indices are coarse row-major indices and must not be mistaken for native indices.

## Verification and practical limits

- The [synthetic test module](../tests/analysis/testBOIVideoDetectorPrototype.py) covers 16 named scenes. Geometry/coverage and scientific-isolation invariants pass for all 16; 14 of 14 stated primary-configuration behaviour assertions pass. Fixed-cohort changing-mask and missing-pixel safeguards, native coordinates and sampling conversion pass. Weak/gradual signals and recurrence without intervening recovery are included without a passing recognition assertion; their correctness is not established. These checks do not validate biological boundaries or the sensitivity configuration's recognition performance.
- [Independent verification](../../reference-validation/boi-video-detector-prototype-20261106/independent-verification.json) passes 19,112 mask/frame checks, 461 scalar checks, geometry/context replays and 42 native diagnostic-mask samples. All 1,628 movie source frames match the frozen coarse caches. All eight videos fully decode and decoded samples agree with intended composites. All eight summary figures and two decoded movie examples were visually inspected. Gallery asset links, card controls and JavaScript receive static checks; live browser interaction is not claimed.
- All eight full source hashes match after processing. All 684 protected existing scientific, production and cached-result files match their before-run hashes, including the selected automatic result sources for all 17 completed recordings. No production MATLAB source was changed by this milestone. Existing unrelated dirty work was preserved.
- Two repair cycles were used. The first corrected synthetic-only evidence/motion handling before recording evaluation. The second followed a development memory-guard stop at approximately 2.07 GiB: exact column-tiled median temporaries and one recording per worker reduced memory. Six median parity cases and the full FB2413 catalogue, masks, contacts and coverage match exactly before/after that repair. The stopped attempt and earlier synthetic failures remain in the evidence directory.
- Successful recording workers took about 83–277 seconds each, with sampled process-tree peaks up to 1.80 GiB, below the 2 GiB ceiling. The independent verification used about 650 MiB. New derived material is approximately 620 MiB, below 1 GiB; four scheduled batches and two repairs were used, within eight active hours. These timings are not a MATLAB/Python benchmark.

The implementation used already cached Python, NumPy/SciPy, Pillow, Matplotlib and FFmpeg, without package installation or production environment changes. Python is an experimental offline backend, not a selected production platform. Existing MATLAB batch/statistics/export workflows remain the working application.

For a computational replay, inspect the retained [worker launcher](../../reference-validation/boi-video-detector-prototype-20261106/run_worker.py), [detection runner](../../reference-validation/boi-video-detector-prototype-20261106/run_detection.py), [selection](../../reference-validation/boi-video-detector-prototype-20261106/select_review.py), [renderer](../../reference-validation/boi-video-detector-prototype-20261106/render_review.py) and [independent verifier](../../reference-validation/boi-video-detector-prototype-20261106/verify_independent.py). Receipts retain exact commands, settings, source hashes and runtime. The launcher uses this Mac's cached tools and refuses to overwrite worker receipts; detection also refuses to overwrite configuration directories. Replaying processing requires a separate output destination and bounded authorization, not running blindly over these delivered results.

## Preservation and stopping decision

The burden formula, normalization support/implementation, exposure, individual event/ROI references, automatic results, saved review decisions and export formats remain unchanged. No new scientific amplitude, accepted event area, contribution or recording burden was calculated. Unknown area remains unknown; no partial normalized burden or imputed zero was introduced. Sink/surge separation is preserved.

All five delivery items are closed as experimental engineering work with the recognition, eligibility, identity and area limitations above. This milestone stops here. No GUI integration, 17-recording run, scientific adoption, commit/push, release or external publication is included. Findings remain local. Before any further implementation, discuss whether the search mask and proposal representation can preserve the important dim/local events while retaining observed spatial recovery; do not infer an accepted detector from passing computational checks.
