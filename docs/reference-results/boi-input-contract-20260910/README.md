# R1 BOI input and denominator verification — 10 September 2026

The final input/QC implementation passed 36 MATLAB checks, the known-event and
successful-zero-event integration, and a new statistics export from ID400's
unchanged full-recording master. These are numerical/input/export checks, not
biological validation. The [contract guide](../../BOI_RECORDING_INPUT_CONTRACT.md)
explains assumptions, fields and holds; the [verification report](verification-report.json)
contains observed results and source/output hashes.

## What was verified

- Original sink and surge event tables are identical to the earlier walkthrough.
- All original burden fields, including recording, animal summary and time-series
  values, are exactly unchanged. The recording table additionally carries six
  input-status columns. Existing window numbers agree within 1e-12 + 1e-10 ×
  absolute original value; no onset rule or detector parameter changed.
- All 600 frame contributions are exported. Covered native sink area-time is
  13,329,135.3125 µm²·s; analyzed static tissue-time is 2,147,981,587.5 µm²·s.
  Their ratio reproduces occupied fraction 0.0062054234496551515 (about 0.6205%).
  MATLAB CSV replay passed, followed by an independent Python CSV check.
- All 196 descriptive sink onsets remain counted. None of this recording's saved
  sink starts is at acquisition time zero. Artificial boundary fixtures verify
  the nonzero boundary case and distinguish ongoing events at a window start;
  they do not settle physiological onset admission.
- Camera exposure, measured frame timestamps and declared frame validity remain
  unknown in this historical master. `ModeledFrameIncluded` records the existing
  all-frame model separately. No unknown acquisition fact was filled from the
  image interval, filename, appearance or later source declarations.
- Five input review issues appear in the normal acceptance table: assumed timing,
  unknown camera exposure, unknown intensity history, unreviewed frame validity
  and static tissue validity. Scientific eligibility remains open.
- Partial-frame windows, native-mask overlap, tissue intersection, missing masks,
  zero area, valid zero events, failed recordings, truncated support, malformed
  declarations, unsupported timing, declared exclusions and changed source
  declarations have explicit tested behavior. No IOSI recording was analyzed;
  the BOI-only modality check uses a metadata fixture only.

## Execution and feasibility

Final execution: MATLAB R2025a, two process workers; integration 12.33 seconds,
ID400 statistics 33.62 seconds, total verification function 57.69 seconds. The
new output tree was approximately 54.77 MB before the final log/report copies.
No full biological detector rerun was performed for R1. No fresh peak-memory or
human review-time claim is made. The prior complete-recording resource evidence
and the open cohort resource budget remain applicable.

Full outputs are in the sibling workspace folder
`reference-validation/boi-input-contract-20260910-verified/`; the statistics
subfolder contains the input review, contracts, workbook, frame CSVs and MAT
outputs. `code-manifest.csv` captures the MATLAB sources and the runner verifies
that they remained unchanged during the final run. Prior automatic, curated and
statistics results in `boi-workflow-20260910/` were preserved; the earlier run-A
MAT SHA-256 remains `182a29c6423c2a5490f814e2166b53bb0a165b0f1026fac1b589354ab301872a`.
The [artifact/decision record](artifact-record.json) adds current dictionary,
code, export and log hashes.

## Preserved corrections

The first R1 export completed, but its verification compared entire old/new
burden objects and stopped when it encountered the six added metadata columns.
A read-only comparison established exact equality for every original field.
The comparator now checks the original fields explicitly. The original failed
comparison report and executed runner are retained in
`reference-validation/boi-input-contract-20260910/`, with the read-only correction
under `boi-input-contract-20260910-final/`. This was an audit-schema mismatch,
not a numerical result change.

Subsequent review found that the draft per-frame field `DeclaredFrameValid`
used true as the fallback when no validity declaration existed. The summary
already described the assumption, but the field name could misrepresent it as
observed metadata. The final version exports unknown as NaN/null and separates
`ModeledFrameIncluded`. This justified one additional integration/statistics
export without detector tuning. Both earlier output directories remain intact.
The final 36 tests include the unknown-versus-modeled distinction.

## Reproduce

From the project folder in MATLAB:

```matlab
setupOxygenDynamicsPath;
addpath(fullfile(pwd,'tests','analysis'));
checks = runtests({'testBOIRecordingInputContract', ...
    'testAnalysisCorrections','testPipelineContract','testMeasurementAvailability'});
assertSuccess(checks);
prior = fullfile(fileparts(pwd),'reference-validation','boi-workflow-20260910');
newOutput = fullfile(fileparts(pwd),'reference-validation','boi-input-contract-new-run');
report = runBOIInputContractVerification(prior,newOutput);
```

Use a new output directory. The optional third argument can point to a completed
verification output tree to replay its export checks without running analysis
again. The prior root must be the fixed ID400 development walkthrough; source
identity is checksum-verified. Do not present this animal as untouched evaluation.

## Remaining scientific work

This implementation makes assumptions inspectable; it does not validate static
tissue support, motion/exposure coverage, calibration evidence, timing alignment
or intensity history. Irregular timing and frame exclusions require method
assessment rather than automatic resampling. Recovery, event identity and onset
censoring remain unresolved. Cohort holds and biological outcome priorities are
unchanged. A comparable non-DANDI recording still needs a declared development/
evaluation role, source review and this preflight before outcome inspection;
independent researcher GUI and numerical-replay acceptance are still required.
