function Info = getOxygenPipelineVersion()
%GETOXYGENPIPELINEVERSION Return centralized release and build metadata.

Info = struct();
Info.Version = '3.1.0-dev.1';
Info.BuildTimestamp = '2026-10-04 20:36:05 +02:00';
Info.DisplayName = ['Oxygen Dynamics Pipeline v',Info.Version];

end
