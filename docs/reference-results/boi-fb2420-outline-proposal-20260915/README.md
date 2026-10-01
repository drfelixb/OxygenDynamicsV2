# FB2420 provisional outline

R1-FB2420-OUTLINE-PROPOSAL-072 · 15 September 2026 · proposal creation complete

[Review the overlay](proposal-01/reference-source-outline.png) and
[read the proposal](report.md). Amber marks particularly uncertain margins;
the pink top cap is the image edge, not established surgery. Dark internal
regions and the pink-plus transient location remain inside. No ROI is adopted.

- [Exact proposal](outline-proposal.json): 22 native column/row vertices,
  uncertainty segments, actor, selection rationale, budget and stopping point.
- [Standard helper proposal](proposal-01/Proposal.json),
  [logical mask](proposal-01/ProposedMask.mat),
  [geometry and native indices](proposal-01/OutlineGeometry.mat), and
  [vertices, column then row](proposal-01/vertices-column-row.csv).
- [Standard source-frame preview](proposal-01/TissueSupportPreview.png)
  and [vector overlay](proposal-01/reference-source-outline.pdf).
- [Verification](verification.json), [visual QA](visual-review.json),
  [preservation](preservation.json), [input bindings](inputs.json),
  and [MATLAB log](matlab-01.log).

`createOutlineProposal.m` is the local MATLAB R2025a preparation script; the
portable copy is `.m.txt`. It uses `inpolygon` on the original native pixel
centers and the unchanged `reviewBOITissueSupport` entry point. It checks input
hashes, mask connectedness/holes, two retained locations and absence of a tissue
declaration. The mask contains 161039 of 262144 pixels; its exact MATLAB mask
file SHA256 is in the standard proposal. No calibrated area is inferred.

The script reads phase-071 source display arrays and the three native frames
required by the existing helper. It does not threshold, register, fit, change
correction, read legacy outcomes or run detection. Unknown custom TIFF tag
warnings are retained; the standard helper's source reads and assertions pass.
The camera tag evidence was separately retained in phase-071 and is not replaced.

All 485 existing MATLAB files and all 65 sealed phase-071 artifacts were checked
unchanged (prior ledger versions are in `before/`). Source and phase-070 acquisition
declaration remain unchanged. No `BOITissueSupport.json` is written. The exact
mask is a review artifact, not a production input decision.

Researcher boundary judgment is requested and pending. A change should produce
a new proposal, preserving this one. The same source can support a provisional
working ROI without establishing exact anatomy, registration or dynamic validity.
The localized transient remains a separate unresolved artifact-assessment issue.
Any future run still needs an explicit source-bound decision and frozen queue.

Preserve this directory; the helper rejects an existing proposal output. A replay
or revision must use a fresh output path. `artifact-record.json` seals local,
portable and current repository artifacts; `completion.json` records its hash.
Neither includes itself in the seal. BOI scope and all scientific, feasibility,
usability and traceability requirements remain in force.
