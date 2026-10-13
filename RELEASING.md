# Release decisions and future publication

The current checkout is **3.1.0-dev.3**, software build
`2026-10-13 20:02:39 +02:00`. Preserved candidate ZIPs remain 3.1.0-dev.2 and
do not contain the later interface fixes; no replacement ZIP is built here.
Stable 3.1.0, a tag, GitHub release or DOI need
separate release approval. Existing tags and prior archives remain unchanged.
The historical v3.0 tag and version decisions are repository records
(`docs/SOFTWARE_NEXT_STEPS.md`); each existing package manifest identifies its own candidate.

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
custom containment and worker qualification are deferred to a possible v4.

## Prepare an approved candidate

1. Work from the intended reviewed source on `development-existing-analysis-v3`.
   Freeze the committed file list and hashes. Update version/build metadata only
   when the approved task calls for it; package creation time is separate.
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
confirm the exact source and archive, then follow the approved merge/tag/GitHub
release procedure. Include compatibility, evidence and limitation statements.
Do not move existing tags or replace published archives; correct a publication
with a newly identified version and archive.

A future release can be archived through Zenodo if maintainers approve and enable
that integration. Confirm [CITATION.cff](CITATION.cff), author order, licensing
scope and release metadata before publication. Record a new DOI only after it is
issued. Preserve the original deposit's CC BY 4.0 metadata observation separately
from the MIT code notice; this task changes neither published record.
