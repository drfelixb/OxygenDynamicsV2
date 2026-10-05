# OxygenDynamics release decisions

5 October 2026 · For the researcher and project rights holder

The previous **3.1.0-dev.2 portable-guides distribution** is accepted within its
demonstrated scope. The newer licensing candidate has separate package/loader
verification in its delivery record; researcher acceptance is not presumed. Recommend publication wording limited to saved results and
checked calculations. Project licence selection, further tests/recordings and
publication remain separate decisions. The dependency reconciliation below was
completed afterward and is included in the new licensing candidate; the earlier
ZIPs keep their original contents.

## Licence and dependency decisions

**Original software:** the Science_2024 release already contains an MIT licence,
with `Copyright (c) 2023 Antonis Asiminas`. The exact
[MIT notice](../licenses/Science_2024-MIT.txt) is restored for inherited code.
Its permission includes modification and redistribution with retained notices.
The earlier BSD-3-Clause proposal is superseded by this original release evidence.

**New V2 contributions:** recommend MIT for continuity, subject to confirmation
by the authorised rights holder. No new holder/year or blanket V2 grant has been
adopted. [Licensing and contributor credits](../LICENSING.md) distinguish the
existing grant, new contributions and the separate CC BY 4.0 label in Zenodo's
saved metadata. Reusing original code under its MIT grant does not ordinarily
require a fresh permission request; any applicable internal procedure for new
employee contributions remains unconfirmed. [MIT terms](https://opensource.org/license/mit).

The [current notices](../THIRD_PARTY_NOTICES.md) inventory six bundled components:

| Component | Verified upstream terms | Retained notice and remaining provenance limit |
|---|---|---|
| `abfload` | BSD-2-Clause, pinned author-maintained licence | 2009 Collman / 2004 Hentschke notices, Egert attribution and local path patch retained. Bundled starting revision unknown. |
| `loadtiff`, adapted `saveastiff` | BSD-3-Clause-style, official 4.5.0 licence | Upstream source notice 2012 and distribution notice 2019 both retained. Historical revisions/adaptation history unknown. |
| `peakfinder` | BSD-2-Clause, official 2.0.2 licence | Official source attribution 2015 and licence notice 2016 both retained. Exact bundled revision unknown. |
| `plot_areaerrorbar`, `hex2rgb` | BSD-3-Clause, official 1.3.1 / 1.1.1 licences | Exact upstream licence spelling and original local names retained. Exact bundled revisions unknown. |

[Notice review and remaining permission questions](LICENCE_NOTICE_RECONCILIATION.md)
records the identifiable upstream evidence and hashes. No additional redistribution
permission requirement was identified in these BSD terms; this is not exhaustive
rights clearance. Users need their own MATLAB/toolbox access.

## Proposed environment declaration

| Environment | Accurate support scope | Evidence limit |
|---|---|---|
| macOS, Apple silicon, MATLAB R2025a | Named saved-result inspection, review/save/reopen/export | Assistant-operated checks. Prior full portable gate: 132/133, then three targeted passes; no final complete rerun. |
| Linux, MATLAB R2025b | Portable automated calculation/export/compatibility checks | Complete 133/133 pass on `5c23b02`; no Linux desktop/native-chooser or fresh-recording demonstration. |
| Windows, other releases/platforms | No support claim yet | Not demonstrated in this work. |

Imaging routes require Image Processing Toolbox; some analyses need Statistics
and Machine Learning Toolbox. Whole-application compatibility is not established.
Acceptance of assistant checks is distinct from independent scientist walkthrough
feedback, still absent. [Environment evidence](SOFTWARE_NEXT_05_DELIVERY.md).

## Evidence gaps and release choice

Fresh-recording integration, runtime and peak memory are **unverified**; optional/
legacy paths and broader compatibility remain incompletely checked. Disclose these
limits. Claims of fresh-recording support or a complete final macOS gate need
separately approved finite checks. VM/watchdog/custom containment and worker
qualification remain deferred to a possible v4.

Retain C02's conditional reference, FB2312's unresolved recovery, fixed-footprint
qualifications, unknown historical calculator versions and automatic/reviewed
separation. Optical percentages do not measure oxygen concentration/pressure;
arithmetic agreement does not validate correction, reference suitability or physiology.

The previous portable-guides candidate's **446 source/document hashes match commit
[e119df6](https://github.com/drfelixb/OxygenDynamicsV2/commit/e119df6338faa0590f933f889a8dddf81256de30)**;
all 447 files match folder/ZIP/extraction. It contains newer documentation than
hosted-tested `5c23b02`, with unchanged application calculations; `e119df6` had
no new CI execution. [Candidate identity and hashes](SOFTWARE_NEXT_07_DISTRIBUTION.md).

The new licensing candidate has **447 sources at 44f3031** and 448 matching
folder/ZIP/extraction files, with 65 local links and the same-session extracted
definition load passing. The approved twelve-label/one-checksum repair preserves
all formulas, frames, numerical values and qualifications. No numerical suite
was repeated on this source. [New candidate identity](SOFTWARE_LICENSING_DISTRIBUTION_DELIVERY.md).

Confirm licensing for new V2 contributions and applicable notices, support scope,
exact release identity and destination before publication. Acceptance does not
authorize stable `3.1.0`, a tag, release
or DOI. This sheet is a repository decision record, outside the candidate/result files.

## Recommended publication wording

Use the following only after the licence/notices and publication are approved:

> OxygenDynamics 3.1.0-dev.2 is a MATLAB development version for inspecting saved
> BOI analyses, saving reviewed optical measurements and exporting their values
> and ingredients. Named saved-data workflows were demonstrated on macOS with
> MATLAB R2025a. The portable calculation suite passed 133/133 on Linux with
> MATLAB R2025b at commit 5c23b02; a final complete macOS suite was not repeated.
> This distribution corresponds to packaged source at commit 44f3031.
> It adds licensing documents and a portable provenance-label/checksum repair;
> package and extracted-definition checks passed without repeating the numerical suite.
> Fresh-recording integration, runtime and memory remain unverified. Measurements
> retain their reference, footprint and recovery qualifications and do not
> establish oxygen concentration or physiological validity.

Link the approved licence/notices and exact archive hash. No testing, recording,
commit/push or publication is authorized by preparing this sheet.
