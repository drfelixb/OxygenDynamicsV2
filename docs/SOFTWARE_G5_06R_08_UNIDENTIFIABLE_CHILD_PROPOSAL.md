# SW-G5-06R-08: saved-data unidentifiable-child decision card

29 September 2026. **Approved for implementation and at most ten one-use saved-data evaluations on 29 September 2026. No live operations authorized.** Owner: Codex assistant; review: self-review unless separately assigned. User benefit: explain an identity-lookup stop accurately and retain unresolved children in cleanup evidence, without granting an unsafe startup exception.

## Accepted evidence and limits

The researcher accepts the [17.1546-second startup](SOFTWARE_G5_06R_07_STARTUP_ATTEMPT.md) as fail-closed and incomplete. Its formal `containment_failure` remains unchanged. The single launch approval is consumed; no retry is available. The observed command text `(java_home)` is evidence text only, not a verified executable, identity, or policy exemption.

The saved trigger table contains PID 23091, PPID 22859, PGID 22857, UID 501 at 09:49:12.467 UTC; the preceding full table at 09:49:12.163 UTC does not contain it. The final saved cleanup table also lacks that PID. This does not establish which lookup failed, an exact exit time, or the absence of an unobserved descendant. `kernel_identity()` currently returns `None` both for an invalid libproc result and for `os.getsid()` raising `ProcessLookupError`. The historical failure cannot be assigned retrospectively to either stage.

Read-only fixture inputs, relative to workspace root:

| File | SHA-256 |
| --- | --- |
| `reference-validation/software-g5-r07-startup-only-20260928/summary.json` | `33fa02891fc5485b90cd3e13348cb8e6cfb5aebff81c6d8aba59524329898338` |
| `reference-validation/software-g5-r07-startup-only-20260928/evidence/trigger.json` | `65e1ee2c067bd47072a582eb4c8c540b7b8f7dfbf8c72f59c88e40b7c8bd3a47` |
| `reference-validation/software-g5-r07-startup-only-20260928/evidence/stop-report.json` | `1c7126af988f29f7e658a23434ea1c23482348533a189d0063b152f032863b20` |

Derived cases use these saved full tables as templates, with explicitly labelled in-memory changes to rows, timestamps and lookup responses. Invented birth identities, errno values and follow-up observations are synthetic, never attributed to the live attempt. The later read-only terminal observation is not a saved fixture table.

## Proposed bounded change

Limit implementation to structured identity-lookup evidence and unresolved-candidate classification in `reference-validation/software-g5-isolation-revision-20260928/isolation_guard.py`, plus a saved-data harness and necessary guard integration. Do not change the helper allow policy, worker, release writer, scientific software or consumed supervisor. Preserve the current identity API for existing callers if practical. No new release-success path is proposed.

On an unidentifiable new child, retain its triggering row, observed ancestry, original group and lookup evidence in an **unresolved-candidate record before raising the stop**. It must remain distinct from the verified registry and must not disappear from reporting simply because `remaining_live_pids` only lists verified identities. Startup stop is latched immediately: no readiness acceptance, claim, token, Run or automatic resume.

For a future separately approved attempt, cleanup may classify that candidate using at most **two newly acquired full process tables**, both captured after the failed lookup, at least 0.25 seconds apart and within **one second of that failure**. The tighter existing attempt deadline always wins; acquisition timeout uses only the remaining allowance. This is a bounded cleanup observation, not a retry of startup. If two qualifying tables cannot be obtained, record unresolved observation and continue the existing bounded stop procedure. Do not reset any attempt, monitor or cleanup deadline.

Search the whole table, not just the original PGID. Preserve every previously observed candidate/descendant link across reparenting. Record these distinctions:

- **Absent on two fresh full tables:** `candidate_absent_on_fresh_tables`. This is sampled absence, not verified exit of a known birth identity or proof that no descendant escaped. Never rename it `contained` or resume startup on this evidence alone.
- **Still present, lookup unavailable:** `candidate_persistent_unidentified`; retain it as potentially live and unresolved.
- **Identity changes:** where a valid partial libproc birth identity exists, a different birth/UID on follow-up means `candidate_identity_changed`. Where no original birth identity exists, a later successful lookup cannot prove continuity: `candidate_continuity_unproven`. A PID or name match is insufficient.
- **Outside the group or reparented:** retain and report the row wherever it appears. Call it an observed escape only with established birth-identity continuity; otherwise report a possible escape with uncertain ownership. Neither can authorize release.
- **Parent disappears but an observed descendant remains:** retain the descendant as unresolved; disappearance of the original candidate is not clean-tree evidence.

Ownership uncertainty keeps the formal stop outcome `containment_failure`, even when later rows are absent. Do not signal an unknown PID or an unverified group. Existing verified processes remain eligible only under the existing fresh identity checks; record inability to safely target an unresolved process. This proposal improves classification and evidence, **not** proof that every possible unobserved descendant was stopped. It deliberately does not unblock MATLAB startup.

## Future lookup diagnostics

Each lookup would record requested PID, linked table/observation ID, UTC and monotonic start/end, and separate stage results:

1. **libproc:** flavor and expected buffer size; reset ctypes errno immediately before the call and capture it immediately afterward; actual return length, returned PID when the complete structure is valid, success/short-or-zero result/PID mismatch/exception. Preserve valid partial birth/UID/PPID/PGID fields as partial evidence only. Do not interpret an invalid buffer as an identity or treat errno as conclusive proof of exit.
2. **Session ID:** `not_attempted` when libproc failed; otherwise returned SID, or exact exception class, errno and message for `os.getsid()`, including `ProcessLookupError` and other `OSError`. Distinguish this failure from libproc failure in the saved reason.
3. **Continuity:** if SID succeeds, recheck libproc birth/UID before treating the composed identity as verified; record that check separately and reject a mismatch or unavailable result. Never combine an old birth record with a new process's SID.

Save the structured failure before the stop exception. If evidence cannot be saved, latch an evidence failure and stop; do not substitute a successful identity or silently omit the unresolved candidate. Keep command names as descriptive fields only. These are proposed instrumentation requirements, not claims about what the consumed attempt already recorded.

## Ten named saved-data cases

Exactly **ten one-use evaluations maximum**, one per row in this order; no retries or spare evaluations. Each evaluation uses injected tables, lookup responses, clock and in-memory signal/release sinks. A successful case means the expected conservative outcome was observed, not successful startup. All cases must keep release intent false and produce zero claims/tokens/attempt markers/run outputs. Test no real process table, libproc call, SID query, sleep, signal or child launch.

| # | Case and exact injected condition | Required outcome |
| --- | --- | --- |
| 1 | `libproc_failure_then_absent`: zero-byte libproc response with injected ESRCH; SID not attempted; candidate absent from two fresh full tables at +0.30/+0.60 s | Preserve libproc diagnosis; classify sampled absence; stop latched, formal containment failure retained. |
| 2 | `sid_failure_then_absent`: full valid libproc record; getsid raises injected ESRCH; same two absence observations | Preserve partial birth evidence and session-stage failure; sampled absence, no verified-exit claim. |
| 3 | `persistent_libproc_failure`: zero-byte libproc response with injected EACCES; same candidate row remains in both fresh full tables | Persistent unidentified candidate remains potentially live; no signal to it or its unverified group. |
| 4 | `persistent_sid_failure`: valid partial libproc record; getsid raises injected EPERM; row remains in both tables | Session lookup distinguished from libproc; persistent unresolved state, no promotion to registry. |
| 5 | `birth_changes_across_sid`: successful first libproc/SID responses followed by a different birth on continuity recheck | Reject composed identity and classify identity change; do not signal the replacement PID. |
| 6 | `verified_birth_outside_group`: partial birth from failed SID lookup; later complete lookup retains that birth/UID but row has different PGID and PPID | Report observed group escape/reparenting with retained birth evidence; no release; only existing fresh ownership gates may nominate a signal target. |
| 7 | `unknown_birth_outside_group`: first libproc fails; later row has same PID outside group with new PPID and successful lookup | Report possible escape/continuity unproven; later lookup cannot establish ownership; no signal to that PID. |
| 8 | `absent_parent_surviving_descendant`: original candidate absent on both refreshes; a derived child linked to it in the trigger table survives and is reparented outside group | Report parent absence separately from unresolved surviving descendant; never claim a clean tree. |
| 9 | `stale_refresh`: two cached/pre-failure tables omit candidate, with completion timestamps that do not make them newly acquired tables | Reject freshness; classify unresolved, not disappearance; no release. |
| 10 | `refresh_timeout`: first fresh full table omits candidate; second acquisition is injected as a timeout at the one-second bound | Insufficient fresh observations; unresolved stop, no extra refresh or extended deadline. |

For cases 1–4, trigger `comm` is a neutral synthetic name and subsequent names may differ; no branch may depend on `(java_home)`. Cases 5–8 use explicitly synthetic identity/ancestry changes. Names must not enter ownership or eligibility decisions anywhere in this patch; verify by self-review before the matrix.

## Gates, outputs and stopping rule

Before evaluation, verify the three source hashes above, pin SHA-256 of every final changed executable, dependency used by the harness, harness and serialized fixture definition, and record a static call-path review. Inject OS adapters so execution cannot reach real lookup, process-table, signal or launch APIs. If this isolation cannot be established, stop before evaluation. Use a new `reference-validation/software-g5-r08-saved-child-20260929/` evidence folder only; stop if it exists. No files are copied into or mutated within the live packet. Derived data stays in memory or this new evidence folder; no `go.json`, claim, token, attempt marker or recording output is created.

Save ordered table/lookup/classification traces, simulated signal targets, release-intent and zero artifact counts, per-case pass/fail/untested, and pre/post hashes. Stop on the first failed assertion, missing ingredient, changed hash, unsupported lookup ambiguity, unexpected filesystem target or real OS adapter access. Mark remaining cases untested; do not fix and retry under this budget. Post-test hashes must match. A later edit invalidates coverage for its changed hashes; prior results remain evidence for their original hashes.

This card proposes one small implementation slice and ten offline evaluations only. It does not authorize MATLAB, synthetic child processes, a live caller, live tokens, detector/statistics execution, recorded movies, SW-G5-07, G5 acceptance or release. Historical 14/14 evidence is not a regression pass on future revised guard code. Live errno behavior, timing, containment and acknowledgement remain untested; any broader regression gate or future launch needs its own decision. Deferring this proposal leaves the current safe stop and its limited diagnosis unchanged.
