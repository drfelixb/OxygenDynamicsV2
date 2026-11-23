function Info = getOxygenPipelineVersion()
%GETOXYGENPIPELINEVERSION Return centralized release and build metadata.

Info = struct();
Info.Version = '3.1.0-rc.1+multichannel.4';
Info.BuildTimestamp = '2026-11-19 09:42:42 +0100';
Info.DisplayName = ['Oxygen Dynamics Pipeline v',Info.Version];

end
