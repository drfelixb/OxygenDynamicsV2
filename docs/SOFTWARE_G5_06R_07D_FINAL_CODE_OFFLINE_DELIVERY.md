# SW-G5-06R-07D final-code offline delivery

29 September 2026. The researcher approved the [14-case decision card](SOFTWARE_G5_06R_07D_FINAL_CODE_OFFLINE_GATE_PROPOSAL.md) for one-use saved-data evaluation only, with no process or MATLAB launch, live worker token, `ui.Run` or recorded movie. Owner and reviewer: Codex assistant self-review; no independent reviewer participated.

The [pre-evaluation manifest](../../reference-validation/software-g5-r07-code-20260928/r07-final-deadline-code-hashes.json) pinned **13 final executable/harness files**: the startup contract and live supervisor, MATLAB startup-only worker, guard/controller/helper/durable writer, all reused R07 fixture runners, the imported saved-context helper and the new consolidated harness. It also fixed the 14-case order, three ID400 source hashes and their aggregate, G2 settings hash and saved trigger/stop hashes. All matched before the packet was created. The old R07B 13-case and R07C one-case manifests/results remain byte-identical to their hashes recorded in the new manifest.

The [saved result](../../reference-validation/software-g5-r07-final-deadline-gate-20260929/summary.json) reports **14/14 pass**, one evaluation per case, with no retry or code drift. All 13 code hashes and the manifest hash matched before and after. The read-only live static gate rejected startup before the new result existed and passed afterward on this exact 14-case summary and hashes. No MATLAB launch followed that gate.

| Cases | Saved trace and file outcome |
|---|---|
| Matching handshake | On-time deadline-enabled writer: one claim/token and one valid saved acknowledgement. |
| Old `go.json`, incompatible version, mismatched nonce, output, source hash, settings hash and worker identity | Seven distinct worker-contract rejections after an on-time deadline-enabled token: one claim/token and zero acknowledgements in each case. Only the old-file case added `go.json`, inside its disposable fixture. |
| Slow sample | >1-second sample gap stopped before release: zero claims, tokens and writer calls. |
| Prompt exit | On-time deadline-enabled token and verified saved acknowledgement; post-token tracking classified the prompt exit. The pure caller check returned `startup_token_after_65_second_deadline` at 65.0 s and classified that late completion `incomplete` even with a valid acknowledgement. |
| Delayed preflight with cached snapshot | Preflight completed at 18.402 s, then provider returned a 17.802 s snapshot; `final_snapshot_predates_completed_preflight`, zero claim/token. |
| Delayed preflight with monitor gap | Preflight completed at 19.052 s; fresh capture hit `final_monitor_gap_over_one_second`, zero claim/token. |
| Short preflight with fresh publication | Preflight complete → fresh capture → scan → assess → claim → on-time deadline-enabled token at 18.002 s; one claim/token, no live worker. |
| Late token | Final snapshot/claim at 64.8 s → writer entry at 65.05 s; `startup_token_deadline_before_write`, failed controller, one consumed claim and zero tokens or acknowledgements. |

Every token-producing case used the one-second snapshot-age limit and an absolute 65-second writer deadline; the saved result records pre/post writer clocks and configuration per case. The final harness blocked child-process creation, live `ps` and process signals. It reports **zero child-process/MATLAB launches, zero live worker tokens and zero recorded-movie runs**. The live control packet and proposed recording output are absent. These checks alter no BOI science or original recording.

**Limits.** No named case remains untested within the 14-case matrix. A filesystem publication that *finishes* at or after 65 seconds is classified `incomplete` by the caller's post-return check; the pure classification path was checked, but an actual slow filesystem write spanning the deadline was **not** simulated. The pre-write guard cannot establish publication completion time. Live MATLAB acknowledgement, containment, `ui.Run`, real-acquisition integration, SW-G5-07, G5 acceptance and release remain untested or unapproved. The startup-only MATLAB launch remains held pending a separate researcher decision; this offline gate is not launch approval.
