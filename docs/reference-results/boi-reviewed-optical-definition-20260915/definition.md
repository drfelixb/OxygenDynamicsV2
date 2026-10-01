# Optical measurements using researcher-selected references

15 September 2026. **R2-REVIEWED-OPTICAL-DEFINITION-067. Proposed definition,
not implemented and not global scientific adoption.** The definition contract
and supplemental dictionary are version **0.1.0-draft**. Original production
measurements, dictionary 0.3.0-draft, pipeline contract and code are unchanged.

The proposed reviewed result answers: **How does the preserved-input optical
signal change during the reviewed interval, relative to the reference frames
the researcher selected for that event?** It is an exploratory optical
comparison. It does not establish resting oxygen, oxygen concentration,
oxygen deficit or biological recognition of a saved detection.

## Exact reference, including the shorter window

Use every frame explicitly selected for this event and onset. Calculate their
arithmetic mean on the original event's fixed-footprint preserved-input trace.
Each recorded frame has equal weight at the externally triggered 1 Hz rate.
Do not add earlier samples, replace samples with post-event values, pad a
shorter window, silently remove native overlaps or use `omitnan`.

For onset 177, the selected reference is **165–176 inclusive: 12 samples**.
This is complete relative to that exact researcher selection. It still fails
the original automatic 20-sample rule; both facts must remain visible.
Frame 165 remains included as stated, with the preceding approximately
155–165 pocket recorded as context. The reference need not be flat.

This differs substantively from the earlier native-only proposal RB02. That
proposal remains preserved. Its initial reluctance to override native overlap
was based on the absence of an explicit reference judgment. The researcher
has now supplied event-specific selections, including native-overlap frames
and a shorter interval. The new proposed branch uses those selections and
retains native exclusions as context. It does not declare contributor events
false positives, modify their masks or establish a universal shortening rule.

A 12-sample reference is not automatically assigned the same precision as a
20-sample reference. No general minimum duration, independent-sample count,
standard error or physiological precision claim is established by these four
examples. Keep sample counts and the actual trace available for assessment.
General reference-duration criteria remain an open scientific question.

## Signal, footprint and correction

Let `r(t)` be the saved preserved-input mean over the **original fixed union
of the target event's native pixels**. Read the exact saved MATLAB trace;
CSV exports used for preflight are not a substitute for its numeric precision.
Keep the source identity and fixed pixel list bound to the result.

Corrected intensity remains primary for the researcher's boundary/reference
judgment; filtered detection score supports it. Raw/removed trend remain
correction QA. This proposal retains the original amplitude source and the
original per-recording correction. It introduces no additional decline fit,
new global trend, corrected-signal denominator, spatial expansion or mask.
Corrected and preserved-input changes can differ; expose their roles rather
than forcing the calculated amplitude to match the plotted corrected dip.

Sampling is exactly **1 Hz from the external trigger**, with frame 1 at modeled
time 0. Embedded timestamps are not authoritative. Frame duration is separate
from exposure. The formulas retain `fs`, but this bounded proposal does not
validate another acquisition protocol.

## Proposed calculations

For accepted reference frames `C` and inclusive reviewed event frames `a:b`:

```text
B = mean(r(C))
q(t) = (r(t) - B) / B, t = a,...,b
minimum signed change = min(q)
maximum signed change = max(q)
```

Report both signed extrema and all recorded frames tied at each exact extremum.
A negative minimum describes a value below the selected reference; a positive
maximum describes a value above it. Report fractions and percent explicitly
(`percent = 100 * fraction`). Do not take absolute values, clip a negative
value, select the larger magnitude or automatically change an event label.

For comparison with the existing code, retain a separately named
**amplitude under the saved sign convention**:

```text
saved sink:  -min(q)
saved surge:  max(q)
```

This is the existing directional formula with reviewed bounds/reference.
The saved sign is an algorithmic identity, not an inferred biological label.
The two signed extrema remain visible even when a pocket-like dip was saved
as a surge. Interpretation and recognition remain unresolved where they were
unresolved before; no single preferred physiological amplitude is selected
by this proposal.

Also specify, using the same `q` and bounds:

```text
signed trace integral = sum(q) / fs       [fraction * seconds]
mean signed change = mean(q)             [fraction]
inclusive duration = (b-a+1) / fs         [seconds]
endpoint span = (b-a) / fs                [seconds]
```

The integral is the existing uniform-frame rectangle sum, not a trapezoidal
endpoint integral or area-time quantity. Positive and negative contributions
can cancel; retain the trace. Duration does not require a valid optical
reference. A missing amplitude does not erase timing or native measurements.

Teaching example only: twelve reference samples equal to 100 give `B=100`.
For event samples `[100,80,100]`, `q=[0,-0.2,0]`: signed minimum −20%, signed
maximum 0%, sink-convention amplitude +20%, surge-convention amplitude 0%,
and integral −0.2 fraction·seconds at 1 Hz. Three inclusive samples give a
3-second duration and a 2-second endpoint span. These are invented arithmetic
ingredients, not values from the recording or a precision claim about 12 samples.

## Missingness and alternatives

Changed source checksums, mismatched event identities, stale boundary or
judgment revisions and malformed frame lists stop calculation/export. Never
reuse an old number with a new label. An accepted selection must be nonempty,
unique, in range, and strictly before its associated onset.

A missing accepted reference for an onset yields
`unavailable_no_accepted_reference`. Any nonfinite selected reference sample
withholds the reference mean and all dependent optical quantities. A
nonfinite or nonpositive mean also withholds those quantities. No invalid
result becomes zero or triggers an earlier-window search.

If the reference is valid but any event sample is nonfinite, retain its
separately valid reference mean and withhold all interval optical summaries
with an explicit missing-event-signal reason. Keep input values available to
explain the failure. Numerical completion is labeled `computed_exploratory`,
not an unqualified valid baseline or accepted physiology.

Use one record per saved discrete onset/recovery combination. Do not average
alternatives, fill the space between onset choices, invent a preferred offset
or transfer an accepted reference from onset 1154 to alternative 1149.
The current four events yield seven combinations:

| Row / saved identity | Reviewed bounds | Accepted reference | Samples | Preflight disposition |
|---|---|---|---:|---|
| 186 / sink site 15 event 36 | 1154–1166 | 1134–1153 | 20 | Selected reference and event samples finite; mean guard not yet evaluated |
| same | 1154–1167 | 1134–1153 | 20 | Same reference, separate interval |
| same | 1149–1166 | No accepted reference for this onset | unavailable | Withhold reviewed optical quantities |
| same | 1149–1167 | No accepted reference for this onset | unavailable | Withhold reviewed optical quantities |
| 309 / surge site 1 event 4 | 536–556 | 516–535 | 20 | Selected reference and event samples finite; retain contact at 516 |
| 308 / surge site 1 event 3 | 496–516 | 476–495 | 20 | Selected reference and event samples finite |
| 321 / surge site 5 event 1 | 177–195 | 165–176 | 12 | Selected reference and event samples finite; retain all native exclusions |

All seven intervals have finite preserved-input event samples in the saved
exports; five have an accepted reference. This is input preflight only. No
new recording reference mean, extrema, amplitude or integral has been computed.
All four recognition statuses remain `uncertain`.

## Shared definition, provenance and implementation scope

The [supplemental dictionary](planning/boi-reviewed-optical-dictionary-0.1.0-draft.json)
defines BOI-RM01 through BOI-RM04. The
[structured contract](planning/boi-reviewed-optical-contract-0.1.0-draft.json)
records policy, formulas, guards and source-bound cases. The original shared
dictionary and automatic pipeline contract are not relabeled. A proposed
implementation must use this separate versioned definition in its GUI,
export and readable methods explanation; changes to it need a new version.

A new derived record must retain the source/audit/raw hashes, fixed footprint,
native master association and historical checksum limitation, exact reference
and event frames and raw values, numerator `r-B`, denominator `B`, sample
counts, native contributors and reviewed contacts, saved annotation history,
all preferences/alternatives, exact reference judgment and its actor/date/reason,
software/definition/policy versions, units and numerical status. Original
automatic results remain separately identifiable and unchanged. A new source
or judgment produces a new output identity; preserve earlier exports.

Next implementation is a **separate read-only reviewed optical preview and
export**, labeled proposed/exploratory, for these source-bound examples. This
can demonstrate the arithmetic without adopting a global baseline policy or
promoting outputs into cohort statistics. No detector or movie rerun is needed.
Use the existing reviewer and quantitative traces; add meaningful checks for
exact manual membership, both directions, ties, missing samples/nonpositive
reference, alternative bounds, shorter selections, stale inputs and unchanged
automatic results. Wider reference windows and editable manual baseline UI
are beyond this first calculation increment.

The [evidence record](reference-results/boi-reviewed-optical-definition-20260915/README.md)
binds the accepted judgments and preserves the preceding display and proposal.
BOI-only scope, biological variability, physiological relevance, feasibility,
usability, traceability and unresolved anatomical, normalization, recognition,
cohort and independent-validation questions remain in force. These guided
FB2314 examples do not replace the wider 48-event timing challenge or establish
independent scientific validation.
