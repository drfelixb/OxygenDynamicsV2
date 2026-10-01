# FB2314 researcher timing comparison

13 September 2026 · R2-C02-TIMING-COMPARISON-041

The bounded comparison is complete. Retain the current production rules and defer a new physiological timing definition. The two researcher annotations describe a longer excursion than the saved surge masks. Existing recording-specific cubic correction gives useful timing landmarks, but does not reproduce every annotation, and small endpoint changes affect the current raw-source amplitude. These are two development examples from one recording, not independent biological validation.

The user explicitly cautioned against overinterpreting substrate consumption. No new decay model or fitted local baseline was introduced. The trend here is the saved per-pixel whole-recording cubic correction averaged on each fixed native-union footprint. Its shape is recording-derived; no cause is assigned to it. The original script also contains degree-5 per-trace detrending and a degree-7 processed-site sink return rule. That sink rule is distinct from the zero crossings shown here; historical and current surge timing uses native-mask bounds.

## Timing results

All values below are recording frame indices; the external trigger fixes sampling at 1 Hz. A crossing is bracketed by adjacent samples, without sub-frame interpolation.

| FB2314 awake, surge site 1 | Saved native interval | Researcher nominal interval | Researcher onset / recovery possibilities | Existing cubic-reference crossings: onset / recovery |
|---|---|---|---|---|
| Event 3 | 503–514 | 496–516 | 496–498 / 514–516 | 499–500 / 514–515 |
| Event 4 | 540–552 | 536–556 | 536–538 / 554–556 | 536–537 / 554–555 |

Event 3's connected negative corrected excursion occupies frames 500–514; event 4's occupies 537–554. The run is seeded at the corrected minimum within the saved native interval, then extended through finite negative samples. These descriptive landmarks were specified before calculation. They are not accepted event boundaries, the historical sink algorithm, or estimates of physiological accuracy. Event 3's onset bracket falls later than the working annotation range. The user's acknowledged biological uncertainty remains unresolved; no tolerance was widened to claim agreement.

The annotation envelope implements onset 0–2 samples later and recovery 0–2 samples earlier than each nominal pair. This is an explicit working interpretation of approximate feedback, not confidence limits. Nominal pairs have 20 seconds between marked sample times and 21 included samples. Across each envelope, those quantities are respectively 16–20 seconds and 17–21 samples. The current inclusive-frame duration convention assigns 17–21 seconds. Neither endpoint convention is silently substituted for the other.

## Baseline and amplitude consequences

We evaluated the original interval plus all nine onset/recovery combinations for each event: 20 rows total. Each comparison keeps the original footprint (10,951 and 11,565 pixels) and requires exactly the 20 immediately preceding source samples. The complete saved native masks of all 346 events, both signs, were checked for overlap on those footprints. No earlier baseline search, shortened reference, post-event fallback, or sign reassignment was used.

All 18 alternative windows have 20 finite samples without saved native-event overlap. At the nominal starts, baseline frames are 476–495 and 516–535. Across the onset alternatives they range from 476–495 through 478–497, and 516–535 through 518–537. This means clean under the saved-mask criterion; it does not establish a biologically quiet baseline. Undetected activity, neighboring recovery, fluctuations and reference adequacy remain possible concerns. Candidate annotation extensions of other events were not treated as new native masks.

| Event | Saved raw-source surge amplitude | Nominal-annotation diagnostic amplitude | Range over nine annotation alternatives |
|---|---:|---:|---:|
| 3 | −2.064493% | +1.077856% | −1.315211% to +1.077856% |
| 4 | −0.983013% | +1.019564% | −0.597962% to +1.316485% |

These values replay the current surge formula, `max((source - pre-event mean) / pre-event mean)`, on the preserved source and original footprint. They do not use the cubic-corrected trace as the amplitude denominator. Changing the interval changes both the reference samples and which maximum is included; an edge or recovery sample may become that maximum. Positive diagnostic values therefore do not resolve physiological direction or validate the longer interval. Saved negative values and surge labels are preserved. Local corrected negative excursions and positive normalized detector contrast remain explicitly distinct.

## Evidence and verification

- `prespecification.json`: frozen question, cases, calculations and limits.
- `researcher-annotations.json`: nominal marks, uncertainty and verbatim feedback context.
- `run-01/all-window-comparisons.csv`: all 20 rows, frames, durations, availability and arithmetic.
- `run-01/<case>/trace-and-overlap.csv`: all 1,200 samples per event, processing stages and overlapping event identities.
- `run-01/report.json`: immutable MATLAB calculation result; its pending-verification status is superseded by `independent-verification.json` and `completion.json`.
- `plots-02/`: light-background plots for review. Original `run-01` plots are retained locally as the initial rendering attempt; mixed dark axes and pale text made them unsuitable for final presentation.
- `runComparison.m` and `verifyComparison.py` (portable source copies have `.txt` suffix): reproducible MATLAB calculation and independent Python replay.
- `inputs.json`, `code-before.json`, `artifact-record.json`: source and implementation identities, plus completion inventory.

Independent Python/numpy/h5py replay verifies 2,400 trace samples for each of five processing columns, all-frame overlap using all 346 native events, both footprints, crossing brackets, all 20 baseline/amplitude rows, and the two saved amplitude replays. Seven frozen inputs and all 469 MATLAB implementation files remain unchanged. Numerical tolerance is 1e-9 absolute plus 1e-12 relative. MATLAB computation took 22.26 seconds, with no detector/statistics run or new movie read. This is numerical and provenance verification, not a biological test. The 143 phase-039 artifacts are also verified using their explicit preservation paths.

## Decision and next step

Close this experiment as **retain current production rule; defer physiological timing adoption**. No dictionary formula, pipeline contract, baseline algorithm, production boundary, detection label or statistics output changes. Existing worktree changes and earlier evidence are preserved. Original-sample timing, reviewed full-excursion timing and detector occupancy remain distinct.

Before selecting a timing rule, specify a small comparison across already development-exposed recordings and both signs. Include different recording backgrounds, weak/strong and brief/sustained signals, recurring/overlapping events and incomplete recovery; report disagreements and unavailable boundaries. Keep the original recording-specific correction as the starting reference. Define the intended physiological quantity and endpoint convention before tuning. Do not turn these two annotations into exact ground truth or repeatedly tune to them. BOI-only scope, biological variability, physiological relevance, feasibility, researcher usability and traceability remain standing requirements. Formal independent workflow validation and the broader cohort scientific decisions remain open.
