function validateOxygenPipelineContract(Info,M)
C=oxygenPipelineContract();
if ~isfield(Info,'PipelineContract') || ~isequaln(Info.PipelineContract,C) || ...
        ~isfield(Info,'AnalysisSchemaVersion') || ~strcmp(Info.AnalysisSchemaVersion,C.Schema)
    error('OxygenDynamics:ReanalysisRequired','Outputs do not match the current detection/measurement/statistics version. Rerun the master.');
end
validateOxygenAnalysisCalibration(Info,M);
expected=createOxygenMasterParams(M.PixelSize,M.SampleF);
if ~isequaln(orderfields(Info.AnalysisParams),orderfields(expected))
    error('OxygenDynamics:AnalysisSettingsMismatch','Saved master settings differ from the current analysis profile. Rerun the master before pooling.');
end
required={'NFrames','RecordingAreaUm2','SinkEligibleTissuePixels','SurgeEligibleTissuePixels'};
assert(all(isfield(Info,required)) && Info.NFrames>0, ...
    'OxygenDynamics:ReanalysisRequired','Recording exposure or tissue support is missing. Rerun the master.');
end
