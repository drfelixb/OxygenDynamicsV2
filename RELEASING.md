# Release Process

OxygenDynamicsV2 does not currently have a fully reconciled public release
line. The repository tag `v3.0` and the internal version reported by
`getOxygenPipelineVersion.m` must be reconciled before creating another tag.

## Release Preconditions

- The project-level licence has been approved and added.
- Third-party notices and source headers are complete.
- `development` is clean, reviewed, and passing CI.
- `checkOxygenPipelineHealth` reports no failures.
- Dataset verification has been reviewed for the release validation dataset.
- Accepted regression tests and scientific guardrails pass.
- User-visible changes are recorded under `Unreleased` in `CHANGELOG.md`.
- Scientific changes have an accepted regression comparison and documented
  compatibility impact.
- No raw data, generated outputs, secrets, or absolute local paths are tracked.

## Prepare a Candidate

1. Choose a semantic version and update the central version metadata.
2. Move the relevant changelog entries into a dated release section.
3. Run:

   ```matlab
   setupOxygenDynamicsPath
   checkOxygenPipelineHealth
   runRepositoryChecks
   runOxygenPipelineSmokeTest
   createOxygenReleasePackage
   ```

4. Inspect the generated manifest and archive contents.
5. Confirm that documentation, citation metadata, and release metadata agree.
6. Open a pull request from `development` to `main`.

## Publish

After the pull request is approved and merged:

1. Confirm CI passes on `main`.
2. Create an annotated tag matching the approved version.
3. Create a GitHub release from that tag.
4. Attach the generated source package only after inspecting it.
5. Include compatibility notes, validation evidence, and known limitations.

Do not retag an existing commit or replace a published archive. Correct a
release with a new patch version and document the reason in the changelog.

## Future Software DOI

A future GitHub release can be archived through Zenodo after the maintainers
enable the repository integration. Confirm the GitHub release metadata,
`CITATION.cff`, authors, licence, and version before publishing the archive.
Record the resulting DOI in the README and citation metadata only after Zenodo
has issued it. Do not create a `.zenodo.json` file unless Zenodo metadata needs
cannot be met by `CITATION.cff` and the GitHub release.
