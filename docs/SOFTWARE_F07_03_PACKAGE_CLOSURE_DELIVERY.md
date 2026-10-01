# F07-03 bounded source-list repair delivery

29 September 2026. **10/10 approved one-use offline manifest evaluations passed; no retries or untested named cases.** The static source-list repair is delivered. Actual MATLAB/package integration remains untested, so F07-03 is not fully closed and the package is not release-ready. Owner and reviewer: Codex assistant self-review; no independent reviewer participated.

## Patch

- [`createOxygenReleasePackage.m`](../createOxygenReleasePackage.m): replace the legacy root list and recursive helper/external directory copying with a validated exact list. Validate required paths/hashes before directory creation, then repeat the validation against the first plan immediately before `mkdirIfMissing(ReleaseFolder)`. Missing files no longer silently continue. The single copy loop consumes `SourcePlan.RelativePaths` and checks each source/copy hash. Output metadata explicitly retains `ReleaseReady=false` and unverified asset names.
- [`getOxygenReleaseSourceList.m`](../getOxygenReleaseSourceList.m): new source-list helper. Reads the shared JSON policy, checks duplicate destinations and the declared dynamic master edge, rejects excluded/unsafe paths and symlinks, requires file existence, computes hashes and compares the repeated plan. It contains no directory creation, copy or ZIP operation.
- [`OxygenReleaseSourcePolicy.json`](../OxygenReleaseSourcePolicy.json): authoritative filename/exclusion policy shared with the harness. Includes the sixteen approved missing roots, 44 retained root MATLAB files, 337 existing helper files and three external helpers. The new policy/helper and existing notice bring the mandatory list to 403 entries. Optional smoke source is separate; it was not executed. The twelve existing non-MATLAB assets remain explicitly unverified.
- [`runF0703ManifestChecks.py`](../tests/analysis/runF0703ManifestChecks.py) and [fixture definitions](planning/F07_03_FIXTURES.json): one-use offline harness and ten exact cases. They are development verification files and excluded from the product source policy.

No detector, correction, tissue, baseline, event, statistics, UI behavior or scientific version was changed. No unrelated existing edits were reset. The policy excludes recordings/results, development evidence, the whole tests tree and explicitly `tests/analysis/reviewHPCachedReferenceEvidence.py`. Nothing was deleted from those locations.

## Same-policy and ordering evidence

The harness reads the actual `OxygenReleaseSourcePolicy.json` consumed by the MATLAB helper, not a separate list of allowed files. Static checks confirm that the helper reads its inclusion/exclusion fields, that the packager calls the helper twice before its first directory creation, and that all source copies iterate only the returned plan. There is no intervening statement between final source-plan validation and the first directory creation. The helper validates required files without creating outputs. The harness also verifies the source roster against the approved planning manifest and checks the explicit string-named master dependency.

**This is shared policy data plus static integration evidence, not execution equivalence between Python and MATLAB.** The offline evaluator is an independent Python interpreter of the JSON fields. MATLAB's JSON handling, Java path/symlink APIs, actual file resolution and filesystem copy behavior were not executed. The static source checks do not establish race-free copying or closure of every dynamic runtime dependency.

The twelve retained asset entries used synthetic in-memory existence/hash placeholders. Their actual contents were not opened or cleared by this matrix. The future MATLAB path would require and hash them; the offline positive case is not evidence that those checks succeed on a real host. This repair retains their existing package inclusion behavior but marks them unverified; their disposition, documentation closure and licensing must be resolved before an authorized build.

## Cases and ordered decisions

Every evaluation first consumed the shared policy. The next decision is listed below; the [machine record](planning/F07_03_CASE_RESULTS.json) contains the exact paths, traces, expected/actual outcomes, operation counts and post-test hashes.

| # | Case | Result | Decision after policy load |
| --- | --- | --- | --- |
| 1 | `complete_boi_source_list` | Pass | `source_list_validated` — manifest only |
| 2 | `missing_workflow_entry` | Pass | `missing_required_file` — `openBOIRecordingWorkflow.m` |
| 3 | `missing_master_delegate` | Pass | `missing_required_file` — `helpers/runOxygenDynamicsMaster.m` |
| 4 | `missing_abf_reader` | Pass | `missing_required_file` — `external/abfload.m` |
| 5 | `recording_inclusion` | Pass | `rejected_exclusion` — `helpers/recording.tif` |
| 6 | `result_inclusion` | Pass | `rejected_exclusion` — `helpers/DataOutput.mat` |
| 7 | `development_evidence_inclusion` | Pass | `rejected_exclusion` — `docs/reference-results/example/evidence.json` |
| 8 | `machine_specific_script_inclusion` | Pass | `rejected_exclusion` — `tests/analysis/reviewHPCachedReferenceEvidence.py` |
| 9 | `outside_root_path` | Pass | `rejected_path` — `../private_source.m` |
| 10 | `source_hash_drift` | Pass | `source_hash_drift` — `runBOIRecordingWorkflow.m` |

The positive fixture includes the declared master edge and has no duplicate destinations. Negative cases reject three missing required sources, recording/result/evidence/script inclusion, a path outside the root and a changed source hash. All mutations were in memory. Every case left zero package directories, copied files and archives. Native/process/network/package-write attempts were blocked by the harness; no blocked-operation attempts occurred. The only evaluation output was its local JSON evidence record.

## Pinned final hashes

The [final pin manifest](planning/F07_03_FINAL_CODE_HASHES.json) was written before evaluation and covers **407 code, fixture, policy and source inputs**. Every per-case check and the final post-test comparison matched; no executable/harness/fixture edits followed the pin. The [proposed source manifest](planning/F07_03_PROPOSED_SOURCE_MANIFEST.json) remains a historical planning input with its original hashes; the final pin records the changed packager and new helper/policy.

| File | Final SHA-256 |
| --- | --- |
| `createOxygenReleasePackage.m` | `548310d2d30dc10f4766cf89261294a4837b263bb3e43d7b54a428c84cd45989` |
| `getOxygenReleaseSourceList.m` | `5c568c4b242e184cc3c037589a6504a08ab656fb2701c2163eea92cf6f632533` |
| `OxygenReleaseSourcePolicy.json` | `f04feffe6c2d398b1fc59dd99f96a3a20b7f153486a3c6f701f4da3cc7f6c6f1` |
| `tests/analysis/runF0703ManifestChecks.py` | `6063c9e293183a24d9ef0e45165bff48362adbd162986e6172531052c7ff9cd0` |
| `docs/planning/F07_03_FIXTURES.json` | `23751bf31f1c9f9ae1fb5b0ee215806f528ae368d5dddde6b4c3874b11e47c73` |

## Limits and stopping point

No MATLAB launch, package directory, source-copy operation, ZIP, recording access, detector/statistics run, network access, hosted CI or publication occurred. The ten-case budget is consumed with no retry.

Remaining integration gaps: MATLAB syntax/runtime behavior and resolution; optional smoke-disabled configuration; real missing-file/permission behavior; symlink, path-alias and copy-time races; post-copy failure cleanup; actual folder/ZIP contents; twelve retained assets and release-document links; and the complete runtime dependency graph. These are not passes merely because the static policy matrix passed. The prior static audit remains evidence for its original inputs.

F07-03 now has a source-list patch and bounded offline evidence, but remains open for actual package integration. Licensing, hosted CI/platform evidence and the three deferred live/resource blockers remain open. Historical `containment_failure` and consumed launch approval are unchanged. No further check, asset inspection, package build or live attempt is automatic; researcher review of this delivery is the next decision. This is not G5 or release acceptance.
