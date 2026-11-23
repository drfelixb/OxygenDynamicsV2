# Compact workbook: narrow verification extension

13 November 2026. **Explicitly approved; exact correction applied; final verification active.** The original COMPACT-EXPORT-01 approval remains binding except for the single proposed launch increase below. No new milestone, source campaign or budget reset.

The initial eight families passed identity/metadata, zero/missing/review states, signed completeness/membership, reference/AUC/gap provenance and source-conflict/preservation. Three failed on a raw-AUC-reference definition, missing text import and logical Excel readback. One bounded repair addressed these. The second run failed to parse an assertion because its new line lacked MATLAB continuation syntax. This is an implementation mistake, not a scientific finding. No compact workbook has completed readback or been published.

The [exact correction](../../reference-validation/boi-compact-workbook-implementation-20261113/prepared-parser-correction.patch) is prepared, not applied. It adds continuation syntax and explicit parentheses to the reviewed-membership validation assertion. A candidate copy and the other new/edited sources have been checked with MATLAB's standalone source analyzer: no parser errors; style/performance warnings remain. This is not numerical or GUI acceptance.

## Proposed authorization

- Apply that prepared assertion correction as **repair 2 of the existing 2**. No scientific or reference change.
- Permit **one additional guarded MATLAB process**, making the cumulative start cap **3 rather than 2**.
- Run the same eight frozen functions once, bringing evaluations from **16 to the existing maximum 24**. No additional suite, real recording or individual example.
- Reuse the already generated SyntheticDetailedSource.xlsx read-only. The only remaining writer dispatches are the six-sheet Compact_AutomaticOnly.xlsx and the seven-sheet Compact_WriterRetry.xlsx. These are dispatches **3 and 4 of the original maximum 4**, including the initial failed reviewed writer. No other XLSX write or retry.
- Read back both outputs, inspect their layout without generating another XLSX, check original-source preservation and GUI recovery, and close the milestone only if all acceptance checks pass.
- Keep the original six-hour elapsed engineering boundary from the original start, four batches, 4 GiB RSS, 100 MiB evidence/scratch, 25 MiB compact output and all source/preservation limits. No extra repair or test/writer allowance. Stop on a failure or any boundary.

Original detector, 20-second local reference, signed burden formula, normalization, original results and legacy formats remain unchanged. Zero real recording inputs; the five reserved recordings stay untouched. No commit, push, release or real batch export.

Alternative: leave the compact exporter unverified at this checkpoint and continue using the existing detailed export workflow. The [workspace rule](../AGENTS.md) requires approval “Before crossing a boundary”; another MATLAB start needs explicit authorization.
