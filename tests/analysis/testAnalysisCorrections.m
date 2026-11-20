function tests=testAnalysisCorrections
tests=functiontests(localfunctions);
end
function setupOnce(t)
t.TestData.Root=fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(t.TestData.Root); setupOxygenDynamicsPath;
end
function testJoinIdentity(t)
E=events(2); F=E(:,{'RecordingID','Experiment','Mouse','SinkID','EventID'}); F.EventIndex=F.EventID;
F.Area_um=[100;400]; F.Area_norm=[.1;.4];
B=createHypoxicBurdenMetrics(E,F,table());
verifyEqual(t,B.EventTable.BurdenArea_um2,[100;400]);
verifyError(t,@()createHypoxicBurdenMetrics(E,[F;F(1,:)],table()),'OxygenDynamics:AmbiguousEventKey');
end
function testStrictMissing(t)
E=events(1); E.EventArea_um2=NaN; B=createHypoxicBurdenMetrics(E,table(),table());
verifyTrue(t,isnan(B.RecordingTable.HypoxicBurden));
end
function testPuff(t)
P=cell(7,1); M=P; P{7}=[ones(1,30)*10,ones(1,61)*20];M{7}="M";
O=formatPooledTracesForExport(P,M); verifyEqual(t,O{7}{1,4:end},[zeros(1,30),ones(1,61)]);
P{7}=[zeros(1,30),ones(1,61)];O=formatPooledTracesForExport(P,M);verifyTrue(t,all(isnan(O{7}{1,4:end})));
end
function testNativeArea(t)
S=table({[2,5]},{[1,1]},{100},{[1;2;3;4]},'VariableNames',{'Start','Duration','RecAreaSize','OxySink_Pxls_all'});
pc=cell(1,6);pc{2}=[1;2];pc{5}=[1;2;3;4];S.FramePixels={pc};S.EligibleTissuePixels={(1:25)'};
T=computeOngoingSinkTimeSeries(S,6,2);verifyEqual(t,T.AreaUm,[0,8,0,0,16,0]);
verifyEqual(t,T.AreaNorm,[0,.08,0,0,.16,0],'AbsTol',1e-12);
end
function testBurdenIntegral(t)
E=events(1);B=createHypoxicBurdenMetrics(E,table(),table());
verifyEqual(t,sum(B.TimeSeriesTable.HypoxicBurdenOverTime),B.EventTable.PerEventBurdenContribution,'AbsTol',1e-10);
end
function testSignIndependent(t)
E=events(2);E.NormOxySinkAmpPercent=[-10;20];
A=createHypoxicBurdenMetrics(E(1,:),table(),table());B=createHypoxicBurdenMetrics(E,table(),table());
verifyTrue(t,isnan(A.EventTable.BurdenAmplitudePercent(1))&&isnan(B.EventTable.BurdenAmplitudePercent(1)));
end
function testZeroAndPair(t)
E=events(2);R=E(:,{'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'});
R.RecordingArea_um2=[1e6;1e6];R.RecordingDuration_sec=[10;10];
B=createHypoxicBurdenMetrics(E(1,:),table(),table(),R);
verifyEqual(t,B.RecordingTable.NumEvents,[1;0]);verifyEqual(t,B.RecordingTable.HypoxicBurden(2),0);
P=table("R1","R2",'VariableNames',{'BaselineRecordingID','ComparisonRecordingID'});
C=createOxygenBaselineContrasts(B.RecordingTable,P);verifyEqual(t,C.RelativeChangePercent(1),-100);
P=table("R2","R1",'VariableNames',{'BaselineRecordingID','ComparisonRecordingID'});
C=createOxygenBaselineContrasts(B.RecordingTable,P);verifyEqual(t,C.Status(1),"zero_baseline");
end
function E=events(n)
E=table();E.RecordingID=compose('R%d',(1:n)');E.Experiment=cellstr(E.RecordingID);E.Mouse=repmat({'M'},n,1);
E.Condition=repmat({'Awake'},n,1);E.DrugID=repmat({'None'},n,1);E.Genotype=repmat({'WT'},n,1);E.Promoter=repmat({'GFAP'},n,1);E.PuffStim=false(n,1);
E.SinkID=ones(n,1);E.EventID=ones(n,1);E.StartFrame=3*ones(n,1);E.EndFrame=5*ones(n,1);
E.StartSec=2*ones(n,1);E.EndSec=5*ones(n,1);E.DurationFrames=3*ones(n,1);E.DurationSec=3*ones(n,1);
E.SampleF=ones(n,1);E.NormOxySinkAmpPercent=20*ones(n,1);E.EventArea_um2=100*ones(n,1);E.MeanOxySinkArea_um=100*ones(n,1);
E.RecAreaSize=1e6*ones(n,1);E.RecDuration=10*ones(n,1);
end
function testEventFootprintAmplitude(t)
S=table({[6,15]},{[2,2]},{1e3},{[.1,.1]},'VariableNames',{'Start','Duration','RecAreaSize','NormOxySinkAmp'});
E=events(2);E.RecordingID=repmat("R1",2,1);E.EventID=[1;2];E.StartFrame=[6;15];E.EndFrame=[7;16];
E.NormOxySinkAmp=[.1;.1];
for f={'MeanOxySinkFilledArea_um','MeanOxySinkDiameter_um','MeanOxySinkPerimeter_um'}, E.(f{1})=[1;1];end
P=cell(1,20);P{6}=1;P{7}=1;P{15}=2;P{16}=2;
X=100*ones(2,2,20);X(1,1,6:7)=80;X(2,1,15:16)=60;
[S,E]=finalizeOxygenEventMeasurements(S,E,P,X,1,2,0,"R1",'sink',3);
verifyEqual(t,E.NormOxySinkAmp,[.2;.4],'AbsTol',1e-12);
verifyEqual(t,E.EventArea_um2,[4;4]);verifyEqual(t,E.DurationSec,[2;2]);
verifyEqual(t,S.NormOxySinkAmp{1},[.2,.4],'AbsTol',1e-12);
end
function testMouseWeight(t)
E=events(3);R=E(:,{'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'});
R.Mouse={'M1';'M1';'M2'};R.NumEvents=[1;1;1];R.NumSinkSites=[1;1;1];R.HypoxicBurden=[10;10;40];
G=summarizeOxygenMouseMetrics(R);verifyEqual(t,G.HypoxicBurden_Mean,25);verifyEqual(t,G.NumMice,2);
end
function testPhysicalTraceClock(t)
[X,fs]=alignOxygenTraceSamples({[10,20];[1,2,3,4]},[1;2]);
verifyEqual(t,fs,2);verifyEqual(t,X,[10,10,20,20;1,2,3,4]);
[X,L]=averageOxygenTracesByMouse([10,10;10,10;40,40],["A";"A";"A"],["M1";"M1";"M2"]);
verifyEqual(t,mean(X,1),[25,25]);verifyEqual(t,L,["A";"A"]);
end
function testWindowOverlap(t)
E=events(1);R=E(:,{'RecordingID','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'});
R.NFrames=10;R.SampleF=2;R.RecordingDuration_sec=5;R.RecordingArea_um2=100;R.PixelSize=2;
E.StartSec=1;E.EndSec=3;E.EventArea_um2=4;
S=table("R1",{3},{4},{100},'VariableNames',{'RecordingID','Start','Duration','RecAreaSize'});
pc=cell(1,10);pc(3:6)={1};S.FramePixels={pc};S.EligibleTissuePixels={(1:25)'};
W=table(["R1";"R1"],["before";"after"],[0;1.5],[1.5;5], ...
    'VariableNames',{'RecordingID','WindowID','StartSec','EndSec'});
O=createOxygenAnalysisWindows(R,S,E,W);
verifyEqual(t,O.EventOnsets,[1;0]);verifyEqual(t,O.ActiveEventSeconds,[.5;1.5]);
verifyEqual(t,O.MeanOccupiedTissueFraction,[2/150;6/350],'AbsTol',1e-12);
verifyEqual(t,O.AmplitudeAreaTimePercent_um2_sec,[40;120]);
P=table("R1","before","after",'VariableNames',{'RecordingID','BaselineWindowID','ComparisonWindowID'});
C=createOxygenWindowContrasts(O,P);verifyEqual(t,C.RelativeChangePercent(1),-100);
E.NormOxySinkAmpPercent=-20;O=createOxygenAnalysisWindows(R,S,E,W);
verifyTrue(t,all(isnan(O.AmplitudeAreaTimePercent_um2_sec)));
end
function testSurgeRawFractionAndIncompleteBaseline(t)
S=table({[6,15]},{[2,2]},{100},{[2,2]},'VariableNames', ...
    {'Start_Surge','Duration_Surge','RecAreaSize_Surge','NormOxySurgeAmp'});
E=table([1;1],[1;2],[6;15],[7;16],[2;2], ...
    'VariableNames',{'SurgeID','EventID','StartFrame','EndFrame','NormOxySurgeAmp'});
for f={'MeanOxySurgeArea_um','MeanOxySurgeFilledArea_um','MeanOxySurgeDiameter_um','MeanOxySurgePerimeter_um'},E.(f{1})=[1;1];end
P=cell(1,20);P(6:7)={1};P(15:16)={2};
X=100*ones(2,2,20);X(1,1,6:7)=120;X(2,1,15:16)=140;
[~,A]=finalizeOxygenEventMeasurements(S,E,P,X,2,2,0,"R1",'surge',2);
verifyEqual(t,A.NormOxySurgeAmp,[.2;.4],'AbsTol',1e-12);
verifyEqual(t,A.DurationSec,[1;1]);verifyEqual(t,A.StartSec,[2.5;7]);
[~,A]=finalizeOxygenEventMeasurements(S,E,P,X,2,2,0,"R1",'surge',3);
verifyTrue(t,isnan(A.NormOxySurgeAmp(1)));verifyEqual(t,A.BaselineStatus(1),"insufficient_clean_prebaseline");
end
function testZeroRecordingTraceAndFsIntegral(t)
E=events(2);R=E(:,{'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'});
R.NFrames=[20;20];R.SampleF=[2;2];R.RecordingDuration_sec=[10;10];R.RecordingArea_um2=[1e6;1e6];
E=E(1,:);E.SampleF=2;E.DurationSec=1.5;E.StartSec=1;E.EndSec=2.5;
B=createHypoxicBurdenMetrics(E,table(),table(),R);
T=B.TimeSeriesTable;
verifyEqual(t,sum(T.HypoxicBurdenOverTime(T.RecordingID=="R1"))/2,B.RecordingTable.HypoxicBurden(1),'AbsTol',1e-12);
verifyEqual(t,T.HypoxicBurdenOverTime(T.RecordingID=="R2"),zeros(20,1));
verifyEqual(t,B.GroupSummaryTable.NumMice,1);
end
function testOppositeEventExcludesBaseline(t)
S=table({6},{2},{100},{.2},'VariableNames',{'Start','Duration','RecAreaSize','NormOxySinkAmp'});
E=events(1);E.StartFrame=6;E.EndFrame=7;E.NormOxySinkAmp=.2;
for f={'MeanOxySinkFilledArea_um','MeanOxySinkDiameter_um','MeanOxySinkPerimeter_um'},E.(f{1})=1;end
P=cell(1,10);P(6:7)={1};Other=cell(1,10);Other{4}=1;
X=100*ones(2,2,10);X(1,1,6:7)=80;
[~,A]=finalizeOxygenEventMeasurements(S,E,P,X,1,2,0,"R1",'sink',3,Other,0);
verifyTrue(t,isnan(A.NormOxySinkAmp));verifyEqual(t,A.BaselineValidSamples,2);
end
