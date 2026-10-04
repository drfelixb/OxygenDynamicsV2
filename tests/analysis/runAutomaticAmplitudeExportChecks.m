function runAutomaticAmplitudeExportChecks(Root,Batch)
% Nine fixed saved-table/synthetic cases. No analysis engine or recording input.
addpath(fullfile(Root,'existing-analysis'));setupOxygenDynamicsPath;
folder=fullfile(Root,'reference-validation','automatic-amplitude-exports-20261001');
results=repmat(struct('Case','','Status','','Message',''),9,1);
for k=1:9
    results(k).Case=sprintf('A%02d',k);target=fullfile(folder,sprintf('batch-%02d-A%02d',Batch,k));mkdir(target);
    try
        if k<=6
            [C,B]=fixture(k);before=C;old=B;
            D=createAutomaticAmplitudeExportData(C,B);
            assert(isequaln(C,before)&&isequaln(B,old),'Reporting mutated its inputs.');
            checkFixture(k,D,C,B);
        else
            [C,B,source]=saved(Root,k);before=C;old=B;
            D=createAutomaticAmplitudeExportData(C,B);
            assert(isequaln(C,before)&&isequaln(B,old),'Reporting mutated saved data.');
            checkSaved(Root,k,C,D);
            f=fopen(fullfile(target,'Source.txt'),'w');fprintf(f,'%s\n',source);fclose(f);
        end
        workbook=fullfile(target,'Example.xlsx');
        writetable(C.TableOxygenSinkEvents,workbook,'Sheet','OxySinkEvents');
        writetable(C.TableOxygenSurgeEvents,workbook,'Sheet','OxySurgeEvents');
        writetable(B.RecordingTable,workbook,'Sheet','HypoxicBurden_ByRecording');
        writetable(B.GroupSummaryTable,workbook,'Sheet','HypoxicBurden_GroupSummary');
        oldEvent=readtable(workbook,'Sheet','OxySinkEvents');oldR=readtable(workbook,'Sheet','HypoxicBurden_ByRecording');
        oldSurge=readtable(workbook,'Sheet','OxySurgeEvents');oldG=readtable(workbook,'Sheet','HypoxicBurden_GroupSummary');
        Info=writeAutomaticAmplitudeExport(target,workbook,D);
        assert(isequaln(oldEvent,readtable(workbook,'Sheet','OxySinkEvents')));
        assert(isequaln(oldR,readtable(workbook,'Sheet','HypoxicBurden_ByRecording')));
        assert(isequaln(oldSurge,readtable(workbook,'Sheet','OxySurgeEvents'))&&isequaln(oldG,readtable(workbook,'Sheet','HypoxicBurden_GroupSummary')));
        opts=delimitedTextImportOptions('NumVariables',13,'DataLines',[2 Inf],'Delimiter',',');
        opts.VariableNames=D.AverageCounts.Properties.VariableNames;
        opts.VariableTypes=[repmat({'string'},1,7),{'double','double','double'},repmat({'string'},1,3)];
        A=readtable(Info.AverageCountsCSV,opts);
        X=readtable(workbook,'Sheet','AutomaticAverageCounts','TextType','string','ReadVariableNames',true,'VariableNamingRule','preserve');
        assert(height(A)==height(D.AverageCounts)&&isequaln(A.ContributingCount,D.AverageCounts.ContributingCount), ...
            'CSV rows %d vs %d; count class %s vs %s.',height(A),height(D.AverageCounts),class(A.ContributingCount),class(D.AverageCounts.ContributingCount));
        assert(isequaln(X.ContributingCount,D.AverageCounts.ContributingCount)&&isequaln(X.TotalCount,D.AverageCounts.TotalCount));
        assert(all(isnan(X.Value)==isnan(D.AverageCounts.Value)));
        finite=isfinite(D.AverageCounts.Value);assert(all(abs(X.Value(finite)-D.AverageCounts.Value(finite))<=1e-12*max(1,abs(D.AverageCounts.Value(finite)))));
        if k==7,checkProductionExport(Root,target,C,B,D);end
        M=load(fullfile(target,'AutomaticAmplitudeExport.mat'));assert(isequaln(M.AutomaticAmplitudeExport,D));
        CoreData=C;HypoxicBurden=B;save(fullfile(target,'PreservedResults.mat'),'CoreData','HypoxicBurden');
        AutomaticAmplitudeExport=D;save(fullfile(target,'PreservedResults.mat'),'AutomaticAmplitudeExport','-append');
        P=load(fullfile(target,'PreservedResults.mat'));assert(isequaln(P.CoreData,before)&&isequaln(P.HypoxicBurden,old));
        assert(all(D.AverageCounts.ContributingCount<=D.AverageCounts.TotalCount));
        results(k).Status='pass';results(k).Message='Counts, meaning, export round trip and exact existing-data preservation passed.';
    catch err
        results(k).Status='fail';results(k).Message=getReport(err,'extended','hyperlinks','off');
    end
end
f=fopen(fullfile(folder,sprintf('batch-%02d-results.json',Batch)),'w');fprintf(f,'%s\n',jsonencode(results,'PrettyPrint',true));fclose(f);
assert(all(strcmp({results.Status},'pass')),'OxygenDynamics:AmplitudeExportChecks','One or more named checks failed.');
end
function [C,B]=fixture(k)
rec=[repmat("r1",4,1);"r2";"r3";"r3"];mouse=[repmat("m1",5,1);"m2";"m2"];
amp=[.1;-.02;NaN;0;.2;.04;.06];site=[1;1;1;2;1;1;1];eid=[1;2;3;1;1;1;2];
if k==3,amp(:)=NaN;elseif k==4,amp=-abs(amp);amp(4)=-.01;end
E=table(rec,mouse,site,eid,amp,100*amp,'VariableNames',{'RecordingID','Mouse','SinkID','EventID','NormOxySinkAmp','NormOxySinkAmpPercent'});
E.AmplitudeSignConvention=repmat("positive_drop_percent",7,1);
if k==6
    E.AmplitudeSignConvention(:)="negative_drop_percent";E.NormOxySinkAmp=-E.NormOxySinkAmp;E.NormOxySinkAmpPercent=-E.NormOxySinkAmpPercent;
end
E.Condition=repmat("example",7,1);E.EventArea_um2=[10;10;10;10;NaN;20;20];
E.DurationSec=[2;2;2;2;2;2;NaN];E.StartFrame=[21;25;29;33;21;21;25];E.EndFrame=E.StartFrame+1;
E.RecAreaSize=repmat(1e6,7,1);E.RecDuration=repmat(60,7,1);E.SampleF=ones(7,1);
if k==5,E=E([],:);end
Registry=table(["r1";"r2";"r3";"r4"],["m1";"m1";"m2";"m3"],repmat("example",4,1),repmat(1e6,4,1),repmat(60,4,1), ...
    'VariableNames',{'RecordingID','Mouse','Condition','RecordingArea_um2','RecordingDuration_sec'});
S=table('Size',[0 4],'VariableTypes',{'string','string','double','cell'},'VariableNames',{'RecordingID','Mouse','SiteID','NormOxySinkAmp'});
for r=reshape(unique(E.RecordingID,'stable'),1,[])
    for s=reshape(unique(E.SinkID(E.RecordingID==r),'stable'),1,[])
        Q=E(E.RecordingID==r & E.SinkID==s,:);S(end+1,:)={r,Q.Mouse(1),s,{Q.NormOxySinkAmp'}};
    end
end
U=table("r1","m1",1,{[.03 -.01 NaN]},'VariableNames',{'RecordingID','Mouse','SiteID','NormOxySurgeAmp'});
V=table(repmat("r1",3,1),[.03;-.01;NaN],'VariableNames',{'RecordingID','NormOxySurgeAmp'});
if k==5,U=U([],:);V=V([],:);end
C=struct('TableOxygenSinks',S,'TableOxygenSinkEvents',E,'TableOxygenSurges',U,'TableOxygenSurgeEvents',V,'RecordingRegistry',Registry);
B=createHypoxicBurdenMetrics(E,table(),S,Registry);
end
function checkFixture(k,D,C,B)
T=D.AverageCounts;
if k==1||k==2||k==6
    q=row(T,"recording","MeanBurdenAmplitudePercent","r1","");assert(q.ContributingCount==2&&q.TotalCount==4&&q.Value==5);
    q=row(T,"recording","MeanEventBurdenContribution","r1","");assert(q.ContributingCount==2&&q.TotalCount==4&&q.Value==100);
    a=D.Availability;a=a(a.SummaryLevel=="recording" & a.EventType=="sink" & a.RecordingID=="r1",:);
    assert(a.UnavailableAmplitudeEvents==1&&a.NegativeAmplitudeExcludedFromBurdenEvents==1&&a.UnavailableCompositeEvents==2);
    a=D.Availability;a=a(a.SummaryLevel=="recording" & a.EventType=="sink" & a.RecordingID=="r2",:);
    assert(a.UnavailableAmplitudeEvents==0&&a.NegativeAmplitudeExcludedFromBurdenEvents==0&&a.UnavailableCompositeEvents==1);
    q=row(T,"recording","MeanBurdenDuration_sec","r3","");assert(q.ContributingCount==1&&q.TotalCount==2&&q.Value==2);
    q=row(T,"equal_mouse_group","MeanBurdenAmplitudePercent_Mean","","");assert(q.ContributingCount==2&&q.TotalCount==3&&q.Value==8.75);
    q=row(T,"within_mouse","MeanBurdenAmplitudePercent","","m1");assert(q.ContributingCount==2&&q.TotalCount==2&&q.Value==12.5);
    q=row(T,"equal_mouse_group","Burden_AmplitudeComposite_Mean","","");assert(q.ContributingCount==1&&q.TotalCount==3&&q.Value==0);
    q=row(T,"within_mouse","Burden_AmplitudeComposite","","m1");assert(q.ContributingCount==0&&q.TotalCount==2&&isnan(q.Value));
    q=T(T.SummaryLevel=="site" & T.EventType=="sink" & T.RecordingID=="r1" & T.SiteID=="1",:);
    assert(q.ContributingCount==2&&q.TotalCount==3&&abs(q.Value-safeCellMean(C.TableOxygenSinks.NormOxySinkAmp{1}))<eps);
elseif k==3||k==4
    q=row(T,"recording","MeanBurdenAmplitudePercent","r1","");assert(q.ContributingCount==0&&q.TotalCount==4&&isnan(q.Value));
    q=row(T,"equal_mouse_group","MeanBurdenAmplitudePercent_Mean","","");assert(q.ContributingCount==0&&q.TotalCount==3&&isnan(q.Value));
    if k==4
        q=T(T.SummaryLevel=="site" & T.EventType=="sink",:);assert(all(q.Value<0));
    end
elseif k==5
    q=row(T,"recording","MeanBurdenAmplitudePercent","r1","");assert(q.ContributingCount==0&&q.TotalCount==0&&isnan(q.Value));
    assert(all(B.RecordingTable.HypoxicBurden==0));
end
if k~=5
    assert(isequaln(C.TableOxygenSinkEvents.NormOxySinkAmpPercent,100*C.TableOxygenSinkEvents.NormOxySinkAmp));
    a=D.Availability;a=a(a.SummaryLevel=="recording" & a.EventType=="surge" & a.RecordingID=="r1",:);
    assert(a.UnavailableAmplitudeEvents==1&&a.NegativeAmplitudeEvents==1&&isnan(a.UnavailableCompositeEvents));
end
end
function q=row(T,level,metric,rec,mouse)
mask=T.SummaryLevel==level & T.Metric==metric;
if strlength(rec)>0,mask=mask & T.RecordingID==rec;end
if strlength(mouse)>0,mask=mask & T.Mouse==mouse;end
q=T(mask,:);assert(height(q)==1);
end
function [C,B,path]=saved(Root,k)
paths={ ...
' reference-validation/software-g2-workflow-20260923/gui-run/statistics/Stats_Output_20260923T102730/DataOutput.mat', ...
' reference-validation/phase1-optimized-20260909/FB2312-baseline-awake/stats/Stats_Output_20260909T101409/DataOutput.mat', ...
' reference-validation/boi-c02-strict-roi-20260912/run-01/statistics/Stats_Output_20260912T155949/DataOutput.mat'};
path=fullfile(Root,strtrim(paths{k-6}));L=load(path);
C=struct('TableOxygenSinks',L.Table_OxygenSinks_OutCombo,'TableOxygenSinkEvents',L.Table_OxygenSinkEvents_OutCombo, ...
    'TableOxygenSurges',L.Table_OxygenSurges_OutCombo,'TableOxygenSurgeEvents',L.Table_OxygenSurgeEvents_OutCombo);
if isfield(L,'RecordingRegistry'),C.RecordingRegistry=L.RecordingRegistry;end
B=L.HypoxicBurden;
end
function checkSaved(Root,k,C,D)
for kind=["sink","surge"]
    if kind=="sink",S=C.TableOxygenSinks;amp='NormOxySinkAmp';else,S=C.TableOxygenSurges;amp='NormOxySurgeAmp';end
    for i=1:height(S)
        q=D.AverageCounts(D.AverageCounts.SummaryLevel=="site" & D.AverageCounts.EventType==kind,:);q=q(i,:);
        assert(isequaln(q.Value,safeCellMean(S.(amp){i}))&&q.TotalCount==numel(S.(amp){i}));
    end
end
if k==7
    E=C.TableOxygenSinkEvents;mask=E.SinkID==1 & E.EventID==3;
    assert(abs(E.NormOxySinkAmp(mask)-.055522971205831419)<=1e-12);
    g=jsondecode(fileread(fullfile(Root,'reference-validation','software-g4-evidence-20260927','saved-bundle-final','Evidence.json')));
    e=g.AutomaticEvent;v=(mean(e.BaselineValues)-min(e.MeasurementValues))/mean(e.BaselineValues);
    assert(abs(v-E.NormOxySinkAmp(mask))<=1e-12&&abs(100*v-E.NormOxySinkAmpPercent(mask))<=1e-10);
else
    if k==8,audit='reference-validation/signal-audit-full-20260909/normalization-detail-FB2312/event-amplitude-audit.mat';i=194;
    else,audit='reference-validation/boi-c02-strict-roi-20260912/audit-01/source-amplitude-audit/event-amplitude-audit.mat';i=321;end
    L=load(fullfile(Root,audit),'Audit');a=L.Audit(i,:);E=C.TableOxygenSurgeEvents;
    mask=E.SurgeID==a.SiteID & E.EventID==a.EventID;
    assert(sum(mask)==1&&isequaln(E.NormOxySurgeAmp(mask),a.StoredAmplitude));
    assert(isequaln(E.NormOxySurgeAmpPercent(mask),100*a.StoredAmplitude));
end
end

function checkProductionExport(Root,target,C,B,D)
source=fullfile(Root,'reference-validation/software-g2-workflow-20260923/gui-run/statistics/Stats_Output_20260923T102730/DataOutput.mat');
L=load(source);Core=C;
pairs={'FiltersOxySinksMetrics','FiltersOxySinksMetrics';'FiltersOxySurgesMetrics','FiltersOxySurgesMetrics'; ...
'FiltersROIsAndEvents','Filters_ROIsandEvents';'ExportTraces','ExportTraces'; ...
'NumOngoingOxysinks','NumOngoingOxysinks';'NumOngoingOxysinksPerMm2','NumOngoingOxysinksPerMm2'; ...
'SinkCountAreaNormalization','SinkCountAreaNormalization';'TotalSinkAreaNorm','TotalSinkArea_Norm'; ...
'NumOngoingOxysurges','NumOngoingOxysurges';'TotalSurgeArea','TotalSurgeArea'; ...
'SinksRaster','SinksRaster';'SurgesRaster','SurgesRaster';'StatsInfo','StatsInfo'};
for j=1:size(pairs,1),Core.(pairs{j,1})=L.(pairs{j,2});end
Core.HypoxicBurden=B;Core.HypoxicEventSpecificMetrics=table();
for f={'BaselineContrasts','RecordingWindowMetrics','WindowBaselineContrasts'}
    if isfield(L,f{1}),Core.(f{1})=L.(f{1});else,Core.(f{1})=table();end
end
A=createAdditionalOxygenSinkMetrics(C.TableOxygenSinks);U=createAdditionalOxygenSurgeMetrics(C.TableOxygenSurges);
[Ready,~]=createStatsMetricWorkbookData(C.TableOxygenSinks,C.TableOxygenSurges,A,U,Core.FiltersOxySinksMetrics,Core.FiltersOxySurgesMetrics);
BLI=struct('BehaviourDataCombo',[],'BehaviourLogicals',[],'ROIsTraces',[],'ExportTraceCorrs',[],'TraceCorrs',[]);
W=struct('AlignedSinkTraces',[],'TraceCorrs',[],'LPawBinnedTraces',[],'RPawBinnedTraces',[], ...
'PupilBinnedTraces',[],'PooledTraces',[],'BehaviourLogicals',[],'SampleFs',[],'PuffsFs',[],'FiguresOutputFolder',[]);
output=fullfile(target,'production-export');
Info=exportStatsResults(output,'saved-ID400.csv',true,Core,BLI,W,Ready,{},{});
P=load(Info.DataOutputMat);
assert(isequaln(P.Table_OxygenSinks_OutCombo,C.TableOxygenSinks)&&isequaln(P.Table_OxygenSinkEvents_OutCombo,C.TableOxygenSinkEvents));
assert(isequaln(P.Table_OxygenSurges_OutCombo,C.TableOxygenSurges)&&isequaln(P.Table_OxygenSurgeEvents_OutCombo,C.TableOxygenSurgeEvents));
assert(isequaln(P.HypoxicBurden,B)&&isequaln(P.AutomaticAmplitudeExport,D));
assert(isfile(Info.AutomaticAmplitude.Report));
assert(isequaln(P.HypoxicBurden.RecordingTable,B.RecordingTable)&&isequaln(P.HypoxicBurden.GroupSummaryTable,B.GroupSummaryTable));
end
