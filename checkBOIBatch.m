function [Batch,Report,Requests]=checkBOIBatch(Batch,RowIDs,ProgressFcn)
%CHECKBOIBATCH Read-only per-row preparation and saved-completion reconciliation.
% Does not dispatch a queue, change a saved run, or trust CSV completion cells.
% RowIDs optionally limits expensive checks to stable row identities, while
% schema and duplicate-source validation still use the complete batch.
% Report entries for unselected rows remain Unchecked; their CSV cells are
% unchanged. ProgressFcn receives recording/stage events, never analysis work.
setupOxygenDynamicsPath;
[Rows,Origins]=resolveBOIBatch(Batch);n=height(Rows);Requests=cell(n,1);
if nargin<2||isempty(RowIDs),RowIDs=Rows.BatchRowID;end
if nargin<3,ProgressFcn=[];end
assert(isempty(ProgressFcn)||isa(ProgressFcn,'function_handle'), ...
    'OxygenDynamics:BatchCheckProgress','Supply an optional progress function handle.');
assert(ischar(RowIDs)||isstring(RowIDs)||iscellstr(RowIDs), ...
    'OxygenDynamics:BatchCheckSelection','Select stable batch row identities.');
ids=string(RowIDs);ids=ids(:);
assert(~any(ismissing(ids))&&all(strlength(strtrim(ids))>0)&& ...
    numel(unique(ids))==numel(ids)&&all(ismember(ids,Rows.BatchRowID)), ...
    'OxygenDynamics:BatchCheckSelection','Select existing unique batch row identities.');
indices=find(ismember(Rows.BatchRowID,ids));
Report=table(Rows.BatchRowID,Rows.Paths,repmat("Unchecked",n,1), ...
    repmat("Unchecked",n,1),repmat("Unchecked",n,1),strings(n,1), ...
    repmat("Not linked",n,1),'VariableNames',{'BatchRowID','ResolvedPath','InputStatus', ...
    'AnalysisStatus','ResultCheck','Message','MetadataStatus'});
Report.AnalysisStatus(indices)="Not analyzed";
% CSV-owned descriptive fields survive; software outcome fields are reconciled.
auto={'InputStatus','AnalysisStatus','ResultCheck','Message','RunID','StartedUTC', ...
    'CompletedUTC','SoftwareVersion','Stage','ElapsedSeconds'};
for k=1:numel(auto),Batch.Rows.(auto{k})(indices)=strings(numel(indices),1);end
stimulationFields=intersect({'PuffsFile','Puff_2use'},Rows.Properties.VariableNames,'stable');
for checkIndex=1:numel(indices)
    i=indices(checkIndex);
    messages=strings(0,1);request=[];
    reportProgress('source',0);
    if ~isempty(stimulationFields)&&any(strlength(strtrim(string(table2cell(Rows(i,stimulationFields)))))>0)
        messages(end+1)="Stimulation metadata ("+strjoin(string(stimulationFields),', ')+ ...
            ") is preserved as descriptive text and ignored for BOI analysis."; %#ok<AGROW>
    end
    try
        assert(strlength(strtrim(Rows.Paths(i)))>0,'OxygenDynamics:BatchSourceMissing', ...
            'Choose a recording folder for this row.');
        assert(sum(Rows.Paths==Rows.Paths(i))==1,'OxygenDynamics:BatchDuplicateSource', ...
            'This recording folder occurs more than once. Remove the duplicate row or choose a different recording.');
        unsupported=configuredLegacyAnalyses(Rows(i,:));
        assert(isempty(unsupported),'OxygenDynamics:BatchLegacyAnalysis', ...
            'Configured optional analysis fields (%s) require the existing legacy workflow. Keep this CSV and use that route.',strjoin(unsupported,', '));
        assert(isfolder(Rows.Paths(i)),'OxygenDynamics:BatchSourceMissing', ...
            'Recording folder is unavailable: %s. Restore access or correct this row.',Rows.Paths(i));
        assert(all(strlength(strtrim(string(table2cell(Rows(i,{'SampleF','Pixelsize','BOISupportProfile'})))))>0), ...
            'OxygenDynamics:BatchSettingsMissing', ...
            'Supply sampling rate, pixel size and detection support in this row, or explicitly confirm shared settings.');
        % A read-only request still needs a proposed, unused output path.
        % It is not created, and no untrusted ID becomes a path component.
        proposed=tempname(tempdir);
        if isfield(Batch,'OutputParent')&&strlength(strtrim(string(Batch.OutputParent)))>0
            parent=absolutePath(Batch.OutputParent,Batch.BaseFolder);
            proposed=fullfile(parent,['BOIRun_' safeID(Rows.BatchRowID(i))]);
        end
        [request,~,metadata]=prepareBOIBatchRow(Rows(i,:),proposed,Origins(i,:));
        request.BatchMetadata=metadata;
        Requests{i}=request;Report.InputStatus(i)="Ready";
        messages(end+1)="Input checked. No analysis started."; %#ok<AGROW>
    catch err
        Report.InputStatus(i)="Needs attention";
        messages(end+1)=string(err.identifier)+": "+string(err.message); %#ok<AGROW>
    end
    if ismember('AttemptHistory',Rows.Properties.VariableNames)&&strlength(strtrim(Rows.AttemptHistory(i)))>0&&Rows.AttemptHistory(i)~="[]"
        reportProgress('attempt-history',0.5);
        history=loadBOIBatchHistory(Batch,Rows.BatchRowID(i));
        linked=find(history.LinkVerified);
        if ~isempty(linked)
            latest=linked(end);
            if strlength(strtrim(Rows.RunFolder(i)))==0||any(history.RunFolder==Rows.RunFolder(i))
                Rows.RunFolder(i)=history.RunFolder(latest);Batch.Rows.RunFolder(i)=Rows.RunFolder(i);
                messages(end+1)="Latest attempt link recovered from row-associated history."; %#ok<AGROW>
            end
        elseif ~isempty(history)
            messages(end+1)="Attempt history needs attention: "+history.Message(end); %#ok<AGROW>
        end
    end
    if strlength(strtrim(Rows.RunFolder(i)))>0
        reportProgress('saved-result',0.75);
        [outcome,runMessages,meta]=inspectRun(Rows(i,:),request);
        Report.AnalysisStatus(i)=outcome.AnalysisStatus;
        Report.ResultCheck(i)=outcome.ResultCheck;Report.MetadataStatus(i)=meta;
        for k=1:numel(auto)
            if isfield(outcome,auto{k}),Batch.Rows.(auto{k})(i)=outcome.(auto{k});end
        end
        messages=[messages(:);runMessages(:)];
    end
    Report.Message(i)=strjoin(messages,newline);
    Batch.Rows.InputStatus(i)=Report.InputStatus(i);
    Batch.Rows.AnalysisStatus(i)=Report.AnalysisStatus(i);
    Batch.Rows.ResultCheck(i)=Report.ResultCheck(i);
    Batch.Rows.Message(i)=Report.Message(i);
    reportProgress('complete',1);
end
    function reportProgress(stage,fraction)
        if isempty(ProgressFcn),return;end
        label=char(Rows.Paths(i));
        if ismember('Mouse',Rows.Properties.VariableNames)&&strlength(strtrim(Rows.Mouse(i)))>0
            label=char(Rows.Mouse(i));
        end
        if isempty(label),label=sprintf('Batch row %d',i);end
        event=struct('RowIndex',i,'CheckIndex',checkIndex,'CheckCount',numel(indices), ...
            'BatchCount',n,'BatchRowID',char(Rows.BatchRowID(i)), ...
            'Label',label,'ResolvedPath',char(Rows.Paths(i)), ...
            'Stage',stage,'Fraction',fraction,'InputStatus',char(Report.InputStatus(i)), ...
            'AnalysisStatus',char(Report.AnalysisStatus(i)));
        ProgressFcn(event);
    end
end

function [outcome,messages,metadata]=inspectRun(Row,request)
outcome=struct('AnalysisStatus',"Incomplete",'ResultCheck',"Unavailable");
messages=strings(0,1);metadata="Not checked";
root=char(Row.RunFolder);
if isfile(root),root=fileparts(root);end
statusPath=fullfile(root,'RunStatus.json');
try
    assert(isfile(statusPath),'OxygenDynamics:IncompleteRun','No saved run status at %s.',statusPath);
    status=jsondecode(fileread(statusPath));
    assert(isstruct(status)&&isscalar(status)&&isfield(status,'Status'), ...
        'OxygenDynamics:IncompleteRun','Saved run status is invalid.');
    fields={'StartedUTC','CompletedUTC','Stage','ElapsedSeconds'};
    for k=1:numel(fields)
        if isfield(status,fields{k}),outcome.(fields{k})=scalarText(status.(fields{k}));end
    end
    if scalarText(status.Status)~="complete"
        assert(~isempty(request),'OxygenDynamics:BatchRunUnverified', ...
            'Linked saved state is %s. Resolve the row input issues before associating this attempt.',scalarText(status.Status));
        requestPath=fullfile(root,'RunRequest.mat');
        assert(isfile(requestPath),'OxygenDynamics:BatchRunUnverified', ...
            'Linked saved state is %s, but its saved request is absent; row/source association is unverified.',scalarText(status.Status));
        q=load(requestPath,'Request');
        assert(isfield(q,'Request')&&isstruct(q.Request)&&isscalar(q.Request)&& ...
            isfield(q.Request,'InputReview')&&isfield(q.Request.InputReview,'RawSHA256')&& ...
            strcmp(q.Request.InputReview.RawSHA256,request.InputReview.RawSHA256), ...
            'OxygenDynamics:BatchRunUnverified', ...
            'Linked saved state is %s, but its source does not match this row. Select the correct saved attempt.',scalarText(status.Status));
        if isfield(q.Request,'BatchMetadata')
            assert(strcmp(q.Request.BatchMetadata.BatchRowID,Row.BatchRowID), ...
                'OxygenDynamics:BatchRunRowMismatch','Saved batch attempt belongs to a different stable row identity.');
        end
    end
    switch scalarText(status.Status)
        case "failed"
            outcome.AnalysisStatus="Failed";
            messages(end+1)="Saved attempt failed; its partial output is preserved.";
            if isfield(status,'ErrorID'),messages(end+1)=scalarText(status.ErrorID);end
            if isfield(status,'ErrorMessage'),messages(end+1)=scalarText(status.ErrorMessage);end
            return
        case "running"
            outcome.AnalysisStatus="Incomplete";
            messages(end+1)="Saved run is incomplete (last state: running). This editor does not check worker liveness.";
            return
        case {"interrupted","incomplete"}
            outcome.AnalysisStatus="Interrupted";
            messages(end+1)="Saved attempt is interrupted/incomplete. A retry requires a new run folder.";
            return
        case "complete"
            run=loadBOIRecordingRun(root);
            if isfield(run.Request,'BatchMetadata')
                assert(strcmp(run.Request.BatchMetadata.BatchRowID,Row.BatchRowID), ...
                    'OxygenDynamics:BatchRunRowMismatch','Saved batch run belongs to a different stable row identity.');
            end
        otherwise
            error('OxygenDynamics:IncompleteRun','Unsupported saved status: %s.',scalarText(status.Status));
    end
    outcome.AnalysisStatus="Complete";
    [~,runName]=fileparts(run.Directory);outcome.RunID=string(runName);
    outcome.SoftwareVersion="unknown";
    if isfield(run,'SoftwareVersion'),outcome.SoftwareVersion=scalarText(run.SoftwareVersion);end
    if isempty(request)
        outcome.ResultCheck="Unchecked";
        messages(end+1)="Saved completion/artifacts verified. Resolve this row's input problems before comparing current settings/source.";
    else
        old=run.Request;o=old.Options;now=request.Options;
        same=strcmp(run.SourceSHA256,request.InputReview.RawSHA256)&& ...
            isequaln(o.SampleHz,now.SampleHz)&&isequaln(o.PixelSizeUm,now.PixelSizeUm)&& ...
            strcmp(o.SupportProfile,now.SupportProfile);
        if isfield(old,'Sources'),same=same&&sameSources(old.Sources,request.Sources);else,same=false;end
        if isfield(old,'AnalysisParams'),same=same&&isequaln(old.AnalysisParams,request.AnalysisParams);else,same=false;end
        if same
            outcome.ResultCheck="Matches";
            messages(end+1)="Saved completion and artifacts verified; current source and calculation settings match.";
        else
            outcome.ResultCheck="Changed";
            messages(end+1)="Source or calculation settings differ from the saved run. Its original result is preserved; this row needs a new attempt to use the new inputs.";
        end
    end
    metadata=compareMetadata(Row,run.Request);
    messages(end+1)=metadata;
catch err
    if strcmp(err.identifier,'OxygenDynamics:RunArtifactChanged'),outcome.ResultCheck="Changed";end
    messages(end+1)="Saved completion cannot be verified: "+string(err.identifier)+": "+string(err.message);
end
end

function equal=sameSources(a,b)
equal=isstruct(a)&&isstruct(b)&&all(isfield(a,{'Name','SHA256'}))&&numel(a)==numel(b);
if ~equal,return;end
[~,ia]=sort(string({a.Name}));[~,ib]=sort(string({b.Name}));
equal=isequal(string({a(ia).Name}),string({b(ib).Name}))&& ...
    isequal(string({a(ia).SHA256}),string({b(ib).SHA256}));
end
function text=compareMetadata(Row,request)
software={'Paths','SampleF','Pixelsize','BOISupportProfile','BatchRowID','InputStatus', ...
    'AnalysisStatus','ResultCheck','ReviewStatus','RunFolder','Message','RunID','StartedUTC', ...
    'CompletedUTC','SoftwareVersion','Stage','ElapsedSeconds','AttemptHistory'};
if isfield(request,'BatchMetadata')
    snapshot=request.BatchMetadata;
    assert(isstruct(snapshot)&&isscalar(snapshot)&&all(isfield(snapshot,{'Schema','BatchRowID','Names','Values'}))&& ...
        strcmp(snapshot.Schema,'boi-batch-row-metadata-1')&&strcmp(snapshot.BatchRowID,Row.BatchRowID)&& ...
        numel(snapshot.Names)==numel(snapshot.Values), ...
        'OxygenDynamics:InvalidBatchHistory','Saved batch metadata snapshot is invalid.');
    savedNames=string(snapshot.Names);savedValues=string(snapshot.Values);
    names=union(string(Row.Properties.VariableNames),savedNames);
    names=names(~ismember(names,string(software))&~startsWith(lower(names),"boibatch"));
    changed=strings(0,1);
    for name=names(:)'
        current="";saved="";
        if ismember(name,Row.Properties.VariableNames),current=Row.(char(name));end
        if any(savedNames==name),saved=savedValues(savedNames==name);end
        if ~isequal(current,saved),changed(end+1)=name;end %#ok<AGROW>
    end
    if isempty(changed),text="Saved descriptive metadata matches.";
    else,text="Metadata changed since run: "+strjoin(changed,', ')+". Saved metadata/labels/exports are unchanged.";end
    return
end
old=request.Options;
labels={'Mouse','Condition','DrugID','Genotype','Promoter'};changed=strings(0,1);
for k=1:numel(labels)
    field=labels{k};value="unspecified";
    if ismember(field,Row.Properties.VariableNames)&&strlength(strtrim(Row.(field)))>0,value=Row.(field);end
    if ~strcmp(value,string(old.(field))),changed(end+1)=string(field);end %#ok<AGROW>
end
if isempty(changed),text="Saved descriptive labels match.";
else,text="Metadata changed since run: "+strjoin(changed,', ')+". Saved labels/exports are unchanged.";end
additional={'RecordingLabel','RecordingDate','Session','Sex','AgeDays','BrainRegion','Project','Operator','Notes'};
core=[labels {'Paths','SampleF','Pixelsize','BOISupportProfile','BatchRowID','InputStatus', ...
    'AnalysisStatus','ResultCheck','ReviewStatus','RunFolder','Message','RunID','StartedUTC', ...
    'CompletedUTC','SoftwareVersion','Stage','ElapsedSeconds','AttemptHistory'}];
extra=setdiff(Row.Properties.VariableNames,core);
extra=union(extra,intersect(additional,Row.Properties.VariableNames));
extra=extra(~startsWith(extra,'BOIBatch'));
if ~isempty(extra)&&any(strlength(strtrim(string(table2cell(Row(:,extra)))))>0)
    text=text+" Additional/custom metadata was not captured by this older run; the current table is not its original metadata snapshot.";
end
end
function configured=configuredLegacyAnalyses(Row)
% Stimulation fields remain descriptive metadata in this BOI preparation route.
configured={};names={'PostureFile','PupilFile','WhiskingFile','AmyloidFile'};
for k=1:numel(names)
    f=names{k};if ~ismember(f,Row.Properties.VariableNames),continue;end
    value=lower(strtrim(Row.(f)));
    if strlength(value)>0&&~any(value==["nan","none","unspecified","<missing>"])
        configured{end+1}=f; %#ok<AGROW>
    end
end
end
function value=scalarText(value)
value=string(value);assert(isscalar(value)&&~ismissing(value),'OxygenDynamics:IncompleteRun','Saved status fields must be scalar text/numbers.');
end
function path=absolutePath(path,base)
path=char(path);if ~java.io.File(path).isAbsolute(),path=fullfile(base,path);end
path=char(java.io.File(path).getCanonicalPath());
end
function text=safeID(value)
text=regexprep(char(value),'[^A-Za-z0-9_-]','_');
assert(~isempty(text),'OxygenDynamics:InvalidBatch','Batch row identity is missing.');
end
