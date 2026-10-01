# FB2420 provisional tissue-support outline

15 September 2026 · R1-FB2420-OUTLINE-PROPOSAL-072

**This is one concrete proposal for researcher review, not an adopted ROI.**
The outline is drawn from the source/reference context assessed in phase 071.
No event outcomes, intensity threshold, registration fit or desired detection
yield were used to construct it. The exact native vertices and logical mask
are saved separately from the unchanged recording and acquisition declaration.

![Provisional outline on reference and BOI images](proposal-01/reference-source-outline.png)

- **Cyan:** provisional outer boundary. These segments also require review.
- **Amber dashes:** particularly uncertain top, left and lower margins. They
  indicate review attention, not a statistical confidence band.
- **Pink dotted top segment:** closure at native image row 1, between columns
  215 and 280. It is an image-boundary cap, not a visible surgical edge.
- **Pink plus:** the previously inspected transient at row 330, column 432.
  Its location remains inside; it is not an artifact exclusion.

The draft keeps the broad dark left/lower-left interior, with no holes around
dark tissue or vessels. A retained test point at row 350, column 150 documents
that choice without claiming the whole dark region is physiologically observable.
Conversely, the outer excluded pixels are not declared non-cortex. Both decisions
are provisional and must be assessed against the reference, source and uncertainty.

The 22 vertices use `x = native column`, `y = native row`, both one-based.
MATLAB `inpolygon` creates the logical mask and includes points on the boundary.
It is a single connected region with no holes. No anatomical area in mm² is
reported because the physical calibration remains provisional. The saved mask's
fraction of the image field is a geometric descriptor, not an eligible biological
tissue denominator. Top-edge inclusion does not imply that the whole craniotomy
is captured. Any later method-specific image-border exclusion remains separate.

The existing `reviewBOITissueSupport` entry point generated the standard proposal,
mask and source-frame preview (frames 1, 600 and 1200). A separate scientific
overlay shows the same vertices on the reference and fixed early/middle/late
means from phase 071. The reference has its own display scale; all BOI means
share the prior source display scale. No coordinate transform is applied.

The [evidence packet](README.md)
retains vertices, mask, standard proposal, both previews, source/software hashes,
geometry checks and preservation. Current source hashes and the phase-070
acquisition declaration remain unchanged. No `BOITissueSupport.json` was written,
no detector was run, and no original measurement was altered. Existing MATLAB
code and all sealed phase-071 evidence remain preserved.

**Review needed:** whether this outer boundary is a defensible working support,
especially the left/lower margins and the top image-edge cap. Adjustments should
be recorded as a new proposal; this one must remain available. Acceptance would
be a recording-specific working-support judgment, not proof of exact registration,
all-frame observability, a universal boundary rule or independent validation.

The brief localized intensity spikes remain a separate unresolved source issue.
Choosing an outline does not classify or remove them. Before any fresh restricted
run, record the actual support decision and freeze the intended method/review
queue. BOI-only scope, biological variability, physiological relevance,
feasibility, usability, traceability, original correction and unresolved scientific
questions remain standing requirements.
