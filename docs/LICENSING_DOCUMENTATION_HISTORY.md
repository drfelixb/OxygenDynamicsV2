# Licensing documentation history

5 October 2026. Repository-only record; excluded from the development package.
The following text preserves the local review and release guidance before the
portable distribution update. Its dated stopping/approval statements are historical.

## Earlier licence review

```markdown
# Licence and notice review

5 October 2026 · Documentation for researcher review before publication

The six previously inventoried bundled files now have traceable upstream licence
evidence and retained attributions in [Third-Party Notices](../THIRD_PARTY_NOTICES.md).
Five official licence files are reproduced in full, with their URLs, versions,
retrieval dates, byte counts and SHA-256 hashes in the
[portable provenance record](planning/third-party-licence-provenance.json).
The later original-release inspection found an existing MIT grant in the
Science_2024 archive. Its [exact notice](../licenses/Science_2024-MIT.txt) is now
preserved for inherited code. No licence for all new V2 contributions has been
adopted; [licensing and contributor credits](../LICENSING.md) explain the distinction.

## Reconciled dependency notices

| Bundled component | Finding and action |
|---|---|
| `abfload.m` | Author-maintained licence at commit `021c9ffb661978cc4d8a875e64dc3d696ebf40bc` confirms BSD-2-Clause and the 2009 Forrest Collman / 2004 Harald Hentschke notices. Retained Ulrich Egert's local `pvpmod.m` attribution and the documented local ABF2 path repair. Local source differs from the pinned upstream file; its original revision remains unknown. |
| `loadtiff.m`, adapted `saveastiff.m` | Official 4.5.0 licence carries copyright 2019 YoonOh Tak. Official source viewers also carry a 2012 notice, matching the local `loadtiff` year. Retained both full notices, including GIST's non-endorsement terms and the adaptation attribution; no replacement date or invented year range. |
| `peakfinder.m` | Official 2.0.2 licence carries copyright 2016 Nathanael C. Yoder. The official source viewer also displays the local 2015 attribution. Retained both. The source/distribution dates are distinct notices, not evidence that one should be deleted. |
| `plot_areaerrorbar.m` | Official 1.3.1 licence confirms BSD-3-Clause and spells the holder Víctor Martínez. Retained that exact licence spelling alongside the original local Victor Martinez-Cagigal attribution. |
| `hex2rgb.m` | Official 1.1.1 licence confirms BSD-3-Clause and copyright 2014 Chad Greene. Retained the local attribution; the consulted upstream source identifies Chad A. Greene. |

The full terms and source links are in the notices. These identified BSD terms
permit source/binary redistribution and modification with their stated notice,
disclaimer and, where applicable, non-endorsement requirements. No additional
permission requirement was identified in those terms for ordinary redistribution.
The review covers these six files; it is not exhaustive rights clearance.

## Remaining permission and provenance questions

**Permission for inherited code is already supplied.** The paper-linked
Science_2024 archive and pinned GitHub release include MIT, with
`Copyright (c) 2023 Antonis Asiminas`. The earlier inspection overlooked that
file. Reuse, modification and redistribution of code covered by its grant are
permitted with the required notice. Its byte-exact copy is retained at
`licenses/Science_2024-MIT.txt`; the
[source record](planning/original-software-licence.json) identifies the evidence.

**New V2 contribution licensing remains unconfirmed.** MIT is recommended for
continuity; the current documentation does not grant new rights, invent a
copyright holder/year or add a blanket licence field to `CITATION.cff`.
Publication still requires the remaining contribution and release decisions.

**Historical dependency origins remain incomplete.** The exact starting revisions
and complete modification histories of the bundled helpers are unknown. Current
official licences identify the upstream terms consulted; they do not establish
the licence history of every local line. Preserve the existing attributions and
disclose this gap. If an older source archive or contrary permission evidence is
found, reconcile that evidence before claiming complete clearance; no unidentified
permission is guessed here.

For our later discussion, the copyright holder is the person or institution
entitled to grant reuse rights; citation authorship alone does not establish it.
A project licence states what others may do with the project's original code.
The earlier BSD-3-Clause proposal is superseded by the original MIT evidence.
Third-party notices preserve the dependencies' own grants. MATLAB and toolbox
access remains the user's separate responsibility.

## Identity, checks and stop

Source baseline: `development-existing-analysis-v3`, commit
[e119df6338faa0590f933f889a8dddf81256de30](https://github.com/drfelixb/OxygenDynamicsV2/commit/e119df6338faa0590f933f889a8dddf81256de30),
version **3.1.0-dev.2**. This delivery consists of uncommitted documentation changes
after that commit. It is outside both preserved candidates; their ZIPs have not
been rebuilt and contain the earlier notice document.
The explicit source list now includes this review and the provenance JSON so a
future separately approved build can carry the notice links. This file-list
change has only been checked statically; no new package is claimed.

Documentation verification checked all five downloaded licence hashes, exact
licence-text reproduction, retained local attributions, relative links, JSON and
Git whitespace. All **542 MATLAB file hashes** and both candidate ZIP hashes match
the pre-task snapshot. Application calculations, scientific qualifications and
results remain unchanged. Existing historical failures and consumed approvals
remain in the development records. No MATLAB, test suite, recording, package
build, commit/push or publication occurred.

Local evidence packet: `reference-validation/software-licence-notices-20261005`,
outside the software repository. These are assistant documentation checks;
researcher acceptance of this delivery has not yet been received. Stop here for
review and the separately requested project licence discussion.

## Original software licence correction

On 5 October 2026, the researcher supplied the original contributor history and
questioned whether another permission was necessary after publication with
Science. Inspection of the original archive found MIT. The archive checksum
matches the saved Zenodo record, and its notice agrees with the pinned GitHub
file apart from a trailing blank line in the returned GitHub text. The copy
restored here preserves the archive bytes exactly.

The saved Zenodo metadata labels the deposit CC BY 4.0. The source record retains
that observation separately from the explicit MIT file; no published record was
changed or depositor intent inferred. Contributor roles are recorded from Felix's
account in the licensing guide; citation authors and order remain unchanged.

The researcher authorised this correction by “Continue”. Item LICENCE-02 covers
one documentation slice owned by the implementation assistant: preserve MIT,
correct current claims, retain source evidence/credits, add the notice to the
prospective file list, and check links/hashes. Limit: 60 active minutes and 1 MiB
of new documents. Stop after the local delivery. This does not authorise a new
grant for V2 contributions, publication, MATLAB, scientific tests or a build.

The licensing guide, original notice and source record are intended for the next
approved package build; the existing ZIPs still contain earlier documents.
Static verification is recorded at
`reference-validation/software-original-mit-restoration-20261005/documentation-verification.json`
in the local workspace. This is documentation evidence, not a numerical gate or
independent legal review.

## Documentation task completed and next handoff

The researcher's instruction to finish this task and prepare the next
implementation handoff closes this documentation slice on 5 October 2026.
The original MIT notice, contributor credits and corrected current claims are
complete locally. The 21 recorded static checks passed; all 542 MATLAB files
and the two existing ZIPs were preserved. This completion does not adopt a
blanket licence for new V2 contributions or record an independent legal review.

The [next implementation handoff](SOFTWARE_LICENSING_DISTRIBUTION_HANDOFF.md)
proposes saving these documents on the development branch and including them
in one updated development download. It includes ordinary document/link repairs
and packaging verification as one task. Execution approval is pending; no
build, commit/push or publication occurred while preparing the handoff.
```

## Earlier release guidance

```markdown
# Release Process

The historical version line is the unchanged local and GitHub tag `v3.0`
at `329cdc2f1fd3afd04c54ce4518673165f999b1a0` (4 June 2026, “Final Version”).
It is an ancestor of the accepted development baseline. On 4 October 2026,
the researcher approved step 1 and the development label `3.1.0-dev.1`,
replacing the stale internal `1.01` identity. Central metadata and current
manual now agree; older outputs keep their original identity.

This is a development snapshot, not a published release. No existing tag was
moved and no new tag was created. Stable `3.1.0` / `v3.1.0` require separate
release acceptance; calculation contracts are unchanged. See
step-1 record (repository record: `docs/SOFTWARE_NEXT_01_DELIVERY.md`) and
version policy (repository record: `docs/SOFTWARE_NEXT_STEPS.md#software-and-calculation-versioning`).
The process below is future release guidance, not current authorization.

## Release Preconditions

- The original Science_2024 MIT notice is included for inherited code, and the
  authorised rights holder has confirmed licensing of new V2 contributions.
  See [licensing and credits](LICENSING.md).
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
```
