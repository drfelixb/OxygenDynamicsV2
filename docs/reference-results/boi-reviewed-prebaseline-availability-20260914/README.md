# Immediate prebaseline availability at reviewed onsets

**R2-REVIEWED-PREBASELINE-057 — bounded diagnostic complete, 14 September 2026.**
The unchanged sample rule admits all 20 immediate pre-onset samples for the
two site-1 surge examples. It admits none for surge site 5/event 1, and fewer
than 20 for either sink onset. No baseline means or amplitudes were calculated,
no original results were overwritten, and no onset was selected for better
baseline availability.

| Saved event / reviewed onset | Candidate frames | Eligible / required | Native-overlap exclusions | Complete under existing sample rule? |
|---|---|---:|---|---|
| Surge site 1/event 4 — 536 | 516–535 | 20/20 | None | Yes; shared reviewed endpoint at 516 flagged below |
| Surge site 1/event 3 — 496 | 476–495 | 20/20 | None | Yes |
| Surge site 5/event 1 — 177 | 157–176 | 0/20 | 157–176, all 20 | No |
| Sink site 15/event 36 — preferred 1153 | 1133–1152 | 15/20 | 1148–1152, five frames | No |
| Same sink — alternative 1149 | 1129–1148 | 19/20 | 1148, one frame | No |

All 100 candidate sample memberships have finite preserved-input values.
Every exclusion above is due to the saved native-support rule. These are five
unique onset windows for the seven currently reviewed intervals; offset 1166
versus 1167 does not change the pre-onset window. The preferred sink onset
remains the explicitly confirmed frame 1153. Its poorer numerical sample
availability than alternative 1149 does not justify changing that preference.
Earlier frame 1154 is not added to current alternatives.

## Exact rule and claim limits

For reviewed onset `a`, candidates are exactly frames `a-20` through `a-1`.
A sample is eligible if its saved preserved-input mean is finite and its event's
original fixed footprint intersects no saved native mask of **either sign**
at that frame. All 20 samples must survive. There is no search farther back,
replacement of excluded frames, shorter mean, post-event reference or new
correction. External sampling is exactly 1 Hz; embedded timestamps and camera
exposure duration are not substituted.

“Complete” here means the existing **sample eligibility criterion** is met.
It does not establish physiological quietness, approve a new reference,
establish event recognition, or by itself validate an amplitude. Raw means
are the original amplitude-source signal; corrected intensity remains primary
for reviewing timing and scores supporting. Original per-recording correction
is preserved without an added substrate-consumption model.

The preceding phase checked the old baseline lists without relocating their
windows. This phase instead evaluates the originally specified immediate
window relative to each **reviewed** onset. That explains why the two site-1
examples now have 20 candidates, rather than the 16 and 13 remaining after
simply discarding old-list overlaps. No samples were silently appended to the
old baseline, and these candidate windows have not replaced any saved reference.

## Shared endpoint at frame 516

The candidate window before onset 536 begins at **516**, which is also the
preceding site-1/event-3 reviewed recovery frame. This sample is eligible under
the saved native rule: that preceding event's native run ended at 514. The two
fixed native-union footprints share **9,614 pixels** (out of 11,565 for event 4
and 10,951 for event 3), so their trace supports overlap spatially.

This is a reviewed endpoint contact on shared fixed supports, not a claim
that a native mask exists at frame 516 or that all those pixels remain part of
a physiological event there. The researcher chose a recovery peak; whether
that endpoint is acceptable as pre-event reference context remains a scientific
question. It was **flagged, not excluded**. No new manual-overlap exclusion
rule was applied and the old-rule result remains 20/20.

`availability.json` contains each exact candidate, eligible and excluded frame
list, preferences, prior-result associations and temporal flags.
`verification.json` records the independent mask-based result and the spatial
intersection supporting the frame-516 flag. Neither file contains a new
baseline mean or amplitude.

## Reuse and verification

Earlier phase-041/045 results already contain the exact 536–556 and 496–516
anchors with 20 eligible samples, and the 177–195 example with zero. Those
availability results were reused and checked for agreement; their historical
amplitude calculations were neither repeated nor adopted here. Two current
sink-onset checks, 1149 and 1153, are not present in the referenced phase-045
result tables. Earlier 1154 results remain separate historical evidence.

The cached native union and relevant inputs match the phase-045 frozen hashes.
The replay MAT checksum is
`20e139ccc8df31213efa91caeeeb4b2c650383290d012b22fcf9391477fedaef`.
`prior-input-binding.json` records four matching frozen inputs, including the
replay file, event metadata and two trace exports. Current input paths/hashes
and snapshots are in `inputs.json`. The 9 MiB replay cache remains at its
original location; the portable report references it by path/hash rather than
duplicating it. Mask-based rerunning requires that cache and the original audit.

`checkAvailability.py` reads the saved trace/overlap exports and writes the
five-window diagnostic. `verifyAvailability.m` independently loads the
actual audit and the complete cached native union, intersects the original
footprints with that union at every frame, and verifies:

- **4,800 raw samples exactly** against the current audit and the four exact
  footprint sets; decimal CSV raw values agree within the recorded tolerance.
- **4,800 native-overlap flags** against direct mask intersections.
- All four original saved baseline memberships under the same rule.
- All **100 candidate sample memberships** across the five current onset
  windows, including exclusions and nonfinite checks.
- The frame-516 temporal contact and the 9,614-pixel shared fixed support.

The current review SHA256 is
`16a99333cf9fed005fce1823fdea76161055776dde428e27c642afef0f1df26f`;
the audit SHA256 is
`c6ff9c10021068a659053da9be9e8a2092843c7caf19ad9ee8c14086df04776b`.
Both and the native cache remain unchanged. No movie, detector, statistics,
correction fit, baseline mean or amplitude calculation was run. All **476
MATLAB source files** remain unchanged, and the preceding phase's **50 sealed
artifacts** are preserved, with standing-ledger snapshots taken before append.

This is numerical and provenance verification from saved ingredients, not
independent physiological validation or a cohort-wide performance claim.
All four researcher recognition statuses remain `uncertain`; saved labels,
negative/unavailable original amplitudes and unresolved anatomy are preserved.

## Next bounded step

Identify and inspect the saved detections responsible for the excluded baseline
samples, and examine the shared reviewed endpoint at frame 516. Use corrected
traces, local variability and spatial support to inform that review; do not
automatically call exclusions false positives, remove native detections or
relax the 20-sample rule to make an amplitude available. Keep both signs,
non-recognized cases and earlier failures. Any altered exclusion/reference
policy needs a separate explicit scientific proposal and evaluation.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Craniotomy/FOV
uncertainty, reviewed tissue support, HP identity, cohort eligibility,
normalization policy, manual measurement adoption and the frozen 48-event
timing evaluation remain separate open questions.
