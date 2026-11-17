function tests=testBOIBurdenCompleteness
% Synthetic only: strict missingness in calculations, files and GUI rows.
tests=functiontests(localfunctions);
end

function testMissingIngredientWithholdsEveryTotal(t)
[E,G]=fixture();
for field={'NormOxySinkAmpPercent','EventArea_um2','DurationSec'}
    input=E;input.(field{1})(2)=NaN;
    for registry={G,table()}
        B=createHypoxicBurdenMetrics(input,table(),table(),registry{1});
        verifyTrue(t,all(isnan(B.RecordingTable{:,totalColumns()})));
        verifyEqual(t,B.EventTable.PerEventBurdenContribution(1),80);
        verifyTrue(t,isnan(B.EventTable.PerEventBurdenContribution(2)));
    end
end
end

function testCompleteFormulaNormalizationAndKnownZero(t)
[E,G]=fixture();B=createHypoxicBurdenMetrics(E,table(),table(),G);
verifyEqual(t,B.EventTable.PerEventBurdenContribution,[80;120]);
verifyEqual(t,B.RecordingTable{:,totalColumns()},[200 2e6 2 120 20000 1.2e6 200]);
B=createHypoxicBurdenMetrics(E([],:),table(),table(),G);
verifyEqual(t,B.RecordingTable{:,totalColumns()},zeros(1,7));
verifyEqual(t,B.RecordingTable.NumEvents,0);
end

function testGuiDoesNotDisplayPartialSumMeanOrMaximum(t)
[E,G]=fixture();E.NormOxySinkAmpPercent(2)=NaN;
B=createHypoxicBurdenMetrics(E,table(),table(),G);rows=preview(B);
labels={'Hypoxic burden event sum','Hypoxic burden event sum per 1 mm2', ...
    'Hypoxic burden total','Hypoxic burden total per 1 mm2', ...
    'Mean hypoxic burden per min','Mean hypoxic burden per 1 mm2 per min', ...
    'Mean burden amplitude composite','Mean grouped burden', ...
    'Mean grouped burden per 1 mm2','Mean grouped burden per 1 mm2 per min', ...
    'Mean burden over time per 1 mm2','Max burden over time per 1 mm2'};
for label=labels,verifyTrue(t,startsWith(rowValue(rows,label{1}),'Unavailable'));end
verifyEqual(t,rowValue(rows,'Available event contributions'),'1 / 2 (count only)');
verifyEqual(t,rowValue(rows,'Complete normalized recording burdens'),'0 / 1 (count only)');
verifyTrue(t,isnan(B.TimeSeriesTable.HypoxicBurdenOverTime(20)));
verifyEqual(t,B.TimeSeriesTable.HypoxicBurdenOverTime(10),40);
end

function testGuiAllMissingCannotBecomeZero(t)
[E,G]=fixture();E.NormOxySinkAmpPercent(:)=NaN;
B=createHypoxicBurdenMetrics(E,table(),table(),G);rows=preview(B);
verifyEqual(t,rowValue(rows,'Hypoxic burden event sum'),'Unavailable (2 of 2 inputs unresolved)');
verifyEqual(t,rowValue(rows,'Hypoxic burden total'),'Unavailable (1 of 1 inputs unresolved)');
verifyEqual(t,rowValue(rows,'Available event contributions'),'0 / 2 (count only)');
end

function testGuiCompleteAndZeroValuesStayNumeric(t)
[E,G]=fixture();B=createHypoxicBurdenMetrics(E,table(),table(),G);rows=preview(B);
verifyEqual(t,rowValue(rows,'Hypoxic burden total'),'200');
verifyEqual(t,rowValue(rows,'Mean hypoxic burden per 1 mm2 per min'),'1.2e+06');
B=createHypoxicBurdenMetrics(E([],:),table(),table(),G);rows=preview(B);
verifyEqual(t,rowValue(rows,'Hypoxic burden total'),'0');
verifyEqual(t,rowValue(rows,'Mean hypoxic burden per 1 mm2 per min'),'0');
end

function testIncompleteMouseNotHiddenByAvailableGroupMean(t)
[E,G]=fixture();other=E;other.RecordingID(:)="other";
g=G;g.RecordingID="other";E.NormOxySinkAmpPercent(2)=NaN;
B=createHypoxicBurdenMetrics([E;other],table(),table(),[G;g]);
verifyTrue(t,isnan(B.GroupSummaryTable.HypoxicBurden_Mean));
verifyEqual(t,B.GroupSummaryTable.HypoxicBurden_NValidMice,0);
third=other;third.RecordingID(:)="third";third.Mouse(:)="other-mouse";
g3=g;g3.RecordingID="third";g3.Mouse="other-mouse";
B=createHypoxicBurdenMetrics([E;other;third],table(),table(),[G;g;g3]);
% Keep the existing export estimand and explicit valid-mouse count unchanged.
verifyEqual(t,B.GroupSummaryTable.HypoxicBurden_Mean,200);
verifyEqual(t,B.GroupSummaryTable.HypoxicBurden_NValidMice,1);
verifyEqual(t,B.GroupSummaryTable.NumMice,2);
rows=preview(B);
verifyEqual(t,rowValue(rows,'Mean grouped burden'),'Unavailable (1 of 2 mouse summaries unresolved)');
verifyTrue(t,startsWith(rowValue(rows,'Mean grouped burden per 1 mm2 per min'),'Unavailable'));
end

function testWorkbookAndCsvKeepTotalsUnavailable(t)
[E,G]=fixture();E.NormOxySinkAmpPercent(2)=NaN;
B=createHypoxicBurdenMetrics(E,table(),table(),G);
folder=tempname;mkdir(folder);cleanup=onCleanup(@()rmdir(folder,'s'));
xlsx=fullfile(folder,'synthetic.xlsx');writeHypoxicBurdenWorkbookSheets(xlsx,B);
csv=fullfile(folder,'synthetic.csv');writetable(B.RecordingTable,csv);
for source={xlsx,csv}
    if endsWith(source{1},'.xlsx')
        R=readtable(source{1},'Sheet','HypoxicBurden_ByRecording','VariableNamingRule','preserve');
    else
        R=readtable(source{1},'VariableNamingRule','preserve');
    end
    verifyTrue(t,all(isnan(R{:,totalColumns()})));
    verifyEqual(t,R.NumEvents,2);verifyEqual(t,R.NumValidCompositeEvents,1);
end
events=readtable(xlsx,'Sheet','HypoxicBurden_EventBased','VariableNamingRule','preserve');
verifyEqual(t,events.PerEventBurdenContribution(1),80);
verifyTrue(t,isnan(events.PerEventBurdenContribution(2)));
end

function rows=preview(HypoxicBurden)
folder=tempname;mkdir(folder);cleanup=onCleanup(@()rmdir(folder,'s'));
path=fullfile(folder,'synthetic.mat');save(path,'HypoxicBurden');
rows=buildOxygenStatsPreviewRows(struct('DataOutputMat',path));
end
function value=rowValue(rows,label)
index=find(strcmp(rows(:,1),label));assert(isscalar(index),'Missing or duplicate preview row.');
value=rows{index,2};
end
function names=totalColumns()
names={'HypoxicBurden','HypoxicBurden_per_mm2','HypoxicBurden_per_sec', ...
    'HypoxicBurden_per_min','HypoxicBurden_per_mm2_per_sec', ...
    'HypoxicBurden_per_mm2_per_min','Burden_AmplitudeComposite'};
end
function [E,G]=fixture()
G=table("recording","experiment","mouse","baseline","none","genotype","promoter",false,100,1,100,100, ...
    'VariableNames',{'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim', ...
    'NFrames','SampleF','RecordingDuration_sec','RecordingArea_um2'});
E=repmat(G,2,1);E.SinkID=[1;2];E.EventID=[1;1];E.StartFrame=[10;20];E.EndFrame=[11;21];E.DurationSec=[2;2];
E.NormOxySinkAmpPercent=[10;20];E.EventArea_um2=[4;3];E.RecAreaSize=[100;100];E.RecDuration=[100;100];
end
