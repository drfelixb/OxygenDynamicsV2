# OxygenDynamics software backlog

## Current priorities

5 October 2026. Steps 1–5 are accepted within scope; the independent supervision
assessment is complete. The researcher deferred VM isolation, watchdogs and
custom launch qualification to a possible v4. These no longer block the current
version's user-readiness work. The [revised working plan](SOFTWARE_NEXT_STEPS.md)
and current status govern; older dated proposals below are historical.

| Order | Task | Current status |
|---|---|---|
| 1–5 | Calculation explanations/checks, installation candidate and automated protection | Accepted within demonstrated scopes; complete Linux and partial final macOS evidence distinct |
| Accepted within scope | Ordinary installation/saved-result walkthrough and one numerical replay | [Accepted](SOFTWARE_NEXT_07_DELIVERY.md): assistant checks remain distinct from independent researcher feedback |
| Delivered | Portable guides, one updated development candidate and GitHub documentation/scope save | [Documentation/distribution delivery](SOFTWARE_NEXT_07_DISTRIBUTION.md); application calculations unchanged, no active execution |
| Separate decision | Normal MATLAB fresh-recording workflow check and resource observations | Unverified; finite ordinary-workflow proposal permitted without VM/watchdog prerequisite; no run approved |
| Before publication | Applicable licence, citation, dependency notices, support limits and release decision | Open; no public release approval |
| Possible v4 | VM boundary, external watchdog, custom containment and recording-worker release qualification | Deferred out of the current plan; independent findings and failures retained |

**Accepted within demonstrated scope:** selected-run/review workflows; saved
reviewed-pocket calculations and immutable save/reopen/export; the tested viewer
sizes and native controls; automatic amplitude descriptions and contributor counts.
All scientific qualifications, storage-budget exceptions and earlier failures
remain. Legacy paths and broad platform/recording validity are not implied.

The [ready-to-copy first task](SOFTWARE_FIRST_TASK_HANDOFF.md) supplies its exact
scope and budget. The working plan contains handoff instructions for every later
step. Detector refinement, cohort reanalysis, protocol inference and additional
physiological estimators remain outside these next tasks.

## Historical backlog and proposals

26 September 2026 · G1/G2 delivered · SW-G3-01 through SW-G3-03 approved as a partial saved-result slice

Priorities describe product impact, not biological event quality. P1 means a
high-priority correctness/workflow protection gap; P2 means an important usability
or maintainability gap. Findings below are not claims that unexercised paths
have failed at runtime. All changes preserve the accepted scientific behavior
unless separately approved.

| ID / priority | Finding and evidence | Required outcome / acceptance | Proposed milestone / owner |
|---|---|---|---|
| SW-01 / P1 | **Accepted support profile is absent from the normal wrapper context.** `createLegacyRecordingContext` lines 4–15 omit it; master lines 48–50 default to `whole-image`; GUI lines 620–632 do not supply it. G1 runtime context probe confirms the difference from explicit `craniotomy-roi-1`. | One validated request carries explicit profile and source-bound support into the master. GUI/batch effective requests agree. Reject an incompatible/missing required mask clearly. Preserve legacy behavior when explicitly selected; do not silently change detection defaults. | G2 / technical lead |
| SW-02 / P1 | **Default audit creation cannot supply the primary corrected-intensity review trace.** `createBOIEventAudit` passes `reconstructDetection=false`. Tiny existing synthetic fixture reproduces `not_saved` for corrected/filtered stages while optical replay passes. Cached reconstructed ID400 audit does contain them. | In G2 connect or capture the existing corrected/score stages without changing correction. A newly produced run must open the primary trace through the normal workflow, with its source/support identity checked. Old missing evidence stays unavailable. No automatic full-recording reconstruction hidden in a button. | Minimal capture and connected review in G2; full sessions in G4 / core + workflow |
| SW-03 / P1 | **BOI regression tests are not in the CI entry point.** Workflow calls `runRepositoryChecks`; lines 23–45 inspect code and call only the hypoxia/amyloid focused test. G1 explicitly ran 120 selected BOI tests successfully. | Add a bounded BOI test entry point and make CI fail on a relevant test failure. Declare executed/skipped tests and toolboxes. Retain unrelated existing checks; verify headless behavior on the declared CI platform instead of assuming local GUI tests transfer. | G2 for runner/wiring; G5 for platform evidence / validation |
| SW-04 / P2 | **Selected results are fragmented.** GUI `chooseRegressionStatsOutput` lines 561–585 requires a CSV and updates regression/workbook state, not `LastStatsResult`; `openWindowReview` and `runFigures` consult other fields. | One selected-run record drives preview, review, figure/export paths and clear identity. Reopen a compatible existing result without a dummy/new CSV or analysis rerun. Selecting another result clears stale dependent state. | G2 minimal context; G3 polished flow / workflow |
| SW-05 / P2 | **Runtime overrides lack one validated settings boundary.** `applyOxygenDynamicsConfig` rejects unknown config-file fields; `mergeStructs` accepts arbitrary explicit overrides; wrapper and statistics resolve settings separately. | Shared request validation rejects misspelled/unsupported fields, records defaults versus overrides and exposes effective settings. Cover expected overrides and rejected keys. Preserve existing parameter values and documented legacy callers. | G2 / core |
| SW-06 / P2 | **Import requirements differ across stages and remain CSV-led.** Wrapper requires 11 columns; statistics additionally requires `WhiskingFile` and `Puff_2use`. Launcher provides a file chooser, not a guided recording-configuration path. | A single preflight explains requirements for the selected BOI workflow before running. Optional behavior inputs are visibly optional. Establish a minimal single-recording import path using existing contracts without demanding scientific metadata that is not required for the output. | G3 / workflow |
| SW-07 / P2 | **Evidence export and resumable review are distinct but not organized as one user journey.** G1 export succeeded; normal audit loader rejects its `SelectedEventReview.mat`. Sources, native masks, boundaries and reference judgments are separately attached. | Keep evidence bundles and review sessions explicitly labeled. Reopen a session with validated references to the same source/run/revisions; never reinterpret an evidence bundle as a full recording. Relocation/missing-source behavior is clear and tested. Existing immutable boundary snapshots remain the authority. | G4 / workflow + validation |
| SW-08 / P1 | **A failed new statistics attempt can leave the previous result active.** GUI lines 439–476 assign `LastStatsResult` only after successful return; the catch leaves earlier result fields in place, and `setBusy(false)` re-enables result actions based on those fields. Static path finding; failure injection not performed in G1. | Model attempt status and selected result separately. A failed attempt must clearly identify any previous result being shown, never imply it is the failed run's output. Test failure after a successful synthetic/saved result, plus source switching and partial-output handling. | State design in G2; failure hardening in G5 / workflow + validation |

No automatic adoption of a new scientific policy follows from this backlog.
Source locations refer to the unchanged G1 code baseline. The
[baseline report](SOFTWARE_G1_BASELINE.md) links exact runtime evidence.

## G2 proposal — one request and one selected-run context

**User benefit:** the normal MATLAB route can identify exactly what recording,
settings, support profile and result the researcher is working with, while using
the existing calculation engine.

Three bounded implementation items:

1. **SW-G2-01 — Validated recording-analysis request.** Extend existing context
   structures with explicit profile, source/support identity and resolved settings.
   Integrate GUI/wrapper/master adapter without changing scientific formulas or
   global defaults. Address SW-01 and SW-05. Add meaningful request/profile tests.
2. **SW-G2-02 — Selected-run result context.** Centralize paths and identities
   used by preview/window review/export links. Provide a minimal reopen-existing
   result path, clear dependencies when switching, and distinguish an attempted
   run from the previous completed result. Address the core of SW-04/SW-08.
   Capture existing full-precision corrected/score stages during a new run and connect the existing timing viewer. Old missing stages remain unavailable; do not reconstruct them silently.
3. **SW-G2-03 — Repeatable BOI regression gate.** Reuse the selected test suites
   in a maintained repository runner and connect it to CI. Report local versus
   CI-platform evidence separately. Add focused tests for the two integration
   items; no coverage-percentage target or broad test rewrite.

**Preserved:** existing master calculations, thresholds, correction, amplitude
references, tissue interpretations, automatic/reviewed branches, old outputs,
public entry points where practical and source provenance. If an interface
change reveals a scientific-output difference, stop adoption and present it.

**Excluded from G2:** full UI redesign, protocol/stimulation work, cohort runs,
new physiological measures, automatic audit reconstruction, full session migration,
cloud deployment, release publication and replacing the legacy master wholesale.

**Validation proposal:** current bounded BOI tests, small request/state/failure
fixtures and FX01 saved-result reopening. For the final GUI/batch integration
check, propose **at most two new executions of the same FX01 ID400 recording**
(one per entry path), using explicit accepted support and unchanged settings.
Each uses a new output folder and read-only source, with a 10-minute soft budget
per execution and a 6 GiB total new-output review limit. Existing FX01 execution
took about 99 seconds and produced about 1.55 GB before later audits; this is
historical sizing evidence, not a promised runtime or peak-memory bound.
Check budget before another run; stop/reassess rather than expanding the case set.
Approval of this G2 proposal authorizes only those named integration runs.

Acceptance compares source/profile/settings, masks, event identity/timing and
missingness exactly where required; numerical outputs use their established
field-specific tolerances. Run IDs, timestamps and output paths may differ as
versioned provenance. No expected biological direction or historical event count
is an acceptance target. Current GUI/batch result equality has not yet been
demonstrated by G1.

**Owners:** assistant as technical lead/implementer; researcher as product and
scientific owner. An independent reviewer is not yet assigned. This proposal
does not authorize spawning agents. If a human or delegated reviewer participates,
record that role explicitly; otherwise disclose the limitation.

**Delivery sequence:** request/profile contract → selected-result slice → regression
gate and demonstration. Each item must be independently reviewable. Calendar
commitment remains open pending reviewer/team availability; the executable scope
and validation budget above bound the work. Stop at the G2 demonstration and
request approval before G3. The researcher approved the narrowed G2 journey with “Continue” on 23 September. The controlling [G2 work-item record](SOFTWARE_G2_WORKFLOW.md) adds minimal corrected-trace delivery to this slice. On 26 September the researcher approved only [SW-G3-01 through SW-G3-03](SOFTWARE_G3_PARTIAL.md) as a saved-result usability slice; remaining G3 work still needs a separate gate.

## G2 delivery status

See [G2 delivery evidence](SOFTWARE_G2_WORKFLOW.md). SW-01 and SW-05 are addressed
for the shared recording request; explicit wrapper profile propagation is also
implemented. SW-02 is addressed for newly captured runs, and SW-03 has a locally
verified runner plus CI wiring (hosted platform remains unexecuted). SW-04/SW-08
are addressed within the new selected-run workflow; legacy CSV state limitations
remain. Minimal single-recording import from SW-06 is delivered. SW-07 full
review-session persistence stays deferred to G4. This is not a claim that every
backlog item or legacy path is complete. Stop at the G2 gate.
