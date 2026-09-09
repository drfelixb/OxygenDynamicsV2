# Production contact-ledger integration, 2026-09-09

The existing BOI analysis now exports contact edges, contact frames and native
event exposure in normal master/statistics outputs. See
[field definitions and interpretation](../../SURGE_CONTACT_PROVENANCE.md).
Linking, site grouping, normalization, baseline selection and amplitude formulas
are unchanged. Contact exposure belongs to each individual event; events at the
same recurring site can have different contact annotations.

## What was run

1. **Six cached candidate replays** from the previous branch-policy experiment,
   representing four source recordings: ID400, ID401, FB2312 and the separate
   FB2411 fluorescence control. These are not six new master runs.
2. **One complete reference master and statistics rerun:** the ID401
   `smooth_pairs` challenge, 512 × 512 × 600 frames, 1 Hz, 4.75 µm/pixel.
   This movie contains prescribed sink and surge intensity changes on the
   archived background; it is not the unchanged biological baseline recording.
3. Synthetic master/statistics integration, including a zero-event recording,
   102 focused MATLAB tests, smoke checks and repository checks.
4. Ten Python regression tests for the separately frozen branch-policy verifier.

The original source is
`sub-ID401/sub-ID401_ses-M401-01-baseline-awake_image.nwb` in DANDI 000891,
version 0.240215.0831. Full source profiles, asset IDs, archived-series names,
input hashes and calibrations are preserved in each replay's `provenance.json`.
`cached-input-hashes.csv` additionally pins the cached MATLAB candidate inputs.
These are previously examined development sources, not independent held-out
validation recordings. No biological accuracy estimate is claimed.

## Results

All six cached replays preserve the prior candidate IDs, retained event/site
identities and saved site masks. The independent test-only tracker reproduces
every overlap edge; a separate audit verifies contact frame lists, durations,
unique footprint fractions, partner relationships, rejection flags and event/site
joins. This includes rejected candidates and unchosen overlap connections.

| Source and challenge | Retained surge events | Events with contacts | Of those, touching rejected candidates | Retained contact event-frames |
|---|---:|---:|---:|---:|
| FB2312 growing | 40 | 14 | 14 | 36 |
| FB2312 shrinking | 39 | 13 | 13 | 35 |
| FB2411 growing | 12 | 11 | 11 | 44 |
| FB2411 shrinking | 11 | 10 | 10 | 44 |
| ID400 moving | 49 | 25 | 24 | 64 |
| ID401 stationary pairs | 18 | 6 | 6 | 10 |
| Total over these six challenge movies | 169 | 79 | 78 | 233 |

Across all candidates, the replays include 11,035 runs, 17,377 nonzero overlap
edges, 3,483 contact edges and 4,547 candidate/frame contact rows. These totals
include repeated challenges on the same sources. They do not count independent
biological events, and a contact to a short fragment does not prove that the
fragment is a separate oxygen event or noise.

The complete ID401 rerun retains **123 sink events and 18 surge events across
11 surge sites**, with every pre-existing event/site column unchanged except
the recording path. Full native masks, event timing, baseline statuses and
signed amplitudes match the preceding output. Independent measurement checks
pass for all **141 event records**: 61 finite amplitudes and 80 unavailable
amplitudes, with zero arithmetic mismatches. No missing amplitude was filled.

The new ID401 statistics output reports six surges with contacts, all six touching
rejected candidates, and ten contact event-frames. It still counts 18 detected
surge events. Detailed contact assessment is present for surges and explicitly
unassessed for sinks. The saved event metadata, workbook definitions and recording
QC agree with the new per-recording ledgers.

All **102 MATLAB tests** pass, including eight new contact tests covering splits,
merges, rejected siblings, both retained neighbors, deduplication, physical units,
empty/no-contact inputs, gaps, unassessed metadata and independent graph parity.
Smoke and synthetic master/statistics integration pass. Repository checks inspect
381 MATLAB files with 73 existing Code Analyzer messages. Ten Python verifier
regression tests also pass. MATLAB source hashes remain fixed throughout the
complete validation run.

## Contract and limits

- Detector: `existing-v2-surge-shape-continuity-5` (unchanged).
- Normalization: `spatial-sd_then_temporal-sd` (unchanged).
- Measurement output: `event-footprint-contact-ledger-7`.
- Statistics: `mouse-strict-contact-qc-8`.

Older output contracts are rejected before pooling and require reanalysis. The
annotation change does not justify reinterpreting previous historical-contract
reports as fresh master runs. The full cohort still needs rerunning after the
remaining detection/measurement definitions are settled.

Whole-candidate footprint exposure at contacts is not a contaminated-pixel
estimate. Event-frames/event-seconds summed across events are not unique
recording frames/time. No contact flag automatically changes an event count,
joins a gap, refines onset or changes amplitude availability.

## Files and reproduction

- `candidate-replay-summary.csv`: the six geometry-replay summaries.
- `candidate-replays/*/*/*.csv.gz`: all candidate, edge and contact-frame ledgers.
- `master-ID401/*.csv.gz`: the ledgers actually saved by the complete master,
  including the existing gap-review table.
- `master-statistics-qc.csv`: the complete recording-level measurement QC.
- `independent-amplitude-audit.csv`: all 141 independently checked event records.
- `completion.json`, `python-regression-verification.json`, `code-manifest.csv`,
  `cached-input-hashes.csv`: validation scope, source identity and verification.
- `artifact-manifest.json`: compact machine-artifact hashes; excludes itself and
  this README. Compression is lossless and verified during packaging.

Large TIFF, MAT and workbook outputs remain in
`../reference-validation/surge-contact-provenance-20260909` outside Git. From the
repository root in MATLAB, use an output directory that does not already exist:

```matlab
setupOxygenDynamicsPath;
addpath('tests/analysis');
s = parallel.Settings; s.Pool.AutoCreate = false;
runSurgeContactValidation( ...
 '../reference-validation/surge-branch-replay-20260909', ...
 '../reference-validation/surge-contact-provenance-new');
```

That runner includes the six replays, one reference master/statistics run,
independent measurement audit, synthetic integration, focused tests and smoke
checks. Run the Python tests separately:

```sh
python3 -B -m unittest discover -s tests/analysis -p 'test_verify_surge_branch_replay.py' -v
```

Next test local separation of neighboring signals within existing candidate
components. Use explicit contacts to evaluate that change before settling the
spatial amplitude support and surge onset/baseline definitions.
