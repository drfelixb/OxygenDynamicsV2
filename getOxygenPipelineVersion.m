function Info = getOxygenPipelineVersion()
%GETOXYGENPIPELINEVERSION Return centralized release and build metadata.

Info = struct();
Info.Version = '1.01';
Info.BuildTimestamp = '2026-06-15 15:00:55 +02:00';
Info.DisplayName = ['Oxygen Dynamics Pipeline v',Info.Version];

end
