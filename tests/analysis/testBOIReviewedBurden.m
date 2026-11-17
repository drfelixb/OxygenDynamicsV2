function tests=testBOIReviewedBurden
tests=functiontests(localfunctions);
end
function testRejectedDetectionLeavesExactRetainedIngredients(t)
[A,G,R,root]=fixture();c=onCleanup(@()rmdir(root,'s'));
before=A;R=judgment(R,root,'not_recognized','review-01.json');B=createBOIReviewedBurdenMetrics(A,G,{R});
verifyEqual(t,A,before);verifyEqual(t,B.EventTable.SinkID,2);verifyEqual(t,B.ExcludedDetections,A.EventTable(1,:));
verifyEqual(t,B.EventTable.PerEventBurdenContribution,A.EventTable.PerEventBurdenContribution(2));
verifyEqual(t,B.RecordingTable.HypoxicBurden,120);verifyEqual(t,B.RecordingTable.HypoxicBurden_per_mm2_per_min,720000);
verifyEqual(t,B.ReviewDecisions.RecognitionStatus,["not_recognized";"not_reviewed"]);
verifyEqual(t,B.TimeSeriesTable.ActiveHypoxicEvents(10:11),[0;0]);
end
function testRetainedMissingContributionKeepsStrictTotalMissing(t)
[A,G,R,root]=fixture();c=onCleanup(@()rmdir(root,'s'));E=A.EventTable;E.NormOxySinkAmpPercent(2)=NaN;
A=createHypoxicBurdenMetrics(E,table(),table(),G);R=judgment(R,root,'not_recognized','review.json');
B=createBOIReviewedBurdenMetrics(A,G,{R});verifyTrue(t,isnan(B.RecordingTable.HypoxicBurden));
verifyTrue(t,all(isnan(B.RecordingTable{:,{'HypoxicBurden_per_mm2','HypoxicBurden_per_sec', ...
    'HypoxicBurden_per_min','HypoxicBurden_per_mm2_per_sec','HypoxicBurden_per_mm2_per_min','Burden_AmplitudeComposite'}})));
verifyEqual(t,B.ReviewSummary.MissingContributions,1);verifyEqual(t,B.ReviewSummary.RejectedDetections,1);
end
function testUncertainAndUnreviewedRemainIncluded(t)
[A,G,R,root]=fixture();c=onCleanup(@()rmdir(root,'s'));R=judgment(R,root,'uncertain','review.json');
B=createBOIReviewedBurdenMetrics(A,G,{R});verifyEqual(t,B.EventTable,A.EventTable);verifyEmpty(t,B.ExcludedDetections);
verifyEqual(t,B.ReviewSummary.RetainedUnreviewedDetections,1);
end
function testLatestSavedRevisionControlsMembership(t)
[A,G,R,root]=fixture();c=onCleanup(@()rmdir(root,'s'));R=judgment(R,root,'not_recognized','review-01.json');
old=R.BoundaryReview;R=judgment(R,root,'recognized','review-02.json');B=createBOIReviewedBurdenMetrics(A,G,{R});
verifyEqual(t,B.EventTable,A.EventTable);verifyEqual(t,numel(R.BoundaryReview.Document.Revisions),2);
verifyEqual(t,oxygenFileSHA256(old.Path),old.SHA256);
end
function testRecordingIdentityPreventsCrossRecordingExclusion(t)
[A,G,R,root]=fixture();c=onCleanup(@()rmdir(root,'s'));E=A.EventTable;other=E(1,:);other.RecordingID="other";
g=G;g.RecordingID="other";G=[G;g];A=createHypoxicBurdenMetrics([E;other],table(),table(),G);
R=judgment(R,root,'not_recognized','review.json');B=createBOIReviewedBurdenMetrics(A,G,{R});
verifyEqual(t,height(B.EventTable),2);verifyTrue(t,any(string(B.EventTable.RecordingID)=="other"));
verifyEqual(t,B.ReviewSummary.RejectedDetections,[1;0]);
end
function testAmbiguousReviewsAndMismatchedBoundsAreBlocked(t)
[A,G,R,root]=fixture();c=onCleanup(@()rmdir(root,'s'));R=judgment(R,root,'not_recognized','review.json');
verifyError(t,@()createBOIReviewedBurdenMetrics(A,G,{R,R}),'OxygenDynamics:ReviewedBurdenIdentity');
bad=A;bad.EventTable.StartFrame(1)=9;
verifyError(t,@()createBOIReviewedBurdenMetrics(bad,G,{R}),'OxygenDynamics:ReviewedBurdenIdentity');
badG=G;badG.RawSHA256="wrong";
verifyError(t,@()createBOIReviewedBurdenMetrics(A,badG,{R}),'OxygenDynamics:ReviewedBurdenIdentity');
end
function testDraftAndChangedRevisionCannotGovernExport(t)
[A,G,R,root]=fixture();c=onCleanup(@()rmdir(root,'s'));
verifyError(t,@()createBOIReviewedBurdenMetrics(A,G,{R}),'OxygenDynamics:SavedReviewRequired');
R=judgment(R,root,'not_recognized','review.json');p=R.BoundaryReview.Path;
fid=fopen(p,'a');fprintf(fid,'\n');fclose(fid);
verifyError(t,@()createBOIReviewedBurdenMetrics(A,G,{R}),'OxygenDynamics:ReviewedBurdenIdentity');
end
function testAllRejectedHasKnownZeroEventsAndZeroTrace(t)
[A,G,R,root]=fixture();c=onCleanup(@()rmdir(root,'s'));R=judgment(R,root,'not_recognized','review-01.json');
a=annotation('not_recognized');R.BoundaryReview=saveBOIBoundaryReview(R,2,a,fullfile(root,'review-02.json'),R.BoundaryReview);
B=createBOIReviewedBurdenMetrics(A,G,{R});verifyEmpty(t,B.EventTable);verifyEqual(t,B.RecordingTable.NumEvents,0);
verifyEqual(t,B.RecordingTable.HypoxicBurden,0);verifyEqual(t,B.TimeSeriesTable.ActiveHypoxicEvents,zeros(100,1));
end
function testReviewedEventUpdatesOnlyBurdenFieldsAndTiming(t)
[A,G,R,root]=fixture();c=onCleanup(@()rmdir(root,'s'));[R,V]=eventRevisionFixture(A,G,R,root);
B=createBOIReviewedBurdenMetrics(A,G,{R},{V});
verifyEqual(t,B.EventTable.StartFrame,A.EventTable.StartFrame);verifyEqual(t,B.EventTable.DurationSec,A.EventTable.DurationSec);
verifyEqual(t,B.EventTable.NormOxySinkAmpPercent,A.EventTable.NormOxySinkAmpPercent);
verifyEqual(t,B.EventTable.BurdenStartFrame,[2;20]);verifyEqual(t,B.EventTable.BurdenEndFrame,[4;21]);
verifyEqual(t,B.EventTable.PerEventBurdenContribution,[360;120]);verifyEqual(t,B.RecordingTable.HypoxicBurden,480);
verifyEqual(t,sum(B.TimeSeriesTable.HypoxicBurdenOverTime),480);verifyEqual(t,B.TimeSeriesTable.ActiveHypoxicEvents(2:4),ones(3,1));
verifyEqual(t,B.TimeSeriesTable.ActiveHypoxicEvents(10:11),zeros(2,1));verifyEqual(t,B.ReviewSummary.ReviewedEventValues,1);
verifyEqual(t,B.ReviewDecisions.ReviewedValuesApplied,[true;false]);verifyEqual(t,height(B.EventRevisions),1);
end
function testApprovedValueDoesNotHideOtherMissingContributions(t)
[A,G,R,root]=fixture();c=onCleanup(@()rmdir(root,'s'));E=A.EventTable;E.NormOxySinkAmpPercent(:)=NaN;
A=createHypoxicBurdenMetrics(E,table(),table(),G);[R,V]=eventRevisionFixture(A,G,R,root);
B=createBOIReviewedBurdenMetrics(A,G,{R},{V});verifyTrue(t,isnan(B.RecordingTable.HypoxicBurden));
verifyTrue(t,isnan(B.RecordingTable.HypoxicBurden_per_mm2_per_min));
verifyEqual(t,B.ReviewSummary.AvailableContributions,1);verifyEqual(t,B.ReviewSummary.MissingContributions,1);
verifyEqual(t,B.EventTable.PerEventBurdenContribution(1),360);verifyTrue(t,isnan(A.EventTable.PerEventBurdenContribution(1)));
end
function testReviewedEventRejectsConflictsDuplicatesAndAreaChanges(t)
[A,G,R,root]=fixture();c=onCleanup(@()rmdir(root,'s'));[R,V]=eventRevisionFixture(A,G,R,root);
rounded=V;rounded.Document.BurdenArea_um2=4+2*eps(4);rounded.Document.BurdenRecordingArea_um2=100-2*eps(100);
B=createBOIReviewedBurdenMetrics(A,G,{R},{rounded});verifyEqual(t,B.EventTable.PerEventBurdenContribution(1),360);
bad=V;bad.Document.BurdenArea_um2=5;
verifyError(t,@()createBOIReviewedBurdenMetrics(A,G,{R},{bad}),'OxygenDynamics:ReviewedBurdenEvent');
bad=V;bad.Document.BoundarySHA256='different';
verifyError(t,@()createBOIReviewedBurdenMetrics(A,G,{R},{bad}),'OxygenDynamics:ReviewedBurdenEvent');
verifyError(t,@()createBOIReviewedBurdenMetrics(A,G,{R},{V,V}),'OxygenDynamics:ReviewedBurdenEvent');
R=judgment(R,root,'not_recognized','rejected.json');
verifyError(t,@()createBOIReviewedBurdenMetrics(A,G,{R},{V}),'OxygenDynamics:ReviewedBurdenEvent');
end
function testReviewedValueDoesNotChangeOtherRecording(t)
[A,G,R,root]=fixture();c=onCleanup(@()rmdir(root,'s'));E=A.EventTable;other=E(1,:);other.RecordingID="other";
g=G;g.RecordingID="other";G=[G;g];A=createHypoxicBurdenMetrics([E;other],table(),table(),G);
[R,V]=eventRevisionFixture(A,G,R,root);B=createBOIReviewedBurdenMetrics(A,G,{R},{V});
verifyEqual(t,B.RecordingTable.HypoxicBurden,[480;80]);verifyEqual(t,B.EventTable.PerEventBurdenContribution(3),80);
verifyEqual(t,B.EventTable.BurdenRecordingArea_um2,A.EventTable.BurdenRecordingArea_um2);
verifyEqual(t,B.EventTable.BurdenRecordingDuration_sec,A.EventTable.BurdenRecordingDuration_sec);
verifyEqual(t,B.ReviewSummary.ReviewedEventValues,[1;0]);
end
function [R,V]=eventRevisionFixture(A,~,R,root)
% Low-level calculation DTO fixture; the exporter loads/checks real artifacts
% through loadBOIReviewedBurdenEvent before supplying this structure.
a=annotation('recognized');a.OnsetFrames=2;a.PreferredOnsetFrame=2;a.RecoveryFrames=4;a.PreferredRecoveryFrame=4;
R.BoundaryReview=saveBOIBoundaryReview(R,1,a,fullfile(root,'reviewed-event.json'));
e=A.EventTable(1,:);S=struct('RecordingID','recording','SiteID',1,'EventID',1, ...
    'OriginalAutomaticStartFrame',10,'OriginalAutomaticEndFrame',11,'StartFrame',2,'EndFrame',4,'DurationSec',3, ...
    'SampleHz',1,'RawSourceSHA256','raw','BoundarySHA256',R.BoundaryReview.SHA256, ...
    'BurdenArea_um2',e.BurdenArea_um2,'BurdenRecordingArea_um2',e.BurdenRecordingArea_um2, ...
    'BurdenRecordingDuration_sec',e.BurdenRecordingDuration_sec,'BurdenAmplitudePercent',30, ...
    'ReferenceStartFrame',1,'ReferenceEndFrame',1,'ReferenceSamples',1,'ReferenceSHA256',repmat('b',1,64), ...
    'PerEventBurdenContribution',360,'PerEventBurdenContribution_per_mm2_per_min',2160000, ...
    'AreaRemeasured',false,'AreaQualification','Developer fixture; not researcher evidence');
V=struct('Path',fullfile(root,'synthetic-event-DTO'),'ManifestSHA256',repmat('a',1,64),'Document',S);
end
function [A,G,R,root]=fixture()
root=tempname;mkdir(root);
G=table("recording","experiment","mouse","baseline","none","genotype","promoter",false,100,1,100,100,"raw", ...
    'VariableNames',{'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim', ...
    'NFrames','SampleF','RecordingDuration_sec','RecordingArea_um2','RawSHA256'});
E=repmat(G,2,1);E.SinkID=[1;2];E.EventID=[1;1];E.StartFrame=[10;20];E.EndFrame=[11;21];E.DurationSec=[2;2];
E.NormOxySinkAmpPercent=[10;20];E.EventArea_um2=[4;3];E.RecAreaSize=[100;100];E.RecDuration=[100;100];
A=createHypoxicBurdenMetrics(E,table(),table(),G);
Audit=table(["recording";"recording"],["sink";"sink"],[1;2],[1;1],[10;20],[11;21],[10;20],[11;21], ...
    'VariableNames',{'RecordingID','EventType','SiteID','EventID','StartFrame','EndFrame','DetectedStartFrame','DetectedEndFrame'});
path=fullfile(root,'synthetic-audit.mat');save(path,'Audit');
R=struct('AuditPath',path,'AuditSHA256',oxygenFileSHA256(path),'Audit',Audit, ...
    'AnalysisInfo',struct('RawSHA256','raw','NFrames',100,'AnalysisParams',struct('fs',1)));
end
function R=judgment(R,root,status,name)
previous=[];if isfield(R,'BoundaryReview'),previous=R.BoundaryReview;end
R.BoundaryReview=saveBOIBoundaryReview(R,1,annotation(status),fullfile(root,name),previous);
end
function a=annotation(status)
a=struct('Status',status,'OnsetFrames',[],'RecoveryFrames',[],'PreferredOnsetFrame',[],'PreferredRecoveryFrame',[], ...
    'Reviewer','Developer fixture; not researcher evidence','Reason','Synthetic recognition/export regression.');
end
