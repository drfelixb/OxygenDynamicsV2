# Oxygen Dynamics Analysis Manifest

Pipeline version: `v1.01`
Pipeline build: `2026-06-15 15:00:55 +02:00`
Generated: 2026-09-15 12:44:35
Stats output: `/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-first-roi-run-20260915/run-01/statistics/Stats_Output_20260915T124348`
Stats workbook: `/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-first-roi-run-20260915/run-01/statistics/Stats_Output_20260915T124348/FilteredData_input.xlsx`
Data output: `/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-first-roi-run-20260915/run-01/statistics/Stats_Output_20260915T124348/DataOutput.mat`

## Run Overview
- Input CSV: `/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-first-roi-run-20260915/run-01/input.csv`
- Dataset folder: `/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-first-roi-run-20260915/run-01`
- Recording rows with sinks: 79
- Individual oxygen-sink event rows: 278
- Recording rows with surges: 25
- Individual oxygen-surge event rows: 52
- Loaded sink recordings: n/a
- Loaded surge recordings: n/a
- Loaded behaviour recordings: n/a

## Acceptance And QC
- **Overall stats acceptance**: REVIEW - 12 QC checks require review before accepting this stats run.
- **QC: Hypoxic burden area basis**: PASS - 278 of 278 events use event-specific area.
- **QC: Hypoxic burden contribution**: REVIEW - Some event burden contributions are non-finite.
- **QC: Hypoxic burden per 1 mm2**: REVIEW - Some FOV-normalized burden contributions are non-finite.
- **QC: Hypoxic burden rate**: REVIEW - Some FOV- and time-normalized burden-rate contributions are non-finite.
- **QC: Hypoxic burden time series**: REVIEW - Some burden-over-time values are non-finite or recording IDs are missing.
- **QC: Hypoxic burden time-series signal**: PASS - At least one burden-over-time frame is nonzero.
- **QC: Hypoxic burden time axis**: PASS - SampleFs values are finite and positive.
- **QC: Area normalization**: PASS - 1 recording normalization rows are finite.
- **QC: HP_CSV7_FB2420_roi_074 / SOURCE-LABELS**: REVIEW - CSV repeats group names across genotype/drug/promoter; KX and baseline labels are not fully resolved. Evidence: R3-TRANSFER-READINESS-070
- **QC: HP_CSV7_FB2420_roi_074 / SOURCE-CALIBRATION**: REVIEW - CSV 2.35 is provisionally interpreted as micrometres/pixel; physical calibration is not verified. Evidence: R3-TRANSFER-READINESS-070
- **QC: HP_CSV7_FB2420_roi_074 / SOURCE-HISTORY**: REVIEW - Earlier source inventory exists; external inspection and V2/AQuA2 tuning history are unknown. Evidence: R3-TRANSFER-READINESS-070
- **QC: HP_CSV7_FB2420_roi_074 / SOURCE-PREPARATION**: REVIEW - Intensity preparation, substrate timing and motion-correction details are unresolved. Evidence: R3-TRANSFER-READINESS-070
- **QC: HP_CSV7_FB2420_roi_074 / SOURCE-LOCAL-TRANSIENT**: REVIEW - Phase071 found a brief localized high-value source excursion at frame17 near row330/column432; other maximum-trace spikes also remain unresolved. Evidence: /Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-source-support-20260915/run-01/spike-inspection.json SHA256 08cc4bdc9388a203849f9895fdc4ec739cae3b54eb0c6a3a9333e469a8935b15
- **QC: HP_CSV7_FB2420_roi_074 / R1-INTENSITY-UNKNOWN**: REVIEW - Intensity preparation before the preserved TIFF is unknown; preserved input does not imply camera-raw data.
- **QC: HP_CSV7_FB2420_roi_074 / R1-FRAME-VALIDITY**: REVIEW - Every image interval is assumed observable; no frame-level motion or missing-support review is recorded.
- **QC: HP_CSV7_FB2420_roi_074 / R1-REVIEWED-TISSUE**: REVIEW - Static support decision R1-FB2420-SUPPORT-ACCEPTANCE-073 by Researcher (user). Evidence: Researcher acceptance: /Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-support-acceptance-20260915/researcher-acceptance.json SHA256 9d6dabc6073fcd71f5d184f04529ccd15a89e76a3f5859761e00075213d7a2ac; proposal /Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-outline-proposal-20260915/proposal-01/Proposal.json SHA256 c57f8f2a3862690846d9fa34b1e04808a0a896de0ebcd93be45a9dc8c02d0d08; mask SHA256 f72c65a23b82a4b2bdb1704168587d2f618e0cd364351983f0bb9bb8bcc47364; overlay SHA256 c926322ac777aa3053a7ebfa59a9aad714ecd40f3a6efdb3d0b4e8a427fdcdb7.. Alignment: Source and 490 nm after reference use the same 512x512 native grid with visually corresponding large vessels (phase071). No transform applied or registration residual measured. User accepts this provisional working support; exact surgery, subpixel registration and dynamic validity remain unresolved.

## Additional QC Rows
- **Hypoxic burden area basis**: PASS - 278 of 278 events use event-specific area.
- **Hypoxic burden contribution**: REVIEW - Some event burden contributions are non-finite.
- **Hypoxic burden per 1 mm2**: REVIEW - Some FOV-normalized burden contributions are non-finite.
- **Hypoxic burden rate**: REVIEW - Some FOV- and time-normalized burden-rate contributions are non-finite.
- **Hypoxic burden time series**: REVIEW - Some burden-over-time values are non-finite or recording IDs are missing.
- **Hypoxic burden time-series signal**: PASS - At least one burden-over-time frame is nonzero.
- **Hypoxic burden time axis**: PASS - SampleFs values are finite and positive.
- **Area normalization**: PASS - 1 recording normalization rows are finite.
- **HP_CSV7_FB2420_roi_074 / SOURCE-LABELS**: REVIEW - CSV repeats group names across genotype/drug/promoter; KX and baseline labels are not fully resolved. Evidence: R3-TRANSFER-READINESS-070
- **HP_CSV7_FB2420_roi_074 / SOURCE-CALIBRATION**: REVIEW - CSV 2.35 is provisionally interpreted as micrometres/pixel; physical calibration is not verified. Evidence: R3-TRANSFER-READINESS-070
- **HP_CSV7_FB2420_roi_074 / SOURCE-HISTORY**: REVIEW - Earlier source inventory exists; external inspection and V2/AQuA2 tuning history are unknown. Evidence: R3-TRANSFER-READINESS-070
- **HP_CSV7_FB2420_roi_074 / SOURCE-PREPARATION**: REVIEW - Intensity preparation, substrate timing and motion-correction details are unresolved. Evidence: R3-TRANSFER-READINESS-070
- **HP_CSV7_FB2420_roi_074 / SOURCE-LOCAL-TRANSIENT**: REVIEW - Phase071 found a brief localized high-value source excursion at frame17 near row330/column432; other maximum-trace spikes also remain unresolved. Evidence: /Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-source-support-20260915/run-01/spike-inspection.json SHA256 08cc4bdc9388a203849f9895fdc4ec739cae3b54eb0c6a3a9333e469a8935b15
- **HP_CSV7_FB2420_roi_074 / R1-INTENSITY-UNKNOWN**: REVIEW - Intensity preparation before the preserved TIFF is unknown; preserved input does not imply camera-raw data.
- **HP_CSV7_FB2420_roi_074 / R1-FRAME-VALIDITY**: REVIEW - Every image interval is assumed observable; no frame-level motion or missing-support review is recorded.
- **HP_CSV7_FB2420_roi_074 / R1-REVIEWED-TISSUE**: REVIEW - Static support decision R1-FB2420-SUPPORT-ACCEPTANCE-073 by Researcher (user). Evidence: Researcher acceptance: /Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-support-acceptance-20260915/researcher-acceptance.json SHA256 9d6dabc6073fcd71f5d184f04529ccd15a89e76a3f5859761e00075213d7a2ac; proposal /Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-fb2420-outline-proposal-20260915/proposal-01/Proposal.json SHA256 c57f8f2a3862690846d9fa34b1e04808a0a896de0ebcd93be45a9dc8c02d0d08; mask SHA256 f72c65a23b82a4b2bdb1704168587d2f618e0cd364351983f0bb9bb8bcc47364; overlay SHA256 c926322ac777aa3053a7ebfa59a9aad714ecd40f3a6efdb3d0b4e8a427fdcdb7.. Alignment: Source and 490 nm after reference use the same 512x512 native grid with visually corresponding large vessels (phase071). No transform applied or registration residual measured. User accepts this provisional working support; exact surgery, subpixel registration and dynamic validity remain unresolved.

## Key Metrics
- Hypoxic burden event rows: `278`
- Hypoxic burden event sum: `5.90259e+07`
- Hypoxic burden event sum per 1 mm2: `6.73437e+07`
- Hypoxic burden recordings: `1`
- Hypoxic burden total: `0`
- Hypoxic burden total per 1 mm2: `0`
- Mean burden occupancy: `225.788`
- Mean burden rank amplitude: `NaN`
- Mean burden amplitude composite: `NaN`
- Mean grouped burden occupancy: `225.788`
- Mean grouped burden rank amplitude: `NaN`
- Mean grouped burden amplitude composite: `NaN`
- Hypoxic burden time-series rows: `1200`
- Mean burden over time per 1 mm2: `60896.2`
- Max burden over time per 1 mm2: `224254`
- Area-normalized recordings: `1`
- Mean area correction: `1.14092`

## Generated Figures
- No summary figure manifest found yet. Run `runOxygenSummaryFigures` to refresh this section.

## Review Checklist
- Inspect `StatsAcceptance` first. Do not refresh the regression baseline if any row is `REVIEW`.
- Inspect `HypoxicBurden_EventBased` for event-specific area matching before using burden metrics.
- Use `HypoxicBurdenPerMm2OverTime` for FOV-normalized burden-over-time comparisons.
- Create or refresh the regression baseline only from an accepted stats output.
