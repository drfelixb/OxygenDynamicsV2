# Run selected BOI recordings from the batch window

Use **Batch recordings** in `OxygenDynamics_GUI`, or run
`openBOIBatchEditor` in MATLAB. Open the working batch CSV and check the rows.
Opening a file never starts a recording.

1. Choose **Select ready** to select technically prepared rows. Rows needing
   attention remain excluded; the queue review identifies them. You can also
   select a smaller set of table rows.
2. Choose the output parent once. It may be on an external SSD. Queue records require a filesystem supporting
   atomic updates and hard links. The parent must
   already exist and must be outside every source recording folder. Each queue
   and recording receives a new directory, preserving earlier outputs.
3. Review the selected queue. A progress window shows the recording count/name
   and source or saved-result verification stage. Editing is disabled while
   checks run; large movie files take time to read. No analysis is running at
   this step. Check the resulting included, excluded and skipped rows,
   effective sampling, pixel size, tissue-support method, new destinations and
   expected input-copy storage. The storage estimate covers copied inputs;
   analysis outputs require additional space. No universal output-size or
   large-batch runtime estimate is claimed.
4. Confirm this reviewed queue, then start it. Only one recording is dispatched
   at a time, through the existing single-recording BOI workflow. It copies the
   original and optional denoised movie into the new run, performs analysis and
   statistics, and verifies the saved result before reporting Complete.
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
Use the selected row's history to find earlier attempts and reopen an exact
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

Choose **Stats / export…** in the batch window. This connects saved completed
recordings to the existing multi-recording stats/export workflow.

1. Choose an existing **export parent**. A new combined export folder is created
   inside it; keep it outside source and saved-run folders.
2. Leave **All completed recordings** selected to collect the batch, or choose
   **Selected recording rows** for a smaller set.
3. Choose **Review combined export**. Check the included/excluded list and the
   destination. Linked runs must pass the current source/settings/artifact
   checks. Held, incomplete and unverified rows are excluded with reasons.
4. Confirm the reviewed list, then choose **Run stats / export**. It reads the
   exact saved sink/surge master files and runs the existing stats/export service.
   Progress shows verification, recording loading, combining and file writing.
   No detector or new recording analysis is run.
5. Choose **Open workbook** for the usual `FilteredData_<batch-name>.xlsx`,
   or **Open folder** / **Copy path** for all exported files. The completed
   destination stays visible. Excel/MAT event tables, grouped measurements,
   traces and existing companion CSVs retain their current formats/calculations.

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
