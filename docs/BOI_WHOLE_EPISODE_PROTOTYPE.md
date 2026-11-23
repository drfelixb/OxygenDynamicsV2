# Whole episode prototype preview

The saved event reviewer includes an optional **Episode prototype** tab. It scans the full saved raw and corrected traces on the selected sink footprint and proposes temporal episodes. The saved automatic event is an annotation, not a search boundary. This experimental model does not change the working detector or any saved scientific result.

## Inspect a saved footprint

Open a saved event audit with `openBOIEventReview`, select a sink event and choose **Episode prototype → Scan full saved trace**. Nothing runs merely by opening the tab or changing the selection. Choose a proposal row to view its context on both traces, or **Show full recording** to restore the full temporal view. Selecting another footprint clears the previous result. The prior **Whole-event preview** remains available separately.

A table row belongs to a stage and proposed interval at this footprint. It is not an accepted reclassification of the selected saved event. Related saved footprints can propose the same episode, and multiple rows can be competing interpretations of one trajectory. Do not count or sum rows as independent biological events.

## Read the display

Green lines mark the selected proposed interval; the green curve is its fitted episode. Blue shows the fitted background component, and grey dashed shows the best competing background explanation. Red lines mark the original saved event. Raw and corrected traces remain separate; selecting a raw proposal does not establish the same outcome on the corrected trace.

The model compares a depression and return against linear/curved trends and step/slope transitions. Durations and shapes vary within the explicit numerical grid. An outcome of **pocket candidate** means the episode model exceeds its computational evidence margin and contains a decline and return relative to its fitted background. **Background like** means a competing model scores better. **Uncertain** retains close or insufficient phase evidence. These are provisional model outcomes, not scientific acceptance or calibrated probabilities.

Boundary cautions describe low signal at a recording or missing-sample edge without the preceding state or recovery. They do not substitute a later baseline or establish a pocket. Missing samples are not interpolated to assert a complete event.

## Search settings and limits

`boiWholeEpisodeSettings` records the experimental settings. The initial primary search uses 6–384 seconds with triangular and flat-bottom/asymmetric profiles, a linear joint background and competing curved/transition models. A numerical evidence score penalizes added model parameters; its gain is not a percentage or probability. A numerical noise floor prevents degenerate arithmetic and is not a biological amplitude threshold.

Only the strongest 120 matched-filter seeds per stage reach model comparison. The panel explicitly reports whether this cap was reached, unsupported durations and boundary cautions. Weak or atypical episodes may therefore be missed. Timing alternatives cover nearby screened fits within a score band; they are not statistical confidence intervals. A single reported timing pair can still be limited by the duration/shape grid.

Saved native masks originate from the old detector and provide supporting context rather than independent confirmation. The prototype cannot search spatial locations absent from the saved footprints. Broad or spatially shared depressions are not automatically rejected as background.

## Recognition and burden remain separate

The fitted background is a model/display component, not a replacement correction or an approved measurement reference. No new amplitude, baseline, area or burden is calculated here. Prototype results have an experimental-only role and no scientific Save or export control. Existing reviewed recognition decisions and event-specific measurement references remain authoritative for the existing reviewed workflow. The burden formula, normalization, original export formats and complete-contribution requirement are unchanged.

A researcher must assess model failures and suitability before any production adoption. The preview can help compare whole episodes without asking for exact boundaries at every second; it does not yet replace scientific review.
