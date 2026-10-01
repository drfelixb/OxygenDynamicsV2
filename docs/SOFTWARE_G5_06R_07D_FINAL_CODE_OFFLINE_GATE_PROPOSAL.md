# SW-G5-06R-07D — proposed final-code offline gate

29 September 2026. **Approved and delivered within the offline limits below; see the [delivery record](SOFTWARE_G5_06R_07D_FINAL_CODE_OFFLINE_DELIVERY.md).** Owner and self-reviewer: Codex assistant; no independent reviewer participated. The researcher had accepted the SW-G5-06R-07B 13/13 result for its original hashes and SW-G5-06R-07C's one-case deadline result for its revised hashes. This card defined the new 14-case final-code gate. The MATLAB startup remains held.

## User benefit and boundary

The startup-only acknowledgement should retain the earlier schema, process-policy and final-snapshot behavior while enforcing the live 65-second token deadline on every path that can publish a token. This gate uses saved process tables, a mocked monotonic clock and disposable token directories. It changes no BOI measurement, source recording, scientific rule or Run path. It does not authorize `ui.Run`, master, detector, statistics, an attempt marker, a live worker token, MATLAB startup or a recorded movie.

The live caller supplies `launched_at + 65.0` to `StartupAckWriter`. A deadline reached before its atomic write call must reject publication and leave the one-shot claim consumed. **A filesystem publication that begins before but finishes at or after the deadline is classified `incomplete`** by the caller's post-return 65-second check, regardless of whether a token or worker acknowledgement exists. The pre-write check alone cannot prove publication completion time. The 14-case matrix below tests the pre-write crossing and ordinary on-time publication; it does not simulate a slow filesystem operation spanning the deadline. The gate must statically verify that the post-return check still precedes any success classification, and report the slow-publication path as dynamically untested.

## Exact one-use matrix

Maximum **14 evaluations**, one attempt per named case, in a new disposable packet `reference-validation/software-g5-r07-final-deadline-gate-20260929/`. Preserve the prior case names and order; run the 13 SW-G5-06R-07B cases once each on the final revised code, followed by the SW-G5-06R-07C late-token case:

| # | Case | Required result |
|---|---|---|
| 1 | `matching_handshake` | Deadline-enabled writer publishes one on-time disposable startup token; matching saved acknowledgement accepted. |
| 2 | `old_go_json` | On-time deadline-enabled token and claim; old `go.json` causes the named worker-contract rejection, no acknowledgement. |
| 3 | `incompatible_version` | On-time deadline-enabled token, then incompatible schema is rejected, no acknowledgement. |
| 4 | `mismatched_nonce` | On-time deadline-enabled token, then nonce mismatch is rejected, no acknowledgement. |
| 5 | `mismatched_output` | On-time deadline-enabled token, then output mismatch is rejected, no acknowledgement. |
| 6 | `mismatched_source_hash` | On-time deadline-enabled token, then source-hash mismatch is rejected, no acknowledgement. |
| 7 | `mismatched_settings_hash` | On-time deadline-enabled token, then settings-hash mismatch is rejected, no acknowledgement. |
| 8 | `mismatched_worker_identity` | On-time deadline-enabled token, then worker-birth mismatch is rejected, no acknowledgement. |
| 9 | `slow_sample` | Sample gap stops before claim or token. |
| 10 | `prompt_exit` | Deadline-enabled writer publishes one on-time token; saved acknowledgement is verified after prompt worker exit and post-token scan. |
| 11 | `delayed_preflight_cached_snapshot` | Cached pre-preflight snapshot is rejected; zero claim and token. |
| 12 | `delayed_preflight_monitor_gap` | Fresh capture after >1-second gap is rejected; zero claim and token. |
| 13 | `short_preflight_fresh_publication` | Fresh post-preflight scan/assessment leads to one claim and one on-time deadline-enabled disposable token; no live worker action. |
| 14 | `deadline_crossed_after_final_snapshot_before_token_write` | Final snapshot before 65 s, mocked writer entry after 65 s, `startup_token_deadline_before_write`, failed controller, one consumed claim and zero tokens. |

For **every token-producing case** (1–8, 10 and 13), the new gate must instantiate the same deadline-enabled writer configuration as the live caller: one-second maximum final-snapshot age and an absolute `launch + 65.0 s` deadline. Assert the configured deadline, pre-write clock and post-write completion clock; an omitted deadline is a failure even if the old schema result still passes. For cases 2–8, deliberate token mutation or the old-file addition happens **after** the on-time writer publication. The negative cases must retain their specific rejection IDs. The late case must verify order, failure reason, `stop_required`, claim/token counts and absence of a second attempt.

## Preparation, hash gate and stopping rule

After separate approval, make only the harness and necessary static-gate adaptations. Prefer a new consolidated one-use harness; preserve the historical result packets and manifests. Before any case, update the live caller's static gate to require the **new 14-case summary**, so it remains closed while that summary is absent. Then pin final SHA-256 values for **every executable and harness file used**, including `startup_ack_contract.py`, `supervise_r07_startup.py`, `runG506R07StartupWorker.m`, `guarded_run_controller.py`, `isolation_guard.py`, `startup_helper_policy.py`, `durable_release_writer.py`, the three prior R07 runners, the R07C runner, the imported `run_g506r04_offline_cases.py` fixture helper, and the new consolidated harness. If an implementation uses additional local executable modules, pin those too. Record the exact 14-case list and maximum in the same manifest. No final hash can be claimed before the harness and static gate are final.

Before creating the packet, verify the manifest against the current files, parse Python files, and reverify the saved startup trigger/stop hashes, the three read-only ID400 source-file hashes, aggregate source-map hash and saved G2 request/settings hash already named in the [R07B manifest](../../reference-validation/software-g5-r07-code-20260928/r07-boundary-code-hashes.json). Ensure the new packet, held live packet and proposed recording output are absent. During evaluation, block child-process creation, live `ps`, process signals, MATLAB and live worker communication. Use mocked time without real waits. Record ordered caller/controller traces, identity and reason, writer deadline and timing, claim/token/ack counts, and output absence for each case. Verify all pinned hashes again after the last attempted case, and require exact pre/post equality.

**Stop on the first failed case, source/fixture mismatch, unpinned import, hash drift, unexpected process action or output.** Mark remaining cases `untested`; do not repair and rerun within this budget. A pass requires 14/14 once each, all expected paths and counts, no code drift, no live packet or proposed recording output, and the static post-publication incomplete rule. The live static gate may then pass for these exact hashes, but it must not trigger a launch; the MATLAB startup remains held for a separate researcher decision. Deferring this gate leaves the current live static gate closed. A passing offline matrix would still not validate a live acknowledgement, slow filesystem publication timing, real-acquisition integration, SW-G5-07, G5 acceptance or release.
