# Compact batch export: status summaries and formatting speed

13 November 2026. **Implemented and verified; corrected saved-bundle acceptance complete.** Owner root, no delegation. Follow-up CEX-BATCH-01 is separate from the completed synthetic-only compact milestone; its spent counters are preserved, not reset.

The [final delivery](BOI_COMPACT_BATCH_USABILITY_DELIVERY.md) records successful acceptance after the explicitly approved [memory correction](BOI_COMPACT_BATCH_MEMORY_PLAN.md). The earlier [boundary checkpoint](BOI_COMPACT_BATCH_USABILITY_CHECKPOINT.md) remains historical; spent counters are not reset.

## Observed product-use result

At the researcher's “Try that” request, the existing MATLAB session opened the saved combined export and completed the compact preview. It covers 17 recordings, 6,727 original detections, 34 recording/type rows and 40,756 frame rows. No reviewed snapshot was selected. No analysis, individual pocket review or workbook write occurred. Source hashes and exact counts are saved locally in `reference-validation/boi-compact-gui-export-20261113/PreviewPlan.json`.

The Availability projection contains **1,004,937 rows**, mostly repeated metric status descriptions. It fits just below Excel's row limit but defeats the compact-workbook goal. Static source inspection also shows that formatting repeatedly searches and rebuilds whole worksheet XML for each row; that cost grows disproportionately with table size. No full-sized writer timing is claimed: the write was deliberately not started. The GUI was left open with inputs retained and Export disabled.

A separate diagnostic defect was observed: the panel's anonymous State getter returns the constructor snapshot, rather than the live preview. The GUI's nested callbacks retain the correct preview. The saved counts above were obtained from that live callback workspace; no source values were changed.

## Proposed reporting layout

Keep all six core sheets and every existing measurement, event/frame identity, source value, missing cell, sign, review flag and normalization definition. Change only **Availability** from one row per numeric cell to status counts grouped by **RecordingID, event type, source sheet, metric, state, reason and quality**. Identity metadata remains explicit; do not group across mice, visits or conditions.

Each summary reports the number of affected source rows and the exact rule/columns used to select those rows in Events, Recordings, Sites or TimeSeries. Available, missing, excluded, not applicable, not assessed and absent reviewed snapshots remain distinct. Negative contributions and quality flags remain separate from inclusion. The primary tables retain every row-level value/flag, so the summary never replaces measurements or conceals missing contributions. Definitions explains the summary, source scope and selection rules. Do not make scientific sums, means, weights or new exposure normalization.

This is a reporting-layout version change, identified in the new receipt/Definitions. It is not revision-31 scientific-policy adoption or a change to local references, burden or normalization. Prior workbooks remain intact.

## Three bounded batches

1. Freeze the exact grouping/selection rules and comparison against the old cell-level projection using constructed tables. Keep the contract's missingness, signed values and automatic/reviewed roles.
2. Build summaries directly, avoiding the million-row intermediate. Format worksheet rows in one bounded pass, preserving cell values/types/number formats, filters and frozen identities. Avoid loading/serializing all source tables merely to restore an absent selection sidecar; keep exact file/snapshot/metadata binding and validation. Fix the State getter to return live state. No new production language or package.
3. Run the finite checks below, then complete one named saved-bundle GUI export and inspect its sheets. Record file sizes, time, source preservation and comparison limitations; stop after acceptance.

Production changes are restricted to the compact source adapter, projector/definitions, formatter, preview/export binding and panel/persistence helpers introduced in the completed milestone. Scientific kernels and legacy formats remain protected.

## Acceptance and limits

- **Two active engineering hours**, three sequential batches, **one repair**.
- Three constructed scenario families: summary count/missingness/flag preservation; source binding/live GUI state; bulk formatting with numeric/text readback. **At most six total function evaluations**, including retries. Disable scientific calculators/image readers.
- One named saved source: the already selected completed 17-recording automatic export. Small whitelisted saved tables/series and streaming file checksums only; no raw/denoised arrays, traces, images, re-detection, source regeneration, individual cases or detector benchmark. No reserved raw recording is opened or changed.
- One saved-bundle GUI acceptance workflow, with at most one repair/retry; no other recording source.
- **At most two MATLAB worker starts**, **three total new XLSX dispatches**: one constructed output, one final real saved-value compact output, and at most one affected writer retry. No new input workbook. Count failures.
- **6 GiB process-tree RSS**, **100 MiB new evidence/scratch**, **25 MiB total new compact outputs**. The memory cap accommodates the observed large saved-source loading transient; no original source copy is created.
- Compare core saved values at `1e-10 * max(1,abs(source))`; IDs, flags, versions and hashes exact. Summed summary row counts must reconstruct the original cell-status inventory and each state/reason/quality count. No partial burden totals are calculated.
- Preserve the original detector, 20-second reference, signed burden formula, normalization, saved results and original detailed formats. No new mandatory CSV fields, peak area, inferred phases or mouse/session pooling.
- Stop on acceptance or any source/resource/effort/repair/attempt boundary. No automatic next campaign, commit, push or release.

Alternative: keep the current preview and existing detailed exports, with no compact batch workbook written. The [workspace rules](../AGENTS.md) require approval “Before implementation” for the next bounded milestone. The current “Try that” product-use request is not treated as permission to change this reporting layout.
