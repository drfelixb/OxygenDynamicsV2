function tests=testBOIEventBaselineFlags
% Twelve frozen scenario families; no external recording reads.
tests=functiontests(localfunctions);
end
function setupOnce(~),setupOxygenDynamicsPath;end

function testOrdinaryOwnReferenceAndPreservation(t)
[E,V,P,G]=fixture(31,34,100,1);old=E;
E=deriveBOIPreEpisodeReferences(E,V,P,1,20);saved=E;
D=deriveBOIEventReferences(E,V,P,1,20);
verifyEqual(t,D(:,saved.Properties.VariableNames),saved);
verifyEqual(t,D.EventAmplitudePercent,20,'AbsTol',1e-12);
verifyEqual(t,[D.EventReferenceStartFrame D.EventReferenceEndFrame],[11 30]);
verifyFalse(t,D.EventReferenceNeedsReview);verifyEqual(t,D.AboveRecordingReference,0);
verifyEqual(t,D.EventReferenceFiniteSamples,20);
% Exercise the actual live raw-footprint route, not a second calculator.
[S,X,cells]=liveFixture(old,V);[~,L]=finalizeOxygenEventMeasurements(S,old,cells,X,1,2,0,'R','sink',20);
verifyEqual(t,L.EventAmplitudePercent,D.EventAmplitudePercent);
verifyEqual(t,L.EventReferenceStatus,D.EventReferenceStatus);
verifyEqual(t,L.AboveRecordingReference,D.AboveRecordingReference);
B=createHypoxicBurdenMetrics(D,table(),table(),G);
verifyEqual(t,B.EventTable.BurdenAmplitudePercent,20);
policy=boiEventReferencePolicy;verifyEqual(t,string(B.ReferencePolicy.Version),string(policy.Version));
file=[tempname '.xlsx'];c=onCleanup(@()delete(file));writeHypoxicBurdenWorkbookSheets(file,B);
Q=readtable(file,'Sheet','HypoxicBurden_EventBased','VariableNamingRule','preserve');
verifyEqual(t,Q.EventAmplitudePercent,20);verifyEqual(t,Q.NormOxySinkAmpPercent,old.NormOxySinkAmpPercent);
verifyEqual(t,Q.SignedTraceAUC_sec,old.SignedTraceAUC_sec);
end

function testNonOneHzScalingAndBurdenWindows(t)
[E,V,P,G]=fixture(61,68,200,2);D=deriveBOIEventReferences(E,V,P,2,20);
verifyEqual(t,[D.EventReferenceStartFrame D.EventReferenceEndFrame D.EventReferenceRequestedSamples],[21 60 40]);
verifyEqual(t,D.RecordingReferenceEndFrame,40);
B=createHypoxicBurdenMetrics(D,table(),table(),G);expected=20*E.EventArea_um2*4;
verifyEqual(t,B.EventTable.PerEventBurdenContribution,expected,'AbsTol',1e-12);
verifyEqual(t,B.RecordingTable.HypoxicBurden_per_mm2_per_min,expected*1e6/1000*60/100,'AbsTol',1e-9);
W=createOxygenAnalysisWindows(G,table(),D,[]);
verifyEqual(t,W.AmplitudeAreaTimePercent_um2_sec,expected,'AbsTol',1e-12);
verifyEqual(t,W.AmplitudeAreaTime_per_mm2_per_min,B.RecordingTable.HypoxicBurden_per_mm2_per_min,'AbsTol',1e-9);
verifyEqual(t,sum(B.TimeSeriesTable.HypoxicBurdenOverTime)/2,expected,'AbsTol',1e-12);
verifyEqual(t,D.SignedTraceAUC_sec,E.SignedTraceAUC_sec);
D.EventAmplitudeAvailable=false;D.EventAmplitudePercent=NaN;
B=createHypoxicBurdenMetrics(D,table(),table(),G);W=createOxygenAnalysisWindows(G,table(),D,[]);
verifyTrue(t,isnan(B.RecordingTable.HypoxicBurden)&&isnan(W.AmplitudeAreaTimePercent_um2_sec));
end

function testShortPrehistoryAndNonprecedingComparator(t)
[E,V,P,G]=fixture(6,9,40,1);D=deriveBOIEventReferences(E,V,P,1,20);
verifyEqual(t,D.EventAmplitudePercent,20);verifyEqual(t,D.EventReferenceObservedSamples,5);
verifyTrue(t,D.EventReferenceShort&&D.EventReferenceNeedsReview);
verifyEqual(t,D.RecordingReferenceStatus,"not_assessable_not_preceding");verifyTrue(t,isnan(D.AboveRecordingReference));
B=createHypoxicBurdenMetrics(D,table(),table(),G);
verifyTrue(t,isfinite(B.RecordingTable.HypoxicBurden)&&B.RecordingTable.IncludesFlaggedReferences);
verifyEqual(t,B.RecordingTable.NumFlaggedReferenceContributors,1);
end

function testBothSignOverlapRetained(t)
[E,V,P,G]=fixture(31,34,100,1);
P{12}=[1;9];P{25}=1;P{26}=2;V{1}.Raw([12 25])=[60 120];
expectedMean=(18*100+60+120)/20;D=deriveBOIEventReferences(E,V,P,1,20);
verifyEqual(t,D.EventReferenceOverlapFrames,2);verifyEqual(t,D.RecordingReferenceOverlapFrames,1);
verifyEqual(t,D.EventReferenceValue,expectedMean);
verifyEqual(t,D.EventAmplitudePercent,100*(expectedMean-80)/expectedMean,'AbsTol',1e-12);
verifyTrue(t,D.EventReferenceOverlapping&&D.EventAmplitudeAvailable);
B=createHypoxicBurdenMetrics(D,table(),table(),G);verifyTrue(t,B.RecordingTable.IncludesFlaggedReferences);
end

function testMissingReferenceSamplesRetained(t)
[E,V,P,~]=fixture(31,34,100,1);V{1}.Raw([12 14])=NaN;
D=deriveBOIEventReferences(E,V,P,1,20);
verifyEqual(t,D.EventAmplitudePercent,20);verifyEqual(t,D.EventReferenceFiniteSamples,18);
verifyEqual(t,D.EventReferenceMissingSamples,2);verifyTrue(t,D.EventReferenceMissingSamplesFlag);
verifyEqual(t,D.RecordingReferenceFiniteSamples,18);verifyTrue(t,D.RecordingReferenceNeedsReview);
end

function testRecordingStartClippedPostReference(t)
[E,V,P,~]=fixture(1,8,15,1);D=deriveBOIEventReferences(E,V,P,1,20);
verifyEqual(t,[D.EventReferenceStartFrame D.EventReferenceEndFrame],[9 15]);
verifyEqual(t,D.EventReferenceObservedSamples,7);verifyEqual(t,D.EventAmplitudePercent,20);
verifyTrue(t,D.EventReferencePostEvent&&D.EventReferenceRecoveryUnverified&&D.EventReferenceShort);
verifyEqual(t,D.RecordingReferenceStatus,"not_assessable_not_preceding");
end

function testRecordingStartNoPostSamples(t)
[E,V,P,G]=fixture(1,15,15,1);D=deriveBOIEventReferences(E,V,P,1,20);
verifyEqual(t,D.EventReferenceStatus,"no_actual_reference_samples");
verifyTrue(t,isnan(D.EventReferenceStartFrame)&&isnan(D.EventAmplitudePercent));
verifyEqual(t,D.EventReferenceObservedSamples,0);
B=createHypoxicBurdenMetrics(D,table(),table(),G);verifyTrue(t,isnan(B.RecordingTable.HypoxicBurden));
end

function testNoFiniteReference(t)
[E,V,P,~]=fixture(31,34,100,1);V{1}.Raw(11:30)=NaN;
D=deriveBOIEventReferences(E,V,P,1,20);verifyEqual(t,D.EventReferenceStatus,"no_finite_reference_samples");
verifyEqual(t,D.EventReferenceMissingSamples,20);verifyFalse(t,D.EventAmplitudeAvailable);
verifyTrue(t,isnan(getBOISinkBurdenAmplitude(D)));
end

function testNonpositiveReference(t)
[E,V,P,~]=fixture(31,34,100,1);V{1}.Raw(11:30)=0;
D=deriveBOIEventReferences(E,V,P,1,20);verifyEqual(t,D.EventReferenceStatus,"nonpositive_or_nonfinite_reference");
verifyFalse(t,D.EventAmplitudeAvailable);verifyEqual(t,D.EventReferenceValue,0);
end

function testMissingEventSignal(t)
[E,V,P,~]=fixture(31,34,100,1);V{1}.Raw(32)=NaN;
D=deriveBOIEventReferences(E,V,P,1,20);verifyEqual(t,D.EventReferenceStatus,"missing_required_event_signal");
verifyFalse(t,D.EventSignalComplete||D.EventAmplitudeAvailable);
verifyEqual(t,D.RecordingReferenceStatus,"not_assessable_missing_event_signal");
verifyTrue(t,isnan(D.EventMinimumValue)&&isnan(D.AboveRecordingReference));
end

function testSignedAmplitudeAndReviewedAuthority(t)
[E,V,P,G]=fixture(31,34,100,1);V{1}.Raw(31:34)=105;
D=deriveBOIEventReferences(E,V,P,1,20);verifyEqual(t,D.EventAmplitudePercent,-5);
verifyTrue(t,D.EventAmplitudeAvailable&&D.EventAmplitudeNegative);verifyEqual(t,D.AboveRecordingReference,1);
verifyTrue(t,isnan(getBOISinkBurdenAmplitude(D)));verifyEqual(t,D.NormOxySinkAmpPercent,E.NormOxySinkAmpPercent);
% An explicit reviewed value must override the automatic selector, including
% a signed automatic amplitude. Keep the automatic reference and AUC evidence.
B=createHypoxicBurdenMetrics(D,table(),table(),G);
B.ReviewDecisions=table("R",1,1,"recognized",false,"boundary", ...
    'VariableNames',{'RecordingID','SinkID','EventIndex','RecognitionStatus','ExcludedFromReviewedBurden','ReviewSHA256'});
B.ReviewSummary=table("R",0,0,'VariableNames',{'RecordingID','AvailableContributions','MissingContributions'});
B.ReviewPolicy=struct();
S=struct('RecordingID','R','SiteID',1,'EventID',1,'OriginalAutomaticStartFrame',31,'OriginalAutomaticEndFrame',34, ...
    'StartFrame',31,'EndFrame',34,'DurationSec',4,'SampleHz',1,'RawSourceSHA256','raw','BoundarySHA256','boundary', ...
    'BurdenArea_um2',E.EventArea_um2,'BurdenRecordingArea_um2',1000,'BurdenRecordingDuration_sec',100, ...
    'BurdenAmplitudePercent',30,'ReferenceStartFrame',11,'ReferenceEndFrame',30,'ReferenceSamples',20, ...
    'ReferenceSHA256','reference','PerEventBurdenContribution',1200, ...
    'PerEventBurdenContribution_per_mm2_per_min',720000,'AreaRemeasured',false,'AreaQualification','constructed');
revision=struct('Document',S,'Path','constructed','ManifestSHA256','manifest');
R=applyBOIReviewedBurdenEvents(B,G,{revision});
verifyEqual(t,R.EventTable.BurdenAmplitudePercent,30);verifyEqual(t,R.RecordingTable.HypoxicBurden,1200);
verifyEqual(t,R.EventTable.EventAmplitudePercent,-5);verifyEqual(t,R.EventTable.SignedTraceAUC_sec,E.SignedTraceAUC_sec);
verifyFalse(t,R.RecordingTable.IncludesFlaggedReferences);
end

function testExplicitRecordingOverrideAndSourceIdentity(t)
[E,V,P,~]=fixture(51,54,100,1);override=struct('StartFrame',21,'EndFrame',40,'Source','explicit_test_override');
V{1}.Raw(1:20)=70;V{1}.Raw(21:40)=110;
D=deriveBOIEventReferences(E,V,P,1,20,'synthetic',override);
verifyEqual(t,D.RecordingReferenceValue,110);verifyEqual(t,D.AboveRecordingReference,0);
verifyTrue(t,D.RecordingReferenceOverride);verifyEqual(t,D.RecordingReferenceSource,"explicit_test_override");
default=deriveBOIEventReferences(E,V,P,1,20,'synthetic');
verifyEqual(t,default.EventAmplitudePercent,D.EventAmplitudePercent);verifyEqual(t,default.AboveRecordingReference,1);
% Exercise the production receipt-bound adapter with pre-episode values present.
E=deriveBOIPreEpisodeReferences(E,V,P,1,20);before=E;
folder=tempname;mkdir(folder);c=onCleanup(@()rmdir(folder,'s'));
[sf,uf,af]=savedFixture(folder,E,V);
S=attachSavedBOIEpisodeReferences(E,sf,uf,folder,1,override);
verifyEqual(t,S(:,before.Properties.VariableNames),before);
verifyEqual(t,S.EventAmplitudePercent,D.EventAmplitudePercent);
verifyEqual(t,S.RecordingReferenceValue,D.RecordingReferenceValue);
verifyEqual(t,S.EventReferenceAuditSHA256,string(oxygenFileSHA256(af)));
verifyEqual(t,attachSavedBOIEpisodeReferences(S,sf,uf,folder,1),S);
bad=S;bad.EventReferenceVersion(:)="unknown";
verifyError(t,@()getBOISinkBurdenAmplitude(bad),'OxygenDynamics:EventReferenceVersion');
bad=E;bad.StartFrame=50;
verifyError(t,@()attachSavedBOIEpisodeReferences(bad,sf,uf,folder,1,override),'OxygenDynamics:EpisodeSourceMismatch');
verifyError(t,@()deriveBOIEventReferences(E,V,P,1,20,'synthetic',struct('StartFrame',5,'EndFrame',4,'Source','bad')), ...
    'OxygenDynamics:EventReferenceEvidence');
A=load(af);A.Traces{1}.Raw(2)=999;save(af,'-struct','A');
verifyError(t,@()attachSavedBOIEpisodeReferences(E,sf,uf,folder,1),'OxygenDynamics:EpisodeSourceMismatch');
end

function [E,V,P,G]=fixture(first,last,N,fs)
G=table("R","example","mouse","baseline","none","genotype","promoter",false,N,fs,N/fs,1000,"raw", ...
    'VariableNames',{'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim', ...
    'NFrames','SampleF','RecordingDuration_sec','RecordingArea_um2','RawSHA256'});
E=G;E.SinkID=1;E.EventID=1;E.StartFrame=first;E.EndFrame=last;
E.StartSec=(first-1)/fs;E.EndSec=last/fs;E.DurationSec=(last-first+1)/fs;
E.EventArea_um2=10;E.RecAreaSize=1000;E.RecDuration=N/fs;
E.NormOxySinkAmp=.01;E.NormOxySinkAmpPercent=1;E.BaselineStatus="preserved_strict";
E.SignedTraceAUC_sec=-.8;E.AmplitudeSignConvention="positive_drop_percent";
for f={'MeanOxySinkArea_um','MeanOxySinkFilledArea_um','MeanOxySinkDiameter_um','MeanOxySinkPerimeter_um'}
    E.(f{1})=1;
end
raw=100*ones(1,N);raw(first:last)=80;
V={struct('Raw',raw,'Footprint',1,'DetectedFrames',first:last)};
P=cell(1,N);P(first:last)={1};
end
function [S,X,P]=liveFixture(E,V)
S=table({[NaN]},{1000},'VariableNames',{'NormOxySinkAmp','RecAreaSize'});
P=cell(1,E.NFrames);P(E.StartFrame:E.EndFrame)={1};
X=100*ones(2,2,E.NFrames);X(1,1,:)=reshape(V{1}.Raw,1,1,[]);
% Shape columns are original placeholders consumed by the existing finalizer.
% They are populated on E by the caller's fixture below.
end
function [sf,uf,af]=savedFixture(folder,E,V)
mkdir(fullfile(folder,'BOIReview'));sf=fullfile(folder,'Sink.mat');uf=fullfile(folder,'Surge.mat');
pc=cell(1,E.NFrames);pc(V{1}.DetectedFrames)={1};
Table_OxygenSinks_Out=table({pc},'VariableNames',{'FramePixels'});
Table_OxygenSurges_Out=Table_OxygenSinks_Out([],:);Table_OxygenSinkEvents_Out=E;
AnalysisInfo=struct('RawSHA256','raw','NFrames',E.NFrames,'AnalysisParams',struct('fs',E.SampleF,'quantBaselineWindowSec',20));
save(sf,'Table_OxygenSinks_Out','Table_OxygenSinkEvents_Out','AnalysisInfo');save(uf,'Table_OxygenSurges_Out','AnalysisInfo');
Audit=table("sink",E.SinkID,E.EventID,E.StartFrame,E.EndFrame,E.StartFrame,E.EndFrame,"raw",E.NormOxySinkAmp, ...
    'VariableNames',{'EventType','SiteID','EventID','StartFrame','EndFrame','DetectedStartFrame','DetectedEndFrame','SourceRawSHA256','StoredAmplitude'});
Traces=V;af=fullfile(folder,'BOIReview','event-amplitude-audit.mat');save(af,'Audit','Traces','AnalysisInfo');
receipt=struct('Schema','boi-created-event-audit-1','AuditSHA256',oxygenFileSHA256(af), ...
    'MasterSHA256',{{oxygenFileSHA256(sf),oxygenFileSHA256(uf)}},'SourceSHA256','raw','EventCount',1);
fid=fopen(fullfile(folder,'BOIReview','AuditCreationReceipt.json'),'w');fprintf(fid,'%s',jsonencode(receipt));fclose(fid);
end
