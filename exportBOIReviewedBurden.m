function Receipt=exportBOIReviewedBurden(StatsMAT,ReviewPaths,OutputFolder,ReviewedEventFolders)
% Export a separate burden workbook using saved recognition judgments.
% The source combined results and automatic burden are never overwritten.
setupOxygenDynamicsPath;
if nargin<4,ReviewedEventFolders={};end
if ischar(ReviewedEventFolders)||isstring(ReviewedEventFolders),ReviewedEventFolders=cellstr(ReviewedEventFolders);end
StatsMAT=char(java.io.File(StatsMAT).getCanonicalPath());
OutputFolder=char(java.io.File(OutputFolder).getCanonicalPath());
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
assert(strcmp(before,oxygenFileSHA256(StatsMAT)),'OxygenDynamics:ReviewedBurdenSource','Source results changed while preparing this export.');
[ok,~,id]=mkdir(OutputFolder);assert(ok&&isempty(id),'OxygenDynamics:ReviewOutputExists','New export directory could not be claimed.');
status=struct('Status','writing','SourceStatsMAT',StatsMAT,'SourceStatsSHA256',before,'ReviewSources',sources, ...
    'AutomaticResultsChanged',false,'DetectorReruns',0,'CorrectionReruns',0,'StatisticsReruns',0);
writeBOIRunJSON(fullfile(OutputFolder,'ReviewedBurdenStatus.json'),status);
try
    workbook=fullfile(OutputFolder,'ReviewedHypoxicBurden.xlsx');
    writeHypoxicBurdenWorkbookSheets(workbook,HypoxicBurden);
    for f={'ReviewSummary','ReviewDecisions','ExcludedDetections'}
        writetable(HypoxicBurden.(f{1}),workbook,'Sheet',f{1});
        writetable(HypoxicBurden.(f{1}),fullfile(OutputFolder,[f{1} '.csv']));
    end
    if isfield(HypoxicBurden,'EventRevisions')
        writetable(HypoxicBurden.EventRevisions,workbook,'Sheet','EventRevisions');
        writetable(HypoxicBurden.EventRevisions,fullfile(OutputFolder,'EventRevisions.csv'));
    end
    writetable(HypoxicBurden.EventTable,fullfile(OutputFolder,'HypoxicBurden_EventBased.csv'));
    writetable(HypoxicBurden.RecordingTable,fullfile(OutputFolder,'HypoxicBurden_ByRecording.csv'));
    writetable(HypoxicBurden.TimeSeriesTable,fullfile(OutputFolder,'HypoxicBurden_TimeSeries.csv'));
    Receipt=status;Receipt.Status='complete';Receipt.Workbook=workbook;
    Receipt.Policy=HypoxicBurden.ReviewPolicy;
    Receipt.AutomaticDetections=height(S.HypoxicBurden.EventTable);Receipt.RetainedDetections=height(HypoxicBurden.EventTable);
    Receipt.RejectedDetections=height(HypoxicBurden.ExcludedDetections);
    Receipt.ImportedReviewedEvents=numel(Events);
    Receipt.CreatedUTC=char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ss'Z'"));
    Receipt.ImplementationSHA256=oxygenFileSHA256(which('createBOIReviewedBurdenMetrics'));
    save(fullfile(OutputFolder,'ReviewedHypoxicBurden.mat'),'HypoxicBurden','Receipt','-v7.3');
    folder=fullfile(OutputFolder,'SavedReviews');mkdir(folder);
    for k=1:numel(Reviews)
        copyfile(Reviews{k}.BoundaryReview.Path,fullfile(folder,sprintf('Review-%02d.json',k)));
    end
    if ~isempty(Events)
        folder=fullfile(OutputFolder,'SavedReviewedEvents');mkdir(folder);
        for k=1:numel(Events)
            checked=loadBOIReviewedBurdenEvent(Events{k}.Path);
            assert(strcmp(checked.ManifestSHA256,Events{k}.ManifestSHA256),'OxygenDynamics:ReviewedBurdenEvent','Reviewed event changed during export.');
            target=fullfile(folder,sprintf('Event-%02d',k));copyfile(Events{k}.Path,target);
            copied=loadBOIReviewedBurdenEvent(target);assert(strcmp(copied.ManifestSHA256,checked.ManifestSHA256));
        end
    end
    fid=fopen(fullfile(OutputFolder,'README.txt'),'w');assert(fid>=0);c=onCleanup(@()fclose(fid));
    fprintf(fid,['Reviewed burden tables from the saved combined export. Existing formula, normalization and baseline policy are preserved.\n' ...
        'Only SAVED not_recognized sink detections are excluded. ReviewDecisions retains original row identities, reviewer, reason and revision checksum.\n' ...
        'Unreviewed and uncertain detections retain their automatic ingredients; this is not a fully adjudicated pocket set.\n' ...
        'HypoxicBurden_EventBased and all recording/group/time-series calculations use the retained set. ExcludedDetections preserves rejected automatic rows.\n' ...
        'Missing required retained contributions keep strict totals unavailable. Blank numeric CSV/Excel cells and MAT NaN mean unavailable, not zero. No partial sums.\n' ...
        'Burden-only export: unrelated sheets and large site/trace matrices remain in the original combined workbook/MAT bundle.\n' ...
        'Source statistics and automatic outputs are unchanged. SavedReviews contains portable revision snapshots for matching original audits.\n']);
    if ~isempty(Events)
        fprintf(fid,['EventRevisions lists explicitly imported, already approved single-event results. SavedReviewedEvents retains their exact artifacts.\n' ...
            'Version 2 event artifacts use source-bound reviewed frame-area revisions. Incomplete, uncertain or spatially mismatched area withholds the event contribution and strict recording totals; old automatic burden is not substituted.\n' ...
            'AutomaticBurdenArea_um2, when present, preserves the prior area. ReviewedAreaStatus and ReviewedAreaMeanFrames describe the explicitly supplied area revision.\n' ...
            'BurdenStartFrame/BurdenEndFrame/BurdenDuration_sec govern burden and its time series. Original automatic StartFrame/EndFrame/DurationSec and Episode* columns remain source evidence.\n' ...
            'The automatic episode-reference policy/default is unchanged. Imported manual reference selections apply only to their named events.\n' ...
            'ReviewSummary available/missing counts include the imported values. Episode-reference counts describe automatic evidence separately.\n']);
    end
    clear c;
    writeBOIRunJSON(fullfile(OutputFolder,'ReviewedBurdenStatus.json'),Receipt);
catch err
    status.Status='failed';status.ErrorID=err.identifier;status.ErrorMessage=err.message;
    writeBOIRunJSON(fullfile(OutputFolder,'ReviewedBurdenStatus.json'),status);rethrow(err);
end
end
