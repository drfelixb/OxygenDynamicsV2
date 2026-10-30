function tests=testBOIBatchQueue
% Ten finite queue lifecycle cases. Executors write synthetic saved artifacts;
% none calls the detector, statistics pipeline or supplied recording data.
tests=functiontests(localfunctions);
end

function setupOnce(~)
setupOxygenDynamicsPath;
end

function test01SelectionExcludesHeldRowsAndCountsStorage(t)
[b,parent,root]=queueFixture(3);cleanup=onCleanup(@()rmdir(root,'s'));
holdSource(b.Rows.Paths(2));
selected=b.Rows.BatchRowID(1:2);
[plan,checked]=prepareBOIBatchQueue(b,parent,selected,false);
verifyEqual(t,plan.RunRowIDs,b.Rows.BatchRowID(1));
verifyEqual(t,plan.ExcludedRowIDs,b.Rows.BatchRowID(2));
verifyEqual(t,plan.NotSelectedRowIDs,b.Rows.BatchRowID(3));
verifyEqual(t,plan.Counts.Total,3);verifyEqual(t,plan.Counts.Selected,2);
verifyEqual(t,plan.Counts.Run,1);verifyEqual(t,plan.Counts.Excluded,1);
verifyEqual(t,checked.Rows.InputStatus(2),"Needs attention");
file=dir(fullfile(char(b.Rows.Paths(1)),'raw.tif'));
verifyEqual(t,plan.SourceCopyBytes,double(file.bytes));
verifyFalse(t,isfolder(plan.QueueFolder));
verifyFalse(t,isfolder(plan.Requests{1}.Options.OutputFolder));
% An output destination must not enter another row's source, even when that
% source is held or was not selected. Canonicalize dot/parent path segments.
heldParent=fullfile(char(b.Rows.Paths(2)),'.');
verifyError(t,@()prepareBOIBatchQueue(b,heldParent,b.Rows.BatchRowID(1),false), ...
    'OxygenDynamics:BatchQueueOutputInsideSource');
nested=fullfile(char(b.Rows.Paths(3)),'nested-output');mkdir(nested);
unselectedParent=fullfile(nested,'..','nested-output');
verifyError(t,@()prepareBOIBatchQueue(b,unselectedParent,b.Rows.BatchRowID(1),false), ...
    'OxygenDynamics:BatchQueueOutputInsideSource');
end

function test02SkipRequiresVerifiedArtifacts(t)
[b,parent,root]=queueFixture(1);cleanup=onCleanup(@()rmdir(root,'s'));
[plan,b]=prepareBOIBatchQueue(b,parent);
[b,outcome]=runBOIBatchQueue(b,plan,[],[],@savedExecutor);
verifyEqual(t,string(outcome.Status),"complete");
verifyFalse(t,isfolder([char(b.FilePath) '.boi-execution-lock']));
run=loadBOIRecordingRun(char(b.Rows.RunFolder(1)));
[skip,~]=prepareBOIBatchQueue(b,parent);
verifyEqual(t,skip.SkippedRowIDs,b.Rows.BatchRowID);
verifyEmpty(t,skip.RunRowIDs);verifyEqual(t,skip.Counts.Run,0);
writeBOIRunJSON(run.Paths.Workbook,struct('ChangedAfterCompletion',true));
[changed,~]=prepareBOIBatchQueue(b,parent);
verifyEmpty(t,changed.SkippedRowIDs);
verifyEqual(t,changed.RunRowIDs,b.Rows.BatchRowID);
end

function test03FreshRetryPreservesImmutableMetadataAndHistory(t)
[b,parent,root]=queueFixture(1);cleanup=onCleanup(@()rmdir(root,'s'));
b.Rows.Notes="Original, ÆØÅ";b.Rows.Puff_2use="0007";
b=writeBOIBatchCSV(b);
[plan,b]=prepareBOIBatchQueue(b,parent);
[b,outcome]=runBOIBatchQueue(b,plan,[],[],@savedExecutor);
verifyEqual(t,string(outcome.Status),"complete");
firstFolder=char(b.Rows.RunFolder(1));firstIndex=fullfile(firstFolder,'BOIRun.mat');
firstIndexHash=oxygenFileSHA256(firstIndex);
history=loadBOIBatchHistory(b,b.Rows.BatchRowID(1));
verifyEqual(t,height(history),1);verifyTrue(t,history.Verified(1));
snapshot=char(history.SnapshotPath(1));snapshotHash=oxygenFileSHA256(snapshot);
original=load(snapshot,'Attempt');
verifyEqual(t,string(original.Attempt.Row.Notes),"Original, ÆØÅ");
verifyEqual(t,string(original.Attempt.Row.Puff_2use),"0007");
verifyFalse(t,any(isfield(original.Attempt.Request.Options,{'PuffsFile','Puff_2use'})));
metadata=original.Attempt.Request.BatchMetadata;
verifyEqual(t,string(metadata.BatchRowID),b.Rows.BatchRowID(1));
verifyEqual(t,string(metadata.Values{strcmp(metadata.Names,'Notes')}),"Original, ÆØÅ");
verifyEqual(t,string(metadata.Values{strcmp(metadata.Names,'Puff_2use')}),"0007");
b.Rows.Notes="Edited later";b.Rows.Mouse="0007";b=writeBOIBatchCSV(b);
[retry,b]=prepareBOIBatchQueue(b,parent,b.Rows.BatchRowID,true);
verifyEqual(t,retry.Counts.Run,1);verifyEmpty(t,retry.SkippedRowIDs);
verifyNotEqual(t,retry.Requests{1}.Options.OutputFolder,firstFolder);
[b,outcome]=runBOIBatchQueue(b,retry,[],[],@savedExecutor);
verifyEqual(t,string(outcome.Status),"complete");
verifyNotEqual(t,char(b.Rows.RunFolder(1)),firstFolder);
verifyEqual(t,oxygenFileSHA256(firstIndex),firstIndexHash);
verifyEqual(t,oxygenFileSHA256(snapshot),snapshotHash);
history=loadBOIBatchHistory(b,b.Rows.BatchRowID(1));
verifyEqual(t,height(history),2);verifyTrue(t,all(history.Verified));
verifyEqual(t,numel(unique(string(history.RunFolder))),2);
notes=strings(height(history),1);
for k=1:height(history)
    saved=load(char(history.SnapshotPath(k)),'Attempt');notes(k)=string(saved.Attempt.Row.Notes);
end
verifyEqual(t,sort(notes),sort(["Original, ÆØÅ";"Edited later"]));
old=loadBOIRecordingRun(firstFolder);verifyEqual(t,old.Request.Options.Mouse,'0001');
end

function test04FailureStopsLaterDispatchAndRetainsPending(t)
[b,parent,root]=queueFixture(3);cleanup=onCleanup(@()rmdir(root,'s'));
[plan,b]=prepareBOIBatchQueue(b,parent);calls=0;
[b,outcome]=runBOIBatchQueue(b,plan,[],[],@failSecond);
verifyEqual(t,calls,2);verifyEqual(t,string(outcome.Status),"failed");
verifyEqual(t,outcome.CompletedRowIDs,plan.RunRowIDs(1));
verifyEqual(t,string(outcome.FailedRowID),plan.RunRowIDs(2));
verifyEqual(t,outcome.PendingRowIDs,plan.RunRowIDs(3));
verifyFalse(t,isfolder(plan.Requests{3}.Options.OutputFolder));
history=loadBOIBatchHistory(b);
verifyEqual(t,height(history),2);
failed=history(string(history.BatchRowID)==plan.RunRowIDs(2),:);
verifyEqual(t,height(failed),1);verifyEqual(t,string(failed.Status),"Failed");verifyFalse(t,failed.Verified);
verifyTrue(t,isfile(fullfile(char(failed.RunFolder),'RunStatus.json')));
[fault,parent2,root2]=queueFixture(2);cleanup2=onCleanup(@()rmdir(root2,'s'));
[faultPlan,fault]=prepareBOIBatchQueue(fault,parent2);faultCalls=0;
faultSnapshot='';faultSnapshotHash='';
[~,faultOutcome]=runBOIBatchQueue(fault,faultPlan,[],[],@failAttemptStateWrite);
verifyEqual(t,faultCalls,1);verifyEqual(t,string(faultOutcome.Status),"failed");
verifyEqual(t,faultOutcome.PendingRowIDs,faultPlan.RunRowIDs(2));
verifyFalse(t,isfolder(faultPlan.Requests{2}.Options.OutputFolder));
verifyTrue(t,isfile(faultOutcome.RecoveryCSV));
native=loadBOIRecordingRun(faultPlan.Requests{1}.Options.OutputFolder);
verifyEqual(t,native.Status,'complete');verifyTrue(t,isfile(faultSnapshot));
verifyEqual(t,oxygenFileSHA256(faultSnapshot),faultSnapshotHash);
verifyFalse(t,isfolder([char(fault.FilePath) '.boi-execution-lock']));
    function Run=failSecond(request,progress)
        calls=calls+1;
        if calls==2
            writeFailedAttempt(request,progress);
            error('QueueTest:PlannedFailure','Finite injected failure; no engine was called.');
        end
        Run=savedExecutor(request,progress);
    end
    function Run=failAttemptStateWrite(request,progress)
        faultCalls=faultCalls+1;injected=false;Run=savedExecutor(request,@blockStateDestination);
        function blockStateDestination(status,path)
            progress(status,path);
            if ~injected&&strcmp(status.Stage,'staging')
                [runsFolder,runName]=fileparts(request.Options.OutputFolder);
                attemptID=extractAfter(string(runName),'BOIRun_');
                attemptFolder=fullfile(fileparts(runsFolder),'attempts',char(attemptID));
                state=fullfile(attemptFolder,'AttemptState.json');
                movefile(state,fullfile(attemptFolder,'AttemptState.before-write-fault.json'));
                mkdir(state);faultSnapshot=fullfile(attemptFolder,'AttemptSnapshot.mat');
                faultSnapshotHash=oxygenFileSHA256(faultSnapshot);injected=true;
            end
        end
    end
end

function test05StopFinishesCurrentAndLeavesNextPending(t)
[b,parent,root]=queueFixture(2);cleanup=onCleanup(@()rmdir(root,'s'));
[plan,b]=prepareBOIBatchQueue(b,parent);stop=false;calls=0;
[b,outcome]=runBOIBatchQueue(b,plan,[],@stopNow,@stopDuringCurrent);
verifyEqual(t,calls,1);verifyEqual(t,string(outcome.Status),"stopped");
verifyEqual(t,outcome.CompletedRowIDs,plan.RunRowIDs(1));
verifyEqual(t,outcome.PendingRowIDs,plan.RunRowIDs(2));
verifyFalse(t,isfolder(plan.Requests{2}.Options.OutputFolder));
run=loadBOIRecordingRun(char(b.Rows.RunFolder(1)));verifyEqual(t,run.Status,'complete');
history=loadBOIBatchHistory(b);verifyEqual(t,height(history),1);verifyTrue(t,history.Verified);
    function Run=stopDuringCurrent(request,progress)
        calls=calls+1;stop=true;Run=savedExecutor(request,progress);
    end
    function value=stopNow()
        value=stop;
    end
end

function test06ExternalCSVConflictRecoversAndStopsNext(t)
[b,parent,root]=queueFixture(2);cleanup=onCleanup(@()rmdir(root,'s'));
[plan,b]=prepareBOIBatchQueue(b,parent);calls=0;externalBytes=uint8([]);csv=b.FilePath;
[b,outcome]=runBOIBatchQueue(b,plan,[],[],@editCSVDuringCurrent);
verifyEqual(t,calls,1);verifyEqual(t,string(outcome.Status),"writeback-conflict");
verifyEqual(t,readBytes(csv),externalBytes);
verifyEqual(t,outcome.CompletedRowIDs,plan.RunRowIDs(1));
verifyEqual(t,outcome.PendingRowIDs,plan.RunRowIDs(2));
verifyFalse(t,isfolder(plan.Requests{2}.Options.OutputFolder));
verifyTrue(t,isfile(outcome.RecoveryCSV));recovered=readBOIBatchCSV(outcome.RecoveryCSV);
[~,report]=checkBOIBatch(recovered);row=find(recovered.Rows.BatchRowID==plan.RunRowIDs(1));
verifyEqual(t,report.AnalysisStatus(row),"Complete");verifyEqual(t,report.ResultCheck(row),"Matches");
history=loadBOIBatchHistory(b);verifyEqual(t,height(history),1);verifyTrue(t,history.Verified);
[between,parent2,root2]=queueFixture(2);cleanup2=onCleanup(@()rmdir(root2,'s'));
[betweenPlan,between]=prepareBOIBatchQueue(between,parent2);betweenCSV=between.FilePath;
editedBetween=false;betweenBytes=uint8([]);
[~,betweenOutcome]=runBOIBatchQueue(between,betweenPlan,@editBetweenRecordings,[],@savedExecutor);
verifyEqual(t,string(betweenOutcome.Status),"writeback-conflict");
verifyEqual(t,betweenOutcome.CompletedRowIDs,betweenPlan.RunRowIDs(1));
verifyEqual(t,betweenOutcome.PendingRowIDs,betweenPlan.RunRowIDs(2));
verifyEqual(t,readBytes(betweenCSV),betweenBytes);
verifyTrue(t,isfile(betweenOutcome.RecoveryCSV));
verifyFalse(t,isfolder(betweenPlan.Requests{2}.Options.OutputFolder));
    function Run=editCSVDuringCurrent(request,progress)
        calls=calls+1;edited=false;Run=savedExecutor(request,@editAfterStaging);
        function editAfterStaging(status,path)
            progress(status,path);
            if ~edited&&strcmp(status.Stage,'staging')
                fid=fopen(csv,'ab');assert(fid>=0);fwrite(fid,uint8(10),'uint8');fclose(fid);
                externalBytes=readBytes(csv);edited=true;
            end
        end
    end
    function editBetweenRecordings(~,event)
        if ~editedBetween&&strcmp(event.Status,'Complete')
            fid=fopen(betweenCSV,'ab');assert(fid>=0);fwrite(fid,uint8(10),'uint8');fclose(fid);
            betweenBytes=readBytes(betweenCSV);editedBetween=true;
        end
    end
end

function test07ReorderingKeepsAttemptsWithStableRowIDs(t)
[b,parent,root]=queueFixture(2);cleanup=onCleanup(@()rmdir(root,'s'));
% Identical synthetic source bytes make row identity, rather than source hash
% alone, necessary when a CSV result link is copied onto a different row.
copyfile(fullfile(char(b.Rows.Paths(1)),'raw.tif'),fullfile(char(b.Rows.Paths(2)),'raw.tif'),'f');
ids=b.Rows.BatchRowID;subjects=b.Rows.Mouse;
b.Rows=b.Rows([2 1],:);b=writeBOIBatchCSV(b);[plan,b]=prepareBOIBatchQueue(b,parent);
verifyEqual(t,plan.RunRowIDs,ids([2 1]));
[b,outcome]=runBOIBatchQueue(b,plan,[],[],@savedExecutor);
verifyEqual(t,string(outcome.Status),"complete");
b.Rows=b.Rows([2 1],:);b=writeBOIBatchCSV(b);read=readBOIBatchCSV(b.FilePath);
verifyEqual(t,read.Rows.BatchRowID,ids);verifyEqual(t,read.Rows.Mouse,subjects);
for k=1:2
    history=loadBOIBatchHistory(read,ids(k));verifyEqual(t,height(history),1);
    verifyEqual(t,string(history.BatchRowID),ids(k));verifyTrue(t,history.Verified);
    saved=load(char(history.SnapshotPath),'Attempt');
    verifyEqual(t,string(saved.Attempt.Row.Mouse),subjects(k));
    verifyEqual(t,string(saved.Attempt.BatchRowID),ids(k));
end
foreign=char(read.Rows.RunFolder(2));read.Rows.RunFolder(1)=string(foreign);
[~,report]=checkBOIBatch(read);
verifyEqual(t,report.AnalysisStatus(1),"Incomplete");verifyEqual(t,report.ResultCheck(1),"Unavailable");
writeBOIRunJSON(fullfile(foreign,'RunStatus.json'),struct('Status','failed','Stage','analysis'));
[~,report]=checkBOIBatch(read);
verifyEqual(t,report.AnalysisStatus(1),"Incomplete");verifyEqual(t,report.ResultCheck(1),"Unavailable");
end

function test08StaleSettingsOrSourceRejectBeforeDispatch(t)
[b,parent,root]=queueFixture(1);cleanup=onCleanup(@()rmdir(root,'s'));
[plan,b]=prepareBOIBatchQueue(b,parent);changed=b;changed.Rows.SampleF="2";
verifyError(t,@()runBOIBatchQueue(changed,plan,[],[],@mustNotDispatch),'OxygenDynamics:BatchQueueChanged');
verifyFalse(t,isfolder(plan.QueueFolder));
lock=[char(b.FilePath) '.boi-execution-lock'];mkdir(lock);
verifyError(t,@()runBOIBatchQueue(b,plan,[],[],@mustNotDispatch),'OxygenDynamics:BatchQueueLocked');
verifyTrue(t,isfolder(lock));verifyFalse(t,isfolder(plan.QueueFolder));rmdir(lock);
[unwindPlan,unwindBatch]=prepareBOIBatchQueue(b,parent);
verifyError(t,@()runBOIBatchQueue(unwindBatch,unwindPlan,[],@stopFailure,@mustNotDispatch),'QueueTest:StopFailure');
verifyFalse(t,isfolder(lock));verifyFalse(t,isfolder(unwindPlan.Requests{1}.Options.OutputFolder));
unwind=jsondecode(fileread(fullfile(unwindPlan.QueueFolder,'QueueState.json')));
verifyEqual(t,string(unwind.Status),"interrupted");
imwrite(uint16(17*ones(48)),fullfile(char(b.Rows.Paths(1)),'raw.tif'));
verifyError(t,@()runBOIBatchQueue(b,plan,[],[],@mustNotDispatch),'OxygenDynamics:BatchQueueChanged');
verifyFalse(t,isfolder(plan.QueueFolder));
[later,parent2,root2]=queueFixture(2);cleanup2=onCleanup(@()rmdir(root2,'s'));
[laterPlan,later]=prepareBOIBatchQueue(later,parent2);calls=0;
[~,outcome]=runBOIBatchQueue(later,laterPlan,[],[],@changePendingSource);
verifyEqual(t,calls,1);verifyEqual(t,string(outcome.Status),"failed");
verifyEqual(t,outcome.CompletedRowIDs,laterPlan.RunRowIDs(1));
verifyEqual(t,outcome.PendingRowIDs,laterPlan.RunRowIDs(2));
verifyFalse(t,isfolder(laterPlan.Requests{2}.Options.OutputFolder));
[completed,parent3,root3]=queueFixture(2);cleanup3=onCleanup(@()rmdir(root3,'s'));
[completedPlan,completed]=prepareBOIBatchQueue(completed,parent3);stopCalls=0;
verifyError(t,@()runBOIBatchQueue(completed,completedPlan,[],@stopAfterCompletion,@savedExecutor),'QueueTest:StopAfterCompletion');
verifyEqual(t,stopCalls,2);verifyFalse(t,isfolder([char(completed.FilePath) '.boi-execution-lock']));
verifyFalse(t,isfolder(completedPlan.Requests{2}.Options.OutputFolder));
native=loadBOIRecordingRun(completedPlan.Requests{1}.Options.OutputFolder);
verifyEqual(t,native.Status,'complete');savedCSV=readBOIBatchCSV(completed.FilePath);
verifyEqual(t,savedCSV.Rows.AnalysisStatus(1),"Complete");
history=loadBOIBatchHistory(savedCSV,completedPlan.RunRowIDs(1));
verifyEqual(t,height(history),1);verifyEqual(t,string(history.Status),"Complete");verifyTrue(t,history.Verified);
attemptState=jsondecode(fileread(fullfile(fileparts(char(history.SnapshotPath)),'AttemptState.json')));
verifyEqual(t,string(attemptState.Status),"complete");
unwind=jsondecode(fileread(fullfile(completedPlan.QueueFolder,'QueueState.json')));
verifyEqual(t,string(unwind.Status),"interrupted");
verifyEqual(t,string(unwind.CompletedRowIDs),completedPlan.RunRowIDs(1));
verifyEqual(t,string(unwind.PendingRowIDs),completedPlan.RunRowIDs(2));
    function Run=changePendingSource(request,progress)
        calls=calls+1;
        imwrite(uint16(19*ones(48)),fullfile(char(later.Rows.Paths(2)),'raw.tif'));
        Run=savedExecutor(request,progress);
    end
    function value=stopAfterCompletion()
        stopCalls=stopCalls+1;
        if stopCalls==2,error('QueueTest:StopAfterCompletion','Finite unwind between completed and pending recordings.');end
        value=false;
    end
end

function test09CompleteStatusWithoutValidArtifactsIsFailure(t)
[b,parent,root]=queueFixture(2);cleanup=onCleanup(@()rmdir(root,'s'));
b.Rows.AnalysisStatus(:)="Complete";b=writeBOIBatchCSV(b);
[plan,b]=prepareBOIBatchQueue(b,parent);verifyEqual(t,plan.Counts.Run,2);calls=0;
[b,outcome]=runBOIBatchQueue(b,plan,[],[],@statusOnly);
verifyEqual(t,calls,1);verifyEqual(t,string(outcome.Status),"failed");
verifyEmpty(t,outcome.CompletedRowIDs);verifyEqual(t,outcome.PendingRowIDs,plan.RunRowIDs(2));
verifyNotEqual(t,b.Rows.AnalysisStatus(1),"Complete");
history=loadBOIBatchHistory(b);verifyEqual(t,height(history),1);verifyFalse(t,history.Verified);
    function Run=statusOnly(request,progress)
        calls=calls+1;folder=request.Options.OutputFolder;mkdir(folder);
        Request=request;save(fullfile(folder,'RunRequest.mat'),'Request');
        status=struct('Schema','boi-run-status-1','Status','complete','Stage','complete');
        path=fullfile(folder,'RunStatus.json');writeBOIRunJSON(path,status);progress(status,path);
        Run=struct('Status','complete');
    end
end

function test10GUIProtectsBusyQueueAndStopsAfterCurrent(t)
[b,parent,root]=queueFixture(2);cleanup=onCleanup(@()rmdir(root,'s'));
[fig,ui]=openBOIBatchEditor(b);closeFig=onCleanup(@()delete(fig));
ui.SetOutputParent(parent);ui.SelectRows([1 2]);plan=ui.ReviewQueue(parent,b.Rows.BatchRowID,false);
ui.ConfirmQueue(true);calls=0;outcome=ui.RunQueue(@checkBusy);
verifyEqual(t,calls,1);verifyEqual(t,string(outcome.Status),"stopped");
verifyEqual(t,outcome.PendingRowIDs,plan.RunRowIDs(2));
verifyFalse(t,ui.State().Busy);verifyFalse(t,ui.State().Running);
verifyTrue(t,isvalid(fig));verifyEqual(t,ui.GetBatch().Rows.Mouse,b.Rows.Mouse);
    function Run=checkBusy(request,progress)
        calls=calls+1;verifyTrue(t,ui.State().Busy);verifyTrue(t,ui.State().Running);
        verifyError(t,@()ui.Edit(1,'Mouse','lost'),'OxygenDynamics:BatchBusy');
        verifyError(t,@()ui.DeleteRows(1),'OxygenDynamics:BatchBusy');
        verifyError(t,@()ui.SetShared(struct('SampleF','3'),true),'OxygenDynamics:BatchBusy');
        verifyError(t,@()ui.SelectRows(2),'OxygenDynamics:BatchBusy');
        verifyError(t,@()ui.Save(),'OxygenDynamics:BatchBusy');
        close=fig.CloseRequestFcn;close(fig,[]);verifyTrue(t,isvalid(fig));
        ui.StopAfterCurrent();verifyTrue(t,ui.State().StopRequested);
        Run=savedExecutor(request,progress);
    end
end

function [b,parent,root]=queueFixture(count)
root=tempname;mkdir(root);parent=fullfile(root,'results');mkdir(parent);paths=strings(count,1);
for row=1:count
    folder=fullfile(root,sprintf('source-%02d',row));mkdir(folder);paths(row)=string(folder);
    for frame=1:30
        image=uint16((100+row)*ones(48));file=fullfile(folder,'raw.tif');
        if frame==1,imwrite(image,file);else,imwrite(image,file,'WriteMode','append');end
    end
end
b=createBOIBatch(table(paths,repmat("1",count,1),repmat("1",count,1),repmat("whole-image",count,1), ...
    'VariableNames',{'Paths','SampleF','Pixelsize','BOISupportProfile'}));
b.Rows.Mouse=compose('%04d',(1:count)');b.Rows.Notes=repmat("",count,1);
b=writeBOIBatchCSV(b,fullfile(root,'batch.csv'));
end

function holdSource(folder)
issue=struct('IssueID','SOURCE-QUEUE-TEST-HOLD','Disposition','hold_recording', ...
    'AffectedMeasurements','All synthetic measurements','Message','Finite synthetic source hold.', ...
    'Action','Resolve the synthetic hold before dispatch.','Evidence','Queue software fixture; no biological claim.');
metadata=struct('Schema','boi-acquisition-metadata-1','Modality','BOI', ...
    'RawSHA256',oxygenFileSHA256(fullfile(char(folder),'raw.tif')),'ReviewIssues',issue);
writeBOIRunJSON(fullfile(char(folder),'BOIInputMetadata.json'),metadata);
end

function writeFailedAttempt(request,progress)
folder=request.Options.OutputFolder;mkdir(folder);Request=request;
save(fullfile(folder,'RunRequest.mat'),'Request');
status=struct('Schema','boi-run-status-1','Status','failed','Stage','staging', ...
    'ErrorID','QueueTest:PlannedFailure','ErrorMessage','Finite injected failure; no engine was called.');
path=fullfile(folder,'RunStatus.json');writeBOIRunJSON(path,status);progress(status,path);
end

function Run=savedExecutor(Request,progress)
% The native loader verifies real fixture files/checksums and a captured empty
% event audit. A return value or editable CSV completion cell is insufficient.
folder=Request.Options.OutputFolder;
assert(~isfolder(folder)&&~isfile(folder),'QueueTest:OutputExists','Executor needs a fresh output folder.');
mkdir(folder);save(fullfile(folder,'RunRequest.mat'),'Request');
status=struct('Schema','boi-run-status-1','Status','running','Stage','staging', ...
    'StartedUTC',char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ss'Z'")));
statusPath=fullfile(folder,'RunStatus.json');emit();
info=Request.InputReview.Files.RawTiffInfo;raw=zeros(info.Height,info.Width,info.Frames,'uint16');
for frame=1:info.Frames,raw(:,:,frame)=imread(Request.InputReview.Files.RawFile,frame);end
sites=table({cell(1,info.Frames)},'VariableNames',{'FramePixels'});
sites.RecordingID="QueueSynthetic";sites.SiteID=1;sites.FrameSize={[info.Height info.Width]};
sites.NFrames=info.Frames;sites.SampleF=Request.Options.SampleHz;sites=sites([],:);
events=table(strings(0,1),zeros(0,1),zeros(0,1),zeros(0,1),zeros(0,1),zeros(0,1),strings(0,1), ...
    zeros(0,1),zeros(0,1),strings(0,1),'VariableNames', ...
    {'RecordingID','SinkID','EventID','StartFrame','EndFrame','BaselineValue','BaselineStatus','BaselineValidSamples','NormOxySinkAmp','Condition'});
surges=renamevars(events,{'SinkID','NormOxySinkAmp'},{'SurgeID','NormOxySurgeAmp'});
D=struct('RecordingFolder',folder,'ReviewRaw',raw,'IM_Notrend',single(raw), ...
    'IM_Zframetime_smoothed',single(raw)/100,'Table_OxygenSinks_Out',sites, ...
    'Table_OxygenSinkEvents_Out',events,'Table_OxygenSurges_Out',sites,'Table_OxygenSurgeEvents_Out',surges, ...
    'Mean_OxySink_TraceZ',zeros(0,info.Frames),'Mean_OxySink_Trace_Convo',zeros(0,info.Frames), ...
    'Mean_OxySurge_TraceZ',zeros(0,info.Frames));
I=struct('RawFile',Request.InputReview.Files.RawFile,'RawSHA256',Request.InputReview.RawSHA256, ...
    'NFrames',info.Frames,'FrameSize',[info.Height info.Width],'DenoisedFile','', ...
    'BOISupportProfile',Request.Options.SupportProfile,'AnalysisParams',Request.AnalysisParams);
AnalysisInfo=I;Table_OxygenSinks_Out=sites;Table_OxygenSinkEvents_Out=events;
Table_OxygenSurges_Out=sites;Table_OxygenSurgeEvents_Out=surges;
masters={fullfile(folder,'sink.mat'),fullfile(folder,'surge.mat')};
save(masters{1},'AnalysisInfo','Table_OxygenSinks_Out','Table_OxygenSinkEvents_Out');
save(masters{2},'AnalysisInfo','Table_OxygenSurges_Out','Table_OxygenSurgeEvents_Out');
status.Stage='analysis';emit();captureBOIRunReview(D,I,masters);
status.Stage='statistics';emit();
roles={'Request','EventAudit','SinkMaster','SurgeMaster','DataOutput','Workbook','AnalysisManifest','AuditReceipt','CodeManifest'};
paths={'RunRequest.mat',fullfile('BOIReview','event-amplitude-audit.mat'),'sink.mat','surge.mat', ...
    'data.mat','workbook.txt','analysis.json',fullfile('BOIReview','AuditCreationReceipt.json'),'code.csv'};
for k=[5 6 7 9],writeBOIRunJSON(fullfile(folder,paths{k}),struct('SyntheticQueueFixture',true));end
artifacts=struct('Role',{},'Path',{},'SHA256',{});
for k=1:numel(roles)
    artifacts(k)=struct('Role',roles{k},'Path',paths{k},'SHA256',oxygenFileSHA256(fullfile(folder,paths{k})));
end
Run=struct('Schema','boi-recording-run-1','Status','complete','SourceSHA256',I.RawSHA256, ...
    'SupportProfile',Request.Options.SupportProfile,'Artifacts',artifacts,'ElapsedSeconds',0);
save(fullfile(folder,'BOIRun.mat'),'Run');status.Status='complete';status.Stage='complete';status.ElapsedSeconds=0;emit();
Run=loadBOIRecordingRun(folder);
    function emit()
        writeBOIRunJSON(statusPath,status);if ~isempty(progress),progress(status,statusPath);end
    end
end

function bytes=readBytes(path)
fid=fopen(path,'rb');assert(fid>=0);cleanup=onCleanup(@()fclose(fid));bytes=fread(fid,Inf,'*uint8');
end

function Run=mustNotDispatch(varargin) %#ok<STOUT,INUSD>
error('QueueTest:UnexpectedDispatch','Stale plans must be rejected before an executor call.');
end

function value=stopFailure() %#ok<STOUT>
error('QueueTest:StopFailure','Finite abnormal unwind before the first executor dispatch.');
end
