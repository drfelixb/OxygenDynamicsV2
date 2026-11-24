function [Batch,Outcome]=runBOIBatchQueue(Batch,Plan,ProgressFcn,StopFcn,Executor)
%RUNBOIBATCHQUEUE Execute a reviewed finite queue through the existing engine.
% Requests are sequential and each attempt has a fresh destination. Stop is
% checked only between recordings. Native artifacts, never an executor return
% or CSV label, determine completion. A writeback conflict finishes the current
% recording, saves a recovered CSV, and prevents any later dispatch.
setupOxygenDynamicsPath;
if nargin<3,ProgressFcn=[];end
if nargin<4,StopFcn=[];end
if nargin<5||isempty(Executor),Executor=@runBOIRecordingWorkflow;end
assert((isempty(ProgressFcn)||isa(ProgressFcn,'function_handle'))&& ...
    (isempty(StopFcn)||isa(StopFcn,'function_handle'))&&isa(Executor,'function_handle'), ...
    'OxygenDynamics:InvalidBatchQueue','Queue callbacks/executor must be function handles.');
assert(~isfield(Batch,'WorkingCSV')||isequal(Batch.WorkingCSV,true), ...
    'OxygenDynamics:BatchWorkingCSVRequired', ...
    'Save a separate working CSV, then review the queue before starting recordings.');
assert(isstruct(Plan)&&isscalar(Plan)&&isfield(Plan,'Schema')&&strcmp(Plan.Schema,'boi-batch-queue-plan-1')&& ...
    all(isfield(Plan,{'PlanSHA256','BatchSnapshot','Requests','RunRowIDs','AttemptIDs','QueueFolder','QueueID'})), ...
    'OxygenDynamics:BatchQueueChanged','Review a batch queue before starting it.');
assert(strcmp(boiBatchQueueDigest(rmfield(Plan,'PlanSHA256')),Plan.PlanSHA256)&&isequaln(Batch,Plan.BatchSnapshot), ...
    'OxygenDynamics:BatchQueueChanged','Batch settings or queue destinations changed after review. Review and confirm a new queue.');
assertCSVCurrent();
Outcome=struct('Schema','boi-batch-queue-outcome-1','Status','complete', ...
    'CompletedRowIDs',strings(0,1),'PendingRowIDs',Plan.RunRowIDs,'FailedRowID',"", ...
    'Message','','ErrorID','','QueueFolder',Plan.QueueFolder,'RecoveryCSV','');
if isempty(Plan.RunRowIDs)
    Outcome.Message='No selected rows require dispatch. Excluded and verified skipped rows remain unchanged.';return;
end
% Reject a stale first source before creating the queue or invoking any executor.
assertRequestCurrent(Plan.Requests{1});
executionLock=[char(Batch.FilePath) '.boi-execution-lock'];
assert(java.io.File(executionLock).mkdir(),'OxygenDynamics:BatchQueueLocked', ...
    ['This CSV has an execution lock from another or interrupted queue. Do not start a second queue or remove the lock while a worker may be active. ' ...
    'Inspect its saved queue state; save a recovered CSV under a new filename to reconcile it. No worker liveness is inferred. Lock: %s'],executionLock);
claimedQueue=false;active=false;currentIndex=0;row=0;
fatal=false;csvDisabled=false;recoveryDocument=[];attemptState=struct();statePath='';snapshotPath='';
queueState=struct();
guard=boiBatchQueueCleanup(executionLock,Plan.QueueID,Plan.QueueFolder);
cleanup=onCleanup(guard.callback());
assertCSVCurrent();
boiBatchWriteAtomicJSON(fullfile(executionLock,'Owner.json'),struct('QueueID',Plan.QueueID, ...
    'QueueFolder',Plan.QueueFolder,'CSV',Batch.FilePath,'StartedUTC',utcNow()));
assert(java.io.File(Plan.QueueFolder).mkdir(),'OxygenDynamics:BatchQueueOutputExists', ...
    'The reviewed queue output folder already exists. Review a new queue; earlier outputs are preserved.');
claimedQueue=true;
guard.Claimed=true;
mkdir(fullfile(Plan.QueueFolder,'attempts'));mkdir(fullfile(Plan.QueueFolder,'runs'));
planPath=fullfile(Plan.QueueFolder,'QueuePlan.mat');
planHash=boiBatchWriteSnapshot(planPath,'Plan',Plan);
queueState=struct('Schema','boi-batch-queue-state-1','QueueID',Plan.QueueID,'PlanPath',planPath, ...
    'PlanSHA256',planHash,'Status','running','Stage','queued','StartedUTC',utcNow(),'CompletedUTC','', ...
    'CurrentRowID','','CompletedRowIDs',strings(0,1),'PendingRowIDs',Plan.RunRowIDs, ...
    'FailedRowID','','Message','','RecoveryCSV','','Attempts',struct('BatchRowID',{},'AttemptID',{},'SnapshotPath',{},'RunFolder',{}));
saveQueueState();
for k=1:numel(Plan.RunRowIDs)
    currentIndex=k;
    row=find(Batch.Rows.BatchRowID==Plan.RunRowIDs(k));
    assert(isscalar(row),'OxygenDynamics:BatchQueueChanged','A reviewed recording identity is no longer unique.');
    if shouldStop()
        Outcome.Status='stopped';Outcome.Message='Stopped between recordings. Pending recordings were not started.';break;
    end
    if k>1
        try,assertCSVCurrent();
        catch err
            csvDisabled=true;
            setFatal('writeback-conflict','OxygenDynamics:BatchCSVConflict', ...
                ['The working CSV changed between recordings. Its external edit is preserved; later recordings were not started. ' err.message]);
            saveRecovery();break;
        end
        try,assertRequestCurrent(Plan.Requests{k});
        catch err
            Outcome.Status='failed';Outcome.ErrorID=err.identifier;Outcome.Message=err.message;
            Outcome.FailedRowID=Plan.RunRowIDs(k);
            Batch.Rows.InputStatus(row)="Needs attention";Batch.Rows.ResultCheck(row)="Unchecked";
            Batch.Rows.Message(row)="Not dispatched: "+string(err.message);
            persistBatchCSV();break;
        end
    end
    request=Plan.Requests{k};attemptID=char(Plan.AttemptIDs(k));
    attemptFolder=fullfile(Plan.QueueFolder,'attempts',attemptID);
    assert(java.io.File(attemptFolder).mkdir(),'OxygenDynamics:BatchQueueOutputExists','Attempt evidence already exists.');
    snapshotPath=fullfile(attemptFolder,'AttemptSnapshot.mat');statePath=fullfile(attemptFolder,'AttemptState.json');
    planRow=find(Plan.BatchSnapshot.Rows.BatchRowID==Plan.RunRowIDs(k));
    Attempt=struct('Schema','boi-batch-attempt-1','BatchRowID',char(Plan.RunRowIDs(k)), ...
        'AttemptID',attemptID,'QueueID',Plan.QueueID,'RunFolder',request.Options.OutputFolder, ...
        'CreatedUTC',utcNow(),'Row',Plan.BatchSnapshot.Rows(planRow,:), ...
        'ResolvedRow',Plan.ResolvedRows(planRow,:),'SettingOrigins',Plan.Origins(planRow,:), ...
        'Request',request);
    version=getOxygenPipelineVersion();Attempt.Software=version;
    snapshotHash=boiBatchWriteSnapshot(snapshotPath,'Attempt',Attempt);
    attemptState=struct('Schema','boi-batch-attempt-state-1','BatchRowID',Attempt.BatchRowID, ...
        'AttemptID',attemptID,'QueueID',Plan.QueueID,'RunFolder',Attempt.RunFolder, ...
        'SnapshotPath',snapshotPath,'SnapshotSHA256',snapshotHash,'Status','running','Stage','queued', ...
        'StartedUTC',utcNow(),'CompletedUTC','','ElapsedSeconds','','Message','','ErrorID','');
    queueState.Attempts(end+1)=struct('BatchRowID',Attempt.BatchRowID,'AttemptID',attemptID, ...
        'SnapshotPath',snapshotPath,'RunFolder',Attempt.RunFolder);
    paths=boiBatchHistoryPaths(Batch.Rows.AttemptHistory(row),Batch.BaseFolder);paths(end+1)=string(snapshotPath);
    Batch.Rows.AttemptHistory(row)=string(jsonencode(cellstr(paths)));
    Batch.Rows.RunFolder(row)=string(Attempt.RunFolder);Batch.Rows.RunID(row)=string(attemptID);
    Batch.Rows.AnalysisStatus(row)="Running";Batch.Rows.ResultCheck(row)="Unchecked";
    Batch.Rows.StartedUTC(row)=string(attemptState.StartedUTC);Batch.Rows.CompletedUTC(row)="";
    Batch.Rows.SoftwareVersion(row)=string(version.Version);
    Batch.Rows.BOIBatchSourceCommit(row)=string(version.SourceCommit);
    Batch.Rows.BOIBatchSourceState(row)=string(version.SourceState);
    Batch.Rows.Stage(row)="queued";Batch.Rows.ElapsedSeconds(row)="";Batch.Rows.Message(row)="Queued attempt prepared; no completion claimed.";
    queueState.CurrentRowID=Attempt.BatchRowID;queueState.Stage='queued';
    active=true;persistAttemptAndCSV();notifyProgress();
    if fatal
        attemptState.Status='interrupted';attemptState.Message='Attempt was not dispatched because durable preparation/writeback failed.';
        Batch.Rows.AnalysisStatus(row)="Interrupted";Batch.Rows.Message(row)=string(attemptState.Message);
        persistAttemptAndCSV();active=false;syncGuard();break;
    end
    dispatched=false;
    try
        dispatched=true;
        Executor(request,@recordProgress);
        native=loadBOIRecordingRun(request.Options.OutputFolder);
        assert(boiBatchSameRequest(native.Request,request)&&isfield(native.Request,'BatchMetadata')&& ...
            isequaln(native.Request.BatchMetadata,request.BatchMetadata)&& ...
            strcmp(native.Request.BatchMetadata.BatchRowID,Attempt.BatchRowID), ...
            'OxygenDynamics:BatchRunUnverified','Saved completion/source/settings/metadata do not match this row-associated attempt.');
        % Recheck source declarations and calibration after execution as well.
        recheckOptions=request.Options;recheckOptions.OutputFolder=tempname(Plan.QueueFolder);
        current=prepareBOIRecordingRequest(recheckOptions);
        current.Options.OutputFolder=request.Options.OutputFolder;
        assert(boiBatchSameRequest(current,request),'OxygenDynamics:BatchQueueChanged','Source or calculation inputs changed during the recording.');
        attemptState.Status='complete';attemptState.Stage='complete';attemptState.CompletedUTC=utcNow();
        attemptState.Message='Native completion and row-associated source/settings/metadata/artifacts verified.';
        if isfield(native,'ElapsedSeconds'),attemptState.ElapsedSeconds=string(native.ElapsedSeconds);end
        Batch.Rows.AnalysisStatus(row)="Complete";Batch.Rows.ResultCheck(row)="Matches";
        Batch.Rows.Stage(row)="complete";Batch.Rows.CompletedUTC(row)=string(attemptState.CompletedUTC);
        Batch.Rows.ElapsedSeconds(row)=string(attemptState.ElapsedSeconds);Batch.Rows.Message(row)=string(attemptState.Message);
        Outcome.CompletedRowIDs(end+1,1)=Plan.RunRowIDs(k);
    catch err
        attemptState.Status='failed';attemptState.ErrorID=err.identifier;attemptState.Message=err.message;
        attemptState.CompletedUTC=utcNow();
        Batch.Rows.AnalysisStatus(row)="Failed";Batch.Rows.ResultCheck(row)="Unavailable";
        Batch.Rows.CompletedUTC(row)=string(attemptState.CompletedUTC);
        Batch.Rows.Message(row)=string(err.identifier)+": "+string(err.message);
        Outcome.FailedRowID=Plan.RunRowIDs(k);
        if ~fatal
            Outcome.Status='failed';Outcome.ErrorID=err.identifier;Outcome.Message=err.message;
        end
    end
    if dispatched,Outcome.PendingRowIDs=Plan.RunRowIDs(k+1:end);end
    queueState.CompletedRowIDs=Outcome.CompletedRowIDs;queueState.PendingRowIDs=Outcome.PendingRowIDs;
    queueState.FailedRowID=char(Outcome.FailedRowID);
    persistAttemptAndCSV();active=false;syncGuard();notifyProgress();
    if fatal||strcmp(attemptState.Status,'failed'),break;end
end
% The final GUI progress callback may yield to an external CSV editor even
% when there is no next row. Reconcile that boundary before reporting success.
if ~csvDisabled
    try,assertCSVCurrent();
    catch err
        csvDisabled=true;
        setFatal('writeback-conflict','OxygenDynamics:BatchCSVConflict', ...
            ['The working CSV changed after the latest stage write. Its external edit is preserved. ' err.message]);
        saveRecovery();
    end
end
if strcmp(Outcome.Status,'complete')
    if shouldStop()&&~isempty(Outcome.PendingRowIDs)
        Outcome.Status='stopped';Outcome.Message='Stopped after the current recording. Pending recordings were not started.';
    else
        Outcome.Message=sprintf('Verified %d completed recordings; %d pending.',numel(Outcome.CompletedRowIDs),numel(Outcome.PendingRowIDs));
    end
end
queueState.Status=Outcome.Status;queueState.Stage='finished';queueState.CompletedUTC=utcNow();
queueState.CompletedRowIDs=Outcome.CompletedRowIDs;queueState.PendingRowIDs=Outcome.PendingRowIDs;
queueState.FailedRowID=char(Outcome.FailedRowID);queueState.Message=Outcome.Message;
queueState.RecoveryCSV=Outcome.RecoveryCSV;saveQueueState();guard.Finished=true;
% Run cleanup while normal-return data still exists. Unexpected unwind uses
% the independent handle state and does not depend on destruction ordering.
clear cleanup

    function assertCSVCurrent()
        assert(isfile(Batch.FilePath)&&strcmp(oxygenFileSHA256(Batch.FilePath),Batch.FileSHA256), ...
            'OxygenDynamics:BatchQueueChanged','The working CSV changed since queue review/writeback. Reconcile it and review a new queue.');
    end
    function stop=shouldStop()
        stop=false;if isempty(StopFcn),return;end
        stop=StopFcn();
        assert(islogical(stop)&&isscalar(stop),'OxygenDynamics:InvalidBatchQueue','The stop callback must return one logical value.');
    end
    function recordProgress(status,statusPath)
        % The existing engine catches callback exceptions. Retain an internal
        % fatal flag so persistence failure cannot accidentally dispatch next.
        try
            expected=fullfile(Plan.Requests{currentIndex}.Options.OutputFolder,'RunStatus.json');
            assert(strcmp(char(java.io.File(char(statusPath)).getCanonicalPath()),expected), ...
                'OxygenDynamics:BatchRunUnverified','Progress belongs to a different run folder.');
            assert(isstruct(status)&&isscalar(status)&&all(isfield(status,{'Status','Stage'})), ...
                'OxygenDynamics:BatchRunUnverified','Invalid recording progress state.');
            for field={'StartedUTC','ElapsedSeconds','Stage'}
                if isfield(status,field{1})
                    value=string(status.(field{1}));
                    assert(isscalar(value)&&~ismissing(value),'OxygenDynamics:BatchRunUnverified','Invalid progress field.');
                    attemptState.(field{1})=char(value);Batch.Rows.(field{1})(row)=value;
                end
            end
            % A native complete callback is only an observation until the
            % executor has returned and its whole indexed result is verified.
            if strcmp(status.Status,'failed')
                Batch.Rows.AnalysisStatus(row)="Failed";
                if isfield(status,'ErrorMessage'),attemptState.Message=char(string(status.ErrorMessage));end
            else
                Batch.Rows.AnalysisStatus(row)="Running";
            end
            Batch.Rows.Message(row)="Recording stage: "+string(status.Stage)+". Completion awaits artifact verification.";
            queueState.Stage=char(string(status.Stage));persistAttemptAndCSV();notifyProgress();
        catch err
            setFatal('failed',err.identifier,['Queue progress could not be durably recorded: ' err.message]);
        end
    end
    function persistAttemptAndCSV()
        syncGuard();
        try
            boiBatchWriteAtomicJSON(statePath,attemptState);saveQueueState();
        catch err
            setFatal('failed',err.identifier,['Attempt/queue state could not be saved: ' err.message]);
            csvDisabled=true;saveRecovery();
            return
        end
        persistBatchCSV();
    end
    function persistBatchCSV()
        if csvDisabled,saveRecovery();return;end
        try
            Batch=writeBOIBatchCSV(Batch);
            syncGuard();
        catch err
            csvDisabled=true;
            if strcmp(err.identifier,'OxygenDynamics:BatchCSVConflict')
                setFatal('writeback-conflict',err.identifier, ...
                    ['The working CSV changed outside this queue. Its external edit is preserved. The current recording may finish; later recordings will not start. ' err.message]);
            else
                setFatal('failed',err.identifier,['CSV writeback failed. Later recordings will not start. ' err.message]);
            end
            saveRecovery();
        end
    end
    function saveRecovery()
        try
            candidate=Batch;
            if isempty(recoveryDocument)
                path=fullfile(Plan.QueueFolder,['RecoveredBatch_' char(java.util.UUID.randomUUID()) '.csv']);
            else
                path=recoveryDocument.FilePath;
                candidate.FilePath=path;candidate.FileSHA256=recoveryDocument.FileSHA256;
            end
            recoveryDocument=writeBOIBatchCSV(candidate,path);Outcome.RecoveryCSV=path;
            queueState.RecoveryCSV=path;saveQueueState();
        catch recoveryError
            Outcome.Message=[Outcome.Message ' Recovered CSV could not be updated: ' recoveryError.message ...
                '. Immutable attempt evidence and native outputs remain in the queue folder.'];
        end
    end
    function setFatal(status,id,message)
        fatal=true;
        if strcmp(Outcome.Status,'writeback-conflict'),return;end
        Outcome.Status=status;Outcome.ErrorID=id;Outcome.Message=message;
    end
    function notifyProgress()
        if isempty(ProgressFcn),return;end
        event=struct('QueueID',Plan.QueueID,'QueueFolder',Plan.QueueFolder, ...
            'RowID',Plan.RunRowIDs(currentIndex),'Index',currentIndex,'Count',numel(Plan.RunRowIDs), ...
            'Status',char(Batch.Rows.AnalysisStatus(row)),'Stage',char(Batch.Rows.Stage(row)), ...
            'Message',char(Batch.Rows.Message(row)),'RunFolder',char(Batch.Rows.RunFolder(row)));
        try,ProgressFcn(Batch,event);
        catch err,setFatal('failed','OxygenDynamics:BatchQueueProgressFailed',['Queue progress display failed: ' err.message]);end
    end
    function saveQueueState()
        queueState.RecoveryCSV=Outcome.RecoveryCSV;
        syncGuard();
        boiBatchWriteAtomicJSON(fullfile(Plan.QueueFolder,'QueueState.json'),queueState);
    end
    function syncGuard()
        guard.Claimed=claimedQueue;guard.Active=active;guard.Batch=Batch;
        guard.AttemptState=attemptState;guard.QueueState=queueState;
        guard.StatePath=statePath;guard.RecoveryCSV=Outcome.RecoveryCSV;
    end
end
function assertRequestCurrent(request)
try
    current=prepareBOIRecordingRequest(request.Options);
    assert(boiBatchSameRequest(current,request),'OxygenDynamics:BatchQueueChanged','Reviewed recording inputs changed.');
catch err
    error('OxygenDynamics:BatchQueueChanged','Recording inputs changed after queue review. Check/review the queue again. %s',err.message);
end
end
function text=utcNow()
text=char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ss'Z'"));
end
