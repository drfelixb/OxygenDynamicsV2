function Info = getOxygenPipelineVersion()
%GETOXYGENPIPELINEVERSION Return centralized release and build metadata.

Info = struct();
Info.Version = '3.1.0-dev.10';
Info.BuildTimestamp = '2026-10-30 11:14:26 +01:00';
Info.DisplayName = ['Oxygen Dynamics Pipeline v',Info.Version];

end
