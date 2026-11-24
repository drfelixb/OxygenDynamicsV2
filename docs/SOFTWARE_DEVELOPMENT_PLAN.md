# OxygenDynamics: software development plan

**Paired sink depth, 24 November 2026.** The researcher approved PAIR-DEPTH-01 (#16). Root owns alignment of paired sink depths, reference flags, trace changes and summaries with the single-channel export. Acceptance compares one generated movie alone and in a pair, including clean, overlapping, recording-start and negative cases. Stop at a tested pull request for researcher review.

**Coordination checkpoint, 23 November 2026.** An audit of the repository and of the local working copies found that the automated Linux check had failed since October because compact workbook formatting needed Java 9; that is repaired (#11) and the check is green. The check set now also runs 24 test files it previously skipped (#14). The multichannel workflow is integrated into `main` as an opt-in feature (#15), with the depth reference rule recorded as an open decision (#16). All unpublished local work is preserved on `archive/dev-checkout-20261123` and `archive/event-first-20261123`. The researcher shelved the whole-event and whole-episode previews, the Python detector prototypes and the event-first detector; issue #3 is parked as delivered but not adopted. The [11 November project handoff](BOI_PROJECT_HANDOFF_20261111.md) is added as a historical record. No calculation, default or output format changed in this checkpoint. No milestone is active; the next one needs researcher approval.

**Multichannel integration, 23 November 2026.** Root owns PAIR-INTEGRATION-01. Integrate the paired workflow from `84d5832` so it is available alongside the current Batch Editor. Acceptance covers the portable and desktop gates and a separate run of all multichannel tests, including the TIFF rescan, with generated fixtures on macOS. The integration PR records the tested revision, counts and diagnostics. Stop at researcher review or an out-of-scope failure.

**Rescan blank preserved TIFF paths, 19 November 2026.** Root delivered PAIR-RESCAN-01. Checking included rows discovers an unambiguous same-stage pair, preserves assigned channels, validates headers and clears alignment confirmation on new assignments. The original desktop check rediscovered both coupledMC stacks for FB25028 after clearing the two movie cells in memory. Both headers gave 512 × 512 pixels and 1,200 frames. The separate synthetic regression was pending at handoff.

**CSV batches for multichannel recordings, 18 November 2026.** Root delivered PAIR-BATCH-01. The Batch Editor opens an editable queue for two oxygen channels or oxygen plus fluorescence. Serial runs produce per-recording results, a recoverable queue and a combined workbook with recording-level means and medians. Twelve focused checks passed in the original build. Synthetic GUI checks covered both modes, an isolated input failure and an excluded row. The desktop import check opened HP_dual.csv for review. [Batch guide](BOI_MULTICHANNEL.md)

**Live multichannel progress, 18 November 2026.** Root delivered PAIR-PROGRESS-01. The stage line and read-only progress window show the active channel and stage. Eight focused checks and Run-button tests in both modes passed in the original build. Both channel output checksums matched for the original FB25026 session.

**Multichannel RC1 upgrade, 18 November 2026.** Root delivered PAIR-01 for synchronized, prealigned movies and optional oxygen detection TIFFs. The original build provided independent RC1 runs, a paired workbook, an event viewer and a combined saved-recording export. Six focused checks and both end-to-end synthetic modes passed on MATLAB R2025a on macOS. [Multichannel guide](BOI_MULTICHANNEL.md)

**Automatic pocket traces, 20 November 2026.** The maintainer approved an on-demand addition to completed and reopened RC1 automatic exports. The implementation owner is the root development chat. Work item POCKET-TRACES-01 covers checksum-bound original TIFFs, automatic measurement and native timing provenance, source identity preview, confirmed partial exports, and condition-specific equal-mouse summaries. Acceptance covers synthetic source conflicts, missing movies, condition separation, GUI handoff and numerical parity with the previous standalone analysis on a fixed reference export. The fixed reference matched across raw traces, pocket windows, mouse and sensor summaries and bootstrap limits. Five focused checks passed on MATLAB R2025a, including export from the reopened Batch Editor. Stop at a feature PR for researcher review. [Workflow and output guide](POCKET_TRACES.md)

**Checkpoint pushed; broader planning delivered, 30 October 2026:** Felix’s requested stop is recorded: shorter FB2412 659-672 remains preview-only, with no scientific save, and the live longer-interval area draft is preserved. Development **3.1.0-dev.10** source `5408db9` is committed/pushed to the existing development branch and verified by remote fetch. The complete portable gate passes 204/204 on macOS/R2025a, the 492-file source policy validates, 67 changed MATLAB files are inspected with 53 nonblocking style/performance advisories, and protected scientific artifacts match. HTTPS credential attempts failed; existing SSH completed the normal fast-forward push. One headless test start, no repair or cohort rerun/export. GitHub Linux CI was in progress at the transport snapshot; report it independently. The [broader plan](BOI_BROADER_WORKFLOW_PLAN.md) is planning only: propose finishing the existing routine batch-to-export workflow with minimal CSV requirements, then reliability/handoff, with burden-method validation separate. No new pipeline or export format, partial burden, area-rule adoption, scientific review campaign, package or release. Documentation-only follow-up preserves all tested MATLAB source hashes and skips duplicate CI. DEV-CHECKPOINT-20261030 is complete; no active implementation. Next step is researcher review of WORKFLOW-CLOSE-01 before implementation.

**Scientific review stopped; development checkpoint authorized, 30 October 2026:** Felix explicitly keeps FB2412 site 1/event 2 shorter 659-672 as an unsaved preview, stops this inspection and requests committing/pushing current software before a broader plan. DEV-CHECKPOINT-20261030 is the active delivery item: root/no delegation, normal current-branch transport, development version/inventory reconciliation, existing portable checks and source review. Preserve automatic results, saved longer review, the live 43-frame area draft, old exports and all exploratory previews. No shorter-pocket save, area-rule adoption, baseline/detector/correction change, new cohort run/export, package, release tag or next-plan implementation. Budget 90 active minutes/128 MiB, at most three headless starts, two full portable gates and one focused repair run/two repairs. Stop after verified push and proposed broader workflow plan. Scope: `reference-validation/boi-development-checkpoint-20261030/scope.json`.

**Short native-mask candidate checked; save proposal pending, 30 October 2026:** At Felix’s “go on,” read-only follow-up confirms masks in all 14 frames 659-672, counts 100,216,223,275,413,584,686,668,596,547,518,463,290,149. Their exact union equals the accepted 718-pixel event-2 footprint; their mean area reproduces the original 2259.491429 um2. Retaining the previously accepted 631-650 reference would retain minimum frame 664 and 6.942974529% raw amplitude. Conditional full-14-frame contribution is 219626.280112 and normalized contribution 13546.159907 with saved recording exposure, independently replayed with Decimal arithmetic. These are complete single-candidate preview values, not adopted judgments or partial recording sums. Frame 672 remains the detector endpoint, not confirmed full signal recovery. Sources and saved artifacts match; no image read, detector/correction/segmentation run, scientific save or cohort export. Existing longer review and live area draft remain unchanged. Propose one new immutable shorter review/reference/event artifact, preserving all history and qualifying the endpoint; 20 active minutes/20 MiB, existing MATLAB/no source images, eight finite checks/two repairs. Deferral leaves the preview unsaved. Explicit scientific choice is pending; no implementation active. Records: `reference-validation/boi-fb2412-short-interval-preview-20261030/short-candidate-measurement-preview.json` and `short-review-save-proposal.json`.

**Shorter-interval comparison delivered, 30 October 2026:** Felix identifies 659-672 as the shorter candidate. A display-only companion tab shows this 14-second native-mask interval on the accepted 718-pixel event-2 raw/corrected traces, with saved 631-650 reference and unaccepted immediate 639-658 comparison. The earlier longer-pocket tab uses event-3 pixels, as its label states; this new tab avoids mixing its values with event-2 measurements. At 672 raw 806.757660 and corrected -139.317603 remain below saved reference means 833.873329 / -96.852065; the immediate window includes preceding decline. These observations do not automatically reject a mask-defined pocket or establish full recovery. Six independent numeric checks, native visible check, exact live draft/frame preservation and five protected saved-artifact hashes pass. Scope FB2412-S1-SHORT-PREVIEW-01: root/no delegation, 15 minutes/5 MiB ceiling, one existing-session display run, no new image reads, scientific save, area method, burden or export. Existing saved 651-693 timing and 631-650 reference remain unchanged. Preview complete; no active implementation. Evidence: `reference-validation/boi-fb2412-short-interval-preview-20261030/verification.json`.

**Strict completeness delivered, 29 October 2026:** [BURDEN-COMPLETENESS-01](BOI_BURDEN_COMPLETENESS.md) repairs the stats GUI preview’s omit-missing sums/means/maxima and incomplete-mouse presentation; unavailable required values now show explicit counts. Recording/reviewed-export totals were already strict. Workbook basis notes clarify missingness and gapped traces; no numeric formula, normalization, export schema, scientific result or live draft changes. Twenty-five synthetic tests pass, including XLSX/CSV readback; six Code Analyzer reports are empty and 39 protected artifacts match. One headless start, no repair, below 0.1 MiB evidence. Existing saved reviewed CSVs confirm all 17 complete burdens remain unavailable (3,257 available / 2,147 missing retained contributions). No source images, cohort rerun/export or area-rule adoption. Root/no delegation. Delivered and stopped; no active implementation. The extended pocket’s area/burden remains unresolved. Evidence: `reference-validation/boi-burden-completeness-20261029/verification.json`.

**Strict burden completeness check approved, 29 October 2026:** Felix’s “Go on” advances the directly proposed GUI/export completeness preservation. BURDEN-COMPLETENESS-01 audits existing strict recording sums, repairs the stats preview’s omit-missing display aggregates, adds explicit availability counts and workbook guidance, and checks finite synthetic fixtures plus existing saved CSVs read-only. Formula, normalization, baseline/correction/detector, scientific revisions, live draft and prior exports remain unchanged. Root/no delegation; 35 active minutes, 10 MiB evidence, at most two headless MATLAB starts/two repairs. Stop at focused verified delivery; no area-rule adoption or new cohort export. Scope: `reference-validation/boi-burden-completeness-20261029/scope.json`.

**Area-preview visual inspection complete, 29 October 2026:** At Felix’s “go on,” compare denoised frame 664 at all three frozen cutoffs, then play recovered 694-713 at 1 frame/s. Lower cutoff adds an upper neighboring extension; higher cutoff leaves scattered core fragments. Primary 3x still marks small lower/right-edge patches after the central darkening has largely faded in the accepted recovered context. These observations do not establish a biological boundary or absence/continuation; agent recommendation remains not to adopt any cutoff solely from this example. MATLAB is stopped at frame 713 / 3x. No new source read, segmentation run, code/default/calculation change or scientific judgment/save. All 24 protected files match. Record: `reference-validation/boi-fb2412-area-rule-preview-20261029/visual-inspection.json`. Inspection is complete and stopped; researcher method decision remains pending, with reviewed area/burden unavailable and no further tuning or dataset work authorized.

**One-pocket area preview delivered; rule not adopted, 29 October 2026:** FB2412-S1-AREA-RULE-PREVIEW-01 is visibly open in MATLAB at denoised frame 664 / 3x baseline fluctuation, with candidate outlines, fixed-contrast reference/current/loss maps, area curves and all six source/cutoff summaries. Native source/cutoff and leave-one-out/recovered image checks, episode/recovery playback, Stop, reload identity and original live draft/form/cache preservation pass; old frame-marker accumulation is repaired. All 498 exact candidate-mask digests and 5,478 per-frame numeric checks match independent NumPy replay; five native Code Analyzer reports are empty. Four uncertain and 39 unreviewed choices, original review frame 676 and all 24 protected saved/calculation files remain unchanged. The previously documented numerical sensitivity, recovered-context activity and spatial mismatch remain; all six conditional burdens are explicitly unavailable. No scientific judgment/save/adoption, formula/exposure/correction/default change, source image read, recording or combined export. One complete cached preparation with two preparation fixes and two small display-only technical repairs; less than 10 MiB of the 16 MiB allowance, within 60 active minutes excluding unlock wait. Root/no delegation. Evidence: `reference-validation/boi-fb2412-area-rule-preview-20261029/verification.json`. The approved preview is complete and stopped; no active implementation. Researcher inspection is next; no further method or dataset work is approved.

**Area-rule numerical preview verified; MATLAB display pending unlock, 29 October 2026:** The approved one-pocket preview completes all 498 source/cutoff/frame mask cases; independent NumPy pixel digests and 5,478 frame numeric checks match. Denoised mean candidate areas are 6097.739, 1750.119 and 529.133 um2 at 2/3/4 times fluctuation; primary 3x has outside-footprint candidates in 38/43 event frames and candidates in all 20 recovered frames (mean 77.6 pixels versus 2.2 in leave-one-out reference checks). Raw 3x has no event candidate; its much larger per-pixel noise does not reject the recognized pocket. All six conditional contributions remain unavailable. Exact threshold geometry/missingness/normalization cases pass; 24 protected artifacts/calculation files match and no review revision is saved. One complete cached preparation, two preparation fixes plus one bounded additional display-only frame-size-orientation repair, below 10 MiB of the 16 MiB allowance; no source reads or scientific-rule tuning. The corrected preview tab still needs native reopening/checks because CUA reports the Mac locked; manual unlock requested. No method adoption or completion claim. Evidence: `reference-validation/boi-fb2412-area-rule-preview-20261029/findings.json`. The same approved item remains active only for the pending native display/acceptance checks.

**One-pocket area-rule preview approved, 29 October 2026:** Felix replies “yes” to the concrete automatic candidate area preview. FB2412-S1-AREA-RULE-PREVIEW-01 is the one active item: use only existing cached FB2412 site 1 frames 631-713, per-pixel 631-650 mean/sample-SD, frozen loss multipliers 2/3/4, 8-connected footprint-associated candidates, exact pixels and reference/recovery/raw-source diagnostics. Full-interval conditional arithmetic retains formula/exposure and withholds spatial mismatch or invalid data; no scientific adoption, area revision, source read, detector/correction/default change, partial sum or combined export. Preserve the original live draft/form/cache and all saved artifacts. Root/no delegation; 60 active minutes, 16 MiB, one cache preparation/two repairs/eight finite checks. Stop at verified MATLAB preview or clear infeasibility. Scope: `reference-validation/boi-fb2412-area-rule-preview-20261029/scope.json`.

**Automatic area-rule proposal prepared, 29 October 2026:** Felix asks to continue after a reproducible area rule was proposed. Read-only review confirms original mask-based area and the mismatch between 18 detected frames and the accepted 43-frame interval; manual tracing remains uncertain after flicker/playback. Propose FB2412-S1-AREA-RULE-PREVIEW-01 for this one pocket: event-specific per-pixel reference/fluctuation, provisional 3-times-fluctuation loss with fixed 2/4 sensitivity, connected candidate masks linked to the accepted footprint, reference/recovery and raw/denoised consistency checks. Threshold-defined optical area is a new candidate measurement, not a published validated physiological boundary. No constant footprint, imputed detector zeros, partial sums or silent clipping; preserve formula, exposure, amplitude, timing, originals and live draft. Preview proposal: 60 active minutes, 16 MiB, existing cache only/no source reads, one preparation/two repairs, eight finite checks. No numerical preview, production change, area adoption or export has been executed or approved. Scope/details: `reference-validation/boi-fb2412-area-rule-proposal-20261029/proposal.json`. Alternative: retain explicitly unavailable area/burden. Proposal delivered; no active implementation; await approval for the bounded preview.

**Cached baseline comparison/playback delivered, 29 October 2026:** FB2412-S1-AREA-DISPLAY-01 is visibly open in MATLAB at denoised frame 664. Reference 631-650 and current input use matched fixed contrast beside the existing percentage-change map. Raw/denoised selection, one-pass episode playback through 693, bounded reference flicker, Stop, overlays and return to the existing area-review frame pass native checks. Exact image/scales at four named source/frame pairs pass. The original frame 676, all form values, cached images and full unsaved document digest are preserved: four uncertain and 39 unreviewed, zero accepted/empty. All 22 protected saved/calculation files remain unchanged; source diff adds only the comparison entry. Two targeted repair passes addressed timer test timing/shared-state reporting, followed by a short label fit; final static/native Code Analyzer reports no messages for the new comparison. No source image reads, scientific save, new area/burden, formula/normalization/default change or export. Evidence remains below 0.1 MiB, within the 10 MiB ceiling; bounded active work excludes the Mac-lock wait. Owner root/no delegation. Evidence: `reference-validation/boi-fb2412-area-display-20261027/verification.json`. Display milestone delivered and stopped; no active implementation. The next step is researcher judgment using these views; uncertain boundaries remain unresolved rather than inferred.


**Cached area comparison/playback approved, 27 October 2026:** Felix says “go on” to the display-only baseline/current comparison and playback proposal. FB2412-S1-AREA-DISPLAY-01 adds a companion tab using the existing 83 cached frames/source, matched grayscale limits, the existing change map/overlays, raw/denoised selection, bounded playback/flicker and read-only return to an event frame. Preserve the live unsaved review, form state and all saved artifacts; do not reopen/reset the area editor or create a scientific revision. No source image read, segmentation/threshold/correction/detector, area/burden/export or default change. Owner root/no delegation; 30 active minutes, 10 MiB new evidence, one cached preparation plus at most two display repairs. Finite GUI checks cover exact image data/scales, playback stop and draft preservation. Stop with a usable view for researcher review. Scope: `reference-validation/boi-fb2412-area-display-20261027/scope.json`.


**Area-review usability feedback, 27 October 2026:** Felix reports that manual assessment is difficult from the grayscale images. The live FB2412 site 1/event 2 panel is at frame 676 with unsaved uncertain choices and 0/43 accepted; the last saved revision remains 2 with all frames unreviewed. No draft is discarded, no zero is inferred and no judgment is saved by the agent. Improve temporal/reference visualization before further exact tracing: a baseline/current comparison at shared contrast, cached short playback and the existing change-map overlay are possible display-only improvements. This is a recommendation, not an approved new implementation, segmentation rule, threshold, area definition, burden calculation or export. Original data, formula, normalization and strict missingness remain unchanged. No active implementation.


**Single-pocket area panel delivered; researcher review pending, 26 October 2026:** [Reviewed frame areas](BOI_REVIEWED_FRAME_AREA.md) is open in the existing FB2412 site 1/event 2 reviewer. All 43 frames remain unreviewed; 18 saved masks are unaccepted suggestions. Exact pixels, components/holes, explicit empty/uncertain states, responsive drawing cancellation, undo, immutable save/reopen and latest-revision loading are supported. Complete interval mean area and the existing burden/exposure product are available only after all frames are accepted without spatial mismatch. The existing reviewed-event importer validates the new area artifact and withholds missing area instead of using the old automatic contribution; legacy site 20 behavior is preserved. Six focused area cases and 12 existing reviewed-burden cases pass, alongside native incomplete/legacy loaders, parent/source rejection, 83 raw trace means, all 7,002 suggested pixels and 149 protected prior hashes. One preparation reads 83 image planes/source (166 total), with two targeted display/drawing repair passes using the cache; no image reread or scientific frame acceptance. New evidence is below 1 MiB, within the 20 MiB allowance; implementation is within the approved 60-active-minute budget. Source recordings, automatic outputs, prior revisions and workbook remain unchanged. Technical future-export snapshot 08 explicitly holds the new event's area/burden; no 17-recording workbook is built. Owner root/no delegation. Engineering delivery is complete and stopped; researcher review of this one event remains within the approved scope. Evidence: `reference-validation/boi-fb2412-area-review-20261026/verification.json`; no active implementation or subsequent milestone authorization.

**Single-pocket reviewed area implementation approved, 26 October 2026:** Felix explicitly selects “Build single-pocket area review.” FB2412-S1-REVIEWED-AREA-01 is active: existing MATLAB reviewer panel for frames 651-693, source-bound immutable per-frame masks, explicit empty/uncertain/unreviewed states, complete reviewed mean area and existing single-event burden/normalization only after all frames are accepted. Existing masks are suggestions, never accepted on initialization; no interpolation, zero imputation or silent footprint expansion. Extend the existing importer for complete or withheld reviewed area while preserving legacy site 20 behavior and all automatic outputs. Six focused checks plus named GUI acceptance; one preparation of 83 frames/source (166 total), at most two repairs, 60 active minutes / 20 MiB new evidence/output, no delegation. No 17-recording export, detector/correction/threshold work, source copy or default change. Scope: `reference-validation/boi-fb2412-area-review-20261026/scope.json`.

**Full-event area feasibility reviewed; implementation proposal pending, 26 October 2026:** Felix asks to continue toward full-event mean area. Read-only source review confirms the paper-linked stats script and current code average native detected event-frame area; the 718-pixel trace union is not that mean. Existing 18 positive selected masks and 25 empty selected detection frames are saved evidence, not missing files; empty detections do not establish zero biological area. Final binary maps are built from the same tracked masks, not independent earlier detections. The old curation app only includes/excludes pockets and exports Included_Pocs; current BOI pocket review has no per-frame area editor. All 7,002 saved native-pixel rows and 43 coverage rows match; the saved amplitude/decisions remain unchanged. Evidence: `reference-validation/boi-fb2412-area-review-plan-20261026/verification.json`. Proposed FB2412-S1-REVIEWED-AREA-01, not approved: existing-reviewer area panel for exactly 43 frames; initial masks remain unaccepted suggestions; each frame must have accepted geometry or explicit empty judgment, with uncertainty withholding complete mean/burden. Source-bound masks, geometry/spatial checks, no interpolation/zero imputation or silent footprint expansion, then existing single-event burden product and exposure normalization only after complete researcher review. Add reviewed-area validation/missingness to the existing importer, preserve automatic values/formats, no combined workbook. Up to 60 active minutes / 20 MiB, six focused checks plus existing site 20 compatibility, 83 image frames per source (166 total), one preparation/two repairs; no detector/correction/threshold campaign or source copy. Concrete proposal: `reference-validation/boi-fb2412-area-review-plan-20261026/proposal.json`. No active implementation; await explicit approval for new reviewed masks and area definition. Alternative is retaining the saved amplitude/duration with unavailable burden.

**Approved longer-pocket timing, reference and amplitude saved, 26 October 2026:** Felix explicitly selects saving FB2412 site 1 onset 651, recovery 693 and individual 20 s reference 631-650, linked to saved event 2 while preserving event 3 exclusion. FB2412-S1-TIMING-REFERENCE-SAVE-01 appends one immutable boundary revision retaining all six earlier revisions and saves one source-bound reference through the existing validator/loader. Existing reviewed optical calculation and standard selected-event export deliver raw drop 6.942974529%, duration 43 inclusive seconds, baseline 833.873329 and minimum 775.977716 at frame 664 on the accepted 718-pixel footprint. JSON null / CSV-MAT NaN explicitly retain unavailable full-event mean area, burden and normalized contribution; no constant footprint area, zero-filled masks or partial sum. MATLAB visibly shows the saved result and missingness. Exact prior history, accepted pixel identity, 63 reference/event sample rows, 131 prior trace samples, native MAT readback, 25 result-manifest / 20 standard-evidence file hashes, source audit and 116 protected earlier artifact/code hashes pass. One save/export invocation plus one display-only table-height adjustment. Existing exporter cannot yet apply an amplitude-only missing-area hold: the reconciled next-export manifest is explicitly NOT READY and forbids silently keeping old automatic event 2 burden. Evidence: `reference-validation/boi-fb2412-site1-reviewed-20261026/verification.json`; manifest: `pending-reviewed-export-07.json`. Owner root/no delegation; 10-active-minute plan. Standard export required 5.55 MiB versus planned 5 MiB; one bounded 6.5 MiB technical allowance preserves its existing formats, with no repeat export or source expansion. No source movie, detector/correction/statistics run, new area, burden product, recording total, workbook rebuild, global default or original write. Save/amplitude task delivered and stopped; no active implementation. Remaining scientific work is full-event mean area; existing burden formula and exposure normalization remain unchanged.

**Accepted-footprint measurement decision preview delivered, 26 October 2026:** Felix asks to continue timing/reference/area finalization. FB2412-S1-MEASUREMENT-DECISION-01 uses the exact saved event 2 raw trace, whose 718 pixels match the accepted cyan footprint, over 600-730; no source image read. Previously previewed references on this accepted footprint give 6.942974529% (individual 20 s 631-650), 6.111216901% (10 s 641-650) and 6.849980155% (local 20 s pre/post line). Minimum is 664; the older 411-pixel preview is preserved and not mixed into these values. Pre/post raw means are 833.873329 / 831.641574. Both matching native masters and all audit event identities/support pass the existing attachment service; both 20-s windows are native-clean. MATLAB visibly shows candidate interval 651-693 (43 inclusive samples), raw references and sparse existing native area evidence. Existing area code and import path use mean native area, not union area: saved event 2 mean 409.142857 pixels over 14 frames; event 3 318.5 over four. Full 43-frame mean area remains unavailable; no zero filling or constant 718-pixel area is adopted. Independent Decimal arithmetic, four half means, 131 earlier-footprint samples, 40 native-contact frames, three source audit/master hashes, 32 prior spatial artifact and 66 earlier protected hashes pass. One extraction plus one display, no MATLAB code repair; one transient CUA timeout recovered without a rerun. Evidence: `reference-validation/boi-fb2412-spatial-review-20261026/measurement-decision-verification.json`. Owner root/no delegation, 15 active minutes / 5 MiB ceiling. Preview delivered and stopped; no active implementation or new scientific adoption. Explicit exact timing/reference choice requested before the bounded save/amplitude-only proposal in `proposed-timing-baseline-save.json`. Burden formula/normalization, original results and strict completeness remain unchanged; no burden product, partial sum, workbook, detector/correction/statistics run, new segmentation or default change.

**Cyan footprint accepted and saved, 26 October 2026:** Felix replies “ja passt” to the displayed cyan outline covering the recognized FB2412 site 1 longer pocket. FB2412-S1-FOOTPRINT-JUDGMENT-01 records this explicit selection as one immutable existing-workflow note revision, preserving all five earlier revisions, event 1/3 exclusions, recovered background 694-713 and pre-651 background interpretation. The accepted footprint is precisely the existing event 2 fixed union (718 source-bound pixels); this does not adopt constant area over 651-693 or establish time-varying/mean area. Event 2 recognition/mapping stays unreviewed; exact timing and reference-method adoption remain open. MATLAB visibly shows the saved acceptance. Validator/save/reload, exact history chain, 718 unique pixel identities/table hash, audit hash, prior spatial/protected artifacts and nonconflicting next-export sources pass. Evidence: `reference-validation/boi-fb2412-spatial-review-20261026/footprint-judgment-verification.json`; next-export manifest: `pending-reviewed-export-06.json`. Owner root/no delegation, running session, one note-save invocation/no MATLAB repair; one verification-only singleton JSON normalization repair. Ten active minutes / 2 MiB ceiling. No source image read, remeasurement, detector/correction/statistics run, merged event, new burden/export or original write. Judgment recording delivered and stopped; no active implementation.

**Spatial comparison continuation delivered, 26 October 2026:** Felix asks to continue the proposed comparison of FB2412 site 1 frames 665/693 against the larger cyan outline. The same MATLAB figure now visibly shows cached denoised source crops and existing change maps side by side at shared scales, zoomed to rows 312-382 / columns 187-257. No source frame is reread or new image calculation made. Cyan encloses the main localized trough reduction; smaller yellow omits part of its upper-left region. The reduction largely fades by 693, while pale surrounding differences leave the precise outer boundary uncertain. This is an assessment, not adoption of the union as full-pocket area. Two exact copied footprint means and prior spatial artifacts pass; the initial presentation recipe is archived unchanged. Two display-only shape/assertion repairs, one successful rendering. Evidence: `reference-validation/boi-fb2412-spatial-review-20261026/comparison-verification.json` and `trough-recovery-comparison.png`. Owner root/no delegation, 10 active minutes / 5 MiB additional ceiling; no scientific judgment/reference/timing/mask/area adoption, source movie/detector/correction/statistics run, burden/export or original write. Presentation complete and stopped; no active implementation. Await researcher judgment of visible cyan extent before any quantified area proposal.

**One-pocket spatial inspection delivered, 26 October 2026:** FB2412-S1-SPATIAL-REVIEW-01 validates the exact saved event 2/3 native masks with the existing attachment service and source receipt, then displays eight fixed raw/denoised frames against accepted recovery context 694-713 (27 unique frames/source, 54 total). MATLAB visibly shows raw and denoised trough 665 and denoised recovery 693; raw eight-frame gallery inspected. Denoised changes localize a reduction around the saved outlines at 665 that largely fades by 693. The saved unions contain 718/411 pixels, with 408 common; this supports considering fragments at the same location but does not establish a full pocket boundary or merge. Native intervals 659-672 and 674-677 cover only 18/43 provisional frames. Full time-varying area remains unmeasured. Independent validation checks all 7,002 native pixel rows, union membership, coordinates, coverage/crop, 16 source means, four source hashes and 66 protected prior artifact hashes. Evidence: `reference-validation/boi-fb2412-spatial-review-20261026/verification.json` and `inspection.json`. One preparation, one cached callback rebinding after delayed dropdown refresh; both selectors visibly verified. Owner root/no delegation, current MATLAB session, within 20 active minutes / 32 MiB evidence. No source copy, new segmentation/mask/area, exact timing/reference/method adoption, review revision, burden/export, detector/correction/statistics run, production change or original write. Read-only comparison delivered and stopped; no active implementation. Next decision is whether the larger cyan outline captures the pocket at trough, before proposing any quantitative area rule.

**One-pocket spatial inspection approved, 26 October 2026:** Felix requests the proposed full spatial review of the recognized FB2412 site 1 pocket before finalizing its reviewed measurement. FB2412-S1-SPATIAL-REVIEW-01 validates saved event 2/3 native masks and compares raw/denoised images at eight fixed frames with accepted recovery context 694-713 (27 unique frames per source, 54 total). Display-only change maps and source overlays expose coverage without segmentation or a new area. Owner root, no delegation; current session, 20 active minutes / 32 MiB evidence, one display preparation plus at most two repairs. Scope: `reference-validation/boi-fb2412-spatial-review-20261026/scope.json`. Stop at verified spatial comparison and extent assessment. No source copy/modification, detector/correction/statistics run, mask/area/timing/reference adoption, merge, burden/export or default change.

**Recovered-background window accepted by researcher, 26 October 2026:** Felix explicitly judges frames 694-713 to represent recovered background for the recognized FB2412 site 1 pocket. FB2412-S1-RECOVERED-WINDOW-01 saves one new immutable existing-workflow note revision, preserving all four earlier revisions, pre-651 background interpretation, longer-pocket recognition and short event 3 exclusion. MATLAB visibly records the accepted-window judgment on the local-line preview. The acceptance does not select an exact recovery frame, adopt the line measurement method or establish wider pocket area. Review validator/save/reload, exact previous history, source audit hash, 55 prior artifact hashes and conflict-free future export sources pass. Evidence: `reference-validation/boi-fb2412-local-background-line-20261026/recovered-window-verification.json`; manifest: `pending-reviewed-export-05.json`. Owner root, no delegation; current session, 10 active minutes / 2 MiB; no repair, new reference calculation, detector/correction/statistics run, scientific default, burden or export. Judgment recording delivered and stopped. Existing workbook remains unchanged and predates these notes; exact timing and spatial extent remain open before quantification.

**Approved one-pocket local-line preview delivered, 26 October 2026:** FB2412-S1-LINEAR-REFERENCE-PREVIEW-01 constructs the authorized straight reference between fixed means 631-650 and 694-713 at centers 640.5/703.5, with interpolation only. Same cached raw/denoised vectors and 411-pixel saved footprint; provisional interval 651-693. Conditional raw depth is 7.867265% versus 7.830724% for the constant immediate 20-second reference. At 693 the raw signal is +9.901926 above its line; denoised is -0.483652 below, small relative to post-window SD 4.488885. Later 20 samples are native-clean but denoised half means 814.418712 / 817.918478 still rise slightly. The post window is a plausible candidate, not independently validated recovery; using its mean as an anchor cannot itself prove recovery. MATLAB visibly shows signals, local-reference residuals, before/after diagnostics and four-reference comparison. Independent verification checks 284 values (linear reference, signed residual/depth, endpoint, half-mean/SD arithmetic), interpolation limits and 52 prior artifact hashes. Evidence: `reference-validation/boi-fb2412-local-background-line-20261026/verification.json`. About 39.4 KiB evidence, no repair, owner root/no delegation, current session, 15 active minutes / 5 MiB. No method/reference/exact endpoint adoption, additional source image read, global correction fit, event merge, area/burden/export, detector/statistics run or default change. Preview complete and stopped; no active implementation.

**One-pocket local-background line preview approved, 26 October 2026:** Felix explicitly approves the proposed line joining fixed 20-second means from 631-650 and 694-713 for the recognized FB2412 site 1 pocket. FB2412-S1-LINEAR-REFERENCE-PREVIEW-01 uses cached stages on the same footprint, interpolates between mean-window centers only, compares with the existing three constant references and assesses the post-window recovery assumption. Owner root, no delegation; current session, 15 active minutes, 5 MiB evidence, one preview plus at most two targeted repairs. Scope: `reference-validation/boi-fb2412-local-background-line-20261026/scope.json`. Stop at visible and independently verified single-pocket comparison; no method adoption, new global correction/detection, source movie read, exact timing/reference/area/burden/export or default change.

**Pre-pocket background interpretation saved, 26 October 2026:** Felix classifies the decline before frame 651 as background variation. FB2412-S1-BACKGROUND-NOTE-01 appends one immutable existing-workflow note revision, preserving longer-pocket recognition around 651-693, short event 3 rejection and all three earlier revisions. MATLAB visibly states this background/pocket distinction on the existing local-reference preview. Exact timing, baseline duration/model and spatial extent remain unselected. Review validator/save/reload, exact previous history, source audit hash, 43 prior artifact hashes and conflict-free next-export source selection pass. Evidence: `reference-validation/boi-fb2412-local-reference-preview-20261026/background-verification.json`; manifest: `pending-reviewed-export-04.json`. Owner root, no delegation; current session, 10 active minutes / 2 MiB. No new calculation, reference model, fit, burden, export, detector/correction/statistics run or original write. Recording the judgment is complete. Proposed next, not yet approved: one-event local-background reference preview using a straight line between fixed 20-second means 631-650 and 694-713, checking the post-window recovery assumption and comparing with the already shown constant references. This changes the reference assumption and requires separate approval; no adoption or quantified longer event is authorized.

**Local-reference and recovery preview delivered, 26 October 2026:** Felix's “go on” advances the single recognized longer-pocket preview. FB2412-S1-LOCAL-REFERENCE-PREVIEW-01 compares exactly three fixed references on the unchanged saved footprint and cached components: earlier 20 s 621-640 (raw mean 845.067153, conditional raw drop 9.697209%), immediate 20 s 631-650 (827.954015, 7.830724%) and immediate 10 s 641-650 (819.524574, 6.882692%). Existing computeBOIReviewedOpticalInterval supplies raw previews on provisional 651-693; no burden/area product is calculated. All three references are native-clean but already falling. First raw mean reaches after trough are 705/693/689; denoised reaches are absent through 730 / 699 / 693. These are descriptive noisy crossings, not accepted recovery endpoints. Shortening samples a lower background level and does not resolve reference suitability. The remaining scientific question is whether pre-651 decline belongs to the pocket or background variation; no method is adopted to decide it. MATLAB visibly shows full and recovery views; 45 independent means/drop/half-change/crossing/count checks and 40 prior artifact hashes pass. One header-only display repair. Evidence: `reference-validation/boi-fb2412-local-reference-preview-20261026/verification.json`; owner root, no delegation, current session, 15 active minutes / 5 MiB. No source image read, new fit/correction/detector/statistics run, judgment/reference/exact timing/area/burden/export or default change. Named preview delivered and stopped.

**Longer-pocket correction components explained, 26 October 2026:** Felix observes that the recognized FB2412 site 1 pocket is clear in raw context but loses its return in corrected context. FB2412-S1-CORRECTION-COMPONENTS-01 verifies the saved denoised detection input, distinct from the original TIFF used for raw quantification. Read only frames 600-730, one at a time, on the saved event-3 union footprint (411 pixels). Matching denoised-input minus saved-corrected means recover the existing removed component without a fit. Recovery 665-693 is +75.440389 raw, +41.829440 denoised, rising removed component +14.438614, leaving +27.390826 corrected. Denoising reduces contrast; the rising subtracted component further suppresses the return. This is computational attribution; biological validity of the removed component remains unresolved. MATLAB visibly shows four stages and segment changes. All 131 saved raw/corrected samples, 131 component identities, 131 input differences, eight segment checks, original raw/denoised/audit hashes and 30 prior artifact hashes pass. Four relevant loader/detrending/capture helpers match the run manifest; whole current master differs. An optional exact-cubic finite-difference criterion at 1e-8 does not pass (maximum 1.99e-5); the source is 32-bit IEEE float and no exact coefficient/polynomial reconstruction or new fit is claimed. The direct saved-stage attribution is independently verified. Evidence: `reference-validation/boi-fb2412-correction-components-20261026/verification.json`. Owner root, no delegation, current session, 20 active minutes / 10 MiB; one diagnostic/display invocation plus a zero-frame precision-tag check. No correction/detector/statistics run, scientific choice, reference/area/amplitude/burden/export or method/default change. Read-only component review delivered and stopped.

**Longer pocket recognized by researcher, 26 October 2026:** Felix confirms that the displayed broader interval would cover a pocket. FB2412-S1-LONGER-RECOGNITION-01 appends one immutable note revision using the existing review service: positive recognition of a longer site 1 pocket around 651-693, retaining short event 3 as not recognized separately. Exact timing, baseline, spatial extent and mapping to original event 2 remain unselected; event 2 status is unchanged. MATLAB visibly states researcher-recognized longer pocket with approximate green bounds and open measurement choices. The exact two prior revisions, 17 protected earlier artifacts, source audit checksum, validator/save/reload and conflict-free future export source list pass. Evidence: `reference-validation/boi-fb2412-site1-longer-preview-20261026/recognition-verification.json`; source selection: `pending-reviewed-export-03.json`. Owner root, no delegation; current session, 10 active minutes / 5 MiB, no display repair. No new merged event, area/amplitude/burden or export, detector/correction/statistics rerun, method/default change or original overwrite. Existing workbook predates the new notes. Recognition recording delivered and stopped; measurement remains pending.

**Short detection rejected; longer candidate preview delivered, 26 October 2026:** Felix rejects FB2412 site 1/event 3 and tentatively suggests a broader pocket around 651-693. Existing review services save one new immutable snapshot containing the unchanged earlier site 1/event 1 rejection and the new short-event rejection with blank endpoints. Event 2 remains unreviewed. MATLAB visibly shows green candidate 651-693 against raw/corrected contexts 600-730 and details 630-710 on the saved short-event footprint. Raw values at 651/minimum 665/693 are 850.187348 / 763.119221 / 838.559611; corrected values are -102.545928 / -160.981981 / -133.591155, with decline already present before 651. This supports investigation of the broader raw dip but does not establish corrected recovery at 693 or its spatial extent. Seventeen independent numeric checks, exact trace/audit binding, saved revision reload/chain, 10 prior artifact hashes and visible display pass. One table-vector shape repair reuses the saved revision. Scope/evidence: `reference-validation/boi-fb2412-site1-longer-preview-20261026/scope.json` and `verification.json`; owner root, no delegation, current session, 15 active minutes / 5 MiB. No longer recognition/merge, onset/recovery/baseline/area/amplitude/burden adoption, source movie/detector/correction/statistics run or combined export. The existing workbook remains unchanged and predates this rejection; a conflict-free explicit source list for the next requested export is in `pending-reviewed-export.json`. Named review delivered and stopped; longer pocket remains tentative.

**Next saved detection opened for recognition, 26 October 2026:** Felix's “go on” advances the proposed next flagged example, beginning with event recognition. The next unreviewed case in the fixed eight-example order is FB2412 site 1/event 3, saved 674-677. The same MATLAB recording viewer visibly shows corrected/raw contexts 600-730 and details 650-695, preceding detection 2 at 659-672 and the single intervening frame 673. A small target dip sits within a wider depressed trace; no return to the earlier corrected level is evident between these labels. No classification is adopted. Eighteen independent saved sample/minimum/boundary/gap checks, exact audit/trace binding, five protected source/decision/result artifacts and retained loaded site 1/event 1 rejection pass. Scope/evidence: `reference-validation/boi-fb2412-site1-event3-review-20261026/scope.json` and `verification.json`; owner root, no delegation, current session, one named case, 15 active minutes / 5 MiB. No review revision, baseline/recovery choice, amplitude/burden/export, source movie/detector/correction/statistics run or method/default change. Presentation complete; target recognition awaits Felix.

**FB2412 recording-start rejection delivered, 26 October 2026:** REVIEW-BURDEN-03 saves Felix's explicit not-a-sink judgment for site 1/event 1 as one immutable standalone not_recognized snapshot. MATLAB visibly shows the saved status, reason, blank endpoints and history. A fresh burden-only workbook from the same 17 saved recordings carries this third exclusion, both earlier rejections and the exact approved site 20 event result. There are 5,404 retained detections, 3,257 available and 2,147 missing contributions; all 17 complete burdens remain unavailable under strict sums. Original results/formats/formula/normalization and every retained event value remain unchanged; no reference/recovery preview is adopted. Native MAT/CSV/workbook checks, 17 strict totals/frame traces, 626,864 independent retained-cell comparisons, exact approved artifact, original source SHA, 113 prior artifact hashes and 579 protected MATLAB sources pass. One export attempt; one verification-only JSON scalar/list normalization repair. About 105 MiB new output/evidence, below 256 MiB. Evidence: `reference-validation/boi-fb2412-start-rejected-20261026/final-verification.json`. Owner root, no delegation; no detector/correction/movie/statistics rerun, production code/default change, partial sum or Git transport. Delivered and stopped; no active implementation.

**FB2412 recording-start rejection in progress, 26 October 2026:** Felix rejects site 1/event 1 as not a sink event during the active review. REVIEW-BURDEN-03 records one standalone immutable not_recognized judgment and follows the existing reviewed-export workflow for the same saved 17 recordings, retaining prior two rejections and exact approved site 20 event artifact. Existing MATLAB services/formats only; no production code, reference/timing adoption, detector/correction/statistics run, partial sum or original overwrite. Owner root, no delegation; current session, 30 active minutes, one export plus one targeted repair, 256 MiB output/evidence. Scope: `reference-validation/boi-fb2412-start-rejected-20261026/scope.json`. Stop at saved visible rejection and verified separate export.

**FB2412 recording-start recovery detail delivered, 26 October 2026:** Felix's “go on” advances the named recovery review, without adopting a scientific choice. A presentation-only tab in the same MATLAB viewer visibly shows saved raw/corrected samples 45-82, candidate mean/reference 56-75 and proposed end 55. Corrected values at 54/55/56/57 are -35.722671 / -23.577349 / -15.199086 / -25.288179 versus candidate mean -24.642261: 55 first reaches that mean, 56 overshoots, then local fluctuations cross it repeatedly. Propose observed interval 1-55 and separate later reference 56-75, preserving unknown true onset/pre-recording state; a mean crossing is descriptive, not an adopted recovery rule. Twenty-one independent numeric checks, exact source trace binding, original audit checksum, 32 prior artifact hashes and visible MATLAB detail pass. Scope/evidence: `reference-validation/boi-fb2412-start-review-20261025/recovery-detail-scope-20261026.json` and `recovery-detail-verification-20261026.json`; owner root, no delegation, one named case, current session, 15 active minutes / 5 MiB. No judgment/reference acceptance, timing/result change, amplitude/burden/area calculation, export, detector/correction rerun or method/default change. Preview delivered; explicit endpoint/reference choice remains open.

**FB2412 recording-start view verified and assessed, 26 October 2026:** Following manual unlock, the existing MATLAB figure visibly shows the exact site 1/event 1 recording-start tab, full raw/corrected context 1-140, recovery zoom 25-90 and unchanged candidate table. Frames 56-75 are a reasonable candidate for a reviewed post-recovery reference: corrected half means -24.341626 / -24.942896 support a local plateau, while raw half means 885.914183 / 873.159026 show a modest -1.450213% change. The cached 9.034434% comparison still uses saved interval 1-35 and is not a newly accepted amplitude. Missing pre-event state, early overshoot and later separate rise limit recovery/comparability inference; endpoint near 55-56 remains unselected. Prior 18 numeric checks, unchanged source audit and 32 prior artifact hashes pass; manual-lock blocker cleared. Evidence: `reference-validation/boi-fb2412-start-review-20261025/recovery-assessment-20261026.json`. Inspection/recommendation complete, owner root, no delegation. No reference/judgment adoption, timing/burden/export update, partial sum, detector/correction rerun or method/default change.

**FB2412 recording-start walkthrough prepared, 25 October 2026:** At Felix's request the running MATLAB session loaded FB2412 sink site 1/event 1 in its existing recording viewer and selected the presentation-only recording-start tab. Saved interval 1-35, unresolved search limit 55, raw/corrected traces and the four previously calculated later-window comparisons are shown; no pre-event samples exist. Eighteen independent numerical checks, original audit hash and 32 prior artifact hashes pass. No judgment, recovery/reference acceptance, amplitude/burden update, export, detector/correction rerun or method/default change. MATLAB receipt confirms display creation, but visual verification is pending because the Mac is locked; manual unlock requested. Scope/evidence: `reference-validation/boi-fb2412-start-review-20261025/`. Owner root, no delegation, one named example, current session, 15 active minutes / 5 MiB evidence. Resume only visual verification of the existing tab, then deliver the walkthrough; reference suitability remains undecided.

**Current reviewed decisions exported, 25 October 2026:** [REVIEW-BURDEN-02](BOI_REVIEWED_DECISIONS_20261025.md) saves Felix's explicit FB2319 sink site 7/event 2 rejection in the existing immutable workflow and excludes it with the previous FB2317 rejection. The fresh reviewed burden workbook also imports the exact already-approved FB2412 event revision (114-182, reference 104-113, 69 s; normalized contribution 187950.456671 using unchanged saved area). Same 17 recordings: 5,405 retained detections, two rejected, one approved value import, 3,257 available and 2,148 missing contributions; all 17 complete recording burdens remain unavailable. Automatic source columns/results and earlier artifacts are preserved; active reviewed timing is explicit in BurdenStartFrame/BurdenEndFrame/BurdenDuration_sec. Twelve focused synthetic cases, named artifact/tamper validation, MAT/workbook/CSV readback, 17 strict totals and frame traces, 583,274 independent unchanged-cell comparisons, 17 rank replays, original source MAT/workbook checksums, 32 prior artifacts and 574 protected MATLAB source hashes pass. About 111 MiB new evidence/output. One attempt stopped before export on two-ULP area serialization differences; the next completed, followed by a verification-only CSV precision repair (exact missingness, observed max 39 ULPs). No new scientific choices, formula/normalization/default change, partial sum, movie/detector/correction run, area remeasurement or Git transport. MATLAB visually shows the saved FB2319 Not recognized revision. Delivered and stopped; no active implementation.

**FB2319 rejection and current reviewed export approved, 25 October 2026:** Felix explicitly rejects FB2319 sink site 7/event 2 and requests saving/excluding it from reviewed burden while preserving the automatic result. REVIEW-BURDEN-02 saves one new immutable rejection and carries forward the prior FB2317 rejection and exact approved FB2412 event result. Extend only the existing opt-in reviewed exporter with source-bound import of the approved event artifact; preserve automatic evidence columns and add explicit active burden interval/source fields. Reuse existing formulas on all retained events with full exposure and strict missingness. Same 17 saved recordings; 12 focused synthetic checks plus named artifact verification, 60 active minutes, 256 MiB new evidence/output, at most two export attempts/two repairs, current MATLAB session, owner root, no delegation. No new reference/timing/area choice, detector/correction/movie run, partial sum, original overwrite or global-default change. Scope: `reference-validation/boi-reviewed-decisions-20261025/scope.json`. Stop at verified current reviewed export.

**FB2319 trace/reference walkthrough delivered, 25 October 2026:** At Felix's request the existing viewer opens FB2319 sink site 7/event 2 (saved frames 45-51), with full raw/corrected context and a corrected local zoom. This is the same named event in the previously authorized eight-example set. Both signals broadly rise through the series. Immediate references have 5/20 and 1/10 clean samples because of the preceding native run; saved episode reference 5-24 gives -13.294471% raw drop. Earlier nearest clean 20/10 s means 1072.019241 / 1095.420812 remain below the event minimum 1195.291885, yielding -11.499107% / -9.117142%; corrected companion checks are also wrong-direction. The later 93-112 mean gives +14.597747% only as an unaccepted higher-state comparison. No classification or alternative baseline is adopted. Correct MATLAB display, 12 independent numeric checks, unchanged original audit and 25 prior FB2412 reviewed artifact checksums pass. Evidence/scope: `reference-validation/boi-fb2319-baseline-review-20261025/verification.json` and `scope.json`; owner root, no delegation, running MATLAB session, 15 active minutes / 5 MiB evidence. No amplitude/burden update, new recording total, partial sum, export, source movie/detector/correction/statistics run, production code/default change or next method adoption. Named walkthrough complete; researcher recognition remains open.

**Reviewed FB2412 event recalculation delivered, 25 October 2026:** FB2412-REVIEWED-EVENT-01 saves the researcher-approved onset 114, recovery 182 and reference 104-113 in new immutable boundary/reference revision 02. Existing raw reviewed optical arithmetic gives baseline 575.076065, minimum 532.194743 at frame 161, positive drop 7.456634830% and inclusive duration 69 s. Unchanged saved native mean area 5922.697166667 um^2 yields single-event contribution 3047273.908463444 percent*um^2*s; unchanged full-recording exposure (810658.82 um^2, 1200 s) gives normalized event contribution 187950.456670751 percent*um^2*s per mm^2 per minute. Earlier/later spatial extent is explicitly not remeasured. The separate MAT/CSV/JSON single-event artifact and existing selected-event evidence export reload correctly; 14 independent numeric checks, 25 artifact checksums, 10 exported reference / 69 event samples, original audit/earlier revision preservation and 574 preexisting MATLAB code hashes pass. MATLAB visibly shows the saved reviewed result. Artifact bytes: 5867694 (below 16 MiB). No recording/cohort total, partial sum, combined-workbook rebuild, detector/correction/movie run, global scientific-default change or production code edit. Evidence: `reference-validation/boi-fb2412-site20-reviewed-20261025/single-event-final-verification.json`. Delivered and stopped; no active implementation.

**Recovery 182 and single-event recalculation approved, 25 October 2026:** Felix selects frame 182 after the recovery comparison. FB2412-REVIEWED-EVENT-01 completes only FB2412 sink site 20/event 1 using onset 114, reference 104-113 and inclusive duration 69 s. Save a new boundary/reference revision, reuse the existing raw reviewed optical calculation, saved native mean event area and existing burden/exposure formulas, and write a separate single-event result plus existing event-evidence export. The unchanged area is explicitly qualified: earlier/later spatial extent has not been remeasured. Independent event arithmetic, source/revision preservation, reload/checksums and visible MATLAB result are acceptance checks. Owner root; no delegation; running session, 15 active minutes, 16 MiB artifacts, at most two targeted repairs. No recording/cohort total, partial sum, combined-workbook rebuild, movie/detector/correction run or default change. Scope: `reference-validation/boi-fb2412-site20-reviewed-20261025/recalculation-scope.json`. Stop at the verified single-event contribution.

**Selected onset/reference saved; recovery checked, 25 October 2026:** Felix explicitly selects onset 114 and baseline 104-113 for FB2412 sink site 20/event 1 and requests recovery inspection before burden recalculation, preserving formula, normalization and originals. Existing immutable boundary and source-bound reference services save/reload those choices, with recovery blank. The selected raw/corrected means are 575.076065 / 27.617396. Saved end 172 remains below both. Corrected intensity crosses at 180, falls below at 181, and stays above through 182-205; raw is within the observed reference range at 182 and above its mean at 183-201. MATLAB shows full corrected context and corrected/raw recovery zooms; 182 (69 inclusive seconds) is recommended using corrected-primary timing, with 183 (70 seconds) an explicit alternative. Twelve independent reference/recovery values and the original audit checksum pass. Exact recovery choice requested from Felix; no recovery revision, amplitude, event burden, combined export, area remeasurement or default/algorithm change is made. Evidence: `reference-validation/boi-fb2412-site20-reviewed-20261025/recovery-check.json`; bounded scope in `scope.json`, owner root, no delegation, current MATLAB session, 15 active minutes / 5 MiB evidence. Original and previous reviewed exports remain intact; the existing burden formula and exposure normalization are preserved for the pending recalculation.

**Earlier-onset preview delivered, 25 October 2026:** Felix recognizes FB2412 sink site 20/event 1 as a real pocket starting earlier and requests checking onset around frame 120 and showing a reference before the decline. The existing saved viewer now displays the original raw/corrected traces on the same footprint over frames 70-200, candidate onset 120 and visible early fall around 114-120, preserving saved bounds 142-172. Three explicit windows (94-113, 104-113, 100-119) are compared without a search or optimization. The 104-113 short plateau has raw mean 575.076065; the longer 94-113 mean 570.172242 includes a preceding rise; 100-119 mean 571.099024 includes the initial fall. Six independent window-mean checks and the unchanged source audit hash pass; correct MATLAB display visually verified. Evidence/scope: `reference-validation/boi-baseline-review-20261025/earlier-onset-preview.json` and `earlier-onset-scope.json`. This is one bounded saved-event preview in the running MATLAB session (15-minute / 5-MiB limit), owner root, no delegation. No formal onset/reference revision, new amplitude or burden, export, detector/correction/statistics rerun, reference-age/gap/default change or method adoption. Preview complete; await exact event/reference judgment before modifying scientific results.

**Saved pocket rejection and reviewed export delivered, 16 October 2026:** [REVIEW-BURDEN-01](BOI_REVIEWED_BURDEN_EXCLUSION.md) saves Felix's explicit FB2317 sink site 13/event 5 rejection in the existing immutable review workflow. MATLAB visibly shows Not recognized and the saved reason/history. A separate opt-in burden export reuses existing calculations/formats and excludes exactly one detection: 5,406 retained rows, 3,256 available and 2,150 missing contributions; all 17 complete burdens remain unavailable under strict missingness. Eight focused cases, 17-recording products/totals/normalization, workbook readback, 583,848 independent retained-cell comparisons, unchanged original workbook checksum and 574 protected MATLAB code hashes pass. Source MAT checksum checked before/after preparation. Approximately 105 MiB new evidence/output; no original write, partial sum, detector/correction/statistics rerun, baseline adoption, MATLAB restart or Git transport. Ordinary automatic batch exports retain automatic detections; saved decisions are supplied explicitly to the reviewed exporter. Delivered and stopped; no active implementation.

**Saved pocket rejection and reviewed export approved, 16 October 2026:** Felix explicitly requests marking FB2317 sink site 13/event 5 as not a pocket, preserving the automatic result and excluding it from reviewed burden. [REVIEW-BURDEN-01](BOI_REVIEWED_BURDEN_EXCLUSION.md) is the active bounded item: existing immutable review save/reload, opt-in identity-bound reviewed burden adapter and fresh burden-only export for the same 17 saved recordings using existing calculations/formats. Eight focused synthetic cases plus the named example, running MATLAB session, two repair passes, 30 active minutes, 256 MiB new output/evidence. Other missing contributions retain strict missingness. No detector/correction/statistics rerun, new baseline rule, partial sum or original-file overwrite. Owner root, no delegation; stop at verified export.

**Event-specific reference preview delivered, 16 October 2026:** the
[eight-example preview](BOI_EVENT_REFERENCE_DURATION_PREVIEW.md) compares 80
candidate windows at 20 and 10 seconds, preserving individual footprints,
intervals, formula and exposure. Earlier code confirms each event's own temporal
reference even within a shared ROI; the current episode addition can share an
earlier period. Nearest clean pre-event candidates yield four positive values
at 20 s and five at 10 s, but the additional FB2317 value (1.029012% raw) disagrees
with corrected local direction and remains unresolved. FB2413 has a clean local
20 s reference despite its contaminated inherited window. Shortening changes
other conditional event products by −2.39%, +5.84%, −7.50% and −40.64%; no products
were summed or adopted. One 24.94-second MATLAB invocation, 13 synthetic cases,
554 independent numeric comparisons, three exact signed current-result replays
and 595 unchanged protected hashes pass. Both figures inspected. No production
code/default, original result, movie/detector/correction/statistics/export run,
recording total or partial sum. Preview complete; no active implementation.
Recommended scientific decision: event-specific local references, retain 20 s
as current default and consider a flagged 10 s option only with supported local
state. Method adoption and an all-17 export remain unapproved.

**Event-specific reference preview approved, 16 October 2026:** Felix approves
previewing the reference rules on the same eight saved examples before method
adoption, and adds a 20-versus-10-second comparison and the earlier requirement
for a separate baseline for each individual event, including shared ROIs.
AMP-RECOVERY-PREVIEW-01 is the single active preview: same fixed event footprints,
intervals, formula, normalization and original results; compare immediate,
nearest clean within the total 20-second displacement, approved episode-window
and post-episode sensitivity candidates. Keep reference age and episode gap at
20 seconds independently of averaging duration. Four active hours, at most four
five-minute MATLAB starts, 100 MiB evidence, finite synthetic checks. No movie,
detector, correction, 17-recording statistics/export, partial sums or production
adoption. Owner root, no delegation. Deliver the numerical/visual preview and
concrete recommendation, then stop.

**Remaining-reference review delivered, 16 October 2026:** the same 5,407 saved
sink events in 17 recordings are examined without new calculations/export.
[Findings and proposal](BOI_COMPLETE_BURDEN_REFERENCE_PROPOSAL.md): 912 of 973
incomplete references overlap native masks; 61 have acquisition truncation
without overlap. Three overlap cases also truncate. Of 1,007 over-age references,
782 are sample-complete but not thereby physiologically validated. The 72 start
flags represent 48 native-frame-1 series. Direction disagreement remains separate
(99 events). Eight fixed examples expose old-level drift and overly broad
reference grouping; 60 protected hashes remain unchanged. Three native starts
include two retained diagnostic-collector failures and a successful 29.36-second
extraction. Technical allowance was expanded to three starts; no scientific scope
expansion, movie/detector/correction/statistics/export run, new amplitudes or
recording totals, partial sums, or production method adoption. Propose a bounded
recovery-aware reference preview using existing services before another all-17
export. This review is complete; no implementation is active or approved.

**Remaining-reference review authorized, 16 October 2026:** Felix requests a
read-only examination and proposal for complete burden in the same 17 recordings.
AMP-COMPLETE-REVIEW-01 keeps the formula, exposure normalization and strict sums.
Use the saved export, audits and masters plus eight fixed illustrative events;
one five-minute native extraction and one targeted repair initially, 100 MiB
evidence; the delivered record above documents the bounded technical expansion. No source-movie, detector, correction, statistics/export run or method
adoption. Deliver the concrete reference proposal and stop; no implementation
is active. Owner root, no delegation.

**Fresh pre-episode export delivered, 16 October 2026:** the same 17 saved
recordings export into a new complete workbook/MAT bundle. [Delivery and counts](BOI_PRE_EPISODE_COMBINED_EXPORT.md):
3,256/5,407 event contributions are available (490 newly available, one newly
withheld; previously 2,767). All 17 complete recording burdens remain unavailable
under strict missingness. Remaining reasons: 1,007 old references, 973 incomplete
clean references, 72 unresolved acquisition-start references and 99 wrong-direction
signals. Original measurements, formulas, normalization, 700 protected hashes,
40 original movie size/timestamps and three source holds are preserved. All event
products/exposure scaling, strict totals, saved audits and workbook readback pass;
109 sheets retain the existing formats plus approved policy metadata. No detector
or correction rerun, method adjustment, partial-burden endpoint or Git transport.
The named export/availability task is complete; no active implementation remains.

**Fresh combined export approval record, 16 October 2026:** Felix explicitly requests
one fresh export of the same 17 completed recordings using the approved
pre-episode policy, with burden availability checked. BATCH-EPISODE-EXPORT-01
was the approved active item; owner root, no delegation. Preserve the three source
holds, source recordings, previous outputs, formulas and normalization. Use the
existing batch stats service, a new output folder, at most two 60-minute attempts
including a necessary repair, 32 GiB combined output ceiling and 100 MiB review
evidence. Verify original-column preservation, selected reference policy,
event products/exposure scaling, strict recording totals and workbook readback.
Report available and missing contributions by recording without promoting
partial sums. No detector/correction rerun, new dataset campaign, package or
Git transport. Stop at verified export and availability delivery.

**Pre-episode baseline delivered, 16 October 2026:** local **3.1.0-dev.9**
implements the approved recurrent-pocket reference through existing batch stats
and future BOI master outputs. Original automatic columns and historical files
remain. References shifted more than 20 seconds and unclear acquisition-start
series are withheld explicitly; strict burden/normalization remain. The named
FB2412 fixture reproduces 6.012181% and normalized event contribution 2608.970113,
with the isolated control unchanged. 129 distinct focused cases pass across
final reports (102 compatibility cases and 15 final reference/loader cases,
with overlap); nine historical hashes are unchanged. Six bounded headless starts,
including retained fixture/inventory failures, total 236.99 seconds.
No supplied movie/detector processing, all-17 export, complete recording total,
package or Git transport. [Delivery](BOI_PRE_EPISODE_IMPLEMENTATION.md).
The approved milestone is complete; implementation stops here. A fresh combined
export from saved runs is the practical next step, not a recording rerun.

**Pre-episode baseline approval record, 16 October 2026:** Felix approves
implementation for recurrent pockets, retaining unresolved acquisition-start
references, the burden formula, normalization and original results. He explicitly
selects withholding references shifted more than 20 seconds from the usual
baseline. [AMP-EPISODE-01](BOI_PRE_EPISODE_IMPLEMENTATION.md) was the approved active
milestone: shared versioned reference calculation, existing saved/live stats
integration and export provenance, bounded synthetic checks and the same named
FB2412 regression fixture. Owner root, no delegation. Four active hours, at most
six focused MATLAB invocations (five minutes each) plus two targeted repairs,
100 MiB evidence and 200 MiB synthetic exports. No detector/movie processing,
17-recording re-export, package or Git transport. Stop at verified local delivery.


**Episode-reference preview delivered, 15 October 2026:** the [unadopted proposal](BOI_EPISODE_BASELINE_PROPOSAL.md)
uses a common pre-series period on each event's own footprint. For FB2412 site-1
event 3, frames 639–658 have all 20 samples without native overlap and give a
6.012181% candidate drop, versus the immediate-window 2.561716% containing the
preceding dip. Event 2 and the isolated control remain unchanged. Adjacent
post-event windows for event 1 give 7.403022% and 9.034434%; neither is adopted
as a proven recovered reference. Observed-window burden can retain acquisition
censoring if a boundary reference is justified; no unobserved time is added.
Existing areas, durations, burden formula and exposure normalization are retained.
Four reference/product calculations and 15 protected hashes pass verification;
one 18.39-second headless preview. No recording totals, source movie, detector,
correction/statistics run or production-method adoption. The preview is complete;
episode/recovery definitions need review before implementation. No next execution
or active implementation milestone is inferred.

**Episode-reference preview authorized, 15 October 2026:** Felix requests a
biologically sensible recurrent/start-event reference and demonstration before
any method change. [AMP-REFERENCE-PREVIEW-01](BOI_EPISODE_BASELINE_PROPOSAL.md)
uses the same three saved FB2412 examples, with event 2 as recurrence context.
Test the pre-series window 639–658 on event 3's own footprint; retain the isolated
control; show post-event windows 36–55 and 56–75 as boundary-reference sensitivity.
Existing event areas/durations and burden/normalization remain. One bounded
headless MATLAB preview, no source movie, detector/correction/statistics run or
production adoption. Deliver and stop; implementation remains none.

**Saved baseline comparison delivered, 15 October 2026:** the three fixed FB2412
examples replay their current saved measurements. The [comparison](BOI_AMPLITUDE_BASELINE_COMPARISON.md)
separates baseline eligibility, spatial support and original timing: the
recurrent event has 14 preceding-event frames in its 20-frame reference; the
recording-start fallback uses later signal; site-union versus event-footprint
amplitudes differ substantially; the old global search expands the isolated
event's interval from 801–804 to 678–903. All 12 readouts are independently
verified and 11 protected hashes are unchanged. One completed 17.58-second
headless MATLAB comparison after one retained launcher failure. No raw movie,
detector/correction/statistics run, burden/normalization or production-method
change. The named comparison is complete. Reference and duration meaning need
scientific definition before any candidate-method adoption; no next execution
or implementation milestone is active.

**Saved baseline comparison authorized, 15 October 2026:** Felix requests
comparison of original/current amplitude and baseline rules on the saved
isolated, recurrent and recording-start examples before any method change.
[AMP-BASELINE-REVIEW-01](BOI_AMPLITUDE_BASELINE_COMPARISON.md) fixes three FB2412
site-1 events and separates baseline, footprint and timing effects. One bounded
headless MATLAB comparison, no detector/correction/statistics run, no source
movie read and no production-method or burden/normalization change. Deliver
the comparison and stop. Owner root, no delegation; implementation remains none.

**Burden interpretation correction, 15 October 2026:** Felix questioned the
scientific and biological meaning of partial burden. The proposed promotion of
partial sums into the routine GUI/export is withdrawn. They remain diagnostic
evidence only: baseline eligibility depends on event overlap, so the retained
subset may exclude recurrence that the cumulative burden is intended to include.
Area/time normalization and event-count coverage do not repair that selection.
Keep the intended composite burden and normalization. The appropriateness of the
current baseline/reference rule needs scientific discussion before an export
change; no new investigation campaign or implementation is active. The dated
review below and its separate preview are preserved as historical evidence.

**Burden availability review, 15 October 2026:** Felix requested checking missing
event contributions against the supplied script while preserving normalization
and showing a usable, explicit export. The [saved-data review and candidate](BOI_BURDEN_EXPORT_REVIEW.md)
matches all 5,407 sink events to their existing audits: 2,767 contribute, 2,572
lack the full clean baseline and 68 have wrong-direction amplitude. The old
omit-missing aggregation applied to current saved ingredients gives partial
normalized sums for all 17 recordings, with counts, reasons and coverage in a
separate preview. Complete totals remain unavailable; normalization is retained.
No detector/statistics/amplitude run, production calculation change or export
overwrite. Review only; implementation remains stopped. Adoption of the proposed
additional observed-burden and missingness fields needs scientific-output review.

**Combined batch export delivered, 15 October 2026:** local **3.1.0-dev.8**
connects the batch GUI to the existing stats/export service. The 17 completed
recordings export together into 108 workbook sheets with 5,407 sink events and
1,320 surge events. All 204 per-recording table and 136 stored-trace comparisons
match their saved individual results; final focused checks pass 44/44. Three
source holds, originals, earlier results, optional stimulation metadata and
review flags remain. Large MAT variables use v7.3 storage with the same filenames
and schemas; calculation rules and worksheet formats remain unchanged. See the
[delivery](BOI_BATCH_STATS_EXPORT_DELIVERY.md). No new recording/detector run,
MATLAB desktop, package, commit/push or release. Implementation is stopped after
verified local delivery; Felix can now use the combined exports for postprocessing.

**Combined batch export approved, 15 October 2026:** Felix explicitly requests
connecting the batch GUI to the existing stats/export workflow for the 17
completed recordings, retaining formats and calculations. BATCH-EXPORT is the
single active milestone: exact saved-run adapter, GUI review/run/output access,
finite checks and one named combined export, with at most one repair attempt.
See the [bounded work items](BOI_BATCH_GUI_PLAN.md#batch-connection-to-existing-stats-and-export).
Owner: root Codex without delegation. Six active hours, four focused test
invocations plus two targeted rechecks, 100 MiB evidence, 200 MiB synthetic
output and initially 2 GiB estimated named export output; complete large-table
MAT storage requires a corrected finite allowance of 16 GiB, with ample local
space. The same 17 recordings and two-attempt limit remain; at most 60 minutes
per export attempt.
No detector/new-recording run, new MATLAB desktop, package or Git transport.
Stop after verified local delivery. Earlier stopped milestones remain historical.

**GUI polish delivered, 15 October 2026:** Felix's “Good. Continue” approved
the proposed clearer check progress and faster saved-run opening.
[BATCH-UX](BOI_BATCH_GUI_PLAN.md#gui-progress-and-saved-run-opening) delivers local
**3.1.0-dev.7**: recording/stage progress and verification of only the selected
recording when opening its saved run. Batch-wide duplicate checks and selected
source/settings/metadata/artifact checks remain. Final 26/26 focused cases pass;
one read-only FB2412 reopening checked one of 20 rows in 16.39 seconds, with
progress and restored controls observed. Owner: root Codex, no delegation.
No new MATLAB desktop, recording execution, calculation change, package or Git
transport. The completed batch and source holds are preserved. Implementation
is stopped at this local delivery; another milestone or release needs agreement.

**Batch inspection round closed, 15 October 2026:** Felix started the reviewed
queue himself on 14 October; all 17 selected recordings completed and passed
the queue's saved-result verification, with no recorded execution errors and
no pending rows. FB2416, FB2417 and FB2318 remain held. Felix inspected FB2412
event traces, sink/surge recording summaries and surge frame ingredients,
reported that the trace viewer worked fine, and requested closure of this
inspection round. See the [closeout](BOI_BATCH_EXECUTION_DELIVERY.md#researcher-run-and-inspection-closeout).
This closes the demonstrated inspection round, without changing scientific
review flags or approving a release. At that closeout, implementation was stopped;
the GUI candidates were subsequently approved and delivered as recorded above.
The dated implementation and pre-run accounts below retain their original scope.

**GUI batch execution delivered, 14 October 2026:** Felix requested execution of the 17 ready rows from the GUI, retaining the three source holds. [BATCH-RUN-01 through BATCH-RUN-03](BOI_BATCH_EXECUTION_TASK.md) implement the sequential queue, status/history persistence, output/queue review, stop-after-current, verified skip/retry and failure handling using the existing recording workflow. The bounded engineering checks do not start the supplied recordings. Local **3.1.0-dev.6** is [delivered](BOI_BATCH_EXECUTION_DELIVERY.md): final 15/15 focused checks plus one targeted unwind recheck pass, with zero final cleanup warnings. Both layouts are inspected and the named 20-row preflight retains 17 ready/3 held. The updated window is open with 17 selected; Felix chooses output storage and starts the reviewed queue. No supplied recording, scientific algorithm change, new package, Git transport or release. Implementation is stopped.

**Setup repair delivered, 14 October 2026:** [BATCH-SETUP-FIX-01](BOI_BATCH_SETUP_REPAIR.md) delivers local **3.1.0-dev.5**: stimulation fields remain descriptive metadata, the automatic tissue estimate needs no preset ROI, and the separate 20-row input mapping passes native preflight for 17 rows with three explicit source holds (FB2416/FB2417/FB2318). Four focused tests, one targeted GUI recheck and linked-source/hold checks pass. Originals and scientific engines are preserved; the prepared copy is open in existing MATLAB. Implementation is stopped pending Felix's trial/source reconciliation. No analysis, queue execution, release or Git transport occurred.

**First batch editor milestone delivered, 14 October 2026:**
[BATCH-SETUP-01 through BATCH-SETUP-04](BOI_BATCH_EDITOR_DELIVERY.md) deliver local
**3.1.0-dev.4**, CSV import/export and shared settings/overrides, optional/custom
metadata, per-row preflight and verified saved-run reopening. Final 10/10
focused cases pass, with the initial dropdown failure retained; both planned
window sizes are inspected. One MATLAB start, 31 case evaluations and below
2 MiB evidence; zero detector/statistics/recorded-movie execution. Separate
Codex static review is complete; Felix's editor usability acceptance remains
pending. Of 544 existing MATLAB files, 541 are unchanged; launcher, version and
test registration are the only existing MATLAB edits. No active implementation
remains. Queue execution/live status writeback require their next bounded
proposal and approval. No package, commit/push or publication occurred.

**Approved first batch editor milestone, 14 October 2026:** Felix agreed to the
field set and [batch plan](BOI_BATCH_GUI_PLAN.md) and requested implementation of
the first milestone as proposed. BATCH-SETUP-01 through BATCH-SETUP-04 are active:
CSV contract/adapter, editor, explicit shared settings and row overrides,
optional metadata, per-row preflight and existing-run status display. Budget:
eight active hours, two MATLAB starts, 100 MiB, zero detector/statistics/recorded
movie executions. Routine repairs, focused rechecks and separate technical
review are included. Deliver the editor and stop before queue execution/live
status writeback, packaging, commit/push or publication. The earlier planning-only
entry below is historical for this approved scope.

**Current direction, 14 October 2026:** Felix requested skipping the second
user review and prioritising GUI usability, especially batch CSV preparation,
optional metadata and visible analysis completion. The proposed colleague
walkthrough and its preparation are skipped for the current plan; no unfamiliar
user evidence is claimed. The [batch CSV and GUI plan](BOI_BATCH_GUI_PLAN.md)
proposes a batch editor with one recording folder entered per row, explicitly
confirmed shared acquisition/support settings, optional metadata and durable
run-status tracking. The first proposed milestone is CSV/editor/preflight work;
queue execution and live status writeback follow separately. Planning only:
no implementation milestone is active. Existing software, saved results and
scientific rules are preserved; release remains a separate decision. This
direction supersedes the colleague-task next step in the dated entry below.

**Acceptance and next handoff, 14 October 2026:** Felix accepted the
[3.1.0-dev.3 interface/GitHub delivery](BOI_USABILITY_GITHUB_DELIVERY.md), final
branch commit 984288f. The [next handoff](BOI_COLLEAGUE_WALKTHROUGH_HANDOFF.md)
prepares a current development test ZIP and a short colleague installation,
saved-result/export and arithmetic walkthrough using FB2311. Actual unfamiliar
scientist feedback remains pending. This chat records acceptance and prepares
that bounded task only; its pasted execution prompt is the next authorization.
No new build, MATLAB session, test, commit/push or publication occurred here.

**Current delivery, 13 October 2026:** the approved detection-support/export-folder
usability task is locally verified. Current checkout **3.1.0-dev.3**, build
**2026-10-13 20:02:39 +02:00**, preserves calculations, definitions and saved results.
Missing support now gives an actionable choice; event/window exports retain their
full completed destination with **Open folder** and **Copy path**. Thirteen unique
focused checks pass after one retained getter repair; the named FB2311 saved
exports preserve the four measures, frames, reference contributors and original
calculator identity. Folder destinations were observed in Finder and two layouts
captured. Native chooser cancellation is verified through the shared continuation,
not a new manual chooser sequence. [Delivery](BOI_USABILITY_GITHUB_DELIVERY.md)
records the finite scope and final source/Git transport handoff. No recording,
detector/statistics run, correction refit or package build. Felix’s manual test
remains accepted within its original scope, with peak memory unmeasured. Normal
branch delivery is the final approved action; stop afterward. No automatic next
test, implementation, package, containment or release task follows.

**Handoff preparation, 13 October 2026 (historical):** the
[interface and GitHub handoff](BOI_USABILITY_GITHUB_HANDOFF.md) covers actionable
detection-support guidance, accessible event/window export folders, current
documentation and a proposed 3.1.0-dev.3 development snapshot. It uses the saved
FB2311 run for focused verification and includes routine repairs within one
bounded task. This chat prepared the handoff; implementation awaits Felix's
explicit execution prompt in the implementation chat. No application change,
MATLAB start, test, version change, commit/push or new package occurred here.

**Latest manual-test status, 13 October 2026:** Felix completed and accepted the
demonstrated FB2311 recording, sink inspection/export and saved-run reopening
workflow. The [test result](BOI_FB2311_MANUAL_TEST_RESULT.md) records one event
amplitude and three sink-summary arithmetic checks, with matching values after
reopening. This supplies fresh-recording integration and elapsed-time evidence
for this one case; peak memory and scientific interpretation remain unverified.
No further execution is scheduled; release remains a separate decision.

**Latest task status, 5 October 2026:** the corrected licensing documents and
verified development download are complete and accepted within their demonstrated
scope. [Delivery](SOFTWARE_LICENSING_DISTRIBUTION_DELIVERY.md): packaged source
44f3031, final branch commit 029c989, version 3.1.0-dev.2. The approved provenance
label/checksum repair preserves formulas, values and scientific qualifications.
New V2 contribution licensing and release decisions remain separate. Earlier
dated approvals and deliveries below remain historical records.

**Manual-test preparation, 5 October 2026 (historical):** personally test one recording in ordinary MATLAB,
from import through analysis, inspection, reopening and export. The
[manual walkthrough and results form](BOI_FELIX_MANUAL_RECORDING_TEST.md) are
prepared under the [planning handoff](SOFTWARE_RESEARCHER_RECORDING_TEST_HANDOFF.md).
Felix's recording selection, settings, new unused output and feasible numeric
resource limits remain pending. Preparation read controls/definitions only;
no MATLAB launch, recording, numerical test, application repair, build or
commit/push occurred. The existing candidate remains unchanged. Keep the test
pending until Felix reports the outcome; assistant preparation is not researcher
feedback. Custom containment and VM/watchdog work remain deferred to a possible v4.

**Manual-test guidance, 13 October 2026:** Felix opened development 3.1.0-dev.2
and selected the OneDrive FB2311 source folder. Verified local copies of its
preserved and denoised movies are prepared in
`reference-validation/felix-fb2311-manual-test-20261013/input`; both have
512 × 512 pixels and 1,200 frames. Felix confirmed 1 Hz and 2.35 µm/pixel.
Felix subsequently ran the recording through the interface. The saved status
in `BOIRun_FB2311_20261013_01` reports complete, elapsed 293.60 seconds,
with 240 automatic sink candidates and 88 surge candidates in its saved audit.
Numerical resource limits were not recorded before the manual run; peak memory
was not measured. No MATLAB or recording was launched by the assistant.
Felix demonstrated sink site 2/event 5 amplitude, timing and source-footprint
inspection, then exported its evidence. An independent Python/Pillow replay
read the original 250 fixed pixels on 20 reference frames (479–498) and 16
measurement frames (499–514). It reproduced reference mean 5637.9378,
minimum 5403.236 at frame 508 and automatic optical drop 4.162901548860646%,
with zero difference from the saved amplitude fraction. Source and export
hashes were checked; no detector/statistics execution or correction refit.
Reference suitability, physiological boundaries and the denoised correction
remain separate questions. Felix also inspected and exported the whole-recording
sink summary. An independent Python replay checked 1,200 frame intervals,
240 saved event intervals and the denominator from 156,907 sink-support pixels
at 2.35 µm/pixel (0.8665189075 mm²), with µm²-to-mm² and seconds-to-minutes
conversion. Occupied tissue fraction 0.005748436972219212 (0.5748436972%),
onset rate 13.8485148981 events/mm²/min and concurrent density
3.9064352442 events/mm² match the saved values within floating/CSV rounding.
One acquisition-boundary candidate is included by the saved descriptive rule.
This replay used saved union areas; native mask reconstruction and anatomical
validation were not performed. Felix subsequently confirmed a reopened completed
run with 328 automatic events, the same site 2/event 5 frames, amplitude and
reference count, and all three matching sink-summary values. He accepted this
demonstrated workflow with “ok, all matches. i think we are good”. Surge inspection,
native-mask attachment and opening this run's workbook were not demonstrated;
these are retained limits, with no automatic follow-up. This is not scientific
validation of the detections or release approval.

Version 0.2 · 23 September 2026 · SW-PLAN-001

Approval recorded 23 September 2026: roadmap and G1 accepted (“i approve”). Later milestone gates remain in force.

G1 is complete: [engineering baseline](SOFTWARE_G1_BASELINE.md). The [narrowed G2 slice](SOFTWARE_G2_WORKFLOW.md) was approved by “Continue” on 23 September; [G2 is delivered](SOFTWARE_G2_WORKFLOW.md); work is at its completion gate.

**Product direction, roadmap, G1 and the narrowed G2 slice are approved.**
The researcher [accepted G3's demonstrated daily-use workflow for usability](SOFTWARE_G3_USABILITY_ACCEPTANCE.md) on 27 September 2026. This does not validate a fresh real-acquisition run or every failure path and is not release approval. Analysis/statistics failures, incomplete-run recovery and relevant real-acquisition checks move to bounded G5 release work. [SW-G4-01 through SW-G4-04 were approved](SOFTWARE_G4_PROPOSAL.md) with zero new detector/statistics runs; [exact replay targets](SOFTWARE_G4_REPLAY_TARGETS.md) were recorded before implementation. The researcher accepted the [bounded G4 delivery](SOFTWARE_G4_DELIVERY.md) for usability of the specific C02 review, the ID400 measurement explanations and readable export. This does not establish all-recording or all-metric validity. [SW-G5-01 through SW-G5-03 were approved](SOFTWARE_G5_PROPOSAL.md) under two synthetic attempts, one small synthetic detector and zero recorded runs; the researcher accepted only the statistics boundary and saved incomplete-run recovery evidence from the [first-slice delivery](SOFTWARE_G5_FIRST_SLICE_DELIVERY.md). A separate, approved [SW-G5-04 test-only live analysis boundary check](SOFTWARE_G5_04_DELIVERY.md) was accepted for that boundary evidence only. The researcher accepted the [eight-case SW-G5-05 delivery](SOFTWARE_G5_05_DELIVERY.md) within its zero-run budget, with the initial discovery defect retained. The researcher approved [SW-G5-06 alone](SOFTWARE_G5_06_PRE_RUN_PROPOSAL.md) on 28 September 2026 for one supervised, named real-acquisition attempt under its revised process-isolation and resource limits. SW-G5-07, G5 acceptance and release remain unapproved. No team has been launched by writing this plan.

**Current gate (1 October 2026):** [CC-02U delivered](SOFTWARE_CC_02_USABILITY_COMPLETION_DELIVERY.md), with all six focused layout/native-chooser/preservation checks passing within twelve recorded evaluations. The researcher accepted the bounded workflow at 1120 × 800 and 900 × 650, including demonstrated native selections and cancellations. Both CC-02 usability items are closed within that scope; all documented limitations remain. No further checks, launches or implementation are authorized. Release remains paused; overall usability, G5 and release are unaccepted.

**Current delivery (1 October 2026):** [Automatic amplitude and summary export clarification delivered](SOFTWARE_AUTOMATIC_AMPLITUDE_EXPORT_DELIVERY.md): final 9/9 saved/synthetic cases passed; formulas, existing values and column identifiers preserved. The [pre-execution budget](SOFTWARE_AUTOMATIC_AMPLITUDE_EXPORT_TASK.md) storage ceiling was exceeded and is disclosed; earlier duplicate artifacts were losslessly compressed. No further tests, launches or campaign are planned. The researcher accepted this clarification within its demonstrated scope on **4 October 2026**, retaining the storage-budget exception, earlier failures and scientific limitations. **Development and release are paused.** No further verification or analysis task is authorized automatically; await a new explicit researcher requirement. Live-run containment remains paused.

**Next work proposal (4 October 2026):** the [software priorities and working plan](SOFTWARE_NEXT_STEPS.md) orders seven practical steps, starting with saving the accepted software and reconciling its development identity, then checking duration/area/occupancy and the remaining summaries. It includes a proposed version policy, bounded task budgets and handoffs. The [first-task handoff](SOFTWARE_FIRST_TASK_HANDOFF.md) is ready for a separate step-1 approval. Preparing these documents authorizes planning only; no implementation, tests, MATLAB, package build, commit/push or release action has started. Development and release remain paused.

**Step-1 authorization (4 October 2026):** the researcher approved saving accepted
software and establishing `3.1.0-dev.1`, including routine repairs and normal
commit/push to `development-existing-analysis-v3`. Only NEXT-01 is active;
[its record](SOFTWARE_NEXT_01_DELIVERY.md) defines the static-only checks and
90-minute/two-commit/one-push/5-MiB limits. The preceding paused/proposal
statements describe earlier gates. No calculation work, MATLAB, tests, package,
recording, release or step-2 work is authorized.

**Current delivery (4 October 2026): Step 2 approved and delivered.** The
researcher authorized the complete bounded duration/native-area/union-occupancy/
onset-rate/concurrent-density task, with routine repairs and old/new review
before scientific-output adoption. [Task](SOFTWARE_NEXT_02_TASK.md),
[delivery](SOFTWARE_NEXT_02_DELIVERY.md) and
[scientist guide](BOI_DURATION_AREA_AND_EVENT_RATES.md) record final 9/9 named
passes, two batches/18 evaluations, two charged MATLAB attempts (one successful
saved-data-only session), approximately 42.16 MiB and zero production changes.
Correctly implemented definitions and original results are preserved. No
numerical adoption decision remains within the named scope. Earlier pause/gate
statements describe their historical dates; current development is stopped
after Step 2. Step 3 requires separate approval and release stays paused.

**Current delivery (4 October 2026): Step 3 delivered; development stopped.**
The researcher accepted Step 2 within its demonstrated arithmetic/export scope,
retaining failures and scientific limits, then approved Step 3. Its
[delivery](SOFTWARE_NEXT_03_DELIVERY.md) and
[guide](BOI_INTEGRALS_COMPOSITES_AND_SUMMARIES.md) record 8/8 final cases,
three batches/24 evaluations and two saved-data-only sessions. Numerical
formulas/results remain unchanged. Original/current export identity is repaired
in local 3.1.0-dev.2; both saved statistics creator versions remain unknown.
Step 2 uncommitted work is preserved. No commit/push or Step 4 starts;
release and development remain paused pending separate approval.

**Current authorization (4 October 2026): Step 3 accepted; Step 4 active.**
The researcher accepted Step 3 within its demonstrated calculation/provenance
scope, retaining limitations, and approved the complete installation-package
task with routine repairs/rechecks. [Step 4 task](SOFTWARE_NEXT_04_TASK.md)
sets four active hours, three builds, six focused batches, two MATLAB sessions
and 150 MiB. Preserve previous candidate and uncommitted Steps 2–3; no
recordings, calculation changes, containment, commit/push/publication or Step 5.
Earlier dated active/pause statements are historical, superseded for this scope.

**Current delivery (4 October 2026): Step 4 complete; development stopped.**
[Installation candidate delivery](SOFTWARE_NEXT_04_DELIVERY.md): one fresh
3.1.0-dev.2 modified-working-tree build; exact source/folder/ZIP/extraction
hashes match; six final saved-data routes pass without checkout fallback.
Five focused batches and one MATLAB session, under four hours/150 MiB; retained
harness failures and extra window recheck. Step 3 accepted within its limits;
previous candidate and Steps 2–3 preserved. No commit/push/publication.
Current active execution is none. Step 4 acceptance and separate Step 5 approval
remain; release and containment work stay paused.

**Current authorization (4 October 2026): Step 4 accepted; Step 5 active.**
The researcher accepted the installation candidate within its saved-data limits
and approved portable calculation/export/compatibility checks plus named
macOS/R2025a and hosted Linux/R2025b evidence. [Task](SOFTWARE_NEXT_05_TASK.md):
four active hours, one selected local BOI gate with targeted repairs, at most
two hosted executions including push triggers, each capped at 30 minutes.
Commit/push accepted Steps 2–4 and portable tests; preserve candidate/results.
No recording, calculation change, containment, release or Step 6. Earlier
active/pause statements apply to their historical dates only.

**Current delivery (4 October 2026): Step 5 complete; development stopped.**
[Portable check/environment delivery](SOFTWARE_NEXT_05_DELIVERY.md): 26 new
portable cases connected to BOI runner; 29 desktop cases separate. Final hosted
Linux/R2025b gate 133/133 passes on 5c23b02; macOS/R2025a one full gate had
132 passes/one repaired fixture failure, then three targeted checks passed.
Two hosted executions used, both below 30 minutes; earlier failures retained.
Accepted Steps 2–4 and tests committed/pushed; preserved candidate's 443 source
hashes match tested source. Documentation-only completion commit skips CI.
No active implementation remains; Step 6 and release require separate approval.

**Current authorization (5 October 2026): Step 5 accepted; Step 6 initial
assessment only.** The researcher accepted the portable-calculation/environment
scope, preserving the complete Linux pass versus partial final macOS evidence,
and authorized one separate Codex reviewer for an independent code review of
the launch supervisor, worker and saved startup/cleanup evidence. This is not a
human systems audit. [Assessment](SOFTWARE_NEXT_06_INDEPENDENT_ASSESSMENT.md):
three active hours maximum; no implementation, tests, research-process/MATLAB
launches, recording analysis, push or publication. Historical failures and
consumed approvals remain. Stop after assessment; any implementation or recording
requires a separate concrete proposal and approval. No retries or diagnostic
campaign are authorized. No active implementation milestone exists.

**Current delivery (5 October 2026): Step 6 initial assessment complete; stopped.**
The separately authorized [independent code review](SOFTWARE_NEXT_06_INDEPENDENT_ASSESSMENT.md)
finds that sampled ancestry cannot establish whole-launch ownership/cleanup.
It recommends an exclusively owned disposable execution boundary with an
external watchdog and one finite, separately authorized qualification packet.
No such boundary or recording-ready release contract is demonstrated. Fourteen
code hashes and five saved-evidence anchors identify the review; 140 protected
files/candidate pins match. No repairs, tests, research-process/MATLAB launches,
recording analysis, commit/push or publication. Historical failures and consumed
approvals remain. Any implementation/recording needs a separate concrete proposal
and approval; no qualification campaign, retries or Step 7 starts automatically.

## Current scope decision on 5 October 2026

The researcher deferred VM isolation, external watchdogs, custom process-tree
containment, one-use recording-worker release contracts and their qualification
campaign to a possible later major version, such as v4. These are outside the
current 3.1 development plan and are not prerequisites for its remaining user
workflow or release preparation. The independent assessment remains valid for
the reviewed supervision approach; its findings and historical failures are
preserved, not marked passed.

Proceed with ordinary MATLAB use, clear analysis outputs and the final
installation/calculation walkthrough in [the revised working plan](SOFTWARE_NEXT_STEPS.md).
The [next-chat handoff](SOFTWARE_NEXT_07_HANDOFF.md) describes one complete user
readiness task. Preparing that handoff is authorized planning; its implementation
and any MATLAB session still need the bounded task approval.

A normal MATLAB fresh-recording check can be proposed separately without a VM,
external watchdog or custom launch-control qualification. Such a proposal must
name the recording, settings, new output, feasible effort/output budget and
ordinary stop procedure. No new recording execution is authorized by this scope
decision. Fresh-recording integration and runtime/memory evidence remain
unverified; claims must retain that limitation. Project licensing, applicable
support limits and final release publication remain separate decisions.

This current scope supersedes earlier containment-related release prerequisites.
Older dated gates, the assessment, consumed approvals and original results stay
as historical evidence. Software version remains 3.1.0-dev.2; this revision
changes planning records only.

**Current delivery (5 October 2026): ordinary MATLAB user readiness complete.**
The researcher approved the complete four-hour/two-session/100-MiB task.
[Delivery](SOFTWARE_NEXT_07_DELIVERY.md),
[walkthrough](BOI_ORDINARY_MATLAB_WALKTHROUGH.md) and
[worked calculations](BOI_SAVED_CALCULATION_WORKED_EXAMPLES.md) demonstrate
fresh candidate installation, completed-run inspection, accepted ID400 reviewed
choices/new save/reopen/export, and G2 ID400 automatic recording mean from CSV
ingredients (94/192 events). Assistant controls/captures and independent Python
arithmetic are distinguished from scientist feedback, which has not been received.
No application code, scientific definition or accepted result changed. Original
candidate/results and earlier uncommitted assessment/scope work are preserved.
One confirmed MATLAB R2025a session exited 0; timed-out native desktop access is
conservatively charged as a second possible session. Three evidence-harness
failures and focused repairs are retained. No full matrices, hosted CI, recordings,
refits, custom supervision, commit/push or publication. Task complete for review;
no active execution remains. Licensing, declared support and explicit release
decisions remain; fresh integration/runtime/memory are unverified. No automatic
next task, recording proposal execution or publication.

**Current authorization (5 October 2026): saved-data user readiness accepted;
documentation/distribution only.** The researcher accepted the demonstrated
scope while preserving assistant checks versus researcher feedback. One bounded
[task](SOFTWARE_NEXT_07_DISTRIBUTION.md) makes the new guides portable, includes
them in one new development candidate, and saves accepted documentation/scope
records to GitHub on development-existing-analysis-v3. Ninety active minutes,
one build, at most one packaging-only MATLAB session, 50 MiB, at most one
automatic CI execution and no manual rerun. The push skips CI; historical
numerical evidence is retained. Preserve previous ZIP/results. No recording,
calculation/scientific-definition change, licence choice, custom supervision,
merge/tag or publication. Stop after delivery; no further task is authorized.

**Current delivery (5 October 2026): portable documentation and development
candidate complete.** [Delivery](SOFTWARE_NEXT_07_DISTRIBUTION.md) records one
packaging-only build, 446 exact source/document files plus manifest, matching
folder/ZIP/extraction hashes and 38 package links. Previous ZIP/results and
accepted scientific values/qualifications are preserved. New guides are portable;
only packaging-manifest wording changed in MATLAB, no calculation/GUI/test repair.
Accepted documentation/scope records are saved on the development branch with CI
skipped. Task stopped after normal push/source verification; no active execution.
Researcher acceptance does not imply an independent scientist walkthrough.
Licence/dependency notices, support/claims and explicit release approval remain.
Fresh-recording integration/runtime/memory remain unverified; no automatic next task.

**Current decision record (5 October 2026): updated development distribution
accepted within demonstrated scope.** The researcher requested one concise
[release decision sheet](RELEASE_DECISION_SHEET.md) covering the project licence,
dependency notices, supported environments/evidence gaps and accurate publication
wording. Documentation preparation only; no active implementation, tests, MATLAB,
recording, package build, commit/push or publication. Preserve prior candidates,
results, scientific qualifications and assistant/researcher feedback distinction.
Licence selection and any further execution/publication require separate approval.

**Current documentation delivery (5 October 2026): dependency notices reconciled;
project licence discussion deferred.** The researcher authorized one complete
licence/notice documentation task, preserving code/results and returning the
documents before publication. When exact project details were requested, the
researcher deferred holder/year/licence selection to a separate background
discussion. [Review](LICENCE_NOTICE_RECONCILIATION.md) and
[notices](../THIRD_PARTY_NOTICES.md) identify official upstream terms for the six
listed files, retain source/distribution attributions and preserve unknown
historical origins. Five licence-byte hashes and full text reproductions are
recorded; 542 MATLAB file hashes and both candidate ZIP hashes are unchanged.
No project grant is adopted. Local documentation is outside the accepted ZIPs;
no code change, MATLAB, tests, recording, build, commit/push or publication.
No active milestone remains. Return for review and the separate licence discussion;
historical failures, consumed approvals and scientific qualifications remain.

**Current authorization (5 October 2026): original software licence correction.**
The researcher said “Continue” after the original Science_2024 release was found
to contain an MIT licence. One documentation slice, LICENCE-02, restores that
notice verbatim, corrects current licensing claims, records contributor roles and
source evidence, and checks links and preserved hashes. The implementation
assistant owns the correction. Limit: 60 active minutes and 1 MiB of new documents;
no MATLAB, scientific tests, recording, build, commit/push or publication.
Licensing authority for new V2 contributions remains a separate decision; this
approval does not adopt a blanket licence for them. Stop after the local delivery.
Earlier “no licence found” records describe the inspection available at that time
and are superseded for inherited code by the original release evidence.

**Current documentation delivery (5 October 2026): original MIT notice restored.**
[Licensing and contributor credits](../LICENSING.md), the
[source record](planning/original-software-licence.json) and the corrected
[notice review](LICENCE_NOTICE_RECONCILIATION.md) retain the original archive's MIT
text and `Copyright (c) 2023 Antonis Asiminas`. Archive checksum and pinned GitHub
text confirm the source; the saved Zenodo CC BY 4.0 label is recorded separately.
The earlier BSD proposal is superseded. The researcher-described roles of
Antonios Asiminas, Ryszard Gomolka, Felix Beinlich and Maiken Nedergaard are
credited without assigning ownership or changing citation order. Current
documents explain that the existing MIT grant permits reuse with its notice;
new V2 contribution licensing remains unconfirmed. No new grant or rights holder
is invented. The prospective package file list includes the notice, guide and
source record; no rebuild is claimed. Delivery is local and uncommitted, version
3.1.0-dev.2. Stop after static document/preservation checks. Publication, support
decisions and fresh-recording evidence remain separate; no automatic next work.

**Current approved task stopped before build (5 October 2026).** The researcher
approved the complete [documentation/distribution handoff](SOFTWARE_LICENSING_DISTRIBUTION_HANDOFF.md)
within two active hours, two builds, one packaging-only MATLAB session, three
commits, one successful normal push and 50 MiB. Initial local/remote identity,
space and preservation checks passed. The mandatory reviewed-optical contract
contains twelve absolute research-path strings and is hash-pinned by its MATLAB
loader. Unchanged contracts/code and no machine-specific paths cannot both be
met. [The concrete decision](SOFTWARE_LICENSING_DISTRIBUTION_BLOCKER.md) proposes
twelve provenance-label replacements, one loader digest change and a single
non-numerical definition-load check in the packaging session, without changing
scientific values/formulas. Proposal only; no code/contract change, MATLAB,
build, commit or push occurred. Existing uncommitted documents/results and old
ZIPs remain preserved. Stop for the bounded scope decision; no active execution.

**Current continuation approved (5 October 2026).** The researcher approved the
path amendment within the same DOCS-DIST-01 total budget: use unique labels for
distinct historical judgments, retain their hashes, preserve every formula,
frame, value and qualification, and update only the loader checksum. The same
single MATLAB session may package and check the extracted definition loader.
Twelve path strings have been replaced; four distinct judgments have four labels.
The checksum-only loader change and all other field equality are checked
statically. Portable reader documents retain the MIT/dependency terms and V2
licensing limit; historical task/evidence records stay outside the package.
Complete source commit, package/hash/link/notice verification and one normal
push, then stop. No numerical matrices, recording, CI or publication are approved.

**Current local delivery complete (5 October 2026).** The approved licensing
[distribution delivery](SOFTWARE_LICENSING_DISTRIBUTION_DELIVERY.md) has 447
committed sources at 44f3031 and 448 matching folder/ZIP/extracted files.
All 65 reader links, exact MIT/five upstream licence texts, exclusions and
preservation checks pass. The same single MATLAB session built once and passed
the extracted definition load; normal exit 0, zero numerical evaluations or
recording runs. Only twelve provenance strings and one loader checksum changed
under the explicit amendment; formulas, frames, values, judgment hashes and all
qualifications remain. Both old ZIPs/results are preserved. This closing record
is outside the package; final normal push/remote verification is reported in the
handoff/transport receipt. No active implementation or automatic next task remains.
New V2 licensing, declared support/claims and publication remain decisions; no
new CI, recording, custom supervision or release action is authorised.

## 1. Product goal

Deliver a maintainable MATLAB application in which a researcher can load a BOI
recording, check its metadata and tissue support, run the established analysis,
inspect and revise event judgments, and export understandable, reproducible
results without reconstructing paths, scripts or development history.

Success is demonstrated by a working researcher journey and reliable numerical
behavior. Completing cohort analyses, reproducing a publication figure or
maximizing the number of detected events is not the product goal.

Use the [researcher workflow and traceability contract](RESEARCHER_WORKFLOW_AND_TRACEABILITY.md)
as the product acceptance foundation. The [measurement dictionary](BOI_MEASUREMENT_DICTIONARY.md)
and [working measurement specification](BOI_WORKING_ANALYSIS_SPECIFICATION.md)
describe current meanings and unresolved science. The older reanalysis plan,
cohort roadmap and completed C02 reports remain historical evidence; their
cohort-completion requirements do not govern this software release.

## 2. Current starting point

This is an existing implementation to professionalize incrementally, not an
empty project. The planning inspection found:

| Observed implementation | Planning implication |
|---|---|
| `OxygenDynamics_GUI.m`: 1,409 lines, shared state and nested callbacks; import review, measurements and result panels already exist. | Map the real user journey and state transitions before splitting code or redesigning screens. File length is a review signal, not proof of a defect. |
| `OxygenDynamics_Master.m`: 493 lines; `runOxygenDynamicsStats.m`: 550 lines, supported by many helpers. | Identify stable orchestration and calculation boundaries; reuse the engine. |
| Saved event review, metadata/support contracts, dictionaries, source hashes and output schemas already exist. | Connect and consolidate them; avoid a parallel review or provenance framework. |
| The saved verification inventory contains 495 MATLAB files and extensive existing changes. | Preserve the current worktree and classify production, experimental and test code before restructuring. |
| GitHub CI targets MATLAB R2025b on Linux; recent local evidence uses R2025a on macOS. | Establish a declared support matrix and check it. A green historical run does not establish current compatibility. |
| README contains extensive experiment history and historical test counts. | Give users a short current entry point; keep history linked separately and report fresh checks accurately. |

This is a planning inspection, not a completed code-quality, security or
performance audit. There was no new detector run or fresh test-suite execution
to support this plan.

## 3. Scope and scientific boundaries

**In scope:** the MATLAB BOI application, its analysis engine and existing
supported inputs, configuration and parameter explanations, researcher review,
saved results, error handling, reproducibility, bounded tests, documentation,
packaging and maintainability. Both sink and surge results remain supported.
Existing batch capability stays available and shares calculation code with the
GUI; a new batch orchestration platform is not an implied requirement.

**Deferred:** cohort reanalysis, treatment comparisons, scientific manuscript
results, KX whisker analysis, stimulation-window reconstruction, new protocol
inference, IOSI, a replacement detector, new physiological estimators, cloud/web
deployment and a MATLAB-free rewrite. Existing experimental capabilities and
outputs are preserved; deferring work is not permission to delete them.

Your fixed stimulation protocol can become an explicit configuration requirement
in a later approved milestone. We will not infer it from recordings or build a
generic protocol engine now.

Standing scientific requirements:

- Keep biological variability and difficult signals visible. Accepted detector
  imperfections do not trigger another optimization campaign.
- Preserve original recording-specific correction. No universal substrate
  decline model or adjustment to obtain expected effects.
- For the supplied recordings, externally controlled 1 Hz takes precedence over
  unreliable embedded timestamps. Store timing authority, frame/time mapping and
  unknown camera exposure separately. Do not hard-code all future inputs to 1 Hz.
- Use source-specific craniotomy support, including dark interior tissue and
  uncertain edges; do not define anatomy from bright pixels or image corners.
- Corrected intensity leads visual review; detection score supports it; raw
  intensity/trend checks correction. Quantitative optical sources retain their
  existing definition and must not be silently replaced by the displayed trace.
- Keep automatic detections, human judgments and reviewed measurements distinct.
  Preserve negative finite values, unavailable values and their reasons. Missing
  amplitude must not erase otherwise available event counts or coverage.
- Version meaningful calculation changes. Unknown biology remains unknown;
  numerical agreement is not physiological ground truth.

## 4. How I would organize a small team

Use three engineering roles, with you as product/scientific owner. Roles may be
combined in a smaller team; they do not require three full-time hires.

| Role | Accountability | Boundary |
|---|---|---|
| Product/scientific owner — researcher | Priorities, workflow acceptance, interpretation, scientific defaults and scope decisions. | The team prepares concrete choices; it does not transfer implementation minutiae to you. |
| Technical lead / core engineer | Architecture, numerical contracts, integration, bounded work selection and preservation of existing behavior. | Cannot approve a new scientific method or product scope on your behalf. |
| Workflow engineer | GUI state, import/review/run/inspect/export flow, persistence and user-facing errors. | Uses the same engine and data contracts as batch execution. |
| Validation/release engineer | Regression fixtures, independent numerical checks, compatibility, performance evidence and release package. | Does not tune the implementation to make a preferred biological result pass. |

The technical lead owns integration. The author of a calculation, persistence or
schema change should not be its sole reviewer when another engineer is available.
If working alone, report that limitation; an automated replay is not an
independent human review. The originally planned unfamiliar-researcher usability
demonstration is skipped for the current plan by Felix's 14 October direction;
no such feedback is claimed. Technical review remains distinct.

One delivery milestone is active at a time. At most two implementation items
run concurrently when their files/contracts are independent. Core interfaces
are agreed before parallel edits. No agents or additional tasks are spawned
merely because this document describes a team.

## 5. Goals, subgoals and completion gates

### G0 — Agree the product and operating boundaries

**Outcome:** one current mission, a bounded first release and an approval record.

- G0.1 Record software development as the active objective; supersede stale cohort next steps.
- G0.2 Agree the priority user journey and the existing scientific behavior to preserve.
- G0.3 Separate required release capabilities from later requests and scientific questions.
- G0.4 Approve G1's scope and stopping condition before implementation begins.

**Done when:** the plan and first milestone are explicitly accepted; the active
status identifies the approved milestone. **Now:** plan and guardrails approved on 23 September; G1 authorized.

### G1 — Establish an engineering baseline and a bounded backlog

**Outcome:** know what works, what is fragmented and what is actually broken.

- G1.1 Map launch → import → preflight → run → inspect → revise → reopen → export
  through actual functions and saved artifacts. Identify manual path selection,
  hidden dependencies and ambiguous application state.
- G1.2 Classify production, experiment, legacy and test entry points without
  moving/deleting files. Inventory uncommitted changes and the protected baseline.
- G1.3 Run the relevant existing fast checks; label passed, failed, skipped and
  untested separately. Review CI dependencies and local/CI version differences.
- G1.4 Propose at most three existing regression recordings, chosen for software
  coverage: representative workflow, differing scale/support or missingness, and
  a local non-DANDI input. Reuse cached outputs and small synthetic fixtures first.
- G1.5 Produce a severity-ranked backlog and a recommended first implementation
  slice. Each finding must cite a reproducible failure or concrete user obstacle.

**Acceptance:** a concise system map, current verification summary, fixture
proposal and at most ten prioritized issues. Distinguish an implemented feature
from one demonstrated end to end. No open-ended audit and no cohort analysis.

**Stop:** deliver those four artifacts and propose G2. No detector optimization,
source-data campaign, broad cleanup or dependency upgrades. The default G1
validation uses saved results and bounded synthetic/unit checks; no full movie
detector execution is included without a named, approved test case and budget.

### G2 — Establish stable software boundaries through one working slice

**Outcome:** one recording travels through a coherent application path using the
existing engine, with interfaces that can be tested independently of the GUI.

- G2.1 Define explicit recording, configuration, run-result and review-revision
  contracts by extending existing structures; avoid introducing a competing schema.
- G2.2 Separate GUI callbacks/state from orchestration and scientific calculations
  only where the first slice needs it. Keep existing entry points/adapters working.
- G2.3 Centralize settings resolution and validation so GUI and batch agree.
  Display default/override provenance and scientific meaning.
- G2.4 Make the selected recording/run/revision explicit, with valid transitions
  and no stale results carried into a newly selected input.

**Acceptance:** the same approved fixture and configuration produce equivalent
scientific outputs through GUI and batch. IDs, masks, event timing, missingness
and metadata are identical where exact equality is required; established
field-specific numeric tolerances apply elsewhere. No blanket permissive tolerance.

**Stop:** the vertical slice and contracts are reviewable. Architecture changes
must earn their place by this use case; a repository-wide rewrite is excluded.

### G3 — Make the daily researcher workflow coherent

**Outcome:** routine use does not require remembering development scripts/paths.

- G3.1 Provide one clear entry point with new analysis and reopen-existing-result
  paths, retaining the current supported input routes.
- G3.2 Show identity, timing authority, calibration and tissue support before
  running; separate missing data, warnings and blocking input errors.
- G3.3 Show the selected settings, output destination and overwrite/version
  behavior before a run. Surface progress and actionable failures.
- G3.4 Open the relevant event/recording review directly from the selected run.
  Retain the corrected/raw/score roles already established with the researcher.
- G3.5 Make save, reopen and export discoverable and verify that they target the
  intended source/run/revision.

**Acceptance:** a scripted user journey completes import, preflight, run,
inspection and reopen/export using documented UI controls; no manual source
editing or hunting for generated files. At the milestone demo, you judge whether
the flow is usable. A clear error replaces an invalid action or stale result.

**Stop:** the agreed journey works. Additional dashboards, protocol editors and
visual redesign requests enter the backlog rather than expanding this milestone.

### G4 — Make review decisions and results durable and explainable

**Outcome:** a saved result can be understood and reproduced after the session.

- G4.1 Persist event judgments, boundary alternatives, reference choices and
  uncertain tissue decisions with source/run IDs, actor, reason and revision.
- G4.2 Reopen automatic and reviewed results without silently recomputing or
  replacing either. Existing files need an explicit compatibility/migration path.
- G4.3 Connect each measurement to units, source signal, spatial support,
  baseline, numerator/denominator, relevant settings and unavailable reasons.
- G4.4 Produce a compact readable export and structured provenance from the
  shared dictionary and saved calculation ingredients.

**Acceptance:** save–close–reopen preserves judgments exactly; a reviewer can
trace one event and one recording summary to saved ingredients and reproduce
them within declared tolerance. A changed setting or judgment produces a new
explainable revision while the previous result remains intact. Exported source
links remain usable after moving the result folder where relocation is supported.

**Stop:** this evidence is available for the agreed examples. No exhaustive
manual labeling or new physiological recovery estimator is required.

### G5 — Harden reliability, testing and compatibility

**Outcome:** predictable failure handling and a release candidate with evidence.

- G5.1 Test invalid/missing metadata, disconnected/missing source files, corrupt
  or incompatible results, zero-event recordings, missing baselines and both signs.
- G5.2 Define run lifecycle and partial-output rules. Prevent partial runs from
  looking complete; preserve recoverable evidence. Use safe cancellation between
  stages where feasible; mid-stage resume is a separate requirement if necessary.
- G5.3 Measure runtime and peak memory on approved fixtures. Define a documented
  support envelope and budgets based on evidence, not an invented speed target.
- G5.4 Reconcile MATLAB/toolbox/OS support with CI; run focused tests per change,
  integration checks at milestones and the approved release matrix at release.
- G5.5 Check result version compatibility, no-overwrite behavior, dependency
  licensing and absence of bundled private recordings or machine-specific paths.

**G3 acceptance handoff:** bound and check analysis- and statistics-stage
failures, incomplete-run recovery and relevant real-acquisition behavior in G5.
The G3 staging check and synthetic success do not establish those paths; each
G5 check needs its own fixture, run budget and approval before execution.

**Acceptance:** no known unresolved data-loss, source-mixup, silent calculation
corruption or approved-workflow blocking defect. Nonblocking limitations are
listed and accepted. Relevant automated checks pass; unsupported/untested
platforms are labeled honestly. A failed run has a clear status and next action.

**Stop:** agreed release checks pass. Do not rerun all historical experiments
or create performance optimization work without a measured release blocker.

### G6 — Deliver and demonstrate the software release

**Outcome:** a versioned MATLAB package that another researcher can use.

- G6.1 Provide installation/dependency instructions, a short quick start,
  example configuration and a concise measurement/review guide.
- G6.2 Package the required software, schemas and appropriately licensed small
  fixtures; keep bulky/private development evidence outside the release package.
- G6.3 Originally proposed an unfamiliar-researcher walkthrough and second-person
  numerical replay. Felix requested skipping that second user review on
  14 October 2026; its preparation is also skipped for the current plan. Retain
  the absence of unfamiliar-user feedback as an evidence limit.
- G6.4 Publish release notes, supported versions, known limitations and migration
  instructions. Prepare a version/tag/release candidate for your final approval.

**Acceptance:** fresh-install walkthrough succeeds, results/reviews reopen, and
the product owner accepts essential usability and scientific limitations with
the available calculation evidence. The skipped second
user review is not a pending task or a claimed pass. Publication/merge is
explicitly approved before action.

**Stop:** agreed release delivered; additional features belong to a subsequent
version. Completion does not require reanalyzing your full dataset.

## 6. Intended architecture and sequencing

Use the existing MATLAB implementation with clear responsibilities:

`GUI / batch entry points → application services → existing analysis engine`

`application services ↔ versioned recording / settings / result / review storage`

`results + shared measurement dictionary → inspection and export`

The GUI owns presentation and user intent; services own the run/review lifecycle;
the analysis engine owns scientific calculations; storage owns versioning and
durability. These are responsibilities, not a commitment to a class hierarchy,
new framework or renamed directory tree. Small refactors proceed with regression
evidence and existing-call compatibility.

Sequence: G0 → G1 → G2 → G3/G4 → G5 → G6. Testing and documentation accompany
every change; G5 is the release hardening pass, not the first time tests are written.
G3 and G4 may have independent parallel items after their shared contracts are
stable. Use one demonstrable end-to-end slice before broadening functionality.

## 7. Approval boundaries that prevent drift

| Team can decide within an approved milestone | Ask the researcher before proceeding |
|---|---|
| Function organization, naming, small refactors, error text and targeted tests that preserve behavior. | Detector/correction/baseline defaults, measurement meaning, source authority or other output-changing scientific rules. |
| Fix a reproducible UI/persistence problem and verify it against the approved task. | Adopt a scientific-output fix after reviewing its impact, even if it was discovered during engineering. |
| Reuse agreed fixtures for specified software checks within their budget. | Add an external dataset campaign, cohort rerun, scientific comparison or additional diagnostic program. |
| Choose implementation details for agreed MATLAB capabilities. | Add protocol inference, KX whisker/stimulation work, another platform or a major rewrite. |
| Prepare a reviewable patch, candidate release and migration proposal. | Publish/merge a release, perform destructive migration, or overwrite original data/results. |
| Complete remaining items inside the currently approved milestone. | Start a new milestone or materially increase scope/resources beyond its agreed envelope. |

**Continuation rule:** "go on" means continue the current approved software
work. It does not authorize a new analysis objective. At a boundary, present the
named next milestone and obtain approval specific to that scope. An explicit
"go on with G2 as proposed" is sufficient; formal paperwork is not required.
Do not repeatedly ask about routine engineering choices inside that agreement.

For a boundary-crossing proposal, provide: the user problem; proposed change;
affected code/results/scientific meaning; validation cases and resource budget;
what happens if deferred; and the precise approval needed. Prepare concrete
read-only evidence or a contained candidate patch where authorized, but do not
run the out-of-scope analysis while waiting. Silence is not consent.

Unresolved science goes into a parked decision register with its affected
capability. It blocks only that capability, unless there is a demonstrated
consequence elsewhere. A failed gate triggers a bounded fix, deferral or explicit
scope decision—not an automatically invented diagnostic phase.

## 8. Work-item and team cadence

Keep one prioritized backlog linked to this plan. Every item records:

| Field | Required content |
|---|---|
| ID / parent goal | For example SW-G2-01, not an unnamed next step. |
| User problem and expected behavior | Concrete before/after; one reviewable outcome. |
| Scope and exclusions | Affected components, scientific behavior held fixed, explicit non-goals. |
| Owner / reviewer | Who implements and who checks; disclose combined roles. |
| Dependencies / approval | Existing contract, prerequisite and approval status. |
| Validation and budget | Named fixtures/checks, tolerances, maximum full runs/time/storage, stopping condition. |
| Done evidence | Patch, demonstration, verification result, documentation and remaining limits. |

Use small reviewable changes, not a months-long rewrite branch. Preserve the
current uncommitted baseline before edits; choose branches/worktrees based on
that baseline so no existing work is accidentally dropped. Separate scientific
behavior changes from structural changes. Do not make automatic cleanup commits
or push existing work merely to obtain a tidy repository.

For an actual small team: short coordination around blockers during active work,
one working-software demonstration each week, and a milestone review at the gate.
For our interaction: report the current goal/item, what now works, what was
verified and what remains. Do not turn every internal check into a new numbered
project phase. Prefer one concise status record over repeated large narratives.

Each milestone is divided into slices small enough for a weekly demonstration;
if it cannot be demonstrated, split it before committing. Calendar estimates and
a release date follow G1, when team availability, dependencies and the actual
backlog are known. The first planning commitment is a bounded G1 deliverable,
not a speculative completion percentage or delivery date.

## 9. Universal definition of done

A software item is done when its agreed behavior works; the relevant checks
pass; scientific behavior is preserved or its change explicitly approved;
errors and missing states are understandable; original data/results and review
history survive; code has the required review; and user/developer documentation
matches the change. Record untested paths and remaining risks rather than
claiming blanket validation. Numerical checks and UI acceptance have distinct roles.

Do not add tests that merely restate implementation details or retest every
historical experiment. Favor meaningful contract, numerical-invariant,
save/reopen, GUI/batch consistency and failure-path checks. Large recorded movies
are limited integration fixtures; small deterministic examples belong in routine CI.

## 10. Immediate next decision

**G1 and the approved narrowed G2 slice are complete.** See the [G2 delivery
record](SOFTWARE_G2_WORKFLOW.md). The [G3 usability acceptance](SOFTWARE_G3_USABILITY_ACCEPTANCE.md)
records the researcher's decision on the demonstrated daily-use workflow:
saved-result selection, inspection and export; pre-run presentation; one small
synthetic end-to-end run with visible stages; native chooser and MATLAB workbook
launch on the saved G2 result; and one staging-only failure with accepted wording.
No G3 tests follow this decision. It is **usability acceptance with explicit
evidence limits**, not validation of a fresh real-acquisition run, analysis- or
statistics-stage failure behavior, incomplete-run recovery or release readiness.
Those checks are handed to bounded G5 release work, with separate approval and
budgets. No cohort analysis or scientific-method change is implied.

**G4 gate:** the researcher approved [SW-G4-01 through SW-G4-04](SOFTWARE_G4_PROPOSAL.md)
under named saved fixtures and a zero-run budget. The [two numerical replay
targets](SOFTWARE_G4_REPLAY_TARGETS.md) and C02 row 186 unavailable-amplitude
case were recorded before coding. The [bounded delivery](SOFTWARE_G4_DELIVERY.md)
links existing review revisions, reopens automatic/reviewed evidence without
recomputation, replays the two numbers from saved ingredients and exports a
readable/structured portable snapshot. The local BOI gate passed 134/134 with
zero new detector/statistics executions. The researcher accepted the specific
C02 review and the displayed ID400 measurement explanations and readable export
as usable. The **bounded named-example G4 usability gate is closed**; general
legacy migration, all-recording validation and all-metric reporting are not
claimed. This was assistant self-review, with no independent human code review.

**G5 first-slice result:** the researcher approved [SW-G5-01 through SW-G5-03](SOFTWARE_G5_PROPOSAL.md)
with two disposable synthetic failure attempts, at most one small synthetic
detector execution and zero recorded runs. The [pre-run fault contract](SOFTWARE_G5_FAULT_CONTRACT.md)
and [delivery](SOFTWARE_G5_FIRST_SLICE_DELIVERY.md) record both preserved
incomplete folders, visible stage/error/recovery messages, rejection as
completed runs, same-GUI new-output preflight and the local 135/135 BOI gate.
The analysis test double raised a MATLAB output-signature error instead of its
planned custom exception; it was **not rerun**. No engine defect is claimed.
The researcher accepted the **statistics boundary failure and saved incomplete-run
recovery** within their stated limits, and explicitly classified **live analysis
failure feedback as untested**. Generic internal-error guidance was then revised
and checked against the two preserved saved failures, with zero new attempts or
detector runs; the accepted staging source-missing wording was preserved.

**SW-G5-04 delivery:** the separately approved [single guarded attempt](SOFTWARE_G5_04_DELIVERY.md)
used a new disposable synthetic source and one-output shadow. It produced the
intended injected error, a **live** analysis-failure GUI capture and matching
`failed`/`analysis` status; the incomplete folder was rejected as complete.
No detector or recorded movie ran, and the two earlier attempts were unchanged.
This demonstrates a test-only delegate boundary, not an internal master error.
The researcher accepted this as **live analysis-boundary failure evidence only**. It does not test errors inside the real detector/master, complete G5 or approve release.

**SW-G5-05 delivery:** the researcher approved the [eight named saved/small-fixture cases](SOFTWARE_G5_05_FIXTURE_MATRIX.md)
with zero detector, statistics and recorded-movie runs. The [delivery](SOFTWARE_G5_05_DELIVERY.md)
reports pass/fail/untested for each. An unsupported run version was first offered
by discovery despite direct-open rejection; this was counted as a defect and
fixed before final acceptance checks. Focused tests passed 16/16 and the one
local BOI gate passed 136/136. The originals remain unchanged. The researcher
accepted this named software-contract evidence only; it is not G5 or release
acceptance.

**SW-G5-06 pre-Run guard stop:** the researcher approved the [exact real-acquisition card](SOFTWARE_G5_06_PRE_RUN_PROPOSAL.md)
for one named, supervised ID400 awake attempt. The [execution record](SOFTWARE_G5_06_EXECUTION.md) documents a safe stop during disposable MATLAB startup: a descendant left the isolated process group before Run release. No `ui.Run()`, detector, statistics or recorded movie executed, and no output folder was created. The researcher accepted this stop and untested classification. The researcher then approved [SW-G5-06R-01/02 isolation implementation and up to three synthetic process-tree checks](SOFTWARE_G5_06_ISOLATION_REVISION_PROPOSAL.md), followed by one separately approved startup-only MATLAB diagnostic. That one diagnostic is complete; any further MATLAB or recorded-movie run remains unapproved. The real-acquisition integration/resource check remains untested; there is no retry under the old approval. The [remaining G5 work](SOFTWARE_G5_NEXT_PROPOSAL.md), including SW-G5-07 support/release audit and any revised real-run attempt, requires a separate decision. Engine-internal failure paths, compatibility and release checks remain open. No G5 or release acceptance has been given.

The [SW-G5-06R delivery](SOFTWARE_G5_06R_DELIVERY.md) retains two initial passing synthetic checks and the failed initial reparenting check. An exit-time identity-classification bug was corrected and covered by saved-fixture tests. The researcher separately approved one reparenting-only synthetic recheck; it passed within 1.86 seconds with the unrelated sentinel preserved and no live tracked child. The researcher then approved [one startup-only MATLAB diagnostic](SOFTWARE_G5_06R_STARTUP_DIAGNOSTIC.md), with no Run or retry and cleanup inside its 90-second cap. That diagnostic identified and separately stopped an out-of-group `system_profiler` descendant under MATLABWindow. Its worker was not ready, and no recorded-movie run is authorized or validated. The researcher approved the [SW-G5-06R-03 decision card](SOFTWARE_G5_06R_03_DECISION_CARD.md) for implementation and seven saved-fixture cases (at most twelve evaluations), with no process launch. Its [bounded delivery](SOFTWARE_G5_06R_03_DELIVERY.md) records 12/12 saved-fixture passes for the tested policy, followed by two statically reviewed fail-closed guards that were not re-evaluated under that consumed budget. The researcher separately approved the [SW-G5-06R-04 offline decision card](SOFTWARE_G5_06R_04_OFFLINE_PROPOSAL.md) for six cases/eight saved-data evaluations. The [offline delivery](SOFTWARE_G5_06R_04_DELIVERY.md) records 8/8 passes on the final policy and a new controller decision path: startup and fresh final policy checks, one in-memory positive intent and no live release. The consumed one-use supervisor was not changed, and no live caller or recorded run is authorized. Any future live writer connection, startup diagnostic or recorded-run attempt requires a separate decision.

The researcher accepted SW-G5-06R-04 as **offline evidence only** and requested a one-shot intent fix before any live-writer decision. [SW-G5-06R-05](SOFTWARE_G5_06R_05_DELIVERY.md) passed its two named saved-data evaluations without retry: a second fresh call after success was rejected, and a sink exception after a simulated in-memory side effect left the shared claim consumed and blocked a recreated controller. There was no process/MATLAB launch or Run release. The researcher then approved the revised [SW-G5-06R-06 five-case filesystem card](SOFTWARE_G5_06R_06_LIVE_WRITER_PROPOSAL.md). Its [bounded delivery](SOFTWARE_G5_06R_06_DELIVERY.md) records **5/5 passes** for durable claim/token behavior, including separate preexisting claim, preexisting token and mismatched payload identity cases. These are disposable filesystem tokens with no waiting worker; no live Run occurred. A live caller, renewed SW-G5-06 attempt, SW-G5-07, G5 acceptance and release remain unapproved.

The researcher accepted SW-G5-06R-06 as **filesystem-only evidence**, not a live release, and approved the bounded [SW-G5-06R-07 startup-only card](SOFTWARE_G5_06R_07_STARTUP_ONLY_PROPOSAL.md): a new no-Run worker and versioned acknowledgement handshake, eight one-use offline schema cases, and one MATLAB startup only after clean static/offline gates. The [partial delivery](SOFTWARE_G5_06R_07_PARTIAL.md) records 8/8 saved-data schema passes, followed by two caller corrections from self-review. Because the final caller hash differs from the tested hash, the static final-code gate failed closed before MATLAB launch. The conditional startup and live acknowledgement remain untested; no proposed output was created. Any further offline re-evaluation needs a bounded decision. Actual Run-token integration and any named recorded-movie attempt remain separate decisions.

The researcher accepted that prelaunch stop and approved a final-code offline recheck only. The [recheck record](SOFTWARE_G5_06R_07_FINAL_CODE_OFFLINE_RECHECK.md) reports **10/10** one-use saved-data evaluations on pinned code hashes: the eight schema cases plus slow-sample and prompt-exit caller cases. The final-code static gate now passes. There was no child process or MATLAB launch, live token, attempt marker or proposed recording output. The unspent startup launch needs a separate decision; this offline result does not close live containment/acknowledgement, real-acquisition integration, SW-G5-07, G5 or release.

The researcher then **held that launch** after identifying that the final process snapshot was captured before a repeated preflight. The [SW-G5-06R-07B boundary revision and offline gate card](SOFTWARE_G5_06R_07B_PREFLIGHT_BOUNDARY_PROPOSAL.md) move final capture behind all potentially slow preflight work and reject a snapshot predating completed preflight. The earlier 10/10 matrix no longer matched the changed hashes, so the static gate initially failed closed. No MATLAB launch was made under this revision.

The researcher approved that one-use matrix under no-launch limits. The [SW-G5-06R-07B offline delivery](SOFTWARE_G5_06R_07B_OFFLINE_DELIVERY.md) records **13/13** saved-data passes on ten pinned executable/harness hashes, including stale-snapshot rejection after delayed preflight, a >1-second final monitor-gap stop, and one fresh-snapshot disposable token path. The updated static gate passed afterward without code drift. No child process, MATLAB session, live worker token or proposed recording output was created. The unspent startup launch remains held for a separate decision; there is still no live acknowledgement, recorded-movie integration, G5 acceptance or release approval.

The researcher accepted that **13/13 as evidence for its original hashes only** and kept the MATLAB launch held. [SW-G5-06R-07C](SOFTWARE_G5_06R_07C_TOKEN_DEADLINE_DELIVERY.md) moved the absolute 65-second token deadline into the startup writer and passed one pinned, one-use saved-data check: a final snapshot at 64.8 s followed by a writer call at 65.05 s left one consumed claim and **zero tokens**. The revised code hashes matched before and after that check, but differ from the 13-case hashes. The live 13-case static gate therefore fails closed; the new one-case result is narrow deadline evidence, not a revised 13-case pass or startup authorization. No process/MATLAB launch, live token or recording output occurred. The held startup, live acknowledgement, recorded-movie integration, G5 acceptance and release remain open.

The [SW-G5-06R-07D final-code offline gate card](SOFTWARE_G5_06R_07D_FINAL_CODE_OFFLINE_GATE_PROPOSAL.md) specified the prior 13 cases plus the late-token case once each, at most 14 saved-data evaluations and zero process/MATLAB launches. It required deadline-enabled writer configuration on every token-producing path and exact final executable/harness hashes pinned before testing. A token whose filesystem publication finishes at or after 65 seconds is classified incomplete; a pre-write check does not establish completion time.

The researcher approved that exact offline budget. The [SW-G5-06R-07D delivery](SOFTWARE_G5_06R_07D_FINAL_CODE_OFFLINE_DELIVERY.md) records **14/14 one-use saved-data passes** on 13 pinned executable/harness hashes, with identical pre/post hashes and a passing read-only live static gate. All token-producing fixtures exercised the deadline-enabled writer. The late writer case left one consumed claim and zero tokens; the caller's post-return late-completion rule classified an otherwise valid acknowledgement as incomplete. No process or MATLAB launched, no live worker token or proposed recording output was created, and no case in the matrix was left untested. A slow filesystem publication spanning the deadline and live MATLAB acknowledgement remain untested. The startup stays held; passing this gate is not launch, G5 or release approval.

The researcher then separately approved **one startup-only MATLAB launch** under SW-G5-06R-07. The [saved attempt](SOFTWARE_G5_06R_07_STARTUP_ATTEMPT.md) stopped incomplete at 17.15 seconds when a `(java_home)` child appeared in the new MATLAB group but could not be assigned a precise birth identity. No ready receipt, claim, token, acknowledgement, Run call or proposed output was created. The stop report recorded two clean snapshots and no remaining verified PIDs, yet classified cleanup as `containment_failure` because the group had an unverified member; a later read-only process snapshot found no live group or that PID. The single launch is consumed with no retry. Live acknowledgement, a clean containment classification, real-acquisition integration, SW-G5-07, G5 acceptance and release remain open; any further launch needs a new bounded decision.

The researcher accepts the 17.15-second attempt as **fail-closed and incomplete**, retaining its formal `containment_failure` and consumed approval. The [SW-G5-06R-08 saved-data proposal](SOFTWARE_G5_06R_08_UNIDENTIFIABLE_CHILD_PROPOSAL.md) specifies structured libproc versus session-ID diagnostics and ten one-use offline cases for disappearance, persistence, identity change, escape and insufficient observations. It adds no name-based exception or successful release path: ownership uncertainty still fails closed. This is **planning only**; no implementation, tests or launch are authorized. A new approval is required before the proposed slice, and any future live attempt remains a separate decision.

The researcher then approved **SW-G5-06R-08 implementation and ten one-use saved-data evaluations**, requiring incomplete libproc responses to provide no verified birth identity. The [delivery](SOFTWARE_G5_06R_08_DELIVERY.md) records **10/10 passes**, no retries, five pinned code/dependency/harness/fixture files and eight historical packet files unchanged through the final hash gate. Structured libproc versus SID diagnosis, fresh-table classifications and guard rejection paths were exercised through injected adapters only; no native lookup, signal, child/MATLAB launch, token or recording run occurred. The historical `containment_failure` remains unchanged. Native adapter and full cleanup-loop behavior are untested, and prior release gates do not validate these changed guard hashes. The offline budget is consumed; researcher acceptance is pending, with no further live work proposed or authorized.

The researcher **accepted SW-G5-06R-08 as bounded offline diagnostic evidence only**. The historical `containment_failure` and exhausted startup approval remain unchanged; startup, G5 and release are not complete. The [planning decision](SOFTWARE_G5_REAL_ACQUISITION_GATE_DECISION.md) recommends deferring the real-acquisition gate as an explicit release blocker rather than automatically continuing diagnostics. The alternative is a separately approved independent containment review before considering further implementation or a live-attempt proposal. This choice is pending; no reviewer engagement, implementation, checks, launch or automatic retry is authorized.

The researcher **chose to defer the real-acquisition gate**. Successful live acknowledgement, verified containment and real-acquisition resource measurements are now separately recorded as **open release blockers**; integration also remains unverified. Historical `containment_failure` and consumed launch approval remain unchanged. No further containment diagnostics, MATLAB startup or retry is authorized. The [SW-G5-07 audit proposal](SOFTWARE_G5_07_AUDIT_PROPOSAL.md) defines one local inventory and six static assessments, with documentation-only outputs and no execution or repairs. Its approval is pending; this deferral does not approve the audit, complete G5 or approve release.

The researcher approved **SW-G5-07: one local inventory and six named static assessments**, limited to audit/manifests and factual planning updates. The [completed audit](SOFTWARE_G5_07_AUDIT.md) pins 561 text inputs, records no input drift, and reports A/C/E as failures (stale status/build metadata and package dependency/shareability issues), B/D as untested evidence gaps (hosted platform execution and licensing/provenance), and F as a static reconciliation pass only. No tests, MATLAB, network, excluded payload reads, containment diagnostics, code repair or packaging occurred. Project licence approval and the incomplete legacy package dependency list remain release blockers in addition to the three deferred live/resource gates. Audit delivery is not G5/release acceptance; bounded follow-up proposals await the researcher’s choice.

The researcher **accepted SW-G5-07 as a bounded static audit** and requested F07-03 planning first. The [package-closure proposal](SOFTWARE_F07_03_PACKAGE_CLOSURE_PROPOSAL.md) names sixteen missing root files, retained roots, 337 helper files and three external helpers in an exact source manifest, with explicit recording/result/development exclusions and ten proposed one-use offline manifest cases. No repair, evaluation or package build has been authorized. Licensing, hosted CI and all three deferred live/resource blockers stay open; no G5/release acceptance or containment retry is implied.

The researcher approved the **F07-03 bounded source-list repair and ten one-use offline manifest cases**. The [delivery](SOFTWARE_F07_03_PACKAGE_CLOSURE_DELIVERY.md) records **10/10 passes** and 407 unchanged final hashes. The revised packager and offline harness consume the same explicit JSON policy; static checks place required-file/hash validation before directory creation and restrict copying to the validated list. The Python policy interpreter does not execute or prove equivalence with MATLAB. No package folder, copied source, ZIP or MATLAB launch occurred. Twelve retained assets remain unverified; actual package/runtime integration, licensing, hosted CI and the three deferred live/resource blockers stay open. The budget is consumed, researcher acceptance is pending, and no further check/build or G5/release acceptance is implied.

The researcher requested **one bounded F07-03 integration proposal with routine repairs included**, replacing per-error approval requests. [F07-03I](SOFTWARE_F07_03_INTEGRATION_PROPOSAL.md) proposes a disposable actual package build, folder/ZIP inspection and extracted-package MATLAB resolution, with up to four build iterations/twelve validation batches and clearly defined material blockers. After a single scope approval, ordinary packaging corrections and repeat checks would proceed autonomously. This remains planning only; no package build or MATLAB launch is authorized yet. Scientific source, prior outputs, licensing/CI and the deferred real-acquisition gates remain protected.

The current status and approval record live in
[software-development-status.json](planning/software-development-status.json).

F07-03I is now approved as one bounded integration-and-repair slice: four builds, twelve validation batches and two packaging-only MATLAB starts maximum. Routine packaging fixes proceed within that scope. No scientific execution, publication, licensing decision or reopening of deferred live gates is authorized. Evidence is recorded in `reference-validation/f07-03-integration-local/`.

[F07-03I delivery](SOFTWARE_F07_03_INTEGRATION_DELIVERY.md): the actual local MATLAB build, 414-file folder/ZIP/extract integrity, 26 extracted-package resolutions/no parse errors and two pre-directory negative checks passed. Usage was one build, three validation batches and one ordinary packaging-only MATLAB start; normal exit and source preservation verified. This is self-reviewed named-route packaging evidence, accepted by the researcher within the delivery-report limits on 29 September 2026. Full dynamic/optional/legacy runtime closure, licensing, hosted CI and all deferred live/resource gates remain open; no G5/release completion or further run is authorized.

On 29 September 2026, the researcher **accepted F07-03I as a bounded local package candidate with the limitations in the delivery report**. This closes candidate acceptance only. G5 and release remain incomplete; licensing, hosted CI, broader runtime verification and all three deferred live/resource blockers remain open. Historical `containment_failure` and consumed launch approvals are unchanged. This acceptance authorizes documentation updates only, not another test, diagnostic phase or MATLAB launch. No further execution is active or authorized under this acceptance.

The researcher **paused release work** and requested one calculation-correctness decision using existing evidence. [CC-01](SOFTWARE_CALCULATION_CORRECTNESS_DECISION.md) recommends retaining existing formulas while reporting normalized detector contrast separately from preserved-input optical change, with automatic and exploratory reviewed results distinct. Its expected scientific-output change is zero; eight named saved-evidence cases and at most ten evaluations are proposed for separate approval. This is planning only: no code/output change, numerical validation, MATLAB launch or recording rerun occurred. G5/release stay incomplete, F07-03I acceptance and all open blockers are preserved, and no release or containment work is resumed.

At the researcher’s request, [CC-01 revision 2](SOFTWARE_CALCULATION_CORRECTNESS_DECISION.md) **supersedes the reporting-only recommendation and its eight-case reporting-validation proposal**. It distinguishes arithmetic consistency from scientific target validity and compares normalized contrast labels, raw local-change labels and corrected local-excursion labels; automatic versus exact reviewed references; and raw versus corrected-numerator amplitudes. The recommendation is to evaluate local corrected direction and a corrected excursion scaled by the positive preserved-input reference mean, preserving automatic and reviewed original results. This is a proposed new derived quantity, not scientific adoption or a claim that correction isolates biology. Known numeric consequences and unquantified candidate changes are explicit; a finite saved-evidence numerical comparison is proposed but unapproved. Only documents changed. Release remains paused, scientific-output changes and recording runs remain unauthorized, and all open G5/release blockers remain.


The researcher approved **CC-01 revision 2's bounded saved-evidence comparison**, including a concise Science/STAR/paper-linked-code/current-V2 comparison. The [delivery](SOFTWARE_CC_01_COMPARISON_REPORT.md) records 18 cases and 19 evaluations (one bounded import repair/recheck), ten computable real A2 combinations, four preserved unavailable real combinations and four synthetic recipes whose A1 replay passed but whose A2 remains untested for missing saved correction. The 26 pinned inputs remained unchanged. Earlier and final harness hashes are distinguished; no claim is made that all cases ran on the final harness. No new correction fit, MATLAB, detector, statistics engine or recording ran. Current labels and amplitudes are preserved. The report corrects the earlier interpretation of `detrend_custom(...,2)`: it selects the trace dimension and uses a fifth-degree fit. Arithmetic replay is demonstrated within scope; physiological validity and scientific adoption remain open. Delivery awaits the researcher's decision, with no further active execution. Release work stays paused and all blockers/consumed launch approvals remain unchanged.

The researcher accepted CC-01 **as a bounded arithmetic/numerical comparison only** and requested a concise [three-event scientific decision view](SOFTWARE_CC_01_SCIENTIFIC_DECISION_VIEW.md) from saved evidence. The view shows preserved-input and saved-correction traces, exact references, measurement windows, native detection bounds and both extrema for historical ID400, FB2312 and C02 row 321. It identifies the choices about direction, mixed windows, primary magnitude and reference authority without adopting a rule. The three pinned audit hashes and CC-01 extrema were checked; no original data/output was changed, no source movie or MATLAB was opened, and no detector/statistics/recording run occurred. Scientific adoption remains pending; release stays paused.

On 30 September 2026, the researcher identified a sink/pocket in the green phase of all three examples, placed FB2312's sink onset at approximately frame 398, and described C02's lilac phase as a possible preceding surge. The decision view records these qualitative judgments and the researcher's hypothesis that hyperemia-associated surges are broader while capillary-obstruction-associated pockets are local. The current FB2312 reference includes the identified decline, and C02's reviewed reference may include a positive event; replacement boundaries, references, amplitudes and any spatial classification rule remain undecided. No production label/calculation, saved evidence or plot was changed; no new numerical evaluation or recording run occurred.


The researcher requested scientific-rule framing from those judgments, with no adoption or run. On 30 September 2026 the [decision view](SOFTWARE_CC_01_SCIENTIFIC_DECISION_VIEW.md#proposed-scientific-rule-framed-by-these-judgments) was expanded to distinguish a pocket episode's decline/recovery from a separate positive event, identify reference contamination independently of recognition, and treat spatial extent as supporting evidence only. Possible broader hyperemia/local pockets remains a hypothesis. This was documentation-only: no new numerical evaluation, replacement reference, amplitude, label, spatial rule or recording execution. The next decision concerns episode/reference semantics; implementation remains inactive and release paused.

On 30 September 2026 the researcher agreed (“i agree”) to those episode and reference semantics as the interpretive foundation. The remaining decision is how to operationalize the accepted meaning with explicit boundaries, reference authority and numerical criteria. Agreement does not authorize replacement samples, amplitudes, labels, code or further evaluations/runs. Acceptance was recorded in the decision view and status; release remains paused.


On 30 September 2026 the researcher requested one concrete recommendation for the same three saved examples and clarified that references may contain normal fluctuations. The [combined review card](SOFTWARE_CC_01_SCIENTIFIC_DECISION_VIEW.md#concrete-three-example-recommendation-30-september-2026) proposes ID400 W82–98/R73–81, FB2312 W398–417/R378–397 (end unresolved), and C02 W177–195/R165–170 (six-frame reference provisional). It recommends comparing signed corrected trough excursion scaled by the positive raw reference mean. Original measurements and detector labels remain visible; no candidate-reference amplitude was calculated or adopted. Saved fixed footprints/eligible support were presented with physical-scale and phase-extent limitations. Source-matched audit/metadata hashes were retained and unchanged; no source movie, MATLAB, correction fitting or detector/statistics execution occurred. The three candidates await scientific review together. Release stays paused.


The researcher approved **CC-01-3E: one saved-evidence comparison of the exact three proposed episode/reference pairs**, including routine arithmetic verification. Scope is three named pairs only; identical raw/corrected frames and unchanged fixed footprints, existing results alongside the new comparison, conditional C02 reference and unresolved FB2312 recovery. Owner: assistant; scientific reviewer: researcher. Acceptance requires source/harness hash gates, scalar arithmetic agreement, preserved sign/footprint origin, missing automatic C02 result and explicit limitations. Stop on missing/mismatched saved ingredients; no alternate reference, correction fitting, footprint redefinition, production change, MATLAB or recording execution is authorized. Evidence is under `reference-validation/cc-01-three-pair-comparison-20260930/`; final code and six saved inputs were pinned before calculation.


[CC-01-3E delivery](SOFTWARE_CC_01_SCIENTIFIC_DECISION_VIEW.md#approved-three-pair-numerical-comparison-30-september-2026) completed all three named pairs with source/hash and scalar/decomposition/old-trough checks passing. Raw/corrected signed troughs are ID400 −4.3287/−5.0523%, FB2312 −8.1385/−8.3626%, C02 −11.1049/−12.3838% (conditional). Current automatic/reviewed amplitudes and signs are retained; FB2312/C02 remain measured on saved surge footprints and FB2312's recovery endpoint is unresolved. Six input hashes/final harness matched. Zero production changes, correction refits, footprint changes, MATLAB/detector/statistics or recording executions. Routine arithmetic is verified, not physiological validity. The comparison awaits one scientific decision; no active implementation or further numerical work is authorized. Release remains paused.


The researcher **accepted CC-01-3E within its limits** and selected corrected signed trough (% of positive raw reference intensity) as the primary exploratory measure for researcher-reviewed pockets, with raw signed trough alongside. C02's conditional reference, FB2312's unresolved recovery and all saved-footprint qualifications are retained. This is a reviewed-measure semantic selection, not an implemented production change or automatic scientific relabelling. [CC-02-01 through CC-02-05](SOFTWARE_CC_02_REVIEWED_POCKET_IMPLEMENTATION_PROPOSAL.md) propose one bounded review/calculation/save/reopen/export integration, exact frames/status/provenance, three primary fixtures and legacy/negative fixtures (14 cases, at most 20 evaluations/four batches/two saved-data MATLAB starts; four implementation hours). Routine repairs would be included after one scope approval. Planning only: no code, checks, new calculations or launches have begun. Release remains paused and automatic measurements/prior outputs are preserved.


On 30 September 2026 the researcher approved **CC-02-01 through CC-02-05 as one complete bounded integration slice**, including routine repairs, under the proposal's four-hour/20-evaluation/four-batch/two-saved-data-MATLAB-session/500 MiB limits. Implementation is active only for this reviewed-measure workflow. Automatic/legacy outputs, conditional reference, unresolved recovery and footprint qualifications remain protected. Zero recording runs, refits, footprint changes or automatic relabelling. Release remains paused.


**CC-02 partial delivery, validation limit reached (30 September 2026).** The [partial report](SOFTWARE_CC_02_INTEGRATION_PARTIAL_DELIVERY.md) records the implemented candidate and retained failures. Four batches used; 17/20 evaluation attempts, two MATLAB starts, already-open desktop reused without launch. ID400's corrected/raw preview matches accepted numbers; Save failed because an anonymous getter captured its initial value. The nested getter repair is untested after the batch ceiling. T05 passed save/load/replay on earlier hashes; other named round trips/guard assertions remain failed or untested as specified. All 44 preservation inputs are unchanged; zero recording/engine/refit/footprint/relabel runs. **CC-02 is incomplete**, no active execution remains, and no further checks or sessions are authorized by this delivery. A separately bounded continuation of the same integration is required before claiming a working accepted workflow. Release remains paused and all deferred blockers/consumed containment approvals stay unchanged.


**CC-02 completion extension approved (30 September 2026).** The researcher authorizes the existing CC-02-01–05 scope, routine repairs and validation: up to 28 additional case evaluations, two saved-data-only MATLAB starts, four active implementation hours and 500 MiB new disposable evidence. Batch counts are recorded with **no separate batch ceiling**. Dispatch, cached-code handling and prerequisite paths must be corrected; dependent checks stop on a failed prerequisite until it is repaired. Completion requires all 14 existing named cases passing on unchanged final code and ID400/FB2312/C02 preview → save → reopen → export demonstrations with exact values and all qualifications. Original sources/automatic/legacy outputs remain protected; zero recording/engine/refit/footprint/relabel/release activity. The historical partial packet is preserved. Owner: assistant; no independent reviewer or usability acceptance is presumed. Stop on scope/source mismatch or exhaustion and report unfinished work.


**CC-02 completion extension delivered (30 September 2026).** The [delivery report](SOFTWARE_CC_02_COMPLETION_DELIVERY.md) records all **14/14 named cases passing on unchanged final code**, including the three complete reviewed-quantity journeys and exact values/frame/flag/footprint preservation. Used 28/28 additional evaluations, two recorded batches (no ceiling), one of two saved-data MATLAB starts, under four hours and 500 MiB. The worker exited 0; final C02 saved review is visible in the existing desktop. All 527 final code/contract/harness pins, 47 extension inputs and 44 historical preservation inputs match. Earlier partial failures and first-matrix hashes remain historical. Main corrected traces are visible and sample-checked; standalone portable small-window screenshots still show plot/text overlap, documented as a presentation limitation. Manual native chooser use and independent review were not claimed. The bounded numerical/integration completion gate is met; **researcher usability acceptance remains pending**. No further test/diagnostic phase is active, and no numerical evaluations remain under this extension. Zero engine/recording/refit/footprint/relabel/release activity. Release remains paused, with all G5 blockers, historical containment_failure and consumed approvals unchanged.


**CC-02 bounded acceptance recorded (30 September 2026).** The researcher accepted the [bounded numerical/integration delivery](SOFTWARE_CC_02_COMPLETION_DELIVERY.md#researcher-acceptance--30-september-2026) and demonstrated main-window workflow only. C02 remains conditional, FB2312’s recovery remains unresolved, and all saved-footprint qualifications are retained. **Native chooser interaction and standalone viewer layout remain open usability items; overall usability, G5 and release remain unaccepted.** This documentation-only acceptance starts no further checks, launches or implementation. Historical partial/delivery packets, numerical outputs, formal `containment_failure`, consumed approvals and deferred live/resource release blockers are unchanged. No active execution milestone remains; release work stays paused pending separate direction.


**CC-02U usability-completion proposal prepared (30 September 2026), approval pending.** The [decision card](SOFTWARE_CC_02_USABILITY_COMPLETION_PROPOSAL.md) covers standalone viewer layout at 1120 × 800 and 900 × 650 and a researcher native-folder save/reopen/export walkthrough including cancellation. Six named focused checks reuse ID400/FB2312/C02 saved evidence; at most twelve evaluations including routine UI repairs/rechecks, two active hours, one saved-data-only MATLAB session and 100 MiB new evidence. Only one unchanged ID400 preview is proposed to reach the existing Save control; no arithmetic rule or original output changes. Exact stored values, C02 conditional reference, FB2312 unresolved recovery and all footprint qualifications remain protected. The full numerical matrix is not repeated by default; an affected scientific/persistence dependency is a material blocker, not permission for broader testing. Planning only: no implementation, checks or launches begun. Overall usability, G5 and release remain unaccepted, release paused, and all historical containment/consumed approval records unchanged.


**CC-02U approved (30 September 2026).** One complete bounded presentation/native-chooser slice with routine UI repairs: two active hours, one saved-data-only MATLAB session, six focused checks/twelve evaluations and 100 MiB evidence. One unchanged ID400 preview is authorized. Native interactions will be researcher-performed one step at a time. Preserve all scientific values/references/qualifications and original outputs; zero calculation changes, recording runs, refits, footprint changes or release work. Delivery and usability acceptance remain pending.


**CC-02U native walkthrough handoff (30 September 2026).** Presentation-only repairs use explicit standalone panel rectangles and visible-value/qualification summaries, scrollable provenance, a complete visible-trace y range, native chooser wording and visible saved/export path details. Cases 01/02 pass assistant structural/native inspection on all three saved examples at both sizes; immediate small exportapp captures retain padded larger canvases, documented separately. Seven evaluations used (retained failures/superseded presentation versions included); one existing MATLAB desktop designated, zero starts. One authorized unchanged ID400 preview has exact scientific-field equality and is ready for researcher Save → Cancel; cases 03–06 remain pending. All 71 protected inputs and 528 final code/harness pins match at handoff. Active work clock is stopped while waiting for researcher input; this is continuation of the same approved slice, not delivery or usability acceptance. No scientific/recording/refit/footprint/release work occurred.


**CC-02U bounded delivery (1 October 2026).** The [delivery report](SOFTWARE_CC_02_USABILITY_COMPLETION_DELIVERY.md) records 6/6 final focused passes using 12/12 evaluations, including retained layout/harness failures, a wrong-window foreign-review rejection and saved-window restoration in the same MATLAB desktop. Normal 1120 × 800 and smaller 900 × 650 layouts were inspected for all three saved examples; native save/reopen/main-export/standalone-export interactions and cancellation were researcher-performed. All 71 protected inputs and 528 final code/harness pins match. One unchanged ID400 preview, one existing saved-data MATLAB session, zero starts or recording/engine/refit/footprint/relabel/release activity; under two active hours and 100 MiB. C02 remains conditional, FB2312 recovery unresolved and all saved-footprint qualifications unchanged. Small exportapp canvas padding remains a capture limitation. Assistant self-review only; finished C02 standalone viewer presented at smaller size for researcher assessment. **Usability acceptance is pending; overall usability, G5 and release remain unaccepted.** The evaluation budget is consumed; no further checks or launches start under this delivery. Historical containment_failure and consumed launch approvals remain unchanged; release stays paused.


**CC-02U bounded usability acceptance recorded (1 October 2026).** The researcher accepted the [finished workflow](SOFTWARE_CC_02_USABILITY_COMPLETION_DELIVERY.md#researcher-acceptance--1-october-2026) at **1120 × 800 and 900 × 650**, including the demonstrated native selections and cancellations. **Standalone viewer layout and native chooser interaction are closed within that scope.** C02 remains conditional, FB2312 recovery remains unresolved, and all footprint qualifications and documented limitations are retained. This is documentation-only acceptance: no further checks, launches or implementation. Overall usability beyond this bounded workflow, G5 and release remain unaccepted; release work remains paused. Historical packets, `containment_failure`, consumed approvals and deferred release blockers are unchanged. No next execution phase is active or automatically proposed.


**Development and release pause confirmed (1 October 2026).** CC-02 is closed within its accepted scope. The researcher will provide the next requirement after using the workflow. Development and release work remain paused; no subsequent validation phase is to be prepared automatically. No further planning, implementation, checks or launches are active or authorized. All scientific qualifications, documented limitations, historical evidence and G5/release non-acceptance remain unchanged.

**Researcher priority and communication clarified (1 October 2026).** The
immediate goal is correct analysis calculations and understandable scientific
outputs. Detection refinement is a separate future priority. Scientist-facing
documentation and progress reports should explain the working feature,
calculation, reference, units and uncertainty in plain language. Internal work
codes remain in development records. README and the short measurement guide
are revised for this purpose; the previous README is preserved in
`DEVELOPMENT_NOTES.md`. This is a documentation-only clarification and GitHub
update. Existing calculation rules, saved outputs and acceptance limits remain
unchanged; no new validation campaign or recording execution is authorized.

## Step-1 completion — 4 October 2026

Accepted exports and planning are saved with development identity `3.1.0-dev.1`;
see [source identity and static checks](SOFTWARE_NEXT_01_DELIVERY.md). The
authorization above is consumed by this bounded delivery. The delivery-record
commit is followed only by the approved normal branch push and remote-tip
verification, whose outcome is reported in the final handoff. Development and
release then stop. No step-2 work or additional checks are authorized.
