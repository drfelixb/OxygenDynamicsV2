# CC-01 revision 2 — bounded calculation comparison

29 September 2026. **Comparison delivered; no scientific adoption.** The researcher approved revision 2's saved-evidence scope and requested the paper-to-code comparison below. Release work remains paused. This report replaces neither saved measurements nor labels. It is assistant self-review; no independent reviewer participated.

**Recommendation:** retain the existing detector as candidate generation and distinguish its sign from the direction of a local optical excursion. The corrected excursion A2 is a plausible *exploratory* magnitude, but these results do not justify replacing the automatic amplitude or relabelling events. Arithmetic consistency is demonstrated within the named cases; scientific calculation correctness remains open. In particular, a positive saved-sign peak does not establish a biological surge, and subtraction of a trend does not establish that the residual is exclusively oxygen-related.

## 1. Scientific target, definitions and rule choices

The intended sink/pocket is a local downward excursion and the intended surge an upward excursion distinguishable from surrounding variability in the recording-specific corrected trace. Reference frames should represent that event's preceding state, after examining adjacent activity. They are not an unmeasured pre-isoflurane baseline or absolute resting oxygen. The supplied recordings use externally triggered 1 Hz sampling; frame 1 corresponds to modeled time 0 s. No file timestamps were used.

Three separate quantities remain visible:

- **Detection contrast:** spatial frame normalization, temporal pixel normalization, spatial averaging and temporal smoothing of detrended input. Its score is dimensionless and relative to the selected tissue/spatial reference. Sink/surge admission is made in this representation, not by the sign of raw local change. A filtered footprint mean is neither a pixel threshold nor necessarily unit variance.
- **Automatic amplitude A1:** preserved-input intensity change on a fixed union of native event pixels. For raw mean trace r, event frames W and reference R, B=mean(r(R)), q1=(r−B)/B. Saved sink amplitude is −min(q1(W)); saved surge amplitude is max(q1(W)). No absolute value is imposed. The automatic reference requests all 20 immediately preceding samples at 1 Hz, excludes native activity of either sign/nonfinite samples and requires all 20 plus finite positive B. Missingness is retained.
- **Reviewed amplitude:** the same raw formula and fixed footprint with the exact separately accepted R and W. It is exploratory and does not repair or overwrite the automatic result. A short accepted reference can be valid for this branch while the automatic reference remains unavailable.

The candidate **A2** uses saved correction c=r−T and q2=(c−mean(c(R)))/B. It scales the corrected excursion by the *positive raw reference mean*, never by the near-zero corrected reference mean. Sink/surge extrema use the original saved sign for comparison only. No new correction was fitted and no common substrate-decline assumption was introduced.

| Choice | Scientific consequence | Decision from this comparison |
|---|---|---|
| Keep contrast sign as the biological label | A relative contrast rise can accompany a local fall. | Keep it as saved detector provenance; it alone cannot establish local direction. |
| Use raw local direction and A1 | Measures observed optical change, including the component removed by correction. | Preserve as a distinct observed quantity; do not call it correction-independent event magnitude. |
| Use corrected local direction and A2 | Better matches the researcher's corrected-trace target, but depends on biological validity of the saved correction and reference. | Preferred candidate target, not a validated default or automatic relabelling rule. |
| Replace the reference automatically with earlier/shorter/post-event samples | Changes the biological comparison and may absorb a preceding event or recovery. | Not adopted. Keep automatic missingness and explicitly reviewed reference choices separate. |

No direction threshold was invented. Both extrema, the interval mean, sample signs and mean excursion relative to the reference's unscaled MAD were evaluated descriptively. MAD here is median absolute deviation, not a calibrated noise estimator or a significance test; autocorrelation and after-event variability are not resolved by this ratio. All local-direction classifications remain unclassified. Integrals in the structured evidence are inclusive sample sums at 1 Hz, not physiological oxygen burden.

## 2. Numerical impact with the original labels retained

A1 below is the original automatic formula or the existing exploratory reviewed formula for that row. A2 is a new offline comparison only. All amplitudes are percent; differences are percentage points. Rows from the same event are paired alternatives, not independent biological observations.

| Saved example / branch | Saved label | W (frames) | A1 (%) | A2 candidate (%) | A2−A1 (pp) |
|---|---|---|---:|---:|---:|
| ID400 historical, sink 11/1 | sink | 58–98 | -0.3497 | 2.7930 | +3.1427 |
| FB2312 historical, surge 1/2 | surge | 403–412 | -2.3881 | -2.6306 | -0.2424 |
| ID400 G2, sink 1/3 | sink | 431–457 | 5.5523 | 5.3533 | -0.1990 |
| C02 row 186 reviewed 1154–1166 | sink | 1154–1166 | 17.7058 | 18.9329 | +1.2271 |
| C02 row 186 reviewed 1154–1167 | sink | 1154–1167 | 17.7058 | 18.9329 | +1.2271 |
| C02 row 308 automatic | surge | 503–514 | -2.0645 | -1.4221 | +0.6424 |
| C02 row 308 reviewed 496–516 | surge | 496–516 | 1.0779 | 1.9258 | +0.8479 |
| C02 row 309 automatic | surge | 540–552 | -0.9830 | 0.0123 | +0.9953 |
| C02 row 309 reviewed 536–556 | surge | 536–556 | 1.0196 | 2.3634 | +1.3438 |
| C02 row 321 reviewed 177–195 | surge | 177–195 | 6.0209 | 5.5765 | -0.4443 |

The same R, W and footprint are used within each A1/A2 pair, isolating the correction-numerator change. Comparing an automatic row with a reviewed row changes both the interval and reference, so that difference must not be attributed to the reference alone.

Reference sets are 38–57 (historical ID400), 383–402 (FB2312), 411–430 (G2 ID400), 1134–1153 (C02 row 186 reviewed onset 1154), 483–502/476–495 (row 308 automatic/reviewed), 520–539/516–535 (row 309 automatic/reviewed), and 165–176 (row 321 reviewed). The exact sets, raw reference means, native bounds, extreme frames and identities are in [results.json](../../reference-validation/cc-01-comparison/results.json).

Four combinations retain unavailable amplitudes:

| Example | W | Reference finding | A1 and A2 |
|---|---|---|---|
| C02 row 186 automatic, sink | 1156–1165 | 14/20 clean samples | Unavailable |
| C02 row 186 reviewed, sink | 1149–1166 | No accepted reference for onset 1149 | Unavailable |
| C02 row 186 reviewed, sink | 1149–1167 | No accepted reference for onset 1149 | Unavailable |
| C02 row 321 automatic, surge | 183–193 | 0/20 clean samples | Unavailable |

For row 186's reviewed onset 1154, the explicit 20-frame reference includes 1152 and 1153, as accepted. Only 14 of those frames pass the automatic native-activity screen; the reviewed reference is not an automatic 20-clean-frame pass. Row 321's accepted 165–176 reference contains 12 samples and zero native-eligible samples under that screen. Its reviewed result depends on the researcher's interpretation of adjacent activity. A2 does not remove either disagreement.

### Direction versus peak magnitude

| Example / branch | Corrected minimum (%) | Corrected maximum (%) | Mean (%) | Mean / reference MAD |
|---|---:|---:|---:|---:|
| ID400 historical, sink 11/1 | -2.7930 | 6.2393 | 1.4456 | 1.149 |
| FB2312 historical, surge 1/2 | -7.3532 | -2.6306 | -4.6044 | -6.097 |
| ID400 G2, sink 1/3 | -5.3533 | 1.4043 | -1.9573 | -2.233 |
| C02 row 186 reviewed 1154–1166 | -18.9329 | -0.7216 | -9.7122 | -2.703 |
| C02 row 186 reviewed 1154–1167 | -18.9329 | 0.9627 | -8.9497 | -2.490 |
| C02 row 308 automatic | -8.6908 | -1.4221 | -5.6730 | -3.264 |
| C02 row 308 reviewed 496–516 | -8.8573 | 1.9258 | -3.6013 | -1.978 |
| C02 row 309 automatic | -7.3151 | 0.0123 | -4.0284 | -3.875 |
| C02 row 309 reviewed 536–556 | -7.5749 | 2.3634 | -2.5782 | -2.711 |
| C02 row 321 reviewed 177–195 | -15.1948 | 5.5765 | -6.0773 | -1.667 |

- Historical ID400 changes from a negative saved sink amplitude to a positive one after correction. However, the corrected window contains both signs and its mean is positive. This is not evidence that the entire 58–98 interval is a clean downward event.
- FB2312 remains below its local reference throughout the selected window despite the saved surge label. At the raw extreme (frame 411), the saved corrected-stage change is −18.5797 input units, spatial-normalized change +0.2109, and temporally normalized change +0.5964. C02 row 308 similarly changes from −28.4180 corrected input units to +0.1051/+0.1953 in those normalized stages. These are stage changes, not interchangeable units or final detector thresholds: they demonstrate how relative contrast can disagree with local direction.
- C02 row 309 automatic crosses zero only slightly under A2: +0.0123% at its maximum, while its minimum is −7.3151% and mean −4.0284%. Treating that positive endpoint as a validated surge would be unjustified.
- The reviewed row 308/309/321 windows retain positive surge-convention maxima while their corrected means are negative. Row 321's maximum is at onset frame 177 and its trough at 186. Both extrema are necessary to understand the excursion.
- Row 186's two valid reviewed alternatives have identical peaks, but adding frame 1167 includes a positive recovery sample and changes the corrected mean from −9.7122% to −8.9497%. Equal peaks do not make interval choice irrelevant.
- Row 308 reviewed has its A1 maximum at frame 496 but its A2 maximum at 516. We recomputed extrema over the whole saved window rather than substituting a residual at the old peak.

### Existing synthetic evidence

| Saved recipe | Sink A1 (%) | Surge A1 (%) | Candidate A2 |
|---|---:|---:|---|
| clean | 20.0000 | 20.0000 | Untested: no saved correction |
| unmarked_same_tail | 16.6667 | 15.3846 | Untested: no saved correction |
| linear_drift | 16.9027 | 21.6242 | Untested: no saved correction |
| global_step | 50.0000 | -10.0000 | Untested: no saved correction |

Both signs in each recipe were replayed from saved vectors. The imposed event component is 20% in these recipes, but the measured raw result also reflects a preceding tail, drift or a global step. The global falling step yields −10% in the saved surge convention despite an imposed upward component. The fixture contains Raw and Imposed ingredients, but no source-matched saved correction: **all four synthetic A2 evaluations are untested**. The known imposed component was not substituted for an estimated correction. Consequently, this comparison does not demonstrate recovery of the imposed event by A2.

## 3. Concise paper-to-code comparison

| Source | Scientific or computational meaning | Relationship to this decision |
|---|---|---|
| [Science, DOI 10.1126/science.adn1011](https://pmc.ncbi.nlm.nih.gov/articles/PMC11251491/) | Describes localized negative excursions, sharp boundaries/onset/recovery and relative BLI decrease before a pocket (Fig. 2C–N). Calibration supports relative oxygen sensitivity, while the discussion limits extended baseline comparisons and absolute quantification. | Supports a local relative optical target; does not establish A2's correction/reference formula or validate the seven named events. |
| [STAR Protocols, DOI 10.1016/j.xpro.2024.103334](https://pmc.ncbi.nlm.nih.gov/articles/PMC11460448/) | Tables 2/3 describe amplitude relative to the preceding 20 s. Limitations identify enzyme expression and substrate availability as influences on intensity and describe a relative readout. | Supports explicit local reference semantics, but the prose does not resolve raw versus corrected numerator or guarantee every 20 s window is physiologically clean. |
| [Paper-linked Science_2024 archive, Zenodo 10629901](https://doi.org/10.5281/zenodo.10629901) | Master code cubic-detrends pixels. Its normalization divides by spatial SD but then sqrt(temporal SD). Sink amplitude uses an absolute difference of minima magnitudes between a convolved trace and a seventh-degree trend. Surge amplitude uses an absolute event-mean/reference-mean ratio of a normalized trace, with a post-event fallback near the start. | These two legacy amplitude definitions are neither symmetric raw ΔB/B nor A2. The archive's statistics script averages the stored amplitude fields; GetHypoxicEventsStats copies them into event rows and exports them. This is a concrete prose/code discrepancy, not proof that every published figure used this exact path. |
| Current workspace V2, pinned below | Uses SD in both normalization stages with the recorded ROI/whole-image profile. The automatic finalizer separately measures signed raw fixed-footprint change with complete screened pre-reference requirements. Reviewed measurements have explicit separate references. Pixel correction is cubic; `detrend_custom(...,2)` uses a fifth-degree trace fit. | Current detector contrast, automatic amplitude and reviewed amplitude are separate contracts. Neither the old archive nor publication prose establishes A2 equivalence. This report changes no production contract. |

The archive's sink expression is `abs(abs(min(temptrace(W)))−abs(min(tracetrend(W))))`; the two minima can occur at different frames. Its surge expression is `abs(mean(z(W))/mean(z(R)))`, not `(event−reference)/reference`. These are verified code expressions, not reconstructed published numerical results. Archive locations: master lines 1165–1222, 1553–1558 and 1933–1954; statistics lines 793/802; event-specific export lines 439/714/842. The local ZIP MD5 matches its saved Zenodo record: `078fd8e731a3d7449818e3dcf0d73dfb`.

**Correction to an earlier explanation:** the `2` argument of `detrend_custom` selects the input dimension, not polynomial degree. The current helper's trace branch is degree five. The superseded proposal is retained as history; its second-order interpretation must not be reused.

Source access: Science main article HTML and STAR full-text XML were read and saved. The Science supplementary-file request returned an HTML access challenge; its complete supplement was not freshly verified. Earlier local supplement audit notes are historical context, not a substitute for this missing primary verification. The code ZIP is the immutable saved release, not a fresh checkout of a possibly changed branch. No publication cohort or figure was recomputed.

## 4. Correction provenance and arithmetic verification

Historical ID400, FB2312 and C02 audits contain raw fixed-footprint traces and saved raw cubic trends. Their reconstructed residuals agree with their saved DetectionDetrended stage within 0.0001 input units; the largest observed discrepancy is approximately 0.0000254. G2 ID400 instead provides a saved full-precision in-memory corrected stage, linked by AuditCreationReceipt and exact source/capture/master/helper hashes. Its trend is obtained algebraically as raw minus saved corrected trace; no new fit is involved. No named real source declared a denoised input. Each correction is associated with the same fixed footprint/source, and original normalization profiles remain distinct.

These checks verify the saved association, not that detrending removed only substrate effects or preserved every biological signal. Original movie checksums were compared between saved metadata/receipts; source movies were not reopened or rehashed. Missing synthetic correction provenance remains untested.

For ten available real combinations, the original A1/reference replay passed, and A2 was checked by an independent scalar implementation using accurate summation against the vector calculation. The pointwise identity q1=q2+(T−mean(T(R)))/B passed; maximum absolute discrepancy was 2.78e−16 in fractional units. The scalar tolerance was 1e−10×max(1,abs(expected)); decomposition tolerance was 1e−10. The four real unavailable combinations remained unavailable. Four synthetic recipes passed their saved A1/reference/integral replay for both signs. No arithmetic mismatch remains after the import repair below. None of these are physiological ground-truth validations or sensitivity/specificity estimates.

## 5. Budget, errors and reproducibility

The approved matrix contains seven real event identities, fourteen reference/interval combinations, plus four synthetic recipes with both signs: **18 cases**. **19/20 evaluations** were used, including one affected-case recheck. No extra cases, recordings, new fits, MATLAB launches, detectors or statistics engines ran. Numerical execution elapsed about 576 s including the bounded repair, within the two-hour allowance. No further evaluation is scheduled.

Before cases, a source-profile guard incorrectly assumed all normalization was whole-image; exact saved ROI versus whole-image profiles were then used. Six cases passed before evaluation 7 hit an import error: converting the unavailable automatic RawExtremeFrame `NaN` while evaluating a separately valid reviewed interval. The optional automatic comparison was restricted to the automatic branch. This was a harness import defect, not a changed scientific rule. The failed packet remains preserved; the affected case was rechecked once and the remaining cases completed. The stale remaining-case list in the budget file was reconciled from final saved results without rerunning cases.

The first six passes belong to harness SHA256 `8abc03eaf11f9662b60b4d28f616001bb51f168594a5a956ba064fda664c2b03`; the remaining twelve, including the corrected seventh case, belong to `e5dbc9abfe6479ae9bfe592480feb7b36fbdbd0f7b5666c4074ef80e0247241a`. They are **not claimed as eighteen executions of one final harness**. All 26 pinned scientific/code/archive inputs matched their hashes after execution. Full hashes, results and earlier failures are preserved under [cc-01-comparison](../../reference-validation/cc-01-comparison/), especially [pins.json](../../reference-validation/cc-01-comparison/pins.json), [results-attempt-01.json](../../reference-validation/cc-01-comparison/results-attempt-01.json), [repair-record.json](../../reference-validation/cc-01-comparison/repair-record.json) and [final-hashes.json](../../reference-validation/cc-01-comparison/final-hashes.json).

Current master SHA256: `3dfc06fbdcf606e198ba1f0aaca53c2fccb22fdacbf28ddf5ffb1bf2096dbc21`. Paper-linked ZIP SHA256: `7b091482b5358a85be4f80c8a3aea9d32eb6645cc5362124bd4c8f48f8f7b27e`. These identify different generations; neither should be confused with older local audits' then-current V2 snapshot.

## 6. Decision returned to the researcher

**Arithmetic:** the named available calculations can be reproduced from saved ingredients, and the numerical impact of A2 is now explicit. The original outputs have not been changed. Missing-reference and missing-correction cases remain unavailable/untested rather than being filled in.

**Scientific interpretation:** local corrected direction is the preferred target, but a peak sign alone is inadequate. A2 modestly changes G2 ID400, reverses the sink-convention sign of historical ID400 without making its whole interval downward, and does not resolve FB2312's surge/local-fall disagreement. Reviewed windows can encompass onset/recovery maxima surrounding a downward excursion. The paper/code discrepancy also prevents claiming that either current A1 or proposed A2 is simply the published amplitude reproduced.

**Recommended decision:** retain A1 and original contrast labels as the operational saved outputs; accept A2 only as an explicitly exploratory comparison at this stage, with both extrema and the exact correction/reference visible. Do not adopt an automatic corrected-direction classifier or replace an amplitude column from this evidence. Any later implementation decision must specify the intended event/reference semantics and handle mixed excursions and missing correction provenance; that is a scientific choice, not a reporting fix. No new diagnostic campaign is proposed here. G5/release, licensing, hosted CI, live acknowledgement, containment and real-acquisition resource blockers are unchanged.
