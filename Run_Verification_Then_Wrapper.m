%% Run non-destructive verification first, then oxygen wrapper when not blocked.

VerificationReport = runOxygenPipelineVerificationReport();

assertNoBlockedVerificationRows(VerificationReport,'the wrapper');

OxygenDynamics_Wrapper;
