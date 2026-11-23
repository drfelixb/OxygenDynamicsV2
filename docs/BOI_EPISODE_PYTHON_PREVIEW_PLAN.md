# Python exploration of episode coverage and recovery

5 November 2026. Proposed next bounded milestone after the completed whole-episode prototype. Felix authorizes using Python or other appropriate development tools and defers the final MATLAB/Python implementation choice. This permits tool selection for exploration; a production platform migration is not selected. The preceding prototype is stopped, and Felix approves the bounded scope below (“I approve the plan”). This bounded preview is delivered and stopped; see [results](BOI_EPISODE_PYTHON_PREVIEW_RESULTS.md). No production migration or subsequent implementation is approved.

## Recommendation

Use Python with the existing NumPy/SciPy environment for the next numerical prototype. Keep the current MATLAB GUI, batch execution, statistics and exports as the working user workflow. Choose the final backend after the method demonstrates useful recognition, traceable outputs, manageable dependencies and acceptable runtime. A direct language port would preserve the present model failures.

The current Python is3.12.10 on Apple silicon, with NumPy2.4.6 and SciPy1.17.1. No new package is needed for the proposed numerical work. MathWorks lists Python3.12 as supported by MATLAB R2025a's Python interface, but live environment integration has not been tested. Architecture and other configuration requirements still apply. [MathWorks compatibility](https://www.mathworks.com/support/requirements/python-compatibility.html), [configuration requirements](https://www.mathworks.com/help/matlab/matlab_external/install-supported-python-implementation.html). MATLAB can call Python functionality, so retaining the existing interface would remain an option if a Python backend later offers a clear benefit. [MATLAB Python interface](https://www.mathworks.com/help/matlab/call-python-libraries.html).

The numerical work proposed here needs signal features and least-squares/model comparisons, not a new application framework. SciPy supplies signal-processing primitives; a peak finder alone does not identify a biological episode. Its peak documentation also warns about missing values, so preserve finite segments rather than interpolate over gaps to assert recovery. [SciPy peak documentation](https://docs.scipy.org/doc/scipy/reference/generated/scipy.signal.find_peaks.html).

## What the saved results already establish

Read-only inspection of the saved FB2413 site3/event6 results finds1,089 raw and1,234 corrected proposal seeds, of which120 per stage were fitted. There are three retained raw centres in826–851, all broad; none is at most48 frames wide. There are no retained corrected centres in that discussion interval. This supports investigating coverage before deciding that the episode model itself rejected the localized pocket. The omitted pre-cap trials are not saved, so their existence and rejection mechanism require a separately approved diagnostic rescan. Cap starvation is a plausible explanation, not yet a demonstrated sole cause.

The recovery implementation explicitly computes its post-event level and trough on signal minus fitted background. Thus a falling fitted background can produce apparent relative recovery while the raw signal continues declining. This is a model-definition issue, not a MATLAB arithmetic failure. Python already independently reproduced the previous model's sampled calculations; changing language by itself will not repair that definition.

These observations inspect three existing files and source code only. No new model, recording evaluation, scientific label or burden value was produced. Evidence and hashes: `reference-validation/boi-episode-next-plan-20261105/inspection.json`.

## Bounded next milestone

**POCKET-EPISODE-03**, owner root, no delegation. Four active engineering hours, up to four analysis batches, two repair cycles and512 MiB new derived evidence. Use at most56 full saved traces: the seven exact prior judgment footprints, the existing FB2317/group62 recovery-failure footprint, plus four overlap-group representatives per development recording selected by deterministic identifier hash, with duplicates removed. Retain the same12 development recording IDs. Do not re-evaluate the five previously held-out recordings or restart an all17-recording campaign in this milestone.

| Item | Practical outcome | Bounded implementation | Acceptance |
| --- | --- | --- | --- |
| PY-01 | Establish a faithful Python reference | Reuse the saved-evidence contract and independent scoring work; replay the old calculation before changing it. | Numerical agreement within documented tolerance on at least24 saved hypotheses across the finite fixture set; explicit one-based frame exchange and sampling rate. |
| PY-02 | Give localized episodes a fair assessment | Separate candidate generation, fitting and final prioritization; inspect/evaluate all eligible generated trials on the finite traces before applying a display shortlist. Retain generation/fit/exclusion reasons. | A trace/duration coverage ledger accounts for every eligible trial. FB2413's omitted short-window possibilities are traced through generation and fitting, without forcing a positive label. If resource limits prevent exhaustive fitting, stop at a reported checkpoint rather than silently discard weaker trials. |
| PY-03 | Make recovery assumptions visible | Compare observed post-trough trajectory evidence, return toward the preceding state and return conditional on the fitted background. Keep raw/corrected assessments separate. | Model-dependent closure is distinguishable from observed recovery. Ambiguous combinations retain an uncertain outcome; no universal demand for absolute raw baseline return or a fixed plateau is adopted. |
| PY-04 | Explain repeated views and choose a backend direction | Link likely repeated temporal proposals on overlapping saved footprints for display, produce a compact old/new comparison and report dependency/runtime/portability findings. | No biological event merge or changed membership. One small whole-episode montage, preserved originals and a concrete MATLAB/Python recommendation, not an adopted platform change. |

Use two prespecified exploratory variants: improved coverage with the old scoring/recovery calculation, then the same coverage with the separated recovery evidence. This isolates a search effect from a recovery interpretation effect. Lock numerical choices and finite fixtures before the new source-trace evaluation; do not search many parameter sets to reproduce the familiar judgments. Recovery ambiguity remains meaningful even when a model score is high.

Observed recovery need not mean a return to one exact raw intensity. Background may change and real pockets may be broad, asymmetric or recurrent. Conversely, a downward fitted reference alone cannot establish physiological recovery. Report these sources of evidence separately rather than invent a universal positive-slope or baseline-duration rule. This milestone does not choose new10/20-second measurement references.

## Checks and deliverables

Use at most16 named synthetic scenes covering localized episodes within broad trends, monotonic/transition-only signals, background-dependent apparent return, overshoot, recurrence, incomplete recording edges, gaps and sampling-rate/frame conversions. Preserve an unchanged reference case and include uncertainty outcomes. Verify bookkeeping and source identity as well as arithmetic.

Produce a montage of at most eight full contexts: the localized miss, model-created recovery, a recognized wider episode, a saved negative, and four contrasting/uncertain views selected by fixed coverage rules. The researcher evaluates whole trajectories, not a second-by-second boundary questionnaire. Old scientific judgments remain visible and authoritative for the existing reviewed workflow; new experimental outputs are not accepted labels.

Measure Python time and memory with an initial small benchmark. Do not present the old capped MATLAB run versus a new exhaustive Python run as a language-speed comparison: the algorithms and workload differ. If a stable model remains ordinary array/least-squares code, recommend a verified MATLAB port as a production option. If retaining Python offers a demonstrated substantial advantage, propose a pinned backend invoked from MATLAB with an explicit input/output contract. Do not maintain two independently evolving scientific implementations.

The17 recordings have already informed exploration and their earlier held-out outputs were inspected. New tuning cannot claim those same outputs as untouched independent validation. This pass supports engineering/model decisions; sensitivity and specificity require independent biological assessment and spatial misses cannot be assessed from retained footprints alone.

## Preservation and stop

Use existing local saved traces and existing Python/MATLAB plotting capabilities; no new package installation, MATLAB/Python environment reconfiguration, GPU or external service. No movies, correction refits, tissue/area segmentation, scientific review saves, amplitude/reference/burden changes, partial sums, cohort export, production default, GUI replacement, commit/push, external publication, package or release. Findings stay local. Saved experimental outputs remain separate from scientific export inputs.

Stop after the source-bound Python comparison, coverage/recovery failure report, small montage and backend recommendation, or at the agreed budget/source boundary. A production backend migration, integration into batch execution and any larger validation campaign remain separate decisions. Deferral keeps the current optional MATLAB prototype and all existing outputs intact.
