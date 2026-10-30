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
% Recheck current sources/settings and indexed artifacts immediately before
% running stats. No automatic CSV save or completion/review writeback occurs.
[~,report]=checkBOIBatch(Batch,Plan.Included.BatchRowID,@checkProgress);
indices=ismember(report.BatchRowID,Plan.Included.BatchRowID);
assert(all(report.InputStatus(indices)=="Ready"&report.AnalysisStatus(indices)=="Complete"&report.ResultCheck(indices)=="Matches"), ...
    'OxygenDynamics:BatchStatsRunChanged','A reviewed saved run or its inputs changed; review combined export again.');
for k=1:height(Plan.Included)
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
writeBOIRunJSON(statusPath,status);
try
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
    assert(isstruct(stats)&&all(isfield(stats,{'OutputXlsx','DataOutputMat','AnalysisManifest','StatsInfo'})), ...
        'OxygenDynamics:BatchStatsIncomplete','The existing stats service did not return completed export paths.');
    for field={'OutputXlsx','DataOutputMat','AnalysisManifest'}
        path=char(java.io.File(stats.(field{1})).getCanonicalPath());
        assert(isfile(path)&&startsWith(path,[Plan.OutputFolder filesep]), ...
            'OxygenDynamics:BatchStatsIncomplete','A required combined export is missing or outside its new directory.');
    end
    required={'RecordingRegistry','Table_OxygenSinks_OutCombo','Table_OxygenSinkEvents_OutCombo', ...
        'Table_OxygenSurges_OutCombo','Table_OxygenSurgeEvents_OutCombo'};
    saved=whos('-file',stats.DataOutputMat);
    assert(all(ismember(required,{saved.name})), ...
        'OxygenDynamics:BatchStatsIncomplete','A required table is missing from the combined MAT export.');
    coreFiles={'SinkTable4LME.mat','SinkEventTable.mat','SurgeTable4LME.mat','SurgeEventTable.mat'};
    for k=1:numel(coreFiles)
        path=fullfile(fileparts(stats.DataOutputMat),coreFiles{k});
        assert(isfile(path),'OxygenDynamics:BatchStatsIncomplete','A core MAT export is missing.');
        saved=whos('-file',path);
        assert(ismember(required{k+1},{saved.name}), ...
            'OxygenDynamics:BatchStatsIncomplete','A required table is missing from %s.',path);
    end
    data=load(stats.DataOutputMat,'RecordingRegistry');
    assert(isfield(data,'RecordingRegistry')&&height(data.RecordingRegistry)==height(Plan.Included)&& ...
        isequal(sort(string(data.RecordingRegistry.RecordingID)),sort(Plan.Included.RecordingID)), ...
        'OxygenDynamics:BatchStatsIncomplete','Combined results do not contain exactly the reviewed recording identities.');
    recorded=stats.StatsInfo.Recordings;
    assert(numel(recorded)==numel(Plan.SavedSources)&& ...
        isequal(string({recorded.SinksMatFile}),string({Plan.SavedSources.SinkMaster}))&& ...
        isequal(string({recorded.SurgesMatFile}),string({Plan.SavedSources.SurgeMaster})), ...
        'OxygenDynamics:BatchStatsSourceChanged','Statistics loaded different master files from the reviewed selection.');
    for k=1:height(Plan.Included),loadBOIRecordingRun(Plan.Included.RunFolder(k));end
    assert(strcmp(oxygenFileSHA256(Plan.BatchFile),Plan.BatchFileSHA256), ...
        'OxygenDynamics:BatchStatsCSVChanged','The working CSV changed during combined export; its external edits were preserved.');
    Result=struct('Schema','boi-batch-stats-result-1','Status','complete','Directory',Plan.OutputFolder, ...
        'Workbook',stats.OutputXlsx,'DataOutput',stats.DataOutputMat,'AnalysisManifest',stats.AnalysisManifest, ...
        'Included',Plan.Included,'Excluded',Plan.Excluded,'StatsResult',stats,'PlanDigest',Plan.Digest);
    save(fullfile(Plan.OutputFolder,'BatchStatsResult.mat'),'Result');
    status.Status='complete';status.Stage='complete';status.Workbook=Result.Workbook;writeBOIRunJSON(statusPath,status);
catch err
    status.Status='failed';status.ErrorID=err.identifier;status.ErrorMessage=err.message;
    writeBOIRunJSON(statusPath,status);rethrow(err);
end
    function checkProgress(event)
        if isempty(ProgressFcn),return;end
        ProgressFcn(struct('Stage','verifying','Index',event.CheckIndex,'Count',event.CheckCount,'Mouse',event.Label));
    end
    function statsProgress(event)
        status.Stage=event.Stage;status.Index=event.Index;writeBOIRunJSON(statusPath,status);
        if ~isempty(ProgressFcn),ProgressFcn(event);end
    end
end
