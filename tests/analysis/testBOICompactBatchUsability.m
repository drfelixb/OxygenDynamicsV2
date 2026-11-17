function tests=testBOICompactBatchUsability
tests=functiontests(localfunctions);
end
function setupOnce(~),setupOxygenDynamicsPath;end
function testCompactLayoutAndOpenedSource(t)
[S,O]=fixture();
root=char(java.io.File(tempname()).getCanonicalPath());
mkdir(root);files=onCleanup(@()rmdir(root,'s')); %#ok<NASGU>
fig=uifigure('Visible','off');figureCleanup=onCleanup(@()delete(fig)); %#ok<NASGU>
Host=struct('AssertIdle',@()[],'Begin',@(~)[],'End',@()[],'AutomaticSource',@()S, ...
    'BatchContext',@()struct('FilePath','','Metadata',table()));
P=createBOICompactExportPanel(uitab(uitabgroup(fig)),Host);
previewButton=P.PreviewButton;
exportButton=P.ExportButton;
t.verifyEqual(P.ActionButton,previewButton);
t.verifyNotEqual(previewButton,exportButton);
t.verifyEqual(string(previewButton.Text),"Preview compact workbook");
t.verifyEqual(string(exportButton.Text),"Export compact workbook");
t.verifyEqual(string(previewButton.Enable),"off");
t.verifyEqual(string(exportButton.Enable),"off");
t.verifyFalse(P.OptionalButton.Value);
t.verifyEqual(string(P.OptionalSettings.Visible),"off");
t.verifyEqual(string(P.Details.Visible),"off");

automatic=fullfile(root,'Automatic.xlsx');
writelines("source fixture",automatic);
P.OfferOpenedSource(automatic);
t.verifyEqual(P.State().Source,automatic);
t.verifyEqual(P.Destination.Value,fullfile(root,'Automatic_compact.xlsx'));
t.verifyEmpty(P.State().Plan);
t.verifyEmpty(P.Reviews.Items);
t.verifyEqual(string(previewButton.Enable),"on");
t.verifyEqual(string(exportButton.Enable),"off");
t.verifyFalse(isfile(P.Destination.Value));

other=fullfile(root,'Other.xlsx');
existing=fullfile(root,'Other_compact.xlsx');
writelines("other source",other);
writelines("existing compact workbook",existing);
P.OfferOpenedSource(other);
t.verifyNotEqual(P.Destination.Value,existing);
t.verifyEqual(fileparts(P.Destination.Value),root);
t.verifyFalse(isfile(P.Destination.Value));
t.verifyEqual(strtrim(string(fileread(existing))),"existing compact workbook");

P.OptionalButton.Value=true;
toggle=P.OptionalButton.ValueChangedFcn;toggle(P.OptionalButton,[]);
t.verifyEqual(string(P.OptionalSettings.Visible),"on");
t.verifyEqual(string(P.Source.Visible),"on");
t.verifyEqual(string(P.Destination.Visible),"on");
t.verifyEqual(string(previewButton.Visible),"on");
t.verifyEqual(string(exportButton.Visible),"on");
P.OptionalButton.Value=false;toggle(P.OptionalButton,[]);
t.verifyEqual(string(P.OptionalSettings.Visible),"off");

output=fullfile(root,'Compact_test.xlsx');
P.SetInputs(S,{},output,O);
P.OfferOpenedSource(automatic);
t.verifyEqual(P.State().Source,S);
t.verifyEqual(P.Destination.Value,output);
previewClick=previewButton.ButtonPushedFcn;previewClick(previewButton,[]);
t.verifyEqual(P.PreviewButton,previewButton);
t.verifyEqual(P.ExportButton,exportButton);
t.verifyEqual(string(previewButton.Text),"Preview compact workbook");
t.verifyEqual(string(exportButton.Text),"Export compact workbook");
t.verifyEqual(string(exportButton.Enable),"on");
t.verifyEqual(string(P.Details.Visible),"on");
t.verifyTrue(any(contains(string(P.Details.Value),"4 recordings")));
t.verifyNotEmpty(P.State().Plan);
t.verifyFalse(isfile(output));

P.Destination.Value=fullfile(root,'Changed.xlsx');
destinationChanged=P.Destination.ValueChangedFcn;destinationChanged(P.Destination,[]);
t.verifyEmpty(P.State().Plan);
t.verifyEqual(string(exportButton.Enable),"off");
P.Destination.Value=output;destinationChanged(P.Destination,[]);
previewClick(previewButton,[]);
exportClick=exportButton.ButtonPushedFcn;exportClick(exportButton,[]);
completed=P.State().Result;
t.verifyEqual(completed.Status,'complete');
t.verifyTrue(isfile(output));
t.verifyEqual(string(exportButton.Enable),"off");
t.verifyEqual(string(P.OpenButton.Enable),"on");

P.SetInputs(fullfile(root,'missing-automatic.mat'),{},fullfile(root,'Unwritten.xlsx'),O);
t.verifyError(@()P.Preview(),'OxygenDynamics:CompactSource');
t.verifyEqual(P.State().Result,completed);
t.verifyEmpty(P.State().Plan);
t.verifyEqual(string(exportButton.Enable),"off");
t.verifyEqual(string(P.OpenButton.Enable),"on");
t.verifyTrue(isfile(output));
end
function testLocalStagingAndDestinationCollision(t)
[S,O]=fixture();
root=char(java.io.File(tempname()).getCanonicalPath());mkdir(root);
cleanup=onCleanup(@()rmdir(root,'s')); %#ok<NASGU>
destination=fullfile(root,'compact workbook.xlsx');
plan=prepareBOICompactWorkbook(S,{},destination,O);
receipt=exportBOICompactWorkbook(S,{},destination,O,plan,@verifyEmptyDestination);
receiptPath=[destination '.receipt.json'];
stored=jsondecode(fileread(receiptPath));
hash=oxygenFileSHA256(destination);
t.verifyEqual(receipt.Status,'complete');
t.verifyEqual(receipt.WorkbookSHA256,hash);
t.verifyEqual(stored.WorkbookSHA256,hash);

collision=fullfile(root,'existing workbook.xlsx');sentinelHash='';
plan=prepareBOICompactWorkbook(S,{},collision,O);
t.verifyError(@()exportBOICompactWorkbook(S,{},collision,O,plan, ...
    @createCollision),'OxygenDynamics:CompactDestination');
t.verifyEqual(oxygenFileSHA256(collision),sentinelHash);
t.verifyFalse(isfile([collision '.receipt.json']));

removedParent=fullfile(root,'removed destination');mkdir(removedParent);
missing=fullfile(removedParent,'compact.xlsx');
plan=prepareBOICompactWorkbook(S,{},missing,O);
t.verifyError(@()exportBOICompactWorkbook(S,{},missing,O,plan, ...
    @()rmdir(removedParent)),'OxygenDynamics:CompactPublish');
t.verifyFalse(isfolder(removedParent));
listing=dir(root);names=string({listing.name});
t.verifyEqual(sort(names(~ismember(names,[".",".."]))), ...
    ["compact workbook.xlsx","compact workbook.xlsx.receipt.json","existing workbook.xlsx"]);

    function verifyEmptyDestination()
        listing=dir(root);names=string({listing.name});
        t.assertEmpty(names(~ismember(names,[".",".."])));
    end
    function createCollision()
        writelines("existing workbook",collision);
        sentinelHash=oxygenFileSHA256(collision);
    end
end
function testBulkFormattingAndReadback(t)
[S,O]=fixture();S.Registry=S.Registry(1,:);R=S.Registry;
R.NFrames=20000;R.SampleF=2;R.RecordingDuration_sec=10000;S.Registry=R;
S.Tables.OxySinkEvents=S.Tables.OxySinkEvents(1:2,:);S.Tables.OxySurgeEvents=S.Tables.OxySurgeEvents([],:);
B=S.Tables.HypoxicBurden_EventBased(1:2,:);B.PerEventBurdenContribution_per_mm2_per_min=[-9;72];S.Tables.HypoxicBurden_EventBased=B;
BR=S.Tables.HypoxicBurden_ByRecording(1,:);BR.HypoxicBurden_per_mm2_per_min=63;S.Tables.HypoxicBurden_ByRecording=BR;
frame=(1:20000)';time=(frame-1)/2;active=zeros(20000,1);active(10:15)=1;active(20:27)=1;
curve=zeros(20000,1);curve(10:15)=-500;curve(20:27)=3000;
S.Tables.HypoxicBurden_TimeSeries=table(repmat("001",20000,1),frame,time,active,curve, ...
    'VariableNames',{'RecordingID','Frame','TimeSec','ActiveHypoxicEvents','HypoxicBurdenPerMm2OverTime'});
area=zeros(20000,1);area(10:15)=50;area(20:27)=60;
S.Tables.WindowFrameIngredients=table(repmat("001",20000,1),frame,time,area,repmat(200000,20000,1), ...
    'VariableNames',{'RecordingID','Frame','ModeledStartSec','OccupiedArea_um2','AnalyzedArea_um2'});
S.Tables.SurgeWindowFrameIngredients=S.Tables.WindowFrameIngredients([],:);
counts={char(R.Experiment),char(R.Mouse),char(R.Condition),char(R.DrugID),R.PuffStim,active'};
scaled=counts;scaled{6}=active'*5;S.Tables.NumOngoingOxysinks=counts;S.Tables.NumOngoingOxysinksPerMm2=scaled;S.Tables.NumOngoingOxysurges=counts;
O.Metadata=O.Metadata(1,:);fig=uifigure('Visible','off');c=onCleanup(@()delete(fig)); %#ok<NASGU>
Host=struct('AssertIdle',@()[],'Begin',@(~)[],'End',@()[],'AutomaticSource',@()S,'BatchContext',@()struct('FilePath','','Metadata',table()));
P=createBOICompactExportPanel(uitab(uitabgroup(fig)),Host);
root=tempname;mkdir(root);files=onCleanup(@()rmdir(root,'s')); %#ok<NASGU>
P.SetInputs(S,{},fullfile(root,'Bulk workbook.xlsx'),O);plan=P.Preview();
t.verifyEqual(plan.Counts.Events,2);t.verifyEqual(plan.Counts.TimeSeries,20000);t.verifyLessThan(plan.Counts.Availability,1000);
receipt=P.Export();
t.verifyEqual(receipt.Status,'complete');t.verifyEqual(P.State().Result,receipt);t.verifyFalse(P.State().Busy);t.verifyEmpty(P.State().Plan);
t.verifyEqual(numel(sheetnames(receipt.Workbook)),6);
% Native export already compares every cell/type to the prepared tables.
x=zipText(receipt.Workbook,'xl/worksheets/sheet4.xml');
t.verifyTrue(contains(x,'topLeftCell="F2"'));t.verifyTrue(contains(x,'<autoFilter ref="A1:'));
t.verifyTrue(contains(regexp(x,'<row[^>]*r="20001"[^>]*>','match','once'),'customHeight="1"'));
t.verifyEmpty(regexp(x,'<f(?:\s|>)','once'));
a=readtable(receipt.Workbook,'Sheet','Availability','TextType','string');
[~,prepared]=prepareBOICompactWorkbook(S,{},fullfile(root,'never-written.xlsx'),O);
t.verifyEqual(sum(a.NumRows),numericInventory(prepared.Data));
e=readtable(receipt.Workbook,'Sheet','Events','TextType','string');t.verifyEqual(e.AutomaticContribution,[-300;2400]);
t.verifyEqual(e.AutomaticContribution_per_mm2_per_min,[-9;72]);
end
function n=numericInventory(D)
n=0;for sn={'Events','Recordings','Sites','TimeSeries','Phases'}
T=D.(sn{1});for f=string(T.Properties.VariableNames),if isnumeric(T.(f))||islogical(T.(f)),n=n+height(T);end,end
end
end
function s=zipText(path,name)
z=java.util.zip.ZipFile(path);c=onCleanup(@()z.close());stream=z.getInputStream(z.getEntry(name));cs=onCleanup(@()stream.close()); %#ok<NASGU>
b=stream.readAllBytes();s=native2unicode(typecast(b(:)','uint8'),'UTF-8');
end
function [S,O]=fixture()
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
end
