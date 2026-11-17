function [SinkTable,SinkEventTable,RecordingDuration,HasSinks] = prepareStatsSinkTables( ...
    SinkTable,SinkEventTable,RecordingMetadata)
%PREPARESTATSSINKTABLES Select schema, add metadata, and backfill events.

RecordingDuration = nan;
HasSinks = size(SinkTable,1)>0;


SinkTable = selectStatsSinkSummaryColumns(SinkTable);
SinkTable = addStatsRecordingMetadata(SinkTable,RecordingMetadata,'RecDuration');
if HasSinks, RecordingDuration = SinkTable.RecDuration{end}; end

if istable(SinkEventTable)
    SinkEventTable = refreshStatsEventMetadata(SinkEventTable,RecordingMetadata);
end
end
