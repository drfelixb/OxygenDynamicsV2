# F07-03 package dependency closure — decision card

29 September 2026. **Planning only; no repair, verification execution or package build approved.** The researcher accepts SW-G5-07 as a bounded static audit. Owner of the proposed slice: Codex assistant, with self-review explicitly labelled. Benefit: prevent a future source package from shipping the BOI GUI without its workflow and review dependencies.

## Proposed implementation boundary

Limit a later approved change to `createOxygenReleasePackage.m` and, if needed, one source-list helper plus a local verification harness/fixture manifest. Add the sixteen root dependencies below and replace recursive helper/external folder copying with an exact, reviewable file list. A missing required source must stop before any package directory is created; it must not be silently listed as skipped. Do not alter detector, correction, baseline, event, tissue-support, statistics, UI behavior, version numbers or scientific rules.

The [proposed source manifest](planning/F07_03_PROPOSED_SOURCE_MANIFEST.json) names and hashes the planning inputs: **16 root additions, 44 existing root MATLAB files retained, 337 current helper MATLAB files, and three external MATLAB files**. The existing optional root smoke-test source is recorded separately; its execution is not included. No open-ended `helpers/**` or `external/**` inclusion is permitted: newly appearing files require a decision rather than automatic copying. This conservative source boundary preserves existing shared/legacy helpers without claiming they are all minimal BOI dependencies or validated features.

This is a source-list repair proposal, not packaging clearance. Existing non-MATLAB root assets are identified separately in the manifest and remain unverified for distribution. Do not build a partial package or silently declare the curation app, citation metadata, PDFs/SVGs or release-document links resolved. Their disposition and a complete release-document set remain separate gates before a package build.

## Named BOI entry points and required source files

`Start_OxygenPipeline.m` → `OxygenDynamics_GUI.m`, with `setupOxygenDynamicsPath.m`, `getOxygenPipelineVersion.m` and `OxygenDynamics_Config.m`, remain existing root requirements. The following **sixteen omitted root files** are proposed additions:

| Route | Required root additions |
| --- | --- |
| GUI “New analysis / reopen saved run”; shared batch preparation/execution | `openBOIRecordingWorkflow.m`, `prepareBOIRecordingRequest.m`, `reviewBOIRecordingInput.m`, `runBOIRecordingWorkflow.m`, `loadBOIRecordingRun.m` |
| Saved event/window review and optional temporal context, including exported reopen recipes | `openBOIEventReview.m`, `openBOIWindowReview.m`, `openBOITemporalContext.m` |
| Create event audit and reconstruct its measurement evidence | `createBOIEventAudit.m`, `auditOxygenEventAmplitudeSource.m` |
| GUI “Open saved review evidence” and public G4 bundle creation/loading | `openBOIG4EvidenceBundle.m`, `loadBOIG4EvidenceBundle.m`, `createBOIG4EvidenceBundle.m` |
| Public reviewed tissue-support preparation/persistence | `reviewBOITissueSupport.m`, `writeBOITissueSupport.m` |
| Statistics/summary provenance export called by shared helpers | `writeOxygenAnalysisManifest.m` |

The latter public creation/support tools are explicit package roots, not claims that every one is called directly by a GUI button. Existing engine roots remain `OxygenDynamics_Master.m` and `runOxygenDynamicsStats.m`; analysis code is included as source only. The dynamic master edge is explicit: `helpers/runOxygenDynamicsMaster.m` → `helpers/runLegacyAnalysisScript.m` → the string-named `OxygenDynamics_Master.m`. Do not rely solely on a lexical call scan to find it.

The manifest enumerates every helper by filename. Important families include the recording input/tissue contract, saved loaders, all BOI review panels, boundary/reference handling, event/window exporters, source hashing and pipeline-contract validation. External source requirements are exactly `external/abfload.m`, `external/loadtiff.m` and `external/saveastiff.m`, with `THIRD_PARTY_NOTICES.md` retained as a required notice document. This does not resolve project licensing or upstream provenance.

`runBOISoftwareChecks.m`, `runRepositoryChecks.m` and the `tests/` tree are development validation entry points, not additions to this product-source repair. Do not claim they are available in the resulting candidate. Preserve the existing legacy root-file behavior without adding non-BOI analysis work or running the optional smoke source.

## Explicit exclusions

Exclude recordings and acquisition inputs (`.tif`, `.tiff`, `.abf`, `.nwb`), saved analysis/result payloads (`.mat`, `.csv`, `.xlsx`), private local-source maps, generated output folders, `docs/reference-results/`, workspace `reference-validation/`, `Legacy_Archive/`, and all `tests/` development scripts/evidence. Explicitly deny `tests/analysis/reviewHPCachedReferenceEvidence.py`, even if someone attempts to add it by name. Its hard-coded volume must not enter the candidate through this repair.

Also exclude Git/agent metadata, prior package directories, unlisted files, symlinks and paths escaping the repository. These exclusions govern package eligibility; do not delete, relocate or modify any original recording, result, script or evidence. Required source/notice exceptions must be explicit; there is no blanket exception for a file merely because it resides in a source folder.

## Finite verification proposal

After implementation approval, pin the final packager, source-list helper if introduced, harness, fixture definitions and required source-list hashes **before evaluation**. Perform one static call-path review followed by **at most ten one-use offline manifest evaluations**, one per row below. Use injected in-memory file inventories derived from the approved manifest; mutate copies in memory only. No MATLAB, tests of the detector, real source execution, filesystem package copy, archive, live process operation, network access or CI run.

| # | Named case | Expected result |
| --- | --- | --- |
| 1 | `complete_boi_source_list` | All sixteen additions, retained roots, exact helper/external lists, notice and explicit dynamic master edge are represented; no silent omissions or duplicate destinations. |
| 2 | `missing_workflow_entry` | Remove `openBOIRecordingWorkflow.m`: reject as missing required source. |
| 3 | `missing_master_delegate` | Remove `helpers/runOxygenDynamicsMaster.m`: reject. |
| 4 | `missing_abf_reader` | Remove `external/abfload.m`: reject. |
| 5 | `recording_inclusion` | Attempt to add synthetic inventory entry `helpers/recording.tif`: reject despite its source-folder location. |
| 6 | `result_inclusion` | Attempt to add `helpers/DataOutput.mat`: reject. |
| 7 | `development_evidence_inclusion` | Attempt to add `docs/reference-results/example/evidence.json`: reject. |
| 8 | `machine_specific_script_inclusion` | Attempt to add the exact excluded development-script path: reject. |
| 9 | `outside_root_path` | Attempt to add `../private_source.m`: reject before resolution/copy. |
| 10 | `source_hash_drift` | Change the in-memory hash for `runBOIRecordingWorkflow.m` after pinning: reject rather than repin automatically. |

Every case must leave zero package directories, copied source files and archives. Report ordered decisions, pass/fail/untested, before/after hashes and consumption count. The harness must check the **same explicit source policy consumed by the revised packager**; a second unrelated list is not evidence of closure. Its static integration review must show validation precedes directory creation and all copy operations use that approved list. If this relationship cannot be verified without MATLAB, report the integration gap rather than treating a model of the list as an executed packager test.

Stop on the first failed case, input/code drift, missing approved ingredient, unexpected output or need for an excluded operation; no automatic retry. Preserve the failure and mark remaining cases untested. No fixing/retesting after a failed evaluation under this budget. Formatting/syntax review before the pinned evaluations is allowed; no uncounted fixture runs. Nonzero-short path variants, actual MATLAB resolution, GUI startup, copy/ZIP correctness, symlink/race handling and the full dependency graph at runtime are **not** demonstrated by these ten manifest cases.

## Delivery and remaining gates

Proposed delivery: a reviewable source-list patch, exact updated manifest, ten-case result record and factual plan/status update. A pass would establish bounded static/manifest closure only. Keep F07-03 open to the extent actual package verification remains unperformed; do not label a distributable release complete from this slice.

Project licensing, hosted CI/platform evidence, successful live acknowledgement, verified containment and real-acquisition resource measurements remain open. Historical `containment_failure`, consumed launch approval and the real-acquisition deferral are unchanged. No containment diagnostics, retry, MATLAB launch or package build is part of this proposal. F07-01/F07-02 documentation/version repair is also outside it.

Deferring this proposal leaves the known package omission recorded and all current software/evidence intact. Any implementation requires a separate explicit approval of this slice and its finite budget; any later package build or live validation needs another decision.
