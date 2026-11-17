# MATLAB researcher workflow and traceability

Agreed product requirement, 10 September 2026. This is an implementation and
release contract, not a claim that the existing interface already meets it.
Applies to BOI reanalysis and comparable local BOI acquisitions. IOSI is excluded.

## Purpose

A researcher should be able to answer: **What did the software calculate, from
which data, how, and why?** The normal workflow must support those answers
without requiring the user to read MATLAB source code. Source code and detailed
technical evidence remain available for deeper inspection.

The product runs in MATLAB. The current `OxygenDynamics_GUI.m` already provides
a stepwise launcher, input selection, verification, results preview, and links
to run outputs. Extend that workflow and reuse its analysis functions. A
standalone application or a MATLAB-free deployment is not promised by this plan.

## Normal workflow

1. **Import:** select archive-derived or local BOI recordings. Show the selected
   image series, animal/session identity, sampling, physical scale, preparation,
   and what is known about preprocessing. Explain missing or conflicting values
   before they affect analysis; do not infer biological identity from a filename
   alone.
2. **Review:** show each issue, its evidence, the affected measurements and the
   action available. Separate a warning, an excluded measurement, an excluded
   recording, and an import failure. Preserve the original and corrected values.
3. **Run:** show the planned steps, effective settings and their scientific
   purpose. Save that configuration with a unique run identity. Give meaningful
   progress and an actionable explanation if a step fails.
4. **Inspect:** select a recording, event or summary. Show native images/masks,
   quantitative trace, baseline, observation window and exclusions relevant to
   that result. Distinguish detection preprocessing from the signal actually
   used to measure amplitude. Explain uncertain event identity and missing data.
5. **Export:** save results together with a readable methods/calculation guide
   and machine-readable provenance. A collaborator should be able to interpret
   the export without having this conversation or the original desktop session.

Offer concise explanations first and expandable details second. Use familiar
scientific names with units; define technical terms where they appear. A
disabled result must say what information is needed to enable it. Do not label
an uncertain result as valid merely to simplify the screen.

## Calculation record

Each released measurement needs one versioned definition shared by the GUI,
batch exports and methods guide. Record:

- Scientific question, plain-language meaning, formula, units and claim limits.
- Actual input signal, baseline/reference, spatial support and time window.
- Numerator and denominator; aggregation order, weighting and animal grouping.
- Overlap, split/merge, truncation, valid exposure and missing-value rules.
- Effective parameter values, their purpose and the evidence for defaults.
- Links to the relevant input, masks/traces, run and event/recording identifiers.
- A worked example and the function/version that implements the definition.

For example, a proposed occupied-tissue result should explain: "For every valid
frame, we measured the tissue covered by at least one detected sink. Overlapping
sinks count once. We divided accumulated covered area-time by accumulated valid
tissue-time." If these ingredients are 0.12 mm²·min and 2.00 mm²·min, the result
is 0.06, or 6%. This is a teaching example, not a measured cohort result or a
claim that the final implementation has been validated. The export must expose
the actual ingredients used, including excluded support and unavailable time.

Do not confuse that fraction with onset rate, simultaneous event density,
absolute oxygen concentration or damaged tissue. The same level of explanation
is required for baselines, smoothing, thresholding, tracking, amplitude,
recurrence, recovery and statistical summaries when those outputs are released.

## Provenance that survives a rerun

Preserve source identity and content checksums, selected series and axes,
available acquisition metadata, and known prior processing. Explicitly mark
unknown history rather than claiming traceability before the available source.
Record software/configuration versions, resolved settings, time, inputs and
outputs for every run; distinguish defaults from user overrides.

Record automatic and manual decisions with the affected IDs, previous/new
values, reason, supporting evidence, actor or decision origin, and timestamp.
Record failures and omissions as well as successful steps. Curated outputs
must retain their relationship to automatic results. Reanalysis must preserve
or explicitly version prior results so that changes can be explained.

The readable report and structured record must agree. A dense diagnostic log,
an unexplained spreadsheet column, or a final figure alone does not meet this
requirement. Keep private local paths and unpublished metadata out of public
exports unless intentionally included; portable source IDs should retain the
link through a locally stored mapping.

## Work now and later

**Now:** design the measurement dictionary, stable result identifiers, recorded
decisions and exports alongside R0–R4; retain evidence during issue resolution;
fix import failures that prevent researchers using supported recordings. Audit
existing manifests and exports before adding parallel mechanisms. Keep GUI and
batch behavior aligned.

**Later UI pass:** improve layout, visual hierarchy, navigation, tooltips and
interaction after the scientific workflow is stable. That pass can refine how
evidence is presented; it cannot recover provenance discarded earlier.

**Release walkthrough:** a researcher unfamiliar with development imports a
representative recording, understands one QC issue, runs it, traces an event
and recording summary to their source and calculation, and exports them. A
second person reproduces a numerical result from its saved ingredients within
the defined numerical tolerance. A rerun with a changed setting or curation
decision explains the difference and preserves the prior run. Record observed
confusion and failures, correct essential issues, and document remaining limits.
Include a local acquisition in this walkthrough. Resource limits and scientific
validation gates in the main plan still apply.
