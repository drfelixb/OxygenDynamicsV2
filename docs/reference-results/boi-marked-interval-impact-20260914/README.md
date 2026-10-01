# Measurement impact of researcher-marked intervals

14 September 2026 · R2-MARKED-INTERVAL-IMPACT-045 · verified, bounded audit complete

**The marked intervals leave amplitude available for two of the six newly annotated events.** The other four still lack 20 immediate baseline samples free of saved native-event overlap. Earlier/later boundaries change timing, but do not by themselves solve reference availability. Neither baseline availability nor a finite amplitude establishes whether an event is biologically distinguishable.

## New guided examples

All intervals use the cited one-based plot frames at external 1 Hz. “Clean” below means finite raw signal and no overlap with either sign's saved native support on the same fixed footprint; it does not establish a physiologically quiet baseline. Amplitudes are relative optical changes, displayed as percentages, not oxygen concentrations. The saved detector sign is preserved.

| Example / recording / saved sign and site-event | Researcher interval | Clean baseline samples: saved → marked | Saved amplitude | Marked amplitude |
|---|---|---|---|---|
| 1 · FB2314 awake · sink 15/36 | 1154–1167 | 14/20 → 14/20 | Unavailable | Unavailable |
| 2 · FB2314 awake · surge 5/1 | 177 or 178–195 | 0/20 → 0/20 for both | Unavailable | Unavailable |
| 3 · ID400 awake · sink 45/1 | 295, 296 sensitivity, or 297–312/313 | 20/20 → 20/20 for every alternative | 7.8838% | 7.6787–8.0248% |
| 4 · ID400 awake · surge 4/6 | 529–546 | 2/20 → 0/20 | Unavailable | Unavailable |
| 5 · FB2316 KX · sink 14/6 | 717–772 | 20/20 → 20/20 | 6.7268% | 6.6592% |
| 6 · FB2316 KX · surge 10/3 | No surge recognized; no manual interval | Saved: 0/20 | Unavailable | Not assigned |
| 7 · HP identity pending · sink 15/4 | No distinct event recognized; no manual interval | Saved: 20/20 | 1.5316% | Not assigned |
| 8 · HP identity pending · surge 6/3 | 235–356 | 0/20 → 0/20 | Unavailable | Unavailable |

All sample losses in these comparisons are due to saved native overlap; there are no nonfinite pre-event samples. Example 1 excludes frames 1148–1153 from its candidate baseline 1134–1153. Both example 2 alternatives, example 4 and example 8 have overlap on every candidate baseline frame. This audit does not determine whether each overlapping detection is a true physiological event.

## What changes when boundaries move

For **example 3**, onset 295 gives 8.0248%; onset 297 gives 7.6787%. Interpreting the user's literal “295 s” as elapsed time gives frame 296 and 7.8838%. Frame 296 is an explicit coordinate sensitivity, not a newly supplied annotation. The original 297 and alternative plotted 295 remain distinct; no continuous onset range is adopted. Offsets 312 and 313 give identical amplitude at each onset because the raw minimum remains at frame 308. The differences from the saved amplitude are +0.1410, 0, and −0.2050 percentage points for onsets 295, 296, and 297, respectively. These differences arise from moving the pre-event reference; the raw minimum and footprint are unchanged. This arithmetic does not choose the best physiological onset.

For **example 5**, the marked interval has a 55-second endpoint separation and includes 56 samples, compared with 63 seconds and 64 samples for the saved 716–779 interval. Its raw minimum remains at frame 771. Amplitude decreases by 0.0676 percentage points because moving onset from 716 to 717 changes the baseline mean. These sample counts are not exposure durations and no duration convention is newly adopted.

For **example 8**, the marked 235–356 interval has 121 seconds between endpoints and 122 samples. Its baseline is frames 215–234; every sample overlaps saved native support. The marked interval ends before the original native event's last frame, 389. The original native-union footprint is deliberately retained, including pixels contributed after the marked offset. This isolates the timing comparison but does not validate that footprint for the manually marked event. The raw maximum remains at frame 316. No missing amplitude is replaced with zero.

Example 2 remains labelled as a saved surge although the researcher described peaks bounding a decline and recovery. Recognition/sign interpretation, timing and amplitude-reference eligibility remain separate questions; this audit does not relabel it. Example 7's finite 1.5316% saved amplitude does not override the researcher's judgment that its small, brief dip stays within surrounding variability. Its unresolved upper-right anatomical location remains a separate issue.

## Earlier anchors reused

The two earlier FB2314 surge 1/3 and 1/4 timing grids were already independently checked in [phase 041](../boi-c02-timing-comparison-20260913/README.md). Their exact 20 rows (18 alternatives and two saved comparators) are carried forward by hash in [reused-anchor-results.csv](reused-anchor-results.csv), without rerunning or newly confirming them. Every alternative has 20 eligible pre-event samples under the saved-native criterion. Event 3 ranges from −1.3152% to +1.0779%; event 4 from −0.5980% to +1.3165%. Negative amplitudes remain visible. Boundary/reference choice can change the computed sign; no preferred sign or generalized robustness claim is inferred.

The complete review therefore contains eight annotated cases including the two earlier anchors, and two candidates not recognized by the researcher. Four annotated cases have an available amplitude under the tested rule, four do not. Alternatives are sensitivity calculations within events, not independent observations or additional animals.

## Calculation and reproducibility

[The frozen specification](prespecification.json) fixes the cases, variants, formulas, limits and stopping decision. [The researcher review](researcher-review.json) preserves the exact feedback and uncertainties. [The 20 calculated rows](run-01/interval-results.csv) expose the original and candidate intervals, footprint size, baseline frame lists, overlap exclusions, raw extrema, reference mean, amplitude status and changes. The signal is the saved raw mean over each event's original native-union footprint; existing recording-specific correction used for review was not refitted or substituted as the amplitude source. No substrate-decay model or cause is inferred.

For start frame a, reference candidates are exactly a−20 through a−1. A frame is eligible only if the raw value is finite and its footprint intersects no native mask of either sign. All 20 must be eligible. With positive finite mean B and finite event signal, sink amplitude is −min((raw−B)/B), and surge amplitude is max((raw−B)/B), over the inclusive marked interval. Otherwise amplitude is unavailable with its reason. There is no earlier search, shortened reference, post-event reference, or imputation. Fractions in the CSV become percentages by multiplying by 100; amplitude differences are in percentage points.

The [independent verification](verification.json) reproduces all eight saved comparators and all 12 new variants. Python independently intersects the fixed footprints with the complete saved native unions, checks full raw trace identity against the earlier trace exports, and verifies sample sets, statuses, extrema and arithmetic against MATLAB. It verifies 33 frozen input hashes and all 469 unchanged MATLAB implementation files. Numerical tolerance is 1e−9 absolute plus 1e−12 relative; IDs, statuses, missingness and sample sets must match exactly. This is independent arithmetic from saved ingredients, not independent movie extraction or biological validation.

The calculation took 1.75 seconds in MATLAB R2025a, excluding startup. No movies were read and no detector, correction fit, statistics or production modification ran. The first independent-verification launch was blocked by a partially removed temporary Python dependency; restoring h5py 3.16.0 in an isolated temporary directory allowed the same verifier to pass. Both failures and the successful verification log are retained. No scientific calculation was changed or rerun in response.

## Decision and next bounded step

**Retain production rules; defer scientific timing and recognition policy.** The audit answers the measurement-impact question, not the final definition of a physiological event or baseline. Cleaner references, desired amplitude signs, and historical counts are not tuning targets. The three identified animals and provisional HP recording remain development examples; acquisition, anatomical, cohort and independent-validation holds remain open. Both signs, biological variability, physiological relevance, feasibility, usability and traceability remain standing requirements.

Next: draft a small, testable set of event-recognition and onset/recovery rules from the reviewed examples, with amplitude availability shown separately. Specify how local variability, plausible alternative boundaries, brief recovery peaks, sustained signals, recurrence and unresolved events will be evaluated before any algorithm comparison. Preserve original correction and labels; do not automatically adopt a threshold or alter the 20-sample reference rule to make these cases measurable.
