# Prespecified onset-model selection and waveform challenge

This validation-only step chooses between the available-context rising fit and
pulse fit. It changes no production rule, footprint, native peak interval,
baseline requirement, model grid or component-fit threshold.

## Selector

Require identical fit-frame bounds. Subtract `2*log(2)` from both existing
complexity-adjusted scores to charge for choosing between two model families.
A model is plausible if its adjusted score is at least 10 and its status is
resolved, broad-profile unresolved, or search-boundary unresolved. A falling
rising-fit solution is not a positive-event model. Preserve a shared missing
context/construction status when neither model has evidence.

Choose the larger adjusted score, with rising fit first in an exact tie. If the
best model is unresolved, do not rescue the result with a weaker resolved fit.
If the other plausible model is within two score units, require both resolved,
onsets no more than five seconds apart, and their combined profile endpoints
spanning at most ten seconds. Otherwise return model disagreement/uncertainty.
A clearly lower-scoring model cannot veto the best model. These thresholds are
provisional diagnostics, not calibrated confidence or significance claims.
Copy baseline and amplitude only from the accepted model. Never average onsets,
choose the earlier reference, or maximize amplitude across models.

## Evaluations

First replay the selector on both previously verified component outputs of the
5,520-row development panel and their 115 source controls; no refitting occurs.
Retain all denominators, gained/lost resolutions and clean-reference diagnostics.

Then use a separate waveform panel on the same 115 original-source supports,
plus all frozen surge-event supports from the archived ID13-20200917 and
FB2316-baseline recordings. These two recordings were earlier pipeline references
but have not been used to develop these onset fits. Their supports come from
historical detector outputs; do not relabel them as current-detector validation
or pool their saved measurements with current analysis outputs. Check raw TIFF
hashes against the saved analysis and export exact event/mask/reference provenance.

Cross optical increments 2/10/20%, rise scales 7/23 seconds, delays 10/25 seconds,
and three new families (36 recipes per support):

- Gamma pulse: for positive sample index j, `(j/r)*exp(1-j/r)`, cut to zero after
  `8*r` samples. It has no plateau and an asymmetric tail.
- Exponential rise/decay: rise `(1-exp(-3*j/r))/(1-exp(-3))` through r samples,
  hold for 11 samples, then `exp(-(j-r-11)/(2*r))`, cut after `r+11+12*r`.
- Quadratic asymmetric pulse: rise `(j/r)^2`, hold for 11 samples, then
  `(1-(j-r-11)/(2*r))^2` until recovery reaches zero.

Set first positive sample to native start minus the chosen delay. Use the
previous construction rule `Y=X*(1+a*envelope)` with no rounding or new noise.
Require 20 finite positive known pre-onset source samples and a finite positive
source trace; retain unavailable recipes explicitly. Report terminal truncation.
Evaluate rising, pulse and selector on identical traces/exclusions. The selector
receives no waveform identity or truth. Also report all 36 noiseless recipes
without making their success a gate or tuning the rules to failures.

Use the existing five-second and one-percent descriptive screens, with all
constructible cases in denominators, plus paired source controls. Report the
additional recordings and fluorescence background separately. Independently
rebuild the new waveforms, raw support traces, exclusions, fits, selector and
amplitude arithmetic. No claim of biological accuracy or robustness to new
photon noise follows from deterministic mean-trace challenges.
