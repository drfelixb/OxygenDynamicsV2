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

## Reviewed reference preview

14 September 2026, **R5-REVIEWED-REFERENCE-PREVIEW-060**. Open a fresh event
review to load the updated code; already-open figures retain their callbacks.
Load the saved researcher revision under **Researcher boundaries**, then open
**Reviewed reference** and use **Attach both native sources...** to select the
matching sink and surge master files. These are the current audit's master
outputs, not old v2 or AQuA results. Both complete native populations must match
the audit before any candidate can be called eligible.

The onset selector shows all saved alternatives and initially selects the
explicit preference, if present. It does not save or change that preference.
The preview shows exactly the proposed 20-second immediate reference, observed
and missing sample counts, proposed A/B eligibility, a corrected-intensity
trace and exact frame membership. Green points meet A's rule; red marks show
exclusions; amber marks show contact with another reviewed interval. Ordinary
variation remains visible. Missing corrected stages are not replaced by raw
or score traces; **View timing traces** opens their established context view.

The evidence table distinguishes **Native mask** exclusions from **Reviewed
interval contact**. Native overlap pixels and shared fixed-footprint pixels
have separate columns. Select a row and use **Open selected contributor in
timing review** to inspect that saved event. A shared recovery endpoint is not
an observed native mask. Native contributors retain their original sign and
recognition uncertainty.

Option A retains native eligibility and flags reviewed contact; option B also
vetoes contact with another saved inclusive reviewed interval on a shared
fixed footprint. Both are explicitly proposed, not adopted. Unknown native
support is `NaN`, not zero; no saved onset means no preview window. Unsaved
boundary drafts never enter the preview. Changing an onset selection rechecks
the saved evidence; stale inputs withhold the preview/export and require
reloading or reattachment. No new reference mean, reviewed amplitude, integral,
normalization or correction is calculated.

Export schema 7 adds `ReviewedReferencePreview.json`, and, when saved onsets
exist, `ReviewedReferenceFrames.csv` and `ReviewedReferenceContributors.csv`.
The exact typed preview is a separate `ReviewedReferencePreview` variable in
`SelectedEventReview.mat`; the original `Data` snapshot is unchanged. The
receipt binds both master hashes/association, the saved annotation history,
clock, exclusions, contacts and implementation hashes. Native pixel masks can
be reconstructed from the checked masters; they are not duplicated by these
new preview CSVs. Earlier export folders and schemas remain intact.

The original **Baseline diagnostic** remains a separate saved-reference
diagnostic; its existing arithmetic is unchanged. Numerical eligibility in
this new tab is not physiological reference acceptance. The
[baseline proposal](BOI_REVIEWED_BASELINE_POLICY_PROPOSAL.md) and
[implementation evidence](reference-results/boi-reviewed-reference-preview-20260914/README.md)
retain the open scientific decisions and guided-development limitations.

### Saved researcher reference choices

15 September 2026, **R5-RESEARCHER-REFERENCE-DISPLAY-066**. A fresh reviewer
adds **Load reference judgments...**. Load the matching saved boundary history
first, then select the separate reference-judgment JSON files. From MATLAB,
`UI.LoadReferenceJudgments(paths)` accepts a path or cell array of paths.
Loading replaces the attached set; duplicate event/onset records are rejected.

Blue rings mark researcher-selected reference samples on the corrected trace.
Native green/red marks and amber reviewed contacts remain visible underneath.
The **Researcher selected** column is 1 for selected, 0 for outside that saved
selection, and NaN when that onset has no attached judgment. The separate
summary shows selected frames, sample count, native-eligible count within the
selection, the original sample requirement, reviewer, date and decision ID.
A shorter reference is displayed with its actual sample count; it never
silently passes the original 20-sample requirement. No mean or amplitude is
calculated. A judgment for one onset is not applied to another alternative.

The four saved examples have 20, 20, 20 and 12 selected samples. The pocket
starting at 177 uses 165–176; all 12 selected frames retain their native
exclusion marks. Preferred onset 1154 uses 1134–1153; alternative 1149 remains
unjudged. These local selections do not adopt a global baseline policy or
change detection signs, masks, correction, recognition or original measures.

The loader checks the boundary-file checksum, audit/event identity, saved
annotation and integer frame membership. This increment supports explicit
selections within the displayed preceding 20-second candidate window; it
rejects selections outside that supported window rather than dropping them.
Changed judgments or boundary revisions withhold preview/export until the
appropriate files are loaded. A failed replacement clears the old judgment
attachment. Exact document content, path and SHA256 accompany the preview.

Current export schema **8** / reference-preview schema **2** add this separate
judgment evidence and the membership column. Original `Data` is unchanged;
`ReviewedReferencePreview` remains a separate MAT variable. Existing exports
remain preserved. The preceding schema-7 description documents the earlier
preview increment. The dictionary remains unchanged.

[Versioned launcher and verification](reference-results/boi-researcher-reference-display-20260915/README.md)
provide the four source-bound examples. Already-open figures retain their old
callbacks; open a fresh figure to use the updated display. The earlier sealed
launcher still opens its historical boundary revision and is unchanged.

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
set of lines represents accepted manual physiological boundaries. Purple lines
show separately saved researcher marks; editing occurs in **Researcher
boundaries**. There is no snapping, relabelling, exclusion or adoption of phase
047 timing candidates. Earlier researcher marks and uncertainty remain in their
original evidence records unless explicitly imported with their provenance.

New exports use `boi-event-review-export-6` (timing metadata was added in version 5). `TimingReview.json` and the MAT/JSON
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

## Researcher boundaries and revision files

Open **Researcher boundaries** for the selected event, and use **View timing
traces** to return to the corrected-primary view. Enter a recognition judgment,
discrete onset and recovery/offset alternatives, optional preferred choices,
your reviewer name and the reason or uncertainty. All inputs are **one-based
recording frames**, not elapsed seconds: at the external 1 Hz clock, frame 1154
is modeled time 1153 s. Comma-separated `1149, 1154` means two explicit choices;
it does not assert that every intervening frame is plausible. There is no
snapping, automatic tolerance or endpoint initialization from detector bounds.
An empty endpoint is unresolved. A recognized event may still have unresolved
timing. **Not recognized** requires empty current endpoints; prior marks remain
in revision history. Recognition does not establish physiological validity or
change the saved sink/surge label.

**Save new revision...** writes a new JSON file in the chosen folder. Use a new
filename each time, for example `review-01.json`, then `review-02.json`. Each
snapshot contains the complete loaded history across reviewed events, audit
and raw-source checksums, event identities and saved bounds, frame clock,
reviewer, reason, UTC time, previous and new judgments, and implementation
checksums. Earlier files are never overwritten. **Load saved review...** resumes
from a snapshot for this exact audit. Loading an older snapshot deliberately
starts from its contained history; save a separately named continuation.
Concurrent branches are retained as separate files and are not merged
automatically. A changed loaded file or audit blocks saving/export until
reloaded and reconciled. These are provenance checks, not a digital signature
or retrospective proof of the original analysis.

Drafts stay with their event when you switch rows, including while loading a
saved review. They remain session-only until saved. Closing the reviewer with
unsaved drafts offers to keep reviewing or discard them. **Timing overlays and
evidence exports include only saved judgments.** Purple dotted lines show saved
alternatives and thicker purple lines show preferred choices; red dashed and
blue dotted lines retain their existing automatic measurement/native roles.
The display expands to include manual marks outside the old automatic search
limits. It does not widen or recalculate any measurement.

Export schema `boi-event-review-export-6` adds `ResearcherBoundaries.json` for the
selected event, and `ResearcherBoundaryHistory.json` when a review is attached.
The latter is self-contained and can be loaded against the matching saved
audit even if the original review folder has moved. It contains history for
all events in the loaded review, which is identified explicitly in the export
README. The existing frame CSV, amplitude, baseline, native masks, acquisition
provenance and measurement dictionary definitions remain unchanged. Manual
endpoints never silently recalculate amplitude, duration statistics or native
masks. No saved review attached means `not_reviewed`, not a negative judgment.

Earlier conversation feedback remains in its separate, versioned evidence
records; it is not silently imported or assigned a new reviewer timestamp.
The phase-054 verification files contain explicitly labelled developer
fixtures, which must not be treated as new researcher annotations.
