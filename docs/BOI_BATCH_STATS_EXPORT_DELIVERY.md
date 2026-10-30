# Combined statistics/export from the BOI batch GUI

15 October 2026 · BATCH-EXPORT · root Codex, no delegation.

Status: delivered locally; implementation stopped. Local 3.1.0-dev.8, build
2026-10-15 12:58:02 +02:00. Felix approved connecting the batch GUI to the existing
stats/export workflow for the 17 completed recordings, retaining calculations
and export formats. No release, packaging or Git transport is included.

The batch window now has **Stats / export…**. Choose a parent, review completed
recordings, confirm and export, then open the workbook or export folder. The
recording/window inspector is optional for tracing measurements. Current
source/settings/artifact checks select exact indexed saved sink/surge masters;
newer folders and ambiguous files cannot silently replace them. Saved labels
and calibration remain the calculation inputs. Current optional metadata,
including descriptive stimulation fields, is retained in a separate sidecar.

The adapter calls runOxygenDynamicsStats once for the reviewed recording set.
The existing workbook, event tables, grouped measurements, traces, companion
CSVs, MAT filenames and variable schemas are retained. Scientific formulas,
detector, correction and measurement rules and the export worksheet writer are
unchanged. A saved progress function is excluded from the serialized config.

The first named attempt wrote its workbook but MATLAB v7 omitted the two site
tables above the 2 GiB per-variable limit from the main and separate MAT files.
That attempt is preserved and explicitly marked incomplete. The repaired save
helper selects compressed v7.3 MAT storage for large variables and retains v7
for smaller files. It checks saved names immediately; the batch also requires
all main/core tables before reporting success. This is serialization repair;
no values or calculations are adjusted.

The final focused suite passes 44/44. Initial results are retained: 32/42 due to
an omitted Condition column in the new empty-event fixture; then 41/42 due to
fixture directory timestamp setup; one targeted 1/1 repair passed. After the
serialization guard work, all 44 pass in one invocation. Total 129 case
evaluations across three focused invocations and one targeted recheck. Tests
cover exact source binding, saved text IDs, row order, stale/changed inputs,
metadata preservation, failed/partial outputs, MAT names/values, GUI review,
busy protection and failure recovery, plus existing batch and portable-summary
regressions. No detector/new-recording execution is part of these tests.

The completed named export includes 17 recordings and excludes FB2416, FB2417
and FB2318. It contains 108 workbook sheets, 5,407 sink events and 1,320 surge
events. All 204 per-recording table comparisons and 136 stored-trace comparisons
match the individual saved results (only collection row indices are ignored).
All four separate core MAT tables match their combined counterparts; the three
large MAT files use v7.3. The final named export has no omitted-variable warning
or execution error. The existing service took 24.7 minutes; the observed native
attempt, including verification, took 30.64 minutes. This is named example
evidence, not a general runtime guarantee.

The full export occupies 11,867,761,414 bytes (about 11.9 GB), including detailed
MAT data; the workbook is 14,129,865 bytes. Both named attempts together occupy
12,023,814,627 bytes. The initial 2 GiB engineering estimate was too small
because the incomplete first attempt omitted large variables. The finite
storage allowance was corrected to 16 GiB within the same 17-recording,
two-attempt scope; more than 200 GB local space was available. No further
recording or export attempt was added. The evidence packet is about 4.2 MB.

All 699 protected research files retain their hashes, including 680 earlier
run-output files totaling 3,535,986,415 bytes. Original/prepared/working CSVs,
20 Not reviewed flags, stimulation metadata and three holds are preserved.
All 40 original movie sizes/timestamps are unchanged; the approved source and
saved-run checks also passed. No new movie is copied into the stats export.
Of 562 earlier MATLAB files, 552 retain their hashes; ten changes cover the
version, adapter/loader/progress plumbing, GUI/test registration and MAT saves.
Four MATLAB files are new. The scientific export worksheet writer is unchanged.

The completed tab was observed at 1120 x 800 and 900 x 650 content sizes, with
restored controls and the full destination visible. Its native Open folder
button opened the exact completed directory in Finder. Workbook contents and
the enabled Open workbook control were checked; a native workbook launch was
not performed in this task. Root self-review only; no delegation or additional
researcher review is claimed.

Evidence packet: reference-validation/boi-batch-stats-export-20261015, outside
Git. final-verification.json, combined-verification-02.json, native-output-access.json
and the retained initial failures/repair receipts record the acceptance checks.
The receipt-format repair preserves the original expanded JSON evidence and
normalizes its 108 identical successful records into one sheet-list receipt;
no analysis or comparison was rerun. The final audit checks newly changed
whitespace only, preserving historical comment formatting. Local
macOS/MATLAB R2025a evidence does not declare broader platform support or
biological validity. Original scientific qualifications and the three source
holds remain. Stop after verified local delivery; no automatic next milestone.

What follows: Felix can use the workbook/CSVs for postprocessing and the optional
inspector for tracing inputs. No next implementation milestone is scheduled.
