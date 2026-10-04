function tests=testBOIPortableSummaries
% Portable frozen independent arithmetic; synthetic saved ingredients only.
tests=functiontests(localfunctions);
end
function setupOnce(~),setupOxygenDynamicsPath;end
function testSignedCancellation(~)
C=jsondecode(fileread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'fixtures','boi-step3-arithmetic.json')));
target=tempname;mkdir(target);cleanup=onCleanup(@()rmdir(target,'s'));
checkFixture(caseValue(C.Cases,1),target);
end
function testNegativeIntegralAndUnits(~)
C=jsondecode(fileread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'fixtures','boi-step3-arithmetic.json')));
target=tempname;mkdir(target);cleanup=onCleanup(@()rmdir(target,'s'));
checkFixture(caseValue(C.Cases,2),target);
end
function testUnequalMouseCounts(~)
C=jsondecode(fileread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'fixtures','boi-step3-arithmetic.json')));
target=tempname;mkdir(target);cleanup=onCleanup(@()rmdir(target,'s'));
checkFixture(caseValue(C.Cases,3),target);
end
function testMissingContributions(~)
C=jsondecode(fileread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'fixtures','boi-step3-arithmetic.json')));
target=tempname;mkdir(target);cleanup=onCleanup(@()rmdir(target,'s'));
checkFixture(caseValue(C.Cases,4),target);
end
function testZeroEvents(~)
C=jsondecode(fileread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'fixtures','boi-step3-arithmetic.json')));
target=tempname;mkdir(target);cleanup=onCleanup(@()rmdir(target,'s'));
checkFixture(caseValue(C.Cases,5),target);
end
function testLegacySignProvenance(~)
C=jsondecode(fileread(fullfile(fileparts(fileparts(mfilename('fullpath'))),'fixtures','boi-step3-arithmetic.json')));
target=tempname;mkdir(target);cleanup=onCleanup(@()rmdir(target,'s'));
checkFixture(caseValue(C.Cases,6),target);
end
function checkFixture(C,target)
[R,E]=fixtureTables(C);originalR=R;originalE=E;
B=createHypoxicBurdenMetrics(E,table(),table(),R);assert(isequaln(R,originalR)&&isequaln(E,originalE));
checkBurden(B,C.Expected);
Core=fixtureCore(E,R);counts=createAutomaticAmplitudeExportData(Core,B);checkCounts(counts,C.Expected);
writeAutomaticAmplitudeExport(target,fullfile(target,'Summary.xlsx'),counts);
writeHypoxicBurdenWorkbookSheets(fullfile(target,'Summary.xlsx'),B);checkWorkbook(target,B,C.Expected);
StatsInfo=struct('PipelineContract',oxygenPipelineContract());
if strcmp(C.ExpectedOriginalSoftware,'1.01'),StatsInfo.CalculationSoftware=struct('Version','1.01','BuildTimestamp','historical fixture build');end
Saved=struct('StatsInfo',StatsInfo,'RecordingRegistry',R,'HypoxicBurden',B,'Table_OxygenSinkEvents_OutCombo',E);
P=createOxygenExportProvenance(Saved,{'createOxygenExportProvenance'});checkProvenance(P,C.ExpectedOriginalSoftware);
writeJSON(fullfile(target,'ExportProvenance.json'),P);
path=fullfile(target,'DataOutput.mat');save(path,'-struct','Saved');
oldHash=oxygenFileSHA256(path);out=fullfile(target,'AnalysisManifest.md');writeOxygenAnalysisManifest(path,'outputPath',out);
checkManifest(out,C.ExpectedOriginalSoftware);assert(strcmp(oldHash,oxygenFileSHA256(path)));
if isfield(C,'Trace')&&~isempty(C.Trace)
    T=C.Trace;raw=T.Raw(:);Rframes=T.ReferenceFrames(:);W=(T.MeasurementStartFrame:T.MeasurementEndFrame)';fs=T.SampleHz;
    rows=table();
    for kind=["sink","surge"]
        M=computeBOIReviewedOpticalInterval(raw,Rframes,W(1),W(end),fs,char(kind));
        checkEqual(M.SignedTraceIntegralSec,T.ExpectedFractionSec,'signed integral fraction-seconds');
        checkEqual(100*M.SignedTraceIntegralSec,T.ExpectedPercentSec,'percent-seconds conversion');
        % Same four native samples in tiny fixed-footprint automatic quantifier.
        [Sites,Events,Pixels,Raw]=traceInputs(raw,W,fs,kind);
        [~,A]=finalizeOxygenEventMeasurements(Sites,Events,Pixels,Raw,fs,2,0,'tiny',char(kind),numel(Rframes)/fs);
        checkEqual(A.SignedTraceAUC_sec,T.ExpectedFractionSec,'automatic signed integral');
        rows=[rows;table(kind,M.SignedTraceIntegralSec,100*M.SignedTraceIntegralSec,'VariableNames',{'Sign','FractionSeconds','PercentSeconds'})]; %#ok<AGROW>
    end
    writetable(rows,fullfile(target,'SignedIntegrals.csv'));Tcsv=readtable(fullfile(target,'SignedIntegrals.csv'));
    checkEqual(Tcsv.FractionSeconds,repmat(T.ExpectedFractionSec,2,1),'integral CSV round trip');
end
end
function [R,E]=fixtureTables(C)
reg=C.Registry;nr=numel(reg);R=table(string({reg.RecordingID})',string({reg.Mouse})', ...
    'VariableNames',{'RecordingID','Mouse'});
for name={'Experiment','Condition','DrugID','Genotype','Promoter'},R.(name{1})=repmat("fixture",nr,1);end
R.PuffStim=false(nr,1);R.NFrames=[reg.NFrames]';R.SampleF=[reg.SampleHz]';
R.RecordingArea_um2=[reg.RecordingAreaUm2]';R.RecordingDuration_sec=[reg.RecordingDurationSec]';
R.AnalysisStatus=repmat("loaded",nr,1);
E=table('Size',[0 15],'VariableTypes',[{'string','string'},repmat({'double'},1,11),{'string','double'}], ...
 'VariableNames',{'RecordingID','Mouse','SinkID','EventID','NormOxySinkAmp','NormOxySinkAmpPercent','EventArea_um2','DurationSec', ...
 'StartFrame','EndFrame','RecAreaSize','RecDuration','SampleF','AmplitudeSignConvention','NFrames'});
for j=1:numel(C.Events)
    e=C.Events(j);sg="positive_drop_percent";if isfield(e,'SignConvention')&&~isempty(e.SignConvention),sg=string(e.SignConvention);end
    r=find(R.RecordingID==string(e.RecordingID));amp=num(e.AmplitudePercent);
    E(end+1,:)={string(e.RecordingID),string(e.Mouse),e.SiteID,e.EventID,amp/100,amp,num(e.AreaUm2),num(e.DurationSec), ...
        e.StartFrame,e.EndFrame,e.RecordingAreaUm2,e.RecordingDurationSec,e.SampleHz,sg,R.NFrames(r)};
end
for name={'Experiment','Condition','DrugID','Genotype','Promoter'},E.(name{1})=repmat("fixture",height(E),1);end
E.PuffStim=false(height(E),1);
end
function Core=fixtureCore(E,R)
S=table('Size',[0 4],'VariableTypes',{'string','string','double','cell'},'VariableNames',{'RecordingID','Mouse','SiteID','NormOxySinkAmp'});
for i=1:height(R)
    local=E(E.RecordingID==R.RecordingID(i),:);
    for s=reshape(unique(local.SinkID),1,[])
        q=local.SinkID==s;S(end+1,:)={R.RecordingID(i),R.Mouse(i),s,{local.NormOxySinkAmp(q)'}};
    end
end
U=table('Size',[0 4],'VariableTypes',{'string','string','double','cell'},'VariableNames',{'RecordingID','Mouse','SiteID','NormOxySurgeAmp'});
V=table('Size',[0 2],'VariableTypes',{'string','double'},'VariableNames',{'RecordingID','NormOxySurgeAmp'});
Core=struct('TableOxygenSinks',S,'TableOxygenSinkEvents',E,'TableOxygenSurges',U,'TableOxygenSurgeEvents',V,'RecordingRegistry',R);
end
function checkBurden(B,X)
fields={'PerEventBurdenContribution','Contribution';'PerEventBurdenContribution_per_mm2','PerMm2'; ...
    'PerEventBurdenContribution_per_sec','PerSec';'PerEventBurdenContribution_per_min','PerMin'; ...
    'PerEventBurdenContribution_per_mm2_per_sec','PerMm2Sec';'PerEventBurdenContribution_per_mm2_per_min','PerMm2Min'; ...
    'BurdenAmplitudePercent','Amplitude';'BurdenArea_um2','Area';'BurdenDuration_sec','Duration'};
for k=1:size(fields,1)
    expected=values(X.Events,fields{k,2});
    if ~isempty(X.Events),checkEqual(B.EventTable.(fields{k,1}),expected,['event ' fields{k,1}]);else,assert(isempty(B.EventTable));end
end
map=recordingMap();
for i=1:numel(X.Recordings)
    r=X.Recordings(i);T=B.RecordingTable(string(B.RecordingTable.RecordingID)==string(r.RecordingID),:);assert(height(T)==1);
    for k=1:size(map,1),checkEqual(T.(map{k,1}),num(r.(map{k,2})),['recording ' map{k,1}]);end
end
G=B.GroupSummaryTable;assert(height(G)==1);
for pair={'HypoxicBurden','Total';'HypoxicBurden_per_mm2','PerMm2';'HypoxicBurden_per_sec','PerSec';'HypoxicBurden_per_min','PerMin'; ...
        'HypoxicBurden_per_mm2_per_sec','PerMm2Sec';'HypoxicBurden_per_mm2_per_min','PerMm2Min'; ...
        'MeanBurdenAmplitudePercent','MeanAmplitude';'MeanBurdenArea_um2','MeanArea';'MeanBurdenDuration_sec','MeanDuration'}'
    field=pair{1};x=X.Group.(pair{2});checkEqual(G.([field '_Mean']),num(x.Mean),['group ' field]);
    checkEqual(G.([field '_SEM']),num(x.SEM),['group SEM ' field]);checkEqual(G.([field '_NValidMice']),x.ValidMice,['group contributors ' field]);
end
% The time series integrates to the same strict recording composite. No omitnan total.
T=B.TimeSeriesTable;
for i=1:numel(X.Recordings)
    r=X.Recordings(i);q=string(T.RecordingID)==string(r.RecordingID);
    checkEqual(sum(T.HypoxicBurdenOverTime(q))/r.SampleHz,num(r.Total),'composite time-series integral');
    checkEqual(sum(T.HypoxicBurdenPerMm2OverTime(q))/r.SampleHz,num(r.PerMm2),'area-normalized time-series integral');
end
end
function map=recordingMap()
map={'NumEvents','NumEvents';'NumSinkSites','NumSites';'NumValidCompositeEvents','ValidContributions'; ...
'HypoxicBurden','Total';'Burden_AmplitudeComposite','Total';'HypoxicBurden_per_mm2','PerMm2'; ...
'HypoxicBurden_per_sec','PerSec';'HypoxicBurden_per_min','PerMin';'HypoxicBurden_per_mm2_per_sec','PerMm2Sec'; ...
'HypoxicBurden_per_mm2_per_min','PerMm2Min';'MeanEventBurdenContribution','MeanContribution'; ...
'MedianEventBurdenContribution','MedianContribution';'MeanEventBurdenContribution_per_mm2','MeanPerMm2Contribution'; ...
'MeanBurdenAmplitudePercent','MeanAmplitude';'MeanBurdenArea_um2','MeanArea';'MeanBurdenDuration_sec','MeanDuration'};
end
function checkCounts(D,X)
A=D.AverageCounts;
for i=1:numel(X.Recordings)
    r=X.Recordings(i);
    for pair={'MeanEventBurdenContribution','Contribution';'MeanBurdenAmplitudePercent','Amplitude';'MeanBurdenArea_um2','Area';'MeanBurdenDuration_sec','Duration'}'
        q=A.SummaryLevel=="recording"&A.RecordingID==string(r.RecordingID)&A.Metric==string(pair{1});assert(sum(q)==1);
        checkEqual(A.ContributingCount(q),r.Contributors.(pair{2}),'recording contributor count');checkEqual(A.TotalCount(q),r.NumEvents,'recording total event count');
    end
end
for pair={'HypoxicBurden','Total';'MeanBurdenAmplitudePercent','MeanAmplitude';'MeanBurdenArea_um2','MeanArea';'MeanBurdenDuration_sec','MeanDuration'}'
    x=X.Group.(pair{2});
    for i=1:numel(x.WithinMouse)
        m=x.WithinMouse(i);q=A.SummaryLevel=="within_mouse"&A.Mouse==string(m.Mouse)&A.Metric==string(pair{1});assert(sum(q)==1);
        checkEqual(A.Value(q),num(m.Value),'strict within-mouse value');checkEqual(A.ContributingCount(q),m.ContributingRecordings,'within-mouse contributing recordings');checkEqual(A.TotalCount(q),m.TotalRecordings,'within-mouse total recordings');
    end
    q=A.SummaryLevel=="equal_mouse_group"&A.Metric==string(pair{1})+"_Mean";assert(sum(q)==1);
    checkEqual(A.Value(q),num(x.Mean),'equal-mouse value');checkEqual(A.ContributingCount(q),x.ValidMice,'contributing mice');checkEqual(A.TotalCount(q),x.TotalMice,'total mice');
end
end
function checkWorkbook(target,B,X)
R=readtable(fullfile(target,'Summary.xlsx'),'Sheet','HypoxicBurden_ByRecording','VariableNamingRule','preserve');
map=recordingMap();for k=1:size(map,1),checkEqual(R.(map{k,1}),B.RecordingTable.(map{k,1}),['recording workbook ' map{k,1}]);end
G=readtable(fullfile(target,'Summary.xlsx'),'Sheet','HypoxicBurden_GroupSummary','VariableNamingRule','preserve');
for name=G.Properties.VariableNames
    if endsWith(name{1},'_Mean')||endsWith(name{1},'_SEM')||endsWith(name{1},'_NValidMice'),checkEqual(G.(name{1}),B.GroupSummaryTable.(name{1}),['group workbook ' name{1}]);end
end
save(fullfile(target,'Summary.mat'),'B');L=load(fullfile(target,'Summary.mat'));assert(isequaln(L.B,B));
opts=delimitedTextImportOptions('NumVariables',13,'DataLines',[2 Inf],'Delimiter',',');
opts.VariableNames={'SummaryLevel','EventType','RecordingID','Mouse','SiteID','GroupKey','Metric','Value','ContributingCount','TotalCount','CountUnit','Units','ContributingRule'};
opts.VariableTypes=[repmat({'string'},1,7),{'double','double','double'},repmat({'string'},1,3)];
C=readtable(fullfile(target,'AutomaticAverageCounts.csv'),opts);
A=readtable(fullfile(target,'Summary.xlsx'),'Sheet','AutomaticAverageCounts','VariableNamingRule','preserve');
checkEqual(C.ContributingCount,A.ContributingCount,'count CSV workbook round trip');checkEqual(C.Value,A.Value,'summary CSV workbook round trip');
assert(~isempty(X.Recordings));
end
function [S,E,P,Raw]=traceInputs(raw,W,fs,kind)
N=numel(raw);Raw=repmat(reshape(raw,1,1,N),3,4,1);P=cell(1,N);P(W)={1};
area='RecAreaSize';amp='NormOxySinkAmp';id='SinkID';prefix='MeanOxySink';if kind=="surge",area='RecAreaSize_Surge';amp='NormOxySurgeAmp';id='SurgeID';prefix='MeanOxySurge';end
S=table({48},{NaN},'VariableNames',{area,amp});
E=table(1,1,W(1),W(end),NaN,NaN,'VariableNames',{id,'EventID','StartFrame','EndFrame',amp,[amp 'Percent']});
for field={'Area_um','FilledArea_um','Diameter_um','Perimeter_um'},E.([prefix field{1}])=0;end
end
function checkProvenance(P,expected)
assert(strcmp(P.OriginalCalculation.SoftwareVersion,expected));I=getOxygenPipelineVersion();assert(isequal(P.CurrentReaderExporter.Version,I.Version));
assert(strcmp(P.CurrentReaderExporter.Role,'current_reader_exporter_not_historical_calculator'));
assert(strcmp(P.OriginalCalculation.ValueRole,'saved_values_not_recomputed_by_reader_exporter'));
end
function checkManifest(path,expected)
s=fileread(path);I=getOxygenPipelineVersion();assert(contains(s,['Original calculation software version: `' expected '`']));
assert(contains(s,['Current reader/exporter software version: `v' I.Version '`']));
assert(contains(s,'Saved calculation values are not recomputed or relabelled'));assert(~contains(s,'Pipeline version:'));
end
function v=values(rows,field)
v=zeros(numel(rows),1);for i=1:numel(rows),v(i)=num(rows(i).(field));end
end
function v=num(v)
if isempty(v),v=NaN;end
end
function checkEqual(a,b,label)
a=double(a(:));b=double(b(:));assert(numel(a)==numel(b),'OxygenDynamics:Next03Mismatch','%s dimensions differ.',label);
assert(all((isnan(a)&isnan(b))|(isfinite(a)&isfinite(b)&abs(a-b)<=1e-10*max(1,abs(b)))), ...
    'OxygenDynamics:Next03Mismatch','%s differs from the independent expected answer.',label);
end
function writeJSON(path,value)
f=fopen(path,'w');assert(f>=0);c=onCleanup(@()fclose(f));fprintf(f,'%s\n',jsonencode(value,'PrettyPrint',true));
end

function c=caseValue(cases,k)
if iscell(cases),c=cases{k};else,c=cases(k);end
end
