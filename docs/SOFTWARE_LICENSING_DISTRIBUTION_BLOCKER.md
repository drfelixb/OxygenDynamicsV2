# Development download: contract-path decision

5 October 2026 · Approved documentation/distribution task stopped before build

The local and GitHub branch tips both match
`e119df6338faa0590f933f889a8dddf81256de30`. The original MIT notice and both
previous ZIP hashes match the handoff. The proposed output destination was
absent and has now been created only for preservation receipts and this repair
proposal. No package, MATLAB session, commit or push has occurred.

## Conflict found in the static package check

The required file `docs/planning/boi-reviewed-optical-contract-0.1.0-draft.json`
contains twelve absolute local research-path values: seven saved-example
`RecordingID` strings and five historical `JudgmentPath` strings.
`helpers/getBOIReviewedOpticalDefinition.m` requires that contract's exact SHA-256.
The reviewed optical preview loads it, and the event exporter includes its
contents in `ReviewedOpticalContract.json`.

The handoff requires both unchanged scientific contracts/MATLAB files and no
machine-specific input paths or private evidence in the new package. Those
requirements conflict for this file. Removing it would leave its required
definition loader without its contract; changing its paths would invalidate the
loader's integrity check. No such change has been adopted.

The handoff says: “If a MATLAB or scientific-contract change becomes necessary,
report that concrete scope change before adoption”. It also directs a stop for
an application defect requiring wider scope. This is a specific package/privacy
constraint, not evidence of a calculation failure. Existing calculations and
scientific qualifications remain accepted within their earlier demonstrated scope.

## Smallest proposed amendment

Permit twelve provenance-string replacements in that contract: identify the
recording as `C02-saved-example` and retain each judgment basename under the
label `historical-judgment/`. Keep all frame selections, samples, numerical
values, formulas, scientific qualifications and judgment hashes unchanged.
Update only the matching digest literal in its MATLAB loader. This revises the
preservation check to 541 unchanged MATLAB files plus one inspected digest-pin
repair; original results and earlier candidates remain untouched.

A proposed patch is saved outside the checkout at
`reference-validation/software-licensing-distribution-20261005/proposed-contract-path-repair.patch`.
The accompanying JSON lists every old/new string. Static preparation confirmed
exactly twelve string fields change; the helper proposal changes only its one
digest literal. The proposed patch is **not applied**.

Verification proposed before distribution: compare all contract fields except
those twelve strings; inspect the exact one-literal helper diff; then perform one
non-numerical definition-load/integrity check from the extracted candidate in
the same single MATLAB session as packaging. No numerical matrix or recording
is proposed. This expands that session's scope beyond packaging only.

Allow at most twenty additional active minutes within the existing two-hour
total, with the same two-build, one-session, three-commit, one-successful-push and
50-MiB limits. Keep version/build unchanged and identify the new source by its
actual commit and hashes. An alternative is to leave the protected sources
unchanged and defer the new candidate. No blanket licence or publication decision
is involved.

## Stopped state

All 542 MATLAB files and scientific JSON contracts remain unchanged. No new ZIP
or GitHub commit is available from this task. The existing uncommitted licence
documents are preserved. This record and current plan/status updates remain
uncommitted. Continue only after the researcher decides the bounded amendment;
no build, push, numerical testing or automatic diagnostic work follows this stop.

## Researcher amendment approval and applied repair

On 5 October 2026, the researcher approved the amendment within the existing
budget, explicitly requiring unique labels for distinct judgments and retention
of their hashes. The earlier proposed basename-only labels were refined to
`C02-baseline`, `C02-event4-reference`, `C02-event3-reference` and
`C02-short-reference` prefixes under `historical-judgment/`; repeated references
to the same judgment retain one label. The recording label is `C02-saved-example`.
Exactly twelve strings changed; all other contract fields remain equal.
The loader changes only its contract checksum literal. This resolves the
original package-path blocker. The earlier stopped/proposal text is historical;
source/package verification and the approved same-session load check follow.

## Verification and closure

The first candidate build and extracted-copy definition load passed in the same
single ordinary MATLAB session; all required function resolutions were inside
the extraction. Static comparison confirms every field outside the twelve
approved labels is equal and all judgment hashes remain. Source/package hashes
and links passed. The blocker is resolved within the approved amendment; see
[the delivery](SOFTWARE_LICENSING_DISTRIBUTION_DELIVERY.md). Earlier stopped and
proposal records remain historical and do not authorise a retry or new task.
