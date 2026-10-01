# HP full-recording development workflow

10 September 2026. The full 512 × 512 × 1,200 earlier TIFF from the CSV/folder
FB2412 completed one BOI master, two statistics exports and an independent
source-pixel amplitude audit. This is the previously selected ECS-stratum
**development case**, not an independently evaluated animal or an eligible
biological comparison. No detector thresholds were tuned.

[Decision R1-HP-CLOCK-002](../../planning/boi-hp-clock-correction-20260910.json)
records the user's authoritative confirmation: timestamps within the recording
files are incorrect; acquisition is precisely **1 Hz under external triggering**.
The analysis uses that exact uniform clock. Original embedded values are retained
unchanged as `SourceClockTimesSec`, marked `known_unreliable`, and never used
for detection or exposure denominators. Actual measured frame timestamps remain
unknown; no absolute clock or exposure-start times were manufactured.

The [original input preflight](../boi-hp-input-20260910/README.md), its source
copy and sidecar remain intact. Its earlier clock interpretation is superseded,
not silently rewritten. All nine local files bound in its artifact record were
verified unchanged. The user's timing confirmation also takes precedence over
the contradictory internal-trigger tag noted for FB2410 in the source inventory.

## Executed workflow and calculations

The [MATLAB report](workflow-report.json), [independent CSV replay](independent-replay.json)
and [window comparison](window-comparison.csv) retain exact values and hashes.
The selected input SHA-256 remains
`3d903105aa450da0348d6aa4ddb4b23145099534d5817a826461bb5ff2132e73`.

| Check | Result |
|---|---|
| Confirmed analysis timing | 1,200 intervals, each exactly 1 s; modeled starts 0…1199 s. Original incorrect timestamps are a separate exported column. |
| Camera exposure | Preserved 0.96 s setting per page, separate from the 1 s interval. |
| Unknowns | Declared measured frame times and frame validity remain NaN. Physical scale is conditional on supplied 2.35 µm/pixel. |
| Both signs | 168 detected sink events, 81 surge events; no cross-sign cancellation. |
| Amplitude availability | Finite values for 75/168 sinks and 20/81 surges. These counts are availability, not biological validity or accuracy. |
| Independent source audit | All 249 events match saved baseline, availability status and amplitude; zero numerical mismatches. |
| Sink occupied fraction | CSV replay gives 0.006252045294063687, or about 0.6252%, under the saved static tissue mask and current detector. |
| Setting-change traceability | Whole-recording [0,1200) versus diagnostic [30,1200) s; identical sink and surge event tables; original run A checksum unchanged. These are diagnostic windows, not approved experimental baselines. |
| Shared explanations | Workbook measurement dictionary equals the current source dictionary; source identity/calibration issues appear in `StatsAcceptance` as REVIEW. |

The deterministically selected example is sink site 1, event 3, the first finite
sink amplitude in saved row order. Its baseline is 834.7919583727531 preserved
input units across 20 clean frames; amplitude is 0.04343062264562953 (4.3431%)
and signed trace integral is −0.9115381882376358 s. Both MATLAB and a separate
Python CSV calculation reproduce the saved values within 1e−10 relative plus
1e−12 absolute numerical tolerance. This tolerance checks arithmetic, not
biological accuracy. The native image and mask both use frame 508. A supplementary
close-up makes the local event and baseline visible alongside the full trace.

One detector-labelled surge has a negative amplitude relative to its local
baseline: site 1, event 4, frames 1048–1060, amplitude
−0.00266302858071584 (−0.2663%). The source-pixel audit reproduces it exactly
and marks `WrongDirection=true`. It was neither excluded, clipped to zero nor
used to tune the detector. Detector direction and local baseline-relative
amplitude need scientific interpretation under R2. The full example footprint
trace also contains large level changes outside the selected event; these are
preserved, without attributing them to physiology or acquisition artifacts.

## Biological and researcher interpretation

CSV/folder FB2412 versus embedded prefix FB2411 remains unresolved. The run uses
the recording-specific provisional label `HP_ECS_CSV2_identity_pending` and
Unknown condition, genotype, drug and promoter fields. Original metadata stays
in the source declaration/review. This avoids silently converting experimental
group labels into biological facts; it does not settle the actual animal ID.
No between-recording contrast, animal-level inference or cohort pooling was run.

The [follow-up source record](source-followup.json) establishes that both earlier
and denoised TIFFs in FB2416/FB2417 are respectively byte-identical. The FB2316
and FB2318 denoised TIFFs are distinct by full hash, with pairing still unresolved.
Parent and Data CSV copies are identical. Historical source code supports the
intended Hz/µm input units, but not independent calibration. Its uppercase-only
denoised-name check is a provenance concern; no particular prior result is
attributed to that code without evidence. Prior outcome tables were not opened.

Identity, calibration and label issues are now source-bound structured
`ReviewIssues`, visible in MATLAB preflight, saved contracts and ordinary
statistics QC. This demonstrates the same input/statistics workflow on a local
recording while retaining scientific questions. Static tissue, motion/intensity
history, substrate, physiological onset/recovery definitions and comparison
eligibility remain open. The ECS case does not establish transfer across every
expression compartment or acquisition variant. IOSI remains excluded.

Remaining usability limitations: the existing statistics log counts unique
Mouse labels as “mice,” even for this provisional label. “Without stimulation”
in the legacy log reflects absent configured puff inputs, not independent
evidence about stimulation. The raw-only loading message also uses the legacy
phrase “motion-corrected-only,” which does not establish processing history.
The source review and corrected declaration are authoritative for these
unresolved facts. A researcher GUI walkthrough and independent collaborator
replay remain required release evidence.

## Runtime, storage and verification

MATLAB R2025a used two process workers. Master: 81.14 s; statistics A: 54.74 s;
source amplitude audit: 8.58 s; statistics B: 52.63 s. The runner took 225.99 s
internally and 245.91 s including MATLAB startup/pool/shutdown as measured by
macOS `time -l`. Output at runner completion was 3,376,776,772 bytes (about
3.15 GiB), below the prespecified 5 GiB review target. Later small audit/figure
files are additional and included in the final artifact inventory.

Reported maximum resident set size was 13,447,593,984 bytes (12.52 GiB), with
peak memory footprint 17,834,015,024 bytes (16.61 GiB). These are process
accounting values, **not** a measured simultaneous sum across MATLAB and all
workers or a cohort resource estimate. No swapping was reported.

All **42** targeted MATLAB tests passed: input/clock/source-review tests plus
analysis corrections, pipeline contract and measurement availability. Tests
include backwards source-clock observations, absent evidence, source holds,
bad issue dispositions/IDs, explicit contradictory image clocks and CSV/workbook
round-tripping. Full real-recording execution additionally verified the normal
master/statistics path, structured QC, dictionary, source clock separation,
both-sign amplitude replay and unchanged original statistics output.

The first resource-measured launch stopped at a sandboxed macOS timing query
before MATLAB created a run. The permitted launch completed normally. A
supplementary plotting attempt lacked bundled Python matplotlib, so MATLAB
rendered the figure directly; no packages were installed. Runtime/plotting
attempts did not change scientific settings or source data.

Local artifacts are in the parent workspace:
`reference-validation/boi-hp-workflow-20260910/` and
`reference-validation/boi-hp-source-followup-20260910/`. They include the staged
source/declaration, input review, full MATLAB code manifest, effective master
settings, both independent output runs, all-event audit, event trace and footprint
CSVs, same-frame inspection, detail figure, source follow-up and unit-test result.
Use `tests/analysis/runBOIHPWorkflow.m` with the original fixed source, corrected
metadata and a **new** output root to reproduce the recorded experiment. Prior
outputs must remain intact. The artifact record binds the retained evidence by
hash and records final verification.
