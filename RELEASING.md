# Release decisions and future publication

`v3.1.0-rc.1` is the public prerelease for the BOI Batch Editor workflow.
The researcher confirmed clearance for public redistribution of the new V2
contributions under MIT on 17 November 2026. The release uses the exact
verified source snapshot and source archive. See [licensing](LICENSING.md)
and the [release comparisons](docs/RELEASE_NOTES_3.1.0_RC1.md).

## Choosing and setting a version

Use three-part versions. Increment the first number when a workflow is removed or an existing output changes meaning, the second for a new feature that preserves existing outputs, and the third for fixes without output changes. Between releases, `main` carries `X.Y.Z-dev`. Prepare `X.Y.Z-rc.N` candidates and the final `X.Y.Z` on a release branch. Keep released numbers off `main`.

Every pull request adds a line under Unreleased in `CHANGELOG.md` labelled **Added**, **Changed output**, **Fixed** or **Removed**. The highest-impact change determines the proposed increment. The researcher approves the number before it is set.

The researcher approved 4.0.0 as the next release on 24 November 2026, with a release candidate first. After `setupOxygenDynamicsPath`, run `setOxygenVersion(newVersion)` from a development checkout for an approved version change. It updates the authoritative getter, its build timestamp and the current checkout declarations in CITATION.cff, README.md, INSTALLATION.md and DISTRIBUTION_STATUS.md. Development citations omit the release date. A candidate or final release uses the date the version is set. Dated examples, licence records and published release notes keep their original versions.

Saved identities include the full source commit and checkout state. A modified checkout can contain staged or unstaged edits or untracked, non-ignored files. A source copy outside a checkout records `unknown` for both fields. Re-exporting uses the original calculation identity if recorded and separately identifies the current exporter.

## Before proposing publication

- Retain the [original Science_2024 MIT notice](licenses/Science_2024-MIT.txt)
  and confirm licensing coverage/authority for new V2 contributions. See
  [licensing and credits](LICENSING.md).
- Retain [dependency notices](THIRD_PARTY_NOTICES.md), required disclaimers and
  attributions, and disclose the unknown historical dependency origins.
- Declare support and claims within the actual evidence in
  [distribution status](DISTRIBUTION_STATUS.md). The complete Linux portable pass,
  partial final macOS gate and named saved workflows are separate evidence.
- Decide the exact release version, source commit, destination and archive hash.
  Felix's completed FB2311 case supplies integration and 293.60 s elapsed time;
  peak memory and broader recording/runtime support remain unverified. His
  demonstrated sink workflow is distinct from an unfamiliar scientist's walkthrough.
- Review source/citation metadata, applicable notices and package exclusions.
  Keep original calculations, results and scientific qualifications traceable.

Any additional tests, recording runs or numerical adoption must have their own
finite approval. Preparing these instructions or a development archive does
not authorize those activities or establish physiological validity. VM/watchdog/
custom containment and worker qualification remain deferred pending a separate decision.

## Run the release runbook for version X

Use the exact researcher-approved version in place of `X`, without a leading
`v`. A candidate uses `X.Y.Z-rc.N` and a final uses `X.Y.Z`. The instruction
to run this procedure authorizes preparation through the branch review in step 4.
The researcher authorizes tagging separately and decides when to publish.

1. **Start from reviewed main.** In a fresh clone, fetch `origin/main`, confirm
   its tip is the latest reviewed main commit and record its full SHA. Confirm
   that `release/X`, tag `vX` and a release or draft for `vX` are unused.
   Stop on a collision. Run `git switch -c release/X origin/main`. In MATLAB
   at the project root run `setupOxygenDynamicsPath`, then
   `setOxygenVersion('X')`. Check the getter, build time, citation date and
   version mirrors in the resulting diff. Cut every candidate and the final
   this way, including the final after a successful candidate.
2. **Prepare the changelog and notes.** In `CHANGELOG.md`, move the current
   Unreleased entries under `## X — YYYY-MM-DD` using the release preparation
   date. Leave an empty `## Unreleased` above it. Create
   `docs/releases/X.md` from the template below. Use the dated entries to
   describe changes. For a final or later candidate, also summarize the
   relevant earlier candidate entries so the notes cover the intended comparison.
3. **Verify on the Mac.** In a fresh MATLAB session at the release checkout
   run the following block. Keep reports outside the repository. Enter the
   actual counts, platform, MATLAB release and limitations in the notes.
   Commit the version changes, changelog and notes on `release/X`. Revalidate
   the source inventory from the clean commit and record its SHA and source
   count in the review report. If code or inputs change after testing, repeat
   the affected checks. Stop and report a failed or incomplete gate.

   ```matlab
   setupOxygenDynamicsPath
   reports = tempname; mkdir(reports);
   portable = runBOISoftwareChecks('portable',fullfile(reports,'portable'));
   desktop = runBOISoftwareChecks('desktop',fullfile(reports,'desktop'));
   repo = runRepositoryChecks()
   plan = getOxygenReleaseSourceList(pwd,true);
   fprintf('Validated %d source files\n',numel(plan.RelativePaths));
   ```

4. **Push the branch and stop.** Use `git push -u origin release/X`. Report
   the base SHA, release commit SHA, branch and notes links, counts and
   limitations. Wait for the researcher's explicit instruction to tag that
   exact commit. If review finds a candidate problem, fix it on `main` through
   a normal pull request. Start the next approved candidate at step 1 after
   that fix has been reviewed and merged.
5. **Tag only on explicit instruction.** Fetch the release branch and confirm
   that its tip equals the SHA approved in step 4. Recheck the remote tag and
   draft/release names. If any already exists, stop. From the approved commit
   run `git tag -a vX APPROVED_SHA -m "OxygenDynamicsV2 X"` followed by
   `git push origin refs/tags/vX`. Watch **Prepare draft release** to
   completion. It validates the tag/version, runs portable checks on Linux
   R2025b, builds and verifies the ZIP, and creates a draft with the notes and
   checksums. Candidates carry GitHub's prerelease flag. Check the draft state,
   flag, asset names and checksums, then report its URL. On failure inspect
   the run and any partial draft before reporting. Preserve all existing tags,
   releases and assets.
6. **Carry the record back to main.** Once the draft exists, create a separate
   branch from the latest `origin/main`. Copy the reviewed `docs/releases/X.md`
   and add its dated heading and entries to `CHANGELOG.md`. Remove only the
   entries carried into that heading from Unreleased, preserve intervening
   changes and add an **Added** line recording the release notes, as required
   by the pull request template. For a candidate, keep the current development
   version. For a final, obtain the researcher's approved next `X.Y.Z-dev`
   and run `setOxygenVersion` with that development version on the new branch.
   Inspect the diff, confirm the getter and its mirrors all identify a
   development version, and open the template pull request against `main`.
   Never merge the release branch into `main`. Publishing the GitHub draft
   remains a manual decision by the researcher.

### Release note template

Save as `docs/releases/X.md` on the release branch. The workflow uses this
file verbatim as the draft body and attaches a copy. Fill in the Mac results
before branch review. Report the subsequent hosted run and archive checksum
alongside the draft once they exist.

```markdown
# OxygenDynamicsV2 X — YYYY-MM-DD

## Changes
[Summarize the dated changelog entries since the named comparison version.
Describe affected workflows, changes in output meaning and any migration steps.]

## Verification
- macOS [version and architecture], MATLAB [release]. Portable [passed/failed/incomplete],
  desktop [passed/failed/incomplete]. Include the total for each.
- Repository checks inspected [count] MATLAB files, reported [count] Code
  Analyzer messages, and ran [count and outcome] focused check(s).
- Release source validation checked [count] paths. List any additional checks
  actually performed, their results and any outstanding verification.

## Limitations
[State untested workflows, recordings, scientific claims and known issues.]
Windows and MATLAB releases beyond the environments explicitly verified for
this version remain outside the demonstrated scope.
```

### Dry run

From a checkout of this repository, run
`gh workflow run release.yml --ref BRANCH` and open the resulting Actions run.
It accepts development versions. Download the `oxygen-source-…` artifact,
enter its folder and run `shasum -a 256 -c SHA256SUMS` on macOS or
`sha256sum --check SHA256SUMS` on Linux. A manual run ends at the artifact,
even when its selected ref is a tag. The draft job runs only for a new tag push.

A future release can be archived through Zenodo if maintainers approve and enable
that integration. Confirm [CITATION.cff](CITATION.cff), author order, licensing
scope and release metadata before publication. Record a new DOI only after it is
issued. Preserve the original deposit's CC BY 4.0 metadata observation separately
from the MIT code notice; this task changes neither published record.
