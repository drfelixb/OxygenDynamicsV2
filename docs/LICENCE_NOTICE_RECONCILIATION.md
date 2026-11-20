# Licence and dependency notice review

5 October 2026 · Software 3.1.0-dev.2 development candidate

The original Science_2024 software has an existing MIT grant. Its
[exact notice](../licenses/Science_2024-MIT.txt) is included for code covered by
that release. Licensing of new V2 contributions remains unconfirmed; see
[licensing and contributor credits](../LICENSING.md). The separate CC BY 4.0 label
in the saved Zenodo metadata is retained in the
[original-licence source record](planning/original-software-licence.json), without
inferring dual licensing or changing the published metadata.

## Reconciled dependency notices

| Bundled component | Finding and action |
|---|---|
| `abfload.m` | Author-maintained licence at commit `021c9ffb661978cc4d8a875e64dc3d696ebf40bc` confirms BSD-2-Clause and the 2009 Forrest Collman / 2004 Harald Hentschke notices. Retained Ulrich Egert's local `pvpmod.m` attribution and the documented local ABF2 path repair. Local source differs from the pinned upstream file; its original revision remains unknown. |
| `loadtiff.m`, adapted `saveastiff.m` | Official 4.5.0 licence carries copyright 2019 YoonOh Tak. Official source viewers also carry a 2012 notice, matching the local `loadtiff` year. Retained both full notices, including GIST's non-endorsement terms and the adaptation attribution; no replacement date or invented year range. |
| `peakfinder.m` | Official 2.0.2 licence carries copyright 2016 Nathanael C. Yoder. The official source viewer also displays the local 2015 attribution. Retained both. The source/distribution dates are distinct notices, not evidence that one should be deleted. |
| `plot_areaerrorbar.m` | Official 1.3.1 licence confirms BSD-3-Clause and spells the holder Víctor Martínez. Retained that exact licence spelling alongside the original local Victor Martinez-Cagigal attribution. |
| `hex2rgb.m` | Official 1.1.1 licence confirms BSD-3-Clause and copyright 2014 Chad Greene. Retained the local attribution; the consulted upstream source identifies Chad A. Greene. |

The full terms and source links are in the notices. These identified BSD terms
permit source/binary redistribution and modification with their stated notice,
disclaimer and, where applicable, non-endorsement requirements. No additional
permission requirement was identified in those terms for ordinary redistribution.
The review covers these six files; it is not exhaustive rights clearance.

## Remaining permission and provenance limits

The exact starting revisions and complete modification histories of the bundled
helpers are unknown. The consulted upstream licences identify the terms and
attributions retained; they do not establish the history of every local line or
exhaustive rights clearance. If contrary source-specific permission evidence is
found, reconcile it before claiming complete clearance.

No new copyright holder/year or blanket V2 licence is assigned. Confirm licensing
coverage and authority for new V2 contributions before public release. Users need
their own MATLAB and applicable toolbox access. The contributor roles in the
licensing guide are the researcher's account and do not assign ownership.

## Package identity and scientific limits

The package includes the exact original MIT notice, the five full reconciled
upstream licence texts, original-licence source record and dependency
[provenance/hash record](planning/third-party-licence-provenance.json).
`RELEASE_MANIFEST.txt` identifies the committed source and every packaged file;
package creation time is separate from the retained software build timestamp.
Earlier ZIPs and saved results are preserved. This candidate adds licence and
reader documentation plus an approved provenance-label/integrity-pin repair.

The reviewed-optical contract uses portable labels for one saved example and
four distinct historical judgments. Those labels are identifiers, not installed
input files. Their original judgment hashes are retained. Formulas, frame
choices, numerical values and qualifications are unchanged; only the twelve
path strings and matching loader checksum change. Existing saved outputs retain
their earlier definition identity. A definition-load check is separate from a
numerical or scientific validation claim.

Retain C02's conditional reference, FB2312's unresolved recovery, fixed saved
footprints, unknown historical calculator versions and automatic/reviewed
separation. Optical changes do not establish oxygen concentration or physiological
validity. See [support and distribution limits](../DISTRIBUTION_STATUS.md).
Historical development approvals and local evidence remain repository records
(`docs/LICENSING_DOCUMENTATION_HISTORY.md`); they are not package inputs or new
permission to test, record or publish.
