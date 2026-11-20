# BOI prior-use and validation audit

12 September 2026. **R3-PRIOR-USE-016 completed for the existing workspace
records.** Evaluation roles remain unfrozen. This audit identifies documented
use and its limits; it does not certify that an animal has never been inspected
elsewhere. No new recording analysis, detector run, model fit or scientific
policy change occurred.

The [structured ledger](planning/boi-prior-use-audit-20260912.json) retains all
87 archive assets / 63 canonical archive animal labels, the 20 HP input rows,
and 20 separately located external-acquisition leads. These inventories overlap
and must not be added to obtain a biological sample size. IOSI remains excluded;
its three metadata rows are retained only to prevent accidental inclusion.

## Findings that affect evaluation planning

**Five BOI animals have documented analytical use:** ID400, ID401, FB2312,
FB2316 and ID13, covering seven archive sessions. **FB2411 is a sixth used
archive animal, separately recorded as a fluorescence control.** Repeated runs,
constructed movies, event supports and waveform recipes do not add animals.

The selected local **HP_ECS_CSV2_identity_pending** recording has also undergone
a complete development workflow and repeated source/measurement inspection.
Its CSV/folder label FB2412 conflicts with embedded FB2411 metadata. Do not merge
it with the archived FB2411 fluorescence animal or count it as a newly verified
independent animal. The HP inventory also retains byte-identical candidate files
under FB2416/FB2417 labels; labels alone cannot establish independent replicates.

The isolated event-first prototype used **ID400 awake, first 120 of 600 frames**.
This extends ID400's known history; it adds no new animal and supplies no
independent biological comparison with the main pipeline. Earlier runtime and
statistics bug reproductions used controlled/synthetic fixtures and code review;
they do not establish additional real-animal use.

The onset-model report's **“additional recordings” ID13 and FB2316** were new to
that particular fitting panel, but were already pipeline references. Subsequent
waveform, eligibility and amplitude investigations used them again. Their
historical method-specific designation is preserved; neither is untouched
animal-level evaluation for the overall reanalysis.

## C02: seven candidate pairs

| Mouse | Documented history | Consequence for evaluation planning |
|---|---|---|
| ID400 | Awake and isoflurane full pipeline references; awake prototype, injections, measurement development and workflow checks. | Known development animal across both states and other same-animal sessions. |
| ID401 | Awake and isoflurane full references; awake tracking/onset/amplitude development. | Known development animal across both states and other same-animal sessions. |
| FB2312 | Awake full reference and multiple tracking/measurement challenges; awake/iso local acquisition headers inspected. | The isoflurane session does not create an untouched animal. |
| FB2314 | Awake/iso local first-frame fingerprints and acquisition headers inspected for identity and order. No analytical execution found in reviewed records. | Source-inspected; outside-workspace use and evaluation independence remain unresolved. |
| FB2315 | Awake/iso local first-frame and acquisition comparison established distinct files despite FB2314 filenames. No analytical execution found in reviewed records. | Preserve resolved local identity and unverified archive equivalence; source-inspected, no untouched assignment. |
| ID402 | Baseline folders/file inventory inspected; neither baseline ABF found in that search. No image inspection or analytical execution documented in these records. | Inventory evidence only; absence of a run is not proof of independence. |
| ID403 | Awake baseline ABF header inspected; other pair timing remains unresolved. No image inspection or analytical execution found in reviewed records. | Acquisition-inspected; outside history and eligibility remain unresolved. |

This refines the four earlier “prior use not fully audited” entries. It does not
promote them to evaluation. Acquisition/source inspection is recorded separately
from analytical use so the eventual independence decision can consider what was
actually seen and when. A proposed cohort table, a teaching example containing a
mouse name, or a code example is not evidence that its movie was analyzed.

The original [policy proposal](BOI_MEASUREMENT_POLICY_PROPOSAL.md) and its frozen
candidate ledger remain intact. This audit is a linked overlay, not a retrospective
rewrite of earlier knowledge or an approval of any pair/window.

## Acquisition coverage and limits

The [complete stratum table](reference-results/boi-prior-use-audit-20260912/acquisition-strata.md)
keeps original cohort groups, metadata scales, direct used sessions and
same-animal exposure separate. Local resolutions still govern held/renamed source
metadata; original group labels are not final eligibility decisions.

| Acquisition family | Existing real-recording evidence | Remaining limitation |
|---|---|---|
| Quiet awake | ID400/ID401 at 4.75 µm/pixel and FB2312 at 2.35; full reference and development challenges. | Reused animals, intensity preparation and tissue eligibility; no independent operating-range estimate. |
| Isoflurane | ID400/ID401 at 4.75 µm/pixel, full reference/timing audits. | No directly analyzed finer-scale isoflurane session in the reviewed execution records; awake evidence does not validate the other state. |
| KX baseline | FB2316 at 2.35 µm/pixel, full reference, later mean-trace and full-movie challenges. | No corresponding real-reference evidence here for the 1.58 µm/pixel subgroup; preparation differences remain. |
| Mobile awake | ID13 at 2.38 µm/pixel, full reference and later constructed mean-trace onset work. | One reused animal, not validation across the 2.8 µm/pixel/geriatric or other mobile acquisitions. |
| Whisker/gas/microsphere/calibration | Metadata/source and some acquisition-timing checks; no analytical execution for these sessions found in the reviewed records. | Trigger recovery or a compatible pixel scale does not validate response windows, calibration, controls or detector performance. Some animals already have development use in other sessions. |
| HP local compartment acquisitions | One ECS-labelled complete development recording; all 20 rows inventoried, with headers/fingerprints/reference searches. | Identity, preparation and anatomical support remain unresolved; no analytical transfer evidence for every ECS/neuronal/intracellular label. |
| Fluorescence support | FB2411 at 6.75 µm/pixel, separately analyzed control and constructed challenges. | It is not a BOI biological observation or a labelled false-positive ground truth. |

The recorded full reference profiles use 1 Hz. Synthetic mask/timing tests at
other rates exercise arithmetic and structural behavior, not biological
cross-frequency equivalence. HP's user-confirmed external **1 Hz** remains
authoritative; incorrect embedded timestamps and 0.96-second camera exposure
remain separate provenance. No new timing estimate was made.

## What has actually been validated

| Evidence family | What existing work supports | What it leaves open |
|---|---|---|
| Prescribed support arithmetic | Baseline/amplitude/integral replay, both signs, missingness, inclusive durations and timing status behavior. | Physiological reference, onset and recovery. |
| Full-movie known components | Selected weak/strong, recurrent, smooth, moving, growing/shrinking and overlapping components on a small set of reused backgrounds. | Real-event sensitivity/specificity and realistic population/acquisition coverage. |
| Candidate-mask tracking | Contact, scale, growth/containment, gap and split/merge behavior under prescribed masks. | Preprocessing/detection error and biological identity through contact. |
| Mean-trace onset/peak experiments | Effects of waveform mismatch, context, baseline contamination and support; gains and losses recorded. | End-to-end recovery of those traces from images, realistic noise calibration and independent physiological onset. |
| Source/tissue/workflow checks | Input identity, lossless conversion where explicitly verified, source-bound masks/metadata, saved numerical replay and usable MATLAB developer paths. | Anatomical validity, dynamic observable tissue, independent researcher walkthrough and second-person release replay. |
| Animal comparisons | Candidate pairing and metadata confounds are documented. | Frozen metric-specific contrasts, missingness analysis, uncertainty/multiplicity and biological inference. |

The [42-entry evidence catalog](reference-results/boi-prior-use-audit-20260912/evidence-catalog.md)
links these assignments to execution reports, including the separate prototype.
Each catalog entry records scope and source sessions. It is not a count of
independent experiments, animals or successful scientific validations. Historical
success/failed-candidate conclusions remain in their original reports; no
previous suggestion automatically starts another method experiment.

## Search, verification and stopping point

The audit searched current repository documentation/tests, local provenance and
logs, prototype records, runtime/statistics review and metadata reconciliation.
The [search inventory](reference-results/boi-prior-use-audit-20260912/search-inventory.json)
records paths, content hashes, all canonical asset/session/animal identity hits,
and line numbers for the four C02 animals needing deeper history review. Hits
were search leads, not automatic use assignments. Existing execution reports,
phase-1 asset receipts and the local-source resolution links establish the
positive assignments.

It did not read TIFF/NWB/ABF/MAT image/recording payloads or event/trace CSV tables,
download data, inspect new outcomes, scan the connected source drive, or rerun
analysis. Saved JSON/text provenance was searched for identities, including
larger review sidecars. This is a record audit, not a replay of every past run.

An initial summary accidentally included empty lookup keys as used sessions;
review caught the mismatch with the six-animal/per-asset evidence. The corrected
summary requires nonempty evidence and the verifier checks the exact eight
archive-session set. The initial script and reports remain preserved. No
scientific assignment or source record was changed to resolve this reporting
error.

The [verification record](reference-results/boi-prior-use-audit-20260912/verification-report.json)
checks asset/animal conservation, source/receipt joins, animal-level propagation,
HP non-merging, the C02 distinctions, stratum totals, source hashes and preserved
implementation/evidence. All final evaluation and eligibility fields stay unset.

**The audit is complete; evaluation freeze is not.** Before calling any remaining
animal independent, reconcile original-study analysis, earlier V2/AQuA2 work,
human event inspection and use on other computers or unavailable workspaces.
The user has already described exploratory AQuA2 work; no claim of a completely
unseen HP acquisition follows from its absence in this audit's execution catalog.
Then record the animal-level roles and freeze comparison-specific validation
cases, acceptance criteria and resource budgets before accessing new outcomes.

## Subsequent external-source evidence — 12 September 2026

The user confirmed original-publication membership for the four questioned C02
animals in [R3-PUBLICATION-HISTORY-018](planning/boi-publication-history-20260912.json).
The later [R1-C02-INPUT-019 input audit](reference-results/boi-c02-input-20260912/README.md)
then inventoried their eight external source folders. Each contains sink, surge
and manual-curation-named MAT files, giving 24 legacy processing artifacts.
Only variable headers and file hashes were inspected; none contains a top-level
`Info` variable. No event, trace or mask values were read.

This is positive legacy-processing evidence outside the original workspace-only
search. Preserve the dated audit and its original scope; use this overlay when
interpreting the four animals' history. Original publication and local legacy
outputs do not establish later V2/AQuA2 parameter selection, actual manual edits,
current-method execution or untouched evaluation status. Published data remain
valid reanalysis candidates subject to measurement-specific eligibility.

[R1-C02-PROVENANCE-020](reference-results/boi-c02-provenance-20260912/README.md)
subsequently read the complete selected local/archive pixel arrays for all eight
sessions solely to verify source equivalence and orientation. Record this as
full-source integrity inspection, extending the prior source/header-only history.
No events were detected, annotated, tuned or contrasted; no legacy numerical
outcomes were read. This additional inspection does not assign untouched roles.

[R1-C02-OBSERVABILITY-021](reference-results/boi-c02-observability-20260912/README.md)
adds source-QC inspection for the same eight sessions: all-frame pixel diagnostics,
whole-field brightness/change timelines and 55 unique source frames were reviewed.
This is exposure to source signal structure, beyond numerical equality testing;
retain it in any later independence assessment. No detector or legacy event
outcomes, parameter selection, physiological annotation or biological contrast
was performed. The review actor is Codex, not an independent researcher.


## Subsequent development timing panel — 13 September 2026

[R2-TIMING-PANEL-042](reference-results/boi-timing-panel-20260913/README.md)
freezes 48 events across FB2314 awake, ID400 awake, FB2316 KX and the already
analyzed provisional HP ECS recording. FB2314's subsequent full workflow,
restricted-ROI analysis and researcher event annotations in phases023–041
supersede its earlier source-only history above; it is now development-exposed.
ID400, FB2316 and HP retain their earlier development roles. No new animal is
certified independent and HP identity is not resolved by this panel.

Panel preparation reads existing audit characteristics and saved trace/native
support records to select and verify cases. New timing comparison outcomes are
pending. Condition, support and preparation differences remain separate;
fluorescence and IOSI recordings are excluded from this BOI panel.
