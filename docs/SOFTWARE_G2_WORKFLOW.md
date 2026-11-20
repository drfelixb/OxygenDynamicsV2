# G2 — one recording through analysis and review

23 September 2026 · SW-G2 · Approved and delivered

The researcher’s “Continue” approves the narrowed journey proposed immediately
before it: select one recording → confirm settings/tissue support → run → inspect
the corrected trace/events → reopen the saved result. This is software delivery,
not dataset reanalysis. The approval and earlier decisions are retained in
[the status record](planning/software-development-status.json).

| Item | User benefit and bounded implementation | Acceptance / stopping condition |
|---|---|---|
| SW-G2-01 | GUI and batch use one validated request and the existing master/statistics adapters. Explicit sample rate, calibration, support profile, source identity and output destination. Reject unknown keys and incompatible support before analysis. | Same effective request in both routes; source/settings changes invalidate confirmation; source preserved; no overwrite. |
| SW-G2-02 | A focused recording workflow in the existing launcher connects a completed result to the existing event/window viewers. Capture existing corrected and score traces during analysis; save an indexed run for reopening. Failed attempts cannot show a previous result as their output. | New-run review shows corrected intensity with score support; selected result reopens without CSV hunting or computation; both signs and missing/zero-event states remain explicit. |
| SW-G2-03 | Maintain a bounded BOI test runner and wire it into current CI. Add focused request, capture, persistence and failure checks. | Relevant local tests pass; two approved GUI/batch integration executions agree; local and unexecuted CI-platform evidence distinguished. |

Owner/implementer: assistant. Product/scientific owner: researcher. No independent
reviewer or delegated agent is assigned; self-review and automated verification
must not be described as independent human review.

Preserve correction, detection thresholds, timing, full native event footprints,
original immediate native-screened optical baseline, both signs and unavailable
measurements. Review traces are presentation evidence; they do not replace the
preserved-input signal used for quantitative optical measurements. Copy only
selected acquisition inputs/declarations into a new run directory; leave sources
and old outputs intact. Timing authority remains explicit, not inferred from
unreliable file timestamps or globally fixed to 1 Hz.

Validation uses small synthetic and saved-result fixtures first. At most two
fresh executions of FX01 ID400 awake are authorized, one GUI and one batch, in
new directories. Ten-minute soft budget per execution, six GiB combined output
review limit; inspect consumption before starting the second. Compare settings,
source hash, support, masks, event identity/timing and missingness exactly;
numerical checks use established tolerances, or exact equality where feasible.
Run IDs, dates and paths may differ as provenance. No biological direction or
preferred event count is a target. No extra fixture execution without approval.

Excluded: broad GUI redesign/refactoring, full review-session persistence or
migration, protocol/stimulation/KX work, cohort results, new estimators, detector
tuning, automatic reconstruction of old missing review stages and release
publication. G3/G4 still own broader daily-workflow polish and durable review
sessions. Stop at the G2 demonstration and report remaining limitations.

Before editing, all 495 MATLAB files and affected planning/CI documents were
preserved under `reference-validation/software-g2-workflow-20260923/before-code`
and `before`; all 93 G1 artifacts verified against the prior manifest. Existing
uncommitted changes are retained, with the original diff/status in that packet.

## Entry points and contracts

`Start_OxygenPipeline` → **BOI recording workflow** opens the focused route.
`openBOIRecordingWorkflow(options)` optionally prefills it; it never starts an
analysis automatically. GUI confirmation applies to the displayed preflight.
Batch callers inspect the prepared request and then run explicitly:

```matlab
options = struct('RecordingFolder', '/absolute/path/to/recording', ...
    'OutputFolder', '/absolute/path/to/new-run', ...
    'SampleHz', 1, 'PixelSizeUm', 4.75, ...
    'SupportProfile', 'craniotomy-roi-1');
request = prepareBOIRecordingRequest(options);
% Inspect request.InputReview, request.AnalysisParams and request.SettingOrigins.
result = runBOIRecordingWorkflow(request);
reopened = loadBOIRecordingRun(result.ManifestPath);
```

The numeric values above are illustrative, not universal acquisition defaults.
Supply the actual rate/calibration. Optional Mouse, Condition, DrugID, Genotype
and Promoter labels default explicitly to `unspecified`. Unknown option names
are rejected. The new service explicitly resolves BOI statistics settings and
uses no behavior/stimulation inputs. Legacy CSV configuration remains available;
its `BOISupportProfile` now propagates to the master, retaining `whole-image` as
its compatibility default. Existing CSV GUI state fragmentation remains a later
milestone issue; the G2 selected-run contract governs the new focused route.

`boi-recording-request-1` wraps existing import review, legacy context, master
parameters and source hashes. It does not define a new scientific model.
Before execution, effective inputs are revalidated; changed sources/settings
require a new request. Each run copies selected raw/denoised TIFFs and metadata
sidecars into its own Recording folder. It does not copy old outputs.

`boi-recording-run-1` is an index of the request, both master files, event audit,
statistics, workbook, manifest, audit receipt and code inventory. Artifact hashes
are checked on reopen. `RunStatus.json` distinguishes a complete run from failed
or partial output. The request and original source paths remain historical
provenance. Saved source-image browsing still uses master paths; moving whole
runs and rebinding those paths is not promised in G2.

The event audit reuses `Audit`, `Traces`, `AnalysisInfo` and the existing audit
receipt schema. During a new master run it captures event-footprint corrected
intensity and filtered score directly from existing full-precision stacks, plus
the established site timing trace. Independent raw optical replay must agree
before the audit is marked complete. No trend is refitted and no detection is
rerun for reopening. Old standalone audits missing these stages remain missing.
Zero detected events is retained as an empty event result, not evidence of a
biological zero. Existing boundary/reference revisions and evidence exports
remain separate; `BOIRun.mat` is not a new full review-session format.

## Delivery evidence and stopping point

G2 delivers the approved single-recording slice. New GUI and batch requests share
validation and calculation adapters; new runs include corrected/score evidence;
reopen restores selected-run settings and declared support. The existing event
viewer opens its timing tab first and receives matching master references. The
recording viewer connects both signs to the same audit. No CSV or analysis rerun
is needed to reopen a G2 `BOIRun.mat`.

| Check | Observed result |
|---|---|
| Bounded BOI regression gate, MATLAB R2025a / macOS ARM | 129/129 tests passed, no failed/incomplete tests; 152 s. |
| Final focused request/state/capture/persistence checks | 10/10 passed after final changes (nine repeated tests plus one added zero-event GUI test). No movie analysis. Together with the unchanged prior suites, 130 distinct tests have passing evidence. |
| GUI integration, FX01 ID400 awake | One detector/statistics execution; analysis service about 87 s; entire GUI demonstration about 126 s, including saved review. Corrected and filtered traces available. Both sink/surge window-to-event connections passed. |
| Batch integration, same fixture/settings | One execution; about 89 s including request/service. |
| Numerical regression | 148/148 exact comparisons passed: 74 GUI versus batch and 74 GUI versus preserved G1-era results. Native geometry, event/site tables, timing, missingness, parameters, source metadata/support, statistics tables and captured traces checked. Only recording-path identities and the historical registry alias were normalized; no numeric tolerance was needed (`isequaln`). |
| Saved-result reopening | Fresh workflow window, no selected CSV, zero detector/statistics executions; saved settings and the exact saved support declaration displayed. |
| Budget | Exactly two approved real-recording executions; combined outputs 3,120,902,990 bytes (about 2.91 GiB), within six GiB. No extra recording or detector run. |
| Static review | Incremental changes reviewed against the preserved G1 worktree. The new core files and final GUI/state changes have no MATLAB Code Analyzer messages. |

The initial checks caught an anonymous GUI state accessor retaining its initial
value and a test-runner array construction incompatibility; both were corrected.
A later synthetic fixture incorrectly placed its output under its source and was
properly rejected; its fixture path was corrected. Failure logs are retained in
the local evidence packet. None of these failures changed scientific outputs.
After the two integrations, changes were limited to the selected-run display,
request-schema validation on reopen, directory-creation protection and focused
tests; scientific calculation code was unchanged. Saved-result checks cover those
final presentation changes without a third detector execution.

The implemented code and [compact evidence packet](reference-results/software-g2-workflow-20260923/)
remain in the worktree. Detailed logs, before-code snapshots and both run outputs
are in `reference-validation/software-g2-workflow-20260923/`. The new artifact
record preserves the chain back to the 93 verified G1 artifacts; changed files
have their previous bytes in the before snapshots. No existing source, output,
scientific decision record or uncommitted change was discarded.

## Remaining limits and next gate

- This is a working development slice, not a release or a claim of biological
  ground truth. The researcher has not yet completed the new GUI usability
  walkthrough. Implementation and review were performed by the same assistant;
  there was no independent human or agent code review.
- CI now calls `runBOISoftwareChecks` alongside existing repository checks, but
  the hosted Linux/R2025b job was not executed here. Local evidence is R2025a on
  macOS ARM; release compatibility and peak memory are not established.
- Legacy CSV screens keep their previous state/navigation limitations, including
  SW-08. The new focused workflow clears stale selections and rejects incomplete
  runs; this does not retroactively repair every legacy route.
- Full review sessions, relocation of saved source-image paths, cancellation or
  resume inside a calculation, broader error hardening and release packaging
  remain outside G2. Boundary/reference revisions retain their existing separate
  persistence. Old audits lacking corrected stages are not silently reconstructed.
- Protocol/stimulation information is not collected in this workflow. Existing
  statistics may label empty stimulation inputs “Without stimulation”; that
  inherited label is not evidence that a protocol was absent. No protocol was
  inferred or reconstructed. This fixture's accepted context is preserved.
- Output indexes bind automatic artifacts by hash. Editing them in place is
  rejected on reopen; separate researcher revisions remain the supported route.

**Stop here.** G3 has not started. The next decision is a researcher walkthrough
of this working slice and an explicitly bounded daily-workflow/usability scope.
No additional cohort work or diagnostic campaign follows from G2 completion.
