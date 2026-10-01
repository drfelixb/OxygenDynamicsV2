# SW-G5-06R-05 offline one-shot delivery

28 September 2026. The researcher accepted SW-G5-06R-04 within its offline limits and requested the [bounded one-shot fix](SOFTWARE_G5_06R_05_OFFLINE_ONE_SHOT.md) before any live-writer proposal. The [saved result](../../reference-validation/software-g5-isolation-revision-20260928/saved-one-shot-intent-20260928/summary.json) records **2/2 passes**, one evaluation per named case, no retry and no code drift. This is assistant self-review; no independent reviewer participated.

The [controller](../../reference-validation/software-g5-isolation-revision-20260928/guarded_run_controller.py) now reserves a one-shot `MemoryIntentClaim` after the fresh final `scan → assess_pre_run` gate and before invoking the injected sink. Success marks the claim delivered. A sink exception leaves it `reserved_uncertain`; a second `consider_release` fails with `release_intent_already_consumed` before another sink call. The optional injected claim permits an offline recreated controller to share the consumed state. This in-memory claim **does not survive a process crash** unless a future caller supplies separately approved durable storage.

| Saved-data case | Result |
|---|---|
| `second_fresh_call_after_success` | First final gate produced one in-memory sink invocation and delivered claim. A later distinct snapshot yielded `release_intent_already_consumed`; no second sink invocation. |
| `sink_side_effect_then_exception` | The sink recorded one **simulated in-memory side effect** then raised. The controller returned `intent_sink_error_RuntimeError`, left the claim `reserved_uncertain`, and rejected both a fresh-snapshot second call and a recreated controller using the same claim. One sink invocation total. |

Original saved source hashes were verified before copying and the copies still matched. The unchanged policy and guard retained hashes `882d062a203efc4d9c50992c6e5d54ba336514371c02084f91d77ed278a6fade` and `810c61f11d3d1586e211302b0c495b1dfb2b4659f49e0e1d8b713963100b5d39`. The final controller hash was `c0271ca71858dad883ffc3a3b3c49bd242000defed78e2a00b40b9f0f3c584f1`; it and the runner hash were recorded before evaluation and were unchanged after it. The harness blocked live process-table, subprocess and signal calls. It created no `go.json`, attempt marker or run output, sent no signal and performed no MATLAB, detector, statistics or recorded-movie execution.

The controller still has **no live writer**, durable one-shot claim or actual Run caller. The [SW-G5-06R-06 card](SOFTWARE_G5_06R_06_LIVE_WRITER_PROPOSAL.md) is a separate proposed decision. A live process, real-acquisition run, SW-G5-07, G5 acceptance and release remain unapproved.
