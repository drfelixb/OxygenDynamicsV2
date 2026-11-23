function Info = getOxygenPipelineVersion()
%GETOXYGENPIPELINEVERSION Return centralized release and build metadata.

Info = struct();
Info.Version = '3.1.0-dev.14';
Info.BuildTimestamp = '2026-11-05 15:59:47 +01:00';
Info.DisplayName = ['Oxygen Dynamics Pipeline v',Info.Version];

end
