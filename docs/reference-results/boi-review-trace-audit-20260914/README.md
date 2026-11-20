# Review-trace provenance: clarify the human reference before another method

14 September 2026 · R2-REVIEW-TRACE-AUDIT-048

**The candidate comparison used the correct saved middle-panel trace. There is no detected trace-identity or frame-order mismatch.** However, the original review figures displayed several signals, and the feedback did not consistently identify which panel guided the marks. The intended human reference therefore remains to clarify before treating all differences as failures to recover the same feature on the same signal.

This qualifies interpretation of [phase 047](../boi-recognition-timing-execution-20260914/README.md); it does not invalidate its numerical results or establish that another trace would solve the scientific problem. Those candidates remain unadopted. No replacement trace, smoothing rule or event boundary has been selected here.

## What was shown and what was tested

| Display in the original three-panel figures | Saved column | Meaning and support | Used by T2/T3 for timing? |
|---|---|---|---|
| Top blue | `RawMean` | Preserved source mean over this event's fixed native-union footprint | No; used for relative amplitude with its own reference requirements |
| Top orange | `ExistingRemovedTrend` | Raw minus saved per-pixel-corrected mean, on the same event footprint | No; displayed correction context |
| Middle blue | `CubicCorrectedMean` | Existing per-pixel-corrected signal averaged over that same fixed event footprint | **Yes**, for both directional branches |
| Bottom orange | `FilteredMean` | Normalized, spatially/temporally filtered detection signal averaged over the event footprint | No |
| Bottom dotted | `SavedSiteTimingTrace` | Saved site trace; its support is the site's union across its active frames and its processing differs between sinks and surges | No |

The lower dotted line is not simply an alternative plotting style for the middle blue line. In the audited code, sinks use the saved filtered/corrected site trace and surges the saved normalized site trace. The full site support can differ from one event's native union. A switch to a site trace would change more than temporal filtering and must remain explicit.

The audit follows the existing renderer and trace provenance in `auditOxygenEventAmplitudeSource`, `preprocessDetectionStack`, `extractSinkTraces` and `extractSurgeTraces`; it does not recreate those preprocessing stages or infer missing historical metadata. Existing per-recording correction remains intact. No substrate-decay mechanism is assumed.

## Verified evidence

All **ten original plot hashes** match the record of the guided review. Across those ten cases, **10,800 corrected-trace samples** agree between the displayed CSV column and the saved MATLAB array used by the candidate comparison, within 1e−9 absolute plus 1e−12 relative. Event/recording identity, trace column and plot source are recorded in [trace-identity.json](trace-identity.json).

[The endpoint neighborhoods](marked-endpoint-neighborhoods.csv) copy the exact saved values from four displayed signal columns for each supplied endpoint and the two frames on either side: **140 rows**. They retain all supplied alternatives, the separate frame-296 coordinate sensitivity, and the original labels. The two non-recognized examples receive no invented endpoints. This is an inspectable extraction, not a nearest-peak search, new landmark criterion, trace-ranking exercise or new tolerance around the marks. No “best matching” trace is selected from these numbers.

The prior 148 sealed artifacts and all 469 implementation files verify unchanged before the audit. Source hashes, plot identities and extraction checks are in [verification.json](verification.json) and [inputs.json](inputs.json). Only saved evidence was read. No movies, detector, candidate replay, amplitude recomputation, new correction or statistics ran.

## What the researcher already clarified

The earlier comments already support treating the full local excursion and recovery as the object of interest, rather than every small fluctuation. Example 1 explicitly accepts a brief recovery peak even if another decrease follows; a sustained flat return cannot be imposed as a universal requirement. Example 3 retains alternative plausible onsets. Example 7 was not recognized because the brief small decrease remained within the surrounding variability; that does not establish a universal minimum amplitude or duration. The original recording-specific correction must be respected without overinterpreting substrate decline.

No additional explanation is inferred for examples 5 and 8, which have supplied bounds but no explicit onset/offset rationale. Their marks do not by themselves define a general recovery-level tolerance, a prominence cutoff, or the panel used for the judgment. The named physiological uncertainties, weak and sustained events, recurrence and spatial support remain in scope.

## The specific clarification needed

**Which trace or combination of traces mainly guided the supplied marks: top raw, middle corrected, bottom filtered, or several panels together?** This is a reference-definition question, not a request to approve code or redo the eight annotations. The question has been presented to the researcher; no answer is assumed.

- If the middle corrected trace was the intended timing reference, the recent comparison used that reference. Its failure to separate the main excursion from nested fluctuations and its recovery overshoot then remain the relevant method limitations.
- If the raw or filtered trace guided the marks, record that provenance first. A comparison on it would be a new, explicitly specified diagnostic; do not silently substitute it or transfer the current recognition screen's signal units.
- If several panels were used together, preserve that as a composite visual judgment. It does not supply an automatic rule for combining the signals or justify selecting whichever panel best matches each event.

The source audit is complete; this clarification remains open. Hold the next scientific method proposal until the intended reference is known. The existing corrected-trace comparison, source amplitudes, annotations, rejected candidates and uncertainty stay preserved. BOI-only scope, both signs, biological variability, physiological relevance, feasibility, usability, traceability and unresolved anatomical/cohort/HP identity and independent-validation requirements remain unchanged.

For context, the original [HP surge figure](../boi-timing-execution-20260913/review/HP-ECS-identity-pending/surge-site6-event3/timing-review.png) and [ID400 sink figure](../boi-timing-execution-20260913/review/ID400-awake/sink-site45-event1/timing-review.png) are the same displays reviewed earlier; they have not been replaced or relabelled.
