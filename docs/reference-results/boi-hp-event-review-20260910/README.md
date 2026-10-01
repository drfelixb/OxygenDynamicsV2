# HP flagged-event and source review

Technical review completed under [R2-HP-REVIEW-003](../../planning/boi-hp-event-review-20260910.json),
10 September 2026. This is the already inspected local ECS development case.
The assistant performed the review; only acquisition facts absent from the
record remain questions for the researcher. Confirmed exact **1 Hz external
triggering** remains authoritative. Incorrect embedded timestamps were not used.

**Conclusion:** the negative surge amplitude is correctly calculated. The
detector identifies relative normalized contrast while the preserved source
intensity remains below its pre-event mean. The low-intensity image-edge
location also exposes a tissue-support problem. Retain the result and flag,
restrict the biological claim, and address tissue support before detector tuning.
The [structured disposition](review-disposition.json) records these restrictions
without modifying the source, original results or detector settings.

## Flagged surge: calculation versus interpretation

Surge site 1, event 4 spans frames 1048–1060, with clean pre-event frames
1028–1047. All 13 event samples lie below their 20-frame baseline mean.

| Quantity | Source reconstruction |
|---|---:|
| Baseline mean | 468.47941882303832 input units |
| Event minimum / maximum | 459.44595158597662 / 467.23184474123542 input units |
| Event mean | 463.30551720816743 input units; −1.1044% relative to baseline |
| Directional surge amplitude | −0.26630285807158355% |
| Signed integral | −0.14357241383687749 s |
| Whole-image mean, baseline to event | 754.7951 to 714.9144; −5.2836% |
| Saved-tissue mean, baseline to event | 893.7420 to 833.7899; −6.7080% |

The event's source intensity falls less than the broader field. At its maximum
source-intensity frame (1051), the detrended event-footprint change remains
negative (−1.275653 input units), but its frame-wise spatial z-score change is
positive (+0.235195); subsequent temporal normalization gives +0.506905.
The sign disagreement is therefore already present at frame-wise normalization.
The independent cubic-fit decomposition contributes only +0.005994 percentage
points at that frame; the residual contributes −0.272297 percentage points.
It does not explain away the negative raw amplitude.

This agrees with the implemented sequence: cubic detrending, frame-wise
standardization, temporal standardization, spatial convolution and temporal
smoothing. Surge candidates exceed the current frame's 90th percentile of the
processed signal, then pass shape/tracking/duration rules. The candidate rule
does not require the preserved source trace to exceed a local pre-event mean.
No alternative baseline or threshold was tried in this review.

The existing independent audit reconstructed saved site traces and matched all
249 event amplitudes, baseline values, sample counts and availability statuses.
A separate CSV calculation reproduced the flagged amplitude and integral.
`BaselineStatus=valid` means the numerical baseline was calculable; it is not
scientific acceptance. The diagnostic plot caption now explicitly labels the
baseline status and the source/detector direction disagreement. Original plots
and numerical artifacts are preserved; only presentation text changed.

See [event measurements and stage summary](flagged-event-summary.json).
Do not describe this event as a positive baseline-relative BOI excursion or an
oxygen increase. Its detector label, negative amplitude and QC flag remain
unchanged. This is not an established biological false-positive rate or a
justification for automatically deleting all direction-discordant events.

## Tissue support is the more consequential issue

The fixed event footprint occupies rows 353–508 and columns 6–139, in the
low-intensity lower-left image region. It contains 9,584 pixels; 3,346 (34.9%)
are in a 20-pixel image-border band, reported here as a location diagnostic,
not an exclusion rule. Its overlap with the saved surge tissue mask is 7,705
pixels (80.4%). Individual native frames have 83.9–91.5% overlap with that mask.
The [per-frame support table](flagged-event-support.csv) preserves the counts.

The region was therefore largely **inside the mask used by the software**.
Passing that mask is not evidence of anatomical cortical support. The image
review shows that the intensity-derived mask admits substantial low-intensity
peripheral support. No anatomical boundary or corrected mask was invented here.

This affects more than the single surge: occupied-tissue fractions and
area-normalized comparisons for this recording remain conditional calculations
under an unvalidated mask. They are not ready for quantitative biological
inclusion. Keep the saved arithmetic available for technical replay, but do not
present it as validated cortical tissue occupancy. A researcher-reviewed support
path and bounded validation are needed before biological use; automatic mask
threshold tuning toward this one example is not justified.

## Broader source changes

All 1,200 source frames were scanned. Saved-tissue mean ranges from 707.8378 to
1038.6015 input units, a maximum/minimum ratio of 1.4673. A broad rise occurs
around 820–850 s, followed later by substantial changes around 980–1060 s.
Multiple fixed 4 × 4 image tiles change together, with different magnitudes.
These are observed intensity patterns, not mechanistic assignments.

The five largest adjacent changes in saved-tissue mean occur at frame pairs
1012/1013, 1027/1028, 1039/1040, 1045/1046 and 1059/1060, about ±2.1–2.4% per
step. For four pairs, all 16 tile means move in the same direction; for the
remaining pair, 14 rise and two fall. Same-scale before/after panels were
inspected. Their raw spatial correlations are not used as a motion acceptance
test: noise, intensity changes and motion are not separated by that statistic.

No zero-valued or 65,535-valued pixels were observed; the largest pixel was
63,949. This checks digital endpoint clipping only, not camera linearity or all
forms of saturation. Retained metadata show no changes in exposure setting
(960 ms), gain (300), preamp gain, amplifier, binning, ROI, trigger label or
baseline-clamp setting. Metadata persistence does not independently prove
hardware stability, especially given the known timestamp problem.

The images and metadata do not determine whether the broad changes arise from
physiology, substrate, handling/motion, illumination or other acquisition
effects. Acquisition/intervention notes were requested for the two time ranges;
this is a request for missing experimental facts, not for the user to perform
the technical review. No experimental window, biological mechanism, frame
exclusion or source correction was inferred.

## Evidence, verification and stopping point

[Source summary](source-review-summary.json),
[largest changes](largest-source-transitions.csv) and
[retained settings](acquisition-setting-review.json) provide compact evidence.
Full traces, 16-tile means, source panels, the same-frame event masks, complete
stage reconstruction and scripts remain in the parent workspace under
`reference-validation/boi-hp-event-review-20260910/`. The artifact record binds
them by checksum, together with the original workflow output hashes.

The source scan's first script attempted a nonexistent MAT variable name and
stopped before reading image pixels. Its source and failure log are retained.
The corrected script read the exported JSON contract and completed the scan.
MATLAB emitted TIFF directory/private-tag warnings; source reads completed,
dimensions and full hashes remained consistent, and those logs are retained.
No source format conversion was performed.

This review used one detector-stage reconstruction and one completed source
scan. No master rerun, detector tuning, resampling or numerical correction was
needed. Both earlier statistics outputs and source data were verified unchanged.
The plot-caption-only change was checked by rendering the saved audit; it did
not warrant a repeat of the full biological workflow or new numerical tests.

Disposition: retain calculations, restrict interpretation, prioritize explicit
tissue-support review. Biological variability, physiological relevance, practical
review effort, BOI-only scope and full traceability remain standing requirements.
