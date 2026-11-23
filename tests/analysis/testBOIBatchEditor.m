function tests=testBOIBatchEditor
% Bounded batch-preparation and GUI checks. No detector/statistics engine runs.
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function test01PathsOnlyDraft(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
b=createBOIBatch(table(string(o.RecordingFolder),'VariableNames',{'Paths'}));
[checked,r,q]=checkBOIBatch(b);
verifyEqual(t,r.InputStatus,"Needs attention");verifyEmpty(t,q{1});
verifyTrue(t,contains(r.Message,'sampling rate'));verifyEqual(t,checked.Rows.AnalysisStatus,"Not analyzed");
path=fullfile(root,'draft.csv');b=writeBOIBatchCSV(b,path);read=readBOIBatchCSV(path);
verifyEqual(t,read.Rows.Paths,b.Rows.Paths);verifyEqual(t,read.Rows.SampleF,"");
verifyFalse(t,isfolder(o.OutputFolder));
end
function test02MinimalCSVAndAdapter(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
b=batchFor(o);[b,r,q]=checkBOIBatch(b);
verifyEqual(t,r.InputStatus,"Ready");verifyNotEmpty(t,q{1});
verifyEqual(t,q{1}.AnalysisParams,createOxygenMasterParams(o.PixelSizeUm,o.SampleHz));
[rows,origins]=resolveBOIBatch(b);
[request,legacy,metadata]=prepareBOIBatchRow(rows,o.OutputFolder,origins);
verifyEqual(t,request.Options.Mouse,'unspecified');verifyTrue(t,isnan(legacy.WhiskingFile));
verifyEqual(t,width(legacy),14);verifyEqual(t,metadata.BatchRowID,char(b.Rows.BatchRowID));
verifyFalse(t,isfolder(o.OutputFolder));
end
function test03LegacyAndCollisionHandling(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
b=batchFor(o);names={'PostureFile','PupilFile','PuffsFile','WhiskingFile','AmyloidFile','Puff_2use'};
for k=1:numel(names),b.Rows.(names{k})="NaN";end
b.Rows.Mouse="0012";b.Rows.Genotype="";
b.Rows.PuffsFile="  stimulation, ÆØÅ ""source"".mat  ";b.Rows.Puff_2use="0007";
identity=b.Rows.BatchRowID;stimulationPath=b.Rows.PuffsFile;
path=fullfile(root,'legacy.csv');writeBOIBatchCSV(b,path);read=readBOIBatchCSV(path);
[checked,r,q]=checkBOIBatch(read);verifyEqual(t,r.InputStatus,"Ready");verifyEqual(t,read.Rows.Mouse,"0012");
verifyEqual(t,read.Rows.BatchRowID,identity);verifyEqual(t,checked.Rows.PuffsFile,stimulationPath);
verifyEqual(t,checked.Rows.Puff_2use,"0007");verifyTrue(t,contains(r.Message,'ignored for BOI analysis'));
verifyNotEmpty(t,q{1});verifyFalse(t,any(isfield(q{1}.Options,{'PuffsFile','Puff_2use'})));
[rows,origins]=resolveBOIBatch(checked);
[request,legacy,metadata]=prepareBOIBatchRow(rows,o.OutputFolder,origins);
verifyTrue(t,isnan(legacy.PuffsFile));verifyTrue(t,isnan(legacy.Puff_2use));
verifyFalse(t,any(isfield(request.Options,{'PuffsFile','Puff_2use'})));verifyTrue(t,isnan(request.Context.Puff));
verifyEqual(t,string(metadata.Values{strcmp(metadata.Names,'PuffsFile')}),stimulationPath);
verifyEqual(t,string(metadata.Values{strcmp(metadata.Names,'Puff_2use')}),"0007");
verifyEqual(t,metadata.BatchRowID,char(identity));verifyFalse(t,isfolder(o.OutputFolder));
for field={'PostureFile','PupilFile','WhiskingFile','AmyloidFile'}
    held=read;held.Rows.(field{1})="configured.mat";[~,r,q]=checkBOIBatch(held);
    verifyEqual(t,r.InputStatus,"Needs attention");verifyTrue(t,contains(r.Message,'legacy workflow'));
    verifyTrue(t,contains(r.Message,field{1}));verifyEmpty(t,q{1});
end
bad=b.Rows;bad.samplef="3";
verifyError(t,@()createBOIBatch(bad),'OxygenDynamics:BatchColumnCollision');
bad=[b.Rows;b.Rows];verifyError(t,@()createBOIBatch(bad),'OxygenDynamics:BatchDuplicateRowID');
duplicate=fullfile(root,'duplicate.csv');fid=fopen(duplicate,'wb');
fprintf(fid,'Paths,BatchRowID,Mouse,RunFolder,AnalysisStatus\nsource,copy,0012,saved,Complete\nother,copy,0007,other-saved,Complete\n');fclose(fid);
original=fileread(duplicate);
verifyError(t,@()readBOIBatchCSV(duplicate),'OxygenDynamics:BatchDuplicateRowID');
recovered=readBOIBatchCSV(duplicate,'new-copies');
verifyNotEqual(t,recovered.Rows.BatchRowID(1),recovered.Rows.BatchRowID(2));
verifyEqual(t,recovered.Rows.Mouse,["0012";"0007"]);verifyEqual(t,recovered.Rows.RunFolder(2),"");
verifyEqual(t,recovered.Rows.AnalysisStatus(2),"Not analyzed");verifyEqual(t,fileread(duplicate),original);
verifyNotEmpty(t,recovered.ImportNotice);
end
function test04SharedValuesOverridesAndSaveAs(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
b=createBOIBatch(table(["source";"source"],'VariableNames',{'Paths'}),root);
b.Shared=struct('SampleF','2','Pixelsize','4.75','BOISupportProfile','whole-image');
[resolved,origins]=resolveBOIBatch(b);verifyEqual(t,resolved.SampleF,["";""]);verifyEqual(t,origins.SampleF,["missing";"missing"]);
b.SharedConfirmed=true;b.Rows.SampleF(2)="3";
[resolved,origins]=resolveBOIBatch(b);verifyEqual(t,resolved.SampleF,["2";"3"]);verifyEqual(t,origins.SampleF,["shared";"row"]);
sub=fullfile(root,'other');mkdir(sub);b=writeBOIBatchCSV(b,fullfile(sub,'batch.csv'));
verifyEqual(t,b.BaseFolder,sub);verifyEqual(t,b.Rows.Paths,repmat(string(o.RecordingFolder),2,1));
read=readBOIBatchCSV(b.FilePath);[again,originAgain]=resolveBOIBatch(read);
verifyEqual(t,again.SampleF,resolved.SampleF);verifyEqual(t,originAgain.SampleF,origins.SampleF);
verifyEqual(t,read.Rows.SampleF,["";"3"]);
% A later pasted relative path belongs to the new CSV directory.
new=createBOIBatch(table("new-source",'VariableNames',{'Paths'}),b.BaseFolder);
resolvedNew=resolveBOIBatch(new);verifyEqual(t,resolvedNew.Paths,string(fullfile(sub,'new-source')));
empty=createBOIBatch();empty.Shared=b.Shared;empty.SharedConfirmed=true;
verifyError(t,@()writeBOIBatchCSV(empty,fullfile(root,'empty-shared.csv')),'OxygenDynamics:BatchCSVWrite');
end
function test05MetadataReorderAndGUI(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
b=batchFor(o);b.Rows.Mouse="0012";b.Rows.Condition="";
b.Rows.('Lab notes')="comma, quote "" and ÆØÅ"+newline+"second line";
[fig,ui]=openBOIBatchEditor(b);closeFig=onCleanup(@()delete(fig));
ui.AddPaths("other-source");ui.AddColumn('Session');ui.ApplyMetadata('Session',"0007",2);
ui.SelectRows(2);ui.MoveRows(-1);b=ui.GetBatch();
verifyEqual(t,b.Rows.Session(1),"0007");verifyEqual(t,b.Rows.Mouse(2),"0012");
id=b.Rows.BatchRowID(2);ui.SelectRows(2);ui.Edit(2,'Notes',"Optional note");
verifyEqual(t,ui.GetBatch().Rows.BatchRowID(2),id);
path=fullfile(root,'metadata.csv');ui.Save(path);ui.Open(path);b=ui.GetBatch();
verifyEqual(t,b.Rows.Mouse(2),"0012");verifyEqual(t,b.Rows.Condition(2),"");
verifyEqual(t,b.Rows.('Lab notes')(2),"comma, quote "" and ÆØÅ"+newline+"second line");
verifyEqual(t,b.Rows.Session(1),"0007");verifyEmpty(t,ui.State().Requests);
ui.SetShared(struct('SampleF','2','Pixelsize','4.75','BOISupportProfile','whole-image'),true);
ui.ResetToShared(2);ui.Check();verifyEqual(t,ui.State().Report.InputStatus(2),"Ready");
verifyTrue(t,any(string(ui.SupportProfile.Items)=="Automatic tissue estimate"));
ui.SelectRows(2);detailText=strjoin(string(ui.Details.Value),newline);
verifyTrue(t,contains(detailText,'Mouse: 0012'));
state=ui.State();qc=state.Requests{2}.InputReview.QC;
for qi=1:height(qc),verifyTrue(t,contains(detailText,qc.Message(qi)));end
ui.Edit(2,'Pixelsize','5');verifyEmpty(t,ui.State().Requests);
verifyEqual(t,ui.GetBatch().Rows.InputStatus(2),"Unchecked");
broken=ui.GetBatch();broken.Rows.BatchRowID(:)="duplicate";ui.SetBatch(broken);
verifyError(t,@()ui.Check(),'OxygenDynamics:BatchDuplicateRowID');verifyFalse(t,ui.State().Busy);
end
function test06MissingSourceAndDuplicateRows(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
b=batchFor(o);b.Rows=[b.Rows;b.Rows];b.Rows.BatchRowID(2)=string(char(java.util.UUID.randomUUID()));
third=b.Rows(1,:);third.BatchRowID=string(char(java.util.UUID.randomUUID()));third.Paths=string(fullfile(root,'absent'));
b.Rows=[b.Rows;third];[~,r,q]=checkBOIBatch(b);
verifyEqual(t,r.InputStatus,repmat("Needs attention",3,1));verifyTrue(t,contains(r.Message(1),'duplicate'));
verifyTrue(t,contains(r.Message(3),'unavailable'));verifyTrue(t,all(cellfun(@isempty,q)));
end
function test07CalibrationAndSourceBoundSupport(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
b=batchFor(o);b.Rows.SampleF="0";[~,r]=checkBOIBatch(b);verifyEqual(t,r.InputStatus,"Needs attention");
b.Rows.SampleF="2";b.Rows.BOISupportProfile="craniotomy-roi-1";
[~,r]=checkBOIBatch(b);verifyEqual(t,r.InputStatus,"Needs attention");verifyTrue(t,contains(r.Message,'support','IgnoreCase',true));
declaration=struct('Schema','boi-static-tissue-support-1','Modality','BOI', ...
    'RawSHA256',oxygenFileSHA256(fullfile(o.RecordingFolder,'raw.tif')),'FrameSize',[48 48], ...
    'IndexConvention','MATLAB_one_based_column_major_row_column','MaskPixels',(1:48*48)', ...
    'ReviewStatus','reviewed_for_static_support','DecisionID','batch-test','Actor','synthetic fixture', ...
    'Reason','software check','Evidence','synthetic','AlignmentEvidence','same grid','RecordedUTC','2026-10-14T00:00:00Z');
writeBOIRunJSON(fullfile(o.RecordingFolder,'BOITissueSupport.json'),declaration);
[~,r]=checkBOIBatch(b);verifyEqual(t,r.InputStatus,"Ready");
declaration.RawSHA256=repmat('0',1,64);writeBOIRunJSON(fullfile(o.RecordingFolder,'BOITissueSupport.json'),declaration);
[~,r]=checkBOIBatch(b);verifyEqual(t,r.InputStatus,"Needs attention");
end
function test08VerifiedFailedAndIncompleteDisplay(t)
[path,root,o]=savedFixture();cleanup=onCleanup(@()rmdir(root,'s'));
b=batchFor(o);b.Rows.RunFolder=string(root);b.Rows.AnalysisStatus="Complete";
[b,r]=checkBOIBatch(b);verifyEqual(t,r.AnalysisStatus,"Complete");verifyEqual(t,r.ResultCheck,"Matches");
verifyEqual(t,b.Rows.ReviewStatus,"Not reviewed");
[fig,ui]=openBOIBatchEditor(b);closeFig=onCleanup(@()delete(fig));
ui.AttachRun(1,path);ui.SelectRows(1);[runFig,runUI]=ui.OpenRun();closeRun=onCleanup(@()delete(runFig));
verifyEqual(t,runUI.State().SelectedRun.ManifestPath,path);
verifyEqual(t,ui.State().Report.ResultCheck,"Matches");
writeBOIRunJSON(fullfile(root,'RunStatus.json'),struct('Status','failed','Stage','staging','ErrorID','Test:Failure','ErrorMessage','Synthetic saved failure'));
[~,r]=checkBOIBatch(b);verifyEqual(t,r.AnalysisStatus,"Failed");verifyTrue(t,contains(r.Message,'Test:Failure'));
writeBOIRunJSON(fullfile(root,'RunStatus.json'),struct('Status','running','Stage','analysis'));
[~,r]=checkBOIBatch(b);verifyEqual(t,r.AnalysisStatus,"Incomplete");verifyTrue(t,contains(r.Message,'liveness'));
writeBOIRunJSON(fullfile(root,'RunStatus.json'),struct('Status','interrupted'));
[~,r]=checkBOIBatch(b);verifyEqual(t,r.AnalysisStatus,"Interrupted");
delete(fullfile(root,'RunRequest.mat'));
[~,r]=checkBOIBatch(b);verifyEqual(t,r.AnalysisStatus,"Incomplete");verifyEqual(t,r.ResultCheck,"Unavailable");
verifyTrue(t,isfile(path));
end
function test09ChangedInputsMetadataAndArtifacts(t)
[~,root,o]=savedFixture();cleanup=onCleanup(@()rmdir(root,'s'));
b=batchFor(o);b.Rows.RunFolder=string(root);b.Rows.SampleF="2";
[~,r]=checkBOIBatch(b);verifyEqual(t,r.ResultCheck,"Changed");
b.Rows.SampleF="1";b.Rows.Mouse="Edited subject";b.Rows.Notes="Added later";
[~,r]=checkBOIBatch(b);verifyEqual(t,r.ResultCheck,"Matches");verifyTrue(t,contains(r.MetadataStatus,'Metadata changed since run'));
verifyTrue(t,contains(r.MetadataStatus,'not captured'));
q=load(fullfile(root,'RunRequest.mat'),'Request');verifyEqual(t,q.Request.Options.Mouse,'unspecified');
% A different TIFF source cannot silently reuse an old completion.
sourceHash=oxygenFileSHA256(fullfile(root,'raw.tif'));imwrite(uint16(99*ones(4,5)),fullfile(root,'raw.tif'));
[~,r]=checkBOIBatch(b);verifyNotEqual(t,r.ResultCheck,"Matches");
verifyNotEqual(t,oxygenFileSHA256(fullfile(root,'raw.tif')),sourceHash);
writeBOIRunJSON(fullfile(root,'workbook.txt'),struct('Changed',true));
[~,r]=checkBOIBatch(b);verifyEqual(t,r.AnalysisStatus,"Incomplete");verifyEqual(t,r.ResultCheck,"Changed");
end
function test10WriteFailureExternalEditAndBackups(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
b=batchFor(o);path=fullfile(root,'batch.csv');[b,backup]=writeBOIBatchCSV(b,path);
verifyEqual(t,backup,'');before=fileread(path);b.Rows.Mouse="0004";
[b,backup]=writeBOIBatchCSV(b,path);verifyEqual(t,fileread(backup),before);
verifyEqual(t,readBOIBatchCSV(path).Rows.Mouse,"0004");
fid=fopen(path,'ab');fwrite(fid,uint8(10));fclose(fid);external=fileread(path);
verifyError(t,@()writeBOIBatchCSV(b,path),'OxygenDynamics:BatchCSVConflict');verifyEqual(t,fileread(path),external);
verifyError(t,@()writeBOIBatchCSV(b,fullfile(root,'absent','batch.csv')),'OxygenDynamics:BatchCSVWrite');
recovered=fullfile(root,'recovered.csv');writeBOIBatchCSV(b,recovered);verifyTrue(t,isfile(recovered));
mkdir([recovered '.boi-write-lock']);other=readBOIBatchCSV(recovered);
verifyError(t,@()writeBOIBatchCSV(other,recovered),'OxygenDynamics:BatchCSVConflict');
rmdir([recovered '.boi-write-lock']);verifyFalse(t,isfolder([path '.boi-write-lock']));
end
function test11SelectedCheckPreservesUnrelatedRows(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
b=batchFor(o);other=b.Rows;other.BatchRowID=string(char(java.util.UUID.randomUUID()));
other.Paths=string(fullfile(root,'unavailable'));other.RunFolder="unread-saved-run";
other.InputStatus="Ready";other.AnalysisStatus="Complete";other.ResultCheck="Matches";
other.Message="Unrelated row must remain untouched";other.AttemptHistory="not valid history";
b.Rows=[b.Rows;other];events={};
[checked,r,q]=checkBOIBatch(b,b.Rows.BatchRowID(1),@observe);
verifyEqual(t,r.InputStatus,["Ready";"Unchecked"]);
verifyEqual(t,r.AnalysisStatus(2),"Unchecked");verifyEqual(t,checked.Rows(2,:),other);
verifyNotEmpty(t,q{1});verifyEmpty(t,q{2});verifyNotEmpty(t,events);
verifyTrue(t,all(cellfun(@(e)e.RowIndex==1&&e.CheckCount==1&&e.BatchCount==2,events)));
verifyError(t,@()checkBOIBatch(b,"absent-id"),'OxygenDynamics:BatchCheckSelection');
verifyError(t,@()checkBOIBatch(b,[b.Rows.BatchRowID(1);b.Rows.BatchRowID(1)]), ...
    'OxygenDynamics:BatchCheckSelection');
    function observe(event)
        events{end+1}=event;
    end
end
function test12SelectedCheckRetainsGlobalDuplicateGuard(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
b=batchFor(o);other=b.Rows;other.BatchRowID=string(char(java.util.UUID.randomUUID()));b.Rows=[b.Rows;other];
[checked,r,q]=checkBOIBatch(b,b.Rows.BatchRowID(1));
verifyEqual(t,r.InputStatus,["Needs attention";"Unchecked"]);
verifyTrue(t,contains(r.Message(1),'duplicate'));verifyEmpty(t,q{1});verifyEmpty(t,q{2});
verifyEqual(t,checked.Rows(2,:),b.Rows(2,:));
end
function test13ProgressPreservesResultsAndReportsStages(t)
[~,root,o]=savedFixture();cleanup=onCleanup(@()rmdir(root,'s'));
b=batchFor(o);b.Rows.RunFolder=string(root);other=b.Rows;
other.BatchRowID=string(char(java.util.UUID.randomUUID()));other.Paths=string(fullfile(root,'missing'));
other.RunFolder="";b.Rows=[b.Rows;other];events={};
[plain,rPlain,qPlain]=checkBOIBatch(b);
[progress,rProgress,qProgress]=checkBOIBatch(b,[],@observe);
verifyEqual(t,progress,plain);verifyEqual(t,rProgress,rPlain);
verifyEqual(t,qProgress{1}.Sources,qPlain{1}.Sources);
verifyEqual(t,qProgress{1}.AnalysisParams,qPlain{1}.AnalysisParams);
verifyEmpty(t,qProgress{2});verifyEqual(t,rProgress.AnalysisStatus(1),"Complete");
stages=string(cellfun(@(e)e.Stage,events,'UniformOutput',false));
verifyTrue(t,any(stages=="source")&&any(stages=="saved-result"));
verifyEqual(t,sum(stages=="complete"),2);
fraction=cellfun(@(e)(e.CheckIndex-1+e.Fraction)/e.CheckCount,events);
verifyTrue(t,all(diff(fraction)>=0));verifyEqual(t,fraction(1),0);verifyEqual(t,fraction(end),1);
verifyError(t,@()checkBOIBatch(b,[],@failProgress),'Test:BatchProgressFailure');
verifyFalse(t,isfolder(o.OutputFolder));
    function observe(event)
        events{end+1}=event;
    end
    function failProgress(~)
        error('Test:BatchProgressFailure','Synthetic read-only progress interruption.');
    end
end
function test14GUIOpensOnlySelectedSavedRecording(t)
[path,root,o]=savedFixture();cleanup=onCleanup(@()rmdir(root,'s'));
b=batchFor(o);b.Rows.RunFolder=string(root);other=b.Rows;
other.BatchRowID=string(char(java.util.UUID.randomUUID()));other.Paths=string(fullfile(root,'not-readable'));
other.RunFolder="not-readable-run";other.AttemptHistory="not valid history";b.Rows=[b.Rows;other];
[fig,ui]=openBOIBatchEditor(b);closeFig=onCleanup(@()delete(fig));ui.SelectRows(1);
before=ui.GetBatch().Rows(2,:);verifyEqual(t,string(ui.OpenRunButton.Enable),"on");
[savedFig,savedUI]=ui.OpenRun();closeSaved=onCleanup(@()delete(savedFig));
verifyEqual(t,savedUI.State().SelectedRun.ManifestPath,path);verifyEqual(t,string(savedUI.RunButton.Enable),"off");
verifyEqual(t,ui.State().Report.ResultCheck(1),"Matches");
verifyEqual(t,ui.State().Report.InputStatus(2),"Unchecked");verifyEqual(t,ui.GetBatch().Rows(2,:),before);
verifyEmpty(t,ui.State().Requests{2});verifyEqual(t,ui.State().CheckProgress.CheckCount,1);
verifyEmpty(t,ui.CheckDialog());verifyFalse(t,ui.State().Busy);
ui.SelectRows(2);columns=string(ui.Table.ColumnName);data=ui.Table.Data;
verifyEqual(t,string(data{2,columns=="Analysis status"}),"Check saved run");
verifyEqual(t,string(ui.OpenRunButton.Enable),"on");
end
function test15GUISelectedOpeningRejectsChangedInputsAndArtifacts(t)
for change=1:3
    [~,root,o]=savedFixture();cleanup=onCleanup(@()rmdir(root,'s'));
    b=batchFor(o);b.Rows.RunFolder=string(root);
    if change==1
        fid=fopen(fullfile(root,'raw.tif'),'ab');fwrite(fid,uint8(0));fclose(fid);
    elseif change==2
        b.Rows.Pixelsize="2";
    else
        writeBOIRunJSON(fullfile(root,'workbook.txt'),struct('Changed',true));
    end
    [fig,ui]=openBOIBatchEditor(b);closeFig=onCleanup(@()delete(fig));ui.SelectRows(1);
    verifyError(t,@()ui.OpenRun(),'OxygenDynamics:BatchRunUnverified');
    verifyNotEqual(t,ui.State().Report.ResultCheck,"Matches");
    verifyFalse(t,ui.State().Busy);verifyEmpty(t,ui.CheckDialog());
    verifyFalse(t,isfolder(o.OutputFolder));clear closeFig cleanup
end
end
function test16GUIProgressBusyProtectionAndRecovery(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
b=batchFor(o);other=b.Rows;other.BatchRowID=string(char(java.util.UUID.randomUUID()));
other.Paths=string(fullfile(root,'missing'));b.Rows=[b.Rows;other];
[fig,ui]=openBOIBatchEditor(b);closeFig=onCleanup(@()delete(fig));observed={};busyError="";
watch=timer('Name','BOIBatchGUIPolishProgressTest','ExecutionMode','fixedSpacing','Period',0.01,'TimerFcn',@observe);
closeWatch=onCleanup(@()delete(watch));start(watch);
try
    ui.Check();
catch err
    clear closeWatch
    rethrow(err);
end
stop(watch);clear closeWatch
verifyNotEmpty(t,observed);verifyEqual(t,busyError,"OxygenDynamics:BatchBusy");
verifyTrue(t,all(cellfun(@(x)x.Busy&&strcmp(x.CheckButton,'off')&& ...
    contains(x.Title,'Checking recording')&&contains(x.Message,'No analysis is running'),observed)));
verifyFalse(t,ui.State().Busy);verifyEmpty(t,ui.CheckDialog());
verifyEqual(t,ui.State().CheckProgress.CheckCount,2);verifyEqual(t,string(ui.CheckButton.Enable),"on");
verifyError(t,@()ui.Check("absent-id"),'OxygenDynamics:BatchCheckSelection');
verifyFalse(t,ui.State().Busy);verifyEmpty(t,ui.CheckDialog());
ui.SetBatch(b);ui.Check(b.Rows.BatchRowID(1));
verifyEqual(t,ui.State().Report.InputStatus(2),"Unchecked");
ui.SelectReady();verifyEqual(t,ui.State().CheckProgress.CheckCount,2);
verifyEqual(t,ui.State().Report.InputStatus,["Ready";"Needs attention"]);
ui.Save(fullfile(root,'batch.csv'));parent=fullfile(root,'results');mkdir(parent);
ui.SelectRows(1);plan=ui.ReviewQueue(parent);
verifyEqual(t,plan.Counts.Run,1);verifyEqual(t,plan.Counts.NotSelected,1);
verifyEqual(t,ui.State().CheckProgress.CheckCount,2);verifyEmpty(t,ui.CheckDialog());
verifyFalse(t,ui.State().Busy);verifyFalse(t,ui.State().QueueConfirmed);
verifyEqual(t,string(ui.RunQueueButton.Enable),"on");verifyEqual(t,string(ui.RunQueueButton.Text),"Start 1 recording");
ui.SelectRows(2);excludedPlan=ui.ReviewQueue(parent);
verifyEqual(t,excludedPlan.Counts.Excluded,1);
verifyEqual(t,string(ui.QueuePreview.Text),"0 to start · 0 skipped · 1 excluded");
verifyEqual(t,string(ui.RunQueueButton.Enable),"off");
verifyError(t,@()ui.ReviewQueue(fullfile(root,'missing-output')),'OxygenDynamics:InvalidBatchQueue');
verifyFalse(t,ui.State().Busy);verifyEmpty(t,ui.CheckDialog());
clear closeFig cleanup
    function observe(~,~)
        state=ui.State();dialog=ui.CheckDialog();
        if isempty(state.CheckProgress)||isempty(dialog)||~isvalid(dialog),return;end
        observed{end+1}=struct('Busy',state.Busy,'CheckButton',ui.CheckButton.Enable, ...
            'Title',dialog.Title,'Message',dialog.Message);
        try
            ui.Edit(1,'Notes','must stay blocked');
        catch err,busyError=string(err.identifier);
        end
    end
end
function test17ImportSetupFillsOnlyMissingSettings(t)
root=tempname;
mkdir(root);
cleanup=onCleanup(@()rmdir(root,'s'));
paths=fullfile(string(root),["recording-a";"recording-b";"recording-c"]);
for k=1:numel(paths),mkdir(paths(k));end
rows=table(paths,["";"3";""],["2.35";"";""],["whole-image";"craniotomy-roi-1";""], ...
    ["0010";"0011";"0012"],'VariableNames',{'Paths','SampleF','Pixelsize','BOISupportProfile','Mouse'});
batch=createBOIBatch(rows,root);
batch.Shared.SampleF='1.5';
batch.SharedConfirmed=true;
source=fullfile(root,'import.csv');
writeBOIBatchCSV(batch,source);
original=fileread(source);
[fig,ui]=openBOIBatchEditor(source);
closeFig=onCleanup(@()delete(fig));
verifyEqual(t,ui.Tabs.SelectedTab,ui.ImportTab);
verifyEqual(t,string(ui.ImportRate.Enable),"off");
verifyEqual(t,string(ui.ImportPixelSize.Enable),"on");
verifyEqual(t,string(ui.SupportProfile.Value),"whole-image");

before=ui.GetBatch();
[~,report]=checkBOIBatch(before,before.Rows.BatchRowID(2));
verifyTrue(t,contains(report.Message(2),"Missing pixel size."));
verifyFalse(t,contains(report.Message(2),"detection support"));
ui.ImportPixelSize.Value='-2';
ui.ApplyImportSettingsButton.ButtonPushedFcn(ui.ApplyImportSettingsButton,[]);
verifyEqual(t,ui.GetBatch().Rows,before.Rows);
verifyTrue(t,contains(string(ui.ImportFeedback.Text),"pixel",'IgnoreCase',true));
verifyEqual(t,fileread(source),original);

ui.ImportPixelSize.Value='';
ui.ApplyImportSettingsButton.ButtonPushedFcn(ui.ApplyImportSettingsButton,[]);
verifyEqual(t,ui.GetBatch().Rows,before.Rows);
verifyFalse(t,ui.State().Dirty);
verifyEqual(t,fileread(source),original);

ui.Open(source);
verifyEqual(t,ui.Tabs.SelectedTab,ui.ImportTab);
verifyEqual(t,ui.GetBatch().Rows.BOISupportProfile,rows.BOISupportProfile);
ui.ImportPixelSize.Value='4.75';
ui.ApplyImportSettingsButton.ButtonPushedFcn(ui.ApplyImportSettingsButton,[]);
draft=ui.GetBatch();
[resolved,origins]=resolveBOIBatch(draft);
verifyEqual(t,resolved.SampleF,["1.5";"3";"1.5"]);
verifyEqual(t,origins.SampleF,["shared";"row";"shared"]);
verifyEqual(t,resolved.Pixelsize,["2.35";"4.75";"4.75"]);
verifyEqual(t,resolved.BOISupportProfile,["whole-image";"craniotomy-roi-1";"whole-image"]);
verifyEqual(t,origins.BOISupportProfile,["row";"row";"default"]);
verifyEqual(t,draft.Rows.Mouse,rows.Mouse);
verifyEqual(t,draft.Rows.BatchRowID,batch.Rows.BatchRowID);
verifyEqual(t,draft.Rows.AnalysisStatus,repmat("Not analyzed",3,1));
verifyEqual(t,draft.Rows.RunFolder,repmat("",3,1));
verifyEmpty(t,ui.State().Report);
verifyEmpty(t,ui.State().Requests);
verifyEmpty(t,ui.State().QueuePlan);
verifyEqual(t,string(ui.RunQueueButton.Enable),"off");
verifyTrue(t,ui.State().Dirty);
verifyEqual(t,fileread(source),original);

copy=fullfile(root,'configured.csv');
ui.Save(copy);
ui.Open(copy);
[reopened,reopenedOrigins]=resolveBOIBatch(ui.GetBatch());
verifyEqual(t,reopened(:,{'BatchRowID','SampleF','Pixelsize','BOISupportProfile'}), ...
    resolved(:,{'BatchRowID','SampleF','Pixelsize','BOISupportProfile'}));
verifyEqual(t,reopenedOrigins,origins);
verifyEqual(t,fileread(source),original);
end
function test18ImportSetupMapsForeignRoot(t)
root=tempname;mkdir(root);cleanup=onCleanup(@()rmdir(root,'s'));
local=fullfile(root,'local recordings');mkdir(local);
recording=fullfile(local,'mouse-a');mkdir(recording);
if ispc,foreign='/Volumes/research/recordings';
else,foreign='D:\recordings';end
if ispc,filePath=[foreign '/mouse-a'];else,filePath=[foreign '\mouse-a'];end
source=fullfile(root,'foreign.csv');
writelines(["Paths,SampleF,Pixelsize,BOISupportProfile";string(filePath)+",1,2.35,whole-image"],source);
original=fileread(source);
[fig,ui]=openBOIBatchEditor(source);closeFig=onCleanup(@()delete(fig));
verifyEqual(t,ui.Tabs.SelectedTab,ui.ImportTab);
verifyEqual(t,ui.GetBatch().Rows.Paths,string(filePath));
verifyEqual(t,string(ui.ApplyImportSettingsButton.Enable),"off");
verifyNotEmpty(t,ui.ImportPrefix.Value);
ui.MapImportPaths(foreign,local);
verifyEqual(t,ui.GetBatch().Rows.Paths,string(char(java.io.File(recording).getCanonicalPath())));
verifyEqual(t,ui.GetBatch().Rows.BOISupportProfile,"whole-image");
verifyTrue(t,ui.State().Dirty);
verifyEmpty(t,ui.State().QueuePlan);
verifyEqual(t,fileread(source),original);
end
function test19StableRecordingListAcrossTabs(t)
root=tempname;mkdir(root);cleanup=onCleanup(@()rmdir(root,'s'));
source=fullfile(root,'recordings.csv');
writelines(["Paths,SampleF,Pixelsize,Mouse";"Data/one,1,2.35,FB01";"Data/two,1,2.35,FB02"],source);
[fig,ui]=openBOIBatchEditor(source);closeFig=onCleanup(@()delete(fig));
verifyEqual(t,string(ui.Tabs.SelectedTab.Title),"Recording details");
verifyEqual(t,string(ui.SupportProfile.Value),"whole-image");
verifyFalse(t,ui.SharedConfirmed.Value);
verifyTrue(t,any(strcmp(ui.Table.Data(:),'Automatic (default)')));
ui.SelectRows(2);
% UI figure layout is reported asynchronously by the desktop renderer.
for attempt=1:40
    drawnow;
    if ui.Table.Position(3)>fig.Position(3)-50&&ui.Tabs.Position(3)>fig.Position(3)-50,break;end
    pause(0.05);
end
rowBounds=ui.Table.Position;
tabBounds=ui.Tabs.Position;
assertGreaterThan(t,rowBounds(3),fig.Position(3)-50);
assertGreaterThan(t,tabBounds(3),fig.Position(3)-50);
verifyGreaterThan(t,rowBounds(4),100);
verifyGreaterThan(t,tabBounds(4),250);
for tab=reshape(ui.Tabs.Children,1,[])
    previous=ui.Tabs.SelectedTab;
    ui.Tabs.SelectedTab=tab;
    action=ui.Tabs.SelectionChangedFcn;
    if isa(action,'function_handle'),action(ui.Tabs,struct('OldValue',previous,'NewValue',tab));end
    drawnow;
    verifyEqual(t,string(ui.Table.Visible),"on");
    verifyEqual(t,ui.Table.Position,rowBounds,'AbsTol',1);
    verifyEqual(t,ui.Tabs.Position,tabBounds,'AbsTol',1);
    verifyEqual(t,ui.State().SelectedRows,2);
end
end
function test20ImportedCSVProtectedUntilSeparateWorkingSave(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
source=fullfile(root,'recordings.csv');
prior=fullfile(root,'prior');mkdir(prior);
file=fopen(source,'wb');
fprintf(file,['Paths,BatchRowID,SampleF,Pixelsize,BOISupportProfile,Mouse,RunFolder\n' ...
    '"%s",row-20,%g,%g,%s,0012,prior\n'],o.RecordingFolder,o.SampleHz,o.PixelSizeUm,o.SupportProfile);
fclose(file);
sourceHash=oxygenFileSHA256(source);
parent=fullfile(root,'results');mkdir(parent);
[fig,ui]=openBOIBatchEditor(source);closeFig=onCleanup(@()delete(fig));
verifyTrue(t,contains(ui.FileLabel.Text,'Imported CSV'));
verifyFalse(t,ui.GetBatch().WorkingCSV);
verifyEqual(t,ui.Check().InputStatus,"Ready");
ui.SelectRows(1);
verifyError(t,@()ui.ReviewQueue(fullfile(root,'absent')),'OxygenDynamics:InvalidBatchQueue');
verifyEqual(t,oxygenFileSHA256(source),sourceHash);
plan=ui.ReviewQueue(parent);
verifyEqual(t,plan.Counts.Run,1);
verifyEqual(t,string(ui.RunQueueButton.Enable),"off");
verifyTrue(t,contains(ui.QueueStatus.Text,'Save as'));
verifyError(t,@()ui.ConfirmQueue(true),'OxygenDynamics:BatchWorkingCSVRequired');
verifyError(t,@()ui.StartReviewedQueue(),'OxygenDynamics:BatchWorkingCSVRequired');
verifyError(t,@()runBOIBatchQueue(ui.GetBatch(),plan),'OxygenDynamics:BatchWorkingCSVRequired');
verifyFalse(t,isfolder(plan.QueueFolder));
verifyError(t,@()ui.Save(),'OxygenDynamics:BatchImportedCSV');
verifyError(t,@()ui.Save(fullfile(root,'.','recordings.csv')),'OxygenDynamics:BatchImportedCSV');
verifyEqual(t,oxygenFileSHA256(source),sourceHash);

working=fullfile(root,'working.csv');
ui.Save(working);ui.Open(working);
verifyTrue(t,contains(ui.FileLabel.Text,'Working CSV'));
verifyTrue(t,ui.GetBatch().WorkingCSV);
verifyFalse(t,ismember('BOIBatchWorkingCSV',ui.GetBatch().Rows.Properties.VariableNames));
verifyEqual(t,ui.GetBatch().Rows.BatchRowID,"row-20");
verifyEqual(t,ui.GetBatch().Rows.RunFolder,string(char(java.io.File(prior).getCanonicalPath())));
workHash=oxygenFileSHA256(working);
ui.Edit(1,'Mouse','0050');ui.SelectRows(1);
verifyError(t,@()ui.ReviewQueue(fullfile(root,'absent')),'OxygenDynamics:InvalidBatchQueue');
plan=ui.ReviewQueue(parent);
verifyEqual(t,plan.Counts.Run,1);
verifyEqual(t,string(ui.RunQueueButton.Enable),"on");
verifyEqual(t,oxygenFileSHA256(working),workHash);
ui.Save();
verifyEqual(t,readBOIBatchCSV(working).Rows.Mouse,"0050");
verifyEqual(t,oxygenFileSHA256(source),sourceHash);
end
function [o,root]=inputFixture()
% Same finite 48 x 48 x 30 preparation recipe as testBOIRecordingWorkflow.
root=tempname;mkdir(root);source=fullfile(root,'source');mkdir(source);
for k=1:30
    frame=uint16(100*ones(48));frame(20,20)=90+k;
    if k==1,imwrite(frame,fullfile(source,'raw.tif'));else,imwrite(frame,fullfile(source,'raw.tif'),'WriteMode','append');end
end
o=struct('RecordingFolder',source,'OutputFolder',fullfile(root,'new-run'), ...
    'SampleHz',2,'PixelSizeUm',4.75,'SupportProfile','whole-image');
end
function b=batchFor(o)
b=createBOIBatch(table(string(o.RecordingFolder),string(o.SampleHz),string(o.PixelSizeUm), ...
    string(o.SupportProfile),'VariableNames',{'Paths','SampleF','Pixelsize','BOISupportProfile'}));
end
function [path,root,o]=savedFixture()
% Reuse the small saved-run/event-audit recipe in testBOIRecordingWorkflow.
root=tempname;mkdir(root);source=fullfile(root,'raw.tif');
raw=100*ones(4,5,30,'uint16');raw(1,1,7:8)=80;raw(2,1,15:16)=60;
for k=1:30
    if k==1,imwrite(raw(:,:,k),source);else,imwrite(raw(:,:,k),source,'WriteMode','append');end
end
c=cell(1,30);c(7:8)={1};c(15:16)={2};Sites=table({c},'VariableNames',{'FramePixels'});
Sites.RecordingID="R";Sites.SiteID=1;Sites.FrameSize={[4 5]};Sites.NFrames=30;Sites.SampleF=1;
E=table(["R";"R"],[1;1],[1;2],[7;15],[8;16],[100;100],["valid";"valid"],[4;4],[.2;.4],["test";"test"], ...
    'VariableNames',{'RecordingID','SinkID','EventID','StartFrame','EndFrame','BaselineValue','BaselineStatus','BaselineValidSamples','NormOxySinkAmp','Condition'});
D=struct('RecordingFolder',root,'ReviewRaw',raw,'IM_Notrend',single(raw)-25, ...
    'IM_Zframetime_smoothed',single(raw)/100,'Table_OxygenSinks_Out',Sites,'Table_OxygenSinkEvents_Out',E, ...
    'Mean_OxySink_TraceZ',1:30,'Mean_OxySink_Trace_Convo',2*(1:30),'Mean_OxySurge_TraceZ',3*(1:30));
G=renamevars(E,{'SinkID','NormOxySinkAmp'},{'SurgeID','NormOxySurgeAmp'});G.NormOxySurgeAmp=-G.NormOxySurgeAmp;
D.Table_OxygenSurges_Out=Sites;D.Table_OxygenSurgeEvents_Out=G;
I=struct('RawFile',source,'RawSHA256',oxygenFileSHA256(source),'NFrames',30,'FrameSize',[4 5], ...
    'DenoisedFile','','AnalysisParams',struct('fs',1,'quantBaselineWindowSec',4,'surgeBaselineWindowSec',4));
AnalysisInfo=I;Table_OxygenSinks_Out=Sites;Table_OxygenSinkEvents_Out=E;Table_OxygenSurges_Out=Sites;Table_OxygenSurgeEvents_Out=G;
masters={fullfile(root,'sink.mat'),fullfile(root,'surge.mat')};
save(masters{1},'AnalysisInfo','Table_OxygenSinks_Out','Table_OxygenSinkEvents_Out');
save(masters{2},'AnalysisInfo','Table_OxygenSurges_Out','Table_OxygenSurgeEvents_Out');
captureBOIRunReview(D,I,masters);
o=struct('RecordingFolder',root,'OutputFolder',[root '-unused-new-run'], ...
    'SampleHz',1,'PixelSizeUm',1,'SupportProfile','whole-image');
Request=prepareBOIRecordingRequest(o);save(fullfile(root,'RunRequest.mat'),'Request');
roles={'Request','EventAudit','SinkMaster','SurgeMaster','DataOutput','Workbook','AnalysisManifest','AuditReceipt','CodeManifest'};
paths={'RunRequest.mat',fullfile('BOIReview','event-amplitude-audit.mat'),'sink.mat','surge.mat', ...
    'data.mat','workbook.txt','analysis.json',fullfile('BOIReview','AuditCreationReceipt.json'),'code.csv'};
for k=[5 6 7 9],writeBOIRunJSON(fullfile(root,paths{k}),struct('Synthetic',true));end
A=struct('Role',{},'Path',{},'SHA256',{});
for k=1:numel(roles),A(k)=struct('Role',roles{k},'Path',paths{k},'SHA256',oxygenFileSHA256(fullfile(root,paths{k})));end
Run=struct('Schema','boi-recording-run-1','Status','complete','SourceSHA256',I.RawSHA256,'SupportProfile','whole-image','Artifacts',A);
path=fullfile(root,'BOIRun.mat');save(path,'Run');writeBOIRunJSON(fullfile(root,'RunStatus.json'),struct('Status','complete'));
end
