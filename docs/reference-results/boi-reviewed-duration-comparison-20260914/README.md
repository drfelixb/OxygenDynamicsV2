# Reviewed versus automatic durations

**R2-REVIEWED-DURATIONS-055 — bounded diagnostic complete, 14 September 2026.**
The four actual researcher entries are compared with their saved automatic
measurement bounds and native detection bounds. All seven combinations of
explicitly saved alternatives are retained. This changes no measurement,
production code, dictionary definition or scientific acceptance status.

## Main result: elapsed time between endpoint samples

| Saved event | Automatic measurement span (s) | Reviewed span (s) | Increase (s) |
|---|---:|---:|---:|
| Surge site 1 / event 4 | 12 | 20 | 8 |
| Surge site 1 / event 3 | 11 | 20 | 9 |
| Surge site 5 / event 1 | 10 | 18 | 8 |
| Sink site 15 / event 36, preferred onset 1153 | 9 | 13 or 14 | 4 or 5 |
| Same sink, alternative onset 1149 | 9 | 17 or 18 | 8 or 9 |

These spans use `(last frame - first frame) / Hz`. The sink's possible spans
are the discrete set **13, 14, 17, 18 s**, not every value in a continuous
13–18 s interval. Neither offset is preferred, so there is no single preferred
duration or justified midpoint. The current preferred onset is the explicitly
confirmed **frame 1153**; earlier 1154 is retained in historical evidence and
is not inserted into the current choices.

The three saved surge events have equal native and measurement bounds. The
sink differs: native frames 1157–1164 span **7 s**, whereas measurement frames
1156–1165 span **9 s**. Compared with native detection, the preferred manual
onset gives **6 or 7 s** extra; the alternative onset gives **10 or 11 s** extra.
The full [comparison tables](COMPARISON.md) and [structured record](duration-comparison.json)
retain both references, endpoint shifts, counts, modeled times and preferences.

## The one-frame convention is separate from the boundary change

BOI-M04 in the existing dictionary 0.3.0-draft defines duration as
`(EndFrame - StartFrame + 1) / SampleF`. Current MATLAB finalization stores the
same inclusive frame count and duration. Its half-open nominal support is
`[(StartFrame-1)/Hz, EndFrame/Hz)`. This convention remains unchanged.

The interval from frame 536 to frame 556 illustrates the distinction:

- Frame 536 is modeled time 535 s; frame 556 is modeled time 555 s.
- Elapsed time between those endpoint samples is **20 s**.
- There are **21 included frames**; using the existing inclusive convention
  gives **21 s**, with nominal support `[535, 556)` s.
- The saved automatic bounds 540–552 have a **12 s** endpoint span and
  **13 included frames**, corresponding to **13 s** under the existing convention.
- The reviewed interval is **8 s longer under either convention**, when both
  sides use the same convention. Comparing manual span 20 with automatic
  inclusive duration 13 would incorrectly give 7 rather than 8.

At the confirmed external 1 Hz clock, all count-based durations are exactly
one second greater than their endpoint spans. Counts and seconds remain
separate quantities in the artifact. Nominal frame support does not establish
camera exposure length or subframe physiological onset/recovery. Embedded
recording timestamps are not substituted.

For the sink, preferred-onset spans 13/14 s correspond to counts 14/15 and
inclusive-convention durations 14/15 s. The alternative onset produces spans
17/18 s, counts 18/19 and inclusive-convention durations 18/19 s. The saved
measurement uses 10 frames/10 s; native detection uses 8 frames/8 s. No value
here overwrites an event table's saved duration or converts manual bounds into
native mask occupancy.

## Interpretation and limits

All four reviewed intervals extend earlier and later than their saved
measurement bounds. Across the seven combinations, onset moves 3–7 frames
earlier and offset 1–4 frames later. These are guided examples from one
recording/animal; they do not establish an unbiased duration error distribution,
a universal expansion rule, a detector threshold or cohort-level biology.
Saved surge labels are retained even where the researcher describes a decline.
All four recognition statuses remain `uncertain`. No recognition or eligibility
is promoted by successful arithmetic verification.

Corrected intensity remains primary, scores supporting and raw intensity a
correction-quality check. The original per-recording correction and baseline
are retained, without an extra substrate-consumption model. Manual intervals
do not change amplitudes, baseline membership, signed fractions, native masks,
area-time measures or composite burdens. No missing value is replaced by zero.

## Source and verification record

The input is the actual `BOI-researcher-review-04.json` saved by Felix, SHA256
`16a99333cf9fed005fce1823fdea76161055776dde428e27c642afef0f1df26f`.
It binds to the representative saved audit SHA256
`c6ff9c10021068a659053da9be9e8a2092843c7caf19ad9ee8c14086df04776b`.
`inputs.json` gives paths, checksums and exact input snapshots, including the
1153 clarification and current dictionary/duration implementation. Raw-source
identity is inherited from the verified audit; no source movie reread is
required for frame arithmetic.

`compareDurations.py` creates JSON and Markdown using only the saved choices
and interval bounds. `verifyDurations.m` independently loads the actual audit
and review in MATLAB. It verifies **4 events, 7 human intervals, 8 automatic/
native intervals and 127 human sample memberships** using the saved frame
membership and modeled-time vectors, including the complete alternative
Cartesian product and both difference references. All previous measurement
fields remain exactly unchanged when annotations are attached. Original audit
and review checksums remain unchanged. All **476 MATLAB source files** are
preserved, and the previous W4 record's **124 sealed artifacts** remain
preserved, including snapshots of standing ledgers before appending this result.

The independent MATLAB arithmetic check is developer verification, not
independent physiological validation. The definition of manual duration for
released analyses remains an explicit policy question; this diagnostic does
not change BOI-M04 or the measurement dictionary version.

## Next bounded step

Check whether the currently saved prebaseline samples overlap any of these
reviewed intervals. Reuse the earlier baseline diagnostics and focus on the
actual saved choices, including the confirmed 1153 onset; retain both the
old reference and any incompatibility flags without recalculating amplitudes.
A later policy for measuring amplitude on manual intervals must state its
baseline, signal and support explicitly before adoption. Automatic timing
ranking and the frozen 48-event evaluation remain separate unresolved work.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Craniotomy/FOV
uncertainty, tissue support, HP identity, cohort eligibility, normalization and
independent-validation requirements remain open.
