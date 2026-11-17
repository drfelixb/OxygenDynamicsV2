# Surge audit and smooth-signal validation, 2026-09-09

See the [ranked surge audit](../../SURGE_ANALYSIS_AUDIT.md) for corrected code,
remaining differences and dependencies. Current numerical amplitudes use raw
individual-event footprints for both signs; the obsolete normalized site ratio
is removed. Terminal seeding is corrected. Surge timing remains native and is
explicitly labelled; recurrence assessment now covers both signs.

## Input design

Three complete converted DANDI 000891 recordings are used:

- ID400 awake, `M400-01-baseline-awake`, 512 × 512 × 600, 4.75 µm/pixel.
- ID401 awake, `M401-01-baseline-awake`, 512 × 512 × 600, 4.75 µm/pixel.
- FB2411 fluorescence control, 301 frames, 6.75 µm/pixel. Its converted TIFF has
  the full original 221 × 394 spatial samples; no spatial crop is used.

All have sampling frequency 1 Hz. These are two BOI animals and one separate
fluorescence-control source, not twelve independent biological recordings.
Each source has four paired inputs: unmodified control, smooth pairs, one clean
smooth pulse, and the same single pulse with recorded intensity noise.

Each image contains a sink injection at x = round(0.33 × width), y = round(0.5 ×
height), and a surge injection at x = round(0.67 × width), the same y. Radius is
85.5 µm, converted using that recording's pixel size. Both signs are present
simultaneously; this is not an isolated one-sign threshold calibration.

Paired pulses occupy inclusive frames 41–60/66–85, 111–130/146–165 and
196–215/246–265: 20-second supports with 5, 15 and 30 empty seconds between pair
members. The singleton occupies frames 101–160. Pulse samples follow
`sin(pi*j/(L+1))^2` times ±0.2, so the support endpoints have small nonzero
amplitudes. The latent peak is approximately 20%, not a rectangular step.

The noisy singleton adds zero-mean Gaussian perturbations with SD 0.08 in
fractional input-intensity units, independently over time/sign but shared across
all pixels of one patch. Seed = 90209 + source index. The complete applied
fraction time series is saved in each manifest. This is not a calibrated photon
noise model. Inputs are rounded to uint16 without intensity rescaling; clipping
is rejected. Physical radius and cases are fixed before observing results.

## How to read the measurements

Every event in every output receives an independent baseline/amplitude audit,
including background events unrelated to injections. The matched-event table
scores both signs in the imposed signal support: best native space-time IoU,
number of overlapping runs, matched native bounds and measurement-boundary errors,
amplitude availability, recurrence flag and timing-resolution status.

The control is evaluated in the identical target windows/masks. Multiple
intersecting runs are not automatically labelled false splits: spatially separate
components or natural background events can also intersect an injected support.
The same matched event row across multiple truth windows can expose a merge.
No IoU cutoff is optimized to these cases, and no biological accuracy rate is
reported. Known nonzero smooth tails make timing errors explicit; detection
thresholds may not retain the full support.

Measured amplitude relative to the algorithm's selected pre-event baseline is
not interchangeable with the imposed fraction relative to the paired source
samples. A baseline can be free of detected events while including an undetected
smooth tail. The arithmetic audit checks the implemented measurement definition,
not this physiological-baseline assumption.

## Isolated moving-region diagnostic

For prescribed 400-pixel square candidates present over 12 frames:

| Candidate motion | Adjacent overlap | Retained surge runs | Retained sink runs |
|---|---:|---:|---:|
| Stationary | 400 pixels | 1 | 1 |
| One pixel/frame | 380 pixels | 0 | 1 |

The default surge tracker requires >390 pixels overlapping its original seed.
This isolates a size/motion limitation after candidate formation. It is not an
end-to-end movie sensitivity estimate, and the thresholds were not adjusted to
make the moving case pass.

## Observed results

| Background | Case | Sink windows intersecting a detection | Surge windows intersecting a detection |
|---|---|---:|---:|
| M400-01-baseline-awake | control | 0/7 | 0/7 |
| M400-01-baseline-awake | smooth_pairs | 6/6 | 3/6 |
| M400-01-baseline-awake | single_clean | 1/1 | 0/1 |
| M400-01-baseline-awake | single_noise | 1/1 | 0/1 |
| M401-01-baseline-awake | control | 0/7 | 0/7 |
| M401-01-baseline-awake | smooth_pairs | 6/6 | 3/6 |
| M401-01-baseline-awake | single_clean | 1/1 | 1/1 |
| M401-01-baseline-awake | single_noise | 1/1 | 1/1 |
| FB2411 | control | 0/7 | 0/7 |
| FB2411 | smooth_pairs | 6/6 | 0/6 |
| FB2411 | single_clean | 1/1 | 1/1 |
| FB2411 | single_noise | 1/1 | 1/1 |

These are counts of target windows with any native space-time intersection,
not sensitivity estimates or confirmed independent events. The control's seven
windows include all six pair supports plus the singleton support; no injection
is applied. All target windows have zero overlap in the controls, despite
background detections elsewhere. See the full CSV for IoU, matched event rows,
measurement availability and timing errors. Low IoU can indicate partial temporal
or spatial capture. The fluorescence singleton surge IoUs are only 0.087 (clean)
and 0.079 (noisy), despite nonzero intersection.

The twelve runs contain 1,549 native event records: 1,343 sinks and 206 surges.
Independent recalculation matches every stored baseline/status/amplitude,
including unavailable values. Finite amplitudes occur in 666 sink records and
78 surge records; 677 and 128 respectively remain unavailable. Four finite sink
amplitudes have the opposite raw-intensity direction; none of these 206 surge
records does. There are 700 close sink runs and 64 close surge runs, counted
across all repeated backgrounds/cases. These totals are not biological replicates.

The standalone Python input verifier checks 1,363,128,296 pixels against source
hashes and the saved fraction ledger, with a declared 1e-9-count tolerance only
for JSON-rounding half-count ties. It does not independently regenerate MATLAB's
noise random-number sequence. A separate MATLAB set-intersection calculation
verifies all 90 matching rows, native gap/recurrence flags and surge timing
metadata against saved masks. The obsolete site-amplitude column is absent.

## Finer-resolution unchanged-source check

A fourth distinct source, FB2312 awake baseline, was separately rerun without
injections: 512 × 512 × 1,200 frames, 1 Hz, 2.35 µm/pixel. Its exact DANDI asset,
NWB series and archive/converted-source hashes are recorded in
`fb2312-source-recheck/source-audit-report.json`. This is not a smooth-injection
validation at the finer pixel scale.

The recording yields 366 sink runs and 58 surge runs. Independent recalculation
matches all 424 measurements/statuses. For surges, 28 amplitudes are finite and
30 unavailable; two finite amplitudes are negative. For sinks, 169 are finite and
197 unavailable; two finite amplitudes have the opposite raw-intensity direction.
Wrong-direction values remain signed and flagged. The detector's relative
processed contrast can disagree with preserved-intensity direction; arithmetic
agreement does not validate calling these absolute oxygen increases/decreases.

Across all 13 master runs on four distinct sources, 1,973 baseline/amplitude
records match independently, of which 941 are finite and 1,032 unavailable.
This update does not rerun the entire eight-recording reference cohort and does
not establish physiological surge timing or biological event accuracy.

## Checks and provenance

MATLAB R2025a: all 57 focused analysis tests passed. Smoke and synthetic
master-to-statistics integration passed; workbook definitions explicitly cover
surge fractions, percentages, native timing and both-sign recurrence. Repository
inspection covered 351 MATLAB files, reporting 60 Code Analyzer messages; it is
not a warning-free lint result.

`code-manifest.csv` freezes the source used for all twelve smooth movie runs;
the runner checked that MATLAB source hashes remained unchanged during that
batch. The subsequent independent overlap verifier, isolated motion diagnostic
and FB2312 recheck runner were added after that batch. The FB2312 subfolder has
its own code manifest. Later edits clarify workbook definitions and extend the
export integration assertions; they do not alter detection or amplitude math.
Input manifests preserve exact applied fraction series, calibration and source
identifiers. Large generated TIFF/MAT outputs remain in the local
`reference-validation` folders and are not included in Git.
