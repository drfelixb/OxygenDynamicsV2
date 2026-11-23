function tests=testBOIBatchStats
% Exact saved-run handoff and GUI protection. No detector or recording runs.
tests=functiontests(localfunctions);
end
function setupOnce(~),setupOxygenDynamicsPath;end

function test01CompletedSelectionAndMetadata(t)
[b,parent,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
[p,c]=prepareBOIBatchStats(b,parent);
verifyEqual(t,p.Counts.Included,2);verifyEqual(t,p.Counts.Excluded,1);
verifyEqual(t,p.InputRows.Mouse,["0001";"0002"]);
verifyTrue(t,all(isnan(p.InputRows.PuffsFile)));verifyTrue(t,all(isnan(p.InputRows.Puff_2use)));
verifyEqual(t,p.SourceRows.Puff_2use,repmat("0007",3,1));
verifyEqual(t,p.InputRows.Paths,string({p.SavedSources.RecordingFolder})');
verifyEqual(t,p.InputRows.RecordingID,p.Included.RecordingID);
verifyNotEqual(t,p.InputRows.Paths,b.Rows.Paths(1:2));
verifyFalse(t,isfolder(p.OutputFolder));verifyEqual(t,c.Rows.ReviewStatus,b.Rows.ReviewStatus);
end

function test02PinnedMastersIgnoreNewerFoldersAndOtherFiles(t)
[b,parent,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
[p,~]=prepareBOIBatchStats(b,parent,b.Rows.BatchRowID(1));s=p.SavedSources(1);
newer=fullfile(s.RecordingFolder,'OxygenSinks_Output_newer');mkdir(newer);
writeBOIRunJSON(fullfile(newer,'OxygenSinks_Urefined_decoy.mat'),struct('Decoy',true));
writeBOIRunJSON(fullfile(fileparts(s.SinkMaster),'a_Urefined_decoy.mat'),struct('Decoy',true));
assert(java.io.File(newer).setLastModified(java.lang.System.currentTimeMillis()+60000));
exact=createStatsRecordingSourceInfo(s.RecordingFolder,'','No','Recent','Recent','Recent',s);
verifyEqual(t,exact.SinksMatFile,s.SinkMaster);verifyEqual(t,exact.SurgesMatFile,s.SurgeMaster);
verifyFalse(t,exact.HasBehaviourData);
legacy=createStatsRecordingSourceInfo(s.RecordingFolder,'','No','Recent','Recent','Recent');
verifyEqual(t,legacy.SinksDataFolder,newer);verifyEmpty(t,legacy.SinksMatFile);
bad=s;bad.SinkMaster=fullfile(root,'outside.mat');writeBOIRunJSON(bad.SinkMaster,struct('Decoy',true));
verifyError(t,@()createStatsRecordingSourceInfo(s.RecordingFolder,'','No','Recent','Recent','Recent',bad),'OxygenDynamics:StatsSavedSource');
end

function test03StalePlanAndOutputConflictNeverDispatch(t)
[b,parent,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
[p,b]=prepareBOIBatchStats(b,parent);
changed=b;changed.Rows.Mouse(1)="edited";
verifyError(t,@()runBOIBatchStats(changed,p,[],@neverDispatch),'OxygenDynamics:BatchStatsPlanChanged');
tampered=p;tampered.SavedSources(1).SinkMaster='other.mat';
verifyError(t,@()runBOIBatchStats(b,tampered,[],@neverDispatch),'OxygenDynamics:BatchStatsPlanChanged');
mkdir(p.OutputFolder);verifyError(t,@()runBOIBatchStats(b,p,[],@neverDispatch),'OxygenDynamics:BatchStatsOutputExists');
rmdir(p.OutputFolder);
fid=fopen(b.FilePath,'a');fprintf(fid,'\n');fclose(fid);
verifyError(t,@()runBOIBatchStats(b,p,[],@neverDispatch),'OxygenDynamics:BatchStatsCSVChanged');
verifyFalse(t,isfolder(p.OutputFolder));
end

function test04ChangedArtifactStopsBeforeStats(t)
[b,parent,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
[p,b]=prepareBOIBatchStats(b,parent);run=loadBOIRecordingRun(p.Included.RunFolder(1));
writeBOIRunJSON(run.Paths.Workbook,struct('Changed',true));
verifyError(t,@()runBOIBatchStats(b,p,[],@neverDispatch),'OxygenDynamics:BatchStatsRunChanged');
verifyFalse(t,isfolder(p.OutputFolder));
end

function test05SuccessfulDispatchAndExistingFormats(t)
[b,parent,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
[p,b]=prepareBOIBatchStats(b,parent);hash=oxygenFileSHA256(b.FilePath);calls=0;
events={};statusPath=fullfile(p.OutputFolder,'BatchStatsStatus.json');
receiptPath=fullfile(p.OutputFolder,'BatchStatsResult.mat');
r=runBOIBatchStats(b,p,@observe,@execute);
verifyEqual(t,calls,1);verifyEqual(t,r.Status,'complete');verifyTrue(t,isfile(r.Workbook));
verifyEqual(t,oxygenFileSHA256(b.FilePath),hash);
verifyTrue(t,endsWith(r.Workbook,'FilteredData_batch.xlsx'));
saved=load(fullfile(r.Directory,'BatchStatsSelection.mat'),'Plan');verifyEqual(t,saved.Plan,p);
status=jsondecode(fileread(statusPath));verifyEqual(t,status.Status,'complete');
stages=string(cellfun(@(event)event.Stage,events,'UniformOutput',false));
verifyEqual(t,unique(stages,'stable'),["verifying";"verifying-sources";"preparing";"loading"; ...
    "verifying-output";"reverifying-runs";"saving-receipt";"complete"]);
sources=[events{stages=="verifying-sources"}];
verifyEqual(t,[sources.Index],1:2);verifyEqual(t,[sources.Count],[2 2]);
verifyEqual(t,{sources.Mouse},{'0001','0002'});
output=[events{stages=="verifying-output"}];
verifyEqual(t,[output.Index],1:8);verifyEqual(t,[output.Count],repmat(8,1,8));
verifyEqual(t,output(3).Item,'SinkTable4LME.mat');
rechecks=events(stages=="reverifying-runs");
verifyEqual(t,cellfun(@(event)event.Index,rechecks),[1;2;3]);
verifyEqual(t,cellfun(@(event)event.Count,rechecks),[3;3;3]);
verifyEqual(t,rechecks{2}.Mouse,'0002');verifyEqual(t,rechecks{3}.Item,'Batch CSV');
verifyEqual(t,nnz(stages=="complete"),1);
clear cleanup
    function out=execute(config)
        calls=calls+1;verifyFalse(t,config.useCuratedSinks);verifyEmpty(t,config.analysisWindowsCsv);
        verifyEmpty(t,config.baselinePairsCsv);verifyEqual(t,config.savedRecordingSources,p.SavedSources);
        out=fakeStats(config);
        config.progressFcn(struct('Stage','complete','Index',2,'Count',2,'Mouse',''));
        running=jsondecode(fileread(statusPath));
        verifyEqual(t,running.Status,'running');verifyEqual(t,running.Stage,'loading');
        verifyFalse(t,isfile(receiptPath));
    end
    function observe(event)
        events{end+1,1}=event;
        if strcmp(event.Stage,'saving-receipt')
            writing=jsondecode(fileread(statusPath));
            verifyEqual(t,writing.Status,'running');verifyEqual(t,writing.Stage,'saving-receipt');
            verifyFalse(t,isfile(receiptPath));
        elseif strcmp(event.Stage,'complete')
            finished=jsondecode(fileread(statusPath));
            verifyEqual(t,finished.Status,'complete');verifyEqual(t,finished.Stage,'complete');
            verifyTrue(t,isfile(receiptPath));
        end
    end
end

function test06FailureRetainsPartialFolderAndOriginals(t)
[b,parent,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
[p,b]=prepareBOIBatchStats(b,parent);hash=oxygenFileSHA256(b.FilePath);
verifyError(t,@()runBOIBatchStats(b,p,[],@plannedFailure),'BatchStatsTest:Failure');
status=jsondecode(fileread(fullfile(p.OutputFolder,'BatchStatsStatus.json')));
verifyEqual(t,status.Status,'failed');verifyFalse(t,isfile(fullfile(p.OutputFolder,'BatchStatsResult.mat')));
verifyEqual(t,oxygenFileSHA256(b.FilePath),hash);
verifyTrue(t,isfile(fullfile(p.OutputFolder,'IncludedRecordings.csv')));
end

function test07ReorderAndSavedLabelsPreserved(t)
[b,parent,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
b.Rows=b.Rows([2 3 1],:);b.Rows.Mouse(1)="later label";b=writeBOIBatchCSV(b);
[p,~]=prepareBOIBatchStats(b,parent);
verifyEqual(t,p.InputRows.Mouse,["0002";"0001"]);
verifyEqual(t,p.Included.BatchRowID,b.Rows.BatchRowID([1 3]));
verifyTrue(t,contains(p.Included.MetadataStatus(1),'Metadata changed since run'));
[one,~]=prepareBOIBatchStats(b,parent,b.Rows.BatchRowID(3));
verifyEqual(t,one.Counts.Included,1);verifyEqual(t,one.InputRows.Mouse,"0001");
verifyError(t,@()prepareBOIBatchStats(b,parent,[b.Rows.BatchRowID(1);b.Rows.BatchRowID(1)]),'OxygenDynamics:BatchStatsSelection');
verifyError(t,@()prepareBOIBatchStats(b,char(p.Included.RunFolder(1))),'OxygenDynamics:BatchStatsOutputInsideSource');
end

function test08ExistingStatsEntryPreservesTextAndBindsRows(t)
[b,parent,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
[p,~]=prepareBOIBatchStats(b,parent);csv=fullfile(root,'stats.csv');writetable(p.InputRows,csv);label='';
config=struct('inputCsv',csv,'masterFolder',root,'interactive',false,'imagingMode','BLI', ...
    'useCuratedSinks',false,'chooseSpecificFolders',false,'savedRecordingSources',p.SavedSources,'progressFcn',@observe);
verifyError(t,@()runOxygenDynamicsStats(config),'BatchStatsTest:ObservedLabel');verifyEqual(t,label,'0001');
config.savedRecordingSources=config.savedRecordingSources([2 1]);
verifyError(t,@()runOxygenDynamicsStats(config),'OxygenDynamics:StatsSavedSource');
clear cleanup
    function observe(event)
        label=event.Mouse;error('BatchStatsTest:ObservedLabel','Stop before loading fixture measurements.');
    end
end

function test09GUIReviewConfirmationAndInvalidation(t)
[b,parent,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
[fig,ui]=openBOIBatchEditor(b);closeFig=onCleanup(@()delete(fig));
verifyError(t,@()ui.RunStats(@neverDispatch),'OxygenDynamics:BatchStatsNotConfirmed');
verifyEqual(t,string(ui.ExportStatsButton.Text),"Export workbook");
verifyEqual(t,string(ui.ExportStatsButton.Enable),"off");
ui.SelectRows(1);p=ui.ReviewStats(parent);verifyEqual(t,p.Counts.Included,2);
verifyEqual(t,ui.Tabs.SelectedTab,ui.StatsTab);verifyFalse(t,ui.State().Busy);
verifyEmpty(t,ui.CheckDialog());verifyEqual(t,string(ui.ExportStatsButton.Enable),"on");
verifyEqual(t,string(ui.ExportStatsButton.Text),"Export workbook");
verifyFalse(t,ui.State().StatsConfirmed);verifyFalse(t,isfolder(p.OutputFolder));
verifyTrue(t,contains(ui.StatsPreview.Text,'2 included · 1 excluded'));
verifyEqual(t,string(ui.StatsDetails.Visible),"off");
showDetails=ui.StatsDetailsButton.ButtonPushedFcn;
showDetails(ui.StatsDetailsButton,[]);verifyEqual(t,string(ui.StatsDetails.Visible),"on");
verifyTrue(t,any(contains(string(ui.StatsDetails.Value),string(p.OutputFolder))));
ui.StatsScope.Value='Selected recording rows';
scopeChanged=ui.StatsScope.ValueChangedFcn;scopeChanged(ui.StatsScope,[]);
verifyEmpty(t,ui.State().StatsPlan);verifyEqual(t,string(ui.ExportStatsButton.Enable),"off");
verifyEqual(t,string(ui.StatsDetails.Visible),"off");
ui.ReviewStats(parent);
ui.Edit(1,'Notes','later edit');verifyEmpty(t,ui.State().StatsPlan);
verifyEqual(t,string(ui.ExportStatsButton.Enable),"off");
verifyError(t,@()ui.RunStats(@neverDispatch),'OxygenDynamics:BatchStatsNotConfirmed');
delete(fig);clear closeFig
end

function test10GUIBusySuccessAndFailureRecovery(t)
[b,parent,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
[fig,ui]=openBOIBatchEditor(b);closeFig=onCleanup(@()delete(fig));
ui.ReviewStats(parent);verifyFalse(t,ui.State().StatsConfirmed);r=ui.StartReviewedStats(@execute);
verifyFalse(t,ui.State().Busy);verifyEmpty(t,ui.CheckDialog());
verifyEqual(t,string(ui.OpenStatsButton.Enable),"on");verifyEqual(t,ui.StatsExportFolder.Folder(),r.Directory);
verifyEqual(t,string(ui.OpenStatsFolderButton.Enable),"on");verifyEmpty(t,ui.State().StatsPlan);
verifyEqual(t,string(ui.ExportStatsButton.Enable),"off");
verifyEqual(t,string(ui.StatsDetailsButton.Text),"Show export guide");
verifyTrue(t,ui.State().StatsHandoff.ReadOnly);verifyTrue(t,any(contains(string(ui.StatsDetails.Value),'START HERE FOR POSTPROCESSING')));
availability=ui.State().StatsHandoff.Burden;
if availability.Known
    verifyEqual(t,ui.StatsSummary.Text,sprintf('%d / %d normalized burdens available', ...
        availability.AvailableNormalizedRecordings,availability.Recordings));
else
    verifyEqual(t,ui.StatsSummary.Text,'Burden availability not recorded');
end
priorSummary=ui.StatsSummary.Text;
ui.ReviewStats(parent);
verifyEqual(t,ui.StatsSummary.Text,priorSummary);verifyEqual(t,string(ui.OpenStatsButton.Enable),"on");
verifyError(t,@()ui.StartReviewedStats(@plannedFailure),'BatchStatsTest:Failure');
verifyFalse(t,ui.State().Busy);verifyEmpty(t,ui.CheckDialog());verifyFalse(t,ui.State().StatsConfirmed);
verifyEqual(t,ui.StatsExportFolder.Folder(),r.Directory);verifyTrue(t,isfile(r.Workbook));
verifyEqual(t,ui.StatsOutcome.Text,'Export failed; previous export retained.');
verifyEqual(t,ui.StatsSummary.Text,priorSummary);
delete(fig);clear closeFig cleanup
    function out=execute(config)
        verifyTrue(t,ui.State().Busy);verifyFalse(t,ui.State().Running);
        verifyError(t,@()ui.Edit(1,'Mouse','lost'),'OxygenDynamics:BatchBusy');
        verifyError(t,@()ui.Save(),'OxygenDynamics:BatchBusy');
        verifyError(t,@()ui.ReopenStats(root),'OxygenDynamics:BatchBusy');
        verifyEqual(t,string(ui.ReopenStatsButton.Enable),"off");
        verifyTrue(t,ui.ReviewedExport.State().Busy);verifyEqual(t,string(ui.ReviewedExport.PreviewButton.Enable),"off");
        verifyError(t,@()ui.ReviewedExport.Preview(),'OxygenDynamics:BatchBusy');
        verifyEqual(t,string(ui.StopButton.Enable),"off");
        notify=config.progressFcn;
        notify(struct('Stage','loading','Index',1,'Count',2,'Mouse','0001'));
        dialog=ui.CheckDialog();verifyEqual(t,string(dialog.Indeterminate),"on");
        verifyTrue(t,contains(dialog.Message,'Loading saved recording 1 of 2'));
        out=fakeStats(config);
    end
end

function test13GUIReopensInFreshEditorAndRetainsPreviousOnFailure(t)
[b,parent,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
[p,b]=prepareBOIBatchStats(b,parent);r=runBOIBatchStats(b,p,[],@fakeStats);
minimal=createBOIBatch(table("REPLACE_WITH_RECORDING_FOLDER",'VariableNames',{'Paths'}));
for input={r.Directory,fullfile(r.Directory,'BatchStatsResult.mat')}
    [fig,ui]=openBOIBatchEditor(minimal);closeFig=onCleanup(@()delete(fig));before=ui.GetBatch();
    loaded=ui.ReopenStats(input{1});verifyEqual(t,loaded,r);verifyEqual(t,ui.GetBatch(),before);
    verifyFalse(t,ui.State().Busy);verifyEmpty(t,ui.CheckDialog());verifyEqual(t,ui.Tabs.SelectedTab,ui.StatsTab);
    verifyEqual(t,ui.StatsExportFolder.Folder(),r.Directory);verifyEqual(t,string(ui.OpenStatsButton.Enable),"on");
    verifyEqual(t,string(ui.OpenStatsFolderButton.Enable),"on");verifyEqual(t,string(ui.ExportStatsButton.Enable),"off");
    verifyEqual(t,ui.CompactExport.State().Source.Workbook,r.Workbook);
    verifyTrue(t,ui.CompactExport.State().Source.UseWorkbookBurdenTables);
    verifyEqual(t,fileparts(ui.CompactExport.Destination.Value),fileparts(r.Workbook));
    verifyEqual(t,string(ui.CompactExport.ActionButton.Enable),"on");
    verifyFalse(t,ui.CompactExport.OptionalButton.Value);
    verifyFalse(t,ui.State().StatsHandoff.OriginalRecordingsRechecked);
    verifyError(t,@()ui.ReopenStats(parent),'OxygenDynamics:BatchStatsSavedExport');
    verifyEqual(t,ui.State().StatsResult,r);verifyEqual(t,ui.StatsExportFolder.Folder(),r.Directory);
    verifyFalse(t,ui.State().Busy);verifyEmpty(t,ui.CheckDialog());
    delete(fig);clear closeFig
end
end

function test11MissingSavedTablesCannotReportSuccess(t)
[b,parent,root]=fixture();cleanup=onCleanup(@()rmdir(root,'s'));
for missing=["main","core"]
    [p,b]=prepareBOIBatchStats(b,parent);
    verifyError(t,@()runBOIBatchStats(b,p,[],@incomplete),'OxygenDynamics:BatchStatsIncomplete');
    status=jsondecode(fileread(fullfile(p.OutputFolder,'BatchStatsStatus.json')));
    verifyEqual(t,status.Status,'failed');verifyFalse(t,isfile(fullfile(p.OutputFolder,'BatchStatsResult.mat')));
    verifyEqual(t,status.Stage,'verifying-output');
    if missing=="main",verifyEqual(t,status.Index,2);else,verifyEqual(t,status.Index,3);end
end
    function out=incomplete(config)
        out=fakeStats(config);
        if missing=="main"
            RecordingRegistry=table(string({config.savedRecordingSources.RecordingID})','VariableNames',{'RecordingID'});
            save(out.DataOutputMat,'RecordingRegistry');
        else
            WrongVariable=1;save(fullfile(fileparts(out.DataOutputMat),'SinkTable4LME.mat'),'WrongVariable');
        end
    end
end

function test12ExistingMATNamesAndValuesRoundTrip(t)
root=tempname;mkdir(root);cleanup=onCleanup(@()rmdir(root,'s'));
sites=table([1;2],{[1 3 5];[2 4]},'VariableNames',{'SiteID','Pixels'});
events=table([NaN;Inf;3],'VariableNames',{'Value'});
D=struct('Table_OxygenSinks_OutCombo',sites,'Table_OxygenSinkEvents_OutCombo',events, ...
    'Table_OxygenSurges_OutCombo',sites,'Table_OxygenSurgeEvents_OutCombo',events,'ROIs_Traces',{{[1 2 3]}});
saveStatsDataOutput(root,D,true);saved=load(fullfile(root,'DataOutput.mat'));verifyEqual(t,saved,D);
fid=fopen(fullfile(root,'DataOutput.mat'));header=char(fread(fid,20,'uint8')');fclose(fid);
verifyTrue(t,startsWith(header,'MATLAB 5.0 MAT-file'));
saveStatsCoreTables(root,sites,events,sites,events);
files={'SinkTable4LME.mat','SinkEventTable.mat','SurgeTable4LME.mat','SurgeEventTable.mat'};
names={'Table_OxygenSinks_OutCombo','Table_OxygenSinkEvents_OutCombo','Table_OxygenSurges_OutCombo','Table_OxygenSurgeEvents_OutCombo'};
for k=1:4
    saved=load(fullfile(root,files{k}));verifyEqual(t,fieldnames(saved),names(k)');verifyEqual(t,saved.(names{k}),D.(names{k}));
end
end

function out=fakeStats(config)
% Dispatch/persistence fixture only; numerical/export integration is checked
% separately on the explicitly authorized 17 completed native recordings.
folder=fullfile(config.outputRoot,'Stats_Output_fixture');mkdir(folder);
config.progressFcn(struct('Stage','loading','Index',1,'Count',numel(config.savedRecordingSources),'Mouse','0001'));
RecordingRegistry=table(string({config.savedRecordingSources.RecordingID})','VariableNames',{'RecordingID'});
data=fullfile(folder,'DataOutput.mat');
D=struct('RecordingRegistry',RecordingRegistry,'Table_OxygenSinks_OutCombo',table(), ...
    'Table_OxygenSinkEvents_OutCombo',table(),'Table_OxygenSurges_OutCombo',table(),'Table_OxygenSurgeEvents_OutCombo',table());
saveStatsMATFile(data,D);saveStatsCoreTables(folder,table(),table(),table(),table());
book=createStatsExcelOutputPath(folder,config.inputCsv);
writetable(RecordingRegistry,book,'Sheet','RecordingRegistry');
manifest=fullfile(folder,'AnalysisManifest.md');writeBOIRunJSON(manifest,struct('DispatchFixture',true));
recordings=struct('SinksMatFile',{config.savedRecordingSources.SinkMaster},'SurgesMatFile',{config.savedRecordingSources.SurgeMaster});
out=struct('OutputXlsx',book,'DataOutputMat',data,'AnalysisManifest',manifest,'StatsInfo',struct('Recordings',recordings));
end
function out=plannedFailure(~) %#ok<STOUT>
error('BatchStatsTest:Failure','Finite stats/export fixture failure.');
end
function out=neverDispatch(~) %#ok<STOUT>
error('BatchStatsTest:UnexpectedDispatch','Stale/changed plans must not dispatch statistics.');
end

function [b,parent,root]=fixture()
root=tempname;mkdir(root);parent=fullfile(root,'combined');mkdir(parent);paths=strings(3,1);
for k=1:3
    source=fullfile(root,sprintf('source-%d',k));mkdir(source);paths(k)=string(source);
    raw=uint16((100+k)*ones(48,48,30));
    for f=1:30
        if f==1,imwrite(raw(:,:,f),fullfile(source,'raw.tif'));else,imwrite(raw(:,:,f),fullfile(source,'raw.tif'),'WriteMode','append');end
    end
end
b=createBOIBatch(table(paths,repmat("1",3,1),repmat("1",3,1),repmat("whole-image",3,1), ...
    'VariableNames',{'Paths','SampleF','Pixelsize','BOISupportProfile'}));
b.Rows.Mouse=["0001";"0002";"held"];b.Rows.Puff_2use=repmat("0007",3,1);b.Rows.Notes=repmat("original",3,1);
[rows,origins]=resolveBOIBatch(b);
for k=1:2
    folder=fullfile(root,sprintf('saved-%d',k));
    [request,~,metadata]=prepareBOIBatchRow(rows(k,:),folder,origins(k,:));request.BatchMetadata=metadata;
    makeSavedRun(request);b.Rows.RunFolder(k)=string(folder);
end
b=writeBOIBatchCSV(b,fullfile(root,'batch.csv'));
end
function makeSavedRun(Request)
folder=Request.Options.OutputFolder;mkdir(folder);rec=fullfile(folder,'Recording');mkdir(rec);
copyfile(fullfile(Request.Options.RecordingFolder,'raw.tif'),fullfile(rec,'raw.tif'));
raw=uint16(100*ones(48,48,30));sites=table({cell(1,30)},'VariableNames',{'FramePixels'});
sites.RecordingID=string(rec);sites.SiteID=1;sites.FrameSize={[48 48]};sites.NFrames=30;sites.SampleF=1;sites=sites([],:);
events=table(strings(0,1),zeros(0,1),zeros(0,1),zeros(0,1),zeros(0,1),zeros(0,1),strings(0,1),zeros(0,1),zeros(0,1), ...
    'VariableNames',{'RecordingID','SinkID','EventID','StartFrame','EndFrame','BaselineValue','BaselineStatus','BaselineValidSamples','NormOxySinkAmp'});
events.Condition=strings(0,1);
surges=renamevars(events,{'SinkID','NormOxySinkAmp'},{'SurgeID','NormOxySurgeAmp'});
AnalysisInfo=struct('RawFile',fullfile(rec,'raw.tif'),'RawSHA256',Request.InputReview.RawSHA256,'NFrames',30, ...
    'FrameSize',[48 48],'DenoisedFile','','DenoisedSHA256','','AnalysisParams',Request.AnalysisParams, ...
    'BOISupportProfile','whole-image','RecordingID',rec);
Table_OxygenSinks_Out=sites;Table_OxygenSinkEvents_Out=events;Table_OxygenSurges_Out=sites;Table_OxygenSurgeEvents_Out=surges;
sinkFolder=fullfile(rec,'OxygenSinks_Output_fixture');surgeFolder=fullfile(rec,'OxygenSurges_fixture');mkdir(sinkFolder);mkdir(surgeFolder);
masters={fullfile(sinkFolder,'OxygenSinks_Urefined.mat'),fullfile(surgeFolder,'OxygenSurges.mat')};
save(masters{1},'AnalysisInfo','Table_OxygenSinks_Out','Table_OxygenSinkEvents_Out');
save(masters{2},'AnalysisInfo','Table_OxygenSurges_Out','Table_OxygenSurgeEvents_Out');
D=struct('RecordingFolder',rec,'ReviewRaw',raw,'IM_Notrend',single(raw),'IM_Zframetime_smoothed',single(raw), ...
    'Table_OxygenSinks_Out',sites,'Table_OxygenSinkEvents_Out',events,'Table_OxygenSurges_Out',sites,'Table_OxygenSurgeEvents_Out',surges, ...
    'Mean_OxySink_TraceZ',zeros(0,30),'Mean_OxySink_Trace_Convo',zeros(0,30),'Mean_OxySurge_TraceZ',zeros(0,30));
captureBOIRunReview(D,AnalysisInfo,masters);save(fullfile(folder,'RunRequest.mat'),'Request');
roles={'Request','EventAudit','SinkMaster','SurgeMaster','DataOutput','Workbook','AnalysisManifest','AuditReceipt','CodeManifest'};
paths={'RunRequest.mat',fullfile('Recording','BOIReview','event-amplitude-audit.mat'), ...
    fullfile('Recording','OxygenSinks_Output_fixture','OxygenSinks_Urefined.mat'),fullfile('Recording','OxygenSurges_fixture','OxygenSurges.mat'), ...
    'data.mat','workbook.txt','analysis.json',fullfile('Recording','BOIReview','AuditCreationReceipt.json'),'code.csv'};
for k=[5 6 7 9],writeBOIRunJSON(fullfile(folder,paths{k}),struct('Synthetic',true));end
artifacts=struct('Role',{},'Path',{},'SHA256',{});
for k=1:numel(roles),artifacts(k)=struct('Role',roles{k},'Path',paths{k},'SHA256',oxygenFileSHA256(fullfile(folder,paths{k})));end
Run=struct('Schema','boi-recording-run-1','Status','complete','SourceSHA256',Request.InputReview.RawSHA256, ...
    'SupportProfile','whole-image','Artifacts',artifacts);save(fullfile(folder,'BOIRun.mat'),'Run');
writeBOIRunJSON(fullfile(folder,'RunStatus.json'),struct('Status','complete'));
end
