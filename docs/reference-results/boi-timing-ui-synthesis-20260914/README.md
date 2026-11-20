# Four timing-view reviews: comparison and next method question

R2-TIMING-UI-SYNTHESIS-052, 14 September 2026. The four follow-up judgments
are compared with frozen saved measurements and phase 047 candidates. All are
previously inspected events in **one FB2314 awake recording**. They are not four
animals, a representative cohort, or independent validation.

## Current annotations

| Saved event | Current onset | Current offset | Saved measurement bounds |
|---|---|---|---|
| Sink 15 / 36, audit 186 | 1154 preferred; 1149 alternative | 1166 or 1167 | 1156–1165 |
| Surge 5 / 1, audit 321 | 177 | 195 | 183–193 |
| Surge 1 / 3, audit 308 | 496 | 516 | 503–514 |
| Surge 1 / 4, audit 309 | **536** | 556 | 540–552 |

The onset entry 526 was explicitly corrected to 536 and is excluded from the
current comparison. It remains in the revision history. Earlier uncertainties,
including 177-or-178 and the two anchors' operational envelopes, remain in the
original records. The table distinguishes latest nominal choices from earlier
uncertainty; it does not declare that uncertainty withdrawn. No unstated timing
tolerance is introduced. Case 1's alternatives remain discrete, not every frame
between 1149 and 1154.

Coordinates are one-based recording frames. At the external 1 Hz cadence,
modeled elapsed time is frame minus one; exposure is separate. These comparisons
do not adopt a duration convention or modify any baseline, mask or amplitude.

## Comparison with the existing candidates

T2 selects the nearest eligible corrected-trace shoulders around the native
seed; T3 selects the strongest shoulders within the same frozen search limits.
The following table is the **declining corrected-signal branch**, not a relabeling
of the three saved surges or an automatic choice of branch from the human answer.

| Saved event | T2 interval | T3 interval | T3 onset relative to latest preferred/nominal onset |
|---|---|---|---|
| Sink 15 / 36 | 1160–1167 | 1154–1167 | Same; 1149 remains a human alternative |
| Surge 5 / 1 | 176–189 | 176–195 | 1 frame earlier |
| Surge 1 / 3 | 507–513 | 493–516 | 3 frames earlier |
| Surge 1 / 4 | 536–545 | 531–556 | 5 frames earlier |

T3 reaches a supplied offset in all four examples, but it is not a complete
timing solution. T2 often stops inside the marked excursion. A hybrid that
chooses whichever T2/T3 endpoint agrees best would use the reference answers
to construct the method; no such hybrid is adopted.

The rising corrected-signal branch also remains visible:

| Saved event | T2 rising branch | T3 rising branch |
|---|---|---|
| Sink 15 / 36 | 1156–1159 | 1156–1163 |
| Surge 5 / 1 | Unresolved: seed not bracketed peak | Unresolved: seed not bracketed peak |
| Surge 1 / 3 | 508–514 | 508–521 |
| Surge 1 / 4 | 546–553 | 544–553 |

`current-reviews.json` retains all 16 frozen candidate rows and their context
statuses. `candidate-comparisons.json` contains 28 signed endpoint comparisons
against all seven current supplied interval combinations, with unresolved
branches unavailable rather than zero. Differences are descriptive, not accuracy
classes or a method-selection score. Candidate amplitudes are historical copied
values only; no amplitude was recalculated for the latest marks.

## What the signal evidence supports

The selected anchor offsets, 516 and 556, are local maxima in corrected intensity
but local minima in **both** supporting score curves. This is directly verified
from each selected sample and its immediate neighbors. Score support cannot
therefore be reduced to snapping the boundary to a same-direction score peak.
It does not establish that a score trough is a general recovery rule either.

For the first case, 1149 and 1154 are separate local corrected maxima. The
researcher prefers 1154 and retains 1149 as plausible. A unique onset based only
on the existence of a local turn is not established. The chosen onset 177 in
the second case follows corrected frame 176, whose value is slightly higher
(898.752 versus 898.460 source units). No tolerance that turns them into a
numerically flat plateau is fitted or assumed. The researcher did not supply
a new rationale for this short reply.

The exact three-sample neighborhoods are in `endpoint-neighborhoods.json`:
10 boundary locations × 3 signals × 3 samples = 90 serialized values. They are
copied without smoothing, interpolation, new extrema searches or baseline fits.
The values support corrected-primary and score-supporting review while retaining
ambiguity about which fluctuation begins the full excursion.

The previous wider-panel failures remain binding: the recognized ID400 rise and
long HP surge are not resolved by agreement on these four FB2314 offsets. In the
prior HP surge, T3's rising branch ended at 417 versus the researcher's 356.
The two previously non-recognized examples remain in the challenge set. The
range screen also fails or changes with context length for recognized examples;
it is not adopted as an acceptance threshold. Prior analyses and scientific
questions are not reset by this follow-up review.

## Decision and verification

Retain production timing and the corrected-primary signal hierarchy. The next
bounded method step is an **onset-and-recovery ambiguity diagnostic**, specified
in [NEXT-STEP.md](NEXT-STEP.md). It should expose why alternative corrected
shoulders are selected and what the scores contribute before a ranking rule is
proposed. This phase does not implement that diagnostic or adopt a new method.

The comparison verifies four current event identities, all 28 endpoint
differences, all 90 copied sample values, the corrected 536 onset, linked input
hashes and all 32 earlier feedback artifacts. Every MATLAB implementation file
remains unchanged. No detector, timing candidate, correction or amplitude rerun
occurred. `verification.json`, `inputs.json` and `completion.json` record the
checks; prior standing documents are preserved before their append-only update.

BOI-only scope, both saved signs, biological variability, physiological relevance,
feasibility, usability and traceability remain requirements. Anatomical/craniotomy
uncertainty, HP identity, cohort eligibility, full-excursion criteria and
independent evaluation remain open. No substrate consumption model is inferred.
