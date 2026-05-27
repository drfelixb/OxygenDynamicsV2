function MasterOutput = runiOSDynamicsMaster(recordingFolder,Context)
%RUNIOSDYNAMICSMASTER Run iOS sink/surge analysis for one recording.
%
% This function is the public function entry point for the iOS master
% analysis. The legacy master body is still held in iOSDynamics_Master.m
% during the staged migration, but it now runs inside an explicit isolated
% context rather than sharing the wrapper workspace.

if nargin < 1 || isempty(recordingFolder)
    recordingFolder = pwd;
end
if nargin < 2 || isempty(Context)
    Context = struct();
end

MasterOutput = runLegacyAnalysisScript(recordingFolder,'iOSDynamics_Master.m',Context);

end
