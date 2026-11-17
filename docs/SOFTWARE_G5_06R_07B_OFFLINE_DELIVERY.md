# SW-G5-06R-07B offline delivery

28 September 2026. Owner and reviewer: Codex assistant self-review; no independent reviewer participated. The researcher approved the 13 named, one-use offline evaluations in the [decision card](SOFTWARE_G5_06R_07B_PREFLIGHT_BOUNDARY_PROPOSAL.md), with no process/MATLAB launch, live worker token or recorded movie. All 13 cases ran once; no retry occurred.

The one-use [hash manifest](../../reference-validation/software-g5-r07-code-20260928/r07-boundary-code-hashes.json) pinned **10 executable/harness files before evaluation**, including the already-updated static gate and new harness. The [saved result](../../reference-validation/software-g5-r07-preflight-boundary-recheck-20260928/summary.json) reports **13/13 pass**, exact pre/post hash equality and no code drift. Source checks matched the three ID400 files, their aggregate source-map hash, the saved G2 request, and both saved process-table hashes before the packet was created. The updated read-only static gate subsequently passed on that summary and the current pinned code. The previous 10/10 result remains historical; this is the current offline gate.

| Cases | Outcome | Claim/token files per disposable case | Saved worker acknowledgement |
|---|---|---|---|
| Matching handshake | Pass | 1 / 1 | 1 |
| Old `go.json`, incompatible version, mismatched nonce, output, source hash, settings hash and worker birth identity (seven separate cases) | Pass; each rejected at its named contract check | 1 / 1 in each case; tokens were deliberately made incompatible or an old token was added after the offline claim | 0 in each case |
| Slow sample | Pass; `monitor_gap_over_one_second` | 0 / 0 | 0 |
| Prompt exit | Pass; saved acknowledgement classified after a post-token tree scan | 1 / 1 | 1 |
| Delayed preflight, cached snapshot | Pass; `final_snapshot_predates_completed_preflight` | 0 / 0 | 0 |
| Delayed preflight, monitor gap | Pass; `final_snapshot_capture_error_RuntimeError: final_monitor_gap_over_one_second` | 0 / 0 | 0 |
| Short preflight, fresh publication | Pass; one eligible startup-only offline token | 1 / 1 | 0; no worker was present |

The new ordered traces are saved in each case result. For the **cached snapshot**, simulated preflight ran from monotonic 17.802 to 18.402; the provider then returned the older 17.802 snapshot. The controller recorded `other_guards_passed → capture_final_snapshot → stop`, with no scan, claim or token. For the **monitor-gap** case, preflight ended at 19.052 after a simulated 1.25-second delay. The provider called the final-capture helper, which rejected the >1-second interval before returning a snapshot; the controller stopped without a claim or token. For the **short preflight** case, the order was `preflight start → preflight complete → final capture → scan → assess → claim reserve → startup token sink`, with one disposable claim and token. Simulated delays advanced a mocked monotonic clock; they did not wait in real time.

The runner blocked child-process creation, live `ps` calls and process signals. It reports zero child-process/MATLAB launches, zero live-worker tokens and zero recorded-movie runs. The live control packet and proposed recording output remain absent. These are saved-table and Python contract/caller checks, not live MATLAB worker or containment evidence. The unspent SW-G5-06R-07 startup launch remains on hold; any launch needs a separate researcher decision. Actual Run-token integration, real-acquisition integration/resources, SW-G5-07, G5 acceptance and release remain open.
