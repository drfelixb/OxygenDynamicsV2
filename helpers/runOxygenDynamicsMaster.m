function MasterOutput = runOxygenDynamicsMaster(recordingFolder,Context)
%RUNOXYGENDYNAMICSMASTER Run oxygen sink/surge analysis for one recording.
%
% This function is the public function entry point for the oxygen master
% analysis. The legacy master body is still held in OxygenDynamics_Master.m
% during the staged migration, but it now runs inside an explicit isolated
% context rather than sharing the wrapper workspace.

if nargin < 1 || isempty(recordingFolder)
    recordingFolder = pwd;
end
if nargin < 2 || isempty(Context)
    Context = struct();
end

MasterOutput = runLegacyAnalysisScript(recordingFolder,'OxygenDynamics_Master.m',Context);

end
