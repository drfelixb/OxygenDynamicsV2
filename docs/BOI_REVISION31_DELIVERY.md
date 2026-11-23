# Revision 31: signed contributions delivered locally

13 November 2026. SIGNED-CONTRIBUTIONS-31, owner root, no delegation.
The researcher approved the [bounded implementation/test plan](BOI_REVISION31_IMPLEMENTATION_PLAN.md).
R31-01..03 are complete. No implementation milestone remains active; compact
workbook implementation and real-data regeneration/export remain separate and held.

## Result

New BOI statistics calculations explicitly select `boi-signed-contributions-1`.
Retained finite signed amplitudes feed the unchanged event product; negative
contributions subtract in the strict complete recording sum. Positive, zero and
negative complete totals are valid numerical states. A missing required
ingredient still makes the complete total unavailable. Reference-quality,
above-recording-reference and sign flags do not exclude computable values.
Failed/unprocessed inventory cannot be promoted to an analyzed zero under the
new policy.

The unchanged formulas are:

`contribution_i = amplitude_percent_i * event_mean_area_um2_i * duration_s_i`

`normalized_burden = sum(contribution_i) * 1e6 / recording_area_um2 * 60 / recording_duration_s`

The event-specific twenty-second reference calculator and its version are
unchanged. The original detector/correction, event masks/timing, mean area,
duration, physical calibration, signed optical integral and original saved
results are preserved. No absolute value, clipping, zero fill, partial sum,
coverage scaling, new reference or additional normalization is introduced.

## Versions, flags and existing exports

- `boiBurdenSelectionPolicy` identifies signed selection separately from the
  original reference version. Existing unmarked/legacy low-level calls keep
  their historical behavior. Reading an old result does not silently adopt a
  new policy; new BOI stats explicitly request the signed policy.
- Event, recording, window and burden-series routes retain the selected policy.
  Unsupported/mixed policies and conflicting identities are rejected.
- `BurdenAmplitudeNegative` and `BurdenContributionNegative` are 0/1/NaN, with
  matching nonnegative/negative/not-assessable text. They describe the actual
  selected automatic or reviewed value. Missing area can leave an amplitude
  negative while its contribution remains unavailable.
- Recording outputs include `NumNegativeBurdenAmplitudes`,
  `NumNegativeBurdenContributions`, available/required contribution counts,
  `BurdenTotalSign` and `NormalizedBurdenTotalSign`. Sign is positive, zero,
  negative or not assessable. Review summaries count retained negative products.
- Reviewed values keep authority, and explicit not-pocket exclusions govern
  reviewed membership only. Compatible positive legacy approved scalars retain
  their exact values when used with a signed parent; explicitly signed artifacts
  retain signed validation and must have compatible parent provenance. Old
  artifacts are never rewritten or relabelled.
- Existing detailed workbook/CSV/MAT formats retain their roles and gain sign
  metadata. `Burden_SelectionPolicy` records the policy. Export plans/receipts,
  metric definitions, normalization guidance and automatic availability reporting
  distinguish signed inclusion from historical sign exclusion. Negative-value
  counts are descriptive, not biological severity or calibrated oxygen.

No compact six-sheet workbook, individual-review GUI extension, new mandatory
CSV field or real-cohort export is included in this delivery.

## Verification and actual use of limits

All **12 frozen constructed checks and 24 selected existing synthetic
regressions passed**. They cover signed products/totals, genuine missingness,
zero/failed states, unchanged normalization, reference flags, reviewed authority,
exclusions and identity, legacy/source compatibility, windows/burden-series and
existing-format persistence. Independent expected scalar/table arithmetic is
used. Tests do not certify biological reference suitability, detector performance
or comparability of actual recordings.

The existing reviewed-export regression produced the signed workbook used by
the new readback check; that check did not create a ninth workbook. Native
XLSX/CSV/MAT readback preserves signed values, flags, source identity and the
selected policy. Synthetic source files remain unchanged by export.

| Resource | Used | Approved maximum |
| --- | --- | --- |
| Sequential batches | 3 | 3 |
| Constructed function executions | 12 | 24 |
| Existing synthetic function executions | 24 | 48 |
| MATLAB starts | 2 | 2 |
| Combined repair cycles | 1 | 1 |
| Synthetic workbook export attempts | 8 | 8 |
| Peak process-tree RSS | 1,457,864,704 bytes (1.36 GiB) | 2 GiB |
| Evidence/scratch at preservation closeout | 1.35 MiB | 100 MiB combined |
| Elapsed through preservation closeout | 24.5 minutes | 4 active hours |
| Real recording inputs / biological case reviews | 0 / 0 | 0 / 0 |

The first MATLAB launch stopped before test discovery because its temporary
path exceeded MATLAB's startup limit. The one harness repair used an isolated
short scratch path, still included in the combined output guard. The second
launch passed all 36 evaluations without a scientific-code or test repair.
Launch, repair and workbook-attempt allowances are exhausted. No further run
starts from unused function-execution allowances.

A before/after source inventory preserves **595 existing MATLAB source/test
files byte-for-byte**. Sixteen existing files changed within the approved list;
four new files are the two allowed production helpers and the finite suite/driver.
The reference calculator, finalizer and recording normalization/strict-sum source
are byte-identical to the pre-milestone snapshots. No real-result payload was
opened or written; all file fixtures are constructed. Existing unrelated dirty
work is preserved. No commit, push, package or release was performed.

Evidence: `reference-validation/boi-revision31-implementation-20261113/` contains
the approved frozen scope/counters, pre-edit snapshots, implementation diff,
both launch receipts, the startup failure/repair record, all 36 passing results,
synthetic signed export/readback artifacts and source-preservation inventory.

The milestone stops here. Compact-export implementation retains its separate
agreed scope and unchanged proposed limits; any later real-data run/export
requires its explicit applicable execution authorization.
