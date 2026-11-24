# Install and open OxygenDynamicsV2

Extract the source package to a new folder and set it as the MATLAB Current Folder. This candidate was checked in MATLAB R2025a on macOS. The imaging workflow uses Image Processing Toolbox. Some optional analyses use Statistics and Machine Learning Toolbox.

```matlab
setupOxygenDynamicsPath
getOxygenPipelineVersion
openBOIBatchEditor
```

The version should be `3.1.0-rc.1`. If MATLAB resolves an older installation, use `which openBOIBatchEditor -all` to find overlapping path entries. Close older BOI editor and viewer windows before switching versions.

For the routine batch path, use the [one-page guide](docs/BOI_BATCH_QUICK_START.pdf). To reopen a single completed run independently of a CSV, run `openBOIRecordingWorkflow`, then choose the completed `BOIRun.mat` index. For an existing combined export, use **Automatic export → Open existing export…** in the Batch Editor and select its complete `BOIBatchStats_…` folder.

From a repository checkout, run `runBOISoftwareChecks('portable','results-portable')` to run the synthetic software checks.

See [distribution status](DISTRIBUTION_STATUS.md), [measurement definitions](docs/BOI_DURATION_AREA_AND_EVENT_RATES.md), [licensing and credits](LICENSING.md) and [third-party notices](THIRD_PARTY_NOTICES.md).
