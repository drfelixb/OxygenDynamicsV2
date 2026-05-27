function [SinkTable,SinkEventTable,RecordingDuration,HasSinks] = prepareStatsSinkTables( ...
    SinkTable,SinkEventTable,RecordingMetadata)
%PREPARESTATSSINKTABLES Select schema, add metadata, and backfill events.

RecordingDuration = nan;
HasSinks = size(SinkTable,1)>0;
if ~HasSinks
    return
end

SinkTable = selectStatsSinkSummaryColumns(SinkTable);
SinkTable = addStatsRecordingMetadata(SinkTable,RecordingMetadata,'RecDuration');
RecordingDuration = SinkTable.RecDuration{end};

if ~isempty(SinkEventTable)
    SinkEventTable = ensureStatsEventPuffStim(SinkEventTable,RecordingMetadata.PuffStim);
end
end
