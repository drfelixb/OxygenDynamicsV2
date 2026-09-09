# Existing surge tracker: split/merge replay, 2026-09-09

**Decision:** retain the production rule while developing explicit contact
provenance and testing candidate separation. A majority extension recovers some
imposed support, but controlled examples prove that dominant overlap can change
source identity after contact. The current 60% primary rule has the same class
of failure. See [policy definitions and next steps](../../SURGE_BRANCH_POLICY.md).

## Scope and source recordings

Six **complete movie replays** from four previously used source recordings:
three BOI references and the separate FB2411 fluorescence control. No new raw
recordings, master/statistics runs or amplitude calculations are claimed here.
The frozen constructed TIFF inputs are reused; their hashes, original source
hashes, DANDI asset IDs, series names and calibration are in each case's
`provenance.json` and `challenge-manifest.json`.

| Source | Replayed challenge | Image dimensions × frames | Pixel size | Sampling |
|---|---|---|---:|---:|
| `sub-ID401/sub-ID401_ses-M401-01-baseline-awake_image.nwb` | Six stationary smooth pairs | 512 × 512 × 600 | 4.75 µm | 1 Hz |
| `sub-ID400/sub-ID400_ses-M400-01-baseline-awake_image.nwb` | Moving singleton | 512 × 512 × 600 | 4.75 µm | 1 Hz |
| `sub-FB2312/sub-FB2312_ses-FB2312-baseline-awake_image.nwb` | Growing and shrinking singletons | 512 × 512 × 1,200 each | 2.35 µm | 1 Hz |
| `sub-FB2411/sub-FB2411_ses-FB2411_image.nwb` | Growing and shrinking singletons | 221 × 394 × 301 each | 6.75 µm | 1 Hz |

The archive release is DANDI 000891 version 0.240215.0831, as in the preceding
reference work. Archived intensity preparation is not assumed to be untouched
camera output. Each challenge contains both signs in separate patches, but this
replay compares **surge candidate linking only**. It does not recalculate sinks,
recurring sites, baseline exclusion, amplitudes, or mouse summaries.

Recipes were fixed in the preceding [continuity](../surge-shape-continuity-20260909/README.md)
and [shape](../surge-shape-evidence-20260909/README.md) experiments. Imposed local
intensity changes peak near ±20% with sine-squared time courses. Moving support
travels at 4.75 µm/s; growing/shrinking radii change between 60 and 120 µm.
These sources and the known ID401 failure informed development; none is a
held-out biological validation set.

## Verification

- **94 focused tests passed**, including nine new branch-policy tests.
- Repository checks passed: 376 MATLAB files, 73 existing Code Analyzer messages.
- All six baseline reconstructions reproduce saved production site masks and
  candidate/gap ledgers exactly. Production MATLAB hashes match the prior runs;
  the complete MATLAB source manifest is unchanged during replay.
- All four policies preserve every accepted candidate pixel exactly once and
  maintain contiguous runs without filling gaps. Sibling runs are kept even if
  they fail duration qualification.
- Independent Python verification passes for **44,193 candidate-run rows and
  69,508 overlap-edge rows** across 24 policy/movie comparisons. These are repeated
  policy evaluations of six movies, not distinct biological events.
- Graph verification recomputes area/overlap arithmetic, all link decisions,
  partner counts, contact flags, run durations and qualification. It does not
  independently establish image segmentation or biological identity.

The original production detector contract remains
`existing-v2-surge-shape-continuity-5`; measurement/statistics identities are also
unchanged. Production calculations are unchanged from `03bdce8`.

## Retained runs across complete recordings

| Policy | All candidate runs | Duration-qualified runs | Qualified runs flagged ambiguous | Linked contact edges |
|---|---:|---:|---:|---:|
| Current isolated-shape rule | 11,035 | 169 | 79 | 477 |
| Majority extension | 10,759 | 188 | 98 | 753 |
| Split-only extension | 10,887 | 174 | 84 | 625 |
| Stop at every contact | 11,512 | 144 | 54 | 0 |

These totals describe algorithmic runs throughout the six challenge movies,
including their original background fluctuations. They are **not independent
event accuracy or site counts**. Increasing or decreasing them is not itself an
improvement. Contact flags remain on runs that end or begin at a contact even
when the contact is not linked, explaining nonzero ambiguity in the last row.

The majority extension adds 276 contact links and the split-only extension adds
148. Stopping every contact removes 477 existing links. The extensions preserve
all previously retained pixel-frames in this batch; stopping at contacts removes
2,030,430 retained pixel-frames. Changed event identities could still change
amplitudes and baseline exclusions in a subsequent master rerun.

## Overlap with imposed surge support

IoU is intersection divided by union of the **complete native space-time
supports**, including candidate pixels outside the injected patch. Nonzero IoU
is not a prespecified success criterion or proof that an event is the injection.

| Imposed surge window | Current | Majority extension | Split-only extension | Stop at contacts |
|---|---:|---:|---:|---:|
| ID401 first pulse, frames 41–60 | 0 | 0.3624 | 0.3624 | 0 |
| ID400 moving singleton, frames 101–160 | 0.1194 | 0.1194 | 0.1194 | 0.1194 |
| FB2312 growing, frames 101–160 | 0.1643 | 0.2249 | 0.1643 | 0.1643 |
| FB2312 shrinking, frames 101–160 | 0 | 0.1788 | 0 | 0 |
| FB2411 growing | 0 | 0 | 0 | 0 |
| FB2411 shrinking | 0 | 0 | 0 | 0 |

The other five ID401 windows have unchanged best IoU under all four policies.
Thus the majority extension improves three of eleven evaluated surge windows,
and the split-only extension improves one. The moving and fluorescence-control
challenges remain unresolved. Full 44-row results are in `support-scores.csv`.

The ID401 first pulse now has one 14-frame run, frames **44–57**, instead of two
seven-frame rejected pieces. At frame 50→51, its continuing child has 0.5286
mutual coverage, 0.9764 containment and area ratio 1.8471. The sibling remains
separate, with both edges recorded. The gain is real for this imposed support,
but does not establish that the same linking choice is correct for all natural
contacts.

FB2312's best growing run extends from 133–143 to **127–143** under the majority
extension. Its shrinking challenge gains a best run at **127–141**. The growing
case has 30 frames of retained intersection across all retained runs; this must
not be confused with the 17-frame duration of the single best match.

## Artifacts and reproduction

- `policy-summary.csv`: recording-wide candidate/run and changed-link counts.
- `support-scores.csv`: all policy-specific matches to imposed surge windows.
- Per-case `*-runs.csv.gz` and `*-edges.csv.gz`: complete rejected/retained run
  ledgers and all nonzero overlap connections. Run IDs are policy-local.
- `completion.json`, `test-verification.json`, `graph-verification.json`:
  machine-readable verification and its limits.
- `code-manifest.csv`, `artifact-manifest.json`: MATLAB source and compact
  machine-artifact hashes. The artifact manifest excludes itself and this README.

Large TIFFs and cached `candidate-input.mat` files remain outside Git in
`../reference-validation/surge-branch-replay-20260909`. Source movies remain in
the preceding validation folders. From the repository root in MATLAB:

```matlab
setupOxygenDynamicsPath;
addpath('tests/analysis');
s = parallel.Settings; s.Pool.AutoCreate = false;
runSurgeBranchReplay( ...
 '../reference-validation/surge-shape-continuity-20260909', ...
 '../reference-validation/surge-shape-evidence-20260909', ...
 '../reference-validation/surge-branch-replay-new'); % must not exist
r = runtests('tests/analysis'); assertSuccess(r);
runRepositoryChecks;
```

The independent verifier accepts either the complete output directory or these
compact artifacts, reading gzip ledgers automatically:

```sh
python3 tests/analysis/verify_surge_branch_replay.py docs/reference-results/surge-branch-replay-20260909
```

This writes `graph-verification.json`. Its verifier source hash records the exact
Python code used. No rule from this comparison is active in production.
