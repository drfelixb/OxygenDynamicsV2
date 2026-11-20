function tests=testBOIConnectedReview
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function [statsPath,auditPath,root,masters]=fixture
root=tempname;mkdir(root);source=fullfile(root,'source.tif');raw=100*ones(4,5,80,'uint16');
raw(1,1,27:28)=80;raw(3,1,27:28)=80;raw(2,1,55:56)=60;
for f=1:80,if f==1,imwrite(raw(:,:,f),source);else,imwrite(raw(:,:,f),source,'WriteMode','append');end;end
c=cell(1,80);c(27:28)={1};c{27}=[1;3];c(55:56)={2};
Sites=table("source-R",1,{c},{[4 5]},80,1,{[27 55]},{[2 2]},{80},{(1:20)'}, ...
 'VariableNames',{'RecordingID','SiteID','FramePixels','FrameSize','NFrames','SampleF','Start','Duration','RecAreaSize','EligibleTissuePixels'});
E=table(repmat("source-R",2,1),[1;1],[1;2],[27;55],[28;56],[100;100],["valid";"valid"],[20;20],[.2;.4],repmat("Unknown",2,1), ...
 'VariableNames',{'RecordingID','SinkID','EventID','StartFrame','EndFrame','BaselineValue','BaselineStatus','BaselineValidSamples','NormOxySinkAmp','Condition'});
E.StartSec=E.StartFrame-1;E.EndSec=E.EndFrame;E.StatsRecordingIndex=ones(2,1);
[A,T]=auditOxygenEventFootprints(Sites,E,Sites,raw,20,'sink');
Table_OxygenSinks_Out=Sites;Table_OxygenSinkEvents_Out=E;
G=renamevars(E,{'SinkID','NormOxySinkAmp'},{'SurgeID','NormOxySurgeAmp'});G.NormOxySurgeAmp=-G.NormOxySurgeAmp;
GS=renamevars(Sites,{'Start','Duration','RecAreaSize'},{'Start_Surge','Duration_Surge','RecAreaSize_Surge'});
[B,U]=auditOxygenEventFootprints(GS,G,Sites,raw,20,'surge');
Table_OxygenSurges_Out=GS;Table_OxygenSurgeEvents_Out=G;Audit=[A;B];Traces=[T;U];
contract=oxygenPipelineContract();
AnalysisInfo=struct('RawFile',source,'RawSHA256',oxygenFileSHA256(source),'DenoisedFile','','DenoisedSHA256','', ...
 'NFrames',80,'FrameSize',[4 5],'AnalysisParams',createOxygenMasterParams(2,1),'RecordingID','source-R', ...
 'SinkEligibleTissuePixels',(1:20)','SurgeEligibleTissuePixels',(1:20)','RecordingAreaUm2',80,'SurgeRecordingAreaUm2',80, ...
 'PipelineContract',contract,'AnalysisSchemaVersion',contract.Schema);
Audit.SourceRawSHA256=repmat(string(AnalysisInfo.RawSHA256),4,1);auditPath=fullfile(root,'event-amplitude-audit.mat');save(auditPath,'Audit','Traces','AnalysisInfo');
mkdir(fullfile(root,'OxygenSinks_Output'));mkdir(fullfile(root,'OxygenSurges_Output'));
masters={fullfile(root,'OxygenSinks_Output','OxygenSinks_UrefinedTest.mat'),fullfile(root,'OxygenSurges_Output','OxygenSurgesTest.mat')};
save(masters{1},'AnalysisInfo','Table_OxygenSinks_Out','Table_OxygenSinkEvents_Out');save(masters{2},'AnalysisInfo','Table_OxygenSurges_Out','Table_OxygenSurgeEvents_Out');
[C,RecordingInputQC,RecordingFrameExposure]=createBOIRecordingInputContract(AnalysisInfo,"portable-R",[4 5]);BOIInputContracts={C};
RecordingRegistry=table("portable-R",{'M'},{'Unknown'},{'Unknown'},{'Unknown'},{'Unknown'},false,80,1,80,80,2,"loaded",string(AnalysisInfo.RawSHA256), ...
 'VariableNames',{'RecordingID','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim','NFrames','SampleF','RecordingDuration_sec','RecordingArea_um2','PixelSize','AnalysisStatus','RawSHA256'});
Sites.RecordingID="portable-R";GS.RecordingID="portable-R";E.RecordingID(:)="portable-R";G.RecordingID(:)="portable-R";
X=table(["portable-R";"portable-R"],["whole";"partial"],[0;26.5],[80;27.5],'VariableNames',{'RecordingID','WindowID','StartSec','EndSec'});
[RecordingWindowMetrics,WindowFrameIngredients]=createOxygenAnalysisWindows(RecordingRegistry,Sites,E,X);
[SurgeRecordingWindowMetrics,SurgeWindowFrameIngredients]=createBOISurgeAnalysisWindows(RecordingRegistry,BOIInputContracts,GS,G,X);
Table_OxygenSinkEvents_OutCombo=E;Table_OxygenSurgeEvents_OutCombo=G;StatsInfo=struct('Recordings',struct('Folder','source-R'));
statsPath=fullfile(root,'DataOutput.mat');save(statsPath,'RecordingRegistry','BOIInputContracts','RecordingInputQC','RecordingFrameExposure','RecordingWindowMetrics','WindowFrameIngredients', ...
 'SurgeRecordingWindowMetrics','SurgeWindowFrameIngredients','Table_OxygenSinkEvents_OutCombo','Table_OxygenSurgeEvents_OutCombo','StatsInfo');
end
function testMappedIdentityBothSignsAndPartialWindow(t)
[p,a,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));W=loadBOIWindowReview(p);
for kind={'sink','surge'}
 [R,k]=linkBOIWindowEventReview(W,2,1,a,kind{1});D=buildBOIEventReviewData(R,k);
 verifyEqual(t,D.WindowLink.StatsRecordingID,'portable-R');verifyEqual(t,D.WindowLink.AuditRecordingID,'source-R');
 verifyEqual(t,D.WindowLink.OverlapSec,1);verifyFalse(t,D.WindowLink.OnsetInWindow);verifyTrue(t,D.WindowLink.OngoingAtWindowStart);
 verifyTrue(t,D.ReplayMatches);other=buildBOIEventReviewData(R,2);verifyFalse(t,isfield(other,'WindowLink'));
end
[R,k]=linkBOIWindowEventReview(W,1,2,a,'surge');verifyEqual(t,R.Audit.EventID(k),2);verifyEqual(t,R.Audit.StoredAmplitude(k),-.4);
end
function testMappingAndMeasurementMismatch(t)
[p,a,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));W=loadBOIWindowReview(p);
W.StatsInfo.Recordings.Folder='other';verifyError(t,@()linkBOIWindowEventReview(W,1,1,a),'OxygenDynamics:WindowEventIdentity');
W=loadBOIWindowReview(p);W.Table_OxygenSinkEvents_OutCombo.BaselineValue(1)=99;
verifyError(t,@()linkBOIWindowEventReview(W,1,1,a),'OxygenDynamics:WindowEventMeasurement');
W=loadBOIWindowReview(p);W.BOIInputContracts{1}.PixelSizeUm=3;
verifyError(t,@()linkBOIWindowEventReview(W,1,1,a),'OxygenDynamics:WindowEventSource');
W=loadBOIWindowReview(p);W.BOIInputContracts{1}.SurgeEligibleTissuePixels=[1;2];
verifyError(t,@()linkBOIWindowEventReview(W,1,1,a),'OxygenDynamics:WindowEventSource');
end
function testConnectedExportAndChangedResults(t)
[p,a,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));W=loadBOIWindowReview(p);[R,k]=linkBOIWindowEventReview(W,2,1,a,'surge');
out=fullfile(root,'export');receipt=exportBOIEventReview(R,k,out);verifyEqual(t,receipt.WindowLink.WindowID,'partial');
verifyEqual(t,receipt.WindowLink.ResultsSHA256,W.SHA256);verifyEqual(t,receipt.SelectedEvent.EventType,"surge");
S=load(p);S.Note='changed';save(p,'-struct','S');
verifyError(t,@()exportBOIEventReview(R,k,fullfile(root,'blocked')),'OxygenDynamics:WindowReviewChanged');
verifyFalse(t,isfolder(fullfile(root,'blocked')));verifyError(t,@()linkBOIWindowEventReview(W,1,1,a),'OxygenDynamics:WindowReviewChanged');
end
function testWindowGuiToEventAndBack(t)
[p,a,root,masters]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));[fig,UI]=openBOIWindowReview(p);closeFig=onCleanup(@()delete(fig));
UI.SelectSign('surge');UI.Select(2);UI.SelectEvent(1);UI.ConnectAudit(a);[ef,eu]=UI.OpenEvent();closeEvent=onCleanup(@()delete(ef));
verifyEqual(t,eu.List.Data.Sign(eu.List.Selection),"surge");verifyTrue(t,contains(eu.Detail.Value{1},'CONNECTED WINDOW'));
eu.AttachNative(masters{2});verifyEqual(t,eu.Overlay.Value,'native');verifyTrue(t,contains(eu.ImageStatus.Text,'checksums matched'));
eu.ReturnToWindow.ButtonPushedFcn([],[]);verifyEqual(t,UI.Sign.Value,'surge');verifyEqual(t,UI.Windows.Selection,2);
end
function testAuditCreationReceiptAndOriginalPreservation(t)
[p,a,root,masters]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));before=oxygenFileSHA256(a);out=fullfile(root,'created');
new=createBOIEventAudit(root,out);R=loadBOIEventReview(new);verifyTrue(t,isfield(R,'AuditCreationReceipt'));
verifyEqual(t,R.AuditCreationReceipt.EventCount,4);verifyEqual(t,R.AuditCreationReceipt.MeasurementMismatches,0);
verifyEqual(t,oxygenFileSHA256(a),before);W=loadBOIWindowReview(p);[R,k]=linkBOIWindowEventReview(W,1,1,new);
R=attachBOINativeMasks(R,k,masters{1});verifyTrue(t,contains(R.NativeMasks{k}.Association,'creation receipt'));
receipt=exportBOIEventReview(R,k,fullfile(root,'created-export'));verifyTrue(t,isfield(receipt,'AuditCreationReceipt'));
verifyError(t,@()createBOIEventAudit(root,out),'OxygenDynamics:AuditOutputExists');
S=load(masters{1});S.Note='changed';save(masters{1},'-struct','S');
verifyError(t,@()attachBOINativeMasks(R,k,masters{1}),'OxygenDynamics:NativeMaskProvenance');
end
function testAuditFailureRecordAndReceiptMismatch(t)
[~,a,root,masters]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));
S=load(masters{2});S.AnalysisInfo.RawSHA256='wrong';save(masters{2},'-struct','S');out=fullfile(root,'failed');
verifyError(t,@()createBOIEventAudit(root,out),'OxygenDynamics:AuditSourceMismatch');verifyTrue(t,isfile(fullfile(out,'AuditCreationFailure.json')));
copyfile(a,fullfile(out,'event-amplitude-audit.mat'));verifyError(t,@()loadBOIEventReview(fullfile(out,'event-amplitude-audit.mat')),'OxygenDynamics:IncompleteEventAudit');
fid=fopen(fullfile(root,'AuditCreationReceipt.json'),'w');fprintf(fid,'{"Schema":"boi-created-event-audit-1","AuditSHA256":"wrong","SourceSHA256":"wrong","MasterSHA256":["a","b"]}');fclose(fid);
verifyError(t,@()loadBOIEventReview(a),'OxygenDynamics:InvalidEventReview');
end
