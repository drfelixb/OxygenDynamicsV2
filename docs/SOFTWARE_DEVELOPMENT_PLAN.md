# OxygenDynamics: software development plan

Version 0.2 · 23 September 2026 · SW-PLAN-001

Approval recorded 23 September 2026: roadmap and G1 accepted (“i approve”). Later milestone gates remain in force.

G1 is complete: [engineering baseline](SOFTWARE_G1_BASELINE.md). The [narrowed G2 slice](SOFTWARE_G2_WORKFLOW.md) was approved by “Continue” on 23 September; [G2 is delivered](SOFTWARE_G2_WORKFLOW.md); work is at its completion gate.

**Product direction, roadmap, G1 and the narrowed G2 slice are approved.**
The researcher [accepted G3's demonstrated daily-use workflow for usability](SOFTWARE_G3_USABILITY_ACCEPTANCE.md) on 27 September 2026. This does not validate a fresh real-acquisition run or every failure path and is not release approval. Analysis/statistics failures, incomplete-run recovery and relevant real-acquisition checks move to bounded G5 release work. [SW-G4-01 through SW-G4-04 were approved](SOFTWARE_G4_PROPOSAL.md) with zero new detector/statistics runs; [exact replay targets](SOFTWARE_G4_REPLAY_TARGETS.md) were recorded before implementation. The researcher accepted the [bounded G4 delivery](SOFTWARE_G4_DELIVERY.md) for usability of the specific C02 review, the ID400 measurement explanations and readable export. This does not establish all-recording or all-metric validity. [SW-G5-01 through SW-G5-03 were approved](SOFTWARE_G5_PROPOSAL.md) under two synthetic attempts, one small synthetic detector and zero recorded runs; the researcher accepted only the statistics boundary and saved incomplete-run recovery evidence from the [first-slice delivery](SOFTWARE_G5_FIRST_SLICE_DELIVERY.md). A separate, approved [SW-G5-04 test-only live analysis boundary check](SOFTWARE_G5_04_DELIVERY.md) was accepted for that boundary evidence only. The researcher accepted the [eight-case SW-G5-05 delivery](SOFTWARE_G5_05_DELIVERY.md) within its zero-run budget, with the initial discovery defect retained. The researcher approved [SW-G5-06 alone](SOFTWARE_G5_06_PRE_RUN_PROPOSAL.md) on 28 September 2026 for one supervised, named real-acquisition attempt under its revised process-isolation and resource limits. SW-G5-07, G5 acceptance and release remain unapproved. No team has been launched by writing this plan.

**Current gate (1 October 2026):** [CC-02U delivered](SOFTWARE_CC_02_USABILITY_COMPLETION_DELIVERY.md), with all six focused layout/native-chooser/preservation checks passing within twelve recorded evaluations. The researcher accepted the bounded workflow at 1120 × 800 and 900 × 650, including demonstrated native selections and cancellations. Both CC-02 usability items are closed within that scope; all documented limitations remain. No further checks, launches or implementation are authorized. Release remains paused; overall usability, G5 and release are unaccepted.

**Current delivery (1 October 2026):** [Automatic amplitude and summary export clarification delivered](SOFTWARE_AUTOMATIC_AMPLITUDE_EXPORT_DELIVERY.md): final 9/9 saved/synthetic cases passed; formulas, existing values and column identifiers preserved. The [pre-execution budget](SOFTWARE_AUTOMATIC_AMPLITUDE_EXPORT_TASK.md) storage ceiling was exceeded and is disclosed; earlier duplicate artifacts were losslessly compressed. No further tests, launches or campaign are planned. The researcher accepted this clarification within its demonstrated scope on **4 October 2026**, retaining the storage-budget exception, earlier failures and scientific limitations. **Development and release are paused.** No further verification or analysis task is authorized automatically; await a new explicit researcher requirement. Live-run containment remains paused.

**Next work proposal (4 October 2026):** the [software priorities and working plan](SOFTWARE_NEXT_STEPS.md) orders seven practical steps, starting with saving the accepted software and reconciling its development identity, then checking duration/area/occupancy and the remaining summaries. It includes a proposed version policy, bounded task budgets and handoffs. The [first-task handoff](SOFTWARE_FIRST_TASK_HANDOFF.md) is ready for a separate step-1 approval. Preparing these documents authorizes planning only; no implementation, tests, MATLAB, package build, commit/push or release action has started. Development and release remain paused.

**Step-1 authorization (4 October 2026):** the researcher approved saving accepted
software and establishing `3.1.0-dev.1`, including routine repairs and normal
commit/push to `development-existing-analysis-v3`. Only NEXT-01 is active;
[its record](SOFTWARE_NEXT_01_DELIVERY.md) defines the static-only checks and
90-minute/two-commit/one-push/5-MiB limits. The preceding paused/proposal
statements describe earlier gates. No calculation work, MATLAB, tests, package,
recording, release or step-2 work is authorized.

## 1. Product goal

Deliver a maintainable MATLAB application in which a researcher can load a BOI
recording, check its metadata and tissue support, run the established analysis,
inspect and revise event judgments, and export understandable, reproducible
results without reconstructing paths, scripts or development history.

Success is demonstrated by a working researcher journey and reliable numerical
behavior. Completing cohort analyses, reproducing a publication figure or
maximizing the number of detected events is not the product goal.

Use the [researcher workflow and traceability contract](RESEARCHER_WORKFLOW_AND_TRACEABILITY.md)
as the product acceptance foundation. The [measurement dictionary](BOI_MEASUREMENT_DICTIONARY.md)
and [working measurement specification](BOI_WORKING_ANALYSIS_SPECIFICATION.md)
describe current meanings and unresolved science. The older reanalysis plan,
cohort roadmap and completed C02 reports remain historical evidence; their
cohort-completion requirements do not govern this software release.

## 2. Current starting point

This is an existing implementation to professionalize incrementally, not an
empty project. The planning inspection found:

| Observed implementation | Planning implication |
|---|---|
| `OxygenDynamics_GUI.m`: 1,409 lines, shared state and nested callbacks; import review, measurements and result panels already exist. | Map the real user journey and state transitions before splitting code or redesigning screens. File length is a review signal, not proof of a defect. |
| `OxygenDynamics_Master.m`: 493 lines; `runOxygenDynamicsStats.m`: 550 lines, supported by many helpers. | Identify stable orchestration and calculation boundaries; reuse the engine. |
| Saved event review, metadata/support contracts, dictionaries, source hashes and output schemas already exist. | Connect and consolidate them; avoid a parallel review or provenance framework. |
| The saved verification inventory contains 495 MATLAB files and extensive existing changes. | Preserve the current worktree and classify production, experimental and test code before restructuring. |
| GitHub CI targets MATLAB R2025b on Linux; recent local evidence uses R2025a on macOS. | Establish a declared support matrix and check it. A green historical run does not establish current compatibility. |
| README contains extensive experiment history and historical test counts. | Give users a short current entry point; keep history linked separately and report fresh checks accurately. |

This is a planning inspection, not a completed code-quality, security or
performance audit. There was no new detector run or fresh test-suite execution
to support this plan.

## 3. Scope and scientific boundaries

**In scope:** the MATLAB BOI application, its analysis engine and existing
supported inputs, configuration and parameter explanations, researcher review,
saved results, error handling, reproducibility, bounded tests, documentation,
packaging and maintainability. Both sink and surge results remain supported.
Existing batch capability stays available and shares calculation code with the
GUI; a new batch orchestration platform is not an implied requirement.

**Deferred:** cohort reanalysis, treatment comparisons, scientific manuscript
results, KX whisker analysis, stimulation-window reconstruction, new protocol
inference, IOSI, a replacement detector, new physiological estimators, cloud/web
deployment and a MATLAB-free rewrite. Existing experimental capabilities and
outputs are preserved; deferring work is not permission to delete them.

Your fixed stimulation protocol can become an explicit configuration requirement
in a later approved milestone. We will not infer it from recordings or build a
generic protocol engine now.

Standing scientific requirements:

- Keep biological variability and difficult signals visible. Accepted detector
  imperfections do not trigger another optimization campaign.
- Preserve original recording-specific correction. No universal substrate
  decline model or adjustment to obtain expected effects.
- For the supplied recordings, externally controlled 1 Hz takes precedence over
  unreliable embedded timestamps. Store timing authority, frame/time mapping and
  unknown camera exposure separately. Do not hard-code all future inputs to 1 Hz.
- Use source-specific craniotomy support, including dark interior tissue and
  uncertain edges; do not define anatomy from bright pixels or image corners.
- Corrected intensity leads visual review; detection score supports it; raw
  intensity/trend checks correction. Quantitative optical sources retain their
  existing definition and must not be silently replaced by the displayed trace.
- Keep automatic detections, human judgments and reviewed measurements distinct.
  Preserve negative finite values, unavailable values and their reasons. Missing
  amplitude must not erase otherwise available event counts or coverage.
- Version meaningful calculation changes. Unknown biology remains unknown;
  numerical agreement is not physiological ground truth.

## 4. How I would organize a small team

Use three engineering roles, with you as product/scientific owner. Roles may be
combined in a smaller team; they do not require three full-time hires.

| Role | Accountability | Boundary |
|---|---|---|
| Product/scientific owner — researcher | Priorities, workflow acceptance, interpretation, scientific defaults and scope decisions. | The team prepares concrete choices; it does not transfer implementation minutiae to you. |
| Technical lead / core engineer | Architecture, numerical contracts, integration, bounded work selection and preservation of existing behavior. | Cannot approve a new scientific method or product scope on your behalf. |
| Workflow engineer | GUI state, import/review/run/inspect/export flow, persistence and user-facing errors. | Uses the same engine and data contracts as batch execution. |
| Validation/release engineer | Regression fixtures, independent numerical checks, compatibility, performance evidence and release package. | Does not tune the implementation to make a preferred biological result pass. |

The technical lead owns integration. The author of a calculation, persistence or
schema change should not be its sole reviewer when another engineer is available.
If working alone, report that limitation; an automated replay is not an
independent human review. A researcher unfamiliar with development participates
in the final usability demonstration.

One delivery milestone is active at a time. At most two implementation items
run concurrently when their files/contracts are independent. Core interfaces
are agreed before parallel edits. No agents or additional tasks are spawned
merely because this document describes a team.

## 5. Goals, subgoals and completion gates

### G0 — Agree the product and operating boundaries

**Outcome:** one current mission, a bounded first release and an approval record.

- G0.1 Record software development as the active objective; supersede stale cohort next steps.
- G0.2 Agree the priority user journey and the existing scientific behavior to preserve.
- G0.3 Separate required release capabilities from later requests and scientific questions.
- G0.4 Approve G1's scope and stopping condition before implementation begins.

**Done when:** the plan and first milestone are explicitly accepted; the active
status identifies the approved milestone. **Now:** plan and guardrails approved on 23 September; G1 authorized.

### G1 — Establish an engineering baseline and a bounded backlog

**Outcome:** know what works, what is fragmented and what is actually broken.

- G1.1 Map launch → import → preflight → run → inspect → revise → reopen → export
  through actual functions and saved artifacts. Identify manual path selection,
  hidden dependencies and ambiguous application state.
- G1.2 Classify production, experiment, legacy and test entry points without
  moving/deleting files. Inventory uncommitted changes and the protected baseline.
- G1.3 Run the relevant existing fast checks; label passed, failed, skipped and
  untested separately. Review CI dependencies and local/CI version differences.
- G1.4 Propose at most three existing regression recordings, chosen for software
  coverage: representative workflow, differing scale/support or missingness, and
  a local non-DANDI input. Reuse cached outputs and small synthetic fixtures first.
- G1.5 Produce a severity-ranked backlog and a recommended first implementation
  slice. Each finding must cite a reproducible failure or concrete user obstacle.

**Acceptance:** a concise system map, current verification summary, fixture
proposal and at most ten prioritized issues. Distinguish an implemented feature
from one demonstrated end to end. No open-ended audit and no cohort analysis.

**Stop:** deliver those four artifacts and propose G2. No detector optimization,
source-data campaign, broad cleanup or dependency upgrades. The default G1
validation uses saved results and bounded synthetic/unit checks; no full movie
detector execution is included without a named, approved test case and budget.

### G2 — Establish stable software boundaries through one working slice

**Outcome:** one recording travels through a coherent application path using the
existing engine, with interfaces that can be tested independently of the GUI.

- G2.1 Define explicit recording, configuration, run-result and review-revision
  contracts by extending existing structures; avoid introducing a competing schema.
- G2.2 Separate GUI callbacks/state from orchestration and scientific calculations
  only where the first slice needs it. Keep existing entry points/adapters working.
- G2.3 Centralize settings resolution and validation so GUI and batch agree.
  Display default/override provenance and scientific meaning.
- G2.4 Make the selected recording/run/revision explicit, with valid transitions
  and no stale results carried into a newly selected input.

**Acceptance:** the same approved fixture and configuration produce equivalent
scientific outputs through GUI and batch. IDs, masks, event timing, missingness
and metadata are identical where exact equality is required; established
field-specific numeric tolerances apply elsewhere. No blanket permissive tolerance.

**Stop:** the vertical slice and contracts are reviewable. Architecture changes
must earn their place by this use case; a repository-wide rewrite is excluded.

### G3 — Make the daily researcher workflow coherent

**Outcome:** routine use does not require remembering development scripts/paths.

- G3.1 Provide one clear entry point with new analysis and reopen-existing-result
  paths, retaining the current supported input routes.
- G3.2 Show identity, timing authority, calibration and tissue support before
  running; separate missing data, warnings and blocking input errors.
- G3.3 Show the selected settings, output destination and overwrite/version
  behavior before a run. Surface progress and actionable failures.
- G3.4 Open the relevant event/recording review directly from the selected run.
  Retain the corrected/raw/score roles already established with the researcher.
- G3.5 Make save, reopen and export discoverable and verify that they target the
  intended source/run/revision.

**Acceptance:** a scripted user journey completes import, preflight, run,
inspection and reopen/export using documented UI controls; no manual source
editing or hunting for generated files. At the milestone demo, you judge whether
the flow is usable. A clear error replaces an invalid action or stale result.

**Stop:** the agreed journey works. Additional dashboards, protocol editors and
visual redesign requests enter the backlog rather than expanding this milestone.

### G4 — Make review decisions and results durable and explainable

**Outcome:** a saved result can be understood and reproduced after the session.

- G4.1 Persist event judgments, boundary alternatives, reference choices and
  uncertain tissue decisions with source/run IDs, actor, reason and revision.
- G4.2 Reopen automatic and reviewed results without silently recomputing or
  replacing either. Existing files need an explicit compatibility/migration path.
- G4.3 Connect each measurement to units, source signal, spatial support,
  baseline, numerator/denominator, relevant settings and unavailable reasons.
- G4.4 Produce a compact readable export and structured provenance from the
  shared dictionary and saved calculation ingredients.

**Acceptance:** save–close–reopen preserves judgments exactly; a reviewer can
trace one event and one recording summary to saved ingredients and reproduce
them within declared tolerance. A changed setting or judgment produces a new
explainable revision while the previous result remains intact. Exported source
links remain usable after moving the result folder where relocation is supported.

**Stop:** this evidence is available for the agreed examples. No exhaustive
manual labeling or new physiological recovery estimator is required.

### G5 — Harden reliability, testing and compatibility

**Outcome:** predictable failure handling and a release candidate with evidence.

- G5.1 Test invalid/missing metadata, disconnected/missing source files, corrupt
  or incompatible results, zero-event recordings, missing baselines and both signs.
- G5.2 Define run lifecycle and partial-output rules. Prevent partial runs from
  looking complete; preserve recoverable evidence. Use safe cancellation between
  stages where feasible; mid-stage resume is a separate requirement if necessary.
- G5.3 Measure runtime and peak memory on approved fixtures. Define a documented
  support envelope and budgets based on evidence, not an invented speed target.
- G5.4 Reconcile MATLAB/toolbox/OS support with CI; run focused tests per change,
  integration checks at milestones and the approved release matrix at release.
- G5.5 Check result version compatibility, no-overwrite behavior, dependency
  licensing and absence of bundled private recordings or machine-specific paths.

**G3 acceptance handoff:** bound and check analysis- and statistics-stage
failures, incomplete-run recovery and relevant real-acquisition behavior in G5.
The G3 staging check and synthetic success do not establish those paths; each
G5 check needs its own fixture, run budget and approval before execution.

**Acceptance:** no known unresolved data-loss, source-mixup, silent calculation
corruption or approved-workflow blocking defect. Nonblocking limitations are
listed and accepted. Relevant automated checks pass; unsupported/untested
platforms are labeled honestly. A failed run has a clear status and next action.

**Stop:** agreed release checks pass. Do not rerun all historical experiments
or create performance optimization work without a measured release blocker.

### G6 — Deliver and demonstrate the software release

**Outcome:** a versioned MATLAB package that another researcher can use.

- G6.1 Provide installation/dependency instructions, a short quick start,
  example configuration and a concise measurement/review guide.
- G6.2 Package the required software, schemas and appropriately licensed small
  fixtures; keep bulky/private development evidence outside the release package.
- G6.3 Complete an unfamiliar-researcher walkthrough, including one local input;
  have a second person reproduce one numerical result from exported ingredients.
- G6.4 Publish release notes, supported versions, known limitations and migration
  instructions. Prepare a version/tag/release candidate for your final approval.

**Acceptance:** fresh-install walkthrough succeeds, results/reviews reopen, the
independent replay succeeds, and the product owner accepts essential usability
and scientific limitations. Publication/merge is explicitly approved before action.

**Stop:** agreed release delivered; additional features belong to a subsequent
version. Completion does not require reanalyzing your full dataset.

## 6. Intended architecture and sequencing

Use the existing MATLAB implementation with clear responsibilities:

`GUI / batch entry points → application services → existing analysis engine`

`application services ↔ versioned recording / settings / result / review storage`

`results + shared measurement dictionary → inspection and export`

The GUI owns presentation and user intent; services own the run/review lifecycle;
the analysis engine owns scientific calculations; storage owns versioning and
durability. These are responsibilities, not a commitment to a class hierarchy,
new framework or renamed directory tree. Small refactors proceed with regression
evidence and existing-call compatibility.

Sequence: G0 → G1 → G2 → G3/G4 → G5 → G6. Testing and documentation accompany
every change; G5 is the release hardening pass, not the first time tests are written.
G3 and G4 may have independent parallel items after their shared contracts are
stable. Use one demonstrable end-to-end slice before broadening functionality.

## 7. Approval boundaries that prevent drift

| Team can decide within an approved milestone | Ask the researcher before proceeding |
|---|---|
| Function organization, naming, small refactors, error text and targeted tests that preserve behavior. | Detector/correction/baseline defaults, measurement meaning, source authority or other output-changing scientific rules. |
| Fix a reproducible UI/persistence problem and verify it against the approved task. | Adopt a scientific-output fix after reviewing its impact, even if it was discovered during engineering. |
| Reuse agreed fixtures for specified software checks within their budget. | Add an external dataset campaign, cohort rerun, scientific comparison or additional diagnostic program. |
| Choose implementation details for agreed MATLAB capabilities. | Add protocol inference, KX whisker/stimulation work, another platform or a major rewrite. |
| Prepare a reviewable patch, candidate release and migration proposal. | Publish/merge a release, perform destructive migration, or overwrite original data/results. |
| Complete remaining items inside the currently approved milestone. | Start a new milestone or materially increase scope/resources beyond its agreed envelope. |

**Continuation rule:** "go on" means continue the current approved software
work. It does not authorize a new analysis objective. At a boundary, present the
named next milestone and obtain approval specific to that scope. An explicit
"go on with G2 as proposed" is sufficient; formal paperwork is not required.
Do not repeatedly ask about routine engineering choices inside that agreement.

For a boundary-crossing proposal, provide: the user problem; proposed change;
affected code/results/scientific meaning; validation cases and resource budget;
what happens if deferred; and the precise approval needed. Prepare concrete
read-only evidence or a contained candidate patch where authorized, but do not
run the out-of-scope analysis while waiting. Silence is not consent.

Unresolved science goes into a parked decision register with its affected
capability. It blocks only that capability, unless there is a demonstrated
consequence elsewhere. A failed gate triggers a bounded fix, deferral or explicit
scope decision—not an automatically invented diagnostic phase.

## 8. Work-item and team cadence

Keep one prioritized backlog linked to this plan. Every item records:

| Field | Required content |
|---|---|
| ID / parent goal | For example SW-G2-01, not an unnamed next step. |
| User problem and expected behavior | Concrete before/after; one reviewable outcome. |
| Scope and exclusions | Affected components, scientific behavior held fixed, explicit non-goals. |
| Owner / reviewer | Who implements and who checks; disclose combined roles. |
| Dependencies / approval | Existing contract, prerequisite and approval status. |
| Validation and budget | Named fixtures/checks, tolerances, maximum full runs/time/storage, stopping condition. |
| Done evidence | Patch, demonstration, verification result, documentation and remaining limits. |

Use small reviewable changes, not a months-long rewrite branch. Preserve the
current uncommitted baseline before edits; choose branches/worktrees based on
that baseline so no existing work is accidentally dropped. Separate scientific
behavior changes from structural changes. Do not make automatic cleanup commits
or push existing work merely to obtain a tidy repository.

For an actual small team: short coordination around blockers during active work,
one working-software demonstration each week, and a milestone review at the gate.
For our interaction: report the current goal/item, what now works, what was
verified and what remains. Do not turn every internal check into a new numbered
project phase. Prefer one concise status record over repeated large narratives.

Each milestone is divided into slices small enough for a weekly demonstration;
if it cannot be demonstrated, split it before committing. Calendar estimates and
a release date follow G1, when team availability, dependencies and the actual
backlog are known. The first planning commitment is a bounded G1 deliverable,
not a speculative completion percentage or delivery date.

## 9. Universal definition of done

A software item is done when its agreed behavior works; the relevant checks
pass; scientific behavior is preserved or its change explicitly approved;
errors and missing states are understandable; original data/results and review
history survive; code has the required review; and user/developer documentation
matches the change. Record untested paths and remaining risks rather than
claiming blanket validation. Numerical checks and UI acceptance have distinct roles.

Do not add tests that merely restate implementation details or retest every
historical experiment. Favor meaningful contract, numerical-invariant,
save/reopen, GUI/batch consistency and failure-path checks. Large recorded movies
are limited integration fixtures; small deterministic examples belong in routine CI.

## 10. Immediate next decision

**G1 and the approved narrowed G2 slice are complete.** See the [G2 delivery
record](SOFTWARE_G2_WORKFLOW.md). The [G3 usability acceptance](SOFTWARE_G3_USABILITY_ACCEPTANCE.md)
records the researcher's decision on the demonstrated daily-use workflow:
saved-result selection, inspection and export; pre-run presentation; one small
synthetic end-to-end run with visible stages; native chooser and MATLAB workbook
launch on the saved G2 result; and one staging-only failure with accepted wording.
No G3 tests follow this decision. It is **usability acceptance with explicit
evidence limits**, not validation of a fresh real-acquisition run, analysis- or
statistics-stage failure behavior, incomplete-run recovery or release readiness.
Those checks are handed to bounded G5 release work, with separate approval and
budgets. No cohort analysis or scientific-method change is implied.

**G4 gate:** the researcher approved [SW-G4-01 through SW-G4-04](SOFTWARE_G4_PROPOSAL.md)
under named saved fixtures and a zero-run budget. The [two numerical replay
targets](SOFTWARE_G4_REPLAY_TARGETS.md) and C02 row 186 unavailable-amplitude
case were recorded before coding. The [bounded delivery](SOFTWARE_G4_DELIVERY.md)
links existing review revisions, reopens automatic/reviewed evidence without
recomputation, replays the two numbers from saved ingredients and exports a
readable/structured portable snapshot. The local BOI gate passed 134/134 with
zero new detector/statistics executions. The researcher accepted the specific
C02 review and the displayed ID400 measurement explanations and readable export
as usable. The **bounded named-example G4 usability gate is closed**; general
legacy migration, all-recording validation and all-metric reporting are not
claimed. This was assistant self-review, with no independent human code review.

**G5 first-slice result:** the researcher approved [SW-G5-01 through SW-G5-03](SOFTWARE_G5_PROPOSAL.md)
with two disposable synthetic failure attempts, at most one small synthetic
detector execution and zero recorded runs. The [pre-run fault contract](SOFTWARE_G5_FAULT_CONTRACT.md)
and [delivery](SOFTWARE_G5_FIRST_SLICE_DELIVERY.md) record both preserved
incomplete folders, visible stage/error/recovery messages, rejection as
completed runs, same-GUI new-output preflight and the local 135/135 BOI gate.
The analysis test double raised a MATLAB output-signature error instead of its
planned custom exception; it was **not rerun**. No engine defect is claimed.
The researcher accepted the **statistics boundary failure and saved incomplete-run
recovery** within their stated limits, and explicitly classified **live analysis
failure feedback as untested**. Generic internal-error guidance was then revised
and checked against the two preserved saved failures, with zero new attempts or
detector runs; the accepted staging source-missing wording was preserved.

**SW-G5-04 delivery:** the separately approved [single guarded attempt](SOFTWARE_G5_04_DELIVERY.md)
used a new disposable synthetic source and one-output shadow. It produced the
intended injected error, a **live** analysis-failure GUI capture and matching
`failed`/`analysis` status; the incomplete folder was rejected as complete.
No detector or recorded movie ran, and the two earlier attempts were unchanged.
This demonstrates a test-only delegate boundary, not an internal master error.
The researcher accepted this as **live analysis-boundary failure evidence only**. It does not test errors inside the real detector/master, complete G5 or approve release.

**SW-G5-05 delivery:** the researcher approved the [eight named saved/small-fixture cases](SOFTWARE_G5_05_FIXTURE_MATRIX.md)
with zero detector, statistics and recorded-movie runs. The [delivery](SOFTWARE_G5_05_DELIVERY.md)
reports pass/fail/untested for each. An unsupported run version was first offered
by discovery despite direct-open rejection; this was counted as a defect and
fixed before final acceptance checks. Focused tests passed 16/16 and the one
local BOI gate passed 136/136. The originals remain unchanged. The researcher
accepted this named software-contract evidence only; it is not G5 or release
acceptance.

**SW-G5-06 pre-Run guard stop:** the researcher approved the [exact real-acquisition card](SOFTWARE_G5_06_PRE_RUN_PROPOSAL.md)
for one named, supervised ID400 awake attempt. The [execution record](SOFTWARE_G5_06_EXECUTION.md) documents a safe stop during disposable MATLAB startup: a descendant left the isolated process group before Run release. No `ui.Run()`, detector, statistics or recorded movie executed, and no output folder was created. The researcher accepted this stop and untested classification. The researcher then approved [SW-G5-06R-01/02 isolation implementation and up to three synthetic process-tree checks](SOFTWARE_G5_06_ISOLATION_REVISION_PROPOSAL.md), followed by one separately approved startup-only MATLAB diagnostic. That one diagnostic is complete; any further MATLAB or recorded-movie run remains unapproved. The real-acquisition integration/resource check remains untested; there is no retry under the old approval. The [remaining G5 work](SOFTWARE_G5_NEXT_PROPOSAL.md), including SW-G5-07 support/release audit and any revised real-run attempt, requires a separate decision. Engine-internal failure paths, compatibility and release checks remain open. No G5 or release acceptance has been given.

The [SW-G5-06R delivery](SOFTWARE_G5_06R_DELIVERY.md) retains two initial passing synthetic checks and the failed initial reparenting check. An exit-time identity-classification bug was corrected and covered by saved-fixture tests. The researcher separately approved one reparenting-only synthetic recheck; it passed within 1.86 seconds with the unrelated sentinel preserved and no live tracked child. The researcher then approved [one startup-only MATLAB diagnostic](SOFTWARE_G5_06R_STARTUP_DIAGNOSTIC.md), with no Run or retry and cleanup inside its 90-second cap. That diagnostic identified and separately stopped an out-of-group `system_profiler` descendant under MATLABWindow. Its worker was not ready, and no recorded-movie run is authorized or validated. The researcher approved the [SW-G5-06R-03 decision card](SOFTWARE_G5_06R_03_DECISION_CARD.md) for implementation and seven saved-fixture cases (at most twelve evaluations), with no process launch. Its [bounded delivery](SOFTWARE_G5_06R_03_DELIVERY.md) records 12/12 saved-fixture passes for the tested policy, followed by two statically reviewed fail-closed guards that were not re-evaluated under that consumed budget. The researcher separately approved the [SW-G5-06R-04 offline decision card](SOFTWARE_G5_06R_04_OFFLINE_PROPOSAL.md) for six cases/eight saved-data evaluations. The [offline delivery](SOFTWARE_G5_06R_04_DELIVERY.md) records 8/8 passes on the final policy and a new controller decision path: startup and fresh final policy checks, one in-memory positive intent and no live release. The consumed one-use supervisor was not changed, and no live caller or recorded run is authorized. Any future live writer connection, startup diagnostic or recorded-run attempt requires a separate decision.

The researcher accepted SW-G5-06R-04 as **offline evidence only** and requested a one-shot intent fix before any live-writer decision. [SW-G5-06R-05](SOFTWARE_G5_06R_05_DELIVERY.md) passed its two named saved-data evaluations without retry: a second fresh call after success was rejected, and a sink exception after a simulated in-memory side effect left the shared claim consumed and blocked a recreated controller. There was no process/MATLAB launch or Run release. The researcher then approved the revised [SW-G5-06R-06 five-case filesystem card](SOFTWARE_G5_06R_06_LIVE_WRITER_PROPOSAL.md). Its [bounded delivery](SOFTWARE_G5_06R_06_DELIVERY.md) records **5/5 passes** for durable claim/token behavior, including separate preexisting claim, preexisting token and mismatched payload identity cases. These are disposable filesystem tokens with no waiting worker; no live Run occurred. A live caller, renewed SW-G5-06 attempt, SW-G5-07, G5 acceptance and release remain unapproved.

The researcher accepted SW-G5-06R-06 as **filesystem-only evidence**, not a live release, and approved the bounded [SW-G5-06R-07 startup-only card](SOFTWARE_G5_06R_07_STARTUP_ONLY_PROPOSAL.md): a new no-Run worker and versioned acknowledgement handshake, eight one-use offline schema cases, and one MATLAB startup only after clean static/offline gates. The [partial delivery](SOFTWARE_G5_06R_07_PARTIAL.md) records 8/8 saved-data schema passes, followed by two caller corrections from self-review. Because the final caller hash differs from the tested hash, the static final-code gate failed closed before MATLAB launch. The conditional startup and live acknowledgement remain untested; no proposed output was created. Any further offline re-evaluation needs a bounded decision. Actual Run-token integration and any named recorded-movie attempt remain separate decisions.

The researcher accepted that prelaunch stop and approved a final-code offline recheck only. The [recheck record](SOFTWARE_G5_06R_07_FINAL_CODE_OFFLINE_RECHECK.md) reports **10/10** one-use saved-data evaluations on pinned code hashes: the eight schema cases plus slow-sample and prompt-exit caller cases. The final-code static gate now passes. There was no child process or MATLAB launch, live token, attempt marker or proposed recording output. The unspent startup launch needs a separate decision; this offline result does not close live containment/acknowledgement, real-acquisition integration, SW-G5-07, G5 or release.

The researcher then **held that launch** after identifying that the final process snapshot was captured before a repeated preflight. The [SW-G5-06R-07B boundary revision and offline gate card](SOFTWARE_G5_06R_07B_PREFLIGHT_BOUNDARY_PROPOSAL.md) move final capture behind all potentially slow preflight work and reject a snapshot predating completed preflight. The earlier 10/10 matrix no longer matched the changed hashes, so the static gate initially failed closed. No MATLAB launch was made under this revision.

The researcher approved that one-use matrix under no-launch limits. The [SW-G5-06R-07B offline delivery](SOFTWARE_G5_06R_07B_OFFLINE_DELIVERY.md) records **13/13** saved-data passes on ten pinned executable/harness hashes, including stale-snapshot rejection after delayed preflight, a >1-second final monitor-gap stop, and one fresh-snapshot disposable token path. The updated static gate passed afterward without code drift. No child process, MATLAB session, live worker token or proposed recording output was created. The unspent startup launch remains held for a separate decision; there is still no live acknowledgement, recorded-movie integration, G5 acceptance or release approval.

The researcher accepted that **13/13 as evidence for its original hashes only** and kept the MATLAB launch held. [SW-G5-06R-07C](SOFTWARE_G5_06R_07C_TOKEN_DEADLINE_DELIVERY.md) moved the absolute 65-second token deadline into the startup writer and passed one pinned, one-use saved-data check: a final snapshot at 64.8 s followed by a writer call at 65.05 s left one consumed claim and **zero tokens**. The revised code hashes matched before and after that check, but differ from the 13-case hashes. The live 13-case static gate therefore fails closed; the new one-case result is narrow deadline evidence, not a revised 13-case pass or startup authorization. No process/MATLAB launch, live token or recording output occurred. The held startup, live acknowledgement, recorded-movie integration, G5 acceptance and release remain open.

The [SW-G5-06R-07D final-code offline gate card](SOFTWARE_G5_06R_07D_FINAL_CODE_OFFLINE_GATE_PROPOSAL.md) specified the prior 13 cases plus the late-token case once each, at most 14 saved-data evaluations and zero process/MATLAB launches. It required deadline-enabled writer configuration on every token-producing path and exact final executable/harness hashes pinned before testing. A token whose filesystem publication finishes at or after 65 seconds is classified incomplete; a pre-write check does not establish completion time.

The researcher approved that exact offline budget. The [SW-G5-06R-07D delivery](SOFTWARE_G5_06R_07D_FINAL_CODE_OFFLINE_DELIVERY.md) records **14/14 one-use saved-data passes** on 13 pinned executable/harness hashes, with identical pre/post hashes and a passing read-only live static gate. All token-producing fixtures exercised the deadline-enabled writer. The late writer case left one consumed claim and zero tokens; the caller's post-return late-completion rule classified an otherwise valid acknowledgement as incomplete. No process or MATLAB launched, no live worker token or proposed recording output was created, and no case in the matrix was left untested. A slow filesystem publication spanning the deadline and live MATLAB acknowledgement remain untested. The startup stays held; passing this gate is not launch, G5 or release approval.

The researcher then separately approved **one startup-only MATLAB launch** under SW-G5-06R-07. The [saved attempt](SOFTWARE_G5_06R_07_STARTUP_ATTEMPT.md) stopped incomplete at 17.15 seconds when a `(java_home)` child appeared in the new MATLAB group but could not be assigned a precise birth identity. No ready receipt, claim, token, acknowledgement, Run call or proposed output was created. The stop report recorded two clean snapshots and no remaining verified PIDs, yet classified cleanup as `containment_failure` because the group had an unverified member; a later read-only process snapshot found no live group or that PID. The single launch is consumed with no retry. Live acknowledgement, a clean containment classification, real-acquisition integration, SW-G5-07, G5 acceptance and release remain open; any further launch needs a new bounded decision.

The researcher accepts the 17.15-second attempt as **fail-closed and incomplete**, retaining its formal `containment_failure` and consumed approval. The [SW-G5-06R-08 saved-data proposal](SOFTWARE_G5_06R_08_UNIDENTIFIABLE_CHILD_PROPOSAL.md) specifies structured libproc versus session-ID diagnostics and ten one-use offline cases for disappearance, persistence, identity change, escape and insufficient observations. It adds no name-based exception or successful release path: ownership uncertainty still fails closed. This is **planning only**; no implementation, tests or launch are authorized. A new approval is required before the proposed slice, and any future live attempt remains a separate decision.

The researcher then approved **SW-G5-06R-08 implementation and ten one-use saved-data evaluations**, requiring incomplete libproc responses to provide no verified birth identity. The [delivery](SOFTWARE_G5_06R_08_DELIVERY.md) records **10/10 passes**, no retries, five pinned code/dependency/harness/fixture files and eight historical packet files unchanged through the final hash gate. Structured libproc versus SID diagnosis, fresh-table classifications and guard rejection paths were exercised through injected adapters only; no native lookup, signal, child/MATLAB launch, token or recording run occurred. The historical `containment_failure` remains unchanged. Native adapter and full cleanup-loop behavior are untested, and prior release gates do not validate these changed guard hashes. The offline budget is consumed; researcher acceptance is pending, with no further live work proposed or authorized.

The researcher **accepted SW-G5-06R-08 as bounded offline diagnostic evidence only**. The historical `containment_failure` and exhausted startup approval remain unchanged; startup, G5 and release are not complete. The [planning decision](SOFTWARE_G5_REAL_ACQUISITION_GATE_DECISION.md) recommends deferring the real-acquisition gate as an explicit release blocker rather than automatically continuing diagnostics. The alternative is a separately approved independent containment review before considering further implementation or a live-attempt proposal. This choice is pending; no reviewer engagement, implementation, checks, launch or automatic retry is authorized.

The researcher **chose to defer the real-acquisition gate**. Successful live acknowledgement, verified containment and real-acquisition resource measurements are now separately recorded as **open release blockers**; integration also remains unverified. Historical `containment_failure` and consumed launch approval remain unchanged. No further containment diagnostics, MATLAB startup or retry is authorized. The [SW-G5-07 audit proposal](SOFTWARE_G5_07_AUDIT_PROPOSAL.md) defines one local inventory and six static assessments, with documentation-only outputs and no execution or repairs. Its approval is pending; this deferral does not approve the audit, complete G5 or approve release.

The researcher approved **SW-G5-07: one local inventory and six named static assessments**, limited to audit/manifests and factual planning updates. The [completed audit](SOFTWARE_G5_07_AUDIT.md) pins 561 text inputs, records no input drift, and reports A/C/E as failures (stale status/build metadata and package dependency/shareability issues), B/D as untested evidence gaps (hosted platform execution and licensing/provenance), and F as a static reconciliation pass only. No tests, MATLAB, network, excluded payload reads, containment diagnostics, code repair or packaging occurred. Project licence approval and the incomplete legacy package dependency list remain release blockers in addition to the three deferred live/resource gates. Audit delivery is not G5/release acceptance; bounded follow-up proposals await the researcher’s choice.

The researcher **accepted SW-G5-07 as a bounded static audit** and requested F07-03 planning first. The [package-closure proposal](SOFTWARE_F07_03_PACKAGE_CLOSURE_PROPOSAL.md) names sixteen missing root files, retained roots, 337 helper files and three external helpers in an exact source manifest, with explicit recording/result/development exclusions and ten proposed one-use offline manifest cases. No repair, evaluation or package build has been authorized. Licensing, hosted CI and all three deferred live/resource blockers stay open; no G5/release acceptance or containment retry is implied.

The researcher approved the **F07-03 bounded source-list repair and ten one-use offline manifest cases**. The [delivery](SOFTWARE_F07_03_PACKAGE_CLOSURE_DELIVERY.md) records **10/10 passes** and 407 unchanged final hashes. The revised packager and offline harness consume the same explicit JSON policy; static checks place required-file/hash validation before directory creation and restrict copying to the validated list. The Python policy interpreter does not execute or prove equivalence with MATLAB. No package folder, copied source, ZIP or MATLAB launch occurred. Twelve retained assets remain unverified; actual package/runtime integration, licensing, hosted CI and the three deferred live/resource blockers stay open. The budget is consumed, researcher acceptance is pending, and no further check/build or G5/release acceptance is implied.

The researcher requested **one bounded F07-03 integration proposal with routine repairs included**, replacing per-error approval requests. [F07-03I](SOFTWARE_F07_03_INTEGRATION_PROPOSAL.md) proposes a disposable actual package build, folder/ZIP inspection and extracted-package MATLAB resolution, with up to four build iterations/twelve validation batches and clearly defined material blockers. After a single scope approval, ordinary packaging corrections and repeat checks would proceed autonomously. This remains planning only; no package build or MATLAB launch is authorized yet. Scientific source, prior outputs, licensing/CI and the deferred real-acquisition gates remain protected.

The current status and approval record live in
[software-development-status.json](planning/software-development-status.json).

F07-03I is now approved as one bounded integration-and-repair slice: four builds, twelve validation batches and two packaging-only MATLAB starts maximum. Routine packaging fixes proceed within that scope. No scientific execution, publication, licensing decision or reopening of deferred live gates is authorized. Evidence is recorded in `reference-validation/f07-03-integration-local/`.

[F07-03I delivery](SOFTWARE_F07_03_INTEGRATION_DELIVERY.md): the actual local MATLAB build, 414-file folder/ZIP/extract integrity, 26 extracted-package resolutions/no parse errors and two pre-directory negative checks passed. Usage was one build, three validation batches and one ordinary packaging-only MATLAB start; normal exit and source preservation verified. This is self-reviewed named-route packaging evidence, accepted by the researcher within the delivery-report limits on 29 September 2026. Full dynamic/optional/legacy runtime closure, licensing, hosted CI and all deferred live/resource gates remain open; no G5/release completion or further run is authorized.

On 29 September 2026, the researcher **accepted F07-03I as a bounded local package candidate with the limitations in the delivery report**. This closes candidate acceptance only. G5 and release remain incomplete; licensing, hosted CI, broader runtime verification and all three deferred live/resource blockers remain open. Historical `containment_failure` and consumed launch approvals are unchanged. This acceptance authorizes documentation updates only, not another test, diagnostic phase or MATLAB launch. No further execution is active or authorized under this acceptance.

The researcher **paused release work** and requested one calculation-correctness decision using existing evidence. [CC-01](SOFTWARE_CALCULATION_CORRECTNESS_DECISION.md) recommends retaining existing formulas while reporting normalized detector contrast separately from preserved-input optical change, with automatic and exploratory reviewed results distinct. Its expected scientific-output change is zero; eight named saved-evidence cases and at most ten evaluations are proposed for separate approval. This is planning only: no code/output change, numerical validation, MATLAB launch or recording rerun occurred. G5/release stay incomplete, F07-03I acceptance and all open blockers are preserved, and no release or containment work is resumed.

At the researcher’s request, [CC-01 revision 2](SOFTWARE_CALCULATION_CORRECTNESS_DECISION.md) **supersedes the reporting-only recommendation and its eight-case reporting-validation proposal**. It distinguishes arithmetic consistency from scientific target validity and compares normalized contrast labels, raw local-change labels and corrected local-excursion labels; automatic versus exact reviewed references; and raw versus corrected-numerator amplitudes. The recommendation is to evaluate local corrected direction and a corrected excursion scaled by the positive preserved-input reference mean, preserving automatic and reviewed original results. This is a proposed new derived quantity, not scientific adoption or a claim that correction isolates biology. Known numeric consequences and unquantified candidate changes are explicit; a finite saved-evidence numerical comparison is proposed but unapproved. Only documents changed. Release remains paused, scientific-output changes and recording runs remain unauthorized, and all open G5/release blockers remain.


The researcher approved **CC-01 revision 2's bounded saved-evidence comparison**, including a concise Science/STAR/paper-linked-code/current-V2 comparison. The [delivery](SOFTWARE_CC_01_COMPARISON_REPORT.md) records 18 cases and 19 evaluations (one bounded import repair/recheck), ten computable real A2 combinations, four preserved unavailable real combinations and four synthetic recipes whose A1 replay passed but whose A2 remains untested for missing saved correction. The 26 pinned inputs remained unchanged. Earlier and final harness hashes are distinguished; no claim is made that all cases ran on the final harness. No new correction fit, MATLAB, detector, statistics engine or recording ran. Current labels and amplitudes are preserved. The report corrects the earlier interpretation of `detrend_custom(...,2)`: it selects the trace dimension and uses a fifth-degree fit. Arithmetic replay is demonstrated within scope; physiological validity and scientific adoption remain open. Delivery awaits the researcher's decision, with no further active execution. Release work stays paused and all blockers/consumed launch approvals remain unchanged.

The researcher accepted CC-01 **as a bounded arithmetic/numerical comparison only** and requested a concise [three-event scientific decision view](SOFTWARE_CC_01_SCIENTIFIC_DECISION_VIEW.md) from saved evidence. The view shows preserved-input and saved-correction traces, exact references, measurement windows, native detection bounds and both extrema for historical ID400, FB2312 and C02 row 321. It identifies the choices about direction, mixed windows, primary magnitude and reference authority without adopting a rule. The three pinned audit hashes and CC-01 extrema were checked; no original data/output was changed, no source movie or MATLAB was opened, and no detector/statistics/recording run occurred. Scientific adoption remains pending; release stays paused.

On 30 September 2026, the researcher identified a sink/pocket in the green phase of all three examples, placed FB2312's sink onset at approximately frame 398, and described C02's lilac phase as a possible preceding surge. The decision view records these qualitative judgments and the researcher's hypothesis that hyperemia-associated surges are broader while capillary-obstruction-associated pockets are local. The current FB2312 reference includes the identified decline, and C02's reviewed reference may include a positive event; replacement boundaries, references, amplitudes and any spatial classification rule remain undecided. No production label/calculation, saved evidence or plot was changed; no new numerical evaluation or recording run occurred.


The researcher requested scientific-rule framing from those judgments, with no adoption or run. On 30 September 2026 the [decision view](SOFTWARE_CC_01_SCIENTIFIC_DECISION_VIEW.md#proposed-scientific-rule-framed-by-these-judgments) was expanded to distinguish a pocket episode's decline/recovery from a separate positive event, identify reference contamination independently of recognition, and treat spatial extent as supporting evidence only. Possible broader hyperemia/local pockets remains a hypothesis. This was documentation-only: no new numerical evaluation, replacement reference, amplitude, label, spatial rule or recording execution. The next decision concerns episode/reference semantics; implementation remains inactive and release paused.

On 30 September 2026 the researcher agreed (“i agree”) to those episode and reference semantics as the interpretive foundation. The remaining decision is how to operationalize the accepted meaning with explicit boundaries, reference authority and numerical criteria. Agreement does not authorize replacement samples, amplitudes, labels, code or further evaluations/runs. Acceptance was recorded in the decision view and status; release remains paused.


On 30 September 2026 the researcher requested one concrete recommendation for the same three saved examples and clarified that references may contain normal fluctuations. The [combined review card](SOFTWARE_CC_01_SCIENTIFIC_DECISION_VIEW.md#concrete-three-example-recommendation-30-september-2026) proposes ID400 W82–98/R73–81, FB2312 W398–417/R378–397 (end unresolved), and C02 W177–195/R165–170 (six-frame reference provisional). It recommends comparing signed corrected trough excursion scaled by the positive raw reference mean. Original measurements and detector labels remain visible; no candidate-reference amplitude was calculated or adopted. Saved fixed footprints/eligible support were presented with physical-scale and phase-extent limitations. Source-matched audit/metadata hashes were retained and unchanged; no source movie, MATLAB, correction fitting or detector/statistics execution occurred. The three candidates await scientific review together. Release stays paused.


The researcher approved **CC-01-3E: one saved-evidence comparison of the exact three proposed episode/reference pairs**, including routine arithmetic verification. Scope is three named pairs only; identical raw/corrected frames and unchanged fixed footprints, existing results alongside the new comparison, conditional C02 reference and unresolved FB2312 recovery. Owner: assistant; scientific reviewer: researcher. Acceptance requires source/harness hash gates, scalar arithmetic agreement, preserved sign/footprint origin, missing automatic C02 result and explicit limitations. Stop on missing/mismatched saved ingredients; no alternate reference, correction fitting, footprint redefinition, production change, MATLAB or recording execution is authorized. Evidence is under `reference-validation/cc-01-three-pair-comparison-20260930/`; final code and six saved inputs were pinned before calculation.


[CC-01-3E delivery](SOFTWARE_CC_01_SCIENTIFIC_DECISION_VIEW.md#approved-three-pair-numerical-comparison-30-september-2026) completed all three named pairs with source/hash and scalar/decomposition/old-trough checks passing. Raw/corrected signed troughs are ID400 −4.3287/−5.0523%, FB2312 −8.1385/−8.3626%, C02 −11.1049/−12.3838% (conditional). Current automatic/reviewed amplitudes and signs are retained; FB2312/C02 remain measured on saved surge footprints and FB2312's recovery endpoint is unresolved. Six input hashes/final harness matched. Zero production changes, correction refits, footprint changes, MATLAB/detector/statistics or recording executions. Routine arithmetic is verified, not physiological validity. The comparison awaits one scientific decision; no active implementation or further numerical work is authorized. Release remains paused.


The researcher **accepted CC-01-3E within its limits** and selected corrected signed trough (% of positive raw reference intensity) as the primary exploratory measure for researcher-reviewed pockets, with raw signed trough alongside. C02's conditional reference, FB2312's unresolved recovery and all saved-footprint qualifications are retained. This is a reviewed-measure semantic selection, not an implemented production change or automatic scientific relabelling. [CC-02-01 through CC-02-05](SOFTWARE_CC_02_REVIEWED_POCKET_IMPLEMENTATION_PROPOSAL.md) propose one bounded review/calculation/save/reopen/export integration, exact frames/status/provenance, three primary fixtures and legacy/negative fixtures (14 cases, at most 20 evaluations/four batches/two saved-data MATLAB starts; four implementation hours). Routine repairs would be included after one scope approval. Planning only: no code, checks, new calculations or launches have begun. Release remains paused and automatic measurements/prior outputs are preserved.


On 30 September 2026 the researcher approved **CC-02-01 through CC-02-05 as one complete bounded integration slice**, including routine repairs, under the proposal's four-hour/20-evaluation/four-batch/two-saved-data-MATLAB-session/500 MiB limits. Implementation is active only for this reviewed-measure workflow. Automatic/legacy outputs, conditional reference, unresolved recovery and footprint qualifications remain protected. Zero recording runs, refits, footprint changes or automatic relabelling. Release remains paused.


**CC-02 partial delivery, validation limit reached (30 September 2026).** The [partial report](SOFTWARE_CC_02_INTEGRATION_PARTIAL_DELIVERY.md) records the implemented candidate and retained failures. Four batches used; 17/20 evaluation attempts, two MATLAB starts, already-open desktop reused without launch. ID400's corrected/raw preview matches accepted numbers; Save failed because an anonymous getter captured its initial value. The nested getter repair is untested after the batch ceiling. T05 passed save/load/replay on earlier hashes; other named round trips/guard assertions remain failed or untested as specified. All 44 preservation inputs are unchanged; zero recording/engine/refit/footprint/relabel runs. **CC-02 is incomplete**, no active execution remains, and no further checks or sessions are authorized by this delivery. A separately bounded continuation of the same integration is required before claiming a working accepted workflow. Release remains paused and all deferred blockers/consumed containment approvals stay unchanged.


**CC-02 completion extension approved (30 September 2026).** The researcher authorizes the existing CC-02-01–05 scope, routine repairs and validation: up to 28 additional case evaluations, two saved-data-only MATLAB starts, four active implementation hours and 500 MiB new disposable evidence. Batch counts are recorded with **no separate batch ceiling**. Dispatch, cached-code handling and prerequisite paths must be corrected; dependent checks stop on a failed prerequisite until it is repaired. Completion requires all 14 existing named cases passing on unchanged final code and ID400/FB2312/C02 preview → save → reopen → export demonstrations with exact values and all qualifications. Original sources/automatic/legacy outputs remain protected; zero recording/engine/refit/footprint/relabel/release activity. The historical partial packet is preserved. Owner: assistant; no independent reviewer or usability acceptance is presumed. Stop on scope/source mismatch or exhaustion and report unfinished work.


**CC-02 completion extension delivered (30 September 2026).** The [delivery report](SOFTWARE_CC_02_COMPLETION_DELIVERY.md) records all **14/14 named cases passing on unchanged final code**, including the three complete reviewed-quantity journeys and exact values/frame/flag/footprint preservation. Used 28/28 additional evaluations, two recorded batches (no ceiling), one of two saved-data MATLAB starts, under four hours and 500 MiB. The worker exited 0; final C02 saved review is visible in the existing desktop. All 527 final code/contract/harness pins, 47 extension inputs and 44 historical preservation inputs match. Earlier partial failures and first-matrix hashes remain historical. Main corrected traces are visible and sample-checked; standalone portable small-window screenshots still show plot/text overlap, documented as a presentation limitation. Manual native chooser use and independent review were not claimed. The bounded numerical/integration completion gate is met; **researcher usability acceptance remains pending**. No further test/diagnostic phase is active, and no numerical evaluations remain under this extension. Zero engine/recording/refit/footprint/relabel/release activity. Release remains paused, with all G5 blockers, historical containment_failure and consumed approvals unchanged.


**CC-02 bounded acceptance recorded (30 September 2026).** The researcher accepted the [bounded numerical/integration delivery](SOFTWARE_CC_02_COMPLETION_DELIVERY.md#researcher-acceptance--30-september-2026) and demonstrated main-window workflow only. C02 remains conditional, FB2312’s recovery remains unresolved, and all saved-footprint qualifications are retained. **Native chooser interaction and standalone viewer layout remain open usability items; overall usability, G5 and release remain unaccepted.** This documentation-only acceptance starts no further checks, launches or implementation. Historical partial/delivery packets, numerical outputs, formal `containment_failure`, consumed approvals and deferred live/resource release blockers are unchanged. No active execution milestone remains; release work stays paused pending separate direction.


**CC-02U usability-completion proposal prepared (30 September 2026), approval pending.** The [decision card](SOFTWARE_CC_02_USABILITY_COMPLETION_PROPOSAL.md) covers standalone viewer layout at 1120 × 800 and 900 × 650 and a researcher native-folder save/reopen/export walkthrough including cancellation. Six named focused checks reuse ID400/FB2312/C02 saved evidence; at most twelve evaluations including routine UI repairs/rechecks, two active hours, one saved-data-only MATLAB session and 100 MiB new evidence. Only one unchanged ID400 preview is proposed to reach the existing Save control; no arithmetic rule or original output changes. Exact stored values, C02 conditional reference, FB2312 unresolved recovery and all footprint qualifications remain protected. The full numerical matrix is not repeated by default; an affected scientific/persistence dependency is a material blocker, not permission for broader testing. Planning only: no implementation, checks or launches begun. Overall usability, G5 and release remain unaccepted, release paused, and all historical containment/consumed approval records unchanged.


**CC-02U approved (30 September 2026).** One complete bounded presentation/native-chooser slice with routine UI repairs: two active hours, one saved-data-only MATLAB session, six focused checks/twelve evaluations and 100 MiB evidence. One unchanged ID400 preview is authorized. Native interactions will be researcher-performed one step at a time. Preserve all scientific values/references/qualifications and original outputs; zero calculation changes, recording runs, refits, footprint changes or release work. Delivery and usability acceptance remain pending.


**CC-02U native walkthrough handoff (30 September 2026).** Presentation-only repairs use explicit standalone panel rectangles and visible-value/qualification summaries, scrollable provenance, a complete visible-trace y range, native chooser wording and visible saved/export path details. Cases 01/02 pass assistant structural/native inspection on all three saved examples at both sizes; immediate small exportapp captures retain padded larger canvases, documented separately. Seven evaluations used (retained failures/superseded presentation versions included); one existing MATLAB desktop designated, zero starts. One authorized unchanged ID400 preview has exact scientific-field equality and is ready for researcher Save → Cancel; cases 03–06 remain pending. All 71 protected inputs and 528 final code/harness pins match at handoff. Active work clock is stopped while waiting for researcher input; this is continuation of the same approved slice, not delivery or usability acceptance. No scientific/recording/refit/footprint/release work occurred.


**CC-02U bounded delivery (1 October 2026).** The [delivery report](SOFTWARE_CC_02_USABILITY_COMPLETION_DELIVERY.md) records 6/6 final focused passes using 12/12 evaluations, including retained layout/harness failures, a wrong-window foreign-review rejection and saved-window restoration in the same MATLAB desktop. Normal 1120 × 800 and smaller 900 × 650 layouts were inspected for all three saved examples; native save/reopen/main-export/standalone-export interactions and cancellation were researcher-performed. All 71 protected inputs and 528 final code/harness pins match. One unchanged ID400 preview, one existing saved-data MATLAB session, zero starts or recording/engine/refit/footprint/relabel/release activity; under two active hours and 100 MiB. C02 remains conditional, FB2312 recovery unresolved and all saved-footprint qualifications unchanged. Small exportapp canvas padding remains a capture limitation. Assistant self-review only; finished C02 standalone viewer presented at smaller size for researcher assessment. **Usability acceptance is pending; overall usability, G5 and release remain unaccepted.** The evaluation budget is consumed; no further checks or launches start under this delivery. Historical containment_failure and consumed launch approvals remain unchanged; release stays paused.


**CC-02U bounded usability acceptance recorded (1 October 2026).** The researcher accepted the [finished workflow](SOFTWARE_CC_02_USABILITY_COMPLETION_DELIVERY.md#researcher-acceptance--1-october-2026) at **1120 × 800 and 900 × 650**, including the demonstrated native selections and cancellations. **Standalone viewer layout and native chooser interaction are closed within that scope.** C02 remains conditional, FB2312 recovery remains unresolved, and all footprint qualifications and documented limitations are retained. This is documentation-only acceptance: no further checks, launches or implementation. Overall usability beyond this bounded workflow, G5 and release remain unaccepted; release work remains paused. Historical packets, `containment_failure`, consumed approvals and deferred release blockers are unchanged. No next execution phase is active or automatically proposed.


**Development and release pause confirmed (1 October 2026).** CC-02 is closed within its accepted scope. The researcher will provide the next requirement after using the workflow. Development and release work remain paused; no subsequent validation phase is to be prepared automatically. No further planning, implementation, checks or launches are active or authorized. All scientific qualifications, documented limitations, historical evidence and G5/release non-acceptance remain unchanged.

**Researcher priority and communication clarified (1 October 2026).** The
immediate goal is correct analysis calculations and understandable scientific
outputs. Detection refinement is a separate future priority. Scientist-facing
documentation and progress reports should explain the working feature,
calculation, reference, units and uncertainty in plain language. Internal work
codes remain in development records. README and the short measurement guide
are revised for this purpose; the previous README is preserved in
`DEVELOPMENT_NOTES.md`. This is a documentation-only clarification and GitHub
update. Existing calculation rules, saved outputs and acceptance limits remain
unchanged; no new validation campaign or recording execution is authorized.

## Step-1 completion — 4 October 2026

Accepted exports and planning are saved with development identity `3.1.0-dev.1`;
see [source identity and static checks](SOFTWARE_NEXT_01_DELIVERY.md). The
authorization above is consumed by this bounded delivery. The delivery-record
commit is followed only by the approved normal branch push and remote-tip
verification, whose outcome is reported in the final handoff. Development and
release then stop. No step-2 work or additional checks are authorized.
