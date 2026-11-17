# Baselines for manually reviewed BOI events — proposal

14 September 2026. **R2-REVIEWED-BASELINE-POLICY-059. Status: proposed, not
adopted or implemented.** This supplements the earlier
[measurement-policy proposal](BOI_MEASUREMENT_POLICY_PROPOSAL.md). Preparing
this proposal does not accept its scientific decisions. Original measurements,
researcher annotations, MATLAB code and dictionary 0.3.0-draft remain unchanged.

**Recommendation:** retain the existing 20-frame native-exclusion rule for
these 1 Hz recordings. If adopted, calculate reviewed-interval optical
measurements as a separate, explicitly exploratory result. Keep physiological
reference suitability and recognition uncertainty visible alongside numerical
availability. Flag contact with a manually marked recovery endpoint without
automatically excluding it. Do not rescue insufficient references by moving
farther back, averaging fewer samples or ignoring an overlapping detection.

This recommendation preserves a reproducible descriptive optical reference.
It does not establish that 20 seconds is a universal physiological scale, that
a reference is flat, or that a detected surge is a local oxygen increase.

## What changes, and what stays attached to the original result

| Record | Proposed behavior |
|---|---|
| Original automatic result | Keep its original interval, footprint, baseline frames/value, amplitude, integral, sign, status and provenance. A manual edit never overwrites or silently reinterprets it. |
| Researcher boundary annotation | Keep all saved discrete alternatives, preferences, recognition status and history. It is a judgment record, not an automatic measurement update. |
| Reviewed-reference preview | Show the exact immediate candidate frames, eligible count, exclusion contributors and context flags for each distinct reviewed onset. No mean is needed to explain availability. |
| Reviewed-interval optical result, if policy is adopted | Use the reviewed interval and its own reference under the rules below. Label it exploratory and show it alongside the original. Preserve uncertainty even if the calculation is finite. |
| Physiological interpretation | A separate assessment for a stated claim. Numerical completeness does not establish resting oxygen, an event-free physiological state, recovery, or event recognition. |

Changing the anchor from automatic start to reviewed onset is a new derived
measurement definition, even when the source, mean and screening rule are
retained. Before implementing calculation/export, version that definition and
its schema; update the shared dictionary and contract wherever their scope
requires it. Historical exports retain their existing definitions. No version
has been incremented by this proposal.

## Exact proposed rules

**RB01 — source, support and clock.** Use the original event's fixed union of
native pixels and its preserved-input mean trace, exactly as for current
amplitude. Do not substitute the corrected trace or detection score as a
fractional-amplitude denominator. Corrected intensity remains primary for
boundary/context review; scores support it and raw/removed trend provide QA.
Keep the original per-recording correction, with no added substrate-decline
model. The fixed footprint is observed native support from the original event;
its trace outside the native run is not newly observed native event occupancy.

For the present data, external sampling is exactly 1 Hz and frame 1 has modeled
time 0. Embedded timestamps are not authoritative and camera exposure remains
distinct. For another supported sampling rate, retain the existing rule
`n = round(20 * fs)` rather than hard-coding 20 frames; validate its acquisition
contract separately.

**RB02 — candidate reference and numerical availability.** For each saved
reviewed onset `a`, request the `n` immediately preceding samples, `a-n` through
`a-1`. At the recording boundary, show only observed candidates and the missing
count; never access frame 0, wrap around, pad, or call a shortened window full.
An observed candidate is eligible only when its preserved-input footprint mean
is finite and its fixed footprint intersects no saved native mask of either
sign at that frame. Require all `n` samples. Use the full native union across
sites and both signs, not just the target's site or selected review examples.

Insufficient samples mean unavailable reference-dependent amplitude and
integral. Do not calculate a partial fallback mean. Do not substitute zero,
delete the detection, alter its mask, or select an onset because it has more
eligible samples. Native projected area/coverage and timing retain their own
definitions and eligibility; missing amplitude alone does not erase them.

**RB03 — calculation after adoption.** For a valid reviewed interval `[a,b]`
and a complete reference `C`, use the same preserved-input trace `r(t)`:

```text
B = mean(r(t), t in C)
d(t) = (r(t) - B) / B, for t = a,...,b
sink directional amplitude = -min(d(t))
surge directional amplitude = max(d(t))
signed trace integral = sum(d(t)) / fs
```

Require a finite positive `B` and finite event samples before computing these
outputs. Invalid bounds, unavailable source/footprint, nonpositive reference
and missing event samples have distinct unavailable reasons. Retain negative
directional amplitudes; never take an absolute value to obtain an expected
sign. Fraction and percent are explicitly distinguished. The integral retains
its signed fraction-seconds convention. These are preserved-input optical
changes, not oxygen concentration or a score-derived physiological amplitude.

At this proposal stage, full sample availability has been checked; new `B`,
event-signal guards and derived amplitudes have not been evaluated. Do not
promise a finite amplitude solely from a 20/20 count.

Compute each explicitly saved onset/recovery combination separately if this
calculation is later adopted. Do not average alternatives, interpolate an
uncertainty range, or invent a preferred recovery. A preferred onset can still
have two equally retained offset alternatives. Keep recognition `uncertain`
when that is the saved judgment; numerical success does not change it.

**RB04 — recovery contact is a context flag.** If an eligible candidate also
lies in another explicitly reviewed interval on a shared fixed footprint,
record the other event, annotation revision, exact shared frames, footprint
intersection and boundary alternatives. Distinguish recovery-endpoint-only
contact from overlap with other interval samples. Include the current saved
alternative combinations without treating every frame between alternatives
as a possible boundary or automatically choosing the preferred one.

Under the recommended rule, this flag does not change the native eligibility
count. A manually marked recovery peak may represent return toward baseline;
an inclusive timing endpoint alone cannot establish contamination. Nor does
absence of this flag establish physiological cleanliness: only four events
have current saved annotations here, and unreviewed intervals remain unknown.
No reviewed interval creates a native mask outside its saved native run.

**RB05 — physiological suitability and review burden.** Show the reference
and neighboring context on the corrected intensity trace, including preceding
events and return after the reviewed interval. Ordinary variation, a slope,
unusual morphology or noncentral location alone is not an automatic failure.
Do not require the researcher to draw an exactly flat plateau or add a
recording-independent substrate assumption.

Keep an explicit context assessment separate from numerical status:
`not_assessed`, `unresolved`, `unsuitable_for_stated_claim`, or
`supported_for_stated_claim`, with the claim, reviewer, reason and evidence.
These are proposed fields, not existing assessments. Support for a descriptive
optical comparison is not automatically support for a resting-oxygen claim.
Until a claim is supported, any computed result remains an exploratory optical
quantity. A future unsuitable assessment blocks that claim's use, not the
historical calculation or event record. Physiological acceptance criteria
remain open; this proposal does not make subjective review a new cohort gate.

Review flags in the existing event view; do not demand manual examination of
every event just to reproduce the automatic output. A no-event reference means
no retained native overlap under this detector, not proven biological silence.

## Consequences for the four actual reviewed events

These counts reuse the verified phase-057/058 evidence. They are not new
amplitudes or retrospective approvals. All four recognition statuses remain
`uncertain`.

| Saved identity / reviewed interval | Proposed reference | Eligible | Consequence under recommendation |
|---|---|---:|---|
| Surge site 1/event 3, row 308 / 496–516 | 476–495 | 20/20 | Sample-complete; could enter the derived calculation after adoption and remaining numerical checks. Physiological suitability has not been established. |
| Surge site 1/event 4, row 309 / 536–556 | 516–535 | 20/20 | Same, with an explicit recovery-endpoint contact at 516. Retain the flag; do not silently exclude the sample. |
| Surge site 5/event 1, row 321 / 177–195 | 157–176 | 0/20 | Reviewed amplitude/integral unavailable: surge site 4/event 1 excludes 157–165, then site 2/event 2 excludes 166–176. |
| Sink site 15/event 36, row 186 / preferred 1153 to 1166 or 1167 | 1133–1152 | 15/20 | Both reviewed results unavailable: surge site 1/event 7 excludes 1148–1152. Keep preferred onset 1153. |
| Same sink / alternative 1149 to 1166 or 1167 | 1129–1148 | 19/20 | Both alternative results unavailable: the same surge excludes 1148. Do not prefer 1149 to improve availability. |

Frame 1153 is the researcher's intentional current frame choice, not a
seconds-to-frame conversion. Earlier 1154 remains historical. There are five
distinct reference windows and seven reviewed intervals, with four sink
combinations; shared references need not be recomputed for each offset.

The two finite original automatic amplitudes for rows 308/309 remain tied to
their original automatic references and intervals. They do not become the
reviewed-interval amplitudes merely because both new windows have 20 samples.
The original amplitudes for rows 321/186 remain unavailable.

## The substantive policy choice: how to treat frame 516

| Option | Exact rule and consequence in these examples | Assessment |
|---|---|---|
| A — retain native eligibility and flag reviewed contact | Frame 516 remains eligible: 20/20 before onset 536. Both site-1 windows remain sample-complete; the other three do not. | **Recommended for descriptive optical measurement.** Preserves the original screening rule while exposing its limits. Does not certify a quiet physiological baseline. |
| B — also veto any overlap with another saved inclusive reviewed interval on a shared fixed footprint | Exclude 516; 19/20 remain before onset 536, so that reviewed result becomes unavailable. Other counts remain 20, 0, 15 and 19 in this bounded four-event review. No replacement sample. | Defensible only as a separately adopted rule. It treats a recovery endpoint as disqualifying and depends on which neighboring events were manually reviewed. |
| C — permit native-overlap overrides or substitute another reference | Could change availability, but no resulting counts or amplitudes are asserted here. Exact revised rules and evidence would be needed. | Not recommended from this inspection. No contributor was scientifically rejected; a sign disagreement or missing amplitude is not sufficient reason for an override. |

Option B's 19/20 is set arithmetic on the already verified contact at 516,
not a detector rerun or a new baseline calculation. The contrast applies only
to the saved reviewed intervals/footprints in this development example. It
cannot be extrapolated to cohort missingness. A duration endpoint and a valid
optical reference sample can coincide under A because they answer different
questions; make that explicit to the researcher.

Neither option authorizes fitting another baseline, averaging pre/post peaks,
extending an earlier search, weakening the 20-sample requirement, excluding
internal dark tissue, or changing the detector's sign labels. Such changes
would need their own estimand, rationale and bounded comparison.

## Researcher-facing preview and traceability

Suggested wording, for row 309:

> Reviewed reference: frames 516–535; 20 of 20 samples meet the native-mask
> rule. Frame 516 is also the preceding reviewed recovery endpoint. Reference
> suitability remains unresolved. No reviewed amplitude has been calculated.

For row 186:

> Reviewed reference: frames 1133–1152; 15 of 20 eligible. A saved surge
> overlaps frames 1148–1152. Reviewed amplitude is unavailable under the
> proposed rule. Preferred onset remains 1153.

Use neutral labels such as “20/20 eligible,” not an unqualified “valid
baseline.” Keep original measurement, reviewed diagnostic and scientific
assessment visibly distinguishable in the view and export.

Each derived record must bind recording/raw/audit identity and hashes, native
master association and its historical limitations, fixed footprint, source
stage, external clock, policy/software versions, exact reference and event
frames, rejected samples with contributing event IDs, arithmetic ingredients,
numerical status, contextual flags, annotation file hash/revision/actor/reason,
and all alternatives/preferences. A changed annotation or source creates a
new derived record; never reuse an old result as if current or erase it.
Scientific review adds its own dated history without rewriting boundary history.

## Bounded implementation and verification after the proposal

The first feasible increment is a **read-only reviewed-reference preview**
using the saved vectors and checked native union. It can expose the five
windows and exact contributor links without new amplitudes, movie processing,
manual reannotation or policy adoption. A and B may be displayed as explicitly
labeled proposal alternatives; neither overwrites production results.

If A or a revised calculation policy is adopted, implement separate derived
records and test their scientific arithmetic invariants: both signs and all
sites screened, recording-start truncation, nonfinite samples/nonpositive
reference, all 20 required samples, discrete alternatives, signed outputs,
stale annotation protection and preservation of original measurements. Verify
one complete and one insufficient real reference from saved ingredients,
plus minimal constructed cases for missing/invalid inputs. A raw-movie or
detector rerun is unnecessary for this measurement-only work.

Do not aggregate these exploratory results into cohort estimates, change
native coverage, propagate reviewed timing into automatic statistics, or
construct a new amplitude-area-duration composite in this increment. Those
uses need their own agreed support, admission and versioned definitions.

A separate automatic timing hypothesis would still require the frozen wider
48-event challenge with both signs and non-recognized cases. The four guided
examples from FB2314 are development evidence, not independent biological or
usability validation. BOI-only scope, biological variability, physiological
relevance, feasibility, usability, traceability and unresolved anatomical,
normalization, cohort and scientific questions remain in force.

The [structured proposal](planning/boi-reviewed-baseline-policy-20260914.json)
keeps every decision `proposed` and reviewer/adoption fields empty. The
[evidence record](reference-results/boi-reviewed-baseline-policy-20260914/README.md)
links the prior inspections, exact input hashes and preservation checks.
