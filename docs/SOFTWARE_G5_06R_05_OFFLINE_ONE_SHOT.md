# SW-G5-06R-05 — offline one-shot release intent

28 September 2026. Researcher-authorized bounded fix and check following acceptance of SW-G5-06R-04. Owner: Codex; assistant self-review only unless an independent reviewer participates. User benefit: the release decision cannot authorize a second sink call after success or after an uncertain partial sink effect.

Change only the launch-agnostic `guarded_run_controller.py` and a new saved-data runner. Reserve an in-memory intent claim immediately before calling the injected sink; consume it permanently whether the sink returns or raises. Reject a later call even with a fresh final snapshot. A claim can be injected and shared across controller instances for the offline check. This is **not** a durable live claim or live writer.

Before evaluation, verify the original `startup-diagnostic/evidence/trigger.json` SHA-256 `76634a8dac7b6bf1ceb84fbff503b0f127ca716e8e00fff58151f6814a56f8ea` and `stop-report.json` SHA-256 `9ba7c7564183837acbd773c83b27da3b8987fc824680eea3bf7000a228b7c85e`. Copy both into a new packet. Keep `startup_helper_policy.py` at `882d062a203efc4d9c50992c6e5d54ba336514371c02084f91d77ed278a6fade` and `isolation_guard.py` at `810c61f11d3d1586e211302b0c495b1dfb2b4659f49e0e1d8b713963100b5d39`. Record final code hashes before and after evaluation.

Maximum **two named saved-data evaluations**, one per case, no retry. An evaluation may contain time-ordered snapshots and an attempted second call. Use only saved process tables and a hypothetical ready receipt; intercept any live process-table, subprocess or signal call. The sink and its simulated side effect exist only in memory. No process or MATLAB launch; no `go.json`, attempt marker, run output, detector, statistics or recorded-movie execution.

| Case | Expected result |
|---|---|
| `second_fresh_call_after_success` | Complete saved startup and fresh final gate; first sink call records one in-memory intent. A second call with a distinct later snapshot is rejected as already consumed; sink count remains one. |
| `sink_side_effect_then_exception` | Sink records one simulated in-memory side effect, then raises. Controller fails closed and marks the claim uncertain/consumed. A fresh-snapshot second call and a recreated controller sharing that claim cannot call the sink again. |

Stop before evaluation on source/hash mismatch, existing packet, changed policy/guard, or inability to intercept all live providers. Stop on first failed case without retry; report any remaining case untested. Acceptance is two passes, no code drift, exactly one sink invocation per case and no second authorization. A real writer and durable claim, live caller, MATLAB/recorded-movie attempt, SW-G5-07, G5 acceptance and release remain separate decisions.
