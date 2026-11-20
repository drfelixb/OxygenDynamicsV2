# Experimental pulse-shaped onset fit

This specification precedes evaluation. Retain the available contiguous clean
context, 20-second reference, 40-second onset search, four-second native
lookahead, fixed footprint and native amplitude peak interval from the previous
experiment. No production change is made.

Fit a linear background plus a nonnegative pulse. Search linear and sine-squared
rises/recoveries, independent rise and recovery lengths of 2/5/10/15/20/30/45/60
seconds, and plateaus of 0/5/10/20/40/60 seconds. Require positive template support
at native start. All onset candidates use identical samples. Durations extending
past the fit window remain template parameters, not measured physiology.

For each template, fit intercept, background slope and nonnegative coefficient.
Profile over shape and durations at each onset. Score improvement is
`n*log(SSE_background/SSE_pulse)-5*log(n)-2*log(2)`. The five extra parameters
are coefficient, onset and three durations; the last term charges for two
shape families. Retain this conservative penalty even for unobserved parts.
Require score >=10, an interior optimum, and an onset profile within two score
units spanning at most ten seconds. This descriptive score is not a p-value,
and the profile is not a confidence interval. Recompute near-exact residuals
directly to prevent floating-point subtraction from creating false improvement.

Calculate provisional amplitude from the original raw native peak and the raw
mean of the 20 frames before resolved onset. The fitted pulse coefficient is
a diagnostic, not the reported amplitude. Preserve missing signal, insufficient
context and nonpositive-baseline states.

First test all 48 existing noiseless recipes, constant/linear/falling signals,
neighbors, recording limits, missing peak samples, gain changes and unequal
rise/recovery. Then evaluate the same frozen 115-support, 5,520-recipe panel:
5,136 constructible fits, 384 unavailable rows, and 115 source controls. Compare
with the prior available-context results using the same five-second/one-percent
screens and full denominators, including gained and lost resolutions. Keep the
fluorescence control separate. Neither shape nor grid is tuned after results.

The template families include the panel's generating shapes and durations;
this is deliberately in-family development evidence, not held-out validation.
No photon noise, spatial detection, oxygen calibration or biological accuracy
is established. More resolved fits alone cannot justify promotion. Independent
numerical reconstruction and source/input hashes accompany the comparison.
