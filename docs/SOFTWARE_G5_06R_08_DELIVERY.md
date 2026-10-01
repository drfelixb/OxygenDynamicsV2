# SW-G5-06R-08 saved-data delivery

29 September 2026. **10/10 approved one-use evaluations passed; no retries, failures or untested matrix cases.** Owner and reviewer: Codex assistant self-review; no independent reviewer participated. This is offline diagnostic/classification evidence, not live containment, a startup pass, G5 acceptance or release.

## Implementation and preserved boundaries

The guard now retains an unresolved child record before raising its stop: triggering row and ancestry, separate libproc/session-ID/continuity results, timestamps and refresh evidence. Native errno capture is implemented but was not invoked. libproc loading is lazy so importing the saved-data harness cannot load that native adapter. A complete BSD response can provide partial birth evidence when SID fails; an incomplete response provides **no verified birth identity and no retained buffer fields**. The fixtures deliberately supplied a poisoned birth field alongside a zero-byte response and verified it was discarded.

The guard blocks worker attestation and process eligibility once an unresolved child is recorded. A bounded cleanup method classifies at most two fresh full process tables, within one second of failure and within the supplied earlier deadline. It never clears the stop, promotes the unknown child into the verified registry, or signals that child. The stop report now includes unresolved records, independently of the verified-PID list. The existing helper policy, worker, release writer, consumed supervisor and scientific software were not changed. There is no command-name exception.

All ten cases retained `containment_failure`, false release intent and zero claims, tokens, attempt markers and run outputs. The harness blocked native/process APIs before importing the guard; it reported **zero blocked-adapter access attempts**, real process lookups, signals, child launches, MATLAB launches or recorded-movie executions. Injected waits only advanced an in-memory clock.

## Classifications and ordered traces

Trace notation: **L** = structured lookup; **S** = guard stop after evidence persistence; **F** = injected full-table acquisition; **C** = candidate classification; **U** = unresolved observation. Each result also checks attestation/release rejection and unknown-PID signal rejection without native calls. Full tables, stage-specific responses, candidate traces and in-memory evidence records are saved in the linked result files.

| Case | Result and classification | Ordered trace |
| --- | --- | --- |
| [1. libproc_failure_then_absent](../../reference-validation/software-g5-r08-saved-child-20260929/01-result.json) | Pass: `candidate_absent_on_fresh_tables` | L(libproc failure) → S → F → F → C |
| [2. sid_failure_then_absent](../../reference-validation/software-g5-r08-saved-child-20260929/02-result.json) | Pass: `candidate_absent_on_fresh_tables` | L(SID failure) → S → F → F → C |
| [3. persistent_libproc_failure](../../reference-validation/software-g5-r08-saved-child-20260929/03-result.json) | Pass: `candidate_persistent_unidentified` | L(libproc failure) → S → F → L → F → L → C |
| [4. persistent_sid_failure](../../reference-validation/software-g5-r08-saved-child-20260929/04-result.json) | Pass: `candidate_persistent_unidentified` | L(SID failure) → S → F → L → F → L → C |
| [5. birth_changes_across_sid](../../reference-validation/software-g5-r08-saved-child-20260929/05-result.json) | Pass: `candidate_identity_changed` | L(birth changes across SID) → S → F → F → C |
| [6. verified_birth_outside_group](../../reference-validation/software-g5-r08-saved-child-20260929/06-result.json) | Pass: `candidate_observed_escape_or_reparenting` | L(SID failure) → S → F → L → F → L → C |
| [7. unknown_birth_outside_group](../../reference-validation/software-g5-r08-saved-child-20260929/07-result.json) | Pass: `candidate_continuity_unproven` | L(libproc failure) → S → F → L → F → L → C |
| [8. absent_parent_surviving_descendant](../../reference-validation/software-g5-r08-saved-child-20260929/08-result.json) | Pass: `candidate_descendant_unresolved` | L(libproc failure) → S → F → F → C |
| [9. stale_refresh](../../reference-validation/software-g5-r08-saved-child-20260929/09-result.json) | Pass: `candidate_observation_unresolved` | L(libproc failure) → S → F(stale) → U |
| [10. refresh_timeout](../../reference-validation/software-g5-r08-saved-child-20260929/10-result.json) | Pass: `candidate_observation_unresolved` | L(libproc failure) → S → F → F(timeout) → U |

Fresh injected captures occurred at +0.30 and +0.60 seconds relative to the failed lookup. Case 9 stopped on its first stale table; it did not consume a second cached table. Case 10 reached the one-second bound on its second acquisition, with only one qualifying refresh. Neither requested a replacement sample. Case 8 separately retained parent absence and the surviving reparented descendant. Case 6 establishes birth continuity in derived data, but still does not establish signal ownership or allow release.

## Final hashes

The [pre-evaluation manifest](../../reference-validation/software-g5-isolation-revision-20260928/r08-final-hashes.json) pinned five project code/dependency/harness/fixture files and all eight files in the historical startup packet before evaluation. Every per-case hash check and the [post-test gate](../../reference-validation/software-g5-r08-saved-child-20260929/hashes-after.json) matched. No executable or harness was edited after the pin or evaluation.

| File | Final SHA-256 |
| --- | --- |
| `isolation_guard.py` | `7b587a8c04ec09eb1eaceba676f41dfe4ed12260a7f6307a4252ec04f5d5deca` |
| `process_identity_evidence.py` | `9195f191506e24314a0ec4f4f724eadd71974cf8847a04349d3f3fd71f5d3299` |
| `r08-fixtures.json` | `77d3cde4cb5dc09cf24206ab53a4fdb6341017aded51a62b90fa116657471acf` |
| `run_g506r08_saved_cases.py` | `5f282bb7f16a7b68aafa3ec3ff5e16ccc078c1026975aeacdea725eef8baebba` |
| `startup_helper_policy.py` | `882d062a203efc4d9c50992c6e5d54ba336514371c02084f91d77ed278a6fade` |

The historical packet remains byte-for-byte unchanged, including its formal `containment_failure`. Earlier 14/14 results remain evidence for their original hashes; they are **not** passes on the revised guard. The current live caller’s old hash gate must not be treated as satisfied by this matrix.

## Limits and stopping point

Dynamically exercised: structured identity logic through injected adapters; guard `_row_record()` persistence before raising; `reconcile_unresolved()` through injected captures/clock/lookups; `assess_pre_run()` and `bind_reported_worker()` rejection after a latched stop; unknown-PID signal rejection before any lookup or signal.

Not dynamically exercised: native libproc/errno and session-ID behavior; nonzero short-buffer and PID-mismatch variants; evidence-write failure; normal live guard construction and scanning; the complete `stop()` signal/cleanup loop; actual monitor timing, a tighter live supervisor deadline, live acknowledgement, or the broader prior release-controller regression matrix. The native wrapper and stop-report integration received static self-review only. The new diagnostic bounds do not demonstrate a live cleanup time guarantee. Unknown or unobserved descendants cannot be declared contained from two absent tables.

The [machine summary](../../reference-validation/software-g5-r08-saved-child-20260929/summary.json) reports ten consumed evaluations, ten passes, zero retries and a passing final hash gate. No further evaluation or live work is proposed or authorized by this delivery. Researcher review of this bounded evidence is the next decision; any future live work requires a separate proposal and approval.

**Researcher acceptance, 29 September 2026:** accepted as bounded offline diagnostic evidence only. Historical `containment_failure` unchanged; startup, G5 and release remain incomplete. No automatic retry or launch. The [next decision](SOFTWARE_G5_REAL_ACQUISITION_GATE_DECISION.md) is planning only: defer the real-acquisition gate as an explicit release blocker, or separately authorize independent containment review.
