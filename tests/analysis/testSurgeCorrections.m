function tests=testSurgeCorrections
tests=functiontests(localfunctions);
end
function setupOnce(~)
setupOxygenDynamicsPath;
end
function testLastValidSeedForBothTrackers(t)
for minimum=[3 3.03 10]
 N=30;first=N-ceil(minimum)+1;F=cell(N,1);
 for f=first:N,F{f}=struct('PixelIdxList',[1;2;3]);end
 A=trackSinkCandidates(F,minimum,.6);[~,L]=filterSinkRunsByDuration(A,minimum,150);
 verifyEqual(t,find(L),first:N);
 A=trackSurgeCandidates(F,minimum,0);[~,L]=refineTrackedSurgeCandidates(A,minimum);
 verifyEqual(t,find(L),first:N);
end
end
function testWholeRecordingExactlyMinimumDuration(t)
F=repmat({struct('PixelIdxList',[1;2;3])},10,1);
A=trackSurgeCandidates(F,10,0);[~,L]=refineTrackedSurgeCandidates(A,10);
verifyEqual(t,nnz(L),10);
end
function testSurgeFootprintFractionSignAndNoLegacyExport(t)
[S,E,P,X]=fixture;
[~,A]=finalizeOxygenEventMeasurements(S,E,P,X,1,1,0,"R",'surge',20);
verifyEqual(t,A.NormOxySurgeAmp,[.2;-.2],'AbsTol',1e-12);
verifyEqual(t,A.NormOxySurgeAmpPercent,[20;-20],'AbsTol',1e-12);
verifyFalse(t,ismember('SiteTraceAmplitude',A.Properties.VariableNames));
end
function testSurgeContaminationAndNoPostEventFallback(t)
[S,E,P,X]=fixture;
other=cell(1,120);other(25:29)={1};
[~,A]=finalizeOxygenEventMeasurements(S,E,P,X,1,1,0,"R",'surge',20,other,0);
verifyTrue(t,isnan(A.NormOxySurgeAmp(1)));verifyEqual(t,A.BaselineValidSamples(1),15);
E=E(1,:);E.StartFrame=5;E.EndFrame=14;P=cell(1,120);P(5:14)={1};
[~,A]=finalizeOxygenEventMeasurements(S,E,P,X,1,1,0,"R",'surge',20);
verifyTrue(t,isnan(A.NormOxySurgeAmp));verifyEqual(t,A.BaselineStatus,"insufficient_clean_prebaseline");
end
function testSurgeCloseFlagsAndRecordingBoundaries(t)
P=cell(1,40);P(1:10)={1};P(21:40)={1};
meta=struct('Experiment',{{'R'}},'Mouse',{{'M'}},'Condition',{{'C'}},'DrugID',{{'D'}}, ...
 'Genotype',{{'G'}},'Promoter',{{'P'}},'PuffStim',false);
shape=struct('MeanArea_um',1,'MeanFilledArea_um',1,'MeanDiameter_um',1,'MeanPerimeter_um',1, ...
 'MeanCircularity',1,'MeanCentroid_x',1,'MeanCentroid_y',1);
[~,~,~,amp,~,E]=collateOxygenSurgeEvents(P,~cellfun(@isempty,P),meta,shape,1,createOxygenMasterParams(1,1));
verifyTrue(t,all(isnan(amp{1})));verifyTrue(t,all(E.CloseNativeRun));
verifyEqual(t,E.TouchesRecordingStart,[true;false]);verifyEqual(t,E.TouchesRecordingEnd,[false;true]);
verifyEqual(t,E.PreviousNativeGapSec(2),10);verifyFalse(t,ismember('TimingResolved',E.Properties.VariableNames));
verifyEqual(t,E.TimingMethod,repmat("native_mask_bounds_not_refined",2,1));
end
function [S,E,P,X]=fixture
S=table({[nan nan]},{100},'VariableNames',{'NormOxySurgeAmp','RecAreaSize_Surge'});
E=table([1;1],[1;2],[31;81],[40;90],[NaN;NaN], ...
 'VariableNames',{'SurgeID','EventID','StartFrame','EndFrame','NormOxySurgeAmp'});
for f={'MeanOxySurgeArea_um','MeanOxySurgeFilledArea_um','MeanOxySurgeDiameter_um','MeanOxySurgePerimeter_um'},E.(f{1})=[1;1];end
P=cell(1,120);P(31:40)={1};P(81:90)={2};
X=100*ones(2,2,120);X(1,1,31:40)=120;X(2,1,81:90)=80;
end
