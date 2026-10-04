# Install this development candidate

Requires MATLAB; this candidate is checked on macOS with MATLAB R2025a.
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
See the [reviewed-pocket guide](docs/POCKET_MEASUREMENTS.md),
[duration/area/rate guide](docs/BOI_DURATION_AREA_AND_EVENT_RATES.md) and
[integral/composite/summary guide](docs/BOI_INTEGRALS_COMPOSITES_AND_SUMMARIES.md).

This is 3.1.0-dev.2, a modified uncommitted snapshot based on b0f6d20; it is
not identical to that commit. RELEASE_MANIFEST.txt records the base commit,
source state, policy hash and per-file SHA256. It is a development candidate,
not a published release or verification of fresh recording execution.
Required toolboxes vary by route; full detector/runtime/platform compatibility,
third-party licensing and hosted CI remain separate gates. C02 references remain
conditional, FB2312 recovery unresolved, reviewed corrected troughs exploratory.
Automatic and reviewed results remain separate; unknown original calculator
identity stays unknown. Use a new output folder for each saved revision/export.
