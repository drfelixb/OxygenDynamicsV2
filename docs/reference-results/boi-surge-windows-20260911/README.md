# Separate surge window evidence — developer verification

11 September 2026. Decision **R5-SURGE-WINDOW-011** extends the BOI measurement
and MATLAB review workflow to separately saved surge windows. It preserves the
original sink calculations, both signs' event values and prior evidence. This
is a technical development check; scientific eligibility remains unestablished.

## Result and calculation record

New BOI statistics exports contain `SurgeRecordingWindowMetrics` and
`SurgeWindowFrameIngredients` in MAT, CSV and workbook sheets. Their schema is
`boi-surge-window-exposure-1`. Source identity, clock and calibration must match
the saved input contract, and surge site support must equal its surge mask.
Original `RecordingWindowMetrics`, `WindowFrameIngredients`, registry area and
baseline contrasts remain sink-specific. A successful zero is distinct from
missing native masks, zero tissue and failed analysis. Both signs remain separate.

The inspector's sign selector displays the corresponding event timing,
covered area-time and analyzed tissue-time. Switching signs preserves window
identity even when table rows are ordered differently. Older exports remain
readable with explicit surge unavailability; partial extensions are rejected.
Exports record the selected sign and retain immutable result hashes, source
contracts and current/selected dictionary context. Dictionary **0.3.0-draft**
documents this additive implementation; outcome priorities are unchanged.

For the same preserved HP ECS development recording and whole [0,1200) s window:

| Quantity | Sink | Surge |
|---|---:|---:|
| Saved tissue pixels | 156,253 | 179,865 |
| Event onsets | 168 | 81 |
| Active event-time (s) | 2,705 | 2,975 |
| Mean occupied tissue fraction | 0.00625204529406 | 0.0674802490757 |
| Onset rate (events/mm²/min) | 9.73453469042 | 4.07729971313 |
| Concurrent event density (events/mm²) | 2.61229328746 | 2.49587791081 |

Surge covered area-time is 80,434,119.045 µm²·s and analyzed tissue-time is
1,191,965,355 µm²·s. Their ratio is about **6.7480%**. These are descriptive
values conditional on the supplied 2.35 µm/pixel scale and unreviewed static
support, not oxygen concentration or biological acceptance. The different
sign-specific areas preclude simply sharing denominators or cancelling signs.

All 81 surge detections contribute to these amplitude-independent summaries.
Only 20 have finite amplitudes and one remains negative. Neither missing nor
negative amplitude is used as an event exclusion. No surge amplitude-area-time
composite is defined; its fields remain NaN even for a successful zero-event
recording. Acquisition-boundary onsets remain in the existing descriptive rule,
with a separate count; no physiological admission policy is adopted.

## Verification and preserved correction

- Initial **33 targeted tests passed**: surge calculations, saved-window review
  and input contracts. After a sign-switch identity refinement, **14 affected
  tests passed** (including the new row-order case). These are 34 distinct tests,
  with overlap between runs.
- One statistics-only run used the unchanged staged HP master and source. It
  completed in approximately **58 s** between second-resolution log entries.
  No detector rerun, tuning, source change, mask adoption or animal pooling.
- Sink windows/frame ingredients, both sign event/site tables, hypoxic summaries,
  window contrasts, registry, input QC and exposure compare exactly using
  `isequaln`. The preserved previous sink implementation reproduces its original
  outputs exactly.
- Initial verification stopped at whole-struct input-contract equality. The
  old HP export predates the already implemented tissue-review extension.
  Rebuilding adds only `TissueDecision` (empty struct), `TissueSnapshot` (empty)
  and `TissueSupportExtension=boi-static-tissue-support-1`. Every pre-existing
  contract field is exactly unchanged. The failed check and field-level diagnosis
  remain in the evidence folder. Verification resumed from the completed output,
  without a second statistics run.
- All **1,200 surge native-mask unions** independently reconstructed with Boolean
  pixel membership match saved frame areas. Python replays both signs' three
  measures from CSV with tolerance `1e-12 * max(1, abs(saved value))`; this is an
  arithmetic tolerance, not a scientific criterion. The initial Python area check
  incorrectly required exact equality between decimal CSV and binary arithmetic
  (difference below 2e-10 µm²). It now uses the predefined tolerance; the original
  script and diagnosis are retained. No measured value changed.
- MATLAB calculation, frame-ledger and separate support views were inspected by
  the developer. The structured report records test outcomes, checksums, prior
  artifact preservation and the two GUI/test files changed after statistics.

The normal missing-behaviour warning remains: no behaviour output exists for
this staged recording. That evidence is unavailable, not inferred from labels.
External trigger timing remains precisely **1 Hz**. The **0.96 s** camera
integration is separate; incorrect embedded timestamps do not drive calculations.

## Evidence and remaining work

Local artifacts are under
`workspace/reference-validation/boi-surge-windows-20260911/`: the single statistics
export, both selected-window exports, native-union counts, screenshots, run
configuration, initial/continued verification scripts, test tables and logs.
`createOxygenAnalysisWindowsBefore.m` preserves the pre-change sink implementation
with only its function name changed so the comparator can execute alongside the
new helper. Local exports intentionally include original paths and metadata.

[Structured verification](verification-report.json),
[artifact record](artifact-record.json) and the
[decision](../../planning/boi-surge-windows-20260911.json) bind the portable account
to local evidence. Earlier manifests and analyses are preserved.

Source identity and biological labels, physical calibration, anatomical/dynamic
support, broad source changes and negative surge interpretation remain unresolved.
AQuA2 exploratory detection is not anatomical evidence. No outcome hierarchy,
animal-level inference or cohort admission is frozen. The independent researcher
release walkthrough has not been performed. Next owned work connects window
selection to event/source inspection for a continuous MATLAB review path.
