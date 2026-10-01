# CC-02 completion extension: final saved-data gate passed

30 September 2026. **All 14 named cases pass on the final unchanged code.** ID400, FB2312 and C02 each demonstrate explicit preview → immutable save → reopen → export, including the selected-event export and portable saved-artifact reader. The researcher accepted this bounded numerical/integration delivery and the demonstrated main-window workflow on 30 September 2026. Native chooser interaction and standalone viewer layout remain open usability items. Overall usability, G5 and release remain unaccepted; this is not physiological validation.

The earlier [partial delivery](SOFTWARE_CC_02_INTEGRATION_PARTIAL_DELIVERY.md), failures, consumed original budget and original evidence are retained. Only the separately approved extension was used to complete this slice.

## Finished workflow

C02's final saved example is open in the existing MATLAB desktop under **Reviewed optical → Reviewed pocket (0.2.0)**. Its blue curve is the matching saved corrected intensity; green points are exactly the explicitly selected reference samples. The saved detector sign and original automatic amplitude remain at the top. Its conditional primary and raw companion appear together. The unchanged saved surge footprint and its qualification accompany the result.

Use the [MATLAB opening recipe](reference-results/cc-02-completion-20260930/open-final-reviewed-examples.m.txt) to open all three saved examples. It displays their existing saved revisions without new pocket arithmetic. Historical ID400/FB2312 dimensions are obtained from their explicitly selected, source-matched conversion reports; original audits are not rewritten.

1. **Select** a saved event. Selection does not infer a pocket interpretation, reference, endpoint or new reviewed value.
2. **Enter explicit choices**: interpretation, onset/observed-end frames, exact reference frames, suitability, endpoint status, reviewer, reason, and established recording-specific external 1 Hz authority.
3. **Preview draft** calculates the two quantities using the identical frames and original fixed footprint, with source-associated saved correction only. It labels the result unsaved. A missing matching correction never becomes a normalized detection score or a new fit.
4. **Save NEW revision** chooses a parent through the native directory chooser and writes a new generated child folder. Previous reviewed revisions and the automatic result are retained. A changed draft needs a new preview.
5. **Reopen saved revision** chooses its completed folder. This displays stored values without pocket arithmetic replay. Source/event/frame/footprint/revision/schema integrity is checked.
6. **Export SAVED revision** creates a new folder with MAT/JSON evidence, definition, exact-sample CSV, fixed-pixel CSV, measures CSV, readable methods/results and checksums. Unsaved edits are excluded. **Export selected evidence** in Saved event evidence includes this artifact under `ReviewedPocket/`, alongside unchanged automatic and legacy evidence.

The three final saved revisions, pocket exports and selected-event exports are under the workspace-root `reference-validation/cc-02-completion-extension-20260930/`, named `batch-02-T01-*`, `batch-02-T02-*`, and `batch-02-T03-*`. Readable results are `Evidence.md` inside each saved/exported reviewed folder. Primary export filenames are the same for all examples, distinguished by their enclosing folder and explicit audit/event identity.

## Preserved numerical meaning and three demonstrations

Primary = `100 × min((corrected(W) − mean(corrected(R))) / mean(raw(R)))`.

Companion = `100 × min((raw(W) − mean(raw(R))) / mean(raw(R)))`.

The raw reference mean must be finite and positive. No sign clipping, absolute value, filtered-score substitution, reference extension, sample dropping, correction refitting, automatic relabelling or footprint replacement occurs. Negative means downward optical change, not oxygen percentage or absolute pO2. Raw and corrected extrema may differ in general; all tied minimum frames are retained.

| Example and saved identity | Episode W / reference R | Corrected primary % | Raw companion % | Preserved qualification |
|---|---|---:|---:|---|
| ID400 historical audit row 41; sink site 11/event 1; 1,100 pixels | 82–98 / 73–81 (9 samples) | −5.0523405688433565 | −4.328656254545948 | Accepted local-state fixture reference; both minima frame 88; saved sink footprint; reviewed extent not independently established. |
| FB2312 row 194; surge site 1/event 2; 3,684 pixels | 398–417 / 378–397 (20 samples) | −8.362579856515431 | −8.138502968125097 | Recovery unresolved; 417 is observation end, not confirmed recovery; both minima 404. Measured on saved surge footprint; pocket extent not independently established. |
| C02 row 321; surge site 5/event 1; 5,086 pixels | 177–195 / 165–170 (6 samples) | −12.383756977559301 | −11.104931801071126 | **Conditional** provisional reference throughout; both minima 186; original automatic amplitude remains unavailable. Measured on saved surge footprint; pocket extent not independently established. |

Values match the accepted CC-01 targets within the already specified `1e−10 × max(1, abs(expected))` percent tolerance. Small cross-language reduction/printing differences do not replace the targets. Saved MAT values, exact arrays, flags and complete reviewed payloads are identical through reopen and both exports (`isequaln` assertions). The structured case receipts retain full-precision MATLAB values. Confirmed pocket duration is not calculated by this slice, including when a recovery observation is supplied; FB2312's unresolved recovery cannot be promoted to confirmed duration.

A fixture's `accepted_local_state` is an explicitly reused scientific-review choice, not a new independent physiological judgment. C02 remains conditional. The saved surge sign remains in FB2312/C02; reviewed pocket interpretation is separate and never contributes replacement automatic counts, occupancy or statistics.

## Final named validation results

All results below come from **batch 02**, on one pinned set of 527 executable/definition/harness files. Its final post-test gate passed for code, sources and fixtures. The first matrix also passed 14/14 on its earlier hashes, but a subsequent screenshot-driven presentation repair made the second complete matrix necessary. No first-matrix pass was silently transferred to changed code.

| Case | Final result | Demonstrated outcome |
|---|---|---|
| T01 ID400 | Pass | Numeric target/minima/frame/footprint checks, scalar arithmetic, preview/save/reopen, draft exclusion, both export routes, saved portable open, explicit replay, actual corrected-curve sample assertions. |
| T02 FB2312 | Pass | Same journey; preserved saved surge footprint, exact reference, unresolved recovery and no confirmed duration. |
| T03 C02 | Pass | Same journey; conditional six-frame reference everywhere, saved surge footprint, unavailable automatic amplitude preserved. |
| T04 legacy compatibility | Pass | Existing G2 completed-run navigation/event selection; no inferred new pocket record; retained raw-only 0.1.0 definition; unchanged G4 C02 reviewed amplitude `not_calculated`. |
| T05 missing correction | Pass | Corrected primary explicitly unavailable; separate raw companion; save/load and explicit replay retain missingness. |
| T06 correction/source mismatch | Pass | `OxygenDynamics:PocketIdentityMismatch`; no output folder created. |
| T07 changed footprint | Pass | `OxygenDynamics:PocketIdentityMismatch`; unchanged footprint required; no folder created. |
| T08 stale judgment/boundary revision | Pass | `OxygenDynamics:PocketRevisionMismatch`; stale result cannot be saved; no folder created. |
| T09 reference overlaps episode | Pass | `OxygenDynamics:InvalidPocketFrames` before calculation/save; no replacement samples or folder. |
| T10 nonfinite reference sample | Pass | Explicit `unavailable_nonfinite_reference`; selected sample not dropped; save/load/replay preserve unavailable values. |
| T11 nonpositive reference mean | Pass | Both quantities unavailable with `unavailable_nonpositive_reference_mean`; no corrected-mean denominator substitution. |
| T12 reference judged unsuitable | Pass | New revision withholds both quantities; prior immutable artifact hash and automatic row unchanged. |
| T13 empty reference | Pass | Explicit `unavailable_empty_reference`; no inferred reference; saved artifact retains empty membership. |
| T14 incompatible reviewed schema | Pass | `OxygenDynamics:UnsupportedPocketSchema` on reopened exported fixture; no automatic migration. |

The dependent cases consume their prerequisite only after T01 has a **pass receipt on identical pinned code**, with exact saved/export paths and manifest hashes. No alias or hard-coded historical `batch-01-T01` path is used by the new harness. A prerequisite failure stops the batch; dependency checks cannot count a failed prerequisite as their expected rejection.

The GUI actions use the actual callbacks exposed by the existing event reviewer, with new disposable destinations. The named walks check actual plotted corrected samples, preview/save state, stored payload equality, explicit replay separation, export draft exclusion, and visible suitability/endpoint/footprint text. Screenshots of the final main review windows are retained. User interaction with the native choosers was not exercised in this extension; their programmatic destination paths and callback wiring were exercised. A final saved C02 review was reopened in the already-running user desktop for handoff, without a launch or new calculation.

## Implementation and routine repairs

CC-02-01: separate versioned definition/judgment, explicit suitability/recovery status, exact frames and revisions.

CC-02-02: saved-ingredient arithmetic, source/correction association, signed minima on one fixed footprint, historical dimension adapter, unavailable/identity gates.

CC-02-03: existing event review has pocket/legacy subviews, explicit controls, primary corrected curve, exact reference markers, saved footprint, automatic measure and separate reviewed quantities. The corrected curve uses a single axis; its samples are asserted in the three final walks. The prior nested state-getter repair is now exercised by successful saves.

CC-02-04: new immutable revision folders, manifests and pre-directory identity gates; saved-only reopen; explicit arithmetic replay; earlier revisions preserved.

CC-02-05: structured/readable reviewed exports and integration into selected-event evidence; automatic and legacy payloads retained separately. Portable evidence embeds definition and implementation hashes, raw/corrected vectors, exact memberships and original pixel identities.

Harness repairs normalize decoded case IDs, use explicit passing-artifact receipts, stop on the first failed gate and refresh cached code between jobs. The disposable driver is a base-workspace script; before each job it performs `clear functions`, `rehash`, and an unloaded-function guard. This clears only the disposable session, not the user's workspace. The driver and harness hashes are included in the pins. A TTY was retained for process control; no interrupted/cached executable was reused as revised-code evidence.

After the first pass, screenshot inspection identified an absent corrected curve on dual axes and an overlapping portable plot/text capture. The final code uses a single corrected axis and explicit portable grid rows, and all 14 cases were repeated. Corrected-curve visibility/sample checks pass. **Portable `exportapp` screenshots still show plot/text overlap at the default small window size.** The cause and behavior across native window sizes were not separately tested under the consumed evaluation budget. The main existing review window is visually readable and was shown natively; use it for this acceptance. The standalone portable viewer's small-window/capture layout remains a usability limitation, not a numerical replay failure or a claim of fully accepted presentation.

## Budget, preservation and limits

Extension used **28/28 additional case evaluations**, two recorded batches with no separate ceiling, **one of two saved-data MATLAB starts**, less than four hours, and less than 500 MiB new disposable evidence (exact bytes and elapsed time in `budget.json`). The first full matrix and one final full matrix account for all 28. The disposable test session exited with code 0 after its close flag. The already-open user MATLAB desktop remains open with the final saved C02 review. No further case evaluations are authorized under the consumed extension.

All 44 original preservation inputs remain unchanged; the extension's 47 pinned inputs, including the copied saved-vector fixtures and unchanged scientific pairs, remain unchanged. No original audit, recording, completed-run index, automatic/legacy output, accepted earlier packet or dirty-worktree change was reset/overwritten. Historical partial failures are retained. Source hashes, final code manifest and post-test gate are provided with the delivery packet. Review is **assistant self-review only**, not independent review.

**Zero recording/movie runs, detector/master/statistics-engine runs, correction refits, footprint changes, automatic relabelling, packaging or release work.** Release remains paused; licensing, hosted CI, successful live acknowledgement/containment and real-acquisition resource blockers remain open. Historical `containment_failure` and consumed launch approvals are unchanged.

Remaining limits: physiological validity/reference contamination beyond the explicit chosen pairs; pocket spatial extent/native overlap; independent anatomical support/edge uncertainty validation; future clock/acquisition types; broad cohort/general regression coverage; original-audit absence/relocation beyond this matrix; manual native-chooser acceptance; standalone portable small-window layout; independent review; package closure for these new files. None is claimed resolved by the 14-case arithmetic/integration gate. No automatic diagnostic or later milestone begins with this delivery.

## Review the finished examples

- [ID400 main reviewed workflow](../../reference-validation/cc-02-completion-extension-20260930/batch-02-T01-review.png).
- [FB2312 main workflow: recovery unresolved](../../reference-validation/cc-02-completion-extension-20260930/batch-02-T02-review.png).
- [C02 main workflow: conditional reference](../../reference-validation/cc-02-completion-extension-20260930/batch-02-T03-review.png).
- [Final named receipts and gate](../../reference-validation/cc-02-completion-extension-20260930/batch-02-results.json).
- [Exact final executable/harness pins](../../reference-validation/cc-02-completion-extension-20260930/batch-02-code-pins.json).

## Researcher acceptance — 30 September 2026

The researcher accepted **CC-02’s bounded numerical/integration delivery and demonstrated main-window workflow only**. C02 remains conditional, FB2312’s recovery remains unresolved, and all saved-footprint qualifications are retained.

**Native chooser interaction and standalone viewer layout remain open usability items. Overall usability, G5 and release remain unaccepted.** This acceptance authorizes no further checks, launches or implementation. Historical execution evidence, numerical outputs, the formal `containment_failure` and consumed launch approvals remain unchanged. Release work remains paused; further work awaits separate direction.


## Resolution of the two open usability items — 1 October 2026

The researcher accepted [CC-02U’s bounded usability workflow](SOFTWARE_CC_02_USABILITY_COMPLETION_DELIVERY.md#researcher-acceptance--1-october-2026) at 1120 × 800 and 900 × 650, including demonstrated native save/reopen/export selections and cancellation. Standalone viewer layout and native chooser interaction are closed within that scope. The 30 September delivery and acceptance remain historical evidence; their then-open items are resolved by this later acceptance, without expanding scientific or release claims. C02’s conditional reference, FB2312’s unresolved recovery, all footprint qualifications and documented limits remain. Acceptance recording ran no further checks or launches. G5 and release remain unaccepted, and release work remains paused.
