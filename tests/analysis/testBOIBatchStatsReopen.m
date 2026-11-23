function tests=testBOIBatchStatsReopen
% Receipt-only reopening; sources intentionally do not exist. No analysis runs.
tests=functiontests(localfunctions);
end
function setupOnce(~),setupOxygenDynamicsPath;end

function testFolderAndReceiptReopenWithoutSourcesOrWrites(t)
[folder,R,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));before=hashes(folder);
verifyFalse(t,isfile(R.Included.SinkMaster(1)));
for input={folder,fullfile(folder,'BatchStatsResult.mat'),fullfile(folder,'BatchStatsStatus.json')}
    [loaded,I]=loadBOIBatchStatsResult(input{1});verifyEqual(t,loaded,R);
    verifyTrue(t,I.ReadOnly);verifyFalse(t,I.OriginalRecordingsRechecked);verifyFalse(t,I.FullFileChecksumsRechecked);
    verifyEqual(t,I.CreatorSoftware,'3.1.0-dev.9');verifyEqual(t,I.Directory,folder);
end
verifyEqual(t,hashes(folder),before);
end

function testHandoffSeparatesAvailabilityFromCompletion(t)
[folder,~,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
[R,I]=loadBOIBatchStatsResult(folder);verifyEqual(t,R.Status,'complete');
verifyEqual(t,I.Burden.Recordings,2);verifyEqual(t,I.Burden.AvailableNormalizedRecordings,1);
verifyEqual(t,I.Burden.Events,4);verifyEqual(t,I.Burden.AvailableEvents,3);verifyEqual(t,I.Burden.MissingEvents,1);
text=strjoin(string(I.Handoff),newline);
for expected=["HypoxicBurden_ByRecording","HypoxicBurden_EventBased","BurdenAmplitudeSource", ...
        "HypoxicBurden_ReferencePolicy","NormalizationGuide","burden-only companion","not zero"]
    verifyTrue(t,contains(text,expected));
end
verifyTrue(t,contains(text,'1 / 2 normalized recording values available'));
data=load(R.DataOutput,'HypoxicBurden');
verifyEqual(t,data.HypoxicBurden.RecordingTable.HypoxicBurden_per_mm2_per_min(1),1.2e6);
verifyTrue(t,isnan(data.HypoxicBurden.RecordingTable.HypoxicBurden_per_mm2_per_min(2)));
end

function testMissingAndIncompleteReceiptsCannotReopen(t)
[folder,~,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
path=fullfile(folder,'BatchStatsStatus.json');original=jsondecode(fileread(path));
for state={'running','failed'}
    status=original;status.Status=state{1};writeBOIRunJSON(path,status);
    verifyError(t,@()loadBOIBatchStatsResult(folder),'OxygenDynamics:BatchStatsSavedExport');
end
delete(path);verifyError(t,@()loadBOIBatchStatsResult(folder),'OxygenDynamics:BatchStatsSavedExport');
end

function testUnknownSchemaAndChangedSelectionAreRejected(t)
[folder,R,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
path=fullfile(folder,'BatchStatsResult.mat');Result=R;Result.Schema='future-schema';save(path,'Result');
verifyError(t,@()loadBOIBatchStatsResult(folder),'OxygenDynamics:BatchStatsSavedExport');
Result=R;Result.PlanDigest=repmat('a',1,64);save(path,'Result');
verifyError(t,@()loadBOIBatchStatsResult(folder),'OxygenDynamics:BatchStatsSavedExport');
Result=R;save(path,'Result');p=fullfile(folder,'BatchStatsSelection.mat');s=load(p,'Plan');Plan=s.Plan;
Plan.Counts.Included=99;save(p,'Plan');
verifyError(t,@()loadBOIBatchStatsResult(folder),'OxygenDynamics:BatchStatsSavedExport');
end

function testOutsidePathsAndMovedFolderAreRejected(t)
[folder,R,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
outside=fullfile(root,'outside.xlsx');copyfile(R.Workbook,outside);
Result=R;Result.Workbook=outside;Result.StatsResult.OutputXlsx=outside;save(fullfile(folder,'BatchStatsResult.mat'),'Result');
verifyError(t,@()loadBOIBatchStatsResult(folder),'OxygenDynamics:BatchStatsSavedExport');
Result=R;save(fullfile(folder,'BatchStatsResult.mat'),'Result');
moved=fullfile(root,'moved export');movefile(folder,moved);
verifyError(t,@()loadBOIBatchStatsResult(moved),'OxygenDynamics:BatchStatsSavedExport');
end

function testMissingOrWrongCoreTablesAreRejected(t)
[folder,R,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
core=fullfile(fileparts(R.DataOutput),'SinkEventTable.mat');WrongVariable=1;save(core,'WrongVariable');
verifyError(t,@()loadBOIBatchStatsResult(folder),'OxygenDynamics:BatchStatsSavedExport');
delete(core);verifyError(t,@()loadBOIBatchStatsResult(folder),'OxygenDynamics:BatchStatsSavedExport');
end

function testMixedRegistryAndWorkbookIdentityAreRejected(t)
[folder,R,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));data=load(R.DataOutput);
bad=data.RecordingRegistry;bad.RecordingID(1)="other";writetable(bad,R.Workbook,'Sheet','RecordingRegistry');
verifyError(t,@()loadBOIBatchStatsResult(folder),'OxygenDynamics:BatchStatsSavedExport');
writetable(data.RecordingRegistry,R.Workbook,'Sheet','RecordingRegistry');bad=data.HypoxicBurden.RecordingTable;bad.RecordingID(1)="other";
writetable(bad,R.Workbook,'Sheet','HypoxicBurden_ByRecording');
verifyError(t,@()loadBOIBatchStatsResult(folder),'OxygenDynamics:BatchStatsSavedExport');
end

function testMixedMasterAndCountReceiptsAreRejected(t)
[folder,R,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
Result=R;Result.StatsResult.StatsInfo.Recordings(1).SinksMatFile='another-source.mat';save(fullfile(folder,'BatchStatsResult.mat'),'Result');
verifyError(t,@()loadBOIBatchStatsResult(folder),'OxygenDynamics:BatchStatsSavedExport');
Result=R;save(fullfile(folder,'BatchStatsResult.mat'),'Result');path=fullfile(folder,'BatchStatsStatus.json');
status=jsondecode(fileread(path));status.IncludedRecordings=99;writeBOIRunJSON(path,status);
verifyError(t,@()loadBOIBatchStatsResult(folder),'OxygenDynamics:BatchStatsSavedExport');
end

function testLegacyMissingAvailabilityStaysUnknown(t)
[folder,R,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
data=load(R.DataOutput);data=rmfield(data,'HypoxicBurden');save(R.DataOutput,'-struct','data');
delete(R.Workbook);writetable(data.RecordingRegistry,R.Workbook,'Sheet','RecordingRegistry');
[~,I]=loadBOIBatchStatsResult(folder);verifyFalse(t,I.Burden.Known);
verifyTrue(t,isnan(I.Burden.AvailableNormalizedRecordings));
verifyTrue(t,any(contains(string(I.Handoff),'BURDEN AVAILABILITY: not recorded')));
end

function testKnownZeroEventExportRemainsZero(t)
[folder,R,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
data=load(R.DataOutput);E=data.HypoxicBurden.EventTable;
data.HypoxicBurden=createHypoxicBurdenMetrics(E([],:),table(),table(),data.RecordingRegistry);
save(R.DataOutput,'-struct','data');delete(R.Workbook);writeHypoxicBurdenWorkbookSheets(R.Workbook,data.HypoxicBurden);
writetable(data.RecordingRegistry,R.Workbook,'Sheet','RecordingRegistry');
[~,I]=loadBOIBatchStatsResult(folder);
verifyTrue(t,I.Burden.Known);verifyEqual(t,I.Burden.Events,0);verifyEqual(t,I.Burden.MissingEvents,0);
verifyEqual(t,I.Burden.AvailableNormalizedRecordings,2);
end

function [folder,Result,root]=fixture()
root=tempname;mkdir(root);folder=fullfile(root,'export with spaces and ''quotes''');mkdir(folder);
stats=fullfile(folder,'statistics');mkdir(stats);
ids=["recording-A";"recording-B"];n=2;
RecordingRegistry=table(ids,["0012";"0007"],repmat("example",n,1),repmat("baseline",n,1), ...
    repmat("none",n,1),repmat("genotype",n,1),repmat("promoter",n,1),false(n,1), ...
    repmat(100,n,1),ones(n,1),repmat(100,n,1),repmat(100,n,1),'VariableNames', ...
    {'RecordingID','Mouse','Experiment','Condition','DrugID','Genotype','Promoter','PuffStim', ...
    'NFrames','SampleF','RecordingDuration_sec','RecordingArea_um2'});
E=RecordingRegistry([1 1 2 2],:);E.SinkID=[1;2;1;2];E.EventID=ones(4,1);
E.StartFrame=[10;20;10;20];E.EndFrame=E.StartFrame+1;E.DurationSec=repmat(2,4,1);
E.NormOxySinkAmpPercent=[10;20;30;NaN];E.EventArea_um2=[4;3;2;2];E.RecAreaSize=repmat(100,4,1);E.RecDuration=repmat(100,4,1);
HypoxicBurden=createHypoxicBurdenMetrics(E,table(),table(),RecordingRegistry);
D=struct('RecordingRegistry',RecordingRegistry,'HypoxicBurden',HypoxicBurden, ...
    'Table_OxygenSinks_OutCombo',table(),'Table_OxygenSinkEvents_OutCombo',E, ...
    'Table_OxygenSurges_OutCombo',table(),'Table_OxygenSurgeEvents_OutCombo',table());
data=fullfile(stats,'DataOutput.mat');save(data,'-struct','D');
saveStatsCoreTables(stats,table(),E,table(),table());
book=fullfile(stats,'FilteredData_batch.xlsx');writeHypoxicBurdenWorkbookSheets(book,HypoxicBurden);
writetable(RecordingRegistry,book,'Sheet','RecordingRegistry');
manifest=fullfile(stats,'AnalysisManifest.md');fid=fopen(manifest,'w');fprintf(fid,'Synthetic saved-export fixture; no biological data.\n');fclose(fid);
masters=fullfile(root,["offline-A";"offline-B"],"Sink.mat");surges=fullfile(root,["offline-A";"offline-B"],"Surge.mat");
included=table(["row-A";"row-B"],ids,masters,surges,'VariableNames',{'BatchRowID','RecordingID','SinkMaster','SurgeMaster'});
excluded=table(strings(0,1),'VariableNames',{'BatchRowID'});
sources=struct('RecordingID',cellstr(ids),'SinkMaster',cellstr(masters),'SurgeMaster',cellstr(surges));
records=struct('SinksMatFile',cellstr(masters),'SurgesMatFile',cellstr(surges));
Plan=struct('Schema','boi-batch-stats-plan-1','OutputFolder',folder,'Included',included,'Excluded',excluded, ...
    'InputRows',table(ids,'VariableNames',{'RecordingID'}),'InputCSVName','batch.csv','SavedSources',sources, ...
    'Counts',struct('Included',2,'Excluded',0));Plan.Digest=boiBatchQueueDigest(Plan);
save(fullfile(folder,'BatchStatsSelection.mat'),'Plan');
writetable(Plan.InputRows,fullfile(folder,'batch.csv'));writetable(included,fullfile(folder,'IncludedRecordings.csv'));
writetable(excluded,fullfile(folder,'ExcludedRecordings.csv'));writetable(Plan.InputRows,fullfile(folder,'BatchSourceRows.csv'));
statsResult=struct('OutputXlsx',book,'DataOutputMat',data,'AnalysisManifest',manifest, ...
    'StatsInfo',struct('Recordings',records,'CalculationSoftware',struct('Version','3.1.0-dev.9')));
Result=struct('Schema','boi-batch-stats-result-1','Status','complete','Directory',folder,'Workbook',book, ...
    'DataOutput',data,'AnalysisManifest',manifest,'Included',included,'Excluded',excluded,'StatsResult',statsResult,'PlanDigest',Plan.Digest);
save(fullfile(folder,'BatchStatsResult.mat'),'Result');
writeBOIRunJSON(fullfile(folder,'BatchStatsStatus.json'),struct('Schema','boi-batch-stats-status-1', ...
    'Status','complete','Stage','complete','Workbook',book,'IncludedRecordings',2,'ExcludedRecordings',0));
end
function h=hashes(folder)
list=dir(fullfile(folder,'**','*'));h=strings(0,2);
for k=1:numel(list)
    if list(k).isdir,continue;end
    path=fullfile(list(k).folder,list(k).name);h(end+1,:)=[string(path),string(oxygenFileSHA256(path))]; %#ok<AGROW>
end
end
