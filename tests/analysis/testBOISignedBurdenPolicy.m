function tests=testBOISignedBurdenPolicy
% Twelve frozen constructed/table-level checks; no recording sources.
tests=functiontests(localfunctions);
end
function setupOnce(~),setupOxygenDynamicsPath;end

function testFiniteSignedProductsAndFlags(t)
[E,G]=fixture([10;-5;0;NaN]);original=E;
B=signed(E,G);
verifyEqual(t,B.EventTable.PerEventBurdenContribution,[80;-40;0;NaN]);
verifyEqual(t,B.EventTable.BurdenAmplitudeNegative,[0;1;0;NaN]);
verifyEqual(t,B.EventTable.BurdenContributionSignStatus,["nonnegative";"negative";"nonnegative";"not_assessable"]);
verifyEqual(t,E,original);verifyEqual(t,B.EventTable.SignedTraceAUC_sec,E.SignedTraceAUC_sec);
verifyEqual(t,B.RecordingTable.NumNegativeBurdenContributions,1);
verifyEqual(t,B.RecordingTable.NumAvailableBurdenContributions,3);
end
function testNegativeAndZeroCompleteRecordingTotals(t)
[E,G]=fixture([10;-20]);B=signed(E,G);
verifyEqual(t,B.RecordingTable.HypoxicBurden,-80);
verifyEqual(t,B.RecordingTable.BurdenTotalSign,"negative");
verifyEqual(t,B.RecordingTable.NormalizedBurdenTotalNegative,1);
E.NormOxySinkAmpPercent=[10;-10];B=signed(E,G);
verifyEqual(t,B.RecordingTable.HypoxicBurden,0);verifyEqual(t,B.RecordingTable.BurdenTotalSign,"zero");
E.NormOxySinkAmpPercent=[20;-10];B=signed(E,G);
verifyEqual(t,B.RecordingTable.HypoxicBurden,80);verifyEqual(t,B.RecordingTable.BurdenTotalSign,"positive");
end
function testMissingIngredientsKeepStrictTotalsUnavailable(t)
for name={'NormOxySinkAmpPercent','EventArea_um2','DurationSec'}
    [E,G]=fixture([-5;10]);E.(name{1})(2)=NaN;B=signed(E,G);
    verifyEqual(t,B.EventTable.PerEventBurdenContribution(1),-40);
    verifyTrue(t,isnan(B.EventTable.PerEventBurdenContribution(2)));
    verifyTrue(t,isnan(B.RecordingTable.HypoxicBurden_per_mm2_per_min));
    verifyEqual(t,B.RecordingTable.NormalizedBurdenTotalSign,"not_assessable");
end
[E,G]=fixture(-5);E.EventArea_um2=NaN;B=signed(E,G);
verifyEqual(t,B.EventTable.BurdenAmplitudeNegative,1);verifyTrue(t,isnan(B.EventTable.BurdenContributionNegative));
verifyEqual(t,B.RecordingTable.NumNegativeBurdenAmplitudes,1);verifyEqual(t,B.RecordingTable.NumNegativeBurdenContributions,0);
end
function testAnalyzedZeroAndUnknownInventoryStayDistinct(t)
[E,G]=fixture(10);B=signed(E([],:),G);
verifyEqual(t,B.RecordingTable.HypoxicBurden,0);verifyEqual(t,B.RecordingTable.NumRequiredBurdenContributions,0);
verifyEqual(t,B.RecordingTable.BurdenTotalSign,"zero");
G.AnalysisStatus="failed";
verifyError(t,@()signed(E([],:),G),'OxygenDynamics:RecordingNotAnalyzed');
verifyError(t,@()createOxygenAnalysisWindows(G,table(),E([],:),table(),'sink',boiBurdenSelectionPolicy()),'OxygenDynamics:RecordingNotAnalyzed');
end
function testNormalizationAppliedExactlyOnce(t)
[E,G]=fixture([-5;10]);E.SampleF(:)=2;E.DurationSec(:)=1;E.StartSec=(E.StartFrame-1)/2;E.EndSec=E.EndFrame/2;
E.RecAreaSize(:)=2e6;E.RecDuration(:)=60;G.SampleF=2;G.RecordingArea_um2=2e6;G.RecordingDuration_sec=60;
B=signed(E,G);
verifyEqual(t,B.EventTable.PerEventBurdenContribution,[-20;40]);
verifyEqual(t,B.RecordingTable.HypoxicBurden_per_mm2_per_min,10,'AbsTol',1e-10);
verifyEqual(t,B.EventTable.BurdenArea_um2,E.EventArea_um2);verifyEqual(t,B.EventTable.BurdenDuration_sec,E.DurationSec);
verifyEqual(t,B.EventTable.NormOxySinkAmpPercent,E.NormOxySinkAmpPercent);
end
function testQualityAndRecordingReferenceFlagsDoNotExclude(t)
[E,G]=fixture([-5;10]);P=boiEventReferencePolicy;
E.EventReferenceVersion=repmat(string(P.Version),2,1);E.EventAmplitudePercent=[-5;10];E.EventAmplitudeAvailable=true(2,1);
E.EventReferenceNeedsReview=true(2,1);E.EventReferenceShort=true(2,1);E.EventReferenceOverlapping=true(2,1);
E.EventReferencePostEvent=true(2,1);E.EventReferenceMissingSamplesFlag=false(2,1);E.AboveRecordingReference=ones(2,1);
B=signed(E,G);verifyEqual(t,B.EventTable.PerEventBurdenContribution,[-40;80]);
verifyEqual(t,B.RecordingTable.NumFlaggedReferenceContributors,2);verifyEqual(t,B.RecordingTable.NumAboveRecordingReferenceEvents,2);
verifyEqual(t,B.EventTable.EventAmplitudePercent,E.EventAmplitudePercent);
end
function testReviewedSignedValuesHaveExplicitAuthority(t)
root=tempname;F=makeBOIReviewedExportFixture(root,'legacy');cleanup=onCleanup(@()rmdir(root,'s'));
% Construct a coherent signed reviewed artifact before it is treated as saved.
S=jsondecode(fileread(fullfile(F.EventFolders{1},'ReviewedEventBurden.json')));
A=load(F.AuditPath);A.Traces{2}.Raw(12:17)=50;save(F.AuditPath,'-struct','A');
receiptPath=fullfile(root,'AuditCreationReceipt.json');receipt=jsondecode(fileread(receiptPath));receipt.AuditSHA256=oxygenFileSHA256(F.AuditPath);writeBOIRunJSON(receiptPath,receipt);
R=loadBOIEventReview(F.AuditPath);annotation=struct('Status','recognized','OnsetFrames',18,'RecoveryFrames',22, ...
    'PreferredOnsetFrame',18,'PreferredRecoveryFrame',22,'Reviewer','Synthetic software check','Reason','Constructed signed import, no biological judgment');
R.BoundaryReview=saveBOIBoundaryReview(R,2,annotation,fullfile(root,'signed-boundary.json'));
J=jsondecode(fileread(S.ReferencePath));J.BoundaryReviewSHA256=R.BoundaryReview.SHA256;
boundary=getBOIBoundaryReview(R,2);J.BoundaryAnnotationUnchanged=boundary.Annotation;J.SavedEvent=boundary.Event;
reference=fullfile(root,'signed-reference.json');writeBOIRunJSON(reference,J);
S.AuditSHA256=R.AuditSHA256;S.BoundaryPath=R.BoundaryReview.Path;S.BoundarySHA256=R.BoundaryReview.SHA256;
S.ReferencePath=reference;S.ReferenceSHA256=oxygenFileSHA256(reference);S.RawReferenceMean=50;S.RawMinimum=70;
S.BurdenAmplitudePercent=-40;S.PerEventBurdenContribution=-600;S.PerEventBurdenContribution_per_mm2_per_min=-3600000;
P=boiBurdenSelectionPolicy;S.BurdenSelectionPolicyVersion=P.Version;
artifact=F.EventFolders{1};writeBOIRunJSON(fullfile(artifact,'ReviewedEventBurden.json'),S);refreshChecksums(artifact);
V=loadBOIReviewedBurdenEvent(artifact);verifyEqual(t,V.Document.BurdenAmplitudePercent,-40);
B=signed(F.Automatic.EventTable,F.Registry);
Q=createBOIReviewedBurdenMetrics(B,F.Registry,{R},{V});
verifyEqual(t,Q.EventTable.BurdenAmplitudePercent,[10;-40]);
verifyEqual(t,Q.EventTable.PerEventBurdenContribution,[80;-600]);verifyEqual(t,Q.RecordingTable.HypoxicBurden,-520);
verifyEqual(t,Q.EventTable.NormOxySinkAmpPercent,B.EventTable.NormOxySinkAmpPercent);
verifyEqual(t,Q.EventTable.BurdenContributionNegative,[0;1]);
end
function testNotPocketExclusionsAndIdentity(t)
root=tempname;F=makeBOIReviewedExportFixture(root,'complete');cleanup=onCleanup(@()rmdir(root,'s'));
E=F.Automatic.EventTable;E.NormOxySinkAmpPercent(2)=-20;
other=E(1,:);other.RecordingID="other-constructed";other.Mouse="0008";other.Condition="treatment";
G=F.Registry;g=G;g.RecordingID=other.RecordingID;g.Mouse=other.Mouse;g.Condition=other.Condition;
B=signed([E;other],[G;g]);R=loadBOIEventReview(F.AuditPath);R.BoundaryReview=loadBOIBoundaryReview(R,F.ReviewPaths{1});
Q=createBOIReviewedBurdenMetrics(B,[G;g],{R});
verifyEqual(t,height(Q.ExcludedDetections),1);verifyEqual(t,Q.RecordingTable.HypoxicBurden,[-120;80]);
verifyEqual(t,Q.RecordingTable.NumNegativeBurdenContributions,[1;0]);
verifyEqual(t,B.EventTable.PerEventBurdenContribution,[80;-120;80]);
end
function testHistoricalPoliciesRemainReadableWithoutRelabelling(t)
[E,G]=fixture([10;-5]);legacy=createHypoxicBurdenMetrics(E,table(),table(),G);before=legacy;
folder=tempname;mkdir(folder);cleanup=onCleanup(@()rmdir(folder,'s'));path=fullfile(folder,'old.mat');save(path,'legacy');hash=oxygenFileSHA256(path);
B=signed(E,G);saved=load(path);verifyEqual(t,saved.legacy,before);verifyEqual(t,oxygenFileSHA256(path),hash);
verifyTrue(t,isnan(before.EventTable.PerEventBurdenContribution(2)));verifyEqual(t,B.EventTable.PerEventBurdenContribution(2),-40);
verifyFalse(t,isfield(before,'SelectionPolicy'));verifyTrue(t,isfield(B,'SelectionPolicy'));
end
function testPolicyVersionAndSourceConflictGuards(t)
[E,G]=fixture([10;-5]);E.BurdenSelectionPolicyVersion=["unknown";"unknown"];
verifyError(t,@()signed(E,G),'OxygenDynamics:BurdenSelectionPolicy');
E.BurdenSelectionPolicyVersion=["boi-signed-contributions-1";"boi-legacy-nonnegative-1"];
verifyError(t,@()signed(E,G),'OxygenDynamics:BurdenSelectionPolicy');
E.BurdenSelectionPolicyVersion(:)="boi-signed-contributions-1";
verifyError(t,@()getBOISinkBurdenAmplitude(E,'boi-legacy-nonnegative-1'),'OxygenDynamics:BurdenSelectionPolicy');
% The frozen reviewed-source regression separately checks parent tampering.
end
function testWindowsAndSavedCurvesPreserveSignedSemantics(t)
[E,G]=fixture([10;-5]);B=signed(E,G);P=boiBurdenSelectionPolicy;
[W,~]=createOxygenAnalysisWindows(G,table(),E,table(),'sink',P);
verifyEqual(t,W.AmplitudeAreaTimePercent_um2_sec,40);verifyEqual(t,W.AmplitudeAreaTime_per_mm2_per_min,B.RecordingTable.HypoxicBurden_per_mm2_per_min);
verifyTrue(t,any(B.TimeSeriesTable.HypoxicBurdenOverTime<0));
expected=sum(B.TimeSeriesTable.HypoxicBurdenPerMm2OverTime)/G.SampleF*60/G.RecordingDuration_sec;
verifyEqual(t,expected,B.RecordingTable.HypoxicBurden_per_mm2_per_min,'AbsTol',1e-10*max(1,abs(expected)));
E.NormOxySinkAmpPercent(1)=NaN;B=signed(E,G);
verifyTrue(t,isnan(B.RecordingTable.HypoxicBurden));verifyTrue(t,any(isnan(B.TimeSeriesTable.HypoxicBurdenOverTime)));
verifyTrue(t,any(isfinite(B.TimeSeriesTable.HypoxicBurdenOverTime)));
end
function testExistingFormatsPersistSignedValuesAndFlags(t)
F=makeBOIReviewedExportFixture(tempname,'complete');
cleanup=onCleanup(@()rmdir(F.Root,'s')); %#ok<NASGU>
source=load(F.StatsMAT);E=source.HypoxicBurden.EventTable;
E.NormOxySinkAmpPercent(2)=-20;
source.HypoxicBurden=createHypoxicBurdenMetrics(E,table(),table(),source.RecordingRegistry,boiBurdenSelectionPolicy());
save(F.StatsMAT,'-struct','source');sourceHash=oxygenFileSHA256(F.StatsMAT);
plan=prepareBOIReviewedBurdenExport(F.StatsMAT,F.ReviewPaths,F.OutputFolder);
receipt=exportBOIReviewedBurden(plan.StatsMAT,plan.ReviewPaths,plan.OutputFolder,plan.ReviewedEventFolders,plan);
path=receipt.Workbook;
R=readtable(path,'Sheet','HypoxicBurden_ByRecording','VariableNamingRule','preserve');
verifyEqual(t,R.HypoxicBurden,-120);verifyEqual(t,R.HypoxicBurden_per_mm2_per_min,-720000);
verifyEqual(t,R.NumNegativeBurdenContributions,1);verifyEqual(t,string(R.NormalizedBurdenTotalSign),"negative");
E=readtable(path,'Sheet','HypoxicBurden_EventBased','VariableNamingRule','preserve');verifyEqual(t,E.BurdenAmplitudeNegative,1);
P=readtable(path,'Sheet','Burden_SelectionPolicy');verifyEqual(t,string(P.Version),"boi-signed-contributions-1");
M=load(fullfile(F.OutputFolder,'ReviewedHypoxicBurden.mat'));verifyEqual(t,M.HypoxicBurden.EventTable.PerEventBurdenContribution,-120);
C=readtable(fullfile(F.OutputFolder,'HypoxicBurden_ByRecording.csv'),'VariableNamingRule','preserve');verifyEqual(t,C.HypoxicBurden,-120);
verifyEqual(t,oxygenFileSHA256(F.StatsMAT),sourceHash);
[events,registry]=fixture([-5;10]);B=signed(events,registry);core=struct('TableOxygenSinks',table(),'TableOxygenSinkEvents',events, ...
    'TableOxygenSurges',table(),'TableOxygenSurgeEvents',table(),'RecordingRegistry',registry);
D=createAutomaticAmplitudeExportData(core,B);v=D.Availability(D.Availability.EventType=="sink",:);
verifyEqual(t,v.NegativeAmplitudeExcludedFromBurdenEvents,0);verifyEqual(t,v.SelectedNegativeContributionEvents,1);
verifyTrue(t,contains(D.Definitions.SignAndAvailability(7),'not excluded'));
end

function B=signed(E,G),B=createHypoxicBurdenMetrics(E,table(),table(),G,boiBurdenSelectionPolicy());end
function [E,G]=fixture(amplitude)
amplitude=amplitude(:);n=numel(amplitude);
G=table("r31-synthetic","fixture","0001","control","none","g","p",false,120,1,120,1000,"synthetic-raw",1,"loaded", ...
    'VariableNames',{'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim','NFrames','SampleF', ...
    'RecordingDuration_sec','RecordingArea_um2','RawSHA256','PixelSize','AnalysisStatus'});
E=repmat(G,n,1);E.SinkID=(1:n)';E.EventID=ones(n,1);E.EventIndex=ones(n,1);
E.StartFrame=10+3*(1:n)';E.EndFrame=E.StartFrame+1;E.DurationSec=2*ones(n,1);
E.StartSec=E.StartFrame-1;E.EndSec=E.EndFrame;E.NormOxySinkAmpPercent=amplitude;
E.NormOxySinkAmp=amplitude/100;E.EventArea_um2=4*ones(n,1);E.RecAreaSize=1000*ones(n,1);E.RecDuration=120*ones(n,1);
E.SignedTraceAUC_sec=-.25*ones(n,1);
end
function refreshChecksums(folder)
files=dir(folder);M=struct('Path',{},'SHA256',{});
for i=1:numel(files)
    if files(i).isdir||strcmp(files(i).name,'Checksums.json'),continue;end
    M(end+1)=struct('Path',files(i).name,'SHA256',oxygenFileSHA256(fullfile(folder,files(i).name))); %#ok<AGROW>
end
writeBOIRunJSON(fullfile(folder,'Checksums.json'),M);
end
