# Additional memory-only repair: outcome and stopping checkpoint

6 November 2026. **Approved repair applied; processing stopped at the next resource boundary.** Compact seed storage, verified input layout and fresh configuration workers preserve all 1,370,100 FB2413 primary seeds, all 21,039 candidates, cohorts and phase values exactly. All four recordings and eight review cards are delivered. The pooled independent checker then reached 2,158,411,776 sampled RSS bytes after passing both FB2413 configurations; full replay for the other six configurations remains incomplete. In accordance with the stopping condition below, no further numerical repair or processing followed. The [results report](BOI_VIDEO_DETECTOR_REVISION_RESULTS.md) records the incomplete verification, unresolved recognition failures and unchanged scientific workflow. The original approved proposal below is retained as history; it is no longer active or awaiting approval.

## Original checkpoint before the approved repair

The revised service and all 16 synthetic scenes are implemented. After two synthetic repair cycles, 15/15 stated recognition assertions and the geometry, matched-pixel, missingness, native gap and dim-tissue safeguards pass. The frozen FB2413 primary run completes in 2,264 seconds and preserves 1,370,100 temporal seeds and 21,039 experimental candidates. Independent replay matches every comparison cohort, 123 scalar checks and seven proposal scores.

The selected group overlapping site 3/event 6 has proposed bounds 640–1094, its main assessed trough at 794 and a return comparison at 809–813. This is **not successful isolation of the discussed 826–851 episode**. Completing the remaining comparison must retain this limitation; the proposed repair changes storage/process isolation only.

The sensitivity pass is stopped by the memory guard at sampled process-tree RSS 2,202,058,752 bytes (about 2.05 GiB), after completing proposal search and before writing a complete sensitivity output. The primary output remains valid and preserved. No other revised recording run has started. There are no new scientific results, burden values, changed normalization or changed originals.

## Concrete repair

ID: **VDI-MEM-01**, owner root, no delegation. Benefit: finish the approved comparison within the existing memory cap while retaining all hypotheses and numerical values.

1. Replace the list of millions of Python seed tuples with fixed float64 array chunks. Append order and row values stay identical. Six mathematical buffer checks at 0, 1, 8,191, 8,192, 8,193 and 20,000 rows match the current storage byte for byte.
2. Run one primary or sensitivity configuration per fresh process, so the previous pass's allocator state cannot accumulate into the next pass.
3. Use the already tested time-contiguous input layout in temporary, field-by-field verified cache copies. Full seed/cohort/phase/classification parity already passes on the existing 2,002-candidate synthetic fixture, with exact all-frame raw trace agreement on the sampled FB2413 masks. Original caches remain unchanged. Temporary copies are removed after use.

The [prepared patch](../../reference-validation/boi-video-detector-revision-20261106/repair-candidate/memory-only-candidate.diff) and [proposal record](../../reference-validation/boi-video-detector-revision-20261106/repair-candidate/proposal.json) retain the approved proposal. Numerical equivalence passed before continuation. No detection threshold, confidence rule, episode/reference criterion, formula, normalization, source recording, scientific decision or export changed.

Before continuing, replay the completed FB2413 primary with the compact buffer into a separate parity directory and require exact seeds, groups, cohorts, classifications and phase values against the preserved primary. Then reuse that completed primary, finish sensitivity, and run the other three recordings one configuration per worker. Freeze the equivalent implementation before the known comparison runs; disclose the storage change and partial stopped attempt. Reuse the already rendered checkpoint card if its candidate, context and source pins match the final selection.

## Budget, acceptance and stopping condition

Request **one additional memory-only engineering repair**, at most two active engineering hours within the original eight-hour total; unchanged four recordings/four batches, one primary/one sensitivity configuration, 2 GiB memory and 1 GiB new derived material. One exact primary parity replay is included; this is not a new parameter configuration. No additional named synthetic scene is introduced.

Acceptance: exact buffer and full primary parity, successful memory-guarded completion or an explicit checkpoint, independent source/geometry/phase checks, and the original compact review/failure report. Recognition limitations are reported without tuning them away. If parity fails or the 2 GiB cap is reached again, stop and preserve the checkpoint; no further unapproved repairs or increased limits.

The alternative is to stop with the verified FB2413 primary checkpoint and defer the remaining four-recording evaluation. Neither choice adopts the detector or changes the scientific workflow. Findings remain local.

The original approved plan allowed “two repairs”; both were used. The [workspace rules](../AGENTS.md) require that before crossing a boundary we “ask and wait for explicit approval.” The researcher explicitly approved this one additional memory-only repair before application. That approval did not authorize a further repair after another resource stop.
