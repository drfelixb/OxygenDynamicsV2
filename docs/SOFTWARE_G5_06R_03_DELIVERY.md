# SW-G5-06R-03 bounded delivery

28 September 2026. The researcher approved implementation of the [revised decision card](SOFTWARE_G5_06R_03_DECISION_CARD.md) and **seven named saved-fixture cases, at most twelve evaluations**. No process-tree launch, MATLAB diagnostic, detector, statistics, recorded-movie run or retry was authorized or performed. SW-G5-07, G5 acceptance and release remain unapproved.

The new [startup helper policy](../../reference-validation/software-g5-isolation-revision-20260928/startup_helper_policy.py) is pure process-table logic. The [existing isolation guard](../../reference-validation/software-g5-isolation-revision-20260928/isolation_guard.py) now exposes `enable_startup_helper_policy` before its first scan and `assess_pre_run` after each scan. These methods cannot create `go.json`, signal a process or launch MATLAB. A future supervisor must treat a failed assessment as a stop and may use `run_eligible` only together with its other source, GUI, output and resource guards. The consumed one-use SW-G5-06 supervisor and startup diagnostic were not changed or relaunched.

The policy accepts a **provisional** match only for the exact `/usr/sbin/system_profiler` child/parent arguments and live MATLABWindow → MATLAB → `/usr/bin/time` launch ancestry, with matching precise birth identity, UID, SID and PGIDs. It tracks the child and any observed descendants, keeps Run blocked until a later matching worker attestation and two clean helper-exit snapshots at least one second apart, and uses a 20-second helper and 65-second pre-Run deadline. A new or changed escape, identity ambiguity, monitoring error/gap, missing attestation or timeout fails closed. The prior diagnostic's helper was first seen outside the original group; no group transition was directly observed, and the saved evidence cannot rule out a process between samples.

The one-use [saved-fixture result](../../reference-validation/software-g5-isolation-revision-20260928/saved-helper-policy-20260928/summary.json) reports **12/12 passes across seven cases**:

| Case | Evaluations | Saved outcome |
|---|---:|---|
| `pre_ready_lineage_attest_then_exit` | 1 | Provisional wait → matching receipt → two clean exit snapshots → eligible. |
| `helper_timeout_or_no_worker_attestation` | 2 | Both variants blocked at their respective deadlines. |
| `changed_executable` | 1 | Rejected. |
| `changed_argv` | 1 | Rejected. |
| `lost_or_wrong_ancestry` | 1 | Rejected. |
| `birth_uid_sid_pgid_mismatch` | 4 | Each single-field variant rejected. |
| `second_helper_or_other_escape` | 2 | Both rejected; both escaped PIDs retained in the result. |

The runner verified SHA-256 of the original `trigger.json` and `stop-report.json` **before copying**, then reverified the copies. The copied files retain those hashes. Fixture mutations were in memory. No signal was sent; `would_stop_tracked_live_pids` records only hypothetical targets. The implementation and report had **assistant self-review only**; no independent reviewer participated.

**Post-fixture self-review limit.** After the twelve evaluations were consumed, a static review added two fail-closed guards: a matched helper changing PGID/SID is rejected, and the policy cannot be armed after the first guard scan. The final files parse successfully, but those two additions were **not re-evaluated against fixtures** under the exhausted budget. The tested policy SHA-256 was `b34059064b26cae447b87f70e3edbba276791ebf4a210c85126457ad5e994f39`; the final policy SHA-256 is `882d062a203efc4d9c50992c6e5d54ba336514371c02084f91d77ed278a6fade`. The guard's final hash also differs from its tested version. The saved matrix supports the tested policy and a static review of the final hardening, **not** a claim of final-code live validation.

No Run-release supervisor was exercised with this policy. The future caller still needs a bounded integration check that proves it calls `assess_pre_run` on each startup scan, blocks on failure, binds the later worker receipt to the recorded MATLAB identity, and checks the gate immediately before any release. Real-acquisition integration, resource measurement, analysis/statistics engine-internal failures and release remain open. Any further fixture evaluation, process launch or recorded-movie attempt requires a separate decision.
