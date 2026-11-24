function Result=runBOIBatchStats(Batch,Plan,ProgressFcn,Executor)
%RUNBOIBATCHSTATS Collect reviewed saved runs using the existing stats exporter.
% Never dispatches a detector, stages movies, or writes into completed runs.
setupOxygenDynamicsPath;
if nargin<3,ProgressFcn=[];end
if nargin<4||isempty(Executor),Executor=@runOxygenDynamicsStats;end
assert(isstruct(Plan)&&isscalar(Plan)&&isfield(Plan,'Schema')&& ...
    strcmp(Plan.Schema,'boi-batch-stats-plan-1')&&isfield(Plan,'Digest'), ...
    'OxygenDynamics:BatchStatsNotReviewed','Review the combined export before starting it.');
plain=rmfield(Plan,'Digest');
assert(strcmp(Plan.Digest,boiBatchQueueDigest(plain))&& ...
    strcmp(Plan.BatchDigest,boiBatchQueueDigest(Batch)), ...
    'OxygenDynamics:BatchStatsPlanChanged','The batch or export selection changed; review again.');
assert(isfile(Plan.BatchFile)&&strcmp(oxygenFileSHA256(Plan.BatchFile),Plan.BatchFileSHA256), ...
    'OxygenDynamics:BatchStatsCSVChanged','The saved batch CSV changed; reopen and review it.');
assert(isempty(ProgressFcn)||isa(ProgressFcn,'function_handle'),'OxygenDynamics:StatsProgress','Supply an optional progress function handle.');
assert(isa(Executor,'function_handle'),'OxygenDynamics:BatchStatsExecutor','Supply a stats executor function handle.');
assert(~isfolder(Plan.OutputFolder)&&~isfile(Plan.OutputFolder), ...
    'OxygenDynamics:BatchStatsOutputExists','Choose a fresh combined export; earlier output is preserved.');
recordingCount=height(Plan.Included);
% Recheck current sources/settings and indexed artifacts immediately before
% running stats. No automatic CSV save or completion/review writeback occurs.
[~,report]=checkBOIBatch(Batch,Plan.Included.BatchRowID,@checkProgress);
indices=ismember(report.BatchRowID,Plan.Included.BatchRowID);
assert(all(report.InputStatus(indices)=="Ready"&report.AnalysisStatus(indices)=="Complete"&report.ResultCheck(indices)=="Matches"), ...
    'OxygenDynamics:BatchStatsRunChanged','A reviewed saved run or its inputs changed; review combined export again.');
for k=1:recordingCount
    emitProgress(progressEvent('verifying-sources',k,recordingCount,Plan.Included.Mouse(k)));
    run=loadBOIRecordingRun(Plan.Included.RunFolder(k));
    assert(strcmp(run.Paths.SinkMaster,Plan.SavedSources(k).SinkMaster)&& ...
        strcmp(run.Paths.SurgeMaster,Plan.SavedSources(k).SurgeMaster), ...
        'OxygenDynamics:BatchStatsRunChanged','A reviewed run now resolves to different master files.');
end
[ok,~,id]=mkdir(Plan.OutputFolder);
assert(ok&&isempty(id),'OxygenDynamics:BatchStatsOutputExists','The new export directory could not be claimed.');
statusPath=fullfile(Plan.OutputFolder,'BatchStatsStatus.json');
status=struct('Schema','boi-batch-stats-status-1','Status','running','Stage','preparing', ...
    'StartedUTC',char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ss'Z'")), ...
    'IncludedRecordings',Plan.Counts.Included,'ExcludedRecordings',Plan.Counts.Excluded);
status.ExporterSoftware=getOxygenPipelineVersion();
writeBOIRunJSON(statusPath,status);
try
    emitProgress(progressEvent('preparing',1,1,''));
    save(fullfile(Plan.OutputFolder,'BatchStatsSelection.mat'),'Plan');
    writetable(Plan.SourceRows,fullfile(Plan.OutputFolder,'BatchSourceRows.csv'));
    writetable(Plan.Included,fullfile(Plan.OutputFolder,'IncludedRecordings.csv'));
    writetable(Plan.Excluded,fullfile(Plan.OutputFolder,'ExcludedRecordings.csv'));
    csv=fullfile(Plan.OutputFolder,Plan.InputCSVName);writetable(Plan.InputRows,csv);
    config=struct('inputCsv',csv,'masterFolder',Plan.OutputFolder, ...
        'outputRoot',fullfile(Plan.OutputFolder,'statistics'),'interactive',false,'imagingMode','BLI', ...
        'useCuratedSinks',false,'chooseSpecificFolders',false,'sinkFolderSelection','Recent', ...
        'surgeFolderSelection','Recent','behaviourFolderSelection','Recent', ...
        'behaviourTimeWindows',{{'3','3','3','3'}},'analysisWindowsCsv','','baselinePairsCsv','', ...
        'windowPairsCsv','','savedRecordingSources',Plan.SavedSources,'progressFcn',@statsProgress);
    stats=Executor(config);
    coreFiles={'SinkTable4LME.mat','SinkEventTable.mat','SurgeTable4LME.mat','SurgeEventTable.mat'};
    outputCheckCount=numel(coreFiles)+4;
    statsProgress(progressEvent('verifying-output',1,outputCheckCount,'','Required export files'));
    assert(isstruct(stats)&&all(isfield(stats,{'OutputXlsx','DataOutputMat','AnalysisManifest','StatsInfo'})), ...
        'OxygenDynamics:BatchStatsIncomplete','The existing stats service did not return completed export paths.');
    for field={'OutputXlsx','DataOutputMat','AnalysisManifest'}
        path=char(java.io.File(stats.(field{1})).getCanonicalPath());
        assert(isfile(path)&&startsWith(path,[Plan.OutputFolder filesep]), ...
            'OxygenDynamics:BatchStatsIncomplete','A required combined export is missing or outside its new directory.');
    end
    required={'RecordingRegistry','Table_OxygenSinks_OutCombo','Table_OxygenSinkEvents_OutCombo', ...
        'Table_OxygenSurges_OutCombo','Table_OxygenSurgeEvents_OutCombo'};
    statsProgress(progressEvent('verifying-output',2,outputCheckCount,'','DataOutput.mat table inventory'));
    saved=whos('-file',stats.DataOutputMat);
    assert(all(ismember(required,{saved.name})), ...
        'OxygenDynamics:BatchStatsIncomplete','A required table is missing from the combined MAT export.');
    for k=1:numel(coreFiles)
        statsProgress(progressEvent('verifying-output',k+2,outputCheckCount,'',coreFiles{k}));
        path=fullfile(fileparts(stats.DataOutputMat),coreFiles{k});
        assert(isfile(path),'OxygenDynamics:BatchStatsIncomplete','A core MAT export is missing.');
        saved=whos('-file',path);
        assert(ismember(required{k+1},{saved.name}), ...
            'OxygenDynamics:BatchStatsIncomplete','A required table is missing from %s.',path);
    end
    statsProgress(progressEvent('verifying-output',outputCheckCount-1,outputCheckCount,'','Recording registry'));
    data=load(stats.DataOutputMat,'RecordingRegistry');
    assert(isfield(data,'RecordingRegistry')&&height(data.RecordingRegistry)==height(Plan.Included)&& ...
        isequal(sort(string(data.RecordingRegistry.RecordingID)),sort(Plan.Included.RecordingID)), ...
        'OxygenDynamics:BatchStatsIncomplete','Combined results do not contain exactly the reviewed recording identities.');
    statsProgress(progressEvent('verifying-output',outputCheckCount,outputCheckCount,'','Saved master file paths'));
    recorded=stats.StatsInfo.Recordings;
    assert(numel(recorded)==numel(Plan.SavedSources)&& ...
        isequal(string({recorded.SinksMatFile}),string({Plan.SavedSources.SinkMaster}))&& ...
        isequal(string({recorded.SurgesMatFile}),string({Plan.SavedSources.SurgeMaster})), ...
        'OxygenDynamics:BatchStatsSourceChanged','Statistics loaded different master files from the reviewed selection.');
    for k=1:recordingCount
        statsProgress(progressEvent('reverifying-runs',k,recordingCount+1,Plan.Included.Mouse(k)));
        loadBOIRecordingRun(Plan.Included.RunFolder(k));
    end
    statsProgress(progressEvent('reverifying-runs',recordingCount+1,recordingCount+1,'','Batch CSV'));
    assert(strcmp(oxygenFileSHA256(Plan.BatchFile),Plan.BatchFileSHA256), ...
        'OxygenDynamics:BatchStatsCSVChanged','The working CSV changed during combined export; its external edits were preserved.');
    statsProgress(progressEvent('saving-receipt',1,1,''));
    Result=struct('Schema','boi-batch-stats-result-1','Status','complete','Directory',Plan.OutputFolder, ...
        'Workbook',stats.OutputXlsx,'DataOutput',stats.DataOutputMat,'AnalysisManifest',stats.AnalysisManifest, ...
        'Included',Plan.Included,'Excluded',Plan.Excluded,'StatsResult',stats,'PlanDigest',Plan.Digest);
    Result.ExporterSoftware=status.ExporterSoftware;
    save(fullfile(Plan.OutputFolder,'BatchStatsResult.mat'),'Result');
    completed=status;
    completed.Status='complete';completed.Stage='complete';completed.Index=recordingCount;
    completed.Workbook=Result.Workbook;writeBOIRunJSON(statusPath,completed);
catch err
    status.Status='failed';status.ErrorID=err.identifier;status.ErrorMessage=err.message;
    writeBOIRunJSON(statusPath,status);rethrow(err);
end
emitProgress(progressEvent('complete',recordingCount,recordingCount,''));
    function checkProgress(event)
        emitProgress(progressEvent('verifying',event.CheckIndex,event.CheckCount,event.Label));
    end
    function statsProgress(event)
        % The inner exporter has written its files but the batch still has to verify them.
        if strcmp(event.Stage,'complete'),return;end
        status.Stage=event.Stage;status.Index=event.Index;writeBOIRunJSON(statusPath,status);
        emitProgress(event);
    end
    function emitProgress(event)
        if ~isempty(ProgressFcn),ProgressFcn(event);end
    end
end

function event=progressEvent(stage,index,count,mouse,item)
event=struct('Stage',stage,'Index',index,'Count',count,'Mouse',char(string(mouse)));
if nargin==5,event.Item=item;end
end
