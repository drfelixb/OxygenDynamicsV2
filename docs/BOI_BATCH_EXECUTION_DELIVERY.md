# GUI batch execution delivery

14 October 2026 · **3.1.0-dev.6**, build **2026-10-14 13:44:29 +02:00**.
BATCH-RUN-01 through BATCH-RUN-03 are delivered locally under the researcher's
explicit request to run the 17 ready recordings from the GUI and keep three held.
[Authorized task and limits](BOI_BATCH_EXECUTION_TASK.md),
[user guide](BOI_BATCH_EXECUTION.md).

**Update, 15 October 2026:** The researcher subsequently ran the selected batch
and closed the demonstrated FB2412 inspection round. See the
[run and inspection closeout](#researcher-run-and-inspection-closeout).
The original implementation and pre-run evidence below remain dated history.

## Result

The existing MATLAB session now shows **BOI batch — 17 ready recordings**, with
17 selected and FB2416/FB2417/FB2318 excluded by native source holds. The new
working copy is `reference-validation/boi-batch-execution-20261014/HP_Compartments_BOI_run.csv`.
Felix chooses the output parent, reviews the selected queue, confirms, then
starts it. No supplied recording or real queue was started by this delivery.

The queue runs one recording at a time through unchanged `runBOIRecordingWorkflow`.
It checks exact source/settings before dispatch, verifies native result artifacts
and row-associated immutable request metadata before Complete, and saves stage/
outcome CSV updates. Verified matching completions are skipped by default;
explicit repeat/retry creates new attempts/folders. Stop-after-current, execution
failure and persistence/conflict failure prevent later dispatch. Persistent
working-CSV execution locks protect against a second MATLAB instance; normal
and known abnormal unwind release only the owned lock. A process disappearing
without cleanup remains incomplete with unknown liveness; reopening never
restarts it and stale locks require deliberate reconciliation/recovery.

Every attempt has an immutable metadata/request snapshot and durable state.
The saved native Request artifact also contains BatchMetadata, protected by its
artifact hash and stable BatchRowID. AttemptHistory retains row-associated links,
including after reordering. New copied identities clear history/result claims.
Original/denoised source pairing, source declarations, optional stimulation text,
all user metadata and scientist review remain intact. Stimulation values never
reach BOI analysis inputs. Completion does not set scientist review to Reviewed.

The GUI provides ready selection, output parent, explicit run-again, queue review,
settings/destinations/source-copy storage, confirmation, sequential progress,
stop-after-current and verified history/result opening. Busy state protects
editing, selection, closing and output changes. Output is refused inside any
prepared/original source folder, including held/unselected rows. Source-copy
storage is estimated separately from additional, unmeasured result/temporary
storage; atomic file operations/hard links are required for queue records.

## Verification and retained failures

Three focused invocations made **31 case evaluations**. The initial 15-case run
passed 10: four cases errored when multiple status strings were concatenated with
the wrong orientation; one stop fixture incorrectly captured its initial false
value in an anonymous function. It also exposed nested onCleanup callbacks reading
an already-destroyed workspace. These first results and warnings remain retained.
The service now normalizes message columns and owns unwind data in an independent
handle guard. The stop fixture uses a shared nested callback.

The second run passes **15/15**, with zero failed/incomplete cases and zero
warnings. This comprises ten queue cases and five existing editor/CSV cases.
The targeted third invocation passes the expanded between-recording abnormal
unwind case: a completed first result/history/CSV stays Complete, the second row
stays pending, the queue records interruption and its execution lock is released.
Failure/state-write recovery, external CSV edits during/between records, verified
skip, immutable retry, same-byte cross-row identity rejection, stale source/plan,
forged completion, locks and GUI busy/stop protections are included.

Executors in these lifecycle tests generate native-loader-valid synthetic saved
artifacts; they never invoke detector/statistics engines. Thus this is queue/
persistence/integration evidence, not a new numerical or fresh-recording validation.
The production default delegates to the unchanged single-recording service,
whose earlier accepted FB2311 evidence retains its original scope/version.

Queue layouts were inspected at 1120×800 and 900×650 and captured as PNGs. Native
**Select ready** and **Review selected queue** clicks selected two synthetic ready
rows and excluded a held row, without starting the queue. The final named 20-row
preflight reports 17 ready/3 held; all 17 are selected and Run remains unconfirmed
with no output parent chosen. Native source checks read inputs only.

A separate Codex reviewer, without queue/test authorship, inspected production
code and the passing runtime records. Findings concerning cross-row incomplete
attempt association and destinations inside other source folders were repaired;
cleanup guard repairs were re-reviewed, with no unresolved static finding. This
is technical review; no second human usability review or scientific acceptance
is claimed.

## Preservation and stopping point

The source OneDrive CSV, previous prepared CSV, 40 original movie sizes/mtimes and
all original user metadata/row IDs remain unchanged. Only generated Message text
and the new empty AttemptHistory software column differ in the working copy.
All 546 preexisting MATLAB files outside six named contract/UI/runner/version
edits match milestone-start hashes; ten new MATLAB files comprise nine service/
helper files and the queue tests. No scientific engine/formula changed.

Evidence lives outside Git in `reference-validation/boi-batch-execution-20261014`,
including all three result/log sets, final-verification.json, independent-review.json,
reader-source-check.json, handoff-summary.json and both layout PNGs. Evidence is
below 2 MiB, within 100 MiB; temporary synthetic fixtures were removed. Existing
MATLAB was reused: zero new desktops, supplied-recording runs, synthetic engine
runs, packages, commits, pushes or publication. The future source policy includes
new services/helpers/guide; 467 sources/assets and 56 reader links resolve without
building a package.

Implementation is complete and stopped. Felix can choose output storage and start
the reviewed 17-row queue. Full 17-recording elapsed time, output storage, peak memory
and real-queue integration remain unmeasured; existing scientific qualifications
and the three source holds remain. Any runtime repair follows the actual observed
failure; no automatic reanalysis, detector tuning or further campaign is scheduled.

## Researcher run and inspection closeout

**BATCH-INSPECT-01 · 15 October 2026 · closed.** Felix requested: “ok, i have
inspected everything. lets continue and finish this inspection round.” User
benefit: retain the completed batch outcome and the demonstrated usability
feedback so the next task does not repeat this inspection. Owner: root Codex.
Scope: read saved execution metadata and record feedback; no new analysis,
test invocation, code change, scientific adjudication or distribution action.
Stop when the current plan/status and this record agree with the saved outcome.

Felix personally selected the output parent, reviewed/confirmed the queue and
clicked Run. Queue `50c02732-cf69-4817-a7df-043fe1f17a42` started on 14 October
at **16:54:10** and finished at **18:22:04 Copenhagen time**: **5,274 seconds**
(about 1 hour 28 minutes), including queue validation and dispatch overhead.
All **17 recordings** have Complete/Matches CSV outcomes, complete attempt and
native run states, and the queue's row-associated artifact verification message.
There are **zero pending or failed recordings and no recorded execution errors**.
No recovery CSV was required, and the execution lock was released. These are
17 researcher-started recording executions, separate from the original
implementation verification's zero supplied-recording-run budget.

FB2416 and FB2417 remain held for duplicate source identity; FB2318 remains held
for unverified original/denoised correspondence. They have no attempt history
or run folder. Stimulation text remains optional metadata. The original source
CSV and earlier prepared CSV retain their hashes; all 40 original movie
sizes/mtimes still match the source audit. This closeout does not rehash movie
bytes or repeat full saved-artifact loading: it checks the queue/attempt/native
JSON and CSV agreement with the verification already performed by the queue.

The opened FB2412 result is
`runs/BOIRun_74bbc0f0-26b3-4cf3-985c-114d6ff80a9c` within that queue. The viewer
showed 284 automatic events with captured saved traces. Felix explicitly said
“the trace viewer worked fine.” He then inspected the whole-recording sink
summary, surge summary, and surge Frame ingredients table, including its
rightmost area-time and occupancy-status columns. The displayed summary replay
checks matched. His closure statement closes this demonstrated inspection
round; it does not claim a new independent numerical replay, scientific
validation of detections/tissue/calibration, event adjudication, an evidence
export, inspection of other tabs/recordings, or a second unfamiliar-user review.
The CSV's 20 scientific ReviewStatus values remain **Not reviewed**.

The receipt is
`reference-validation/boi-batch-execution-20261014/inspection-closeout-20261015.json`.
No recording/test run or MATLAB launch was added for closeout. The saved result
files, working CSV, sources and MATLAB code remain unchanged. No package,
commit/push or release was made or approved.

Two observed GUI follow-up candidates remain: show progress through source
checks while editing is disabled, and open one saved recording without checking
unrelated batch rows while retaining necessary integrity checks. These address
the waiting/confusion encountered in this trial. They require a bounded agreed
implementation milestone; no calculation change, new recording campaign or
automatic continuation follows this closed inspection round.
