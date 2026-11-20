# C02 measurement-specific readiness and next execution

12 September 2026 — **R1-C02-READINESS-027: consolidation complete; no scientific eligibility or mask/window approval.**

The eight sources can enter the existing **conditional descriptive MATLAB path**
with explicit support and observability assumptions. Interpreting normalized
results as observable tissue coverage or physiological event rates still needs
justified support/exposure and endpoint-specific decisions. Uncertain anatomical
area does not by itself prevent calculating a detected event's duration or
preserved-input relative optical amplitude. Support nevertheless affects candidate
admission, so those event populations remain conditional on the chosen mask.

The recent audits did not run the event detector on these eight sources. Their
fresh event values and event-level availability are therefore **not computed**,
never zero, finite or scientifically accepted by this report. Legacy MAT headers
were inventoried, but their event values are not new outputs of the current
pipeline. The next useful work is one fresh recording workflow to expose actual
availability, using unchanged defaults and preserving every earlier result.

This is a requirements overlay on dictionary **0.3.0-draft**, not a definition
change, numerical acceptance threshold, new automatic software gate or outcome
freeze. It covers FB2314, FB2315, ID402 and ID403 (eight recordings), a subset of
the seven C02 candidate mice. FB2312, ID400 and ID401 do not inherit this review.
Both BOI signs remain in scope; no IOSI or AQuA2 analysis is introduced.

## Facts resolved and questions retained

| Question | Current evidence and consequence |
|---|---|
| Source identity/archive membership | 019/020 bind all eight sources to pinned DANDI assets with whole-pixel equality. Retain FB2315 identity despite FB2314 in its TIFF filename. Earlier unverified-equivalence statements are superseded only for these eight sources. |
| Timing | External triggering is exactly 1 Hz; original frame indices define intervals. Incorrect embedded clocks do not drive analysis. Camera exposure duration remains separately unknown. |
| Isoflurane context | 022 establishes separate pre-established states; the establishment interval was unmeasured. A numerical stabilization duration or within-file induction baseline is not a C02 prerequisite. No induction-kinetics claim follows. |
| Static support | 023 reproduces the automatic percentile support and sign border. 024 supplies eight explicit unadopted outlines. Neither constitutes validated observable anatomy. ID402 iso has weak evidence around its entire perimeter. |
| Temporal observability | 025 covers all 7,200 frames diagnostically; 026 reviews six flagged local sequences. No justified exclusion was established from those flags. Full-frame validity, fine motion and local optical effects remain uncertain. |
| Full-file exposure | Within each mouse, awake/iso nominal lengths already match. No trimming is needed merely for pairing. Full-file duration is a descriptive modeling extent, not an approved biological exposure window. S13's historical 600-frame selection from longer files remains a reproduction question. |
| Pre-source preparation | Local-to-archive equality does not recover earlier intensity transformations, motion parameters or camera integration. Restrict optical and acquisition-comparability claims accordingly. |
| Prior use and biological unit | Publication use permits reanalysis. These sources have now been inspected and cannot be labelled untouched. Mouse is the biological replicate; R4 weighting and metric-specific pairing remain proposed. |

Evidence: [input audit](../boi-c02-input-20260912/README.md),
[pixel equivalence](../boi-c02-provenance-20260912/README.md),
[experimental context](../../BOI_C02_EXPERIMENTAL_CONTEXT.md),
[automatic support](../boi-c02-support-20260912/README.md),
[draft outlines](../boi-c02-outline-proposals-20260912/README.md),
[temporal diagnostic](../boi-c02-temporal-20260912/README.md),
[focused review](../boi-c02-sequences-20260912/README.md).

## Recording-specific denominator evidence

These are **preserved automatic-mask calculations**, not adopted anatomical
areas or valid tissue-time. Sink/surge order is explicit. Values are rounded
here; [recording-readiness.json](recording-readiness.json) retains numerical
values, source/asset identities, every boundary question and focused-review scope.
The uniform modeled interval for frame f is [f−1,f) seconds; nominal exposure ends
at 1200 or 600 seconds even though the final frame label is 1199 or 599 seconds.

| Mouse / state | Nominal seconds | µm/pixel | Automatic sink / surge area, mm² | Nominal sink / surge area-time, mm²·min |
|---|---:|---:|---:|---:|
| FB2314 / awake | 1200 | 2.35 | 0.8948 / 1.0021 | 17.896 / 20.042 |
| FB2314 / isoflurane | 1200 | 2.35 | 0.8756 / 0.9883 | 17.513 / 19.766 |
| FB2315 / awake | 1200 | 2.35 | 0.8902 / 0.9891 | 17.805 / 19.781 |
| FB2315 / isoflurane | 1200 | 2.35 | 0.8718 / 0.9894 | 17.437 / 19.788 |
| ID402 / awake | 600 | 4.75 | 3.5872 / 4.0698 | 35.872 / 40.698 |
| ID402 / isoflurane | 600 | 4.75 | 3.4832 / 4.1056 | 34.832 / 41.056 |
| ID403 / awake | 600 | 4.75 | 3.6191 / 3.9907 | 36.191 / 39.907 |
| ID403 / isoflurane | 600 | 4.75 | 3.6543 / 4.0022 | 36.543 / 40.022 |

The existing 20-pixel sink border is 47 µm for FB2314/FB2315 and 95 µm for
ID402/ID403. It remains an explicit acquisition-scale difference, not an endorsed
physical rule. An accepted support change would alter spatial bins/candidate
admission as well as denominator area. Recompute in a fresh stage; never divide
old event numerators by a replacement mask area and present that as the new result.

## Measurement decision map

“Fresh conditional descriptive run” means the implementation can produce
source-traceable outputs under stated assumptions. It does not mean current
values exist or are scientifically admitted. An input-only availability inventory
is available now; event availability requires actual new outputs.

| Measurement | Direct tissue-area denominator | Current next route |
|---|---|---|
| BOI-M01 Mean occupied tissue fraction | required | fresh conditional descriptive run |
| BOI-M02 Detected event onset rate | required | fresh conditional descriptive run |
| BOI-M03 Mean concurrent event density | required | fresh conditional descriptive run |
| BOI-M04 Event duration and timing | not directly required | fresh conditional descriptive run |
| BOI-M05 Mean native projected event area | not directly required | fresh conditional descriptive run |
| BOI-M06 Relative optical event amplitude | not directly required | fresh conditional descriptive run |
| BOI-M07 Signed trace integral | not directly required | fresh conditional descriptive run |
| BOI-M08 Local recurrence and event history | not directly required | fresh conditional descriptive run |
| BOI-M09 Local recovery | definition unresolved | definition required |
| BOI-M10 Amplitude-area-duration composite | required only for normalized variant | fresh conditional descriptive run |
| BOI-M11 Experimental response and positive dynamics | inherits endpoint requirements | comparison plan required |
| BOI-M12 Measurement availability | inherits reported metric; input inventory needs none | input inventory now event QC after fresh run |
| BOI-M13 Animal-level summaries and contrasts | inherits endpoint requirements | comparison plan required |
| BOI-M14 Spatial and cross-sign association | definition/annotation dependent | definition or annotation required |

The [14 requirement records](measurement-requirements.json) preserve dictionary
names, proposed roles and implementation references. The [112 recording × measurement records](recording-measurement-readiness.json)
and [tabular version](recording-measurement-readiness.csv) keep generic endpoint
requirements and recording-specific boundary uncertainty together. All scientific
admission fields remain unassessed. M14 distinguishes the unfrozen cross-sign
estimator from existing auxiliary geometry functions requiring aligned annotation.

**BOI-M01 — Mean occupied tissue fraction.** Native per-frame mask unions and selected sign support; every original interval retained. Scientific question: Justified observable tissue-time and detection validity for interpreted tissue coverage. No amplitude baseline needed. Finite baseline failures must not remove native coverage.

**BOI-M02 — Detected event onset rate.** Saved event onsets plus positive modeled sign area-time; expose acquisition-start counts. Scientific question: Justified support/exposure and onset identity/censoring before physiological onset-rate claims. Do not adopt OnsetsAfterAcquisitionStart as a replacement estimator merely because it is exported.

**BOI-M03 — Mean concurrent event density.** Saved event overlap time and positive modeled sign area-time. Scientific question: Justified support/exposure and event identity; native occupancy and refined event time differ. Concurrent density counts overlapping events individually; occupancy unions their pixels.

**BOI-M04 — Event duration and timing.** Saved native and measurement event bounds, exact 1 Hz, timing-resolution flags. Scientific question: Physiological onset/return criteria, censoring and observability over each relevant interval. An anatomical area denominator is not in the duration formula; admission/timing can still depend on support and preprocessing.

**BOI-M05 — Mean native projected event area.** Native masks with canonical physical scale, full-image coordinates and outside-support annotations. Scientific question: Native projected geometry and admissible interpretation; acquisition-scale sensitivity. Event area is not tissue-intersected. Do not silently clip it; that would redefine the measurement.

**BOI-M06 — Relative optical event amplitude.** Preserved-input union-footprint trace, 20 immediately preceding clean seconds, both-sign overlap and baseline status. Scientific question: Footprint observability, baseline interpretation and prior intensity-history claim restrictions. Unknown anatomical denominator alone does not prevent optical arithmetic. No earlier/post-event fallback, no negative-to-positive conversion.

**BOI-M07 — Signed trace integral.** Same source trace/baseline as M06 and saved event interval, rectangle sum at exact 1 Hz. Scientific question: Baseline and event-interval validity; optical signed integral only. Fraction-seconds is not a measured oxygen deficit or volume integral.

**BOI-M08 — Local recurrence and event history.** Native event/site order, empty-frame gaps, observation boundaries and close-run flags. Scientific question: Site identity, intervening observability and censoring for a recurrence estimator. No neighbour is not infinite recurrence; a close-run flag alone never merges or excludes.

**BOI-M09 — Local recovery.** Retain traces and unresolved-return evidence only. Scientific question: Define reference, return threshold, persistence, support and censoring before an estimator. Trace-refined event termination is not established physiological recovery.

**BOI-M10 — Amplitude-area-duration composite.** Matched M04/M05/M06 components and contribution availability; modeled tissue-time for normalized variant. Scientific question: Component validity, composite rationale and support/exposure for normalized use. Missing/wrong-direction required contributions keep total unavailable; no finite-subset total and no surge composite.

**BOI-M11 — Experimental response and positive dynamics.** Source summaries and preserved traces may be inspected; separate C02 states are established before recording. Scientific question: Metric eligibility, selected state exposure and comparison design; no induction kinetics without measured administration. Unmeasured establishment duration is not a C02 comparison prerequisite. Full-file descriptive extent is not experimental approval.

**BOI-M12 — Measurement availability.** Report source/QC facts now; after a fresh run report detected, measured and unavailable events/support by reason. Scientific question: Detected-event denominator and coverage availability must be explicit; no unsupported missing-at-random assumption. Uncomputed or failed is not successful zero. Zero events gives no event-amplitude mean or availability fraction.

**BOI-M13 — Animal-level summaries and contrasts.** Retain per-recording ingredients and source-linked candidate pairs. Scientific question: R4 weighting, paired metric availability, repeated-session rule, uncertainty and multiplicity plan. Four recently audited mice are a subset of the seven C02 candidates. No frame/event pseudoreplication or automatic complete-case pairing.

**BOI-M14 — Spatial and cross-sign association.** Preserve native geometry; vascular distance additionally needs justified aligned vascular annotations. Scientific question: Specify spatial/time relation and nulls; cross-session matching needs independent alignment evidence. No frozen cross-sign estimator or aligned annotation is supplied by this packet; do not manufacture association values.

## Decisions required for interpretation

1. **Tissue and candidate support:** justify a static observable field for each
   source and record weak/clipped boundaries. Preserve internal dark BOI regions.
   Review the sign border and accepted outside-support fraction as separate
   methodological choices; do not silently change them with a polygon.
2. **Observable time and experimental exposure:** retain unknown frame validity
   separately from modeled inclusion. Resolve a measurement's required local
   observability before claiming valid exposure; no score cutoff was validated.
   If an invalid frame is demonstrated, the current pipeline cannot accept a
   partial `FrameValid` declaration without a focused implementation decision.
   Deleting or renumbering frames is not a workaround.
3. **Event interpretation:** keep native versus refined timing, baseline
   missingness, split/merge and observation-boundary uncertainty visible. The
   immediately preceding 20-second event baseline is not an experimental baseline
   or a reason to remove the first 20 seconds from coverage.
4. **C02 inference:** endpoint eligibility, outcome hierarchy, equal-mouse pairing,
   missing-pair handling and uncertainty/multiplicity require the existing R2/R4
   scientific decisions. A finite result or a successful software run supplies
   evidence; it does not decide those policies.

These questions are not blanket file-import failures. Missing annotation for a
vascular association does not invalidate every optical metric; unavailable event
amplitude does not remove detected native coverage. Conversely, an amplitude
value cannot validate tissue-time, and an unprocessed source cannot be a valid
zero-event record. Biological variability and physiological interpretation remain
standing requirements at every layer.

## Concrete next MATLAB run

The [bounded run specification](next-descriptive-run.json) selects
**FB2314-baseline-awake**, asset `9ce94e52-e1d9-446d-a758-66db41a698e6`, all 1200
frames at 1 Hz and 2.35 µm/pixel. It is first in the existing eight-source audit
order, adding this C02 acquisition scale to the earlier ID400 and HP walkthroughs.
This is not selection for a desired result or a claim that it represents every
mouse or state.

Use one fresh, byte-identical source stage, one normal master and one statistics
export. Retain unchanged automatic support/default detection, both signs and
all original intervals under explicit assumptions; do not adopt an outline,
import legacy curated outputs or request a biological contrast. The planned
[acquisition declaration](BOIInputMetadata.proposed.json) records confirmed 1 Hz,
unreliable file clocks and three source-review issues. It leaves camera exposure,
frame validity and pre-source intensity history unknown. It is **proposed**, not
installed beside an original recording or captured by an actual master.

The existing MATLAB parser accepts this declaration and preserves its unknowns:
[parser check](declaration-verification.json), [review notices](declaration-qc.csv).
This is an in-memory schema/compatibility check, not a new recording preflight or
scientific approval.

The execution budget is one master and one stats run with two workers, a
900-second soft gate before the next major stage, and a 5 GiB output review target.
Check resources beforehand and measure process memory. The earlier 1200-frame HP
run used 12.52 GiB peak process RSS; it is not a guarantee for this source or total
machine demand. Preserve any failure and fix only a demonstrated execution defect;
do not tune scientific settings to finish faster.

Required evidence is both-sign event/measurement availability, preserved NaNs and
negative directional amplitudes, native occupancy and sign-specific area-time,
boundary diagnostics, and a source-trace numerical replay. Select the first finite
event in saved row order for each sign as a worked example, or state why none is
available; keep all-event availability alongside it. Stop after this single
recording. No second state/mouse, mask adoption or biological comparison follows
automatically.

## Verification and provenance

[Verification](verification.json) checks unique 8 × 14 coverage, source identity,
unchanged dictionary roles, nominal support arithmetic, preserved unknowns and
empty approval/exclusion fields. [Repository evidence bindings](evidence-bindings.json)
and [prior-data bindings](input-evidence-bindings.json) identify exact source
records used. No new recording pixels were read, event outcomes loaded, detector
or registration run performed in this consolidation. Previous artifacts and
existing implementation changes are preserved in the [artifact record](artifact-record.json).

The consolidation phase is complete. R1 scientific support/exposure eligibility,
R2 measurement admission, R4 inference and independent researcher usability remain
open. The next activity is the single descriptive workflow specified above,
producing actual availability evidence rather than another unconstrained source scan.
