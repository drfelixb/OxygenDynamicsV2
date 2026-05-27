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
    TableOxygenSinkEvents = TableOxygenSinkEvents(IncludedPocs(TableOxygenSinkEvents.SinkID),:);
end
end
