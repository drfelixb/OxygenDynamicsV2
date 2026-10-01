# BOI researcher walkthrough and phase handoff

This packet covers the MATLAB import → review → run → inspect → export path.
It separates completed developer verification from the independent researcher
walkthrough required by the [workflow contract](RESEARCHER_WORKFLOW_AND_TRACEABILITY.md).
All scientific admission questions in the [current status](REANALYSIS_STATUS.md)
and [cohort record](BOI_COHORT_RESOLUTION.md) remain active.

The saved HP recording is **development/training evidence**, with a provisional
identity, scale and unreviewed tissue support. It is not an eligible biological
validation case. Its external trigger is precisely 1 Hz; embedded timestamps
are unreliable. Camera integration is 0.96 s, separately recorded. AQuA2 outputs
are exploratory detection experiments, not anatomical reference evidence.

## Prepare an independent session

Use a researcher who did not implement the software and a second person to
reproduce the exported calculation. Record their roles, software version/code
manifest, input/source hashes, run IDs, elapsed time, assistance, confusion and
failures in a new copy of
[the walkthrough record](planning/boi-researcher-walkthrough-template.json).
Do not mark tasks complete before observing them. An eligible recording and its
scientific decisions must be identified before this can count as a formal release
walkthrough. The HP training case can establish familiarity, not eligibility.

Keep previous sources, masters, statistics and review folders intact. For a fresh
run or changed input decision, stage unchanged source files and declarations in
a new recording folder. Select a new output root. Never edit the saved clock or
remove unusual events to obtain an expected biological result.

## Tasks to observe in MATLAB

1. Open `OxygenDynamics_GUI`, choose the recording CSV and run **1. Run
   Verification**. In **BOI Input Review**, explain one source or support issue,
   the measurement it affects and the required evidence/action. Distinguish
   readable input, unsupported input, unavailable measurement and scientific
   eligibility. Read the full review if the short explanation is insufficient.
2. Review sampling, physical scale, modality, source preparation, tissue support
   and the intended master/statistics settings. Run **2. Run Wrapper**, then
   **3. Run Stats** only on the chosen fresh stage under the agreed scientific
   and resource conditions. Keep the output folders, configuration, manifest,
   review issues and measurements. BOI is the only modality in this round.
3. In **BOI Measurements**, open the run's **recording/window evidence**. The
   launcher uses the most recently completed statistics output when available;
   otherwise choose the saved `DataOutput.mat`. Select a recording/window and
   a sign. Explain occupancy, onset rate and concurrent-event density using the
   actual numerator, denominator and units. Inspect the frame ingredients and
   the separate saved sink/surge tissue supports.
4. In **Event timing**, select an event and **Choose saved event audit**. If an
   audit is unavailable, return to the main **BOI Measurements** tab and use
   **Create event source audit**. Select the recording folder containing one
   unambiguous master per sign and a parent for a new audit folder. This explicitly
   reads the whole preserved source to check traces/baselines; the progress notice
   explains its cost. It does not rerun detection or statistics. The resulting
   audit opens in the event inspector and can be selected from the window view.
5. Use **Open selected event evidence**. Explain the portable statistics ID and
   original audit ID, the sign/site/event, window membership and overlap. The
   software checks the saved recording mapping, source hash, grid, sampling,
   calibration, support, acquisition snapshot, event bounds, baseline and
   amplitude. A failed connection explains why; it does not select a nearby
   event or infer an identity from a similar filename.
6. Explain the preserved-input trace, clean pre-event baseline, missing baseline
   status and signed amplitude. Use **Show source frame**, then **Attach native
   masks** with the matching sign's master. Distinguish the orange fixed amplitude
   footprint, cyan per-frame native event support and saved tissue denominator.
   Inspect another native frame and a frame outside the selected run. Recurrence
   at the same site must not appear as part of this event. A negative surge stays
   negative; baseline `valid` is a numerical status, not physiological acceptance.
7. Export the event evidence in a new folder and use **Return to window** to
   export its window ingredients. Inspect the exported `WindowLink`: it retains
   the statistics/audit hashes, both recording IDs, sign/site/event and window
   overlap. New audit creation receipts retain source/master hashes; older audits
   explicitly lack that historical binding. Do not infer a missing historical
   checksum from successful present-day attachment.
8. The second person uses only the exported ingredients to reproduce one window
   quantity and one event amplitude. The [window guide](BOI_WINDOW_REVIEW_WORKFLOW.md)
   and [event guide](BOI_EVENT_REVIEW_WORKFLOW.md) give the formulas. Use the saved
   baseline status and full required sample count; retain NaN/unavailability.
   Numerical comparison uses the documented arithmetic tolerance. It does not
   establish anatomical accuracy, sensitivity or physiological validity.
9. On another fresh output, change one *declared diagnostic* statistics window
   or an appropriately justified input/curation decision. Explain the resulting
   measurement differences from saved configurations and ingredients. Verify
   that the prior source/run remains intact. A diagnostic window is not evidence
   of an experimental baseline. Record assistance and any unexplained changes.

## Training evidence already available

The local workspace has the following preserved folders (paths here are relative
to the workspace, not the repository):

| Evidence | Local location |
|---|---|
| HP staged source and original master | `reference-validation/boi-hp-workflow-20260910/Recording/` |
| Input CSV | `reference-validation/boi-hp-workflow-20260910/development-input.csv` |
| Original whole-recording statistics A | `reference-validation/boi-hp-workflow-20260910/run-A/Stats_Output_20260910T150837/` |
| Original diagnostic statistics B | `reference-validation/boi-hp-workflow-20260910/run-B/Stats_Output_20260910T150955/` |
| Separate both-sign window export | `reference-validation/boi-surge-windows-20260911/stats/Stats_Output_20260911T214044/` |
| Connected walkthrough and new source audit | `reference-validation/boi-workflow-phase-20260911/` |

Training examples are sink site 1/event 3 and surge site 1/event 4. Their native
runs span frames 508–553 and 1048–1060 respectively. The surge's negative amplitude
is preserved; its physiological interpretation remains unresolved. The developer
walkthrough tests these known examples rather than selecting fresh evaluation data.
Original A/B statistics demonstrate [0,1200) versus [30,1200) seconds with exactly
unchanged event tables. The original full workflow already measured master and
statistics feasibility; this phase adds inspection/audit costs.

## Phase status and release boundary

The connected inspection/export implementation and developer verification are
recorded in [R5-CONNECT-012](reference-results/boi-workflow-phase-20260911/README.md).
Completion of those technical checks is not completion of formal R5 release.
The independent session, second-person replay and scientific eligibility must be
observed and recorded by their actual owners. No reviewer, acceptance, tissue
mask, final outcome hierarchy, animal weighting or cohort inclusion is invented.
A dedicated tissue-mask editor is not supplied here; the explicit reviewed-mask
proposal/decision path and its scientific requirements remain documented in
[the tissue-support guide](BOI_REVIEWED_TISSUE_SUPPORT.md).
