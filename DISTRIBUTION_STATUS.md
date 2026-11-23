# Distribution and validation status

The source tree includes the opt-in multichannel workflow from the RC1 handoff. Its synthetic checks cover two oxygen channels and oxygen plus fluorescence. The integration pull request records the MATLAB results for this revision, including the TIFF rescan. [Multichannel guide](docs/BOI_MULTICHANNEL.md)

OxygenDynamicsV2 **3.1.0-rc.1** is a research software release candidate for the BOI Batch Editor. Its scope is recording setup, sequential analysis using the accepted BOI detector, saved results, and postprocessing exports. The [release notes](docs/RELEASE_NOTES_3.1.0_RC1.md) distinguish the workflow and measurement changes from both earlier releases and the original publication.

The source passed 310 synthetic regression checks in MATLAB R2025a on macOS across the full run and a focused rerun after restoring a test fixture helper. The packaged Batch Editor also opened in that environment. Recorded user testing of the CSV-to-automatic-to-compact workflow is separate from candidate verification. Performance and scientific interpretation across research cohorts, Windows desktop behavior, and compatibility with other MATLAB versions are outside the demonstrated scope.

The V2 contributions are distributed under [MIT](LICENSE). The [original Science_2024 MIT notice](licenses/Science_2024-MIT.txt) accompanies inherited code. See [licensing and credits](LICENSING.md) and [third-party notices](THIRD_PARTY_NOTICES.md) for the applicable scope and dependencies.
