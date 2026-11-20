# Run selected BOI recordings from the batch window

Use **Batch recordings** in `OxygenDynamics_GUI`, or run
`openBOIBatchEditor` in MATLAB. Open the batch CSV and check the rows. You can
review a queue from an imported source CSV. Use **Save as…** to create a
separate working CSV before starting recordings. You can reopen that working
CSV and use it for later queues.

1. Choose **Select ready** to select technically prepared rows. Rows needing
   attention remain excluded; the queue review identifies them. You can also
   select a smaller set of table rows.
2. Open **Run** and choose the output parent once. The list and current
   selection stay visible above the tab. The parent may be on an external SSD.
   Queue records require a filesystem supporting atomic updates and hard links.
   The parent must already exist outside every source recording folder. Each
   queue and recording receives a new directory, preserving earlier outputs.
3. Click **Review selected queue**. During the checks, the progress window shows
   the recording and verification stage. Large movie files take time to read.
   Review the counts to start, skip and exclude, the output parent and the
   estimated space for the input copies. Results and temporary files take
   additional space. Use **Show details** for each recording's ID, settings and
   paths, and for reasons for exclusions or skips.
4. Click the start button, for example **Start 20 recordings**, to confirm and
   start the reviewed queue. Changes to the selection, inputs or destination
   require another review. The queue runs one
   recording at a time. It copies the original and optional denoised movie into
   the new run, performs analysis and statistics, and verifies the saved result
   before reporting Complete.
5. Watch the current row and stage. **Stop after current recording** lets the
   active recording finish and prevents the next recording from starting. An
   execution or status-saving failure also stops later dispatch. Pending rows
   remain pending; completed and partial outputs are preserved.

By default, a linked completed result is skipped only when its artifacts, source
and calculation settings verify against the current row. To repeat selected
rows deliberately, choose **Run again** before reviewing the queue. Every retry
uses a fresh attempt and output directory. Existing calculations do not resume
partway through a recording, and the queue has no cooperative mid-recording
cancel operation.

The working CSV is updated at stage changes and recording outcomes. Stable
`BatchRowID` values associate rows after reordering. Each attempt preserves its
resolved request and full descriptive metadata, including optional stimulation
text. `PuffsFile` and `Puff_2use` remain metadata and are excluded from BOI
calculation inputs. Technical completion never sets scientist review to Reviewed.
Use **History** to find the selected row's earlier attempts and reopen an exact
verified completed result.

Another writer changing the CSV stops automatic updates and later dispatch. The
external edit is left intact; a recovered CSV and saved run/queue records retain
the current outcome. Reconcile the copies before continuing. An execution lock
prevents two MATLAB instances from running the same working CSV concurrently.
An interrupted process may leave a lock and an incomplete attempt. Check whether
another MATLAB instance is still running before recovering a copy; the interface
does not infer worker death from an old timestamp. Importing or reopening never
restarts a queue automatically.

Input readiness establishes technical compatibility. Preserve source identity,
calibration, tissue and other scientific warnings before biological interpretation.
The three unresolved HP sources remain held: FB2416/FB2417 have duplicate movie
candidates, and FB2318 has an unverified original/denoised pairing. No new
acquisition, detector, correction or measurement method is introduced by the
queue.

See the [batch editor guide](BOI_BATCH_EDITOR.md) for minimal fields, shared
settings, optional metadata and safe CSV saving, and the
[single-recording walkthrough](BOI_ORDINARY_MATLAB_WALKTHROUGH.md) for inspection
of the resulting measurements.

## Collect completed recordings for postprocessing

Open **Automatic export** from the tab bar or with **Stats / export…**. This
connects saved completed recordings to the multi-recording stats/export workflow.

1. Choose an existing **export parent**. A new combined export folder is created
   inside it; keep it outside source and saved-run folders.
2. Leave **All completed recordings** selected to collect the batch, or choose
   **Selected recording rows** for a smaller set.
3. Choose **Review combined export**. The preview shows how many recordings are
   included or excluded and where the new export will be saved. Expand **Show
   details** for the recording list and exclusion reasons. Linked runs must pass
   the current source/settings/artifact checks.
4. Click **Export workbook** to confirm and start the reviewed export. The
   button is available after a successful review of the current selection and
   destination. Progress counts the saved runs during verification, then shows
   loading, combining and file writing. This step reads saved sink/surge master
   files.
5. Choose **Open workbook** for the usual `FilteredData_<batch-name>.xlsx`,
   or **Open folder** / **Copy path** for all exported files. The completed
   destination stays visible separately from the current preview. **Open
   existing export…** lets you select an already completed export without
   reviewing a new one.

The combined statistics use each run's saved labels and calibration. Editing
metadata later does not silently relabel the saved analysis; the review lists
differences. `BatchSourceRows.csv` retains the current optional/custom metadata,
including descriptive stimulation text. `IncludedRecordings.csv`,
`ExcludedRecordings.csv` and `BatchStatsSelection.mat` identify the exact selected
runs and mappings. These accompany the existing exports.

Changing rows, settings or the export selection/destination requires a new
review. A failed export retains its partial folder and `BatchStatsStatus.json`,
and is not offered as a completed result. Review again for a fresh destination.
Earlier per-recording outputs and the working batch CSV are preserved.

The recording/window inspector remains optional when tracing a summary back to
its calculation inputs. It is not required for routine combined stats export.

Large combined MAT tables use MATLAB v7.3 storage when a variable exceeds the
ordinary v7 size limit. Filenames, variable names and calculations stay the same;
smaller MAT exports retain v7 storage. The batch reports completion only when
all required main and separate core tables were saved.
