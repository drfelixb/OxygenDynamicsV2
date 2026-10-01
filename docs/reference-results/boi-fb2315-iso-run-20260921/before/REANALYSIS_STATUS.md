# BOI reanalysis current status

Current overview (21 September 2026): [project position and closure checklist](BOI_PROJECT_OVERVIEW.md). The dated entries below preserve the development history.

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


## R2-RECOGNITION-TIMING-EXECUTION-047 — fixed candidate comparison complete

[The verified comparison](reference-results/boi-recognition-timing-execution-20260914/README.md)
implements the frozen nearest-turn and strongest-shoulder diagnostics on all
48 events in both directions. Known-shape checks pass 89 groups, and independent
Python verification checks all 192 nested timing/context/amplitude rows and
reproduces 48 original comparators. There are 154 complete intervals, 34
unbracketed seeds and four partial-shoulder rows. Complete intervals generate
308 context-scale diagnostics; these are repeated calculations, not biological
replicates. Recording, saved sign, direction and candidate remain separate.

The strongest-shoulder decline matches example 1 at 1154–1167, but can begin too
early or extend recovery too far: the HP surge becomes 233–417 versus the user's
235–356. Nearest turns frequently capture small internal fluctuations. The
recognized ID400 surge fails the proposed range screen at both context scales;
the rejected HP dip passes at 10 samples and fails at 20 for the strongest
decline candidate. No branch, context scale or manual alternative is selected
to rescue agreement. Both candidates and the range screen remain unadopted.

All ten fixed figures and every supplied annotation alternative are retained,
including the coordinate sensitivity for example 3. Original saved/zero-crossing
comparators, slot mappings, native geometry and source links are reused. A
reporting-only correction marks unassessed baseline counts unavailable instead
of zero; original run outputs and initial figures are preserved. No detector,
correction, movie, statistics or production rerun occurred. All 469 implementation
files and prior evidence remain unchanged or explicitly snapshotted.

Decision: retain production rules and defer scientific recognition/timing policy.
The fixed comparison stops; do not automatically adjust smoothing, thresholds,
context lengths or search limits. Next clarify what distinguishes a full
excursion from nested fluctuations and what constitutes local recovery when
later activity follows, using these failure cases before another method proposal.
BOI-only scope, both signs, biological variability, physiological relevance,
feasibility, usability, traceability and unresolved anatomical/cohort/HP identity
and independent-validation requirements remain in force. Existing recording-
specific correction remains the starting reference; no substrate mechanism is
inferred and amplitude availability remains separate from recognition.


## R2-REVIEW-TRACE-AUDIT-048 — displayed signal identity checked

[The review-trace audit](reference-results/boi-review-trace-audit-20260914/README.md)
verifies all ten original guided-review plot hashes and all 10,800 corrected
samples against the saved array used by phase 047. No trace-identity or
frame-order mismatch was found: the candidates used the displayed middle blue
corrected trace as specified. The original displays also contain raw and
filtered event-footprint traces and a differently supported/processed site
trace. The researcher did not consistently specify which panel guided the marks.

The intended human reference is therefore an explicit open provenance question;
do not treat phase 047 as comparison against a confirmed corrected-trace-only
annotation protocol. Its numerical results remain valid and preserved. This
audit does not establish that switching traces would solve its failures.
Exact endpoint neighborhoods are copied for inspection without ranking traces,
new landmark searches or invented tolerances. Prior judgments already support
full-excursion review, brief recovery where appropriate and local variability;
no universal numerical criterion is inferred.

The source audit is complete. The researcher has been asked which original
panel or combination mainly guided the marks; no answer is assumed. Clarify
that before another scientific method proposal, without asking for reannotation
or silently replacing the timing trace. No candidate/detector/amplitude rerun,
new correction, production change or substrate mechanism follows. BOI-only
scope, both signs, biological variability, physiological relevance, feasibility,
usability, traceability and existing scientific/cohort/anatomical holds remain.


## R2-CORRECTED-SCORE-SUPPORT-049 — researcher reference clarified and score support checked

The researcher confirms that the middle corrected-intensity trace mainly guides
the judgments, the bottom detection-score view also helps, and the top raw view
is used to check whether the correction has worked. [The recorded clarification
and bounded support audit](reference-results/boi-corrected-score-support-20260914/README.md)
resolve phase 048's reference-panel question without changing earlier marks.
This is a primary/supporting hierarchy, not an exclusive corrected-only protocol;
orange versus dotted bottom traces were not individually specified.

The 32 fixed intervals comprise 30 supplied timing combinations (including two
coordinate sensitivities) and two saved-native references for non-recognized
examples. All 96 corrected/filtered/site-trace rows are independently verified.
The filtered event-footprint score has fewer interior turns in every marked
combination, including 5 versus 1 in example 1 and 63 versus 27 in the HP surge.
It can also emphasize a different signed feature from corrected intensity in
the earlier FB2314 anchors. Fewer turns or shifted extrema are not biological
validation, an automatic boundary criterion, or a pure temporal-filter-delay
estimate. The separately supported site trace remains distinct.

Keep corrected intensity primary and detection score as supporting structure;
keep the raw view for correction quality. Phase 047 used the primary trace and
its failures remain relevant; adding score support is not yet a validated
automatic solution. No source switching by agreement, new filter/correction,
threshold, event exclusion, relabeling or amplitude change was introduced.
All 469 implementation files and earlier evidence remain preserved.

Decision: record the confirmed researcher reference roles and retain production
timing. Next implement this hierarchy as a timing-review view in the existing
MATLAB reviewer, preserving the amplitude-inspection view and exporting signal
roles, source/support identity, availability and frame/time coordinates. The
handoff names existing integration points and bounded checks. No new automatic
timing rule is adopted. BOI-only scope, biological variability, physiological
relevance, feasibility, usability, traceability and unresolved anatomical,
cohort, HP identity and independent-validation requirements remain in force.


## R5-TIMING-REVIEW-UI-050 — saved-stage timing view implemented

The existing MATLAB event reviewer now includes **Timing review**, with corrected
intensity primary, separately labeled event-footprint and site detection scores
as supporting context, and optional raw/correction-quality inspection. Event and
frame selection are synchronized with amplitude inspection. Saved one-based
sample bounds and modeled elapsed time are explicit; the external 1 Hz clock
remains authoritative and exposure duration remains separate.

Missing or malformed stages remain unavailable; nonfinite samples remain gaps.
The already removed trend is raw minus saved corrected intensity only when their
shared input is recorded, with no new fit or substrate model. Saved amplitudes,
baselines, event signs, researcher marks and uncertainty are unchanged. No
recognition threshold, boundary snapping or phase 047 candidate is adopted.

[Implementation evidence](reference-results/boi-timing-review-ui-20260914/README.md)
records 27 passing event/connected-review tests, final timing-specific checks,
exact preservation of every previous measurement field across 346 FB2314 events,
1,245,600 exact saved-stage samples, independent export verification and rendered
current/historical views. The actual older HP audit with absent stages opens
and exports with those stages explicitly unavailable. These are developer
checks, not physiological validation or an independent researcher walkthrough.

New event exports use schema 5 and include timing signal roles, input/support
identity, availability, selected event/bounds and frame/time provenance. The
measurement dictionary and baseline diagnostic retain their existing definitions.
Four existing MATLAB files change and two helpers are added; the remaining 465
are unchanged. Prior evidence and phase-start versions remain preserved.

The bounded UI phase is complete. Use the new view for subsequent researcher
boundary review. Biological variability, physiological relevance, feasibility,
usability, traceability, BOI-only scope and unresolved cohort, anatomical,
HP identity and independent-validation requirements remain in force.


## R2-TIMING-UI-FEEDBACK-051 — first researcher review in the new tab

The researcher confirms the MATLAB timing view is open. For FB2314 awake,
sink site 15 / event 36 (audit row 186), onset **1154 remains preferred**, with
**1149** a defensible alternative. Offset is **1166 or 1167**, with the detection
score mentioned as context; no unique offset or specific score curve is inferred.
[The verbatim feedback and provenance](reference-results/boi-timing-ui-feedback-20260914/README.md)
preserve these as discrete frame alternatives alongside the earlier 1154–1167
judgment. The earlier marks were shown in the review prompt, so this is not
blinded or independent evaluation. No production timing, correction, amplitude,
label or application annotation storage changes. The broader timing criterion
and existing scientific holds remain unresolved; further researcher review is
pending.


### Timing-view feedback 02 — saved surge site 5 / event 1

The researcher replies **177–195** for FB2314 awake audit row 321 in the
MATLAB timing view: onset frame 177, offset frame 195. The earlier onset
177-or-178 / offset 195 judgment remains preserved; no additional rationale or
tolerance is inferred. [Feedback 02 and provenance](reference-results/boi-timing-ui-feedback-20260914/feedback-02.md)
record the conversational event association, exact saved evidence and earlier
annotation. No direct screen inspection, independent validation, event relabeling,
automatic timing update or amplitude recalculation occurred.


### Timing-view feedback 03 — saved surge site 1 / event 3

The researcher replies **496–516** for FB2314 awake audit row 308: onset
frame 496, offset frame 516. This repeats the earlier nominal bounds;
the prior possible onset 496–498 and recovery 514–516 remain preserved.
[Feedback 03 and provenance](reference-results/boi-timing-ui-feedback-20260914/feedback-03.md)
retain the exact reply and conversational event association. No new rationale,
withdrawal of uncertainty, independent validation or production change is inferred.


### Timing-view feedback 04 — saved surge site 1 / event 4

The researcher replies **526–556** for FB2314 awake audit row 309: onset
frame 526, offset frame 556. Onset is 10 frames earlier than the prior nominal
536–556 judgment and outside its earlier 536–538 onset envelope; offset is
unchanged. [Feedback 04 and provenance](reference-results/boi-timing-ui-feedback-20260914/feedback-04.md)
preserve both judgments. No typo, new rationale, curve reference or tolerance
is inferred. The feature supporting onset 526 remains an open researcher
question. No production timing, correction, amplitude or label changes occur.


### Timing-view feedback 05 — explicit correction to 536–556

The researcher explicitly corrects the preceding entry: **536, not 526**.
The current annotation for FB2314 awake, saved surge site 1 / event 4 (audit
row 309), is **536–556**, matching the original nominal judgment.
[The correction and revision history](reference-results/boi-timing-ui-feedback-20260914/feedback-05.md)
supersede feedback 04's onset 526; it remains historical, not a current
alternative. The question about a feature supporting 526 is withdrawn.
Earlier uncertainty is preserved. No production calculation or label changes.


## R2-TIMING-UI-SYNTHESIS-052 — four follow-up reviews compared

[The comparison](reference-results/boi-timing-ui-synthesis-20260914/README.md)
resolves the current references to sink 15/36: onset 1154 preferred or 1149,
offset 1166 or 1167; saved surge 5/1: 177–195; surge 1/3: 496–516; surge 1/4:
536–556. The explicitly corrected entry 526 is excluded from the current
comparison while its history remains preserved. These are four familiar events
from one FB2314 awake recording, not independent validation.

The existing wider T3 declining branch reaches a supplied offset in all four,
but begins 1, 3 and 5 frames early in the latter three cases. Both directional
branches and all 28 comparisons with the seven current boundary combinations
remain visible. At anchor offsets 516 and 556, corrected intensity has a local
maximum while both supporting scores have a local minimum. Score peak snapping
is therefore unsupported. T2 often captures only part of the marked excursion.
Neither T3 nor a human-selected endpoint hybrid is adopted. Earlier cross-recording
failures, including the long HP surge offset and two non-recognized examples,
remain binding.

All 90 copied boundary-neighbor values and all endpoint differences are checked;
32 prior feedback artifacts and every MATLAB implementation file remain unchanged.
No candidate, detector, correction or amplitude rerun was performed. The bounded
next step is a saved-trace diagnostic exposing competing corrected shoulders,
their score context and barriers across the ten existing reviewed examples,
without ranking, new smoothing or automatic boundary assignment. Its scope,
outputs, verification and feasibility limits are specified in NEXT-STEP.md.
BOI-only scope, biological variability, physiological relevance, usability,
traceability, anatomical/identity/cohort uncertainty and independent validation
remain requirements.


## R2-BOUNDARY-AMBIGUITY-053 — competing shoulders inventoried

[The completed diagnostic](reference-results/boi-boundary-ambiguity-20260914/README.md)
exposes 323 eligible shoulders across 20 directional branches in the ten
previously reviewed examples. The frozen seeds, search limits and exact plateau
rules are retained. All 668 extrema, 76 observed T2/T3 boundary selections,
10,800 source rows and 3,876 shoulder sample values are verified. One branch
retains an unbracketed seed; neither negative recognition case receives human
boundaries. Ten final labeled figures are inspected. This is numerical/display
verification, not independent biological validation.

The first case's plausible 1149 onset is outside the neighbor-partition search
start 1151. Several supplied marks are beside rather than on exact turns.
For the anchors, higher earlier shoulders compete with the researcher's later
onsets; at 531 versus 536, about 0.30 corrected source units decide T3's earlier
choice. The long HP surge has many eligible recoveries, including the marked
356, but the strongest rule chooses the later 417. The non-recognized examples
also contain many eligible extrema. Existence of a turn does not establish event
presence, and the current evidence does not justify a universal ranking rule.

Production timing remains unchanged. Search-window eligibility, exact sample
selection and grouping fluctuations into a full excursion remain distinct
scientific questions. The next useful implementation is editable researcher
boundaries/alternatives/reasons with revision history in the MATLAB reviewer,
kept alongside automatic results and without silent amplitude recalculation.
Any later automatic selection hypothesis must be frozen and evaluated against
all 48 existing events with both signs and every earlier failure retained.
All 471 MATLAB files and prior evidence remain preserved. BOI-only scope,
biological variability, physiological relevance, feasibility, usability,
traceability and unresolved anatomy, HP identity, cohort eligibility and
independent-validation requirements remain in force.

## 14 September 2026 — editable researcher boundaries completed

Phase **R5-RESEARCHER-BOUNDARIES-054** implements the bounded next step from
phase 053. The existing MATLAB reviewer now supports recognition judgments,
discrete onset/recovery alternatives, optional preferences, reviewer/reason,
per-event drafts and complete revision history. Each save creates a new
self-contained file bound to the saved audit, raw source and event identity;
old files are preserved. Reopening and export are implemented. Purple saved
manual overlays are distinct from automatic/native bounds. Unsaved drafts
remain session-only and are excluded from plots/exports; closing warns before
discard. Empty endpoints and non-recognition do not become biological zeros.

**30 focused tests pass.** All original review fields for **346** representative
events remain exact, including **1,245,600** saved stage values. Two selected
trace exports are byte-identical to the phase-start implementation, and both
exported histories reopen. Four rendered views are inspected. Five existing
MATLAB review/test files changed, five helpers were added, and the other
466 prior MATLAB files are unchanged. All 70 preceding phase artifacts are
preserved, including snapshots of these ledgers. See
[implementation, verification and limits](reference-results/boi-researcher-boundaries-20260914/README.md)
and the updated [reviewer workflow](BOI_EVENT_REVIEW_WORKFLOW.md).

No detector, correction, baseline, amplitude, native mask or statistics method
changed. Export schema is 6; the measurement dictionary and scientific method
versions are unchanged. This is developer verification, not independent
physiological validation or release acceptance. QA revision files are explicitly
labelled development fixtures. Existing researcher feedback is not silently
migrated; its original alternatives, reasons and corrected 536–556 revision
remain authoritative in phase 051. Next is a researcher save/reopen walkthrough;
any later feedback migration must retain original source records and dates.
Automatic selection, cohort eligibility, reviewed anatomy, HP identity and
normalization questions remain open. BOI-only scope, biological variability,
physiological relevance, feasibility, usability and traceability remain in force.

## 14 September 2026 — four actual researcher revisions verified

Follow-up **R5-RESEARCHER-BOUNDARIES-054-W4** completes the bounded guided
four-example entry/persistence check. The researcher saved four entries;
assistant MATLAB checks reopened them and verified all four exports, exact MAT
snapshots and 44 artifact checksums. All earlier entries, original review files,
audit data and measurement fields are unchanged. The entries remain `uncertain`.
This is not independent physiological validation or full release acceptance.

Current choices are 536–556 (site 1/event 4), 496–516 (site 1/event 3), 177–195
(site 5/event 1), and onset alternatives **1149/1153**, **1153 preferred**, with
recovery alternatives **1166/1167** and no preference (sink site 15/event 36).
The researcher explicitly confirmed that **1153 is intentional**, resolving
the discrepancy with earlier 1154. This is a recording-frame choice, not
elapsed seconds. The earlier 1154 review and the new clarification are both
preserved. No new application revision or correction was authored by the
assistant. See [current review, clarification and exports](reference-results/boi-researcher-boundary-walkthrough-20260914/revision-04/README.md).

Next: compare reviewed and saved automatic durations with endpoint spans and
inclusive sample counts explicitly separated; preserve all alternatives.
Manual marks do not change baseline, amplitude or native masks. Automatic
ranking and its 48-event evaluation remain separate open work. BOI-only scope,
biological variability, physiological relevance, feasibility, usability,
traceability, anatomical uncertainty, HP identity and cohort gates remain.

## 14 September 2026 — reviewed duration comparison completed

**R2-REVIEWED-DURATIONS-055** compares the four actual saved researcher entries
with their automatic measurement and native detection bounds. Seven explicit
reviewed intervals are retained. Elapsed endpoint spans increase by 8 s
(surge site 1/event 4), 9 s (site 1/event 3), 8 s (site 5/event 1), and 4 or 5 s
for the sink with preferred onset 1153. Alternative onset 1149 gives an increase
of 8 or 9 s. Sink recovery choices remain 1166/1167 without a preference.
Native detection for this sink spans 7 s versus the saved measurement's 9 s;
these references remain distinct.

The existing BOI-M04 duration counts inclusive frames. At 1 Hz it is one
second greater than elapsed time between the endpoint samples. Both
conventions are shown separately; same-convention duration differences are
identical. No duration, amplitude, baseline or native-mask field is overwritten,
and the dictionary/scientific method version is unchanged. See
[comparison and limits](reference-results/boi-reviewed-duration-comparison-20260914/README.md).

An independent MATLAB check verifies four events, seven reviewed intervals,
eight automatic/native intervals and 127 human sample memberships against
saved membership/time vectors. All 476 MATLAB files and earlier artifacts
remain preserved. This guided single-recording diagnostic is not physiological
validation or a universal boundary-extension rule. Next is a saved-prebaseline
compatibility check against the actual reviewed intervals, preserving the old
reference and measurements. BOI-only scope, biological variability,
physiological relevance, feasibility, usability, traceability and all earlier
anatomy, identity, cohort and normalization questions remain in force.

## 14 September 2026 — saved baseline overlap check completed

**R2-REVIEWED-BASELINE-OVERLAP-056** intersects the actual saved baseline-candidate
lists with all seven reviewed intervals. Site 1/event 4 retains 20 samples but
frames 536–539 (four) lie in its 536–556 reviewed interval. Site 1/event 3 also
retains 20; frames 496–502 (seven) lie inside 496–516. Site 5/event 1 retains
zero samples and was already unavailable. Sink site 15/event 36 retains 14/20;
1154–1155 overlap every onset/recovery combination. Its baseline was already
unavailable. An empty overlap for the empty list is not compatibility evidence.

Removing overlapping retained samples alone would leave 16, 13, 0 and 12,
all below the original requirement of 20. These are set counts, not new
references. The two finite saved baselines/amplitudes remain computations of
the original automatic windows; they are not silently reinterpreted as manual-
interval amplitudes. Missing values, signed amplitudes, correction and native
masks remain unchanged. See [exact lists, implications and limits](reference-results/boi-reviewed-baseline-overlap-20260914/README.md).

Independent MATLAB verification checks 54 retained memberships, 80 original
candidate memberships and all seven reviewed intervals against the actual
audit. All existing measurement fields, original files and 476 MATLAB files
remain unchanged. Next is availability under the unchanged immediate 20-frame
rule before the reviewed onsets, reusing prior evidence and reporting exact
exclusions. No fallback mean, earlier search or new correction is adopted.
All BOI scientific, anatomical, identity, cohort and validation gates remain.

## 14 September 2026 — immediate prebaseline availability verified

**R2-REVIEWED-PREBASELINE-057** applies the unchanged sample rule to exactly
20 frames immediately before each current reviewed onset. Eligible counts
are 20/20 for onset 536 (516–535), 20/20 for onset 496 (476–495), 0/20 for
177 (157–176), 15/20 for preferred 1153 (1133–1152), and 19/20 for alternative
1149 (1129–1148). Exclusions are respectively none, none, all 20, frames
1148–1152, and frame 1148. All candidates are finite; exclusions are saved
both-sign native support on the original fixed footprint. Offset choices
do not change these five windows. No mean or amplitude was calculated.

The two full-count windows and the zero-count window agree with earlier
exact-interval phase-041/045 evidence. MATLAB verification directly intersects
the complete cached native union, checks all four footprints and 4,800 exact
raw values against the actual audit, 4,800 overlap flags, original baseline
memberships and 100 new candidate memberships. All 476 MATLAB files and
original audit/review/cache inputs remain unchanged. See
[results, source binding and limits](reference-results/boi-reviewed-prebaseline-availability-20260914/README.md).

The 516–535 window includes frame 516, the preceding reviewed event's recovery
endpoint, on fixed footprints sharing 9,614 pixels. It remains eligible under
the existing native rule but is flagged for physiological review, not silently
excluded. Twenty eligible samples do not establish a physiologically quiet
baseline or authorize new amplitude values. Next is inspection of the native
detections causing exclusions and this shared endpoint, without relaxing the
sample rule or automatically treating detections as false positives. All BOI
scope, variability, relevance, feasibility, usability, traceability and earlier
scientific/anatomical/cohort uncertainties remain.

## 14 September 2026 — native baseline exclusion contributors inspected

**R2-BASELINE-EXCLUSION-REVIEW-058** attributes all exclusions in the five
reviewed-onset candidate windows to three saved surge events. Before onset 177,
site 4/event 1 (audit row 320) overlaps frames 157–165 and site 2/event 2
(row 315) overlaps 166–176. Before preferred onset 1153, site 1/event 7
(row 312) overlaps the small sink footprint at 1148–1152, declining from
345/348 to 93/348 pixels. The same event accounts for frame 1148 before the
alternative onset 1149. These are substantial target-footprint intersections;
none is automatically rejected as a false positive or relabeled.

Corrected traces, supporting scores, correction QA and native spatial maps
were inspected. Frame 516 is a local maximum in both neighboring-event
corrected traces, shares the preceding reviewed recovery endpoint, and has
zero native overlap. It remains eligible under the existing rule; physiological
reference suitability remains unresolved. Eligible counts stay 20, 20, 0, 15
and 19 for onsets 536, 496, 177, preferred 1153 and alternative 1149. No new
mean, amplitude, correction fit or detection was calculated.

[Inspection, exact contributor identities and figures](reference-results/boi-baseline-exclusion-review-20260914/README.md)
verify 100 candidate memberships, 26 contributor memberships and seven saved
event/master associations. The legacy master-checksum limitation is explicit.
All 476 MATLAB source files, four actual human annotations and 48 sealed
phase-057 artifacts remain preserved. Next is a concrete baseline-policy
proposal for manually reviewed events, separating native sample eligibility,
physiological suitability and original automatic measurements. BOI scope,
variability, relevance, feasibility, usability, traceability and all earlier
anatomical, normalization, cohort and independent-validation gates remain.

## 14 September 2026 — reviewed-event baseline policy proposal prepared

**R2-REVIEWED-BASELINE-POLICY-059** provides a concrete
[readable proposal](BOI_REVIEWED_BASELINE_POLICY_PROPOSAL.md) and
[structured decision record](planning/boi-reviewed-baseline-policy-20260914.json).
Recommendation A retains the immediate 20-sample both-sign native-exclusion
rule at external 1 Hz and flags reviewed recovery contact without a new veto.
A future reviewed optical calculation would be a separate exploratory result,
with the original fixed footprint/preserved-input source and all alternatives
retained. Numerical eligibility, recognition and physiological suitability
remain distinct. All five rules are proposed; no adoption is recorded.

The two site-1 windows retain 20/20 eligible samples under A. The 177 window
has 0/20; preferred 1153 has 15/20 and alternative 1149 has 19/20. Alternative
B would additionally exclude the shared reviewed endpoint 516, leaving 19/20
before onset 536. This is explicit set-count sensitivity for the four saved
reviews, not a new baseline mean, amplitude, detector result or cohort claim.
No reference substitution, event rejection, correction model or onset change
is adopted. Current preferred onset remains 1153.

[Verification and preservation](reference-results/boi-reviewed-baseline-policy-20260914/README.md)
check five windows, seven reviewed combinations, four unchanged annotations,
ten input hashes, all 476 MATLAB files and 78 sealed phase-058 artifacts.
Next implementation is a read-only reviewed-reference preview with exact
exclusions and contributor links. Derived amplitude/integral calculation
requires policy selection and versioned definitions. The dictionary and
original automatic outputs remain unchanged. All BOI scientific, anatomical,
variability, feasibility, usability, traceability and validation gates remain.

## 14 September 2026 — reviewed-reference preview implemented and verified

**R5-REVIEWED-REFERENCE-PREVIEW-060** adds a read-only **Reviewed reference**
tab to the existing MATLAB event reviewer. Saved onset alternatives show
candidate frames, proposed A/B eligibility, corrected intensity, exact native
exclusions and reviewed contacts. Contributor rows open the corresponding
saved event in timing review. Shared fixed-footprint contact has a separate
pixel column from native overlap. Both complete native masters must associate
with the audit; unknown support is never treated as zero. Drafts are excluded
and changed sources/revisions withhold preview or export.

Export schema 7 adds preview JSON/CSV and a separate exact MAT variable while
preserving the original event `Data` snapshot. No reviewed baseline mean,
amplitude, integral, new correction or policy adoption is introduced. The
existing dictionary and quantitative algorithms remain unchanged.

[Implementation, opening instructions and evidence](reference-results/boi-reviewed-reference-preview-20260914/README.md)
include 34 passing focused tests, seven passing final GUI checks, all 346
native-event associations and exact reproduction of 100 real candidate
memberships/26 native contributor memberships. Four final exports and views
were verified; preferred onset 1153 remains intact. Initial failures and prior
renderings are retained. The inventory is 479 MATLAB files: 473 unchanged,
three modified with old bytes preserved and three added. All 46 sealed
phase-059 artifacts are preserved. Next is researcher inspection/policy
selection before separate reviewed optical calculations. BOI-only scope and
all biological, physiological, anatomical, feasibility, usability, traceability,
cohort and independent-validation gates remain open as applicable.

## 15 September 2026 — researcher preferred onset revised to 1154

**R2-RESEARCHER-REFERENCE-FEEDBACK-061** saves the explicit researcher revision
for sink site 15/event 36 (row 186): preferred onset 1154 replaces 1153;
earlier alternative 1149 and recovery alternatives 1166/1167 remain intact.
The new immutable review-05 preserves the full earlier history and uncertain
recognition. The researcher explicitly includes both frames 1152 and 1153
in the baseline, with the exact conversation statements retained separately.

For candidate frames 1134–1153, the native rule gives 14/20, excluding
1148–1153. A separate membership diagnostic honoring only those two human
inclusions gives 16/20; 1148–1151 remain excluded and unadjudicated. No mean,
reviewed amplitude, native mask/sign change or global exception is introduced.
The native-only GUI preview remains at 14/20; the human frame judgment is a
separate saved record. [Feedback, provenance and reload instructions](reference-results/boi-researcher-reference-feedback-20260915/README.md).
All 479 MATLAB files, earlier annotations/measurements and 339 sealed phase-060
artifacts remain preserved. Next is judgment of the remaining four frames,
with all standing BOI scientific and traceability requirements unchanged.

## 15 September 2026 — complete reference accepted for preferred onset 1154

**R2-RESEARCHER-BASELINE-ACCEPTANCE-062** records the researcher's explicit
“yes absolutely” for inclusion of frames 1148–1151. With the previously
accepted 1152/1153, the full 1134–1153 reference now contains 20/20 samples
under this local human judgment. Native-rule eligibility remains 14/20;
no detection/mask is changed or declared false positive. Boundary revision 05
still prefers onset 1154, with recovery alternatives 1166/1167 and uncertain
recognition unchanged. This judgment applies only to that preferred onset,
not alternative 1149 or other events.

[Exact feedback and separate membership records](reference-results/boi-researcher-baseline-acceptance-20260915/README.md)
preserve the prior judgment and all 59 sealed phase-061 artifacts. All 479
MATLAB files remain unchanged. No mean, reviewed amplitude/integral, global
rule or resting-oxygen claim is introduced. Next is the 516–535 reference for
site 1/event 4, especially its shared recovery endpoint 516. All standing BOI
scientific, biological and traceability requirements remain in force.

## 15 September 2026 — event 4 reference accepted, including frame 516

**R2-EVENT4-REFERENCE-ACCEPTANCE-063** records the researcher's “i thinks it
loks perfect” in response to review of reference 516–535 and its recovery
endpoint contact at 516. All 20 samples are accepted for saved surge site
1/event 4 (row 309), reviewed interval 536–556. Native eligibility was already
20/20; the 9,614-pixel shared fixed-footprint contact with preceding event 3
remains visible. Acceptance of 516 here is not a global endpoint rule.

[Exact judgment and source binding](reference-results/boi-researcher-event4-reference-20260915/README.md)
retain the original native results, uncertain recognition and unchanged
boundary revision 05. No reference mean or reviewed amplitude was calculated.
All 479 MATLAB files and 22 sealed phase-062 artifacts remain preserved.
Next is the 476–495 reference before onset 496 for site 1/event 3. Standing
BOI scientific, biological, physiological and traceability requirements remain.

## 15 September 2026 — event 3 reference accepted

**R2-EVENT3-REFERENCE-ACCEPTANCE-064** records the researcher's “thats the
baseline” in response to review of frames 476–495 before onset 496. All 20
samples are accepted as the local reference for saved surge site 1/event 3
(row 308), with reviewed boundaries 496–516 unchanged. The verified preview
has 20/20 finite, native-eligible samples and no reviewed contacts.

[Exact judgment and source binding](reference-results/boi-researcher-event3-reference-20260915/README.md)
retain boundary revision 05, uncertain recognition and original measurements.
No reference mean, reviewed amplitude/integral or global policy was introduced.
All 479 MATLAB files and 28 sealed phase-063 artifacts are preserved. Next is
reference 157–176 before onset 177 for site 5/event 1 (row 321), whose native
exclusions remain separate from the pending human reference assessment.
BOI-only scope, biological variability, physiological relevance, feasibility,
usability, traceability and unresolved scientific questions remain in force.


## 15 September 2026 — shorter reference selected before onset 177

**R2-SHORT-REFERENCE-JUDGMENT-065** records a shorter researcher-selected
reference for saved surge site 5/event 1 (row 321), reviewed interval 177–195.
The researcher identifies another pocket approximately 155–165 and selects
165–176 inclusive as the reference for the pocket starting at 177. This gives
12 samples at 1 Hz; frame 165 is deliberately retained as stated, despite its
shared position at the approximate preceding pocket endpoint. The earlier
157–164 part of the proposed 20-frame window is not selected.

All 12 selected samples are finite, but native overlap eligibility remains
0/12: row 320 contributes at 165 and row 315 at 166–176. This records local
human reference suitability separately from native detections; it neither
identifies the observed preceding pocket conclusively with row 320 nor calls
row 315 false positive. Twelve samples do not satisfy the original 20-sample
requirement. No automatic fallback, policy adoption, native/sign change,
reference mean or reviewed amplitude/integral is introduced.

[Exact feedback, membership and source binding](reference-results/boi-researcher-short-reference-20260915/README.md)
preserve boundary revision 05, uncertain recognition, all 479 MATLAB files
and 26 sealed phase-064 artifacts. All four preferred-onset examples now have
local reference judgments. Alternative onset 1149 and general quantitative
reference rules remain unresolved. Next is to expose these separate judgments,
including a shorter interval, in the MATLAB reviewer before any new derived
measurement. BOI-only scope, biological variability, physiological relevance,
feasibility, usability, traceability and all other open scientific questions
remain standing requirements.


## 15 September 2026 — researcher reference selections displayed

**R5-RESEARCHER-REFERENCE-DISPLAY-066** displays the four saved local
reference judgments in a fresh MATLAB event reviewer. Blue rings and a
separate membership column show researcher selections alongside unchanged
native exclusions and reviewed contacts. The summary identifies frames,
actual sample count, native-eligible count within that selection, original
sample requirement, reviewer, date and decision ID. The 165–176 selection
remains 12 samples and does not pass the original 20-sample requirement.
Alternative onset 1149 stays unjudged; the 1134–1153 selection applies to 1154.

The loader binds each judgment to the loaded boundary checksum, saved event
identity and annotation, and supports selections within the displayed
preceding 20-second candidate. Changed, duplicated or malformed sources are
rejected. Failed replacement clears the old attachment. Export schema 8 and
preview schema 2 preserve exact judgment documents, paths and hashes with
separate membership; original event Data and measurements are unchanged.
No new reference mean, amplitude/integral, correction, native mask, event sign,
recognition status or global baseline policy is introduced.

[Launcher, code and verification](reference-results/boi-researcher-reference-display-20260915/README.md)
record 37 passing regression tests plus four passing final focused tests
(38 distinct tests), four visually inspected final examples, all 346 native
event associations and 56 checked final export artifacts. Five existing
MATLAB files changed with prior bytes retained; 474 remain unchanged and one
helper was added (480 total). All 30 sealed phase-065 artifacts are preserved.
Initial failed attempts remain recorded. This display increment is complete;
next is researcher use of the updated display, then explicit versioned
measurement-policy work before any derived reviewed quantities. BOI-only,
biological variability, physiological relevance, feasibility, usability,
traceability and unresolved scientific/independent-validation gates remain.


## 15 September 2026 — reviewed optical definition drafted

**R2-REVIEWED-OPTICAL-DEFINITION-067** prepares a separate proposed
reviewed-optical contract and supplemental dictionary, version 0.1.0-draft.
Exact researcher-selected frames define the new reference; 165–176 gives
12 complete selected samples while still failing the original automatic
20-sample rule. Native overlap and recovery contact remain visible context.
This is a new proposed local measurement branch, not a change to the earlier
native-only proposal, automatic results or global scientific policy.

The [readable definition](BOI_REVIEWED_OPTICAL_DEFINITION_PROPOSAL.md)
retains the preserved-input fixed-footprint trace and specifies the reference
mean, signed minimum/maximum, separately labeled saved-sign directional
amplitude, signed rectangle-sum integral and explicit timing conventions.
All negative values, exact extremum ties, discrete alternatives and uncertain
recognition remain visible. There is no new decline model or denominator
substitution. A shorter reference has an explicit count and no assumed equal
precision or universal minimum physiological duration.

[Source-bound preflight and preservation](reference-results/boi-reviewed-optical-definition-20260915/README.md)
check seven saved intervals: five have accepted reference selections, two
at onset 1149 remain unjudged. All event samples and selected reference
samples are finite; no new recording reference mean, amplitude or integral
was calculated, and the reference-mean guard remains unevaluated. Four
supplemental draft definitions and synthetic teaching arithmetic were checked.
All 480 MATLAB files, original dictionary/pipeline contract, actual judgments,
316 sealed phase-066 artifacts and the subsequent usability feedback remain
preserved. Next is a separate read-only exploratory calculation preview under
this draft, not cohort aggregation or global policy adoption. All BOI,
biological, physiological, feasibility, usability, traceability and unresolved
scientific/independent-validation requirements remain in force.


## 15 September 2026 — reviewed optical preview calculated and verified

**R2-REVIEWED-OPTICAL-PREVIEW-068** implements a separate read-only
**Reviewed optical** tab and export under the pinned supplemental draft
0.1.0 definition. Exact accepted reference frames give a preserved-input
fixed-footprint mean, signed extrema with all ties, separately labeled
saved-sign amplitude and signed rectangle-sum integral. The view retains
original automatic results, actual reference count/native overlap, reviewed
bounds, duration/endpoint span, preferences and uncertain recognition.

Five of seven saved boundary combinations now have computed exploratory
results; the two using onset 1149 remain unavailable because no reference
was accepted for that onset. For row 321, reference 165–176 remains exactly
12 samples, with 0 native-eligible samples within the selection; its minimum
signed optical change is −14.1681% and maximum +6.0209%. These are descriptive
preserved-input changes, not oxygen concentration or a sign reclassification.
All earlier automatic measurements remain exactly equal to their prior MAT
exports. The 20-sample production rule and native masks remain unchanged.

[Launcher, full results and verification](reference-results/boi-reviewed-optical-preview-20260915/README.md)
record 46 passing regression tests, eight passing final arithmetic/integration
checks and two final GUI/export checks, plus all 346 native associations,
seven boundary combinations and 80 final export hashes. Five final views were
visually inspected. Missing/nonpositive references, missing event samples,
nonfinite derived arithmetic, stale sources and definition drift withhold
results explicitly. An unavailable plot keeps the real frame range and has
no zero trace. Export schema 9 retains new quantities separately from original
Data, with exact samples, definition documents and source/software provenance.

Five prior MATLAB files changed with earlier bytes retained; 475 are unchanged
and five files were added (485 total). All 71 sealed phase-067 artifacts,
actual judgments and earlier rendering/export passes are preserved. This
calculation-preview increment is complete. Next is inspection of the reference
mean and signed trace, then claim-specific interpretation; no global baseline
policy, biological recognition, cohort admission or independent validation is
adopted. BOI-only scope, biological variability, physiological relevance,
feasibility, usability, traceability and all unresolved scientific gates remain.



## 15 September 2026 — original versus reviewed optical comparison complete

**R2-REVIEWED-AUTOMATIC-COMPARISON-069** compares the four guided FB2314
examples using all seven saved boundary combinations. Five reviewed intervals
have exploratory optical results, two using unjudged onset 1149 remain
unavailable, and only two have valid optical measurements on both sides.
Original missing measurements remain missing; no partial original reference
is averaged and no missing difference is replaced by zero.

For rows 309 and 308, reviewed reference means are respectively 0.4598% and
0.3948% higher, while intervals are eight and nine sample-count seconds longer.
Signed minima change from −7.9420% to −8.3634% and from −9.1645% to −9.5218%.
Saved-sign amplitude is separately compared using the unchanged sink/minimum
and surge/maximum conventions. Its sign does not establish biological event
identity. Original retained reference frames overlap newly reviewed intervals
by two samples (186), four (309) and seven (308). Both reference and bounds
changed; this direct comparison estimates no isolated or causal contributions.

The [readable comparison](BOI_REVIEWED_AUTOMATIC_COMPARISON.md) and
[evidence packet](reference-results/boi-reviewed-automatic-comparison-20260915/README.md)
retain exact frames, values, original/reviewed statuses and a visually checked
four-panel figure. MATLAB replay verified identities, fixed footprints, raw
traces and original baseline/amplitude/mean/integral against pinned sources.
All 18 input hashes, 485 existing MATLAB files and 613 sealed phase-068
artifacts are preserved. The later “thats fine” feedback remains separately
recorded as positive local feedback, without new scientific adoption.

This comparison phase is complete. Next is to specify a separate transfer
check on additional BOI recordings; the four guided examples do not provide
independent validation. Reference precision/duration, native sign versus
pocket morphology, physiological interpretation, anatomy, normalization and
cohort eligibility remain unresolved. The existing 48-event timing challenge
still applies to later timing/detector changes. BOI-only scope, biological
variability, physiological relevance, feasibility, usability and traceability
remain standing requirements. No production code, measurement definition,
correction, native mask, saved recognition status or cohort policy changed.


## 15 September 2026 — additional local transfer candidates prepared

**R3-TRANSFER-READINESS-070** fixes four candidates before new source access:
FB2420 (first GFAP-ECS CSV row without a recorded identity issue), FB2311
(first GFAP-GeNL), FB2402 (first hSyn-GeNL), and FB2410 (documented trigger-tag
conflict). No new event outcomes were used for selection, and no failed-case
substitution was allowed. All retain descriptive transfer-preparation roles;
prior external tuning/inspection history remains unknown. FB2311's archive
series link is retained; other labels' absence from the ledger is not proof
of complete DANDI absence or independent biological replication.

All four source TIFFs are present, match the earlier dimensions/byte counts,
and have distinct current full hashes matched by MATLAB import. These are
first-recorded full hashes for these inventory entries, not historical byte
equivalence. Four named reference candidates match their earlier hashes;
reference pixels/alignment remain unassessed. The source CSV is unchanged.
Workspace links avoid source copies; separate hashed declarations preserve
confirmed external 1 Hz and the FB2410 internal-tag conflict. No new exposure,
physical calibration, anatomical mask or biological label was invented.

The unchanged MATLAB import review passed all four in 3.75–5.74 seconds each,
excluding startup, with `descriptive_input_requires_scientific_review` status.
Unknown frame validity, exposure consistency, preparation, source history,
calibration and tissue remain QC. No detector, new optical calculation, legacy
outcome inspection or image-pixel interpretation was performed. All 485 MATLAB
files and 36 sealed phase-069 artifacts are preserved; no scientific rule or
cohort eligibility changed.

[Preparation report](BOI_TRANSFER_READINESS.md) and
[evidence packet](reference-results/boi-transfer-readiness-20260915/README.md)
retain frozen selection, source/declaration hashes, complete MATLAB QC,
readiness outputs, timings and preservation. This phase is complete. Next is
source/tissue and preparation assessment, starting with FB2420, then a distinct
frozen event-review queue before accessing new event outcomes. Do not transfer
FB2314 annotations to these recordings. BOI-only scope, biological variability,
physiological relevance, feasibility, usability, traceability and unresolved
scientific questions remain standing requirements; the 48-event development
challenge remains applicable to later detector/timing changes.


## 15 September 2026 — FB2420 source/reference assessment complete

**R1-FB2420-SOURCE-SUPPORT-071** inspects the metadata-selected BOI source and
same-folder `490nm after_MMStack_Default.ome.tif` reference. A prespecified
all-frame summary, six fixed snapshots and three 30-frame means show visually
corresponding large-vessel landmarks in their native grids. This supports
working outline review, not exact registration, a surgical boundary or dynamic
validity. Irregular outer margins and the dark left/lower-left area remain
uncertain; no intensity threshold, corner crop, mask or exclusion is adopted.

All 1200 BOI headers record 960 ms exposure and external triggering. This is
new all-frame setting evidence, separate from exact user-confirmed 1 Hz cadence;
prior declarations remain unchanged. Whole-field brightness rises from 952.415
to a maximum 2042.302 at frame 324 before ending at 1314.042. No causal substrate
model or new correction is assigned. No stored sample equals zero or 65535;
that encoding check does not rule out artifacts or sensor clipping.

Brief high-value maxima prompted a bounded, recorded three-frame inspection.
At row 330/column 432, values in frames 16/17/18 are 1642/61564/1796; one neighboring
pixel also rises strongly. This is a localized transient with unresolved cause
and detection impact. No pixel/frame is removed or labelled biological/false.
The original scan and addendum selections remain fixed; failed dependency and
serialization attempts are preserved alongside successful outputs.

[Report and visual comparison](BOI_FB2420_SOURCE_SUPPORT.md) and
[evidence packet](reference-results/boi-fb2420-source-support-20260915/README.md)
retain exact source/patch arrays, acquisition counts, all-frame summaries,
three visually inspected figures and verification. Array transport to MATLAB,
snapshot/patch arithmetic, source/reference/declaration hashes, all 485 existing
MATLAB files and all 53 sealed phase-070 artifacts were checked. No production
code, optical measurement, native mask, event outcome or scientific policy changed.

The source assessment is complete. FB2420 now has documented source-QC/visual
exposure and retains its descriptive transfer role. Next is a provisional
craniotomy/support outline for substantive researcher review, with uncertain
margins and internal darkness explicit. The transient issue remains for artifact
assessment before biological event claims. BOI-only scope, biological variability,
physiological relevance, feasibility, usability, traceability and unresolved
scientific questions remain standing requirements.


## 15 September 2026 — FB2420 outline proposal ready for researcher review

**R1-FB2420-OUTLINE-PROPOSAL-072** creates one provisional native support
polygon from the phase-071 source/reference context. Its 22 recorded vertices
produce 161039 included pixels (61.43% of the image), one connected region and
no holes. This is image geometry, not calibrated anatomical area or an eligible
biological denominator. The dark left/lower-left interior and the known
row 330/column 432 transient location remain included; neither darkness nor the
transient is used to cut a hole.

The reference/source overlay marks particularly uncertain top/left/lower margins
in amber and the row 1 image-edge closure in pink. That top segment is not a
visible surgical border. Cyan segments remain provisional as well. The existing
`reviewBOITissueSupport` helper saves the source-bound logical proposal and
standard frames 1/600/1200 preview. Both that preview and the reference plus
three fixed source-mean overlays were visually checked. Exact vertices, native
mask indices, display limits and source/software bindings are retained.

[Proposal and review focus](BOI_FB2420_OUTLINE_PROPOSAL.md) and
[evidence packet](reference-results/boi-fb2420-outline-proposal-20260915/README.md)
record checks for connectedness, absence of holes, retained dark/transient
locations, unchanged source/acquisition declaration and exact mask checksum.
All 485 existing MATLAB files and all 65 sealed phase-071 artifacts are preserved.
No `BOITissueSupport.json` was written, detector run, source corrected or original
measurement changed. The TIFF reader's unknown-custom-tag warnings are retained;
source reads and proposal assertions passed.

Proposal creation is complete; substantive researcher boundary judgment is
requested and pending. No acceptance is inferred from continuation or technical
rendering. Next is that recording-specific judgment or a preserved revision,
before applying a support decision. Exact registration, dynamic observability,
transient cause/impact, calibration, reference precision and physiological
interpretation remain unresolved. BOI-only scope, biological variability,
physiological relevance, feasibility, usability, traceability and all standing
scientific questions remain in force.


## 15 September 2026 — FB2420 working ROI accepted and recorded

**R1-FB2420-SUPPORT-ACCEPTANCE-073** records the researcher's explicit reply
“I accept” to the phase-072 outline as acceptance of that exact provisional
working static ROI. No vertices or mask pixels changed. The 161039-pixel mask
retains dark interior, uncertain margins, the top image-edge closure and the
known transient location. This is a recording-specific working-support decision;
exact registration, surgical boundary, dynamic validity, transient cause/impact,
calibration, physiological interpretation and independence remain unresolved.

The existing MATLAB tissue writer recorded `BOITissueSupport.json` in a fresh
stage linked to the unchanged source, with the original phase-070 acquisition
metadata copied byte-for-byte. MATLAB import confirms exact native mask equality,
recorded decision/source hashes, reviewed-support QC and retained scientific
review status. Unknown frame validity and other input issues remain visible.
No detector was run and no restricted method was selected implicitly.

[Accepted working support](BOI_FB2420_WORKING_SUPPORT.md) and
[acceptance evidence](reference-results/boi-fb2420-support-acceptance-20260915/README.md)
retain the verbatim reply, proposal/mask/overlay bindings, writer decision,
fresh-stage mapping, exact declaration and full input review. All 485 existing
MATLAB files and 43 sealed phase-072 artifacts are preserved. The older
review-pending proposal is retained as history; this is the subsequent acceptance.

This acceptance/application-to-input phase is complete. Next is the first
source-bound run and event-review plan, with explicit support profile and the
localized transient issue retained before biological interpretation. Source
correction, original measurements and global policies remain unchanged. BOI-only
scope, biological variability, physiological relevance, feasibility, usability,
traceability and all unresolved scientific requirements remain in force.


## 15 September 2026 — FB2420 first accepted-ROI run and first recognition judgment

**R3-FB2420-FIRST-ROI-RUN-074** completes one prespecified full master/statistics
run with the accepted 161039-pixel working ROI and existing `craniotomy-roi-1`
profile. Original correction, default detection/measurement settings and external
1 Hz sampling remain unchanged. All 330 events passed source amplitude/baseline/
status and signed integral/mean replay; masks respect sign-specific support.
184 automatic amplitudes are finite and 146 unavailable; eight finite values
oppose their saved sign and remain unchanged. Technical replay does not establish
physiological event identity.

The frozen queue contains nine unique cases from fourteen prescribed slots.
All-event checks found no direct native, measured or retained-baseline contact
with the inspected frame-17 patch; this does not establish absence of indirect
normalization effects or other artifacts. Selection and contact arithmetic were
reproduced independently. This remains descriptive transfer development, with
previous source-QC exposure and unknown outside tuning history.

For the first case (audit row 34, sink site 6/event 1; measured frames 25–31),
the researcher explicitly answered **“I do not see a pocket”**. Immutable review
revision 1 records `not_recognized` with empty boundaries. Exact question/reply
and source bindings are retained. No automatic result, label, mask or baseline
was changed and no false-positive ground truth was inferred.

Loading that judgment exposed a timing-view bug with empty boundary arrays.
One viewer helper now normalizes manual bounds to a row; its regression test
checks recognized-to-unrecognized loading, clearing of purple marks, retained
automatic bounds and unchanged measurements. The entire event-review test suite
passed. Of 485 MATLAB files, 483 are byte-identical and both edited originals
are preserved. All 38 phase-073 sealed artifacts and 13 pinned inputs verified.
The initial rendering failure and the earlier queue-identity mismatch are
retained. Neither correction reran the full pipeline.

[Run report](BOI_FB2420_FIRST_ROI_RUN.md) and
[evidence packet](reference-results/boi-fb2420-first-roi-run-20260915/README.md)
retain source replay, complete missingness, fixed selection, transient context,
resources, human feedback, code snapshots and artifact hashes. The run used
3.33 GB output and 210.73 seconds inside MATLAB with two workers; the portable
packet omits large binary payload copies while binding their retained local files.

The technical run phase is complete; human review continues with queue position
2, sink site 1/event 1 (native frames 1–44, measured 1–48). Acquisition truncates
its preceding context, and automatic amplitude is unavailable for insufficient
clean prebaseline. Unobserved onset/reference information remains unresolved.
BOI-only scope, biological variability, physiological relevance, feasibility,
usability and traceability remain standing requirements. Anatomy, frame validity,
preparation/calibration, transient impact, reference precision, physiological
interpretation and independence remain open; no global policy or cohort result
was adopted. Later detector/timing changes still require the 48-event challenge.


## 15 September 2026 — FB2420 second recognition and tentative context

**R3-FB2420-RECOGNITION-075** saves the researcher's nonrecognition within the
marked case-2 interval (sink site 1/event 1, automatic frames 1–48). Cumulative
review revision 2 preserves case 1 and adds empty-boundary `not_recognized` for
audit row 1. Separately, the researcher tentatively suggested pockets around
frames 2–28 and 65–84/85 on that displayed footprint trace. Exact language and
approximation are retained; these are not confirmed event identities, native
event splits, precise boundaries, reference windows or measurement inputs.

[Revision-2 evidence](reference-results/boi-fb2420-recognition-review-20260915/revision-02/README.md)
contains the exact reply, source-bound tentative observations, cumulative review,
MATLAB load/render verification and preserved prior artifacts. All 485 MATLAB
files and 219 phase-074 artifacts verified unchanged, with pre-append standing
ledgers saved. No detector or measurement was changed or rerun.

Next is frozen case 3, sink site 3/event 1 (audit row 22, frames 2–4), whose
footprint differs from case 2. Temporal proximity does not establish identity
with the tentative early observation. Human recognition remains pending;
pre-acquisition signal and sufficient clean prebaseline are unavailable.
All standing BOI scope, biological variability, physiological relevance,
feasibility, usability and traceability requirements and unresolved scientific
questions remain in force. No global policy or physiological truth is inferred.


## 15 September 2026 — FB2420 third recognition and contextual pocket

**R3-FB2420-RECOGNITION-076** records case 3 (sink site 3/event 1, audit row 22)
as `not_recognized` at automatic frames 2–4. The researcher judges these frames
as fluctuation when considering the subsequent trace. Separately, the researcher
identifies a pocket starting around frame 7 until likely frame 27 on that
displayed footprint trace. Recognition is retained with approximate timing;
this is not assigned to the rejected event, another native event, a reference
window or a measurement. Identity with the earlier case-2 observation from a
different footprint is unresolved. No detector threshold or global policy changes.

[Revision-3 evidence](reference-results/boi-fb2420-recognition-review-20260915/revision-03/README.md)
retains the exact reply, rationale, approximate observation, cumulative immutable
review and MATLAB verification. Both earlier judgments, all 485 MATLAB files
and 32 prior sealed artifacts are preserved. Automatic source bindings passed;
no detector or measurement was changed or rerun. Next is frozen case 4, sink
site 17/event 1 (native frames 101–160; measured 86–171), with human recognition
pending. All standing BOI, biological variability, physiological relevance,
feasibility, usability, traceability and unresolved scientific requirements persist.


## 15 September 2026 — FB2420 fourth recognition

**R3-FB2420-RECOGNITION-077** saves the exact reply “no pocket” for case 4,
sink site 17/event 1 (audit row 106; measured frames 86–171, native 101–160).
Cumulative revision 4 records `not_recognized` without human boundaries and
preserves the preceding three judgments. No additional rationale, alternative
interval, reference or physiological interpretation is inferred.

[Revision-4 evidence](reference-results/boi-fb2420-recognition-review-20260915/revision-04/README.md)
retains exact feedback, source bindings, immutable history and MATLAB verification.
All 485 MATLAB files and 32 prior sealed artifacts verified; no detector or
measurement changed or reran. Next is frozen case 5, sink site 5/event 2
(audit row 33; native 18–22, measured 18–26), selected for closest same-site
recurrence. Its one-frame native gap is not proof of biological recurrence;
amplitude is unavailable for insufficient clean prebaseline. All standing BOI,
biological variability, physiological relevance, feasibility, usability, traceability
and unresolved scientific requirements persist.


## 15 September 2026 — FB2420 fifth recognition; surge review next

**R3-FB2420-RECOGNITION-078** saves “no i do not see one.” for case 5, sink
site 5/event 2 (audit row 33; measured 18–26, native 18–22). Cumulative revision
5 records `not_recognized` without human boundaries and preserves all earlier
judgments and separately recorded contextual observations. No additional reason
or scientific classification is inferred. All five purposively selected sink
cases now have nonrecognition judgments; this does not establish recording-wide
absence, a false-positive rate, independent validation or permission to tune.

[Revision-5 evidence](reference-results/boi-fb2420-recognition-review-20260915/revision-05/README.md)
retains exact feedback, immutable history and MATLAB/source verification. All
485 MATLAB files and 32 previous sealed artifacts are preserved. No detector
or measurement was changed or rerun. Next is case 6, surge site 3/event 1
(audit row 291; native and measured frames 134–144), selected by the frozen
first-finite-amplitude rule. Human surge recognition remains pending. All standing
BOI, biological variability, physiological relevance, feasibility, usability,
traceability and unresolved scientific requirements persist.


## 15 September 2026 — FB2420 recognized surge with broader human interval

**R3-FB2420-RECOGNITION-079** records “yes, but more from 130 - 150” for
case 6, surge site 3/event 1 (audit row 291). Immutable cumulative revision 6
adds `recognized`, onset 130 and recovery 150, with approximate timing retained
in the reason and exact feedback. No uncertainty width, preferred endpoints,
reference baseline or precise physiological boundaries are inferred. Automatic
native/measured bounds remain 134–144 and all original measurements are unchanged.

[Revision-6 evidence](reference-results/boi-fb2420-recognition-review-20260915/revision-06/README.md)
retains exact feedback, annotations, source hashes and MATLAB verification of
purple human marks separately from automatic marks. The first five judgments,
prior context observations, all 485 MATLAB files and 32 prior sealed artifacts
are preserved. No detector, measurement or correction was changed or rerun.
Next is frozen case 7, surge site 1/event 1 (audit row 279, frames 1–10), selected
by two rules and displayed once. Earlier signal is unobserved and sufficient
clean prebaseline is unavailable. Human recognition remains pending. All standing
BOI, biological variability, physiological relevance, feasibility, usability,
traceability and unresolved scientific requirements persist.


## 15 September 2026 — FB2420 seventh recognition

**R3-FB2420-RECOGNITION-080** records “i dont see a surge there” for case 7,
surge site 1/event 1 (audit row 279, automatic frames 1–10). Cumulative revision
7 saves `not_recognized` with empty human boundaries, preserving all six earlier
judgments, including the recognized surge at approximate frames 130–150.
Pre-acquisition signal remains unobserved, but the explicit nonrecognition is
not relabeled uncertain. No additional rationale, reference or physiology inferred.

[Revision-7 evidence](reference-results/boi-fb2420-recognition-review-20260915/revision-07/README.md)
retains exact feedback, immutable history, source checks and MATLAB verification.
All 485 MATLAB files and 32 prior sealed artifacts are preserved; automatic
results are unchanged and no detector/measurement rerun occurred. Next is case
8, surge site 11/event 5 (audit row 309, native/measured 971–1034), selected for
longest native duration. Automatic amplitude remains unavailable for insufficient
clean prebaseline; human recognition is pending. All standing BOI, biological
variability, physiological relevance, feasibility, usability, traceability and
unresolved scientific requirements persist.


## 15 September 2026 — FB2420 eighth recognition

**R3-FB2420-RECOGNITION-081** records “i do not recognize a surge there” for
case 8, surge site 11/event 5 (audit row 309, native/measured frames 971–1034).
Immutable cumulative revision 8 adds `not_recognized` with empty boundaries and
preserves all seven prior judgments, including the recognized surge at approximate
frames 130–150. No additional rationale, alternative, reference or physiology inferred.

[Revision-8 evidence](reference-results/boi-fb2420-recognition-review-20260915/revision-08/README.md)
retains exact feedback, immutable history, MATLAB verification and source hashes.
All 485 MATLAB files and 32 prior sealed artifacts are preserved; no automatic
result changed and no detector/measurement rerun occurred. The last frozen case
is case 9, surge site 2/event 4 (audit row 283; native/measured 105–126), selected
for closest same-site recurrence. Amplitude is unavailable for insufficient clean
prebaseline. Human recognition remains pending; the nine-case recognition phase
is not yet complete. All standing BOI, biological variability, physiological
relevance, feasibility, usability, traceability and unresolved scientific
requirements persist.


## 15 September 2026 — FB2420 frozen recognition phase complete

**R3-FB2420-RECOGNITION-COMPLETE-082** saves “no surge” for final case 9
(surge site 2/event 4; audit row 283, frames 105–126). Cumulative revision 9
preserves all earlier judgments. All nine frozen examples are reviewed: one
recognized surge with approximate human bounds 130–150 (automatic 134–144),
and eight cases not recognized. These purposive counts are not detector accuracy,
false-positive rate or physiological ground truth. Separate pocket observations
remain source-bound: case 2 possibly 2–28 and 65–84/85; case 3 around 7 to likely
27. Similar timing across different footprints does not establish identity.

[Recognition report](BOI_FB2420_RECOGNITION_REVIEW.md) and
[final evidence packet](reference-results/boi-fb2420-recognition-review-20260915/revision-09/README.md)
retain the complete identity/judgment summary, exact replies, immutable history,
source replay bindings and verification. All 485 MATLAB files and 32 previous
sealed artifacts are preserved. No detector, correction or measurement changed
or reran, no reference baseline was selected, and no automatic output was removed.

This recognition phase is complete; overall scientific reanalysis remains open.
Next is a bounded read-only discrepancy audit of existing stages, spatial support
and event grouping on these nine cases and three contextual observations, before
any method change. The diagnostic plan is recorded but not executed. Later
detector/timing changes need a separate decision and the 48-event challenge.
All standing BOI, biological variability, physiological relevance, feasibility,
usability, traceability and unresolved scientific requirements remain in force.


## 15 September 2026 — FB2420 bounded discrepancy audit complete

**R3-FB2420-DISCREPANCY-AUDIT-083** compares saved full-precision stages, exact
event/site/native support, grouping and reference eligibility for the frozen
nine cases and three contextual pocket observations. No detector or new
correction fit ran, and no original measurement or human judgment changed.

The largest score/primary-trace shape discrepancies are already visible at
within-frame ROI normalization: case 9 corrected/spatial-Z correlation is −0.860
and corrected/filtered −0.865 in the prespecified context. Cases 4/5 retain high
correlation yet were not recognized; the recognized surge has low broader-window
correlation. Therefore no correlation acceptance threshold is justified. Spatial
percentile candidates, lifetime-site timing and fixed-footprint recognition are
different operations; no single smoothing or normalization change is established
as a solution. The original recording-specific correction is preserved.

The tentative case-2 interval 2–28 overlaps the same longer native sink on all
27 frames (mean fixed-footprint coverage 57.81%). The case-2 65–84/85 interval
and case-3 7–27 interval have no retained native sink/surge contact on their
original footprints. This is retained-output absence, not proof about intermediate
candidates or calibrated missed biological events. Cross-footprint identity
remains unresolved. Recognized-surge reference candidate 110–129 has 20 native-
eligible finite samples; physiological quietness and reference precision are not
established, and no reference was selected.

[Audit report](BOI_FB2420_DISCREPANCY_AUDIT.md) and
[evidence packet](reference-results/boi-fb2420-discrepancy-audit-20260915/README.md)
retain all nine stage comparisons, full traces, native contacts, source maps,
code snapshots and checks. MATLAB matched all 330 native identities and completed
the main audit in 33.53 seconds with about 4.19 MB initial output. Python reproduced
54 correlations, 32400 prior-export values, native counts/contacts and 20 reference
rows. All 485 MATLAB files and 35 prior sealed artifacts are preserved.

This audit phase is complete. Next is a bounded design for separate temporal
evidence on the unchanged corrected traces, including both retained candidates
and already reviewed footprints lacking native output. Reference assumptions,
variability/return context, method, resource budget and regressions must be explicit
before implementation. No rule or threshold was fitted or adopted. Later detector/
timing changes still require a separate decision and the 48-event challenge.
All standing BOI, biological variability, physiological relevance, feasibility,
usability, traceability and unresolved scientific requirements persist.


## 15 September 2026 — FB2420 fixed-interval temporal comparison specified

**R3-FB2420-TEMPORAL-SPEC-084** freezes 14 interval records: nine original
automatic measurement intervals, the recognized surge at approximate 130–150,
and three contextual pockets with 84/85 retained as distinct recovery alternatives.
The existing 10/20-sample context scales yield 28 future descriptive rows. The
earlier 48-event candidate comparison is explicitly bound; its failed automatic
boundary/range-screen rules are not silently reintroduced. No boundary search,
pass/fail screen, parameter selection or global policy is adopted.

[Specification](BOI_FB2420_TEMPORAL_COMPARISON_SPEC.md) and
[evidence packet](reference-results/boi-fb2420-temporal-comparison-spec-20260915/README.md)
define separate before/after medians, ranges and unscaled MAD, both signed interval
contrasts and endpoint/context differences in corrected-intensity units. Context
is not an accepted optical baseline. Native/human contact stays visible without
trimming observations; missing flanks produce unavailable dependent descriptors,
not fallback estimates. Original correction, raw optical measurement definitions,
fixed footprints, automatic results and human uncertainty remain intact.

Source preflight matched all 330 native events and verified all 14 intervals: 17
of 28 rows have complete context on both sides; 11 lack preceding acquisition
samples. Ten rows have before-native contact and seven have after-native contact,
separate from completeness. Python reproduced exact frame memberships. All 485
MATLAB files and 143 prior sealed artifacts are preserved. No new temporal
descriptors, baseline or detector outputs were calculated.

Specification/preflight is complete. Next: implement and verify a separate
comparison, then execute once under the frozen 5-minute/50-MiB budget, with at most
one implementation-only corrective round and no retuning. Biological agreement
remains descriptive, with no success threshold. Later detector/timing changes
require their own decision and the 48-event panel. All standing BOI, biological
variability, physiological relevance, feasibility, usability, traceability and
unresolved scientific requirements persist.


## 15 September 2026 — FB2420 fixed-interval temporal comparison completed

**R3-FB2420-TEMPORAL-COMPARISON-085** executed the frozen 14-interval/two-scale
comparison once: 28 rows, 18.20 MATLAB seconds, 1,868,980 initial output bytes.
All descriptors and exact frame/status dependencies were independently reproduced.
Seventeen rows have complete flanks; eleven lack full preceding acquisition
context. Native contacts occur in 10 preceding and 7 following contexts; human
interval associations remain a separate layer. No contact removed observations.

[Report](BOI_FB2420_TEMPORAL_COMPARISON.md) and
[evidence packet](reference-results/boi-fb2420-temporal-comparison-20260915/README.md)
preserve all values, missingness, source/footprint identities, original automatic
rows, saved review, recovery alternatives and the two predetermined illustrations.
Recognized 130–150 surge contrasts depend on which flank/context scale is used;
65–84/85 shares extrema but changes recovery/context ingredients. Nonrecognized
intervals also have sizable directional contrasts. No recognition screen, universal
reference or automatic boundary rule follows from these observations.

Twelve pre-execution known-shape fixtures and native/human contact assertions
passed with independent reproduction. Result checks reproduced 10,800 prior trace
values, all 28 descriptor rows, 1,443 native frame records and 28 human contacts.
A single verifier-only corrective round handled MATLAB's null-to-empty-array
serialization of absent parent-observation metadata. The frozen verifier and
failure record are retained; numeric missingness remains strict. No source rerun,
scientific retuning, production code change, new correction or baseline occurred.
All 485 repository MATLAB files and 31 prior sealed artifacts are preserved.

The bounded phase is complete. Next planned comparison applies unchanged
descriptors to the existing 48-event development panel after binding its intervals
and prior human alternatives; that panel was not rerun here. Later detector/timing
changes require a separate decision and original measurement regression. BOI-only,
biological variability, physiological relevance, feasibility, usability, traceability
and unresolved scientific/eligibility questions persist. This is descriptive
source-exposed development evidence, not independent biological validation.


## 15 September 2026 — existing 48-event temporal panel compared

**R3-PANEL-TEMPORAL-COMPARISON-086** applied the unchanged phase085 descriptors to
all 48 original events across FB2314 awake, FB2316 KX, ID400 awake and provisional
HP ECS. Forty-eight automatic intervals, thirty historical/coordinate alternatives
and seven latest FB2314 alternatives produced 170 two-scale rows. Every row was
independently verified. Current preferred onset 1154, alternative boundaries,
saved uncertain statuses and accepted 165–176 reference remain intact; historical
superseded choices are not used as current human-contact intervals.

[Report](BOI_PANEL_TEMPORAL_COMPARISON.md) and
[evidence packet](reference-results/boi-panel-temporal-comparison-20260915/README.md)
show 91/96 original-interval rows with complete flanks, and 165/170 across all
alternatives. Missing context remains unavailable. Native contact and human
context remain separate flags, not exclusions or physiological reference tests.
The 20-sample window before the 177–195 pocket contacts the approximate preceding
155–165 pocket; the accepted 165–176 reference is not replaced. Nonrecognized
intervals also have positive contrasts, so no recognition threshold is adopted.

Verification reproduced 50,400 corrected samples, 243,193 fixed-footprint pixel
IDs, all descriptor/frame/status values, 10,153 repeated native frame records and
336 human-contact records. Both predetermined illustrations were inspected.
One technical correction handles FrameSize absent from legacy AnalysisInfo by
validating geometry already saved in native site tables. Original metadata and
production loaders remain unchanged. The initial failure and completed FB2314
exports are preserved; run-02 reuses those exports and completes the remaining
recordings. Its successful MATLAB resume took 27.93 seconds and wrote 10.08 MB;
there were no movie reads, detector runs, new corrections or optical baselines.

All 485 repository MATLAB files, 131 prior sealed artifacts and 136 source bindings
are preserved. This bounded phase is complete. Next is an optional MATLAB context
view with accepted references and current/history roles displayed separately,
including explicit legacy compatibility. No biological classifier or timing rule
is adopted. Any later detector/timing change requires a separate decision and
original measurement regression. BOI-only scope, biological variability,
physiological relevance, feasibility, usability, traceability, evaluation exposure
and all unresolved scientific/eligibility questions persist.


## 21 September 2026 — optional context view delivered; proceed with current detection

**R5-CONTEXT-VIEW-087** adds a read-only optional context tab and explicit legacy
context launcher. Accepted references, saved current alternatives and history stay
separate. Six context tests and all 35 existing event-review tests passed initially;
the final six context tests and all 170 saved descriptor rows passed after UI fixes.
Both final screenshots were inspected. Two narrow display correction iterations
were needed, exceeding the initial one-round estimate; earlier evidence is retained.
There were no new detector runs, correction fits or optical baseline calculations.
484 of 485 existing MATLAB files remain unchanged, with one viewer integration
change and ten new implementation/test files. All 479 prior sealed artifacts and
136 bound sources are preserved. [Usage](BOI_TEMPORAL_CONTEXT_VIEW.md) and
[evidence](reference-results/boi-context-view-20260915/README.md).

**R0-PROCEED-CURRENT-DETECTION-088** records the researcher's acceptance of useful
current detection with some mislabeled activity at this stage. Proceed with the
current detector and correction. Do not automatically open another recognition/
timing diagnostic or optimization phase; targeted additional method work needs a
concrete failure affecting a required output or intended comparison. Preserve known
errors, biological uncertainty and source/measurement integrity. This is qualitative
stage-specific acceptance, not a quantified accuracy claim or a resolution of
unrelated cohort identity/calibration/eligibility questions. Exhaustive manual
relabeling is not an implicit prerequisite.

The [updated whole-project overview](BOI_PROJECT_OVERVIEW.md) puts the next work on
consolidating the working analysis specification, recording eligibility, animal-level
statistics, the researcher release walkthrough and the frozen cohort rerun. Optional
viewer delivery is complete; the overall scientific reanalysis is not yet complete.


## 21 September 2026 — working analysis specification consolidated

**R0-R2-WORKING-SPEC-089** consolidates existing definitions and the researcher's
accepted detector limitations into one [working specification](BOI_WORKING_ANALYSIS_SPECIFICATION.md).
All fourteen measurement IDs retain their current dictionary definitions and
proposed roles. Automatic outputs, implemented exploratory reviewed optical
results and optional context remain separate. The current onset 1154 and exact
accepted references supersede older proposal examples without erasing history.
Pre-recording isoflurane state establishment remains unmeasured; no mandatory
intra-file wash-in requirement is reintroduced.

Current useful detection is the working method. No further default detector/timing
optimization or exhaustive manual relabeling is required. Final primary claims,
recording windows/eligibility and comparison-specific animal statistics remain
explicit choices; descriptive output can proceed without pretending those choices
are settled. The next concrete work is an evidence-based eligibility matrix for
the seven C02 candidate pairs, as the existing worked example, not a newly adopted
scientific priority. Reuse resolved source checks and record only affected holds.

This is a documentation consolidation: all 495 MATLAB files, original dictionaries,
source records and 157 preceding sealed artifacts are preserved (updated cumulative
documents have before snapshots). No movie access, diagnostic experiment, detector
run, new measurement or scientific comparison occurred. The
[evidence record](reference-results/boi-working-analysis-spec-20260921/README.md)
checks source hashes, all measurement IDs, exact reference counts and local links.


## 21 September 2026 — seven-pair C02 eligibility evidence matrix completed

**R1-C02-ELIGIBILITY-090** joins the existing source, workflow, support and
measurement records into [14 recording rows, seven pairs and 196 measurement entries](BOI_C02_ELIGIBILITY_MATRIX.md).
All seven candidate mice remain; no new scientific exclusion or final inclusion
is made. Six recordings have identified saved event-run evidence, spanning different
historical/current contracts. Eight lack equivalent event runs in this inventory;
this is missing run evidence, not failed detection or zero events. ID400 and ID401
have historical runs for both states; neither is silently promoted to a current
restricted-profile comparison.

One source-specific working ROI is accepted (FB2314 awake); seven existing outline
proposals remain available but unaccepted. The other six recordings have no reviewed
ROI in this evidence inventory. Earlier whole-pixel equivalence for both states of
FB2314/FB2315/ID402/ID403 remains resolved. External 1 Hz and pre-recording state
establishment remain authoritative; no missing numerical wash-in duration is used
as a hold. Per-metric reference missingness does not erase native coverage.

No movie/source payload, new detector run, tuning, biological comparison, mask or
window adoption occurred. All 495 MATLAB files and 25 preceding sealed artifacts
are preserved. The [evidence packet](reference-results/boi-c02-eligibility-20260921/README.md)
records the joined source versions and consistency checks. This matrix completes
C02 evidence inventory, not final scientific eligibility or the other cohorts.
Next: review the existing FB2314 isoflurane outline, then prepare its matched-profile
run and paired observation-window decision using the current method.


## 21 September 2026 — FB2314 isoflurane accepted-support run completed

**R1-FB2314-ISO-PREP-091 / R1-FB2314-ISO-RUN-092.** The researcher explicitly
accepted the displayed isoflurane outline. The original source-bound mask was
recorded in a fresh stage and applied with unchanged `craniotomy-roi-1` settings.
The [completed run](BOI_FB2314_ISO_RUN.md) preserves dark internal tissue, boundary
uncertainty, exact 1 Hz, original correction, full native indices and all prior
results. Automatic labels remain imperfect and accepted for proceeding.

Both signs' source-amplitude replay and independent native coverage/exposure checks
passed. All 495 MATLAB files remain unchanged. The scientific master parameters
match the earlier awake run; only review-interface files changed in the interim.
Both FB2314 states now have accepted working support and verified restricted runs.
The [matrix update](planning/boi-c02-eligibility-update-20260921-092.json) records
this progress without rewriting the dated inventory or excluding another mouse.

Full [0,1200) is a descriptive modeled extent, not a new final comparison-window
approval. No paired effect, detector retuning, manual event relabeling or universal
baseline change was performed. Next is the paired observation-window decision and
summary, while remaining pairs reuse their existing support proposals.


## 21 September 2026 — first paired FB2314 descriptive summary completed

**R4-FB2314-DESCRIPTIVE-093.** The [paired report](BOI_FB2314_PAIRED_SUMMARY.md)
uses both verified restricted-profile outputs over full frames 1–1200, modeled
[0,1200) seconds at the externally triggered 1 Hz. This is a stated working
descriptive window, not researcher approval of final cohort windows. One mouse
and one recording per state are represented; event counts are not biological N.

Both signs have lower onset rates in the isoflurane recording. Sink coverage and
concurrency are lower; surge coverage and concurrency are higher. Recording- and
sign-specific denominators remain explicit. Conditional optical summaries retain
all finite signed values and their availability counts. Missing amplitudes do not
erase events/coverage or become zero; total sink amplitude-weighted burden remains
unavailable. No inferential or causal claim is made.

All 582 event rows and 4,800 sign/frame rows passed saved-table aggregation checks.
The detector, original correction, source data and all 495 MATLAB files are
unchanged. Prior evidence is preserved, with before snapshots of these cumulative
documents. Current researcher-reviewed alternatives remain separate. No new
diagnostic panel, scientific exclusion or unmeasured baseline requirement is added.

This completes the first paired descriptive output. Next, extend the current
method to the next C02 pair using the existing FB2315 recording-specific outline
proposals. Final outcomes, windows, measurement admission, animal-level statistics
and cohort freeze remain open, without making another detector experiment a
prerequisite.


## 21 September 2026 — FB2315 awake accepted-support run completed

**R1-FB2315-PREP-094 / R1-FB2315-AWAKE-RUN-095.** Both original FB2315
sources match the recorded hashes and existing outline proposals. Original filenames
containing FB2314 remain preserved; resolved canonical identity is FB2315.
The researcher explicitly accepted the awake working outline. Its
[current-method run and numerical verification](BOI_FB2315_AWAKE_RUN.md) are complete.
Dark interior and edge uncertainty remain explicit. The isoflurane decision is separate.

The detector, correction, dictionary and all 495 MATLAB files are unchanged.
All saved-event source-amplitude checks and native-support/exposure checks passed.
Missing and negative amplitudes remain explicit and do not erase coverage/counts.
Full frames 1–1200 are the working descriptive interval, not final cohort window
approval. No scientific exclusion or new biological inference was made.

Next, resolve the separate FB2315 isoflurane outline judgment, run that recording
with the same method, and produce the second paired descriptive summary.
