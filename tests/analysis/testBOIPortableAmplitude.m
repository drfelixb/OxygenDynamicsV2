function tests=testBOIPortableAmplitude
% Existing amplitude meanings and contributors, without local saved results.
tests=functiontests(localfunctions);
end
function setupOnce(~),setupOxygenDynamicsPath;end
function testFiniteNegativeMissingAndZero(~),check(1);end
function testUnequalMouseContributors(~),check(2);end
function testAllUnavailable(~),check(3);end
function testAllNegative(~),check(4);end
function testNoEvents(~),check(5);end
function testExplicitLegacySign(~),check(6);end
function check(k)
[C,B]=fixture(k);original=C;old=B;D=createAutomaticAmplitudeExportData(C,B);
assert(isequaln(C,original)&&isequaln(B,old));checkFixture(k,D,C,B);
folder=tempname;mkdir(folder);cleanup=onCleanup(@()rmdir(folder,'s'));
workbook=fullfile(folder,'Exports.xlsx');writetable(C.TableOxygenSinkEvents,workbook,'Sheet','OriginalSink');
writetable(C.TableOxygenSurgeEvents,workbook,'Sheet','OriginalSurge');
before=readtable(workbook,'Sheet','OriginalSink');beforeSurge=readtable(workbook,'Sheet','OriginalSurge');
writeAutomaticAmplitudeExport(folder,workbook,D);
assert(isequaln(before,readtable(workbook,'Sheet','OriginalSink'))&&isequaln(beforeSurge,readtable(workbook,'Sheet','OriginalSurge')));
S=load(fullfile(folder,'AutomaticAmplitudeExport.mat'));assert(isequaln(S.AutomaticAmplitudeExport,D));
opts=delimitedTextImportOptions('NumVariables',13,'DataLines',[2 Inf],'Delimiter',',');opts.VariableNames=D.AverageCounts.Properties.VariableNames;
opts.VariableTypes=[repmat({'string'},1,7),{'double','double','double'},repmat({'string'},1,3)];T=readtable(fullfile(folder,'AutomaticAverageCounts.csv'),opts);
assert(isequaln(T.ContributingCount,D.AverageCounts.ContributingCount)&&isequaln(T.TotalCount,D.AverageCounts.TotalCount));
a=T.Value;b=D.AverageCounts.Value;assert(all((isnan(a)&isnan(b))|(isfinite(a)&isfinite(b)&abs(a-b)<=1e-10*max(1,abs(b)))));
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

function v=safeCellMean(v)
v=v(isfinite(v));if isempty(v),v=NaN;else,v=mean(v);end
end
