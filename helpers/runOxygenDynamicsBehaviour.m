function BehaviourOutput = runOxygenDynamicsBehaviour(recordingFolder,Context)
%RUNOXYGENDYNAMICSBEHAVIOUR Run behaviour analysis for one recording.
%
% This function is the public function entry point for behaviour analysis.
% OxygenDynamics_Behaviour.m remains a legacy script during the staged
% migration and is executed in an isolated function workspace.

if nargin < 1 || isempty(recordingFolder)
    recordingFolder = pwd;
end
if nargin < 2 || isempty(Context)
    Context = struct();
end

BehaviourOutput = runLegacyAnalysisScript(recordingFolder,'OxygenDynamics_Behaviour.m',Context);

end
