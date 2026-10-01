function tests=testBOISurgeWindows
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function [R,C,S,E,windows]=fixture
R=table("R",{'M'},{'Awake'},{'Unknown'},{'Unknown'},{'Unknown'},false,4,1,4,8,2,"loaded","hash", ...
    'VariableNames',{'RecordingID','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim', ...
    'NFrames','SampleF','RecordingDuration_sec','RecordingArea_um2','PixelSize','AnalysisStatus','RawSHA256'});
C={struct('Schema','boi-recording-input-1','RecordingID','R','RawSHA256','hash', ...
    'NFrames',4,'SampleHz',1,'PixelSizeUm',2,'FrameSize',[3 4], ...
    'SinkEligibleTissuePixels',[1;2],'SurgeEligibleTissuePixels',[1;2;3;4;5;6], ...
    'FrameTimingStatus','uniform_confirmed_from_acquisition_evidence','TissueValidityStatus','not_established')};
% Recurrence at site 1; overlap with site 2 counts once, pixel 9 lies outside support.
P={[1;2],[2;3;9],[],[4]};Q={[],[3;4],[],[]};
S=table(["R";"R"],{[1 4];2},{[2 1];1},{24;24},{P;Q},{(1:6)';(1:6)'}, ...
    'VariableNames',{'RecordingID','Start_Surge','Duration_Surge','RecAreaSize_Surge','FramePixels','EligibleTissuePixels'});
E=table(repmat("R",3,1),[1;1;2],[1;2;1],[0;3;1],[2;4;2],[-.2;NaN;10],[8;4;8], ...
    'VariableNames',{'RecordingID','SurgeID','EventID','StartSec','EndSec','NormOxySurgeAmpPercent','EventArea_um2'});
windows=table(["R";"R"],["whole";"partial"],[0;.5],[4;2.5], ...
    'VariableNames',{'RecordingID','WindowID','StartSec','EndSec'});
end
function testUnequalSupportOverlapsAndRecurrence(t)
[R,C,S,E,X]=fixture;originalR=R;originalE=E;
[W,F]=createBOISurgeAnalysisWindows(R,C,S,E,X);
verifyEqual(t,R,originalR);verifyEqual(t,E,originalE);
verifyEqual(t,W.AreaUm2,[24;24]);verifyEqual(t,W.CoveredAreaTime_um2_sec,[24;16]);
verifyEqual(t,W.AnalyzedTissueTime_um2_sec,[96;48]);verifyEqual(t,W.MeanOccupiedTissueFraction,[.25;1/3],'AbsTol',1e-14);
verifyEqual(t,W.EventOnsets,[3;1]);verifyEqual(t,W.ActiveEventSeconds,[4;2.5]);
verifyEqual(t,W.AcquisitionStartOnsetsCounted,[1;0]);verifyEqual(t,W.OngoingAtWindowStart,[0;1]);
verifyEqual(t,F.WindowOverlapSec(F.WindowID=="partial"),[.5;1;.5]);
verifyEqual(t,F.OccupiedArea_um2(F.WindowID=="whole"),[8;12;0;4]);
verifyTrue(t,all(isnan(W.AmplitudeAreaTimePercent_um2_sec)));
verifyTrue(t,all(W.CompositeStatus=="not_defined_for_surge"));
% Changing amplitudes cannot silently exclude detections or affect these measures.
E.NormOxySurgeAmpPercent(:)=100;[A,B]=createBOISurgeAnalysisWindows(R,C,S,E,X);
verifyEqual(t,A,W);verifyEqual(t,B,F);
end
function testSupportIdentityAndClockGuards(t)
[R,C,S,E,X]=fixture;D=C;D{1}.SampleHz=2;
verifyError(t,@()createBOISurgeAnalysisWindows(R,D,S,E,X),'OxygenDynamics:InputContractIdentity');
D=C;D{1}.RawSHA256='other';verifyError(t,@()createBOISurgeAnalysisWindows(R,D,S,E,X),'OxygenDynamics:InputContractIdentity');
D=C;D{1}.SurgeEligibleTissuePixels=[1;2;3;4;5;7];
verifyError(t,@()createBOISurgeAnalysisWindows(R,D,S,E,X),'OxygenDynamics:TissueAreaMismatch');
D=C;D{1}.SurgeEligibleTissuePixels=[1;1];
verifyError(t,@()createBOISurgeAnalysisWindows(R,D,S,E,X),'OxygenDynamics:InvalidNativeSupport');
S.FramePixels{1}=S.FramePixels{1}(1:3);
verifyError(t,@()createBOISurgeAnalysisWindows(R,C,S,E,X),'OxygenDynamics:InvalidNativeSupport');
end
function testMissingZeroAndFailedAreDistinct(t)
[R,C,S,E,X]=fixture;S=S([],:);W=createBOISurgeAnalysisWindows(R,C,S,E,X);
verifyTrue(t,all(isnan(W.MeanOccupiedTissueFraction)));verifyEqual(t,W.EventOnsets,[3;1]);
E=E([],:);W=createBOISurgeAnalysisWindows(R,C,S,E,X);
verifyEqual(t,W.MeanOccupiedTissueFraction,[0;0]);verifyTrue(t,all(isnan(W.AmplitudeAreaTimePercent_um2_sec)));
C{1}.SurgeEligibleTissuePixels=[];W=createBOISurgeAnalysisWindows(R,C,S,E,X);
verifyTrue(t,all(isnan(W.MeanOccupiedTissueFraction)));verifyTrue(t,all(isnan(W.EventOnsetRate_per_mm2_per_min)));
verifyEqual(t,W.AnalyzedTissueTime_um2_sec,[0;0]);
R.AnalysisStatus="failed";verifyError(t,@()createBOISurgeAnalysisWindows(R,C,S,E,X),'OxygenDynamics:RecordingNotAnalyzed');
end
function [path,root]=savedFixture
[R,C,S,E,X]=fixture;
RecordingRegistry=R;BOIInputContracts=C;
[SurgeRecordingWindowMetrics,SurgeWindowFrameIngredients]=createBOISurgeAnalysisWindows(R,C,S,E,X);
Table_OxygenSurgeEvents_OutCombo=E;
SS=S;SS.Properties.VariableNames=strrep(SS.Properties.VariableNames,'_Surge','');SS.EligibleTissuePixels={ [1;2];[1;2]};SS.RecAreaSize={8;8};
SE=E;SE.Properties.VariableNames=strrep(SE.Properties.VariableNames,'Surge','Sink');
[RecordingWindowMetrics,WindowFrameIngredients]=createOxygenAnalysisWindows(R,SS,SE,X);
Table_OxygenSinkEvents_OutCombo=SE;
RecordingInputQC=table("R","Q","Synthetic support","Review",'VariableNames',{'RecordingID','IssueID','Message','Action'});
RecordingFrameExposure=table(repmat("R",4,1),(1:4)',.96*ones(4,1),'VariableNames',{'RecordingID','Frame','CameraExposureSec'});
root=tempname;mkdir(root);path=fullfile(root,'DataOutput.mat');
save(path,'RecordingRegistry','BOIInputContracts','SurgeRecordingWindowMetrics','SurgeWindowFrameIngredients', ...
    'Table_OxygenSurgeEvents_OutCombo','RecordingWindowMetrics','WindowFrameIngredients','Table_OxygenSinkEvents_OutCombo', ...
    'RecordingInputQC','RecordingFrameExposure');
end
function testSavedReplayExportAndLegacy(t)
[path,root]=savedFixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIWindowReview(path);
D=buildBOIWindowReviewData(R,2,'surge');verifyEqual(t,D.Metrics.Replayed,[1/3;60e6/48;2.5e6/48],'AbsTol',1e-10);
verifyTrue(t,all(D.Checks.Status=="match"));verifyTrue(t,all(D.Metrics.ArithmeticStatus=="match"));
verifyTrue(t,ismember('SurgeID',D.Events.Properties.VariableNames));
r=exportBOIWindowReview(R,2,fullfile(root,'surge'),'','surge');verifyEqual(t,r.WindowOutcomeSign,'surge');
verifyEqual(t,r.SurgeWindowOutcomes,'available_separate_saved_windows');
S=load(path);S=rmfield(S,{'SurgeRecordingWindowMetrics','SurgeWindowFrameIngredients'});save(path,'-struct','S');
R=loadBOIWindowReview(path);verifyFalse(t,R.HasSurgeWindows);
verifyError(t,@()buildBOIWindowReviewData(R,1,'surge'),'OxygenDynamics:WindowReviewMissingEvidence');
D=buildBOIWindowReviewData(R,1);verifyTrue(t,all(D.Checks.Status=="match"));
end
function testPartialAndMixedSurgeEvidenceRejected(t)
[path,root]=savedFixture;cleanup=onCleanup(@()rmdir(root,'s'));S=load(path);T=rmfield(S,'SurgeWindowFrameIngredients');save(path,'-struct','T');
verifyError(t,@()loadBOIWindowReview(path),'OxygenDynamics:WindowReviewMissingEvidence');
T=S;T.SurgeRecordingWindowMetrics.StartSec(1)=1;save(path,'-struct','T');
verifyError(t,@()loadBOIWindowReview(path),'OxygenDynamics:WindowReviewIdentity');
T=S;T.Table_OxygenSurgeEvents_OutCombo.RecordingID(1)="wrong";save(path,'-struct','T');
verifyError(t,@()loadBOIWindowReview(path),'OxygenDynamics:WindowReviewIdentity');
end
function testGuiSignSelection(t)
[path,root]=savedFixture;cleanup=onCleanup(@()rmdir(root,'s'));[fig,UI]=openBOIWindowReview(path);closeFig=onCleanup(@()delete(fig));
UI.SelectSign('surge');UI.Select(2);verifyEqual(t,UI.Sign.Value,'surge');
verifyEqual(t,UI.Metrics.Data.Saved(1),1/3,'AbsTol',1e-14);verifyTrue(t,contains(UI.Status.Text,'SURGE'));
UI.SelectSign('sink');verifyEqual(t,UI.Sign.Value,'sink');verifyEqual(t,UI.Metrics.Data.Saved(1),.5);
end
function testSignSwitchKeepsWindowIdentity(t)
[path,root]=savedFixture;cleanup=onCleanup(@()rmdir(root,'s'));S=load(path);
S.SurgeRecordingWindowMetrics=S.SurgeRecordingWindowMetrics([2 1],:);save(path,'-struct','S');
[fig,UI]=openBOIWindowReview(path);closeFig=onCleanup(@()delete(fig));
UI.Select(2);UI.SelectSign('surge');verifyEqual(t,UI.Windows.Selection,1);
verifyEqual(t,UI.Windows.Data.WindowID(1),"partial");verifyEqual(t,UI.Metrics.Data.Saved(1),1/3,'AbsTol',1e-14);
UI.SelectSign('sink');verifyEqual(t,UI.Windows.Selection,2);
end
