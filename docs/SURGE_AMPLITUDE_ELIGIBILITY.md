# Experimental surge amplitude eligibility and failure decomposition

This step investigates the 89 flagged selector measurements from the preceding
waveform panel. It does not refit onsets or alter detection, spatial supports,
native peak windows, statistics or production contracts.

## Intended quantity and necessary conditions

The target is the maximum observed optical change within the native event
interval relative to the mean of 20 seconds immediately before the estimated
onset, on the same fixed spatial support: `max(Y_native)/mean(Y_reference)-1`.
It includes background fluctuations. A positive fitted component relative to a
modelled sloping background is a different quantity and cannot replace it.

Before examining further diagnostic results, specify these necessary conditions:
resolved onset; complete contiguous reference in the recording, ending before
native detection; no overlap with retained detections of either sign; finite
reference and native samples; and a strictly positive reference mean. Preserve
the signed raw amplitude when those arithmetic conditions hold. A negative raw
amplitude is a direction conflict for a baseline-relative surge; zero indicates
no positive raw change. Only strictly positive raw changes receive a provisional
positive-surge amplitude. Never take an absolute value, clamp to zero, subtract
an estimated drift, move the peak window or change the reference to force a sign.

These conditions are necessary, not sufficient for a scientifically reportable
event amplitude. A positive result remains provisional because absence of
detected overlap does not establish absence of the event's early rising phase.
The function must not receive construction truth or an unchanged source trace.

## Investigation and sensitivity diagnostics

Reconstruct all selector recipes and unchanged source controls from frozen trace
caches. Retain unresolved and unconstructible rows. Recheck both-sign exclusions
and compare signed amplitudes with the preceding output. Export first-half and
second-half reference means, their relative difference, amplitudes under those
two references, and whether both references preserve a positive change. These
are descriptive sensitivities; do not choose a new cutoff after seeing these
data or treat half-reference agreement as proof of a clean baseline.

For constructed cases with an arithmetic amplitude, let p be the first observed
maximum within the native interval, Bx the source-only mean on the proposed
reference frames, and By the constructed reference mean. Independently verify:

`Yp/By - 1 = (Xp/Bx - 1) + (Yp-Xp)/Bx + (Yp/By - Yp/Bx)`.

The terms represent source fluctuation at the same observed peak, imposed
increment, and the change caused by the reference denominator. They are exact
paired-source diagnostics, not estimates available for unknown spontaneous
events. Keep them separate from amplitude eligibility. Retain the prior >1%
imposed-baseline screen as an oracle diagnostic only. Report all 89 flagged
cases, all recipes, controls, sources and fluorescence separately; repeated
recipes are not independent biological observations.

No new model-selection threshold or baseline-stability exclusion is introduced.
After this audit, use the observable sensitivity results to design a separate
baseline-validation experiment before production integration.
