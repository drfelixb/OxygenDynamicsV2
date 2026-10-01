# Bounded timing comparison completed

13 September 2026 · R2-TIMING-EXECUTION-043

**Retain the existing production correction and timing rules.** The frozen comparison completed for all 48 selected events, but it does not support adopting corrected-trace zero crossings as a general physiological event-duration rule. Crossings are useful inspectable landmarks; they sometimes delimit only a fragment of the detected event or remain unresolved within the permitted context.

The existing recording-specific correction was retained throughout. No substrate-decay model or causal interpretation of the trend was introduced. The researcher's approximate FB2314 boundaries remain uncertain annotations, not fitting targets or accepted biological truth.

## Results

Each of 48 events contributes its saved interval and two separately labelled diagnostic branches: a connected negative and a connected positive excursion in the existing cubic-corrected local trace. A branch without the requested sign inside native support is unavailable; this is not a detector failure. We did not choose whichever branch agrees with the detector label or produces a preferred amplitude.

| Recording, 12 selected events each | Negative branch: two crossings / censored / absent | Positive branch: two crossings / censored / absent | Saved finite amplitudes | Finite diagnostic amplitudes, negative / positive branch |
|---|---:|---:|---:|---:|
| FB2314 awake, restricted ROI | 6 / 5 / 1 | 5 / 1 / 6 | 4 | 2 / 1 |
| ID400 awake, historical whole-field processing | 9 / 0 / 3 | 7 / 0 / 5 | 6 | 2 / 3 |
| FB2316 KX, historical whole-field processing | 2 / 4 / 6 | 2 / 5 / 5 | 4 | 1 / 1 |
| HP ECS, identity pending, historical whole-field processing | 4 / 5 / 3 | 0 / 5 / 7 | 3 | 1 / 0 |

Of the 96 diagnostic branches, **35 have both crossings, 25 are censored, and 36 have no excursion of the requested sign in native support**. Of the 35 fully bracketed branches, **20 do not cover the entire native event**. Numerical crossings alone therefore do not identify a full physiological excursion. Censoring records acquisition boundaries, the fixed 30-frame extension limit and same-site neighbor partitions separately; limits are safeguards, not physiological cutoffs. A branch that encounters a limit is not assigned a completed duration.

Only 11 fully bracketed branches also have the required 20 clean pre-event samples and a calculable raw-source amplitude; the other 24 lack sufficient clean baseline context. Saved measurements retain their original 17 finite and 31 unavailable outcomes. The two saved negative FB2314 surge amplitudes remain negative in their negative-excursion diagnostic branches. No sign relabeling, clipping, baseline shortening, earlier baseline search or post-event fallback was used. These branch counts are accounting checks from a deliberately selected panel, not independent biological observations, condition effects or detection-accuracy estimates.

Native support changes across time in 47 selected events; the remaining event contains only one native frame. Per-frame area and adjacent-mask intersection-over-union are exported. These describe saved geometry, not tissue motion or biological event identity. The ten fixed review examples include both simple and fluctuating traces, recurring context and long unresolved excursions. Complete coverage of biological morphology, preparation differences and physiological recovery is not established by this panel.

## The two researcher anchors

| FB2314 surge site 1 | Researcher nominal marks | Negative corrected run, included frames | Crossing brackets, onset / recovery | Diagnostic raw-source amplitude |
|---|---:|---:|---|---:|
| Event 3 | 496–516 | 500–514 | 499–500 / 514–515 | −2.458626% |
| Event 4 | 536–556 | 537–554 | 536–537 / 554–555 | −0.597962% |

Their landmarks reproduce phase041. Event 3's onset is later than the working annotation range; that disagreement is retained. The current diagnostic run includes 15 and 18 samples respectively, with 14 and 17 seconds between its endpoint sample times at external 1 Hz. Neither convention is silently designated as physiological duration. These amplitudes use a 20-sample raw-source baseline immediately preceding the indicated run and the unchanged surge formula. They differ from phase041's manual-envelope alternatives because the intervals and reference samples differ.

## Review packet

[Open the ten fixed examples](REVIEW.md). Each links a source/corrected/detector trace, three native-mask snapshots, and the exact checked result table. No new examples were selected after examining timing outcomes. Blue lines on the two anchors mark the researcher's earlier uncertainty ranges; they are not additional detections. Purple and green delimit negative and positive diagnostic runs, respectively. A censored run line is a search endpoint, not a recovered biological boundary.

The plots use the saved full field of view and source coordinates. In particular, HP sink site15/event4 has small support near the upper-right image edge. Its numerical replay does not establish craniotomy membership or physiological relevance. It remains visibly flagged for anatomical interpretation, without an automatic crop, exclusion or replacement case. Restricted FB2314 support and historical whole-field recordings remain separate; HP identity and preparation remain unresolved.

## Verification, corrections and resources

MATLAB reproduced all 48 saved measurements, baseline samples and availability states before calculating diagnostics. Independent Python/numpy/h5py replay verifies all **144 rows**, **50,400 full-trace samples per column**, native footprints, per-frame support geometry, both-sign overlap exclusions, seed selection, crossing brackets, censor reasons and current amplitude arithmetic. It reads the exported saved ingredients and original audit CSVs. This is an independent calculation path, not an independent source-pixel extraction or human physiological assessment; no source movie was reread.

The completed per-recording MATLAB work took 19.82, 5.86, 5.90 and 7.57 seconds, respectively, including the initial plot exports and excluding startup. The frozen limit was 10 minutes per recording and 1 GiB new evidence. No peak-memory measurement was made. No detector, statistics or full-movie processing ran. Sixteen frozen input files and all 469 MATLAB implementation files retain their hashes.

The first attempt stopped on mixed optional JSON fields in the review queue. The corrected reader accepts the decoded cell representation without changing selection or scientific settings; `run-01` and its failure records remain intact. `run-02` contains the completed calculation. During reporting review, the saved rows' `CoversWholeNative` flag was found to inherit a false default. [Checked tables](checked-tables/) correct that field from the already saved bounds in 48 rows; all other saved fields and every diagnostic field are unchanged. `reporting-correction.json` records the exact changes. Initial plot legend warnings were resolved by displaying only actually present baseline markers; final plots use plain-language statuses. No numerical timing or amplitude rerun was needed for these reporting corrections.

The final evidence includes the frozen panel, scripts, attempt records, checked tables, per-event full traces, footprints and native support, ten review views, verification reports and checksums. Local MATLAB replay ingredients retain both-sign native unions; the portable packet excludes these larger MAT files and records their local hashes. All old phase042 artifacts are verified using preserved phase-start documents where current standing records were appended. Existing worktree changes and historical outputs remain intact.

## Decision and remaining scientific question

Close this experiment as **retain current production rules; restrict the new outputs to diagnostic landmarks; defer a physiological timing rule**. A short zero crossing inside a longer native event and a broad unresolved excursion cannot be treated interchangeably as a full event duration. The comparison does not justify extending limits, joining segments, assigning a substrate mechanism or selecting a different reference until the intended physiological quantity is explicit.

Next is the fixed researcher review, beginning with the first two entries: distinguish a complete excursion, a partial fluctuation within native activity, and recovery unresolved within the available context. Approximate ranges or an unresolved judgment are acceptable; exact hand labels are not required. Further algorithm work depends on that interpretation, rather than another automatic parameter search.

BOI-only scope, biological variability, physiological relevance, feasibility, usability and traceability remain standing requirements. This is development evidence from three identified animals plus a provisional local recording, not a cohort eligibility freeze, independent biological validation or a completed independent researcher workflow release.
