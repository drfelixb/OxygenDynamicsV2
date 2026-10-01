# Published C02 local-input audit

12 September 2026 — **R1-C02-INPUT-019 completed: technical input compatibility
established for eight recordings from four animals; scientific eligibility remains
measurement-specific and unresolved.** These are published-data reanalysis
candidates under [R3-PUBLICATION-HISTORY-018](../../planning/boi-publication-history-20260912.json).
Publication use does not exclude them from reanalysis.

## Findings

| Animals | Sessions per animal | TIFF dimensions | Frames per session | TIFF stored depth | Canonical pixel scale | Sampling |
|---|---|---|---|---|---|---|
| FB2314, FB2315 | Awake and isoflurane | 512 × 512 | 1,200 | 16 bit | 2.35 µm/pixel | 1 Hz |
| ID402, ID403 | Awake and isoflurane | 512 × 512 | 600 | 8 bit | 4.75 µm/pixel | 1 Hz |

All eight selected source names, dimensions, frame counts and canonical metadata
agree with the cached manifest for **DANDI 000891, version 0.240215.0831**.
The local TIFF depth is a storage property, not proof of camera acquisition depth
or intensity preparation. The cached headers used here do not record archive
dtype. Neither name/shape agreement nor TIFF hashes establishes local-to-archive
pixel equality; different TIFF and NWB container hashes are not an equality test.
All four FB2314/FB2315 whole-file hashes are distinct. Preserve canonical FB2315
identity despite the FB2314 text in its source filenames.

Each recording has one sink, one surge and one manual-curation-named MAT file:
**24 preserved legacy files**. Their variable headers contain event tables,
maps and traces, but none has a top-level `Info` variable. This establishes prior
processing artifacts in the external source folders. It does not establish their
software revision, settings, creation history, actual human curation actions or
later V2/AQuA2 tuning. No event, mask or trace values were loaded. Archive
membership is established for the eight mapped recordings; this audit does not
claim that the 24 local MAT outputs are themselves DANDI assets.

## Interpretation of import review

The existing MATLAB preflight marks all eight inputs
`descriptive_input_requires_scientific_review`; none failed import. There are no
`BOIInputMetadata.json` or `BOITissueSupport.json` declarations beside these
sources. Missing new-format sidecars do not imply absence of historical evidence.

The unmodified [software QC export](input-qc.csv) has five notices per recording.
The [interpretation overlay](qc-interpretation.json) retains the user's timing
correction separately from that raw export:

| Review item | Current evidence and consequence |
|---|---|
| Frame timing | User confirms precise 1 Hz external triggering; canonical archive metadata also gives 1 Hz. The generic missing-timestamp notice is not an unresolved sampling-rate question. Use frame-index timing. Incorrect embedded clocks must not override it. Frame loss, support and experimental alignment remain separate checks. |
| Camera exposure | Unknown in this audit. Do not infer exposure from frame spacing or a TIFF filename. Relevant to temporal integration and acquisition comparability. |
| Intensity preparation | Motion-corrected source names and 8/16-bit storage are observed; transformations before these preserved TIFFs remain unknown. Relative amplitude and detection comparability require processing evidence or explicit claim restrictions. |
| Frame validity | No frame-level motion/missing-support review is established. Nominal frame count does not certify usable tissue-time. |
| Tissue support | No source-bound reviewed tissue declaration. Intensity-estimated support is not established anatomical or dynamically valid support. Tissue-normalized coverage and event-density denominators need review. |

The two spatial scales and stored depths remain explicit acquisition strata.
Preserve animal pairing and biological variability; do not tune toward a common
event count or an expected isoflurane effect. Equalizing observation lengths,
choosing experimental windows and defining animal-level summaries are later
scientific decisions, not silent consequences of this audit.

## Verification and preservation

The [prespecified plan](../../planning/boi-c02-input-20260912.json) limited work to
eight preflights and an independent header/hash replay. MATLAB R2025a completed
the successful pass in **37.9 seconds**. Independent Python/Pillow verification
checked **7,200 TIFF frame headers, eight source hashes and 24 legacy hashes**;
the selected legacy inventory still matched. It took 2.1 seconds on this machine
with locally available files; neither runtime is a pipeline or cloud-download
benchmark. No pixel-series decoding, new detector run or statistics run occurred.

All 460 manifest-listed MATLAB files remained unchanged. Checks also verified
31 prior baseline/timing artifacts and two prior policy-preparation artifacts.
See [verification-report.json](verification-report.json), [summary.csv](summary.csv),
[legacy-inventory.csv](legacy-inventory.csv) and [report.json](report.json).

The initial attempt failed while constructing a MATLAB table because the report
field `VariableNames` is reserved. Its `check_failed` rows are reporting failures,
not eight unreadable recordings. The preserved corrected runner uses
`MATVariableList` and supplies the already-known canonical Mouse to validation,
removing an incidental missing-mouse warning. Production code and source metadata
were unchanged. `run-01`, its log and initial runner remain locally preserved;
`run-02` contains the successful results. The original prespecification is also
retained separately from the completed planning record.

Private source paths and full MATLAB reviews remain under the local workspace's
`reference-validation/boi-c02-input-20260912/`. Portable artifacts identify sources
by session, asset, source filename and checksum. The [artifact record](artifact-record.json)
links the retained evidence without exposing external absolute paths.

## Disposition

Retain current import and measurement rules. Close this bounded technical audit;
keep source equivalence, intensity preparation, valid tissue/time, exposure and
paired experimental windows explicit for the affected measurements. Prior-use
history now includes these external legacy outputs, without rewriting the scope
of the earlier workspace-only audit or assigning an untouched role.

Next work is to trace the local-to-archive conversion and available preparation
evidence, then make the measurement-specific eligibility decisions. This audit
does not approve a biological contrast, method evaluation, cohort freeze or rerun.
