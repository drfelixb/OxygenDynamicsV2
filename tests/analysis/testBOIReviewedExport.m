function tests=testBOIReviewedExport
tests=functiontests(localfunctions);
end
function setupOnce(~),setupOxygenDynamicsPath;end
function testPreviewIsReadOnlyAndStatesStrictMissingness(t)
F=makeBOIReviewedExportFixture(tempname);c=onCleanup(@()rmdir(F.Root,'s'));before=treeHashes(F.Root);
p=prepareBOIReviewedBurdenExport(F.StatsMAT,F.ReviewPaths,F.OutputFolder);
verifyEqual(t,treeHashes(F.Root),before);verifyFalse(t,isfolder(F.OutputFolder));
verifyEqual(t,p.Counts.RejectedDetections,1);verifyEqual(t,p.Counts.RetainedDetections,1);
verifyEqual(t,p.Counts.MissingContributions,1);verifyEqual(t,p.Counts.AvailableNormalizedRecordings,0);
verifyEqual(t,p.Decisions.RecognitionStatus,"not_recognized");verifyEqual(t,p.Decisions.SinkID,1);
verifyEqual(t,p.Digest,boiBatchQueueDigest(rmfield(p,'Digest')));
end
function testConfirmedExportKeepsFormatsValuesAndOriginals(t)
F=makeBOIReviewedExportFixture(tempname,'complete');c=onCleanup(@()rmdir(F.Root,'s'));before=treeHashes(F.Root);
capture=getenv('BOI_R31_EVIDENCE_DIR');signedRun=~isempty(capture);
expected=120;
if signedRun
    S=load(F.StatsMAT);E=S.HypoxicBurden.EventTable;
    E.NormOxySinkAmpPercent(2)=-20;
    S.HypoxicBurden=createHypoxicBurdenMetrics(E,table(),table(),S.RecordingRegistry,boiBurdenSelectionPolicy());
    save(F.StatsMAT,'-struct','S');before=treeHashes(F.Root);expected=-120;
end
p=prepareBOIReviewedBurdenExport(F.StatsMAT,F.ReviewPaths,F.OutputFolder);
r=exportBOIReviewedBurden(p.StatsMAT,p.ReviewPaths,p.OutputFolder,p.ReviewedEventFolders,p);
verifyEqual(t,r.Status,'complete');verifyEqual(t,r.RejectedDetections,1);
S=load(fullfile(F.OutputFolder,'ReviewedHypoxicBurden.mat'),'HypoxicBurden');B=S.HypoxicBurden;
verifyEqual(t,B.EventTable.PerEventBurdenContribution,expected);verifyEqual(t,B.RecordingTable.HypoxicBurden,expected);
verifyEqual(t,B.RecordingTable.HypoxicBurden_per_mm2_per_min,expected*6000);
X=readtable(r.Workbook,'Sheet','HypoxicBurden_ByRecording');verifyEqual(t,X.HypoxicBurden_per_mm2_per_min,expected*6000);
verifyTrue(t,isfile(fullfile(F.OutputFolder,'ReviewDecisions.csv')));verifyTrue(t,isfile(fullfile(F.OutputFolder,'ExcludedDetections.csv')));
verifyEqual(t,originalHashes(F.Root,before),before);
if signedRun
    copyfile(F.OutputFolder,fullfile(capture,'signed-export'));
    copyfile(F.StatsMAT,fullfile(capture,'synthetic-automatic-source.mat'));
    writeBOIRunJSON(fullfile(capture,'signed-export-source.json'),struct('SHA256',oxygenFileSHA256(F.StatsMAT)));
end
verifyError(t,@()exportBOIReviewedBurden(p.StatsMAT,p.ReviewPaths,p.OutputFolder,{},p),'OxygenDynamics:ReviewOutputExists');
end
function testChangedSourceAndTamperedPlanNeverWrite(t)
F=makeBOIReviewedExportFixture(tempname);c=onCleanup(@()rmdir(F.Root,'s'));
p=prepareBOIReviewedBurdenExport(F.StatsMAT,F.ReviewPaths,F.OutputFolder);
bad=p;bad.Counts.RejectedDetections=0;
verifyError(t,@()exportBOIReviewedBurden(p.StatsMAT,p.ReviewPaths,p.OutputFolder,{},bad),'OxygenDynamics:ReviewedExportPlanChanged');
S=load(F.StatsMAT);S.StatsInfo.Note='changed';save(F.StatsMAT,'-struct','S');
verifyError(t,@()exportBOIReviewedBurden(p.StatsMAT,p.ReviewPaths,p.OutputFolder,{},p),'OxygenDynamics:ReviewedExportPlanChanged');
verifyFalse(t,isfolder(F.OutputFolder));
end
function testChangedReviewAndReceiptNeverWrite(t)
F=makeBOIReviewedExportFixture(tempname);c=onCleanup(@()rmdir(F.Root,'s'));
p=prepareBOIReviewedBurdenExport(F.StatsMAT,F.ReviewPaths,F.OutputFolder);path=F.ReviewPaths{1};
f=fopen(path,'a');fprintf(f,'\n');fclose(f);
verifyError(t,@()exportBOIReviewedBurden(p.StatsMAT,p.ReviewPaths,p.OutputFolder,{},p),'OxygenDynamics:ReviewedExportPlanChanged');
% New preview accepts a semantically identical revision, but pins the new bytes.
p=prepareBOIReviewedBurdenExport(F.StatsMAT,F.ReviewPaths,F.OutputFolder);
path=fullfile(F.Root,'AuditCreationReceipt.json');f=fopen(path,'a');fprintf(f,'\n');fclose(f);
verifyError(t,@()exportBOIReviewedBurden(p.StatsMAT,p.ReviewPaths,p.OutputFolder,{},p),'OxygenDynamics:ReviewedExportPlanChanged');
verifyFalse(t,isfolder(F.OutputFolder));
end
function testDraftDuplicateWrongSourceAndOutputCollisionAreBlocked(t)
F=makeBOIReviewedExportFixture(tempname);c=onCleanup(@()rmdir(F.Root,'s'));
verifyError(t,@()prepareBOIReviewedBurdenExport(F.StatsMAT,{},F.OutputFolder),'OxygenDynamics:SavedReviewRequired');
verifyError(t,@()prepareBOIReviewedBurdenExport(F.StatsMAT,[F.ReviewPaths F.ReviewPaths],F.OutputFolder),'OxygenDynamics:ReviewedBurdenIdentity');
S=load(F.StatsMAT);S.StatsInfo.Recordings.SinksMatFile='different-master';save(F.StatsMAT,'-struct','S');
verifyError(t,@()prepareBOIReviewedBurdenExport(F.StatsMAT,F.ReviewPaths,F.OutputFolder),'OxygenDynamics:ReviewedBurdenSource');
verifyFalse(t,isfolder(F.OutputFolder));
end
function testLegacyAndCompleteAreaArtifactsUseExistingCalculation(t)
for mode={'legacy','area-complete'}
    F=makeBOIReviewedExportFixture(tempname,mode{1});c=onCleanup(@()rmdir(F.Root,'s'));
    p=prepareBOIReviewedBurdenExport(F.StatsMAT,F.ReviewPaths,F.OutputFolder,F.EventFolders);
    verifyEqual(t,p.Counts.ReviewedEventValues,1);verifyEqual(t,p.Counts.AvailableNormalizedRecordings,1);
    m=p.EventSources.Measurement;verifyEqual(t,[m.StartFrame m.EndFrame m.ReferenceStartFrame m.ReferenceEndFrame],[18 22 12 17]);
    r=exportBOIReviewedBurden(p.StatsMAT,p.ReviewPaths,p.OutputFolder,p.ReviewedEventFolders,p);
    X=readtable(r.Workbook,'Sheet','HypoxicBurden_EventBased');verifyEqual(t,X.PerEventBurdenContribution,450);
    verifyEqual(t,X.PerEventBurdenContribution_per_mm2_per_min,2700000);verifyTrue(t,isfile(fullfile(F.OutputFolder,'EventRevisions.csv')));
    clear c
end
end
function testIncompleteAreaExportsUnavailableWithoutPartialSum(t)
F=makeBOIReviewedExportFixture(tempname,'area-incomplete');c=onCleanup(@()rmdir(F.Root,'s'));
p=prepareBOIReviewedBurdenExport(F.StatsMAT,F.ReviewPaths,F.OutputFolder,F.EventFolders);
verifyEqual(t,p.Counts.MissingContributions,1);verifyEqual(t,p.Counts.AvailableNormalizedRecordings,0);
r=exportBOIReviewedBurden(p.StatsMAT,p.ReviewPaths,p.OutputFolder,p.ReviewedEventFolders,p);
X=readtable(r.Workbook,'Sheet','HypoxicBurden_ByRecording');verifyTrue(t,isnan(X.HypoxicBurden_per_mm2_per_min));
S=load(fullfile(F.OutputFolder,'ReviewedHypoxicBurden.mat'),'HypoxicBurden');verifyTrue(t,isnan(S.HypoxicBurden.EventTable.BurdenArea_um2));
verifyEqual(t,S.HypoxicBurden.EventTable.AutomaticBurdenArea_um2,3);
end
function testChangedConflictingAndPreviewEventArtifactsAreBlocked(t)
F=makeBOIReviewedExportFixture(tempname,'legacy');c=onCleanup(@()rmdir(F.Root,'s'));
p=prepareBOIReviewedBurdenExport(F.StatsMAT,F.ReviewPaths,F.OutputFolder,F.EventFolders);
verifyError(t,@()prepareBOIReviewedBurdenExport(F.StatsMAT,F.ReviewPaths,fullfile(F.EventFolders{1},'nested'),F.EventFolders),'OxygenDynamics:ReviewOutputExists');
verifyError(t,@()prepareBOIReviewedBurdenExport(F.StatsMAT,F.ReviewPaths,F.OutputFolder,[F.EventFolders F.EventFolders]),'OxygenDynamics:ReviewedBurdenIdentity');
verifyError(t,@()prepareBOIReviewedBurdenExport(F.StatsMAT,{fullfile(F.Root,'review-01.json')},F.OutputFolder,F.EventFolders),'OxygenDynamics:ReviewedBurdenEvent');
writeBOIRunJSON(fullfile(F.EventFolders{1},'Status.json'),struct('Status','preview'));
verifyError(t,@()exportBOIReviewedBurden(p.StatsMAT,p.ReviewPaths,p.OutputFolder,p.ReviewedEventFolders,p),'OxygenDynamics:ReviewedBurdenEvent');
verifyFalse(t,isfolder(F.OutputFolder));
end
function testGUIConfirmationInvalidationAndStrictExport(t)
F=makeBOIReviewedExportFixture(tempname);c=onCleanup(@()rmdir(F.Root,'s'));
[fig,ui]=openBOIBatchEditor();closeFig=onCleanup(@()delete(fig));b=ui.GetBatch();P=ui.ReviewedExport;
verifyError(t,@()P.Export(),'OxygenDynamics:ReviewedExportNotConfirmed');
P.SetInputs(F.StatsMAT,F.ReviewPaths,{},F.OutputFolder);p=P.Preview();verifyFalse(t,ui.State().Busy);verifyEmpty(t,ui.CheckDialog());
verifyEqual(t,p.Counts.MissingContributions,1);verifyEqual(t,string(P.RunButton.Enable),"off");
verifyTrue(t,contains(strjoin(string(P.Details.Value)),"not_recognized"));
P.Confirm(true);P.Destination.Value=fullfile(F.Root,'changed destination');
verifyError(t,@()P.Export(),'OxygenDynamics:ReviewedExportPlanChanged');verifyFalse(t,isfolder(F.OutputFolder));
P.SetInputs(F.StatsMAT,F.ReviewPaths,{},F.OutputFolder);P.Preview();P.Confirm(true);r=P.Export();
verifyFalse(t,ui.State().Busy);verifyEmpty(t,ui.CheckDialog());verifyFalse(t,P.State().Confirmed);verifyEmpty(t,P.State().Plan);
verifyEqual(t,string(P.WorkbookButton.Enable),"on");verifyEqual(t,P.Folder.Folder(),F.OutputFolder);
verifyTrue(t,contains(P.Outcome.Text,'0 / 1'));verifyEqual(t,ui.GetBatch(),b);verifyFalse(t,ui.State().Dirty);
verifyTrue(t,isfile(r.Workbook));
end
function testGUIFailureRetainsPreviousAndRestoresControls(t)
F=makeBOIReviewedExportFixture(tempname,'complete');c=onCleanup(@()rmdir(F.Root,'s'));
[fig,ui]=openBOIBatchEditor();closeFig=onCleanup(@()delete(fig));P=ui.ReviewedExport;
P.SetInputs(F.StatsMAT,F.ReviewPaths,{},F.OutputFolder);P.Preview();P.Confirm(true);r=P.Export();
next=fullfile(F.Root,'second export');P.SetInputs(F.StatsMAT,F.ReviewPaths,{},next);P.Preview();P.Confirm(true);
f=fopen(F.ReviewPaths{1},'a');fprintf(f,'\n');fclose(f);
verifyError(t,@()P.Export(),'OxygenDynamics:ReviewedExportPlanChanged');
verifyFalse(t,isfolder(next));verifyEqual(t,P.Folder.Folder(),F.OutputFolder);verifyEqual(t,P.State().Result,r);
verifyFalse(t,ui.State().Busy);verifyFalse(t,P.State().Busy);verifyEmpty(t,ui.CheckDialog());verifyFalse(t,P.State().Confirmed);
verifyEqual(t,string(P.RunButton.Enable),"off");verifyEqual(t,string(P.WorkbookButton.Enable),"on");
P.SetInputs(F.StatsMAT,{}, {},next);verifyError(t,@()P.Preview(),'OxygenDynamics:SavedReviewRequired');
verifyEmpty(t,P.State().Plan);verifyEqual(t,P.Folder.Folder(),F.OutputFolder);verifyFalse(t,ui.State().Busy);
end
function testGUIAcceptedEventPreviewAndFreshEditor(t)
F=makeBOIReviewedExportFixture(tempname,'legacy');c=onCleanup(@()rmdir(F.Root,'s'));
[fig,ui]=openBOIBatchEditor();closeFig=onCleanup(@()delete(fig));P=ui.ReviewedExport;
P.SetInputs(F.StatsMAT,F.ReviewPaths,F.EventFolders,F.OutputFolder);P.Preview();
text=strjoin(string(P.Details.Value));verifyTrue(t,contains(text,'frames 18-22'));verifyTrue(t,contains(text,'reference 12-17'));
verifyTrue(t,contains(text,'1 / 1 complete normalized'));verifyEqual(t,P.Events.Items,F.EventFolders);
P.SetBusy(true);verifyError(t,@()P.Confirm(true),'OxygenDynamics:BatchBusy');verifyEqual(t,string(P.RunButton.Enable),"off");P.SetBusy(false);
verifyFalse(t,P.State().Confirmed);delete(fig);clear closeFig;
[fig,ui]=openBOIBatchEditor();closeFig=onCleanup(@()delete(fig));verifyEmpty(t,ui.ReviewedExport.State().Plan);verifyFalse(t,ui.ReviewedExport.State().Confirmed);
end
function H=treeHashes(root)
f=dir(fullfile(root,'**','*'));H=strings(0,2);
for k=1:numel(f)
    if f(k).isdir,continue;end
    p=fullfile(f(k).folder,f(k).name);H(end+1,:)=[string(p),string(oxygenFileSHA256(p))]; %#ok<AGROW>
end
end
function H=originalHashes(~,before)
H=before;for k=1:size(before,1),H(k,2)=string(oxygenFileSHA256(before(k,1)));end
end
