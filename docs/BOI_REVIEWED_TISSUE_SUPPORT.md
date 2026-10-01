# Reviewed static BOI tissue support

Implementation decision R1-TISSUE-004, 10 September 2026. This adds an explicit
input path for a reviewed mask. It does **not** supply an anatomical mask for HP
or establish scientific eligibility. Both BOI signs remain in scope; IOSI is
excluded.

## Why this is needed

**Craniotomy clarification, 12 September 2026.** The user identifies the relevant
BOI signal region as the craniotomy, which can be smaller than the camera field.
Use recording-specific anatomical support; automatic image activity, a generic
corner crop or internal darkness does not define its boundary. The
[FB2314 check](reference-results/boi-c02-craniotomy-20260912/README.md) finds the
two negative peripheral surges approximately 99.9% outside the unchanged prior
outer-field proposal while both interior sink examples remain inside. Exact
surgical boundary vertices are not established by that user clarification or
by the prior visual proposal. The existing footprint and whole-image
normalization limitations below remain material to a craniotomy-based workflow.

Following the user's visual acceptance, [R1-C02-ROI-RUN-031](reference-results/boi-c02-reviewed-roi-20260912/README.md)
applies that outline as working support in a fresh FB2314 awake development run.
The reviewed-mask path works as implemented, but retains 5.13%/7.85% exterior
native detected area-time for sinks/surges. This is an actual support-only run,
not strict containment. The [next method specification](reference-results/boi-c02-reviewed-roi-20260912/strict-roi-specification.md)
defines separate normalization/candidate-containment work and verification;
the default whole-image behavior described below is unchanged.
The opt-in [restricted ROI workflow](BOI_STRICT_ROI_WORKFLOW.md) is now implemented
and synthetically checked as R1-C02-STRICT-032; it has not yet been compared on
this biological source. Selecting a reviewed mask alone still uses the default
method.

The [HP review](reference-results/boi-hp-event-review-20260910/README.md) found
that automatic support admitted dark peripheral image regions. Its area cannot
be treated as independently validated observable cortex. Changing a percentile
to remove an inconvenient event would not resolve that problem. A support
decision needs anatomical/observable-support evidence, native alignment and an
explanation of its limitations. Unusual event morphology alone is not grounds
for exclusion.

## MATLAB workflow

Preserve an earlier analyzed recording. Stage its unchanged original TIFF,
optional denoised TIFF and acquisition declaration in a new recording folder
for a new support decision. Keep only the intended original and optional
denoised TIFF at that folder's top level.

1. Construct or import a **logical**, two-dimensional mask in the original TIFF's
   decoded row/column coordinates. True means included static support. Matching
   dimensions do not prove registration. Retain supporting images/notes and the
   evidence for alignment.
2. Create a proposal in a new folder and inspect its preview and mask:

   ```matlab
   setupOxygenDynamicsPath;
   reviewBOITissueSupport(recordingFolder, mask, proposalFolder);
   imshow(fullfile(proposalFolder,'TissueSupportPreview.png'));
   ```

   This saves `ProposedMask.mat`, `Proposal.json` and mask boundaries, including
   holes, over first/middle/last source frames on a shared intensity scale. It
   does not adopt support. Three frames aid coordinate review; they do not
   establish anatomy or validity throughout time. Examine the whole recording
   and supporting evidence separately.
3. After substantive review, supply `decision` with exactly these text fields:
   `DecisionID`, `Actor`, `Reason`, `Evidence` and `AlignmentEvidence`. Use actual
   review details, retrievable evidence identifiers and checksums where available;
   explain remaining limitations.

   ```matlab
   writeBOITissueSupport(recordingFolder, proposalFolder, decision);
   reviewBOIRecordingInput(recordingFolder, sampleHz, pixelSizeUm);
   ```

   The writer verifies the proposal mask checksum, source checksum, dimensions
   and logical mask. It creates `BOITissueSupport.json` with exact native pixel
   indices, the review decision and UTC time. Existing decisions and earlier
   master outputs cannot be overwritten through this entry point.
4. Run the normal BOI master and statistics on this fresh stage. Batch and GUI
   master entry points share this input capture. Proposal/review commands are
   MATLAB entry points; a dedicated GUI mask editor and the researcher usability
   release walkthrough remain unfinished.
5. Read `RecordingInputReview.md` and `RecordingInputQC.csv` in the statistics
   output. `RecordingInputContracts.json` and `DataOutput.mat` retain the
   declaration and automatic-to-reviewed changes. Status is **reviewed static
   support declared**, not scientific acceptance.

The functions never resize, threshold, register or infer an anatomical mask.
Empty reviewed support is rejected. Existing automatic zero-area results retain
unavailable normalized measurements, rather than fabricated zeros.

## Effect on calculations

| Component | Effect of reviewed support in a fresh run |
|---|---|
| Automatic estimate | Still calculated; native pixels retained for comparison |
| Selected support | Reviewed mask replaces the automatic estimate |
| Sink support | Existing 20-pixel border exclusion applies with current defaults |
| Surge support | Reviewed native mask without the sink border exclusion |
| Spatial bins | Recomputed using selected support and existing size/coverage rules |
| Candidate acceptance | Existing maximum outside-support fraction applies |
| Event footprints and source amplitude | Accepted event pixels are **not clipped** to tissue |
| Detection normalization | Whole-image normalization is unchanged |
| Sink occupied fraction | Native sink-mask union intersected with selected sink support, divided by selected sink tissue-time |
| Area-normalized summaries | Use selected sign-specific area; calibration remains a separate requirement |

The default outside-support limit is 0.5: a candidate with exactly half its
pixels outside support can remain with its full footprint. This existing rule
is not newly accepted as physiological. Event geometry/amplitude therefore may
include pixels outside tissue. Spatial bins retain their fractional coverage
rule. Whole-image normalization can still produce sign disagreement with source
amplitude. Static support does not establish validity in every frame.

## Traceability and compatibility

The additive schema `boi-static-tissue-support-1` requires `Schema`, `Modality`,
`RawSHA256`, `FrameSize`, `IndexConvention`, `MaskPixels`, `ReviewStatus`,
`DecisionID`, `Actor`, `Reason`, `Evidence`, `AlignmentEvidence` and `RecordedUTC`.
Unknown fields, duplicate/out-of-bounds indices, mismatched source/shape,
non-BOI declarations and unreviewed status fail explicitly. Indices use MATLAB's
one-based column-major row/column convention. The supported status
`reviewed_for_static_support` records the actor's declaration.

The master snapshots exact JSON text and its SHA-256. For reviewed runs,
`AnalysisInfo.TissueSupportAudit` records automatic pixels, added/removed pixels,
the application rule and unchanged normalization/candidate policies. Both sign
outputs must have identical support evidence. Statistics checks selected masks
against the declaration and border rule, and the change ledger against the
automatic mask. These records accompany the frame/window area-time ingredients.

Adding, changing or removing a declaration after a master is rejected, including
for historical masters predating this extension. Statistics cannot apply it
retrospectively. Moving intact sources and declarations remains supported.
Without a declaration, the original automatic calculation is unchanged and old
results remain readable. The core calculation version is unchanged: this adds
an explicit recorded input choice, not a new normalization or candidate rule.

## Evidence and limits

[Verification](reference-results/boi-tissue-support-20260910/README.md) covers
synthetic support transport, source/decision mutation, both sign areas, candidate
overlap semantics, denominator replay and the existing default-mask known-event/
zero-event workflow. Synthetic support makes no biological claim.

HP anatomical support/alignment, dynamic observability, identity, calibration,
biological labels and the cause of broad intensity changes remain unresolved.
The confirmed external **1 Hz** trigger remains the analysis clock; embedded
timestamps remain unreliable provenance. No HP mask is adopted, detector rerun,
event value altered or recording admitted to the cohort by this work.
