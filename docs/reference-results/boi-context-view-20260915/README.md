# Context-view evidence

See [report.md](report.md) for delivery, validation, limitations and researcher direction.

- `start.json`, `before/`, `code-before.json`: original scope and prior state.
- `tests-01.*`, `verification*`, original screenshots/export: initial technical pass and visually unsuccessful display.
- `before-correction/`, `run-02/`: first correction, preserved export, tests and remaining visual issue.
- `run-03/`: final passing tests, saved-source replay, inspected screenshots and full context export.
- `implementation/`: final installed source snapshots, stored as `.m.txt`.
- `visual-review.json`, `preservation.json`: final display and unchanged-input evidence.
- `researcher-direction.json`: qualitative acceptance of current detection imperfections.
- `artifact-record.json`, `completion.json`: sealed inventory and completion.

Portable MATLAB scripts have `.m.txt` extensions to avoid production discovery.
Source paths are internal traceability, not a deidentified public release. Earlier
exports bind earlier implementation hashes. New exports never replace prior evidence.
