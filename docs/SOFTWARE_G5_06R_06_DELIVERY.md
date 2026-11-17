# SW-G5-06R-06 filesystem-only delivery

28 September 2026. The researcher approved the [revised five-case decision card](SOFTWARE_G5_06R_06_LIVE_WRITER_PROPOSAL.md) for implementation and **one disposable filesystem evaluation per named case**, with no automatic retry and no process/MATLAB/live Run. The [precheck](SOFTWARE_G5_06R_06_PRECHECK.md) recorded the source, policy and final-code hashes and exact disposable paths before evaluation. The [one-use summary](../../reference-validation/software-g5-isolation-revision-20260928/saved-durable-writer-20260928/summary.json) records **5/5 passes**, all five evaluations consumed, no code drift and no rerun. This was assistant self-review only; no independent reviewer participated.

The [durable claim and writer](../../reference-validation/software-g5-isolation-revision-20260928/durable_release_writer.py) use exclusive, flushed claim creation before token publication. A complete token is published from a flushed temporary file by a no-overwrite hard link, followed by directory flush and byte verification. The [guarded controller](../../reference-validation/software-g5-isolation-revision-20260928/guarded_run_controller.py) binds the saved ready receipt and attested worker to the claim, then passes the final gated intent to the injected writer. The consumed one-use supervisor was not changed. All tokens below were in disposable case directories with no waiting worker.

| Case | Observed saved outcome |
|---|---|
| `single_release_then_fresh_second_call` | One claim and one token; later fresh-snapshot call rejected as consumed. Claim and token hashes unchanged. |
| `side_effect_then_writer_exception` | Token published, then injected exception; claim and token retained. A new controller reading the same directory rejected retry, with both hashes unchanged. |
| `preexisting_claim_only` | Seeded claim unchanged, no token, zero writer invocations. |
| `preexisting_token_only` | Seeded token unchanged, no claim, zero writer invocations; inconsistent state rejected. |
| `payload_identity_mismatch` | Payload nonce differed from matching claim and ready receipt. Writer rejected it after reservation and before token creation; claim remained consumed, with no retry. |

The copied saved source hashes and final code hashes matched their pre-evaluation values. The harness blocked live process-table, subprocess and signal calls; it launched no child process or MATLAB session and performed no detector, statistics or recorded-movie execution. There was **no live Run release**. `go.json` files in the packet are isolated filesystem fixtures, not actual worker releases. The preexisting-token case intentionally retains its seeded token. The first failing case would have stopped the harness; none failed.

This evidence supports the disposable filesystem contract and one-shot controller/writer integration only. It does not establish power-loss durability, live process containment, MATLAB startup, actual worker response to `go.json`, real-acquisition runtime/resources or release readiness. Connecting a live caller or making another named SW-G5-06 attempt, SW-G5-07, G5 acceptance and release require separate decisions.
