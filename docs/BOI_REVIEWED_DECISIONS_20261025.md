# Current reviewed burden export

25 October 2026. REVIEW-BURDEN-02. Owner: root; no delegation.

Felix explicitly rejected FB2319 sink site 7/event 2 and requested exclusion
from reviewed burden, preserving the automatic result. The existing review
workflow saved a new immutable `not_recognized` revision with empty endpoints
and his reason. MATLAB's Researcher boundaries tab visibly shows the saved
status, revision path, reviewer and history.

The fresh burden-only export carries all three existing decisions:

- FB2319 site 7/event 2: rejected and excluded.
- FB2317 site 13/event 5: earlier rejection remains excluded.
- FB2412 site 20/event 1: the already approved single-event result is imported
  with onset 114, recovery 182, reference 104–113 and 69 inclusive seconds.
  Normalized contribution remains 187950.456671 using the original saved area;
  its earlier/later spatial extent has not been remeasured.

Workbook:
`reference-validation/boi-reviewed-decisions-20261025/ReviewedBurden/ReviewedHypoxicBurden.xlsx`.
MAT, CSV tables, the three saved review snapshots and an exact copy of the
approved event artifact accompany it. The original combined export and earlier
reviewed workbook remain unchanged.

## Calculations and source evidence

The existing reviewed exporter has an optional fourth input containing completed
approved single-event artifact folders. The default three-input behavior is
unchanged. Imports validate the artifact manifest, exact audit/raw-source and
recognition/boundary/reference links, and replay the approved raw optical
arithmetic. Area, recording exposure and original event identity must match the
automatic snapshot. No reference, endpoint or amplitude sign is inferred.

All retained events use the existing burden calculator and independent full
recording exposures. The formula and normalization are unchanged. Missing
required contributions continue to withhold complete sums; no partial sums are
introduced. The existing within-recording rank sensitivity includes the newly
available amplitude and therefore changes ranks within FB2412 as expected.

Automatic `StartFrame`, `EndFrame`, `DurationSec`, optical amplitude and
`Episode*` fields remain original evidence. Reviewed calculations and frame-wise
burden use **BurdenStartFrame**, **BurdenEndFrame** and **BurdenDuration_sec**.
**EventRevisions** lists the exact approved import, selected reference and area
qualification. **ReviewSummary** counts actual available/missing reviewed
contributions. Episode-reference summaries separately retain automatic evidence.

## Demonstrated result

- Same 17 recording identities and exposures; 5,407 original detections.
- Two rejected detections; 5,405 retained detections; one approved value import.
- 3,257 available and 2,148 missing contributions. All 17 complete recording
  burdens remain unavailable under strict missingness.
- Twelve focused synthetic cases pass, including earlier default behavior,
  saved review precedence, missingness, identity/conflict checks, reviewed
  interval/frame updates, source rounding and area/exposure preservation.
- The named approved artifact loads and a changed disposable copy is rejected.
- MAT/workbook/CSV readback passes. All 17 recording totals and frame traces are
  checked from every retained event, without missing-value omission.
- Independent XLSX verification compares 583,274 unchanged automatic/other-event
  cells, replays ranks and frame-wise values across 17 recordings, and reports
  zero error cells. The approved normalized contribution is retained.
- Original source MAT and workbook checksums, 32 earlier artifacts and 574
  previously protected MATLAB source files remain unchanged.

The first attempt stopped before creating an export folder because JSON area
metadata differed from the binary source by two machine ULPs. Only area metadata
matching now permits up to 32 ULPs; source hashes, identities and clocks remain
exact. The next attempt completed. A verification-only resume accounts for CSV
decimal serialization (observed maximum 39 ULPs, bounded at 64), with exact
missingness; workbook numeric readback is exact. Neither repair changes science
values, formulas, defaults or an earlier result.

Evidence lives in `reference-validation/boi-reviewed-decisions-20261025/`:
`final-verification.json`, `independent-workbook-verification.json`,
`focused-checks.json`, source-binding/readback diagnostics and preservation
records. About 111 MiB new output/evidence is below the 256 MiB allowance.
The work used the running MATLAB session; no detector, correction, source movie,
new area measurement, extra recording or Git transport was used.

Delivered and stopped. Further event judgments remain with the researcher.
