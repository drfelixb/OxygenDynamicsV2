# Batch CSV and GUI usability plan

**Combined batch export delivered, 15 October 2026:** local **3.1.0-dev.8**
connects the batch GUI to the existing stats/export service. The 17 completed
recordings export together into 108 workbook sheets with 5,407 sink events and
1,320 surge events. All 204 per-recording table and 136 stored-trace comparisons
match their saved individual results; final focused checks pass 44/44. Three
source holds, originals, earlier results, optional stimulation metadata and
review flags remain. Large MAT variables use v7.3 storage with the same filenames
and schemas; calculation rules and worksheet formats remain unchanged. See the
[delivery](BOI_BATCH_STATS_EXPORT_DELIVERY.md). No new recording/detector run,
MATLAB desktop, package, commit/push or release. Implementation is stopped after
verified local delivery; Felix can now use the combined exports for postprocessing.

**Existing stats/export connection approved, 15 October 2026:** Felix requests
exporting the 17 completed recordings together through the existing workflow,
preserving formats and calculations. BATCH-EXPORT is delivered locally and
implementation is stopped; the read-only
assessment below is superseded only within this approved scope. See the
[work items](#batch-connection-to-existing-stats-and-export).

**Existing export workflow checked, 15 October 2026:** Felix asked to check the
older workflow before proposing another exporter. The V2 source and current
implementation already provide CSV-driven multi-recording statistics, grouped
metrics/traces and Excel/MAT export. The new queue reuses that service one
recording at a time. The next proposal must reuse the existing export path and
address its handoff from the queue; a replacement export system is not the
agreed direction. See the [assessment](#existing-stats-and-export-workflow).
This assessment starts no implementation or analysis.

**GUI polish delivered, 15 October 2026:** Felix's “Good. Continue” approved
the check-progress and selected saved-run opening improvements. Local
**3.1.0-dev.7** passes 26/26 focused cases and one read-only FB2412 reopening.
See the [bounded work items and delivery](#gui-progress-and-saved-run-opening).
No implementation milestone remains active.

**Inspection round closed, 15 October 2026:** Felix's user-started queue completed
all 17 selected recordings; the three source-held rows remain excluded. He
inspected FB2412 saved traces, sink/surge summaries and surge frame ingredients,
reported the trace viewer worked fine, and closed this round. See the
[closeout](BOI_BATCH_EXECUTION_DELIVERY.md#researcher-run-and-inspection-closeout).
The closure proposed GUI follow-ups, subsequently approved and delivered above;
the inspection closure itself did not authorize implementation or release.

**Execution milestone delivered, 14 October 2026:** Local 3.1.0-dev.6 adds the reviewed sequential queue, status/history persistence and stop/retry behavior. See [execution delivery](BOI_BATCH_EXECUTION_DELIVERY.md) and [user guide](BOI_BATCH_EXECUTION.md). Earlier first-milestone/proposal entries below are retained history.

14 October 2026 · First editor milestone approved

**First milestone delivered:** [editor delivery](BOI_BATCH_EDITOR_DELIVERY.md),
local 3.1.0-dev.4, final 10/10 focused cases and both layout sizes inspected.
See the [editor guide](BOI_BATCH_EDITOR.md). Felix's usability acceptance is
pending; queue execution/live status writeback remain subsequent work. The
approved proposal and its boundaries are retained below.

Make batch preparation the next usability priority. A **Batch recordings** window
inside the existing MATLAB application should let a scientist add recording
folders, enter shared acquisition settings, add optional metadata, check each
row, and later run and reopen the batch. The working CSV should show which
recordings have completed analysis and where their results are saved.

Felix requested skipping the second user review. The proposed colleague
walkthrough and its preparation are skipped for the current plan; no
unfamiliar-user evidence is claimed. Felix approved the field set, plan and first
editor milestone on 14 October: “Go ahead with the first batch editor milestone
as proposed.” Queue execution/live writeback remain subsequent work.

## Current batch obstacles

The legacy wrapper requires 11 column headers; statistics requires 13, including
behaviour fields even when those inputs are absent. The current manual example
does not contain both additional statistics headers. Neither route updates
analysis status in the input CSV. The launcher also defaults to reanalysis and
one blocked row prevents the whole verified batch from starting.

The newer single-recording service already makes the five biological labels
optional, checks explicit acquisition/support settings, preserves incomplete
runs, and verifies completed result artifacts. The batch interface should adapt
to these shared services. It can generate their internal statistics CSV with
unused behaviour placeholders, so the scientist need not fill those columns.

## Minimum input and optional fields

**Enter one recording folder per row.** Enter sampling rate, pixel size,
detection support and output parent once for the batch. A row can override the
three acquisition/support settings. Display their units and whether each value
comes from shared settings or a row override. Require explicit confirmation;
there is no universal 1 Hz, pixel calibration or tissue-support default.

Save the resolved acquisition/support values into every row when exporting a
portable CSV. This gives it four essential columns and avoids dependence on a
hidden settings file. A CSV containing only paths can be opened as a draft;
missing settings must be resolved before that row is ready. Choose the output
parent once when running; generate a unique run directory for each attempt.

| Field group | Proposed fields | Requirement |
|---|---|---|
| Recording source | `Paths` | The only value the user must enter for every row. One supported recording folder, with ambiguous source files reported. |
| Acquisition and support | `SampleF` in Hz, `Pixelsize` in µm/pixel, `BOISupportProfile` | Required effective values, filled from shared settings or explicit row overrides. The per-row support column is a proposed addition. |
| Existing descriptive labels | `Mouse`, `Condition`, `DrugID`, `Genotype`, `Promoter` | Optional. Present `Mouse` as Subject ID, keeping its compatibility name. |
| Additional descriptive metadata | `RecordingLabel`, `RecordingDate`, `Session`, `Sex`, `AgeDays`, `BrainRegion`, `Project`, `Operator`, `Notes` | Optional columns shown on demand. `AgeDays` has an explicit unit; dates use ISO format. |
| User additions | Other descriptive columns | Preserve their names, values, blanks and row association when importing, saving and exporting. |
| Software fields | Stable row identity, validation, analysis state and latest attempt/result details | Generated and updated by the application; no manual entry required. |

Reserve software-owned column names and reject ambiguous name collisions.
Generate missing `BatchRowID` values and require unique nonblank IDs. When a
copied/imported row repeats an ID, require an explicit choice to keep the same
row or create a new identity before linking any attempt.

Optional metadata must survive CSV editing and be saved beside the run request
as an immutable metadata snapshot. Preserve leading zeros in IDs. Keep blanks
in the user's table; the existing engine adapter can supply its explicit
`unspecified` labels. Extra metadata remains descriptive and does not change
calculations or substitute for source-bound acquisition/tissue declarations.
Unknown columns must not be passed into the strict recording-request API.
Editing descriptive metadata after completion preserves the saved snapshot and
old exported labels. Show **Metadata changed since run** separately when the
calculation inputs still match; a matching calculation does not mean its saved
labels reflect subsequent edits.

Support existing verbose CSVs through an adapter. Retain legacy behaviour and
other optional columns without introducing new behaviour/protocol capabilities
into this BOI task. If a row requests an optional analysis unavailable through
the new BOI route, show that limitation and retain its existing legacy route;
never silently ignore a configured analysis. Resolve relative source paths
against the CSV's directory;
show the resolved path. Export paths relative to the destination only where that
preserves the same source, otherwise retain an explicit absolute path.

## Analysis status and CSV updates

Use separate fields for input readiness, technical analysis completion and
scientist review. A single yes/no Analyzed column would hide failed attempts,
changed settings and missing results.

| Field | Values or content | Meaning |
|---|---|---|
| `BatchRowID` | Generated stable identifier | Connects metadata and attempts after sorting or moving rows. Distinct from Subject ID and the engine's RecordingID. |
| `InputStatus` | Unchecked, Ready, Needs attention | Whether current inputs/settings pass preflight. |
| `AnalysisStatus` | Not analyzed, Running, Complete, Failed, Interrupted | Technical outcome of the latest attempt. |
| `ResultCheck` | Unchecked, Matches, Changed, Unavailable | Whether the saved completion still matches the source/settings and verified artifacts. |
| `ReviewStatus` | Not reviewed, In progress, Reviewed | Optional scientist workflow marker. Completion never sets it to Reviewed; actual judgments remain in the existing review system. |
| Latest attempt details | `RunID`, `RunFolder`, `StartedUTC`, `CompletedUTC`, `SoftwareVersion`, `Stage`, `ElapsedSeconds`, `Message` | Generated links and explanations; most can stay in a details panel. |

Show a compact **Analyzed** indicator derived from verified completion if useful,
while retaining the fuller states. Record the executed settings, source hashes
and calculator identity in the attempt record. A version difference alone should
not label old results incorrect; show their creator and compare relevant inputs.

Update the working CSV at each stage transition and after each recording.
Keep an immutable input/settings/metadata snapshot for every attempt and a
durable attempt history referencing the existing `RunStatus.json` and verified
`BOIRun.mat`. Those run records determine technical completion; editable CSV
status cells are a convenient view. Recover a stale CSV from the saved records.
Associate attempts through verified row/run links, never table position,
Subject ID or a filename alone. Older runs lack a batch row ID: attach them by
explicit selection or an unambiguous verified association, without altering
their saved identity.
If a process disappears without verified completion, show Interrupted rather
than Complete, while preserving the original run status file.

Save CSV updates through a temporary file and atomic replacement, with a retained
prior copy. Detect external edits and concurrent writers; stop automatic
writeback on conflict and offer a recovered copy. Preserve custom columns,
notes and row order. Reopening or importing a CSV never starts analysis.

## Batch window and main GUI

The window belongs to the existing application, with the same preparation,
analysis and result-opening services. It can have a larger table without
becoming a separate application with separate settings.

1. **Create or open:** Add folders, paste paths, or open a CSV. Show the recording
   label/path, readiness, analysis status and result link first. Let the user
   choose optional columns and apply metadata to selected rows.
2. **Set shared values:** Sampling rate, pixel size, explicit support choice and
   output parent. Show row overrides and allow resetting them to shared values.
3. **Check:** Give row/cell-specific problems and corrective actions. Show source
   and tissue-support details for the selected row. Detect duplicates, missing
   files, output conflicts and changed settings. Let the user explicitly select
   ready rows even if other rows need attention; show every excluded row/count.
4. **Run selected ready rows:** Confirm the resolved settings and destinations
   once for the selected queue. Start sequentially. Skip verified matching
   completed rows by default; Run again creates a fresh attempt and folder.
   Stop the queue on an execution failure initially, retain all pending rows,
   and offer a deliberate continuation after the error is understood.
5. **Reopen results:** Select a completed row to open its exact indexed run,
   event/recording results, workbook or folder. Failed rows show their stage,
   error and incomplete-output location. Reopening the batch restores history.

Offer **Stop after current recording**. The existing engine has no cooperative
mid-recording cancellation or calculation resume; neither is promised here.
Retry starts a new run. Keep the original source-staging behaviour and show
expected copy storage before execution: the current service copies source
movies into each new run. Large-batch performance and storage optimization are
separate requirements.

After batch preparation/tracking works, simplify the main GUI around **New
analysis**, **Batch recordings**, and **Open saved run**. Put basic information
first and detailed parameters behind an expandable panel. Reuse Open folder and
Copy path, consistent status wording, units and visible selected-run identity.

## Delivery sequence and first milestone

Only one implementation milestone will be active. The first is **Create and
check a batch without hand editing CSVs**. It includes compatible import/export,
optional metadata, shared settings, row validation and saved-completion display.
The later execution queue and automatic live writeback follow the agreed schema.

| Work item | User benefit and bounded scope | Acceptance and stopping condition |
|---|---|---|
| BATCH-SETUP-01 | Small public CSV contract and adapter; generate legacy compatibility fields internally. | A paths-only draft and the resolved four-column CSV open; existing verbose CSVs remain readable; GUI and noninteractive preparation resolve identical settings. Stop at the preparation boundary. |
| BATCH-SETUP-02 | Batch table inside the current app; shared values, row overrides, optional/custom metadata, save/reopen. | A scientist can prepare a batch without writing CSV text. Sorting, save/reopen, leading-zero IDs, quoted commas, Unicode and blank labels preserve associations and values. Stop after the editor workflow. |
| BATCH-SETUP-03 | Per-row preflight and honest completion display from existing run records. | Missing/duplicate/conflicting inputs identify their row and remedy; source/settings changes invalidate readiness; completed/failed/incomplete fixtures display accurately. Stop before queue dispatch or changing old results. |
| BATCH-SETUP-04 | Concise instructions, example CSVs, focused contract/UI verification and technical review. | Document the minimal fields, optional fields, state meanings and untested execution. Deliver the working editor, checks and limits. |

Owner for these items: the implementation Codex chat. A separate Codex reviewer
checks schema/persistence changes within the milestone; Felix judges the table
workflow. This technical review does not reinstate the skipped second user review.

**Proposed first-milestone budget:** eight active engineering hours, two MATLAB
session starts, 100 MiB of disposable test/evidence output, zero detector,
statistics-pipeline or recorded-movie executions, and no build, commit/push or
publication. Routine repairs and necessary focused rechecks are included;
record checks without a separate arbitrary batch-count ceiling.

Use a finite matrix of ten cases: (1) paths-only draft, (2) resolved minimal
CSV, (3) legacy verbose CSV, (4) shared settings and row override, (5) optional
and custom text round trip with reorder, (6) missing source and duplicate rows,
(7) missing/invalid calibration and source-bound support, (8) completion/failure/
incomplete display, (9) changed settings/source/artifact invalidation, and
(10) CSV write failure/external-edit conflict. Reuse the tiny input and saved-run
fixture builders in `tests/analysis/testBOIRecordingWorkflow.m`; use disposable
copies for mutations. Inspect the editor at 1120 × 800 and 900 × 650. These are
preparation/persistence checks and do not demonstrate live batch execution.

Stop when the four items pass and the editor is reviewable, or report the exact
unfinished item at the budget/scope boundary. If this work is deferred, the
existing manual CSV and single-recording workflows stay available.

**Next milestone:** sequential queue execution, durable attempt history,
automatic CSV writeback, verified skip/retry, failure handling and stop-after-
current-recording. Its approval proposal must name the final schema, finite
success/failure/interruption/conflict fixtures and any small synthetic engine
attempt. No real recording campaign follows automatically.

**Following milestone:** broader main-window navigation, settings presentation
and inspection/export polish, guided by Felix's use of the batch editor.
Scientific defaults, calculations, original outputs and existing review
qualifications remain under the current workspace guardrails.

## Source anchors

- [Legacy wrapper headers](../helpers/requiredWrapperInputColumns.m) and
  [statistics input](../runOxygenDynamicsStats.m).
- [Current launcher](../OxygenDynamics_GUI.m) and
  [single-recording window](../openBOIRecordingWorkflow.m).
- [Shared preparation](../prepareBOIRecordingRequest.m),
  [run orchestration](../runBOIRecordingWorkflow.m), and
  [saved-run verification](../loadBOIRecordingRun.m).
- [Source-bound acquisition metadata](../helpers/captureBOIAcquisitionMetadata.m)
  and [existing fixture builders](../tests/analysis/testBOIRecordingWorkflow.m).

## GUI progress and saved-run opening

15 October 2026 · BATCH-UX · Owner: root Codex, without delegation.
Felix's “Good. Continue” continues the two GUI improvements proposed at the
inspection closeout. This bounded milestone is now delivered; no new scientific
method, detector work, recording campaign or release is included.

- **BATCH-UX-01 — visible check progress.** Benefit: distinguish source/result
  checking from a stalled window or running analysis. Add optional progress
  reporting to existing check/queue preparation, with recording count/identity
  and current check stage displayed while editing remains protected. Preserve
  identical results with/without the callback and restore controls on error.
- **BATCH-UX-02 — selected saved-run opening.** Benefit: opening FB2412 does not
  read unrelated recordings. Keep global row/duplicate-source validation, then
  verify the selected current source, effective settings, saved row association,
  metadata and artifacts through existing services. Unselected rows/results
  remain untouched; unchecked completion cells never become verified claims.
- **BATCH-UX-03 — bounded verification/handoff.** Reuse existing finite editor/
  queue synthetic fixtures and add focused progress/selective-opening cases.
  Perform at most one read-only FB2412 reopening in the existing MATLAB desktop.
  Inspect progress and restored controls, update guides/version/status, then
  stop. No second user review or full batch reanalysis is scheduled.

Budget: four active engineering hours; up to three focused test invocations plus
at most two targeted repair rechecks; zero new MATLAB desktops and zero recording
or detector/statistics executions. One named FB2412 source/result verification
and reopening is permitted without running it. Evidence ceiling 100 MiB,
synthetic generated output ceiling 200 MiB. Original recordings, the completed
17-row queue, working CSV, scientific review flags and held sources are protected.
No package, commit/push or publication. Stop after delivery; further product or
scientific changes need a separate agreed scope.

### Local delivery, 15 October 2026

**3.1.0-dev.7**, build **2026-10-15 11:29:23 +02:00**. BATCH-UX-01 through
BATCH-UX-03 are complete. Checks display the recording count/name and source,
attempt-history or saved-result stage. Editing stays protected, and the dialog
and busy state clear on success or error. **Open saved run** verifies only the
selected recording through the existing services, retaining global schema and
duplicate-source guards. Other rows remain untouched and visibly unchecked.
**Check rows**, **Select ready** and queue review still perform full-batch checks.

The two existing synthetic suites pass **26/26** on macOS/MATLAB R2025a, with
zero failed or incomplete cases and no runtime warnings in the final log.
Six additional cases cover selected-only work, global duplicates, progress/result
equivalence, successful GUI opening, changed-source/settings/artifact rejection,
busy protection and recovery. Static review also identified and repaired the
**Select ready** edge case after a partial check; the final suite covers it.
The initial **24/26** result is retained: two new GUI assertions compared MATLAB
enable-state objects with character values. Their visible states were correct;
the assertions now compare strings. A test-only nested timer cleanup cycle was
also repaired, and its single disposable timer was released. There were two
focused invocations, 52 case evaluations and no additional repair invocation.
Code Analyzer retains nonblocking style messages; no independent reviewer or
new full software/platform gate is claimed.

One permitted read-only FB2412 reopening completed in **16.393764 seconds**:
one recording checked from the 20-row CSV, 284 saved automatic events loaded,
the other 19 rows unchanged with empty requests and unchecked reports. The
recording/stage progress window was observed in native MATLAB, then closed;
controls returned and recording execution stayed disabled in the saved viewer.
The updated editor and FB2412 saved viewer remain open under distinct dev.7
window titles. No full-batch timing comparison or memory measurement was made.

Evidence is in `reference-validation/boi-batch-gui-polish-20261015` outside the
Git repository: original source hashes, before-file copies, both test results,
the read-only handoff and final verification receipt. Of 562 existing MATLAB
files, 557 are unchanged. Only the batch checker, queue preparation, batch
editor, version function and editor tests changed; there are no new repository
MATLAB files. The working CSV and 35 queue/attempt/native status records retain
their bytes. Original CSVs retain their hashes; all 40 original movies retain
their sizes and modification times. This preservation check does not rehash
every movie or completed artifact. Scientific review flags and the three source
holds remain unchanged.

Limits: progress advances per recording/stage, without a byte-level estimate
or cancellation within a file check. Required hashing can still take time.
The prior scientific qualifications remain; these are GUI and integrity checks.
Zero new MATLAB desktops, recording/detector/statistics executions, packages,
commits, pushes or releases. Stop here; further product work needs an agreed scope.

## Existing stats and export workflow

15 October 2026. Felix: “can you check the old workflow. there is an export etc
included. i feel like we reinventing something here again.” This authorizes a
read-only workflow assessment. The earlier chat suggestion to create new
combined CSV exports was premature; reuse the existing machinery first.

- `OxygenDynamics_Wrapper` reads the metadata CSV and runs recordings.
- `OxygenDynamics_Stats` calls `runOxygenDynamicsStats`, which reads the selected
  CSV, loads saved recording outputs, combines tables and prepares grouped
  metrics and traces. `exportStatsResults` writes the workbook, event tables,
  MAT data and trace exports. These core steps are present in the earlier V2
  source (`85884af`) and remain in the current code. The main GUI retains
  **Run Stats** and **Open Stats**.
- The new `runBOIRecordingWorkflow` creates a one-row `input.csv` for the staged
  `Recording` folder and calls the same `runOxygenDynamicsStats` service. The
  batch queue invokes this workflow once per selected recording. It therefore
  produces separate per-recording workbooks rather than the old dataset-wide
  combined stats output.
- Read-only directory/CSV checks confirm all 17 completed named queue runs have
  one stats workbook and a one-row stats input pointing to their own staged
  output. FB2413's workbook sheet inventory includes `OxySinkEvents`,
  `OxySurgeEvents`, site metrics, recording/window summaries, traces, metadata
  and QC. Those exports already exist; no new result was generated here.
- The recording/window inspector is optional calculation evidence. It neither
  replaces the ordinary stats exports nor supplies the missing queue-to-combined-
  stats handoff.

The gap is routing and presentation: connect verified completed queue entries
to the existing multi-recording stats/export workflow, and make those outputs
easy to open from the GUI. The working batch CSV points to prepared source
folders, while analyzed outputs are inside each run's staged `Recording`
folder. Passing it unchanged to the older stats route is not a demonstrated
handoff. A bounded implementation proposal must preserve exact run selection,
recording identity, metadata, held rows, optional-stimulation semantics and
existing calculations/formats. Cross-recording export does not authorize
experimental comparisons or detector execution.

No code, calculation, workbook, original recording or saved research output was
changed. No MATLAB execution, numerical test, package or Git transport. This
assessment stops at the findings; implementation still needs a scoped approval.

## Batch connection to existing stats and export

15 October 2026 · BATCH-EXPORT · Owner: root Codex, no delegation.
Approval: “yes, let’s connect the batch GUI to the existing stats and export
workflow so i can export the 17 completed recordings together. keep the existing
export formats and calculations.”

- **BATCH-EXPORT-01 — exact saved-run adapter.** Resolve completed runs through
  existing row/source/settings/artifact verification. Construct the existing
  stats CSV using the saved labels, timing/calibration and stable recording IDs.
  Bind exact indexed sink/surge masters, excluding held/incomplete/unverified
  entries with reasons. Keep stimulation descriptive. Acceptance: reordered
  rows, stale requests, duplicate identities, changed inputs/artifacts and output
  conflicts cannot select or overwrite an unintended result. No detector call.
- **BATCH-EXPORT-02 — GUI review, export and access.** Add a combined export
  tab/action with explicit included/excluded counts, destination and saved-label
  policy. Run the existing stats/export service once for the reviewed completed
  rows; protect editing, display progress and restore controls on failure.
  Provide opening/copying the completed workbook/folder. Acceptance: no export
  from an unreviewed/stale plan, failed export not presented as complete, and
  unchanged ordinary queue/inspection behavior.
- **BATCH-EXPORT-03 — finite verification and named delivery.** Focused synthetic
  adapter/GUI/selection checks plus existing batch regression cases. Perform
  the authorized combined stats/export for the existing 17 completed recordings
  in a new folder. Check exact recording identities, existing workbook/event/
  trace formats, per-recording values against their saved results and original
  file preservation. Record limits and deliver the updated local GUI and output.

Budget: six active engineering hours; up to four focused test invocations plus
two targeted repair rechecks. At most two named combined export attempts (one
initial and one necessary repair), each at most 60 minutes. Evidence 100 MiB,
synthetic output 200 MiB. The initial 2 GiB named-output estimate was too small
because the first attempt omitted two large tables. Complete v7.3 MAT storage
uses a corrected finite engineering allowance of 16 GiB, including the preserved
incomplete attempt; local free space exceeds 64 GiB. This estimate correction
keeps the same 17 recordings, two export attempts and scientific scope. Reuse the current MATLAB
desktop. Zero detector/new-recording runs, scientific calculation changes,
stimulation reconstruction, other dataset campaigns, packages, commits/pushes
or release. Existing output formats/calculations remain in the existing stats
service; selection/progress plumbing and size-aware MAT serialization are extended.
MAT filenames and variable schemas are unchanged; large variables use compressed
v7.3 storage to prevent omission. No new exporter framework.
The 17 completed runs, original sources, working CSV, review flags and three
source holds remain protected. Stop at verified local delivery.
