function Run=runBOIRecordingWorkflow(Request,ProgressFcn)
%RUNBOIRECORDINGWORKFLOW Shared single-recording GUI/batch orchestration.
% Only a prepared, unchanged request is accepted; use a new output directory.
% Optional ProgressFcn receives each saved RunStatus and its path.
setupOxygenDynamicsPath;
if nargin<2,ProgressFcn=[];end
assert(isempty(ProgressFcn)||isa(ProgressFcn,'function_handle'), ...
    'OxygenDynamics:InvalidRunRequest','ProgressFcn must be a function handle.');
assert(isstruct(Request)&&isscalar(Request)&&all(isfield(Request,{'Schema','Options','Sources','Context','AnalysisParams','InputReview','SettingOrigins'}))&& ...
    strcmp(Request.Schema,'boi-recording-request-1'),'OxygenDynamics:InvalidRunRequest','Prepare the request first.');
Current=prepareBOIRecordingRequest(Request.Options);
% Setting origins are presentation metadata; all effective inputs are rechecked.
assert(isequaln(Current.Options,Request.Options)&&isequaln(Current.Sources,Request.Sources)&& ...
    isequaln(Current.Context,Request.Context)&&isequaln(Current.AnalysisParams,Request.AnalysisParams)&& ...
    isequaln(Current.InputReview,Request.InputReview), ...
    'OxygenDynamics:RunRequestChanged','Inputs or settings changed after preflight. Prepare and confirm a new request.');
o=Request.Options;out=o.OutputFolder;
[created,message,messageID]=mkdir(out);
assert(created&&isempty(messageID),'OxygenDynamics:RunOutputExists', ...
    'Cannot claim a new run directory (it may already exist): %s. %s',out,message);
started=tic;
Status=struct('Schema','boi-run-status-1','Status','running','Stage','staging', ...
    'StartedUTC',char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ss'Z'")));
statusPath=fullfile(out,'RunStatus.json');writeBOIRunJSON(statusPath,Status);reportProgress();
try
    save(fullfile(out,'RunRequest.mat'),'Request');
    writetable(createOxygenRegressionCodeManifest(fileparts(mfilename('fullpath'))),fullfile(out,'CodeManifest.csv'));
    rec=fullfile(out,'Recording');mkdir(rec);
    for k=1:numel(Request.Sources)
        src=Request.Sources(k);copyfile(fullfile(o.RecordingFolder,src.Name),fullfile(rec,src.Name));
        assert(strcmp(oxygenFileSHA256(fullfile(rec,src.Name)),src.SHA256), ...
            'OxygenDynamics:RunSourceChanged','Source changed during staging: %s.',src.Name);
    end
    Status.Stage='analysis';writeBOIRunJSON(statusPath,Status);reportProgress();
    Master=runOxygenDynamicsMaster(rec,Request.Context);
    assert(isequaln(Master.AnalysisInfo.AnalysisParams,Request.AnalysisParams)&& ...
        strcmp(getBOISupportProfile(Master.AnalysisInfo),o.SupportProfile), ...
        'OxygenDynamics:RunSettingsMismatch','Master effective settings differ from the confirmed request.');
    Status.Stage='statistics';writeBOIRunJSON(statusPath,Status);reportProgress();
    Paths={rec};PostureFile=NaN;PupilFile=NaN;PuffsFile=NaN;WhiskingFile=NaN;
    Mouse={o.Mouse};Genotype={o.Genotype};Condition={o.Condition};DrugID={o.DrugID};Promoter={o.Promoter};
    SampleF=o.SampleHz;Pixelsize=o.PixelSizeUm;Puff_2use=NaN;
    RecordingID=string(Master.AnalysisInfo.RecordingID);
    T=table(Paths,PostureFile,PupilFile,PuffsFile,WhiskingFile,Mouse,Genotype,Condition,DrugID,Promoter,SampleF,Pixelsize,Puff_2use,RecordingID);
    csv=fullfile(out,'input.csv');writetable(T,csv);
    config=struct('inputCsv',csv,'masterFolder',out,'outputRoot',fullfile(out,'statistics'), ...
        'interactive',false,'imagingMode','BLI','useCuratedSinks',false,'chooseSpecificFolders',false, ...
        'sinkFolderSelection','Recent','surgeFolderSelection','Recent','behaviourFolderSelection','Recent', ...
        'behaviourTimeWindows',{{'3','3','3','3'}},'analysisWindowsCsv','','baselinePairsCsv','','windowPairsCsv','');
    Stats=runOxygenDynamicsStats(config);
    save(fullfile(out,'EngineReturns.mat'),'Master','Stats','config');
    for k=1:numel(Request.Sources)
        src=Request.Sources(k);
        assert(strcmp(oxygenFileSHA256(fullfile(o.RecordingFolder,src.Name)),src.SHA256), ...
            'OxygenDynamics:RunSourceChanged','Source changed during analysis: %s.',src.Name);
    end
    paths={fullfile(out,'RunRequest.mat'),Master.ReviewAuditPath, ...
        fullfile(Master.OutputFolders.OxySinksPath,['OxygenSinks_Urefined' Master.DatafileID '.mat']), ...
        fullfile(Master.OutputFolders.OxySurgesPath,['OxygenSurges' Master.DatafileID '.mat']), ...
        Stats.DataOutputMat,Stats.OutputXlsx,Stats.AnalysisManifest, ...
        fullfile(fileparts(Master.ReviewAuditPath),'AuditCreationReceipt.json'),fullfile(out,'CodeManifest.csv')};
    roles={'Request','EventAudit','SinkMaster','SurgeMaster','DataOutput','Workbook','AnalysisManifest','AuditReceipt','CodeManifest'};
    artifacts=struct('Role',{},'Path',{},'SHA256',{});
    for k=1:numel(paths)
        assert(startsWith(paths{k},[out filesep]),'OxygenDynamics:RunPathMismatch','Output escaped its run directory.');
        artifacts(k)=struct('Role',roles{k},'Path',paths{k}(numel(out)+2:end),'SHA256',oxygenFileSHA256(paths{k}));
    end
    Run=struct('Schema','boi-recording-run-1','Status','complete','SourceSHA256',Request.InputReview.RawSHA256, ...
        'SupportProfile',o.SupportProfile,'Artifacts',artifacts,'ElapsedSeconds',toc(started), ...
        'ScientificStatus','not_established');
    save(fullfile(out,'BOIRun.mat'),'Run');
    Status.Status='complete';Status.Stage='complete';Status.ElapsedSeconds=toc(started);writeBOIRunJSON(statusPath,Status);
    Run=loadBOIRecordingRun(fullfile(out,'BOIRun.mat'));
    reportProgress();
catch err
    Status.Status='failed';Status.ErrorID=err.identifier;Status.ErrorMessage=err.message;
    Status.ElapsedSeconds=toc(started);writeBOIRunJSON(statusPath,Status);reportProgress();rethrow(err);
end
    function reportProgress()
        if isempty(ProgressFcn),return;end
        try
            ProgressFcn(Status,statusPath);
        catch progressError
            warning('OxygenDynamics:RunProgressDisplayFailed', ...
                'Run status was saved, but its progress display failed: %s',progressError.message);
        end
    end
end
