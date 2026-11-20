# Saved BOI event inspection in MATLAB

11 September 2026. The **BOI Measurements** tab connects the measurement
dictionary and a read-only saved-event inspector to `OxygenDynamics_GUI`.
Opening a review does not run detection, statistics or source reconstruction.
Both sinks and surges remain visible, including unavailable amplitudes and
source changes opposite to a detector label.

## Researcher steps

1. Open **BOI Measurements**. Select a measurement to read its question,
   formula, units, signal/baseline, spatial support, missingness rules,
   implementation limits and worked teaching example. **Open full definition**
   provides a larger scrollable snapshot of the selected definition.
2. The initial dictionary is labelled **Current definitions; not a saved run
   snapshot**. Use **Open saved dictionary** to read a run's exported
   `BOIMeasurementDictionary.json`. The selected path and version remain visible.
   Choosing a file alone does not verify that a particular audit used it.
3. Select **Open saved event audit**, then choose an existing
   `event-amplitude-audit.mat`. The same viewer is available from MATLAB as
   `openBOIEventReview(auditPath)`. The audit must contain `Audit`, `Traces` and
   `AnalysisInfo` from `auditOxygenEventAmplitudeSource`; a statistics MAT file
   or old detection output is not interchangeable with that evidence.
4. Select an event row. The detail panel shows the saved recording/site/event
   identity, stored amplitude, independently audited amplitude, baseline status
   and replay agreement. The plots show preserved-input intensity and signed
   optical change. Green samples identify the clean baseline; red dashed bounds
   identify the measurement interval and blue dotted bounds native detection.
   Choose **Baseline diagnostic** to inspect the same clean samples and compare
   the audited mean reference with a line fitted only to those samples. The tab
   shows the saved amplitude, audited amplitude and explicitly diagnostic
   alternative. Reference sensitivity is line minus audited amplitude in
   percentage points; saved-versus-audited disagreement is flagged separately.
   **View saved event** returns to the event
   list; selecting another event updates the diagnostic and its interval markers.
   Choose **Timing review** for corrected intensity with supporting detection
   scores. **View amplitude evidence** returns to the same event list.
5. Use **Show source frame** to load one original image after checking its
   checksum. The orange overlay is the **fixed union footprint used for
   amplitude**, not a native mask at that frame or a tissue boundary. Choose
   another frame with the spinner and load it explicitly. Changing the spinner
   clears the previous image until the selected frame is loaded. A gray dash-dot
   line marks the displayed frame on the quantitative traces. Missing or changed
   sources withhold the image and explain why; saved traces stay available.
6. For native morphology, use **Attach native masks** and select the saved sink
   or surge master matching the selected event. The viewer checks its source and
   complete analysis metadata, recording/site/event identity, stored measurement,
   native run bounds and union footprint against the audit. The overlay selector
   then offers **Native mask at this frame** in cyan, separately from the orange
   fixed amplitude footprint. The quantitative trace continues to use the fixed
   footprint; choosing a display does not recalculate amplitude.
7. **Export selected evidence** creates a new folder under the chosen parent.
   It saves all-frame quantitative ingredients, clean-baseline and event-window
   membership, fixed footprint coordinates, the selected dictionary, saved
   acquisition evidence, calculation text, MAT/JSON provenance and checksums.
   If native masks are attached, it also saves `NativeEventFramePixels.csv` and
   the attachment evidence. Earlier reviews and analysis outputs are preserved.

## Timing review follows the researcher signal hierarchy

The **Timing review** tab makes saved corrected intensity the primary plot for
event shape and onset/recovery. The supporting plot separately labels the
filtered score averaged over the fixed event footprint and the saved site
trace. Their spatial support and processing differ; a score extremum is not
automatically a physiological boundary. Both detected signs retain their saved
labels, including cases with disagreement or no recognizable excursion.

Enable **Show raw / correction quality check** to inspect the preserved input.
The already removed trend is raw minus saved corrected mean only when the
audit explicitly records a shared input. It is unavailable when corrected
intensity used a separate denoised input or that relationship is unknown.
There is no new fit, correction, substrate-decline model or amplitude baseline.
Missing, malformed and nonfinite saved stages are explicitly unavailable or
retained as gaps, without substituted signals or zeros. Existing amplitude
evidence remains accessible in all these cases.

All timing plots share recording-frame coordinates. The synchronized spinner
shows both the selected one-based frame and modeled elapsed time:
`time = (frame - 1) / samplingHz`. Frame 1 is time 0; these recordings use the
confirmed external 1 Hz trigger. Exposure duration is separate. The gray marker
indicates the selected frame; source-image loading and checksum verification
remain explicit in the amplitude tab. Event selection updates all traces.

Red dashed and blue dotted lines show the saved measurement and native
**sample bounds**, respectively. These use inclusive first/last frame indices;
the older amplitude view shows half-open duration edges in seconds. Neither
set of lines represents accepted manual physiological boundaries. The tab
does not edit annotations, snap marks, relabel or exclude events, or adopt the
phase 047 timing candidates. Earlier researcher marks and uncertainty remain
in their original evidence records.

New exports use `boi-event-review-export-5`. `TimingReview.json` and the MAT/JSON
receipt include signal roles, saved-stage field names, processing/support,
availability, selected event and sample bounds, source/audit hashes, and clock
provenance. `SelectedEventTrace.csv` adds `CorrectedIntensity`,
`FilteredDetectionScore`, `SavedSiteTimingTrace` and `ExistingRemovedTrend`.
The original quantitative fields and baseline diagnostic retain their meanings.
The timing metadata schema is `boi-timing-review-1`; no measurement formula or
dictionary version changes. [Implementation and verification evidence](reference-results/boi-timing-review-ui-20260914/README.md)
records the saved-recording checks and rendered views. Independent researcher
usability and physiological validation remain separate requirements.

## Baseline sensitivity is a diagnostic

The **Baseline diagnostic** tab does not correct or overwrite a measurement.
The left plot shows the actual clean baseline samples, audited mean and fitted
line. The right plot shows the line extrapolated through the original
measurement window. Black dashed bounds mark that window; blue dotted bounds
mark native detection. These may coincide. The display includes both native
bounds even when they extend beyond the measurement interval; expanding the
display does not extend the fitted reference or calculation window.
Source timing is modeled from the
saved frame rate, including the externally triggered 1 Hz cadence in the
audited FB2314 recording; embedded clocks are not substituted.

The tab uses the audit's actual required sample count and sampling rate. It
does not impose a new baseline length: current FB2314 results require 20 clean
samples (20 seconds). An incomplete or nonlocal set of samples is withheld;
no earlier samples replace it. Replayed baseline/source disagreement, a
nonfinite source or a nonpositive extrapolated reference is explained. An
invalid line may remain visible to explain why the alternative amplitude is
unavailable. It is never clipped into an available result.

The scrollable table shows stored and audited baselines, full-window and two-half slopes, coefficient
of variation, peak-to-trough variation, residual RMS, descriptive R-squared,
extrapolation duration, reference minimum and diagnostic signed integral.
Slopes use percent of the full baseline mean per second. The two halves use
their own time-centered fits and the same full-window mean; each half needs at
least two samples. A flat trace has unavailable R-squared rather than a claim
of a perfect explanatory fit. No stable/unstable threshold or substrate
half-life is inferred. A shared fluctuation can be biologically meaningful.

The saved result and the source audit can disagree even when trace replay
matches the audit. The tab explicitly flags **AUDIT DISAGREEMENT**, displays
both amplitudes, and draws a distinct stored baseline when it differs from the
audited mean. A missing historical stored baseline remains unavailable.
Reference sensitivity always compares the line with the audited mean-reference
amplitude on the same source. The separate line-minus-saved difference remains
in the table and export, labeled as potentially including audit disagreement.
Neither comparison overwrites the saved result or resolves the disagreement.

The diagnostic uses method `boi-baseline-linear-review-1` and schema
`boi-baseline-diagnostic-2`. Its centered-sum least-squares reference is
`mean(y) + beta*(time-mean(baselineTime))`, with
`beta = sum((t-mean(t)).*(y-mean(y))) / sum((t-mean(t)).^2)`.
No event or post-event sample contributes to the fit. Fractional change is
`(source-reference)/reference`; sink amplitude is its negative minimum and
surge amplitude its maximum over the unchanged measurement window. Signed
integral is the sample sum divided by sampling Hz. Negative and very small
values remain in the export; numerical sign is not physiological acceptance.

Export version 4 introduced `BaselineDiagnostic.json`; version 5 retains it,
with source/audit identity, event identity, original saved amplitude, explicit
units, availability reason and calculation version. The record includes
`SavedMeasurementMatchesAudit`, `AuditAgreementMessage`, `SavedBaseline`,
`AuditedBaseline`, `AuditedAmplitudeFraction` and explicit comparison roles.
`DifferenceFromAuditedAmplitude_pp` measures line-versus-mean sensitivity;
`DifferenceFromSavedAmplitude_pp` retains its earlier numerical meaning and
can also include audit disagreement. The fit method remains version 1 because
its source samples and arithmetic are unchanged. The same diagnostic is
recorded in the MAT snapshot and JSON receipt. `SelectedEventTrace.csv` adds:

- `DiagnosticLinearReference`: baseline and event samples only when a fit can
  be calculated; otherwise NaN.
- `DiagnosticLinearSignedFraction`: event samples only when the entire
  alternative measurement has finite source values and positive finite
  references; otherwise NaN for the whole event.

The original `SignedFraction`, saved event fields, baseline, dictionary and
statistics are retained. Review implementation hashes and artifact checksums
include the new calculation. To reopen the live inspector, open the original
saved audit again. `SelectedEventReview.mat` is an immutable exported snapshot
of `Data` and `Receipt`, not a replacement audit input. Old exports are preserved
and need not contain the new fields.

Implementation evidence and the three FB2314 examples are in
[R2-BASELINE-REVIEW-038](reference-results/boi-baseline-review-20260912/README.md).
The subsequent code-review corrections and regression evidence are in
[R2-BASELINE-REVIEW-FIXES-039](reference-results/boi-baseline-review-fixes-20260912/README.md).

If an audit has not been generated, use **Create event source audit** in the
main BOI Measurements tab. Choose one recording folder with an unambiguous
saved master per sign and a parent for a new output. `createBOIEventAudit` invokes
the existing source-audit calculation explicitly, reading the full movie with
a runtime notice. It preserves prior analyses and records source/master hashes,
actual runtime, event counts, mismatches and unavailable/direction evidence.
Failed creations retain `AuditCreationFailure.json` and are withheld by the
viewer. The same action is available in batch as
`createBOIEventAudit(recordingFolder,newOutputFolder)`.

## Reproduce an amplitude from the exported CSV

The CSV uses 1/0 membership flags. In MATLAB:

```matlab
F = readtable(fullfile(reviewFolder,'SelectedEventTrace.csv'));
B0 = mean(F.PreservedInputMean(F.CleanBaseline == 1));
q = (F.PreservedInputMean(F.MeasurementWindow == 1) - B0) / B0;
surgeAmplitude = max(q);  % fraction; multiply by 100 for percent
sinkAmplitude = -min(q); % use the recorded event sign
```

Use this replay only when the recorded baseline status is `valid` and the
required clean sample count is present. Do not manufacture an available
amplitude from a shorter baseline. The inspector separately checks the baseline
mean and amplitude against the saved audit. A disagreement is displayed, not
corrected. CSV/MAT NaN and JSON null denote unavailable values, not zero.

## Scientific and provenance limits

The HP acquisition remains user-confirmed external **1 Hz**. Displayed times
are the saved calculation's frame-index model; unreliable embedded clocks are
retained in acquisition provenance and never substituted into the plot.
The inspector reads the saved acquisition snapshot, not a newly edited sidecar.
Its source-identity and calibration issues remain visible.

Older audits do not contain native masks for every frame or the master file's
checksum. New audits created through `createBOIEventAudit` save the master hashes
in `AuditCreationReceipt.json`, bind that receipt to the audit/source hash, and
require attached masters to match those captured hashes. Their receipt is retained
in event exports. This added evidence never changes an older audit retrospectively.

For an older audit, the original saved audit does not contain the master file's checksum. Native support is therefore an explicitly **attached
master snapshot**, with the selected file's checksum and attachment time. Exact
metadata, identity, bounds and union agreement support the association; they
do not retrospectively prove which per-frame mask file existed when the audit
was created. No missing historical checksum is invented.

Only the selected native event run is displayed. Outside it, native support is
known empty even when another event recurs at the same site or a trace-refined
measurement interval extends farther. Missing attachments are unavailable,
not empty. `NativeMaskPixels` in the trace CSV is NaN when unavailable and a
count, including zero outside the run, when attached. Native coordinate rows
can reproduce these counts. No physical calibration is inferred from them.
Missing or changed attached masters block native display and attached export;
the fixed-footprint view remains available when its preserved image is valid.

Neither overlay is reviewed anatomical tissue or established physiological
extent. The interface does not calculate tissue occupancy from an event mask.
AQuA2 exploratory outputs are not substituted for missing anatomical evidence.

`valid` describes the baseline calculation, not scientific eligibility.
Negative surge amplitudes, unavailable measurements and unresolved identity
remain in the table. An empty audit is not automatically a valid biological
zero. No event is relabelled, excluded, normalized again or pooled across animals.

Exports retain local paths and original acquisition metadata and are intended
for local research review. Public sharing needs a deliberate portable mapping.
The exported dictionary is labelled either current context or a user-selected
saved dictionary; it is never silently claimed to be the historical definition.
Changing the displayed dictionary on disk requires reloading before export.
Changing an audit on disk requires reopening before export.

The [initial viewer verification](reference-results/boi-event-viewer-20260911/README.md)
and [native-mask inspection verification](reference-results/boi-native-inspection-20260911/README.md)
document developer tests and the selected HP walkthroughs.
[Connected workflow verification](reference-results/boi-workflow-phase-20260911/README.md)
completes window-to-event navigation, both-sign source inspection and creation
of missing audits. The [researcher handoff](BOI_RESEARCHER_WALKTHROUGH.md) retains
independent usability, biological validity and formal release as separate gates.

When opened from a window's **Event timing** table, the selected event carries
its checked recording/window context. **Return to window** keeps the previous
selection. `WindowLink` in the event export records both original IDs, hashes,
window bounds and onset/overlap contribution. It is a present-day checked
association, not an invented historical audit-to-statistics checksum. Choosing
an unrelated event in the audit does not inherit that link.
