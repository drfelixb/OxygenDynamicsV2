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

## Prepare an approved candidate

1. Branch from the reviewed commit on `main` and set the approved candidate version on that release branch.
   Freeze the committed file list and hashes. Update version/build metadata only
   when the approved task calls for it; package creation time is separate.
   In a fresh MATLAB session in that checkout, run `setupOxygenDynamicsPath` before `runBOISoftwareChecks('portable','results-portable')`
   and `runBOISoftwareChecks('desktop','results-desktop')`. Validate the source
   inventory with `getOxygenReleaseSourceList(pwd,true)`.
2. Use `createOxygenReleasePackage` with the approved output root/name, actual
   source commit and accurate source state. It copies the explicit source list;
   it does not recursively gather recordings, results or development evidence.
3. Compare exact source/folder/ZIP/extracted file sets and hashes, check local
   reader links and retained notices, and verify exclusions.
4. Record the archive hash, limitations and any implementation changes. A base
   commit alone does not identify modified files. See [package contents](PACKAGE_CONTENTS.md).

The preserved licensing candidate received static/package and definition-load
checks. The later interface task uses focused saved-FB2311 checks and no recording
rerun or package build. Publication claims must identify those scopes separately.

## Publish only after a separate release decision

After the approved release review and any separately authorised integration:
confirm the exact source and archive, then follow the approved tag and GitHub
release procedure on the release branch. Include compatibility, evidence and limitation statements.
Do not move existing tags or replace published archives; correct a publication
with a newly identified version and archive.

A future release can be archived through Zenodo if maintainers approve and enable
that integration. Confirm [CITATION.cff](CITATION.cff), author order, licensing
scope and release metadata before publication. Record a new DOI only after it is
issued. Preserve the original deposit's CC BY 4.0 metadata observation separately
from the MIT code notice; this task changes neither published record.
