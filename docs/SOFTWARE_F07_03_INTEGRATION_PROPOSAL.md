# F07-03I — one bounded local package integration slice

29 September 2026. **Approved by the researcher on 29 September 2026 for this complete bounded scope.** Owner: Codex assistant; self-review reported accurately. This replaces further one-error-at-a-time proposals for ordinary F07-03 packaging problems. It does not reuse or extend a consumed startup/recording approval.

## Outcome

Deliver a disposable local package folder and ZIP whose contents agree with the final explicit source policy, plus a focused MATLAB record showing the named BOI entry points resolve from an independently extracted copy. Include the final source patch, inventories/hashes, correction history and remaining limitations. The result is a **local integration candidate**, not a distributable or published release.

## One approval covers

1. **Freeze inputs and prepare the local candidate.** Preserve the current dirty worktree and all prior evidence. Record starting hashes and the exact source policy. Inspect the twelve retained non-MATLAB assets named in that policy locally, including archive-member inspection for the MLAPP, only to determine candidate inclusion, dependencies and accidental data/path exposure. Do not open recordings or development-result directories. Keep mandatory notices and attribution. Exclude clearly nonessential development material; record exclusions and any affected help links. An essential asset that cannot be assessed within this scope is a material blocker, not an assumed pass.
2. **Execute the actual MATLAB packager.** Exercise `getOxygenReleaseSourceList` and `createOxygenReleasePackage` on the current source into a fresh numbered destination. Verify required-file validation occurs before package creation. Use ordinary local MATLAB for packaging/inspection only, never the consumed startup worker or acquisition supervisor. No analysis request, `ui.Run`, master, detector or statistics invocation is allowed.
3. **Inspect the folder and ZIP.** Enumerate actual contents, compare exact relative paths and per-file hashes with the approved list, and allow only the explicitly generated release manifest as additional content. Reject duplicates, traversal, absolute paths, symlink entries and exclusions. Extract only validated archive members into a new empty directory. Compare extracted hashes against the package folder and source snapshot. A folder merely existing or ZIP returning success is insufficient.
4. **Check package-only resolution in MATLAB.** Temporarily isolate the MATLAB path/current folder from the development checkout, preserving and restoring the existing session settings with cleanup handlers. Run the packaged `setupOxygenDynamicsPath`, then record `which` results for the entry points/services below. They must resolve inside the extracted candidate, with no development-checkout fallback. Check source parse/Code Analyzer errors without invoking the functions. Do not open a recording or start the analysis/review GUIs as a substitute for a resolution check.
5. **Repair and repeat within this slice.** Fix ordinary packaging defects and rerun affected checks. Finish with one complete folder/ZIP/resolution pass against the final hashes. Preserve earlier failed candidates and logs with their failure status; present the working final candidate or a material blocker. Do not ask for approval for each ordinary error.

## Exact resolution targets

Launcher: `Start_OxygenPipeline`, `OxygenDynamics_GUI`, `setupOxygenDynamicsPath`.

Recording route: `openBOIRecordingWorkflow`, `prepareBOIRecordingRequest`, `reviewBOIRecordingInput`, `runBOIRecordingWorkflow`, `loadBOIRecordingRun`.

Saved review: `openBOIEventReview`, `openBOIWindowReview`, `openBOITemporalContext`, `openBOIG4EvidenceBundle`, `loadBOIG4EvidenceBundle`, `createBOIG4EvidenceBundle`.

Audit/support/export: `createBOIEventAudit`, `auditOxygenEventAmplitudeSource`, `reviewBOITissueSupport`, `writeBOITissueSupport`, `writeOxygenAnalysisManifest`.

Shared implementation: `runOxygenDynamicsMaster`, `runLegacyAnalysisScript`, `OxygenDynamics_Master`, `runOxygenDynamicsStats`, `loadtiff`, `saveastiff`, `abfload`.

Also verify the explicit dynamic edge from the master delegate to `OxygenDynamics_Master.m`, and that all policy-listed helper sources are present with matching hashes. The master/statistics names are **resolved only**, never called. The full dependency graph and GUI behavior at runtime remain outside the resulting claim.

## Routine fixes authorized by a later approval of this whole slice

- Packaging/helper MATLAB syntax or API compatibility, JSON shape handling, exact-list completeness, relative-path calculation, destination creation and file/ZIP layout.
- Missing BOI packaging dependencies discovered from the named routes, provided they are existing repository source or necessary packaging infrastructure and do not change scientific behavior. Log each addition and why it is required; no blanket recursive copying.
- Exclusion enforcement, preservation of notices, package-only path setup in the verification harness, and release-manifest accuracy.
- Narrow packaging documentation/help-link corrections and exclusion of nonessential development assets. Do not decide a release version, change scientific definitions, rewrite the general manual or select a licence.

Do not reset or clean the worktree, overwrite old results, alter raw data, or patch the detector/measurement/GUI workflow to make a packaging check pass. An apparent source defect outside packaging is documented and reported as a blocker or limitation.

## Finite budget and preservation

- **At most four build/rebuild iterations**, each with a fresh numbered folder and ZIP; no overwrite of a failed candidate.
- **At most twelve focused validation batches** across those iterations. One batch is a logged invocation of the package-policy/negative-check harness, a folder/ZIP integrity inspection, or the complete named MATLAB resolution check. A final full inspection/resolution consumes the same budget; reserve capacity for it. Ordinary static reads, edits and source hashing are not extra runtime batches.
- **At most two ordinary MATLAB session starts** if no suitable session is already available or one needs replacement; otherwise use the existing session with temporary path/folder state restored. These are packaging-only sessions, not renewed containment diagnostics or acquisition-worker attempts. Stop rather than repair MATLAB installation, licensing or startup infrastructure.
- Stop after **two hours of active execution work**, or before a further build if fewer than **4 GiB** are free. Keep all candidate/evidence output under **2 GiB** total. Check after each batch and before the next build; these are operational checks, not a validated process-memory/containment guarantee. A packaging call that does not return within ten minutes is a material blocker; interrupt only the owned packaging operation through the normal session interface, with no broad process killing or containment redesign.
- Use `reference-validation/f07-03-integration-local/` as a new run root. If it already exists, choose a fresh suffixed run root and record it; do not erase/reuse it. Put `iteration-01`, subsequent numbered candidates, ZIPs, extracted copies and logs beneath that root. Evidence stays outside the candidate source list. No external acquisition volume is needed.
- Pin source/policy/harness hashes before each iteration and report intentional patch changes between iterations. Final source/folder/ZIP/extracted hashes must agree. Preserve the historical ten-case evidence for its original hashes; use new integration records rather than rerunning its consumed one-use harness.

If the budget is exhausted, preserve the partial work and report the remaining blocker. Do not expand the budget automatically or start a new diagnostic phase.

## Invariants and acceptance

Keep exclusions for recordings, saved results, development evidence, private local-source maps, tests, agent/Git metadata and `tests/analysis/reviewHPCachedReferenceEvidence.py`. Scan candidate files/assets only; do not copy excluded data into the candidate to test rejection. Small in-memory inventories or disposable minimal source-list fixtures may exercise missing-file/exclusion errors. No synthetic or recorded-movie analysis is part of this scope.

Technical acceptance requires: (a) the actual packager succeeds; (b) folder, ZIP and extracted contents satisfy the final exact policy and exclusions; (c) hashes match; (d) all named resolutions point into the extracted package and no parse-blocking error remains; (e) original non-packaging source and prior outputs are preserved; and (f) the report names untested behavior and remaining gates. Self-review is not independent review. Researcher acceptance of the delivered integration candidate remains separate from G5/release acceptance.

**Material blockers requiring a stop/report:** need for scientific/output-changing code, excluded acquisition data, network/install work, unresolved essential assets or rights requirements, inability to isolate package resolution from checkout, uncontrolled writes outside the disposable root, unrelated user changes that cannot be safely preserved, repeated environmental failure, or exhaustion of the above budget. Routine packaging errors within the listed scope are fixed without a new permission request.

Licensing and hosted CI remain open. The three deferred live/resource blockers—successful acquisition-worker acknowledgement, verified containment and real-acquisition resource measurement—stay open, as does real-acquisition integration. A packaging-only MATLAB session does not close any of them. Historical `containment_failure` and consumed launch approval remain unchanged. No recorded-movie analysis, publication/upload, licence decision, release acceptance or reopening of that gate is authorized by this proposal.

**Requested single decision:** approve F07-03I as this whole integration-and-repair slice. After approval, work autonomously within these boundaries and return the working candidate plus limitations, or the material blocker, rather than seeking permission for each routine correction.
