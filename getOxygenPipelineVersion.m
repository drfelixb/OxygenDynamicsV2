function Info = getOxygenPipelineVersion()
%GETOXYGENPIPELINEVERSION Return centralized release and build metadata.

Info = struct();
Info.Version = '3.1.0-dev.3';
Info.BuildTimestamp = '2026-10-13 20:02:39 +02:00';
Info.DisplayName = ['Oxygen Dynamics Pipeline v',Info.Version];

end
