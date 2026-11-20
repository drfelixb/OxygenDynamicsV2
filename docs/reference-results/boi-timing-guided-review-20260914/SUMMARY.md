# Guided event and timing review completed

14 September 2026 · R2-TIMING-GUIDED-REVIEW-044

The eight new fixed examples have received researcher judgments: **six have timing marks and two are not recognized as events**. The two earlier FB2314 annotations complete coverage of the ten-case queue; they are carried forward with their original uncertainty, not newly confirmed. This is a completed guided annotation round, not independent validation or approval of production changes.

| Example | Recording and saved detector label | Researcher judgment / onset → offset |
|---|---|---|
| 1 | FB2314 awake, sink 15/36 | 1154 → 1167; rapid decline and brief recovery peak |
| 2 | FB2314 awake, surge 5/1 | 177–178 → 195; peaks bounding decline/recovery |
| 3 | ID400 awake, sink 45/1 | 297, or alternative around 295, → 312–313 |
| 4 | ID400 awake, surge 4/6 | Recognizable surge: 529 → 546 |
| 5 | FB2316 KX, sink 14/6 | 717 → 772 |
| 6 | FB2316 KX, surge 10/3 | No visible surge; no manual boundaries |
| 7 | HP identity pending, sink 15/4 | No distinct event: brief decrease remains within surrounding variability |
| 8 | HP identity pending, surge 6/3 | Recognizable surge: 235 → 356 |
| 9, earlier anchor | FB2314 awake, surge 1/3 | Nominal 496 → 516; original later-onset/earlier-offset uncertainty retained |
| 10, earlier anchor | FB2314 awake, surge 1/4 | Nominal 536 → 556; original later-onset/earlier-offset uncertainty retained |

Numbers are retained as cited plot positions. For example 3 the researcher explicitly wrote “295 s”; the plot uses one-based frames. Preserve that wording and the alternative 297 without silently converting 295 to 296 or inventing a continuous accepted onset interval. At external 1 Hz, frame 1 corresponds to modeled elapsed time 0; the origin distinction remains to reconcile before a quantitative implementation. General biological timing is approximate and no extra uncertainty ranges were invented. Endpoint time differences and inclusive sample counts are kept distinct in the structured records.

## What the feedback supports

Recognizing an event comes before assigning its duration. The researcher did not see a surge in example 6 and judged example 7's small, brief dip insufficiently distinct from preceding and following variability. Those are event-presence disagreements with the detector, not merely missing precise boundaries. They remain visible alongside the original masks and measurements. The user attributed example 7's judgment to temporal variability; its upper-right image location is a separate unresolved anatomical issue.

In the annotated examples, the researcher uses local signal shape to mark the excursion: the turn into a pronounced decline or rise, followed by the locally judged recovery. Example 1's brief recovery peak is an acceptable case-specific offset despite an immediate subsequent dip, which could be biological. A sustained flat segment or return to a single fitted zero-reference level is therefore not required by all these judgments. Example 3 retains two plausible onsets. The HP surge 235–356 also illustrates a researcher-defined finite interval within a broader positive corrected trace.

These observations guide candidate definitions; they do not yet specify an automatic algorithm. Peak prominence, local variability reference, event separation, slow/sustained activity, absent recovery and changing spatial support remain unresolved. Do not turn the example 7 judgment into a universal minimum-duration or amplitude cutoff, suppress weak biological signals, or tune to a desired detector count. Both signs, biological variability, physiological relevance, feasibility and researcher usability remain requirements.

## Preservation and verification

Verbatim feedback is saved in feedback-01 through feedback-08 JSON files. Feedback 04 contains both the example 3 addition and example 4 annotation. Each update has preserved before/after record hashes and copies; all eight chains verify. The consolidated record matches the exact ten-case frozen review queue and binds the displayed plots by hash. Earlier anchors remain attributed to their original annotation source and date. Source code, baseline correction, production timing, detector labels, raw-source amplitudes and prior outputs are unchanged.

The earlier phase 043 first-case narrative incorrectly called recovery unresolved. The numerical evidence shows **onset censored at frame 1151** and a recovery crossing at 1166–1167. The dated correction in this packet preserves the older sealed report and its already-correct numerical results. This correction is not an additional manual annotation or algorithm change.

The packet covers three identified animals plus a provisional HP recording. It does not resolve cohort eligibility, preparation differences, anatomical support, final outcome definitions or the independent researcher release walkthrough. No model, detector, statistics, movie-processing or amplitude run occurred during this annotation round.

## Next bounded step

Audit the measurement consequences of the supplied intervals and alternatives using existing saved ingredients. Keep fixed original footprints and require 20 immediate finite pre-event samples screened against both-sign native overlap. Preserve unavailable references rather than searching earlier or borrowing recovery samples. Keep the two non-recognized candidates in the audit with their original outputs, but assign them no manual timing. Resolve the coordinate-origin ambiguity explicitly for any numerical use of example 3's alternative. Freeze candidate intervals and report baseline availability and amplitude differences before proposing a production recognition or timing rule.

Original recording-specific correction remains the starting reference. No substrate-decay mechanism is assumed, and no production policy has been adopted.
