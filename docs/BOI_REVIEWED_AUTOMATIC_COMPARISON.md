# Original and researcher-reviewed optical measurements

15 September 2026 · R2-REVIEWED-AUTOMATIC-COMPARISON-069

The four guided FB2314 awake/immobile examples now have a source-bound
comparison of their original automatic measurements and the separate
researcher-reviewed optical preview. This is a descriptive development check.
Both reference membership and event bounds changed; their individual effects
have not been isolated. No automatic measurement or scientific policy changed.

## What changed

All bounds below are **recording frames**, inclusive. External triggering is
exactly 1 Hz: frame 1 is modeled elapsed time 0 seconds. Sample-count duration
is `(last-first+1)/Hz`; elapsed endpoint span is one second shorter here.

| Saved identity / audit row | Original measured interval | Reviewed interval | Original → reviewed duration | Accepted reference |
|---|---|---|---|---|
| Sink site 15/event 36 / 186 | 1156–1165 | 1154–1166 or 1167 | 10 → 13 or 14 s | 1134–1153, 20 samples |
| Surge site 1/event 4 / 309 | 540–552 | 536–556 | 13 → 21 s | 516–535, 20 samples |
| Surge site 1/event 3 / 308 | 503–514 | 496–516 | 12 → 21 s | 476–495, 20 samples |
| Surge site 5/event 1 / 321 | 183–193 | 177–195 | 11 → 19 s | 165–176, 12 samples |

Row 186 retains the alternative onset 1149, with both recoveries 1166 and
1167, giving 18 or 19 sample-count seconds. No reference has been accepted for
1149, so both alternative optical results remain unavailable. Onset 1154 is
preferred; neither recovery is preferred. The native sink bounds 1157–1164
are distinct from its original measured bounds 1156–1165.

## Optical results

Both methods use the same preserved-input mean over each event's original,
fixed native union footprint. For each available result, the reference mean
is B and the signed fractional trace is `(input-B)/B`. The corrected intensity
trace remains the primary recognition/timing/reference-context view; it is
not substituted for the optical denominator. The filtered score supports
inspection, and the raw/trend view supports correction QA.

| Audit row | Original → reviewed B, input units | Original → reviewed signed minimum | Original → reviewed saved-sign amplitude |
|---|---|---|---|
| 186, onset 1154 | unavailable → 3791.7652 | unavailable → −17.7058% | unavailable → +17.7058% |
| 309 | 1857.9871 → 1866.5308 | −7.9420% → −8.3634% | −0.9830% → +1.0196% |
| 308 | 1998.3357 → 2006.2259 | −9.1645% → −9.5218% | −2.0645% → +1.0779% |
| 321 | unavailable → 5137.8256 | unavailable → −14.1681% | unavailable → +6.0209% |

The available original reference means rise by 0.4598% (309) and 0.3948%
(308). Their signed minima change by −0.4214 and −0.3572 percentage points.
These are direct differences under the two complete definitions, not estimates
of the reference-only effect. Signed rectangle-sum integrals change from
−0.617194 to −0.726814 fraction-seconds (309) and from −0.739801 to −0.883177
fraction-seconds (308). Longer intervals and changed references both enter
these comparisons.

**The saved-sign amplitude is a different quantity from the signed minimum.**
The sink convention uses minus the minimum; the surge convention uses the
maximum. Thus a saved surge can have a negative downward minimum and a
positive saved-sign amplitude. The positive reviewed maxima do not establish
biological surge identity. Original negative surge amplitudes are retained,
with no absolute-value repair, clipping or relabeling.

For row 186, the two accepted-reference integrals are −1.128851
fraction-seconds through 1166 and −1.104194 through 1167. Adding frame 1167
adds a positive sample; signed integrals need not become more negative with
longer duration. Row 321's reviewed integral is −0.960803 fraction-seconds.
Neither row has an original valid B, amplitude or integral: their numerical
differences remain missing, never zero.

## Why reference and timing cannot be interpreted independently here

The original rule retained 14/20, 20/20, 20/20 and 0/20 candidate samples for
rows 186, 309, 308 and 321 respectively. It required all 20 for a valid mean,
so rows 186 and 321 have no original optical measurement. The partial 14
retained candidates are not averaged to manufacture an original result.

Some original retained reference candidates fall inside the newly reviewed
event intervals: frames 1154–1155 for row 186, 536–539 for row 309 and 496–502
for row 308. These overlaps are 2, 4 and 7 samples. Row 321 has no original
retained samples; its original candidate window nevertheless overlaps the
reviewed interval at 177–182. The comparison retains exact frame lists.

The reviewed references are explicit local judgments. Their native-eligible
counts are 14/20, 20/20, 20/20 and 0/12 respectively. In particular, accepting
165–176 gives 12 complete researcher-selected samples; it does not satisfy or
change the original 20-sample/native-exclusion rule. Native eligibility alone
does not define physiological quietness. The preceding pocket around 155–165
and the accepted boundary sample 165 remain contextual observations.

![Original and reviewed reference frames and bounds](reference-results/boi-reviewed-automatic-comparison-20260915/run-01/reference-boundary-comparison.png)

The figure shows preserved-input intensity for measurement inspection. Blue
circles and blue dashed means show the accepted references. Gray squares show
original retained candidates; gray dashed means appear only for valid original
references (rows 309 and 308). Gray dotted vertical lines are original measured
bounds; purple lines are reviewed bounds. The sink panel shows the preferred
onset and both recovery alternatives. All seven combinations are in the tables.

## Verification and limits

MATLAB replay verified all four identities, fixed footprints and raw traces
against the audit and pinned exports. Original reference means and directional
amplitudes were checked against the sink/surge masters. Replayed original
signed means and integrals also matched the saved master fields, including
missing values. All seven saved combinations were checked: five have computed
reviewed results, two lack an accepted reference, and only two have optical
results on both sides. The figure was visually inspected.

The [evidence packet](reference-results/boi-reviewed-automatic-comparison-20260915/README.md)
contains exact samples, source hashes, MATLAB runner, numerical tables,
machine-readable comparisons, verification and preservation records. All 485
existing MATLAB files and 613 sealed phase-068 artifacts are preserved.

These four examples support local calculation traceability and guided use.
They do not establish detector improvement, biological recognition, equal
precision across reference lengths, a universal baseline duration, resting
oxygen, cohort eligibility or independent validation. All saved recognition
statuses remain uncertain. No substrate model or correction was changed.

Next is to specify a separate transfer check on additional BOI recordings,
retaining the corrected trace, recording-specific variability, native context
and explicit reference/timing judgments. The existing 48-event timing challenge
remains relevant to any later timing or detector change. BOI-only scope,
biological variability, physiological relevance, feasibility, usability,
traceability and all unresolved scientific questions remain standing requirements.
