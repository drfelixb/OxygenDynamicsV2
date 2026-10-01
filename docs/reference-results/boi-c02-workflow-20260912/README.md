# FB2314 awake: fresh BOI MATLAB workflow and measurement availability

12 September 2026 — **R1-C02-WORKFLOW-028 completed: one master, one statistics export, both-sign numerical/source replay passed.**

The unchanged pipeline detected **219 sinks and 49 surges**. Finite event-relative
amplitudes are available for **109 sinks and 13 surges**; all other amplitudes
lack the required clean pre-event baseline. Two negative directional surge
amplitudes are retained. All 268 independent MATLAB source-amplitude checks agree
with the saved measurements. Python independently reproduces both signs' native
coverage and the two selected source traces.

These are descriptive results from unvalidated automatic support and explicitly
assumed observability, not an anatomical/physiological acceptance or C02 contrast.
The selected surge reaches a dim field margin and occurs within a broader optical
rise. Those observations remain scientific questions rather than automatic
exclusions. No scientific default, mask, baseline rule or source frame changed.

## Source, execution and preserved assumptions

- **Mouse/session:** FB2314 / FB2314-baseline-awake; portable run ID
  `dandi000891_FB2314_awake_028`.
- **Archive asset:** `9ce94e52-e1d9-446d-a758-66db41a698e6`, DANDI 000891 version
  0.240215.0831; prior whole-pixel equivalence is retained from 020.
- **Original source SHA-256:**
  `08381f8ef4cb0da80a09645aeffc9416188cf7937eaf207c0536f1f997494cf8`.
- **Input:** 512×512×1200, 2.35 µm/pixel, exact external 1 Hz. Original frame f
  represents modeled interval [f−1,f) seconds. All 1200 intervals remain included
  in the descriptive model; declared frame validity and camera exposure are unknown.
- **Scope:** BOI sinks and surges, one already published/inspected awake recording.
  No isoflurane state, other mouse, IOSI, AQuA2 result or legacy curation was loaded
  as new analysis input. Publication and inspection preclude an untouched role.

The original TIFF was copied byte-for-byte into a new local `run-01/Recording`
folder. Only that fresh stage received [BOIInputMetadata.json](BOIInputMetadata.json)
and generated outputs. The declaration confirms 1 Hz and retains unreliable
file-clock status plus support, temporal-validity and intensity-history review
issues. It was captured by the master; it was not added retrospectively to old
outputs. [Metadata provenance](metadata-change.json) records the change from the
027 proposal to the actual stage origin/time. No reviewed tissue sidecar was
supplied; the 024 draft remains unadopted.

The normal MATLAB `runOxygenDynamicsMaster` and `runOxygenDynamicsStats` entry
points were used with two thread workers. [Effective defaults](effective-master-settings.json)
match `createOxygenMasterParams(2.35,1)` exactly, including both 20-second baseline
rules and the existing sign-specific support/border. The whole-file [0,1200)
extent is descriptive, not an approved biological analysis window. Pre-recording
state establishment remains distinct from an event baseline, and its unmeasured
duration is not imposed as a prerequisite.

## Actual availability

| Sign | Detected events | Finite amplitude | Unavailable amplitude | Negative finite amplitude | Covered area-time attributable only to unavailable-amplitude events |
|---|---:|---:|---:|---:|---:|
| sink | 219 | 109 (49.8%) | 110 | 0 | 76.6% |
| surge | 49 | 13 (26.5%) | 36 | 2 | 89.6% |

The coverage column uses native support intersected with the actual automatic
sign mask and is within-sign only. It is **not a share of all tissue-time**, and
it is not pooled across signs. Here finite/unavailable coverage has no shared
pixels within sign, as explicitly checked. Merely reporting finite-event means
would omit events responsible for 76.6% of detected sink covered area-time and
89.6% of detected surge covered area-time. This does not establish missing-at-random
or imply what their missing amplitudes would have been.

Of the 110 unavailable sinks, 102 have detected overlap in the preceding baseline,
7 have recording-start truncation alone, and 1 has both. All 36 unavailable surges
have detected baseline overlap. No nonfinite source samples were found in those
baseline checks. These are [disjoint reason counts](availability-reasons.json);
the full [event audit](event-amplitude-audit.csv) retains source hashes, exact
counts/statuses and mismatches. “Valid” baseline status means the current
algorithmic rule passed, not that biological context was stationary.

Unavailable amplitudes stay NaN, their events remain in native coverage, and
negative directional amplitudes stay negative. The sink composite remains
unavailable when required amplitudes are missing. No surge composite is defined.
Neither unavailable quantity becomes zero or a sum over only convenient finite
contributions. [Both-sign QC](measurement-availability.csv) also retains timing,
recurrence, tracking and contact flags.

## Conditional coverage and timing ingredients

| Sign | Automatic analyzed area, mm² | Modeled area-time, mm²·min | Covered area-time, µm²·s | Mean occupied fraction as percent |
|---|---:|---:|---:|---:|
| sink | 0.894810675 | 17.896213500 | 6159398.880000 | 0.573622% |
| surge | 1.002090760 | 20.041815200 | 36404154.325000 | 3.027350% |

These exact support areas reproduce the prior unchanged-default audit. They do
not resolve anatomical support or dynamic validity. Each sign's folder contains
native union/support arrays, full frame ingredients, event measurements,
availability partitions and window metrics. Overlaps count once in coverage;
event-time density counts each event separately. The input/QC export preserves
why interpretation is conditional: [recording review](recording-input-qc.csv)
and [all frame-exposure records](frame-exposure.csv).

Three sinks have saved measurement starts at acquisition frame 1; the current
descriptive onset numerator includes them. That is not proof of new physiological
onset. Two sinks and one surge contact the recording end. For 166 sinks, refined
measurement time extends outside native detection bounds; total sink measurement
time is 3177 event-seconds versus 1760 native event-seconds. These quantities
cannot substitute for each other. No censoring, timing or grouping policy was
changed to obtain these outputs.

## Two worked source-to-result examples

Selection was fixed as the first finite amplitude in saved event-row order for
each sign. These examples demonstrate calculation, not typical biological quality.
Both use 20 immediately preceding clean samples, with no earlier or post-event
replacement. Baseline cleanliness was checked against both signs' native overlap.

| Sign | Site / event | Measurement frames | Native frames | Baseline, stored source units | Directional amplitude | Signed integral, fraction·s |
|---|---|---|---|---:|---:|---:|
| sink | 1 / 2 | 443–450 | 448–450 | 6053.483795 | 9.346906% | -0.507072860 |
| surge | 1 / 1 | 108–118 | 108–118 | 3583.537036 | 9.003833% | 0.716420533 |

Inspect [sink source/support and traces](sink/example-detail.png) and
[surge source/support and traces](surge/example-detail.png). The initial
same-frame native-mask inspections remain [sink](sink/example-inspection.png)
and [surge](surge/example-inspection.png). The detail panel's cyan outline is
the **union footprint** used for the trace, not a claim that every footprint
pixel was active in that displayed frame. White denotes automatic included
support; orange denotes the native time span.

The sink has a local drop/partial return against a broad changing full-recording
trace; its refined bounds begin five frames before native detection. The surge
union reaches the dim right margin, and its optical trace rises during baseline
and continues beyond its native event bounds. Clean detected context does not
establish a flat physiological reference or isolate an event from a broader
response. These [visual findings](visual-review.json) are retained without
classifying the causes or excluding either example.

For each example, `example-footprint.csv` contains one-based MATLAB column-major
native indices; `example-trace.csv` contains all 1200 source means and explicit
baseline/event flags. Reproduce B0 from the flagged baseline, q=(I−B0)/B0, then
−min(q) for sink or max(q) for surge over the saved event interval. Sum q at 1 Hz
for the signed integral. The source image and whole-recording trace have not been
replaced by detection-normalized values.

## Verification and feasibility

- **Execution:** master 59.42 s; statistics 55.43 s;
  function elapsed 134.58 s, process wall 140.46 s.
  Initial output was 3.05 GiB, below the 5 GiB review target.
- **Source/measurement audit:** 19.37 s inside MATLAB, separate
  process wall 28.91 s; all 268 amplitudes/statuses matched.
  No detection preprocessing was reconstructed or retuned.
- **Independent Python replay:** all 2400 sign/frame native-union and availability
  partitions, exposure/normalization arithmetic and 2400 source-trace samples for
  the two selected footprints passed. Their baseline overlap and signed integrals
  were rechecked. Original/staged TIFF hashes and the saved statistics MAT match.
- **Preservation:** dictionary 0.3.0-draft and all 461 current MATLAB implementation
  files match the execution-start manifest. The extra file compared with earlier
  460-file checks is the previously added study viewer in the documentation packet;
  no production code changed for this run. Original legacy outputs are checked
  against their earlier hashes in the final preservation record.
- **Memory:** peak process RSS was 14.63 GiB
  for execution and 11.47 GiB for the separate audit.
  These are process measurements, not total machine requirements. Detailed values
  are retained in [resource summary](resource-summary.json).

[Verification](verification.json) distinguishes independent Python checks from
the all-event MATLAB audit and biological limits. Numeric agreement establishes
traceability and calculation correctness for the tested path; it does not certify
anatomy, detector identity, local motion, physiological timing or missingness.
The two detail figures received a grayscale/legend clarification only; their
initial versions and all numeric outputs are preserved. No execution failure
required a detector or statistics retry.

## Reproduction and completion boundary

The local evidence folder `reference-validation/boi-c02-workflow-20260912`
contains the executed MATLAB runner, exact source locator, fresh recording,
master/statistics MATs and workbook, audit code/logs, verification script and
resource records. Runners reject existing output directories. To repeat, prepare
a new evidence root/source stage with the preserved configuration rather than
rerunning into these folders. The report keeps portable IDs and compact numerical
artifacts; the large source and normal full exports remain in local evidence.

The shared [measurement dictionary](BOIMeasurementDictionary.json) and
[readable calculation guide](BOIMeasurementGuide.md) accompany the outputs.
The [artifact record](artifact-record.json) binds local and portable evidence,
previous readiness records and original legacy hashes. An independent researcher
has not yet replayed the normal MATLAB workflow; that usability release requirement
remains open.

The specified single-recording phase is complete. No second state or mouse was
run, no masks/windows/exclusions were approved and no biological contrast was
requested. The next scientific review should use the actual peripheral surge,
nonstationary baseline context and unavailable-support examples to resolve
candidate/measurement admission while preserving both signs and biological
variation. A paired C02 interpretation requires those decisions, not merely
another successful file execution.
