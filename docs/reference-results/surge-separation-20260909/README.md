# Local surge separation: full-reference experiment

**Decision: retain the partition as validation-only code.** It improves coverage
of two stationary imposed signals in ID400 and ID401, but does not consistently
maintain separate identities through approach/crossing or improve the finer
acquisition. It also changes retained-run counts in unchanged recordings.
Production detection, normalization, amplitudes and statistics are unchanged.

## Scope and sources

Twenty complete movie evaluations: four unchanged source controls and sixteen
constructed challenges, using the same four development references from Dandiset
000891, version `0.240215.0831`. These are **four source recordings**, not twenty
independent biological samples. FB2411 is interpreted separately as fluorescence.

| Source | Archive NWB path | Image height × width × frames | µm/pixel |
| --- | --- | --- | --- |
| ID400 awake baseline | `sub-ID400/sub-ID400_ses-M400-01-baseline-awake_image.nwb` | 512 × 512 × 600 | 4.75 |
| ID401 awake baseline | `sub-ID401/sub-ID401_ses-M401-01-baseline-awake_image.nwb` | 512 × 512 × 600 | 4.75 |
| FB2312 awake baseline | `sub-FB2312/sub-FB2312_ses-FB2312-baseline-awake_image.nwb` | 512 × 512 × 1,200 | 2.35 |
| FB2411 fluorescence control | `sub-FB2411/sub-FB2411_ses-FB2411_image.nwb` | 394 × 221 × 301 | 6.75 |

All use 1 Hz sampling. Each case manifest contains the archive asset identifier,
selected image series, original conversion hash, challenge hash and calibration.
Image dimensions above describe the MATLAB TIFF orientation, not the NWB/HDF5
storage-axis order.

Every movie went through the complete existing detrending, tissue estimation,
normalization, smoothing and candidate detection. Native and partitioned
candidates then used the same existing tracker. **No master/statistics reruns or
amplitude recalculations were performed in this experiment.**

The [prespecified protocol](../../SURGE_CONTACT_SEPARATION.md) defines the four
Gaussian challenges, conservative partition and all counting/scoring units.
All parameters were fixed before reviewing scores. The MATLAB source manifest
was unchanged throughout the completed run. An earlier attempt stopped before
detection because the harness passed uint16 data to polynomial detrending; it
was preserved separately as `surge-separation-20260909-partial-input-type` and
is excluded from these results.

## Coverage and event counts

Arrows show **native → experimental partition**. Coverage is the fraction of a
source's known imposed light inside its assigned retained event, integrated over
the imposed window. Different source recipes must receive different event IDs.
Zero coverage can mean that both sources' light occupies the same merged event;
it does not establish absence of that light from all detections. Values are
rounded to one decimal percent. These percentages are not biological accuracy.
Retained runs cover the entire recording, including activity outside the injection.
They are individual duration-qualified runs, not recurring sites/ROIs.

| Source | Challenge | Source 1 coverage | Source 2 coverage | Retained runs |
| --- | --- | --- | --- | --- |
| ID400 | Stationary pair | 12.5% → 50.4% | 9.1% → 49.6% | 47 → 53 |
| ID400 | Approach pair | 76.0% → 17.3% | 0.0% → 60.3% | 46 → 50 |
| ID400 | Crossing pair | 79.3% → 81.8% | 0.0% → 0.0% | 47 → 50 |
| ID400 | Single expanding | 84.4% → 84.4% | — | 49 → 51 |
| ID401 | Stationary pair | 17.4% → 77.7% | 0.0% → 66.3% | 10 → 11 |
| ID401 | Approach pair | 73.9% → 73.9% | 0.0% → 0.0% | 10 → 10 |
| ID401 | Crossing pair | 3.3% → 3.3% | 77.5% → 77.5% | 10 → 10 |
| ID401 | Single expanding | 83.4% → 83.4% | — | 10 → 10 |
| FB2312 | Stationary pair | 26.3% → 26.3% | 24.5% → 24.5% | 42 → 43 |
| FB2312 | Approach pair | 33.8% → 33.8% | 25.7% → 25.7% | 40 → 41 |
| FB2312 | Crossing pair | 39.3% → 39.3% | 22.9% → 22.9% | 40 → 41 |
| FB2312 | Single expanding | 31.1% → 31.1% | — | 40 → 41 |
| FB2411 fluorescence | Stationary pair | 0.0% → 0.0% | 0.0% → 0.0% | 6 → 6 |
| FB2411 fluorescence | Approach pair | 0.0% → 0.0% | 0.0% → 0.0% | 9 → 9 |
| FB2411 fluorescence | Crossing pair | 0.0% → 0.0% | 0.0% → 0.0% | 7 → 7 |
| FB2411 fluorescence | Single expanding | 0.0% → 0.0% | — | 5 → 5 |

The full precision [case comparison](case-comparison.csv) and
[112 source-score records](recipe-scores.csv) also retain imposed-source
contribution, all-retained coverage, descriptive fragmentation counts, native
bounds and partition exposure. In the ID400 approaching case, one selected run
contains only 46.5% source-2 contribution among its imposed light: assignment to
source 2 does not imply a clean separation. The selected single-expanding coverage
is unchanged in all four sources; background counts can still change.

## Unchanged controls and failure mechanisms

| Unchanged source | Retained runs, native → partition |
| --- | --- |
| ID400 | 50 → 52 |
| ID401 | 9 → 9 |
| FB2312 | 39 → 40 |
| FB2411 fluorescence | 7 → 7 |

Assigned hypothetical recipe coverage is unchanged in all four controls. These
count changes therefore cannot be credited to recovery of an imposed signal.
They are not labelled false positives either: native physiological truth is
unknown. All raw candidates, rejected runs and contact edges remain available.

The [960 peak-location frame traces](recipe-peak-decisions.csv) and
[reason counts](recipe-peak-decision-counts.csv) explain the main limitations:

- The ID400 and ID401 stationary pairs each receive sixteen parent-frame splits
  while both prescribed peak locations occupy one native candidate.
- In ID401's approaching pair, 32/80 frames have one or both recipe peaks outside
  admitted candidates, eight already have separate native candidates, three fail
  the history requirement, and 37 lack exactly two preceding overlapping
  candidates. Relaxing only the saddle threshold would not solve this case.
- The finer-resolution paired challenges have no successful split of the native
  parent containing both recipe peaks. Insufficient history/admission limits
  their opportunities. Their unchanged scores do not isolate the effect of
  spatial resolution from background, normalization or other acquisition factors.
- In each FB2411 paired challenge, one or both prescribed peaks are outside
  admitted candidates for 76/80 frames. The near-zero retained coverage is a
  full-pipeline result, not a specific test failure of the partition step.
  Peak locations were fixed geometrically, not screened to guarantee tissue
  eligibility. This trace does not identify which admission filter excluded them.

Even a perfectly partitioned two-lobed optical field cannot establish whether it
arose from two independent physiological processes or one distributed process.
Whole-movie normalization can also alter candidates outside an imposed patch.
Keep contact/partition uncertainty explicit; do not interpret changed event
counts as established physiological recovery. Physical smoothing remains an
unresolved cross-acquisition dependency.

## Verification and retained evidence

- **114 MATLAB tests passed**, including twelve new partition/recipe checks.
  Smoke checks passed; repository checks inspected 385 MATLAB files, with 74
  Code Analyzer advisory messages (one new suggestion to use `nnz` for a logical
  count). This is not a claim of zero analyzer messages.
- **19 Python tests passed**: ten existing branch-verifier tests and nine new
  separation-verifier tests. The nine new tests also passed under `-O`.
- Independent Python verification ran under `-O`, reconstructed
  **2,621,419,496 challenge pixels**, verified four unchanged source controls,
  checked source/reference metadata and hashes, and found **zero pixel mismatches
  or tolerated rounding ties**.
- Independently verified complete-frame candidate pixel conservation, retained
  native bounds and membership in admitted candidates. Recalculated source light
  inside saved masks and checked distinct-run assignment for **112 score records**.
  This is independent arithmetic/mask auditing, not independent image segmentation
  or physiological ground truth.

See [completion scope](completion.json), [independent verification](independent-verification.json),
[MATLAB tests](matlab-tests.csv), [repository checks](repository-checks.json),
[Python tests](python-tests.txt), [optimized tests](python-optimized-tests.txt),
and the [MATLAB source manifest](code-manifest.csv).
Per-case CSV ledgers use LF line endings and `.csv.gz` compression. The
`artifact-manifest.csv` hashes the compact evidence files. Full TIFF/MAT caches
remain outside Git at `../reference-validation/surge-separation-20260909`.

Next validate amplitude support and event-local onset/baseline together, starting
with surge measurements and known imposed optical changes. Use eligible tissue
locations for a dedicated positive-recovery panel, retaining separate tests of
admission failures. Decide the final amplitude meaning before changing normal
outputs and before completing surge statistics parity/cohort reanalysis.
