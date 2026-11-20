# FB2420 corrected-trace comparison specification

15 September 2026 · R3-FB2420-TEMPORAL-SPEC-084 · version 0.1.0-draft

**The bounded comparison is specified and its source preflight passed.**
No temporal descriptors have been computed, classifier implemented or production
policy adopted. The next execution can use the fixed machine-readable
`comparison-spec.json` without selecting cases, boundaries or settings from its
new results.

The question is descriptive: **What signal contrast, endpoint relationships and
local variability surround the intervals already recorded?** This separates
temporal evidence in corrected intensity from the existing spatial detector.
It does not claim to locate all biological events or validate oxygen measurements.

## Reuse previous evidence, without repeating a rejected rule

The phase-047 comparison already defined 10- and 20-sample context summaries:
median, minimum, maximum, range and unscaled median absolute deviation (MAD).
Its nearest-turn and strongest-shoulder rules did not consistently reproduce
researcher timing; the factor-one range screen could reject a recognized surge
and accept an overextended interval. Their exact contract, results, local code
and **48-event development panel** are hash-bound as historical comparators.
The separate 34-amplitude/10-timing synthetic baseline challenge is not mistaken
for this 48-event panel.

This comparison retains those two context scales and descriptive summaries,
uses only fixed existing intervals, and adds no pass/fail range screen, boundary
search, fitted threshold or new smoothing. The 20-second choice first discussed
for this phase is therefore retained alongside the existing 10-second sensitivity,
not treated as a newly established physiological timescale. Neither scale is chosen
as a winner after seeing the result.

## Exact scope: 14 interval records, 28 diagnostic rows

| Record | Source case / footprint | Frames | Role |
|---|---|---|---|
| auto-01 | Sink 6/1 | 25–31 | Original automatic measurement interval |
| auto-02 | Sink 1/1 | 1–48 | Original automatic measurement interval |
| auto-03 | Sink 3/1 | 2–4 | Original automatic measurement interval |
| auto-04 | Sink 17/1 | 86–171 | Original automatic measurement interval |
| auto-05 | Sink 5/2 | 18–26 | Original automatic measurement interval |
| auto-06 | Surge 3/1 | 134–144 | Original automatic measurement interval |
| auto-07 | Surge 1/1 | 1–10 | Original automatic measurement interval |
| auto-08 | Surge 11/5 | 971–1034 | Original automatic measurement interval |
| auto-09 | Surge 2/4 | 105–126 | Original automatic measurement interval |
| human-surge-06 | Same case-6 footprint | 130–150 | Recognized surge, approximate human bounds |
| context-02-A | Same case-2 footprint | 2–28 | Tentative contextual pocket |
| context-02-B84 | Same case-2 footprint | 65–84 | Tentative recovery alternative |
| context-02-B85 | Same case-2 footprint | 65–85 | Same observation, other recovery alternative |
| context-03-A | Same case-3 footprint | 7–27 | Pocket identified by researcher; approximate timing |

The 14 records are not 14 independent events. The nine source footprints stay
fixed; native masks and site identities are not expanded, merged or reassigned.
The two late case-2 rows remain alternatives of one observation. Automatic
nonrecognition does not transfer to those separate contextual intervals. The
recognized surge's identity does not make its automatic endpoints exact.

The corrected signal is the exact saved `DetectionDetrended` mean over the
original native event-union footprint. Use saved MATLAB values, not a new fit
or a display TIFF. Preserve raw, removed-trend and score provenance as QA/context.
Sampling is external 1 Hz, frame 1 corresponds to modeled time 0, and camera
exposure and unreliable embedded timestamps remain distinct.

## Context membership, variability and missingness

For an inclusive interval `a:b` and context size `W` of 10 or 20 samples:

```text
before = a-W : a-1
after  = b+1 : b+W
```

The endpoints `a` and `b` belong to the interval, not also to its flanks. Each
side requires all W observed finite corrected samples for its descriptors.
Retain observed IDs, unavailable counts and every relevant reason when it is
incomplete. No padding, extrapolation, interpolation, shortened fallback or
search farther away is allowed. A complete opposite side remains usable, but
results requiring the incomplete side remain unavailable.

Retain nearby native activity of both signs as per-frame spatial-contact flags,
with contributors and exact footprint intersection. Do not silently trim context
using the very detector whose discrepancies are being examined. Record contacts
with separately reviewed/contextual intervals as another layer, preserving
approximate bounds and alternative identities. Such contacts do not create native
occupancy or prove physiological contamination. Do not require a flat plateau.

These are observed context windows, **not accepted baseline references**. This
choice does not change the original optical amplitude's raw-source reference
rule or any earlier researcher-selected reference. It introduces no corrected-
intensity denominator, percentage amplitude, oxygen unit or accepted baseline.

## Exact descriptive calculations

For each complete side `C`, on the corrected trace `y`:

```text
m = median(y(C))
lo = min(y(C)); hi = max(y(C))
range = hi - lo
MAD = median(abs(y(C) - m))          # unscaled
```

For a finite interval retain its minimum, maximum, all exact tied extrema frames,
onset sample `y(a)`, recovery sample `y(b)` and endpoint difference `y(b)-y(a)`.
For each complete side, report **both** signed contrasts:

```text
rise contrast    = max(y(a:b)) - m
decline contrast = m - min(y(a:b))
```

Also report `y(a)-median(before)`, `y(b)-median(after)` and
`median(after)-median(before)` when their required samples are available.
These keep onset, recovery and changing context levels visible separately.
No line is fitted between the flanks; no new trend or substrate-decline model
is removed. Zero range/MAD remains zero, not infinite evidence. There are no
ratios, absolute-value repairs, p-values or confidence intervals. All values are
in corrected input-intensity units and remain descriptive; temporal correlation
and biological variability preclude treating the samples as independent replicates.

No calculated contrast becomes a recognition label or a boundary proposal.
Negative directional contrasts remain negative. A saved sink/surge sign does not
select whichever interpretation agrees better with the researcher.

## Verified feasibility and output contract

MATLAB verified all 14 interval identities against original bounds, saved human
bounds or the previously bound contextual records, and matched all 330 native
events to both source masters. Preflight took 5.83 seconds and did not calculate
new descriptors, baselines or detector outputs.

Of the 28 interval-by-scale rows, **17 have complete before and after context**;
**11 lack enough preceding acquisition samples**. All after contexts are complete.
Ten rows have preceding native contacts and seven have following contacts; these
counts are separate from finite-context availability. Preserve all rows and all
flags in the output. These are repeated diagnostic rows, not biological counts.

The result must retain interval role, human certainty, source/footprint hashes,
exact frame IDs, all missingness reasons, both directional contrasts, native/human
contact provenance and both context scales. One summary should expose scale
sensitivity and disagreements, with at most two illustrations for further human
review. Raw/correction and score traces remain available, but no new full review
queue or obligation to inspect every event is introduced.

## Verification and stopping point

Before source calculation, verify scalar arithmetic on known rise, decline,
flat/zero-spread, changing-level, tied-extrema, early-acquisition, nonfinite,
neighbor-contact and alternative-recovery examples. Independently reproduce every
finite descriptor and exact status/frame membership. Numeric tolerance is
`1e-9 absolute + 1e-12 relative`; identities, hashes and discrete membership must
match exactly. Original results, annotations and dictionaries must remain intact.

The budget is **one recording, 14 fixed intervals, two context scales, 28 output
rows, one execution pass, five MATLAB minutes and 50 MiB new evidence**. No source
movie reload, detector invocation, correction fit or parameter search. At most
one documented implementation-only corrective round is allowed for a technical
failure; scientific settings cannot be changed to improve agreement. Report poor
separation or inconclusive results rather than starting another search.

This specification does not establish a biological success threshold. A future
production detector/timing change still needs its own recorded decision, the
48-event development panel and original measurement regression. This small,
source-exposed FB2420 comparison cannot replace those checks or establish
independent validation. The numerical comparison is ready to implement separately;
no production change or new global scientific policy has been adopted.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Reference precision,
physiology, anatomical/calibration uncertainty, dynamic validity, transient effects
and independent-evaluation design remain unresolved. All 485 MATLAB files and
143 preceding sealed audit artifacts are preserved.

[Evidence packet](reference-results/boi-fb2420-temporal-comparison-spec-20260915/README.md).
