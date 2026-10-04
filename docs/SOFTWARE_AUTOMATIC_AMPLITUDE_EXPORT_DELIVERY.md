# Automatic amplitude export delivery

1 October 2026 · AMP-EXPORT-01 · Delivered for researcher review

## Result

BOI statistics export now adds a readable automatic optical-amplitude guide, definition sheet/CSV, long average-count sheet/CSV and availability sheet/CSV. It saves the same companions in a separate MAT file and an additive DataOutput.mat field. Existing columns, identifiers, formulas and numerical result tables are preserved. Original outputs are not overwritten.

The guide distinguishes preserved-input automatic fractions/percentages, detection-domain diagnostics and the separate corrected reviewed-pocket measure. It explains reference selection, sign, units and physiological claim limits. The misleading oxygen-drop wording is replaced with optical-drop wording. Site means, recording event means/medians, within-mouse recording means and equal-mouse group means each expose the actual contributing and total observation counts. Missing amplitudes, negative amplitudes excluded from burden and missing unnormalized event composites are separately counted; their overlap is explicit. Per-mm2 composite means have their own contributing counts.

## Demonstration

[Readable saved ID400 export](../../reference-validation/automatic-amplitude-exports-20261001/batch-04-A07/production-export/AutomaticAmplitudeGuide.md) and [workbook](../../reference-validation/automatic-amplitude-exports-20261001/batch-04-A07/production-export/FilteredData_saved-ID400.xlsx).

ID400 site 1 mean automatic drop is 0.0733175904677401 fraction (7.33175904677401%), contributed by 2 of 6 events. The recording mean nonnegative drop is 8.90797287875453%, contributed by 94 of 192 sink events; 98 amplitudes are unavailable, none are negative, and 98 event composites are unavailable. Recording composite total stays unavailable. The mouse and group amplitude means each have 1 of 1 contributors in this single-recording example, with different observation units (recording vs mouse). The accepted automatic site 1/event 3 amplitude remains 0.055522971205831419 fraction (5.5522971205831419%), distinct from either mean and from historical reviewed ID400.

## Verification and preservation

Final-code batch: **9/9 named cases passed** — six synthetic and three saved examples. Synthetic cases cover positive, negative and unavailable amplitudes; unequal events per site and recordings per mouse; all-missing and all-negative amplitudes; zero events/contributors/mice; zero amplitude inclusion; independent area/duration/composite availability; strict within-mouse missingness; ordinary percentage conversion and explicit older negative-drop provenance. Saved cases use ID400 G2 statistics/G4 ingredients, the historical FB2312 saved statistics/audit row 194 and C02 strict-ROI saved statistics/audit row 321. FB2312's automatic surge amplitude remains negative; C02's automatic amplitude remains unavailable. Neither is replaced by a reviewed-pocket measurement.

Production export entry point was exercised with loaded ID400 tables in a new evidence folder, without the statistics calculation pipeline. CSV, workbook and MAT persistence passed. Exact isequaln checks preserve existing site/event tables and burden event/recording/group tables; original workbook sheets retain their imported values. G4 ID400 arithmetic replay passes its existing tolerance. Six calculation-source hashes, seven saved-input hashes and eight final-code pins are unchanged. Git diff whitespace check passes. No detector, recorded-movie analysis/statistics rerun, correction refit, footprint change or release work occurred. Implementation and verification were by the same assistant; no independent human review.

## Initial failures, routine repairs and budget exception

The first MATLAB invocation produced no log or case results and no new MATLAB process was observed. Two working MATLAB sessions followed (three invocations total); both exited normally. The first verification batch passed all six synthetic cases but failed CSV import checks for the three saved cases because automatic header/type inference did not import the long mixed table consistently. The next dispatch retained cached code and repeated those failures. A fresh session and explicit refresh before dispatch, plus fixed CSV variable types/header layout, corrected the harness. The third batch passed 9/9. After final report formatting and a missing-site-count guard, the fourth batch passed 9/9 on unchanged final pins. Historical failure receipts are retained.

Used four batches and 36 case evaluations, two working MATLAB starts plus one unsuccessful invocation, and approximately 26 minutes against the three-hour budget. **The 150 MiB evidence ceiling was exceeded: the uncompressed packet reached approximately 225 MiB.** This is a budget exception, not a passing budget claim. Repeated earlier batch-03 MAT artifacts were losslessly compressed; every decompressed SHA-256 was checked, with originals recoverable exactly. Final batch-04 artifacts remain directly usable. Retained evidence is approximately 145.5 MiB. Original inputs and older evidence outside this new packet were untouched. See budget.json and lossless-storage-repair.json for exact bytes and receipts; no further verification was run after the final batch.

## Limits and stopping condition

The named export/count rules and preservation checks are demonstrated. This does not validate every metric/recording, biological reference suitability, correction validity, detector performance or full GUI/legacy platform behavior. Full trace/behavior display export was not part of the companion task; the production saved-table export check supplied empty optional display inputs. Legacy result columns and scientific calculations were not adopted or redefined. The complete bounded task is delivered; no additional campaign or release phase is proposed.

## Researcher acceptance — 4 October 2026

The researcher accepted the automatic amplitude export clarification **within its demonstrated scope**. The storage-budget exception, earlier failures, scientific limitations and historical execution evidence remain unchanged. This acceptance does not establish all-metric validity, physiological interpretation or release readiness. Development and release are paused. No further verification, MATLAB launches or new analysis task is authorized automatically; await a new explicit researcher requirement. This record is a documentation-only update.
