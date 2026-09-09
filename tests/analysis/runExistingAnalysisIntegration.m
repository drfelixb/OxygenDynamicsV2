function result=runExistingAnalysisIntegration()
% Full master smoke, followed by an explicitly injected known-measurement fixture.
% The injected events test quantification/export, not detector sensitivity.
setupOxygenDynamicsPath;
rng(17);root=tempname;mkdir(root);rec=fullfile(root,'Recording1');mkdir(rec);
X=1000+10*randn(96,96,100);
X(35:55,35:55,40:48)=X(35:55,35:55,40:48)-250;
X(60:80,60:80,65:76)=X(60:80,60:80,65:76)+250;
saveastiff(uint16(X),fullfile(rec,'test_original.tif'),struct('overwrite',true));
C=struct('SFs',2,'PiSz',2.5,'Mous','M1','Cond','Awake','Drug','None','Gen','WT','Promo','GFAP','Puff',NaN,'strOW','Y');
master=runOxygenDynamicsMaster(rec,C);
assert(master.AnalysisInfo.RecordingDurationSec==50);
assert(isfield(master.AnalysisInfo,'SinkEligibleTissuePixels') && isfield(master.AnalysisInfo,'SurgeEligibleTissuePixels'));
rec2=fullfile(root,'Recording2');copyfile(rec,rec2);
files=dir(fullfile(rec,'OxygenSinks_Output','*Urefined*.mat'));assert(numel(files)==1);
file=fullfile(files(1).folder,files(1).name);D=load(file);A=D.AnalysisInfo.RecordingAreaUm2;
assert(A>0);
S=createOxygenSinkSummaryTable({'R1'},{'M1'},{'Awake'},{'None'},{'WT'},{'GFAP'}, ...
    {50},{A},{10},{10},{6.25},{6.25},{2.5},{10},{1},{[10,10,1,1]},2,{[45,75]},{[4,4]},{[.25,.4]},{[0,0]},{[1;2]});
for f={'MeanOxySinkArea_um','MeanOxySinkFilledArea_um','MeanOxySinkDiameter_um','MeanOxySinkPerimeter_um'}
    S.(f{1})=cell2mat(S.(f{1}));
end
E=createOxygenSinkEventTable({'R1';'R1'},{'M1';'M1'},{'Awake';'Awake'},{'None';'None'}, ...
    {'WT';'WT'},{'GFAP';'GFAP'},[false;false],[1;1],[1;2],[45;75],[48;78],[22;37],[24;39], ...
    [4;4],[2;2],[.25;.4],[25;40],[0;0],[2;2],[6.25;6.25],[6.25;6.25],[2.5;2.5],[10;10],[1;1],[10;10],[10;10]);
P=cell(1,100);P(45:48)={1};P(75:78)={2};raw=100*ones(96,96,100);
raw(1,1,45:48)=75;raw(2,1,75:78)=60;
[S,E]=finalizeOxygenEventMeasurements(S,E,P,raw,2,2.5,0,"R1",'sink',20);
E.NativeStartFrame=[45;75];E.NativeEndFrame=[48;78];
E=annotateOxygenEventRecurrence(E,2,20);
D.Table_OxygenSinks_Out=S;D.Table_OxygenSinkEvents_Out=E;
D.OxySinkArea_all=cellfun(@numel,P,'UniformOutput',false);
D.Mean_OxySink_Trace_Convo=zeros(1,100);D.Mean_OxySink_TraceZ=zeros(1,100);D.Mean_OxySink_Trace_Raw=ones(1,100)*100;
save(file,'-struct','D');
D.Table_OxygenSinks_Out=S([],:);D.Table_OxygenSinkEvents_Out=E([],:);
D.OxySinkArea_all=cell(0,100);D.Mean_OxySink_Trace_Convo=zeros(0,100);D.Mean_OxySink_TraceZ=zeros(0,100);D.Mean_OxySink_Trace_Raw=zeros(0,100);
save(fullfile(rec2,'OxygenSinks_Output',files(1).name),'-struct','D');
Paths={rec;rec2};PostureFile=[NaN;NaN];PupilFile=PostureFile;PuffsFile=PostureFile;WhiskingFile=PostureFile;
Mouse={'M1';'M1'};Genotype={'WT';'WT'};Condition={'Awake';'Awake'};DrugID={'None';'None'};Promoter={'GFAP';'GFAP'};
SampleF=[2;2];Pixelsize=[2.5;2.5];Puff_2use=PostureFile;RecordingID=["R1";"R2"];
T=table(Paths,PostureFile,PupilFile,PuffsFile,WhiskingFile,Mouse,Genotype,Condition,DrugID,Promoter,SampleF,Pixelsize,Puff_2use,RecordingID);
csv=fullfile(root,'input.csv');writetable(T,csv);
pairs=table("R1","R2",'VariableNames',{'BaselineRecordingID','ComparisonRecordingID'});
pairCsv=fullfile(root,'pairs.csv');writetable(pairs,pairCsv);
result=runOxygenDynamicsStats(struct('inputCsv',csv,'masterFolder',root,'outputRoot',fullfile(root,'stats'), ...
    'interactive',false,'baselinePairsCsv',pairCsv));
D=load(result.DataOutputMat);
assert(isequal(D.HypoxicBurden.RecordingTable.NumEvents,[2;0]));
assert(max(abs(D.HypoxicBurden.EventTable.BurdenAmplitudePercent-[25;40]))<1e-10);
assert(all(D.RecordingRegistry.RecordingDuration_sec==50));
assert(sum(D.HypoxicBurden.TimeSeriesTable.RecordingID=="R2")==100);
assert(D.BaselineContrasts.RelativeChangePercent(1)==-100);
Q=D.EventMeasurementQC;
q=Q.EventType=="sink";
assert(isequal(Q.DetectedEvents(q),[2;0]));
assert(isequal(Q.CloseNativeRunEvents(q),[2;0]));
assert(all(D.Table_OxygenSinkEvents_OutCombo.CloseNativeRun));
assert(isequal(Q.FiniteAmplitudeEvents(q),[2;0]));
assert(Q.FiniteAmplitudeFraction(find(q,1))==1);
assert(ismember('EventMeasurementQC',sheetnames(result.OutputXlsx)));
definitions=readtable(result.OutputXlsx,'Sheet','MetricDefinitions','TextType','string');
assert(all(ismember(["CloseNativeRun" "RecurrenceStatus" "CloseNativeRunEvents" ...
    "NormOxySurgeAmp" "NormOxySurgeAmpPercent" "TimingMethod"],definitions.MetricName)));
assert(contains(definitions.OutputLocation(definitions.MetricName=="CloseNativeRun"),"OxySurgeEvents"));
assert(ismember('SurgeSiteEventRate_per_min',sheetnames(result.OutputXlsx)));
assert(isfile(result.OutputXlsx));
fprintf('Known-event and zero-event integration passed: %s\n',root);
end
