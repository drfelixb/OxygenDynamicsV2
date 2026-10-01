# HP reference availability and cached geometry review

Decision R1-HP-REFERENCE-005, 10 September 2026. **Cached evidence review is
complete; reference-image inspection remains pending.** The external volume
`extZCM361_2` was not mounted during this review. Reconnection was requested.
No reference image was opened, anatomical mask adopted or detector rerun.

## Findings

The preserved inventory records **16 named reference TIFFs in 14 of 20 recording
folders**. Its search covered TIFF/TIFF-extension files whose names contain
`490` or `white`, directly inside each recording's `New folder`. It was not an
exhaustive recursive search, and did not cover every image format or location.

For the selected development recording (`HP_ECS_CSV2_identity_pending`, CSV
FB2412), that inventory lists **no reference image**. This corrects the premise
that a matching HP reference was already known to be available. References for
other recordings exist in the inventory, but their availability does not supply
an anatomical match for this recording.

In particular, `GFAP-ECS-GeNL/FB2413/New folder/490nm_MMStack_Default.ome.tif`
is associated with another folder/CSV row. The FB2413 recording's embedded
FB2412 prefix is an unresolved naming conflict, not evidence permitting its
reference to be assigned to the selected FB2412 recording. The selected source
itself has an embedded FB2411 prefix. Keep all original labels and associations.

The cached selected BOI TIFF matches its recorded SHA-256 and decodes as
512 × 512 × 1,200. All 1,200 saved frame metadata records report:

- ROI `0-0-512-512`, binning 2, width/height 512;
- transpose correction, transpose XY and mirror X/Y settings `0`;
- channel, slice and position indices `0`;
- `PixelSizeUm = 0` and a six-element all-zero affine string.

TIFF orientation and software tags are not recorded. Constant camera settings
do not establish anatomical registration, absence of prior transformations or
motion-free tissue. The zero calibration/affine fields are not usable physical
calibration or registration. The CSV's 2.35 µm/pixel remains provisional.
Native decoded row/column coordinates remain the mask input coordinates.

User-confirmed external **1 Hz** timing remains authoritative. Incorrect embedded
timestamps were not used to infer sampling, align reference acquisitions or
resolve animal identity.

## Retained evidence

[reference-review.json](reference-review.json) retains every inventoried
reference path, original folder/CSV association, observed geometry frequencies,
input checksums and the precise limits of the search.
[artifact-record.json](artifact-record.json) binds the report and executable
cache review to source hashes and checks that both previous HP statistics
outputs remain unchanged. Local evidence is in workspace
`reference-validation/boi-hp-reference-review-20260910/`.

The executable `tests/analysis/reviewHPCachedReferenceEvidence.py` verifies the
cached TIFF and frame metadata checksums and frame correspondence before
writing a new report. It neither creates a tissue mask nor modifies inputs.

## Next action

When the external volume is available, search beyond the earlier narrow
inventory for a matching FB2412 reference, including other image formats and
parent acquisition folders. Check actual content and acquisition association
before assessing geometry or anatomical boundaries. If no reference can be
established, record that limitation and identify what source/experimental
evidence is needed; do not borrow another animal's image or substitute an
outcome-driven intensity threshold.

The [reviewed-mask implementation](../../BOI_REVIEWED_TISSUE_SUPPORT.md) is ready
to preserve a supported decision. Biological tissue support, dynamic validity,
identity, calibration, biological labels and the unexplained broad signal
changes remain unresolved. This is BOI-only work; reference images are supporting
evidence and are not additional BOI cohort observations.
