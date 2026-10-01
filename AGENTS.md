# OxygenDynamics software development guardrails

## Mission and authority

Develop the next usable, maintainable MATLAB version of the BOI analysis
software. The researcher's 21 September 2026 scope correction supersedes older
documents that direct cohort reanalysis, cohort completion or experimental
comparison planning. Read `docs/SOFTWARE_DEVELOPMENT_PLAN.md` and the current
`docs/planning/software-development-status.json` at the start of resumed work.
The researcher workflow/traceability contract and scientific measurement
boundaries still apply. Preserve older records; do not execute their stale
"next steps" as current authorization.

## Scope boundaries

- Dataset use is for a named software example, regression check or acceptance
  test with a finite fixture set. Do not turn testing into cohort reanalysis.
- Do not begin KX whisker work, stimulation-window reconstruction or protocol
  inference. These are deferred. The researcher normally uses a fixed protocol;
  future protocol support needs a separate agreed requirement.
- Keep the accepted detector, recording-specific correction and measurement
  rules as the working behavior. No tuning toward expected biological results,
  universal substrate-decline model or indefinite diagnostic campaign.
- Preserve BOI-only scope, biological variability, physiological relevance,
  feasibility, usability and traceability. Retain separate sink/surge outputs,
  missingness, uncertainty, source-specific tissue support and automatic versus
  reviewed results. External 1 Hz authority applies to these supplied recordings;
  do not silently assume it for every future acquisition.
- Preserve existing uncommitted work, raw data, earlier outputs and unresolved
  scientific questions. Do not reset, clean, overwrite original outputs or
  perform a broad rewrite/reorganization as housekeeping.

## Approval and continuation

- A request for a plan authorizes planning, not implementation of the plan.
- Before implementation, obtain approval for the milestone and its bounded
  work items. Within it, perform routine engineering decisions, reviews, fixes
  and necessary tests without repeatedly asking for permission.
- "Continue" or "go on" advances only the currently approved work item or
  milestone. It does not approve a new scientific method, dataset campaign,
  product scope or subsequent milestone unless that continuation is explicitly
  tied to the named milestone presented to the researcher.
- Before crossing a boundary, describe the concrete proposal, reason,
  consequences, affected outputs, effort/test budget and alternative of
  deferring it; ask and wait for explicit approval. Do authorized independent
  work meanwhile. Silence and elapsed time are not approval.
- Scientific meaning/defaults, output-changing algorithm changes, new
  experimental analyses, new dataset campaigns, platform changes and release
  publication require approval. A scientific-output bug may be investigated
  and a candidate fix prepared within an approved task, but adoption requires
  review of its numerical/scientific impact; never hide it inside a refactor.
- At milestone completion, report demonstrated behavior, tests, limitations and
  the proposed next milestone. Do not invent another diagnostic phase.

## Working discipline

Every implementation item needs an ID, user benefit, bounded scope, owner,
acceptance checks and stopping condition. Use one active delivery milestone;
parallel tasks must be independent and explicitly assigned if delegation is
authorized. A hypothetical team plan is not authorization to spawn agents.

Prefer incremental changes to the existing MATLAB pipeline, shared GUI/batch
services, explicit inputs/outputs and versioned data contracts. Use existing
test and provenance mechanisms before introducing another framework. Separate
software correctness from biological ground truth and measured performance
from historical test claims. Never make unresolved scientific questions silently
mandatory for unrelated software improvements.

Keep the plan, small current-status file and short work-item records current.
Use detailed evidence only when it supports a specific acceptance check.
MATLAB recipes archived under `docs/reference-results/` must use `.m.txt` so
documentation does not change the recursive scientific-code inventory.

End user-facing replies with a separate `What’s next: …` line.
