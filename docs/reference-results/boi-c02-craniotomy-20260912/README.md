# Craniotomy versus image field: FB2314 awake

12 September 2026 · **R1-C02-CRANIOTOMY-030** · BOI both signs.

**The spatial check strongly supports the user's explanation.** The two negative
surges lie almost completely outside the unchanged prior outer-field proposal,
while both interior sink examples are entirely inside. The relevant signal region
must be based on the recording's craniotomy, which can occupy only part of the
camera field. Automatic image support does not establish that anatomical region.

![Seven saved events against the prior outline](overview.png)

The user clarified: “the true Signal is often or in particular the cases I saw
not in the corners/sides. It’s limited to a craniotomy which sometimes is smaller
than the fov”. This establishes the spatial requirement. It does **not** identify
exact boundary vertices in a particular image. We checked the existing
[024 proposal](../boi-c02-outline-proposals-20260912/README.md), drawn before the
028 event results were inspected, without fitting a new boundary to these events.
That proposal covers **50.02% of this 512×512 field**. It remains an approximation
of the visible outer field, with explicitly uncertain segments, rather than an
independently measured surgical aperture.

## Where the reviewed events occur

Percentages below use **full native event masks over their entire lifetimes**:
sum of detected pixel-seconds outside the proposal divided by all detected
pixel-seconds for that event. At fixed 2.35 µm/pixel and external 1 Hz this equals
the native detected area-time fraction. It is not the fixed union area fraction,
not the fraction of all tissue-time, and not a recalculated amplitude.

| Event | Native area-time outside proposal | Interpretation of location | Source frames |
|---|---:|---|---|
| sink 1/1, present at recording start | 0% | Interior; lack of a preceding baseline remains a separate issue | [1, 9, 18](sink-site01-event01/boundary-review.png) |
| sink 1/2, first finite sink | 0% | Interior comparison; location alone does not certify physiology | [448, 449, 450](sink-site01-event02/boundary-review.png) |
| sink 5/4, largest unavailable amplitude case | 99.66% | Dominantly outside, at right margin | [496, 569, 643](sink-site05-event04/boundary-review.png) |
| surge 1/1, finite positive peripheral case | 87.27% | Mostly outside, crossing the right boundary | [108, 113, 118](surge-site01-event01/boundary-review.png) |
| surge 4/1, largest unavailable amplitude case | 77.74% | Evolving event spanning the interior and right exterior | [136, 192, 249](surge-site04-event01/boundary-review.png) |
| surge 16/1, −1.4504% amplitude | 99.90% | Almost entirely outside, upper-left margin | [501, 507, 514](surge-site16-event01/boundary-review.png) |
| surge 16/7, −1.7567% amplitude | 99.92% | Almost entirely outside, upper-left margin | [650, 657, 665](surge-site16-event07/boundary-review.png) |

These locations make outside-craniotomy detection a more relevant explanation
to investigate than treating the peripheral cases as examples of unusual
intracraniotomy physiology. Their optical arithmetic remains correct on their
saved footprints. The images do not establish the exterior signal's mechanism
(for example, whether it reflects background or optical spread), and this check
does not adjudicate every crossing pixel. The fixed outline preserves dark
interior tissue and vessel-like regions. Darkness or proximity to an image edge
alone is not an exclusion rule; in other sessions the craniotomy can reach the
edge of the camera field.

The [selected geometry](selected-geometry.csv) distinguishes union-footprint
and native-time fractions. This matters for surge 4/1: only 49.65% of its fixed
union is outside, but 77.74% of its native pixel-time is outside. Neither number
is interchangeable with the detector's candidate admission statistic.

## Extent of the existing support problem

All **268 saved events** were checked against the same fixed proposal. Under
exact geometric categories, 114 sinks are wholly inside, 42 wholly outside and
63 cross the boundary; for surges, 6 are wholly inside, 2 wholly outside and 41
cross. A tiny intersection is enough for the crossing category; the two negative
surges therefore count as crossing despite being approximately 99.9% outside.
These are descriptive geometry categories, not biological classifications.

Of the **existing automatically supported detected coverage**, 68.70% for sinks
and 68.92% for surges lies outside the proposal. These numbers partition the
old covered numerator spatially; they are not estimates of how much a rerun
would remove and are not revised occupancy results. The saved within-sign
native masks have no overlap excess in this recording, as established in 029.
The complete [event geometry table](event-geometry.csv) and [calculation report](geometry-report.json)
retain all values, including events with unavailable amplitudes.

## Consequence for the MATLAB workflow

Use **recording-specific craniotomy support** as the intended anatomical field.
Keep the complete original source image and its coordinate system. Establish
the outer ROI from source/preparation or aligned reference evidence; retain
uncertain segments and dark tissue inside it. A fixed corner crop, brightness
threshold or the automatic approximately 70% image selection cannot substitute
for the craniotomy boundary. Apply the anatomical principle consistently to both
signs and conditions rather than fitting a boundary to an expected outcome.

The existing [reviewed tissue-support path](../../BOI_REVIEWED_TISSUE_SUPPORT.md)
can record a source-bound ROI and apply it before candidate filtering and
area normalization in a fresh stage. Its current limitations are material:

- The existing outside-support candidate rule remains in effect; a reviewed ROI
  does not force every accepted pixel to be inside it.
- Accepted event footprints and their quantitative traces are **not clipped**.
- Detection normalization still uses the **whole image**.

Therefore installing a craniotomy mask alone cannot be described as a completely
craniotomy-restricted detector and measurement workflow. Boundary-crossing event
handling and normalization support need an explicit method decision, with source
traceability and biological variability preserved. This check changes no such
rule. The next concrete work is to finalize the source-supported ROI and specify
how detection, measurement footprints and denominators should use it, then assess
the fresh workflow within that region. No old numerator is combined with a new
denominator, and the earlier outputs remain available for comparison.

## Evidence and verification

[Prespecification](prespecification.json) records the user's clarification, the
unchanged prior polygon and the six 029 cases plus the already inspected first
finite sink. Seven three-frame panels and the corrected overview were visually
inspected. Green denotes the prior outline, orange its prior uncertain segments,
cyan the exact displayed frame's native mask and white the fixed union footprint.
Source display limits remain [245,22493]; no image resizing, registration or
new intensity threshold changes the underlying coordinates or data.

[Independent Python verification](verification.json) reproduces all 262,144
polygon positions, all 268 event geometry rows and the exact seven-case selection.
It checks the footprint means of the 21 displayed source frames against the
previous audits and verifies the source hash and all 461 existing MATLAB files.
The first export imported a CSV flag as numeric rather than logical; its failed
attempt is retained and the corrected attempt has identical geometry. The first
overview's overlapping title was corrected in a separate render. That render
completed with a harmless figure-cleanup warning after export, retained in its
log; the image was inspected. See [execution notes](execution-notes.json).

The corrected geometry/render harness took 20.17 s inside MATLAB, 25.30 s process
wall time and 1.43 GiB maximum process RSS. Independent replay took 1.79 s.
No detector/statistics rerun, new source copy, adopted mask, frame exclusion or
scientific outcome change occurred. The [artifact record](artifact-record.json)
binds this packet and preservation checks. Executed MATLAB/Python scripts, failed
attempt, original figure and logs remain in local evidence under
`reference-validation/boi-c02-craniotomy-20260912`.
