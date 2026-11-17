# Physical surge tracking validation, 2026-09-09

See [current rules and limitations](../../SURGE_TRACKING.md). This is validation
of the existing BOI analysis path. No alternative detector is included.

## Source recordings and cases

| Source session | Role | Complete converted image dimensions | Pixel size | Sampling |
|---|---|---|---|---|
| M400-01-baseline-awake | BOI reference, ID400 | 512 × 512 × 600 | 4.75 µm | 1 Hz |
| M401-01-baseline-awake | BOI reference, ID401 | 512 × 512 × 600 | 4.75 µm | 1 Hz |
| FB2411 | Separate fluorescence control | 221 × 394 × 301 | 6.75 µm | 1 Hz |
| FB2312-baseline-awake | BOI reference, FB2312 | 512 × 512 × 1,200 | 2.35 µm | 1 Hz |

Five full-movie inputs per source: unmodified control, smooth pairs, a clean
single pulse, the same singleton with recorded Gaussian intensity perturbations,
and a clean moving singleton. These are four distinct recordings, not twenty
independent biological samples. Original DANDI 000891 asset IDs, NWB series,
source hashes and calibration metadata are preserved in the manifests.

The first four cases on the first three sources reproduce the previous audit's
signal recipes. FB2312 control is also compared with the preceding unchanged
source rerun. Every injected disk has radius 85.5 µm, with centres initially at
round(0.33 × width) for the sink and round(0.67 × width) for the surge, both at
round(0.5 × height). Both signs are present simultaneously. Moving centres
translate horizontally by 4.75 µm/s during inclusive frames 101–160 and are
rounded to image pixels; total prescribed displacement is 280.25 µm before
pixel rounding. No spatial crop is used.

Smooth pair supports are frames 41–60/66–85, 111–130/146–165 and 196–215/246–265,
with 5, 15 and 30 empty seconds between pair members. The singleton occupies
101–160. The local injection is ±0.2 × sin²(pi × j / (L+1)), so its peak is
approximately 20% and its endpoints are small but nonzero. Gaussian perturbations
have SD 0.08 in fractional intensity units, shared across each patch's pixels
and independent over time/sign. This is not calibrated photon noise. Noise
seeds and the complete applied fractions are recorded. All inputs are uint16
without intensity rescaling; clipping is rejected.

Controls are scored in the six pair supports and both static/moving singleton
supports. The moving support has TruthRow 8. Other cases are scored only in their
imposed supports. Native space-time IoU, intersecting runs, matched row IDs,
timing errors and amplitude availability are exported. `TruthEligibleFraction`
reports the fraction of the support within that sign's eligible tissue area;
this helps distinguish recording-area exposure from tracking limitations.

## Candidate-mask sweep

The separate 720-case sweep tests four circle radii, five physical speeds,
three pixel calibrations, three sampling rates and four overlap thresholds.
These prescribed 12-second candidate sequences have no image background or
biological event labels. A radius of 45 µm falls below the physical area cutoff
and is deliberately excluded at every pixel calibration.

At the selected overlap 0.6, full native duration is retained in all 27 eligible
size/calibration/sampling combinations at each speed 0, 4.75 and 9.5 µm/s.
At 19 µm/s, 25/27 retain the full run; at 38 µm/s, 17/27 do. Losses occur mainly
at low sampling rates. Near the threshold, rasterization can change whether
adjacent coverage passes at different pixel sizes. This is not a claim of exact
scale invariance or biological sensitivity.

Across the 135 above-area combinations, complete runs are retained in 129 at
threshold 0.5, 123 at 0.6, 120 at 0.7 and 100 at 0.8. This sweep does not justify
selecting 0.5: permissiveness for prescribed motion does not measure erroneous
linking in biological backgrounds. The default 0.6 was fixed before these results.
`PreviousRuleRuns` uses the former 400-pixel area/390-pixel fixed-seed rule and
reports retained run count, not necessarily complete native duration.

## Interpretation constraints

- Nonzero overlap with a support is not an accuracy cutoff. Multiple intersecting
  runs can reflect spatial components, fragmentation or background activity.
- Geometry-only tracking checks do not validate normalization, candidate
  formation, physiological onset/return or full-movie sensitivity.
- Independent amplitude audits test the saved definition, including unavailable
  baselines. A delayed onset can include a smooth rise in the baseline. A moving
  event's fixed union footprint can dilute its instantaneous local peak.
- Sink native masks and timing are checked against the preceding identical
  inputs. Sink amplitude availability can change when new surge masks exclude
  parts of the pre-event baseline.
- Possible split/merge flags include candidates later rejected by duration;
  the saved-output audit cannot independently reconstruct those discarded
  candidate contacts. Unit tests cover the flag and ownership rules.
- No physiological event labels are available. These results cannot support
  biological sensitivity, specificity or a publication-ready accuracy claim.

## Localizing the remaining short-pulse and moving-signal losses

Stage reconstructions for ID400 smooth pairs, ID401 smooth pairs and ID400 moving
input reproduce the saved surge masks exactly. They reuse production detection
functions. The first three stages summarize the union of candidate pixels per
frame, not individual region identities; their row bounds must not be read as
candidate/event lifetimes. Within-track continuity is assessed separately.

| Background / missed pair window | Frames containing accepted pixels | Longest intersecting track before duration filtering |
|---|---:|---:|
| ID400 / 3 | 12 | 6 |
| ID400 / 4 | 13 | 6 |
| ID400 / 5 | 10 | 8 |
| ID401 / 1 | 14 | 6 |
| ID401 / 4 | 11 | 3 |
| ID401 / 6 | 13 | 7 |

These pieces fail the ten-frame minimum at 1 Hz. ID401 window 1 retains candidate
pixels for fourteen consecutive frames but still splits into short tracks,
showing that region geometry/assignment contributes to the loss. For ID400's
moving singleton, threshold selection intersects all 60 frames, geometry/tissue
filtering intersects 50, and only one ten-frame piece survives from eighteen
intersecting tracks. The selected geometry-only motion tests therefore do not
establish full-movie detection completeness.

The trace helper was executed from a temporary directory while the full-movie
code manifest remained frozen, and added to the repository after that batch.
`stage-source.sha256` identifies its exact source. Its three JSON reports record
input hashes and exact saved-mask agreement.

## Full-movie results

Counts below mean windows with any intersecting native detection, not accuracy.
The full CSV reports space-time IoU and timing errors; very small overlaps should
not be interpreted as recovery of the imposed event.

| Source | Case | Sink windows intersecting | Surge windows intersecting |
|---|---|---:|---:|
| M400-01-baseline-awake | control | 0/8 | 0/8 |
| M400-01-baseline-awake | smooth_pairs | 6/6 | 3/6 |
| M400-01-baseline-awake | single_clean | 1/1 | 1/1 |
| M400-01-baseline-awake | single_noise | 1/1 | 1/1 |
| M400-01-baseline-awake | moving_clean | 1/1 | 1/1 |
| M401-01-baseline-awake | control | 0/8 | 0/8 |
| M401-01-baseline-awake | smooth_pairs | 6/6 | 3/6 |
| M401-01-baseline-awake | single_clean | 1/1 | 1/1 |
| M401-01-baseline-awake | single_noise | 1/1 | 1/1 |
| M401-01-baseline-awake | moving_clean | 1/1 | 1/1 |
| FB2411 | control | 0/8 | 0/8 |
| FB2411 | smooth_pairs | 6/6 | 0/6 |
| FB2411 | single_clean | 1/1 | 0/1 |
| FB2411 | single_noise | 1/1 | 0/1 |
| FB2411 | moving_clean | 1/1 | 1/1 |
| FB2312-baseline-awake | control | 1/8 | 2/8 |
| FB2312-baseline-awake | smooth_pairs | 6/6 | 2/6 |
| FB2312-baseline-awake | single_clean | 1/1 | 0/1 |
| FB2312-baseline-awake | single_noise | 1/1 | 0/1 |
| FB2312-baseline-awake | moving_clean | 1/1 | 1/1 |

Compared with the preceding tracker on identical static inputs, ID400's clean
and noisy singleton surges now have intersecting detections (IoUs 0.239 and
0.254), where previously there were none. Both BOI pair tests remain at 3/6.
The fluorescence-control singleton injections lose their previous small
intersections (old IoUs 0.087 and 0.079). Results are mixed, not evidence that
the full detector is validated. The moving fluorescence case has only a 0.011
best IoU; its nonzero intersection is not meaningful evidence of completeness.

### Unmodified recording comparisons

| Recording | Previous surge runs / sites | Current surge runs / sites | Previous / current finite surge amplitudes |
|---|---:|---:|---:|
| M400-01-baseline-awake | 40 / 14 | 32 / 27 | 19 / 19 |
| M401-01-baseline-awake | 1 / 1 | 4 / 4 | 0 / 3 |
| FB2411 | 1 / 1 | 6 / 6 | 0 / 2 |
| FB2312-baseline-awake | 58 / 19 | 35 / 16 | 28 / 16 |

All thirteen available identical-input comparisons preserve sink native masks,
timing and identities exactly. Sink amplitude availability changes because both
signs' masks contribute to baseline exclusion. For example, ID400 control keeps
196 sink runs across 56 sites, while finite sink amplitudes change from 97 to 105.
Fluorescence-control surge counts increase from 1 to 6; that is not evidence of
oxygen-specific detection. These are unlabelled reference recordings.

### Numerical and geometry verification

All 3,773 baseline/status/amplitude records agree with independent recalculation,
including unavailable values; 1,896 are finite and 1,877 unavailable.

| Event sign | Native runs | Finite amplitudes | Unavailable amplitudes | Opposite raw-intensity direction | Close runs | Possible split/merge flags | Ambiguous site assignments |
|---|---:|---:|---:|---:|---:|---:|---:|
| sink | 3327 | 1656 | 1671 | 11 | 1950 | not assessed | not assessed |
| surge | 446 | 240 | 206 | 30 | 60 | 178 | 12 |

These totals pool repeated validation variants, not independent biological samples.
Signed amplitudes are retained even when their raw-intensity direction disagrees
with the processed-contrast label. The Python verifier checked 3,276,774,370
pixels against source hashes and the fraction/position ledgers, also checking
the analytic noise-free pulse and prescribed motion. The noise RNG sequence is
not independently regenerated; half-count JSON rounding ties have an explicit
1e-9-count tolerance. The separate mask audit verifies all 136 overlap rows,
native gaps/flags, surge timing, physical-area and adjacent-coverage rules,
fixed site anchors, and unique per-frame surge pixel ownership.

MATLAB R2025a: all 67 focused analysis tests, smoke checks and synthetic
master-to-statistics integration passed. The batch inspected 360 MATLAB files
and reported 69 Code Analyzer messages (not a warning-free lint result).
`code-manifest.csv` stayed unchanged through all twenty movie runs. The staged
trace helper was subsequently added to the repository; its exact source hash
is recorded separately. Generated TIFF/MAT files remain in the local
`reference-validation` folders; only compact reports and input ledgers are in Git.

After adding the executed trace helper, final repository inspection passed for
361 MATLAB files with 70 Code Analyzer messages. No production detection or
measurement code changed after the frozen full-movie batch.
