function [Plan,CheckedBatch]=prepareBOIBatchQueue(Batch,OutputParent,SelectedRowIDs,RunAgain,ProgressFcn)
%PREPAREBOIBATCHQUEUE Review a finite sequential queue without creating output.
% A saved working CSV is required. Only explicitly selected, currently ready
% rows are runnable; verified matching completions are skipped unless RunAgain.
setupOxygenDynamicsPath;
if nargin<3,SelectedRowIDs=Batch.Rows.BatchRowID;end
if nargin<4,RunAgain=false;end
if nargin<5,ProgressFcn=[];end
assert(islogical(RunAgain)&&isscalar(RunAgain),'OxygenDynamics:InvalidBatchQueue','RunAgain must be a logical scalar.');
assert(isfield(Batch,'FilePath')&&strlength(string(Batch.FilePath))>0&& ...
    isfield(Batch,'FileSHA256')&&strlength(string(Batch.FileSHA256))>0, ...
    'OxygenDynamics:BatchQueueSaveRequired','Save this batch CSV before reviewing its execution queue.');
assert(isfile(Batch.FilePath)&&strcmp(oxygenFileSHA256(Batch.FilePath),Batch.FileSHA256), ...
    'OxygenDynamics:BatchQueueChanged','The working CSV changed. Reopen/reconcile it and review the queue again.');
assert((ischar(OutputParent)&&isrow(OutputParent))||(isstring(OutputParent)&&isscalar(OutputParent)&&~ismissing(OutputParent)), ...
    'OxygenDynamics:InvalidBatchQueue','Choose one output parent folder.');
assert(strlength(strtrim(string(OutputParent)))>0,'OxygenDynamics:InvalidBatchQueue','Choose one output parent folder.');
parent=java.io.File(char(OutputParent));
if ~parent.isAbsolute(),parent=java.io.File(fullfile(Batch.BaseFolder,char(OutputParent)));end
OutputParent=char(parent.getCanonicalPath());
assert(isfolder(OutputParent),'OxygenDynamics:InvalidBatchQueue','Choose an existing output parent folder.');
assert(parent.canWrite(),'OxygenDynamics:InvalidBatchQueue','The output parent is not writable. Choose a writable folder.');
ids=string(SelectedRowIDs(:));
assert(~any(ismissing(ids))&&all(strlength(strtrim(ids))>0)&&numel(unique(ids))==numel(ids)&& ...
    all(ismember(ids,Batch.Rows.BatchRowID)), ...
    'OxygenDynamics:InvalidBatchQueue','Select existing unique BatchRowID values.');
queueID=char(java.util.UUID.randomUUID());
queueFolder=fullfile(OutputParent,['BOIBatch_' queueID]);
working=Batch;working.OutputParent=queueFolder;
[CheckedBatch,report,requests]=checkBOIBatch(working,[],ProgressFcn);
CheckedBatch.OutputParent=OutputParent;
selected=ismember(CheckedBatch.Rows.BatchRowID,ids);
ready=report.InputStatus=="Ready";
skipped=selected&ready&report.AnalysisStatus=="Complete"&report.ResultCheck=="Matches"&~RunAgain;
run=selected&ready&~skipped;excluded=selected&~ready;
runRows=find(run);queuedRequests=cell(numel(runRows),1);attemptIDs=strings(numel(runRows),1);copyBytes=0;
for k=1:numel(runRows)
    row=runRows(k);request=requests{row};attemptIDs(k)=string(char(java.util.UUID.randomUUID()));
    request.Options.OutputFolder=fullfile(queueFolder,'runs',['BOIRun_' char(attemptIDs(k))]);
    queuedRequests{k}=request;
    for source=1:numel(request.Sources)
        entry=dir(fullfile(request.Options.RecordingFolder,request.Sources(source).Name));
        assert(numel(entry)==1&&~entry.isdir,'OxygenDynamics:BatchQueueChanged','A reviewed source is unavailable. Check this row again.');
        copyBytes=copyBytes+entry.bytes;
    end
end
[resolved,origins]=resolveBOIBatch(CheckedBatch);
% Keep both prepared inputs and canonical original movie locations untouched.
% Recording folders may contain links to originals elsewhere on disk.
for row=1:height(resolved)
    if strlength(strtrim(resolved.Paths(row)))>0
        assertOutside(OutputParent,char(resolved.Paths(row)));
        entries=dir(char(resolved.Paths(row)));
        for entry=1:numel(entries)
            [~,~,extension]=fileparts(entries(entry).name);
            if ~entries(entry).isdir&&any(strcmpi(extension,{'.tif','.tiff'}))
                original=char(java.io.File(fullfile(char(resolved.Paths(row)),entries(entry).name)).getCanonicalPath());
                assertOutside(OutputParent,fileparts(original));
            end
        end
    end
end
for k=1:numel(queuedRequests)
    request=queuedRequests{k};
    for source=1:numel(request.Sources)
        sourcePath=char(java.io.File(fullfile(request.Options.RecordingFolder,request.Sources(source).Name)).getCanonicalPath());
        assertOutside(OutputParent,fileparts(sourcePath));
    end
end
available=double(parent.getUsableSpace());
if available<=0,available=NaN;end
assert(isnan(available)||copyBytes<=available,'OxygenDynamics:BatchQueueStorage', ...
    'The reviewed source copies alone exceed available output storage. Choose another output parent; analysis outputs need additional space.');
counts=struct('Total',height(report),'Selected',nnz(selected),'Ready',nnz(selected&ready), ...
    'Run',nnz(run),'Excluded',nnz(excluded),'Skipped',nnz(skipped),'NotSelected',nnz(~selected));
Plan=struct('Schema','boi-batch-queue-plan-1','QueueID',queueID,'QueueFolder',queueFolder, ...
    'OutputParent',OutputParent,'CreatedUTC',utcNow(),'BatchSnapshot',CheckedBatch, ...
    'SelectedRowIDs',CheckedBatch.Rows.BatchRowID(selected),'RunRowIDs',CheckedBatch.Rows.BatchRowID(run), ...
    'ExcludedRowIDs',CheckedBatch.Rows.BatchRowID(excluded),'SkippedRowIDs',CheckedBatch.Rows.BatchRowID(skipped), ...
    'NotSelectedRowIDs',CheckedBatch.Rows.BatchRowID(~selected),'AttemptIDs',attemptIDs, ...
    'Requests',{queuedRequests},'ResolvedRows',resolved,'Origins',origins,'Report',report, ...
    'Counts',counts,'SourceCopyBytes',copyBytes,'AvailableDiskBytes',available,'RunAgain',RunAgain);
Plan.PlanSHA256=boiBatchQueueDigest(Plan);
end
function assertOutside(parent,sourceFolder)
assert(~strcmp(parent,sourceFolder)&&~startsWith(parent,[sourceFolder filesep]), ...
    'OxygenDynamics:BatchQueueOutputInsideSource','Choose an output parent outside prepared recordings and the canonical original-source folders.');
end
function text=utcNow()
text=char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ss'Z'"));
end
