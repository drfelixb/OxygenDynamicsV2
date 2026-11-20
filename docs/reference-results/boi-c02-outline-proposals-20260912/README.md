# C02 outer-field proposals for source-bound review

12 September 2026 — **R1-C02-OUTLINE-024: eight draft proposals prepared, none adopted.**
These turn the [automatic-support audit](../boi-c02-support-20260912/README.md)
into explicit native-coordinate outlines that can be inspected and revised.
They are approximate visual hypotheses about the recorded outer field, not
validated cortex segmentation or a declaration that all enclosed pixels are
observable at every time. ID402 under isoflurane has especially weak boundary
evidence; all its segments are marked uncertain.

## Review the actual proposals

Every outline is one contiguous polygon without internal holes. Internal low-
signal and vessel-like regions are retained; no darkness threshold, component
filter or desired area fraction defined the drafts. Source sheets show five
fixed frames at the confirmed external 1 Hz. **Green is tentative; orange marks
specifically uncertain segments. Neither color means accepted.**

| Mouse / state | Review files | Native pixels added | Native pixels removed | Surge area change | Sink area change |
|---|---|---:|---:|---:|---:|
| FB2314 / awake | [outline](FB2314-baseline-awake/FiveFrameOutlineReview.png) · [change map](FB2314-baseline-awake/MaskComparison.png) | 17,511 | 67,832 | -27.7% | -20.1% |
| FB2314 / iso | [outline](FB2314-baseline-iso/FiveFrameOutlineReview.png) · [change map](FB2314-baseline-iso/MaskComparison.png) | 9,085 | 58,462 | -27.6% | -20.4% |
| FB2315 / awake | [outline](FB2315-baseline-awake/FiveFrameOutlineReview.png) · [change map](FB2315-baseline-awake/MaskComparison.png) | 45,184 | 19,097 | +14.6% | +19.6% |
| FB2315 / iso | [outline](FB2315-baseline-iso/FiveFrameOutlineReview.png) · [change map](FB2315-baseline-iso/MaskComparison.png) | 52,823 | 17,669 | +19.6% | +26.4% |
| ID402 / awake | [outline](M402-01-baseline-awake/FiveFrameOutlineReview.png) · [change map](M402-01-baseline-awake/MaskComparison.png) | 36,883 | 59,488 | -12.5% | -1.4% |
| ID402 / iso | [outline](M402-03-baseline-iso/FiveFrameOutlineReview.png) · [change map](M402-03-baseline-iso/MaskComparison.png) | 33,568 | 69,008 | -19.5% | -5.1% |
| ID403 / awake | [outline](M403-01-baseline-awake/FiveFrameOutlineReview.png) · [change map](M403-01-baseline-awake/MaskComparison.png) | 45,887 | 20,443 | +14.4% | +20.6% |
| ID403 / iso | [outline](M403-03-baseline-iso/FiveFrameOutlineReview.png) · [change map](M403-03-baseline-iso/MaskComparison.png) | 51,124 | 12,273 | +21.9% | +25.0% |

Changes are relative to each recording's preserved default mask. Gray in the
change maps means retained, green added, red removed, black outside both. These
are geometry comparisons only, not changes in detected events or biological
outcomes. Exact sign-specific pixel counts, areas and nominal area-time are in
the [summary](summary.csv). A smaller or larger area does not validate a draft.
The polygons were saved before rasterization and comparison; none was adjusted
to the resulting area changes.

## Boundary evidence and unresolved interpretation

**FB2314-baseline-awake:** The dim upper margin and lower-left edge are diffuse. Left/lower boundary placement is approximate; optical spillover and tissue boundary are not separated by these images.

**FB2314-baseline-iso:** The lower field reaches the image edge; that segment denotes the acquisition boundary, not an anatomical edge. The dim upper/left margin remains approximate.

**FB2315-baseline-awake:** Top, right and lower edges are clipped or close to the image boundary. The outline bridges internal dark regions and does not remove vessels; the left upper contour is approximate.

**FB2315-baseline-iso:** The field is clipped at top, right and bottom. Image-edge segments bound only the recorded field. Broad internal darkness remains included; left upper outline is uncertain.

**M402-01-baseline-awake:** The left, upper and lower perimeter is diffuse in the grainy images; this is a broad visual field hypothesis with weak boundary evidence, not a certified cortex mask. Review bright rim versus optical spillover on the right.

**M402-03-baseline-iso:** All perimeter segments have weak evidence in the faint source frames. This is a tentative review outline only. No awake mask or transform was transferred; prior viewing of the awake session and automatic map means this drafting was not blinded. Stronger matched-reference or researcher boundary evidence is needed before adoption.

**M403-01-baseline-awake:** Top field is clipped and the upper-left boundary is diffuse. The rightmost rim is close to the image edge. Dark transverse interior bands remain included. Lower outline is approximate where signal fades.

**M403-03-baseline-iso:** Top, right and lower field are clipped; image-edge segments denote acquisition extent. The dark transverse band and internal low-signal areas remain included. Upper-left boundary is diffuse.

All drafts were estimated directly in the individual source's native column/row
coordinates using the preceding fixed source sheets. No mask was copied or
transformed between sessions. Previous viewing of the automatic masks and the
other state is disclosed: this is **not blinded annotation** or independent
validation. No matched anatomical reference was newly established by this task.
The source images provide visible-field structure, not proof that optical glow,
craniotomy edge and tissue boundary coincide. In particular, a faint but visible
field cannot be certified or rejected solely from its intensity.

Image-edge polygon segments bound only what was recorded. They do not imply an
anatomical edge or reconstruct tissue outside the field. The current 20-pixel
sink crop still applies to the draft comparison, with the same 47/95 µm scale
difference already recorded. The full native draft is the surge support. No
new crop, candidate filter or normalization rule is adopted.

## Reproducible proposal files

Each recording folder contains the existing MATLAB workflow's `Proposal.json`,
`ProposedMask.mat` and `TissueSupportPreview.png`. The proposal binds the native
source SHA-256, frame shape and mask-file SHA-256. The readable five-frame sheet
adds uncertainty colors; the original helper preview shows all boundaries green
and uses its own shared first/middle/last display range. Refer to the five-frame
sheet and notes when interpreting uncertainty.

[Outline records](outline-drafts.json) retain every vertex, its rationale, actor,
uncertain segment indices and two internal retention checks. Coordinates are
(column,row), one-based native pixel centers. Segment i joins vertex i to i+1,
with the final segment closing the polygon. Edges at 0.5/512.5 denote image
boundaries. `VerticesColumnRow.csv` and binary PNGs accompany each proposal.
MATLAB `inpolygon` includes polygon-boundary pixel centers; no resizing or
registration is performed. These approximate vertices are auditable choices,
not anatomical measurements with subpixel precision.

Substantive review must resolve the intended outer-field boundary, optical rim
and obscured regions, using preparation/reference evidence where necessary.
Keep any revisions as new proposals with the actual review reason and actor.
The [existing MATLAB adoption workflow](../../BOI_REVIEWED_TISSUE_SUPPORT.md)
can record an accepted support decision only on a fresh analysis stage. This
task did not call the adoption writer or write a source-side support declaration.
Do not retrofit these masks into old results: support can change candidate
admission and bins as well as denominators, so old event numerators cannot simply
be divided by the proposed areas.

Temporal validity remains separate. Five samples cannot certify motion or
observability for all 600/1,200 frames. The nominal full extents, within-mouse
duration matching and [pre-recording established-state clarification](../../BOI_C02_EXPERIMENTAL_CONTEXT.md)
remain unchanged. No induction baseline, exposure duration, frame exclusion or
analysis window is inferred here.

## Verification, usability and preservation

The MATLAB proposal pass completed in **50.168 s**. Independent Python polygon
rasterization matched all **2,097,152 native positions**, verified one connected
hole-free mask per recording, all 16 predeclared interior points, exact added/
removed sets, the sink border and both sign area-time calculations. Eight source
hashes, eight proposal mask-file hashes and 460 MATLAB implementation hashes
passed. Numerical agreement does not establish anatomical validity.

All eight initial five-frame sheets and all eight comparison maps were inspected.
Two existing-helper previews were checked for layout. An overlapping title in
the initial five-frame sheets was repaired in a separate rendering pass, without
changing geometry or measurements; corrected layout was checked on FB2315 awake
and ID402 iso. Initial images, source warnings and logs remain preserved. TIFF
unknown-tag/XMP-type warnings were emitted; no proposal run failed.

[Verification](verification.json), [visual review](visual-review.json),
[prespecification](prespecification.json) and the [artifact record](artifact-record.json)
retain the audit. Full local evidence is in
`workspace/reference-validation/boi-c02-outline-proposals-20260912/`.
The prior automatic-mask evidence and existing worktree changes are preserved.
This closes proposal preparation. Scientific support acceptance, full temporal
validity and the broader reanalysis remain open; no detector or contrast ran.
