function tests=testBOIReviewedArea
tests=functiontests(localfunctions);
end
function testCompleteMeanProductAndNormalization(t)
D=fixture();D=accept(D,{[10;11;12;18],[10;11],[10;11;12;18;19;20]});Q=computeBOIReviewedArea(D);
verifyTrue(t,Q.Complete);verifyEqual(t,Q.MeanAreaPixels,4);verifyEqual(t,Q.MeanAreaUm2,9);
verifyEqual(t,Q.Contribution,270);verifyEqual(t,Q.NormalizedContribution,270*(1e6/144)*(60/60),'RelTol',1e-12);
end
function testMissingAndUncertainWithholdWholeResult(t)
D=fixture();Q=computeBOIReviewedArea(D);verifyEqual(t,Q.Status,'incomplete');verifyTrue(t,isnan(Q.MeanAreaUm2));
D=accept(D,{[10;11],[10;11],[10;11]});D.FrameDecisions(2).Status='uncertain';Q=computeBOIReviewedArea(D);
verifyEqual(t,Q.ReviewedFrames,2);verifyEqual(t,Q.Status,'uncertain');verifyTrue(t,isnan(Q.Contribution));
verifyTrue(t,isnan(Q.NormalizedContribution));
verifyTrue(t,isnan(Q.MeanAreaUm2));
end
function testExplicitEmptyIsZeroWithoutImputation(t)
D=accept(fixture(),{[],[],[10;11;12]});Q=computeBOIReviewedArea(D);
verifyTrue(t,Q.Complete);verifyEqual(t,Q.FramePixels,[0;0;3]);verifyEqual(t,Q.MeanAreaPixels,1);
D.FrameDecisions(1).Status='unreviewed';Q=computeBOIReviewedArea(D);verifyTrue(t,isnan(Q.Contribution));
D=accept(fixture(),{[],[],[]});Q=computeBOIReviewedArea(D);verifyEqual(t,Q.Contribution,0);verifyTrue(t,Q.AllFramesExplicitlyEmpty);
D.FrameDecisions(1).Pixels=10;verifyError(t,@()computeBOIReviewedArea(D),'OxygenDynamics:InvalidAreaReview');
end
function testGeometryHolesComponentsAndMismatch(t)
D=fixture();C=D.Context;C.FixedFootprint=sort([C.FixedFootprint;60]);D.Context=C;D.ContextSHA256=boiPocketDigest(C);
hole=setdiff(C.FixedFootprint,[19;60]);D=accept(D,{hole,[10;11;60],hole});Q=computeBOIReviewedArea(D);
verifyEqual(t,Q.FramePixels,[8;3;8]);verifyTrue(t,Q.Complete);
D.FrameDecisions(1).Pixels=[1;10];Q=computeBOIReviewedArea(D);verifyEqual(t,Q.Status,'spatial_mismatch');
verifyTrue(t,isnan(Q.Contribution));verifyEqual(t,Q.OutsideFootprintPixels(1),1);verifyEqual(t,D.FrameDecisions(1).Pixels,[1;10]);
verifyTrue(t,isnan(Q.NormalizedContribution));
D.FrameDecisions(1).Pixels=[10;10];verifyError(t,@()computeBOIReviewedArea(D),'OxygenDynamics:InvalidAreaReview');
D.FrameDecisions(1).Pixels=65;verifyError(t,@()computeBOIReviewedArea(D),'OxygenDynamics:InvalidAreaReview');
end
function testClockFrameAndContextMismatchAreRejected(t)
D=fixture();D.FrameDecisions(1).Frame=11;verifyError(t,@()computeBOIReviewedArea(D),'OxygenDynamics:InvalidAreaReview');
D=fixture();D.Context.PixelSizeUm=2;verifyError(t,@()computeBOIReviewedArea(D),'OxygenDynamics:InvalidAreaReview');
D=fixture();D.Context.SampleHz=2;D.ContextSHA256=boiPocketDigest(D.Context);verifyError(t,@()computeBOIReviewedArea(D),'OxygenDynamics:InvalidAreaReview');
D=accept(fixture(),{10,10,10});D.FrameDecisions(1).Reviewer='';verifyError(t,@()computeBOIReviewedArea(D),'OxygenDynamics:InvalidAreaReview');
end
function testReviewedAreaImportAndMissingness(t)
[A,G,R,root]=importFixture();cleanup=onCleanup(@()rmdir(root,'s'));
a=struct('Status','recognized','OnsetFrames',2,'RecoveryFrames',4,'PreferredOnsetFrame',2,'PreferredRecoveryFrame',4, ...
    'Reviewer','Synthetic software test','Reason','Software test only');
R.BoundaryReview=saveBOIBoundaryReview(R,1,a,fullfile(root,'review.json'));
S=struct('Schema','boi-reviewed-single-event-burden-2','RecordingID','recording','SiteID',1,'EventID',1, ...
    'OriginalAutomaticStartFrame',10,'OriginalAutomaticEndFrame',11,'OriginalAutomaticArea_um2',4, ...
    'StartFrame',2,'EndFrame',4,'DurationSec',3,'SampleHz',1,'RawSourceSHA256','raw','BoundarySHA256',R.BoundaryReview.SHA256, ...
    'BurdenArea_um2',2,'BurdenRecordingArea_um2',100,'BurdenRecordingDuration_sec',100,'BurdenAmplitudePercent',30, ...
    'ReferenceStartFrame',1,'ReferenceEndFrame',1,'ReferenceSamples',1,'ReferenceSHA256',repmat('b',1,64), ...
    'PerEventBurdenContribution',180,'PerEventBurdenContribution_per_mm2_per_min',1080000, ...
    'AreaStatus','complete','AreaMeanFrameCount',3,'AreaRemeasured',true,'AreaQualification','Synthetic software test, not researcher evidence');
V=struct('Path','synthetic-only','ManifestSHA256',repmat('a',1,64),'Document',S);
B=createBOIReviewedBurdenMetrics(A,G,{R},{V});verifyEqual(t,B.EventTable.BurdenArea_um2,[2;3]);
verifyEqual(t,B.EventTable.AutomaticBurdenArea_um2,[4;3]);verifyEqual(t,B.EventTable.StartFrame,A.EventTable.StartFrame);
verifyEqual(t,B.EventTable.PerEventBurdenContribution,[180;120]);verifyEqual(t,B.RecordingTable.HypoxicBurden,300);
V.Document.BurdenArea_um2=NaN;V.Document.PerEventBurdenContribution=NaN;V.Document.PerEventBurdenContribution_per_mm2_per_min=NaN;
V.Document.AreaStatus='incomplete';V.Document.AreaRemeasured=false;
B=createBOIReviewedBurdenMetrics(A,G,{R},{V});verifyTrue(t,isnan(B.EventTable.PerEventBurdenContribution(1)));
verifyTrue(t,isnan(B.RecordingTable.HypoxicBurden));verifyEqual(t,B.EventTable.PerEventBurdenContribution(2),120);
verifyTrue(t,isnan(B.RecordingTable.HypoxicBurden_per_mm2_per_min));
verifyEqual(t,B.ReviewSummary.MissingContributions,1);verifyEqual(t,B.EventTable.AutomaticBurdenArea_um2,[4;3]);
end
function D=fixture()
C=struct('Schema','boi-reviewed-area-context-1','Frames',(10:12)','FrameSize',[8 8], ...
    'FixedFootprint',[10;11;12;18;19;20;26;27;28],'SampleHz',1,'FrameOrigin',1, ...
    'DurationSec',3,'PixelSizeUm',1.5,'RecordingAreaUm2',144,'RecordingDurationSec',60,'AmplitudePercent',10);
F=repmat(struct('Frame',0,'Status','unreviewed','Pixels',[],'Origin','none','Note','','Reviewer','','DecidedUTC',''),3,1);
for k=1:3,F(k).Frame=C.Frames(k);end
D=struct('Schema','boi-reviewed-event-area-1','Context',C,'ContextSHA256',boiPocketDigest(C), ...
    'Revision',0,'FrameDecisions',F,'AutomaticResultsChanged',false);
end
function D=accept(D,pixels)
for k=1:numel(pixels)
    D.FrameDecisions(k).Pixels=double(pixels{k}(:));D.FrameDecisions(k).Status='accepted';
    if isempty(pixels{k}),D.FrameDecisions(k).Status='empty';end
    D.FrameDecisions(k).Reviewer='Synthetic software test';D.FrameDecisions(k).DecidedUTC='2026-10-26T00:00:00Z';
end
end
function [A,G,R,root]=importFixture()
root=tempname;mkdir(root);
G=table("recording","experiment","mouse","baseline","none","genotype","promoter",false,100,1,100,100,"raw", ...
    'VariableNames',{'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim','NFrames','SampleF','RecordingDuration_sec','RecordingArea_um2','RawSHA256'});
E=repmat(G,2,1);E.SinkID=[1;2];E.EventID=[1;1];E.StartFrame=[10;20];E.EndFrame=[11;21];E.DurationSec=[2;2];
E.NormOxySinkAmpPercent=[10;20];E.EventArea_um2=[4;3];E.RecAreaSize=[100;100];E.RecDuration=[100;100];A=createHypoxicBurdenMetrics(E,table(),table(),G);
Audit=table(["recording";"recording"],["sink";"sink"],[1;2],[1;1],[10;20],[11;21],[10;20],[11;21], ...
    'VariableNames',{'RecordingID','EventType','SiteID','EventID','StartFrame','EndFrame','DetectedStartFrame','DetectedEndFrame'});
path=fullfile(root,'synthetic-audit.mat');save(path,'Audit');
R=struct('AuditPath',path,'AuditSHA256',oxygenFileSHA256(path),'Audit',Audit,'AnalysisInfo',struct('RawSHA256','raw','NFrames',100,'AnalysisParams',struct('fs',1)));
end

function testAreaAndDurationSurviveUnavailableRatio(t)
D=accept(fixture(),{10,10,10});original=computeBOIReviewedArea(D);
D.Context.CameraOffsetCounts=100;D.Context.RawReferenceMean=100;
D.Context.AmplitudePercent=NaN;D.Context.AmplitudeStatus='reference_at_or_below_camera_offset';
D.ContextSHA256=boiPocketDigest(D.Context);updated=computeBOIReviewedArea(D);
t.verifyEqual(updated.MeanAreaUm2,original.MeanAreaUm2);
t.verifyEqual(updated.FramePixels,original.FramePixels);t.verifyTrue(updated.Complete);
t.verifyTrue(isnan(updated.Contribution));t.verifyTrue(isnan(updated.NormalizedContribution));
end
