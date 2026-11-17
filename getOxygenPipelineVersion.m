function Info = getOxygenPipelineVersion()
%GETOXYGENPIPELINEVERSION Return centralized release and build metadata.

Info = struct();
Info.Version = '3.1.0-rc.1';
Info.BuildTimestamp = '2026-11-17 14:33:02 +01:00';
Info.DisplayName = ['Oxygen Dynamics Pipeline v',Info.Version];

end
