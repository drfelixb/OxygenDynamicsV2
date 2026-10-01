# C02 recording and measurement eligibility

21 September 2026 · R1-C02-ELIGIBILITY-090

**All seven candidate mouse pairs remain in the plan. None is excluded by this inventory.** Six of the 14 recordings have identified event-run evidence; eight have no equivalent event run in this saved evidence set. Only FB2314 awake has an accepted source-specific working craniotomy ROI and a completed restricted-profile run. The immediate task is to prepare comparable inputs and runs, not improve event recognition.

Current detection imperfections remain accepted for proceeding. This matrix inventories readiness and affected measurements; it does not create new physiological validation gates or silently approve a final cohort.

## Recording matrix

| Mouse | Session | Scale, µm/pixel | Verified frames | Source evidence | Saved run evidence | Working ROI |
|---|---|---:|---:|---|---|---|
| FB2312 | FB2312-baseline-awake | 2.35 | 1200 | Archive adapter verified | Historical reference | Not recorded here |
| FB2312 | FB2312-baseline-iso | 2.35 | unreconciled | Manifest/local inventory; not execution-verified here | No current event run in inventory | Not recorded here |
| FB2314 | FB2314-baseline-awake | 2.35 | 1200 | Local/archive pixels verified | Restricted profile, plus earlier runs | Accepted for this source |
| FB2314 | FB2314-baseline-iso | 2.35 | 1200 | Local/archive pixels verified | No current event run in inventory | [Draft](reference-results/boi-c02-outline-proposals-20260912/FB2314-baseline-iso/FiveFrameOutlineReview.png) |
| FB2315 | FB2315-baseline-awake | 2.35 | 1200 | Local/archive pixels verified | No current event run in inventory | [Draft](reference-results/boi-c02-outline-proposals-20260912/FB2315-baseline-awake/FiveFrameOutlineReview.png) |
| FB2315 | FB2315-baseline-iso | 2.35 | 1200 | Local/archive pixels verified | No current event run in inventory | [Draft](reference-results/boi-c02-outline-proposals-20260912/FB2315-baseline-iso/FiveFrameOutlineReview.png) |
| ID400 | M400-01-baseline-awake | 4.75 | 600 | Archive adapter verified | Historical reference + later workflow | Not recorded here |
| ID400 | M400-03-baseline-iso | 4.75 | 600 | Archive adapter verified | Historical reference | Not recorded here |
| ID401 | M401-01-baseline-awake | 4.75 | 600 | Archive adapter verified | Historical reference | Not recorded here |
| ID401 | M401-03-baseline-iso | 4.75 | 600 | Archive adapter verified | Historical reference | Not recorded here |
| ID402 | M402-01-baseline-awake | 4.75 | 600 | Local/archive pixels verified | No current event run in inventory | [Draft](reference-results/boi-c02-outline-proposals-20260912/M402-01-baseline-awake/FiveFrameOutlineReview.png) |
| ID402 | M402-03-baseline-iso | 4.75 | 600 | Local/archive pixels verified | No current event run in inventory | [Draft](reference-results/boi-c02-outline-proposals-20260912/M402-03-baseline-iso/FiveFrameOutlineReview.png) |
| ID403 | M403-01-baseline-awake | 4.75 | 600 | Local/archive pixels verified | No current event run in inventory | [Draft](reference-results/boi-c02-outline-proposals-20260912/M403-01-baseline-awake/FiveFrameOutlineReview.png) |
| ID403 | M403-03-baseline-iso | 4.75 | 600 | Local/archive pixels verified | No current event run in inventory | [Draft](reference-results/boi-c02-outline-proposals-20260912/M403-03-baseline-iso/FiveFrameOutlineReview.png) |

“Verified frames” reuses earlier input/execution records; it is not a new movie check. FB2312 isoflurane has stored metadata shape 512×512×1200, but no matching frame-count execution record in this inventory. That uncertainty is recorded without inferring axes from shape or labeling the file unreadable. All recordings retain confirmed external 1 Hz sampling and the canonical metadata scale; no new calibration is claimed.

The [structured matrix](planning/boi-c02-eligibility-20260921.json) contains all 14 exact asset IDs/series, source hashes where bound, seven pairs, seven selected run records and 196 recording × measurement entries. The extra run record is the later ID400 awake workflow. Earlier FB2314 default/support-only runs remain referenced; these are not additional recordings.

## What can already be used

- Existing runs can be inspected and their descriptive results reused with their saved settings, support, exposure assumptions and missingness. Full outcome values were not reloaded or recomputed for this inventory.
- ID400 and ID401 each have historical runs for both states. Those historical paired inputs exist, but they are not a frozen current-profile cohort comparison. The later ID400 awake run has a different detector/measurement contract from its historical isoflurane partner.
- FB2314 awake has the current reviewed working support and restricted-profile run. Its saved evidence reports 305 sinks (143 finite amplitudes) and 41 surges (10 finite amplitudes). Missing amplitudes retain their masks/counts; negative values remain signed. These are existing run values, not new biological findings.
- Full original-local/archive pixel correspondence is already resolved for both states of FB2314, FB2315, ID402 and ID403. Archive-adapter roundtrip verification for the older reference runs is a different source relationship; it is not proof of correspondence to every original local TIFF.

## Measurement-specific readiness

| Outputs | Existing usable evidence | Remaining practical requirement |
|---|---|---|
| M01 occupancy, M02 onset rate, M03 concurrency | Saved descriptive results/ingredients for recordings with runs. | Source-specific support and selected observation windows for comparable area/time denominators; retain descriptive onset/boundary limits. |
| M04 duration, M05 native area, M08 history | Saved event/native geometry where a run exists. | Use its saved profile and calibrated scale; retain truncation/site uncertainty. No new recovery estimator. |
| M06 amplitude, M07 integral | Conditional event measurements under the saved optical reference. | Keep finite/total counts and reasons. No reference fallback; unavailable amplitude does not exclude other measurements. |
| M10 sink composite | Existing components and contribution statuses. | Total stays unavailable if required contributions fail; no surge composite. |
| M12 availability | Source/QC evidence for all rows; event availability evidence where runs exist. | Report actual executed denominators. Missing run evidence is not zero events. |
| M11 response, M13 animal contrast | Exact candidate pairs and known state design. | Approve comparison windows, aggregation and final inferential plan. No contrast computed here. |
| M09 recovery, M14 association | Context/native geometry may be retained. | Estimators remain unfrozen; omit those unsupported claims rather than excluding all other outputs. |

Each of these dispositions is expanded by recording and all 14 dictionary IDs in the structured matrix. “Results or ingredients available” is deliberately not a claim that every quantity is finite, numerically replayed now, or eligible for every scientific claim.

## What remains open—and what is already resolved

All 14 rows currently have no approved final C02 observation window in the reviewed records. A historical full-file interval is a descriptive extent, not an automatic approval. The verified extents are 1200 seconds for the relevant FB sources and 600 seconds for ID400–403. Do not shorten all FB recordings to 600 seconds from the publication figure alone. Keep native frame IDs; the automatic 20-sample event reference is not an exposure exclusion.

Frame validity, camera exposure and pre-source intensity preparation remain incompletely documented. Record the assumptions and restrict affected interpretations; they do not prevent inspection of preserved-input descriptive values. A demonstrated invalid interval would need explicit handling, not frame deletion/renumbering. Unknown exposure is not an unknown sample rate.

Where isoflurane was not applied during the file, state establishment occurred before recording and its duration was unmeasured. **No intra-file wash-in or numerical stabilization-duration requirement is introduced.** The measured awake control remains separate. Retain awake-first order and state-associated claim limits.

FB2315 retains its resolved identity and filename discrepancy, with source-array equivalence established. Development/publication exposure remains visible; no candidate is labeled untouched evaluation. Some labeling errors are accepted at this stage; they are not new automatic exclusion criteria.

## Concrete next work

1. Review the **existing FB2314 isoflurane outline**, paired with its already accepted awake support. Reuse the [saved source-bound preview](reference-results/boi-c02-outline-proposals-20260912/FB2314-baseline-iso/FiveFrameOutlineReview.png); do not draw another proposal or transfer the awake mask by assumption.
2. Record support and observation-window decisions for that pair, then prepare the current restricted-profile run using existing settings. This is applying the current method, not another detector experiment. Preserve the prior awake run and any new paired outputs separately.
3. Reuse the seven still-unaccepted outline proposals across the other audited states. For FB2312/ID400/ID401, establish source-bound working support from their existing source evidence. Extend the same input/run checklist across the seven pairs.
4. Once comparable recording summaries are available, apply the separately agreed animal-level contrast and report metric-specific pair counts. Do not combine historical/current contracts merely to fill every cell.

No new source access, movie processing, detector tuning, reference selection, window approval, scientific inclusion/exclusion or statistical effect was performed here. The matrix is complete as an evidence inventory; final eligibility remains a decision attached to the intended output.

See the [working specification](BOI_WORKING_ANALYSIS_SPECIFICATION.md), [experimental context](BOI_C02_EXPERIMENTAL_CONTEXT.md), [cohort resolution](BOI_COHORT_RESOLUTION.md) and [preservation record](reference-results/boi-c02-eligibility-20260921/README.md).
