function [TableOxygenSinks,TableOxygenSinkEvents,IncludedPocs] = applyStatsSinkCuration( ...
    TableOxygenSinks,TableOxygenSinkEvents,SinksMatFile,UseCurated,RecordingFolder)
%APPLYSTATSSINKCURATION Apply curated oxygen-sink inclusion filters.

IncludedPocs = [];
if ~strcmp(UseCurated,'Yes')
    return
end

IncludedPocs = loadOptionalMatVar(SinksMatFile,'Included_Pocs',[]);
if isempty(IncludedPocs)
    fprintf('No curated Oxygen sink data were found in data folder %s\n',RecordingFolder);
    return
end

TableOxygenSinks = TableOxygenSinks(IncludedPocs,:);
if ~isempty(TableOxygenSinkEvents)
    OriginalSinkIDs = includedPocsToOriginalSinkIDs(IncludedPocs);
    EventOriginalSinkID = TableOxygenSinkEvents.SinkID;
    KeepEvent = ismember(EventOriginalSinkID,OriginalSinkIDs);
    TableOxygenSinkEvents = TableOxygenSinkEvents(KeepEvent,:);
    EventOriginalSinkID = EventOriginalSinkID(KeepEvent);
    [~,RemappedSinkID] = ismember(EventOriginalSinkID,OriginalSinkIDs);
    TableOxygenSinkEvents.OriginalSinkID = EventOriginalSinkID;
    TableOxygenSinkEvents.SinkID = RemappedSinkID;
end
end

function OriginalSinkIDs = includedPocsToOriginalSinkIDs(IncludedPocs)

if islogical(IncludedPocs)
    OriginalSinkIDs = find(IncludedPocs);
else
    OriginalSinkIDs = IncludedPocs(:)';
end

end
