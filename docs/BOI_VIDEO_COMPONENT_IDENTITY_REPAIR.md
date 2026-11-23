# Narrow correction to seed-connected episode identity

11 November 2026. **Approved, verified and delivered.** Root, no delegation.
Amendment to [the approved local/regional/reference revision](BOI_VIDEO_LOCAL_REGIONAL_BASELINE_PLAN.md),
not a new recording campaign or a parameter search.

## Checkpoint and reason

All 32 fixed constructed scenarios passed on the third execution: 96 scene
executions and both permitted pre-freeze repair cycles are consumed. The first
frozen development attempt, FB2311, stopped after 1,244 source records when
source J001245 proposed an onset after its own source anchor. That violates
the declared seed-connected identity contract. Zero recording passes completed;
the partial spool, source IDs, exact failure and frozen code remain preserved
in the [checkpoint](../../reference-validation/boi-local-regional-baseline-20261111/identity-contract-checkpoint.json).
The other eleven recordings were not opened by the detector.

The component matcher allows a seed up to three samples before the first
sustained deficit. Its onset is the preceding sample, which can still follow
that seed. The final recording invariant correctly stops this contradiction.
The failed candidate's full profile was not saved; its source identity is
recovered from source metadata without rerunning a fit.

## Concrete correction and bounded verification

The [two-line candidate patch, not applied](../../reference-validation/boi-local-regional-baseline-20261111/identity-repair-proposal/candidate-not-applied.diff)
rejects a component whose computed onset follows its own seed. It does not
clamp timing to the seed, recenter the anchor or substitute an unrelated dip.
An unsupported target remains explicitly unresolved. No diagnostic settings,
noise estimator, regional comparison, reference audit or scientific rule changes.

Propose **one additional repair cycle**, increasing the shared ceiling from two
to three, and **35 additional constructed executions**, increasing the ceiling
from 96 to 131. Execute the unchanged 32 scenes once, requiring their saved
outputs to remain unchanged, plus three fixed cases: seed just before the
derived onset, at onset, and within the low phase. The first must be withheld
without forced timing; the latter two remain eligible. Freeze those new cases
and expectations before execution. A failure stops without another repair.

After checks, pin the exact corrected code as freeze revision two, preserve
freeze one, retry FB2311 once, then complete the same twelve recordings and
the originally approved independent verification and six-card delivery.
The failed attempt remains counted. Twelve successes would take thirteen
total recording attempts, within the existing eighteen-attempt ceiling.

Retain the original **eight active hours, four batches, one configuration's
numerical settings, 2 GiB RSS, 512 MiB evidence**, candidate/channel/hypothesis/
reference-window limits, two-million-link ceiling and six report attempts.
No further method revision, configuration comparison or original source-image
decoding is included. The existing five reserved recordings remain unopened.

The burden formula, normalization, strict complete contributions, scientific
references, original recordings, automatic/reviewed results and export formats
remain unchanged. No partial burden or scientific result is calculated.

The alternative is to preserve the checkpoint and defer further execution.
The approved plan requires stopping at a repair boundary, and
[AGENTS.md](../AGENTS.md) states: **“Before crossing a boundary, describe the
concrete proposal, reason, consequences, affected outputs, effort/test budget
and alternative of deferring it; ask and wait for explicit approval.”**
Approval of this exact amendment is required before applying the patch or
running any further detector checks.

## Approval record

The researcher approves the narrow identity correction on 11 November 2026.
The original proposal, patch hash and approval are retained in
`reference-validation/boi-local-regional-baseline-20261111/repairs/repair-03`.
The original effort clock and failed attempt remain counted.

## Verification and completion

All 35 approved checks pass: 32 original scenes have exact saved-output parity,
and three new seed-position cases pass. Both freezes and the first failed
FB2311 attempt remain preserved. The same twelve full recording passes complete
in thirteen attempts. The guard establishes onset/seed consistency, not
biological episode identity; remaining failures are recorded in the
[revision results](BOI_VIDEO_LOCAL_REGIONAL_BASELINE_RESULTS.md). No additional
repair or method tuning was performed.
