# Compact workbook: final input-guard and text-layout correction

13 November 2026. **Explicitly approved and completed; both selected evaluations pass.** COMPACT-EXPORT-01 remains incomplete. This requests a narrow extension to finish two confirmed engineering defects, without changing scientific methods or starting another data campaign.

The final approved run passed seven of the eight frozen families, including signed values/missingness/units, MAT/CSV/XLSX compatibility, both native compact writers/readback, source precision and programmatic GUI cancellation/failure recovery. The conflict family failed one assertion: the exporter overwrites an inconsistent exclusion flag before checking it. Valid, coherent snapshots produced both synthetic workbooks, but contradictory snapshots must be rejected. Read-only layout inspection also confirms that a regex escape warning prevents long body text from wrapping; data and header styles remain intact.

## Concrete changes

The [prepared patch](../../reference-validation/boi-compact-workbook-implementation-20261113/prepared-final-guard-layout-correction.patch) is reviewable now and is not applied:

1. Validate saved exclusion membership before replacing any output flag. Contradictory review inputs stop with the existing CompactReview error; valid membership and all saved numerical values are unchanged.
2. Escape the backslash in the formatter's sprintf regex so the existing body wrapping and row-height pass runs. This changes presentation only.
3. Reuse two existing frozen functions: CEX-S5 source conflicts/preservation and CEX-S8 GUI/writer recovery. Add a no-export-warning and explicit body-row-format assertion to S8. Use a new final synthetic workbook filename; preserve all earlier outputs.
4. Make the test driver's already counted limits read from the explicitly approved cumulative scope; no counter reset or new test family.

## Exact proposed extension

- One combined repair: cumulative **3 rather than 2**.
- One additional guarded MATLAB start: cumulative **4 rather than 3**.
- Two existing-function evaluations: cumulative **26 rather than 24**. No other tests or individual examples.
- One new XLSX writer dispatch, Compact_FinalGuardAndLayout.xlsx: cumulative **5 rather than 4**, including all prior failures and the original input fixture. No new input workbook and no retry.
- Keep the original six-hour boundary from 15:07:30 UTC, four batches, 4 GiB RSS, 100 MiB total evidence/scratch, 25 MiB compact output and all original source limits. Zero real recording inputs; five reserved recordings untouched.
- Read back the one final synthetic output, inspect existing sheet layouts without another workbook write, verify preserved source hashes, update local delivery and GitHub state, then stop. Any failure or cap stops this extension; no further repair or run is implicitly authorized.

The detector, event-specific 20-second reference, burden product, signed normalization, original results and detailed formats remain unchanged. No scientific calculator is called by the exporter. No commit, push, release or real batch export is included.

Alternative: retain the current checkpoint and the existing detailed export workflow. The compact milestone stays In Progress until acceptance is complete. The [workspace rule](../AGENTS.md) requires explicit approval “Before crossing a boundary”; all prior allowances are used.
