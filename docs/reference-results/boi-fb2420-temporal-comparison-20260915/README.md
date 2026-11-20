# FB2420 fixed-interval temporal comparison evidence

R3-FB2420-TEMPORAL-COMPARISON-085. Technical comparison complete; no production or
scientific rule adopted. [report.md](report.md) gives the findings and limits.

- `comparison-spec.json`: unchanged phase084 formulas, interval IDs and context scales.
- `execution-plan.json`, `source-bindings.json`, `implementation-freeze.json`: pre-execution scope, source identities and implementation hashes.
- `fixedIntervalDiagnostic.m`, `fixedNativeContacts.m`, `fixedHumanContacts.m`: standalone arithmetic/contact helpers.
- `testFixedIntervalDiagnostic.m`, `known-shape-tests.json`, `independent-known-shape-tests.json`: pre-execution tests and independent checks.
- `runTemporalComparison.m`, `plotTemporalComparison.m`, `execution-01.log`: single source execution and the two predetermined illustrations.
- `run-01/comparison-summary.csv` and `.json`: readable two-scale descriptors; unavailable numerics remain blank/null with status.
- `run-01/comparison.json`: exact ingredients, descriptors, statuses, contact frames and native contributors for all 28 rows.
- `run-01/case-*-corrected.csv`, `case-*-footprint.json`, `case-*-native-contacts.json`: source-bound trace/support ingredients.
- `run-01/original-automatic-rows.csv`, `original-researcher-reviews.json`, `human-interval-sources.json`: separate source annotations and automatic output.
- `verify_comparison.py`: original frozen independent verifier. `verify_comparison_corrected.py` adds only null/empty parent-metadata equivalence; `implementation-correction-01.json` records the one corrective round.
- `run-01/independent-verification.json`, `visual-review.json`, `preservation.json`: completed arithmetic, visual and preservation checks.
- `artifact-record.json`, `completion.json`: sealed artifacts and completion state.

MATLAB source is copied as `.m.txt` in the portable repository packet to keep it
outside production path discovery. Runnable `.m` files remain in the local
`reference-validation/boi-fb2420-temporal-comparison-20260915` packet. The runner
rejects an existing `run-01` folder rather than overwriting evidence. Python checks
use the standard library. Source bindings retain local development paths; this
packet is not a deidentified public release.

No source movie was reloaded, detector run, correction refitted, optical baseline
adopted or event reclassified. The 48-event development panel has not been rerun.
