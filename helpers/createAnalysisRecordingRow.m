function R = createAnalysisRecordingRow(M,SinkData,SurgeData)
% Independent recording registry, including successfully analyzed zero-event inputs.
info=loadRequiredMatVar(SinkData.MatFile,'AnalysisInfo');
N=info.NFrames;A=info.RecordingAreaUm2;
R=table(string(M.RecordingID),{M.DatafileID},{M.Mouse},{M.Condition},{M.DrugID}, ...
    {M.Genotype},{M.Promoter},logical(M.PuffStim),N,M.SampleF,N/M.SampleF,A, ...
    'VariableNames',{'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter', ...
    'PuffStim','NFrames','SampleF','RecordingDuration_sec','RecordingArea_um2'});
R.PixelSize=M.PixelSize;
R.AnalysisStatus="loaded";
R.PipelineVersion=repmat(string(info.PipelineContract.Schema),height(R),1);
R.DetectorVersion=repmat(string(info.PipelineContract.Detector),height(R),1);
R.RawSHA256=repmat(string(info.RawSHA256),height(R),1);
R.DenoisedSHA256=repmat(string(info.DenoisedSHA256),height(R),1);
end
