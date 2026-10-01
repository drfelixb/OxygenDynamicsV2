# Native contributors to reviewed prebaseline exclusions

14 September 2026. **R2-BASELINE-EXCLUSION-REVIEW-058 — bounded inspection
complete.** Three saved surge events account for every native exclusion in the
five candidate windows from phase 057. The attribution is exact; physiological
recognition and baseline acceptance remain unresolved. No detector, correction,
baseline, amplitude, native mask, or researcher annotation was changed.

This is FB2314 awake, the same 1,200-frame development recording and saved
restricted support used in the preceding phases. Frames are one-based at the
externally triggered 1 Hz: modeled elapsed seconds = frame − 1. Embedded image
timestamps are not used; exposure remains distinct. This inspection is neither
a new animal nor independent evaluation.

## Exact contributors

Each exclusion is an intersection between a contributor's native pixels at that
frame and the **target event's fixed union footprint**. It is not a requirement
that the target's own native event already be active. Both signs were searched.
Only saved surge events contribute to these particular excluded windows.

| Reviewed target / onset | Candidate frames | Saved contributor | Excluded frames | Intersecting pixels per frame / target footprint |
|---|---|---|---|---|
| Surge site 1/event 4, row 309 / 536 | 516–535 | None | None | 0 / 11,565 |
| Surge site 1/event 3, row 308 / 496 | 476–495 | None | None | 0 / 10,951 |
| Surge site 5/event 1, row 321 / 177 | 157–176 | Surge site 4/event 1, row 320; native 154–165 | 157–165 | 2,254–2,708 / 5,086 (44.3–53.2%) |
| Same target / 177 | Same window | Surge site 2/event 2, row 315; native 166–182 | 166–176 | 2,215–3,157 / 5,086 (43.6–62.1%) |
| Sink site 15/event 36, row 186 / preferred 1153 | 1133–1152 | Surge site 1/event 7, row 312; native 1148–1174 | 1148–1152 | 345, 277, 203, 120, 93 / 348 (99.1% down to 26.7%) |
| Same sink / alternative 1149 | 1129–1148 | Same surge, row 312 | 1148 | 345 / 348 (99.1%) |

The unchanged eligible counts therefore remain **20, 20, 0, 15, and 19** for
onsets 536, 496, 177, preferred 1153, and alternative 1149. All candidate raw
samples are finite, as verified in phase 057. No earlier search, shortened
reference, partial mean, post-event reference, or new substrate model is used.
Preferred onset **1153 remains intentional**, with 1149 retained as an
alternative; availability is not a reason to change the preference. Recovery
choices remain 1166/1167 without a preferred value.

## Corrected traces and spatial inspection

These are assistant observations of saved evidence, not new researcher
annotations or automated recognition decisions. Corrected intensity is the
primary panel, the two saved scores provide supporting context, and preserved
input/removed trend provide correction QA. The orange event-footprint score
and dotted gray site score retain their different supports and processing.
All axes retain their own original scales. No new curve was fitted.

**Before onset 177:** the corrected target and contributor traces fluctuate
substantially and show a rise toward the 172–177 region before the reviewed
decline. The two contributor IDs occupy successive parts of the candidate
window; their identity alone does not establish two separate physiological
events. The illustrated native intersections cover 53.2% and 62.1% of the
target footprint, rather than only a few boundary pixels. Recognition,
event separation, and whether these fluctuations constitute an acceptable
optical reference remain open.

![Corrected traces for onset 177 and its two exclusion contributors](onset-177-traces.png)

![Native spatial overlap before onset 177](onset-177-spatial.png)

Spatial frames 164 and 172 were selected as each contributor's maximum
intersection **within the candidate window**, solely to make the existing
overlap visible. The complete frame lists and counts are exported; the images
are not an unbiased selection of typical morphology. Full 512 × 512 maps retain
source coordinates. The lower detail views are display zooms, not new analysis
ROIs, anatomical boundaries, or corner exclusions.

**Before preferred onset 1153:** the small sink footprint has 348 pixels; the
overlapping surge's fixed union has 16,936. The surge's native mask covers almost
the entire sink footprint at 1148 and retreats to 93 pixels by 1152. These
first/last excluded frames are shown explicitly. Corrected intensity varies
and declines in this region even though the contributor carries the saved
surge label and a positive filtered score. This is not evidence for a local
physiological increase. The existing normalization audit already demonstrated
that local intensity direction and a spatially referenced detection label can
differ for other events in this recording; this phase does **not** claim a new
pixel-level normalization decomposition for row 312.

![Corrected traces for the sink and overlapping saved surge](onset-1153-traces.png)

![Native overlap contracts across the small sink footprint](onset-1153-spatial.png)

**Shared frame 516:** the preceding reviewed interval ends at 516; its native
run ends at 514. The following event's candidate window starts at 516. At that
frame, native overlap is exactly zero across both signs, while the two fixed
footprints share 9,614 pixels (83.1% of row 309; 87.8% of row 308). Both corrected
footprint traces have a local maximum at 516 relative to 515 and 517, followed
by further variation within 516–535. This is consistent with the user's
recovery-peak marking. It neither proves contamination nor establishes a
physiologically quiet plateau. The existing rule still counts all 20 samples.
No new manual-overlap exclusion or amplitude is adopted.

![Shared recovery endpoint and candidate reference window](shared-516-traces.png)

![Fixed footprint overlap is distinct from occupancy at frame 516](shared-516-spatial.png)

## Verification and traceability

- MATLAB reconstructs the complete both-sign native union directly from the
  two saved master site tables for every candidate membership and checks exact
  agreement with the frozen phase-043 cache: five windows, 100 memberships.
- Every positive intersection maps to exactly one saved recording/sign/site/event
  identity. There are 26 contributor memberships, representing 25 distinct
  target/frame exclusions because frame 1148 appears in both sink windows.
- The existing native-mask attachment validator independently checks seven
  involved events: four targets and three contributors. Analysis metadata,
  recording/event identity, original measurement/baseline/status, native run,
  frame grid and union footprint all match the actual audit. The event-specific
  mask intersections match the direct site-table attribution exactly.
- This legacy audit did not record the master checksums at creation. Their
  current hashes and checked associations are captured now; historical checksum
  provenance is not invented. Original audit, review, cache and master hashes
  are verified before and after the diagnostic.
- Full 1,200-frame saved stages for all seven events, native masks and exact
  intersection pixel sets are retained in `inspection-evidence.mat`; trace CSVs
  provide readable values. No raw movie reread, new detection or correction fit
  was needed. Existing helper checks replay original measurements only.
- Six figures were visually inspected. The first rendering crowded the adjacent
  1166/1167 labels; it and its renderer/log are retained in `render-01`. Final
  labels are separated vertically without moving any frame.
- The 476 existing MATLAB source files, original four human annotations and
  all 48 sealed phase-057 artifacts are preserved. The two standing ledgers'
  previous bytes are retained under `before-standing-docs` before appending this
  phase. Detailed checks are in `preservation.json` and `verification.json`.

`contributors.json` contains exact event identities and per-frame intersections;
`frame-overlap.csv` retains all 100 candidate memberships, including eligible
ones; `event-contributions.csv` lists positive contributor memberships.
`inputs.json` binds input paths, hashes and small source snapshots. The executed
diagnostic and rendering scripts, logs and exact MAT evidence are in workspace
`reference-validation/boi-baseline-exclusion-review-20260914`. Portable MATLAB
source copies use `.m.txt` to avoid adding diagnostic runners to the production
MATLAB inventory. `artifact-record.json` and `completion.json` seal this phase.

## Disposition and next work

This closes attribution and inspection, not baseline-policy selection. There is
no demonstrated indexing or mask-association defect behind these exclusions.
The three contributing detections are not automatically rejected, relabeled or
removed to restore reference availability. Unavailable measurements remain
unavailable; all recognition statuses remain `uncertain`.

Next is a concrete baseline-policy proposal for manually reviewed events,
distinguishing native sample eligibility, physiological reference suitability,
and the separately retained original automatic measurement. Any proposed
exception for overlapping detections or recovery endpoints needs a scientific
rationale and bounded impact assessment before adoption. No further threshold
or boundary search is justified by this diagnostic alone.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Anatomical support,
normalization, recognition, cohort eligibility and independent evaluation
questions remain open. The wider 48-event timing evaluation and non-recognized
cases remain preserved; these guided examples cannot establish generalization.
