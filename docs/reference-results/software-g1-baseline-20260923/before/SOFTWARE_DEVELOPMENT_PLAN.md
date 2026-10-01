# OxygenDynamics: software development plan

Version 0.1 · 21 September 2026 · SW-PLAN-001

**Product direction and scope boundaries are established by the researcher's
latest instructions. The roadmap below is proposed; implementation awaits
approval of the first milestone.** No team has been launched by writing this plan.

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
status identifies the approved milestone. **Now:** plan drafted and guardrails
recorded; roadmap/G1 approval pending.

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

**Approve this roadmap and G1: engineering baseline and bounded backlog.** G1
will inspect the current software, exercise the existing saved-result workflow,
run relevant bounded checks and return a ranked implementation proposal. It will
not start a cohort analysis, modify scientific algorithms, reconstruct a
stimulation protocol or launch a broad refactor.

The current status and approval record live in
[software-development-status.json](planning/software-development-status.json).
