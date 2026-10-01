# Competing boundaries across ten reviewed examples

R2-BOUNDARY-AMBIGUITY-053, 14 September 2026. The bounded diagnostic is complete.
It exposes **323 eligible shoulders across 20 directional branches** in the ten
previously reviewed examples. These are mathematical candidates, not accepted
events or boundaries. No ranking or new timing rule is adopted.

## What was checked

The diagnostic reuses the frozen phase 047 search limits, directional seeds,
finite segments, exact-equality plateau definition and T2/T3 records. Within
each segment it enumerates every observed local extremum. A shoulder is an
observed trough in the directional corrected trace strictly before or after
an observed seed peak. The seed is unchanged. Unbracketed seeds remain unresolved;
an endpoint without its outside neighbor never becomes an observed turn.

Each shoulder retains its full plateau, the representative sample facing the
seed, corrected value, directional seed-to-shoulder difference, temporal order,
intervening extrema, and raw/corrected/event-score/site-score samples across the
plateau and its immediate neighbors. No smoothing or tolerance is added. This
local difference is in corrected signal units, not the released optical amplitude.
Nonfinite and acquisition/neighbor/search barriers remain explicit.

The four latest MATLAB annotations are used alongside their history. The onset
entry 526 is superseded by **536**. ID400's supplied 295 and 297 alternatives
remain distinct; 296 is a separately labeled coordinate sensitivity, not an
accepted mark. The two non-recognized examples have no invented human boundaries.
All examples remain development data; no held-out or independent-validation
claim is appropriate.

## Case-by-case findings

Counts below are onset/recovery shoulders under the frozen search rules, not
biological event counts. Both branches remain visible even when the saved label
or researcher interpretation differs.

| Original example | Saved event | Declining branch | Rising branch | Main unresolved choice |
|---|---|---|---|---|
| 1 | FB2314 sink 15/36 | 3 / 1 | 2 / 3 | Preferred onset 1154 is eligible; alternative 1149 is outside the neighbor-partition search start 1151. Offset 1166 is not an exact turn; 1167 is. |
| 2 | FB2314 surge 5/1 | 5 / 7 | Unresolved seed | Mark 177 follows the exact corrected maximum at 176; recovery 195 is eligible in the declining branch. |
| 9 | FB2314 surge 1/3 | 3 / 3 | 4 / 2 | Onsets 493, 496 and 507 compete. T3 selects the higher 493; the researcher selects 496. Recovery 516 is eligible. |
| 10 | FB2314 surge 1/4 | 2 / 3 | 3 / 1 | Both 531 and 536 are eligible. T3 picks 531 because its value is slightly higher; recovery choices include 545, 552 and the marked 556. |
| 3 | ID400 sink 45/1 | 10 / 12 | 10 / 12 | Marks 297 and 312 are eligible in the declining branch; alternative 295 is not an exact eligible turn, and 313 belongs to the opposite local turn. |
| 4 | ID400 surge 4/6 | 11 / 8 | 9 / 9 | Both human boundaries 529 and 546 are eligible in the rising branch, but many other shoulders compete. |
| 5 | FB2316 KX sink 14/6 | 17 / 6 | 10 / 14 | Onset 717 is eligible in the declining branch; offset 772 is not an exact shoulder. The full marked excursion contains several fluctuations. |
| 6 | FB2316 KX surge 10/3 | 2 / 8 | 2 / 8 | Many shoulders exist despite the researcher not recognizing a surge. No human boundaries assigned. |
| 7 | HP identity pending sink 15/4 | 8 / 8 | 9 / 8 | Many shoulders exist despite the researcher not recognizing a distinct event beyond surrounding variability. No human boundaries assigned. |
| 8 | HP identity pending surge 6/3 | 35 / 15 | 25 / 25 | Human recovery 356 is eligible in the rising branch, but T3 chooses the deeper later recovery at 417. Onset 235 is not an exact eligible turn. |

For example 10, the corrected values at 531 and 536 are approximately 4.78 and
4.48. The strongest-shoulder rule therefore prefers 531 for a difference of
about 0.30 source units. That arithmetic does not establish biological meaning
for the difference. In example 9, 493 is higher than 496, while the researcher
marks the later departure. The nearest rule chooses 507, inside the wider
excursion. Neither selecting the highest nor the nearest shoulder captures
the human onset consistently.

The HP surge illustrates a separate recovery problem: a deeper later minimum
can merge the marked event with subsequent change. Selecting 356 by looking at
the human answer would not be a new independent algorithm. Recognition must
also remain separate: the presence of extrema does not distinguish the two
non-recognized examples from recognized events.

## How to read the figures

Each figure shows both directional branches, corrected intensity above the
supporting scores, and preserved raw context below. Purple circles mark all
eligible shoulders, the red diamond the frozen seed, blue squares T2 choices
and brown crosses T3 choices. Green solid/dashed lines show supplied onset/
recovery marks. Gray dotted lines mark the frozen search limits; pale dashed
lines mark native bounds. The olive dotted line in example 3 is coordinate
sensitivity only. Orange is the event-footprint filtered score; dotted gray is
the differently supported site trace. These scores are not interchangeable.

The full frozen search context plus display-only margins is shown. A human
alternative outside the search window is displayed but does not expand candidate
eligibility. This is why frame 1149 remains visible in example 1. One-based
frames use the confirmed external 1 Hz cadence; modeled seconds equal frame
minus one. Exposure duration and an adopted biological duration convention are
separate. Raw context does not add a fitted trend or amplitude baseline.

[All ten final figures](REVIEW.md) are under `review-02/`. The initial `review/` renders are
preserved; their signal identities were made explicit in each final panel title.

## Decision and next work

Three different issues must be kept separate: the allowed search window may
exclude a plausible boundary; exact local extrema may not include the supplied
sample; and multiple eligible extrema may represent one broader excursion.
Adding another score threshold does not resolve these three issues by itself.
The supporting curves sometimes emphasize a different signed feature, as already
shown in phase 052, so same-direction score-peak snapping remains unsupported.

The current evidence does **not** establish a reproducible ranking rule that
selects one physiological onset/recovery in all cases. Keep alternatives and
unresolved branches; retain production timing. No event exclusion, relabeling,
T2/T3 endpoint hybrid or global substrate-decline model follows from this audit.

The next useful implementation is to let the MATLAB reviewer retain explicit
researcher boundaries, alternatives and reasons alongside the automatic bounds,
with revision history and export provenance. That would preserve usable review
outcomes while an automatic full-excursion rule remains unresolved. It must not
silently recalculate amplitudes or replace native masks. Before a later automatic
rule is evaluated, specify how it separates within-event fluctuations from a
new excursion, handles boundaries beside a peak, and treats neighbor partitions.
Freeze that hypothesis and challenge it on all 48 existing events with both
signs and every known failure retained. Independent validation remains separate.

## Verification and scope limits

The inventory checks all 668 local extrema by an independently expressed
plateau-grouping algorithm and all 323 eligible shoulders. A serialized-output
verifier checks 10,800 source rows, 3,876 shoulder sample values, coordinates,
local differences, mark membership and finite-segment barriers. All 76 observed
saved T2/T3 boundary selections are located exactly. One rising branch remains
unresolved because the fixed native seed is not an observed peak. No seed is
moved to improve agreement.

The diagnostic reads each saved trace once for extraction; verification makes
one separate source pass. Rendering uses the exported arrays. No movie reads,
new detector or timing-candidate runs, correction fits, amplitude calculations
or production-code changes occur. Numerical extraction and two rendering passes
remain below the ten-minute runtime budget; total evidence remains below 100 MiB.
All ten final figures are visually checked. These are numerical/display checks,
not biological accuracy, a general rule or an independent researcher walkthrough.

`inventory.json`, `inputs.json`, the two verification records, source scripts,
render logs and preservation/completion records provide the audit trail.
BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain requirements. HP identity, anatomical/craniotomy
uncertainty, cohort eligibility and independent evaluation remain unresolved.
