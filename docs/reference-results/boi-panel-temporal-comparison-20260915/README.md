# Existing-panel temporal comparison evidence

R3-PANEL-TEMPORAL-COMPARISON-086. [report.md](report.md) contains results and limits.

- `comparison-plan.json`: pre-execution 48-event population, 85 intervals, two scales, annotation roles and resource budget.
- `source-bindings.json`, `recordings.json`, `frozen-events.json`, `researcher-reference.json`, `annotation-variants.json`: original sources and historical human evidence; latest review/reference files are separately source-bound.
- `implementation-freeze.json`: original pre-execution code/configuration hashes; three diagnostic helpers match phase085 exactly.
- `known-shape-tests.json`, `independent-known-shape-tests.json`, `diagnostic_replay.py`: reused known-shape evidence and independent formula implementation.
- `runPanelTemporalComparison.m`, `execution-01.log`, `run-01/`: initial attempt and preserved FB2314 exports.
- `legacy-schema-*.log`, `corrective-freeze.json`, `loadPanelReview.m`, `attachPanelSources.m`, `resumePanelTemporalComparison.m`, `execution-02.log`: the single compatibility correction and resume.
- `run-02/comparison-summary.csv`, `comparison-summary.json`, `comparison.json`: all 170 rows, exact ingredients, missingness and contact provenance.
- `run-02/<recording>/`: original automatic rows, corrected traces, fixed footprints, native contacts, active human contact sources and execution records.
- `verify_panel.py` and `verify_panel_completed.py`: independent verification drivers; the latter targets completed run-02. `verification.log` and `run-02/independent-verification.json` record success.
- `visual-review.json`, `preservation.json`, `artifact-record.json`, `completion.json`: final checks and sealed completion.

The two displayed illustrations were selected before results. No extra human
labeling, source movie read, detector, correction fit, optical baseline, threshold
or scientific policy adoption occurred. Source-exposed development use and unknown
HP identity/anatomy remain explicit. Alternative rows are not biological replicates.
Local MATLAB helpers are copied as `.m.txt` in the portable packet to keep them out
of production discovery. Original run folders are immutable; runners reject an
existing destination. Source bindings contain local paths for this internal
record; this is not a deidentified public release.
