# Software priorities and working plan

4 October 2026. Prepared for the researcher and the next implementation chat.

The priority is correct analysis calculations and understandable results. This
plan first preserves the accepted software, then checks the remaining main
measurements, repairs demonstrated defects, and prepares a usable distribution.
Detector refinement stays a later priority.

**Status: step 1 approved on 4 October 2026; steps 2–7 remain proposed.** Preparing this plan does not start implementation,
tests, MATLAB, packaging, GitHub publication or a recording run. Only step 1 is authorized by the researcher’s current request; release remains
paused. Its completion is recorded in [step-1 delivery](SOFTWARE_NEXT_01_DELIVERY.md). The active
[development plan](SOFTWARE_DEVELOPMENT_PLAN.md) and [workspace instructions](../AGENTS.md)
remain the authority. Earlier accepted work and failures remain recorded.

## What a calculation check means

Follow a result from its source data through the calculation to the exported
table. Confirm the formula, units, selected frames or pixels, denominator,
missing-data behavior and aggregation. Compare a few fixed examples with an
independently written calculation whose expected answer is known.

For example, ten saved frames at 1 Hz have a modeled frame-count duration of
ten seconds under the current inclusive rule. A union of occupied pixels must
count an overlapping pixel once. An average based on 94 of 192 events must
retain that contributor count. These checks concern the software's implementation
of its stated measurements. Reference suitability, background correction and
physiological interpretation require separate scientific judgment.

If a definition is implemented correctly, retain it and explain its limitations.
If the code is wrong, include its repair and focused verification in the same
approved step. Show numerical impact before adopting a repair that changes
scientific outputs. Do not replace the target quantity simply because another
definition gives a more expected biological answer.

## Current starting point

- Repository: `/Users/zcm361/Documents/Github/OxygenDynamicsV2/existing-analysis`.
- Working branch: `development-existing-analysis-v3`.
- Latest local committed baseline when this plan was prepared: `e8266d9`.
- Reviewed-pocket measurement, save/reopen/export and the demonstrated viewer
  controls are accepted. Corrected signed trough remains exploratory; raw trough
  accompanies it. C02's reference remains conditional, FB2312's recovery remains
  unresolved, and the saved-footprint qualifications remain.
- Automatic amplitude and summary export clarification was accepted on
  4 October. Its implementation is local and uncommitted. The storage-budget
  exception and earlier failures remain retained.
- Current code reports software version `1.01`; local Git contains tag `v3.0`.
  The manual and central build timestamp disagree.
- The package source policy omits nine reviewed-pocket functions, two automatic
  amplitude export helpers and the two new reader guides. The accepted September
  package is an older candidate, not an installation of all current features.
- Hosted CI is configured for Linux/R2025b, but current records do not establish
  a hosted pass. Its push branch list omits the current working branch.
- Live acknowledgement, verified containment and real-acquisition runtime/memory
  remain deferred release blockers. Project licensing and broader runtime support
  also remain open. No consumed attempt is available for reuse.

## Priority and sequence

| Step | Practical outcome | Dependency |
|---|---|---|
| 1 | Accepted changes saved on GitHub with a clear development version and current task list | First short task |
| 2 | Duration, area, occupancy and event-rate calculations checked from ingredients to output | Saved baseline |
| 3 | Remaining summary, integral and composite calculations checked and explained | Step 2 definitions stable |
| 4 | An installable candidate containing the current functions, contracts and guides | Steps 2 and 3 completed or explicitly limited |
| 5 | Supported environments and automated checks demonstrated | Current code and candidate available |
| 6 | A complete fresh-recording journey with measured resources and justified cleanup | Separate containment decision and exact run budget |
| 7 | Independent use, reproducible output and an approved versioned release | Required scientific and release decisions resolved |

The researcher owns scientific choices and acceptance. The implementation chat
owns engineering, routine repairs and truthful evidence within each approved
step. An independent person is needed for the later independent replay; a second
assistant is not automatically authorized by this plan. Licensing decisions can
be gathered before step 7; an assistant cannot choose the project's licence for
the rights holder.

The budgets below are proposed active-work limits, not promised calendar dates.
Confirm the selected inputs and feasible artifact sizes before approving a step.
Once approved, ordinary repairs and necessary rechecks use that same budget;
another approval is needed only for a material scope or scientific decision.

## Step 1 Save the accepted software and establish its version

**User benefit:** the accepted software is recoverable and another chat can
identify exactly which version it is working on.

Record the actual branch, commit, remote and pending diff. Preserve all existing
local evidence. Save the accepted export changes and these planning documents.
Add concise changelog entries for reviewed-pocket measurements and automatic
export clarification; retain historical entries. Make the current task list
separate from its historical backlog.

Propose `3.1.0-dev.1` as the development label after confirming that the existing
`v3.0` tag is the intended historical version line. Reconcile the central version,
manual and displayed metadata. Use one actual build timestamp and preserve old
saved-run metadata. This step changes software identity and documentation only;
detector, measurement and statistics contracts stay unchanged.

Commit the intended software/documentation files and push normally to
`development-existing-analysis-v3`. Record the resulting commit and verify that
the remote branch points to it. No merge to main, release tag or GitHub release.

**Proposed budget:** 90 active minutes, at most two commits and one successful
branch push; zero MATLAB starts, test suites, package builds or recording runs.
Use static diff, path, metadata and Git checks. Authentication/network recovery
may retry an unsuccessful push of the same commits; no force-push. Create at most
5 MiB of new textual planning evidence. Stop and report an unexpected remote
divergence or competing work rather than overwriting it.

**Done when:** the accepted changes are on the intended branch, metadata agrees,
the commit is recorded, only intentional unrelated changes may remain, and the
scientific calculation files/contracts are preserved.

**Handoff:** [ready-to-copy first task](SOFTWARE_FIRST_TASK_HANDOFF.md).

## Step 2 Check duration area occupancy and event rates

**User benefit:** a researcher can trust the time and spatial denominators behind
the main descriptive outputs.

Cover five measurement families: inclusive event duration; native mean event
area; union tissue occupancy; onset rate; concurrent event density. Follow both
sink and surge paths, fractional window overlap, pixel-size squared conversion,
sign-specific tissue support and seconds/minutes/mm² conversion. Keep native
and refined bounds distinct. Preserve the existing frame-1 onset policy while
explaining that it does not confirm a new physiological onset. Invalid timing or
calibration must remain unavailable or blocked, not become a valid zero.

Reuse existing relevant tests and one named saved G2 ID400 result; add at most
eight small calculation fixtures covering single-frame events, fractional window
edges, overlapping masks, different sign-specific tissue areas, empty events,
missing calibration and events crossing a window boundary. Check the ingredients
and exported results with explicit independent expected values. No detector or
statistics pipeline rerun and no source-movie reconstruction.

**Proposed budget:** six active hours, at most four validation batches and
40 focused case evaluations including necessary repairs/rechecks, two
saved-data-only MATLAB sessions and 100 MiB new evidence. Freeze the named cases
and exact inputs in the work item before evaluation; do not fill the budget with
unrelated suites. Reuse available ingredients; a missing ingredient is a reported
limit, not permission to regenerate a recording.

**Done when:** each family has an explained formula and one worked example;
named checks pass on the final code, or a precise blocker is reported. Any
scientific-output correction has an explicit old/new comparison and researcher
adoption decision. A correctly implemented rule can remain unchanged.

**Handoff after approval:**

> Complete step 2 of this plan as one calculation-and-repair task. Check duration,
> event area, tissue occupancy, onset rate and concurrent density using the
> stated saved result and small fixtures. Include ordinary repairs and necessary
> rechecks within the budget. Explain the formula, denominator and scientific
> limits of each output. Present numerical impact before adopting an output
> change. Finish with one concise calculation guide and final evidence. Keep the
> detector, correction, footprint definitions and physiological claims unchanged.

## Step 3 Check summaries integrals and the composite

**User benefit:** recording and animal comparisons have understandable weighting,
units and missingness.

Cover the signed optical trace integral, amplitude–area–duration composite,
normalized composite rates, and recording-to-mouse-to-group aggregation. Confirm
strict versus finite-only missingness, zero-event behavior and the denominator
used for each result. Preserve automatic/reviewed separation, separate signs and
the existing equal-mouse descriptive weighting. Choosing the final biological
outcome or statistical inference is a researcher decision.

Check that exporting an older result identifies the version that produced its
calculations separately from the current exporter/reader version. Do not make
old results appear to have been recomputed by newer software.

Use two named saved statistics examples, G2 ID400 and C02, plus at most six small
fixtures with unequal site/recording counts, missing contributions, zero events,
negative signed integrals and explicit unit conversions. Reuse amplitude tests
only if a changed dependency requires them; do not repeat the accepted entire
amplitude or reviewed-pocket matrix automatically.

**Proposed budget:** five active hours, four batches/32 focused evaluations,
two saved-data-only MATLAB sessions and 100 MiB evidence. No movie, detector,
statistics pipeline, correction refit or cohort comparison execution.

**Done when:** calculation ingredients, units, weighting and contributing counts
reconcile with saved/exported values; actual bugs have bounded repair evidence
and approved numerical impact. The guide distinguishes descriptive summaries
from a final experimental statistical analysis.

**Handoff after approval:**

> Complete step 3 as one task checking signed integrals, the sink composite, time
> and area normalization, and recording/mouse/group summaries. Use the fixed saved
> results and small fixtures in the plan. Repair implementation defects within
> scope and show any changed scientific values before adoption. Preserve current
> definitions and prior outputs. Deliver one readable summary example and the
> final focused checks, then stop.

## Step 4 Update the installable candidate

**User benefit:** a copied installation contains the features accepted in the
repository and provides working instructions.

Update the explicit package policy for the current reviewed-pocket and automatic
export functions, their JSON definitions and source contracts, and reader guides.
Resolve actual runtime dependencies and local documentation links. Preserve the
previous candidate. Continue excluding recordings, generated results, private
source maps and development evidence. Do not revert to recursive directory copying.

Build into a new disposable folder. Compare folder, ZIP and extracted files;
check hashes, required entry points and saved-data save/reopen/export from the
extracted copy without falling back to functions in the source checkout.

**Proposed budget:** four active hours, at most three package builds, six focused
validation batches, two packaging/saved-data MATLAB sessions and 150 MiB total
new artifacts. Check space before each copy or archive; stop before exceeding
the limit. If the exact candidate size makes that cap infeasible, revise the
budget before a build. No recording execution or publication.

**Done when:** current features and definitions are included, extracted routes
work in the named environment, documentation links resolve, and the manifest
identifies the exact software version and source commit. A candidate is not a
release approval.

**Handoff after approval:**

> Complete step 4's package update and integration with ordinary repairs included.
> Use the explicit source policy and include the current measurement/export
> dependencies and reader documentation. Preserve prior candidates and exclude
> research payloads. Verify the named extracted-package routes without using the
> source checkout. Deliver the ZIP, manifest, source commit and limits; do not
> publish a release or run a recording.

## Step 5 Demonstrate supported environments and automated checks

**User benefit:** installation requirements and compatibility claims reflect
observed behavior.

Start with the environments already named in project records: macOS/R2025a and
hosted Linux/R2025b. Verify the current BOI runner includes relevant new tests;
the nine export checks are not automatically assumed to be in hosted CI. Add the
working branch to the intended CI trigger if approved. Separate headless
calculation checks from desktop/native-chooser checks. Record unsupported or
untested Windows/other releases without claiming their compatibility.

Check current and explicitly supported older saved-result contracts using small
fixtures. Preserve honest rejection of incompatible or incomplete results.

**Proposed budget:** four active hours, one selected local BOI gate and at most
two hosted workflow executions, with targeted repair/rechecks within scope;
no new platform matrix or acquisition runs. Use the configured 30-minute hosted
job cap and record actual logs/commit. Check external runner availability before
execution. Dependency/platform expansion needs its own decision.

**Done when:** supported paths have named version/toolbox evidence on final code,
CI logs identify the tested commit, and remaining platform limits are documented.

**Handoff after approval:**

> Complete step 5 for the named macOS and hosted Linux environments, including
> relevant new calculation/export checks and working-branch CI wiring. Distinguish
> desktop controls from headless checks. Repair ordinary compatibility problems
> within the budget and report actual run logs and code identity. Keep unknown
> platforms labeled untested; do not expand the matrix or run recordings.

## Step 6 Demonstrate a fresh recording safely

**User benefit:** the complete new-analysis journey is demonstrated with measured
runtime and memory rather than inferred from saved-result checks.

The prior supervised attempts did not establish verified live containment.
Keep their failures and consumed approvals unchanged. First obtain one
independently written containment assessment of current code and saved evidence,
with a three-hour assessment budget and zero launches. Selecting or messaging
that reviewer needs explicit authorization. The assessment must identify a
defensible approach and the minimum finite evidence required, or leave the gate
blocked; it must not begin another sequence of speculative diagnostics.

Only after that decision prepare a single integration proposal naming source,
hashes, settings, new output, supervision/cleanup, time, process-tree memory,
disk limits and retained failure evidence. The exact numeric launch budget must
be prepared from the chosen recording and approved separately. No recording is
preauthorized here, and no historical attempt can be retried under old approval.

**Done when:** one approved fresh journey imports, checks settings, runs, inspects,
reopens and exports with measured resources and verified exit/cleanup; or the
single attempt stops and reports a specific incomplete result. An incomplete
attempt retains the blocker. No automatic retry or additional diagnostic phase.

**Handoff for the assessment after approval:**

> Complete one independent containment assessment for step 6 using current code
> and saved evidence only. Explain unresolved ownership and cleanup risks and
> the minimum evidence needed for a defensible fresh-recording proposal. Stop
> with a written conclusion. Do not implement, launch MATLAB or propose a chain
> of incremental diagnostic retries. A later recording launch requires its own
> exact approval.

## Step 7 Complete independent use and release preparation

**User benefit:** another scientist can install the software, understand a result
and reproduce a numerical example.

Obtain the rights holder's licence decision and reconcile dependency notices,
source attribution, citation and version metadata. Have a researcher unfamiliar
with the development history follow the quick start from a fresh installation,
then reproduce one event measure and one recording summary from exported
ingredients. Reuse step 6's fresh-run evidence where applicable; do not require a
second acquisition just to repeat it. Correct essential instructions or controls
within the approved task. Distinguish arithmetic replay from biological validation.

**Proposed budget:** one unfamiliar-user walkthrough, one independent numerical
replay session and four active engineering hours for documentation/ordinary
repairs; no extra recordings. Reviewer participation and its tools must be
explicitly arranged. Licence decisions and publication remain researcher gates.

Prepare a release candidate and release notes only when required blockers are
closed or a changed release scope is explicitly approved. Release acceptance is
a separate decision from approving a development branch or a candidate ZIP.

**Done when:** final version, source commit, package, tested support, calculation
guide and known limitations agree, required evidence is accepted and publication
is explicitly approved. No main-branch merge, tag or release occurs automatically.

**Handoff after approval:**

> Complete step 7's independent installation/walkthrough, exported numerical
> replay and release documentation within its budget. Preserve every scientific
> qualification and resolve required licence/version/support decisions. Prepare
> a concrete release candidate for approval. Do not merge, tag or publish until
> the researcher explicitly approves those final actions.

## Software and calculation versioning

**Proposed software line:** `3.1.0-dev.1`, then `3.1.0-dev.2`, and so on for
subsequent changed development snapshots. The first label was adopted under step-1 approval after confirming local and
remote `v3.0` at `329cdc2f1fd3afd04c54ce4518673165f999b1a0`. Subsequent labels
remain subject to an approved changed development snapshot. Do not relabel or move `v3.0`.
Do not create a new label merely because another test batch ran; the source
commit and evidence record identify a check without changed software.

- A compatible implementation fix after a stable release increments the last
  number, for example `3.1.1`.
- A compatible new feature increments the middle number, for example `3.2.0`.
- An incompatible interface or adopted change to scientific output meaning
  requires an explicit compatibility decision and normally the first number,
  for example `4.0.0`.
- `3.1.0-rc.1` means a candidate awaiting final acceptance, after required gates.
  `3.1.0` and tag `v3.1.0` are reserved for the separately approved stable release.

The software version and calculation identity answer different questions. Keep
the existing detector/measurement/statistics contracts and reviewed definition
versions unchanged for wording or software-metadata changes. Whenever a formula,
support rule, interval rule or numerical calculation behavior changes, version
the affected calculation contract and retain an old/new result comparison,
including a bug repair that keeps the intended scientific definition.

Each new result/package should identify its software version, source commit or
source hash manifest, relevant calculation contract, settings and source identity.
Record generation time separately from the code build timestamp. Use existing
provenance services; packaged copies without Git need a saved source manifest.
Displaying an old result should retain the version that produced it and identify
the current reader/exporter separately. A new version must not overwrite earlier
saved values or make them appear to have been produced by current code.

## Guidelines for every implementation chat

1. Read workspace instructions, this plan and current status; inspect the actual
   branch/diff. Treat this document's budgets as proposals until the named step
   is explicitly approved. Approval of one step does not activate the next.
2. Record one bounded work item with its internal ID, benefit, exact inputs,
   owner, intended edits, case list, budget and stopping condition before work.
   Routine repairs and necessary rechecks belong inside that same approval.
3. Preserve sources, prior results and failed attempts. Avoid checking in bulky
   research evidence or changing unrelated local work. No automatic delegation.
4. Use named saved examples and small independent arithmetic cases. Broaden
   testing only for an affected dependency or concrete remaining risk. Check
   storage before each batch/copy; finish at the task's stop condition.
5. Report a defect separately from an unresolved scientific choice or unavailable
   evidence. Present proposed scientific-output changes concretely before
   adoption. Explain units, reference, denominator, weighting and missingness.
6. Finish with the changed feature, checks actually performed, remaining limits,
   source commit/version and one proposed next action. Update current status and
   the task list. Stop; do not invent another validation phase.
7. Carry a short handoff to the next chat: accepted scope, actual commit/diff,
   completed outputs, exact remaining task, relevant files, protected results,
   budget remaining, unresolved decisions and required approval. Keep researcher
   messages in plain language; internal IDs remain in records.

**Internal work IDs:** NEXT-01 through NEXT-07 correspond to steps 1 through 7.
NEXT-01 alone is approved for implementation; NEXT-02 through NEXT-07 remain
proposed. The owner is the implementation assistant; no reviewer or additional
agent has been engaged.
