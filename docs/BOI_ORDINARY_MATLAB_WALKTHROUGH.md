# Use the accepted candidate with saved results

5 October 2026 · 3.1.0-dev.2 · saved-data workflow

This is the assistant's demonstrated route, accepted by the researcher within
its saved-data scope. No new independent scientist walkthrough or native-chooser
check is claimed. Acceptance is not feedback from independently following these steps.
The supplied examples need their saved result folders separately; the ZIP
contains software, not recordings/results. Keep previous installations/results.

1. Extract the development candidate ZIP into a new folder.
   In MATLAB, make that folder Current Folder and run:

   ```matlab
   setupOxygenDynamicsPath;
   getOxygenPipelineVersion
   which openBOIEventReview -all
   which openBOIReviewedPocketEvidence -all
   openBOIRecordingWorkflow
   ```

   Expected: version **3.1.0-dev.2**, build **2026-10-04 21:37:28 +02:00**;
   functions resolve from this extraction. Remove another OxygenDynamics
   installation from the path if it appears in `which`.

2. Click **Open saved run**, choosing an existing completed run folder supplied
   separately. For the demonstrated G2 ID400 example, choose its `gui-run` folder.
   Expected for that example: selected completed run, **246 automatic events**, saved traces
   captured, and **Run recording disabled**. **Inspect recording results**
   displays saved window/tissue ingredients. This reads saved results only.

3. For the accepted reviewed-pocket example, open the historical saved audit
   separately in the same MATLAB session. Select the two supplied ID400 ingredient
   files wherever you keep them; no fixed installation or research-folder path is needed:

   ```matlab
   [auditName, auditFolder] = uigetfile('*.mat', 'Select ID400 event-amplitude-audit.mat');
   if isequal(auditName, 0), return; end
   [reportName, reportFolder] = uigetfile('*.json', 'Select matching ID400 reference-report.json');
   if isequal(reportName, 0), return; end
   openBOIEventReview(fullfile(auditFolder, auditName), [], true, ...
     fullfile(reportFolder, reportName));
   ```

   Choose **sink site 11 / event 1**, row 41. In **Timing review**, enable
   **Show raw / correction quality check**. Expected: saved corrected intensity
   above the supporting score; raw intensity and the already removed trend below.
   Red/blue bounds belong to the saved automatic event.

4. Open **Reviewed optical → Reviewed pocket**. Enter onset **82**, observation
   end **98**, reference **73:81**, suitability **accepted_local_state**, and
   recovery **recovery_observed**. Enter reviewer/reason; confirm the explicit
   pocket interpretation and known external 1 Hz clock for this example.
   Click **Preview draft**. Expected: corrected **−5.05234%**, raw **−4.32866%**,
   nine green reference samples, and the same 1,100 saved pixels. These reproduce
   previously accepted choices; they are not a new physiological assessment.

5. Click **Save NEW revision** and choose an output **parent**. The application
   creates a new child folder. **Reopen saved revision** chooses that completed
   child itself. Expected: SAVED status and identical values; opening performs
   no arithmetic replay. Editing choices creates an UNSAVED draft.

6. **Export SAVED revision** creates another new child under the chosen parent.
   It exports the saved revision, not unsaved edits. Open the completed export:

   ```matlab
   exportFolder = uigetdir(pwd, 'Select completed reviewed export child folder');
   if isequal(exportFolder, 0), return; end
   openBOIReviewedPocketEvidence(exportFolder);
   ```

   Expected: stored values, exact choices and qualifications. **Verify saved
   arithmetic** explicitly replays the exported samples; it is not physiological
   validation. Read `Evidence.md`, `ReviewedPocketMeasures.csv` and
   `ReviewedPocketSamples.csv` inside your completed export. GUI chooser clicks
   create generated child names; assistant
   checks invoked the same handlers with explicit new folders.

7. Read the separately supplied G2 recording-summary export `AutomaticSummary.xlsx`,
   sheet **AutomaticAverageCounts**, recording row **MeanBurdenAmplitudePercent**:
   **8.90797287875453%, 94/192 events**. The demonstrated packet's
   `RecordingSummaryIngredients.csv` (192 event rows) and `SelectedRecordingSummary.csv`
   support the [worked calculations](BOI_SAVED_CALCULATION_WORKED_EXAMPLES.md).
   This automatic recording is a different saved analysis from the reviewed
   historical event above; the reviewed value is not averaged into it.

Both quantities are optical/descriptive, not oxygen concentration or pressure.
C02's reference remains conditional, FB2312 recovery unresolved, and fixed saved
footprints are not independently established pocket outlines. Unknown historical
calculator versions stay unknown; automatic and reviewed outputs stay separate.
These exact values belong to the separately supplied ID400 ingredients, not an
arbitrary saved run. Neither those ingredients nor the demonstration captures
are bundled in this software-only ZIP. Other supported completed runs can be
inspected using their own saved values; missing ingredients are not regenerated.

Fresh-recording integration/runtime/memory remain unverified. Independent
researcher walkthrough feedback and release approval remain outstanding.
