function [SurgeTable,SurgeEventTable,HasSurges] = prepareStatsSurgeTables(SurgeTable,SurgeEventTable,RecordingMetadata)
%PREPARESTATSSURGETABLES Select schema, add metadata, and backfill events.

HasSurges = size(SurgeTable,1)>0;
if ~HasSurges
    return
end

SurgeTable = selectStatsSurgeSummaryColumns(SurgeTable);
SurgeTable = addStatsRecordingMetadata(SurgeTable,RecordingMetadata,'RecDuration_Surge');

if ~isempty(SurgeEventTable)
    SurgeEventTable = ensureStatsEventPuffStim(SurgeEventTable,RecordingMetadata.PuffStim);
end
end
