# FB2314 isoflurane: accepted-support analysis completed

21 September 2026 · R1-FB2314-ISO-RUN-092

**The isoflurane recording has completed the current restricted-profile MATLAB workflow and its numerical verification.** Both FB2314 states now have source-specific accepted working support and verified runs with equal effective master settings. No detector tuning or new baseline policy was introduced.

## Researcher decision and inputs

The researcher explicitly selected **“Accept this working outline”** for FB2314 isoflurane. The decision applies to its original source-bound 024 polygon, displayed in the final render-02 five-frame sheet. Internal dark regions remain included. Upper/left edges remain approximate; bottom-edge segments bound the recorded image, not unseen anatomy. No awake mask was transferred.

The full 512×512×1200 source, canonical 2.35 µm/pixel and external 1 Hz are retained. The source SHA256 is `e83acb45ebffd2c61a0035bd6d11c52719180658a8c3cd10a257a477dc882e7c`. The input was copied byte-for-byte into a fresh local stage. Original TIFFs, prior awake output and older isoflurane files remain unchanged. The declaration was written only in that fresh stage.

The run uses `craniotomy-roi-1`, original recording-specific correction and unchanged parameter defaults. Full `[0,1200)` is the descriptive modeled extent, with original frame IDs. No final C02 window, induction time, frame exclusion or statistical contrast is adopted. Pre-recording state establishment remains distinct from the event reference.

## Saved activity and optical availability

| Saved sign | Events | Finite amplitudes | Unavailable amplitudes | Negative finite amplitudes |
|---|---:|---:|---:|---:|
| sink | 203 | 68 | 135 | 8 |
| surge | 33 | 9 | 24 | 0 |

These are automatic labels and preserved-input optical measurements, not validated counts of physiological events. Some labeling errors remain acceptable at this stage. Unavailable amplitudes retain their events and native coverage; negative values are not rectified. The original full 20-sample native-screened reference is unchanged. No manual reference from the awake examples is transferred to this recording.

Coverage and availability ingredients, exact event/source references and missingness reasons are exported for both signs. No finite-subset composite is represented as total burden. The current pipeline and output contracts remain unchanged.

## Verification and feasibility

All **236 saved events** passed the existing MATLAB source-amplitude audit, with zero mismatches. Independent Python verification replayed 2,400 sign/frame native-support and denominator rows, the 1,200 original frame intervals, ROI containment, the neighbor-weight map, and 2400 first-finite-example source trace samples. It also checked those examples' exact reference membership and signed arithmetic. Tolerances were 1e-12 absolute plus 1e-10 relative where applicable; frame and pixel memberships were exact.

The two automatically selected first-finite examples were visually checked as calculation illustrations. No new recognition or boundary labels were requested or inferred. These checks verify computation and support handling, not detector sensitivity/specificity or biological ground truth.

The master took 58.1 seconds and statistics 36.8 seconds; the workflow's measured execution was 125.9 seconds, excluding MATLAB startup. The run wrote 3.00 GiB before the audit, within the 5 GiB target. The audit took 70.3 MATLAB seconds. Process timings and memory observations are retained in the resource logs; these are not whole-machine or future-runtime guarantees.

All 495 repository MATLAB files are unchanged during this run. Relative to the earlier awake run, the only changes to already existing files were the event-review data/export/interface and its tests; the 28 additional files are review helpers/tests. Effective master settings are exactly equal. Thus the pair shares the current scientific processing/profile, with separately accepted recording-specific masks. This is not a claim of identical anatomy or valid time in every frame.

## Current C02 position and next step

The [dated seven-pair matrix](BOI_C02_ELIGIBILITY_MATRIX.md) is preserved. Its [current update](planning/boi-c02-eligibility-update-20260921-092.json) now records seven of 14 recordings with identified run evidence, two accepted working ROIs and one pair with both restricted-profile runs. No mouse has been excluded. Historical default-profile outputs remain distinguishable from current restricted-profile outputs.

Next, specify the paired descriptive observation window and prepare the FB2314 summary from these verified outputs; continue support/run preparation for the remaining pairs using existing proposals. The full stored 1200 frames in each state are available as a concrete window option, but final comparison-window approval is separate. No new detector diagnostics are needed to progress.

Unknown pre-source intensity history, camera exposure, dynamic validity and final claim/statistical decisions remain recorded. They limit affected interpretations; this result is not calibrated oxygen concentration, independent validation or a seven-mouse effect.

## Files

- `researcher-support-decision.json`, `BOITissueSupport.json`, `BOIInputMetadata.json`: exact accepted support and source declarations.
- `run-01/workflow-report.json`, `effective-master-settings.json`, `paired-method-readiness.json`: execution, settings and relationship to awake processing.
- `audit-01/`: event/coverage/exposure tables, summary records, source-amplitude replay and illustration files.
- `verification.json`, `visual-review.json`, `preservation.json`, `artifact-record.json`, `completion.json`: final evidence and checksums.

Full movie/master/MAT outputs remain in the local workspace and are hash-bound in the artifact inventory. The portable packet contains readable evidence and selected exports. Source paths are retained for internal traceability; this is not a deidentified public release.

[Evidence packet](reference-results/boi-fb2314-iso-run-20260921/README.md).
