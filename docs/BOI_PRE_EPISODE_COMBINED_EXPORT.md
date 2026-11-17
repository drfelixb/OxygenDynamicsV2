# Fresh combined export with pre-episode references

16 October 2026. BATCH-EPISODE-EXPORT-01; owner root, no delegation.
Felix explicitly requests the same 17 completed recordings exported with the
approved reference method and a check of which burden values are available.

Use the existing shared batch statistics/export service with exact saved master
selection. Preserve source recordings, saved runs, the previous combined export,
three held recordings, original automatic columns and optional stimulation
metadata. Keep the approved `boi-pre-episode-1` method, strict missingness,
burden formula and normalization. No scientific-method change is authorized.

Acceptance: fresh complete workbook and MATLAB exports for exactly the original
17 recording identities; same original sink/surge measurements; reference-policy
version and audit provenance; independent event-product and normalization checks;
recording sums available only when all required contributions are available;
availability/reasons and newly available versus previously available values by
recording. Do not label a partial sum as recording burden.

Budget/stopping condition: at most two 60-minute export attempts including a
necessary repair, 32 GiB combined fresh output ceiling, 100 MiB review evidence,
one bounded 15-minute saved-result verification plus one repair. Stop after
verified output and availability delivery. No detector/correction rerun,
new dataset campaign, package, commit/push or publication.

Evidence and progress: workspace-root
`reference-validation/boi-pre-episode-export-review-20261016/`.
New output parent: `reference-validation/boi-pre-episode-combined-export-20261016/`.


## Verified delivery

The fresh export is complete in local **3.1.0-dev.9**, using the existing
statistics service and approved `boi-pre-episode-1` policy. It contains the same
17 recording identities, 5,407 sink events and 1,320 surge events. Three source
holds remain excluded: FB2416, FB2417 and FB2318. The prior export is preserved.

**3,256 event contributions are available**, compared with 2,767 before. There
are 490 newly available contributions and one newly withheld contribution, a
net gain of 489. Contributions available under both methods are unchanged.
**No recording has a complete amplitude-area-duration burden:** all 17 strict
totals and their area/time-normalized values remain unavailable. No partial
sum is promoted as recording burden.

| Remaining unavailability | Events |
| --- | ---: |
| Reference shifted more than 20 seconds | 1,007 |
| No full clean pre-episode reference | 973 |
| Unresolved acquisition-start reference | 72 |
| Wrong-direction relative signal | 99 |
| Total unavailable contributions | 2,151 |

No missing evidence, nonpositive-reference/missing-signal or area/duration
failure adds another unavailable contribution in this export. Acquisition-start
counts include linked events with an unresolved series-start reference; they
are not a count of confirmed new physiological onsets.

The single newly withheld value is FB2413 site 3 event 6, measurement frames
835–844. Its episode begins with event 5; the common reference 766–785 is shifted
49 seconds from its usual baseline, exceeding the explicitly chosen 20-second
limit. Its original 11.2329135883708% automatic amplitude remains in the original
column. No fallback to that amplitude is applied to the derived burden.

| Recording label | Available / total contributions | Newly available | Newly withheld |
| --- | ---: | ---: | ---: |
| FB2412 | 143 / 227 | 30 | 0 |
| FB2413 | 148 / 251 | 19 | 1 |
| FB2419 | 171 / 254 | 28 | 0 |
| FB2420 | 203 / 340 | 39 | 0 |
| FB2311 | 142 / 240 | 35 | 0 |
| FB2316 | 176 / 318 | 37 | 0 |
| FB2317 | 136 / 257 | 34 | 0 |
| FB2319 | 167 / 308 | 25 | 0 |
| FB2320 | 184 / 367 | 35 | 0 |
| FB2402 | 177 / 347 | 22 | 0 |
| FB2403 | 196 / 339 | 20 | 0 |
| FB2404 | 224 / 332 | 22 | 0 |
| FB2405 | 340 / 487 | 28 | 0 |
| FB2406 | 339 / 520 | 39 | 0 |
| FB2407 | 233 / 356 | 35 | 0 |
| FB2408 | 107 / 174 | 16 | 0 |
| FB2410 | 170 / 290 | 26 | 0 |

These counts describe numerical availability, not a fraction of true biological
burden. Recording labels and existing identity/calibration/support qualifications
remain as saved; no new animal-level inference is made.

## Files and postprocessing

The main workbook is:

`reference-validation/boi-pre-episode-combined-export-20261016/BOIBatchStats_a5d0f863-5240-4304-a93c-aea629f0d2b0/statistics/Stats_Output_20261016T090151/FilteredData_HP_Compartments_BOI_run.xlsx`

Use `HypoxicBurden_EventBased` for the selected `BurdenAmplitudePercent`,
`PerEventBurdenContribution` and `PerEventBurdenContribution_per_mm2_per_min`,
keeping the reference status and event identity. `HypoxicBurden_ByRecording`
retains unavailable complete totals and companion counts.
`HypoxicBurden_ReferencePolicy` documents the method and 20-second limit.
`BurdenAvailabilityByRecording.csv` in the fresh export's root compares previous
and current availability, with reason counts. Original automatic-amplitude
columns, morphology, event duration, source tissue support and exposure remain.

## Verification and limits

- Native readback verifies all original sink/surge event columns, both-sign
  exposure/frame ingredients, original QC and non-amplitude window metrics.
  Original areas and durations match; every selected event product and its
  normalization are checked. All 17 strict sums retain missingness.
- Saved audit ingredients replay for all 5,407 sink events; independent Python
  checks 3,355 finite reference means/amplitudes, all 5,407 products/normalizations
  and 5,424 exported event/recording rows. The named FB2412 recurrent event retains
  normalized contribution 2608.970112849447. Separate event MAT files agree with
  the main file, and the three large MAT files retain required v7.3 storage.
- All 108 previous workbook sheets remain, with the additional approved reference
  policy sheet (109 total). Key result sheets have no Excel error cells. Artifact
  Tool inspects/renders original versus new result ranges; no restyling occurs.
- Seven hundred historical file hashes are unchanged, including the old combined
  workbook. Forty original movie sizes/modification times and all method-source
  fingerprints are unchanged. No detector/correction run or source movie
  processing occurs. Source-byte fingerprint checks are read-only.
- One complete export-service execution succeeds after a launcher-only progress
  callback repair (the first launch stopped before export). One report-collector
  initialization repair completes the saved-data verification. Original logs are
  retained. No scientific code, formula, normalization or completed export is
  altered by either repair.

Fresh output: 11,871,945,564 bytes. Evidence before closeout: 15,118,806 bytes. Complete export launch including selection and integrity checks: 37.33 minutes. Both stated storage/time limits are met.

Evidence: workspace-root `reference-validation/boi-pre-episode-export-review-20261016/`,
including final/native/independent verification, per-recording availability and
original-versus-derived comparisons. The task is complete and stops here.
Remaining reference eligibility is a scientific-method issue; it is not resolved
by summing the available subset or by changing the normalization. No subsequent
method change, processing campaign, package, commit/push or release is inferred.
