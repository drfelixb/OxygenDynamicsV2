# Felix: test one recording in ordinary MATLAB

13 October 2026 · Felix’s FB2311 manual test is complete and accepted within its
reported sink workflow. See [the result](BOI_FB2311_MANUAL_TEST_RESULT.md): 328
candidates, 293.60 s elapsed, matching selected event and three sink summaries
after reopening. Peak memory and numeric pre-Run limits were not recorded.

The test ran with **3.1.0-dev.2** (preserved candidate03/source 44f3031). For the
new support/export-folder controls, use the **3.1.0-dev.3 checkout**, build
**2026-10-13 20:02:39 +02:00**, following [installation](../INSTALLATION.md).
No replacement ZIP or recording rerun accompanies this update. The reusable
manual instructions below do not authorize another run. Felix’s own feedback,
assistant interface checks and a new unfamiliar-scientist walkthrough remain
separate evidence.

## Before any separately agreed future manual run

For a future test, select **one BOI recording folder** and its existing settings/
metadata authority. The completed FB2311 case used 1 Hz and 2.35 µm/pixel confirmed
by Felix, legacy whole-image support and 1,200 frames. Do not generalize those
values to a new input. Reuse this preflight form before any separately agreed run:

| Before starting | Record the actual choice or evidence |
|---|---|
| Input | Folder, recording ID, preserved TIFF name, optional matching denoised TIFF; image dimensions/frame count when known |
| Timing | Sampling rate in Hz and acquisition evidence; uniform image correspondence; missing/excluded frames; camera exposure separately, or unknown |
| Calibration | µm/pixel and its source; do not substitute another recording's scale |
| Support | Existing **Reviewed craniotomy ROI** with matching source-bound declaration, or intended **Legacy whole image** profile; note anatomical/motion uncertainty |
| Settings | Intended existing rate, calibration, support, labels and effective detector settings; reference to the existing settings record |
| Output | Existing results parent outside the input; proposed unused child `BOIRun_<recordingID>_<date>_01` |
| Finite limits | Maximum elapsed run time ___ min; maximum new output ___ GiB; minimum remaining disk space ___ GiB; observed MATLAB-memory stop threshold ___ GiB; observation interval ___ min |

The folder name is a proposal, not an existing or checked destination. Confirm it
is absent before use; do not create the run child yourself. Agree the numeric
limits after the input size and available disk/RAM are known. The workflow copies
the selected source files into the new run and creates analysis/statistics outputs;
source size alone is not a sufficient storage estimate. Unknown demand remains
unknown. Sampled memory from a system monitor is an observation, not a hard limit
or a guaranteed peak. Stop if an agreed threshold is reached or the machine
becomes unresponsive; retain the folder and report the observation.

Do not assume 1 Hz external triggering. The current route uses a uniform clock;
declared incompatible times or excluded frames are held. Unknown timing evidence
may appear as a scientific warning: decide explicitly whether this conditional,
descriptive test is appropriate. Do not edit declarations to bypass a hold.
Unknown camera exposure remains unknown. This focused route displays established
detector defaults; it has no arbitrary parameter-file import control. If those
effective settings differ from the intended existing analysis, stop at preflight
and report the difference rather than silently substitute or tune settings.

## Manual walkthrough

1. **Open the updated checkout.** Keep candidate03 and older installations. Open a
   fresh ordinary MATLAB desktop, make the updated checkout Current Folder and
   follow [installation](../INSTALLATION.md):

   ```matlab
   addpath(pwd,'-begin');
   setupOxygenDynamicsPath;
   getOxygenPipelineVersion
   which openBOIRecordingWorkflow -all
   which openBOIEventReview -all
   which openBOIWindowReview -all
   openBOIRecordingWorkflow
   ```

   Expected: the version/build above and functions from this checkout. Remove
   conflicting OxygenDynamics path entries before continuing. Record MATLAB/OS
   and installed required toolboxes. Saved workflows were demonstrated on
   macOS/R2025a; historical Linux/R2025b portable checks are not a Linux desktop
   or fresh-recording demonstration.

2. **Select the input.** Click **New analysis**, then **Select recording folder**.
   Select the agreed source folder, with exactly one non-denoised `.tif` and at
   most one matching TIFF whose filename includes `denoised`. Keep any existing
   `BOIInputMetadata.json` and `BOITissueSupport.json` with their source. Do not
   rename, modify or replace originals. Enter the confirmed rate, pixel size,
   **Detection support**, and known mouse/condition labels.
   Expected: the selected folder/settings are visible; **Run recording** is disabled.

3. **Review before Run.** Use **Choose output parent** outside the source. It
   proposes a new `BOIRun_…` child; record that exact path, or replace the output
   field with the agreed unused child above. Click **Review settings**.
   Expected: source hash/frame count, timing/calibration evidence, support,
   effective settings, new destination, required corrections, warnings and
   unavailable information. A declared ROI is shown; legacy support without a
   declaration is estimated later, not independently reviewed tissue. Check
   against the table above and available storage. A required correction keeps
   Run blocked. Only after the choices and limits are agreed, tick
   **I checked these settings and tissue support**. Editing an input requires a
   new review and confirmation.

4. **Start manually once ready.** Record local start time/time zone and click
   **Run recording** yourself. Expected stages: staging → analysis → statistics
   → complete, with the new output path shown. Observe elapsed time, disk space
   and MATLAB memory at the agreed intervals. Stage updates are not a continuous
   heartbeat or an estimated finish time. Do not infer completion from a workbook
   or a quiet screen. On success the workflow selects the completed result and
   displays its actual event count; no event count or amplitude is predicted here.

5. **Inspect both signs.** Click **Inspect event traces**, select a sink and a
   surge when present, and open **Timing review → Show raw / correction quality
   check**. Expected: saved corrected intensity, supporting score/site trace and
   raw intensity/removed trend when saved; missing stages stay unavailable.
   Use the frame selector and **Show source frame** to inspect explicit event
   and reference frames. Orange is the fixed amplitude footprint. **Attach native
   masks** accepts the matching saved master; cyan **Native mask at this frame**
   is distinct. Click **Inspect recording results** and switch its sign selector
   between sink/surge. Expected: each sign's windows, frame ingredients and own
   tissue support. A zero-event result may have no event viewer; record this
   outcome without inventing an example or treating missing evidence as zero.

6. **Close and reopen the completed run.** Record the run path and end time.
   Close the result viewers and workflow, reopen `openBOIRecordingWorkflow`, click
   **Open saved run → Choose BOIRun.mat**, and select the same run's `BOIRun.mat`.
   Expected: the same saved identity/settings/event count, **Run recording**
   disabled, and working inspection/workbook controls. Opening reads saved results;
   it does not rerun the detector or statistics. Use **Open saved workbook** for
   the indexed workbook rather than guessing its filename.

7. **Export the two examples below.** For the chosen event, use **Export selected
   evidence**; for the chosen recording window, use **Export selected window
   evidence**. Choose an export parent; each control creates a new child and
   displays its path. Expected: event `SelectedEventTrace.csv`,
   `FixedAmplitudeFootprint.csv`, `SelectedEventReview.json`/MAT; window
   `Frames.csv`, `Events.csv`, `Metrics.csv`, `Checks.csv`,
   `SelectedWindowReview.json`/MAT. Retain complete exports and their checksum
   records, including unavailable values and original-calculator/current-exporter
   identity. If original calculator identity is unknown, leave it unknown.
   These evidence exports are not the full saved run or a reopened review session.
   **Last completed export folder** keeps the destination visible; use **Open
   folder** or **Copy path**. Cancellation/failure does not promote an incomplete
   destination or erase the last completed path.

## Stop or failure

Bring the MATLAB Command Window into focus and press **Ctrl+C**; on macOS,
**Command+.** is also supported. Interrupts can be delayed in long native/built-in
operations; see [MathWorks: Stop Execution](https://www.mathworks.com/help/matlab/matlab_env/stop-execution.html).
There is no custom workflow Stop button. Closing a viewer is not an analysis-stop
procedure. If MATLAB remains unresponsive, use your ordinary application quit/
OS force-quit procedure for that MATLAB instance and record that it was forced.
No watchdog or automatic retry is part of this test.

An interrupted/forced run remains **incomplete**, even if a surviving status file
says `running` or some outputs exist. Do not relabel it complete. Retain the entire
folder, last visible stage, `RunStatus.json` when present and exact error text/ID.
A normally caught error should display the failed stage and retained folder;
forced termination may not write a final failure status. Do not reuse that folder
or start another attempt automatically. Report the result before a retry decision.

## Inspect one event and one recording summary

**One automatic event amplitude:** name sign/site/event ID. Inspect its saved
fixed pixel footprint, preserved-input mean trace I, clean baseline frames R,
measurement frames E and separate native detected frames. With valid B > 0:

`B = mean(I on R); q = (I − B)/B; sink amplitude = −100 × min(q on E); surge amplitude = 100 × max(q on E).`

Amplitude is percent of the local optical reference, not oxygen concentration.
Record B in input-intensity units, required/available clean reference samples,
event frames, fs, and saved/audit values. This one-event quantity is not an event
mean. Preserve a negative wrong-direction value and its warning; do not take an
absolute value. Corrected intensity helps inspect shape/correction; it does not
replace the preserved-input automatic-amplitude formula. An invalid/missing
reference stays unavailable with its reason. The fixed union footprint is not a
native frame mask, tissue boundary or independently established pocket outline.

**One automatic recording summary:** select the sink whole-recording window
`[0, NFrames/fs)` when available; otherwise record the actual named window and
bounds. Inspect **Occupied tissue fraction**:

`100 × sum(CoveredAreaTime_um2_sec) / sum(AnalyzedTissueTime_um2_sec)` in percent.

The numerator is native sink-mask **union** area inside saved sink support times
clipped frame duration; overlaps count once. The denominator is that sign's
saved tissue area (pixel count × calibration²) times modeled window
duration, in µm²·s. Record both sums, tissue pixels/area, window duration, expected
overlapping-frame count, available contributor rows and detected-event/onset
counts shown for that window. This is tissue-time weighting, not the mean of
event amplitudes or an equal-event/mouse average. A valid analyzed empty window
with positive denominator can be zero; missing masks or invalid denominator are
unavailable. Surge uses its own support and is never subtracted from sinks.
`Checks.csv` agreement is arithmetic/context evidence, not biological validation.
See [duration/area/rate definitions](BOI_DURATION_AREA_AND_EVENT_RATES.md).

Automatic results remain separate from reviewed measurements. If you additionally
make a reviewed-pocket judgment, record your explicit reference/event frames,
reason, source and qualification, and save it as a **NEW** revision using the
[saved-review instructions](BOI_ORDINARY_MATLAB_WALKTHROUGH.md); do not average it
into automatic results. Keep C02's conditional reference, FB2312's unresolved
recovery and all fixed-footprint qualifications. Any later numerical replay is
limited to the selected event and recording summary once their ingredients exist.

## Report back: small results form

```text
Felix’s results form (completed FB2311 feedback is recorded separately):
Recording ID/folder + preserved-source SHA256:
Candidate/source commit + displayed version/build + MATLAB/OS/toolboxes:
Rate/timing authority + pixel calibration evidence:
Support profile/declaration + effective settings + remaining warnings/unknowns:
Agreed output path + elapsed/storage/memory limits and observation interval:
Start/end local time and time zone + completed/failed/interrupted stage:
Retained run path + RunStatus + reopen outcome + workbook path:
New output size/free disk + maximum observed MATLAB memory:
Memory method/sample times/interval (missing = unknown; sampled maximum ≠ true peak):
Event sign/site/event ID + fixed pixels + reference/measurement/native frames:
Event B/reference contributors + saved/audit amplitude (%) + unavailable reason:
Summary sign/window + tissue area/time + numerator/denominator + value (%):
Summary expected/available frame contributors + event/onset counts:
Event/window export paths + provenance/version fields:
Confusing controls or questionable values (include exact row/frame/value):
Exact error ID/text and retained incomplete folder if unsuccessful:
```

The agenda item **Felix must run the recording test** was closed within the
demonstrated scope by Felix's 13 October report. Completion is evidence for this recording and workflow;
biological validity, all-recording performance and release acceptance do not
follow. Elapsed run time is recorded for FB2311; peak memory remains unmeasured.
The full Linux portable pass and partial final macOS evidence retain their prior
limits. Licensing/publication decisions are separate; VM/watchdog/custom
containment and worker qualification remain deferred to a possible v4.
