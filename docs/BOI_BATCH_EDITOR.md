# Prepare and run a BOI batch

The **Batch recordings** window prepares recording lists, acquisition settings,
optional metadata and links to existing results. Enter one recording folder per
row, supply the required acquisition settings, then **Check rows**. The window
can save and reopen the batch without hand editing CSV text.

Use **Select ready**, choose an output parent and review the selected queue.
Confirm its settings and destinations, then **Run reviewed queue** to execute
recordings sequentially through the existing BOI workflow. Progress and outcomes
are saved to the working CSV; source-held rows are excluded. See
[batch execution](BOI_BATCH_EXECUTION.md) for storage, stop, retry and recovery.

After completion, **Stats / export…** collects verified completed recordings
through the existing multi-recording stats/export service. Review the included
rows and new destination, confirm, then run it once to obtain the usual combined
workbook, event tables and traces for postprocessing. See
[combined export](BOI_BATCH_EXECUTION.md#collect-completed-recordings-for-postprocessing).

## Open the editor

From the installation folder in MATLAB, replacing the path with your location:

```matlab
cd('/path/to/OxygenDynamicsV2/existing-analysis');
setupOxygenDynamicsPath;
openBOIBatchEditor;
```

Alternatively, open `OxygenDynamics_GUI` and choose **Batch recordings**. Use
**Open CSV** to open an existing list. Opening a CSV does not start checking or
analysis. A CSV can also be supplied directly:

```matlab
openBOIBatchEditor('examples/boi-batch-draft.csv');
```

## Add recordings and confirm settings

1. Choose **Add folder…**, or **Paste paths…** with one recording folder per
   line. Choose the folder containing the intended original movie and optional
   matching denoised movie. The check reports ambiguous or unavailable sources.
2. Enter shared **Sampling rate (Hz)**, **Pixel size (µm/pixel)** and
   **Detection support**. Select **I confirm these shared acquisition and
   tissue-support settings**. Changing a shared setting clears confirmation.
3. Leave acquisition cells blank to inherit the confirmed shared values. For a
   recording with different settings, enter its row overrides. The support
   choices are `whole-image` (**Automatic tissue estimate (legacy)**) and `craniotomy-roi-1`
   (**Reviewed craniotomy ROI**). The latter requires a matching source-bound
   reviewed support declaration; selecting it does not create a tissue mask.
4. To remove overrides, select the recording rows and choose **Use shared for
   selection**. This clears all three acquisition overrides for those rows.
   **Use shared** in a support cell means a blank value in the CSV.
5. Select a row to inspect its resolved source path, effective settings and
   whether each setting came from that row, shared settings or is missing.

**Automatic tissue estimate (legacy)** needs no preset ROI: the existing method estimates tissue from movie intensity. Inspect the estimated boundary visually; detections can extend beyond that estimate. Its saved value remains `whole-image`. **Reviewed craniotomy ROI** requires a previously saved matching reviewed mask.

There is no universal sampling rate, pixel calibration or support default.
Supply values established for each acquisition. A matching reviewed support
declaration must already be present in the recording folder. The editor checks
that declaration and its source; prepare or review support separately using
the existing tissue-support tools. Choose an output parent once when reviewing
the selected execution queue.

Relative recording paths resolve against the opened CSV's directory. A new,
unsaved batch uses MATLAB's current folder. Saving to another directory retains
existing source and result links as absolute paths; subsequently entered
relative paths use the newly saved CSV's directory.

## Add optional information

Select recording rows, then open **Optional / custom fields**. Choose a field,
enter its value and choose **Apply to selection**. **Show / add field** makes it
visible in the table for individual editing. **Add custom field** accepts an
additional descriptive column. **Hide selected field** hides its display and
keeps its values.

All descriptive information is optional:

| Information | CSV field names |
|---|---|
| Existing biological labels | `Mouse`, `Condition`, `DrugID`, `Genotype`, `Promoter` |
| Recording and session | `RecordingLabel`, `RecordingDate`, `Session` |
| Additional description | `Sex`, `AgeDays`, `BrainRegion`, `Project`, `Operator`, `Notes` |
| Optional stimulation description | `PuffsFile`, `Puff_2use` |
| Your own description | Other custom column names |

**Subject ID** uses the compatibility name `Mouse`. IDs such as `0012` remain
text. Use `YYYY-MM-DD` for recording dates and days for `AgeDays`; both are
descriptive fields. Blanks remain blank in the batch. The analysis adapter
supplies its explicit `unspecified` labels where required internally.

Custom fields, quoted commas, quotes, Unicode and multiline notes are retained
with their recording row. **Move up** and **Move down** move the whole row,
including its stable identity and metadata. Software-owned names are reserved;
case variations such as `samplef` cannot substitute for `SampleF`.

## Check rows and existing results

Choose **Check rows** to verify the batch. During checks, a progress window shows
the recording name, how many recordings are being checked, and whether it is reading
sources, checking attempt history or verifying saved results. Editing is
temporarily disabled. Reading large movie files can take time; no analysis runs
during these checks. The window closes and controls return after completion or
an error.

Select each row needing attention to read its specific problem and remedy in
**Selected recording / check details**. The check reports missing or duplicate
sources, invalid settings, incompatible
inputs, support problems and linked-result issues. A problematic row does not
prevent the other rows from being checked. Editing inputs clears the previous
check; check again before relying on readiness or completion.

| Display | Meaning |
|---|---|
| Input readiness: `Unchecked` | Current inputs have not been checked. |
| Input readiness: `Ready` | Current inputs passed preparation checks. No analysis was started. |
| Input readiness: `Needs attention` | Read the selected row's explanation and correct its inputs. |
| Analysis: `Not analyzed` | No verified saved completion is linked to this row. |
| Analysis: `Complete` | The linked run's completion and required result artifacts were verified. Check the separate saved-result comparison. |
| Analysis: `Failed` | A source-associated saved attempt reports failure; partial output is retained. |
| Analysis: `Incomplete` | Saved completion cannot be established, including a persisted `running` state. The editor does not check whether a worker is alive. |
| Analysis: `Interrupted` | The source-associated saved status explicitly reports interruption or incompleteness. |
| Saved result check: `Matches` | Verified saved results match the current source and calculation settings. |
| Saved result check: `Changed` | Source, calculation settings or required artifacts differ from the saved result. |
| Saved result check: `Unchecked` / `Unavailable` | Current matching or saved completion cannot yet be established; read the details. |

To connect an older result, select one recording and choose **Attach saved
run…**, then choose the exact saved run folder. **Check rows** verifies the
association, settings and artifacts. **Open saved run** checks only the selected
recording before opening it, including its current source/settings, saved row
association and artifacts. It is available when one row has a linked run,
without a prior full-batch check. Unrelated recordings are not read; their
unchecked status remains unchecked. Duplicate source folders elsewhere in the
batch still block a conflicting selected row. A changed, failed or incomplete
result cannot be opened as a matching completed run.

The viewer opens only after completion and a matching result are verified.
A subject ID, filename or CSV status alone does not establish completion.

Scientist review is separate from technical completion. Completing or checking
a run never sets `ReviewStatus` to `Reviewed`. Existing review judgments stay in
their review system. Changes to the five saved biological labels are reported
as **Metadata changed since run** while preserving saved labels and exports.
Older runs did not capture additional/custom batch metadata; details say when
that historical snapshot is unavailable.

Legacy verbose CSVs remain readable. Their descriptive and optional columns
are retained. `PuffsFile` and `Puff_2use` are optional descriptive metadata:
their text is preserved verbatim, including leading-zero identifiers. The row
check explicitly says stimulation metadata is ignored for BOI analysis; these
values are not forwarded to the BOI request or generated legacy-analysis
inputs, and they do not configure a stimulation protocol. Configured optional
posture, pupil, whisking or amyloid analyses remain held for the existing
legacy route. Read the row's explanation before continuing through that route.

## Save safely and reopen

**Save** updates the opened CSV; **Save as…** creates a new destination. A save
writes a complete temporary CSV and publishes it atomically. Updating an opened
CSV retains a prior copy named like `batch.csv.backup-<unique-id>.csv`.

If another writer changed the opened CSV, the save stops with a conflict and
leaves that file unchanged. Keep the editor open and use **Save as…** with a
new filename to save a recovered copy. Reconcile it with the externally edited
file before replacing either. An unrelated existing destination is refused;
open that file deliberately or choose a new filename. Filesystems must support
the required atomic operation.

An empty batch cannot save shared settings: add a recording row first. A
header-only draft with no shared settings can be saved. Saving after **Check
rows** keeps the current status view, but reopening treats it as unchecked
until the saved records and current inputs are checked again.

Each row receives a stable `BatchRowID`, distinct from Subject ID. If an opened
CSV repeats this identity, the editor offers **Create new identities** or
**Cancel**. Explicitly creating identities keeps the first row's identity and
gives later copies new ones. It clears those copies' saved-run links and
analysis/review states while retaining their source, acquisition and metadata.
The original CSV is unchanged until you deliberately save. Duplicate source
folders still need resolving during **Check rows**.

## CSV examples and MATLAB preparation functions

The portable input contract has four essential columns:
`Paths,SampleF,Pixelsize,BOISupportProfile`. Only the folder needs separate
manual entry per recording when the other values come from confirmed shared
settings. A paths-only CSV is accepted as a draft. Export resolves effective
acquisition settings into every row and adds software status/identity and
shared-setting provenance columns automatically. Those extra fields require
no manual entry.

- Paths-only draft: `examples/boi-batch-draft.csv`. Enter real recording
  folders, then confirm shared acquisition settings.
- Minimal portable CSV: `examples/boi-batch-minimal.csv`. The four essential
  columns, with illustrative settings.
- Optional and custom metadata: `examples/boi-batch-metadata.csv`. Optional
  blanks, leading-zero IDs, Unicode and a quoted multiline custom note.

These are repository templates. The package source policy continues to exclude
CSV files; a package user can build the same list through Add folder or start
from this minimal text:

```csv
Paths,SampleF,Pixelsize,BOISupportProfile
/path/to/recording,2,4.75,whole-image
```

Every example folder is a placeholder. Replace it with an actual supported
recording folder. The example values **2 Hz**, **4.75 µm/pixel** and
**whole-image** are illustrative software-fixture settings, never defaults or
recommendations for your recording.

For noninteractive preparation, assign `csvPath` to the input filename and
`newCSVPath` to a new destination, then use the same contract/check services:

```matlab
b = readBOIBatchCSV(csvPath);
[resolved, origins] = resolveBOIBatch(b);
[b, report, requests] = checkBOIBatch(b);
[b, backupPath] = writeBOIBatchCSV(b, newCSVPath);
```

`createBOIBatch(inputTable, baseFolder)` creates a draft from a table.
`b.Shared` holds text fields `SampleF`, `Pixelsize` and `BOISupportProfile`;
set `b.SharedConfirmed=true` only after explicitly confirming them.
`prepareBOIBatchRow` adapts one resolved row to the existing recording-request
boundary and generates legacy compatibility fields internally. These functions
prepare/check inputs and save CSVs; they do not dispatch analysis.

After correcting row issues and saving the batch, use the queue controls below
to review and run selected ready recordings through the existing workflow.


## Queue and attempt history

**Run selected…** opens the queue review. **Select ready** selects technically
prepared rows; the review lists held/excluded and verified skipped rows,
settings, new destinations and source-copy storage. **Run again in new folders**
requests fresh attempts explicitly. **Stop after current recording** prevents
later dispatch after the current recording finishes. Execution and status-saving
failures also stop the queue. No mid-recording resume is provided.

At each stage, the working CSV receives current state and exact result links.
The software-owned `AttemptHistory` column stores links to immutable attempt
snapshots. **Attempt history → Load selected history** verifies a selected row's
attempts; select a verified completed attempt to **Open selected saved run**.
Snapshots preserve all metadata as entered; native request artifacts also retain
the batch metadata and stable row ID. Editable CSV completion text alone is never
completion evidence. A copied row given a new identity has its attempt history
cleared alongside its result links.
