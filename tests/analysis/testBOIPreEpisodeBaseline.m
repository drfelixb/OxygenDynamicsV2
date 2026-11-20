function tests=testBOIPreEpisodeBaseline
tests=functiontests(localfunctions);
end
function setupOnce(~),setupOxygenDynamicsPath;end
function testOwnFootprintsAndOriginals(t)
[E,V,P]=fixture;old=E;D=deriveBOIPreEpisodeReferences(E,V,P,1,20);
verifyEqual(t,D(:,old.Properties.VariableNames),old);
verifyEqual(t,D.EpisodeReferenceStartFrame,[11;11;80]);
verifyEqual(t,D.EpisodeReferenceEndFrame,[30;30;99]);
verifyEqual(t,D.EpisodeReferenceValue,[100;200;100]);
verifyEqual(t,D.EpisodeAmplitudePercent,[20;20;25],'AbsTol',1e-12);
verifyEqual(t,D.EpisodeHeadEventID,[1;1;3]);
verifyEqual(t,D.EpisodeReferenceKind,["immediate_pre_event";"pre_episode";"immediate_pre_event"]);
verifyFalse(t,any(D.EpisodeReferenceNeedsReview));
end
function testOrderAndChainAge(t)
[E,V,~]=fixture;E.StartFrame=[31;46;61];E.EndFrame=E.StartFrame+3;
[V,P]=retime(E,V);D=deriveBOIPreEpisodeReferences(E,V,P,1,20);
verifyEqual(t,D.EpisodeHeadEventID,[1;1;1]);
verifyEqual(t,D.EpisodeReferenceShiftSec,[0;15;30]);
verifyEqual(t,D.EpisodeReferenceStatus(3),"reference_too_old_review");
verifyTrue(t,isnan(D.EpisodeAmplitudePercent(3))&&D.EpisodeReferenceNeedsReview(3));
order=[3;1;2];Q=deriveBOIPreEpisodeReferences(E(order,:),V(order),P,1,20);
verifyEqual(t,Q.EpisodeReferenceStatus,D.EpisodeReferenceStatus(order));
end
function testAgeBoundary(t)
[E,V,~]=fixture;E=E(1:2,:);V=V(1:2);E.StartFrame(2)=51;E.EndFrame(2)=54;
[V,P]=retime(E,V);D=deriveBOIPreEpisodeReferences(E,V,P,1,20);
verifyEqual(t,D.EpisodeReferenceStatus(2),"valid");
E.StartFrame(2)=52;E.EndFrame(2)=55;[V,P]=retime(E,V);
D=deriveBOIPreEpisodeReferences(E,V,P,1,20);
verifyEqual(t,D.EpisodeReferenceStatus(2),"reference_too_old_review");
end
function testSpatiallySeparateRuns(t)
[E,V,P]=fixture;V{2}.Footprint=2;V{2}.Raw(:)=200;V{2}.Raw(36:39)=160;
for f=36:39,P{f}=2;end
D=deriveBOIPreEpisodeReferences(E,V,P,1,20);
verifyEqual(t,D.EpisodeHeadEventID,[1;2;3]);
verifyEqual(t,D.EpisodeReferenceKind(2),"immediate_pre_event");
verifyEqual(t,D.EpisodeAmplitudePercent(2),20,'AbsTol',1e-12);
end
function testBothSignOtherSiteOverlap(t)
[E,V,P]=fixture;P{15}=[1;99];D=deriveBOIPreEpisodeReferences(E,V,P,1,20);
verifyEqual(t,D.EpisodeReferenceValidSamples(1:2),[19;19]);
verifyTrue(t,all(isnan(D.EpisodeAmplitudePercent(1:2))));
% An unrelated, spatially separate event does not exclude the reference.
P{15}=99;D=deriveBOIPreEpisodeReferences(E,V,P,1,20);
verifyEqual(t,D.EpisodeReferenceStatus(1:2),["valid";"valid"]);
end
function testRecordingStartAndTruncatedReference(t)
[E,V,~]=fixture;E.StartFrame(1:2)=[1;6];E.EndFrame=E.StartFrame+3;
[V,P]=retime(E,V);D=deriveBOIPreEpisodeReferences(E,V,P,1,20);
verifyEqual(t,D.EpisodeReferenceStatus(1:2),repmat("recording_start_recovery_unclear",2,1));
verifyTrue(t,all(D.EpisodeAcquisitionStart(1:2))&&all(isnan(D.EpisodeAmplitudePercent(1:2))));
E.StartFrame(1:2)=[10;16];E.EndFrame=E.StartFrame+3;[V,P]=retime(E,V);
D=deriveBOIPreEpisodeReferences(E,V,P,1,20);
verifyEqual(t,D.EpisodeReferenceValidSamples(2),9);
verifyTrue(t,isnan(D.EpisodeAmplitudePercent(2)));
end
function testFinitePositiveAndDirection(t)
[E,V,P]=fixture;V{1}.Raw(15)=NaN;V{2}.Raw(11:30)=0;V{3}.Raw(100:103)=105;
D=deriveBOIPreEpisodeReferences(E,V,P,1,20);
verifyEqual(t,D.EpisodeReferenceStatus,["insufficient_clean_pre_episode_reference"; ...
    "nonpositive_reference_or_missing_event_signal";"wrong_direction"]);
verifyEqual(t,D.EpisodeAmplitudePercent(3),-5,'AbsTol',1e-12);
a=getBOISinkBurdenAmplitude(D);verifyTrue(t,all(isnan(a)));
V{1}.Raw(15)=100;V{1}.Raw(31)=NaN;D=deriveBOIPreEpisodeReferences(E,V,P,1,20);
verifyEqual(t,D.EpisodeReferenceStatus(1),"nonpositive_reference_or_missing_event_signal");
end
function testUniformClock(t)
[E,V,~]=fixture;E.StartFrame=2*E.StartFrame-1;E.EndFrame=2*E.EndFrame;
[V,P]=retime(E,V,240);D=deriveBOIPreEpisodeReferences(E,V,P,2,20);
verifyEqual(t,D.EpisodeReferenceRequiredSamples,[40;40;40]);
verifyEqual(t,D.EpisodeReferenceStartFrame,[21;21;159]);
verifyEqual(t,D.EpisodeReferenceShiftSec,[0;5;0]);
end
function testBurdenStrictnessNormalizationAndWindow(t)
[E,V,P]=fixture;D=deriveBOIPreEpisodeReferences(E,V,P,1,20);R=registry;
B=createHypoxicBurdenMetrics(D,table(),table(),R);
verifyEqual(t,B.EventTable.BurdenAmplitudePercent,[20;20;25],'AbsTol',1e-12);
expected=[20;20;25].*E.EventArea_um2.*E.DurationSec;
verifyEqual(t,B.EventTable.PerEventBurdenContribution,expected,'AbsTol',1e-10);
verifyEqual(t,B.RecordingTable.HypoxicBurden_per_mm2_per_min,sum(expected)*1e6/8e5*60/120,'AbsTol',1e-9);
verifyEqual(t,B.RecordingTable.NumPreEpisodeReferenceEvents,1);
W=createOxygenAnalysisWindows(R,table(),D,[]);
verifyEqual(t,W.AmplitudeAreaTimePercent_um2_sec,sum(expected),'AbsTol',1e-10);
D.EpisodeReferenceStatus(2)="reference_too_old_review";
D.EpisodeReferenceNeedsReview(2)=true;D.NormOxySinkAmpPercent(2)=2; % never fallback
B=createHypoxicBurdenMetrics(D,table(),table(),R);
verifyTrue(t,isnan(B.RecordingTable.HypoxicBurden)&&isnan(B.EventTable.BurdenAmplitudePercent(2)));
verifyEqual(t,B.RecordingTable.NumOldEpisodeReferenceEvents,1);
W=createOxygenAnalysisWindows(R,table(),D,[]);verifyTrue(t,isnan(W.AmplitudeAreaTimePercent_um2_sec));
B=createHypoxicBurdenMetrics(D([],:),table(),table(),R);verifyEqual(t,B.RecordingTable.HypoxicBurden,0);
end
function testSavedEvidenceUnavailable(t)
[E,~,~]=fixture;old=E;D=attachSavedBOIEpisodeReferences(E,'','',tempname,1);
verifyEqual(t,D(:,old.Properties.VariableNames),old);
verifyEqual(t,D.EpisodeReferenceStatus,repmat("saved_evidence_unavailable",3,1));
verifyTrue(t,all(isnan(getBOISinkBurdenAmplitude(D))));
end
function testLegacyColumnConversion(t)
E=table({.2;-.1;NaN},'VariableNames',{'NormOxySinkAmp'});
verifyEqual(t,getBOISinkBurdenAmplitude(E),[20;NaN;NaN]);
E=table(["-20";"10";"NaN"],repmat("negative_drop_percent",3,1), ...
    'VariableNames',{'NormOxySinkAmpPercent','AmplitudeSignConvention'});
verifyEqual(t,getBOISinkBurdenAmplitude(E),[20;NaN;NaN]);
end
function testIdentityAndVersion(t)
[E,V,P]=fixture;E.NativeStartFrame=[30;36;100];E.NativeEndFrame=E.EndFrame;
verifyError(t,@()deriveBOIPreEpisodeReferences(E,V,P,1,20),'OxygenDynamics:EpisodeEvidence');
E=initializeBOIEpisodeReferences(E);E.EpisodeReferenceVersion(:)="unknown";
verifyError(t,@()getBOISinkBurdenAmplitude(E),'OxygenDynamics:EpisodeVersion');
end
function testSavedReceiptAndFullInventoryBeforeSubset(t)
[E,V,~]=fixture;folder=tempname;mkdir(folder);cleanup=onCleanup(@()rmdir(folder,'s'));
[sf,uf,af,rf]=savedFixture(folder,E,V);
D=attachSavedBOIEpisodeReferences(E(2,:),sf,uf,folder,1);
verifyEqual(t,D.EpisodeReferenceStartFrame,11);verifyEqual(t,D.EpisodeAmplitudePercent,20,'AbsTol',1e-12);
verifyEqual(t,D.EpisodeHeadEventID,1);verifyEqual(t,D.EpisodeReferenceAuditSHA256,string(oxygenFileSHA256(af)));
% A replaced audit is rejected even if filenames and row counts are unchanged.
A=load(af);A.Traces{2}.Raw(11)=999;save(af,'-struct','A');
verifyError(t,@()attachSavedBOIEpisodeReferences(E,sf,uf,folder,1),'OxygenDynamics:EpisodeSourceMismatch');
receipt=jsondecode(fileread(rf));receipt.AuditSHA256=oxygenFileSHA256(af);
receipt.SourceSHA256='different';fid=fopen(rf,'w');fprintf(fid,'%s',jsonencode(receipt));fclose(fid);
verifyError(t,@()attachSavedBOIEpisodeReferences(E,sf,uf,folder,1),'OxygenDynamics:EpisodeSourceMismatch');
end
function testExistingStatsLoaderUsesDerivedReference(t)
[E,V,~]=fixture;E.EventArea_um2=[4;8;4];E.RecAreaSize(:)=16;
folder=tempname;mkdir(folder);cleanup=onCleanup(@()rmdir(folder,'s'));
[sf,uf,af,rf]=savedFixture(folder,E,V);
completeStatsFixture(folder,sf,uf,af,rf);
input=struct('Path',folder,'Mouse','example','Condition','example','DrugID','example', ...
    'Genotype','example','Promoter','example','Puff',NaN,'PixelSize',2,'Posture',NaN, ...
    'Pupil',NaN,'Whisking',NaN,'SampleF',1,'RecordingID','R', ...
    'SavedSources',struct('RecordingFolder',folder,'SinkMaster',sf,'SurgeMaster',uf));
selection=struct('Mode','No','Sinks','Recent','Surges','Recent','Behaviour','Recent');
[cells,info]=loadStatsRecordingIntoCells(initializeStatsRecordingCells(1),struct(), ...
    1,input,'',selection,'No','BLI',1);
D=cells.TableOxygenSinkEvents{1};verifyEqual(t,D.EpisodeReferenceStartFrame,[11;11;80]);
verifyEqual(t,D.EpisodeAmplitudePercent,[20;20;25],'AbsTol',1e-12);
verifyEqual(t,D.NormOxySinkAmpPercent,E.NormOxySinkAmpPercent);
verifyEqual(t,info.Recordings.SinksMatFile,sf);
B=createHypoxicBurdenMetrics(D,cells.HypoxicEventSpecificMetrics{1}, ...
    cells.TableOxygenSinks{1},cells.RecordingRegistry{1});
% The approved local policy takes priority; preserved pre-episode fields above
% still describe the older alternative, not the selected new burden input.
localMean=(16*200+4*150)/20;
verifyEqual(t,B.EventTable.BurdenAmplitudePercent,[20;100*(localMean-160)/localMean;25],'AbsTol',1e-12);
verifyEqual(t,D.EventReferenceStartFrame,[11;16;80]);
verifyEqual(t,D.EventReferenceOverlapFrames,[0;4;0]);
end
function testWorkbookPreservesAutomaticAndDerived(t)
[E,V,P]=fixture;D=deriveBOIPreEpisodeReferences(E,V,P,1,20);
B=createHypoxicBurdenMetrics(D,table(),table(),registry);
folder=tempname;mkdir(folder);cleanup=onCleanup(@()rmdir(folder,'s'));
file=fullfile(folder,'Stats.xlsx');writeHypoxicBurdenWorkbookSheets(file,B);
T=readtable(file,'Sheet','HypoxicBurden_EventBased','VariableNamingRule','preserve');
verifyEqual(t,T.NormOxySinkAmpPercent,E.NormOxySinkAmpPercent);
verifyEqual(t,T.EpisodeAmplitudePercent,D.EpisodeAmplitudePercent,'AbsTol',1e-12);
verifyEqual(t,T.EpisodeReferenceStartFrame,D.EpisodeReferenceStartFrame);
verifyEqual(t,string(T.EpisodeReferenceVersion),D.EpisodeReferenceVersion);
end
function [E,V,P]=fixture
E=table(repmat("R",3,1),ones(3,1),(1:3)',[31;36;100],[34;39;103], ...
    'VariableNames',{'RecordingID','SinkID','EventID','StartFrame','EndFrame'});
E.NormOxySinkAmp=[.2;NaN;.25];E.NormOxySinkAmpPercent=100*E.NormOxySinkAmp;
E.AmplitudeSignConvention=repmat("positive_drop_percent",3,1);
for f={'Mouse','Condition','DrugID','Genotype','Promoter'},E.(f{1})=repmat("example",3,1);end
E.PuffStim=false(3,1);E.DurationSec=4*ones(3,1);E.StartSec=E.StartFrame-1;E.EndSec=E.EndFrame;
E.EventArea_um2=[10;20;30];E.RecAreaSize=repmat(8e5,3,1);E.RecDuration=120*ones(3,1);E.SampleF=ones(3,1);
V={struct('Raw',[],'Footprint',1,'DetectedFrames',[]); ...
    struct('Raw',[],'Footprint',[1;2],'DetectedFrames',[]); ...
    struct('Raw',[],'Footprint',1,'DetectedFrames',[])};
[V,P]=retime(E,V);
V{1}.Raw(E.StartFrame(1):E.EndFrame(1))=80;
V{2}.Raw(:)=200;V{2}.Raw(31:34)=150;V{2}.Raw(36:39)=160;
V{3}.Raw(E.StartFrame(3):E.EndFrame(3))=75;
end
function [V,P]=retime(E,V,N)
if nargin<3,N=120;end
P=cell(1,N);
for i=1:height(E)
    d=E.StartFrame(i):E.EndFrame(i);V{i}.DetectedFrames=d;V{i}.Raw=100*ones(1,N);
    for f=d,P{f}=unique([P{f};V{i}.Footprint(:)]);end
end
end
function R=registry
R=table("R","example","example","example","example","example",false,120,1,120,8e5, ...
    'VariableNames',{'RecordingID','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim', ...
    'NFrames','SampleF','RecordingDuration_sec','RecordingArea_um2'});
R.Experiment="example";
end
function [sf,uf,af,rf]=savedFixture(folder,E,V)
mkdir(fullfile(folder,'BOIReview'));sf=fullfile(folder,'Sink.mat');uf=fullfile(folder,'Surge.mat');
pc=cell(1,120);for e=1:height(E),for f=V{e}.DetectedFrames,pc{f}=V{e}.Footprint;end;end
Table_OxygenSinks_Out=table({pc},'VariableNames',{'FramePixels'});
Table_OxygenSurges_Out=Table_OxygenSinks_Out([],:);Table_OxygenSinkEvents_Out=E;
AnalysisInfo=struct('RawSHA256','fixture','NFrames',120,'AnalysisParams',struct('fs',1,'quantBaselineWindowSec',20));
save(sf,'Table_OxygenSinks_Out','Table_OxygenSinkEvents_Out','AnalysisInfo');
save(uf,'Table_OxygenSurges_Out','AnalysisInfo');
Audit=table(repmat("sink",3,1),E.SinkID,E.EventID,E.StartFrame,E.EndFrame,E.StartFrame,E.EndFrame, ...
    repmat("fixture",3,1),E.NormOxySinkAmp,'VariableNames', ...
    {'EventType','SiteID','EventID','StartFrame','EndFrame','DetectedStartFrame','DetectedEndFrame','SourceRawSHA256','StoredAmplitude'});
Traces=V;af=fullfile(folder,'BOIReview','event-amplitude-audit.mat');save(af,'Audit','Traces','AnalysisInfo');
R=struct('Schema','boi-created-event-audit-1','AuditSHA256',oxygenFileSHA256(af), ...
    'MasterSHA256',{{oxygenFileSHA256(sf),oxygenFileSHA256(uf)}},'SourceSHA256','fixture','EventCount',3);
rf=fullfile(folder,'BOIReview','AuditCreationReceipt.json');fid=fopen(rf,'w');fprintf(fid,'%s',jsonencode(R));fclose(fid);
end
function completeStatsFixture(folder,sf,uf,af,rf)
% Tiny disposable source/masters exercise the real existing stats loader.
raw=fullfile(folder,'synthetic.tif');
for f=1:120
    if f==1,imwrite(uint16(100*ones(2)),raw);else,imwrite(uint16(100*ones(2)),raw,'WriteMode','append');end
end
S=load(sf);U=load(uf);A=load(af);
I=S.AnalysisInfo;I.RawFile=raw;I.RawSHA256=oxygenFileSHA256(raw);I.DenoisedFile='';I.DenoisedSHA256='';
I.AnalysisParams=createOxygenMasterParams(2,1);I.PipelineContract=oxygenPipelineContract();
I.AnalysisSchemaVersion=I.PipelineContract.Schema;I.FrameSize=[2 2];
I.RecordingAreaUm2=16;I.SinkEligibleTissuePixels=(1:4)';I.SurgeEligibleTissuePixels=(1:4)';
S.AnalysisInfo=I;U.AnalysisInfo=I;A.AnalysisInfo=I;A.Audit.SourceRawSHA256(:)=string(I.RawSHA256);
T=S.Table_OxygenSinks_Out;T.RecDuration={120};T.RecAreaSize={16};
for f={'MeanCentroid_x','MeanCentroid_y','MeanOxySinkArea_um','MeanOxySinkFilledArea_um', ...
        'MeanOxySinkDiameter_um','MeanOxySinkPerimeter_um','MeanCircularity'},T.(f{1})=1;end
T.MeanOxySinkBoundingBox={[.5 .5 2 2]};T.NumOxySinkEvents=3;
T.Start={[31 36 100]};T.Duration={[4 4 4]};T.NormOxySinkAmp={[.2 NaN .25]};
T.Size_modulation={[0 0 0]};T.OxySink_Pxls_all={[1;2]};T.FrameSize={[2 2]};S.Table_OxygenSinks_Out=T;
S.OxySinkArea_all=zeros(1,120);S.Mean_OxySink_Trace_Convo=zeros(1,120);
U.Table_OxygenSurges_Out=table('Size',[0 16],'VariableTypes', ...
    [repmat({'cell'},1,10),{'double'},repmat({'cell'},1,5)], ...
    'VariableNames',{'RecDuration_Surge','RecAreaSize_Surge','MeanCentroid_Surge_x','MeanCentroid_Surge_y', ...
    'MeanOxySurgeArea_um','MeanOxySurgeFilledArea_um','MeanOxySurgeDiameter_um','MeanOxySurgePerimeter_um', ...
    'MeanCircularity_Surge','MeanOxySurgeBoundingBox','NumOxySurgeEvents','Start_Surge','Duration_Surge', ...
    'NormOxySurgeAmp','Size_Surge_modulation','OxySurge_Pxls_all'});
U.Table_OxygenSurgeEvents_Out=table(zeros(0,1),zeros(0,1),zeros(0,1),zeros(0,1), ...
    'VariableNames',{'SurgeID','EventID','StartFrame','EndFrame'});
U.OxySurgeArea_all=zeros(0,120);U.Mean_ROI_TraceZ=zeros(0,120);
save(sf,'-struct','S');save(uf,'-struct','U');save(af,'-struct','A');
R=jsondecode(fileread(rf));R.AuditSHA256=oxygenFileSHA256(af);R.SourceSHA256=I.RawSHA256;
R.MasterSHA256={oxygenFileSHA256(sf),oxygenFileSHA256(uf)};
fid=fopen(rf,'w');fprintf(fid,'%s',jsonencode(R));fclose(fid);
end
