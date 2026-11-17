# BOI reanalysis current status

10 September 2026. This concise record tracks the current R0/R5 start; it does
not replace the [plan](REANALYSIS_UPDATE_PLAN.md),
[cohort resolution](BOI_COHORT_RESOLUTION.md), original manifests or earlier
experiments. BOI-only scope, biological variability, physiological relevance,
feasibility, researcher usability and traceability remain standing requirements.

| Work package | Current evidence | Still open |
|---|---|---|
| R0 | [Draft versioned measurement dictionary](BOI_MEASUREMENT_DICTIONARY.md); shared MATLAB/JSON/readable exports | Scientific outcome hierarchy and primary admission remain proposed. |
| R1 | Source/acquisition issue resolution preserved; representative source checks and explicit unknowns | Exposure, intensity preparation, tissue validity, acquisition support and measurement-specific eligibility. |
| R2 | Current rules audited; saved-support and fixed baseline/timing challenges complete; [policy proposal](BOI_MEASUREMENT_POLICY_PROPOSAL.md) ready | Scientific reference/missingness decisions, onset admission and physiological recovery. Completed challenges do not authorize another method experiment. |
| R3 | [Existing prior-use audit](BOI_PRIOR_USE_AUDIT.md) complete: five analytically used BOI animals, separate fluorescence control, identity-pending HP development case, and source-inspection histories | Reconcile external/unrecorded use; freeze animal roles, strata, acceptance criteria and resource budgets before new evaluation outcomes. |
| R4 | Dictionary and C02 worked policy proposal distinguish measurement support, paired mice and conditional availability | Scientific adoption of contrast/weighting, valid intervals, repeated sessions, missingness, inference and multiplicity. |
| R5 | Full MATLAB workflow and connected review implementation developer-verified; [researcher handoff](BOI_RESEARCHER_WALKTHROUGH.md) prepared | Independent researcher walkthrough and second-person replay on eligible input; scientific assessment of local transfer. |
| R6 | No final freeze or cohort rerun authorized by an eligibility assumption | Dependent scientific, usability and provenance gates. |

Decision R5-WALK-001 is a development-only statistics-window change: run A
[0,600) seconds versus run B [30,600) seconds on the same automatic detections.
It is neither an experimental baseline decision nor a scientific method change.
The runner records actual execution, arithmetic checks, hashes, failures and
resource observations. Successful arithmetic alone does not close R1–R4.

Existing uncommitted README/notices, ABF import fix, planning documents and
resolution/evidence overlays were preserved. The first dictionary adds no
threshold change, empirical exclusion, new physiological claim or scientific
acceptance criterion.

## Executed development walkthrough

[ID400 full-recording evidence](reference-results/boi-workflow-20260910/README.md):
master plus two statistics runs completed in 169.75 seconds inside MATLAB.
Saved CSV ingredients reproduced occupancy, baseline, amplitude and signed
integral. Run A remained unchanged; both runs retained identical event tables.
Amplitude availability was 102/196 sinks and 28/50 surges. All are descriptive
development observations, not biological acceptance results.

Visual review found a mismatch between the displayed image frame and native
mask frame in the initial example panel. The renderer was corrected to show
both at native frame 436; original evidence was retained. Dictionary export was
also restricted explicitly to the BOI statistics branch. Neither change alters
detection or quantitative measurements. Final checks are recorded below.

Final verification passed: `runExistingAnalysisIntegration` (known events, a
successful zero-event recording, both-sign export schema, and shared dictionary
workbook/JSON/readable guide) using two MATLAB workers; same-frame image/mask
assertion passed for the actual selected event. No full detector rerun was needed
for the presentation/export-only corrections. The [correction record](reference-results/boi-workflow-20260910/presentation-correction.json)
retains final source hashes, reason and before/after figure hashes.

## R1 input/QC implementation

The [recording input and denominator contract](BOI_RECORDING_INPUT_CONTRACT.md)
is implemented as `boi-recording-input-1`, with `boi-window-exposure-1` for the
additive window audit and dictionary `0.2.0-draft`. Researchers can run
`reviewBOIRecordingInput` before the BOI master. New master outputs snapshot
optional source-bound acquisition declarations; compatible older masters
explicitly retain `not_recorded_at_master` unknowns.

Normal BOI statistics exports now include original acquisition declarations,
source and tissue support, per-frame timing/exposure, readable/actionable input
QC, covered area-time and analyzed tissue-time ingredients. Input review issues
are visible in the existing acceptance table. Measured camera exposure is never
inferred from the frame interval. Unknown declared frame validity is NaN/null,
separate from the model's inclusion of a frame.

Acquisition-start events remain in the existing descriptive onset rule and are
reported separately. No new biological censoring or event-exclusion policy is
adopted. Static tissue and uniform timing remain scientific assumptions. Declared
irregular timing or excluded frames require assessment before this uniform-time
pipeline runs; no implicit resampling or deletion is performed.

Verification uses partial-frame/overlap/boundary fixtures, unknown and invalid
metadata, missing/zero tissue, a successful zero-event recording, captured-source
mutation checks and a fresh ID400 statistics export. The full biological master
is reused unchanged; this remains development data. Detailed execution evidence
is in [the R1 verification record](reference-results/boi-input-contract-20260910/README.md).
The record preserves a comparator correction and the subsequent separation of
unknown validity from modeled inclusion. Scientific acceptance and all cohort
holds remain open.

## Additional HP local source check (initial timing interpretation superseded below)

The user-supplied [HP compartment review](BOI_HP_LOCAL_INPUT_REVIEW.md) locates
20 CSV rows, separate from the older U12 search entries. Six GFAP-GeNL mouse
IDs and source basenames match archive baseline entries. Fourteen CSV mouse
IDs are absent from the current archive ledger, with identity conflicts retained.
The earlier TIFF candidates under FB2416 and FB2417 are byte-identical; they
cannot be counted as independent source recordings without reconciliation.

Decision R1-HP-INPUT-001 assigns FB2412 to a development input check before
outcome inspection. A checksum-bound staged copy passes MATLAB file import,
but the current temporal pipeline correctly holds its declared nonuniform
source clock. Exposure settings are recovered as 960 ms; clock semantics,
identity, calibration, intensity history and valid tissue/time remain open.
The [preflight evidence](reference-results/boi-hp-input-20260910/README.md)
records unchanged timestamps, explicit unknowns and the master's acquisition
guard. No detector, biological comparison or prior-outcome inspection was run.
Next: reconcile acquisition/identity evidence and decide supported timing
before the local full-workflow transfer run. Other scientific holds and the
standing BOI, variability, relevance, feasibility, usability and traceability
requirements are unchanged.

## Confirmed HP timing and completed development transfer

The user confirmed that HP recordings are precisely **1 Hz under external
triggering** and that embedded file timestamps are incorrect. Decision
[R1-HP-CLOCK-002](planning/boi-hp-clock-correction-20260910.json) supersedes the
earlier timestamp interpretation above. That original preflight remains intact.
Confirmed uniform sampling now drives analysis; unreliable source clock values
remain separate provenance. No timing tolerance was relaxed and no measured
absolute frame times were invented.

The [complete local workflow](reference-results/boi-hp-workflow-20260910/README.md)
ran the full 1,200-frame selected ECS recording with current defaults and both
signs: one master, two diagnostic statistics exports, independent source-pixel
audit and CSV calculation replay. It used two workers and completed in 245.91 s
including MATLAB/pool startup and shutdown. Both statistics runs retain identical
event tables and the first output is unchanged. All 249 event measurements
matched independent recalculation; amplitude availability was 75/168 sinks and
20/81 surges. One negative baseline-relative surge amplitude remains flagged,
not removed. Targeted MATLAB checks passed (42 tests).

The additive `source-clock-and-source-review-1` input extension retains
confirmed-sampling evidence, unreliable source clocks and structured source
issues in preflight, saved contracts and normal statistics QC. The run uses a
provisional recording identity and Unknown biological fields; unresolved identity,
calibration and label questions remain explicit. Both earlier and denoised source
TIFFs under FB2416/FB2417 are now established as respectively byte-identical.

This completes a technical local development workflow, not independent
biological evaluation, scientific eligibility or the researcher GUI release
gate. Next: review the flagged direction/large trace changes under R2, reconcile
remaining source identity/calibration/labels, and complete a researcher-guided
inspection using the saved calculation examples. No additional cohort batch or
detector tuning is implied by this successful technical run.

## Completed HP event/source review

[R2-HP-REVIEW-003](reference-results/boi-hp-event-review-20260910/README.md)
reconstructed the flagged surge and reviewed the whole source recording. The
negative amplitude is numerically correct; the sign disagreement first appears
after frame-wise normalization. The event footprint is in low-intensity
peripheral image support, yet 80.4% lies inside the saved surge tissue mask.
The current mask therefore cannot serve as anatomical validation for this case.

Retain event identities and values, but do not interpret this candidate as a
source-intensity/oxygen increase. Anatomical/observable tissue support must be
addressed before biological occupancy or area-normalized comparisons from this
recording. Broad image changes remain unexplained by available evidence;
acquisition notes were requested, with no causal attribution inferred. Source
and earlier results remain unchanged. Only the audit plot caption was clarified
to distinguish a calculable baseline from direction agreement or scientific
acceptance. Next owned work: an explicit reviewed tissue-support path and bounded
validation, before further detector tuning or cohort inclusion.

## Explicit reviewed tissue-support path

[R1-TISSUE-004](reference-results/boi-tissue-support-20260910/README.md) adds
MATLAB proposal/preview and decision-recording entry points, source-bound mask
capture before the master, preservation of automatic support and added/removed
pixels, and checks throughout both-sign master/statistics exports. A changed
declaration requires a fresh master; it cannot alter an old result retrospectively.
Without a declaration, automatic support follows the existing calculation.

All 52 targeted checks and the complete synthetic reviewed-mask and default-mask
known-event/zero-event integrations passed. Verification harness corrections
(missing fixture fields, input precision and relative paths) are recorded with
the earlier attempts. No HP mask was fabricated or adopted, and its prior
workflow/event-review artifacts remain unchanged.

Candidate footprints remain untrimmed under the existing outside-support limit;
normalization still uses the whole image. These rules and dynamic observability
remain scientific questions. A declared static review is not acceptance. The
[researcher steps](BOI_REVIEWED_TISSUE_SUPPORT.md) are available in MATLAB; a GUI
mask editor and the independent researcher release walkthrough remain pending.
Next owned work: inspect available HP reference images for anatomical/observable
support and alignment, preserving identity, calibration, labels and intervention
questions before a biological support decision or any detector tuning.

## HP reference search: cached evidence complete, source access pending

[R1-HP-REFERENCE-005](reference-results/boi-hp-reference-review-20260910/README.md)
reviewed the preserved inventory and all 1,200 frame geometry declarations.
The external volume was not mounted; reconnection was requested and reference
pixels could not be inspected. The narrow prior inventory lists 16 named
reference TIFFs across 14 recording folders, but none for the selected FB2412
folder. Another recording's reference cannot be assigned through the unresolved
embedded-prefix conflicts.

ROI/binning/transpose settings are constant in cached metadata; zero physical
calibration/affine fields provide no registration evidence. The cached source
hash and both earlier HP statistics hashes match. No mask was adopted, reference
registration inferred or detector rerun. Confirmed external 1 Hz timing is
unchanged. Next owned action, once the volume is available: broaden the source
search beyond the prior inventory and inspect demonstrably matching references.

## Reconnected-drive reference and legacy support review completed

[R1-HP-REFERENCE-006](reference-results/boi-hp-reference-search-20260911/README.md)
completed the broader search on 11 September. Recursive acquisition folders
contain 23 named reference images across 19 recordings, seven more than the
original shallow inventory. FB2412 remains the only folder without a named
acquisition reference within this search. Whole-volume FB2411/FB2412 filename
matches supplied no additional acquisition location.

Two selected-recording AQuA2 landmark images were inspected. Both accompanying
legacy support maps contain only `None → []`, and their stored image grid is
502 × 502 rather than the source's 512 × 512. Neither supplies an explicit tissue
boundary or independently established anatomical registration. Source TIFF/CSV
checksums match; original analyses and events remain unchanged. No new mask,
detector run or biological eligibility decision was made. HP timing remains the
confirmed external 1 Hz clock.

A location for a separately stored matching reference/reviewed ROI was requested.
The source/legacy search itself is complete within its documented bounds.
Next independent owned work: expose source and tissue review in the MATLAB import
workflow while preserving the unresolved scientific evidence requirement.

## MATLAB import review implemented

[R1-IMPORT-007](reference-results/boi-import-review-20260911/README.md) connects
the GUI and batch verification to shared BOI source/acquisition/tissue preflight.
The new panel separates readable inputs, unsupported holds, import failures and
scientific eligibility. It shows affected measurements and actions, preserves
declarations in verification exports, and provides a full-review reading window.
Warnings do not introduce an extra approval dialog. The user clarified that the
AQuA2 files were exploratory detection work; they remain excluded from anatomical
reference/mask evidence.

The initial 59 targeted MATLAB checks passed; the affected import/UI tests were
rerun after display refinements. The actual GUI verification callback was exercised
on the preserved staged HP input, showing confirmed external 1 Hz sampling,
0.96 s exposure, unresolved source/tissue issues and no scientific acceptance.
Original detector/statistics results remain intact. This is a developer check,
not the independent researcher usability release gate.

## Saved event inspection and measurement definitions connected

[R5-INSPECT-008](reference-results/boi-event-viewer-20260911/README.md) adds the
BOI Measurements launcher tab, readable current/saved definitions, saved-event
inspection and new-folder evidence exports. Both signs, missing baselines and
direction disagreements remain visible. Source pixels require a matching
checksum; the fixed amplitude footprint is labelled separately from native
frame masks and tissue support.

All 249 saved HP event amplitudes and baselines replay correctly. The selected
negative surge is independently reproduced from its exported CSV ingredients.
Focused tests and GUI screenshots document developer verification, with initial
test/display corrections preserved. No detector/statistics rerun or scientific
acceptance occurred. Native-frame mask evidence, recording-summary denominator
navigation and the independent researcher walkthrough remain open.

## Native event-mask inspection connected

[R5-NATIVE-009](reference-results/boi-native-inspection-20260911/README.md)
adds explicit attachment of a saved master to a selected audit event, with
source/analysis/identity/timing/union checks and a newly recorded master checksum.
Native frame masks and fixed amplitude footprints have separate display modes;
recurrence at the same site cannot enter the selected event's native support.
Exports distinguish unavailable masks from known empty frames and include native
pixel coordinates. Old audits and master files remain unchanged.

The original audit did not bind a master-file checksum; that historical limit
remains explicit. The HP sink/surge walkthrough and synthetic checks verify
developer functionality, not anatomical support or physiological validity.
Recording-summary denominator navigation and independent researcher release
verification remain open.

## Recording/window denominator evidence connected

[R5-WINDOW-010](reference-results/boi-window-review-20260911/README.md) adds a
MATLAB inspector for saved recording/window results, with replayed occupied
fraction, onset rate and concurrent-event density. Frame exposure, union area,
tissue-time, event overlap and boundary onsets can be inspected and exported in
a new folder. Both sign-specific tissue masks remain visible; surge window
outcomes are explicitly unavailable in the present saved window schema.

Synthetic edge cases and the HP saved-results walkthrough verify numerical and
interface behavior. No detector/statistics rerun, animal pooling, tissue-validity
acceptance or physiological decision occurs. Surge window evidence, independent
researcher usability and final cohort/scientific release remain open.

## Both-sign window evidence extension

Decision [R5-SURGE-WINDOW-011](planning/boi-surge-windows-20260911.json) adds
separate surge window outcomes and frame ingredients to the BOI statistics path
and MATLAB inspector. Each sign uses its own saved tissue support. Original sink
windows and contrasts retain their calculation and schema; a surge composite is
explicitly undefined. Draft dictionary 0.3.0 records this additive implementation.

Verification is bounded to synthetic checks and one statistics-only run on the
preserved HP development master. No detector rerun, tuning, event exclusion,
animal pooling or scientific eligibility decision is part of this extension.
The [execution record](reference-results/boi-surge-windows-20260911/README.md)
reports the completed checks and their limits. Historical evidence and unresolved
source identity, calibration, tissue validity, onset interpretation and biological
questions remain intact.

## Connected review implementation phase completed

[R5-CONNECT-012](reference-results/boi-workflow-phase-20260911/README.md) completes
the current connected MATLAB review implementation: recording/window event rows
open the exact checked audit event, its source/native masks and exported window
provenance, with a return path. A missing source audit can now be created through
the normal GUI in a new folder, with source/master hashes, a runtime notice and
explicit failed-creation handling. Existing audit and analysis evidence is intact.

The HP developer walkthrough exercises import review, both-sign window/event/
source inspection, export and replay, alongside the already completed master/
statistics workflow and preserved A/B diagnostic setting comparison. All 249
source-audit measurements match earlier values; the negative surge stays negative.
The implementation phase is developer-verified, not independent validation.

Formal **R5 release remains open**: the original contract requires a researcher
independent of implementation, second-person replay, and an eligible recording.
The [handoff packet](BOI_RESEARCHER_WALKTHROUGH.md) and unfilled structured record
are ready for that observation. HP remains development/training evidence with
unresolved identity, calibration, anatomical/dynamic support and physiological
interpretation. R0–R4 scientific decisions and R6 freeze/cohort release are not
closed by this phase. No additional detector tuning or cohort run is implied.

## Saved support and amplitude-availability diagnostic completed

[R2-SUPPORT-013](reference-results/boi-measurement-support-20260912/README.md)
quantifies native coverage, amplitude availability and timing support in the
previously inspected ID400 and HP development recordings. Unavailable-amplitude
events uniquely account for 61.3%/66.4% of ID400 sink/surge coverage and
58.1%/86.9% of HP coverage. These are recording-specific descriptive fractions of
detected native area-time, not cohort estimates or valid observable tissue claims.

The four synthetic tests and independent CSV replay passed. All 495 events and
3,600 sign/frame rows remain, including the negative surge. Current calculations
and all detections are retained; amplitude-complete subsets must not substitute
for all-event coverage. Native versus refined timing and acquisition-boundary
contact remain separate diagnostics. Scientific baseline/onset/recovery policies
are deferred. The [scientific decision queue](BOI_SCIENTIFIC_DECISIONS.md) records
these dependencies; comparison priority and independent researcher release are
still open. No detector, statistics or new source-stack run occurred.

## Fixed baseline and timing challenge completed

[R2-BASELINE-TIMING-014](reference-results/boi-baseline-timing-20260912/README.md)
tested 34 supplied-mask amplitude cases across both signs and 10 sink timing
cases with unchanged defaults. Analytic expectations, the independent footprint
audit and all 23 existing regression tests passed. CSV replay verified the
exported arithmetic; 380 prior local artifacts remain unchanged.

The challenge separates calculation correctness, unavailable measurements and
reference/support differences. An imposed positive component can coexist with a
negative pre-event-relative amplitude during a falling background step. Moving
support changes the relationship between local and fixed-union peaks. Threshold
crossings and native/refined bounds remain distinct from physiological recovery.

Current rules and all selected results, including missing/negative amplitudes,
are retained. No production measurement changes, detector runs, baseline-policy
adoption, outcome demotion or cohort inference occurred. This bounded challenge
is complete; R2 scientific policy, R3 biological variability, R4 comparisons and
independent R5 release remain open. The next decision concerns the intended
reference and claim limits for the chosen scientific comparison.

## Measurement-policy and C02 preparation completed

[R0-R2-R4-POLICY-015](BOI_MEASUREMENT_POLICY_PROPOSAL.md) proposes five positions
covering the optical reference, missingness, timing, outcome hierarchy and paired
animal contrast. C02 is the worked example following the plan's proposed order;
researcher priority and scientific adoption remain unfilled. This is a concrete
review packet, not a new analysis rule or cohort freeze.

The candidate ledger preserves all seven mice/fourteen assets and the current
resolution overlay. Three mice are known development animals; four still need
a complete prior-use audit. No mouse is labelled untouched, no interval is
approved and no pair is declared eligible. Proposed conditional amplitude
summaries cannot substitute for all-event coverage or a full-population effect.

Source-ledger, dictionary, null-approval and implementation-hash checks are in
the [preparation record](reference-results/boi-measurement-policy-20260912/README.md).
No recording outcome, detector, model or statistics run occurred. Next independent
work is an existing-evidence audit by animal and acquisition stratum; scientific
policy adoption and evaluation freeze remain explicit decisions.

## Prior-use and acquisition-evidence audit completed

[R3-PRIOR-USE-016](BOI_PRIOR_USE_AUDIT.md) audits 42 execution/provenance reports
and an indexed corpus of 1,149 existing text records. The ledger preserves all
87 archive assets/63 canonical animal labels, 20 HP input rows and 20 separate
external-acquisition leads without adding them into a biological sample size.

Seven BOI sessions from five animals have documented analytical use; FB2411 is a
separate used fluorescence control. The identity-pending HP ECS recording is
also development evidence. The earlier alternative prototype used ID400 awake.
ID13/FB2316 were already pipeline references before their additional onset-panel
role; no historical method-specific evaluation label establishes new animals.

For the four unresolved C02 histories, FB2314/FB2315 have first-frame/acquisition
inspection, ID403 has an awake acquisition-header check, and ID402 has inventory
evidence. No analytical execution for them was found in the reviewed records.
This is not an untouched designation. No new source/movie analysis or method
experiment occurred; code, previous records and scientific questions remain.

The evidence audit is closed. Final evaluation roles still require an explicit
decision that accounts for original-study work, earlier V2/AQuA2 exploration,
human inspection and activity outside the available workspace. Known analytical
use propagates across sessions of the same animal; metadata/source-only history
is retained for the later independence decision. No eligible cohort is frozen.

## Evaluation-freeze preparation awaiting external history

[R3-FREEZE-PREP-017](BOI_EVALUATION_FREEZE.md) prepares all seven C02 pairs and
four explicit outside-history records without inventing evaluation assignments.
Three pairs are already known development animals. The researcher has been asked
to distinguish original-study use, later V2/AQuA2 tuning and human event/outcome
inspection for FB2314, FB2315, ID402 and ID403. Unanswered fields stay unknown.

All seven candidate pairs remain in the reanalysis ledger; development use is
not automatic exclusion from descriptive analysis. Scientific policy, eligibility,
windows, validation criteria and resource-budget decisions remain necessary
before a freeze. Preparation checks passed; no new analysis or rule change ran.

## Published C02 input audit completed

The researcher confirmed the eight questioned archive recordings are part of
the Science publication; [R3-PUBLICATION-HISTORY-018](planning/boi-publication-history-20260912.json)
records this. Prior publication does not exclude these reanalysis candidates.

[R1-C02-INPUT-019](reference-results/boi-c02-input-20260912/README.md) now establishes
technical input compatibility for FB2314, FB2315, ID402 and ID403 in both states.
The FB files have 1,200 frames at 16-bit storage and 2.35 µm/pixel; ID402/403 have
600 frames at 8-bit storage and 4.75 µm/pixel. All are 512 × 512 at the supplied
1 Hz. Source names, shapes and canonical metadata match the pinned archive
ledger; pixel equivalence and intensity history remain unverified.

All eight folders contain legacy sink, surge and manual-curation-named MAT
outputs. Their presence extends the prior-use evidence beyond the earlier
workspace search; it does not identify software/settings or establish manual
decisions. No numerical outcomes were inspected. Independent verification checked
7,200 frame headers and 32 source/legacy hashes; 460 MATLAB files were unchanged.
The initial reporting failure and corrected successful pass are preserved.

This input audit is complete. The generic missing-timestamp warning is interpreted
using the user's exact external 1 Hz correction, without overriding it from TIFF
clocks. Exposure, intensity preparation, valid tissue/time and approved comparison
windows remain distinct. Next work is source/conversion provenance and
measurement-specific eligibility, before scientific comparison or cohort rerun.

## Eight C02 source arrays verified against DANDI

[R1-C02-PROVENANCE-020](reference-results/boi-c02-provenance-20260912/README.md)
closes local-to-archive pixel equivalence for FB2314, FB2315, ID402 and ID403 in
both states. Eight pinned archive checksums passed. MATLAB and independent
Python agree on 1,887,436,800 pixels across 7,200 frames after the same explicit
spatial transpose already used by the MATLAB archive importer. No intensity
rescaling or frame reordering is needed. The archive's uint16 storage preserves
all values in the locally uint8 ID402/ID403 sources.

The preparation search found historical derived-image rescaling code and limited
ImageJ TIFF headers, but no original upload script or source intensity-processing
record. This evidence must not be confused with proof of camera-raw input.
No analysis code, source or legacy output changed. The successful comparisons
and an early failed report join are preserved; the final completed-table join
passes without repeating pixel analysis.

Source equivalence is now resolved for these eight cases. Next work is observable
tissue/frame-validity review and experimental windows, with pre-TIFF preparation,
exposure and physiological interpretation limits retained per measurement.
No scientific contrast, eligibility approval or evaluation role was assigned.

## C02 source observability triage completed

[R1-C02-OBSERVABILITY-021](reference-results/boi-c02-observability-20260912/README.md)
scanned all 7,200 frames and reviewed eight fixed-source sheets and diagnostic
timelines. No all-zero, constant or exact adjacent-repeat frames were found.
Stored-ceiling/zero pixels, broad brightness changes and changing internal dark
regions are retained as observations, not automatic artifacts or exclusions.
Dark BOI regions must not become non-tissue solely because intensity decreases.

Independent checks verified all diagnostic rows and 55 unique preview-frame pixel
calculations; source hashes and 460 implementation files remain unchanged. The
packet supplies source-bound support/frame/window review records with decisions
unfilled. Nominal [0,1200)/[0,600) s extents at confirmed 1 Hz are not approved
analysis windows. The researcher has been asked about isoflurane stabilization.

Next work is the actual observable-support and experimental-window review. No
mask, frame validity declaration, exclusion, biological comparison or rerun was
adopted. If invalid frames are found, the existing contiguous-time pipeline limit
must be addressed without deleting or renumbering frames. This bounded triage is
complete; it does not certify anatomy, full motion validity or cohort eligibility.

## C02 experimental-context correction

[R1-C02-CONTEXT-022](BOI_C02_EXPERIMENTAL_CONTEXT.md) maps the four questioned
pairs (FB2314, FB2315, ID402/M402, ID403/M403) to Figure 4 awake records and
Figure S13 isoflurane records. S13 presents a seven-mouse separate-state comparison.
The researcher clarifies that state establishment preceded recording and was
unmeasured where isoflurane was not applied within the file. Do not require an
intra-file induction baseline or recovery of a numeric stabilization duration
for these state comparisons. Earlier questions imposing that prerequisite are
superseded; no duration is invented. Support/frame validity and comparison
exposure remain to be decided, without selecting windows from apparent signal
stability. All source evidence and earlier audit records remain intact.

## C02 current spatial-support calculation audited

[R1-C02-SUPPORT-023](reference-results/boi-c02-support-20260912/README.md) replays
the unchanged default source loading, detrending and automatic support on all
eight recently verified C02 sources. The 76.51-second MATLAB pass and independent
Python denominator replay passed. Eight source hashes and 460 MATLAB files are
unchanged; no detector, mask adoption, frame exclusion or contrast occurred.

Automatic masks select 67.47–69.41% of the image, largely constrained by their
30th-percentile occupancy rule. The source overlays show peripheral inclusion
and internal exclusions; anatomical validity is still unresolved. The sink
20-pixel crop removes another 8.69–15.16% of selected pixels and corresponds to
47 µm for the FB sources versus 95 µm for ID402/ID403. Both sign-specific masks,
native count maps and nominal area-time ingredients are retained for review.

All four awake/iso pairs already have matching nominal durations within mouse:
1,200 seconds for FB2314/FB2315 and 600 seconds for ID402/ID403. No trimming is
required merely to obtain within-pair duration matching; no analysis window is
approved by this observation. The pre-recording state-establishment correction
remains in force. Next work is justified static outer-field support proposals
and temporal validity review, retaining changing internal dark regions unless
separate evidence supports exclusion. This bounded audit is complete; R1 support
eligibility and the broader reanalysis remain open.

## Eight C02 outer-field drafts prepared

[R1-C02-OUTLINE-024](reference-results/boi-c02-outline-proposals-20260912/README.md)
creates eight source-bound, unadopted outer-field polygons with native vertices,
uncertain-segment annotations, rationale, MATLAB proposal files and source/mask
checksums. Five fixed source frames show each draft; change maps distinguish
pixels retained, added and removed relative to the preserved automatic mask.
All drafts are contiguous and hole-free, retaining internal dark structures.
No intensity threshold, desired area or expected state effect defined them.

The outlines are approximate visual hypotheses, not validated anatomical or
temporally observable support. ID402 iso has weak perimeter evidence on all
segments; the other sources retain explicit boundary and clipping uncertainties.
No cross-session mask was transferred and no anatomical reference was established.
Prior viewing of both states/automatic maps is disclosed; these are not blinded
annotations. Substantive boundary review and temporal validity remain open.

The 50.168-second MATLAB pass and independent replay of 2,097,152 native positions,
mask topology, 16 interior points and both sign area-time ingredients passed.
Eight source hashes and 460 MATLAB files are unchanged. A separate layout repair
preserves the initial images and all mask geometry. No source support sidecar,
mask adoption, detector run, frame exclusion or window approval occurred.
Proposal preparation is complete. Next work is source/preparation-based resolution
of the uncertain boundaries, particularly ID402 iso, and full temporal validity;
accepted masks would enter a fresh stage, never retrofit existing event results.

## C02 full-frame temporal diagnostic completed

[R1-C02-TEMPORAL-025](reference-results/boi-c02-temporal-20260912/README.md)
provides fixed/adjacent apparent translation, correlation scores and native
row/column intensity profiles for all 7,200 source frames at exact external 1 Hz.
The 145.527-second MATLAB pass returned no registration errors. Independent
checks verified frame/time arithmetic, all projection totals and 56 selected
source frames; eight source hashes and 460 implementation files are unchanged.
All eight source sheets and complete projection/diagnostic timelines were viewed.

Larger apparent corrections occur in awake ID402/ID403 with low peak scores;
they are not established physical motion or automatic exclusions. Broad projected
structure persists while brightness changes. Small estimates do not establish
local observability. A scoped filename search found legacy outputs and additional
whisker sources, but no independent anatomical reference within its name filters.
The report records the search limits and exact original frames needing focused
local-sequence review. No numerical stabilization prerequisite is reintroduced.

This bounded diagnostic is complete. R1 remains open for justified boundaries,
temporal validity and measurement-specific exposure. No support adoption, frame
exclusion, analysis window, detector rerun or scientific eligibility was approved.
Next work is native-resolution landmark/edge review around the flagged intervals,
retaining uncertainty when source evidence cannot distinguish motion from signal.

## C02 focused sequence review completed

[R1-C02-SEQUENCES-026](reference-results/boi-c02-sequences-20260912/README.md)
inspects six prespecified clips around the 025 flags: 68 interval frames at three
fixed vessel/edge ROIs per recording, plus first-frame references. All 18 crop
sheets and seven full-frame triptychs were reviewed. Recognizable structure
persists; no clear coordinated landmark jump or observation-loss event is
established. ID403 frame 546 has a 3.664-pixel fixed-reference estimate but only
0.057 pixels against the preceding frame, illustrating reference dependence.
FB2315 geometry remains recognizable through its brightness/appearance change;
its cause is unresolved. No flag currently justifies a frame exclusion.

The successful 42.953-second MATLAB pass and independent replay of 18,612,224
pixels across 71 source/reference frames passed; three source hashes and all
460 existing implementation files remain unchanged. The first plotting failure
is preserved. A study-specific MATLAB viewer supports source-index navigation
and nominal 1 Hz playback; frame mapping, playback and cleanup checks passed.

This focused review is complete without certifying full-recording validity,
fine motion, anatomy or eligibility. Next work is consolidation of the accumulated
R1 evidence into measurement-specific support/exposure decisions, retaining ID402
iso boundary uncertainty. No further registration tuning or automatic exclusions
are implied, and existing mask proposals remain unadopted.

## C02 measurement-specific readiness consolidated

[R1-C02-READINESS-027](reference-results/boi-c02-measurement-readiness-20260912/README.md)
joins the eight source records to all 14 unchanged dictionary entries, producing
112 explicit recording/measurement records. It distinguishes conditional
descriptive calculation, missing fresh event results, direct tissue-time
normalization and scientific claim admission. No fresh event value from these
audits is treated as zero or valid. The eight sources are a four-mouse subset of
the seven-mouse C02 candidate comparison.

Occupied fraction, onset rate and concurrent density require sign-specific
tissue-time. Duration, native event area, optical amplitude/integral and local
event history do not directly divide by anatomical area, but candidate admission
and scientific interpretation still depend on support, timing and preprocessing.
Recovery and cross-sign estimator definitions remain unresolved. Missing exposure
or annotation is attached to affected claims rather than treated as a blanket
file-import failure. The pre-recording state-establishment correction is retained.

Identity joins, 16 nominal sign denominators, four nominal duration pairs and
the unchanged dictionary/460 implementation files passed verification. A proposed
source-bound acquisition declaration passes the MATLAB parser while keeping
camera exposure and frame validity unknown. No declaration was installed beside
a source, no mask/window/exclusion adopted and no detector run performed.

The consolidation is complete. The next specified execution is one fresh
FB2314-baseline-awake descriptive master and one statistics export, all 1200
frames at 1 Hz and 2.35 µm/pixel, with unchanged automatic support and explicit
review issues. It will provide actual both-sign measurement availability and
source-to-result replay. No second state, revised support or biological contrast
is included in that bounded execution specification.

## FB2314 awake descriptive workflow completed

[R1-C02-WORKFLOW-028](reference-results/boi-c02-workflow-20260912/README.md)
executes the specified single source with one fresh master and one statistics
export, unchanged defaults, both signs and all 1200 original 1 Hz intervals.
Its captured declaration confirms the external clock while keeping camera
exposure and frame validity unknown. No proposed outline was adopted.

The run detects 219 sinks and 49 surges; 109 sink and 13 surge amplitudes are
finite, with two negative directional surge amplitudes retained. All remaining
amplitudes lack the required clean pre-event baseline. Unavailable-amplitude
events account for 76.6% of detected sink covered area-time and 89.6% of surge
covered area-time under the automatic masks, so the finite-amplitude subset does
not represent all detected coverage. Those percentages are within detected
covered support, not fractions of the entire tissue-time denominator.

All 268 independent MATLAB source-amplitude checks agree. Python replays 2400
sign/frame coverage partitions, all frame-exposure rows and the two selected
1200-sample source traces, including baseline overlap and integrals. Source,
staged TIFF, saved statistics and dictionary hashes are preserved; all 461 current
MATLAB implementation files remain unchanged. Master and statistics take 59.42
and 55.43 seconds; initial output is 3.05 GiB and peak execution-process RSS
14.63 GiB. The actual scope and resource limitations accompany the evidence.

The first finite surge reaches a dim field margin and sits within a broad
intensity rise. The sink's refined time extends before native detection, against
a changing full-recording trace. These findings keep anatomical admission,
baseline interpretation and physiological timing open; no rule or exclusion was
changed. The one-recording phase is complete. Further work should resolve these
measurement/admission questions before a paired C02 interpretation; no second
state, mouse or biological contrast was executed.

## FB2314 targeted event/baseline review completed

[R1-C02-EVENT-029](reference-results/boi-c02-event-review-20260912/README.md)
completes six prespecified inspections from saved 028 results, without another
detector or statistics run. Both negative surges are site 16 events 1 and 7,
in the dim upper-left margin. Every event sample is below its respective
20-sample baseline mean, reproducing −1.4504% and −1.7567%. Retain their signs
and detector labels together; their anatomical and physiological identity is
unresolved. The positive peripheral example has a rising baseline/broader trace,
so a clean numerical baseline does not certify an isolated positive transient.

The largest unavailable-amplitude sink (site 5/event 4) loses 19 baseline samples
to preceding same-site native detection; the largest unavailable-amplitude surge
(site 4/event 1) loses 16 to other surge sites. They contribute 21.34% and 22.88%
of all respective detected covered area-time. That coverage remains included.
A sink already present at frame 1 has no observed pre-event baseline; its onset
and refined/native timing remain explicitly limited. Event-local baseline
missingness does not undo the user's pre-recording state-establishment correction.

Independent replay passes for 268 native event rankings, 2400 sign/frame unions,
7200 selected source samples, 18 source/native-mask pairs and 52 baseline-overlap
attributions. Existing MATLAB implementation files, dictionary, sources and
saved results are unchanged. The first export's reserved-column-name failure
is preserved; the corrected review takes 29.51 s process wall time and 1.85 GiB
peak process RSS. All six figures were inspected; researcher replay steps use
the existing MATLAB event viewer. Independent researcher usability remains open.

Disposition: retain the numerical rules/results, restrict physiological claims,
and defer anatomical acceptance. This closes the targeted review; it does not
authorize baseline substitution, event exclusion or a further method search.
The next existing decision is source-supported tissue and event admission,
using these concrete cases and the unadopted outer-field proposals before a
paired C02 interpretation. No additional scientific prerequisite is invented.

## Craniotomy clarification and spatial check

The user clarified that the relevant BOI signal is limited to the craniotomy,
which may be smaller than the camera field. [R1-C02-CRANIOTOMY-030](reference-results/boi-c02-craniotomy-20260912/README.md)
checks all 268 saved FB2314 awake events against the unchanged 024 outer-field
proposal. Both negative surges have approximately 99.9% of native detected
area-time outside it; the large peripheral sink has 99.66% outside, while both
interior sink examples have 0% outside. The result strongly supports prioritizing
outside-craniotomy detection as a spatial support problem. The prior polygon
remains an approximate field boundary, not a confirmed surgical annotation.

All native polygon positions, 268 geometry rows, seven selected cases and
21 selected source-frame means pass independent replay; 461 existing MATLAB
files and prior evidence are preserved. No new analysis or mask adoption occurs.
Recording-specific craniotomy support is now explicit in the standing plan.
The current reviewed-mask path still leaves accepted footprints unclipped and
normalization over the whole image. Finalizing the anatomical ROI and defining
how those operations use it is the next concrete method/support decision.

## Reviewed working ROI executed on FB2314 awake

[R1-C02-ROI-RUN-031](reference-results/boi-c02-reviewed-roi-20260912/README.md)
records the user's “Looks good. Go on.” review and applies the displayed native
outline as working static support in one fresh development master/statistics run.
Uncertain segments remain; no other recording's ROI or final cohort eligibility
is accepted. Existing implementation, parameters, baseline/timing rules and
dictionary 0.3.0-draft remain unchanged.

The run has 175 sinks and 21 surges, with 100/11 finite amplitudes, 75/10
unavailable and no negative finite amplitudes. All 196 source-amplitude/status
checks agree. The two inspected interior sink supports are fully retained;
the five peripheral examples have no same-sign native pixel-time overlap with
the new union. IDs are not treated as cross-run biological matches.

The remaining limitation is explicit: 5.13% of sink and 7.85% of surge full
native detected area-time remains outside the ROI. Forty-four sinks and fifteen
surges include at least one exterior pixel, though none is wholly outside.
The existing mask path therefore does not enforce strict containment or remove
whole-image normalization. Interior baseline/physiological questions remain open.

Both-sign exposure/coverage and before/after support comparisons pass independent
replay; four new source/ROI/trace panels are reviewed. Execution takes 118.21 s
process wall time, 3.00 GiB initial output and 13.72 GiB peak process RSS. A
post-audit dispatch failure is preserved and resolved by a separate comparison
process; no analysis retry was needed. The phase is complete. The next
[restricted-support specification](reference-results/boi-c02-reviewed-roi-20260912/strict-roi-specification.md)
sets exterior-independence, containment, versioning and source-replay checks for
ROI-only normalization/thresholds and restricted native candidates before another
method comparison. No such method change or additional recording was run here.

## Restricted ROI implementation and synthetic verification

[R1-C02-STRICT-032](reference-results/boi-strict-roi-implementation-20260912/README.md)
implements opt-in `craniotomy-roi-1` / `3.1-roi-dev`: ROI spatial normalization,
included-neighbor smoothing, sign-specific threshold support before components,
exact final native containment and included-pixel spatial-bin traces. The
whole-image default and historical replay remain available. Saved policy,
source reconstruction, event review and statistics contracts distinguish the
methods; mixed profiles are rejected.

The synthetic original and exterior-perturbed recordings yield identical
10-sink/4-surge event measurements and native footprints; 28 source audits
agree. Constant input produces no events. Analytic arithmetic, invalid support,
weak/strong and recurrent/sustained boundary fixtures pass. The existing full
legacy workflow also passes. An initial verification dispatch failure and the
spatial-bin correction are retained in the evidence record. This closes the
implementation phase, not scientific validation.

Next: prespecify one FB2314 awake comparison with the unchanged 031 source and
working ROI. Compare native support, availability, source traces and feasibility.
No biological recording was processed by the new method in this phase; no
cohort expansion, acceptance threshold or unresolved ROI decision is implied.

## FB2314 strict ROI comparison completed

[R1-C02-STRICT-RUN-033](reference-results/boi-c02-strict-roi-20260912/README.md)
executes the prespecified single FB2314 awake development comparison. The source,
working ROI, metadata, 1 Hz cadence and unrelated parameters are unchanged.
All 346 native events are exactly contained in their sign support; all source
measurement audits agree. There are 305 sinks and 41 surges, with 143/10 finite
amplitudes, 162/31 unavailable and 1/2 negative finite amplitudes.

This changes interior detection as well as removing exterior support. Occupied
fractions increase from 0.274% to 0.500% for sinks and from 0.893% to 2.244% for
surges on unchanged denominators. Availability does not uniformly improve.
The three negative amplitudes remain supported by original-source replay and
are preserved; two surge examples show raw dips alongside positive normalized
scores. Exact ROI containment does not resolve normalization, anatomical
boundaries or physiological relevance. No further mask edits, thresholds,
baselines, cohort roles or exclusions are adopted.

The comparison phase is complete. Next: audit the ROI reference and detrending
contributions to the signed-disagreement cases and specify a fixed global/local
signal challenge before any further detector change or cohort expansion.

## Signed-disagreement normalization mechanism audited

[R2-C02-NORMALIZATION-034](reference-results/boi-c02-normalization-audit-20260912/README.md)
reconstructs the three 033 cases on unchanged source, support, native/measurement
windows and original 20 clean baseline frames. No detector/statistics run or
method change occurs. All saved stages replay; the exact spatial decomposition
closes within 4e-14 in independent CSV arithmetic. All 193,344 saved native
pixel-time samples satisfy their sign-specific percentile rule.

At the strongest native surge frames, local residuals decline by 173.67 and
124.44 input units while the ROI residual declines by 377.14 and 340.86 units.
Subtracting that larger reference decline makes the local scores rise. In the
first case, raw local and ROI means fall by nearly the same fraction (9.165%
and 9.130%) despite the positive detection score. For the sink, removed local
trend and a rising ROI residual push the score negative while raw intensity
remains above its event baseline. Temporal weighting strengthens the changes;
spatial-SD variation is not the dominant contribution at these anchors.

The audit distinguishes relative spatial contrast from source-baseline change.
It does not settle the physiological meaning of either quantity, uncertain
boundaries or the wider cohort. Next: execute the prespecified synthetic
shared/global versus local signal and baseline-brightness challenge before
choosing a normalization change. Existing scientific questions remain open.


## R2-SUBSTRATE-CHALLENGE-035 — decay and baseline challenge complete

[R2-SUBSTRATE-CHALLENGE-035](reference-results/boi-substrate-challenge-20260912/README.md)
executes the original 24 shared/local controls, 18 separately frozen decay
stage inputs and 144 known-support event measurements. All use 1 Hz. The
20-second original-source baseline and every production parameter remain
unchanged. Exponential half-lives of 10, 20 and 40 minutes are illustrative;
actual substrate kinetics were not estimated.

At a 10-minute half-life, a supplied 20-second window with decay alone measures
as a 3.35% sink; an injected 2% drop measures 5.29%, and a 2% rise measures 0.77%.
The quantifier's original-source baseline can therefore exaggerate drops and
attenuate rises. These are known-window arithmetic fixtures, not detected
biological events. Shared fractional changes on heterogeneous brightness also
produce relative spatial candidates without local injections. Noise-free
near-zero residual variance can amplify numerical structure; all zero-SD and
unavailable decomposition cases remain explicitly recorded.

Independent checks replay all 144 measurements, 25,200 candidate-frame rows
and all 21 noise-free source stacks with exact hashes. All 467 MATLAB files and
the measurement dictionary match the prior phase. The main run took 4.29 minutes
with two threads; existing changes and prior evidence are preserved. The phase
is complete; physiological acceptance, empirical kinetics, biological variability,
cross-mouse transfer and independent researcher usability remain open.

Next: quantify observed local and ROI pre-event slopes for the same three
source-audited FB2314 cases, preserving their native footprints and original
20 clean samples. Do not assign a substrate half-life from short baselines or
adopt a correction before a bounded comparison of baseline approaches.


## R2-C02-BASELINE-DRIFT-036 — actual pre-event drift audited

[R2-C02-BASELINE-DRIFT-036](reference-results/boi-c02-baseline-drift-20260912/README.md)
checks the same three signed-disagreement events from one FB2314 awake
recording. Native footprints, original 20 clean baseline samples at 1 Hz,
measurement windows and negative amplitudes are preserved. No production
method, detector or cohort analysis was rerun or changed.

Local full-window slopes are −0.1027, −0.1634 and +0.0056 percent of baseline
per second for sink 10/1, surge 1/3 and surge 1/4. A straight line explains
6.3%, 17.4% and 0.08% of local variation. The sink and surge 1/4 reverse slope
direction between the two ten-sample halves; the ROI also differs from local
behavior. These fluctuations do not identify substrate half-lives or establish
which component is physiological. A uniform decay correction is not adopted.

Independent checks reproduce 114 metrics, 7,200 saved raw trace values and
all three native footprints. All 467 MATLAB implementation files remain
unchanged, and the 347 sealed files from phase 035 are preserved. The MATLAB
process completed in 30.49 seconds. A failed initial path dispatch is retained.
This completes the descriptive audit; biological variability, physiological
acceptance, cross-mouse transfer and independent researcher usability remain open.

Next: execute the prespecified comparison of the unchanged 20-second mean
with a pre-event linear reference on 144 existing synthetic fixtures and 64
fixed fluctuating-background inputs. Preserve both answers and test the risk
of extrapolating a short fluctuation before any production baseline decision.


## R2-BASELINE-COMPARISON-037 — controlled reference comparison complete

[R2-BASELINE-COMPARISON-037](reference-results/boi-baseline-comparison-20260912/README.md)
compares the existing 20-second mean with a line fitted only to the same
pre-event samples: 144 unchanged saved fixtures plus 64 frozen fluctuating
inputs, for 416 readouts at 1 Hz. No detector, cohort analysis or production
baseline change occurs. All original constant-reference results replay exactly.

The line reduces smooth-decay error: a noise-free 2% drop over a 20-second
window at an illustrative 10-minute half-life measures 1.995% with the line
versus 5.286% with the mean. Fluctuations can instead produce much larger
errors. One zero-injection control measures a 9.967% drop with the line; the
line reverses the injected direction in 8 of 32 fluctuating cases with a
nonzero component. These are fixed synthetic outcomes, not biological error
rates or an automatic baseline-selection rule.

Independent arithmetic and all 64 new native input hashes agree. Three
zero-change controls have a machine-precision strict sign-flag disagreement
(about −1.14e−16 fraction versus zero); the values, flags and initial failed
verification are retained explicitly. No amplitude is rounded or threshold
tuned. All 467 MATLAB files and prior evidence are preserved. The main process
completed in 22.54 seconds. This closes the controlled comparison, while
physiological interpretation, variability across mice and independent usability
remain open.

Next: make baseline variation and reference sensitivity inspectable in the
existing MATLAB event review, retaining the original saved measurement and
labeling alternatives as diagnostics. Do not automatically correct or exclude
events, or infer substrate kinetics from a short fitted segment.


## R2-BASELINE-REVIEW-038 — diagnostic event review implemented

[R2-BASELINE-REVIEW-038](reference-results/boi-baseline-review-20260912/README.md)
adds a **Baseline diagnostic** tab to the existing MATLAB saved-event review.
It shows the actual clean samples, saved mean, pre-event-only fitted line and
extrapolation interval, full/two-half slopes, variation and reference-sensitive
amplitude. The original measurement remains visible and unchanged. New exports
version and hash the diagnostic, preserve its ingredients and retain negative
and unavailable values. Missing samples are never replaced by an earlier search;
invalid extrapolations are withheld without clipping or automatic correction.

All 29 event, connected-review and window-review tests pass. Three saved FB2314
awake cases and one unavailable-baseline case pass reopening/export checks;
independent arithmetic agrees and the source audit is unchanged. Four corrected
MATLAB screenshots have been inspected. The combined final verification process
took 44.88 seconds. An initial test-discovery failure and an interval-marker
display defect are retained with the correction and passing regression checks.

Only four existing review/test MATLAB files changed, with two new review helpers;
463 prior MATLAB files, the detector, quantifier, statistics and measurement
dictionary remain unchanged. Phase-start versions of edited files and all 64
sealed phase-037 artifacts are preserved. This completes implementation and
verification, not physiological acceptance or independent researcher usability.
BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Substrate consumption
does not establish the origin or kinetics of each local fluctuation.

Next: perform a researcher walkthrough of the diagnostic alongside the saved
event evidence, checking that reference sensitivity and unavailable values are
understood before choosing a production baseline method. Cross-mouse validation
and the distinction between net source change and deviation from an expected
or shared signal remain open.


## R2-BASELINE-REVIEW-FIXES-039 — code-review findings corrected

[R2-BASELINE-REVIEW-FIXES-039](reference-results/boi-baseline-review-fixes-20260912/README.md)
corrects the two reproduced phase-038 review defects. The diagnostic now flags
saved-versus-audited disagreement and separates the saved amplitude, audited
mean-reference amplitude and fitted-line amplitude. Reference sensitivity is
line minus audited amplitude on the same source. The earlier line-minus-saved
difference is preserved with an explicit warning that it can include audit
disagreement. Stored and audited baselines retain their distinct identities;
missing historical values are not filled from the audit. Native bounds now
remain visible outside the measurement interval without extending the fit.

All 31 review tests pass, including serialized mismatch checks for both signs,
missing historical baseline, unavailable diagnostic and native bounds on either
side of the plotted samples. Six MATLAB views were inspected. The same three
FB2314 cases and one unavailable-baseline case retain identical quantitative
frames, footprints, saved rows and prior diagnostic arithmetic. All 48 export
artifacts verify. Diagnostic schema 2 and export schema 4 record the new roles;
the fitted-line method remains version 1 because its arithmetic is unchanged.

Four review/test files changed; the other 465 MATLAB files and all earlier
outputs are preserved. The 229 phase-038 sealed files verify using phase-start
snapshots for subsequently edited files; all 18 code-review evidence files
also verify. These fixes do not resolve the scientific baseline choice,
physiological interpretation, biological variability or cross-mouse transfer.
BOI-only scope, feasibility, usability and traceability remain requirements.

Next: researcher walkthrough of the corrected diagnostic alongside original
event evidence; independent usability and any production baseline decision
remain open.


## R2-GUIDED-REVIEW-040 — researcher feedback and timing question

The guided MATLAB diagnostic walkthrough received user feedback on all three
examples: tentative understanding of reference sensitivity, clear unavailability
when no pre-event samples exist (also not definable manually for that case),
and clear separation of audit disagreement. The live reviewer opened and the
user reported successful export and usability. The resulting surge site 1/event 4
export was found beside the source audit. All eight artifact checksums and
implementation/source-audit hashes verify; both amplitudes reproduce from CSV.
Individual researcher clicks were not observed. Guided feedback and assistant
replay do not complete independent release validation.

The user would place onset earlier in both examples and judge pocket duration
from onset to recovery, considering the signal level after the excursion. This
is preserved as a scientific timing proposal, with no manual frame boundaries
or production-method adoption inferred. The two examples are provisionally
interpreted as surge site 1/events 3 and 4; event 4 is confirmed by the export.
These surges currently use native-mask bounds without trace refinement. Existing
sink timing uses a different, bounded detection-trace return rule, not a
post-event reference on the fixed preserved-source footprint.

Next: review wider before/after traces and record researcher onset/recovery
annotations alongside original bounds. Keep post-event timing evidence separate
from the pre-event amplitude reference. Substrate consumption does not imply a
return to the original intensity or identify a local background trajectory.
An earlier onset also changes which 20 clean samples precede it; compare the
resulting baseline availability and amplitudes before any method decision.
Biological variability, physiological relevance, BOI-only scope, feasibility,
usability and traceability remain requirements.

Evidence: workspace `reference-validation/boi-baseline-guided-review-20260913/`
contains verbatim feedback, successive records, export verification and the
wider timing-context plot. No original analysis or code has been changed.


## Researcher correction and timing annotations — 13 September 2026

The user explicitly cautions against overinterpreting substrate decline: each
recording can behave differently, which motivated the original baseline
correction. Treat this as a correction to the emphasis of the preceding guided
explanation. A local slope is not assigned a substrate cause. The original
external-drive `HP_indepth/OxygenDynamics_Master.m` was inspected read-only and
copied with its hash into the guided-review evidence. It uses recording-derived
polynomial detrending (degree 3 per pixel, degree 5 per trace) and a degree-7
processed-site trace trend for sink return-level timing, not a substrate-decay
model. This source inspection does not establish which exact historical file
version generated every saved output, or adopt a new measurement method.

The researcher marks FB2314 surge site 1/event 3 approximately **496–516**
(saved 503–514), and event 4 approximately **536–556** (saved 540–552).
They explicitly allow onset a little later and offset earlier, by around
1–2 seconds, and describe the judgment as biologically difficult. Preserve the
nominal bounds and this uncertainty. A working comparison envelope includes
onsets 496–498 / 536–538 and recoveries 514–516 / 554–556; these are annotated
possibilities, not confidence limits, accepted algorithm thresholds or exact
biological boundaries. Original event and mask labels remain unchanged.

Each nominal pair has 20 seconds between marked sample times, whereas the
current inclusive-frame convention counts 21 samples. Preserve both meanings
until the timing convention is resolved. A nominal earlier onset would move
the candidate 20-sample amplitude baselines to frames 476–495 and 516–535;
cleanliness/overlap has not been re-audited, so no alternative amplitude or
baseline availability is asserted. Post-event recovery evidence does not
silently replace the pre-event amplitude reference.

Next: compare the existing recording-specific correction and timing with these
annotation ranges, preserving biological uncertainty and all previous results.
No decay model, baseline correction or production event boundary was changed.
Evidence: `reference-validation/boi-baseline-guided-review-20260913/`
`feedback-05.json`, `researcher-timing-annotations.json`, and
`original-correction-reference.json`.


## R2-C02-TIMING-COMPARISON-041 — annotated timing comparison complete

[Comparison and evidence](reference-results/boi-c02-timing-comparison-20260913/README.md)
retain the existing recording-specific correction and compare FB2314 awake
surge site 1/events 3 and 4 with the researcher's uncertain annotations.
The cubic-corrected local trace crosses zero between frames 499–500 and
514–515 for event 3, and 536–537 and 554–555 for event 4. Event 3's onset
falls later than the working annotation range. These are descriptive landmarks;
no physiological boundary, sink return algorithm or causal substrate trend
is inferred. Historical and current surge bounds are native-mask based.

All 18 annotation alternatives retain 20 finite immediate pre-event samples
without saved native-event overlap, checked against all 346 events of both
signs on the original footprints. This does not prove a biologically quiet
baseline. Boundary shifts change both the reference samples and the included
raw-source maximum: diagnostic surge amplitudes range from −1.315211% to
+1.077856% (event 3) and −0.597962% to +1.316485% (event 4). Original negative
amplitudes, labels and masks remain unchanged. Marked sample-time separation
and inclusive-frame duration are exported separately.

Independent replay verifies 2,400 samples per trace column, all 20 comparison
rows, both saved amplitudes, native overlaps and crossing brackets. Seven
frozen inputs, all 469 MATLAB implementation files and the 143 preserved
phase-039 artifacts verify unchanged. Two final plots were visually inspected.
No detector/statistics run, new movie read or production-code change occurred.

Decision: close this bounded experiment, retain current production rules and
defer adoption of a physiological timing definition. Before selecting a rule,
specify a small comparison across already development-exposed recordings and
both signs, preserving variable backgrounds, morphology, recurrence, overlap,
incomplete recovery and unavailable measurements. BOI-only scope, biological
variability, physiological relevance, feasibility, usability and traceability
remain requirements. These two annotations remain uncertain development
examples; formal independent validation and cohort scientific decisions stay open.


## R2-TIMING-PANEL-042 — broader development comparison prepared

[The frozen timing panel](reference-results/boi-timing-panel-20260913/README.md)
contains 48 unique events (12 per recording) from FB2314 awake, ID400 awake,
FB2316 KX and HP_ECS_CSV2_identity_pending. All are already development-exposed;
HP is not a fourth verified animal. Fixed detector-magnitude, native-duration,
baseline-context and recurrence slots were declared before selection; both
signs and the two existing researcher anchors are retained. No case was selected
for a new timing result or agreement with manual marks.

All required saved traces and 48 native-mask associations verify. Sixteen frozen
inputs and all 469 MATLAB implementation files remain unchanged. The old ID400
and FB2316 audits lack AnalysisInfo.FrameSize, required by the current GUI
reviewer; direct read-only checks verified dimensions from their saved site
tables without rewriting historical records. The failed GUI-loader attempt is
preserved. Thirty-one selected amplitudes are unavailable under the saved
baseline rule and remain included; this is a selection characteristic, not a
new biological result. The initial researcher review queue has at most10 cases.

This closes panel preparation, not the timing comparison. Next execute one
bounded saved-trace/native-mask replay per recording, preserving original
correction, tissue-support differences, opposite signs, crossing uncertainty,
censoring and missingness. No pooling, new decay model, production timing change
or scientific validation is implied. BOI-only scope, biological variability,
physiological relevance, feasibility, usability and traceability remain standing
requirements. The cohort evaluation freeze and independent release walkthrough
remain open.


## R2-TIMING-EXECUTION-043 — frozen timing comparison completed

[The completed comparison](reference-results/boi-timing-execution-20260913/README.md)
replays all 48 selected events from four development recordings using their
existing correction. Of 96 positive/negative diagnostic branches, 35 have two
crossings, 25 are censored and 36 lack the requested sign inside native support.
Twenty of the 35 bracketed branches cover only part of the native event. These
are diagnostic branch counts, not independent biological observations or
condition effects. Only 11 bracketed branches also provide the required clean
20-sample baseline; saved 17 finite and 31 unavailable amplitudes remain intact.

Decision: retain production correction/timing, keep new crossings as diagnostic
landmarks and defer a general physiological duration rule. No substrate-decay
model, source change, relabeling, fallback reference or scientific tuning was
introduced. Restricted ROI and historical whole-field contexts remain separate.
The HP identity and anatomy holds remain; the fixed HP sink review case has
small support near the upper-right image edge and is not physiologically
validated by its successful numerical replay.

Independent replay verifies 144 rows, 50,400 full-trace samples per column,
48 native footprints, overlap, timing/censoring and saved measurements. All 16
frozen inputs and 469 MATLAB implementation files retain their hashes. Four
recordings completed in 5.86–19.82 seconds each excluding startup. Ten trace
plots and ten native-mask montages were inspected. Initial queue-format failure
and a saved-row coverage-flag reporting correction are preserved with their
exact scope; scientific calculations and selection are unchanged.

Next: [review the ten fixed examples](reference-results/boi-timing-execution-20260913/REVIEW.md),
beginning with the first two, to distinguish complete excursions, partial
fluctuations and unresolved recovery. Approximate ranges or an unresolved
judgment are acceptable. No further automatic parameter search follows from
inconclusive evidence. BOI-only scope, biological variability, physiological
relevance, feasibility, usability and traceability remain requirements;
independent physiological/workflow validation and cohort eligibility stay open.


## R2-TIMING-GUIDED-REVIEW-044 — fixed researcher review completed

[The consolidated guided review](reference-results/boi-timing-guided-review-20260914/SUMMARY.md)
records eight new judgments: six with timing marks and two without a
recognizable event. The two earlier FB2314 anchors complete the ten-case queue
with their original uncertainty; they were not newly confirmed. Example 6 (FB2316
KX surge 10/3) is not seen as a surge. Example 7 (HP sink 15/4) is not distinguished
from surrounding temporal variability; that rationale remains separate from
its unresolved upper-right anatomical support.

The annotated boundaries follow local decline/rise and recovery, including a
brief recovery peak and alternative plausible onsets. Example 3 preserves 295 s
as an additional onset alongside 297, with 312–313 offset; the plot-frame versus
elapsed-time origin remains explicit. No fixed prominence, variability or
duration threshold is inferred. Existing correction, both detector signs,
biological variability and physiological relevance remain standing requirements.

All eight feedback chains and exact ten-case queue coverage verify. Production
code, timing, baselines and amplitudes are unchanged. The phase 043 narrative
correction is retained: example 1's onset was censored, while recovery was
bracketed at 1166–1167. Prior sealed evidence remains preserved. This is guided
development feedback, not an independent accuracy or release validation.

Next: a bounded measurement-impact audit of the supplied intervals and
alternatives, including the same 20-sample immediate baseline, both-sign native
overlap and unavailable values. Keep non-recognized candidates' original
outputs without assigning manual timing. Define testable candidate rules only
after this audit; do not automatically retune the detector. BOI-only scope,
feasibility, usability, traceability, HP identity/anatomical holds and cohort
scientific questions remain in force.


## R2-MARKED-INTERVAL-IMPACT-045 — researcher interval consequences checked

[The verified measurement-impact audit](reference-results/boi-marked-interval-impact-20260914/README.md)
checks 12 explicit variants from six new annotations against eight saved
comparators; the two non-recognized examples receive no manual intervals.
Two new annotated events retain an available amplitude; four still lack the
required 20 immediate finite pre-event samples free of both-sign native overlap.
ID400 sink 45/1 gives 7.6787–8.0248% across onsets 295, 296 (coordinate
sensitivity only), and 297, versus saved 7.8838%. Offsets 312/313 do not change
its amplitude. FB2316 sink 14/6 gives 6.6592%, versus saved 6.7268%.

The HP surge 235–356 remains recognizable to the researcher despite unavailable
amplitude; its fixed original footprint and native extension through frame 389
remain explicit. The rejected HP sink retains its finite saved 1.5316%
amplitude: measurability does not establish event recognition. No substrate
mechanism, revised correction, event relabeling or baseline fallback is adopted.
Frame 295 versus elapsed second 295 remains an explicit alternative rather than
a silently resolved annotation. Earlier anchor grids are reused by hash.

Independent arithmetic/native-overlap verification passes all 20 new rows,
reproduces all eight saved comparators, verifies 33 frozen inputs and confirms
469 unchanged implementation files. Prior evidence and standing document
versions are preserved. This is a bounded development audit, not physiological
validation or final cohort eligibility. BOI-only scope, both signs, biological
variability, physiological relevance, feasibility, usability and traceability
remain requirements; HP identity/anatomy and other scientific holds stay open.

Decision: retain production rules and defer final recognition/timing policy.
Next: prespecify a small candidate set of event-recognition and onset/recovery
rules with local variability, boundary uncertainty, recurrence and sustained
signals represented. Keep amplitude availability separate and preserve the
original recording-specific correction; no automatic threshold adoption or
relaxation of the reference rule follows from this audit.


## R2-RECOGNITION-TIMING-CANDIDATES-046 — bounded candidate definitions prepared

[The candidate comparison](reference-results/boi-recognition-timing-candidates-20260914/README.md)
specifies two diagnostic timing rules: nearest observed turning points and the
strongest shoulders within the same saved search limits. Both operate on the
existing corrected trace, retain both directional branches and allow brief
recovery peaks. Seed/plateau conventions, partial boundaries, nonfinite barriers,
competing excursions and native-support disagreement are explicit.

A separate recognition diagnostic compares directional shoulder prominence
with preceding/following ranges at fixed 10- and 20-sample context scales.
Its factor-one screen is an unvalidated comparison hypothesis, not an event
admission threshold. Active context is retained and flagged. The 20-clean-sample
raw amplitude reference remains separate and unchanged; unavailable amplitudes
do not suppress recognition evidence. No correction fit, substrate model,
automatic exclusion, event relabeling or production policy is adopted.

The same 48 development events and ten reviewed cases are bound to source
hashes. Eight have uncertain timing references, two are not recognized, and 38
have no human reference. The future budget is 192 timing rows and at most 384
context-scale diagnostics, one pass per recording, ten minutes per recording,
250 MiB new evidence and the existing ten-case review limit. Existing comparator
outputs are reused. Technical verification and explicit gains/losses are
required; no scientific winner score or automatic tuning loop is defined.

Preparation is complete; the candidate comparison has not run. All prior
evidence and 469 implementation files remain unchanged. BOI-only scope, both
signs, biological variability, physiological relevance, feasibility, usability,
traceability and unresolved cohort/anatomical/HP identity questions remain.
Next: implement and verify these diagnostic-only candidates, bind their code,
then run the fixed saved-panel comparison. Final physiological rules and
production changes remain deferred pending evidence.
