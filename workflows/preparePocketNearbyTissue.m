function plan = preparePocketNearbyTissue(exportFolder, outputParent, progress)
%PREPAREPOCKETNEARBYTISSUE Preview sources of a completed automatic export.
arguments
    exportFolder (1,1) string
    outputParent (1,1) string = exportFolder
    progress = []
end
setupOxygenDynamicsPath;
result = loadBOIBatchStatsResult(exportFolder);
saved = load(fullfile(result.Directory,'BatchStatsSelection.mat'),'Plan');
selection = saved.Plan;
assert(strcmp(selection.Digest,result.PlanDigest) && strcmp(boiBatchQueueDigest(rmfield(selection,'Digest')),selection.Digest), ...
    'OxygenDynamics:PocketSelection','Export selection changed during preview.');
rows = selection.Included(:,{'BatchRowID','Mouse','Condition','RecordingID','RunFolder'});
[found,idx] = ismember(rows.BatchRowID,selection.SourceRows.BatchRowID);
assert(all(found),'OxygenDynamics:PocketSelection','Missing batch metadata.');
meta = selection.SourceRows(idx,:);
rows.BatchMouse = strip(string(rows.Mouse));
assert(all(~ismissing(rows.BatchMouse) & strlength(rows.BatchMouse)>0),'Every recording needs a mouse ID.');
rows.Condition = label(rows.Condition);
rows.Group = label(selection.InputRows.Promoter);
for field = ["Sensor_Promoter","Promoter"]
    if ismember(field,meta.Properties.VariableNames)
        group = label(meta.(field));
        take = rows.Group=="Unspecified" & group~="Unspecified";
        rows.Group(take) = group(take);
    end
end
for name = ["GFAP","hSyn","ECS"]
    rows.Group(strcmpi(rows.Group,name+"-GeNL") | strcmpi(rows.Group,name)) = name;
end
rows.RecordingFolder = string({selection.SavedSources.RecordingFolder})';
rows.AuditFile = fullfile(rows.RecordingFolder,'BOIReview','event-amplitude-audit.mat');
rows.OriginalFolder = string(meta.Paths);
rows.OriginalFolder(ismissing(rows.OriginalFolder)) = "";
n = height(rows);
rows.SourceSHA256 = strings(n,1);
rows.SourcePath = strings(n,1);
for k = 1:n
    info = load(rows.AuditFile(k),'AnalysisInfo');
    rows.SourceSHA256(k) = lower(string(info.AnalysisInfo.RawSHA256));
    rows.SourcePath(k) = string(info.AnalysisInfo.RawFile);
    assert(~isempty(regexp(rows.SourceSHA256(k),'^[0-9a-f]{64}$','once')), ...
        'OxygenDynamics:PocketSource','Invalid raw source digest in %s.',rows.AuditFile(k));
end
rows.Mouse = rows.BatchMouse;
rows.VerifiedRawFile = strings(n,1);
rows.SourceStatus = strings(n,1);
previous = dir(fullfile(outputParent,'Automatic_PocketTraces_*','Mouse_identity_map.csv'));
[~,order] = sort([previous.datenum],'descend');
hashes = unique(rows.SourceSHA256,'stable');
for i = 1:numel(hashes)
    hash = hashes(i);
    aliases = find(rows.SourceSHA256==hash);
    if ~isempty(progress)
        progress(sprintf('Checking original TIFF %d of %d (%s)…',i,numel(hashes),strjoin(rows.BatchMouse(aliases),', ')));
    end
    assert(numel(unique(rows.Condition(aliases)))==1 && numel(unique(rows.Group(aliases)))==1, ...
        'OxygenDynamics:PocketLabels','One movie has conflicting condition or sensor labels. Review the source export.');
    if numel(unique(rows.BatchMouse(aliases)))>1
        rows.Mouse(aliases) = "";
        for j = order
            old = readPocketTable(fullfile(previous(j).folder,previous(j).name));
            match = old.SourceSHA256==hash & old.SelectionDigest==string(result.PlanDigest);
            if nnz(match)==1
                rows.Mouse(aliases) = old.Mouse(match);
                break
            end
        end
    end
    messages = strings(0,1);
    for k = aliases'
        try
            rows.VerifiedRawFile(aliases) = nearbyRawFile(rows.SourcePath(k),rows.RecordingFolder(k),rows.OriginalFolder(k),hash);
            break
        catch err
            if ~strcmp(err.identifier,'Nearby:RawSource'),rethrow(err);end
            messages(end+1) = string(err.message); %#ok<AGROW>
        end
    end
    if rows.VerifiedRawFile(aliases(1))==""
        rows.SourceStatus(aliases) = "TIFF unavailable. "+strjoin(messages," ");
    else
        rows.SourceStatus(aliases) = "TIFF verified";
    end
end
plan = struct('ExportFolder',string(result.Directory),'SelectionDigest',string(result.PlanDigest), ...
    'EventFile',fullfile(fileparts(string(result.DataOutput)),'SinkEventTable.mat'),'Rows',rows);
plan.EventSHA256 = oxygenFileSHA256(plan.EventFile);
end

function values = label(values)
values = strip(string(values));
blank = ismissing(values) | ismember(lower(values),["","unspecified","unknown","nan"]);
values(blank) = "Unspecified";
end
