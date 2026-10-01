# Expanded HP reference and legacy support review

Decision R1-HP-REFERENCE-006, 11 September 2026. **The expanded search and selected
legacy support review are complete. A matching anatomical reference or reviewed
tissue boundary for the selected FB2412 recording was not established.** No
mask was adopted, detector rerun, event value changed or cohort member admitted.

This follows the [cached review](../boi-hp-reference-review-20260910/README.md),
which was completed while the volume was disconnected. The original narrow
inventory and disconnected-drive record remain intact.

## Expanded acquisition-reference inventory

The reconnected source TIFF and metadata CSV match their original SHA-256
records. Recursive searches under each of the 20 recording `New folder`
directories found **23 named reference images across 19 recordings**, including
**seven nested images** missed by the original shallow search. FB2412 is the
only recording folder without a named acquisition reference in this search.

The seven newly located files are white-light references under FB2316, FB2317,
FB2318 (three files), FB2319 and FB2320. All 23 reference files were fingerprinted
and their TIFF headers inspected; their pixels were not interpreted as part of
this selected-recording review. Folder association alone is not validation of
animal identity, tissue coverage or registration.

Several white-light references are 1024 × 1024 with binning 1, while BOI images
are 512 × 512 with binning 2. Equal field of view and a simple resize cannot be
assumed. Most other reference headers describe 512 × 512 with binning 2; equal
dimensions likewise do not prove alignment. One FB2318 reference lacks a
recoverable first-page binning declaration. Original values and unknowns remain
in [the live inventory](live-reference-inventory.json).

The complete selected FB2412 folder was also searched across file types. A
filename inventory covered 1,413 files under the volume's `Analysis` directory.
A further volume-wide filename search for FB2411/FB2412 found 26 matches, all
inside the same HP recording tree. Protected `.Spotlight-V100` and `.Trashes`
directories could not be enumerated and were not bypassed. This was a filename
search, not a claim that no differently named reference exists anywhere on the
volume. A location for any separately stored reference/ROI has been requested.

## Selected legacy landmark images and support maps

Two AQuA2 landmark PNGs in the selected recording's ordinary and inverted
analysis folders were inspected and cached byte-for-byte. They display the BOI
field in normal/inverted contrast, without a visible annotated tissue boundary.
Their accompanying result options name the denoised BOI movie and its inverted
counterpart as inputs. This evidence does not establish a separate anatomical
reference; the precise PNG rendering formula was not reconstructed.

Both legacy result files store image dimensions **502 × 502 × 1 × 1,200**, versus
512 × 512 for the preserved BOI source. Their options record `regMaskGap = 5`,
`registrateCorrect = 1` and preprocessing settings. The size difference is
consistent with a five-pixel margin on each side, but the saved flags alone do
not establish the actual spatial transform. No transform was inferred or applied.

Crucially, both MATLAB `res.bd` support maps contain exactly **`None → []`**.
There is no explicit tissue boundary in either of these maps to reuse. Empty
annotation is not an anatomical mask, zero tissue area or a successful biological
review. Other unexamined legacy curation structures are not declared empty by
this finding.

The portable [legacy-support summary](legacy-support-summary.json) retains source
checksums, native stored dimensions, relevant option values and exact support-map
contents. Original machine-specific paths remain in the local extraction record;
the portable summary omits those paths. No legacy event counts, amplitudes or
outcome tables were analyzed.

## Method, feasibility and evidence

The inspection scope was recorded before opening the PNGs. Initial MATLAB
variable and HDF5 inventories identified `bd` as a serialized `containers.Map`
inside scalar `res`, rather than a native mask array. Its integer storage payload
was not interpreted as coordinates. MATLAB deserialized one result at a time,
retained only the support map and selected options, and cleared the result before
loading the next. This implementation clarification is recorded separately from
the original inspection plan.

The two files are 9.21 GB and 8.35 GB on disk. MATLAB `whos` reported approximately
3.65 GB and 3.49 GB for their respective scalar results; these are stored-variable
size estimates, not measured peak memory. Full-file checksum plus extraction took
55.97 s and 50.28 s. Each recovered support/options MAT file is about 1 KB.
Source file size and modification time were checked before and after extraction.

[artifact-record.json](artifact-record.json) binds the report, source identities,
scripts, logs and extracted evidence. The full local record is under workspace
`reference-validation/boi-hp-reference-search-20260911/`. Earlier HP workflow and
event-review artifacts were checked against their recorded hashes. Production
MATLAB code and scientific settings were not changed in this review.

## Disposition and next work

Keep FB2412's biological occupied-tissue and area-normalized comparisons
restricted by unresolved anatomical/observable support. Preserve the existing
automatic-mask arithmetic as conditional technical results. Do not transfer
another recording's reference through a naming conflict, or turn a contrast
image/empty legacy map into a reviewed anatomical decision.

External **1 Hz** triggering remains the authoritative HP clock. Embedded file
timestamps were not used to infer sampling, resolve identity or establish
reference correspondence. Identity, calibration, biological labels, dynamic
observability and unexplained broad intensity changes remain unresolved.

The matching-reference/ROI location question is pending. Independent next work
is to expose the existing source and tissue-review evidence in the MATLAB import
workflow, so researchers can see the affected measurements and required action
before running. A real mask decision still requires substantive support and
alignment review through the [recorded-mask path](../../BOI_REVIEWED_TISSUE_SUPPORT.md).
