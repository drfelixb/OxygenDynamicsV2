# Preserved candidate and future package contents

The current explicit `OxygenReleaseSourcePolicy.json` includes the batch editor,
CSV/preflight services, sequential queue/history and the
[batch guide](docs/BOI_BATCH_EDITOR.md) / [execution guide](docs/BOI_BATCH_EXECUTION.md)
for a future build. Three synthetic CSV templates are repository-only examples; the existing
package CSV exclusion is preserved. The guide includes an inline template.
The policy also includes the export-folder
presentation helper, alongside the GUI/batch sources,
reviewed-pocket preview/save/reopen/export, automatic amplitude companions,
provenance helpers, required definitions and reader guides. It also includes
[licensing and credits](LICENSING.md), the exact
[original MIT notice](licenses/Science_2024-MIT.txt),
[dependency notices](THIRD_PARTY_NOTICES.md), the
[original-licence source record](docs/planning/original-software-licence.json) and
[dependency provenance](docs/planning/third-party-licence-provenance.json).

No folder is copied recursively. `RELEASE_MANIFEST.txt` lists the exact paths,
policy hash and per-file SHA-256 values. It identifies the committed package
source separately from software version/build and package creation time.
Current development checkout 3.1.0-dev.10 is not a new package: preserved candidate03 remains
3.1.0-dev.2/source 44f3031 and does not contain the new interface controls.
The reviewed-optical contract retains all scientific fields and judgment hashes;
historical paths use portable labels, with the matching loader checksum updated.

Excluded: recordings, generated results, research payloads, development evidence,
tests, historical task/delivery records, private source maps and changelog. Reader
links resolve to included files; repository-only history references are plain
paths. Saved examples must be supplied separately. See
[installation](INSTALLATION.md) and the
[saved-result walkthrough](docs/BOI_ORDINARY_MATLAB_WALKTHROUGH.md).

Earlier candidate ZIPs and results are preserved. This development distribution
has no stable-release approval. Licensing of new V2 contributions, declared
support/claims and publication remain decisions. Felix’s FB2311 test supplies
integration and 293.60 s elapsed time for one case; peak memory and broader
fresh-recording/platform behavior remain unverified. Static packaging and the definition-load
check do not extend the historical numerical or desktop evidence; see
[support limits](DISTRIBUTION_STATUS.md).


Local 3.1.0-dev.9 source additions: `boiEpisodeReferencePolicy`,
`initializeBOIEpisodeReferences`, `deriveBOIPreEpisodeReferences`,
`collectBOINativePixels`, `attachSavedBOIEpisodeReferences`,
`getBOISinkBurdenAmplitude`, `appendBOIEpisodeReferenceSummary`, the focused
pre-episode test suite and `docs/BOI_PRE_EPISODE_BASELINE.md`.
The existing ZIP is not rebuilt by this local implementation.

30 October 2026: the explicit future-package inventory now also includes the
reviewed burden adapter/exporter, source-bound reviewed frame-area services and
cached comparison view. These are development-checkout features; no new ZIP,
area-rule adoption or cohort export follows from the checkpoint.
