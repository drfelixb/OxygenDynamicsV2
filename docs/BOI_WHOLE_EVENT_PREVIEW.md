# Whole-event pocket assessment preview

5 November 2026. GitHub tracking: https://github.com/drfelixb/OxygenDynamicsV2/issues/3.

Felix approved implementation after recording the new strategy on GitHub:
evaluate baseline, decline, dip and recovery together, prioritizing detection
quality over runtime. This first milestone produces an optional comparison,
not a replacement production detector or a new burden export.

## Delivery scope

**POCKET-WHOLE-EVENT-01**, owner root, no delegation. User benefit: inspect why
an existing spatial candidate does or does not form a complete local excursion,
and compare individual 10- and 20-second references with original boundaries.

Implement a deterministic saved-trace assessment and an optional tab in the
existing event reviewer. Use the eight cached examples in the 16 October
reference preview, plus finite synthetic checks. Preserve every original
measurement and saved scientific judgment. No movie, detector, correction or
segmentation rerun, cohort processing, scientific adoption, package or release.

Budget: four active engineering hours, at most three MATLAB starts, one focused
synthetic batch, one portable gate, one desktop walkthrough and two repair
cycles, up to 100 MiB new evidence. Stop after the comparison is verified and
ready for researcher review. No further milestone follows automatically.

## Experimental contract

The input consists of the raw and already corrected full-recording traces on
the same saved event footprint, the acquisition clock, original seed bounds,
optional both-sign native overlap and native frame-pixel counts. Unknown
support is unavailable, never an all-clear mask. This service reads no images,
fits no correction and calculates no burden.

Assess raw and corrected traces separately. For each reference duration, search
backward from the original seed for the nearest supported departure from a
local reference. Each tested onset has its own immediately preceding contiguous
reference; do not borrow a remote episode reference or choose the brightest
window. Examine wider context to find a sustained dip and subsequent sustained
return. Reject a reference with missing samples, native overlap or excessive
descriptive drift. A pre-reference linear slope is diagnostic only: it is not
subtracted or extrapolated to repair an event.

Noise is estimated from first differences using a robust scale with an explicit
floor relative to the positive raw reference. All thresholds, window lengths
and search horizons are experimental parameters exposed by the preview. Their
initial values exercise the prototype; they are not biological defaults or
validated detection limits. Missing samples are barriers, without interpolation.
Recovery requires a sustained return within a noise band around the reference,
not one crossing or any arbitrary increase. A changed post-event state or
overshoot may therefore remain unresolved. No post-event baseline substitutes
for a missing pre-event state.

The preview distinguishes a complete trace candidate, unsupported baseline,
no sustained dip, unresolved recovery, recording/context censoring and
raw/corrected disagreement. Repeated threshold dips without sustained recovery
remain inside the same candidate excursion. Supported recovery separates
excursions. Original IDs and event counts are unchanged.

Native pixel counts establish only saved spatial support at those frames.
They do not validate anatomical coherence, pocket area throughout an extended
interval or physiological recovery. Missing spatial context qualifies a trace
candidate, and every output remains a preview requiring scientific assessment.
Because the preview starts from existing spatial detections and footprints, it
cannot find pockets absent from the current candidate generator or establish
whole-movie sensitivity.

## Acceptance

- Synthetic complete pockets, drift, noise, repeated dips with/without recovery,
  raw/corrected disagreement, missing samples and recording limits have explicit
  outcomes and independently specified expected bounds where possible.
- Equal physical traces sampled at different rates use seconds consistently.
- Ten- and twenty-second alternatives stay separate; disagreement is visible.
- Selecting another event or changing parameters clears the old preview.
- No preview acceptance/save/export control and no route into burden inputs.
- The eight fixed saved examples are reported without fitting parameters to
  their desired classifications. Numerical behavior is not biological accuracy.
- Original files and calculation sources remain unchanged; existing portable
  review/export checks pass. Native display is checked in the existing session.

## Scientific follow-up

Review candidate failures and alternatives before adopting thresholds, local
background models, event grouping or corrected/raw interpretation. Time-varying
area and a broader spatial candidate generator remain separate work. Preserve
the burden formula, normalization and strict missingness. A complete-looking
trace alone does not make an unresolved area or recording total available.

## Delivery, 5 November 2026

Local dev.13 is verified as a preview: 17 focused numerical and 239 portable
checks pass, plus two focused desktop checks after the presentation repair.
The populated FB2413 site 3/event 6 view is visually checked at 1280×900.
All eight fixed cached examples have separate 10/20-second outcomes; no settings
were optimized to their classifications. The 10-second FB2413 proposal spans
onset830 to return884/raw or879/corrected, substantially beyond the saved
835–844 interval. It needs scientific interpretation, not automatic adoption.
The cached examples do not contain per-frame native pixel counts, which stay
unavailable. This does not invalidate their cached both-sign overlap evidence.

Ten protected detector/calculation sources and 22 saved scientific files match.
No original movie, segmentation, correction or statistics rerun and no scientific
save/export occurred. Two headless starts, one preinitialization launch failure,
two repairs; existing MATLAB desktop reused. Source policy validates 501 files
including optional smoke. Changes are local and uncommitted; no release or new
package. The implementation milestone is complete and stopped for review.
