**Subsequent product-use finding, 13 November 2026:** a saved-batch GUI preview succeeded, but its Availability projection is too large for the compact-workbook goal and formatting scales poorly. No real workbook was written. The [batch-usability follow-up](BOI_COMPACT_BATCH_USABILITY_PLAN.md) is proposed and held; the synthetic core verification below remains a bounded historical result, not full-sized export performance acceptance.

# Compact workbook delivered locally

13 November 2026. COMPACT-EXPORT-01 is complete within the original scope and its two explicitly approved narrow extensions. Original scientific calculations and results remain unchanged.

## Using it

1. Open a completed combined automatic export in the batch editor's existing stats/export tab.
2. Open **Compact workbook** and click **Use opened automatic export**.
3. Optionally select completed **ReviewedHypoxicBurden.mat** exports matching that exact automatic source. Saved compatible batch choices can be restored or changed. Individual event review is optional.
4. Choose a new `.xlsx` filename, click **Preview compact workbook**, then **Export compact workbook**. The completed workbook and its folder have direct open buttons.

The exporter also accepts explicitly selected automatic MAT/workbook sources. Optional metadata CSV uses an exact RecordingID crosswalk. Optional phase CSV requires RecordingID, Phase, StartSec and EndSec; it adds annotations only. No mandatory CSV field was added.

## What is exported

Six core sheets: **Events**, **Recordings**, **Sites**, **TimeSeries**, **Availability** and **Definitions**. Explicit supplied annotations add **Phases** as a seventh sheet. Events opens first, with one row per original detection and paired automatic/reviewed measurements. Recording, mouse, supplied session, condition and source identities remain distinguishable.

Saved local amplitudes, native mean area, duration, exact burden-used ingredients and signed contributions are copied separately. Native diameter/circularity, original-reference signed AUC and native-gap QC retain their roles. AUC is not recalculated or relabelled reviewed when burden timing/reference changes. Peak area remains outside this contract.

Recordings pairs saved raw and area/time-normalized burden with exposure, counts, availability and sign. TimeSeries preserves explicit saved clocks and matching automatic/reviewed area-normalized burden curves; those points have no extra per-minute normalization. Definitions gives field-specific units, signal/area/time normalization and comparison limits. Raw intensity, event size/duration, unnormalized totals and normalized rates are distinguished.

Finite signed values keep their signs and source flags. Genuine missingness stays unavailable; no partial, positive-only or zero-filled burden is computed. Compatible unchanged reviewed values are labelled **No manual review**. Absent compatible reviewed snapshots remain unavailable, with no automatic fallback. Excluded detections remain visible in Events, with reviewed contribution excluded/not applicable.

Only completed matching saved snapshots are copied. Foreign parents, duplicate/overlapping identities, changed preview inputs and contradictory reviewed exclusion membership stop. Preview and destination validation precede writer dispatch; cancellation/errors restore controls and preserve the previous completed export. Selection preferences use a separate source/hash-bound batch UI sidecar; no batch scientific rows or saved reviews are changed.

## Verification

The latest result for each of the eight frozen families passes. The final run evaluates only source conflicts/preservation and GUI/writer recovery; both pass. It also verifies that contradictory flags are rejected, no export warning occurs and body text receives wrapped row formatting. The six other passing family results used for acceptance retain their exact earlier run provenance; no broad rerun is claimed.

Across the explicitly approved scopes: **4 MATLAB starts, 26 function evaluations, 5 XLSX dispatches and 3 combined repairs**. Five writes include the one input fixture and the initial failed writer; three synthetic compact outputs remain preserved. Peak monitored process-tree RSS was **1.31 GiB**, below 4 GiB. Compact outputs total **183,667 bytes**, below 25 MiB; evidence is below 100 MiB. The original six-hour boundary and source limits were retained.

Native MAT/CSV/XLSX compatibility and numeric/text readback are checked on constructed and named pre-existing synthetic sources. All seven final sheet previews were inspected read-only, without another workbook write. The image renderer drops visual leading zeros on numeric-looking text; native XML/readback preserves text ID `001` and is the identity authority.

All **614 pre-existing MATLAB files outside the permitted editor change are byte-identical**. The only edited pre-existing MATLAB file is openBOIBatchEditor.m. New files implement projection, source validation, workbook formatting, GUI/persistence and finite tests. No detector, correction, reference, burden or normalization kernel changed. No scientific calculator, real recording, individual biological example or reserved recording was used.

Evidence: `reference-validation/boi-compact-workbook-implementation-20261113/acceptance-receipt.json`, `delivered-source-manifest.json`, `repair-test-results.json`, `repair-worker-receipt.json`, `final-layout-inspection.json` and `layout-final-ranges.json`.

## Limits

This is a saved-value exporter, not source regeneration. Older saved exports retain their actual policy and missingness; the compact workbook does not turn them into revision-31 calculations. These tests establish the bounded software behavior, not biological validity, new timing/calibration accuracy, performance at arbitrary scale or regeneration of the real 17-recording batch. A real-source upstream statistics/export request remains a separate action.

No Git commit, push, package, release or real batch re-export was performed. No further implementation or verification campaign is active.
