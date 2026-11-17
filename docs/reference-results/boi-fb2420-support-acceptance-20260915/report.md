# Accepted FB2420 working support

15 September 2026 · R1-FB2420-SUPPORT-ACCEPTANCE-073

The researcher explicitly replied **“I accept”** to the phase-072 provisional
FB2420 outer boundary. This accepts the exact proposal as a recording-specific
working static ROI, including the uncertain left/lower margins and top
image-edge closure. No vertices or mask pixels were changed after that reply.

The accepted logical mask contains 161,039 native pixels. The dark interior and
the known transient at row 330, column 432 remain included. Its top closure is
still an image-boundary cap, not an established surgical edge. This acceptance
does not remove the earlier limitations concerning registration precision,
dynamic observability, calibration, preparation, physiological interpretation,
reference precision, transient artifacts or evaluation independence.

The existing MATLAB `writeBOITissueSupport` function records the decision in a
**fresh stage**, linked to the unchanged BOI source. Its acquisition declaration
is copied byte-for-byte from phase 070, retaining confirmed external 1 Hz and
all then-recorded uncertainties. Phase-071 all-frame exposure evidence remains
available separately; earlier metadata is not retrospectively replaced.

The source-bound tissue declaration retains exact native mask indices, source
checksum, actual researcher reply provenance and the proposal/overlay hashes.
The standard MATLAB input review verifies that the declaration loads and that
every mask pixel matches the accepted proposal. It reports reviewed static
support with scientific review still required. All original acquisition,
source-history, calibration and frame-validity issues remain visible.

The [acceptance packet](README.md)
contains the verbatim acceptance, writer decision, staging map, tissue declaration,
MATLAB input review/QC, verification and preservation. The earlier proposal and
its “review pending” status remain intact as dated history; this decision is
the subsequent acceptance overlay. All prior analysis outputs and MATLAB code
remain unchanged.

No detector has run with this ROI. A reviewed mask alone does not select the
restricted normalization/containment method: any fresh restricted run requires
an explicit support profile and a frozen comparison/review plan. Acceptance of
this outline is not adoption of a global detector, baseline policy, exclusion
rule, cohort role or physiological threshold.

Next is to prepare the first source-bound run and event-review plan, retaining
the localized transient issue before biological interpretation. BOI-only scope,
biological variability, physiological relevance, feasibility, usability and
traceability remain standing requirements.
