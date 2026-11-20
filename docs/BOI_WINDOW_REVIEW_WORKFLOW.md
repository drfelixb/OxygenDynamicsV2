# Recording and window evidence in MATLAB

11 September 2026. **BOI Measurements → Open recording/window evidence** opens
a saved BOI `DataOutput.mat`. The same inspector is available as
`openBOIWindowReview(resultsPath)`. It reads saved tables and contracts; it does
not rerun the detector, statistics, source movie or current input preflight.

## Follow a value to its ingredients

1. Select a recording/window row and choose **sink** or **surge** in the sign selector. **Window calculation** shows the saved and
   replayed occupied tissue fraction, event onset rate and concurrent-event
   density, with explicit units and numerical status.
2. **Frame ingredients** shows the arithmetic/context checks and each saved
   frame's union area, analyzed area, window overlap and area-time contributions.
   Partial-frame overlap is preserved. The plots show covered area and the
   contribution to the denominator across the recording.
3. **Event timing** retains every selected-sign event in the selected recording,
   including events outside the window. Onset membership, overlap duration,
   acquisition-boundary onsets and events ongoing at the window start remain
   explicit. These are saved algorithmic intervals, not accepted physiological
   onset/recovery times. Select a row, **Choose saved event audit**, then **Open
   selected event evidence** to follow the event to its baseline, trace and source
   image. Source/recording mapping, both-sign tissue support, sampling, calibration,
   acquisition declarations and saved event measurements must agree. Audit choice
   is retained for that recording during the session; every open rechecks it.
4. **Saved tissue support** displays sink and surge support separately using
   the contract's native pixel indices. The supplied physical scale and tissue
   validity status remain visible. These are analysis masks, not independent
   anatomical references or proof of valid support throughout the movie.
5. **Measurement definitions** provides the shared dictionary, including
   formulas, missingness and interpretation limits. It starts with current
   definitions, explicitly labelled as such. Open the run's saved dictionary
   when reviewing historical definitions; selection alone does not establish
   its original binding to the result MAT file.
6. **Export selected window evidence** creates a new folder containing the
   saved window, frame and event ingredients, input contract, QC, acquisition
   exposure table, arithmetic checks, definitions, readable calculation and
   provenance. It preserves earlier results and rejects a changed result file
   rather than silently mixing it with the open view.

`RecordingWindowMetrics` and `WindowFrameIngredients` retain the original
**sink** `boi-window-exposure-1` schema and calculations. New BOI statistics
exports add `SurgeRecordingWindowMetrics` and `SurgeWindowFrameIngredients`
under `boi-surge-window-exposure-1`, separately in MAT, CSV and workbook sheets.
Both signs refer to the same requested windows and each uses its own saved
tissue support. `RecordingRegistry.RecordingArea_um2` remains the sink area;
use the selected sign's window area or input-contract pixels for its denominator.
Surge amplitude-area-time composite fields are NaN with
`CompositeStatus=not_defined_for_surge`; no surge composite is adopted.

Older exports remain readable with surge window outcomes explicitly unavailable.
The viewer does not create them from sink results. A partial or mismatched surge
extension is rejected. All detections contribute to descriptive coverage,
onsets and active event-time regardless of amplitude availability or direction;
this does not establish physiological event validity. Both signs stay separate
and cannot cancel or share denominators.

The batch inspection and export entry points accept an optional sign:

```matlab
review = loadBOIWindowReview(resultsPath);
surge = buildBOIWindowReviewData(review,1,'surge');
receipt = exportBOIWindowReview(review,1,newFolder,savedDictionaryPath,'surge');
```

Omitting the sign retains sink inspection/export. Selected-window receipts record
the actual sign, window schema and surge-evidence availability.

## Calculations and reproducibility

The viewer replays three calculations from the saved ingredients:

| Quantity | Numerator | Denominator and conversion |
|---|---|---|
| Occupied tissue fraction | Sum of covered area-time in µm²·s | Divide by analyzed tissue-time in µm²·s |
| Event onset rate | Count of onsets in the half-open window | Divide by tissue-time in mm²·min |
| Concurrent event density | Sum of event overlap seconds | Divide by tissue-time in mm²·s |

For a local exported review:

```matlab
F = readtable(fullfile(reviewFolder,'Frames.csv'));
E = readtable(fullfile(reviewFolder,'Events.csv'));
denominator = sum(F.AnalyzedTissueTime_um2_sec);
occupiedFraction = sum(F.CoveredAreaTime_um2_sec) / denominator;
onsetRate = sum(E.OnsetInWindow == 1) * 60e6 / denominator;
concurrentDensity = sum(E.OverlapSec) * 1e6 / denominator;
```

Use the normalized calculations only with a positive finite denominator. Do not
omit NaN or substitute zero for missing numerator/support. CSV membership flags
are 1/0. MAT/CSV NaN and JSON null indicate unavailable quantities. A completed
event-free analysis can produce zero, while a failed recording is flagged by the
analysis-status check. A finite number alone is never scientific acceptance.

Checks include frame identity/coverage, modeled bounds, clipped exposure,
pixel-derived tissue area, area-time products, saved sums, event counts and
event overlap. The numerical comparison tolerance is
`1e-9 * max(1, abs(reference))`; it is an arithmetic tolerance, not a biological
acceptance threshold. Disagreements are displayed and exported. Saved union
areas are checked algebraically; the inspector does not reconstruct every
source mask to validate their original detection.

## Acquisition and interpretation

HP retains confirmed external **1 Hz** timing. Embedded timestamps remain
unreliable source provenance. Camera integration exposure is separately
displayed and exported; the declared 0.96 s does not replace the one-second
interval in tissue-time. No measured absolute image clock is invented.

The selected input contract and QC remain bound to the saved result. Identity,
calibration, tissue observability and physiological interpretation questions are
retained. The viewer does not pool animals, curate events, select outcomes or
approve a cohort. AQuA2 exploratory detections are not tissue-validation evidence.

Exports contain original paths and acquisition metadata for local research
review. Public sharing needs a deliberate portable mapping. Source checksums,
saved registry/analysis information and review implementation hashes remain
available in the structured record.

[Initial developer verification](reference-results/boi-window-review-20260911/README.md)
documents the saved sink replay. [Both-sign verification](reference-results/boi-surge-windows-20260911/README.md)
adds synthetic edge cases and a statistics-only HP replay with unchanged prior results. An independent researcher
walkthrough and scientific release decisions remain open.

## Connected event provenance

The event inspector starts on the exact selected sign/site/event and shows its
window membership and overlap. **Return to window** returns to the originating
window without changing its selection. Event exports retain a `WindowLink` with
statistics/audit hashes, portable and source recording IDs, window bounds and
actual overlap. Selecting another unrelated audit event does not carry that
window link onto it. A changed statistics file blocks connected export until
reopened and reconnected. No event re-identification or physiological exclusion
occurs during navigation.

A missing audit can be created explicitly using **Create event source audit** in
BOI Measurements. It reads the full preserved movie with a runtime notice,
without rerunning detection/statistics. New-folder output includes source/master
checksums and a creation receipt. Failed creations retain an incomplete marker
and cannot be opened as successful evidence. Existing audits remain supported
with their historical provenance limits.

The [phase handoff](BOI_RESEARCHER_WALKTHROUGH.md) gives the complete reviewer
route and records the still-pending independent release tasks.
