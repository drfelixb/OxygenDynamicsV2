function Info = getOxygenPipelineVersion()
%GETOXYGENPIPELINEVERSION Return centralized release and build metadata.

Info = struct();
Info.Version = '3.1.0-dev.2';
Info.BuildTimestamp = '2026-10-04 21:37:28 +02:00';
Info.DisplayName = ['Oxygen Dynamics Pipeline v',Info.Version];

end
