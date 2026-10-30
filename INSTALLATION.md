# Open the current development checkout

30 October 2026 · **3.1.0-dev.10**, build **2026-10-30 11:14:26 +01:00**.

The local development checkout adds **Batch recordings** for CSV preparation,
shared settings, optional metadata, row checks and sequential execution with
saved status/history. Choose the output parent and review/confirm selected ready
rows before starting; see [batch execution](docs/BOI_BATCH_EXECUTION.md). The preserved development ZIPs
remain **3.1.0-dev.2**. This development checkpoint is being saved to the
existing development branch; it builds no replacement ZIP. Keep older installations
and results. See [checkpoint details](docs/BOI_DEVELOPMENT_CHECKPOINT_20261030.md).

In a fresh ordinary MATLAB desktop, make the updated `existing-analysis` checkout
Current Folder. Close older BOI viewer windows before switching installations.
Run:

```matlab
addpath(pwd,'-begin');
setupOxygenDynamicsPath;
getOxygenPipelineVersion
which openBOIRecordingWorkflow -all
which openBOIEventReview -all
which openBOIWindowReview -all
which createBOIExportFolderPanel -all
openBOIRecordingWorkflow
```

Expected: version/build above; the functions resolve from this checkout and its
`helpers` folder. Remove conflicting OxygenDynamics path entries if an older
extraction resolves instead. Click **Open saved run → Choose BOIRun.mat** and
select an existing completed run. No recording is rerun by reopening it.
The software checkout contains no recordings or example results.

For the batch editor run `openBOIBatchEditor`, or start `OxygenDynamics_GUI`
and click **Batch recordings**. See the [batch editor guide](docs/BOI_BATCH_EDITOR.md)
and repository template `examples/boi-batch-draft.csv`. Adding/opening/checking a
batch does not start recording analysis; execution requires a reviewed, confirmed queue.

For new analysis, choose **Detection support** explicitly: **Reviewed craniotomy
ROI** requires a matching saved tissue boundary; **Automatic tissue estimate (legacy)** estimates tissue
from image intensity without a preset ROI. Inspect the estimated edge after
analysis; the saved support value remains `whole-image`. Click **Review settings**, inspect required corrections,
scientific warnings and unknowns, then confirm. A changed support choice clears
confirmation; no method is selected automatically.

In the event viewer use **Export selected evidence**; in recording/window review
use **Export selected window evidence**. Choose an existing parent; a new child
is created without overwriting older exports. **Last completed export folder**
keeps its full path visible, with **Open folder** and **Copy path**. Cancellation
or failure leaves the last completed path unchanged; an incomplete destination
is not enabled as a completed export. These controls do not alter export formats.

For reviewed pockets, use Preview draft → Save NEW revision → Reopen saved
revision → Export SAVED revision as described in the
[saved-result guide](docs/BOI_ORDINARY_MATLAB_WALKTHROUGH.md).
Reviewed measurements remain separate from automatic statistics.

MATLAB and Image Processing Toolbox are required for imaging; some analyses need
Statistics and Machine Learning Toolbox. The
[support record](DISTRIBUTION_STATUS.md) separates Felix's single completed
FB2311 case from portable Linux checks, assistant UI checks and missing evidence.
Peak memory and broad recording/platform support remain unverified. See the
[manual-test result](docs/BOI_FB2311_MANUAL_TEST_RESULT.md) and
[measurement guides](docs/BOI_DURATION_AREA_AND_EVENT_RATES.md).

C02's reference stays conditional, FB2312 recovery unresolved, and fixed-footprint
and automatic/reviewed qualifications remain. Original calculator versions stay
unknown where not recorded. Original [MIT](licenses/Science_2024-MIT.txt) and
[dependency notices](THIRD_PARTY_NOTICES.md) remain exact; licensing of new V2
contributions and publication are separate decisions. No release approval is implied.
