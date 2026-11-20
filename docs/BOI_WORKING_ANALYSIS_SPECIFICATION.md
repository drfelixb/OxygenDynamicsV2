# BOI working analysis specification

21 September 2026 · R0-R2-WORKING-SPEC-089 · version 1.0-working

**Proceed with the current detector and recording-specific correction.** The
researcher considers the detected activity useful and accepts some mislabeled
activity at this stage (R0-PROCEED-CURRENT-DETECTION-088). We will use the existing
method to produce traceable descriptive results, retaining its known limitations.
No further recognition/timing optimization or broad diagnostic panel is planned.
Exhaustive manual event relabeling is not required to proceed.

This specification consolidates existing behavior. It does not change formulas,
settings, saved judgments, the proposed outcome hierarchy or recording eligibility.
The automatic measurement dictionary remains **0.3.0-draft**; the separate
reviewed-optical definition remains **0.1.0-draft**. Their draft status records
unsettled scientific admission, not an inability to calculate descriptive outputs.
The [structured companion](planning/boi-working-analysis-spec-20260921.json)
links all 14 measurement IDs to the unchanged dictionary and records their roles.

## Common rules

- BOI only, both saved signs separately. IOSI is outside scope. Fluorescence and
  expression-support assets retain their distinct roles; local/archive copies
  of one acquisition are not additional biological replicates.
- Use the external **1 Hz** trigger: frame 1 has modeled time 0 seconds.
  Embedded timestamps are unreliable; camera exposure is a separate quantity.
- Use each recording's saved, source-bound support profile. A craniotomy can be
  smaller than the field of view. Preserve internal dark tissue, coordinates and
  boundary uncertainty; neither corners nor intensity alone define anatomy.
  Historical whole-image and restricted-ROI outputs must remain distinguishable.
- Keep the original per-recording correction. Do not impose a common substrate
  decline or adjust settings to obtain expected counts, signs or treatment effects.
- Corrected intensity is primary for visual judgments; detection score supports
  them; raw intensity and the removed trend check correction quality.
- Quantitative optical amplitudes use the preserved-input mean over the original
  event's fixed native-union footprint. Never divide by corrected intensity.
- Retain automatic sign/identity, researcher recognition, uncertainty and revision
  history separately. A saved surge can have a pocket-like shape. Acceptance of
  imperfect detection neither relabels individual events nor supplies an error rate.

## Outputs to carry forward

All existing implemented descriptive outputs remain available where their own
inputs permit calculation. Preserve the proposed priorities below until a final
outcome decision; do not silently promote or discard measurements. No single
count or composite stands in for the full activity pattern.

| ID / output | Calculation and working use | Limit or remaining decision |
|---|---|---|
| M01 occupied tissue fraction | Native union covered area-time within eligible tissue / analyzed tissue-time; fraction or percent, separate signs. Candidate primary sink output. | Current implementation assumes static sign-specific tissue and uniform timing. Detected projected coverage, not hypoxic volume or injury. |
| M02 detected onset rate | Saved onsets in the half-open analysis window / tissue-time in mm²·min. Candidate primary sink output, presently descriptive. | Frame-1 events are currently counted. Keep acquisition-start and ongoing-event fields; no claim that every count is a newly observed physiological onset. Final primary claim/censoring choice remains open. |
| M03 concurrent event density | Sum of event overlap time / tissue-time, using matching time units; events/mm². Required companion. | Events each contribute; this is not mask-union occupancy. |
| M04 duration and timing | Inclusive `(end-start+1)/fs`; modeled interval `[(start-1)/fs,end/fs)`. | Native and refined/saved intervals remain distinct. Truncation and timing uncertainty remain visible; duration is not verified physiological recovery. |
| M05 native projected area | Mean native active-frame pixel count × pixel size²; µm². | Different from fixed-union optical footprint. Existing event area is not tissue-intersected, whereas occupancy is. Missing calibration prevents physical area. |
| M06 optical amplitude | `q=(r-B)/B`; saved sink `-min(q)`, saved surge `max(q)`; fraction or explicitly ×100 percent. | Keep unavailable and negative values. A saved-sign amplitude is not biological classification or calibrated pO2. |
| M07 signed trace integral | `sum(q)/fs` over saved event frames; fraction·seconds. | Signed rectangle sum; cancellation is possible. Not an area-time or oxygen-deficit integral. |
| M08 recurrence/history | Ordered recording-local site events and native empty-frame gaps `(next start-previous end-1)/fs`. | Not onset-to-onset recurrence or anatomical matching across sessions. Existing close-neighbor flags do not merge/delete events. Confirmatory recurrence estimator remains open. |
| M09 recovery | Retain review context and unresolved return judgments. | No frozen physiological recovery estimator; do not invent one for cohort export. |
| M10 sink composite | Sum of positive-drop amplitude percent × mean native area × saved duration. Secondary composite. | Keep total unavailable if required contributions are missing/wrong-direction. No surge composite; not union coverage or measured oxygen debt. |
| M11 experimental response | Comparison-specific aligned windows, reference and contrast. | Protocol evidence must support the requested response. No generic event reference or context window substitutes for an experimental baseline. |
| M12 availability | Finite/total counts, reasons and covered-support availability, by sign/recording/animal. Required alongside summaries. | Event availability and represented coverage are different denominators. Zero events does not give a finite event-amplitude mean. |
| M13 animal summaries | Existing descriptive path averages recordings within mouse/group, then finite mouse summaries equally. | Strict within-mouse missingness remains. Final comparison-specific weighting, repeated sessions, inference and multiplicity are not frozen. |
| M14 spatial/cross-sign association | Retain spatial support and both signs for inspection. | No frozen estimator, alignment rule or dependent-data null model; exploratory only. |

IDs above abbreviate BOI-M01–BOI-M14. Exact definitions, units and implementing
functions remain in the [shared dictionary](BOI_MEASUREMENT_DICTIONARY.md) and
[generated guide](BOIMeasurementGuide.md). This table is not a replacement source
of formulas for MATLAB.

## Automatic and reviewed measurements

**Automatic branch — unchanged.** For amplitude/integral, request all immediately
preceding `round(20*fs)` samples before the saved measurement start. Retain the
existing both-sign native-overlap and finite-sample screening. Insufficient
reference samples leave dependent quantities unavailable; no earlier search,
shortened fallback, post-event substitute or zero imputation. Missing amplitude
alone does not remove detected masks, event counts, timing or coverage. This
20-sample rule is not an instruction to remove the first 20 seconds of exposure.

**Reviewed branch — separate exploratory outputs.** The implemented Reviewed
optical tab uses exactly the accepted reference frames for that event and onset,
on the same original fixed footprint and preserved-input trace. It reports the
reference mean, both signed extrema/ties, saved-sign amplitude, mean signed change,
signed integral and reviewed duration/endpoint span. Each saved onset/recovery
combination remains separate. Missing, stale, nonfinite or nonpositive reference
inputs withhold dependent quantities with reasons. It does not update automatic
cohort statistics, native masks, event identities or the automatic baseline rule.

Current FB2314 selections supersede earlier dated proposal examples:

| Saved audit identity | Current reviewed interval(s) | Accepted reference |
|---|---|---|
| row 186, sink site 15/event 36 | Preferred onset 1154; recovery 1166 or 1167 | 1134–1153 inclusive, 20 samples; includes 1152 and 1153 |
| same event, alternative onset | 1149 to 1166 or 1167 | No accepted reference for onset 1149; reviewed optical result unavailable |
| row 308, surge site 1/event 3 | 496–516 | 476–495, 20 samples |
| row 309, surge site 1/event 4 | 536–556 | 516–535, 20 samples; retain preceding recovery contact at 516 |
| row 321, surge site 5/event 1 | 177–195, described by researcher as a pocket | 165–176, 12 samples; preceding approximately 155–165 pocket remains context |

The four saved recognition statuses remain uncertain. Earlier onset 1153 remains
history. The shorter accepted selection does not create a universal 12-sample
reference rule. Five of the seven combinations have computed exploratory optical
results; the two onset-1149 combinations remain unavailable. Source-bound values
and arithmetic are in the [completed comparison](BOI_REVIEWED_AUTOMATIC_COMPARISON.md).

**Optional context — descriptive only.** The fixed 10/20-sample before/after
windows show corrected-intensity medians, range, unscaled MAD, signed contrasts
and contacts. They are neither accepted optical references nor a recognition
screen. They do not replace the 165–176 selection or establish physiological
quietness. The [context view](BOI_TEMPORAL_CONTEXT_VIEW.md) is complete; another
round of labeling is not required to use these outputs.

## Recording and comparison rules

Keep the cohort ledger and its dated [resolution overlay](BOI_COHORT_RESOLUTION.md)
as the identity source. Assess eligibility per measurement/comparison; a limitation
need not block unrelated descriptive quantities. Record unsupported quantities as
unavailable and preserve source/preparation uncertainty.

C02 is the existing worked example, not a newly adopted project priority. Its
seven candidate pairs are FB2312, FB2314, FB2315, ID400, ID401, ID402 and ID403.
The prior proposal is isoflurane-minus-awake per eligible mouse/metric, then an
equal-mouse mean of those paired differences. This remains a proposed final
contrast; the existing generic aggregation does not implement a frozen paired
statistical plan. Show per-mouse values, exposure and availability before inference.

For these separate-state recordings, where induction was not recorded, state
establishment occurred beforehand and its duration was unmeasured. Do not require
an intra-file isoflurane wash-in or recover an unmeasured stabilization duration.
The measured awake session is separate from that establishment period. Retain
awake-first order and preparation limits; make state-associated, not induction-
kinetic or isolated causal-state claims. The S13 600-second illustration does
not authorize trimming all current sources to 600 seconds.

Other families retain their own requirements: C01 is a between-animal state
association with preparation/acquisition differences; C03/C04 whisker and C05 gas
responses need their own actual aligned windows; FB2360 hyperoxia switch times
remain unresolved. C06 microspheres are **4 µm**, with compatible controls still
to be specified. Calibration remains separate, with no universal optical-to-pO2
conversion. F120/F134/F136/M189 retain unresolved calibration/labels; nm200423-A2
retains its preparation conflict. Local HP identities and archive duplication
must not be inferred from filenames or an absence from one ledger.

The eight C02 files from FB2314/FB2315/ID402/ID403 already have complete
local/archive pixel-equivalence evidence. Do not reopen that resolved check;
pre-TIFF intensity history and other records remain distinct questions.

## Minimal delivery record and missingness

Every recording output must identify the animal/session, source/hash/series,
clock, calibration status, support/profile, approved window frames, effective
settings and code/definition versions. Save event identity and native/saved bounds,
mask/footprint and source-trace links, reference ingredients, numerical status,
flags and any separate human annotations. Recording summaries expose numerators,
denominators, finite/total counts, unavailable reasons and the selected sign.
Animal summaries expose contributing recording IDs, aggregation and per-metric N.
Reuse the existing exports; this specification does not introduce a parallel format.

A successful event-free observation with positive valid tissue-time can yield
zero coverage/count/concurrency. A failed run, missing masks, invalid exposure or
an unavailable optical reference cannot become zero. A finite-event amplitude
summary describes that finite subset, not all biological activity. A missing
state-specific metric produces no paired difference for that metric. Do not
substitute an unpaired value or let numerous events create extra animal replicates.

## Remaining work and stopping rule

1. **Prepare the recording eligibility matrix from existing evidence.** Start
   with the seven C02 pairs as the worked set; list exact sources, available runs,
   tissue/frame support, window evidence, metric-specific missingness and unresolved
   facts. Keep descriptive availability separate from final cohort inclusion.
2. **Settle the short list of final analysis choices.** Select comparison priority
   and primary/secondary claims; approve actual observation windows; specify
   animal weighting, repeated-session handling, uncertainty and multiplicity.
   The present imperfect-detector acceptance is already settled and need not be
   asked again. No numerical error tolerance is invented from that acceptance.
3. **Use the current workflow.** Complete the practical researcher walkthrough
   and numerical replay, then freeze settings/inputs/curation and execute the
   eligible cohort with resource limits and documented omissions. Do not make
   cosmetic polish or exhaustive event review prerequisites.

Only reopen method work for a concrete failure affecting a required output or
intended comparison. First state the consequence and whether an existing flag,
claim limit or measurement-specific omission handles it. A new method experiment
needs a named question and stopping decision; an ambiguous event alone is not
such a reason. Preserve exposed-data history; existing development panels are
not independent accuracy estimates. Physiological relevance, biological variability,
feasibility, usability and traceability remain standing requirements.

This consolidation is complete when its references, measurement coverage and
preservation checks pass. It requires no MATLAB rerun, new detector test or source
movie access. See the [project overview](BOI_PROJECT_OVERVIEW.md) and
[consolidation record](reference-results/boi-working-analysis-spec-20260921/README.md).
