function output = exportAutomaticPocketTraces(plan,parent,decisions,confirmedOmissions,makeFigures,progress)
% Publish a complete result directory only after all selected sources pass.
if nargin<6, progress=[]; end
assert(isfolder(parent),'Choose an existing output folder.');
assert(~isempty(which('bwdist')) && ~isempty(which('tiffreadVolume')),'Image Processing Toolbox is required.');
rows = boiIntensityRows(plan.Rows,[]);
hashes = unique(rows.SourceSHA256,'stable');
if ~isempty(decisions)
    assert(ismember('SourceSHA256',decisions.Properties.VariableNames),'Decisions need a SourceSHA256 column.');
    ids = string(decisions.SourceSHA256);
    assert(numel(unique(ids))==numel(ids) && all(ismember(ids,hashes)),'Duplicate or unknown source decision.');
    for k = 1:height(decisions)
        take = rows.SourceSHA256==ids(k);
        if ismember('Mouse',decisions.Properties.VariableNames)
            name = strip(string(decisions.Mouse(k)));
            if ~ismissing(name) && name~="", rows.Mouse(take)=name; end
        end
        if ismember('RawFile',decisions.Properties.VariableNames)
            file = string(decisions.RawFile(k));
            if ~ismissing(file) && file~=""
                assert(isfile(file) && strcmpi(oxygenFileSHA256(file),ids(k)), ...
                    'OxygenDynamics:PocketSource','Selected TIFF does not match the recorded SHA-256.');
                rows.VerifiedRawFile(take) = file;
                rows.SourceStatus(take) = "TIFF verified";
            end
        end
    end
end
missing = unique(rows.SourceSHA256(rows.VerifiedRawFile==""));
assert(isequal(sort(unique(confirmedOmissions(:))),sort(missing(:))), ...
    'OxygenDynamics:PocketOmission','Locate or retry missing TIFFs, or explicitly confirm exactly the listed omissions.');
rows.Omitted = ismember(rows.SourceSHA256,missing);
keep = ~rows.Omitted;
assert(any(keep),'OxygenDynamics:PocketOmission','At least one source TIFF must be available.');
assert(all(~ismissing(rows.Mouse(keep)) & strlength(rows.Mouse(keep))>0), ...
    'OxygenDynamics:PocketIdentity','Confirm the mouse ID for each conflicting source before export.');
current = load(fullfile(plan.ExportFolder,'BatchStatsSelection.mat'),'Plan');
assert(strcmp(plan.SelectionDigest,current.Plan.Digest) && strcmp(boiBatchQueueDigest(rmfield(current.Plan,'Digest')),current.Plan.Digest), ...
    'OxygenDynamics:PocketSelection','The source export changed after preview.');
assert(strcmp(plan.EventSHA256,oxygenFileSHA256(plan.EventFile)),'The saved sink table changed after preview.');
saved = load(plan.EventFile,'Table_OxygenSinkEvents_OutCombo');
E = saved.Table_OxygenSinkEvents_OutCombo;
assert(all(ismember(string(E.RecordingID),string(rows.RecordingID))),'Event table contains unselected recording IDs.');
E.PocketKey = (1:height(E))';
stage = string(tempname(parent));
[ok,msg]=mkdir(stage); assert(ok,'%s',msg);
guard = onCleanup(@()removeStage(stage)); %#ok<NASGU>
mkdir(fullfile(stage,'Trace_exports'));
rawCSV = fullfile(stage,'Trace_exports','All_pocket_traces.csv');
n = height(rows);
rows.DistinctSource = false(n,1);
rows.GeometryFile = strings(n,1);
rows.TraceFile = strings(n,1);
rows.AuditSHA256 = strings(n,1);
conditions = unique(rows.Condition(keep),'stable');
folders = compose("condition_%03d",(1:numel(conditions))');
index = table(conditions,folders,'VariableNames',{'Condition','Folder'});
writetable(index,fullfile(stage,'Conditions.csv'));
eventsByCondition = cell(height(index),1);
for ci = 1:height(index)
    condition = index.Condition(ci);
    dest = fullfile(stage,index.Folder(ci));
    mkdir(dest); mkdir(fullfile(dest,'recordings'));
    members = find(keep & rows.Condition==condition);
    movieHashes = unique(rows.SourceSHA256(members),'stable');
    eventParts = cell(numel(movieHashes),1);
    traceParts = cell(numel(movieHashes),1);
    for j = 1:numel(movieHashes)
        hash = movieHashes(j);
        aliases = find(rows.SourceSHA256==hash);
        k = aliases(1);
        message=sprintf('Automatic pocket traces: %s | %s | movie %d of %d',condition,rows.Mouse(k),j,numel(movieHashes));
        fprintf('%s\n',message);
        if ~isempty(progress), progress(message); end
        [R,e,match] = auditEvents(rows(k,:),E);
        rows.AuditSHA256(k)=string(R.AuditSHA256);
        for pos = 2:numel(aliases)
            a = aliases(pos);
            [other,otherEvents] = auditEvents(rows(a,:),E);
            verifyDuplicate(R,other,e,otherEvents);
            rows.AuditSHA256(a)=string(other.AuditSHA256);
            clear other otherEvents
        end
        file = rows.VerifiedRawFile(k);
        assert(strcmpi(oxygenFileSHA256(file),hash),'OxygenDynamics:PocketSource','TIFF changed since preview: %s',file);
        [events,frames,geom] = nearbyMeasure(R,e,match,file);
        calibrated=boiIntensityRows(rows(aliases,:),geom.IntensityCalibration);
        rows(aliases,:)=calibrated;
        assert(strcmpi(oxygenFileSHA256(file),hash),'OxygenDynamics:PocketSource','TIFF changed during extraction: %s',file);
        events.Mouse(:) = rows.Mouse(k);
        events.Group(:) = rows.Group(k);
        events.SourceSHA256(:) = hash;
        events.Condition = repmat(condition,height(events),1);
        events.RecordingID = repmat(string(rows.RecordingID(k)),height(events),1);
        events.PocketSet = repmat("Automatic",height(events),1);
        stem = fullfile("recordings","source_"+hash);
        rows.DistinctSource(k) = true;
        rows.GeometryFile(aliases) = stem+"_geometry.mat";
        rows.TraceFile(aliases) = stem+"_traces.csv";
        save(fullfile(dest,rows.GeometryFile(k)),'geom');
        writetable(frames,fullfile(dest,rows.TraceFile(k)));
        eventParts{j} = events;
        traceParts{j} = frames(:,{'PocketKey','FromOnset_s','FromOffset_s','PocketPct','NearPct','FarPct', ...
            'TissueOnlyPocketPct','PocketBaselineFlagged','NearPotentialEventDuringBaseline','NearPotentialEvent','AfterNextSameSiteSink'});
    end
    events = vertcat(eventParts{:});
    traces = vertcat(traceParts{:});
    writetable(events,fullfile(dest,'Pocket_index.csv'));
    writetable(rows(members,:),fullfile(dest,'Recording_sources.csv'));
    if ~isempty(progress), progress("Summarizing traces and writing figures for "+condition+"…"); end
    nearbySummaries(events,traces,dest,condition);
    exportPocketTraceFigures(dest,dest,MakeFigures=makeFigures,CombinedCSV=rawCSV,Condition=condition);
    if makeFigures && ~isempty(events), nearbyFigures(dest,condition); end
    rows.GeometryFile(members) = fullfile(index.Folder(ci),rows.GeometryFile(members));
    rows.TraceFile(members) = fullfile(index.Folder(ci),rows.TraceFile(members));
    eventsByCondition{ci} = events;
end
events = vertcat(eventsByCondition{:});
assert(numel(unique(events.PocketKey))==height(events),'Duplicate pocket keys in output.');
writetable(events,fullfile(stage,'Pocket_index.csv'));
writetable(rows,fullfile(stage,'Recording_sources.csv'));
writetable(boiIntensitySummary(rows(rows.DistinctSource,:)),fullfile(stage,'Camera_offset_summary.csv'));
writetable(rows(rows.Omitted,:),fullfile(stage,'Omitted_recordings.csv'));
mapping = rows(rows.DistinctSource,{'SourceSHA256','Mouse'});
mapping.SelectionDigest = repmat(plan.SelectionDigest,height(mapping),1);
writetable(mapping,fullfile(stage,'Mouse_identity_map.csv'));
settings = struct('Schema','automatic-pocket-traces-1','SelectionDigest',plan.SelectionDigest, ...
    'SourceExport',plan.ExportFolder,'EventTableSHA256',plan.EventSHA256,'PocketSet','Automatic', ...
    'Alignment','Saved automatic measurement start and end frames, inclusive', ...
    'BaselineSeconds',20,'PostOffsetSeconds',60,'NearbyUm',[10 30],'FarUm',[30 50], ...
    'BootstrapReplicates',20000,'BootstrapSeed',42771,'Software',getOxygenPipelineVersion());
settingsFile=fullfile(stage,'AnalysisSettings.json');
writeBOIRunJSON(settingsFile,settings);
receipt=jsondecode(fileread(settingsFile));
assert(strcmp(receipt.Schema,settings.Schema) && strcmp(receipt.EventTableSHA256,settings.EventTableSHA256), ...
    'OxygenDynamics:PocketWrite','Could not verify the staged analysis settings.');
output = fullfile(parent,"Automatic_PocketTraces_"+string(java.util.UUID.randomUUID()));
java.nio.file.Files.move(java.io.File(char(stage)).toPath(),java.io.File(char(output)).toPath(),javaArray('java.nio.file.CopyOption',0));
end

function [R,e,match] = auditEvents(row,E)
R = loadBOIEventReview(row.AuditFile);
assert(strcmpi(R.AnalysisInfo.RawSHA256,row.SourceSHA256),'The saved audit source changed after preview.');
e = E(string(E.RecordingID)==string(row.RecordingID),:);
[e,match] = nearbyMatchEvents(R,e);
end

function removeStage(stage)
if isfolder(stage), rmdir(stage,'s'); end
end

function verifyDuplicate(first,second,e1,e2)
keys={'EventType','SiteID','EventID'};
cols=[keys,{'StartFrame','EndFrame','DetectedStartFrame','DetectedEndFrame'}];
[a,ia]=sortrows(first.Audit(:,cols),keys); [b,ib]=sortrows(second.Audit(:,cols),keys);
i=first.AnalysisInfo; j=second.AnalysisInfo;
refs={'SinkID','EventID','EventReferenceKind','EventReferenceValue','EventReferenceNeedsReview','EventReferenceStartFrame','EventReferenceEndFrame'};
assert(isequal(boiCameraOffset(i),boiCameraOffset(j)) && isequal(a,b) && isequal(i.FrameSize,j.FrameSize) && i.NFrames==j.NFrames && ...
    i.AnalysisParams.fs==j.AnalysisParams.fs && i.AnalysisParams.PixelSize==j.AnalysisParams.PixelSize && ...
    isequal(sort(i.SinkEligibleTissuePixels(:)),sort(j.SinkEligibleTissuePixels(:))) && ...
    isequaln(sortrows(e1(:,refs),refs(1:2)),sortrows(e2(:,refs),refs(1:2))), ...
    'OxygenDynamics:PocketDuplicate','Repeated TIFF has different event bounds, tissue support, camera offset, scale or references.');
for k=1:numel(ia)
    assert(isequal(sort(first.Traces{ia(k)}.Footprint(:)),sort(second.Traces{ib(k)}.Footprint(:))), ...
        'OxygenDynamics:PocketDuplicate','Repeated TIFF has different event footprints.');
end
end
