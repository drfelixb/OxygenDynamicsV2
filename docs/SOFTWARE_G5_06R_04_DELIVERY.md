# SW-G5-06R-04 offline delivery

28 September 2026. The researcher approved the [offline decision card](SOFTWARE_G5_06R_04_OFFLINE_PROPOSAL.md): six named saved-data cases, at most eight evaluations, no process launch or live Run. The [one-use result](../../reference-validation/software-g5-isolation-revision-20260928/saved-controller-gate-20260928/summary.json) records **8/8 passes**, one positive **in-memory release intent**, zero negative intents, and no code drift between the recorded pre/post evaluation hashes. No retry or post-evaluation code edit occurred.

The [guarded controller](../../reference-validation/software-g5-isolation-revision-20260928/guarded_run_controller.py) arms the existing helper policy before the first scan, calls `scan` then `assess_pre_run` on each startup snapshot, binds the later worker receipt through `bind_reported_worker`, and stops on a failed gate. After the other injected preflight guards, `consider_release` requires a distinct, later snapshot and repeats `scan` then `assess_pre_run` immediately before its injected sink. In this delivery, the sink held an intent in memory. The consumed one-use SW-G5-06 supervisor was left unchanged; no live release writer is connected.

| Case | Evaluations | Offline outcome |
|---|---:|---|
| `matched_helper_group_or_session_change` | 2 | Changed helper PGID and SID each failed closed; no intent. |
| `arm_after_first_scan` | 1 | Late policy arming rejected. |
| `controller_pre_ready_to_final_intent` | 1 | Provisional pre-ready wait, matching worker receipt, verified helper exit and fresh final assessment yielded exactly one in-memory intent. The saved call trace shows `scan → assess_pre_run` on every startup snapshot and `scan → assess_pre_run → intent_sink` at the final boundary. |
| `controller_attestation_missing` | 1 | Missing receipt reached the 65-second modeled pre-Run deadline; no intent. |
| `controller_final_escape_or_identity_error` | 2 | New escaped PID and changed precise identity at the final snapshot each stopped the controller; no intent. |
| `controller_stale_final_snapshot` | 1 | Reused startup snapshot rejected; no intent. |

Before copying, SHA-256 of the saved `trigger.json` and `stop-report.json` matched `76634a8dac7b6bf1ceb84fbff503b0f127ca716e8e00fff58151f6814a56f8ea` and `9ba7c7564183837acbd773c83b27da3b8987fc824680eea3bf7000a228b7c85e`; copied files still match. The final [helper policy](../../reference-validation/software-g5-isolation-revision-20260928/startup_helper_policy.py) and [isolation guard](../../reference-validation/software-g5-isolation-revision-20260928/isolation_guard.py) retained their pre-check hashes `882d062a203efc4d9c50992c6e5d54ba336514371c02084f91d77ed278a6fade` and `810c61f11d3d1586e211302b0c495b1dfb2b4659f49e0e1d8b713963100b5d39`. The new controller and offline runner hashes were recorded in `code-hashes-before.json` and the result; they stayed unchanged throughout evaluation.

The offline harness injected saved identities, argv and snapshots. It blocked live `ps`, `subprocess`, `Popen`, and signal calls while evaluating; it sent **zero signals**, launched **zero child processes**, and created no `go.json`, attempt marker or recorded-run output. No MATLAB, detector, statistics or recorded movie executed. The work received **assistant self-review only**; no independent human reviewer participated.

This is saved-data evidence for the final policy and controller decision ordering. It does **not** validate a live Run caller, actual process containment, MATLAB startup, resource limits, or real-acquisition analysis. Any live writer connection, new SW-G5-06 attempt, SW-G5-07, G5 acceptance or release requires a separate decision.
