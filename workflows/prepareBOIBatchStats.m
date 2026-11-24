function [Plan,CheckedBatch]=prepareBOIBatchStats(Batch,OutputParent,RowIDs,ProgressFcn)
%PREPAREBOIBATCHSTATS Review exact completed runs for the existing stats exporter.
% No output is created. Saved run labels are used; stimulation stays metadata.
setupOxygenDynamicsPath;
if nargin<3||isempty(RowIDs),RowIDs=Batch.Rows.BatchRowID;end
if nargin<4,ProgressFcn=[];end
assert(isfield(Batch,'FilePath')&&isfile(Batch.FilePath)&& ...
    strcmp(oxygenFileSHA256(Batch.FilePath),Batch.FileSHA256), ...
    'OxygenDynamics:BatchStatsCSVChanged','Open an unchanged saved batch CSV before reviewing combined export.');
[Rows,~]=resolveBOIBatch(Batch);
ids=string(RowIDs);ids=ids(:);
assert(~any(ismissing(ids))&&all(strlength(strtrim(ids))>0)&& ...
    numel(unique(ids))==numel(ids)&&all(ismember(ids,Rows.BatchRowID)), ...
    'OxygenDynamics:BatchStatsSelection','Select existing unique batch row identities.');
assert((ischar(OutputParent)||isstring(OutputParent))&&isscalar(string(OutputParent))&& ...
    ~ismissing(string(OutputParent))&&strlength(strtrim(string(OutputParent)))>0, ...
    'OxygenDynamics:BatchStatsOutputParent','Choose an existing parent folder for the combined export.');
parent=canonical(OutputParent);
assert(isfolder(parent),'OxygenDynamics:BatchStatsOutputParent','Choose an existing parent folder for the combined export.');
for i=1:height(Rows)
    for path=[Rows.Paths(i),Rows.RunFolder(i)]
        if strlength(strtrim(path))==0,continue;end
        source=canonical(path);
        assert(~strcmp(parent,source)&&~startsWith(parent,[source filesep]), ...
            'OxygenDynamics:BatchStatsOutputInsideSource','Choose a parent outside all recording and saved-run folders.');
    end
end
selected=ismember(Rows.BatchRowID,ids);
candidates=selected&strlength(strtrim(Rows.RunFolder))>0;
assert(any(candidates),'OxygenDynamics:BatchStatsEmpty','No selected recording has a linked completed run.');
[CheckedBatch,report]=checkBOIBatch(Batch,Rows.BatchRowID(candidates),ProgressFcn);
ready=candidates&report.InputStatus=="Ready"&report.AnalysisStatus=="Complete"&report.ResultCheck=="Matches";
assert(any(ready),'OxygenDynamics:BatchStatsEmpty','No selected saved run passed source/settings/artifact verification. Check the recording details.');
inputRows=table();included=table();sources=struct('RecordingID',{},'RecordingFolder',{},'SinkMaster',{},'SurgeMaster',{});
for i=reshape(find(ready),1,[])
    run=loadBOIRecordingRun(CheckedBatch.Rows.RunFolder(i));o=run.Request.Options;
    info=loadRequiredMatVar(run.Paths.SinkMaster,'AnalysisInfo');
    assert(isfield(info,'RecordingID')&&strlength(string(info.RecordingID))>0, ...
        'OxygenDynamics:BatchStatsRecordingID','Saved master has no stable recording identity.');
    rec=canonical(fileparts(fileparts(run.Paths.SinkMaster)));
    % Native runs store masters in a subfolder of their staged Recording.
    assert(strcmp(rec,canonical(fullfile(run.Directory,'Recording'))), ...
        'OxygenDynamics:BatchStatsRecordingPath','Indexed sink master is not inside this run''s staged Recording folder.');
    exact=struct('RecordingID',char(string(info.RecordingID)),'RecordingFolder',rec, ...
        'SinkMaster',run.Paths.SinkMaster,'SurgeMaster',run.Paths.SurgeMaster);
    createStatsRecordingSourceInfo(rec,'','No','Recent','Recent','Recent',exact);
    sources(end+1)=exact; %#ok<AGROW>
    Paths=string(rec);PostureFile=NaN;PupilFile=NaN;PuffsFile=NaN;WhiskingFile=NaN;
    Mouse=string(o.Mouse);Genotype=string(o.Genotype);Condition=string(o.Condition);
    DrugID=string(o.DrugID);Promoter=string(o.Promoter);SampleF=o.SampleHz;Pixelsize=o.PixelSizeUm;Puff_2use=NaN;
    RecordingID=string(info.RecordingID);
    row=table(Paths,PostureFile,PupilFile,PuffsFile,WhiskingFile,Mouse,Genotype,Condition,DrugID,Promoter,SampleF,Pixelsize,Puff_2use,RecordingID);
    inputRows=[inputRows;row]; %#ok<AGROW>
    entry=table(Rows.BatchRowID(i),Mouse,Condition,string(run.Directory),RecordingID, ...
        string(run.Paths.SinkMaster),string(run.Paths.SurgeMaster),report.MetadataStatus(i), ...
        'VariableNames',{'BatchRowID','Mouse','Condition','RunFolder','RecordingID','SinkMaster','SurgeMaster','MetadataStatus'});
    included=[included;entry]; %#ok<AGROW>
end
assert(numel(unique(included.RecordingID))==height(included)&& ...
    numel(unique(included.RunFolder))==height(included), ...
    'OxygenDynamics:BatchStatsDuplicateRun','Two selected rows resolve to the same recording or saved run.');
excluded=Rows(~ready,{'BatchRowID','Mouse','Paths','RunFolder'});reason=strings(height(Rows),1);
reason(~selected)="Not selected for combined export.";
reason(selected&~candidates)="No linked completed run; held or not analyzed.";
reason(candidates&~ready)=report.Message(candidates&~ready);
excluded.Reason=reason(~ready);
[~,csvName,extension]=fileparts(Batch.FilePath);
output=fullfile(parent,['BOIBatchStats_' char(java.util.UUID.randomUUID())]);
Plan=struct('Schema','boi-batch-stats-plan-1','OutputParent',parent,'OutputFolder',output, ...
    'InputCSVName',[csvName extension],'BatchFile',Batch.FilePath,'BatchFileSHA256',Batch.FileSHA256, ...
    'BatchDigest',boiBatchQueueDigest(CheckedBatch),'Included',included,'Excluded',excluded, ...
    'InputRows',inputRows,'SavedSources',sources,'Report',report,'SelectedRowIDs',ids, ...
    'SourceRows',Rows,'Counts',struct('Included',height(included),'Excluded',height(excluded)));
Plan.Digest=boiBatchQueueDigest(Plan);
end
function path=canonical(path)
path=char(java.io.File(char(path)).getCanonicalPath());
end
