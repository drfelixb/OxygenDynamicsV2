# SW-G5-06 execution record — ID400 awake

28 September 2026. Researcher approved **SW-G5-06 only** under the [revised decision card](SOFTWARE_G5_06_PRE_RUN_PROPOSAL.md). This record was opened **before** the one permitted Run. SW-G5-07, G5 acceptance and release are not authorized.

## Locked attempt and expected state

- Source: `reference-validation/boi-id400-awake-run-20260921/run-01/Recording`; real-acquisition `FX01 / ID400 awake`, not a synthetic fixture.
- Source SHA-256, rechecked at 06:35 UTC: TIFF `fc980cfc800ddc830a6dd122f64b734458a16b55de738bad2c7896b7064c2aaf`; metadata `22e0c14d32fad5cf6055abde041a5e5d09a8b1847cdebf9ab04042d97bb7348c`; tissue support `34268277ccbe0ba7d28764986451bec024616b338b16116719a078d45a856571`.
- G2 request `reference-validation/software-g2-workflow-20260923/gui-run/RunRequest.mat`, SHA-256 `fd67cf9f30e85bf39bf4c744bbe28e649b84491a1a26f800c34909411b9518d3`. The read-only request preflight matched G2 sources, analysis parameters, context and input review; only the output path differs. The worker repeats this and the GUI preflight before release.
- Effective sampling is externally triggered 1 Hz for this supplied source; 4.75 µm/pixel; source-bound `craniotomy-roi-1` working support, decision `R1-ID400-AWAKE-RUN-112`; 33 G2 analysis settings unchanged. Input status remains `descriptive_input_requires_scientific_review`.
- New output: `reference-validation/software-g5-real-id400-run-20260927`, absent at 06:35 UTC. Destination had 165,068,800,000 free bytes, above the 8 GiB floor. No existing result will be overwritten.
- One-use worker: `reference-validation/software-g5-real-id400-worker-20260928/runG506Worker.m`, SHA-256 `778efc83e5b611fd7647fd0485085e9888996ea3dd8c82fede8720ae75568a79`. Supervisor `supervise_g506.py`, SHA-256 `c80df15d821c52d2e3ea94b1d57b1e236bf5bf96a2ad25d543c945e1d36d7643`.

The supervisor verifies hashes, space and new-path absence before launching disposable MATLAB. The worker prepares an unchanged request and reports ready. **Before the one Run**, the supervisor verifies its dedicated process-group leader differs from the supervisor and existing MATLAB groups, the actual MATLAB worker and descendants remain in that group, source hashes still match, output is still absent and free space remains sufficient. It then writes a one-use release token; the worker rechecks the request and writes an attempt marker immediately before `ui.Run()`. Any failed pre-Run guard must stop without an attempt.

The approved stop budget is one attempt and no retry; 600 seconds from release (a conservative start just before `ui.Run()`), sampled 3 GiB output, sampled 12 GiB process-tree RSS, and an 8 GiB free-space floor. Samples use `ps` PID/PPID/PGID/RSS at about one-second intervals and sum RSS within the isolated group; `/usr/bin/time -l` independently records launch maximum resident set size in the worker log. The supervisor may stop **only the verified disposable process group**. A threshold stop, error or process exit remains incomplete regardless of stale saved `running` status. Preserve its folder and report any observed threshold overshoot. Stage callbacks and saved `RunStatus.json` provide lifecycle evidence.

## Pre-run / result log

At record creation: all three source hashes matched; output and all one-use control/result files were absent; free space exceeded 8 GiB. Python supervisor parsed; the harmless process-group self-test had passed in the prior pre-run check. MATLAB Code Analyzer returned **0 messages** for the final worker. Host `/usr/bin/time -l /usr/bin/true` exited 0 and reported maximum resident set size. **No SW-G5-06 movie run had started.**

## Outcome of the first supervised launch

The supervisor launched disposable MATLAB at **06:37:09 UTC**. Its launcher PID and dedicated PGID were both **54129**; the supervisor PGID was **54127**, and pre-existing MATLAB PGIDs were **13074** and **13079**. During startup, before the worker reported ready, the supervisor found a descendant outside PGID 54129 and stopped the dedicated group. The launch exited with code **-15** at **06:37:20 UTC**. The monitor did not persist the escaped descendant's PID/command, so its identity and why it left the group are **unknown**. The worker log reached the input-status display, but no ready/release file was written.

The [saved supervisor report](../../reference-validation/software-g5-real-id400-worker-20260928/supervisor-result.json) records `StopReason=descendant_left_isolated_group_before_run`, `AttemptMarkerSeen=false`, zero resource samples after Run release, no worker result and no saved RunStatus. The proposed output folder does not exist. A read-only process-table check after stop found no MATLAB process. The supervisor preserved its control, log and result files, which also prevent accidental one-use relaunch. No `ui.Run()`, detector, statistics or recorded-movie execution occurred. No runtime, real-run peak memory, output size, both-sign result or G2 numerical comparison can be reported from this launch. `/usr/bin/time -l` did not emit a maximum resident set size for the process that received SIGTERM; that measurement is unavailable.

**SW-G5-06 result: untested / blocked by its pre-Run isolation guard.** This is a safe stop, not a successful real-acquisition integration check or evidence of an engine failure. Under the decision card's stop-and-report/no-retry rule, no further launch will be made from this approval. A revised isolation design and any further real-acquisition attempt require a new bounded decision. SW-G5-07, G5 acceptance and release remain open.

The researcher accepted this pre-Run stop and untested classification on 28 September 2026. The [bounded isolation revision proposal](SOFTWARE_G5_06_ISOLATION_REVISION_PROPOSAL.md) is planning only; it does not authorize another MATLAB launch or recorded-movie attempt.
