# First task handoff for saving the accepted software

4 October 2026. Copy the request below into a clean chat after deciding to approve
step 1. It authorizes only the stated baseline/version/GitHub task when sent by
the researcher. This saved document itself authorizes no implementation.

```text
Implement step 1, “Save the accepted software and establish its version,” as one
complete task, including ordinary documentation, metadata and Git repairs.

Workspace: /Users/zcm361/Documents/Github/OxygenDynamicsV2
Git checkout: /Users/zcm361/Documents/Github/OxygenDynamicsV2/existing-analysis
Target branch: development-existing-analysis-v3
Expected last committed baseline when this handoff was prepared: e8266d9.
Inspect the actual current state; do not reset or overwrite newer local work.

Read existing-analysis/AGENTS.md, docs/SOFTWARE_DEVELOPMENT_PLAN.md,
docs/planning/software-development-status.json and docs/SOFTWARE_NEXT_STEPS.md.
My priority is correct analysis calculations and understandable scientific
results. Use ordinary feature names when reporting progress.

The reviewed-pocket workflow and native controls are already accepted. The
automatic amplitude export clarification was accepted on 4 October; its code
and documentation are still local. Keep the storage-budget exception, earlier
failures, C02's conditional reference, FB2312's unresolved recovery and all
saved-footprint/scientific qualifications unchanged.

Scope:
1. Inspect the branch, remote, existing v3.0 tag and complete pending diff.
2. Preserve the accepted export implementation and the current planning documents.
   Update the changelog with clear descriptions of reviewed-pocket measurement
   and the automatic export explanations/counts. Make current tasks distinct
   from historical backlog entries without deleting the history.
3. Confirm that v3.0 is the intended historical version line, then use the proposed
   software development label 3.1.0-dev.1. Reconcile getOxygenPipelineVersion.m,
   the manual and displayed version/build metadata using one actual timestamp.
   Preserve old run metadata and every calculation/detector/statistics contract.
   If the remote history contradicts this version line, report the exact conflict
   before choosing another version. Do not move an existing tag.
4. Statically check the intended diff, version references and preserved calculation
   files. Stage explicitly named software/docs/tests, excluding recordings,
   generated research payloads, local source maps and credentials.
5. Make at most two commits and push normally to development-existing-analysis-v3.
   Verify the remote branch identifies the resulting commit. Report that commit,
   development version, changed files and any remaining local changes.

Budget: 90 active minutes; at most two commits and one successful branch push;
at most 5 MiB new textual planning evidence. Ordinary recovery may retry an
unsuccessful push of the same commits. No force-push, main-branch merge, release
tag or GitHub release. Stop on unexpected divergence rather than overwriting it.

Zero MATLAB starts, test-suite executions, package builds, recording runs,
calculation changes, correction refits, footprint changes or automatic relabelling.
Do not reopen containment diagnostics or broaden the task into release work.

Finish when accepted work is recoverable on the target branch and the development
identity agrees. Update task/status records, retain all release blockers and stop.
Step 2 calculation work needs its own approval; do not start it automatically.
```
