# Restricted craniotomy ROI development workflow

Implementation decision R1-C02-STRICT-032, 12 September 2026. BOI, both signs.
This opt-in method has passed synthetic implementation checks. It is not a
frozen physiological method or a cohort eligibility decision. The existing
whole-image method remains the default and retains its original replay path.

## Select the method explicitly

Use a fresh recording folder containing the unchanged full original TIFF,
optional denoised TIFF and acquisition declaration. Follow the
[reviewed-support workflow](BOI_REVIEWED_TISSUE_SUPPORT.md) to record a source-bound
logical native ROI. A missing, empty or mismatched ROI fails the restricted run;
no mask is inferred from a filename, image corners or internal darkness.

Pass the existing recording metadata and calibration through the normal MATLAB
function entry point, adding one explicit context field:

```matlab
context.BOISupportProfile = 'craniotomy-roi-1';
master = runOxygenDynamicsMaster(newRecordingFolder, context);
```

Use the source's supported calibration. For the confirmed externally triggered
BOI recordings, `context.SFs = 1` specifies the exact 1 Hz cadence. Keep unreliable
embedded clocks as source metadata. Camera exposure is separate and remains
unknown unless supported by acquisition evidence. This development selector is
currently a MATLAB context field; the launcher does not yet offer a profile
selector. Independent researcher usability remains open.

Omitting this field, or explicitly selecting `whole-image`, retains the existing
method. A reviewed mask alone does not select restricted normalization.
Unrecognized profile names fail rather than matching an abbreviation.

## What changes

The restricted method computes each frame's spatial mean and sample SD using
ROI pixels, then applies the existing temporal standardization at each included
pixel. The same spatial kernel is divided by its included-neighbor weight at
each ROI pixel. Subsequent temporal smoothing is unchanged. Exterior zeros are
computational fill, not observations. Spatial-bin traces also average only
included pixels; bin selection and size retain the existing rules.

Each sign's percentile uses its own eligible pixels. Thresholded pixels are
intersected with that support before connected components and shape/size filters.
The existing 20-pixel sink image-border exclusion is still applied separately.
Tracking, refinement, duration and other detector settings retain their current
rules. Every final native footprint must lie exactly within its sign support.
A violation stops export; it is not repaired by clipping.

Amplitude and signed integral use original source intensities on the new event's
fixed union footprint. The existing 20-second clean pre-event baseline,
both-sign overlap screening, unavailable values and negative signed results are
retained. No old event trace is clipped and reinterpreted as a new measurement.

## Saved identity and review

| Item | Restricted method |
|---|---|
| Profile | `craniotomy-roi-1` |
| Analysis schema | `3.1-roi-dev` |
| Detector | `existing-v2-surge-shape-continuity-5_roi-candidates-1` |
| Normalization | `roi-spatial-sd_temporal-sd_weighted-neighbors-1` |
| Measurement | `event-footprint-contact-ledger-7` |
| Statistics formulas | `mouse-strict-contact-qc-8` |

Both master MAT files retain the source-bound tissue declaration and
`AnalysisInfo.DetectionSupportAudit`: native ROI indices, neighbor-weight map,
kernel width, sink border, spatial-bin origins/size and effective policies.
Site/event tables carry the effective schema. Statistics reject mismatched sign
methods or pooling of whole-image and restricted recordings. Each recording's
profile and policy accompany ordinary JSON/MAT exports, registry and readable
input review. The event viewer displays the support profile.

`auditOxygenEventAmplitudeSource(recordingFolder,'reconstructDetection',true)`
selects preprocessing from the saved profile, checks native containment and
reconstructs source measurements and detection traces. Historical whole-image
outputs retain their original reconstruction. The measurement dictionary
0.3.0-draft formulas are unchanged; read them together with each run's effective
support contract because the event population and support differ.

## Scientific limits and next evaluation

ROI normalization can suppress optical changes shared across the ROI. Boundary
restriction can fragment components; fragments are not established independent
biological events. The neighbor-weight map exposes smaller edge neighborhoods;
no unrecorded erosion or minimum coverage threshold is introduced. Exact
anatomical boundaries, physiological validity, biological variability, dynamic
visibility, baseline availability and camera integration remain separate issues.

[Implementation evidence](reference-results/boi-strict-roi-implementation-20260912/README.md)
covers synthetic arithmetic, exterior independence, containment and replay.
The next bounded evaluation is one prespecified FB2314 awake development run
against the saved 031 support-only comparator, using the same full source and
working ROI. Compare native support, availability, original traces and resource
use without a count or treatment-effect target. Other animals, states and
uncertain ROI decisions do not automatically enter that comparison.

## First biological-source development comparison

The prescribed [FB2314 comparison](reference-results/boi-c02-strict-roi-20260912/README.md)
is now complete. Containment and numerical replay pass, but signed disagreements,
changed interior detection and substantial baseline unavailability remain. The
method stays an opt-in development candidate; this run does not establish
physiological acceptance or authorize automatic cohort expansion.

The [034 mechanism audit](reference-results/boi-c02-normalization-audit-20260912/README.md)
shows that the ROI reference can dominate local residual changes in the three
signed-disagreement cases. A positive relative spatial score is not equivalent
to a positive source-baseline intensity change. This remains a development
limitation; no new normalization, baseline or exclusion policy is adopted.


## R2-SUBSTRATE-CHALLENGE-035 — decay and baseline challenge complete

[R2-SUBSTRATE-CHALLENGE-035](reference-results/boi-substrate-challenge-20260912/README.md)
executes the original 24 shared/local controls, 18 separately frozen decay
stage inputs and 144 known-support event measurements. All use 1 Hz. The
20-second original-source baseline and every production parameter remain
unchanged. Exponential half-lives of 10, 20 and 40 minutes are illustrative;
actual substrate kinetics were not estimated.

At a 10-minute half-life, a supplied 20-second window with decay alone measures
as a 3.35% sink; an injected 2% drop measures 5.29%, and a 2% rise measures 0.77%.
The quantifier's original-source baseline can therefore exaggerate drops and
attenuate rises. These are known-window arithmetic fixtures, not detected
biological events. Shared fractional changes on heterogeneous brightness also
produce relative spatial candidates without local injections. Noise-free
near-zero residual variance can amplify numerical structure; all zero-SD and
unavailable decomposition cases remain explicitly recorded.

Independent checks replay all 144 measurements, 25,200 candidate-frame rows
and all 21 noise-free source stacks with exact hashes. All 467 MATLAB files and
the measurement dictionary match the prior phase. The main run took 4.29 minutes
with two threads; existing changes and prior evidence are preserved. The phase
is complete; physiological acceptance, empirical kinetics, biological variability,
cross-mouse transfer and independent researcher usability remain open.

Next: quantify observed local and ROI pre-event slopes for the same three
source-audited FB2314 cases, preserving their native footprints and original
20 clean samples. Do not assign a substrate half-life from short baselines or
adopt a correction before a bounded comparison of baseline approaches.


## R2-C02-BASELINE-DRIFT-036 — actual pre-event drift audited

[R2-C02-BASELINE-DRIFT-036](reference-results/boi-c02-baseline-drift-20260912/README.md)
checks the same three signed-disagreement events from one FB2314 awake
recording. Native footprints, original 20 clean baseline samples at 1 Hz,
measurement windows and negative amplitudes are preserved. No production
method, detector or cohort analysis was rerun or changed.

Local full-window slopes are −0.1027, −0.1634 and +0.0056 percent of baseline
per second for sink 10/1, surge 1/3 and surge 1/4. A straight line explains
6.3%, 17.4% and 0.08% of local variation. The sink and surge 1/4 reverse slope
direction between the two ten-sample halves; the ROI also differs from local
behavior. These fluctuations do not identify substrate half-lives or establish
which component is physiological. A uniform decay correction is not adopted.

Independent checks reproduce 114 metrics, 7,200 saved raw trace values and
all three native footprints. All 467 MATLAB implementation files remain
unchanged, and the 347 sealed files from phase 035 are preserved. The MATLAB
process completed in 30.49 seconds. A failed initial path dispatch is retained.
This completes the descriptive audit; biological variability, physiological
acceptance, cross-mouse transfer and independent researcher usability remain open.

Next: execute the prespecified comparison of the unchanged 20-second mean
with a pre-event linear reference on 144 existing synthetic fixtures and 64
fixed fluctuating-background inputs. Preserve both answers and test the risk
of extrapolating a short fluctuation before any production baseline decision.


## R2-BASELINE-COMPARISON-037 — controlled reference comparison complete

[R2-BASELINE-COMPARISON-037](reference-results/boi-baseline-comparison-20260912/README.md)
compares the existing 20-second mean with a line fitted only to the same
pre-event samples: 144 unchanged saved fixtures plus 64 frozen fluctuating
inputs, for 416 readouts at 1 Hz. No detector, cohort analysis or production
baseline change occurs. All original constant-reference results replay exactly.

The line reduces smooth-decay error: a noise-free 2% drop over a 20-second
window at an illustrative 10-minute half-life measures 1.995% with the line
versus 5.286% with the mean. Fluctuations can instead produce much larger
errors. One zero-injection control measures a 9.967% drop with the line; the
line reverses the injected direction in 8 of 32 fluctuating cases with a
nonzero component. These are fixed synthetic outcomes, not biological error
rates or an automatic baseline-selection rule.

Independent arithmetic and all 64 new native input hashes agree. Three
zero-change controls have a machine-precision strict sign-flag disagreement
(about −1.14e−16 fraction versus zero); the values, flags and initial failed
verification are retained explicitly. No amplitude is rounded or threshold
tuned. All 467 MATLAB files and prior evidence are preserved. The main process
completed in 22.54 seconds. This closes the controlled comparison, while
physiological interpretation, variability across mice and independent usability
remain open.

Next: make baseline variation and reference sensitivity inspectable in the
existing MATLAB event review, retaining the original saved measurement and
labeling alternatives as diagnostics. Do not automatically correct or exclude
events, or infer substrate kinetics from a short fitted segment.


## R2-BASELINE-REVIEW-038 — diagnostic event review implemented

[R2-BASELINE-REVIEW-038](reference-results/boi-baseline-review-20260912/README.md)
adds a **Baseline diagnostic** tab to the existing MATLAB saved-event review.
It shows the actual clean samples, saved mean, pre-event-only fitted line and
extrapolation interval, full/two-half slopes, variation and reference-sensitive
amplitude. The original measurement remains visible and unchanged. New exports
version and hash the diagnostic, preserve its ingredients and retain negative
and unavailable values. Missing samples are never replaced by an earlier search;
invalid extrapolations are withheld without clipping or automatic correction.

All 29 event, connected-review and window-review tests pass. Three saved FB2314
awake cases and one unavailable-baseline case pass reopening/export checks;
independent arithmetic agrees and the source audit is unchanged. Four corrected
MATLAB screenshots have been inspected. The combined final verification process
took 44.88 seconds. An initial test-discovery failure and an interval-marker
display defect are retained with the correction and passing regression checks.

Only four existing review/test MATLAB files changed, with two new review helpers;
463 prior MATLAB files, the detector, quantifier, statistics and measurement
dictionary remain unchanged. Phase-start versions of edited files and all 64
sealed phase-037 artifacts are preserved. This completes implementation and
verification, not physiological acceptance or independent researcher usability.
BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Substrate consumption
does not establish the origin or kinetics of each local fluctuation.

Next: perform a researcher walkthrough of the diagnostic alongside the saved
event evidence, checking that reference sensitivity and unavailable values are
understood before choosing a production baseline method. Cross-mouse validation
and the distinction between net source change and deviation from an expected
or shared signal remain open.


## R2-BASELINE-REVIEW-FIXES-039 — code-review findings corrected

[R2-BASELINE-REVIEW-FIXES-039](reference-results/boi-baseline-review-fixes-20260912/README.md)
corrects the two reproduced phase-038 review defects. The diagnostic now flags
saved-versus-audited disagreement and separates the saved amplitude, audited
mean-reference amplitude and fitted-line amplitude. Reference sensitivity is
line minus audited amplitude on the same source. The earlier line-minus-saved
difference is preserved with an explicit warning that it can include audit
disagreement. Stored and audited baselines retain their distinct identities;
missing historical values are not filled from the audit. Native bounds now
remain visible outside the measurement interval without extending the fit.

All 31 review tests pass, including serialized mismatch checks for both signs,
missing historical baseline, unavailable diagnostic and native bounds on either
side of the plotted samples. Six MATLAB views were inspected. The same three
FB2314 cases and one unavailable-baseline case retain identical quantitative
frames, footprints, saved rows and prior diagnostic arithmetic. All 48 export
artifacts verify. Diagnostic schema 2 and export schema 4 record the new roles;
the fitted-line method remains version 1 because its arithmetic is unchanged.

Four review/test files changed; the other 465 MATLAB files and all earlier
outputs are preserved. The 229 phase-038 sealed files verify using phase-start
snapshots for subsequently edited files; all 18 code-review evidence files
also verify. These fixes do not resolve the scientific baseline choice,
physiological interpretation, biological variability or cross-mouse transfer.
BOI-only scope, feasibility, usability and traceability remain requirements.

Next: researcher walkthrough of the corrected diagnostic alongside original
event evidence; independent usability and any production baseline decision
remain open.


## R2-C02-TIMING-COMPARISON-041 — annotated timing comparison complete

[Comparison and evidence](reference-results/boi-c02-timing-comparison-20260913/README.md)
retain the existing recording-specific correction and compare FB2314 awake
surge site 1/events 3 and 4 with the researcher's uncertain annotations.
The cubic-corrected local trace crosses zero between frames 499–500 and
514–515 for event 3, and 536–537 and 554–555 for event 4. Event 3's onset
falls later than the working annotation range. These are descriptive landmarks;
no physiological boundary, sink return algorithm or causal substrate trend
is inferred. Historical and current surge bounds are native-mask based.

All 18 annotation alternatives retain 20 finite immediate pre-event samples
without saved native-event overlap, checked against all 346 events of both
signs on the original footprints. This does not prove a biologically quiet
baseline. Boundary shifts change both the reference samples and the included
raw-source maximum: diagnostic surge amplitudes range from −1.315211% to
+1.077856% (event 3) and −0.597962% to +1.316485% (event 4). Original negative
amplitudes, labels and masks remain unchanged. Marked sample-time separation
and inclusive-frame duration are exported separately.

Independent replay verifies 2,400 samples per trace column, all 20 comparison
rows, both saved amplitudes, native overlaps and crossing brackets. Seven
frozen inputs, all 469 MATLAB implementation files and the 143 preserved
phase-039 artifacts verify unchanged. Two final plots were visually inspected.
No detector/statistics run, new movie read or production-code change occurred.

Decision: close this bounded experiment, retain current production rules and
defer adoption of a physiological timing definition. Before selecting a rule,
specify a small comparison across already development-exposed recordings and
both signs, preserving variable backgrounds, morphology, recurrence, overlap,
incomplete recovery and unavailable measurements. BOI-only scope, biological
variability, physiological relevance, feasibility, usability and traceability
remain requirements. These two annotations remain uncertain development
examples; formal independent validation and cohort scientific decisions stay open.
