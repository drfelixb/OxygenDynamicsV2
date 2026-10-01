function tests=testBOIRecordingInputContract
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function testUnknownIsNotInvented(t)
[I,id]=info();[C,Q,F]=createBOIRecordingInputContract(I,id,[4 5]);
verifyEqual(t,C.MetadataState,'not_recorded_at_master');
verifyEqual(t,C.FrameTimingStatus,'uniform_assumed_from_sampling_rate');
verifyTrue(t,all(isnan(F.DeclaredFrameValid)));verifyTrue(t,all(F.ModeledFrameIncluded));
verifyTrue(t,all(isnan(F.CameraExposureSec)));verifyTrue(t,all(isnan(F.DeclaredFrameTimeSec)));
verifyEqual(t,F.FrameIntervalSec,ones(4,1)*.5);
verifyEqual(t,F.SinkAnalyzedArea_um2,ones(4,1)*16);
verifyTrue(t,any(Q.IssueID=="R1-EXPOSURE-UNKNOWN"));
verifyEqual(t,C.ScientificEligibility,'not_established_by_input_contract');
end
function testDeclaredClockAndExposureRemainDistinct(t)
D=declaration();D.FrameTimesSec=[10;10.5;11;11.5];D.FrameTimeReference='camera rising edges; image correspondence verified in fixture';
D.TimingEvidence='synthetic timestamp fixture';D.CameraExposureSec=.1;
[R,Q]=resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash');
verifyTrue(t,R.InputCompatible);verifyEqual(t,R.FrameTimingStatus,'declared_uniform_compatible');
verifyEqual(t,R.DeclaredFrameTimesSec,D.FrameTimesSec);verifyEqual(t,R.CameraExposureSec,repmat(.1,4,1));
verifyFalse(t,any(Q.IssueID=="R1-TIMING-UNKNOWN"));
end
function testNonuniformIsHeldNotRounded(t)
D=declaration();D.FrameTimesSec=[0 .5 1.1 1.6];D.FrameTimeReference='frame start';D.TimingEvidence='fixture';
[R,Q]=resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash');
verifyFalse(t,R.InputCompatible);verifyEqual(t,R.DeclaredFrameTimesSec,D.FrameTimesSec');
verifyEqual(t,Q.Disposition(Q.IssueID=="R1-TIMING"),"hold_recording");
end
function testInvalidTimingAndTypo(t)
D=declaration();D.FrameTimesSec=[0 .5 .5 1];
verifyError(t,@()resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash'),'OxygenDynamics:InvalidFrameTiming');
D=declaration();D.FrameTimeSec=[0 .5 1 1.5];
verifyError(t,@()resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash'),'OxygenDynamics:InvalidInputMetadata');
end
function testSourceMismatch(t)
D=declaration();
verifyError(t,@()resolveBOIAcquisitionMetadata(snapshot(D),4,2,'another_hash'),'OxygenDynamics:InputMetadataSourceMismatch');
end
function testSourceClockIsNotImageClock(t)
D=declaration();D.SourceClockTimesSec=[5 5.51 5.50 6.52];
D.SourceClockReference='software receipt proxy';D.SourceClockEvidence='fixture with backward receipt-clock step';
[R,Q]=resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash');
verifyTrue(t,R.InputCompatible);verifyTrue(t,all(isnan(R.DeclaredFrameTimesSec)));
verifyEqual(t,R.SourceClockTimesSec,D.SourceClockTimesSec');
verifyEqual(t,R.FrameTimingStatus,'uniform_assumed_from_sampling_rate');
verifyTrue(t,any(Q.IssueID=="R1-SOURCE-CLOCK"));verifyTrue(t,any(Q.IssueID=="R1-TIMING-UNKNOWN"));
D.FrameTimesSec=[0 .5 1.1 1.5];D.FrameTimeReference='independent camera clock';D.TimingEvidence='fixture';
R=resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash');
verifyFalse(t,R.InputCompatible);verifyEqual(t,R.DeclaredFrameTimesSec,D.FrameTimesSec');
verifyEqual(t,R.SourceClockTimesSec,D.SourceClockTimesSec');
end
function testSourceClockRequiresEvidenceAndFrameCorrespondence(t)
D=declaration();D.SourceClockTimesSec=[1 2 3 4];
verifyError(t,@()resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash'),'OxygenDynamics:InvalidSourceClock');
D.SourceClockReference='receipt';D.SourceClockEvidence='fixture';D.SourceClockTimesSec=[1 2 3];
verifyError(t,@()resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash'),'OxygenDynamics:InvalidSourceClock');
end
function testConfirmedSamplingRetainsUnreliableSourceClock(t)
D=declaration();D.UniformSamplingConfirmed=true;D.SamplingRateEvidence='Researcher confirms precise external triggering at supplied 2 Hz in fixture';
D.SourceClockTimesSec=[5 5.51 5.50 6.52];D.SourceClockReference='incorrect file timestamps';
D.SourceClockEvidence='Researcher identifies metadata as incorrect';D.SourceClockStatus='known_unreliable';
[R,Q]=resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash');
verifyTrue(t,R.InputCompatible);verifyEqual(t,R.FrameTimingStatus,'uniform_confirmed_from_acquisition_evidence');
verifyFalse(t,any(Q.IssueID=="R1-TIMING-UNKNOWN"));verifyTrue(t,all(isnan(R.DeclaredFrameTimesSec)));
verifyEqual(t,R.SourceClockTimesSec,D.SourceClockTimesSec');
D.FrameTimesSec=[0 .5 1.1 1.5];D.FrameTimeReference='conflicting declared image clock';D.TimingEvidence='fixture';
R=resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash');verifyFalse(t,R.InputCompatible);
D=declaration();D.UniformSamplingConfirmed=true;
verifyError(t,@()resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash'),'OxygenDynamics:InvalidSamplingEvidence');
end
function testSourceIssuesControlHoldWithoutChangingClock(t)
D=declaration();D.ReviewIssues=sourceIssue('hold_recording');
[R,Q]=resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash');
verifyFalse(t,R.InputCompatible);verifyEqual(t,R.SourceReviewIssues,D.ReviewIssues);
verifyEqual(t,Q.Disposition(Q.IssueID=="SOURCE-IDENTITY"),"hold_recording");
verifyTrue(t,contains(Q.Message(Q.IssueID=="SOURCE-IDENTITY"),'fixture source evidence'));
D.ReviewIssues.Disposition='review';R=resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash');
verifyTrue(t,R.InputCompatible);verifyTrue(t,all(isnan(R.DeclaredFrameTimesSec)));
end
function testInvalidSourceIssuesCannotSilentlyPass(t)
D=declaration();D.ReviewIssues=sourceIssue('measurement_unavailable');
verifyError(t,@()resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash'),'OxygenDynamics:InvalidSourceReview');
D.ReviewIssues=sourceIssue('hold_recording');D.ReviewIssues.Evidence='';
verifyError(t,@()resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash'),'OxygenDynamics:InvalidSourceReview');
D.ReviewIssues=repmat(sourceIssue('review'),2,1);
verifyError(t,@()resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash'),'OxygenDynamics:InvalidSourceReview');
D.ReviewIssues=sourceIssue('review');D.ReviewIssues.IssueID='R1-TIMING';
verifyError(t,@()resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash'),'OxygenDynamics:InvalidSourceReview');
end
function testSourceClockAndSourceIssuesSurviveResearcherExport(t)
[I,id]=info();D=declaration();D.SourceClockTimesSec=[5 5.51 6.01 6.52];
D.SourceClockReference='software proxy';D.SourceClockEvidence='fixture';D.ReviewIssues=sourceIssue('review');
I.BOIAcquisitionMetadata=snapshot(D);[C,Q,F]=createBOIRecordingInputContract(I,id,[4 5]);
verifyEqual(t,F.SourceClockTimeSec,D.SourceClockTimesSec');verifyTrue(t,all(isnan(F.DeclaredFrameTimeSec)));
verifyEqual(t,F.ModeledStartSec,[0;.5;1;1.5]);
folder=tempname;mkdir(folder);cleanup=onCleanup(@()rmdir(folder,'s'));
workbook=fullfile(folder,'audit.xlsx');W=table(0,'VariableNames',{'CoveredAreaTime_um2_sec'});
writeBOIRecordingInputAudit(folder,workbook,{C},Q,F,W);
back=readtable(fullfile(folder,'RecordingFrameExposure.csv'));
verifyEqual(t,back.SourceClockTimeSec,D.SourceClockTimesSec');verifyTrue(t,all(isnan(back.DeclaredFrameTimeSec)));
sheet=readtable(workbook,'Sheet','RecordingFrameExposure');verifyEqual(t,sheet.SourceClockTimeSec,back.SourceClockTimeSec);
verifyTrue(t,contains(fileread(fullfile(folder,'RecordingInputContracts.json')),'fixture source evidence'));
verifyTrue(t,contains(fileread(fullfile(folder,'RecordingInputReview.md')),'SOURCE-IDENTITY'));
verifyTrue(t,contains(fileread(fullfile(folder,'RecordingInputReview.md')),'SourceClockTimeSec'));
end
function Q=sourceIssue(disposition)
Q=struct('IssueID','SOURCE-IDENTITY','Disposition',disposition,'AffectedMeasurements','Animal-level comparisons', ...
    'Message','Conflicting source identity.','Action','Reconcile acquisition log and folder identity.','Evidence','fixture source evidence');
end
function testFrameExclusionsDoNotCompressTime(t)
D=declaration();D.FrameValid=[true false true true];
[R,Q]=resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash');
verifyFalse(t,R.InputCompatible);verifyEqual(t,R.DeclaredFrameValid,double(D.FrameValid'));
verifyTrue(t,any(Q.IssueID=="R1-FRAME-EXCLUSION"));
end
function testBOIOnly(t)
D=declaration();D.Modality='IOSI';
[R,Q]=resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash');
verifyFalse(t,R.InputCompatible);verifyTrue(t,any(Q.IssueID=="R1-MODALITY"));
end
function testInvalidExposure(t)
D=declaration();D.CameraExposureSec=0;
verifyError(t,@()resolveBOIAcquisitionMetadata(snapshot(D),4,2,'fixture_hash'),'OxygenDynamics:InvalidCameraExposure');
end
function testTissueIndicesAndArea(t)
[I,id]=info();I.SinkEligibleTissuePixels=[1;1;2;3];
verifyError(t,@()createBOIRecordingInputContract(I,id,[4 5]),'OxygenDynamics:InvalidTissueSupport');
[I,id]=info();I.SinkEligibleTissuePixels=[1;2;3;21];
verifyError(t,@()createBOIRecordingInputContract(I,id,[4 5]),'OxygenDynamics:InvalidTissueSupport');
[I,id]=info();I.RecordingAreaUm2=100;
verifyError(t,@()createBOIRecordingInputContract(I,id,[4 5]),'OxygenDynamics:TissueAreaMismatch');
end
function testZeroTissueNotValidZero(t)
[I,id]=info();I.SinkEligibleTissuePixels=[];I.RecordingAreaUm2=0;
[~,Q,F]=createBOIRecordingInputContract(I,id,[4 5]);
verifyEqual(t,F.SinkAnalyzedArea_um2,zeros(4,1));
verifyEqual(t,Q.Disposition(Q.IssueID=="R1-ZERO-TISSUE"),"measurement_unavailable");
[R,S,E]=windowFixture();R.RecordingArea_um2=0;S=S([],:);E=E([],:);
[W,F]=createOxygenAnalysisWindows(R,S,E);
verifyTrue(t,isnan(W.MeanOccupiedTissueFraction));verifyEqual(t,W.AnalyzedTissueTime_um2_sec,0);
verifyEqual(t,sum(F.AnalyzedTissueTime_um2_sec),0);
end
function testOverlapsPartialFramesAndBoundaryOnsets(t)
[R,S,E]=windowFixture();
windows=table(["R";"R"],["whole";"partial"],[0;.25],[2;1.25], ...
    'VariableNames',{'RecordingID','WindowID','StartSec','EndSec'});
[W,F]=createOxygenAnalysisWindows(R,S,E,windows);
% First frame union {1,2,3} intersects tissue {1,2}: 8 um2; later zero.
verifyEqual(t,W.CoveredAreaTime_um2_sec,[4;2]);
verifyEqual(t,W.AnalyzedTissueTime_um2_sec,[16;8]);
verifyEqual(t,W.MeanOccupiedTissueFraction,[.25;.25],'AbsTol',1e-12);
verifyEqual(t,W.EventOnsets,[2;1]);verifyEqual(t,W.AcquisitionStartOnsetsCounted,[1;0]);
verifyEqual(t,W.OnsetsAfterAcquisitionStart,[1;1]);verifyEqual(t,W.OngoingAtWindowStart,[0;1]);
verifyEqual(t,W.AcquisitionStartEvents,[1;1]);
partial=F(F.WindowID=="partial",:);
verifyEqual(t,partial.WindowOverlapSec,[.25;.5;.25]);
verifyEqual(t,sum(partial.CoveredAreaTime_um2_sec)/sum(partial.AnalyzedTissueTime_um2_sec),W.MeanOccupiedTissueFraction(2));
end
function testMissingMaskIsUnavailableButZeroSuccessIsZero(t)
[R,S,E]=windowFixture();S=S([],:);
W=createOxygenAnalysisWindows(R,S,E);
verifyTrue(t,isnan(W.MeanOccupiedTissueFraction));verifyEqual(t,W.EventOnsets,2);
verifyEqual(t,W.OccupancyStatus,"unavailable_native_masks");
E=E([],:);W=createOxygenAnalysisWindows(R,S,E);
verifyEqual(t,W.MeanOccupiedTissueFraction,0);verifyEqual(t,W.EventOnsets,0);
R.AnalysisStatus="failed";
verifyError(t,@()createOxygenAnalysisWindows(R,S,E),'OxygenDynamics:RecordingNotAnalyzed');
end
function testTruncatedMaskSupportCannotBecomeZero(t)
[R,S,E]=windowFixture();S.FramePixels{1}=S.FramePixels{1}(1:3);
verifyError(t,@()createOxygenAnalysisWindows(R,S,E),'OxygenDynamics:InvalidNativeSupport');
end
function testSnapshotMutationAndCapture(t)
folder=tempname;mkdir(folder);cleanup=onCleanup(@()rmdir(folder,'s'));
raw=fullfile(folder,'source.tif');fid=fopen(raw,'w');fprintf(fid,'abc');fclose(fid);
I=struct('RawFile',raw,'RawSHA256',oxygenFileSHA256(raw),'DenoisedFile','','DenoisedSHA256','');
I.BOIAcquisitionMetadata=captureBOIAcquisitionMetadata(folder,4,2,I.RawSHA256);
verifyEqual(t,I.BOIAcquisitionMetadata.State,'not_supplied');
D=declaration();D.RawSHA256=I.RawSHA256;
fid=fopen(fullfile(folder,'BOIInputMetadata.json'),'w');fprintf(fid,'%s',jsonencode(D));fclose(fid);
verifyError(t,@()validateOxygenSourceFiles(I,folder),'OxygenDynamics:InputMetadataChanged');
I.BOIAcquisitionMetadata=captureBOIAcquisitionMetadata(folder,4,2,I.RawSHA256);
validateOxygenSourceFiles(I,folder);
D.IntensityHistory='synthetic change';fid=fopen(fullfile(folder,'BOIInputMetadata.json'),'w');fprintf(fid,'%s',jsonencode(D));fclose(fid);
verifyError(t,@()validateOxygenSourceFiles(I,folder),'OxygenDynamics:InputMetadataChanged');
D.FrameValid=[1 0 1 1];fid=fopen(fullfile(folder,'BOIInputMetadata.json'),'w');fprintf(fid,'%s',jsonencode(D));fclose(fid);
verifyError(t,@()captureBOIAcquisitionMetadata(folder,4,2,I.RawSHA256),'OxygenDynamics:UnsupportedBOIInput');
end
function [I,id]=info()
I=struct('NFrames',4,'AnalysisParams',struct('fs',2,'PixelSize',2),'RawSHA256','fixture_hash', ...
    'DenoisedSHA256','','SinkEligibleTissuePixels',(1:4)','SurgeEligibleTissuePixels',(1:5)', ...
    'RecordingAreaUm2',16,'SurgeRecordingAreaUm2',20);id="R";
end
function D=declaration()
D=struct('Schema','boi-acquisition-metadata-1','RawSHA256','fixture_hash','Modality','BOI');
end
function S=snapshot(D)
S=struct('State','captured','RawJSON',jsonencode(D),'SHA256','fixture_metadata_hash');
end
function [R,S,E]=windowFixture()
R=table("R",{'M'},{'Awake'},{'None'},{'WT'},{'GFAP'},false,4,2,2,8,2,"loaded", ...
    'VariableNames',{'RecordingID','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim', ...
    'NFrames','SampleF','RecordingDuration_sec','RecordingArea_um2','PixelSize','AnalysisStatus'});
P=cell(1,4);P{1}=[1;2];Q=cell(1,4);Q{1}=[2;3];
S=table(["R";"R"],{1;1},{1;1},{8;8},{P;Q},{[1;2];[1;2]}, ...
    'VariableNames',{'RecordingID','Start','Duration','RecAreaSize','FramePixels','EligibleTissuePixels'});
E=table(["R";"R"],[0;1],[1;1.5],[20;20],[4;4], ...
    'VariableNames',{'RecordingID','StartSec','EndSec','NormOxySinkAmpPercent','EventArea_um2'});
end
