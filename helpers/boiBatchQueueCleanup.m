classdef boiBatchQueueCleanup < handle
    %BOIBATCHQUEUECLEANUP Own unwind data independently of nested run workspace.
    % A callback made in this object's method captures this handle directly.
    % It never reads shared variables being destroyed in runBOIBatchQueue.
    properties
        ExecutionLock=''
        QueueID=''
        QueueFolder=''
        Claimed=false
        Finished=false
        Active=false
        Batch=struct()
        AttemptState=struct()
        QueueState=struct()
        StatePath=''
        RecoveryCSV=''
    end
    methods
        function obj=boiBatchQueueCleanup(executionLock,queueID,queueFolder)
            obj.ExecutionLock=executionLock;obj.QueueID=queueID;obj.QueueFolder=queueFolder;
        end
        function callback=callback(obj)
            callback=@()obj.cleanup();
        end
        function cleanup(obj)
            if ~obj.Finished&&obj.Claimed
                try
                    if obj.Active&&~isempty(fieldnames(obj.AttemptState))
                        attempt=obj.AttemptState;
                        attempt.Status='interrupted';attempt.CompletedUTC=obj.utcNow();
                        attempt.Message='The synchronous queue unwound before verified completion. Native run state is preserved.';
                        % Even a state-file failure must not prevent CSV
                        % recovery and release of this known-unwound owner.
                        try,boiBatchWriteAtomicJSON(obj.StatePath,attempt);catch,end
                        batch=obj.Batch;
                        row=find(batch.Rows.BatchRowID==string(attempt.BatchRowID));
                        if isscalar(row)
                            batch.Rows.AnalysisStatus(row)="Interrupted";batch.Rows.ResultCheck(row)="Unavailable";
                            batch.Rows.Message(row)=string(attempt.Message);
                            batch.Rows.CompletedUTC(row)=string(attempt.CompletedUTC);
                            try,writeBOIBatchCSV(batch);
                            catch
                                try
                                    recovered=fullfile(obj.QueueFolder,['RecoveredBatch_' char(java.util.UUID.randomUUID()) '.csv']);
                                    writeBOIBatchCSV(batch,recovered);obj.RecoveryCSV=recovered;
                                catch
                                    % Immutable/native evidence remains.
                                end
                            end
                        end
                    end
                    state=obj.QueueState;
                    if ~isempty(fieldnames(state))
                        state.Status='interrupted';state.CompletedUTC=obj.utcNow();
                        state.Message='Queue execution unwound. Worker liveness in other MATLAB instances was not inferred.';
                        state.RecoveryCSV=obj.RecoveryCSV;
                        try,boiBatchWriteAtomicJSON(fullfile(obj.QueueFolder,'QueueState.json'),state);catch,end
                    end
                catch
                    % Cleanup must not mask the original exception or produce
                    % destructor warnings when persistence is unavailable.
                end
            end
            obj.releaseLock();
        end
    end
    methods (Access=private)
        function releaseLock(obj)
            if ~isfolder(obj.ExecutionLock),return;end
            try
                ownerPath=fullfile(obj.ExecutionLock,'Owner.json');
                if isfile(ownerPath)
                    owner=jsondecode(fileread(ownerPath));
                    if isfield(owner,'QueueID')&&strcmp(owner.QueueID,obj.QueueID),rmdir(obj.ExecutionLock,'s');end
                else
                    rmdir(obj.ExecutionLock); % Only a still-empty owned lock.
                end
            catch
                % Changed/uncertain ownership is retained for explicit recovery.
            end
        end
    end
    methods (Static,Access=private)
        function value=utcNow()
            value=char(datetime('now','TimeZone','UTC','Format',"yyyy-MM-dd'T'HH:mm:ss'Z'"));
        end
    end
end
