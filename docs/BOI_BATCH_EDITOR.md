# Prepare and run a BOI batch

The **Batch recordings** window prepares recording lists, acquisition settings,
optional metadata and links to existing results. Enter one recording folder per
row, supply the required acquisition settings, then **Check rows**. The window
can save and reopen the batch without hand editing CSV text.

The recording list and its current selection stay visible when you switch
tabs. The area below the list shows the selected tab. Scroll inside a tab to
reach additional controls.

Use **Save as…** to create a working CSV before starting recordings. Use
**Select ready**, open **Run**, choose an output parent and click **Review
selected queue**. You can also preview a queue from the imported CSV. The
preview shows how many recordings will start, be skipped or be excluded,
along with the output parent and the space needed to copy the input movies.
Allow additional space for results and temporary files. Use
**Show details** to inspect individual settings, paths and exclusion reasons.
The start button shows the number of recordings it will run, for example
**Start 20 recordings**. Clicking it confirms the preview and starts the queue.
Changing the selection, inputs or destination requires a new preview. The
queue runs one recording at a time and saves progress and outcomes to the
working CSV. See [batch execution](BOI_BATCH_EXECUTION.md) for storage, stop,
retry and recovery.

After completion, open **Automatic export** or click **Stats / export…**.
**Review combined export** shows the included and excluded counts and the new
output path. Expand **Show details** to check individual recordings and
exclusion reasons. Click **Export workbook** to confirm the reviewed preview
and write the combined workbook, event tables and traces for postprocessing.
See [combined export](BOI_BATCH_EXECUTION.md#collect-completed-recordings-for-postprocessing).

## Reopen a completed combined export

In **Automatic export**, choose **Open existing export…**. Choose the completed
`BOIBatchStats_...` folder containing
`BatchStatsResult.mat`, `BatchStatsSelection.mat` and `BatchStatsStatus.json`.
You can do this in a fresh editor without loading a recording CSV first.
**Open workbook** opens the saved `.xlsx` in your system's default spreadsheet
app. **Open folder** and **Copy path** use the same saved export. The last
completed export stays accessible while you prepare another preview. When the
tab shows the completed export, **Show export guide** opens its postprocessing
details.

This reads the saved receipts and result tables, checks required files and
recorded identities, and starts no statistics or recording run. Original movies
and master files need not be online. It does not recheck their bytes or certify
full output-file checksums. Saved calculation/creator identity is preserved;
opening an old export does not apply newer reference rules. Incomplete, failed,
wrong-source or outside-folder receipts are rejected. A failed open preserves
the previous valid export. Moved-folder recovery is not supported by this step;
select the original export folder.

Export completion and measurement availability are separate. The handoff shows
available normalized recording burdens and event contributions when recorded.
Missing required values remain blank/NaN rather than zero or a partial sum.
The automatic workbook does not apply manual decisions. The separate reviewed
exporter produces a **burden-only companion**, not a replacement for all
statistics; individual pocket review is optional for the normal export route.

Start postprocessing with `HypoxicBurden_ByRecording` for recording values and
`HypoxicBurden_EventBased` for event ingredients. Retain `BurdenAmplitudeSource`,
the saved reference policy when present, recording area/time denominators, and
availability counts. `MetricDefinitions`, `MetricBasis` and `NormalizationGuide`
explain the existing fields and units. For group results, retain each metric's
`NValidMice`. These instructions do not change any formula or endpoint.

## Optional reviewed-burden companion

In **Reviewed export**, choose the saved automatic combined
`DataOutput.mat`, or click **Use opened automatic export** after opening its
completed folder in the automatic tab. Add explicitly selected saved boundary
review JSON files. Each is a self-contained history: choose the reconciled
snapshot you intend to use; the GUI does not search for or adopt a latest file.

**Add event result…** optionally selects an already saved single-event result
folder containing `ReviewedEventBurden.json` and `Checksums.json`. Its matching
recognition/boundary snapshot must also be selected. Boundary choices alone do
not replace amplitude, duration or area. Experimental previews and unsaved
viewer drafts are not inputs. A valid saved area revision with incomplete or
uncertain frames keeps the corresponding burden unavailable.

Choose an output parent; the GUI proposes a new separate child folder. Click
**Preview reviewed export** to read the source and saved artifacts without
writing output or reading original movies. Large saved MAT results may take time
to hash/load. The preview lists exact revisions/checksums, event identities,
recognition decisions/reasons, imported timing/reference/amplitude/area values,
retained/excluded counts, missing contributions and the new destination.

Check the confirmation box, then **Export reviewed burden**. Changing the
selection clears confirmation; changed source/artifact bytes are checked again
before output is created. Failure keeps the previous completed export controls
and clears confirmation. Existing destinations are never overwritten.

This invokes the existing burden-only exporter and preserves its workbook,
CSV, MAT and provenance formats. `ReviewDecisions`, `ExcludedDetections` and,
when used, `EventRevisions` explain what was applied. `HypoxicBurden_ByRecording`,
`HypoxicBurden_EventBased` and `HypoxicBurden_TimeSeries` describe the retained
set. Only saved `not_recognized` detections are excluded; unreviewed/uncertain
detections remain included under the existing policy. Missing required retained
contributions withhold complete/normalized burden; no partial sums or false
zeros. Original automatic statistics and all earlier outputs stay separate.
Ordinary automatic export does not require this optional step.

**Open reviewed workbook**, **Open folder** and **Copy path** use the last
successfully completed companion. Workbook opening follows MATLAB's existing
`open` behavior (the Import Tool on the checked Mac); use Excel's File → Open
with that saved workbook path if preferred. No file is saved by opening it.

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

**CSV setup** opens automatically when recordings lack a sampling rate or pixel
size, or when foreign paths need a local folder. It shows how many recordings
need each value. Enter the values you want to apply and click **Apply to missing
rows**. Use the recording list to enter individual values where they differ.

Relative recording paths use the CSV folder and accept Windows or macOS
separators. A legacy path starting with a single backslash is relative to the
CSV folder too. For foreign absolute paths, **CSV setup** suggests a shared
original folder prefix. Choose the corresponding folder on this computer with
**Choose local folder…**. The rest of each matching path stays relative to the
chosen folder. Repeat for other roots. **Check rows** verifies the resulting
folders.
Use **Save as…** to keep the corrected paths and settings in a separate working
CSV. The imported CSV stays intact.

## Add recordings and confirm settings

1. Choose **Add folder…**, or **Paste paths…** with one recording folder per
   line. Choose the folder containing the intended original movie and optional
   matching denoised movie. The check reports ambiguous or unavailable sources.
2. Enter **Sampling rate (Hz)** and **Pixel size (µm/pixel)** for each recording.
   For values shared across recordings, fill the fields above the list and
   select **Confirm shared overrides**. Changing a shared setting clears
   confirmation. Confirmed shared values fill blank fields.
3. **Automatic tissue estimate** is the default **Detection support**. A
   confirmed shared support choice applies to rows with blank support. An
   explicit support choice on a row takes precedence.
4. To remove overrides, select the recording rows and choose **Use shared for
   selection**. This clears all three acquisition overrides for those rows.
   To clear only the support override, select the displayed default or shared
   support option in that cell.
5. Select a row and open **Recording details** to inspect its resolved source path,
   effective settings and the origin of each value.

**Automatic tissue estimate** (`whole-image`) estimates the tissue area from
movie intensity. Inspect the estimated boundary visually because detections
can extend beyond it. **Reviewed craniotomy ROI** (`craniotomy-roi-1`) uses a
previously saved, reviewed mask that matches the source recording. The editor
checks its support declaration and source before the run.

Supply the sampling rate and pixel calibration established for each acquisition.
Choose an output parent once when reviewing the selected execution queue.

Relative recording paths resolve against the opened CSV's directory. A new,
unsaved batch uses MATLAB's current folder. Saving to another directory retains
existing source and result links as absolute paths; subsequently entered
relative paths use the newly saved CSV's directory.

## Add optional information

Select recording rows, then open **Metadata**. Choose a field,
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
**Recording details**. The check reports missing or duplicate
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

**Save as…** creates a working CSV at a new destination. **Save** offers the
same choice when a source CSV is open and updates the working CSV when one is
open. Reopen a working CSV saved by the editor to continue using it. Older
unmarked CSVs open as protected source files. A save writes a complete
temporary CSV and publishes it atomically. Updating a working CSV retains a
prior copy named like `batch.csv.backup-<unique-id>.csv`.

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
Save the new identities to the working CSV. Duplicate source folders still
need resolving during **Check rows**.

## CSV examples and MATLAB preparation functions

The batch uses `Paths`, `SampleF`, `Pixelsize` and `BOISupportProfile`.
A paths-only CSV opens as a draft. Enter the sampling rate and pixel size on
each row or use confirmed shared settings. Leave support blank to use the
confirmed shared choice, if present, or the automatic estimate. Saving adds
status, identity and shared-setting provenance columns. Defaulted support
cells can stay blank in the saved CSV.

- Paths-only draft: `examples/boi-batch-draft.csv`. Enter real recording
  folders, then confirm shared acquisition settings.
- Minimal portable CSV: `examples/boi-batch-minimal.csv`. Example paths and
  explicit acquisition settings.
- Optional and custom metadata: `examples/boi-batch-metadata.csv`. Optional
  blanks, leading-zero IDs, Unicode and a quoted multiline custom note.

These are repository templates. The package source policy continues to exclude
CSV files; a package user can build the same list through Add folder or start
from this minimal text:

```csv
Paths,SampleF,Pixelsize
/path/to/recording,2,4.75
```

Every example folder is a placeholder. Replace it with an actual supported
recording folder. Replace the illustrative **2 Hz** and **4.75 µm/pixel** with
the values for your acquisition.

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
For defaulted support, `resolveBOIBatch` returns `whole-image` and records
`default` as its origin. The run request carries both the effective value and
its origin.
`prepareBOIBatchRow` adapts one resolved row to the existing recording-request
boundary and generates legacy compatibility fields internally. These functions
prepare/check inputs and save CSVs; they do not dispatch analysis.

After correcting row issues and saving a working CSV, use the queue controls below
to review and run selected ready recordings through the existing workflow.


## Queue and attempt history

**Run selected…** opens the **Run** tab. **Select ready** selects technically
prepared rows. Expand **Show details** to see held and verified skipped rows,
recording IDs, effective settings and exact destinations. **Run again in new
folders** requests fresh attempts explicitly. **Stop after current recording**
lets the active recording finish and stops later dispatch. Execution and
status-saving failures also stop the queue. No mid-recording resume is provided.

At each stage, the working CSV receives current state and exact result links.
The software-owned `AttemptHistory` column stores links to immutable attempt
snapshots. **History → Load selected history** verifies a selected row's
attempts; select a verified completed attempt to **Open selected saved run**.
Snapshots preserve all metadata as entered; native request artifacts also retain
the batch metadata and stable row ID. Editable CSV completion text alone is never
completion evidence. A copied row given a new identity has its attempt history
cleared alongside its result links.

## Compact saved-value workbook

1. Open **Compact workbook**. A completed automatic export opened in this
   Batch Editor is offered as the **Source**. Use **Choose automatic export…**
   or **Change source…** to select a saved automatic workbook or MAT file.
2. Check **Save as**. The editor suggests an unused filename such as
   `<source>_compact.xlsx` beside the source. Use **Choose location…** to set
   your own destination.
3. Click **Preview compact workbook** to check the worksheets and active
   options. A successful preview enables **Export compact workbook** beside
   it. Changes to the source, destination or active options require a fresh
   preview. After the export passes its source and workbook checks, use
   **Open compact workbook**.

The workbook is assembled and checked in local temporary storage before it is
saved to the chosen folder. If the folder cannot accept the completed file, use
**Choose location…** to select a local folder such as Downloads and preview again.

**Source**, **Save as** and the preview/export button stay at the top of the
tab. Expand **Optional settings** to add completed compatible reviewed
exports, supply metadata or phase annotations from CSV, or restore or remember
review choices for the batch.

Use Events and Recordings for event/whole-recording postprocessing, Sites and TimeSeries for their saved inventories/series, Availability for grouped status counts with exact source-row locators, and Definitions for units/references/normalization. Every primary value and flag stays in the main tables. Reviewed values require a selected compatible saved review snapshot. Source-row locators describe the unchanged export; explicit recording/event/frame identities support sorting and cross-export joins.
