# Local package integration candidate

This folder is a local F07-03I integration candidate, not an approved release.
`OxygenReleaseSourcePolicy.json` defines the exact included source files;
`RELEASE_MANIFEST.txt` records this build. No recording or saved result is bundled.

From this folder, `setupOxygenDynamicsPath` adds this copy and its helpers and
external folders. The integration check resolves the named BOI entry points
without invoking analysis, statistics, or a GUI. It does not establish runtime
closure for every optional or legacy workflow.

README and USER_MANUAL retain repository context. Their `docs/` links point to
repository-only material that is deliberately not bundled; use the repository
for that context. Tests, development evidence, CHANGELOG, the two development
comparison PDFs, and the legacy OxygenDynamics_Sinks_Curation.mlapp are omitted.
The legacy curation app is outside the named BOI resolution scope. The manual's
broader legacy features have not been tested from this candidate.

Licensing and hosted CI remain open. Successful acquisition-worker acknowledgement,
verified containment, and real-acquisition resource measurements remain deferred
release blockers. Version/manual reconciliation and broader dependency/runtime
checks remain separate work. This packaging check closes none of those gates.
