# Finish the recording interface and update GitHub

13 October 2026 · Implementation handoff for the next Codex chat

Make detection-support selection understandable, make exported folders easy to
find, and bring the documentation and development branch up to date. Use Felix's
completed FB2311 result for verification. Keep the accepted calculations and
saved results unchanged.

This chat prepared the handoff only. Felix can authorize the complete task by
pasting the prompt at the end into the implementation chat. That authorization
covers routine engineering decisions, repairs, focused rechecks, version metadata
and normal commit/push within this scope. Do not request approval for each repair.

Internal work item: **UI-FINISH-01**. Owner: the implementation Codex chat.

## Starting point

- Workspace: `/Users/zcm361/Documents/Github/OxygenDynamicsV2`.
- Git repository: the `existing-analysis` child directory.
- Branch: `development-existing-analysis-v3`.
- Starting HEAD: `029c9897e92986fc2bd5812b568dc8330d031e8a`.
- Current software: **3.1.0-dev.2**, build `2026-10-04 21:37:28 +02:00`.
- Remote: `https://github.com/drfelixb/OxygenDynamicsV2.git`.

Read the workspace and repository `AGENTS.md`,
[development plan](SOFTWARE_DEVELOPMENT_PLAN.md), current
[status](planning/software-development-status.json),
[version policy](SOFTWARE_NEXT_STEPS.md#software-and-calculation-versioning), and
[FB2311 test result](BOI_FB2311_MANUAL_TEST_RESULT.md).

Check the actual branch, HEAD and working diff before editing. Existing local
changes include the development plan, priorities, status and new manual-test
guides/result records. Preserve them and review them for the intended commits.
If the checkout has advanced, inspect the intervening changes and adapt; do not
reset or overwrite competing work.

## Existing example

The local test packet is:

```text
/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/felix-fb2311-manual-test-20261013
```

Use these existing children:

- Run: `BOIRun_FB2311_20261013_01/BOIRun.mat`.
- Source copies: `input/`.
- Accepted event export: `BOIEventReview_tpbec838ab_fbe1_4c53_b6da_f6e034d0ca38/`.
- Accepted window export: `BOIWindowReview_tp0b5173e7_04d3_4017_b0cf_ced062eada80/`.
- Independent arithmetic: `independent-event-replay.json` and
  `independent-sink-window-replay.json`.
- Felix's reopening/acceptance: `manual-test-completion.json`.

The run has **328 automatic candidates: 240 sinks and 88 surges**, with saved
elapsed time **293.5957327 seconds**. Felix confirmed 1 Hz and 2.35 µm/pixel.

| Saved result to preserve | Expected value |
|---|---|
| Sink site 2, event 5 | Measurement frames 499–514; 20 reference frames, 479–498 |
| Automatic event optical drop | 4.162901548860646%, displayed as 4.1629% |
| Whole-recording sink occupied fraction | Approximately 0.00574843697221921, or 0.5748436972% |
| Sink onset rate | Approximately 13.8485148981 events/mm²/min |
| Sink concurrent density | Approximately 3.9064352442 events/mm² |

All four measures were independently replayed within the documented scope.
Felix confirmed matching event count and values after reopening. Peak memory,
anatomical tissue validity, physiological event identity and correction/reference
suitability were not established. Surge inspection, native-mask attachment and
opening this run's indexed workbook were not demonstrated by Felix.

## Fix detection support guidance

Felix encountered `SupportProfile must contain explicit text.` The dropdown in
`openBOIRecordingWorkflow.m` intentionally starts at **Choose explicitly**, with
an empty value. `prepareBOIRecordingRequest.m` currently produces the internal
field-name message. This is an observed missing-choice usability problem; no
dropdown-binding defect has been established.

When support is missing, show an instruction such as:

> Choose a Detection support option, then click Review settings again. Use
> Reviewed craniotomy ROI when you have a matching saved tissue boundary, or
> Legacy whole image to use the existing whole-image method.

Keep the support choice explicit. Preserve the two existing options, ROI
requirements and scientific warnings. Do not select a method automatically or
invent a tissue boundary. Run must remain disabled until valid preflight and
explicit confirmation; changing support must invalidate that confirmation.
Check the observed path and adjust the wording/layout as needed.

## Make export folders easy to find

In `openBOIEventReview.m`, export success is placed in `ImageStatus.Text` in a
short action row. In `openBOIWindowReview.m`, it replaces `status.Text`. Long
paths can be hard to read and the feedback can be replaced by later interactions.

For both **Export selected evidence** and **Export selected window evidence**:

- Show the full output folder in a persistent, selectable text field or area.
- Provide **Open folder** using the user's normal file manager.
- Provide **Copy path** if supported by the existing MATLAB desktop facilities;
  otherwise retain a visibly selectable full path with clear copy instructions.
- Keep controls disabled until a successful export. Cancellation must create
  no folder and must not claim a new successful export. A failed export must
  not enable controls for its incomplete destination.
- Opening or copying must use the exact successful destination, including
  spaces and long paths. Avoid shell interpolation of user-selected paths.
- Preserve export formats, provenance and new-child/no-overwrite behavior.

Keep this change in the existing GUI structure. A small shared presentation
helper is acceptable if it reduces duplication; do not build a new framework.
If a new source file is necessary, include it in the explicit package source
policy for future builds.

## Update documentation and development identity

Update the README and affected user instructions with the actual controls and
plain explanations. Reconcile the development plan, priorities, status,
`RELEASE_DECISION_SHEET.md` and affected distribution/support wording. Current
fields still call the personal test pending and all fresh-recording evidence
unverified. Replace those active claims with the single completed FB2311 case,
its elapsed time and Felix's acceptance. Retain dated history as history.

Record that the memory measurement remains missing. Preserve the Linux 133/133
portable pass and partial final macOS evidence separately. Felix's own test does
not establish an unfamiliar scientist's walkthrough or broad platform support.
Licensing for new V2 contributions and publication remain separate decisions;
VM/watchdog work remains outside the current version.

For these changed GUI files, advance the development version to
**3.1.0-dev.3** using one real build timestamp. Reconcile central/displayed
version, changelog and current documentation. Keep scientific contract versions
and the saved FB2311 creator identity unchanged; the new reader/exporter identity
is separate. Old ZIPs remain 3.1.0-dev.2 and are not installations of these fixes.

Provide exact instructions to launch the updated Git checkout, with function
resolution checked so the older extracted installation is not used accidentally.
This task does not build a replacement ZIP.

## Verification and budget

Use focused existing checks and one ordinary MATLAB desktop session where
possible. Necessary tests and repair/recheck cycles are included. The task budget
is **four active engineering hours**, at most **two MATLAB starts**, **four
focused validation batches**, and **100 MiB of new evidence/exports**. Existing
inputs/results and reading their hashes do not count as new storage. Record
actual use and stop if a materially larger scope or budget is needed.

At minimum, demonstrate:

1. Missing support produces actionable guidance with Run disabled; changing an
   explicit support choice invalidates previous confirmation.
2. Whole-image preflight still accepts the existing input/settings, and missing
   required ROI evidence still blocks the ROI route. Preparing settings may read
   the existing input but must not stage an output or start analysis.
3. One event export has a fully readable/selectable destination and **Open
   folder** opens that exact new folder. Verify path copying where implemented.
4. One sink whole-recording export has the same working controls. Check event
   and window chooser cancellation and failure feedback using small temporary
   destinations, without changing the accepted exports.
5. Reopen the existing run and compare the four stored/exported measures above,
   reference counts, frames, signs, units and provenance. Do not repeat the full
   scientific matrices or rerun the recording.
6. Verify documentation/version agreement and preservation of source/result
   files. Inspect useful layouts at the normal size and one smaller usable size;
   capture only the screenshots needed to show the fixes.

Use a new disposable child below `reference-validation/` for new exports and
evidence, outside the completed run. Record/check hashes of the saved run's
index/status/audit/statistics/workbook, source copies and accepted exports before
and after relevant operations. Preserve all existing artifacts. Do not copy the
movies or import large validation material into Git.

If MATLAB is already open for Felix, preserve his session. Identify which code
the verification uses. Ordinary desktop checks need no VM or custom supervisor.

## GitHub delivery and stopping point

Review the diff and stage the intended GUI, version, relevant documentation and
focused-check files explicitly. Include the accepted manual-test result and
shareable current records; leave unrelated or private preparation data local.
Use portable references in public summaries. Do not use a blanket `git add .`.

Allow at most **two commits and one successful normal push** to
`development-existing-analysis-v3`. Inspect remote state and preserve competing
work. Authentication/transport recovery can retry the same unsuccessful push;
never force-push. One existing CI execution triggered by that push is within
scope, using its configured timeout; record its actual outcome or pending state.
Do not change CI platforms or start extra workflows.

Verify that the remote branch contains the delivered commits. Report the version,
commit/link, actual checks, remaining limitations and exact updated launch path.
Leave raw data, MAT/XLSX results, screenshots, prior packages and large evidence
outside Git. No main-branch merge, release tag, public release or ZIP build.

Stop after the two fixes, documentation and verified branch delivery. Do not
start detector/statistics executions, recording reruns, correction refits,
scientific measurement changes, additional diagnostic phases or delegation.
If a scientific-output issue appears, retain the evidence and report it without
adopting a numerical change in this task.

## Prompt to paste into the implementation chat

> I approve the complete task in
> `existing-analysis/docs/BOI_USABILITY_GITHUB_HANDOFF.md`. Fix the detection-support
> guidance and make event/recording export folders easy to find. Update the
> documentation, adopt 3.1.0-dev.3 and commit/push to
> `development-existing-analysis-v3`, using the existing FB2311 result for focused
> verification within the stated budget. This approval includes routine repairs
> and necessary rechecks; do not ask again for each repair. Preserve calculations,
> originals, saved results and old packages. Complete the task and tell me how
> to open the updated software, then stop.
