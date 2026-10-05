# Independent launch and cleanup code review

5 October 2026 · NEXT-06A · assessment only

One **independent Codex code review, not a human systems audit**, by the separately
authorized reviewer, without implementation-chat history or proposed conclusions.
Scope: ownership, escaped/disappearing children, identity uncertainty, cleanup,
release tokens and resource measurement; current code/saved evidence only,
three active hours maximum. The implementation assistant records the review.

Application: `development-existing-analysis-v3`, commit
`1d4b6631935a2d95730f365fae70c900a8bff107`, version `3.1.0-dev.2`.
Launch helpers live outside that Git repository under `reference-validation`;
their reviewed hashes identify them separately.

**Conclusion: the current approach does not meet the prerequisite for a fresh
recording proposal.** It can document observed processes and refuse release,
but cannot prove cleanup of every process originating from the launch. The
recording gate remains blocked. The following findings and recommendation are
the separate reviewer's assessment.

## Findings

1. **Sampled ancestry does not establish complete ownership.**
   [Guard scanning](/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/software-g5-isolation-revision-20260928/isolation_guard.py:225)
   retains registered identities after reparenting, but a child can escape the
   group/session and reparent between samples before registration. The
   [cleanup result](/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/software-g5-isolation-revision-20260928/isolation_guard.py:579)
   covers registered identities and known uncertain candidates; two clean tables
   cannot exclude an unobserved descendant. R08 correctly latches uncertain
   ownership. Disappearance is diagnostic evidence, not verified ownership,
   complete cleanup or permission to signal an unknown PID.

2. **No independent watchdog enforces the whole-launch cleanup deadline.**
   [Launch](/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/software-g5-r07-code-20260928/supervise_r07_startup.py:264)
   occurs before the outer `try`, followed by disk/packet probes; exceptions can
   precede active cleanup. Guard-initialization fallback signals only the
   launcher. [Stop](/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/software-g5-isolation-revision-20260928/isolation_guard.py:525)
   writes evidence before signalling and resets relative phase deadlines.
   Synchronous filesystem operations and process queries can consume the reserve.
   The supervisor cannot independently guarantee its total cleanup time or stop
   an unobserved descendant.

3. **Resource measurement has a publication gap.** The
   [final capture](/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/software-g5-r07-code-20260928/supervise_r07_startup.py:215)
   sums RSS from the previous registry; the controller then registers new children
   from that snapshot and can publish without recomputing their RSS. Post-token
   monitoring records escaped PIDs without treating escape itself as a stop.
   Historical RSS is sampled tracked-process RSS, not a physical whole-launch
   maximum; unidentified/unobserved children and between-sample peaks are missing.

4. **One-shot consumption is useful, but the recording release is absent.**
   Exclusive claims/no-overwrite publication prevent retry after ambiguous
   writer errors. The
   [current worker](/Users/zcm361/Documents/Github/OxygenDynamicsV2/reference-validation/software-g5-r07-code-20260928/runG506R07StartupWorker.m:73)
   accepts only `acknowledge_preflight_only` and has no analysis entry. The
   historical Run worker uses an incompatible old token schema and a consumed
   approval. The publication deadline is checked before filesystem operations;
   a late token is classified incomplete afterward, which would not prevent a
   future Run reader from acting first. A recording contract needs explicit
   identity, duplicate rejection and worker-side expiry.

## Saved evidence and limits

The original attempt stopped before Run after an escape. The earlier startup
diagnostic stopped an observed `system_profiler` lineage without readiness.
R07 stopped in 17.1546 s with no ready receipt, claim, token, acknowledgement,
attempt marker or output. Its formal `containment_failure` remains despite zero
remaining verified PIDs and two clean observations. Its 263.75 MiB tracked RSS
excludes the unidentified child.

R07D's 14/14 offline passes belong to the earlier guard hash. R08's 10/10 passes
cover injected diagnostic adapters; normal construction/native lookup and the
complete stop loop were not exercised. Neither establishes current live startup
or cleanup. The current one-use caller rejects reuse through existing-packet and
changed-hash gates. The initial reparenting failure, separately approved passing
recheck, all historical failures and consumed approvals remain unchanged.

Reviewed executable files and **all 14 full SHA-256 hashes**, plus five saved
evidence anchors, are in the
[reviewed-file manifest](planning/SOFTWARE_NEXT_06_REVIEWED_HASHES.json).
It identifies both supervisors/workers, guard/identity/helper policy,
controller/writer/acknowledgement contract and relevant harnesses. Reviewer
initial/final hashes and the implementation assistant's reconciliation match.

## Recommendation and minimum finite evidence

Retain process sampling for diagnosis. Prefer an **exclusively owned disposable
execution boundary**, such as a disposable VM in an explicitly agreed MATLAB/OS
environment, with a watchdog outside it able to stop that exact boundary.
Expose source data read-only and preserve a separate output disk. Keep the
scientific workflow unchanged. Boundary availability, licensing and any
environment change are unresolved decisions; this review does not establish
that such a boundary exists or has been qualified.

Before a recording proposal, require **one fixed, separately authorized
qualification packet**, with no repair/retry ladder:

- Freeze application/supervisor/worker/dependency/harness hashes and a fresh
  one-use Run contract with identity validation, duplicate rejection and
  worker-side expiry.
- Evaluate eight named non-recording lifecycle cases once each: normal exit;
  escape/reparenting; unidentified child disappearing; unidentified child
  persisting; guard initialization failure; supervisor/monitor stall; large
  child newly discovered in the final snapshot; publication crossing its
  deadline. Demonstrate whole-boundary stop, retained evidence, resource
  classification and rejection of a second release.
- On exactly those hashes, perform one startup-only MATLAB acknowledgement and
  normal-exit check within the same external boundary, without Run. Stop the
  qualification at the first failure and retain the blocker.

Only a successful independently reviewable packet could support a separate
recording proposal with exact source/settings/output/resource limits. This
recommendation authorizes no implementation or execution. If an owned boundary
cannot be supplied, defer the recording gate as an explicit release blocker.

## Stopping record

Completed within three active hours. No repairs, tests, research-process/MATLAB
launch, recording analysis, commit/push or publication. Only assessment/checksum
and factual plan/status/acceptance records changed. All 140 preservation pins,
including the candidate ZIP, match; original results/scientific qualifications
remain unchanged. Step 5 acceptance retains complete Linux 133/133 versus
macOS 132/133 plus three targeted checks, without a final complete macOS gate.
Assessment complete; implementation/recording remain unapproved and blocked.
