# FB2314 strict ROI development comparison

**R1-C02-STRICT-RUN-033 — comparison phase complete, scientific acceptance open.**
12 September 2026. The prespecified single FB2314 awake recording was processed
with `craniotomy-roi-1` and compared with the saved
[031 support-only run](../boi-c02-reviewed-roi-20260912/README.md).
All final native pixels are inside their sign support and all **346/346**
independent source-measurement audits agree. The new method also changes interior
detections and retains three amplitudes opposing their detector labels. Exact
containment therefore does not establish physiological validity.

## Source and method held fixed

The same full 512×512×1200 preserved source, native working ROI, acquisition
declaration, 2.35 µm pixel size and externally triggered **1 Hz** cadence were
used. Embedded recording clocks do not drive analysis; camera exposure remains
unknown. The tissue declaration is byte-identical to 031, including its review
origin and unresolved boundary issues. No holes, vertices, exclusions, baseline
rules, animal roles or unrelated detector settings changed.

The only analysis change is the versioned restricted-support profile:
ROI spatial standardization, included-neighbor smoothing, sign-specific threshold
support before components and included-pixel spatial-bin means. The sink's
20-pixel image-border rule remains separate. Event measurements still use the
original source on each new event's native union footprint, with the existing
20-sample clean local pre-event baseline and both-sign overlap screening.
[Prespecification](prespecification.json), [effective settings](effective-master-settings.json),
[unchanged implementation hashes](code-manifest.csv).

## Results on the same recording

| Quantity | Sinks: 031 → strict | Surges: 031 → strict |
|---|---:|---:|
| Events | 175 → **305** | 21 → **41** |
| Finite amplitudes | 100 → **143** | 11 → **10** |
| Unavailable amplitudes | 75 → **162** | 10 → **31** |
| Negative finite amplitudes | 0 → **1** | 0 → **2** |
| Mean occupied tissue fraction | 0.274% → **0.500%** | 0.893% → **2.244%** |
| Unavailable-only share of covered area-time | 57.14% → **56.03%** | 61.54% → **77.59%** |
| Full native area-time outside working ROI | 5.13% → **0%** | 7.85% → **0%** |

The sign-specific denominators remain **714,650.1575 µm²** for sinks and
**724,193.0375 µm²** for surges, each observed on the modeled 1200-second grid.
These are descriptive static-support results, not validated physiological burden.
No event count or treatment-effect target defines success. Availability does not
uniformly improve: finite amplitudes represent 46.9% of new sinks and 24.4% of new
surges. [Exact table](before-after.csv), [all event measurements and audit](event-amplitude-audit.csv),
[measurement availability](measurement-availability.csv).

The change is not confined to exterior pixels. New versus old same-sign native
pixel-time intersections are 256,900 sink and 745,210 surge pixel-seconds;
520,281 and 2,785,791 pixel-seconds, respectively, appear only in the new union.
Among the four prespecified 031 examples, two have no native pixel-time overlap
with the new same-sign union, while two have 72.66% and 98.00% overlap. IDs are
not treated as biological matches. [Frame comparison and geometry](comparison-report.json),
[old-example intersections](old-example-overlap.csv).

Boundary contact remains common: 150/305 sinks and 36/41 surges touch the
8-connected inner perimeter of their sign-specific support at least once.
Boundary pixels account for 3.78% and 1.42% of their respective additive native
pixel-time. Contact alone is not an exclusion or proof of artifact; sink contact
can include the separately retained image border. No erosion was applied.

## Prespecified visual cases

Green outlines show the working ROI; cyan is the displayed frame's native mask;
gray is the event's fixed union footprint. All plots retain original coordinates
and the same source-display intensity range. These observations are developer
review, not an independent anatomical or researcher acceptance exercise.

- [Sink site 1/event 2](sink-site01-event02/review.png), first finite event:
  interior footprint, 20 clean baseline samples, amplitude **4.624%**. Its local
  dip sits on a broad recording trend; numerical agreement alone does not
  establish the physiological timing window.
- [Sink site 2/event 7](sink-site02-event07/review.png), first boundary contact:
  only **1/20** clean baseline samples; amplitude stays unavailable.
- [Surge site 1/event 3](surge-site01-event03/review.png), first finite event:
  amplitude **−2.064%**, with all measured event samples below the local baseline.
- [Surge site 1/event 1](surge-site01-event01/review.png), first boundary contact:
  starts at recording frame 1, with **0/20** measured pre-event samples. Its
  amplitude remains unavailable. This event-local requirement does not negate
  the user's statement that the experimental state was established beforehand.

![First finite surge: original source, working ROI and local/full trace](surge-site01-event03/review.png)

## All three signed disagreements retained

Every case has 20 clean measured baseline samples and a footprint wholly inside
the working ROI. Independent source replay verifies these ranges over each
measurement window:

| Event | Source change relative to baseline | Stored amplitude |
|---|---:|---:|
| Sink site 10/event 1 | **+0.395% to +10.080%** | **−0.395%** |
| Surge site 1/event 3 | **−9.165% to −2.064%** | **−2.064%** |
| Surge site 1/event 4 | **−7.942% to −0.983%** | **−0.983%** |

The sink touches the uncertain upper boundary; its residual detector trace has a
local dip while raw intensity remains above the measured baseline during the
measurement window. The two surges occupy a dark internal band extending to the
working boundary. Their normalized scores are positive during raw-intensity
dips. Internal darkness was not removed or relabelled as non-tissue.

For surge site 1/event 3, at the raw event maximum (frame 513), the detrended
change relative to baseline is −28.42 input units, but its spatial-score change
is +0.105 and temporal-score change is +0.195. These saved stages show a change
in the measured representation; they do not by themselves identify its full
cause or justify changing the baseline. For the sink, the saved full-record
cubic contribution at its raw minimum is +7.586%, while the residual contribution
is −7.192%, giving the observed +0.395% raw change. All values and signs remain
available for review.

[Signed-case source replay](signed-case-verification.json),
[case definitions](signed-cases.json),
[sink native support](signed-cases/sink-site10-event1/native-support.png),
[sink stages](signed-cases/sink-site10-event1/detection-stages.png),
[surge 3 stages](signed-cases/surge-site1-event3/detection-stages.png),
[surge 4 stages](signed-cases/surge-site1-event4/detection-stages.png).
Each case folder includes the full 1200-frame stage traces and footprint indices.

## Verification, feasibility and preservation

- The full MATLAB master/statistics workflow passed. All 346 source amplitudes,
  baseline statuses and reconstructed detection traces agree with saved results.
- [Independent Python replay](verification.json) checks all 2400 sign/frame
  coverage and availability rows, both first-finite source traces, exact mask
  support and all **262,144** neighbor weights using an integral-sum calculation.
- [Comparison replay](comparison-verification.json) verifies all 346 native
  event geometries, 2400 old/new frame unions, four old-example overlaps,
  prespecified case selection and 4800 source-trace samples. The separate
  signed-case replay verifies another 3600 source samples for all three cases.
- All four prespecified review panels, three signed-disagreement stage panels
  and three native-support overlays were visually inspected.
- One master took **55.00 s**, statistics **40.76 s**; the execution process took
  **123.40 s**, with **13.81 GiB** peak RSS. The full detection-reconstruction
  audit process took **60.79 s**, with **15.32 GiB** peak RSS. Initial output was
  **3.02 GiB**, below the 5 GiB target. These measurements make the audit's memory
  cost explicit. [Resource record](resource-summary.json).

A preflight Python compatibility error stopped preparation before a runner or
recording analysis existed. It was corrected with streamed SHA256 and followed
by one actual detector/statistics execution. Both dispatch logs are retained;
no scientific outcome prompted a retry. [Dispatch record](dispatch-record.json).
All 467 MATLAB source files and the dictionary remained unchanged. The 664
sealed 032 artifacts and 181 immutable 031 artifacts were verified before
appending the standing status records. Original source and legacy outputs remain
unchanged; previous standing-document contents are saved separately.

The local evidence root is
`workspace/reference-validation/boi-c02-strict-roi-20260912`, containing the full
source copy, master/statistics outputs, all-event audit, native replay MATs,
executed scripts, metadata, logs and artifact hashes. The portable packet carries
the measurement dictionary and readable guide alongside the comparison.

## Next bounded work

Keep this as an opt-in development result. Audit how the ROI reference and
per-pixel detrending contribute to the three signed disagreements, then specify
a fixed challenge separating shared/global optical changes from local changes.
Do that before further detector changes or cohort expansion. Anatomical boundary
uncertainty, biological variability, physiological relevance, dynamic tissue
validity, exposure, baseline availability and independent researcher usability
remain standing requirements. No automatic clipping, relabelling, baseline
replacement or final scientific acceptance is adopted here.
