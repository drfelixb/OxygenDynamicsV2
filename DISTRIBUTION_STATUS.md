# Distribution and validation status

Checkout version: **4.0.0-dev**.

The source tree includes the opt-in multichannel workflow from the RC1 handoff. Its synthetic checks cover two oxygen channels and oxygen plus fluorescence. The integration pull request records the MATLAB results for this revision, including the TIFF rescan. [Multichannel guide](docs/BOI_MULTICHANNEL.md)

Open the Batch Editor with `openBOIBatchEditor`. From a source checkout, start the editor or run `setupOxygenDynamicsPath` before calling `runBOISoftwareChecks` in portable or desktop mode.

OxygenDynamicsV2 **3.1.0-rc.1** was published as a research software release candidate for the BOI Batch Editor. Its scope is recording setup, sequential analysis using the accepted BOI detector, saved results, and postprocessing exports. The [release notes](docs/RELEASE_NOTES_3.1.0_RC1.md) distinguish the workflow and measurement changes from both earlier releases and the original publication.

That candidate passed 310 synthetic regression checks in MATLAB R2025a on macOS across the full run and a focused rerun after restoring a test fixture helper. The packaged Batch Editor also opened in that environment. Recorded user testing of the CSV-to-automatic-to-compact workflow is separate from candidate verification. Performance and scientific interpretation across research cohorts, Windows desktop behavior, and compatibility with other MATLAB versions are outside the demonstrated scope.

For each new candidate or final version, the researcher reviews a fresh release branch and its Mac portable, desktop, repository and source counts before authorizing an annotated tag. A matching tag triggers Linux portable checks and a verified source ZIP with SHA-256 checksums and version-specific notes. GitHub holds the result as a draft for the researcher's publication decision. A manual Actions run on a development branch produces a downloadable test package. [Release runbook](RELEASING.md)

The V2 contributions are distributed under [MIT](LICENSE). The [original Science_2024 MIT notice](licenses/Science_2024-MIT.txt) accompanies inherited code. See [licensing and credits](LICENSING.md) and [third-party notices](THIRD_PARTY_NOTICES.md) for the applicable scope and dependencies.
