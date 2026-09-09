function tests=testReviewCorrections
tests=functiontests(localfunctions);
end
function setupOnce(t)
addpath(fileparts(fileparts(fileparts(mfilename('fullpath')))));
setupOxygenDynamicsPath;
t.TestData.Folder=tempname;mkdir(t.TestData.Folder);
end
function testCalibrationGuard(t)
I=struct('AnalysisSchemaVersion','2.1','AnalysisParams',struct('fs',2,'PixelSize',2.5));
M=struct('SampleF',2,'PixelSize',2.5);
validateOxygenAnalysisCalibration(I,M);
file=fullfile(t.TestData.Folder,'calibration.mat');AnalysisInfo=I;save(file,'AnalysisInfo');
M.SampleF=1;verifyError(t,@()validateOxygenAnalysisCalibration(I,M),'OxygenDynamics:CalibrationMismatch');
verifyError(t,@()upgradeStatsAnalysisTables(table(),table(),M,file,'sink'),'OxygenDynamics:ReanalysisRequired');
M.SampleF=2;M.PixelSize=5;verifyError(t,@()validateOxygenAnalysisCalibration(I,M),'OxygenDynamics:CalibrationMismatch');
verifyError(t,@()upgradeStatsAnalysisTables(table(),table(),M,file,'sink'),'OxygenDynamics:ReanalysisRequired');
I=rmfield(I,'AnalysisParams');verifyError(t,@()validateOxygenAnalysisCalibration(I,M),'OxygenDynamics:MissingSavedCalibration');
end
function testTissueIntersection(t)
S=table({1},{1},{9},'VariableNames',{'Start','Duration','RecAreaSize'});
S.FramePixels={{(1:10)'}};S.EligibleTissuePixels={(1:9)'};
A=computeOngoingSinkTimeSeries(S,1,1);
verifyEqual(t,A.AreaUm,9);verifyEqual(t,A.AreaNorm,1);
G=renamevars(S,{'Start','Duration','RecAreaSize'},{'Start_Surge','Duration_Surge','RecAreaSize_Surge'});
A=computeOngoingSurgeTimeSeries(G,1,1);verifyEqual(t,A.AreaNorm,1);
S=removevars(S,'EligibleTissuePixels');A=computeOngoingSinkTimeSeries(S,1,1);
verifyTrue(t,isnan(A.AreaNorm));verifyEqual(t,A.Count,1);
end
function testFractionalPuffGrid(t)
fs=1.01;time=(-round(30*fs):round(60*fs))/fs;
P=cell(7,1);M=P;P{7}=ones(1,numel(time));P{7}(time>=0)=2;M{7}="M1";
O=formatPooledTracesForExport(P,M,time);
verifyEqual(t,O{7}.BaselineValue,1);verifyEqual(t,O{7}{1,4:end},double(time>=0));
verifyTrue(t,ismember('t_0_sec',O{7}.Properties.VariableNames));
verifyError(t,@()formatPooledTracesForExport(P,M),'OxygenDynamics:TraceTimeMismatch');
end
function testMissingTraceVsPadding(t)
[X,~,coverage]=alignOxygenTraceSamples({[10,10];[NaN];[40,40]},[1;1;1]);
[Y,~]=averageOxygenTracesByMouse(X,["C";"C";"C"],["M1";"M1";"M2"],coverage);
verifyEqual(t,Y,[NaN,10;40,40]);
end
function testFiguresMatchGroupedMissingness(t)
R=table(["R1";"R2";"R3"],["M1";"M1";"M2"],repmat("C",3,1),ones(3,1),ones(3,1),[10;NaN;40], ...
    'VariableNames',{'RecordingID','Mouse','Condition','NumEvents','NumSinkSites','HypoxicBurden'});
G=summarizeOxygenMouseMetrics(R);
S=R(:,{'RecordingID','Mouse','Condition'});S.MeanOxySinkEvent_NormAmp=R.HypoxicBurden;
F=figures(t,S,struct());
verifyEqual(t,F.MetricSummary.Mean,G.HypoxicBurden_Mean);
verifyEqual(t,F.MetricSummary.N,G.HypoxicBurden_NValidMice);
verifyEqual(t,F.MetricSummary.Mean,40);
end
function testUnavailableAndZeroEventFigures(t)
S=table("R1","M1","C",NaN,2,'VariableNames', ...
    {'RecordingID','Mouse','Condition','MeanOxySinkEvent_NormAmp','NumOxySinkEvents_Norm'});
F=figures(t,S,struct());
verifyEqual(t,numel(F.FigureFiles),1);
missing=F.MetricSummary.Metric=="MeanOxySinkEvent_NormAmp";
verifyEqual(t,F.MetricSummary.N(missing),0);
verifyTrue(t,strlength(F.MetricSummary.UnavailableReason(missing))>0);
R=table("R1","M1","C",0,'VariableNames',{'RecordingID','Mouse','Condition','HypoxicBurden'});
F=figures(t,S([],:),struct('HypoxicBurden',struct('RecordingTable',R)));
verifyEqual(t,numel(F.FigureFiles),1);
verifyTrue(t,any(F.MetricSummary.Metric=="HypoxicBurden" & F.MetricSummary.Mean==0));
end
function F=figures(t,S,extra)
folder=tempname(t.TestData.Folder);mkdir(folder);file=fullfile(folder,'DataOutput.mat');
D=extra;D.Table_OxygenSinks_OutCombo=S;D.StatsInfo=struct();save(file,'-struct','D');
F=runOxygenSummaryFigures(file);
end
