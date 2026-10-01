# SW-G5-06 decision card — one named real-acquisition integration

27 September 2026; process-isolation guard added and **SW-G5-06 alone approved 28 September 2026**. At the time of approval, no SW-G5-06 recorded-movie run had started. SW-G5-05 was accepted for its eight saved/small-fixture cases within the zero-run budget. This card fixes the source, settings, destination and stop limits for the single approved attempt. SW-G5-07, G5 acceptance and release remain unapproved.

## Exact source and identity

Use the existing local **FX01 / ID400 awake** BOI recording folder:

`/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/boi-id400-awake-run-20260921/run-01/Recording`

| Required file | Bytes | SHA-256 verified 27 September 2026 |
|---|---:|---|
| `preserved_original.tif` | 157,401,404 | `fc980cfc800ddc830a6dd122f64b734458a16b55de738bad2c7896b7064c2aaf` |
| `BOIInputMetadata.json` | 3,235 | `22e0c14d32fad5cf6055abde041a5e5d09a8b1847cdebf9ab04042d97bb7348c` |
| `BOITissueSupport.json` | 2,234,295 | `34268277ccbe0ba7d28764986451bec024616b338b16116719a078d45a856571` |

This is the **same source folder and source-hash set** saved in G2 [`gui-run/RunRequest.mat`](../../reference-validation/software-g2-workflow-20260923/gui-run/RunRequest.mat) (request SHA-256 `fd67cf9f30e85bf39bf4c744bbe28e649b84491a1a26f800c34909411b9518d3`). G2's [`BOIRun.mat`](../../reference-validation/software-g2-workflow-20260923/gui-run/BOIRun.mat) is the comparison reference. The source is local to this workspace and available now. The external drive is mounted as `/Volumes/ext_zcm361`, not the older `/Volumes/extZCM361_2`; this proposed run does **not** depend on that drive or silently substitute a drive recording. The local TIFF is a preserved real-acquisition movie, not a synthetic fixture.

## Effective settings and support

The read-only `prepareBOIRecordingRequest` preflight was run with the saved G2 options and only the output path changed. It returned `Sources`, `AnalysisParams`, `Context` and `InputReview` exactly equal (`isequaln`) to the saved G2 request. Its status is `descriptive_input_requires_scientific_review`, not a biological eligibility decision. No master, detector, statistics or recorded-movie run was started.

| Setting | Effective value |
|---|---|
| Sampling rate | **1 Hz**, externally triggered for this supplied recording; embedded source clocks marked unreliable |
| Pixel size | **4.75 µm/pixel** |
| Tissue/detection support | **`craniotomy-roi-1`**, source-bound `BOITissueSupport.json`, decision `R1-ID400-AWAKE-RUN-112`, `reviewed_for_static_support`, 512×512 mask with 192,348 declared pixels |
| Labels | Mouse `ID400`; condition `Awake_immobile`; drug `awake`; genotype `WT`; promoter `GFAP.PHP` |
| Analysis parameters | Exact saved G2 `AnalysisParams` struct, unchanged by current preflight; all **33 values** are in the [readable parameter snapshot](planning/SOFTWARE_G5_06_EFFECTIVE_PARAMETERS.txt). No tuning or revised scientific rule. |

The accepted outline remains **working static support** with uncertain/clipped edges. Unknown camera exposure, pre-TIFF intensity history and unresolved frame-level validity remain visible in the preflight. No cross-recording mask transfer or physiological validity claim follows from a successful run.

## Destination and current resource check

Proposed **new output directory** (does not exist):

`/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/software-g5-real-id400-run-20260927`

The source and destination parent are on the same local APFS data volume. At **2026-09-27 19:08:09 UTC**, the destination parent had **164,249,600,000 free bytes (152.97 GiB)**. The host is an Apple M4 Max MacBook Pro with **36 GB RAM**. G2's two prior outputs totaled 3,120,902,990 bytes (about 1.45 GiB per run), and its GUI demonstration took about 126 seconds; those are historical observations, not guarantees for this run.

Before any approved Run, recheck all three source hashes, new-path nonexistence, exact request equivalence, host/process monitor availability and free space **at least 8 GiB**. Launch the disposable MATLAB process in its **own new session and process group**. Before enabling `ui.Run()`, verify that the disposable launcher's PID is the process-group ID, that this group differs from the supervisor's and every pre-existing MATLAB group's, and that the actual MATLAB worker PID and its current descendants belong to it. The supervisor must track descendants and fail closed if a child escapes that group. Stop **before Run** if any check fails, the preflight becomes held, settings/support differ, or process-group isolation and monitoring cannot enforce the limits. Do not repurpose an existing output directory.

## Proposed measurement and firm stop budget

If separately approved, launch **one** GUI-driven execution in the isolated disposable MATLAB process. Record the monotonic wall-clock time immediately before `ui.Run()` and at return/failure, plus timestamped stage callbacks (`staging`, `analysis`, `statistics`, `complete`/`failed`). Independently, a supervisor samples the MATLAB process and descendants every **one second** using `ps` PID/PPID/PGID/RSS data, recording the summed resident set in bytes and its largest observed sample as **peak sampled process-tree RSS**. Shared pages can make the sum conservative and sub-second spikes may be missed; report that measurement method and its limit rather than claiming exact physical peak. Also record `/usr/bin/time -l` maximum resident set size for the MATLAB launch where available. Sample output-directory byte size and filesystem free bytes at least every second.

| Budget | Firm action |
|---|---|
| Attempts | **One** new real-acquisition run; **no retry** under this approval. No other recorded movie or cohort execution. |
| Wall clock | **600 seconds (10 minutes)** from immediately before Run; supervisor terminates the process group at the limit. |
| Output | **3 GiB (3,221,225,472 bytes)** maximum target; terminate when sampled output reaches the limit, and report any sample-interval overshoot rather than claiming an absolute filesystem quota. |
| Memory | **12 GiB (12,884,901,888 bytes)** sampled process-tree RSS ceiling; terminate at or above it. |
| Free space | Stop if destination filesystem free space falls below **8 GiB**. |
| Stop handling | Signal **only the verified disposable process group**; request termination, allow at most 15 seconds, then force-stop that group if needed. Preserve the output folder and its `RunStatus.json` as found. A forced stop is an **incomplete outcome even if the last saved status still says `running`**; record the stop in a separate supervisor report, never relabel the run complete, overwrite it, or retry. Record each threshold, observed peak/size, any one-second sampling overshoot and the reason for stopping. |

After a successful run within bounds, verify `RunStatus.json` complete, reopen the newly saved `BOIRun.mat`, inspect both signs and explicit missingness, compare software outputs against the G2 saved reference under the established exact numerical comparison rules, and report runtime, sampled peak RSS, final output size and limitations. A mismatch is a software finding to review, **not** a reason to tune biological results or rerun. If the source/support identity changes, a run fails, or a resource limit trips, stop and report that outcome; do not broaden the attempt budget.

Expected work if approved: up to 15 minutes to recheck guards and arm the monitor, at most 10 minutes for the one run, and up to 30 minutes for saved-result comparison and reporting. If the comparison cannot be completed from the named saved artifacts within that review bound, report it as untested rather than adding another run or another recording.

**If deferred:** the accepted G3/G4 usability and bounded G5 failure/saved-contract evidence remain as recorded. Fresh real-acquisition integration, measured resources and release readiness remain unverified. No output folder needs to be created now.
