# Put the completed licence documents into GitHub and the development download

5 October 2026 · Proposed task DOCS-DIST-01 · Owner: implementation Codex chat

## Why this is next

The licence documentation is finished locally. The original published code has
MIT permission, its exact notice has been restored, and the dependency notices
and contributor credits are documented. The accepted download still contains
the earlier documents. This task gives users the corrected information in the
repository and one updated development ZIP.

This handoff is a proposal. The researcher requested its preparation; execution
needs approval of the complete scope below under [AGENTS.md](../AGENTS.md).
Pasting the approval message at the end into the implementation chat supplies
that approval. Preparing this file starts no build or push.

## Starting point

- Workspace: `/Users/zcm361/Documents/Github/OxygenDynamicsV2`.
- Git repository: `/Users/zcm361/Documents/Github/OxygenDynamicsV2/existing-analysis`.
- Branch: `development-existing-analysis-v3`.
- Recorded HEAD: `e119df6338faa0590f933f889a8dddf81256de30`.
  Check the actual local and remote tips before changing anything.
- Software version: **3.1.0-dev.2**; software build:
  **2026-10-04 21:37:28 +02:00**. Keep these for this documentation update.
- Read the workspace instructions, repository instructions,
  [development plan](SOFTWARE_DEVELOPMENT_PLAN.md) and
  [current status](planning/software-development-status.json).
- Inspect and preserve the existing uncommitted documentation. It includes
  dependency notices, the release decision sheet, the MIT correction and this
  handoff. Do not reset the checkout or automatically stage unrelated work.

The original code notice is
[Science_2024-MIT.txt](../licenses/Science_2024-MIT.txt), with SHA256
`d82e8bb7af3023a0f86f060203f117135b232c6c5c497621a5353462959e1dbd`.
Keep its wording, copyright name and year exactly.

Preserve these existing candidates:

- `reference-validation/software-next04-package-20261004/OxygenDynamics_3.1.0-dev.2_NEXT04_candidate01.zip`
  — SHA256 `246274ea9bad0ee7d1ac54d61216b77ecf39a32fe5edd8167ea7d05e3851765b`.
- `reference-validation/software-next07-distribution-20261005/OxygenDynamics_3.1.0-dev.2_portable-guides_candidate02.zip`
  — SHA256 `dd321e9b1b08773141959e4538707f5b39564068deeb9acd6b9c9d67389205ef`.

Those paths are relative to the workspace, outside the Git repository. Proposed
new packet: `reference-validation/software-licensing-distribution-20261005`.
Proposed ZIP: `OxygenDynamics_3.1.0-dev.2_licensing_candidate03.zip`.
Confirm those destinations are absent. Stop on a collision and report it.

## Complete implementation task

1. **Finish the portable documents.** Reconcile the README, licensing guide,
   dependency notices, distribution status, package contents and release
   instructions. Reader documents must explain what the software measures and
   what was demonstrated in ordinary words. Keep development history separate
   from current instructions. Correct package links and wording within this task.
2. **Check the exact package list.** Include the restored MIT notice,
   `LICENSING.md`, the original-licence source record, dependency notices and
   their provenance record. Preserve the explicit file-list approach. Include
   only necessary documentation dependencies; do not copy development evidence
   or research payloads to resolve a link.
3. **Save the intended source snapshot.** Commit the scoped documentation and
   policy changes on the existing branch with `[skip ci]`. Freeze the packaged
   source files and their hashes. Identify the source commit separately from
   any later delivery-record commit; a base commit alone cannot identify changed
   bytes.
4. **Build one new development candidate.** Use the existing
   `createOxygenReleasePackage` route in an ordinary packaging-only MATLAB
   session. Give it the new output root/name, actual source commit and source
   state. Keep package creation time separate from the unchanged software build.
   Repairs and a second build are included if needed within the budget.
5. **Verify and finish the delivery.** Compare exact file sets and hashes across
   committed source, package folder, ZIP and extracted copy. Verify local links
   from the extracted package, legal notice inclusion and exclusions. Save a
   concise delivery record outside the packaged file set, update plan/status,
   push normally to the development branch and verify the remote tip. Report
   the new ZIP, exact packaged-source commit, final branch commit and limits.

## Five acceptance checks

1. **Legal text:** original MIT bytes and all five reconciled dependency licence
   texts remain exact. Credits and the Zenodo metadata distinction remain.
2. **Portable content:** every local reader link resolves inside the extracted
   package; no machine-specific input path or private evidence is shipped.
3. **Package identity:** complete folder/ZIP/extraction file sets and hashes agree
   with the identified committed source; version/build/creation time are accurate.
4. **Preservation:** the 542 MATLAB files present at this handoff, scientific
   contracts and original inputs/results remain unchanged. Earlier candidate
   ZIPs match their recorded hashes. No research payload enters the package.
5. **Git and records:** intended files only, normal push, verified remote commit,
   truthful support/validation claims and a clear completed-task status.

Use static checks and packaging verification for these five checks. Include
ordinary repairs and necessary rechecks within the single approved task. If a
MATLAB or scientific-contract change becomes necessary, report that concrete
scope change before adoption; the accepted numerical checks are not repeated
automatically.

## Claims and remaining decisions

The [licensing guide](../LICENSING.md) distinguishes the existing MIT grant from
unconfirmed licensing of new V2 contributions. Preserve that distinction. A
new copyright assignment or blanket V2 licence needs a rights-holder decision;
this packaging task supplies neither. The new ZIP remains a development
candidate with that limitation.

Retain the existing support evidence: Ubuntu/R2025b portable checks passed
133/133 on `5c23b02`; the macOS/R2025a full gate was 132/133 with three subsequent
targeted passes. Named saved workflows were demonstrated on macOS. Do not imply
a final full macOS pass, Linux desktop demonstration, or checks on the new
documentation commit. Fresh-recording integration, runtime and peak memory
remain unverified. Publication and stable-version acceptance are later decisions.

Scientific definitions and saved qualifications stay intact, including automatic
versus reviewed results, C02's conditional reference, FB2312's unresolved
recovery and fixed-footprint qualifications. Custom containment, VM/watchdog
work and worker qualification stay deferred to a possible v4.

## Budget and stopping point

Two active hours; at most two package builds, one packaging-only MATLAB session,
three commits (source, any necessary source repair, final delivery record) and
one successful normal branch push; 50 MiB of new artifacts.
Check storage before copies. No numerical suites, CI launch, recording analysis,
correction refit, detector tuning, merge, tag or GitHub release is included.
Authentication recovery may retry an unsuccessful push of the same commits;
never force-push or overwrite a competing remote change.

Stop on unexpected source/remote drift, destination collision, an application
defect requiring a wider scope, or budget exhaustion. Preserve any partial build
and report the exact limitation. Done means the corrected documents are saved
on the intended branch and included in a verified new development ZIP. Deliver
one readable result and stop; no diagnostic or release campaign follows.

## Paste into the next implementation chat when ready to approve

> I approve the complete documentation and development-download update in
> `docs/SOFTWARE_LICENSING_DISTRIBUTION_HANDOFF.md`, including routine repairs
> and focused rechecks within its two-hour, two-build, one packaging-only MATLAB
> session, three-commit, one successful branch-push and 50-MiB limits. Preserve the
> original MIT notice, dependency terms, accepted calculations, scientific
> qualifications, old ZIPs and original results. Put the completed documents on
> `development-existing-analysis-v3` and into one new verified development ZIP.
> Keep version 3.1.0-dev.2 and report the exact source and branch commits. Retain
> the unconfirmed licensing of new V2 contributions and current support limits;
> no blanket new licence, recording run, CI campaign, stable tag or public release
> is approved. Complete the whole task, bring me the result, and stop.

## Approval and completion record

The researcher approved this complete task and then the bounded provenance-label/
loader-checksum amendment on 5 October 2026. The original total budget remains.
[The delivery](SOFTWARE_LICENSING_DISTRIBUTION_DELIVERY.md) records one build,
one same-session extracted definition-load check, exact package verification and
preserved original results/ZIPs. Source and closing-record commits are separate.
The final normal branch push/remote check is reported in the handoff receipt.
This proposed-task text is historical; no further execution follows completion.
