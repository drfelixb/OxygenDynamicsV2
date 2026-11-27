# OxygenDynamicsV2

MATLAB software for analysing sink and surge events in cerebral bioluminescence oxygen imaging.

Checkout version: **4.0.0-rc.1**.

From the project folder, run `openBOIBatchEditor`, `openBOIMultichannelBatch` or `runPocketNearbyTissue` directly. For other commands in a fresh MATLAB session, run `setupOxygenDynamicsPath` first.

For a multichannel CSV batch, run `openBOIMultichannelBatch` or choose **Imaging mode** in the Batch recordings window. For one pair, run `openBOIMultichannel`. The guide covers two oxygen channels, oxygen plus fluorescence, the paired workbook and reopening event traces. [Multichannel guide](docs/BOI_MULTICHANNEL.md)

## Start or resume a batch

Open this folder in MATLAB and run `openBOIBatchEditor`. Open a recording CSV, check the inputs and save a separate working CSV before running a queue. Reopen that working CSV to check and reuse completed recordings. In **Automatic export**, **Open existing export…** loads a completed combined export folder for further work, including **Compact workbook**.

- [Automatic pocket and nearby-tissue traces](docs/POCKET_TRACES.md)
- [One-page Batch Editor guide](docs/BOI_BATCH_QUICK_START.pdf)
- [Installation](INSTALLATION.md) and [full Batch Editor guide](docs/BOI_BATCH_EDITOR.md)
- [Release notes comparing v3.0 and Science_2024](docs/RELEASE_NOTES_3.1.0_RC1.md)
- [Measurement definitions](docs/BOI_DURATION_AREA_AND_EVENT_RATES.md) and [distribution and validation status](DISTRIBUTION_STATUS.md)

From a source checkout, run `runBOISoftwareChecks('portable','results-portable')` to check the installation with synthetic recordings.

MATLAB with Image Processing Toolbox is required for imaging. Some optional analyses also require Statistics and Machine Learning Toolbox. For saved optical measurements and optional review, see the [measurement guide](docs/POCKET_MEASUREMENTS.md).

The project builds on the analysis for [Oxygen imaging of hypoxic pockets in the mouse cerebral cortex](https://doi.org/10.1126/science.adn1011). See [citation information](CITATION.cff), [licensing and credits](LICENSING.md) and [third-party notices](THIRD_PARTY_NOTICES.md). The V2 contributions are [MIT-licensed](LICENSE). The inherited Science_2024 code retains its original MIT notice.
