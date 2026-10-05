# Install this development candidate

Requires MATLAB. The named saved-data routes were checked on macOS/R2025a;
the portable calculation gate passed on Linux/R2025b. Required toolboxes vary
by route: Image Processing Toolbox and, for some analyses, Statistics and
Machine Learning Toolbox. See [support and distribution limits](DISTRIBUTION_STATUS.md).
Extract the ZIP into a new folder. Keep previous installations and result folders.
In MATLAB, change Current Folder to the extracted folder and run:

```matlab
setupOxygenDynamicsPath;
getOxygenPipelineVersion
openBOIRecordingWorkflow
```

Avoid keeping another OxygenDynamics checkout on the MATLAB path. Confirm
`which openBOIEventReview -all` and `which openBOIReviewedPocketEvidence -all`
point to this installation. Select an existing completed BOI run to inspect
saved events/windows; this package contains no recordings or saved results.
For reviewed pockets: select saved event, enter explicit frames/reference and
suitability/recovery judgment, Preview draft, Save NEW revision, then Export
SAVED revision. Reopen portable exports with `openBOIReviewedPocketEvidence`.
Follow the [short saved-result walkthrough](docs/BOI_ORDINARY_MATLAB_WALKTHROUGH.md)
and [two worked calculations](docs/BOI_SAVED_CALCULATION_WORKED_EXAMPLES.md).
See also the [reviewed-pocket guide](docs/POCKET_MEASUREMENTS.md),
[duration/area/rate guide](docs/BOI_DURATION_AREA_AND_EVENT_RATES.md) and
[integral/composite/summary guide](docs/BOI_INTEGRALS_COMPOSITES_AND_SUMMARIES.md).

This candidate retains software version 3.1.0-dev.2 and its original software
build timestamp; the package creation time is recorded separately.
RELEASE_MANIFEST.txt records the actual committed source through its source-state
entry and per-file SHA256 values, alongside the ancestry/base field and policy hash. It is a development candidate,
not a published release or verification of fresh recording execution.
The per-file hashes identify the actual packaged bytes; a base commit alone
does not identify a modified snapshot. Fresh recording/runtime/platform evidence,
licensing of new V2 contributions, declared support and release approval remain
incomplete. Retain the [original MIT notice](licenses/Science_2024-MIT.txt) and
[dependency terms](THIRD_PARTY_NOTICES.md); see [licensing and credits](LICENSING.md). C02 references remain
conditional, FB2312 recovery unresolved, reviewed corrected troughs exploratory.
Automatic and reviewed results remain separate; unknown original calculator
identity stays unknown. Use a new output folder for each saved revision/export.
