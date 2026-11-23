# Finish the same benchmark with a lighter renderer

9 November 2026. Concrete continuation proposal for POCKET-VIDEO-DETECTOR-08.
No new detector, case selection, scientific calculation or recording is proposed.

## Preserved checkpoint

All thirty case data sets and figures are prepared. Twelve native movies from
six development recordings completed normally. The FB2412 worker reached the
2 GiB process-tree guard while encoding five clips concurrently; its sampled
peak was 2,150,629,376 bytes and the guard stopped it. The independent rendering
group already in progress finished, and no further original-image processing
has been started since the checkpoint was identified.

Inspection of the stopped worker's files finds four complete 360-frame movies
(cases 02, 05, 06 and 26), which can remain byte-identical pending verification.
Case 25 contains only 169 of its intended 360 frames and remains clearly marked
incomplete. All stopped files and their hashes are preserved. Thirteen other
movies have not yet been rendered. The five reserved recordings remain excluded.

## Prepared repair

Use the one remaining engineering repair to finish only the same thirty cases:

- Convert the selected source frames once into their existing fixed-contrast,
  512 × 512 grayscale display in memory. Keep scientific/raw traces and the
  coarse comparison data unchanged. No new denoising or segmentation.
- Encode one case at a time from that temporary display buffer. Avoid the five
  concurrent encoders that exhausted memory.
- Use bounded preview compression (H.264, one encoder thread, no lookahead,
  CRF 23, maximum 2.4 Mbit/s with a 4.8 Mbit buffer), retaining native image-panel
  resolution, every frame, the same contrast, overlays and timing. Videos are
  review media; scientific values never come from compressed pixels.
- Preserve all twelve completed movies and the four recoverable movies exactly.
  Preserve case 25's stopped movie separately; replace its working slot with a
  complete rendering. Do not rerender any other existing movie.
- Read no source frame more than twice in this milestone. For FB2412, only
  case 25 and the eight declared verification frames need another read. Other
  missing movies use one shared source pass per recording.

The candidate implementation is
`reference-validation/boi-broad-video-benchmark-20261109/render_memory_candidate.py`.
Its source-resume command is gated on an explicit approval flag.

## Checks already completed without new source pixels

The candidate reproduces all thirteen available stopped-run expected display
images exactly before compression. A thirty-frame derived-image codec check
passes, with maximum mean absolute RGB difference 2.70 on the three decoded
comparisons and a measured worker-tree peak of about 662 MiB. The test includes
a fully touched worst-size 1200-frame grayscale buffer. It reads no original
recording. A preceding lower-bitrate check failed the unchanged quality limit
and remains preserved; its setting is not proposed for adoption.

The planned final 11,640 case frames, 169 stopped duplicate frames, two
thirty-frame codec checks and the earlier eight-frame layout check total at
most **11,877 rendered frames**, still below the approved 12,000 ceiling.
Expected movie storage at the bounded rate fits the existing 2 GiB evidence
ceiling; the guard remains authoritative.

## Limits, science and stopping condition

Retain the original eight-hour total, four batches, thirty cases, twelve
development recordings, two engineering repairs total, two reads per source
frame, 12,000 rendered frames, 2 GiB worker memory and 2 GiB derived evidence.
This is not a resource-budget increase. The first repair fixed supervisor
process-inspection permissions; this would be the second repair cycle.

The source registry, selection rule, cases, raw/corrected evidence, footprint
identities, existing completed movies, burden formula, normalization, strict
completeness, scientific references, original results and exports stay preserved.
No held-out pixels or trace arrays, new detector fits, scientific judgments,
accepted areas or burden values are included.

After approval, finish rendering, independently verify the ninety declared
movie samples and ninety-six source-frame samples, deliver the thirty-case
gallery and twelve-view starting board, then stop. If a further source, quality,
resource or repair boundary is reached, retain a checkpoint and stop again.
Deferral leaves the prepared figures, complete movies and incomplete case
clearly recorded; it does not mark the benchmark complete.

The [approved benchmark plan](BOI_BROAD_VIDEO_BENCHMARK_PLAN.md) explicitly says:
“Stop at any source/resource/effort/repair boundary with a preserved checkpoint.”
Because that condition occurred, explicit approval is needed to resume original
image work with this prepared repair. Until then, only checkpoint inspection,
derived-image checks and independent non-source work continue.

## Approval record

The researcher explicitly approved this prepared rendering repair on 9 November 2026: “Approve this rendering repair (Recommended).” Original limits and scientific boundaries remain unchanged.


## Outcome

The approved sequential repair finishes all thirty movies within the original limits, preserving sixteen completed movies and the stopped partial file. Subsequent unchanged quality checks flag cases25/29. No further original-image reads, re-encoding or third repair followed. The qualified benchmark and before-compression snapshots are delivered; full media acceptance is not claimed.
