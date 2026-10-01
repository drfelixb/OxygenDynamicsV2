# HP local input preflight evidence

Decision `R1-HP-INPUT-001`, 10 September 2026. See the
[readable source review](../../BOI_HP_LOCAL_INPUT_REVIEW.md) and
[portable inventory overlay](../../planning/boi-hp-local-inputs-20260910.json).
The [MATLAB report](preflight-report.json) records technical verification and
the unresolved acquisition hold, not biological acceptance.

Local artifacts are retained in the parent workspace at
`reference-validation/boi-hp-input-20260910/`:

- `inventory/inventory.json`: all original CSV rows/text, candidate paths,
  TIFF headers, archive links and inventory-script hash.
- `inventory/selected-frame-metadata.json`: exact decoded acquisition JSON
  from all 1,200 selected TIFF pages and their source hash. This is metadata,
  not decoded image pixels.
- `identity-pair-check.json`: reason and full hashes establishing identical
  earlier TIFF candidates in FB2416 and FB2417.
- `Recording/`: byte-identical selected earlier TIFF plus a new source-bound
  acquisition declaration. The external source tree was not changed.
- `stage-manifest.json`: external-to-staged mapping, hashes and provisional
  sampling/calibration.
- `matlab-preflight/InputReview.mat`, `InputQC.csv`, `preflight-report.json`:
  complete MATLAB read-only review and assertions.

The original CSV SHA-256 is
`08c3d27d7d59aa334ebd4abc828fd21860cd71a50618cea56d52aadb6c1eab77`.
The selected TIFF contains 635,262,002 bytes with SHA-256
`3d903105aa450da0348d6aa4ddb4b23145099534d5817a826461bb5ff2132e73`.
The acquisition sidecar hash and executed MATLAB source hashes are in the
report. The artifact record alongside this file binds local evidence, exported
evidence and final checks by hash.

Reproduce the source/header inventory with
`tests/analysis/inventoryHPCompartmentInputs.py SOURCE_ROOT NEW_OUTPUT_DIR`
using Python with Pillow. It rejects output inside the source tree, reads no
image pixels or prior results, and never overwrites an existing evidence folder.
It reads headers for 20 candidates, checks every selected page's frame indices,
preserves original acquisition values and hashes only the selected movie.
The supplementary FB2416/FB2417 full-file hash check was triggered by identical
first-page metadata; no detector experiment or alternative case was introduced.

For the staged input, run this in MATLAB with a new copy of the evidence folder
that contains `stage-manifest.json` and `Recording/`, but no `matlab-preflight/`:

```matlab
addpath('/absolute/path/to/existing-analysis/tests/analysis');
runBOIHPInputPreflight('/absolute/path/to/new/evidence-folder');
```

The manifest's staged path must point to that copy; preserve its source SHA-256
and source-bound sidecar. For ordinary interactive review, use
`reviewBOIRecordingInput(recordingFolder,1,2.35)` after reviewing the provisional
units/calibration. A file-import pass does not authorize a master run.

Verification passed: 512 × 512 × 1,200 input metadata, source/staged hash
equality, unchanged per-page timestamps, 0.96 s exposure settings, unknown
frame validity, explicit timing hold and `OxygenDynamics:UnsupportedBOIInput`
from the master's acquisition guard. Runtime was 8.1213 seconds inside MATLAB
R2025a; startup, source inventory and staging are not included. No worker pool
or detector was run. Memory was not measured. Local evidence storage is
reported separately in the artifact record, not extrapolated to cohort cost.

The optional Python `tifffile` import was unavailable during initial header
inspection. Pillow supplied the required header access and the MATLAB import
independently checked the selected dimensions. No dependency was installed,
no TIFF was converted and no pipeline calculation changed.
