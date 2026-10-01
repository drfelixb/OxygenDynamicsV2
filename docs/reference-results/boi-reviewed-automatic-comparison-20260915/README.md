# Original versus reviewed optical comparison

15 September 2026 · R2-REVIEWED-AUTOMATIC-COMPARISON-069

The bounded comparison is complete. Read [the report](comparison-report.md)
for interpretation and [the figure](run-01/reference-boundary-comparison.png)
for reference/boundary inspection.

- [Optical comparison](run-01/optical-comparison.csv): seven original/reviewed
  pairs; unavailable numbers remain missing.
- [Boundary/reference geometry](run-01/boundary-reference-comparison.csv):
  duration and exact counts of old reference candidates within reviewed bounds.
- [Complete comparison](run-01/comparison.json): all original and reviewed
  records, selected samples, exact overlaps, matched extrema and source map.
  MATLAB JSON encodes NaN as null; the corresponding status is retained.
- [Vector figure](run-01/reference-boundary-comparison.pdf).
- [Verification](verification.json), [input hashes](inputs.json),
  [preservation](preservation.json) and [run log](run-01.log).

The local MATLAB runner is `compareReviewedAutomatic.m`; the portable copy
is `compareReviewedAutomatic.m.txt` to keep evidence outside the runnable
production path. The MAT result is retained locally. To reproduce from the
same pinned workspace sources, use a new, unused output name:

```matlab
addpath('/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-reviewed-automatic-comparison-20260915');
compareReviewedAutomatic('run-02');
```

The runner rejects an existing output directory and source checksum changes.
It reads the audit, both masters and the final phase-068 exports, replays
original arithmetic against the saved master measurements, verifies fixed
footprints and source traces, compares all seven saved intervals, and checks
missingness and overlaps. It does not rerun detection or alter any source.

All 485 existing MATLAB files and 613 sealed phase-068 artifacts were checked
unchanged. Prior ledger versions are in `before/`; only the two current
ledgers and a new report are updated in the repository. The phase-068 tests
remain the production-code verification; this phase adds a source-bound
MATLAB comparison and numerical/visual checks, not new production tests.

`artifact-record.json` seals local, portable and current repository artifacts;
`completion.json` records its checksum. Neither file includes itself in the
seal. Original automatic measurements, manual judgments, uncertain recognition,
draft definitions and positive local feedback are preserved separately.

Both reference selection and bounds changed. The before/after differences
do not isolate their contributions. The four guided examples establish no
independent validation, global baseline duration, detector improvement or
physiological calibration. Next is to specify a separate transfer check on
additional BOI recordings with the standing scientific and usability requirements.
