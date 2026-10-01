# SW-G5-07 — bounded support and release audit proposal

29 September 2026. **Proposal only: not approved for execution or implementation.** Owner: Codex assistant, technical-lead role; self-review, with no claim of independent review. Benefit: establish a finite, honest release-readiness inventory while real-acquisition work is deferred.

## Fixed boundaries

The researcher has deferred the real-acquisition gate. Successful live acknowledgement, verified containment and real-acquisition resource measurements are three explicit open release blockers. Real-acquisition integration also remains unverified. Historical `containment_failure` and consumed launch approvals remain unchanged. This audit cannot close or waive those blockers.

Proposed budget: **one local read-only inventory and six named static assessments, one reporting pass each**. No MATLAB or analysis execution, tests, containment diagnostics, process lookups/signals, CI dispatch, dependency installation, network access, packaging, tagging, publishing or live attempt. No repairs, code changes or automatic rechecks are included. Audit findings become proposed follow-up work, not implicit permission to fix them.

## Inputs and output boundary

At audit start, record repository HEAD, dirty-file inventory and a hashed input manifest so findings refer to the current worktree, not just committed code. Preserve all existing changes. Inspect local `existing-analysis/` software: top-level source/configuration and release documentation, `helpers/`, `external/`, `tests/`, and `.github/workflows/`. Use the named G1–G5 delivery/acceptance records and current plan/status as read-only historical evidence. Do not traverse raw recordings, the external acquisition volume, `docs/reference-results/`, or workspace `reference-validation/` payloads; existing delivery records suffice for historical claims in this audit.

For sharing checks, propose a software-only inclusion/exclusion manifest; do not build an archive or copy files. Exclude recordings, saved result payloads, local process packets and development evidence from that candidate. Runtime-generated source provenance is distinct from hard-coded private paths: flag both where relevant without deleting traceability from original evidence. Unknown binary content or an unverified dependency is recorded as unresolved, not assumed shareable. A later package will require its own validation against the manifest.

## Six named assessments

| ID | Exact scope | Required evidence/output |
| --- | --- | --- |
| SW-G5-07-A — support claims | Reconcile `README.md`, configuration and existing G1–G5 records with MATLAB/toolbox/OS requirements visible in the declared source tree. | Support matrix separating declared requirements, statically inferred dependencies and platforms actually exercised in saved evidence. Missing platform evidence is untested; do not claim new compatibility. |
| SW-G5-07-B — CI evidence | Inspect `.github/workflows/matlab-ci.yml`, `runRepositoryChecks.m`, `runBOISoftwareChecks.m` and their directly referenced repository checks. Compare wiring with locally saved delivery claims. | Identify what CI is configured to run versus what has recorded hosted execution evidence. No remote query or CI trigger; absent hosted evidence is unverified, not a pass. |
| SW-G5-07-C — versions and saved-result contracts | Read `getOxygenPipelineVersion.m`, `helpers/oxygenPipelineContract.m`, its validator, `loadBOIRecordingRun.m`, `loadBOIG4EvidenceBundle.m`, workflow save/no-overwrite code, and G4/SW-G5-05 records. | Version/schema compatibility and no-overwrite evidence map; separate prior runtime results from current static findings, including any relevant code drift. No replay, migration or result mutation. |
| SW-G5-07-D — dependency notices | Inventory bundled `external/` code, source attribution/license headers and `THIRD_PARTY_NOTICES.md`; locate repository license files if present. | Dependency-to-notice table with version/source/license evidence or explicit gaps. Missing/ambiguous redistribution permission remains unresolved; no legal clearance or replacement/install is implied. |
| SW-G5-07-E — shareable files and private paths | One candidate software manifest and one static scan of its text files for hard-coded personal/machine paths, private-data references, accidental result inclusion and unresolved binary dependencies. | Findings with paths/lines and proposed exclusions or repairs. State manifest coverage and exclusions; do not claim the whole workspace or an unbuilt package is sanitized. Do not remove or alter historical provenance. |
| SW-G5-07-F — release evidence reconciliation | Reconcile A–E with the current plan/status, G3/G4 acceptances, G5 deliveries and the explicit deferral. | One release matrix: pass/fail/untested, evidence/hash or location, severity, owner role and required next decision. Carry all three live/resource blockers and unverified real-acquisition integration forward. No G5 or release completion. |

## Completion and stops

Outputs only: `docs/SOFTWARE_G5_07_AUDIT.md`, a local input/candidate-file manifest under `docs/planning/`, and factual plan/status updates. Each of the six rows receives a result; findings may remain open. An audit row passing means its narrow evidence check passed, not that a platform or release was validated. The assistant must label self-review accurately.

Missing evidence is recorded as untested; a concrete contradictory claim or defect is recorded as fail. Continue independent remaining rows without expanding scope. Stop the affected row if resolution requires execution, external access, excluded data or a repair. Stop the audit on input drift that prevents a reproducible assessment, preserving partial findings and marking remaining rows untested; do not automatically restart against new hashes. No diagnostic or implementation campaign follows a finding.

At the end, present blockers and finite follow-up choices and wait for a separate decision. If this audit is deferred too, preserve the existing accepted usability/offline evidence and open release blockers. Approval of this audit would authorize only its local static inspection and documentation, not implementation of fixes, live work, G5 acceptance or release.
