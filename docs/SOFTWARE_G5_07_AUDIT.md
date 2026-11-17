# SW-G5-07 static support and release audit

29 September 2026. **Audit complete within the approved scope: one local inventory and six named static assessments. Release remains blocked.** Three assessments contain confirmed failures, two retain untested evidence gaps, and one passes its narrow reconciliation check. No tests, MATLAB, network access, excluded recording reads, containment diagnostics, repairs, package creation or publication occurred. Owner and reviewer: Codex assistant self-review; no independent reviewer participated.

## Scope and reproducibility

Repository HEAD: `066ba13c6902ad2acf32d442d72ac791e6bfc98a`. Findings describe the **dirty worktree**, not that commit alone. The inventory captured 327 Git-status entries, including 30 modified tracked files. Existing changes were preserved.

The [input manifest](planning/SW_G5_07_INPUT_MANIFEST.json) records 569 entries: 561 hashed text inputs and eight files outside the text allowlist. The [candidate manifest](planning/SW_G5_07_CANDIDATE_MANIFEST.json) records one scan of 547 proposed software text files, the patterns, line-level hits and manual triage. The [final manifest](planning/SW_G5_07_FINAL_MANIFEST.json) records **zero drift across all 561 text inputs** at assessment completion, before factual plan/status updates. No existing source was edited. The two authorized planning-file updates are recorded separately from that input snapshot.

Inventory scope was root software/configuration/release text, `helpers/`, `external/`, `tests/`, `.github/workflows/`, and the named G1–G5 documents/current plan/status. `docs/reference-results/`, workspace `reference-validation/` payloads, acquisition volumes and raw recordings were not opened. Git status may name excluded evidence directories; it was used only as worktree metadata. Historical execution claims below come from the approved delivery documents; their linked payloads were not revalidated.

The eight uninspected formats are two PDFs, two SVGs, `OxygenDynamics_Sinks_Curation.mlapp`, `CITATION.cff`, `Update-GitHub.cmd` and `Update-GitHub.ps1`. The inventory label `nontext_excluded_not_read` denotes exclusion from this text allowlist, **not** a claim that CFF/SVG/scripts are binary. Their contents remain untested. No package exists for this audit, and the candidate manifest is not a complete or cleared distribution.

## Six assessment results

| Assessment | Result | Finding and limit |
| --- | --- | --- |
| A — support claims | **FAIL** | README presents G2 as awaiting approval despite delivered G2 and accepted G3/G4. Platform coverage separately remains untested beyond the recorded examples. |
| B — CI evidence | **UNTESTED** | BOI runner wiring is statically present. Hosted Linux/R2025b execution evidence is absent from the inspected records; no remote status was queried. |
| C — versions and saved-result contracts | **FAIL** | Manual and central build timestamps disagree. Current rejection/no-overwrite checks are visible, with historical fixture evidence; no current execution or cross-version validation occurred. |
| D — dependency notices | **UNTESTED** | Notices cover the six named bundled/adapted components, but project licensing and parts of upstream revision provenance remain unresolved. Missing permission evidence is not reported as a test failure or legal clearance. |
| E — shareability and package contents | **FAIL** | The legacy package list omits current GUI dependencies. A candidate development script contains a machine-specific volume path; uninspected formats and documentation closure remain unresolved. |
| F — release evidence reconciliation | **PASS, static only** | The matrix below preserves accepted evidence, failures, untested paths and all three deferred blockers. This passes record reconciliation, not release readiness. |

## A. Support matrix and stale claims

| Component/environment | Declared or inferred requirement | Actual evidence in scope |
| --- | --- | --- |
| MATLAB / macOS ARM | README lines 321–325 names MATLAB and desktop GUI; minimum supported release is not specified | G2 reports R2025a/macOS ARM 129/129; G4 reports 134/134; G5-05 reports 136/136. These are historical named suites, not a fresh pass on every current file. |
| MATLAB / Linux | CI specifies Ubuntu and R2025b | Configuration only. G2 lines 142–144 and G4 explicitly state hosted execution was not performed. Desktop/native chooser behavior on Linux is untested. |
| MATLAB / Windows and other releases | No completed matrix in the inspected evidence | Untested. Do not infer support from portable-looking MATLAB source. |
| Image Processing Toolbox | Declared for core imaging; calls such as `regionprops` appear in `helpers/detectFrameRegionCandidates.m:32` | CI requests this toolbox. A minimal-toolbox environment was not demonstrated by this audit. |
| Statistics and Machine Learning Toolbox | README declares it for selected optional statistics/vascular/amyloid analyses; CI requests it | Exact feature-to-toolbox/minimum-version closure is untested. Static function names alone are not a tested dependency envelope. |
| Java support inside MATLAB | Canonical paths use `java.io.File`; source hashing uses `java.security.MessageDigest` (`loadBOIRecordingRun.m:5`, `helpers/oxygenFileSHA256.m:6`) | Static dependency visible. A no-JVM configuration is not established as supported. |
| Outlook integration | README declares optional Windows COM notifications; `helpers/sendolmail.m:7` calls `actxserver` | Optional route only; no Outlook/platform execution in this audit. |
| Python development scripts | Present under tests/analysis, with imports such as Pillow | Outside the declared main MATLAB pipeline requirement. Their environment/support is not validated or implicitly added to product requirements. |

**F07-01, P2 documentation failure:** `README.md:1` labels the current workflow G2 development and lines 31–35 describe the G2 proposal as ready for approval. `docs/SOFTWARE_G2_WORKFLOW.md` records delivery; `SOFTWARE_G3_USABILITY_ACCEPTANCE.md` and `SOFTWARE_G4_DELIVERY.md` record subsequent acceptance. These are conflicting current-status statements. The older 185-test headline at README line 109 is not treated as a pass on the current worktree; its different historical suite is not directly comparable with the 136-test BOI gate. No historical test number was changed.

## B. CI wiring versus execution

`.github/workflows/matlab-ci.yml:21–41` configures a 30-minute Ubuntu job, MATLAB R2025b, two toolboxes and `runRepositoryChecks; runBOISoftwareChecks`. Triggers include pull requests, manual dispatch and selected push branches. Their existence does not establish that the current dirty files were pushed or executed remotely.

`runRepositoryChecks.m:23–55` counts Code Analyzer messages and runs a synthetic hypoxia/amyloid check; it does not fail solely because the analyzer reports messages. `runBOISoftwareChecks.m:4–18` constructs thirteen named BOI/contract suites and asserts nonempty results, all passed and none incomplete. These are positive **static wiring** observations, not test results. The GUI/native chooser and hosted runner behavior remain untested here. The existing non-BOI synthetic check was inspected as a direct runner dependency, not executed or expanded.

No current hosted run ID/log or platform result was available in the permitted evidence. No network request, workflow dispatch or CI repair was made. The release precondition “passing CI” in `RELEASING.md:11` remains unsatisfied by evidence in this audit.

## C. Version and saved-result contracts

**F07-02, P2 metadata failure:** `USER_MANUAL.md:75–77` identifies build `2026-06-15 09:50:08 +02:00`, while `getOxygenPipelineVersion.m:6` returns `2026-06-15 15:00:55 +02:00`. Both use `1.01`; the build disagreement is concrete. README describes unpublished V3 development; `RELEASING.md:3–5` itself says the release line/tag/internal version need reconciliation. This audit did not inspect remote tags or choose a new version.

The analysis schema is deliberately separate from UI/release version: `helpers/oxygenPipelineContract.m:5–12` uses `3.0-dev` for whole-image and `3.1-roi-dev` for reviewed ROI. README line 107 describes only `3.0-dev`; the profile distinction should be documented. Distinct schema/version identifiers are not inherently a code defect.

| Contract | Current static evidence | Historical evidence / remaining gap |
| --- | --- | --- |
| Analysis reuse | `validateOxygenPipelineContract.m:4–21` checks exact profile contract, schema, support/calibration, effective parameters and exposure | No recomputation or cross-release compatibility test performed. |
| Complete run reopening | `loadBOIRecordingRun.m:6–52` requires complete status, `boi-recording-run-1`, nine unique artifact roles, in-directory paths, checksums and matching source/support | G5-05 records corrupt/incompatible rejection, including the initial discovery defect and fix. Its payload/code manifests were excluded, so exact historical-to-current hash equivalence remains unverified. |
| Discovery | `openBOIRecordingWorkflow.m:238–264` checks complete status and supported index schema before listing | Static fix is present; prior 16/16 workflow and 136/136 BOI results remain historical, not newly rerun. |
| Fresh output/no overwrite | `prepareBOIRecordingRequest.m:30–31` rejects existing output; `runBOIRecordingWorkflow.m:11–20` repeats preflight and checks directory claim; staged/source hashes are checked | No concurrency, crash-durability or filesystem behavior was tested. |
| G4 evidence | Loader checks fixed filenames, index schema and hashes; creator rejects existing destination/local map (`createBOIG4EvidenceBundle.m:7–10`) | G4 records portable reopen, changed-copy/overwrite/mismatch checks and bounded researcher acceptance. No replay or new reviewed amplitude calculation occurred. |

## D. Dependency notices and licensing evidence

| Local component | Locally recorded terms / attribution | Gap |
| --- | --- | --- |
| `external/abfload.m` | Notices: BSD-2-Clause, Hentschke/Collman; source credits both | Exact upstream revision unrecorded; notice explicitly records a local 10 September change. |
| `external/loadtiff.m` | Source refers to BSD-3-Clause-style terms in notices, Yoon-Oh Tak | Source copyright year 2012 versus notices 2019 needs provenance reconciliation; not proof of permission failure. |
| `external/saveastiff.m` | Adaptation of Multipage TIFF stack, terms referenced in header | Starting revision/modification history unrecorded in notices. |
| `helpers/peakfinder.m` | Notices: BSD-2-Clause, Nathanael C. Yoder | Header year 2015 versus notice 2016; exact incorporated revision unresolved. |
| `helpers/plot_areaerrorbar.m` | BSD-3-Clause notice and source attribution, Martinez-Cagigal | Exact upstream revision not established by inspected text. |
| `helpers/hex2rgb.m` | BSD-3-Clause notice and source attribution, Chad Greene | Exact upstream revision not established by inspected text. |

All three `external/` files appear in the notice inventory. No top-level LICENSE/COPYING file was found in the local inventory. README lines 369–373 explicitly says project licensing is under review; `RELEASING.md:8` requires approval/addition before release. **Project redistribution clearance remains an open release blocker**, not an inferred permission grant. Upstream URLs were not opened, and this is not a legal opinion or a complete third-party provenance audit beyond the named local scope.

## E. Candidate files, private paths and packaging defect

**F07-03, P1 package dependency failure:** `createOxygenReleasePackage.m:77–140` has a fixed root-file list plus `helpers/` and `external/`. It includes `OxygenDynamics_GUI.m` but omits `openBOIRecordingWorkflow.m` and `openBOIG4EvidenceBundle.m`, which that GUI calls at lines 40–41 and 50. It also omits their new root services, including `prepareBOIRecordingRequest.m`, `runBOIRecordingWorkflow.m`, `loadBOIRecordingRun.m`, `createBOIG4EvidenceBundle.m` and `loadBOIG4EvidenceBundle.m`. Static consequence: a package made solely with that list would lack functions needed for the advertised new/reopen and evidence routes. No archive was created or runtime failure claimed. This is a release blocker requiring a separately approved repair/verification scope.

**F07-04, P2 candidate portability finding:** `tests/analysis/reviewHPCachedReferenceEvidence.py:77` hard-codes `/Volumes/extZCM361_2`. This development script must be explicitly excluded from the product distribution or receive a separately approved portability change. It is not evidence that private recording bytes are bundled, and it is not copied by the current legacy packager.

The broad candidate scan raised 47 file-level hold flags. These are **not 47 defects**: the Windows-path regex also matches prose ending with escaped newlines; generic `C:\\User`, `D:\\Data` and `D:\\path` examples are placeholders; animal IDs in synthetic tests are not automatically private data. The manifest retains the raw hits and manual triage rather than claiming a fully sanitized tree. Uninspected formats remain excluded/unresolved. The candidate intentionally excludes development documentation and payloads, so README links into excluded docs need a deliberate release-document set; this is not a dependency-complete package manifest.

Runtime source provenance is different from hard-coded developer paths. Full saved runs retain local source information; they must not be assumed shareable wholesale. G4 separates the private local source map from the evidence folder (`createBOIG4EvidenceBundle.m:175–179` and `SOFTWARE_G4_DELIVERY.md:18`). That is static/documented evidence only here: the actual bundle and recordings were not accessed. No historical provenance was removed.

## F. Release evidence and bounded choices

| Gate / issue | Evidence status | Severity and owner role | Next decision |
| --- | --- | --- | --- |
| G3 daily-use and bounded G4 usability | Accepted within the recorded examples; no fresh runtime validation | Preserve; researcher | No reopening of accepted examples under this audit. |
| G5 analysis/statistics boundary failures and G5-05 contracts | Historical named evidence accepted; internal engine faults and broad recovery remain untested | Reliability lead + researcher | Any additional execution needs its own finite contract. |
| Successful live acknowledgement | **UNTESTED; explicit open release blocker, deferred** | Blocking; researcher/containment reviewer | No diagnostics or launch unless separately reconsidered. |
| Verified containment | **UNTESTED; explicit open release blocker, deferred** | Blocking; containment reviewer | Historical `containment_failure` and consumed approval unchanged. |
| Real-acquisition runtime/peak memory and integration | **UNTESTED; explicit open release blocker, deferred** | Blocking; workflow/validation lead | No recording attempt or automatic retry. |
| Hosted CI/support matrix | **UNTESTED** beyond configuration and historical local examples | Release evidence gap; validation lead | Separately approve a platform-evidence scope if desired. |
| F07-01 / F07-02 documentation and build identity | **FAIL** | P2; maintainer/documentation owner | Approve a documentation/version reconciliation scope; choose version policy explicitly. |
| Project licence and upstream provenance | **UNTESTED/unresolved**; project licence is a release precondition | Blocking project licence; rights holder/maintainer | Obtain the maintainer's licence decision and provenance evidence; no assumption of permission. |
| F07-03 package dependency closure | **FAIL** | P1 release blocker; workflow/packaging owner | Separately approve a source-manifest correction and bounded verification before packaging. |
| F07-04 / uninspected formats / release documentation set | **FAIL** for confirmed candidate path; remaining coverage **UNTESTED** | P2; packaging owner | Approve explicit exclusions/document selection and any further inspection. |

Recommended next choice: **a bounded documentation and candidate-manifest reconciliation proposal**, covering F07-01/F07-02 and an explicit product/development boundary. It should keep the current scientific versions intact until any version decision is approved, and perform no tests or packaging. This is a proposal for the next decision, not authorized work.

Alternative: request a separate **package dependency repair proposal** for F07-03, with a finite static dependency list and verification budget before implementation. Licence selection remains a rights-holder decision. Platform execution can stay deferred alongside the real-acquisition blockers. The researcher may also stop here and retain the audit as the readiness record.

No follow-up is automatic. This audit neither approves its own repairs nor constitutes G5/release acceptance. The one inventory and six assessments are consumed and complete; no containment work or live attempt is proposed.
