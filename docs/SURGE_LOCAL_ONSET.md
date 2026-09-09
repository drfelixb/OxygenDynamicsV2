# Experimental raw-trace surge onset

This protocol is specified before running the reference comparison. It changes
no production detection, event identity, baseline, amplitude or statistics rule.
The full union of each retained event's native masks stays fixed, as does the
native interval used to find the amplitude peak. No intensity-selected core is
introduced.

## Candidate rule

Use the raw mean trace on that support. Fit a continuous broken straight line
with a single increase in slope, against a straight-line reference. Search for
the first rising sample from 40 seconds before the native start through that
start. All candidates use the same fitting samples: 60 seconds before the native
start through at most four seconds after it, clipped to the native end. Twenty
seconds of baseline must precede even the earliest candidate. Frame counts use
floor for search/lookahead and round for the baseline, with at least one frame.

The alternative has two extra parameters (slope change and selected breakpoint).
Its descriptive score improvement is `n*log(SSE_linear/SSE_hinge)-2*log(n)`.
Require improvement >=10, a positive slope change, a positive post-change slope,
and a best candidate strictly inside the search bounds. Candidates within two
score units of the best define a profile span, which must be at most ten seconds.
This span is an ambiguity diagnostic, **not a confidence interval**. Serial
correlation and breakpoint search invalidate a simple significance interpretation.
The score thresholds and time limits are provisional engineering choices.

Require the entire fitting interval to exist and be finite. Any retained sink
or surge intersecting this spatial support before the native start within that
interval makes the estimate unresolved. This deliberately prevents fitting
through a known neighboring event; it does not exclude undetected activity.
Constant/linear traces, falling slopes, weak improvements, search-edge optima
and broad profiles remain unresolved. There is no automatic fallback estimate.

For a resolved estimate only, propose the 20-second window immediately before
it. Use its raw mean and the unchanged native peak interval to calculate a
**provisional** amplitude. Require a positive baseline and finite signal throughout
the native peak interval. Report the fitted
baseline slope separately: earlier placement cannot remove background drift.
A broken-line change is an operational onset, not an estimate of the first
nonzero photon contribution or a physiological boundary.

## Frozen comparison

Evaluate all 228 full-event supports from the eight cached growing/shrinking
movies on ID400, ID401, FB2312 and the separate FB2411 fluorescence control.
Apply the identical rule to each constructed trace and its paired original
source trace, using the same support, native interval and detection-exclusion
ledger. These source controls are selected by detections in the constructed
movie and can contain physiology. They are neither independent negative
examples nor a biological false-positive benchmark.

Retain the previous five spatially preselected injection matches. All eight
cases, including the three without a match, remain in the case ledger. The
known first imposed sample is frame 101, but a smooth sine-squared pulse starts
very weakly. Report frame offset without declaring a tolerance-based accuracy
rate. Compare imposed contributions in proposed versus native baselines using
the paired source at the **same frames**, and separate this effect from source
drift. Never use knowledge of frame 101 or source subtraction to fit the onset.

This cached experiment cannot recover missed detections or validate detection
sensitivity. The FB2411 positive recipe had no eligible tissue at its common
core, so absent matches there cannot establish onset failure. Fresh positive
movie challenges must screen tissue eligibility before construction.
