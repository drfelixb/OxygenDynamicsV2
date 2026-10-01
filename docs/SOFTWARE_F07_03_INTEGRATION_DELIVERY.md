# F07-03I local package integration delivery

29 September 2026. Owner and reviewer: Codex assistant, **self-review only**.
Technical acceptance checks passed; researcher acceptance is pending. This is a
local integration candidate, not a release or G5 completion.

## Candidate and evidence

- [Candidate ZIP](../../reference-validation/f07-03-integration-local/iteration-01/candidate.zip)
- [Candidate folder manifest](../../reference-validation/f07-03-integration-local/iteration-01/candidate/RELEASE_MANIFEST.txt)
- [Budget](../../reference-validation/f07-03-integration-local/budget.json)
- [Pinned source and harness hashes](../../reference-validation/f07-03-integration-local/iteration-01/pins.json)
- [Folder/ZIP/extraction inspection](../../reference-validation/f07-03-integration-local/iteration-01/inspection-result.json)
- [MATLAB resolution and Code Analyzer record](../../reference-validation/f07-03-integration-local/iteration-01/resolve-result.json)
- [Pre-directory rejection checks](../../reference-validation/f07-03-integration-local/negative-result.json)
- [Final hash gate](../../reference-validation/f07-03-integration-local/final-hash-gate.json)
- [MATLAB session log](../../reference-validation/f07-03-integration-local/matlab-session-01.log)

Paths above are relative to this repository's docs directory and reach the sibling
workspace evidence directory. The candidate carries no evidence packet.

## Result and finite budget

One actual MATLAB R2025a package build passed in **7.414 seconds**. One ordinary
packaging-only MATLAB start was used; it exited normally with code 0. Session
path/current-folder restoration was observed (workspace folder restored; zero
checkout path entries). No existing MATLAB session was running.

**Three validation batches**, all passed:

1. Exact folder/ZIP inspection: **414 files = 413 policy-listed inputs plus the
   generated RELEASE_MANIFEST.txt**. No duplicate/case-colliding, absolute,
   traversal, symlink or excluded entries. The archive was validated before
   extraction. Source/folder/archive/extracted bytes match.
2. Extracted-package MATLAB resolution: **26/26 named targets** resolve inside
   the extracted folder with no checkout fallback. All 413 policy inputs were
   validated by the actual MATLAB policy helper. The explicit master delegate /
   legacy-script / master-file edge is included. MATLAB syntax trees report no
   parse errors; Code Analyzer reports 49 existing advisories (growth, extra
   commas, unreachable code, scalar checks, unused values, alignment and display
   style). These are retained, not described as zero warnings. No named engine,
   statistics, GUI or review function was invoked.
3. Actual MATLAB packager negative checks on separate disposable candidate copies:
   missing `openBOIEventReview.m` raises
   `OxygenDynamics:ReleaseRequiredFileMissing`; a policy entry for
   `Data/forbidden.tif` raises `OxygenDynamics:ReleaseExcluded`. In both cases the
   proposed output root remains absent. The exclusion case uses an inventory
   entry only: no recording file was created or read.

Usage: **1/4 builds, 3/12 validation batches, 1/2 MATLAB starts**. No failed
candidate or packaging runtime error required a rebuild. The final hash
reconciliation is a hash gate, not another runtime validation batch. Runtime
records and retained disposable fixtures occupy about **7.5 MiB**, comfortably
below 2 GiB; over 119 GiB remained free versus the 4 GiB floor. Total elapsed
work was under ten minutes, versus the two-hour limit. No detector, statistics,
synthetic analysis, recorded-movie analysis, acquisition-worker or containment
check was run. The supplemental Python warning-summary formatter initially
needed normalization of MATLAB's single-object JSON shape; this did not rerun
or change any MATLAB check.

## Packaging patch

Before the first build, the packager was changed to give `zip` an exact relative
file list anchored at the candidate root, avoiding host-directory prefixes.
It also refuses an existing destination file or ZIP, preserving prior outputs.
The manifest keeps an explicit not-release-ready statement.

The policy adds `PACKAGE_CONTENTS.md` and excludes four nonessential assets:
`CHANGELOG.md`, `Amplitude_Definition_Comparison.pdf`,
`Science_vs_Current_Analysis_Differences_20260601.pdf`, and
`OxygenDynamics_Sinks_Curation.mlapp`. All originals remain unchanged. The twelve
initial assets were screened locally; the MLAPP member list and MATLAB XML were
inspected, but its opaque appModel/screenshot were not certified. It is therefore
excluded, not claimed cleared. The comparison PDFs were screened by file header
and title for exclusion, not scientifically or visually reviewed. Development
history is omitted. Eight retained text/SVG assets have no detected embedded
acquisition payload or absolute machine paths. This is not a comprehensive
privacy or licensing review.

README and USER_MANUAL each gain a short candidate notice linking
PACKAGE_CONTENTS.md. That document explains deliberately omitted repository
`docs/` links and untested legacy functionality; it does not rewrite historical
scientific documentation. Notices, citation and third-party attribution remain
included. A candidate text scan found no `/Users/`, `/Volumes/` or `/home/` paths.

Compared with the initial 416 input hashes, only four existing files changed:
`createOxygenReleasePackage.m`, `OxygenReleaseSourcePolicy.json`, README and
USER_MANUAL. The other 412 initial inputs, including excluded originals, remain
unchanged. PACKAGE_CONTENTS is new; plan/status/evidence updates are separate.
All final source and harness pins match. Earlier F07 ten-case evidence and prior
outputs were not rerun, overwritten or removed.

ZIP SHA-256: `9e42d5c91efcee43f22ce2fe9a69097f73f244823a011f8ab61766d827bb2569`.

## Remaining limitations

This demonstrates the actual package build, exact content/hash integrity and
named BOI resolution/parse closure. It does **not** prove all dynamic dependencies,
optional toolbox availability, every legacy workflow, GUI execution or scientific
correctness from the package. The old curation app is intentionally absent.
Repository-only documentation links and historical version/status reconciliation
remain visible limitations; no version was chosen or changed.

Project licensing, hosted CI, successful acquisition-worker acknowledgement,
verified containment, and real-acquisition resource measurements remain open.
Real-acquisition integration is unverified. Historical `containment_failure` and
consumed approvals are unchanged. No publication or release approval is implied.
The next decision is acceptance of this bounded local integration candidate;
there is no automatic further diagnostic or run.
