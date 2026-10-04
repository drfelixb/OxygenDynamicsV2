function tests=testBOIRecordingWorkflow
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function [options,root]=inputFixture()
root=tempname;mkdir(root);source=fullfile(root,'source');mkdir(source);
for k=1:30
    frame=uint16(100*ones(48));frame(20,20)=90+k;
    file=fullfile(source,'raw.tif');
    if k==1,imwrite(frame,file);else,imwrite(frame,file,'WriteMode','append');end
end
options=struct('RecordingFolder',source,'OutputFolder',fullfile(root,'new-run'), ...
    'SampleHz',2,'PixelSizeUm',4.75,'SupportProfile','whole-image');
end
function testExplicitSettingsAndUnknownKeys(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
r=prepareBOIRecordingRequest(o);
verifyEqual(t,r.Context.SFs,2);verifyEqual(t,r.Context.PiSz,4.75);
verifyEqual(t,r.Context.BOISupportProfile,'whole-image');
verifyEqual(t,r.SettingOrigins.Mouse,'default: unspecified');
verifyEqual(t,r.AnalysisParams,createOxygenMasterParams(4.75,2));
o.SampleHZ=1;verifyError(t,@()prepareBOIRecordingRequest(o),'OxygenDynamics:InvalidRunRequest');
o=rmfield(o,'SampleHZ');o.SampleHz=NaN;verifyError(t,@()prepareBOIRecordingRequest(o),'OxygenDynamics:InvalidRunRequest');
end
function testSupportIsExplicitAndSourceBound(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
o.SupportProfile='craniotomy-roi-1';
verifyError(t,@()prepareBOIRecordingRequest(o),'OxygenDynamics:InvalidDetectionSupport');
x=struct('Schema','boi-static-tissue-support-1','Modality','BOI', ...
    'RawSHA256',oxygenFileSHA256(fullfile(o.RecordingFolder,'raw.tif')),'FrameSize',[48 48], ...
    'IndexConvention','MATLAB_one_based_column_major_row_column','MaskPixels',(1:48*48)', ...
    'ReviewStatus','reviewed_for_static_support','DecisionID','test','Actor','synthetic fixture', ...
    'Reason','test','Evidence','synthetic','AlignmentEvidence','same grid','RecordedUTC','2026-09-23T00:00:00Z');
writeBOIRunJSON(fullfile(o.RecordingFolder,'BOITissueSupport.json'),x);
r=prepareBOIRecordingRequest(o);verifyEqual(t,r.Context.BOISupportProfile,'craniotomy-roi-1');
verifyEqual(t,numel(r.Sources),2);
x.RawSHA256=repmat('0',1,64);writeBOIRunJSON(fullfile(o.RecordingFolder,'BOITissueSupport.json'),x);
verifyError(t,@()prepareBOIRecordingRequest(o),'OxygenDynamics:RunInputHeld');
end
function testChangedSourceAndOutputAreRejectedBeforeEngine(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));r=prepareBOIRecordingRequest(o);
imwrite(ones(48,'uint16'),fullfile(o.RecordingFolder,'raw.tif'));
verifyError(t,@()runBOIRecordingWorkflow(r),'OxygenDynamics:RunRequestChanged');
verifyFalse(t,isfolder(o.OutputFolder));
mkdir(o.OutputFolder);verifyError(t,@()prepareBOIRecordingRequest(o),'OxygenDynamics:RunOutputExists');
o.OutputFolder=fullfile(o.RecordingFolder,'child');verifyError(t,@()prepareBOIRecordingRequest(o),'OxygenDynamics:InvalidRunRequest');
end
function testLegacyContextRetainsDefaultAndForwardsProfile(t)
a={1,'mouse','awake',4.75,'WT','GFAP','awake',NaN,NaN,NaN,'N'};
c=createLegacyRecordingContext(a{:});verifyEqual(t,c.BOISupportProfile,'whole-image');
c=createLegacyRecordingContext(a{:},'craniotomy-roi-1');verifyEqual(t,c.BOISupportProfile,'craniotomy-roi-1');
verifyError(t,@()createLegacyRecordingContext(a{:},'typo'),'OxygenDynamics:InvalidSupportProfile');
end
function [path,root,D,I,masters]=captureFixture(empty)
if nargin<1,empty=false;end
root=tempname;mkdir(root);source=fullfile(root,'raw.tif');
raw=100*ones(4,5,30,'uint16');raw(1,1,7:8)=80;raw(2,1,15:16)=60;
for k=1:30
    if k==1,imwrite(raw(:,:,k),source);else,imwrite(raw(:,:,k),source,'WriteMode','append');end
end
c=cell(1,30);c(7:8)={1};c(15:16)={2};Sites=table({c},'VariableNames',{'FramePixels'});
Sites.RecordingID="R";Sites.SiteID=1;Sites.FrameSize={[4 5]};Sites.NFrames=30;Sites.SampleF=1;
E=table(["R";"R"],[1;1],[1;2],[7;15],[8;16],[100;100],["valid";"valid"],[4;4],[.2;.4],["test";"test"], ...
    'VariableNames',{'RecordingID','SinkID','EventID','StartFrame','EndFrame','BaselineValue','BaselineStatus','BaselineValidSamples','NormOxySinkAmp','Condition'});
if empty,Sites=Sites([],:);E=E([],:);end
D=struct('RecordingFolder',root,'ReviewRaw',raw,'IM_Notrend',single(raw)-25, ...
    'IM_Zframetime_smoothed',single(raw)/100,'Table_OxygenSinks_Out',Sites,'Table_OxygenSinkEvents_Out',E, ...
    'Mean_OxySink_TraceZ',1:30,'Mean_OxySink_Trace_Convo',2*(1:30),'Mean_OxySurge_TraceZ',3*(1:30));
G=renamevars(E,{'SinkID','NormOxySinkAmp'},{'SurgeID','NormOxySurgeAmp'});G.NormOxySurgeAmp=-G.NormOxySurgeAmp;
D.Table_OxygenSurges_Out=Sites;D.Table_OxygenSurgeEvents_Out=G;
I=struct('RawFile',source,'RawSHA256',oxygenFileSHA256(source),'NFrames',30, ...
    'FrameSize',[4 5],'DenoisedFile','','AnalysisParams',struct('fs',1,'quantBaselineWindowSec',4,'surgeBaselineWindowSec',4));
AnalysisInfo=I;Table_OxygenSinks_Out=Sites;Table_OxygenSinkEvents_Out=E;Table_OxygenSurges_Out=Sites;Table_OxygenSurgeEvents_Out=G;
masters={fullfile(root,'sink.mat'),fullfile(root,'surge.mat')};
save(masters{1},'AnalysisInfo','Table_OxygenSinks_Out','Table_OxygenSinkEvents_Out');
save(masters{2},'AnalysisInfo','Table_OxygenSurges_Out','Table_OxygenSurgeEvents_Out');
path=captureBOIRunReview(D,I,masters);
end
function testCapturedStagesAndIndependentOpticalReplay(t)
[path,root,D,~,masters]=captureFixture();cleanup=onCleanup(@()rmdir(root,'s'));
r=loadBOIEventReview(path);verifyEqual(t,height(r.Audit),4);
verifyTrue(t,all(r.Audit.MeasurementMatches));verifyEqual(t,r.Audit.RecomputedAmplitude,[.2;.4;-.2;-.4],'AbsTol',1e-12);
for e=1:4
    trace=r.Traces{e};pixel=1+mod(e-1,2);
    expected=reshape(double(D.IM_Notrend(pixel,1,:)),1,[]);
    verifyEqual(t,trace.DetectionDetrended,expected);
    verifyEqual(t,trace.Filtered,reshape(double(D.IM_Zframetime_smoothed(pixel,1,:)),1,[]));
end
verifyEqual(t,r.Traces{1}.TimingTrace,2*(1:30));verifyEqual(t,r.Traces{3}.TimingTrace,3*(1:30));
verifyEqual(t,r.AuditCreationReceipt.DetectorReruns,0);
verifyEqual(t,r.AuditCreationReceipt.MasterSHA256{1},oxygenFileSHA256(masters{1}));
verifyError(t,@()captureBOIRunReview(D,r.AnalysisInfo,masters),'OxygenDynamics:AuditOutputExists');
end
function testZeroEventsRemainEmpty(t)
[path,root]=captureFixture(true);cleanup=onCleanup(@()rmdir(root,'s'));
r=loadBOIEventReview(path);verifyEqual(t,height(r.Audit),0);verifyEmpty(t,r.Traces);
end
function [path,root]=savedRunFixture(empty)
if nargin<1,empty=false;end
[audit,root,~,I,masters]=captureFixture(empty);
o=struct('RecordingFolder',root,'OutputFolder',[root '-unused-new-run'], ...
    'SampleHz',1,'PixelSizeUm',1,'SupportProfile','whole-image');
Request=prepareBOIRecordingRequest(o);
save(fullfile(root,'RunRequest.mat'),'Request');
roles={'Request','EventAudit','SinkMaster','SurgeMaster','DataOutput','Workbook','AnalysisManifest','AuditReceipt','CodeManifest'};
paths={'RunRequest.mat',fullfile('BOIReview','event-amplitude-audit.mat'),'sink.mat','surge.mat', ...
    'data.mat','workbook.txt','analysis.json',fullfile('BOIReview','AuditCreationReceipt.json'),'code.csv'};
for k=[5 6 7 9],writeBOIRunJSON(fullfile(root,paths{k}),struct('Synthetic',true));end
A=struct('Role',{},'Path',{},'SHA256',{});
for k=1:numel(roles),A(k)=struct('Role',roles{k},'Path',paths{k},'SHA256',oxygenFileSHA256(fullfile(root,paths{k})));end
Run=struct('Schema','boi-recording-run-1','Status','complete','SourceSHA256',I.RawSHA256,'SupportProfile','whole-image','Artifacts',A);
path=fullfile(root,'BOIRun.mat');save(path,'Run');writeBOIRunJSON(fullfile(root,'RunStatus.json'),struct('Status','complete'));
assert(isfile(audit)&&numel(masters)==2);
end
function testReopenVerifiesArtifactsAndIncompleteStatus(t)
[path,root]=savedRunFixture();cleanup=onCleanup(@()rmdir(root,'s'));
r=loadBOIRecordingRun(path);verifyEqual(t,r.EventCount,4);verifyEqual(t,r.CorrectedTraceStatus,'captured');
verifyEqual(t,r.Paths.EventAudit,fullfile(root,'BOIReview','event-amplitude-audit.mat'));
writeBOIRunJSON(fullfile(root,'RunStatus.json'),struct('Status','failed'));
verifyError(t,@()loadBOIRecordingRun(path),'OxygenDynamics:IncompleteRun');
writeBOIRunJSON(fullfile(root,'RunStatus.json'),struct('Status','complete'));
S=load(path,'Run');Run=S.Run;Run.Schema='future-unsupported';save(path,'Run');
verifyError(t,@()loadBOIRecordingRun(path),'OxygenDynamics:InvalidRun');Run=S.Run;save(path,'Run');
Q=load(r.Paths.Request,'Request');Request=Q.Request;Request.Schema='future-unsupported';save(r.Paths.Request,'Request');
% Re-hash the deliberately incompatible request so schema rejection is reached.
Run=S.Run;k=find(strcmp({Run.Artifacts.Role},'Request'));Run.Artifacts(k).SHA256=oxygenFileSHA256(r.Paths.Request);save(path,'Run');
verifyError(t,@()loadBOIRecordingRun(path),'OxygenDynamics:InvalidRun');
Request=Q.Request;save(r.Paths.Request,'Request');Run=S.Run;Run.Artifacts(k).SHA256=oxygenFileSHA256(r.Paths.Request);save(path,'Run');

writeBOIRunJSON(r.Paths.Workbook,struct('Changed',true));
verifyError(t,@()loadBOIRecordingRun(path),'OxygenDynamics:RunArtifactChanged');
end
function testGuiReopenFailureAndSourceSwitchClearPreviousResult(t)
[path,root]=savedRunFixture();cleanup=onCleanup(@()rmdir(root,'s'));
[fig,ui]=openBOIRecordingWorkflow();closeFig=onCleanup(@()delete(fig));
ui.OpenRun(path);s=ui.State();verifyEqual(t,s.Status,'complete');verifyNotEmpty(t,s.SelectedRun);
verifyEqual(t,ui.EventButton.Enable,matlab.lang.OnOffSwitchState.on);
verifyEqual(t,ui.Source.Value,root);verifyEqual(t,ui.SampleHz.Value,'1');
verifyEqual(t,ui.SupportProfile.Value,'whole-image');
ui.Source.ValueChangedFcn([],[]);s=ui.State();verifyEmpty(t,s.SelectedRun);verifyEmpty(t,s.Request);
ui.OpenRun(path);writeBOIRunJSON(fullfile(root,'RunStatus.json'),struct('Status','failed'));
verifyError(t,@()ui.OpenRun(path),'OxygenDynamics:IncompleteRun');s=ui.State();verifyEmpty(t,s.SelectedRun);
verifyEqual(t,ui.EventButton.Enable,matlab.lang.OnOffSwitchState.off);
verifyError(t,@()ui.Run(),'OxygenDynamics:RunNotConfirmed');
end
function testGuiRequiresConfirmationAndRejectsChangedSettings(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
[fig,ui]=openBOIRecordingWorkflow(o);closeFig=onCleanup(@()delete(fig));
r=ui.Prepare();verifyEqual(t,r,prepareBOIRecordingRequest(o));
verifyError(t,@()ui.Run(),'OxygenDynamics:RunNotConfirmed');
ui.Confirm.Value=true;ui.SampleHz.Value='3';
verifyError(t,@()ui.Run(),'OxygenDynamics:RunRequestChanged');
s=ui.State();verifyEmpty(t,s.SelectedRun);verifyEqual(t,s.Status,'failed');verifyFalse(t,isfolder(o.OutputFolder));
end

function testGuiPreflightSeparatesKnownWarningsAndUnavailableEvidence(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
[fig,ui]=openBOIRecordingWorkflow(o);closeFig=onCleanup(@()delete(fig));
r=ui.Prepare();body=strjoin(string(ui.Details.Value),newline);
verifyTrue(t,contains(body,"RECORDING AND SUPPORT"));
verifyTrue(t,contains(body,string(r.InputReview.RawSHA256)));
verifyTrue(t,contains(body,"Frame schedule: 2 Hz"));
verifyTrue(t,contains(body,"Tissue support: whole-image"));
verifyTrue(t,contains(body,"New output directory: " + string(o.OutputFolder)));
verifyTrue(t,contains(body,"Earlier runs are never overwritten"));
verifyTrue(t,contains(body,"[established detector default]"));
verifyTrue(t,contains(body,"SCIENTIFIC WARNINGS (do not block Run)"));
verifyTrue(t,contains(body,"UNAVAILABLE INFORMATION (not zero)"));
verifyTrue(t,contains(body,"Camera exposure duration: unknown"));
verifyEqual(t,ui.Confirm.Enable,matlab.lang.OnOffSwitchState.on);
end

function testGuiHeldPreflightGivesCorrectionAndDisablesRun(t)
[o,root]=inputFixture();cleanup=onCleanup(@()rmdir(root,'s'));
metadata=struct('Schema','boi-acquisition-metadata-1', ...
    'RawSHA256',oxygenFileSHA256(fullfile(o.RecordingFolder,'raw.tif')),'Modality','IOSI');
writeBOIRunJSON(fullfile(o.RecordingFolder,'BOIInputMetadata.json'),metadata);
[fig,ui]=openBOIRecordingWorkflow(o);closeFig=onCleanup(@()delete(fig));
verifyError(t,@()ui.Prepare(),'OxygenDynamics:RunInputHeld');
body=strjoin(string(ui.Details.Value),newline);
verifyTrue(t,contains(body,"REQUIRED CORRECTION BEFORE RUN"));
verifyTrue(t,contains(body,"outside this BOI-only input contract"));
verifyEqual(t,ui.Confirm.Enable,matlab.lang.OnOffSwitchState.off);
verifyEqual(t,ui.RunButton.Enable,matlab.lang.OnOffSwitchState.off);
verifyFalse(t,isfolder(o.OutputFolder));
end

function testSavedStagingFailureGivesRecoveryActionWithoutEnablingRun(t)
root=tempname;mkdir(root);cleanup=onCleanup(@()rmdir(root,'s'));
folder=fullfile(root,'incomplete-run');mkdir(folder);
exactError='No matching files named disposable-source/raw.tif were found.';
writeBOIRunJSON(fullfile(folder,'RunStatus.json'),struct('Schema','boi-run-status-1', ...
    'Status','failed','Stage','staging','ErrorID','MATLAB:COPYFILE:FileNotFound', ...
    'ErrorMessage',exactError));
[fig,ui]=openBOIRecordingWorkflow();closeFig=onCleanup(@()delete(fig));
verifyError(t,@()ui.OpenRun(folder),'OxygenDynamics:IncompleteRun');
body=strjoin(string(ui.Details.Value),newline);
verifyTrue(t,contains(string(ui.Status.Text),"required source file became unavailable"));
verifyTrue(t,contains(body,"Check the recording folder, choose a new output directory, then run Review settings again."));
verifyTrue(t,contains(body,"Exact error ID: MATLAB:COPYFILE:FileNotFound"));
verifyTrue(t,contains(body,"Exact error: " + string(exactError)));
verifyTrue(t,contains(body,"Incomplete run folder retained: " + string(folder)));
verifyEqual(t,ui.RunButton.Enable,matlab.lang.OnOffSwitchState.off);
verifyEqual(t,ui.Confirm.Enable,matlab.lang.OnOffSwitchState.off);
verifyEmpty(t,ui.State().SelectedRun);
verifyEmpty(t,ui.ListRuns(root));
end

function testSavedAnalysisAndStatisticsFailuresRequireNewOutput(t)
root=tempname;mkdir(root);cleanup=onCleanup(@()rmdir(root,'s'));
for stage={'analysis','statistics'}
    folder=fullfile(root,[stage{1} '-incomplete']);mkdir(folder);
    exactID=['OxygenDynamics:G5Injected' upper(stage{1}(1)) stage{1}(2:end) 'Failure'];
    exactMessage=['Synthetic G5 fault at ' stage{1} ' entry; this is not an engine defect.'];
    writeBOIRunJSON(fullfile(folder,'RunStatus.json'),struct('Schema','boi-run-status-1', ...
        'Status','failed','Stage',stage{1},'ErrorID',exactID,'ErrorMessage',exactMessage));
end
[fig,ui]=openBOIRecordingWorkflow();closeFig=onCleanup(@()delete(fig));
for stage={'analysis','statistics'}
    folder=fullfile(root,[stage{1} '-incomplete']);
    verifyError(t,@()ui.OpenRun(folder),'OxygenDynamics:IncompleteRun');
    body=strjoin(string(ui.Details.Value),newline);
    verifyTrue(t,contains(string(ui.Status.Text),"Run failed during " + string(stage{1})));
    verifyTrue(t,contains(body,"Retain this incomplete folder and report the exact error ID below before retrying."));
    verifyTrue(t,contains(body,"After the cause is addressed, choose a new output directory and run Review settings again."));
    verifyTrue(t,contains(body,"OxygenDynamics:G5Injected"));
    verifyTrue(t,contains(body,"Incomplete run folder retained: " + string(folder)));
    verifyEqual(t,ui.RunButton.Enable,matlab.lang.OnOffSwitchState.off);
    verifyEmpty(t,ui.State().SelectedRun);
end
verifyEmpty(t,ui.ListRuns(root));
end

function testGuiZeroEventResultRemainsExplicit(t)
[path,root]=savedRunFixture(true);cleanup=onCleanup(@()rmdir(root,'s'));
[fig,ui]=openBOIRecordingWorkflow();closeFig=onCleanup(@()delete(fig));
ui.OpenRun(path);s=ui.State();verifyEqual(t,s.SelectedRun.EventCount,0);
verifyEqual(t,s.SelectedRun.CorrectedTraceStatus,'no_detected_events');
verifyEqual(t,ui.EventButton.Enable,matlab.lang.OnOffSwitchState.off);
verifyEqual(t,ui.WindowButton.Enable,matlab.lang.OnOffSwitchState.on);
end

function testGuiDiscoveryAndDirectOpenRejectUnsupportedAndCorruptIndexes(t)
[path,root]=savedRunFixture();cleanup=onCleanup(@()rmdir(root,'s'));
[fig,ui]=openBOIRecordingWorkflow();closeFig=onCleanup(@()delete(fig));
for kind={'unsupported','corrupt-status','corrupt-index'}
    folder=fullfile(root,kind{1});mkdir(folder);
    copyfile(path,fullfile(folder,'BOIRun.mat'));
    copyfile(fullfile(root,'RunStatus.json'),fullfile(folder,'RunStatus.json'));
    switch kind{1}
        case 'unsupported'
            S=load(fullfile(folder,'BOIRun.mat'),'Run');Run=S.Run;
            Run.Schema='boi-recording-run-unsupported';save(fullfile(folder,'BOIRun.mat'),'Run');
            expected='OxygenDynamics:InvalidRun';
        case 'corrupt-status'
            fid=fopen(fullfile(folder,'RunStatus.json'),'w');fprintf(fid,'{invalid-json\n');fclose(fid);
            expected='';
        case 'corrupt-index'
            fid=fopen(fullfile(folder,'BOIRun.mat'),'w');fprintf(fid,'not-a-MAT-file\n');fclose(fid);
            expected='';
    end
    verifyEmpty(t,ui.ListRuns(folder),sprintf('%s must not be offered as a completed run.',kind{1}));
    caught=[];try,ui.OpenRun(folder);catch err,caught=err;end
    verifyNotEmpty(t,caught,'Direct open accepted an invalid run.');
    if isempty(caught),continue;end
    if ~isempty(expected),verifyEqual(t,caught.identifier,expected);end
    verifyEmpty(t,ui.State().SelectedRun);
    detail=strjoin(string(ui.Details.Value),newline);
    verifyTrue(t,contains(detail,"SAVED RUN CANNOT BE OPENED"));
    verifyTrue(t,contains(detail,"Exact error ID: " + string(caught.identifier)));
    verifyTrue(t,contains(detail,"Keep this folder unchanged."));
end
end

function testSavedRunEntryAndNeutralEventChoice(t)
[path,root]=savedRunFixture();cleanup=onCleanup(@()rmdir(root,'s'));
[fig,ui]=openBOIRecordingWorkflow();closeFig=onCleanup(@()delete(fig));
verifyEqual(t,ui.ListRuns(root),{path});
ui.OpenLatest(root);verifyEqual(t,ui.State().Status,'complete');
targets=ui.SelectedTargets();verifyEqual(t,targets.Run,path);
verifyEqual(t,targets.SourceSHA256,ui.State().SelectedRun.SourceSHA256);
verifyEqual(t,targets.Workbook,fullfile(root,'workbook.txt'));
[eventFig,eventUI]=ui.OpenEvents();closeEvents=onCleanup(@()delete(eventFig));
verifyEmpty(t,eventUI.CurrentIndex());verifyEmpty(t,eventUI.List.Selection);
verifyEqual(t,eventUI.Tabs.SelectedTab,eventUI.EventTab);
verifyEqual(t,eventUI.ExportButton.Enable,matlab.lang.OnOffSwitchState.off);
rows=eventUI.List.Data;
verifyEqual(t,unique(rows.Sign),["sink";"surge"]);
verifyEqual(t,rows.StartFrame(1),7);verifyEqual(t,rows.EndFrame(1),8);
verifyTrue(t,all(rows.ReviewStatus=="Automatic; not reviewed"));
eventUI.List.CellSelectionCallback(eventUI.List,struct('Indices',[3 1]));
verifyEqual(t,eventUI.Tabs.SelectedTab,eventUI.EventTab);
verifyEqual(t,eventUI.CurrentIndex(),3);
verifyEqual(t,eventUI.List.Data.Sign(3),"surge");
verifyEqual(t,eventUI.ExportButton.Enable,matlab.lang.OnOffSwitchState.on);
verifyNotEmpty(t,findall(eventUI.RawAxes,'Type','Line'));
verifyNotEmpty(t,findall(eventUI.Timing.CorrectedAxes,'Tag','BOICorrectedTrace'));
verifyEqual(t,ui.ReopenButton.Text,'Open saved run');
ui.NewButton.ButtonPushedFcn(ui.NewButton,[]);verifyEmpty(t,ui.State().SelectedRun);
verifyEqual(t,ui.EventButton.Enable,matlab.lang.OnOffSwitchState.off);
verifyError(t,@()ui.SelectedTargets(),'OxygenDynamics:IncompleteRun');
writeBOIRunJSON(fullfile(root,'RunStatus.json'),struct('Status','failed'));
verifyEmpty(t,ui.ListRuns(root));
end
