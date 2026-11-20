# HP compartment source and input review

**Current timing decision:** the researcher confirmed exactly **1 Hz external
triggering** and stated that timestamps inside the recording files are incorrect.
[R1-HP-CLOCK-002](planning/boi-hp-clock-correction-20260910.json) supersedes the
earlier clock interpretation below. The original preflight is preserved as
history. Embedded clock values are retained as unreliable provenance and do
not create a timing hold or drive analysis. Contradictory trigger metadata,
including FB2410's internal-trigger tag, is preserved without overriding the
researcher's confirmation. No measured absolute frame timestamps are invented.

10 September 2026. The user supplied `HP_indepth/Data` as additional local data,
including `HP_Compartments.csv`. All 20 CSV rows resolve to folders, each with
one earlier BOI TIFF candidate in `New folder` and a top-level TIFF named
`denoised`. This inventory is separate from the 20 older sessions located under
U12 in the [cohort resolution](BOI_COHORT_RESOLUTION.md). Neither inventory is an
eligible cohort or a count of independent biological replicates.

The [source overlay](planning/boi-hp-local-inputs-20260910.json) preserves all
original CSV fields, relative source paths, inspected header values, archive
links, conflicts and evidence hashes. Full local mappings, original page
metadata and the unchanged selected TIFF are retained under
`reference-validation/boi-hp-input-20260910` in the parent workspace. Source
files, prior results, prior cohort manifests and existing worktree changes were
preserved. No prior result tables or image pixels were interpreted in this audit.

## Inventory and biological scope

| CSV group label | Rows | Relationship to the current archive ledger |
|---|---:|---|
| GFAP-ECS | 6 | CSV mouse IDs absent from the ledger; identity conflicts below prevent treating these as six verified distinct acquisitions. |
| GFAP-GeNL | 6 | All six mouse IDs and earlier TIFF basenames match archive baseline series. Keep the animal links; whole-movie archive equivalence remains unverified. |
| hSyn-GeNL | 8 | CSV mouse IDs absent from the ledger; separate expression stratum, with one embedded-prefix conflict. |

All 20 earlier TIFF candidates have 512 × 512 pixels and 16-bit storage. Nineteen
have 1,200 pages; FB2413 has 1,178. These are header counts, not verified valid
observation durations. No padding, trimming or frame exclusion was performed.
No ABF files were found beneath the 20 resolved folders. The `Dual` directory
was empty when listed. Auxiliary 490 nm and white-light files were inventoried
by filename only and are outside this BOI biological input check.

The CSV supplies `SampleF=1` and `Pixelsize=2.35` for every row. The preflight
uses these provisionally as Hz and µm/pixel according to the existing MATLAB
input convention. The CSV itself does not state the units or calibration method.
The 14 ECS/hSyn candidates retain first-page acquisition tags with
`Exposure-ms=960.0` and `PixelSizeUm=0.0`. Zero is unusable calibration evidence;
it is not a replacement for the CSV scale. Exposure was checked on every page
only for the selected FB2412 case. Camera settings are not an independently
measured shutter duration. Source orientation, intensity history, motion
correction, substrate and time since application remain unresolved where absent.
Among these 14 first-page camera tags, 13 declare external triggering; FB2410
declares internal triggering. Preserve that acquisition variant when designing
the later transfer check; the selected FB2412 timing evidence does not validate
all recordings. The six GFAP-GeNL candidates lack these per-page acquisition
fields in the inspected first-page tags.

The CSV's Windows-relative paths were resolved for inventory without editing
the CSV. The top-level folders contain denoised files while earlier candidates
are nested in `New folder`, so this CSV is not yet a ready local batch input
for the current one-original-TIFF-per-folder contract. Correct source pairing
and a separate staged input mapping are required before batch use.

Each row repeats its experimental-group label in `Genotype`, `DrugID` and
`Promoter`. Those original values must not silently become canonical genotype,
drug and promoter facts. `Condition=baseline` is retained. KX appears in folder
or image names, but user clarification of state/drug semantics remains pending.
Every row has `Puff_2use="2 3 5 6"` while puff/behaviour file fields are blank;
this list establishes neither stimulation nor trial timing.

## Identity discrepancies retained

| CSV/folder identity | Conflicting source evidence | Disposition |
|---|---|---|
| FB2412 | Earlier TIFF name agrees; embedded acquisition prefix says FB2411. | Retain CSV/folder identity provisionally; reconcile acquisition identity. |
| FB2413 | Earlier TIFF name agrees; embedded prefix says FB2412. | Reconcile identity; retain the actual 1,178-page length. |
| FB2416 | Earlier and denoised TIFF filenames and embedded prefix say FB2415. | Reconcile original acquisition and correct source pairing. |
| FB2417 | Earlier TIFF name says FB2417, embedded prefix says FB2415. Its entire earlier TIFF is byte-identical to the FB2416 candidate. | Do not count these two source candidates as independent recordings. Locate the correct source before pairing or analysis. |
| FB2419 | Earlier TIFF name agrees; embedded prefix says FB2417. | Reconcile identity. |
| FB2406 | Earlier TIFF name agrees; embedded prefix says FB2405. | Reconcile identity. |
| FB2318 | Earlier TIFF name says FB2318; top-level denoised filename says FB2316. | Verify raw/denoised correspondence before using denoised detection. |

The FB2416/FB2417 earlier TIFFs each contain 635,259,581 bytes and share SHA-256
`f58072c1c936b876c10d182bc52ef4c42d0aa220d3b38e4d6efc6bc9f286586d`.
This is whole-file identity for those two candidates. It does not establish
that their denoised movies, remaining session materials or actual animals are
duplicates. Embedded prefixes alone also cannot resolve which identity is correct.

Follow-up full-file hashing now also establishes that **their denoised TIFFs
are identical**: each has 1,258,570,158 bytes and SHA-256
`6f52ec5de7be30fc66ae62047e1f2ff0921f3c338781ee7796a8ef33cd839132`.
Both source inputs therefore require identity reconciliation before counting
FB2416/FB2417 independently. The FB2316 and FB2318 denoised TIFFs have different
hashes, which rules out byte identity between those two files but does not
verify their respective raw/denoised pairings. The parent and Data copies of
`HP_Compartments.csv` are byte-identical, so the second CSV adds no independent
identity evidence.

The six GFAP-GeNL archive links are FB2311, FB2316, FB2317, FB2318, FB2319 and
FB2320 baseline series. No independent evaluation role may be inferred from
their location on a different drive. The 14 other mouse IDs are new relative
to this ledger, not proof of complete DANDI absence or untouched evaluation.
Historical researcher inspection/tuning is unknown. Preserve biological strata
and animal-level dependence; no pooling across expression compartments or
mechanistic interpretation is justified by this inventory.

## Original MATLAB input check (preserved, timing interpretation superseded)

[Decision R1-HP-INPUT-001](planning/boi-hp-transfer-decision-20260910.json)
selects the first CSV row, FB2412 in the ECS stratum, for a development input
check. The decision records the metadata already inspected before selection.
No outcome was used to choose it. This one case does not represent all local
biological or acquisition variability.

A byte-identical earlier TIFF was staged in a fresh workspace folder. The
top-level denoised file was not substituted for that source. A source-bound
`BOIInputMetadata.json` retains all 1,200 per-page elapsed-clock values and
960 ms exposure settings, with unknown intensity history and frame validity.
The nominal CSV sampling/calibration and conflicting identity remain explicit.

MATLAB R2025a read the full TIFF directory and completed the input check in
8.12 seconds inside MATLAB, with no analysis workers or detector run. The
[execution evidence](reference-results/boi-hp-input-20260910/README.md) verifies
source hashes, page count, unchanged timestamps, exposure, unknown validity
and the master's pre-detection acquisition guard.

**Result: readable input, held by the current uniform-time pipeline.** Attached
Micro-Manager elapsed times run from 3.780 to 1202.94113 seconds; adjacent
intervals range from about 0.99006 to 1.02086 seconds. Their maximum deviation
from the nominal 1 Hz grid, after subtracting the first timestamp, is 0.16113
seconds. They were not rounded, resampled or replaced. Their exposure-start
meaning and alignment to external camera triggers remain unverified.

The guard's 1 µs comparison is a numerical model-consistency check, not a
scientific tolerance. This result does not establish that the recording or
its temporal variability is physiologically unusable. It identifies a required
decision about clock semantics and supported temporal analysis. Recovering the
actual frame clock may distinguish camera timing from software receipt jitter;
an irregular-time method or justified approximation would require explicit
assessment before detector use. Neither is silently adopted here.

The preflight reports timing, unknown intensity preparation and unknown frame
validity. CSV identity and calibration questions are retained in this linked
review/overlay; the current preflight does not automatically understand those
free-text scientific issues. This is a remaining researcher-workflow integration
requirement, not evidence that the three emitted QC rows exhaust eligibility.

## Next decisions

Reconcile CSV label semantics and the listed identities, particularly the
FB2416/FB2417 source pairing, and confirm physical calibration. Timing now uses
the user's confirmed exact 1 Hz external trigger, not the embedded file clock.
Exposure settings remain separate from the one-second sampling interval.
Preserve remaining
recordings' unassigned roles until the variability/evaluation design is recorded.
The bounded input check is complete; biological transfer validation, physiological
relevance, usable tissue, both-sign measurement validity and cohort eligibility
remain open. IOSI stays excluded, and no approved analysis windows were added.

The source-bound declaration now supports structured issues in MATLAB QC and
provenance-only source clocks. This addresses the earlier gap where identity
and calibration questions appeared only in this document. It does not resolve
those questions. The historical wrapper/master establish that the CSV values
were interpreted as Hz and µm/pixel, but do not independently establish physical
calibration or current raw/denoised correspondence. The historical master uses
a case-sensitive `DENOISED` filename check while the inspected inputs use
lowercase `denoised`; this is a source-code risk, not proof of which code or
signal produced any particular prior result. No prior results were opened.

## Expanded reference/support review, 11 September 2026

After the initial source-only audit above, the [expanded review](reference-results/boi-hp-reference-search-20260911/README.md)
searched the reconnected drive recursively and inspected two selected-recording
legacy landmark PNGs and their support/options metadata. This later inspection
does not alter the earlier audit's scope. No legacy event counts, amplitudes or
outcome tables were analyzed.

The expanded inventory contains 23 named acquisition-reference images across
19 recordings, including seven nested files missed previously. No acquisition
reference was established for the selected FB2412 recording. Both of its
inspected legacy support maps contain only `None → []`; neither supplies an
explicit tissue boundary. Their stored 502 × 502 grid also differs from the
512 × 512 preserved source. No anatomical registration or mask was adopted.
The source TIFF/CSV and earlier workflow/event-review evidence remain unchanged.
See [decision R1-HP-REFERENCE-006](planning/boi-hp-reference-search-20260911.json)
for the bounded search, disposition and remaining reference-location question.

## Researcher clarification: AQuA2 outputs

The researcher clarified: “the aqua files are likely not helpful. i have been
playing around with the aqua2 detection.” Record these as exploratory detection
outputs. They are excluded from evidence for acquisition references, reviewed
anatomical masks or ground truth. This does not assess the AQuA2 method itself;
it records the role of these particular files. All source and exploratory output
files remain intact, and the matching-reference/tissue question remains open.
