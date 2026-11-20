function [Plan,Prepared]=prepareBOIReviewedBurdenExport(StatsMAT,ReviewPaths,OutputFolder,ReviewedEventFolders)
%PREPAREBOIREVIEWEDBURDENEXPORT Preview the existing saved-review exporter.
% Read saved results/artifacts only. No directory, review or export is written.
setupOxygenDynamicsPath;
if nargin<4,ReviewedEventFolders={};end
ReviewPaths=canonicalList(ReviewPaths);ReviewedEventFolders=canonicalList(ReviewedEventFolders);
StatsMAT=char(java.io.File(char(StatsMAT)).getCanonicalPath());
OutputFolder=char(java.io.File(char(OutputFolder)).getCanonicalPath());
assert(~isfolder(OutputFolder)&&~isfile(OutputFolder),'OxygenDynamics:ReviewOutputExists','Choose a NEW reviewed export folder.');
if ischar(ReviewPaths)||isstring(ReviewPaths),ReviewPaths=cellstr(ReviewPaths);end
assert(iscell(ReviewPaths)&&~isempty(ReviewPaths),'OxygenDynamics:SavedReviewRequired','Select saved review revision files explicitly.');
before=oxygenFileSHA256(StatsMAT);S=load(StatsMAT,'HypoxicBurden','RecordingRegistry','StatsInfo');
assert(all(isfield(S,{'HypoxicBurden','RecordingRegistry','StatsInfo'})),'OxygenDynamics:ReviewedBurdenSource','Saved automatic results are incomplete.');
Reviews=cell(size(ReviewPaths));sources=struct('Path',{},'SHA256',{},'AuditPath',{},'AuditSHA256',{});
for k=1:numel(ReviewPaths)
    doc=jsondecode(fileread(ReviewPaths{k}));R=loadBOIEventReview(doc.AuditPath);
    R.BoundaryReview=loadBOIBoundaryReview(R,ReviewPaths{k});
    % Verify the saved stats source and audit belong to the same master run.
    records=S.StatsInfo.Recordings;j=find(string({records.Path})==string(R.Audit.RecordingID(1)));
    assert(isscalar(j)&&isfield(R,'AuditCreationReceipt'),'OxygenDynamics:ReviewedBurdenSource','A reviewed audit must match one saved stats recording and its master provenance.');
    receipt=R.AuditCreationReceipt;record=records(j);
    assert(strcmp(receipt.MasterPaths{1},record.SinksMatFile)&&strcmp(receipt.MasterPaths{2},record.SurgesMatFile), ...
        'OxygenDynamics:ReviewedBurdenSource','Saved audit and statistics use different master sources.');
    Reviews{k}=R;sources(k)=struct('Path',R.BoundaryReview.Path,'SHA256',R.BoundaryReview.SHA256, ...
        'AuditPath',R.AuditPath,'AuditSHA256',R.AuditSHA256);
end
Events=cell(size(ReviewedEventFolders));
for k=1:numel(Events),Events{k}=loadBOIReviewedBurdenEvent(ReviewedEventFolders{k});end
HypoxicBurden=createBOIReviewedBurdenMetrics(S.HypoxicBurden,S.RecordingRegistry,Reviews,Events);
% Parent policy is validated by the reviewed calculator; retain it in the plan.
selection=[];if isfield(HypoxicBurden,'SelectionPolicy'),selection=HypoxicBurden.SelectionPolicy;end
selection=boiBurdenSelectionPolicy(HypoxicBurden.EventTable,selection);
assert(strcmp(before,oxygenFileSHA256(StatsMAT)),'OxygenDynamics:ReviewedBurdenSource','Source results changed while preparing this export.');
for k=1:numel(ReviewedEventFolders)
    assert(~startsWith([OutputFolder filesep],[ReviewedEventFolders{k} filesep]), ...
        'OxygenDynamics:ReviewOutputExists','Choose a destination outside imported event artifacts.');
end
receiptHashes=cell(size(Reviews));
for k=1:numel(Reviews)
    receiptHashes{k}=oxygenFileSHA256(fullfile(fileparts(Reviews{k}.AuditPath),'AuditCreationReceipt.json'));
end
eventSources=struct('Path',{},'ManifestSHA256',{},'DocumentSHA256',{},'Measurement',{});
for k=1:numel(Events)
    eventSources(k)=struct('Path',Events{k}.Path,'ManifestSHA256',Events{k}.ManifestSHA256, ...
        'DocumentSHA256',boiPocketDigest(Events{k}.Document),'Measurement',Events{k}.Document);
end
D=HypoxicBurden.ReviewDecisions;D=D(D.RecognitionStatus~="not_reviewed",:);
Q=HypoxicBurden.ReviewSummary;
C=struct('Recordings',height(S.RecordingRegistry),'AutomaticDetections',height(S.HypoxicBurden.EventTable), ...
    'RetainedDetections',height(HypoxicBurden.EventTable),'RejectedDetections',height(HypoxicBurden.ExcludedDetections), ...
    'SavedRecognitionDecisions',height(D),'ReviewedEventValues',numel(Events), ...
    'AvailableContributions',sum(Q.AvailableContributions),'MissingContributions',sum(Q.MissingContributions), ...
    'AvailableNormalizedRecordings',sum(isfinite(HypoxicBurden.RecordingTable.HypoxicBurden_per_mm2_per_min)));
Plan=struct('Schema','boi-reviewed-burden-export-plan-1','StatsMAT',StatsMAT,'SourceSHA256',before, ...
    'ReviewPaths',{ReviewPaths},'ReviewedEventFolders',{ReviewedEventFolders},'OutputFolder',OutputFolder, ...
    'ReviewSources',sources,'AuditReceiptSHA256',{receiptHashes},'EventSources',eventSources, ...
    'Decisions',D,'Summary',Q,'Counts',C);
Plan.BurdenSelectionPolicy=selection;
Plan.Digest=boiBatchQueueDigest(Plan);
Prepared=struct('Source',S,'Reviews',{Reviews},'Events',{Events},'HypoxicBurden',HypoxicBurden);
end
function paths=canonicalList(paths)
if ischar(paths)||isstring(paths),paths=cellstr(paths);end
assert(iscell(paths),'OxygenDynamics:SavedReviewRequired','Choose explicit saved artifact paths.');
paths=reshape(paths,1,[]);
for k=1:numel(paths)
    assert(strlength(strtrim(string(paths{k})))>0,'OxygenDynamics:SavedReviewRequired','Artifact paths cannot be blank.');
    paths{k}=char(java.io.File(char(paths{k})).getCanonicalPath());
end
assert(numel(unique(string(paths)))==numel(paths),'OxygenDynamics:ReviewedBurdenIdentity','An artifact is selected twice. Remove duplicates.');
end
