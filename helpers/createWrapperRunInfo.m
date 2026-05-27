function WrapperRunInfo = createWrapperRunInfo(RunConfig,analysisMode,Paths)
%CREATEWRAPPERRUNINFO Initialize shared wrapper run provenance.

RecordingTemplate = struct( ...
    'Path','','Folder','','Mouse',[],'Condition',[],'DrugID',[], ...
    'RawTiff','','DenoisedTiff','', ...
    'ValidationIsValid',false,'ValidationWarnings',{{}},'ValidationErrors',{{}}, ...
    'ImagingStatus','Not run','BehaviourStatus','Not run');

WrapperRunInfo = struct();
WrapperRunInfo.StartTime = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
WrapperRunInfo.EndTime = '';
WrapperRunInfo.Config = RunConfig;
WrapperRunInfo.AnalysisMode = analysisMode;
WrapperRunInfo.NumRecordings = numel(Paths);
WrapperRunInfo.Recordings = repmat(RecordingTemplate,numel(Paths),1);

end
