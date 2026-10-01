function tests=testBOIWindowReview
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function [path,root]=fixture
root=tempname;mkdir(root);path=fullfile(root,'DataOutput.mat');
RecordingRegistry=table("R",string(repmat('a',1,64)),"loaded",'VariableNames',{'RecordingID','RawSHA256','AnalysisStatus'});
C=struct('Schema','boi-recording-input-1','RecordingID','R','RawSHA256',repmat('a',1,64), ...
    'NFrames',4,'SampleHz',1,'PixelSizeUm',2,'FrameSize',[3 4], ...
    'SinkEligibleTissuePixels',(1:4)','SurgeEligibleTissuePixels',(1:6)', ...
    'FrameTimingStatus','uniform_assumed_from_sampling_rate','TissueValidityStatus','static_mask_not_independently_validated');
BOIInputContracts={C};
RecordingInputQC=table("R","R1-STATIC-TISSUE","Synthetic support, not biological evidence","Review tissue evidence", ...
    'VariableNames',{'RecordingID','IssueID','Message','Action'});
RecordingFrameExposure=table(repmat("R",4,1),(1:4)',.8*ones(4,1),'VariableNames',{'RecordingID','Frame','CameraExposureSec'});
Table_OxygenSinkEvents_OutCombo=table(repmat("R",3,1),ones(3,1),(1:3)',[0;1;3],[1;2;4], ...
    'VariableNames',{'RecordingID','SinkID','EventID','StartSec','EndSec'});
RecordingWindowMetrics=table(repmat("R",2,1),["partial";"whole"],[.5;0],[2.5;4],[2;4], ...
    [10/32;16/64],[1;3],[1.5;3],[1*60e6/32;3*60e6/64],[1.5e6/32;3e6/64],[10;16],[32;64], ...
    repmat("descriptive_static_uniform_assumptions",2,1),repmat("acquisition boundary included; interpretation unresolved",2,1), ...
    repmat("boi-window-exposure-1",2,1),'VariableNames',{'RecordingID','WindowID','StartSec','EndSec','DurationSec', ...
    'MeanOccupiedTissueFraction','EventOnsets','ActiveEventSeconds','EventOnsetRate_per_mm2_per_min','MeanConcurrentEvents_per_mm2', ...
    'CoveredAreaTime_um2_sec','AnalyzedTissueTime_um2_sec','OccupancyStatus','OnsetPolicy','WindowAuditVersion'});
WindowFrameIngredients=table(repmat("R",7,1),[repmat("partial",3,1);repmat("whole",4,1)], ...
    [1;2;3;1;2;3;4],[0;1;2;0;1;2;3],[1;2;3;1;2;3;4],[.5;1;.5;1;1;1;1], ...
    [4;8;0;4;8;0;4],16*ones(7,1),[2;8;0;4;8;0;4],[8;16;8;16;16;16;16], ...
    'VariableNames',{'RecordingID','WindowID','Frame','ModeledStartSec','ModeledEndSec','WindowOverlapSec', ...
    'OccupiedArea_um2','AnalyzedArea_um2','CoveredAreaTime_um2_sec','AnalyzedTissueTime_um2_sec'});
save(path,'RecordingRegistry','RecordingWindowMetrics','BOIInputContracts','RecordingInputQC','RecordingFrameExposure', ...
    'WindowFrameIngredients','Table_OxygenSinkEvents_OutCombo');
end
function testPartialFramesOnsetsAndUnits(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIWindowReview(path);D=buildBOIWindowReviewData(R,1);
verifyEqual(t,D.Metrics.Replayed,[.3125;1875000;46875],'AbsTol',1e-12);
verifyTrue(t,all(D.Checks.Status=="match"));verifyTrue(t,all(D.Metrics.ArithmeticStatus=="match"));
verifyEqual(t,D.Frames.WindowOverlapSec,[.5;1;.5]);verifyEqual(t,D.Events.OnsetInWindow,[false;true;false]);
verifyEqual(t,D.Events.OngoingAtWindowStart,[true;false;false]);verifyEqual(t,D.RecordingExposure.CameraExposureSec,.8*ones(4,1));
verifyTrue(t,any(contains(string(D.Details),'Camera integration exposure: 0.8')));
D=buildBOIWindowReviewData(R,2);verifyEqual(t,sum(D.Events.AcquisitionStartOnset),1);
verifyTrue(t,any(contains(string(D.Details),'Surge support is separately retained')));
end
function testMissingSupportAndZeroDenominator(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIWindowReview(path);
R.WindowFrameIngredients.OccupiedArea_um2(:)=NaN;R.WindowFrameIngredients.CoveredAreaTime_um2_sec(:)=NaN;
R.RecordingWindowMetrics.CoveredAreaTime_um2_sec(:)=NaN;R.RecordingWindowMetrics.MeanOccupiedTissueFraction(:)=NaN;
D=buildBOIWindowReviewData(R,1);verifyEqual(t,D.Metrics.ArithmeticStatus(1),"unavailable");
verifyTrue(t,isnan(D.Metrics.Replayed(1)));verifyTrue(t,isfinite(D.Metrics.Replayed(2)));
R.BOIInputContracts{1}.SinkEligibleTissuePixels=[];
R.WindowFrameIngredients.AnalyzedArea_um2(:)=0;R.WindowFrameIngredients.AnalyzedTissueTime_um2_sec(:)=0;
R.RecordingWindowMetrics.AnalyzedTissueTime_um2_sec(:)=0;
R.RecordingWindowMetrics.EventOnsetRate_per_mm2_per_min(:)=NaN;R.RecordingWindowMetrics.MeanConcurrentEvents_per_mm2(:)=NaN;
D=buildBOIWindowReviewData(R,1);verifyTrue(t,all(isnan(D.Metrics.Replayed)));
end
function testValidZeroIsDifferent(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIWindowReview(path);
R.Table_OxygenSinkEvents_OutCombo=R.Table_OxygenSinkEvents_OutCombo([],:);
R.WindowFrameIngredients.OccupiedArea_um2(:)=0;R.WindowFrameIngredients.CoveredAreaTime_um2_sec(:)=0;
for field={'MeanOccupiedTissueFraction','EventOnsets','ActiveEventSeconds','EventOnsetRate_per_mm2_per_min','MeanConcurrentEvents_per_mm2','CoveredAreaTime_um2_sec'}
    R.RecordingWindowMetrics.(field{1})(:)=0;
end
D=buildBOIWindowReviewData(R,1);verifyEqual(t,D.Metrics.Replayed,zeros(3,1));verifyTrue(t,all(D.Checks.Status=="match"));
R.RecordingRegistry.AnalysisStatus="failed";D=buildBOIWindowReviewData(R,1);
verifyEqual(t,D.Checks.Status(D.Checks.Check=="Recording analysis completed"),"mismatch");
end
function testDisagreementsAndMissingFrameRemainVisible(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIWindowReview(path);
R.WindowFrameIngredients.CoveredAreaTime_um2_sec(1)=99;
D=buildBOIWindowReviewData(R,1);verifyTrue(t,any(D.Checks.Status=="mismatch"));verifyEqual(t,D.Metrics.ArithmeticStatus(1),"mismatch");
R=loadBOIWindowReview(path);R.WindowFrameIngredients(1,:)=[];
D=buildBOIWindowReviewData(R,1);verifyEqual(t,D.Checks.Status(D.Checks.Check=="Frame coverage"),"mismatch");
end
function testIdentityScopeAndDuplicateFrames(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));S=load(path);
S.BOIInputContracts{1}.RawSHA256='wrong';save(path,'-struct','S');verifyError(t,@()loadBOIWindowReview(path),'OxygenDynamics:WindowReviewIdentity');
S.BOIInputContracts{1}.RawSHA256=repmat('a',1,64);S.WindowFrameIngredients(end+1,:)=S.WindowFrameIngredients(1,:);
save(path,'-struct','S');verifyError(t,@()loadBOIWindowReview(path),'OxygenDynamics:WindowReviewIdentity');
S.WindowFrameIngredients(end,:)=[];
S.BOIInputContracts{1}.AcquisitionSnapshot=struct('State','captured','RawJSON','{"Modality":"IOSI"}');
save(path,'-struct','S');verifyError(t,@()loadBOIWindowReview(path),'OxygenDynamics:WindowReviewScope');
end
function testExportCsvReplayAndMutation(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));R=loadBOIWindowReview(path);
folder=fullfile(root,'export');receipt=exportBOIWindowReview(R,1,folder);
F=readtable(fullfile(folder,'Frames.csv'));E=readtable(fullfile(folder,'Events.csv'));
den=sum(F.AnalyzedTissueTime_um2_sec);verifyEqual(t,sum(F.CoveredAreaTime_um2_sec)/den,.3125);
verifyEqual(t,sum(E.OnsetInWindow==1)*60e6/den,1875000);verifyEqual(t,sum(E.OverlapSec)*1e6/den,46875);
verifyEqual(t,receipt.ScientificStatus,'not_established');verifyEqual(t,receipt.SurgeWindowOutcomes,'not_present_in_saved_window_export');
verifyError(t,@()exportBOIWindowReview(R,1,folder),'OxygenDynamics:WindowReviewOutputExists');
S=load(path);S.Note='changed';save(path,'-struct','S');
verifyError(t,@()exportBOIWindowReview(R,1,fullfile(root,'second')),'OxygenDynamics:WindowReviewChanged');
end
function testGuiSelectionAndSupport(t)
[path,root]=fixture;cleanup=onCleanup(@()rmdir(root,'s'));[fig,UI]=openBOIWindowReview(path);closeFig=onCleanup(@()delete(fig));
UI.Select(2);verifyEqual(t,UI.Windows.Selection,2);verifyEqual(t,height(UI.Frames.Data),4);
verifyEqual(t,UI.Metrics.Data.Saved(1),.25);verifyTrue(t,contains(UI.Status.Text,'0 arithmetic/context mismatches'));
verifyTrue(t,contains(UI.SurgeAxes.Title.String,'6 pixels'));verifyTrue(t,contains(UI.SinkAxes.Title.String,'4 pixels'));
end
