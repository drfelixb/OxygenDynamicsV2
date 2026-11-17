# FB2420 source and reference inspection

15 September 2026 · R1-FB2420-SOURCE-SUPPORT-071

**The source/reference inspection is complete.** The major vessel pattern
visually corresponds in the untransformed native grids, providing useful
landmarks for a working tissue-support review. Exact registration, the surgical
boundary and validity throughout time remain unverified. No ROI or exclusion
has been adopted, and no event detector has been run.

## Source correspondence and visible tissue

The selected 512 × 512 × 1,200 BOI source is
`01_FB2420_GFAP_ECS_GeNL_bin2_2x_KX_1Hz_1_MMStack_Default.ome.tif`.
The same-folder reference candidate is
`490nm after_MMStack_Default.ome.tif`, a single 512 × 512 image. Both match the
checksums recorded in phase 070. The reference is contextual acquisition
evidence, not a BOI biological observation or a legacy detection output.

![Reference and early/middle/late BOI means](reference-results/boi-fb2420-source-support-20260915/run-01/reference-source-comparison.png)

The comparison preserves native row/column coordinates. Visually corresponding
features include the large upper vessel, its descending central branch and
junction near row 200, and the lower curved vessel near row 410. These are
qualitative visual landmarks, not measured registration residuals or an estimated
transform. No flipping, rotation, translation or resampling was applied.

The visible illuminated region occupies only part of the field and is not
rectangular. Its outer margins and the broad darker left/lower-left region need
explicit tissue/support judgment. Darkness within the apparent field does not
by itself establish absent cortex, unusable tissue or an exclusion. The visible
reference and six source snapshots support further outline review, not automatic
segmentation or a generic corner crop. The top boundary is also close to the
image edge; complete anatomical coverage is not established.

The first, middle and last 30-frame means retain a similar large-vessel pattern.
This supports coarse correspondence across those sampled windows; it does not
prove subpixel stability or certify every intervening frame. All-frame intensity
summaries are not a motion or dynamic-observability analysis.

## Recording-specific brightness and acquisition evidence

Prespecified snapshots use frames 1, 240, 480, 720, 960 and 1200. Mean windows
use 1–30, 586–615 and 1171–1200. All BOI image panels share display limits
492.2984–4098.6023, the 1st/99th percentiles of the full temporal mean map.
The reference uses its own limits 544–1060. Display clipping does not alter
source values or establish camera saturation. The exact arrays and limits are
retained in the evidence packet.

The whole-field mean rises from 952.415 input units in frame 1 to its maximum
2042.302 at frame 324, then ends at 1314.042 in frame 1200. This is a broad
recording-level brightness change, not an event trace or a physiological
baseline. Its cause is not assigned. No simple substrate-depletion trajectory,
new correction, detrending fit or trimming of the early recording is justified
by these observations. The original recording-specific correction remains the
method to assess in any later analysis.

All 1,200 inspected BOI frame tags record `Exposure-ms=960.0` and external
triggering. This extends the earlier first-page exposure evidence to the whole
TIFF. It remains a camera setting, not independently measured shutter duration.
The earlier phase-070 declaration is preserved unchanged, including its then
unknown all-frame exposure. A future declaration can cite this new evidence
explicitly; no existing input metadata is retrospectively edited.

The analysis clock remains the researcher's confirmed **external 1 Hz**.
Frame 1 is modeled elapsed time 0, frame 1200 is 1199 seconds, and the full
inclusive sample-count duration is 1200 seconds. Embedded clock fields are
unreliable and were not used to align the reference or infer elapsed acquisition
time from its “after” name. Exposure and frame spacing remain separate.

## High-value transient requiring later artifact assessment

All 314,572,800 stored source pixel samples were scanned. The stored range is
198–61564; none equals zero or the uint16 maximum 65535. This does **not**
exclude sensor saturation below that encoding limit, artifacts or invalid frames.
The maximum-per-frame trace contains brief high-value excursions.

A bounded addendum selected the first frame attaining the global stored maximum
(frame 17), plus adjacent frames 16 and 18, before reading those pixels again.
The maximum lies at native **row 330, column 432**. An 11 × 11 native patch
(rows 325–335, columns 427–437) was retained in each frame:

| Frame | Value at row 330, column 432 | Other 120 patch pixels: median | Other patch pixels: maximum |
|---|---:|---:|---:|
| 16 | 1642 | 1734 | 2585 |
| 17 | 61564 | 1725 | 29901 |
| 18 | 1796 | 1709.5 | 2677 |

The inspected peak is a brief, locally concentrated excursion involving the
central pixel and at least one high-valued neighbor. Its cause and its effect
on event detection remain unresolved. It is not established as a biological
surge or classified as a particular camera artifact. Other maximum-trace spikes
have not been inspected individually. No pixel/frame was removed, interpolated,
capped or labelled false-positive.

## Verification, exposure history and next step

The [evidence packet](reference-results/boi-fb2420-source-support-20260915/README.md)
contains the prespecification, triggered inspection addendum, exact frame/patch
values, three visually inspected figures, acquisition summaries and original
source hashes. The full scan and diagnostics took 3.27 seconds in bundled
Python, excluding MATLAB plotting/startup. MATLAB R2025a rendered the scientific
figures. The initial unavailable Python plotting dependency and a later NumPy
integer serialization failure are preserved with corrected scripts/logs; neither
changed the source or scientific selection.

This phase adds full-source QC summaries and visual source/reference inspection
to FB2420's recorded exposure history. Its descriptive transfer role remains;
it is not relabelled independent or untouched evaluation. All 485 existing MATLAB
files, prior results and phase-070 evidence are preserved.

Next is a provisional craniotomy/support outline for substantive researcher
review using these landmarks, keeping uncertain margins and dark internal areas
explicit. Localized transient spikes must remain an artifact-assessment issue
before interpreting new event outcomes. Any fresh restricted-ROI run still
requires its own source-bound support decision and frozen review queue. No
physiological acceptance threshold is inferred from this technical check.

BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Physical calibration,
label semantics, preparation/substrate timing, exact anatomy, dynamic validity,
reference duration/precision, native sign versus pocket morphology, independence
and cohort eligibility remain unresolved where not explicitly established.
