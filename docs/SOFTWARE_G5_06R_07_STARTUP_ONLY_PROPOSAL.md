# SW-G5-06R-07 decision card — startup-only live-caller integration

28 September 2026. **Approved for implementation, eight one-use offline evaluations and one conditional startup-only MATLAB launch.** The first conditional launch stopped before execution because the final code changed after that matrix; see [partial delivery](SOFTWARE_G5_06R_07_PARTIAL.md). After the separately approved [14/14 final-code offline gate](SOFTWARE_G5_06R_07D_FINAL_CODE_OFFLINE_DELIVERY.md), the researcher lifted the hold for one startup-only launch; its [saved attempt](SOFTWARE_G5_06R_07_STARTUP_ATTEMPT.md) stopped incomplete before acknowledgement, without retry. The researcher accepted [SW-G5-06R-06](SOFTWARE_G5_06R_06_DELIVERY.md) as disposable filesystem evidence, not a live release. Owner: Codex; report assistant self-review unless an independent reviewer actually participates. User benefit: demonstrate that a new, guarded MATLAB worker can exchange a one-shot, identity-bound acknowledgement with the supervisor while the process tree remains contained. This proposed check is **startup-only, with no `ui.Run` and no recorded-movie attempt**. It cannot close the fresh real-acquisition G5 gap.

## Why a new worker and schema are required

The consumed `runG506Worker.m` and `supervise_g506.py` belong to the exhausted SW-G5-06 attempt and must not be relaunched or modified. That worker reads top-level `Nonce` and `OutputFolder` from `go.json`, writes `attempt-marker.json`, then calls `ui.Run()`. SW-G5-06R-06 instead writes `g506r06-claim-1` and `g506r06-token-1` with a nested `identity` and `intent`; it has no MATLAB reader. Its current claim assumes `identity.output_path` is also the claim/token directory. Reusing either side unchanged would misread the token or claim the would-be recording output during a no-Run check.

Implement a **new** startup-only worker and caller under a new packet; preserve the old worker, supervisor and SW-G5-06R-06 evidence. The caller uses `IsolationGuard` and `GuardedRunController` with a versioned startup-only claim/token adapter. The control packet holds the claim and acknowledgement token; the proposed recording output remains a separate, absent path. This adapter may reuse the reviewed atomic no-overwrite file primitives, but may not turn the old `go.json` into a live Run release. No code path in the new worker may call `ui.Run`, the master, detector, statistics or an attempt-marker writer.

| New artifact | Required schema and identity |
|---|---|
| `control.json` | `g506r07-startup-control-1`: random one-use `Nonce`, canonical `ControlDirectory`, absent `ProposedOutputFolder`, mode `startup_ack_only`, exact three-file source-hash map and its aggregate `SourceHash`, `SettingsHash` bound to the saved G2 `RunRequest.mat`, and creation time. |
| Raw `worker-ready.json` | `g506r07-startup-ready-1`: `Nonce`, `ControlDirectory`, `OutputFolder` (the proposed, absent recording output), `WorkerPID`, `SourceHash`, `SettingsHash`, four explicit preflight-match booleans, `PreparedStatus`, and time. The worker derives the booleans from read-only request/GUI `Prepare` equality with the saved G2 request; echoing a hash alone does not prove source equivalence. |
| `attested-ready.json` | Supervisor-only, immutable extension of the raw receipt after precise PID/birth-identity verification. It adds `WorkerBirthUS` from the kernel identity, records the raw receipt hash, and is the receipt passed to the guarded controller. The worker is not asked to invent its own birth time. |
| `release-claim.json` | New versioned startup claim in `ControlDirectory`; identity binds nonce, control path, proposed output path, aggregate source hash, settings hash, attested worker PID/birth time, and `startup_ack_only` mode. Atomic exclusive creation and durable flush precede token publication. Claim remains consumed on any ambiguous error. |
| `startup-ack.json` | New versioned nested `identity` and final-gate `intent`, plus action `acknowledge_preflight_only`. Atomic no-overwrite publication in `ControlDirectory`. It is **not** named `go.json` and cannot authorize `ui.Run`. The worker validates the full identity against control and its PID, confirms the supervisor-attested birth time in `attested-ready.json`, writes one `worker-ack.json` with the token hash and `preflight_acknowledged_no_run`, closes the GUI and exits. |

The caller must validate all paths, schema versions, nonce, source/settings hashes, worker PID/birth identity and mode across these artifacts. It must reject missing, duplicate, stale, malformed or mismatched artifacts and any preexisting claim/token. It checks the exact helper policy on every startup snapshot and again on a **new final snapshot** after source/preflight, free-space and resource guards. A provisional pre-ready helper match remains tracked; worker attestation and verified helper exit are required before the startup acknowledgement token. On a writer exception after possible publication, retain the claim/packet, classify the outcome uncertain and do not retry. The final token is an acknowledgement only; actual Run-token integration would need another decision.

## Fixed source, settings and destinations

Use the existing local **FX01 / ID400 awake** recording only for read-only request and GUI preflight:

`/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-id400-awake-run-20260921/run-01/Recording`

| Saved input | SHA-256 reverified read-only 28 September 2026 |
|---|---|
| `preserved_original.tif` | `fc980cfc800ddc830a6dd122f64b734458a16b55de738bad2c7896b7064c2aaf` |
| `BOIInputMetadata.json` | `22e0c14d32fad5cf6055abde041a5e5d09a8b1847cdebf9ab04042d97bb7348c` |
| `BOITissueSupport.json` | `34268277ccbe0ba7d28764986451bec024616b338b16116719a078d45a856571` |
| Saved G2 `gui-run/RunRequest.mat` | `fd67cf9f30e85bf39bf4c744bbe28e649b84491a1a26f800c34909411b9518d3` |

The aggregate `SourceHash` is `23c333a9a0ce2cdb8be139ba2724e19b101fea747523cdf048a4408c13803c73`, defined as SHA-256 of UTF-8 `filename\0sha256\n` records sorted by filename for the three inputs above. `SettingsHash` is the saved G2 `RunRequest.mat` SHA-256; the worker must also compare `Sources`, `AnalysisParams`, `Context` and `InputReview` with that saved request, changing only `Options.OutputFolder`. This is the accepted 1 Hz external-trigger ID400 awake configuration, with the same `craniotomy-roi-1` working support and unresolved scientific limitations; there is no parameter or biological rule change.

New one-use control packet, **absent at card preparation**:

`/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/software-g5-r07-startup-only-20260928`

Separate would-be recording output, **absent at card preparation and required to remain absent throughout**:

`/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/software-g5-r07-reserved-id400-output-20260928`

The earlier SW-G5-06 packet and output name are not reused. The paths are on the local APFS data volume; the parent had `160,800,000` available 1 KiB blocks (about 153 GiB) at the read-only 28 September check. Recheck at least **8 GiB free** immediately before any approved launch. Do not create the proposed recording output or an attempt marker.

## Bounded implementation, checks and stop budget

Implementation would add one new startup-only MATLAB worker, one new supervisor/caller and the versioned adapter; it would not modify the consumed worker/supervisor or scientific engine. Before any launch, record new code hashes; statically inspect the complete worker call path for absence of `ui.Run`, master, detector, statistics and output/attempt claims. The offline matrix has **eight named evaluations maximum**, one attempt per case in a separate disposable control directory:

| Offline case | Required outcome |
|---|---|
| `matching_handshake` | Matching control, raw/attested ready, claim and `startup-ack.json` produce one matching worker acknowledgement. |
| `old_go_json` | The consumed worker's top-level `go.json` format is rejected; no startup acknowledgement or worker action follows. |
| `incompatible_version` | A token with an unsupported schema version is rejected without acknowledgement or fallback. |
| `mismatched_nonce` | A token nonce differing from control, ready and claim is rejected before acknowledgement. |
| `mismatched_output` | A proposed-output path differing from control, ready and claim is rejected before acknowledgement. |
| `mismatched_source_hash` | An aggregate source hash differing from the verified three-file identity is rejected before acknowledgement. |
| `mismatched_settings_hash` | A settings hash differing from the saved G2 request identity is rejected before acknowledgement. |
| `mismatched_worker_identity` | The same PID with a changed attested `WorkerBirthUS` is rejected before acknowledgement. |

Use saved tables and disposable files only; no process launch. Report pass, fail or untested for every case with the exact rejection point and absence of a successful acknowledgement in negative cases. Stop at the **first failed evaluation**; mark all remaining cases untested and do not repair and rerun within this budget. There is **no automatic retry**. A failed static or offline gate cancels the single proposed live startup attempt.

If separately approved and all prelaunch gates pass, allow **one** disposable MATLAB startup launch, **no retry**. Launch in a new session/PGID distinct from the supervisor and preexisting MATLAB groups. Monitor the entire precise-identity process tree, including reparented/out-of-group descendants, on a target interval at most 0.5 seconds; stop if monitoring is unavailable or a gap exceeds 1 second while the worker is active. Allow only the exact provisional `system_profiler` startup lineage already specified by SW-G5-06R-03, while retaining its identity and ability to stop it. Require verified exit before the final token; any other escape or identity ambiguity fails closed.

| Limit | Required action |
|---|---|
| Attempts | One MATLAB startup-only launch after the offline gate; no retry. **Zero `ui.Run`, detector, statistics and recorded-movie executions.** |
| Total wall time | **100 seconds including cleanup.** Final token strictly before the existing 65-second pre-run policy deadline; worker acknowledgement within 10 seconds after token. Reserve the remaining time for stop/verification. |
| Memory | Stop at or above **2 GiB sampled RSS** summed over the tracked process tree. Report sample interval, observed peak and any overshoot; this is a sampled threshold, not an exact physical peak. |
| Evidence | Stop when control-packet bytes approach **32 MiB**; no claim that this is an absolute quota. The proposed recording output must remain absent (zero bytes). |
| Free space | Stop if destination-volume free space falls below **8 GiB**. |
| Containment and cleanup | Before any signal, save process tables and precise identities. Stop the verified disposable group and separately tracked escaped identities only; allow up to **8 seconds graceful** and **8 seconds force/verification**, all inside the 100-second cap. Preserve the packet and uncertainty. Do not signal unrelated work or retry. |

Stop before launch on changed hashes/settings/support, a packet already present **before one-use setup**, unexpected files in the newly created packet, a present proposed output, unavailable MATLAB/monitor, insufficient space, unenforceable process isolation or a worker path that could call Run. During launch, stop on a failed policy/preflight/identity check, unmatched or lingering helper, missing ready/ack, duplicate token, resource limit, monitor gap or unexpected output/attempt marker. Record exact fault point, saved state, process-table evidence, stop targets, live tracked-process count, actual duration, sampled resources and any overshoot. A forced stop or ambiguous token is **incomplete**, even if an acknowledgement file exists; never relabel it successful. Acceptance requires the matching acknowledgement, no `go.json`, no attempt marker or proposed output, and verified exit of all tracked processes. Any failure consumes the one launch and is reported without retry.

**If deferred:** SW-G5-06R-06 remains accepted filesystem-only evidence. Live startup handshake, actual Run-token response, real-acquisition integration, measured run resources, SW-G5-07, G5 acceptance and release remain open. A later named recorded-movie attempt would need a separate source/output/budget decision; this card does not authorize it.
