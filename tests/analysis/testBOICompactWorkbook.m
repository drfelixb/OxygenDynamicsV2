function tests=testBOICompactWorkbook
tests=functiontests(localfunctions);
end
function testIdentityAndOptionalMetadata(t)
[S,V,O]=fixture();[p,P]=prepareBOICompactWorkbook(S,{},target('identity.xlsx'),O);D=P.Data;
t.verifyEqual(height(D.Events),5);t.verifyEqual(p.Counts.Recordings,8);
t.verifyEqual(D.Events.RecordingID,["001";"001";"002";"002";"002"]);
t.verifyEqual(D.Events.Mouse,["M01";"M01";"M01";"M01";"M01"]);
t.verifyEqual(D.Events.SessionID,repmat("Visit01",5,1));t.verifyEqual(D.Events.Condition,["control";"control";"drug";"drug";"drug"]);
t.verifyEqual(D.Events.FieldOfViewID,["F01";"F01";"F02";"F02";"F02"]);
t.verifyEqual(D.Events.ControlRecordingID,["";"";"001";"001";"001"]);
t.verifyEqual(D.Sites.AutomaticEventCount,[2;2;1]);
t.verifyEqual(string(D.Events.Properties.VariableNames(1:5)),["RecordingID","Experiment","Mouse","SessionID","Condition"]);
O.Metadata.Mouse(1)="wrong";t.verifyError(@()prepareBOICompactWorkbook(S,{},target('identity.xlsx'),O),'OxygenDynamics:CompactConflict');
t.verifyEqual(V.Receipt.Status,'complete');
end
function testZeroMissingAndReviewStates(t)
[S,V,O]=fixture();[~,P]=prepareBOICompactWorkbook(S,{},target('states.xlsx'),O);D=P.Data;
t.verifyTrue(all(isnan(D.Events.ReviewedContribution)));t.verifyTrue(all(D.Events.ReviewStatus=="No compatible reviewed snapshot"));
r=D.Recordings(D.Recordings.EventType=="sink",:);t.verifyEqual(r.AutomaticInventoryCount(3),0);t.verifyTrue(isnan(r.AutomaticInventoryCount(4)));
t.verifyEqual(r.AutomaticBurden(3),0);t.verifyTrue(isnan(r.AutomaticBurden(2)));t.verifyTrue(isnan(r.AutomaticBurden(4)));
[~,P]=prepareBOICompactWorkbook(S,{V},target('states.xlsx'),O);D=P.Data;E=D.Events;
t.verifyEqual(E.ReviewStatus(3),"No manual review");t.verifyEqual(E.ReviewedContribution(3),S.Tables.HypoxicBurden_EventBased.PerEventBurdenContribution(3));
t.verifyTrue(all(isnan(E.ReviewedContribution(E.EventType=="surge"))));
a=D.Availability;t.verifyTrue(any(a.State=="excluded_not_applicable"));t.verifyTrue(any(a.State=="not_applicable"));
end
function testSignedCompletenessAndReviewMembership(t)
[S,V,O]=fixture();[~,P]=prepareBOICompactWorkbook(S,{V},target('signed.xlsx'),O);E=P.Data.Events;R=P.Data.Recordings;
t.verifyEqual(E.AutomaticContribution(1),-300);t.verifyEqual(E.AutomaticBurdenContributionNegative(1),1);
t.verifyEqual(E.ReviewedExcluded(1),1);t.verifyTrue(isnan(E.ReviewedContribution(1)));t.verifyEqual(height(E),5);
t.verifyEqual(E.ReviewedContribution(2),2860);t.verifyEqual(E.ReviewedAmplitudePercent(2),11);
r=R(R.EventType=="sink",:);t.verifyEqual(r.AutomaticBurden(1),2100);t.verifyEqual(r.AutomaticBurden_per_mm2_per_min(1),10500);
t.verifyEqual(r.ReviewedBurden_per_mm2_per_min(1),14300);t.verifyEqual(r.AutomaticNegativeContributions(1),1);
t.verifyTrue(isnan(r.AutomaticBurden(2)));t.verifyTrue(isnan(r.ReviewedBurden(2)));
t.verifyEqual(r.ReviewedExcludedCount(1),1);t.verifyEqual(r.AutomaticRequiredContributions(2),2);t.verifyEqual(r.AutomaticAvailableContributions(2),1);
% Source legacy missingness and policy must survive; no R31 relabelling.
S.Tables=rmfield(S.Tables,'Burden_SelectionPolicy');S.Tables.HypoxicBurden_EventBased.PerEventBurdenContribution(1)=NaN;
S.Tables.HypoxicBurden_ByRecording.HypoxicBurden(1)=NaN;
[~,P]=prepareBOICompactWorkbook(S,{},target('signed.xlsx'),O);
t.verifyTrue(isnan(P.Data.Events.AutomaticContribution(1)));t.verifyTrue(contains(P.Data.Events.AutomaticBurdenPolicy(1),'legacy'));
end
function testReferenceAUCAndNativeGapProvenance(t)
[S,V,O]=fixture();[~,P]=prepareBOICompactWorkbook(S,{V},target('reference.xlsx'),O);E=P.Data.Events;
t.verifyEqual(E.AutomaticEventReferenceShort(1),1);t.verifyEqual(E.AutomaticAboveRecordingReference(1),1);
t.verifyEqual(E.AutomaticOpticalAUC_fraction_sec(2),-0.234567890123);
t.verifyEqual(E.AutomaticAUCBaselineStartFrame(2),1);t.verifyEqual(E.AutomaticAUCVersion(2),"original-optical-1");
t.verifyEqual(E.AutomaticPreviousNativeGapSec(2),4);t.verifyEqual(E.AutomaticNextNativeGapSec(1),4);
t.verifyFalse(ismember('ReviewedOpticalAUC_fraction_sec',E.Properties.VariableNames));
t.verifyEqual(E.AutomaticAmplitudePercent(2),10);t.verifyEqual(E.ReviewedAmplitudePercent(2),11);
t.verifyEqual(E.AutomaticAUCBaselineValue(2),1200);t.verifyTrue(isnan(E.AutomaticEventReferenceValue(4)));
end
function testSourceConflictsAndPreservation(t)
[S,V,O]=fixture();before=boiBatchQueueDigest(S);bad=V;bad.Receipt.SourceStatsSHA256='foreign';
t.verifyError(@()prepareBOICompactWorkbook(S,{bad},target('conflict.xlsx'),O),'OxygenDynamics:CompactParent');
t.verifyError(@()prepareBOICompactWorkbook(S,{V,V},target('conflict.xlsx'),O),'OxygenDynamics:CompactConflict');
bad=V;bad.HypoxicBurden.SelectionPolicy.Version="foreign-policy";
t.verifyError(@()prepareBOICompactWorkbook(S,{bad},target('conflict.xlsx'),O),'OxygenDynamics:CompactParent');
bad=V;bad.HypoxicBurden.ReviewDecisions.ExcludedFromReviewedBurden(1)=0;
t.verifyError(@()prepareBOICompactWorkbook(S,{bad},target('conflict.xlsx'),O),'OxygenDynamics:CompactReview');
bad=S;bad.Tables.OxySinkEvents=[bad.Tables.OxySinkEvents;bad.Tables.OxySinkEvents(1,:)];
t.verifyError(@()prepareBOICompactWorkbook(bad,{},target('conflict.xlsx'),O),'OxygenDynamics:CompactIdentity');
[p,~]=prepareBOICompactWorkbook(S,{},target('conflict.xlsx'),O);S.Tables.OxySinkEvents.DurationSec(1)=99;
t.verifyError(@()exportBOICompactWorkbook(S,{},target('conflict.xlsx'),O,p),'OxygenDynamics:CompactPlanChanged');
[S,~,~]=fixture();t.verifyEqual(boiBatchQueueDigest(S),before);
t.verifyFalse(isfile(target('conflict.xlsx')));t.verifyFalse(isfile(target('conflict.xlsx')));
end
function testNumericUnitsPrecisionAndDefinitions(t)
[S,V,O]=fixture();[~,P]=prepareBOICompactWorkbook(S,{V},target('precision.xlsx'),O);D=P.Data;
t.verifyEqual(D.Events.AutomaticAmplitudePercent(3),12.345678901234,'AbsTol',1e-12);
t.verifyEqual(D.Events.AutomaticMeanArea_um2(3),70);t.verifyEqual(D.Events.AutomaticDuration_sec(3),5);
t.verifyEqual(D.Events.AutomaticContribution_per_mm2_per_min(1),-1500);
X=D.Definitions;expected=0;for f=string(fieldnames(D))',if f~="Definitions",expected=expected+width(D.(f));end,end
t.verifyEqual(height(X),expected);t.verifyTrue(all(strlength(X.Units)>0&strlength(X.ComparisonScope)>0&strlength(X.SourceColumn)>0));
a=X.Field=="AutomaticAmplitudePercent";t.verifyTrue(all(contains(X.Units(a),'percent')));t.verifyTrue(all(contains(X.Normalization(a),'no extra factor')));
a=X.Field=="AutomaticBurdenPerMm2";t.verifyTrue(all(contains(X.Normalization(a),'NOT per minute')));
a=X.Field=="AutomaticAUCBaselineValue";t.verifyTrue(all(contains(X.ComparisonScope(a),'NOT directly comparable')));
TS=D.TimeSeries;t.verifyEqual(TS.TimeSec(TS.RecordingID=="001"),[0;.5;1]);
t.verifyEqual(TS.AutomaticBurdenPerMm2(1),-250);t.verifyEqual(TS.ReviewedBurdenPerMm2(1),0);
t.verifyEqual(TS.AutomaticActiveEvents(1),2);t.verifyEqual(TS.AutomaticBurdenActiveEvents(1),1);
t.verifyEqual(TS.AutomaticActiveEvents_per_mm2(1),10);
t.verifyTrue(all(isnan(D.Recordings.AnalyzedArea_um2(D.Recordings.EventType=="surge"))));
end
function testSourcesClocksAndWorkbookContract(t)
[S,~,O]=fixture();out=evidence();
% One declared native input writer dispatch, with scalar tables only.
book=fullfile(out,'SyntheticDetailedSource.xlsx');
if ~isfile(book)
    countWrite();names=fieldnames(S.Tables);writetable(S.Registry,book,'Sheet','RecordingRegistry');
    for i=1:numel(names),if istable(S.Tables.(names{i})),writetable(S.Tables.(names{i}),book,'Sheet',names{i});end,end
end
RecordingRegistry=S.Registry;HypoxicBurden=struct('EventTable',S.Tables.HypoxicBurden_EventBased,'RecordingTable',S.Tables.HypoxicBurden_ByRecording, ...
    'TimeSeriesTable',S.Tables.HypoxicBurden_TimeSeries,'SelectionPolicy',S.Tables.Burden_SelectionPolicy);
WindowFrameIngredients=S.Tables.WindowFrameIngredients;SurgeWindowFrameIngredients=S.Tables.SurgeWindowFrameIngredients;
NumOngoingOxysinks=S.Tables.NumOngoingOxysinks;NumOngoingOxysinksPerMm2=S.Tables.NumOngoingOxysinksPerMm2;NumOngoingOxysurges=S.Tables.NumOngoingOxysurges;
RawMovie=uint8(ones(3)); %#ok<NASGU> whitelist must not load even this variable
mat=fullfile(out,'synthetic-source.mat');save(mat,'RecordingRegistry','HypoxicBurden','WindowFrameIngredients','SurgeWindowFrameIngredients', ...
    'NumOngoingOxysinks','NumOngoingOxysinksPerMm2','NumOngoingOxysurges','RawMovie');
source=struct('Workbook',book,'DataOutput',mat);before=[string(oxygenFileSHA256(book)),string(oxygenFileSHA256(mat))];
[p,P]=prepareBOICompactWorkbook(source,{},target('Compact_AutomaticOnly.xlsx'),O);
t.verifyEqual(P.Data.Events.RecordingID(1),"001");t.verifyFalse(isfield(P.Source.Tables,'RawMovie'));
receipt=exportBOICompactWorkbook(source,{},p.OutputFile,O,p,@countWrite);
t.verifyEqual(string(sheetnames(receipt.Workbook)),["Events";"Recordings";"Sites";"TimeSeries";"Availability";"Definitions"]);
t.verifyEqual([string(oxygenFileSHA256(book)),string(oxygenFileSHA256(mat))],before);
t.verifyEqual(receipt.ScientificCalculations,0);t.verifyTrue(isfile([receipt.Workbook '.receipt.json']));
f=fullfile(out,'xml-check');mkdir(f);c=onCleanup(@()rmdir(f,'s'));unzip(receipt.Workbook,f);
xml=fileread(fullfile(f,'xl','worksheets','sheet1.xml'));t.verifyTrue(contains(xml,'state="frozen"'));t.verifyTrue(contains(xml,'autoFilter'));
t.verifyFalse(contains(xml,'<f>'));t.verifyFalse(contains(fileread(fullfile(f,'xl','styles.xml')),'formatCode="0%"'));
bad=S;bad.Tables.HypoxicBurden_TimeSeries.TimeSec(1)=.25;
t.verifyError(@()prepareBOICompactWorkbook(bad,{},target('clock.xlsx'),O),'OxygenDynamics:CompactClock');
% Previously generated synthetic source compatibility only; no original recordings.
prior=fullfile(fileparts(out),'boi-revision31-implementation-20261113');
L=loadBOICompactWorkbookSources(fullfile(prior,'synthetic-automatic-source.mat'),{},struct());
t.verifyEqual(height(L.Registry),1);csv=readtable(fullfile(prior,'signed-export','HypoxicBurden_EventBased.csv'));
t.verifyEqual(height(csv),1);t.verifyLessThan(csv.PerEventBurdenContribution(1),0);
reviewBook=readtable(fullfile(prior,'signed-export','ReviewedHypoxicBurden.xlsx'),'Sheet','HypoxicBurden_EventBased');
t.verifyEqual(reviewBook.PerEventBurdenContribution,csv.PerEventBurdenContribution);
end
function testGUISelectionAndFailureRecovery(t)
[S,V,O]=fixture();out=evidence();batch=fullfile(out,'synthetic-batch.csv');
f=fopen(batch,'w');fprintf(f,'Paths,Mouse\nconstructed,M01\n');fclose(f);
review=fullfile(out,'completed-review.mat');HypoxicBurden=V.HypoxicBurden;Receipt=V.Receipt;save(review,'HypoxicBurden','Receipt');
writeBOIRunJSON(fullfile(out,'ReviewedBurdenStatus.json'),Receipt);
boiCompactExportSelection('save',batch,V.Receipt.SourceStatsSHA256,{review});
before=oxygenFileSHA256(batch);remembered=boiCompactExportSelection('load',batch,V.Receipt.SourceStatsSHA256);
t.verifyTrue(remembered.Restored);stale=boiCompactExportSelection('load',batch,'changed');t.verifyFalse(stale.Restored);
fig=uifigure('Visible','off');c=onCleanup(@()delete(fig));parent=uitab(uitabgroup(fig));
Host=struct('AssertIdle',@()[],'Begin',@(~)[],'End',@()[],'AutomaticSource',@()S, ...
    'BatchContext',@()struct('FilePath',batch,'Metadata',table()),'BeforeWrite',@countWrite);
P=createBOICompactExportPanel(parent,Host);P.SetInputs(S,{review},target('cancel.xlsx'),O);P.Preview();P.Cancel();
t.verifyFalse(P.State().Busy);t.verifyEmpty(P.State().Plan);t.verifyFalse(isfile(target('cancel.xlsx')));
O.Phases=table("001","stimulation",10,20,"researcher notes","approximate", ...
    'VariableNames',{'RecordingID','Phase','StartSec','EndSec','AnnotationSource','AnnotationUncertainty'});
paired='Compact_SelectedReviews_Phases.xlsx';scope=jsondecode(fileread(fullfile(out,'scope.json')));
if scope.Counters.RepairCycles>0,paired='Compact_WriterRetry.xlsx';end
if isfield(scope,'FinalVerificationOutput'),paired=scope.FinalVerificationOutput;end
P.SetInputs(S,{review},target(paired),O);plan=P.Preview();
lastwarn('');result=P.Export();[exportWarning,~]=lastwarn;t.verifyEmpty(exportWarning);t.verifyEqual(result.Status,'complete');t.verifyEqual(numel(plan.Sheets),7);
t.verifyEqual(string(sheetnames(result.Workbook)),["Events";"Recordings";"Sites";"TimeSeries";"Availability";"Definitions";"Phases"]);
t.verifyFalse(P.State().Busy);t.verifyTrue(isempty(P.State().Plan));last=P.State().Result;
qa=fullfile(out,'final-layout-xml');mkdir(qa);cq=onCleanup(@()rmdir(qa,'s'));unzip(result.Workbook,qa);
x=fileread(fullfile(qa,'xl','worksheets','sheet1.xml'));row=regexp(x,'<row[^>]*r="2"[^>]*>','match','once');
t.verifyTrue(contains(row,'customHeight="1"'));t.verifyTrue(contains(row,'ht="'));

% Failure after preview, before any writer dispatch: destination now exists.
P.SetInputs(S,{review},target('blocked.xlsx'),O);P.Preview();f=fopen(target('blocked.xlsx'),'w');fprintf(f,'sentinel');fclose(f);
t.verifyError(@()P.Export(),'OxygenDynamics:CompactDestination');t.verifyFalse(P.State().Busy);t.verifyEqual(P.State().Result,last);
t.verifyEqual(fileread(target('blocked.xlsx')),'sentinel');delete(target('blocked.xlsx'));
t.verifyEqual(oxygenFileSHA256(batch),before);
P.SetInputs(S,{},target('changed.xlsx'),O);P.Preview();P.Source.Value='changed'; % direct edit checked against stored source label only via callback in UI
P.Destination.Value=target('changed-after-preview.xlsx');t.verifyError(@()P.Export(),'OxygenDynamics:CompactPlanChanged');
% Existing batch editor actually exposes the new tab. No recording input.
[editor,UI]=openBOIBatchEditor();ce=onCleanup(@()delete(editor));t.verifyTrue(isfield(UI,'CompactExport'));t.verifyEqual(UI.CompactExportTab.Title,'Compact workbook');
end
function [S,V,O]=fixture()
ids=["001";"002";"003";"004"];mouse=["M01";"M01";"M02";"M03"];
R=table(ids,["Run001";"Run002";"Run003";"Run004"],mouse,["control";"drug";"control";"control"], ...
    ["";"D1";"";""],repmat("WT",4,1),repmat("P1",4,1),false(4,1),[120;60;30;NaN], ...
    [2;1;.5;NaN],repmat(60,4,1),[200000;400000;300000;NaN],[1.25;2.5;3;NaN], ...
    ["loaded";"loaded";"loaded";"not_analyzed"], ...
    'VariableNames',{'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim','NFrames', ...
    'SampleF','RecordingDuration_sec','RecordingArea_um2','PixelSize','AnalysisStatus'});
E=table(["001";"001";"002";"002"],ones(4,1),[1;2;1;2],[10;20;10;30],[15;27;14;31], ...
    [3;4;5;2],[-2;10;12.345678901234;3],[50;60;70;80],[5;6;7;8],[.7;.6;.5;.4], ...
    [.01;-.234567890123;-.5;NaN],repmat(1200,4,1),ones(4,1),[9;19;9;29],repmat("original-optical-1",4,1), ...
    [1;0;0;0],[1;0;NaN;0],[1210;1200;1300;NaN],[NaN;4;NaN;10],[4;NaN;10;NaN], ...
    'VariableNames',{'RecordingID','SinkID','EventIndex','StartFrame','EndFrame','DurationSec','EventAmplitudePercent', ...
    'EventArea_um2','Diameter_um','MeanCircularity','SignedTraceAUC_sec','BaselineValue','BaselineStartFrame','BaselineEndFrame', ...
    'AnalysisSchemaVersion','EventReferenceShort','AboveRecordingReference','EventReferenceValue','PreviousNativeGapSec','NextNativeGapSec'});
E.EventReferenceVersion=repmat("boi-event-baseline-flags-1",4,1);E.EventReferenceStatus=["short";"available";"overlap";"missing"];
B=E;B.BurdenAmplitudePercent=E.EventAmplitudePercent;B.BurdenArea_um2=[50;60;70;NaN];B.BurdenDuration_sec=E.DurationSec;
B.PerEventBurdenContribution=[-300;2400;4320.9876154319;NaN];B.PerEventBurdenContribution_per_mm2_per_min=[-1500;12000;10802.4690385798;NaN];
B.BurdenAmplitudeNegative=[1;0;0;0];B.BurdenContributionNegative=[1;0;0;NaN];B.BurdenSelectionPolicyVersion=repmat("boi-signed-contributions-1",4,1);
BR=table(ids,[2100;NaN;0;NaN],[10500;NaN;0;NaN],[2;2;0;NaN],[2;1;0;NaN],[1;0;0;NaN], ...
    ["positive";"not_assessable";"zero";"not_assessable"],["positive";"not_assessable";"zero";"not_assessable"], ...
    'VariableNames',{'RecordingID','HypoxicBurden','HypoxicBurden_per_mm2_per_min','NumRequiredBurdenContributions','NumAvailableBurdenContributions', ...
    'NumNegativeBurdenContributions','BurdenTotalSign','NormalizedBurdenTotalSign'});
TS=table(["001";"001";"001";"002";"002";"002"],[1;2;3;1;2;3],[0;.5;1;0;1;2], ...
    [1;1;0;1;1;0],[-250;200;0;1;NaN;NaN], ...
    'VariableNames',{'RecordingID','Frame','TimeSec','ActiveHypoxicEvents','HypoxicBurdenPerMm2OverTime'});
F=table(TS.RecordingID,TS.Frame,TS.TimeSec,[10;20;0;30;40;0],[200000;200000;200000;400000;400000;400000], ...
    'VariableNames',{'RecordingID','Frame','ModeledStartSec','OccupiedArea_um2','AnalyzedArea_um2'});
G=E(3,:);G.SurgeID=1;G.SinkID=[];G.EventAmplitudePercent=[];G.NormOxySurgeAmpPercent=20;
counts=cell(4,6);for i=1:4
    counts(i,1:5)={char(R.Experiment(i)),char(R.Mouse(i)),char(R.Condition(i)),char(R.DrugID(i)),R.PuffStim(i)};
    if i<4,counts{i,6}=zeros(1,R.NFrames(i));else,counts{i,6}=[];end
end
counts{1,6}(1:3)=[2;1;0];scaled=counts;for i=1:3,scaled{i,6}=counts{i,6}*1e6/R.RecordingArea_um2(i);end
S=struct('Registry',R,'Tables',struct('OxySinkEvents',E,'OxySurgeEvents',G, ...
    'HypoxicBurden_EventBased',B,'HypoxicBurden_ByRecording',BR,'HypoxicBurden_TimeSeries',TS, ...
    'Burden_SelectionPolicy',table("boi-signed-contributions-1",'VariableNames',{'Version'}),'WindowFrameIngredients',F, ...
    'SurgeWindowFrameIngredients',F([],:),'NumOngoingOxysinks',{counts},'NumOngoingOxysinksPerMm2',{scaled},'NumOngoingOxysurges',{counts}));
O=struct('Metadata',table(ids,["Visit01";"Visit01";"Visit02";"Visit03"],["F01";"F02";"F01";""],["";"001";"";""], ...
    'VariableNames',{'RecordingID','SessionID','FieldOfViewID','ControlRecordingID'}));
Q=struct('EventTable',B(2:4,:),'RecordingTable',BR(1:3,:),'TimeSeriesTable',TS,'SelectionPolicy',S.Tables.Burden_SelectionPolicy);
Q.EventTable.BurdenAmplitudePercent(1)=11;Q.EventTable.BurdenArea_um2(1)=65;
Q.EventTable.PerEventBurdenContribution(1)=2860;Q.EventTable.PerEventBurdenContribution_per_mm2_per_min(1)=14300;
Q.RecordingTable.HypoxicBurden(1)=2860;Q.RecordingTable.HypoxicBurden_per_mm2_per_min(1)=14300;
Q.RecordingTable.NumRequiredBurdenContributions(1)=1;Q.RecordingTable.NumAvailableBurdenContributions(1)=1;Q.RecordingTable.NumNegativeBurdenContributions(1)=0;
Q.TimeSeriesTable.HypoxicBurdenPerMm2OverTime(1)=0;
Q.ReviewDecisions=E(:,{'RecordingID','SinkID','EventIndex'});Q.ReviewDecisions.RecognitionStatus=["not_recognized";"recognized";"not_reviewed";"not_reviewed"];
Q.ReviewDecisions.Reason=["constructed exclusion";"constructed revised measurement";"";""];Q.ReviewDecisions.ExcludedFromReviewedBurden=[1;0;0;0];
Q.ExcludedDetections=B(1,:);Q.ReviewSummary=table(ids(1:3),[1;0;0],[1;2;0],'VariableNames',{'RecordingID','RejectedDetections','RetainedDetections'});
L=loadBOICompactWorkbookSources(S,{},struct());
V=struct('HypoxicBurden',Q,'Receipt',struct('Status','complete','SourceStatsSHA256',L.AutomaticSHA256));
end
function p=evidence(),p=getenv('BOI_CEX_EVIDENCE_DIR');assert(~isempty(p));end
function p=target(name),p=fullfile(evidence(),name);end
function countWrite()
p=fullfile(evidence(),'scope.json');s=jsondecode(fileread(p));assert(s.Counters.XLSXAttempts<s.ProposedLimits.NamedWorkbookExportAttempts,'Four writer attempts exhausted.');
s.Counters.XLSXAttempts=s.Counters.XLSXAttempts+1;writeBOIRunJSON(p,s);
end
