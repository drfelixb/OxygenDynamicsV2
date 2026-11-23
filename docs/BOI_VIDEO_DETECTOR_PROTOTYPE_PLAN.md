# Video detector prototype with spatial recovery

6 November 2026. Approved implementation scope after the completed video review. The researcher explicitly approves the four-recording prototype and implementation while preserving burden formula, normalization and originals.

## Intended outcome

An experimental service identifies possible pocket episodes throughout a video and explains each proposal using its changing spatial extent, local signal, surrounding tissue and observed recovery. A compact movie comparison shows the complete episode. The researcher reviews patterns rather than repeatedly choosing boundaries second by second.

The initial distinction is between a reversible local component such as the discussed FB2413 episode, a persistent regional change such as the rejected long FB2317 proposal, shared field changes and unresolved cases. These are recognition hypotheses, not validated physiological labels. Size contributes evidence together with temporal behaviour; there is no proposed universal maximum pocket area.

## Build on the existing workflow

The working detector already finds per-frame regions, tracks overlapping pixels and refines correlated traces. The next prototype should extend this structure rather than create another batch or export application. Relevant existing contracts and services include `detectFrameRegionCandidates`, `trackSinkCandidates`, `extractSinkTraces`, `refineSinkRegionsByTraceCorrelation` and `computeTrackedRegionMorphology`.

Keep the production implementations unchanged. Use saved masks/results as the legacy comparator and reuse their native-coordinate and morphology definitions where compatible. An isolated Python prototype can explore the new spatial and episode assessment using the existing cached NumPy/SciPy/Pillow tools and Matplotlib/FFmpeg renderer. Do not port the whole pipeline, install packages or start a replacement GUI. After review, a verified MATLAB port or one Python backend called from MATLAB can be considered separately. The intended user workflow remains CSV → batch run → existing statistics and export.

## Recognition approach

1. **Search the video field.** Generate proposals at several spatial and temporal scales, including locations outside old event footprints. Record the inspected domain and low-signal, boundary or motion-related exclusions. Saved tissue support remains a qualified comparison view; an experimental observability mask must not replace the tissue area used for normalization. Do not require preset ROIs, vascular annotations or new mandatory CSV fields.

2. **Follow evolving regions.** Associate nearby components through time using spatial continuity and signal behaviour. Retain per-frame masks, expansion/contraction, position and uncertainty. Allow irregular boundaries and static vascular gaps. Track split/merge alternatives explicitly; trace correlation alone must not join distant areas into one pocket. Separate recurrent episodes when an intervening recovered state is supported, otherwise retain a linked or unresolved episode interpretation.

3. **Compare local and surrounding changes.** For each proposal, preserve raw evidence and compare nearby, more distant and field-level signals. Inspect neighbouring-region contamination and more than one context distance. Available denoised inputs may help proposal stability after source/axis verification; they are not assumed to be the corrected detection stage or the authority for raw recovery. Do not automatically subtract the field mean or classify every broad change as artifact. A local transient may coexist with a regional change.

4. **Assess the complete episode.** Compare a local decline with recovery against persistent regional change, shared background variation and unresolved explanations. Use preceding context, the descent, spatial evolution and post-event behaviour together. Recovery may follow a changing surrounding state and need not equal one exact raw baseline mean. It must be supported by observed matched-pixel trajectories and spatial contrast, not solely by a falling fitted background. Keep absolute raw return, relative local recovery and correction-dependent apparent return distinguishable.

5. **Keep recognition and measurement separate.** Output a candidate, persistent/shared-change explanation, uncertain case or incomplete boundary, with supporting evidence. Detection context is not an adopted amplitude reference. Each individual episode and ROI can need its own measurement baseline, including recurrent/shared sites. No automatic change from 20 to 10 seconds, inherited-reference age policy or saved review decision is included.

### Prevent recovery caused by changing the mask

The evolving mask is needed to describe extent, but its instantaneous mean can change because different pixels enter or leave it. Assess decline and recovery on matched tissue pixels: a documented fixed comparison footprint and/or explicitly tracked pixel cohorts. Show the evolving-area curve separately. A shrinking mask or discarded dark pixels must not be sufficient to declare recovery. Include this failure mode in the synthetic checks.

### Preserve spatial limitations

The cyan footprints in the existing views identify measurement pixels, not established pocket boundaries. The 4×4-block exploratory maps are not accepted area measurements. Use coarse scales for proposal discovery and native pixels for the boundary comparison, keeping a small prespecified sensitivity range. Unknown or unobservable area remains unknown; absent old detection masks do not establish zero event area.

Do not force circular regions, fill vascular gaps as tissue area or derive a capillary map from BOI brightness. No registered capillary map is present in the selected run folders. Existing source-matched structural annotations, if available, can supply context; acquiring, registering or reconstructing new vascular data is outside this milestone. The prototype does not establish which capillary caused a signal change.

## Finite recording set

| Role | Recording | Frames | Purpose |
| --- | --- | ---: | --- |
| Development | FB2413 | 1–1178 | Local transient and recovery; prior activity; provisional onset 826–827 and likely end 851 remain discussion timing. |
| Development | FB2317 | 1–1200 | Sustained, spreading regional change; avoid interpreting fitted-background closure as observed recovery. |
| Frozen comparison | FB2412 | 1–1200 | Previously recognized site 20/event 1; recording-start rejection; recurrent/extended site 1 example with unresolved area. |
| Frozen comparison | FB2319 | 1–1200 | Previously rejected site 7/event 2; test background confusion outside the two development examples. |

Total: four full recordings, 4,778 frames. Existing raw and denoised TIFF copies are available in the completed run folders; the proposed source ledger records their paths, sizes and expected hashes without reading image pixels during planning. No source copies are needed. Confirm hashes, dimensions, frame alignment and the supplied sampling/calibration metadata before implementation runs.

All four belong to the earlier development partition and have informed prior scientific discussion. The last two are frozen transfer comparisons for this prototype, not historically untouched data or independent biological validation. Existing judgments apply to their named examples, not every event in a recording. The other 13 recordings, including the previous five-recording holdout, are outside this milestone.

The rejected FB2317 long experimental proposal must not silently relabel its later source footprint, site 13/event 9 at 1174–1179, or replace the separate saved site 13/event 5 exclusion. FB2412 site 20 retains its saved 114–182 timing and 104–113 reference. The longer site 1 review and shorter 659–672 preview retain their existing distinct status.

## Bounded delivery

Implementation record: **POCKET-VIDEO-DETECTOR-01**. Owner: root, no delegation. Approved budget: one engineering day, eight active hours, four scheduled processing/verification batches, two repair cycles, 2 GiB working memory and 1 GiB new derived material. Stream or tile source stacks and use the verified off-screen Python renderer. Preserve complete coverage accounting if computational limits are reached; do not silently report a saturated shortlist as a complete search.

| Item | User benefit | Work and acceptance |
| --- | --- | --- |
| VD-01 | Inspect the full field rather than only previously detected ROIs | Verify the finite source set and create a complete domain/frame coverage ledger. Reconcile native coordinates, sampling and quality exclusions with saved metadata. |
| VD-02 | Describe where a possible event grows, persists and resolves | Generate spatial proposals and track their evolving support with explicit split/merge and recurrence uncertainty. Retain rejected/provisional proposals and reasons; no automatic replacement of saved events. |
| VD-03 | Distinguish local recovery from sustained or shared change | Compare complete-episode explanations using matched-pixel raw evidence, context signals and area evolution. Report evidence and uncertainty separately; scores are not calibrated probabilities. |
| VD-04 | Review the result without another frame-by-frame questionnaire | Deliver a local candidate catalogue and at most eight whole-episode movie/figure cards covering favourable, failed, regional, recurrent, incomplete and uncertain examples. Include systematic unlabelled locations/times, not only old detections. |
| VD-05 | Assess correctness and limitations before adoption | Independent replay of selected mask counts, geometry, phase/evidence calculations and source mappings; preservation checks; runtime/memory report and an explicit failure/miss account. |

The four scheduled batches are source/synthetic preparation; development on FB2413/FB2317; frozen application to FB2412/FB2319; and independent verification/rendering. Use one primary configuration and at most one prespecified sensitivity configuration. Declare scale/search ranges, quality/noise treatment, association rules and uncertainty criteria before recording evaluation. Freeze the implementation and settings before the comparison recordings. Do not tune from their results to force the expected labels.

Routine engineering fixes are allowed within the two repair cycles. If a calculation bug invalidates an output, mark it invalid and rerun only the affected bounded work with the correction recorded. Such a repair must not be described as an untouched comparison. A resource or source-contract boundary produces a checkpoint, not a larger campaign.

## Acceptance evidence

Use at most 16 named synthetic scenes covering a local transient, shared rise/fall, spreading persistent decline, a pocket within a regional change, weak/gradual signals, recurrence with changing preceding state, recurrence without recovery, changing-mask bias, overlapping/splitting regions, static vascular gaps, motion-like displacement, noise, missing data, recording-edge censoring and sampling/coordinate conversion. Verify recovery evidence independently of whether a segmentation is biologically accurate.

The known examples must be explained visibly: whether the FB2413 transient is proposed or missed; whether the FB2317 regional decline remains persistent/uncertain instead of acquiring model-created recovery; and how the frozen comparison examples transfer. Report failures rather than repairing the method around each familiar judgment. The prototype may be technically delivered with scientific limitations; it cannot be adopted merely because these examples look convincing.

The catalogue records source hashes, native frame/mask coordinates, candidate identity, old-event overlap mappings, signal stage, proposed timing and timing ranges, spatial extent in pixels, conditional physical extent, qualified support fractions, observed recovery evidence, competing explanations, censoring/quality and split/merge ambiguity. Keep dynamic masks distinct from comparison footprints and preserve missingness. These outputs remain experimental and cannot be selected by the scientific burden exporter.

The compact review uses fixed example roles plus identifier-based systematic samples chosen before the comparison results. Catalogue counts are proposal counts, not biological pocket counts. Sensitivity/specificity and generalization would need separately agreed, independent expert-labelled material; these four familiar recordings cannot establish them.

## Burden and original result contract

The existing hypoxic burden formula, normalization implementation, event-specific measurement references and recording exposure remain unchanged. No new amplitude, accepted area, burden value or scientific export is calculated in this prototype. In particular:

- Do not use prototype masks, display references or candidate scores as measurement inputs.
- Keep complete recording burden unavailable when required retained contributions are missing; no partial sums or imputed zeros.
- Preserve all automatic and reviewed results, exclusions, saved event artifacts and original recordings.
- Keep sink/surge outputs separate; this milestone prototypes sink recognition and does not modify the surge detector.
- Preserve the current MATLAB GUI, batch execution, statistics and export formats.

If the recognition method is later accepted, integration should feed explicitly reviewed/qualified event inputs into the existing measurement and export services. A changed detector can change which events are measured, so that adoption and any fresh output run require separate review even though the burden formula remains identical. No current result is overwritten.

## Stop and next decision

Stop after the experimental service, four-recording comparison, compact whole-episode review, verification and failure/limitation report. No 17-recording campaign, production adoption, GUI/batch integration, original-result rewrite, measurement-method change, Git transport, external publication, package or release is included. Findings remain local.

Deferring implementation retains the completed two-video review and working MATLAB workflow. The researcher has approved implementation within the bounded scope above. After delivery, review recognition and spatial uncertainty before deciding on integration or broader evaluation.
