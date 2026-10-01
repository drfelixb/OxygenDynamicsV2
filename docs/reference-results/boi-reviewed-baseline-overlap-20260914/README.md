# Saved baseline membership versus reviewed intervals

**R2-REVIEWED-BASELINE-OVERLAP-056 — bounded diagnostic complete, 14 September 2026.**
Three of the four retained baseline-candidate lists overlap their associated
reviewed interval. The fourth list is empty because the original baseline was
already unavailable. An empty intersection is therefore not evidence of a
usable baseline in that case.

| Saved event | Retained / required baseline samples | Frames inside reviewed interval | Overlap count | Retained frames strictly before reviewed onset |
|---|---:|---|---:|---:|
| Surge site 1 / event 4, 536–556 | 20/20 | 536–539 | 4 | 16 |
| Surge site 1 / event 3, 496–516 | 20/20 | 496–502 | 7 | 13 |
| Surge site 5 / event 1, 177–195 | 0/20 | None; retained list empty | 0 | 0 |
| Sink site 15 / event 36, all four alternatives | 14/20 | 1154–1155 | 2 | 12 |

The sink result is identical for onsets 1149 and 1153 and recoveries 1166 and
1167. Current preference remains frame 1153, with no preferred recovery.
[All seven interval rows](OVERLAP.md) and [exact frame lists](baseline-overlap.json)
are retained without averaging alternatives or replacing missing values.

## What was checked

The check intersects each event's saved `Traces.CleanBaselineFrames` with its
reviewed inclusive frame interval. A frame counts as overlap when it is at or
after the reviewed onset and at or before recovery. Onset samples are included
by this definition. This is a temporal membership conflict with calling the
samples entirely pre-event; it is not proof that every overlapping sample is
physiologically abnormal. The review judgments and their recognition statuses
remain `uncertain`.

The original source audit requires exactly 20 samples from the immediate
20-frame window before the **automatic measurement onset**, excluding nonfinite
raw means and overlap with saved native support of either sign on the fixed
original footprint. It does not search farther back to replace excluded
samples. “Clean” is that algorithmic condition, not established physiological
quiescence. No replacement window or reference mean was selected in this check.

Original candidate and retained lists are:

- Site 1/event 4: original candidate frames **520–539**, all 20 retained.
  Reviewed onset 536 places the last four inside the reviewed interval.
- Site 1/event 3: original candidate frames **483–502**, all 20 retained.
  Reviewed onset 496 places the last seven inside the reviewed interval.
- Site 5/event 1: original candidate frames **163–182**, with **none retained**.
  The saved audit reports 20 native-overlap exclusions and no nonfinite
  samples. Its baseline and amplitude were already unavailable. Six original
  candidates, 177–182, also lie inside the reviewed interval, but none was
  included in a baseline mean.
- Sink site 15/event 36: original candidates **1136–1155**. The 14 retained
  frames are **1136–1147 and 1154–1155**; frames **1148–1153** were excluded
  by saved native overlap. All original candidates are finite. The retained
  1154–1155 overlap every reviewed alternative. The 14-sample count was
  already insufficient for a baseline mean under the original rule.

The native-overlap exclusion cause is read from saved audit metadata. Here all
80 original candidate samples are finite, so the complement of the retained
lists equals the saved overlap-excluded count. The native detections are not
newly judged biological events by this check, and no source movie or detector
was rerun to revise those exclusions.

## Consequence for using the reviewed intervals

Simply discarding overlapping retained frames would leave **16, 13, 0 and 12**,
respectively. Each is below the unchanged 20-sample requirement. These are
set-membership counts, not newly calculated baseline values or amplitudes.
They do not answer whether a different, properly specified immediate window
before the reviewed onset would meet the existing rule.

The two finite saved baselines remain valid numerical calculations for their
original automatic windows. Their retained samples overlap the newly reviewed
intervals, so the existing amplitudes must not be silently represented as
amplitudes remeasured on the manual intervals. Their saved negative surge
amplitudes remain signed and unchanged. The other two references and
amplitudes remain unavailable; zero is not substituted. No saved `valid`
status is relabelled globally, and no partial 16-, 13- or 12-sample mean is
computed as a fallback.

Corrected intensity remains the primary timing reference. Baseline/amplitude
use the original preserved-input trace and fixed footprint. There is no extra
substrate-consumption fit, correction change, sign flip, new normalization,
post-event reference, early-window search or event acceptance rule.

## Evidence and verification

The actual researcher file is revision-file 04, SHA256
`16a99333cf9fed005fce1823fdea76161055776dde428e27c642afef0f1df26f`.
The saved audit SHA256 is
`c6ff9c10021068a659053da9be9e8a2092843c7caf19ad9ee8c14086df04776b`.
`inputs.json` binds exact snapshots of the four exported trace/receipt pairs,
the actual review, the phase-055 interval enumeration and the original baseline
implementation. The earlier phase-045 specification is retained as context:
that work examined replacement-window impacts, whereas this bounded check
asks whether the **already saved** sample lists overlap current annotations.

`checkOverlap.py` performs the source-bound intersections and writes JSON and
Markdown. `verifyOverlap.m` independently loads the actual MATLAB audit and
review. It checks all **54 retained memberships**, **80 original candidate
memberships** and **seven reviewed intervals**, including empty and partial
lists, exact exclusion sets, statuses and existing stored/audited values.
The normal reader replays original measurements only to verify preservation;
no manual-interval reference or amplitude is calculated. All original selected
measurement fields and input hashes remain unchanged.

All **476 MATLAB files** remain unchanged. The previous phase's **36 sealed
artifacts** are preserved, with standing-ledger originals snapshotted before
appending this result. This is independent arithmetic verification by MATLAB,
not independent physiological validation or cohort-level performance evidence.

## Next bounded step

Assess whether the unchanged rule finds 20 valid samples immediately before
each reviewed onset. Reuse earlier baseline-impact evidence where it matches
these exact current inputs and choices; resolve the current 1153 preference
explicitly. Report availability and exact exclusions first. Do not repair a
reference by searching earlier, shortening the requirement, changing correction,
using a post-event baseline or silently replacing an amplitude.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Native support is not
reviewed craniotomy/tissue support. Anatomical uncertainty, HP identity, cohort
eligibility, normalization policy, manual measurement adoption and the frozen
48-event timing evaluation remain separate open questions.
