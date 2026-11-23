# Updated versus original calculations: FB2412 result

13 November 2026. UPDATED-ORIGINAL-COMPARE-01, owner root, no delegation.
The explicitly approved one-recording comparison is complete locally. No
production calculation, detector, scientific setting or original result changed.

## Main finding

The updated event-specific amplitude reproduces the **original temporal
baseline rule for all 227 sink events**, when the raw event-footprint trace and
saved interval are held fixed. There are no unexpected amplitude differences
or edge-guard differences in this recording. The comparison covers all saved
automatic sink events, using 57 saved surge runs only for both-sign overlap QC.
It does not decode the movie or rerun either detector.

| Calculation path | Finite signed amplitudes | Negative signed amplitudes | Available burden contributions | Unavailable contributions | Complete normalized recording burden |
| --- | ---: | ---: | ---: | ---: | --- |
| Saved strict automatic output | 120 / 227 | 7 | 113 / 227 | 114 | Unavailable |
| Immediately before update: pre-episode reference | 152 / 227 | 9 | 143 / 227 | 84 | Unavailable |
| Updated event-specific reference with flags | 227 / 227 | 12 | 215 / 227 | 12 | Unavailable |

All updated amplitudes are numerically available. The remaining twelve
contributions are unavailable because their signed amplitudes are negative,
under the preserved nonnegative hypoxic-burden eligibility rule. They are not
missing raw/reference measurements. Their signed values stay exported, and
they are not automatically classified as not-pockets or changed to positive
values/zero. A complete total therefore remains unavailable. No partial sum
or coverage rescaling is reported.

Compared with the pre-update path, **73 contributions become available, one
becomes unavailable and 29 finite contributions change**, for a net gain of 72
available contributions. These changes follow the approved return to each
event's own reference; this was not merely filling missing cells while keeping
all earlier finite amplitudes fixed.

The newly unavailable example is site 36/event 3: pre-episode amplitude
0.11548830790454%, updated local amplitude −0.51250386772617%, using reference
frames 210–229. Both signed measurements are preserved. This comparison does
not decide whether the detection is biologically a pocket.

## What stayed fixed and what was checked

- Every original event column and all pre-existing pre-episode columns are
  preserved. Event identity, mean native area, saved interval/duration, original
  signed AUC, analyzed area, recording duration and calibration remain unchanged.
- Mean areas independently match saved native pixel counts × pixel size²;
  saved durations match inclusive frame count / saved frame rate for all 227 rows.
- Source calibration is 2.35 µm/pixel, 1 Hz, 1,200 seconds and 810,658.82 µm²
  analyzed area. The unchanged area/time multiplier is approximately
  **0.06167822857956447**, applied once to eligible event products or a complete
  recording sum. A finite recording sum does not exist in any comparator, so
  this is not a claim of numeric agreement between finite recording totals.
- All three versions' event products and missingness, event normalization,
  whole-recording window consistency and strict recording-total missingness pass.
  An independent Python check verifies 681 product rows, 227 updated normalized
  contribution rows and 3,600 policy/frame curve samples, including missingness.
  Finite curve points are never summed as a substitute for a complete total.
- The actual existing-format MATLAB export passes event/recording readback.
  The diagnostic workbook preserves 21,503 checked data cells, typed missingness
  and the displayed normalization factor. No Excel error cells are found; all
  five sheets are visually reviewed. Scientific result values are static outputs
  from the saved-data comparison, not an editable alternative calculation method.

The unchanged burden product is amplitude-percent × native mean area-µm² ×
saved duration-s. Normalization is strict sum × 1e6/analyzed area-µm² ×
60/recording duration-s. No formula, denominator, weighting, peak-area measure,
new-reference AUC or scientific acceptance rule is changed.

## The originally supplied quantifier is a different comparison

The pinned supplied quantifier at `8cf3f03` is also executed on every saved
native detection with its archived site/timing traces. Its **timing bounds differ
for 226 of 227 events**. It uses an unbounded return search and the whole-site
raw trace, whereas the accepted current calculation retains bounded timing and
individual event footprints. Its historical duration expression is
`(end-start)/fs`, compared with current inclusive `(end-start+1)/fs`.

These older timing/spatial/duration differences predate the latest baseline
update. They are exposed separately on the **Original timing** sheet and are
not attributed to the new baseline arithmetic. No historical detector pipeline
is regenerated, no area is invented over extended legacy intervals, and no
putative historical complete burden is assembled from incompatible ingredients.

## Reference quality and review meaning

The updated calculation flags 107 local references: 105 have native overlap,
one is post-event and one is short. These counts describe quality flags, not
biological invalidity. No reference has missing raw samples in this example.
The separate first-20-second comparator marks 154 event minima above that earlier
mean; two events lack a preceding comparator. That position flag never changes
local amplitude or inclusion and does not establish biological consequence.
Detailed earlier-reference quality fields remain in the native automatic export.

This is an automatic comparison. It does not apply, alter or reverse saved
not-pocket decisions, other manual reviews or pending timing/area previews.
A finite automatic amplitude does not re-admit a detection into reviewed burden.
Native support, reference suitability, anatomical accuracy, whole-episode
detection and cross-acquisition comparability remain separate qualifications.

## Outputs and finite execution

Diagnostic workbook:

`reference-validation/boi-updated-original-comparison-20261113/outputs/updated-original-20261113/FB2412_Updated_Original_Comparison.xlsx`

Start with **Summary**; **Events** retains every automatic event and the three
versions' values/flags; **Original timing** separates the supplied quantifier;
**Time series** keeps area-only curves; **Definitions** records units, source
roles and missingness. The native updated export and comparison CSV/MAT files
remain with the local evidence; this does not implement the compact-export GUI.

Both permitted MATLAB comparison passes/starts and the one routine harness
repair were used. The first pass finished numerical checks but stopped while
assigning a scalar diagnostic string to 227 table rows; the repair repeats the
label per row without changing a calculation. The second pass and native export
round trip pass. Peak MATLAB process-tree RSS across both attempts is
1,972,715,520 bytes (1.84 GiB), within 2 GiB. Workbook rendering peaks below
0.45 GiB. Both sequential batches finish within two active hours and combined
evidence/output remains below 100 MiB.

All five protected original recording input files and every production MATLAB
source file remain byte-identical. No raw TIFF, reserved recording, new real
review artifact, whole-MAT image array, combined cohort workbook, compact-export
implementation, Git commit/push or release is used. Research case findings stay
local; GitHub receives generic scope/completion/check status only.

Evidence: `reference-validation/boi-updated-original-comparison-20261113/`
contains the source/variable whitelist, isolated pinned program copies, both
execution receipts/logs, independent verification, comparison data, native
export, workbook inspection/render receipts and source-preservation record.

Stop after this comparison. Compact-workbook implementation remains proposed
and held; a further dataset campaign or scientific rule change is not implied.
