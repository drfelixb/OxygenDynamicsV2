# G1 software engineering evidence

23 September 2026 · SW-G1-01–05 · Complete; G2 awaits approval

This packet records the approved engineering baseline, not cohort reanalysis.
No production MATLAB files changed, no recorded-movie detector ran, and no
scientific method or stimulation protocol was adopted.

Deliverables: SOFTWARE_G1_BASELINE.md and SOFTWARE_BACKLOG.md under repository docs.
Fixture proposal: fixture-proposal.json, at most three existing software fixtures.

- test-summary.json / test-results.json / matlab-checks.log: 120 passed existing
  bounded BOI tests in twelve suites, 0 failed/incomplete/skipped.
- matlab-environment.json: actual local MATLAB/toolbox environment; remote CI
  and Linux/R2025b were not run.
- saved-workflow-probe.json / log: cached ID400 both-sign replay, connected
  window/event navigation, evidence export and explicit export/session distinction.
- audit-creation-probe.json / log: default source-audit route reproduces missing
  corrected/filtered trace stages using the existing 4x5x80 synthetic fixture;
  all four optical measurements still match.
- cached-event-export/: new evidence export used only for software inspection;
  original source results are unchanged. Contains local source references.
- code-analyzer.json: twelve messages over eight inspected entry points;
  analyzer messages are not automatically defects.
- code-baseline.json / code-classification.json: all 495 original MATLAB hashes
  and explicit entry-point classification, not a full production dependency audit.
- work-items.json: G1 approval, bounded scope and stopping rule.
- before/ and preservation.json: original planning/status documents and the
  preserved prior artifact chain. Local tracked-changes-before.patch records
  pre-existing uncommitted tracked work; it is not a new implementation patch.

Scripts reproduce engineering checks only. Portable MATLAB recipes end .m.txt;
copy them to the corresponding workspace packet as .m if intentionally rerunning
in a new, separately versioned output location. Do not overwrite this sealed packet.
No independent human code review or researcher usability walkthrough was performed.
The evidence does not establish biological accuracy or a supported release matrix.
