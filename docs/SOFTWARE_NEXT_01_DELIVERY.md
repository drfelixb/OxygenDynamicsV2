# Save accepted software and establish development version

4 October 2026 · NEXT-01 · Owner: implementation assistant

Approved by the researcher for step 1 only. Benefit: accepted software is
recoverable on GitHub and has a clear development identity. Inputs: local
HEAD e8266d9d7f295814f1c8075f6a865cac98e9db18, complete pending export/planning
diff, origin https://github.com/drfelixb/OxygenDynamicsV2.git and historical
v3.0 at 329cdc2f1fd3afd04c54ce4518673165f999b1a0. Remote branch and tag
match the local identities; v3.0 is an ancestor of HEAD. No competing work
or contradictory remote version tag was found. Do not move that tag.

Scope: save the accepted automatic export helpers/integration, their existing
checks and guides; preserve planning and acceptance records; update changelog,
current task list, central version, manual and metadata assertions. Adopt
3.1.0-dev.1 with one actual timestamp. No calculation or contract changes.

Budget: 90 active minutes, at most two commits, one successful normal branch
push and 5 MiB new textual evidence. Zero MATLAB, test suites, package builds,
recording runs, calculation changes, main merge, release tag or publication.

Acceptance checks: inspect complete pending diff; check metadata consumers,
version/build agreement, JSON syntax, whitespace and explicit staged paths;
compare protected calculation/contract and original-result files against
initial hashes; verify remote branch equals final commit. These are static
checks, not numerical validation. Historical tests remain historical claims.

Stop when accepted work is saved on development-existing-analysis-v3 and
status is updated. Step 2 and every later step require separate approval.
Release, containment, licensing, platform and scientific blockers remain.

Started UTC: 2026-10-04T18:36:05.317539+00:00

## Static acceptance results before commit

- Central version, README, manual, development notes and smoke assertion agree
  on `3.1.0-dev.1`; build timestamp: `2026-10-04 20:36:05 +02:00`. GUI, health report,
  wrapper provenance, analysis manifest and package metadata already consume
  the shared function; those consumers need no edits. No old output is relabelled.
- Historical evidence hashes match: six calculation files, eight accepted
  export implementation/check files and seven saved input/evidence files.
- All 2224 other initially tracked files match their initial SHA-256 hashes.
  Only the ten explicitly intended metadata/status/doc files changed during
  this task; the accepted export implementation was saved without modification.
- JSON parses and Git whitespace checks pass. No numerical tests were run.
  Staging is restricted to the explicit source, existing check and document list.
  Original research payloads and local source maps are excluded.

## Source saved and completion handoff

- Software source commit: [`2f002ab507613b6c5322a43f72f95d7b09a54c70`](https://github.com/drfelixb/OxygenDynamicsV2/commit/2f002ab507613b6c5322a43f72f95d7b09a54c70).
- Development version: `3.1.0-dev.1`. Build: `2026-10-04 20:36:05 +02:00`.
- This second commit records delivery only; software/calculation files are
  unchanged from the source commit. Both commits are included in the single
  approved normal push to `development-existing-analysis-v3`. The final commit
  is the commit containing this record, identifiable from Git history.
- At this pre-push record snapshot, the normal push and exact `git ls-remote`
  comparison remain required before reporting success. Their actual result and
  final GitHub commit are supplied in the final researcher handoff. No force
  push or new tag is permitted; stop on remote divergence.
- Changed files: six root user/version documents, central metadata and its
  existing smoke assertion; accepted export helpers/integration/sheet wording;
  two existing MATLAB check/session files; reader guide, acceptance/task records,
  seven-step plan, first handoff, backlog, active plan and JSON status. The
  source commit lists all 24 explicit paths. No research payload was staged.
- Zero MATLAB starts, test-suite executions, package builds, recording runs,
  calculation changes, main merges, release tags or publications. Two commits
  maximum; one successful branch push maximum. Textual additions are below
  0.2 MiB, well below 5 MiB. Work elapsed is below the 90-minute limit.
- Calculation contracts, originals, earlier failures, consumed approvals and
  storage-budget exception are retained. C02 reference is conditional, FB2312
  recovery unresolved and all saved-footprint qualifications remain.
- Next chat: step 2 is proposed only. Read the instructions, active plan, status
  and working plan; obtain separate approval before any calculation checks.
  Package omissions, hosted support, live containment, licensing, independent
  use and scientific/release decisions remain open. Stop here.
