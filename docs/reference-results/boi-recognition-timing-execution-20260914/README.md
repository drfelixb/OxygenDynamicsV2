# Fixed candidate comparison: neither rule is ready for production

14 September 2026 · R2-RECOGNITION-TIMING-EXECUTION-047 · numerical comparison verified

**Nearest turning points tend to select a small fluctuation; strongest shoulders can extend too far.** The fixed comparison demonstrates both behaviors on the researcher's examples. Neither candidate provides a sufficiently explained general onset/recovery rule from these development cases. Keep production rules unchanged and defer adoption; do not launch an automatic parameter search.

## Concrete matches and failures

- In example 1, strongest shoulders on the decline branch give **1154–1167**, matching the supplied marks. The nearest-turn rule starts at **1160**, selecting only the final part of the decline. A brief recovery peak is representable without requiring sustained flat recovery.
- In example 3, nearest turns give **307–310**, while strongest shoulders give **283–312**. The researcher marked onset 297 or around 295, offset 312/313. One candidate captures a short fluctuation and the other starts well before either marked onset; matching the latter's offset does not validate its onset. Frame 296 remains only the explicit elapsed-time sensitivity.
- In example 4's recognized surge, the rise branch gives **535–538** or **507–556**, versus **529–546**. Both context scales fail the proposed range screen for both candidates, despite the researcher's recognition of this event.
- In example 5's decline, strongest shoulders give **714–773**, compared with **717–772**; nearest turns give **770–773**. The broader candidate includes 17 directional local peaks. Those are trace fluctuations, not 17 established biological events.
- In example 8's recognized HP surge, strongest shoulders give **233–417**, compared with **235–356**. They extend recovery **61 frames** beyond the marked offset and include 49 directional local peaks. The nearest candidate gives **311–318**. Passing the variability screen for the broad interval cannot establish the correct recovery.
- For example 7's non-recognized HP dip, strongest decline shoulders give **217–236**. This candidate passes the 10-sample context screen but fails the 20-sample screen. The signal's apparent distinctness depends on the chosen context, and the rule does not consistently reproduce the researcher's judgment. Example 6, which the researcher did not recognize as a surge, fails the screen at both scales in both branches/candidates.
- The earlier anchors remain mixed: strongest decline shoulders give **493–516** and **531–556**, with recovery matching nominal marks but onset preceding their retained ranges. Nearest turns shorten both excursions. No branch or alternative is selected automatically to improve agreement.

These are descriptive comparisons to approximate development annotations, not accuracy estimates or exact physiological ground truth. The frozen search limits, native seed, fixed footprint and original correction contribute to the results; this comparison does not isolate which assumption is responsible for a mismatch.

## All ten reviewed examples

Both directional branches are shown regardless of the saved label or the manual interpretation. T2 means nearest observed turning points; T3 means strongest shoulders within the same saved search bounds. A rise/decline branch does not relabel the event.

| Example and saved identity | Researcher marks/judgment | T2 decline | T3 decline | T2 rise | T3 rise |
|---|---|---|---|---|---|
| 1 · FB2314-awake · sink 15/36 | 1154–1167 | 1160–1167 | 1154–1167 | 1156–1159 | 1156–1163 |
| 2 · FB2314-awake · surge 5/1 | 177/178–195 | 176–189 | 176–195 | seed not bracketed peak | seed not bracketed peak |
| 3 · ID400-awake · sink 45/1 | 295 or 297–312/313; 296 sensitivity | 307–310 | 283–312 | 306–308 | 300–308 |
| 4 · ID400-awake · surge 4/6 | 529–546 | 539–543 | 537–571 | 535–538 | 507–556 |
| 5 · FB2316-KX · sink 14/6 | 717–772 | 770–773 | 714–773 | 742–744 | 720–771 |
| 6 · FB2316-KX · surge 10/3 | No surge recognized | 197–203 | 197–203 | 198–206 | 198–228 |
| 7 · HP-ECS-identity-pending · sink 15/4 | No distinct event recognized | 221–226 | 217–236 | 225–227 | 196–229 |
| 8 · HP-ECS-identity-pending · surge 6/3 | 235–356 | 360–368 | 316–383 | 311–318 | 233–417 |
| 9 · FB2314-awake · surge 1/3 | 496–516, original uncertainty retained | 507–513 | 493–516 | 508–514 | 508–521 |
| 10 · FB2314-awake · surge 1/4 | 536–556, original uncertainty retained | 536–545 | 531–556 | 546–553 | 544–553 |

[All 210 boundary comparisons](all-annotation-comparisons.csv) retain every supplied discrete onset/offset combination and the coordinate sensitivity, including signed endpoint differences and distance from plateau/crossing ranges. The saved interval (T0) and prior zero-crossing result (T1) remain alongside T2/T3. No tolerance was invented and no minimum-error alternative was selected. Examples 6/7 have no timing reference; neither do the other 38 unannotated events.

## Complete fixed panel and measurement availability

The same 48 selected events generated **192 timing rows**: 154 complete candidate intervals, 34 unbracketed native seeds, and four partial-shoulder rows. T2 and T3 each have 77 complete intervals because they require the same eligible shoulders and differ only in which ones they select. These are repeated diagnostic calculations, not additional events or independent observations.

Among the 77 complete intervals per candidate, T2 fails to cover the full saved native interval in **69**, while T3 does so in **35**. Native coverage is a support-disagreement flag, not physiological ground truth. T3 contains multiple local directional peaks in **73/77** complete intervals; no automatic merging or biological event counting follows.

The 154 complete rows produced **308 context-scale diagnostics**: 61 exceed both surrounding ranges, 239 do not, and eight lack complete context. No context screen is produced for unresolved timing. These operation counts are not sensitivity/specificity or pooled biological results. [The stratified table](stratified-summary.csv) separates recording, saved sign, candidate and direction; [context-results.csv](context-results.csv) preserves each scale, side, sample set and descriptor. The 10/20-sample scales remain hypotheses; no multiplier or scale was adjusted after the results.

Raw-source amplitudes remain separate from recognition. T2 has **10** finite amplitudes; T3 has **20**. More finite amplitudes do not establish better timing: they can reflect an earlier reference, changed interval, or a different included extremum. All other rows retain the explicit insufficient-baseline or unresolved-timing status. Signed/negative values remain intact. The original 20 immediate clean samples, both-sign overlap exclusion, stored sign formula and native-union footprint are unchanged. In particular, a broad candidate can retain pixels contributed outside the candidate's interval; spatial validity is not established by this timing comparison.

The corrected [timing-results.csv](timing-results.csv) uses an unavailable clean-sample count for the 38 rows whose timing prevented any baseline assessment. The original run CSV had displayed an empty set's length as zero; it is preserved under run-01. Only that reporting field changed. Nested diagnostic results already distinguish unassessed baselines from assessed baselines with zero eligible samples. No numerical method or amplitude was rerun. Final figures use the same distinction and mark overlap-excluded reference samples with red crosses.

## Verification, traceability and feasibility

[Known-shape checks](known-shape-checks.json) passed 89 assertion groups, covering both directions, offset/scaling invariance, nested excursions, brief recovery, exact plateaus and tied seeds, monotonic/flat traces, acquisition/neighbor boundaries, missing samples, context variability and baseline overlap. These establish selected numerical behavior, not biological validity.

[The independent Python verifier](independent-verification.json) checks all 192 nested timing/context/amplitude results against a separate implementation using finite-run transitions and plateau compression. It independently intersects each footprint with all saved native support and reproduces all 48 original amplitude/baseline comparators. Identifiers, statuses, sample sets and missingness match exactly; numerical tolerance is 1e−9 absolute plus 1e−12 relative. Frozen inputs and diagnostic code hashes verify, and all 469 MATLAB production implementation files remain unchanged. This is verification from saved ingredients, not a new source-pixel extraction or independent physiological validation.

The MATLAB calculation took 1.92 s for FB2314, 0.19 s for FB2316, 0.41 s for provisional HP and 0.10 s for ID400, excluding startup and rendering. One saved-data pass per recording completed within the frozen time and evidence limits. No movies, detector, correction fit, statistics or production edit ran. The same ten review cases were rendered; no extra examples were selected to rescue a candidate.

The [frozen candidate contract](candidate-contract.json), [source bindings](inputs.json), [implementation freeze](implementation-freeze.json), original [selection/slot mapping](selection-and-slot-mapping.json), and [coverage/source links](coverage-and-source-links.json) retain recording/event identity and prior evidence. Weak/strong contrast, short/long native events, overlap and recurrence are selection proxies. Native spatial variation is reused from phase 043. Coverage of true weak events, sustained physiology, ambiguous event separation, motion and incomplete acquisitions remains unproven. These are three identified animals and provisional HP; anatomical, preparation, cohort and independent-evaluation holds are unchanged. BOI-only scope, both signs, biological variability, physiological relevance, usability and traceability remain requirements.

## Decision and next step

**Retain production rules; defer both timing candidates and the recognition screen as adoption choices.** Their diagnostic outputs are useful for exposing distinct failures, but neither a local minimum nor the strongest remote shoulder consistently marks the full excursion/recovery seen by the researcher. The range screen can miss a recognized event and changes its decision with context in a rejected example. Finite amplitude, native coverage, number of peaks and desired sign are not substitutes for that scientific judgment.

The fixed comparison stops here. The next scientific decision is what evidence should distinguish the full excursion from nested fluctuations and identify recovery when later activity follows. Use the failures above to make that criterion concrete before proposing another method or changing parameters. Preserve the existing correction; no substrate-decay explanation or automatic new smoothing/threshold search follows from an inconclusive result.

[Open the ten-case review](REVIEW.md). The readable figures accompany the full numerical output rather than replacing it.
