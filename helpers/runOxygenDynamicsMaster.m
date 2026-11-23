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

mode="legacy";
if isfield(Context,'DetectorMode'), mode=string(Context.DetectorMode); end
assert(ismember(mode,["legacy","eventFirst","compare"]),'eventFirst:Mode','Unknown DetectorMode.');
if mode=="legacy"
    MasterOutput = runLegacyAnalysisScript(recordingFolder,'OxygenDynamics_Master.m',Context);
    return
end
C=struct(); if isfield(Context,'EventFirstConfig'), C=Context.EventFirstConfig; end
R=loadOxygenEventFirstRecording(recordingFolder,Context);
NewResult=runOxygenEventFirst(R,C);
folder=saveOxygenEventFirst(NewResult,fullfile(recordingFolder,'OxygenDetectors_Output'));
MasterOutput=struct('EventFirstOutputFolder',folder,'EventFirstResult',NewResult);
if mode=="compare"
    % Legacy retains its established output namespace and calculations.
    Context.CaptureNativeComparison=true;
    LegacyOutput=runLegacyAnalysisScript(recordingFolder,'OxygenDynamics_Master.m',Context);
    L=createLegacyOxygenComparisonEnvelope(R,LegacyOutput);
    Comparison=compareOxygenDetectors(R,L,NewResult,struct('MinIoU',0.1));
    save(fullfile(folder,'DetectorComparison.mat'),'Comparison','L','-v7.3');
    writetable(Comparison.Matches,fullfile(folder,'DetectorCorrespondences.csv'));
    MasterOutput=mergeStructs(LegacyOutput,MasterOutput);
    MasterOutput.Comparison=Comparison;
    LegacyManifest=struct('Detector',"legacy",'PinnedReference',"8cf3f036b41e16b2c472bcee7e5cfaeab41433eb", ...
        'Context',Context,'Output',LegacyOutput,'Comparability',"Independent legacy support and units; no matched biological accuracy claim");
    save(fullfile(folder,'LegacyComparisonManifest.mat'),'LegacyManifest','-v7.3');
end

end
