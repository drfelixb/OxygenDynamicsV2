# Amplitude availability and native coverage — saved-data diagnostic

12 September 2026. Decision **R2-SUPPORT-013** used two already inspected BOI
development recordings, both signs separately, to quantify measurement support.
All detections, amplitudes and timestamps remain unchanged. No detector,
statistics rerun, source-stack scan, threshold search or animal pooling occurred.
This closes a bounded descriptive check; it does not establish scientific eligibility.

## Finding

Events with finite amplitudes cover only a subset of total detected native
area-time. Event availability by count does not describe that coverage loss:

| Development recording / sign | Finite amplitudes / all events | Coverage unique to unavailable-amplitude events | All occupied fraction | Finite-amplitude union occupied fraction |
|---|---:|---:|---:|---:|
| ID400 sink | 102 / 196 | 61.3% | 0.00620542 | 0.00239995 |
| ID400 surge | 28 / 50 | 66.4% | 0.00893840 | 0.00300249 |
| HP ECS sink | 75 / 168 | 58.1% | 0.00625205 | 0.00262200 |
| HP ECS surge | 20 / 81 | 86.9% | 0.06748025 | 0.00884341 |

The third column divides unavailable-only native area-time by **all detected
native area-time**, not by total tissue-time. The last two columns use the same
recording/sign tissue-time denominator. A finite-amplitude subset is not a
replacement for full coverage. These observations do not estimate cohort-wide
representativeness, missingness mechanisms or detection accuracy.

All unavailable amplitudes in these saved tables have the recorded status
`insufficient_clean_prebaseline`. The status alone does not establish whether
missing clean context reflects biology, interference, acquisition boundaries or
the baseline rule. The one negative HP surge remains finite and included. No
negative-direction correction or event exclusion was applied.

## Overlap, timing and boundaries

For each native frame, support inside the saved sign-specific tissue was
partitioned into three **disjoint** sets: finite-amplitude only, unavailable-amplitude
only, and shared by both. Their sum equals the complete union. The shared set
happens to be empty in these four saved cases; synthetic overlap is explicitly
tested, so this is not an assumption of the calculation.

Event measurement-time and native mask-time differ for sinks:

| Recording / sign | Measurement event-seconds | Native event-seconds | Measurement seconds outside the event's native run | Acquisition start/end contacts |
|---|---:|---:|---:|---:|
| ID400 sink | 2,470 | 1,414 | 1,056 across 152 events | 0 / 2 |
| ID400 surge | 654 | 654 | 0 | 0 / 2 |
| HP ECS sink | 2,705 | 2,056 | 649 across 66 events | 1 / 2 |
| HP ECS surge | 2,975 | 2,975 | 0 | 3 / 0 |

These are sums over events, so simultaneous events contribute separately. They
are not covered tissue-time. The difference is consistent with the saved sink
trace-refinement versus surge native-bound rules; it is not itself a demonstrated
bug or a validated physiological duration. Boundary contact is diagnostic, not
a newly adopted onset-censoring policy. Recurrence flags and individual timing
rows are exported without merging or excluding unusual events.

## Verification and provenance

The completed saved-data pass took **6.55 s** inside MATLAB R2025a. Four synthetic
tests passed, covering nonzero shared support, unavailable/negative amplitudes,
recurrence, timing extension, valid zero versus zero tissue, missing/invalid
masks, event identity and older dimension metadata. The first three tests were
also run before the legacy-dimension case was added.

The audit retained **495 event rows and 3,600 recording/sign/frame rows**.
Native partitions agree with the existing union helper; full sink occupancy
agrees with the preserved whole-recording statistics for both cases. Independent
Python CSV replay checks counts, pixel partitions, physical units, availability,
measurement durations and boundary contacts. Its numerical tolerance is
`1e-10 * max(1, abs(saved value))`, not scientific acceptance.

Two failed attempts remain intact: the initial audit expected `FrameSize` in
older ID400 master metadata; its agreeing saved site-table dimensions now supply
that explicitly labelled evidence. A subsequent reporting harness needed an
explicitly fielded empty structure. Original metadata and calculation inputs
were not changed. The Python runtime lacked matplotlib, so the figure was
rendered using MATLAB; the original plotting attempt is retained.

Local evidence is under
`workspace/reference-validation/boi-measurement-support-20260912/`. The
`completed/` folder contains event/frame CSVs, baseline-status counts, summary,
MAT snapshot, verification report and standalone PNG/SVG figure. Initial and
corrected attempts, tests and source snapshots remain alongside it.
[Structured verification](verification-report.json) and
[artifact record](artifact-record.json) bind source/master/statistics hashes,
code, numerical replay and prior-artifact checks.

## Decision and limits

**Retain current calculations and all events.** Report amplitude availability and
native/measurement support separately; restrict interpretation of a finite-amplitude
subset to its actual observations. Defer scientific baseline, onset/recovery,
missingness and primary-outcome admission decisions. This finding is not grounds
to shorten baselines, discard large events or launch another detector search.

Both examples retain their development role. Their different settings and
biological/source contexts are not pooled or assigned a causal explanation.
HP's unreviewed tissue, provisional identity/calibration and broad source changes
remain unresolved. Confirmed external 1 Hz remains authoritative and the 0.96 s
integration is separate. No anatomical evidence comes from AQuA2 experiments.
The [scientific decision queue](../../BOI_SCIENTIFIC_DECISIONS.md) identifies the
remaining choices and evidence; comparison priority is still awaiting researcher
input. The independent R5 walkthrough remains open.
