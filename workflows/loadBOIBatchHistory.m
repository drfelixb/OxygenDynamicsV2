function History=loadBOIBatchHistory(Batch,RowID)
%LOADBOIBATCHHISTORY Read row-linked immutable attempts and native run records.
% Editable CSV completion text is never evidence of completion. Persisted
% running state without a known unwind remains incomplete; liveness is unknown.
setupOxygenDynamicsPath;
if nargin<2,RowID=Batch.Rows.BatchRowID;end
ids=string(RowID(:));
assert(all(ismember(ids,Batch.Rows.BatchRowID)),'OxygenDynamics:InvalidBatchHistory','Select existing batch row identities.');
names={'BatchRowID','AttemptID','QueueID','Status','Stage','RunFolder','StartedUTC', ...
    'CompletedUTC','Message','Verified','SnapshotPath','LinkVerified'};
History=table('Size',[0,numel(names)],'VariableTypes',[repmat({'string'},1,9) {'logical','string','logical'}], ...
    'VariableNames',names);
if ~ismember('AttemptHistory',Batch.Rows.Properties.VariableNames),return;end
for row=find(ismember(Batch.Rows.BatchRowID,ids))'
    rowID=Batch.Rows.BatchRowID(row);
    try,paths=boiBatchHistoryPaths(Batch.Rows.AttemptHistory(row),Batch.BaseFolder);
    catch err
        History=[History;historyRow(rowID,"",err.message)]; %#ok<AGROW>
        continue
    end
    for k=1:numel(paths)
        record=historyRow(rowID,paths(k),"");
        try
            loaded=load(char(paths(k)),'Attempt');
            assert(isfield(loaded,'Attempt')&&isstruct(loaded.Attempt)&&isscalar(loaded.Attempt), ...
                'OxygenDynamics:InvalidBatchHistory','Attempt snapshot is unavailable or invalid.');
            a=loaded.Attempt;
            assert(all(isfield(a,{'Schema','BatchRowID','AttemptID','QueueID','RunFolder','Request','Row','ResolvedRow'}))&& ...
                strcmp(a.Schema,'boi-batch-attempt-1')&&strcmp(a.BatchRowID,rowID)&& ...
                strcmp(a.Request.Options.OutputFolder,a.RunFolder)&& ...
                isfield(a.Request,'BatchMetadata')&&strcmp(a.Request.BatchMetadata.BatchRowID,rowID), ...
                'OxygenDynamics:InvalidBatchHistory','Attempt identity/request does not match this batch row.');
            statePath=fullfile(fileparts(char(paths(k))),'AttemptState.json');
            state=jsondecode(fileread(statePath));
            assert(all(isfield(state,{'Schema','SnapshotSHA256','BatchRowID','AttemptID','QueueID','RunFolder','Status'}))&& ...
                strcmp(state.Schema,'boi-batch-attempt-state-1')&&strcmp(state.BatchRowID,rowID)&& ...
                strcmp(state.AttemptID,a.AttemptID)&&strcmp(state.QueueID,a.QueueID)&&strcmp(state.RunFolder,a.RunFolder)&& ...
                strcmp(state.SnapshotSHA256,oxygenFileSHA256(char(paths(k)))), ...
                'OxygenDynamics:InvalidBatchHistory','Attempt snapshot or its row-linked state changed.');
            record.AttemptID=string(a.AttemptID);record.QueueID=string(a.QueueID);
            record.RunFolder=string(a.RunFolder);record.LinkVerified=true;
            for field={'Stage','StartedUTC','CompletedUTC','Message'}
                if isfield(state,field{1}),record.(field{1})=string(state.(field{1}));end
            end
            nativePath=fullfile(a.RunFolder,'RunStatus.json');
            if ~isfile(nativePath)
                record.Status="Incomplete";
                if strcmp(state.Status,'failed'),record.Status="Failed";end
                if strcmp(state.Status,'interrupted'),record.Status="Interrupted";end
                record.Message=record.Message+" No native completion is available; this is the saved queue outcome.";
            else
                native=jsondecode(fileread(nativePath));
                assert(isfield(native,'Status'),'OxygenDynamics:InvalidBatchHistory','Saved native run state is invalid.');
                if isfield(native,'Stage'),record.Stage=string(native.Stage);end
                if isfield(native,'StartedUTC'),record.StartedUTC=string(native.StartedUTC);end
                switch string(native.Status)
                    case "complete"
                        run=loadBOIRecordingRun(a.RunFolder);
                        assert(boiBatchSameRequest(run.Request,a.Request)&& ...
                            isfield(run.Request,'BatchMetadata')&&isequaln(run.Request.BatchMetadata,a.Request.BatchMetadata), ...
                            'OxygenDynamics:InvalidBatchHistory','Completed run request or metadata does not match this attempt.');
                        record.Status="Complete";record.Verified=true;
                        record.Message="Native completion, source/settings, row identity, metadata and artifacts verified.";
                    case "failed"
                        verifyIncompleteRequest(a);
                        record.Status="Failed";
                        if isfield(native,'ErrorMessage'),record.Message=string(native.ErrorMessage);end
                    case "running"
                        verifyIncompleteRequest(a);
                        record.Status="Incomplete";
                        record.Message="Last native state is running; worker liveness is unknown.";
                        if strcmp(state.Status,'interrupted')
                            record.Status="Interrupted";record.Message="Queue execution unwound before native completion; original native status is preserved.";
                        end
                    case {"interrupted","incomplete"}
                        verifyIncompleteRequest(a);record.Status="Interrupted";
                    otherwise
                        error('OxygenDynamics:InvalidBatchHistory','Unknown saved native run state.');
                end
            end
        catch err
            record.Status="Unavailable";record.Verified=false;
            record.Message=string(err.identifier)+": "+string(err.message);
        end
        History=[History;record]; %#ok<AGROW>
    end
end
end
function record=historyRow(rowID,path,message)
record=table(string(rowID),"","","Unavailable","","","","",string(message),false,string(path),false, ...
    'VariableNames',{'BatchRowID','AttemptID','QueueID','Status','Stage','RunFolder','StartedUTC','CompletedUTC', ...
    'Message','Verified','SnapshotPath','LinkVerified'});
end
function verifyIncompleteRequest(a)
path=fullfile(a.RunFolder,'RunRequest.mat');
if ~isfile(path),return;end
saved=load(path,'Request');
assert(isfield(saved,'Request')&&boiBatchSameRequest(saved.Request,a.Request)&& ...
    isfield(saved.Request,'BatchMetadata')&&isequaln(saved.Request.BatchMetadata,a.Request.BatchMetadata), ...
    'OxygenDynamics:InvalidBatchHistory','Saved incomplete request differs from this row-linked attempt.');
end
