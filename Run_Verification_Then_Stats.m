%% Run non-destructive verification first, then statistics when not blocked.

VerificationReport = runOxygenPipelineVerificationReport();

assertNoBlockedVerificationRows(VerificationReport,'stats');

StatsResult = runOxygenDynamicsStats();
