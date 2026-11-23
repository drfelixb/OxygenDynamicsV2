# Finish the frozen scan with a larger proposal ledger

9 November 2026. Proposed capacity amendment to the approved
[joint detector experiment](BOI_VIDEO_JOINT_DETECTOR_PLAN.md). **Awaiting approval;
recording processing is stopped.** No new detector method or repair is proposed.

## Observed checkpoint

All twenty constructed checks pass after the two permitted repairs. One
configuration was frozen before loading recording arrays. Primary passes for
FB2311, FB2317, FB2319 and FB2402 are complete and preserved. The FB2403 pass
finished its calculation but the guard stopped it before writing its catalogue.

The frozen guard counts both preliminary seed proposals and consolidated
candidate records against the 100,000 ceiling. Across the first five recordings
it reports **105,921 seeds and 43,811 consolidated candidates**. It therefore
stops on seeds. The first four saved catalogues contain 75,542 seeds and 31,403
candidates. These are experimental proposals, including overlapping alternatives,
uncertain and unsupported cases; they are not biological pocket counts.

Successful workers peak below 2 GiB (maximum about 1,606 MiB); new evidence at
the checkpoint is about 60 MiB against 512 MiB. No original image was decoded,
reserved pixel/trace array read, scientific result saved or video encoded.
The stop is the approved proposal-count boundary, not a memory/storage failure.

## Concrete amendment

Increase **only the run-wide ledger capacity from 100,000 to 500,000 records
per configuration**, still applied to both seed and consolidated-candidate
counts. The frozen per-recording seed limit of 100,000 remains unchanged.

All other limits remain: the same twelve prepared development recordings and
thirty views; five reserved recordings untouched; eight active engineering hours,
four batches, 2 GiB worker memory, 512 MiB evidence, 36 recording-pipeline attempts
and the two already used repairs. No additional method repair, parameter tuning,
constructed-scene execution, source TIFF decoding or video encoding is included.
The 512 MiB storage guard remains authoritative if the larger ledger cannot fit.

The existing frozen numerical code, settings and run guard do not change: the
guard already reads the run-wide capacity from the scope record. Keep their
hashes unchanged. A separate resume helper only validates approval, preserves
the stopped attempt, skips byte-verified completed results and dispatches the
remaining existing workers with new log names. It does not fit a new model.

Replay only the stopped FB2403 primary pass, then finish the remaining primary
and raw-route-only passes. This would require **25 attempts in total** including
the stopped one, within the original 36. Preserve all four completed catalogues
and their seed ledgers byte for byte; do not refit or overwrite them. Generate
the thirty-row comparison and six cards already agreed once the passes finish.

Keep the original eight-active-hour total: preserve the original start and
elapsed work at this checkpoint; exclude only the subsequent wait for the
researcher's response from the effort clock. Record any clock offset explicitly
when resuming. There is no reset of work already spent, repair count, scene
executions, pipeline attempts or prior failures. If any unchanged resource or
source limit is reached, stop again with a checkpoint.

## Consequences and alternative

This allows a broader candidate catalogue to be assessed consistently across
all twelve recordings. It does not improve recognition by itself. The catalogue
is large, so over-generation, duplicates and incorrect local promotion must
remain explicit in the assessment. Do not claim biological accuracy from passing
constructed checks or increase a limit to describe the detector as accepted.

Keep the burden formula, normalization, strict complete contributions, scientific
references, original recordings/results, reviews, MATLAB workflow and exports
unchanged. Findings stay local. No production adoption or reserved evaluation.

The alternative is to leave the scan stopped and review only the four saved
catalogues, with the twelve-recording comparison explicitly incomplete.

The [approved plan](BOI_VIDEO_JOINT_DETECTOR_PLAN.md) says that reaching a ledger
or other resource limit “stops with an explicit preserved checkpoint”.
[AGENTS.md](../AGENTS.md) requires approval before crossing that boundary.
Approval of this capacity amendment is needed before resuming processing.

## Approval record

The researcher explicitly approved this capacity-only amendment on 9 November
2026: “I approve.” The proposal text above is preserved as the reviewed scope.
No further method repair or change to frozen numerical code/settings is approved.
