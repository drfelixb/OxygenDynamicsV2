# Camera dark offset

A camera can report a positive count even when no light reaches its sensor. This adds a constant to both the event and its reference. For example, a fall from 120 to 100 counts is a 16.7% drop on the recorded scale. If the camera contributes 20 counts, the same fall is a 20% drop.

## Measuring and entering the offset

Block light from reaching the detector and acquire dark frames with the exposure time, gain, temperature, readout mode and binning used for the movie. Average the dark counts across frames and the sensor region used for the recording. Enter that single value in original camera counts. Motion correction and denoising must preserve the original count scale. An intensity rescale, baseline removal or additional dark subtraction changes what the number means.

Use `CameraOffsetCounts` in a single-recording options structure or batch column. In a paired options structure or one-row-per-recording batch, enter `CameraOffsetCountsA` and `CameraOffsetCountsB` separately. A two-row-per-recording channel list uses `CameraOffsetCounts` on each channel row. Leave the cell blank to use the original definitions. An explicit zero records user-supplied calibration. Supply a finite number greater than or equal to zero.

## Reading the measurements

Let *I* be the preserved footprint intensity, *B* its original reference mean, and *O* the supplied offset. With a supplied offset, the signed fractional change is **q = (I − B) / (B − O)**. A blank uses the original denominator *B*. References, per-frame counts and fitted drift traces remain on their original count scale.

| Measurement | Calculation |
| --- | --- |
| Strict automatic sink depth and surge rise | Sink depth is −100 × min(q). Surge rise is 100 × max(q). |
| Event-local sink depth and pre-episode depth | 100 × (B − minimum event count) / (B − O), using the saved reference frames for that rule. |
| Mean change and signed integral | Mean(q) and sum(q) / sample rate in fraction-seconds. |
| Event burden | Selected depth in percent × mean event area × event duration. Area and time normalization use the original exposure. A required missing contribution withholds the total. |
| Reviewed optical interval | Minimum and maximum q, saved-sign directional amplitude, mean(q) and sum(q) / sample rate on the reviewed frames. |
| Reviewed pocket | For the raw companion use 100 × min(q). For the primary value use 100 × min(drift-corrected event trace − mean drift-corrected reference) / (mean original reference − O). |
| Reviewed frame-area display | Each pixel’s map shows 100 × (current count − that pixel’s reference mean) / (reference mean − O). Nonpositive denominators are masked. Frame decisions and pixel areas use the saved geometry. |
| Paired traces | Use each channel's own B and O for 100 × q at each frame, the anchor extreme and the event mean. |
| Pocket and nearby tissue | Use each region's own pre-onset mean for 100 × q. Subtract the nearby percentage from the pocket percentage for local excess in percentage points. |
| Baseline diagnostic | Normalize slope, spread and residual size by B − O. The fitted-line diagnostic uses its original fitted reference at each frame minus O in that frame's denominator. |

`reference_at_or_below_camera_offset` identifies an unavailable ratio. The recording quality note `ReferencesAtOrBelowOffset` counts finite references at or below O, once per event and reference role. The recording master counts strict references for both signs and event-local, pre-episode and recording-wide references for sinks. Paired results also count each channel’s references on the selected footprints. The nearby-tissue export also checks each sampled region. Repeated uses of the same frame interval can count separately.

`CameraOffsetSource` distinguishes `user_supplied` from `not_supplied`. `IntensityRatiosOffsetCorrected` describes the percentage and fraction columns. Raw trace columns always show original counts. `IntensityRatioDefinition` identifies the automatic dictionary version. Reviewed pocket and interval results also carry their own version. A mixed batch can be identified from the recording rows and correction counts. The counts include analyzed recordings with zero events. A compact workbook excludes unanalyzed rows from the counts, and a nearby-tissue summary excludes recordings omitted from that export. Earlier saved runs use their original definitions and a blank offset.

Comparisons between raw intensities use the original counts. This applies to `AboveRecordingReference` and to the direction of an event relative to its own reference.

Rank-weighted burden ranks the selected `BurdenAmplitudePercent` values within each recording. With an offset, two depths can change order because their reference intensities differ. An unavailable depth has no rank. `BurdenRankInput` identifies the ranked field. `OriginalCountRankAmplitudePercent` preserves the depth on the original count scale for comparison.

Pocket and nearby-tissue summaries use the same reported percentages for their means, intervals and counts. A pocket counts as above baseline and ring when its percentage is positive and exceeds the ring percentage. The mouse counts apply those comparisons to each mouse’s means. `PocketRingCountBasis` records `reported_percentages`. The `*OriginalPct` columns preserve the original percentages for comparison.
