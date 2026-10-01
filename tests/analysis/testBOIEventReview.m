function tests=testBOIEventReview
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function [path,root,masters]=fixture(nativeVariation)
if nargin<1,nativeVariation=false;end
root=tempname;mkdir(root);source=fullfile(root,'source.tif');
R=100*ones(4,5,30,'uint16');R(1,1,7:8)=80;R(2,1,15:16)=60;
if nativeVariation,R(3,1,7:8)=80;end
for k=1:30
    if k==1,imwrite(R(:,:,k),source);else,imwrite(R(:,:,k),source,'WriteMode','append');end
end
c=cell(1,30);c(7:8)={1};c(15:16)={2};Sites=table({c},'VariableNames',{'FramePixels'});
if nativeVariation,Sites.FramePixels{1}{7}=[1;3];end
Sites.RecordingID="R";Sites.SiteID=1;Sites.FrameSize={[4 5]};Sites.NFrames=30;Sites.SampleF=1;
E=table(["R";"R"],[1;1],[1;2],[7;15],[8;16],[100;100],["valid";"valid"],[4;4],[.2;.4], ...
    'VariableNames',{'RecordingID','SinkID','EventID','StartFrame','EndFrame','BaselineValue','BaselineStatus','BaselineValidSamples','NormOxySinkAmp'});
[A,T]=auditOxygenEventFootprints(Sites,E,Sites([],:),R,4,'sink');
Table_OxygenSinks_Out=Sites;Table_OxygenSinkEvents_Out=E;
E=renamevars(E,{'SinkID','NormOxySinkAmp'},{'SurgeID','NormOxySurgeAmp'});E.NormOxySurgeAmp=-E.NormOxySurgeAmp;
[B,U]=auditOxygenEventFootprints(Sites,E,Sites([],:),R,4,'surge');
Table_OxygenSurges_Out=Sites;Table_OxygenSurgeEvents_Out=E;
Audit=[A;B];Traces=[T;U];
AnalysisInfo=struct('RawFile',source,'RawSHA256',oxygenFileSHA256(source),'NFrames',30, ...
    'FrameSize',[4 5],'AnalysisParams',struct('fs',1));
Audit.SourceRawSHA256=repmat(string(AnalysisInfo.RawSHA256),height(Audit),1);
path=fullfile(root,'event-amplitude-audit.mat');save(path,'Audit','Traces','AnalysisInfo');
masters={fullfile(root,'sink-master.mat'),fullfile(root,'surge-master.mat')};
save(masters{1},'AnalysisInfo','Table_OxygenSinks_Out','Table_OxygenSinkEvents_Out');
save(masters{2},'AnalysisInfo','Table_OxygenSurges_Out','Table_OxygenSurgeEvents_Out');
end
function testBothSignsAndReplay(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);
verifyEqual(t,height(R.Audit),4);
for k=1:4
    D=buildBOIEventReviewData(R,k);verifyTrue(t,D.ReplayMatches);verifyTrue(t,D.BaselineReplayMatches);
end
D=buildBOIEventReviewData(R,3);verifyEqual(t,D.ReplayedAmplitude,-.2,'AbsTol',1e-12);
verifyTrue(t,any(contains(string(D.Details),'DIRECTION DISAGREEMENT')));
verifyEqual(t,D.Frames.ModeledTimeSec,(0:29)');
verifyEqual(t,D.Frames.SignedFraction(7:8),[-.2;-.2],'AbsTol',1e-12);
end
function testMissingAndMismatchRemainVisible(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);
R.Audit.RecomputedBaseline(1)=NaN;R.Audit.RecomputedAmplitude(1)=NaN;
R.Audit.RecomputedStatus(1)="insufficient_clean_prebaseline";R.Traces{1}.CleanBaselineFrames=[];
D=buildBOIEventReviewData(R,1);verifyTrue(t,all(isnan(D.Frames.SignedFraction)));
verifyTrue(t,isnan(D.ReplayedAmplitude));
R=loadBOIEventReview(path);R.Traces{1}.Raw(7)=70;D=buildBOIEventReviewData(R,1);
verifyFalse(t,D.ReplayMatches);verifyTrue(t,D.BaselineReplayMatches);
R.Traces{1}.Raw(3)=120;D=buildBOIEventReviewData(R,1);verifyFalse(t,D.BaselineReplayMatches);
end
function testMalformedAndMismatchedAudits(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));S=load(path);
Audit=S.Audit;Traces=S.Traces;AnalysisInfo=S.AnalysisInfo;
Audit.SourceRawSHA256(1)="wrong";save(path,'Audit','Traces','AnalysisInfo');
verifyError(t,@()loadBOIEventReview(path),'OxygenDynamics:InvalidEventReview');
Audit=S.Audit;Traces{1}.Footprint=21;save(path,'Audit','Traces','AnalysisInfo');
verifyError(t,@()loadBOIEventReview(path),'OxygenDynamics:InvalidEventReview');
Traces=S.Traces;Audit(2,:)=Audit(1,:);save(path,'Audit','Traces','AnalysisInfo');
verifyError(t,@()loadBOIEventReview(path),'OxygenDynamics:InvalidEventReview');
end
function testSourcePixelsAndMissingOrChangedSource(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);
[P,M]=readBOIEventReviewFrame(R,1,7);verifyEqual(t,P(1,1),uint16(80));verifyEqual(t,find(M),1);
imwrite(ones(4,5,'uint16'),R.AnalysisInfo.RawFile);
verifyError(t,@()readBOIEventReviewFrame(R,1,7),'OxygenDynamics:ReviewSourceChanged');
delete(R.AnalysisInfo.RawFile);
verifyError(t,@()readBOIEventReviewFrame(R,1,7),'OxygenDynamics:ReviewSourceMissing');
D=buildBOIEventReviewData(R,1);verifyTrue(t,D.ReplayMatches);
end
function testExportReproducesAndPreservesPrior(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);
out=fullfile(root,'export');receipt=exportBOIEventReview(R,3,out);
F=readtable(fullfile(out,'SelectedEventTrace.csv'));
B=mean(F.PreservedInputMean(F.CleanBaseline==1));q=(F.PreservedInputMean(F.MeasurementWindow==1)-B)/B;
verifyEqual(t,max(q),receipt.SelectedEvent.RecomputedAmplitude,'AbsTol',1e-12);
verifyEqual(t,receipt.ScientificStatus,'not_established');
verifyEqual(t,receipt.DictionaryRole,'current_definitions_context_only');
verifyError(t,@()exportBOIEventReview(R,3,out),'OxygenDynamics:ReviewOutputExists');
S=load(path);S.Audit.StoredAmplitude(1)=.9;save(path,'-struct','S');
verifyError(t,@()exportBOIEventReview(R,3,fullfile(root,'second')),'OxygenDynamics:EventReviewChanged');
end
function testGuiSelectionAndDefinitions(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));
[fig,UI]=openBOIEventReview(path);closeFig=onCleanup(@()delete(fig));
UI.Select(3);verifyTrue(t,any(contains(string(UI.Detail.Value),'DIRECTION DISAGREEMENT')));
verifyEqual(t,UI.List.Selection,3);
UI.ImageButton.ButtonPushedFcn([],[]);verifyTrue(t,contains(UI.ImageStatus.Text,'checksum matched'));
source=UI.Review.AnalysisInfo.RawFile;movefile(source,[source '.disconnected']);
UI.ImageButton.ButtonPushedFcn([],[]);verifyTrue(t,startsWith(UI.Detail.Value{1},'IMAGE UNAVAILABLE'));
movefile([source '.disconnected'],source);UI.ImageButton.ButtonPushedFcn([],[]);
verifyTrue(t,contains(UI.ImageStatus.Text,'checksum matched'));
verifyFalse(t,startsWith(UI.Detail.Value{1},'IMAGE UNAVAILABLE'));
verifyTrue(t,contains(UI.Definitions.Status.Text,'not a saved run snapshot'));
[defs,~,source]=getBOIMeasurementDictionary();saved=fullfile(root,'dictionary.json');copyfile(source,saved);
UI.Definitions.Load(saved);verifyEqual(t,numel(UI.Definitions.List.Items),height(defs));
verifyEqual(t,UI.Definitions.SelectedPath(),saved);
UI.Definitions.FullButton.ButtonPushedFcn([],[]);
popup=findall(groot,'Type','figure','Name','BOI measurement definition — saved view');
verifyTrue(t,isscalar(popup));delete(popup);
fid=fopen(saved,'a');fprintf(fid,' ');fclose(fid);
verifyError(t,@()UI.Definitions.SelectedPath(),'OxygenDynamics:DictionaryChanged');
end
function testEmptyAudit(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));S=load(path);
S.Audit=S.Audit([],:);S.Traces={};save(path,'-struct','S');
[fig,UI]=openBOIEventReview(path);closeFig=onCleanup(@()delete(fig));
verifyEqual(t,UI.ExportButton.Enable,matlab.lang.OnOffSwitchState.off);
verifyTrue(t,contains(UI.Detail.Value{1},'does not establish a valid biological zero'));
end
function testIOSIDeclarationIsRejected(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));S=load(path);
D=struct('Schema','boi-acquisition-metadata-1','RawSHA256',S.AnalysisInfo.RawSHA256,'Modality','IOSI');
S.AnalysisInfo.BOIAcquisitionMetadata=struct('State','captured','RawJSON',jsonencode(D),'SHA256','fixture');
save(path,'-struct','S');
verifyError(t,@()loadBOIEventReview(path),'OxygenDynamics:EventReviewScope');
end
function testNativeFramesDoNotBecomeUnionOrRecurrentEvent(t)
[path,root,masters]=fixture(true);cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);
for pair=[1 1;3 2]'
    index=pair(1);R=attachBOINativeMasks(R,index,masters{pair(2)});
    [~,first]=readBOIEventReviewFrame(R,index,7,'native');
    [~,second]=readBOIEventReviewFrame(R,index,8,'native');
    [~,other]=readBOIEventReviewFrame(R,index,15,'native');
    [~,fixed]=readBOIEventReviewFrame(R,index,8,'fixed');
    verifyEqual(t,find(first),[1;3]);verifyEqual(t,find(second),1);
    verifyEqual(t,find(fixed),[1;3]);verifyFalse(t,any(other(:)));
    D=buildBOIEventReviewData(R,index);verifyTrue(t,D.ReplayMatches);
    verifyEqual(t,D.Frames.NativeMaskPixels(7:8),[2;1]);verifyEqual(t,D.Frames.NativeMaskPixels(15),0);
end
verifyError(t,@()readBOIEventReviewFrame(R,2,15,'native'),'OxygenDynamics:NativeMaskMissing');
end
function testNativeMismatchAndMutation(t)
[path,root,masters]=fixture(true);cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);
S=load(masters{1});S.AnalysisInfo.RawSHA256='wrong';bad=fullfile(root,'bad.mat');save(bad,'-struct','S');
verifyError(t,@()attachBOINativeMasks(R,1,bad),'OxygenDynamics:NativeMaskProvenance');
S=load(masters{1});S.Table_OxygenSinkEvents_Out.EventID(1)=99;save(bad,'-struct','S');
verifyError(t,@()attachBOINativeMasks(R,1,bad),'OxygenDynamics:NativeMaskIdentity');
S=load(masters{1});S.Table_OxygenSinks_Out.FramePixels{1}{8}=21;save(bad,'-struct','S');
verifyError(t,@()attachBOINativeMasks(R,1,bad),'OxygenDynamics:NativeMaskSupport');
S=load(masters{1});S.Table_OxygenSinks_Out.FramePixels{1}{7}=1;save(bad,'-struct','S');
verifyError(t,@()attachBOINativeMasks(R,1,bad),'OxygenDynamics:NativeMaskSupport');
R=attachBOINativeMasks(R,1,masters{1});S=load(masters{1});S.Note='changed';save(masters{1},'-struct','S');
verifyError(t,@()readBOIEventReviewFrame(R,1,7,'native'),'OxygenDynamics:NativeMaskChanged');
verifyError(t,@()exportBOIEventReview(R,1,fullfile(root,'blocked-export')),'OxygenDynamics:NativeMaskChanged');
verifyFalse(t,isfolder(fullfile(root,'blocked-export')));
end
function testNativeExportAndGui(t)
[path,root,masters]=fixture(true);cleanup=onCleanup(@()rmdir(root,'s'));
[fig,UI]=openBOIEventReview(path);closeFig=onCleanup(@()delete(fig));UI.AttachNative(masters{1});
verifyEqual(t,UI.Overlay.Value,'native');verifyTrue(t,contains(UI.ImageStatus.Text,'frame 7 (2 pixels)'));
UI.Frame.Value=8;UI.ImageButton.ButtonPushedFcn([],[]);verifyTrue(t,contains(UI.ImageStatus.Text,'frame 8 (1 pixels)'));
out=fullfile(root,'native-export');receipt=exportBOIEventReview(UI.CurrentReview(),1,out);
verifyEqual(t,receipt.NativeFrameMasks,'attached_master_snapshot');
P=readtable(fullfile(out,'NativeEventFramePixels.csv'));F=readtable(fullfile(out,'SelectedEventTrace.csv'));
verifyEqual(t,P.Frame,[7;7;8]);verifyEqual(t,P.MatlabLinearPixel,[1;3;1]);
verifyEqual(t,F.NativeMaskPixels(7:8),[2;1]);
verifyTrue(t,contains(receipt.NativeMaskEvidence.Association,'did not capture master checksum'));
UI.Select(2);verifyEqual(t,UI.Overlay.ItemsData,{'fixed'});
UI.Select(1);verifyTrue(t,ismember('native',UI.Overlay.ItemsData));
verifyError(t,@()UI.AttachNative(masters{2}),'OxygenDynamics:NativeMaskProvenance');
verifyEqual(t,UI.Overlay.ItemsData,{'fixed'});
end
function testDiagnosticUsesOnlySavedBaselineAndPreservesSource(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);
R.Traces{1}.Raw(3:6)=[94 98 102 106];before=R;
D=buildBOIEventReviewData(R,1);B=D.BaselineDiagnostic;
verifyEqual(t,R,before);verifyEqual(t,D.Row,R.Audit(1,:));
verifyEqual(t,D.Frames.SignedFraction(7:8),[-.2;-.2],'AbsTol',1e-12);
verifyEqual(t,B.Status,'available_diagnostic_only');verifyEqual(t,B.SlopeUnitsPerSec,4,'AbsTol',1e-12);
verifyEqual(t,D.Frames.DiagnosticLinearReference(3:8),(94:4:114)','AbsTol',1e-12);
verifyEqual(t,B.AmplitudeFraction,1-80/114,'AbsTol',1e-12);
verifyEqual(t,B.FirstHalfSlopePercentPerSec,4,'AbsTol',1e-12);
verifyEqual(t,B.LastHalfSlopePercentPerSec,4,'AbsTol',1e-12);
verifyTrue(t,all(isnan(D.Frames.DiagnosticLinearReference([1:2,9:30]))));
verifyTrue(t,all(isnan(D.Frames.DiagnosticLinearSignedFraction([1:6,9:30]))));
R.Traces{1}.Raw(9:30)=1e6;after=buildBOIEventReviewData(R,1);
verifyEqual(t,after.BaselineDiagnostic,B);
R.AnalysisInfo.AnalysisParams.fs=2;after=buildBOIEventReviewData(R,1);
verifyEqual(t,after.BaselineDiagnostic.SlopeUnitsPerSec,8,'AbsTol',1e-12);
verifyEqual(t,after.BaselineDiagnostic.BaselineDurationSec,2);
verifyEqual(t,after.BaselineDiagnostic.AmplitudeFraction,B.AmplitudeFraction,'AbsTol',1e-12);
verifyEqual(t,after.BaselineDiagnostic.SignedAUC_sec,B.SignedAUC_sec/2,'AbsTol',1e-12);
end
function testDiagnosticUnavailableDoesNotRepairBaseline(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);
for indices={[],[3 4 6],[2 3 4 5]}
    Q=R;Q.Traces{1}.CleanBaselineFrames=indices{1};D=buildBOIEventReviewData(Q,1);
    verifyEqual(t,D.BaselineDiagnostic.Status,'incomplete_or_nonlocal_baseline');
    verifyTrue(t,all(isnan(D.Frames.DiagnosticLinearReference)));
    verifyEqual(t,D.Row.StoredAmplitude,.2);
end
Q=R;Q.Traces{1}.Raw(3)=NaN;D=buildBOIEventReviewData(Q,1);
verifyEqual(t,D.BaselineDiagnostic.Status,'nonfinite_baseline');
Q=R;Q.Traces{1}.Raw(3)=120;D=buildBOIEventReviewData(Q,1);
verifyEqual(t,D.BaselineDiagnostic.Status,'saved_trace_replay_mismatch');
Q=R;Q.Traces{1}.Raw(7)=NaN;D=buildBOIEventReviewData(Q,1);
verifyEqual(t,D.BaselineDiagnostic.Status,'nonfinite_event_source_or_reference');
verifyTrue(t,D.BaselineDiagnostic.FitAvailable);
verifyTrue(t,all(isnan(D.Frames.DiagnosticLinearSignedFraction)));
end
function testDiagnosticNonpositiveExtrapolationAndFlatTrace(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);
Q=R;Q.Traces{1}.Raw(3:6)=[160 120 80 40];D=buildBOIEventReviewData(Q,1);
verifyTrue(t,D.ReplayMatches);verifyEqual(t,D.BaselineDiagnostic.Status,'nonpositive_event_reference');
verifyTrue(t,D.BaselineDiagnostic.FitAvailable);
verifyEqual(t,D.Frames.DiagnosticLinearReference(7:8),[0;-40],'AbsTol',1e-12);
verifyTrue(t,isnan(D.BaselineDiagnostic.AmplitudeFraction));
verifyTrue(t,all(isnan(D.Frames.DiagnosticLinearSignedFraction)));
verifyEqual(t,D.ReplayedAmplitude,.2,'AbsTol',1e-12);
D=buildBOIEventReviewData(R,3);verifyEqual(t,D.BaselineDiagnostic.SlopeUnitsPerSec,0);
verifyTrue(t,isnan(D.BaselineDiagnostic.DescriptiveR2));
verifyEqual(t,D.BaselineDiagnostic.AmplitudeFraction,-.2,'AbsTol',1e-12);
end
function testDiagnosticExportSnapshotAndReopening(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);before=oxygenFileSHA256(path);
D=buildBOIEventReviewData(R,3);folder=fullfile(root,'diagnostic-export');receipt=exportBOIEventReview(R,3,folder);
verifyEqual(t,receipt.Schema,'boi-event-review-export-9');
snapshot=load(fullfile(folder,'SelectedEventReview.mat'));verifyEqual(t,snapshot.Data,D);
J=jsondecode(fileread(fullfile(folder,'BaselineDiagnostic.json')));
verifyEqual(t,J.MethodID,'boi-baseline-linear-review-1');verifyEqual(t,J.Role,'review_only_not_saved_measurement');
verifyEqual(t,J.EventType,'surge');verifyEqual(t,J.SavedAmplitudeFraction,-.2,'AbsTol',1e-12);
verifyEqual(t,J.SavedAuditSHA256,before);verifyEqual(t,J.RawSourceSHA256,R.AnalysisInfo.RawSHA256);
F=readtable(fullfile(folder,'SelectedEventTrace.csv'));ev=F.MeasurementWindow==1;
q=(F.PreservedInputMean(ev)-F.DiagnosticLinearReference(ev))./F.DiagnosticLinearReference(ev);
verifyEqual(t,max(q),receipt.BaselineDiagnostic.AmplitudeFraction,'AbsTol',1e-12);
verifyEqual(t,receipt.SelectedEvent,table2struct(R.Audit(3,:)));
verifyEqual(t,oxygenFileSHA256(path),before);
again=loadBOIEventReview(path);verifyEqual(t,buildBOIEventReviewData(again,3),D);
checks=jsondecode(fileread(fullfile(folder,'ArtifactChecksums.json')));
for k=1:numel(checks),verifyEqual(t,oxygenFileSHA256(fullfile(folder,checks(k).Name)),checks(k).SHA256);end
end
function testDiagnosticGuiSelectionAndUnavailableState(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));
[fig,UI]=openBOIEventReview(path);closeFig=onCleanup(@()delete(fig));
UI.Select(3);UI.Tabs.SelectedTab=UI.BaselineTab;
verifyTrue(t,contains(UI.Baseline.Status.Text,'DIAGNOSTIC ONLY'));
verifyTrue(t,contains(UI.Baseline.Amplitudes.Text,'Saved amplitude: -20%'));
verifyEqual(t,numel(findall(UI.Baseline.ProjectionAxes,'Tag','BOIDiagnosticReference')),1);
verifyGreaterThan(t,UI.Baseline.ProjectionAxes.XLim(2),2);
UI.Select(1);UI.Select(3);
verifyEqual(t,numel(findall(UI.Baseline.ProjectionAxes,'Tag','BOIDiagnosticMeasurementBound')),2);
verifyEqual(t,numel(findall(UI.Baseline.ProjectionAxes,'Tag','BOIDiagnosticNativeBound')),2);
UI.Baseline.Back.ButtonPushedFcn([],[]);verifyNotEqual(t,UI.Tabs.SelectedTab,UI.BaselineTab);
R=UI.CurrentReview();R.Traces{1}.CleanBaselineFrames=[];D=buildBOIEventReviewData(R,1);UI.Baseline.Update(D);
verifyTrue(t,contains(UI.Baseline.Status.Text,'requires every sample'));
verifyEmpty(t,findall(UI.Baseline.ProjectionAxes,'Tag','BOIDiagnosticReference'));
verifyTrue(t,contains(UI.Baseline.Amplitudes.Text,'diagnostic: unavailable'));
verifyFalse(t,contains(UI.Baseline.Amplitudes.Text,'unavailable%'));
verifyEqual(t,numel(findall(UI.Baseline.ProjectionAxes,'Tag','BOIDiagnosticMeasurementBound')),2);
verifyEqual(t,string(UI.Baseline.BaselineAxes.Visible),"off");
end
function testDiagnosticSeparatesSerializedAuditDisagreement(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));S=load(path);
% Persist a supported saved-versus-audited disagreement for both signs.
S.Audit.StoredAmplitude([1 3])=[.4;-.4];S.Audit.StoredBaseline([1 3])=90;
S.Audit.MeasurementMatches([1 3])=false;save(path,'-struct','S');
R=loadBOIEventReview(path);before=oxygenFileSHA256(path);
[fig,UI]=openBOIEventReview(path);closeFig=onCleanup(@()delete(fig));
for index=[1 3]
    D=buildBOIEventReviewData(R,index);B=D.BaselineDiagnostic;
    verifyTrue(t,D.ReplayMatches&&D.BaselineReplayMatches);
    verifyFalse(t,B.SavedMeasurementMatchesAudit);
    verifyEqual(t,B.DifferenceFromAuditedAmplitude_pp,0,'AbsTol',1e-12);
    verifyEqual(t,abs(B.DifferenceFromSavedAmplitude_pp),20,'AbsTol',1e-12);
    verifyEqual(t,B.SavedBaseline,90);verifyEqual(t,B.AuditedBaseline,100);
    verifyEqual(t,D.Row,S.Audit(index,:));
    UI.Select(index);verifyTrue(t,contains(UI.Baseline.Status.Text,'AUDIT DISAGREEMENT'));
    verifyTrue(t,contains(UI.Baseline.Amplitudes.Text,'Reference sensitivity (line minus audited mean): 0 percentage points'));
    verifyEqual(t,findall(UI.Baseline.BaselineAxes,'Tag','BOIAuditedMeanReference').Value,100);
    verifyEqual(t,findall(UI.Baseline.BaselineAxes,'Tag','BOIStoredMeanReference').Value,90);
    folder=fullfile(root,sprintf('mismatch-%d',index));exportBOIEventReview(R,index,folder);
    J=jsondecode(fileread(fullfile(folder,'BaselineDiagnostic.json')));
    verifyEqual(t,J.Schema,'boi-baseline-diagnostic-2');verifyFalse(t,J.SavedMeasurementMatchesAudit);
    verifyEqual(t,J.DifferenceFromAuditedAmplitude_pp,0,'AbsTol',1e-12);
    verifyTrue(t,contains(J.SavedDifferenceRole,'not_reference_sensitivity'));
    verifyEqual(t,J.SavedBaseline,90);verifyEqual(t,J.AuditedBaseline,100);
    snapshot=load(fullfile(folder,'SelectedEventReview.mat'));verifyEqual(t,snapshot.Data,D);
    F=readtable(fullfile(folder,'SelectedEventTrace.csv'));
    verifyEqual(t,F.SignedFraction,D.Frames.SignedFraction,'AbsTol',1e-12);
    checks=jsondecode(fileread(fullfile(folder,'ArtifactChecksums.json')));
    for k=1:numel(checks),verifyEqual(t,oxygenFileSHA256(fullfile(folder,checks(k).Name)),checks(k).SHA256);end
end
UI.Select(2);verifyFalse(t,contains(UI.Baseline.Status.Text,'AUDIT DISAGREEMENT'));
verifyEmpty(t,findall(UI.Baseline.BaselineAxes,'Tag','BOIStoredMeanReference'));
verifyEqual(t,oxygenFileSHA256(path),before);
verifyEqual(t,buildBOIEventReviewData(loadBOIEventReview(path),3),buildBOIEventReviewData(R,3));
% Missing historical stored baseline remains unavailable, even with an audited mean.
S.Audit=removevars(S.Audit,'StoredBaseline');save(path,'-struct','S');
D=buildBOIEventReviewData(loadBOIEventReview(path),1);
verifyTrue(t,isnan(D.BaselineDiagnostic.SavedBaseline));verifyEqual(t,D.BaselineDiagnostic.AuditedBaseline,100);
UI.Baseline.Update(D);verifyEmpty(t,findall(UI.Baseline.BaselineAxes,'Tag','BOIStoredMeanReference'));
% Disagreement also remains visible when the diagnostic itself is unavailable.
R.Traces{1}.CleanBaselineFrames=[];D=buildBOIEventReviewData(R,1);UI.Baseline.Update(D);
verifyTrue(t,contains(UI.Baseline.Status.Text,'AUDIT DISAGREEMENT'));
verifyTrue(t,isnan(D.BaselineDiagnostic.DifferenceFromAuditedAmplitude_pp));
end
function testDiagnosticDisplaysNativeBoundsOutsideMeasurement(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));S=load(path);
S.Audit.DetectedEndFrame(1)=12;S.Traces{1}.DetectedFrames=(7:12)';save(path,'-struct','S');
[fig,UI]=openBOIEventReview(path);closeFig=onCleanup(@()delete(fig));
D=buildBOIEventReviewData(UI.CurrentReview(),1);
before=D.Frames.DiagnosticLinearReference;
for index=[1 2 1]
    UI.Select(index);bounds=findall(UI.Baseline.ProjectionAxes,'Tag','BOIDiagnosticNativeBound');
    verifyEqual(t,numel(bounds),2);
    verifyGreaterThan(t,min([bounds.Value]),UI.Baseline.ProjectionAxes.XLim(1));
    verifyLessThan(t,max([bounds.Value]),UI.Baseline.ProjectionAxes.XLim(2));
end
verifyEqual(t,find(D.Frames.MeasurementWindow),[7;8]);
verifyTrue(t,all(isnan(before(9:12)))); % Display expansion must not extend the fitted reference.
% Native onset before all plotted source samples, with baseline correctly unavailable.
S.Audit.DetectedStartFrame(1)=1;S.Traces{1}.DetectedFrames=(1:12)';
S.Traces{1}.CleanBaselineFrames=[];S.Audit.RecomputedBaseline(1)=NaN;
S.Audit.RecomputedAmplitude(1)=NaN;S.Audit.RecomputedStatus(1)="insufficient_clean_prebaseline";
save(path,'-struct','S');D=buildBOIEventReviewData(loadBOIEventReview(path),1);UI.Baseline.Update(D);
bounds=findall(UI.Baseline.ProjectionAxes,'Tag','BOIDiagnosticNativeBound');
verifyGreaterThan(t,min([bounds.Value]),UI.Baseline.ProjectionAxes.XLim(1));
verifyLessThan(t,max([bounds.Value]),UI.Baseline.ProjectionAxes.XLim(2));
verifyTrue(t,all(isnan(D.Frames.DiagnosticLinearReference)));
end
function testTimingSignalsAndExportRetainMeasurement(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);before=buildBOIEventReviewData(R,3);
S=load(path);S.AnalysisInfo.DenoisedFile='';
S.Traces{3}.DetectionDetrended=(1:30)-15;S.Traces{3}.Filtered=sin(1:30);S.Traces{3}.TimingTrace=2*cos(1:30);
save(path,'-struct','S');R=loadBOIEventReview(path);D=buildBOIEventReviewData(R,3);
verifyEqual(t,D.Row,before.Row);verifyEqual(t,D.ReplayedAmplitude,before.ReplayedAmplitude);
verifyEqual(t,rmfield(D.BaselineDiagnostic,'SavedAuditSHA256'),rmfield(before.BaselineDiagnostic,'SavedAuditSHA256'));
verifyEqual(t,D.Frames.CorrectedIntensity,((1:30)-15)');verifyEqual(t,D.Frames.FilteredDetectionScore,sin(1:30)');
verifyEqual(t,D.Frames.ExistingRemovedTrend,D.Frames.PreservedInputMean-D.Frames.CorrectedIntensity);
verifyEqual(t,D.TimingReview.Corrected.Role,'primary_timing_reference');verifyEqual(t,D.TimingReview.Site.Support,'saved_site_support_not_event_footprint');
folder=fullfile(root,'timing-export');receipt=exportBOIEventReview(R,3,folder);verifyEqual(t,receipt.Schema,'boi-event-review-export-9');
J=jsondecode(fileread(fullfile(folder,'TimingReview.json')));verifyEqual(t,J.SavedAuditSHA256,R.AuditSHA256);verifyEqual(t,J.PrimaryReference,'CorrectedIntensity');
verifyEqual(t,J.SelectedEvent.SiteID,D.Row.SiteID);verifyEqual(t,J.SelectedEvent.EventType,char(D.Row.EventType));
F=readtable(fullfile(folder,'SelectedEventTrace.csv'));verifyEqual(t,F.CorrectedIntensity,D.Frames.CorrectedIntensity);verifyEqual(t,F.SignedFraction,before.Frames.SignedFraction);
verifyEqual(t,F.ModeledTimeSec,(F.Frame-1)/R.AnalysisInfo.AnalysisParams.fs);
verifyTrue(t,any(strcmp({receipt.ReviewImplementation.Function},'buildBOITimingReviewData')));
checks=jsondecode(fileread(fullfile(folder,'ArtifactChecksums.json')));for k=1:numel(checks),verifyEqual(t,oxygenFileSHA256(fullfile(folder,checks(k).Name)),checks(k).SHA256);end
end
function testTimingMissingMalformedAndDifferentSource(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);D=buildBOIEventReviewData(R,1);
verifyEqual(t,D.TimingReview.Corrected.Status,'not_saved');verifyTrue(t,all(isnan(D.Frames.CorrectedIntensity)));verifyTrue(t,D.ReplayMatches);
R.Traces{1}.DetectionDetrended=ones(1,29);R.Traces{1}.Filtered=ones(5,6);R.Traces{1}.TimingTrace='not data';D=buildBOIEventReviewData(R,1);
verifyEqual(t,D.TimingReview.Corrected.Status,'invalid_saved_stage');verifyEqual(t,D.TimingReview.Filtered.Status,'invalid_saved_stage');verifyEqual(t,D.TimingReview.Site.Status,'invalid_saved_stage');
R.Traces{1}.DetectionDetrended=(1:30)';R.Traces{1}.DetectionDetrended(12)=NaN;R.Traces{1}.Filtered=zeros(30,1);D=buildBOIEventReviewData(R,1);
verifyEqual(t,D.TimingReview.Corrected.Status,'partial_nonfinite');verifyTrue(t,isnan(D.Frames.CorrectedIntensity(12)));verifyEqual(t,D.TimingReview.Filtered.Status,'available');
verifyTrue(t,all(isnan(D.Frames.ExistingRemovedTrend))); % Unknown source relationship must not be invented.
R.AnalysisInfo.DenoisedFile='different-detection.tif';D=buildBOIEventReviewData(R,1);verifyTrue(t,all(isnan(D.Frames.ExistingRemovedTrend)));verifyTrue(t,contains(D.TimingReview.RemovedTrend.Message,'different detection input'));
R.AnalysisInfo.DenoisedFile='';D=buildBOIEventReviewData(R,1);verifyTrue(t,isnan(D.Frames.ExistingRemovedTrend(12)));verifyEqual(t,D.Frames.ExistingRemovedTrend(1),99);
end
function testTimingGuiSynchronizationAndMissingStageReset(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));S=load(path);S.AnalysisInfo.DenoisedFile='';
S.Traces{1}.DetectionDetrended=(1:30)-15;S.Traces{1}.Filtered=sin(1:30);S.Traces{1}.TimingTrace=cos(1:30);save(path,'-struct','S');
[fig,UI]=openBOIEventReview(path);closeFig=onCleanup(@()delete(fig));UI.Tabs.SelectedTab=UI.TimingTab;
line=findall(UI.Timing.CorrectedAxes,'Tag','BOICorrectedTrace');verifyEqual(t,line.YData,((1:30)-15));
verifyEqual(t,sort([findall(UI.Timing.CorrectedAxes,'Tag','BOITimingMeasurementBound').Value]),[7 8]);
UI.Timing.Frame.Value=12;UI.Timing.Frame.ValueChangedFcn([],[]);verifyEqual(t,UI.Frame.Value,12);verifyTrue(t,contains(UI.Timing.FrameLabel.Text,'12 = 11 s'));
UI.Frame.Value=9;UI.Frame.ValueChangedFcn([],[]);verifyEqual(t,UI.Timing.Frame.Value,9);
UI.Timing.RawToggle.Value=true;UI.Timing.RawToggle.ValueChangedFcn([],[]);verifyEqual(t,numel(findall(UI.Timing.RawAxes,'Tag','BOIRemovedTrend')),1);
UI.Select(2);verifyEqual(t,UI.Timing.Frame.Value,15);verifyEmpty(t,findall(UI.Timing.CorrectedAxes,'Tag','BOICorrectedTrace'));verifyEmpty(t,findall(UI.Timing.ScoreAxes,'Tag','BOIFilteredScore'));verifyEmpty(t,findall(UI.Timing.RawAxes,'Tag','BOIRemovedTrend'));
verifyTrue(t,contains(UI.Timing.Status.Text,'was not saved'));verifyTrue(t,UI.CurrentReview().Audit.MeasurementMatches(2));
UI.Select(1);verifyEqual(t,numel(findall(UI.Timing.CorrectedAxes,'Tag','BOITimingSelectedFrame')),1);verifyEqual(t,numel(findall(UI.Timing.CorrectedAxes,'Tag','BOITimingNativeBound')),2);
UI.Timing.Back.ButtonPushedFcn([],[]);verifyNotEqual(t,UI.Tabs.SelectedTab,UI.TimingTab);
end
function a=humanAnnotation()
a=struct('Status','recognized','OnsetFrames',[5 6],'RecoveryFrames',[9 10], ...
    'PreferredOnsetFrame',6,'PreferredRecoveryFrame',[],'Reviewer','Developer fixture — not researcher evidence', ...
    'Reason','Synthetic test: uncertain shoulders; retain explicit alternatives.');
end
function testBoundaryRevisionsReopenAndExport(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);before=buildBOIEventReviewData(R,1);auditHash=oxygenFileSHA256(path);
a=humanAnnotation();p1=fullfile(root,'review-01.json');S1=saveBOIBoundaryReview(R,1,a,p1);firstHash=oxygenFileSHA256(p1);
a.OnsetFrames=6;a.Reason='Synthetic correction: remove 5 as an alternative.';
S2=saveBOIBoundaryReview(R,1,a,fullfile(root,'review-02.json'),S1);
verifyEqual(t,oxygenFileSHA256(p1),firstHash);verifyEqual(t,S2.Document.Revisions(2).PreviousAnnotation,S1.Document.Revisions(1).Annotation);
a.Status='not_recognized';a.OnsetFrames=[];a.RecoveryFrames=[];a.PreferredOnsetFrame=[];a.Reason='Synthetic non-recognition revision; old bounds retained only in history.';
S3=saveBOIBoundaryReview(R,1,a,fullfile(root,'review-03.json'),S2);
R.BoundaryReview=loadBOIBoundaryReview(R,S3.Path);D=buildBOIEventReviewData(R,1);
verifyEqual(t,D.ResearcherBoundaryReview.Status,'not_recognized');verifyEmpty(t,D.ResearcherBoundaryReview.Annotation.OnsetFrames);
verifyEqual(t,numel(D.ResearcherBoundaryReview.History),3);verifyEqual(t,D.Frames,before.Frames);verifyEqual(t,D.Row,before.Row);verifyEqual(t,D.BaselineDiagnostic,before.BaselineDiagnostic);verifyEqual(t,D.ReplayedAmplitude,before.ReplayedAmplitude);
verifyEqual(t,getBOIBoundaryReview(R,2).Status,'not_reviewed');
out=fullfile(root,'annotated-export');receipt=exportBOIEventReview(R,1,out);
verifyEqual(t,receipt.ResearcherBoundaryReview,D.ResearcherBoundaryReview);
reopened=loadBOIBoundaryReview(R,fullfile(out,'ResearcherBoundaryHistory.json'));verifyEqual(t,reopened.Document,S3.Document);
F=readtable(fullfile(out,'SelectedEventTrace.csv'));verifyEqual(t,F.SignedFraction,D.Frames.SignedFraction);
checks=jsondecode(fileread(fullfile(out,'ArtifactChecksums.json')));for k=1:numel(checks),verifyEqual(t,oxygenFileSHA256(fullfile(out,checks(k).Name)),checks(k).SHA256);end
verifyEqual(t,oxygenFileSHA256(path),auditHash);
end
function testTimingLoadsEmptyBoundaryRevisionAndClearsPriorMarks(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);
a=humanAnnotation();S=saveBOIBoundaryReview(R,1,a,fullfile(root,'recognized.json'));
[fig,UI]=openBOIEventReview(path);closeFig=onCleanup(@()delete(fig));
UI.LoadBoundaries(S.Path);before=buildBOIEventReviewData(UI.CurrentReview(),1);
verifyEqual(t,numel(findall(UI.Timing.CorrectedAxes,'Tag','BOIResearcherBound')),4);
a.Status='not_recognized';a.OnsetFrames=[];a.RecoveryFrames=[];
a.PreferredOnsetFrame=[];a.PreferredRecoveryFrame=[];
S=saveBOIBoundaryReview(R,1,a,fullfile(root,'not-recognized.json'),S);
UI.LoadBoundaries(S.Path);
for ax=[UI.Timing.CorrectedAxes UI.Timing.ScoreAxes UI.Timing.RawAxes]
    verifyEmpty(t,findall(ax,'Tag','BOIResearcherBound'));
    verifyEqual(t,numel(findall(ax,'Tag','BOITimingMeasurementBound')),2);
end
verifyTrue(t,contains(UI.Timing.Status.Text,'not_recognized'));
after=buildBOIEventReviewData(UI.CurrentReview(),1);verifyEqual(t,after.Row,before.Row);verifyEqual(t,after.Frames,before.Frames);
UI.Select(2);verifyTrue(t,contains(UI.Timing.Status.Text,'not_reviewed'));
end
function testBoundaryRejectsInvalidConflictingAndChangedEvidence(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);a=humanAnnotation();p=fullfile(root,'review.json');S=saveBOIBoundaryReview(R,1,a,p);h=oxygenFileSHA256(p);
verifyError(t,@()saveBOIBoundaryReview(R,1,a,p,S),'OxygenDynamics:BoundaryReviewOutputExists');verifyEqual(t,oxygenFileSHA256(p),h);
for v={0,31,6.5,NaN,[5 5]}
    b=a;b.OnsetFrames=v{1};verifyError(t,@()validateBOIBoundaryAnnotation(R,1,b),'OxygenDynamics:InvalidBoundaryReview');
end
b=a;b.PreferredOnsetFrame=4;verifyError(t,@()validateBOIBoundaryAnnotation(R,1,b),'OxygenDynamics:InvalidBoundaryReview');
b=a;b.RecoveryFrames=4;verifyError(t,@()validateBOIBoundaryAnnotation(R,1,b),'OxygenDynamics:InvalidBoundaryReview');
b=a;b.Status='not_recognized';verifyError(t,@()validateBOIBoundaryAnnotation(R,1,b),'OxygenDynamics:InvalidBoundaryReview');
b=a;b.Reason=' ';verifyError(t,@()validateBOIBoundaryAnnotation(R,1,b),'OxygenDynamics:InvalidBoundaryReview');
b=a;b.Status='uncertain';b.OnsetFrames=[];b.RecoveryFrames=[];b.PreferredOnsetFrame=[];verifyEqual(t,validateBOIBoundaryAnnotation(R,1,b),b);
J=S.Document;J.Revisions(1).Event.EventID=999;bad=fullfile(root,'wrong-event.json');writeBoundaryTestJSON(bad,J);
verifyError(t,@()loadBOIBoundaryReview(R,bad),'OxygenDynamics:InvalidBoundaryReview');
J=S.Document;J.AuditSHA256='wrong';writeBoundaryTestJSON(bad,J);verifyError(t,@()loadBOIBoundaryReview(R,bad),'OxygenDynamics:InvalidBoundaryReview');
J=S.Document;J.RawSourceSHA256='wrong';writeBoundaryTestJSON(bad,J);verifyError(t,@()loadBOIBoundaryReview(R,bad),'OxygenDynamics:InvalidBoundaryReview');
J=S.Document;J.Revisions(1).PreviousAnnotation=a;writeBoundaryTestJSON(bad,J);verifyError(t,@()loadBOIBoundaryReview(R,bad),'OxygenDynamics:InvalidBoundaryReview');
J=S.Document;J.Revisions(1).PreviousEventRevision=1;writeBoundaryTestJSON(bad,J);verifyError(t,@()loadBOIBoundaryReview(R,bad),'OxygenDynamics:InvalidBoundaryReview');
J=S.Document;J.Revisions(1).Annotation.Reason='Changed on disk';writeBoundaryTestJSON(p,J);
verifyError(t,@()saveBOIBoundaryReview(R,1,a,fullfile(root,'should-not-exist.json'),S),'OxygenDynamics:BoundaryReviewChanged');
R.BoundaryReview=S;verifyError(t,@()exportBOIEventReview(R,1,fullfile(root,'blocked-export')),'OxygenDynamics:BoundaryReviewChanged');verifyFalse(t,isfolder(fullfile(root,'blocked-export')));
S=load(path);S.AnalysisInfo.TestChange=true;save(path,'-struct','S');verifyError(t,@()saveBOIBoundaryReview(R,1,a,fullfile(root,'changed-audit.json')),'OxygenDynamics:EventReviewChanged');
end
function writeBoundaryTestJSON(path,J)
fid=fopen(path,'w');cleanup=onCleanup(@()fclose(fid));fprintf(fid,'%s',jsonencode(J));
end
function testBoundaryGuiDraftIsolationAndSavedOverlay(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));[fig,UI]=openBOIEventReview(path);closeFig=onCleanup(@()delete(fig));a=humanAnnotation();
UI.Boundaries.SetDraft(a);verifyTrue(t,UI.Boundaries.HasDrafts());
receipt=exportBOIEventReview(UI.CurrentReview(),1,fullfile(root,'draft-excluded-export'));verifyEqual(t,receipt.ResearcherBoundaryReview.Status,'not_reviewed');
UI.Select(2);verifyEqual(t,UI.Boundaries.Onset.Value,'');
UI.Select(1);verifyEqual(t,UI.Boundaries.ReadDraft(),a);verifyEmpty(t,findall(UI.Timing.CorrectedAxes,'Tag','BOIResearcherBound'));
UI.SaveBoundaries(fullfile(root,'gui-01.json'));verifyFalse(t,UI.Boundaries.HasDrafts());
verifyEqual(t,sort([findall(UI.Timing.CorrectedAxes,'Tag','BOIResearcherBound').Value]),[5 6 9 10]);
UI.Select(2);verifyEmpty(t,findall(UI.Timing.CorrectedAxes,'Tag','BOIResearcherBound'));
b=a;b.OnsetFrames=12;b.PreferredOnsetFrame=12;b.RecoveryFrames=18;UI.Boundaries.SetDraft(b);UI.Select(1);
a.OnsetFrames=6;a.Reason='Synthetic GUI correction';UI.Boundaries.SetDraft(a);UI.SaveBoundaries(fullfile(root,'gui-02.json'));
verifyTrue(t,UI.Boundaries.HasDrafts());UI.Select(2);verifyEqual(t,UI.Boundaries.ReadDraft(),b);UI.SaveBoundaries(fullfile(root,'gui-03.json'));
verifyFalse(t,UI.Boundaries.HasDrafts());verifyEqual(t,numel(UI.CurrentReview().BoundaryReview.Document.Revisions),3);
UI.Select(1);verifyEqual(t,sort([findall(UI.Timing.CorrectedAxes,'Tag','BOIResearcherBound').Value]),[6 9 10]);
[fig2,V]=openBOIEventReview(path);closeFig2=onCleanup(@()delete(fig2));V.LoadBoundaries(fullfile(root,'gui-03.json'));
verifyEqual(t,V.Boundaries.ReadDraft(),a);verifyTrue(t,any(contains(string(V.Boundaries.History.Value),'Synthetic GUI correction')));
V.Boundaries.Onset.Value='5:7';verifyError(t,@()V.Boundaries.ReadDraft(),'OxygenDynamics:InvalidBoundaryReview');
end
function testReviewedReferenceBothSignsContactsAndExport(t)
[path,root,masters]=fixture(true);cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);
before=buildBOIEventReviewData(R,1);a=humanAnnotation();a.OnsetFrames=25;a.PreferredOnsetFrame=25;a.RecoveryFrames=27;
S=saveBOIBoundaryReview(R,1,a,fullfile(root,'reference-01.json'));
a.OnsetFrames=7;a.PreferredOnsetFrame=7;a.RecoveryFrames=8;
S=saveBOIBoundaryReview(R,3,a,fullfile(root,'reference-02.json'),S);R.BoundaryReview=S;
P=buildBOIReviewedReferencePreview(R,1);verifyEqual(t,P.Status,'native_sources_required');verifyTrue(t,all(isnan(P.Frames.OptionAEligible)));
R=attachBOIReferenceSources(R,masters{:});P=buildBOIReviewedReferencePreview(R,1);
verifyEqual(t,P.Windows.CandidateFrames,(5:24)');verifyEqual(t,P.Windows.OptionAEligibleCount,18);verifyEqual(t,P.Windows.NativeExcludedFrames,[7;8]);
verifyEqual(t,P.Frames.NativeOverlapPixels(P.Frames.Frame==7),2); % Both signs overlap, count the union once.
verifyEqual(t,height(P.Contributors),4);verifyEqual(t,sort(unique(P.Contributors.AuditRow)),[1;3]);
verifyEqual(t,P.Windows.ReviewedContactFrames,[7;8]);verifyEmpty(t,P.Windows.OptionBAdditionalExcludedFrames);
verifyFalse(t,P.NewBaselineOrAmplitudeCalculations);after=buildBOIEventReviewData(R,1);verifyEqual(t,after.Row,before.Row);verifyEqual(t,after.Frames,before.Frames);
folder=fullfile(root,'reference-export');receipt=exportBOIEventReview(R,1,folder);
verifyEqual(t,receipt.ReviewedReferencePreview.Windows.OptionAEligibleCount,18);
F=readtable(fullfile(folder,'ReviewedReferenceFrames.csv'));verifyEqual(t,F.NativeOverlapPixels,P.Frames.NativeOverlapPixels);
checks=jsondecode(fileread(fullfile(folder,'ArtifactChecksums.json')));for k=1:numel(checks),verifyEqual(t,oxygenFileSHA256(fullfile(folder,checks(k).Name)),checks(k).SHA256);end
end
function testReviewedReferenceTruncationAlternativesAndNonfinite(t)
[path,root,masters]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));V=load(path);V.Traces{1}.Raw(10)=NaN;save(path,'-struct','V');R=loadBOIEventReview(path);
a=humanAnnotation();a.OnsetFrames=[1 5 25];a.PreferredOnsetFrame=25;a.RecoveryFrames=[27 28];
R.BoundaryReview=saveBOIBoundaryReview(R,1,a,fullfile(root,'review.json'));R=attachBOIReferenceSources(R,masters{:});P=buildBOIReviewedReferencePreview(R,1);
verifyEqual(t,[P.Windows.OnsetFrame],[1 5 25]);verifyEqual(t,[P.Windows.MissingBeforeRecording],[20 16 0]);
verifyEqual(t,[P.Windows.OptionAEligibleCount],[0 4 17]);verifyEqual(t,P.Windows(3).NonfiniteFrames,10);
verifyEqual(t,P.Windows(3).RecoveryFrames,[27 28]);verifyEmpty(t,P.Windows(3).PreferredRecoveryFrame);verifyFalse(t,any([P.Windows.OptionASampleComplete]));
verifyTrue(t,all(P.Frames.Frame>=1));verifyFalse(t,isfield(P,'BaselineValue'));verifyFalse(t,isfield(P,'Amplitude'));
end
function testReviewedReferenceRejectsPartialWrongAndChangedSources(t)
[path,root,masters]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);
verifyError(t,@()attachBOIReferenceSources(R,masters{2},masters{1}),'OxygenDynamics:ReferenceSourceMismatch');
V=load(masters{1});V.Table_OxygenSinks_Out.FramePixels{1}{7}=[];bad=fullfile(root,'bad.mat');save(bad,'-struct','V');
verifyError(t,@()attachBOIReferenceSources(R,bad,masters{2}),'OxygenDynamics:ReferenceSourceMismatch');
a=humanAnnotation();R.BoundaryReview=saveBOIBoundaryReview(R,1,a,fullfile(root,'review.json'));R=attachBOIReferenceSources(R,masters{:});
fid=fopen(masters{1},'a');fprintf(fid,'changed');fclose(fid);
verifyError(t,@()buildBOIReviewedReferencePreview(R,1),'OxygenDynamics:ReferencePreviewChanged');
folder=fullfile(root,'blocked');verifyError(t,@()exportBOIEventReview(R,1,folder),'OxygenDynamics:ReferencePreviewChanged');verifyFalse(t,isfolder(folder));
end
function testReviewedReferenceGuiSavedOnlyAndContributorNavigation(t)
[path,root,masters]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));[fig,UI]=openBOIEventReview(path);closeFig=onCleanup(@()delete(fig));
a=humanAnnotation();a.OnsetFrames=25;a.PreferredOnsetFrame=25;a.RecoveryFrames=27;
UI.Boundaries.SetDraft(a);verifyEqual(t,UI.Reference.Data().Status,'no_saved_onset');UI.SaveBoundaries(fullfile(root,'review.json'));
verifyEqual(t,UI.Reference.Data().Status,'native_sources_required');UI.AttachReferenceSources(masters{:});
verifyEqual(t,UI.Reference.Data().Windows.OptionAEligibleCount,18);verifyEqual(t,UI.Reference.Onset.Value,25);
UI.Reference.Contributors.CellSelectionCallback([],struct('Indices',[2 1]));chosen=UI.Reference.Contributors.Data.AuditRow(2);
UI.Reference.Open.ButtonPushedFcn([],[]);verifyEqual(t,UI.List.Selection,chosen);verifyEqual(t,UI.Tabs.SelectedTab,UI.TimingTab);
UI.Select(1);a.OnsetFrames=24;a.PreferredOnsetFrame=24;UI.Boundaries.SetDraft(a);verifyEqual(t,UI.Reference.Data().Windows.OnsetFrame,25);
UI.Select(2);verifyEqual(t,UI.Reference.Data().Status,'no_saved_onset');verifyEmpty(t,UI.Reference.Frames.Data);
UI.Select(1);verifyError(t,@()UI.AttachReferenceSources(masters{2},masters{1}),'OxygenDynamics:ReferenceSourceMismatch');
verifyEqual(t,UI.Reference.Data().Status,'native_sources_required');verifyTrue(t,all(isnan(UI.Reference.Frames.Data.OptionAEligible)));
end

function [R,jpath,J]=referenceJudgmentFixture(R,root)
a=humanAnnotation();a.OnsetFrames=[24 25];a.PreferredOnsetFrame=25;a.RecoveryFrames=27;
R.BoundaryReview=saveBOIBoundaryReview(R,1,a,fullfile(root,'human-boundary.json'));
B=getBOIBoundaryReview(R,1);
J=struct('Schema','boi-researcher-reference-acceptance-1','DecisionID','SYNTHETIC-ONLY', ...
    'Reviewer','Synthetic fixture','RecordedUTC','2026-09-15T00:00:00Z', ...
    'BoundaryReviewSHA256',R.BoundaryReview.SHA256,'AuditRow',1,'SavedEvent',B.Event, ...
    'BoundaryAnnotationUnchanged',B.Annotation,'AcceptedReferenceFrames',(7:18)', ...
    'AcceptedSampleCount',12,'ReferenceJudgment','accepted_as_shorter_event_specific_pre_event_reference');
jpath=fullfile(root,'reference.json');writeBoundaryTestJSON(jpath,J);
end
function testReferenceJudgmentsSeparateOverlapAlternativesAndExport(t)
[path,root,masters]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);
[R,jpath]=referenceJudgmentFixture(R,root);before=buildBOIEventReviewData(R,1);
R=loadBOIReferenceJudgments(R,{jpath});P=buildBOIReviewedReferencePreview(R,1);
verifyTrue(t,isnan(P.Windows(2).ResearcherNativeEligibleCount));
R=attachBOIReferenceSources(R,masters{:});P=buildBOIReviewedReferencePreview(R,1);
verifyEqual(t,[P.Windows.OptionAEligibleCount],[18 18]);verifyEqual(t,P.Windows(2).ResearcherSampleCount,12);
verifyEqual(t,P.Windows(2).ResearcherNativeEligibleCount,10);verifyFalse(t,P.Windows(2).ResearcherMeetsOriginalSampleCount);
verifyTrue(t,all(isnan(P.Frames.ResearcherSelectedReference(P.Frames.OnsetFrame==24))));
F=P.Frames(P.Frames.OnsetFrame==25,:);verifyEqual(t,F.Frame(F.ResearcherSelectedReference==1),(7:18)');
verifyEqual(t,F.OptionAEligible(ismember(F.Frame,[7 8])),[0;0]);
after=buildBOIEventReviewData(R,1);verifyEqual(t,after,before);
out=fullfile(root,'human-export');receipt=exportBOIEventReview(R,1,out);
verifyEqual(t,receipt.Schema,'boi-event-review-export-9');
X=load(fullfile(out,'SelectedEventReview.mat'));verifyEqual(t,X.Data,before);verifyEqual(t,X.ReviewedReferencePreview,P);
checks=jsondecode(fileread(fullfile(out,'ArtifactChecksums.json')));for k=1:numel(checks),verifyEqual(t,oxygenFileSHA256(fullfile(out,checks(k).Name)),checks(k).SHA256);end
end
function testReferenceJudgmentsRejectStaleDuplicateAndMalformed(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);[R,jpath,J]=referenceJudgmentFixture(R,root);
verifyError(t,@()loadBOIReferenceJudgments(R,{jpath,jpath}),'OxygenDynamics:ReferenceJudgmentMismatch');
for kind=1:4
    bad=J;
    switch kind
        case 1,bad.AcceptedReferenceFrames=[7;7];bad.AcceptedSampleCount=2;
        case 2,bad.AcceptedReferenceFrames=25;bad.AcceptedSampleCount=1;
        case 3,bad.BoundaryReviewSHA256='wrong';
        case 4,bad.SavedEvent.SiteID=99;
    end
    p=fullfile(root,sprintf('bad-%d.json',kind));writeBoundaryTestJSON(p,bad);
    verifyError(t,@()loadBOIReferenceJudgments(R,p),'OxygenDynamics:ReferenceJudgmentMismatch');
end
R=loadBOIReferenceJudgments(R,jpath);J.Reviewer='changed';writeBoundaryTestJSON(jpath,J);
verifyError(t,@()buildBOIReviewedReferencePreview(R,1),'OxygenDynamics:ReferenceJudgmentChanged');
out=fullfile(root,'blocked');verifyError(t,@()exportBOIEventReview(R,1,out),'OxygenDynamics:ReferenceJudgmentChanged');verifyFalse(t,isfolder(out));
end
function testReferenceJudgmentsGuiSelectionAndFailedReplacement(t)
[path,root,masters]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);[R,jpath]=referenceJudgmentFixture(R,root);
[fig,UI]=openBOIEventReview(path);closeFig=onCleanup(@()delete(fig));UI.LoadBoundaries(R.BoundaryReview.Path);UI.AttachReferenceSources(masters{:});UI.LoadReferenceJudgments(jpath);
verifyTrue(t,contains(UI.Reference.Judgment.Text,'12 samples'));
verifyEqual(t,sum(UI.Reference.Frames.Data.ResearcherSelectedReference==1),12);
UI.Reference.Onset.Value=24;UI.Reference.Onset.ValueChangedFcn([],[]);
verifyTrue(t,contains(UI.Reference.Judgment.Text,'No reference judgment'));verifyTrue(t,all(isnan(UI.Reference.Frames.Data.ResearcherSelectedReference)));
UI.Select(2);verifyEmpty(t,UI.Reference.Data().ResearcherJudgments);
UI.Select(1);verifyError(t,@()UI.LoadReferenceJudgments({jpath,jpath}),'OxygenDynamics:ReferenceJudgmentMismatch');
verifyEmpty(t,UI.Reference.Data().ResearcherJudgments);verifyTrue(t,contains(UI.Reference.Judgment.Text,'No reference judgment'));
end

function testReferenceFrameJudgmentCompletenessAndMissingState(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);[R,jpath,J]=referenceJudgmentFixture(R,root);
B=getBOIBoundaryReview(R,1);J.Schema='boi-researcher-reference-frame-judgment-1';
J.PreferredOnsetFrame=25;J.EligibleFramesWithExplicitJudgments=(5:24)';J.CandidateFrames=(5:24)';
J.RemainingNativeExcludedFrames=[];J.EligibleCountWithExplicitJudgments=20;J.FullReferenceAvailableUnderRemainingRules=true;
J.RecoveryAlternativesFrames=B.Annotation.RecoveryFrames;J.PreferredRecoveryFrame=B.Annotation.PreferredRecoveryFrame;
writeBoundaryTestJSON(jpath,J);attached=loadBOIReferenceJudgments(R,jpath);P=buildBOIReviewedReferencePreview(attached,1);
verifyEqual(t,P.Windows(2).ResearcherSampleCount,20);verifyTrue(t,P.Windows(2).ResearcherMeetsOriginalSampleCount);
verifyTrue(t,isnan(P.Windows(1).ResearcherMeetsOriginalSampleCount));verifyTrue(t,isnan(P.Windows(2).ResearcherNativeEligibleCount));
J.RemainingNativeExcludedFrames=8;writeBoundaryTestJSON(jpath,J);
verifyError(t,@()loadBOIReferenceJudgments(R,jpath),'OxygenDynamics:ReferenceJudgmentMismatch');
end

function testReviewedOpticalAlternativesAndExactExport(t)
[path,root,masters]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);[R,jpath]=referenceJudgmentFixture(R,root);
R=loadBOIReferenceJudgments(R,jpath);verifyEqual(t,buildBOIReviewedOpticalPreview(R,1).Status,'native_sources_required');
R=attachBOIReferenceSources(R,masters{:});before=buildBOIEventReviewData(R,1);O=buildBOIReviewedOpticalPreview(R,1);
verifyEqual(t,numel(O.Intervals),2);verifyEqual(t,O.Intervals(1).Status,'unavailable_no_accepted_reference');
m=O.Intervals(2);verifyEqual(t,m.ReferenceFrames,(7:18)');verifyEqual(t,m.ReferenceSampleCount,12);verifyEqual(t,m.ReferenceMean,mean(double(R.Traces{1}.Raw(7:18))),'AbsTol',1e-12);
verifyEqual(t,m.NativeEligibleWithinSelectedReference,10);verifyEqual(t,m.Status,'computed_exploratory');verifyLessThan(t,m.SavedSignDirectionalAmplitudeFraction,0);
out=fullfile(root,'optical-export');receipt=exportBOIEventReview(R,1,out);X=load(fullfile(out,'SelectedEventReview.mat'));
verifyEqual(t,X.Data,before);verifyEqual(t,X.ReviewedOpticalPreview,O);verifyEqual(t,receipt.Schema,'boi-event-review-export-9');
F=readtable(fullfile(out,'ReviewedOpticalSamples.csv'));verifyEqual(t,F.Frame(F.Interval==2&F.AcceptedReference==1),m.ReferenceFrames);
verifyEqual(t,F.SignedFraction(F.Interval==2&F.AcceptedReference==0),m.SignedFraction,'AbsTol',1e-14);
checks=jsondecode(fileread(fullfile(out,'ArtifactChecksums.json')));for k=1:numel(checks),verifyEqual(t,oxygenFileSHA256(fullfile(out,checks(k).Name)),checks(k).SHA256);end
end
function testReviewedOpticalGuiResetsUnavailableAndChangedJudgment(t)
[path,root,masters]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIEventReview(path);[R,jpath,J]=referenceJudgmentFixture(R,root);
[fig,UI]=openBOIEventReview(path);c=onCleanup(@()delete(fig));UI.LoadBoundaries(R.BoundaryReview.Path);UI.AttachReferenceSources(masters{:});UI.LoadReferenceJudgments(jpath);
verifyEqual(t,UI.Optical.Choice.Value,2);verifyTrue(t,contains(UI.Optical.Summary.Text,'12 samples'));
UI.Optical.Choice.Value=1;UI.Optical.Choice.ValueChangedFcn([],[]);verifyTrue(t,contains(UI.Optical.Summary.Text,'No accepted reference'));
verifyEmpty(t,findall(UI.Optical.RawAxes,'Tag','BOIReviewedReferenceMean'));
verifyEqual(t,UI.Optical.FractionAxes.XLim,[23.5 27.5]);verifyEmpty(t,findall(UI.Optical.FractionAxes,'Tag','BOIOpticalZero'));
verifyEqual(t,numel(findall(UI.Optical.FractionAxes,'Tag','BOIOpticalUnavailable')),1);
UI.Select(2);verifyEmpty(t,UI.Optical.Results.Data);verifyEqual(t,UI.Optical.Data().Status,'no_saved_interval');
UI.Select(1);J.Reviewer='changed';writeBoundaryTestJSON(jpath,J);UI.Optical.Choice.ValueChangedFcn([],[]);
verifyEmpty(t,UI.Optical.Data());verifyEmpty(t,UI.Optical.Results.Data);verifyTrue(t,contains(UI.Optical.Summary.Text,'unavailable'));
out=fullfile(root,'stale-optical');verifyError(t,@()exportBOIEventReview(UI.CurrentReview(),1,out),'OxygenDynamics:ReferenceJudgmentChanged');verifyFalse(t,isfolder(out));
end
