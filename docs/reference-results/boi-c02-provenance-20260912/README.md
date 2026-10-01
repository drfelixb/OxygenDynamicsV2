# C02 source equivalence and preparation provenance

12 September 2026 — **R1-C02-PROVENANCE-020 complete.** All eight local TIFFs
match the selected pixel arrays in the pinned published DANDI files after an
explicit swap of the two spatial axes. No intensity rescaling or frame
reordering is required. This resolves source-array equivalence for these eight
recordings; it does not establish preparation before the preserved TIFFs or
measurement eligibility.

## Verified mapping

For each recording and frame, the verified mapping is
`local_TIFF[row, column, frame] = NWB[column, row, frame]`.
The same mapping passed in all eight cases. Direct comparison without swapping
the two spatial axes did not match; both counts remain in the exports. The
current MATLAB `convertDandiReferenceStack` convention already produces the
local TIFF orientation. No importer correction, changed calibration or silent
orientation adjustment was made.

| Session | Local stored class | Archive stored class | Frames | Unequal pixels after mapping |
|---|---|---|---|---|
| FB2314-baseline-awake | uint16 | uint16 | 1200 | 0 |
| FB2314-baseline-iso | uint16 | uint16 | 1200 | 0 |
| FB2315-baseline-awake | uint16 | uint16 | 1200 | 0 |
| FB2315-baseline-iso | uint16 | uint16 | 1200 | 0 |
| M402-01-baseline-awake | uint8 | uint16 | 600 | 0 |
| M402-03-baseline-iso | uint8 | uint16 | 600 | 0 |
| M403-01-baseline-awake | uint8 | uint16 | 600 | 0 |
| M403-03-baseline-iso | uint8 | uint16 | 600 | 0 |

The archive uses uint16 storage throughout. For the locally uint8 ID402/ID403
sources, the wider archive container preserves every numeric pixel value;
it does not recover additional acquisition precision. Frame-index timing remains
the user-confirmed exact external 1 Hz. Incorrect embedded clocks do not override
it. TIFF/NWB whole-file hashes differ because they are different containers;
pixel equivalence is established by the comparisons above, not those hashes.

All eight downloaded NWB containers match their pinned SHA256 and sizes from
DANDI **000891 / 0.240215.0831**. MATLAB and independent h5py/Pillow implementations
each compared **1,887,436,800 pixels across
7,200 frames**, agreeing on every direct/mapped
difference count and maximum difference. Source TIFF hashes match the previous
audit. [Detailed MATLAB results](pixel-comparison.csv),
[independent results](independent-comparison.json), and
[verification](final-verification.json) retain the evidence. Independent pixel
hashes use the explicitly documented stored-index encoding; because those
hashes precede the spatial mapping, they are not expected to match across axes.

## What processing history is supported

The bounded search covered 511 code files in the publication and connected-drive
analysis trees, excluding the named IOS/voltage-imaging paths. It found no
original TIFF-to-NWB/upload-code pattern. A location/history question was sent
to the researcher; no response is inferred from silence. This establishes a
search limit, not absence of code everywhere. The two relevant source snapshots,
line references, hashes and TIFF header findings are in
[provenance-evidence.json](provenance-evidence.json); full private paths and the
search inventory remain local.

The historical `OxygenDynamics_Master.m` loads non-DENOISED source TIFFs into
`IM_Raw`. Its explicit rescaling/export block targets derived `Images_Processed`
images. That code is not evidence that the selected motion-corrected input TIFFs
were rescaled by those lines. The current archive-to-TIFF adapter is also distinct
from the missing historical upload script. Neither source file establishes the
exact code revision/settings used for these eight legacy runs.

ID402/ID403 TIFF descriptions identify ImageJ 1.53g and 600 frames. ID402 isoflurane
also records `min=1.0` and `max=15.0` display metadata. These are not a record of
pixel conversion or a measured intensity range. The FB2314/FB2315 TIFFs contain
none of the selected description/software/date/resolution provenance tags.
No exposure duration, motion-correction settings, camera-original source or
pre-TIFF intensity transformation was recovered.

## Measurement consequences

| Requirement | Current disposition |
|---|---|
| Source identity and archive conversion | Resolved for these eight selected arrays under the explicit spatial mapping. Preserve canonical FB2315 identity and the original filenames. This does not extend to untested cohort records. |
| Intensity and detection comparability | Archive conversion introduces no numeric differences in these inputs. Earlier intensity processing, 8/16-bit local precision and the 2.35/4.75 µm spatial strata remain relevant; do not tune to equalize event counts or treatment directions. |
| Relative amplitude and integral | Equality preserves the available optical signal. It does not establish camera-raw counts, oxygen calibration, baseline validity or measurement availability. Preserve missing/negative results and physiological claim limits. |
| Tissue-normalized coverage/onset/concurrency | Reviewed observable tissue and dynamic support remain necessary. Do not use legacy detection maps or intensity alone as anatomical truth. |
| Duration and tissue-time | Exact 1 Hz supplies the time grid. Exposure integration, missing frames, motion/support validity and physiological boundary meaning remain separate. |
| Paired biological comparison | Keep four animals/eight sessions and both signs distinct, along with the two acquisition strata. Experimental alignment, wash-in, approved windows and animal-level repeated-measures handling remain unresolved. |

Missing historical details affect the measurements that depend on them; this is
not a blanket exclusion of published data. No outcome hierarchy, eligibility,
evaluation role, window or biological contrast was approved here.

## Feasibility and preservation

The fixed pass downloaded 3,115,250,341 bytes in 253.85 seconds,
within the 4 GB/600-second budget. MATLAB comparisons took
71.9 seconds in total; independent Python
comparisons took 70.5 seconds. One archive
array at a time was loaded by MATLAB; Python streamed frames. These are source-audit
times, not cohort pipeline benchmarks. No new packages were installed.

The Python worker finished first and attempted its final join while the MATLAB
table was incomplete. Its assertion/log are preserved. The final sequential join
checked all eight completed result pairs without rerunning pixel comparisons.
There were no download or completed pixel-comparison failures. All 460 MATLAB
implementation files, 24 legacy outputs and 20 prior local input-audit
artifacts remain unchanged. No detector, event analysis or statistics run occurred.

The original prespecification, downloaded archives, code snapshots, both runners,
logs, source map and search inventory remain in the local workspace under
`reference-validation/boi-c02-provenance-20260912/`. The
[artifact record](artifact-record.json) pins preserved files using portable paths.

**Disposition:** retain current source/import rules with the verified spatial
mapping. Close this source-equivalence audit. Next work is review of observable
tissue/frame validity and experimental windows, retaining the unresolved
pre-TIFF preparation question and the standing biological/physiological limits.
