# Onset and sustained recovery: two-recording prototype results

9 November 2026. The approved boundary experiment is delivered as a separate Python prototype. FB2413's target onset improves to 826 with similar fits at 824–827. FB2412's proposed onset is rejected because the signal is still rising. Sustained return remains unconfirmed for FB2413 and conditional on an unresolved turning context for FB2412. The prototype does not supply accepted event durations or measurement references. [Open the two cards and existing videos](../../reference-validation/boi-video-boundary-revision-20261109/review.html).

## What was implemented

The new module, `prototypes/boi_video_detector/boundaries.py`, fits a continuous preceding, declining and returning trajectory to each fixed diagnostic cohort. It compares stable and sloped preceding alternatives against simpler constant/linear explanations. Similar-fit costs supply model alternatives. An observed adjoining fall is required before the best-fitting turn can be reported as an onset. A narrow model-fit range does not guarantee a biologically correct boundary.

Return is assessed separately from onset identification and from a stable recovered baseline. The experimental setting requires at least 90% reversal of the observed diagnostic drop. First return uses a five-sample median. Sustained return requires a ten-sample window with at least eight samples above that level, both half-window medians above it, at most one consecutive low sample and no substantial downward relapse between its first and last three samples. Noise does not enlarge the remaining-deficit allowance. The settings were frozen after the ten constructed checks and before either real-window run.

The new assessment preserves previous recognition states, hypotheses, masks and regional evidence. Where the preceding frozen comparison supports a regional component and is stable to comparator omission, its existing local residual is reused without fitting another background model. Raw and additional local return can have different timings. Every output remains measurement-unready and supplies no scientific burden.

## Target results

| Example | Onset | Return and interpretation |
| --- | --- | --- |
| FB2413 site 3/event 6, same 73-block cohort | Best fit 826, similar fits 824–827, adjoining fall observed. The previous fit was 824 with alternatives 817–829. The preceding 10/20-second windows remain recovering. | Previous first-return window 852–856. New first return 869–873; no ten-sample window passes persistence in the retained search through 903. Local return is unavailable because the fixed regional evidence remains unresolved. The measurement baseline remains unresolved. |
| FB2412 site 20/event 1, same 125-block core | Best fit 104, similar fits 102–105, but the adjoining signal still rises. No onset is accepted. These are rejected model-fit alternatives, not a defensible onset interval. The previous fit was 110 with alternatives 103–116. | Conditional on that unaccepted context, first raw return is 181–185 and sustained raw confirmation is 182–191, with 9/10 samples above the threshold. The raw confirmation is still rising. The fixed qualified local component confirms over 174–183, with 8/10 samples above its threshold. These spans do not establish an accepted endpoint. |

FB2413's diagnostic turning level changes from median 1493.5 at 821–823 to 1514.8 at 823–825 as the fitted onset moves. The prior 852–856 median is 1491.2. The new 90% closure level is 1497.4. The later return label therefore reflects both a changed diagnostic reference and a stricter persistence requirement. It is not evidence that the pocket necessarily persists to 869 or that biological recovery is absent. The native 697-pixel ROI still shows the larger episode and preceding recovery. The reviewed 823–825 cue remains a timing annotation; no measurement reference is accepted from it.

FB2412's fitted diagnostic turning level moves downward, from 611.9 to 600.2, while the original reviewed ROI has 2,511 pixels and a different raw trajectory. A stricter remaining-deficit fraction can still produce a misleading endpoint if its starting level is inappropriate. Agreement between the new confirmation's beginning at 182 and the reviewed endpoint at 182 cannot be counted as validation. Original-ROI onset 114, recovery 182 and baseline 104–113 remain preserved. Patch 82 and the existing regional decomposition are unchanged.

## Other fixed comparisons and remaining failures

The earlier FB2413 55-block comparison moves from onset 703 to 692, exactly the beginning of its permitted onset search. It still absorbs a long history before its trough at 794. Despite a narrow model-fit range, this is not successful independent episode separation. First return is 818–822 and sustained return is unconfirmed. A narrow score minimum from a misspecified trajectory model can give spurious timing precision.

The wider FB2412 2,024-block comparison has a best turn at 106, similar fits 105–106, also rejected for lack of an adjoining decline. Conditional raw confirmation is 181–190. Its regional interpretation remains the previous comparator-sensitive result; no new local return is inferred for it.

The three-segment model is too simple for the FB2412 combination of rise, sharper fall, flat trough and subsequent return. The adjoining-fall guard exposes the bad turn but does not produce a replacement onset. For FB2413, reference-level sensitivity and normal fluctuations prevent a strong interpretation of the stricter recovery label. Recognition of a whole pocket, precise onset, return to a diagnostic level and eligibility of a stable measurement baseline remain separate questions.

The ten constructed checks pass their stated behavioural assertions. They do not validate numerical settings, calibrated uncertainty or biological event durations. The missing/truncated fixture correctly withholds sustained return, but its detailed `PostContextEndsAtGap` flag can be false after the onset stage has already clipped the search at the gap. The final unresolved-return state is retained; that cause flag should not be used to distinguish gaps from other post-context limits. This metadata limitation is reported under the frozen method, with no post-freeze repair or tuning.

The 90% closure target and ten-sample persistence are experimental settings, not established biological definitions. Fixed masks are diagnostic supports rather than accepted event areas. The empirical variation estimate uses second differences and does not establish independent observations or statistical confidence. These familiar examples do not estimate sensitivity or specificity.

## Verification and preservation

All ten constructed cases pass before freezing: flat plateau, gradual decline, renewed decline during recovery, earlier activity, recovery without a new decline, partial return, a brief return followed by relapse, sustained return with fluctuations, local return while the region remains depressed, and missing/truncated post-context. No engineering repair was used. There was one configuration and no tuning after the real examples were examined.

The frozen assessment processes the same 30,108 FB2413 and 42,624 FB2412 archived hypotheses in windows 608–1114 and 5–839. These include overlapping alternatives and are not event counts. All 72,732 IDs, mask identities, previous-row hashes and previous recognition states match. Four displayed cohort identities remain fixed. Independent checks reproduce nine fixed/native raw, corrected or qualified-local traces, 550 selected least-squares onset costs and 234 return-window decisions. Both native ROI identities and snapshot arrays match their sources. Both figures were visually inspected. [Verification receipt](../../reference-validation/boi-video-boundary-revision-20261109/verification.json).

The delivery uses three batches, ten constructed cases, one frozen configuration and zero repairs. Peak recorded worker memory is about 605 MiB, below 2 GiB, and derived evidence remains below 256 MiB. The final source check covers 1,377 protected files, including four original movie files and prior scientific results. The original-ROI arrays are read from saved evidence, with no new movie decoding or image analysis.

The burden formula, normalization, complete-burden missingness rule, original recordings, automatic and reviewed measurements, accepted scientific references, export formats and production MATLAB workflow are unchanged. No event area, amplitude reference, burden contribution, partial sum, recording total, GUI integration, Git transport or publication was produced.

The experimental milestone is delivered and stopped, including the unresolved cases. The current model is not ready to assign automatic durations for burden. The cards provide the evidence for deciding whether the segmented boundary model is worth retaining before agreeing any further implementation scope.
