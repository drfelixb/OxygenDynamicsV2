# Revision 31: bounded signed-contribution implementation and tests

**Completed locally, 13 November 2026.** R31-01..03 are delivered and all 36
frozen evaluations pass; [delivery and consumed limits](BOI_REVISION31_DELIVERY.md).
No active milestone or automatic further testing remains. Historical approval,
proposal and hold wording below describes the lead-up, not the current state.

**Execution explicitly approved and resumed by the researcher, 13 November 2026.**
The bounded work below is now authorized without further permission requests
inside its limits. Original planning/hold statements are retained as history.
Active scope/counters: `reference-validation/boi-revision31-implementation-20261113/scope.json`.
The initial review-export regression supplies the signed XLSX artifact for the
new readback check; no ninth workbook attempt is added. Positive legacy approved
review scalars remain import-compatible with signed parents because their exact
products are unchanged; explicit incompatible signed/legacy policies are rejected.

13 November 2026. **Proposed execution scope; implementation and numerical
verification remain explicitly held.** Owner: root, sequential work, no delegation.
The scientific rule is already agreed in
[contract revision 31](BOI_COMPACT_EXPORT_PLAN.md#burden-formula-normalization-and-completeness).
This plan does not reopen that decision or authorize a run. Its
[finite execution manifest](planning/boi-revision31-execution-proposal-20261113.json)
records the proposed checks, sources and limits; no test code is written now.

## Result and scope

Newly calculated revision-31 results include every retained event's finite signed
contribution when the other required ingredients are available. Negative values
remain signed and flagged; they subtract in the complete total. Implement this
consistently in the existing automatic, reviewed, recording, window and saved
burden-series routes, and their existing detailed exports. No new event detector,
baseline measurement, image analysis, episode judgment or compact-workbook
implementation belongs to this milestone.

Keep the following expressions unchanged:

`contribution_i = amplitude_percent_i * event_mean_area_um2_i * duration_s_i`

`normalized_burden = sum(contribution_i) * 1e6 / recording_area_um2 * 60 / recording_duration_s`

Keep the event-specific twenty-second reference and its version, event footprint,
mean area, saved duration, recording area/time, original signed integral,
detector/correction and all historical results unchanged. No absolute value,
clamping, zero fill, positive-only/partial sum, coverage scaling or additional
normalization. Missing ingredients and explicit reviewed not-pocket exclusions
remain distinct from negative values and quality flags. Sink and surge roles,
existing grouping and statistical weighting remain unchanged.

## Three sequential work batches

| Item; owner root | User benefit and implementation | Acceptance and stopping condition |
| --- | --- | --- |
| R31-01, batch 1 | Introduce a separate burden-selection policy, proposed identifier `boi-signed-contributions-1`, and thread it through newly calculated results. Include finite signed inputs without changing reference arithmetic or product/scaling kernels. | The selector, event/recording calculations, existing windows and burden time series use the explicitly identified policy. Unknown/mixed policies or conflicting identities stop the affected operation. Old saved values retain their actual policy; absence of metadata does not certify signed adoption. |
| R31-02, batch 2 | Add negative-amplitude/contribution states, retained negative-contributor counts and finite-total sign. Carry the policy through reviewed imports and existing export tables, definitions and receipts. | Flags describe the actual selected automatic/reviewed ingredients, not a different original-reference column. Missing values are not assessable; zero is nonnegative. Only finite retained negative products count as negative contributors. A negative amplitude with missing area is flagged but is not counted as an available contribution. Reviewed authority and exclusions are preserved. |
| R31-03, batch 3 | Execute the frozen constructed/synthetic checks and existing-format round trips; report value/sign/completeness, source preservation and remaining limitations. | All selected checks pass within the limits below. Then stop with a concise report and synthetic evidence. No extra campaign, individual-example investigation, real-data export or next milestone begins automatically. |

The initial numerical run starts only after R31-01/02 are concrete and their
scope/selected test names are frozen. Routine code/test/harness corrections stay
inside the single permitted repair. A repair does not authorize a baseline,
formula, normalization, source or test-family change.

## Version and compatibility behavior

- A burden-selection version is separate from the unchanged event-reference
  version. Newly computed automatic results explicitly select the signed policy;
  reading/copying an older result never silently adopts or relabels it.
- Existing unversioned/older calculation entry points and legacy saved outputs
  retain their documented historical behavior unless a new calculation explicitly
  selects the signed policy. No legacy fallback rescues a genuinely unavailable
  selected ingredient. Unsupported/mixed versions stop before publication.
- A selected reviewed export must match its parent automatic snapshot and policy.
  Retained unchanged values stay unchanged. Imported approved signed values keep
  authority even when the review path removes automatic reference-selector fields.
  Do not reinterpret old reviewed artifacts or rewrite their accepted scalars.
  A policy conflict is reported rather than repaired through an event review.
- The reviewed-event loader currently also requires a nonnegative amplitude.
  Its validation must become policy-aware for explicitly signed, source-bound
  artifacts while retaining old-schema validation and unchanged reviewed
  reference/area/timing arithmetic. No individual-review or area-authoring GUI
  extension is included; import checks use constructed saved artifacts only.
- Output labels/definitions identify a **signed burden composite**. Preserve
  positive, negative and zero totals; do not describe them as guaranteed
  nonnegative oxygen deficits. Existing column/file roles remain available.
- Existing availability reports must not count a negative value as excluded by
  sign under the new policy. Historical exclusion counts retain their actual
  historical meaning. Quality, missingness, sign and review exclusion are separate.
- The compact exporter remains a saved-value copier. This milestone supplies
  versioned upstream values for later use, not a new six-sheet workbook or a
  recalculation performed while copying an old workbook.

## Finite source and edit boundaries

Read repository source/documentation and use constructed inputs only. Existing
synthetic fixture helpers may create disposable MAT/CSV/JSON/XLSX files inside
the new evidence/scratch area. No existing recording workbook, saved raw/ROI
trace, movie, event audit, mask, review artifact, note or Labguru payload is a
development fixture here. Zero real-recording inputs; all five reserved
recordings remain untouched. No individual pocket inspection or biological
judgments, even if a check fails. Do not call old saved-example drivers: in
particular `runBOIEventBaselineFlagsChecks` automatically reads a historical
saved-trace fixture and is outside this plan.

Expected production edits are limited to the shared burden selector/calculator,
recording/sign summaries, existing window caller, reviewed adapters, automatic
availability reports, existing workbook writers/definitions/receipts and policy
metadata at the current master/stats entry points. Exact paths are enumerated in
the manifest. The recording aggregator may receive sign/provenance summaries;
its product, strict summation, exposure factors and weighting do not change.
No baseline/reference calculator or detector/mask/timing implementation is edited.
At most two new small production helpers supply the policy and sign summaries.
Test changes are limited to one new finite suite/driver and the enumerated
synthetic test files if their version expectations need explicit separation.
Unrelated dirty work is preserved. Any necessary expansion is a checkpoint,
not permission to search more recordings or widen the method.

## Frozen constructed checks: twelve functions, at most 24 executions

| Planned check | Required result |
| --- | --- |
| S01 Finite signed products and flags | Positive, negative and zero amplitudes produce unchanged signed products. Sign flags follow the actual selected value; unavailable stays not assessable. |
| S02 Complete totals of either sign | Complete retained sets can yield positive, negative or cancelling-zero totals; no term is silently dropped. |
| S03 Genuine missing ingredients | Missing amplitude, area or duration keeps required contributions and complete totals unavailable; negative finite neighbors remain available. |
| S04 Analyzed zero versus unavailable inventory | A known analyzed zero-event result remains zero; missing/unprocessed inventory never becomes zero. |
| S05 Normalization exactly once | Use varying constructed area/duration and non-1-Hz clocks. Preserve percent scale, calibrated event ingredients and the exact existing area/time factors; no extra factor of 100 or event A/T division. |
| S06 Descriptive reference/quality flags | Short, overlapping, post-event and above-recording-reference flags do not exclude finite signed inputs. The local reference itself remains unchanged. |
| S07 Reviewed signed authority | Unchanged/unreviewed values retain source meaning; an explicitly selected compatible signed review governs its burden ingredient and flags without overwriting automatic/reference/AUC evidence. |
| S08 Exclusions and recording identity | Explicit not-pocket exclusions affect reviewed membership only. Repeated local IDs across constructed recordings/mice/conditions cannot move a decision or denominator. |
| S09 Historical policy preservation | Old-version saved objects remain byte-identical and retain their policy/value. Only an explicitly new calculation can emit a new signed-policy artifact. |
| S10 Version and source conflicts | Unsupported/mixed policies, wrong parent sources and ambiguous identities stop before output; no silent fallback or relabelling. |
| S11 Windows and burden series | Negative terms reach existing windows/series. Compare recording/window totals only when ingredients/support match. A complete saved curve reconciles using existing frame intervals and 60/T; missing samples cannot supply a replacement partial total. |
| S12 Existing-format persistence | Existing XLSX/CSV/MAT routes preserve signed numbers, zero, missingness, flags/counts, identities and policy. Availability/guide text does not claim sign exclusion for signed-policy output. |

Use small tables: at most four constructed recordings, 32 event rows and 300
frames per recording in each new scenario. Existing named synthetic fixtures
retain their current sizes. These are software fixtures, not individually
reviewed biological examples. Test function names and the 24 existing synthetic
regressions are listed in the manifest. Existing regression drivers that run
additional suites or real/saved examples are not used. Select only the frozen
functions through the existing MATLAB unit-test runner.

Independent expected-value arithmetic uses declared scalar/table inputs, not
the production selector or calculator as its own oracle. Formula/scaling values
and file round trips use `1e-10 * max(1,abs(expected))`; identities, versions,
counts, statuses and source preservation agree exactly. Existing tolerances for
reading an approved review scalar are preserved, not relaxed. The tests verify
software behavior and reporting; they do not certify detection sensitivity,
biological reference suitability or actual cross-mouse comparability.

## Proposed budget: not allocated until explicit execution authorization

| Limit | Proposed maximum |
| --- | --- |
| Active engineering effort | 4 hours total, including implementation, tests, repairs, evidence and closeout |
| Sequential implementation batches | 3 |
| Routine code/test/harness repairs | 1 combined repair cycle |
| New constructed evaluations | 12 frozen functions; at most 24 executions including retries |
| Existing synthetic regressions | 24 frozen functions; at most 48 executions including retries |
| MATLAB process starts | 2 total, initial plus one targeted retry/restart; no separate desktop session |
| XLSX writer attempts | 8 total, synthetic inputs only, including existing-regression writes and failed/retry attempts |
| Process-tree resident memory | 2 GiB |
| New evidence/scratch/output | 100 MiB combined, including all synthetic MAT/CSV/JSON/XLSX output |
| Real recording inputs / biological case reviews | 0 / 0 |

Every attempted start/write and every executed selected function counts. Reuse
the existing monitored launcher/test pattern with a direct frozen-suite runner;
do not invoke its historical saved-example steps. First run all frozen functions
once. If needed, use the one repair and rerun only failed/affected functions
within the same counts. Once acceptance passes, do not broaden or repeat tests.

These are a **new proposed allowance for this narrow adoption only**. They do
not reset the completed baseline/comparison allowances, borrow the compact-export
budget or authorize extra source fixtures. The separate compact-export limits
remain unchanged: six hours/four batches/two repairs, eight families/24 executions,
two MATLAB starts/four named-workbook export attempts, 4 GiB, 100 MiB evidence
and 25 MiB workbook output. No compact implementation runs concurrently here.

## Delivery and stop

Deliver the narrow code change, identified policy/field definitions, finite test
report, synthetic existing-format export/readback evidence and preservation
record. Write new evidence into a separate directory; original results are not
overwritten, recalculated, opened as fixtures or relabelled. Update project
tracking truthfully, preserving historical Done cards. No commit/push, package,
release, publication, real 17-recording run/export, detector revision or next
milestone is included. Completion demonstrates this contract on finite synthetic
inputs; a later real-data export remains a separate explicit execution step.

Stop when these acceptance checks pass, or when any approved time, memory,
output, attempt, repair or source boundary is reached. Preserve a checkpoint
with the uncompleted item; do not substitute individual investigations. The
alternative is to retain the documented revision-31 agreement and current
unchanged software until implementation is explicitly resumed.

**Current state: plan prepared for review only. No implementation/test code,
MATLAB launch, numerical verification, recording payload read or workbook
generation is authorized or performed by preparing this plan.**
