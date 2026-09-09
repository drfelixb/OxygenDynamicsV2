function [SurgeTable,SurgeEventTable,HasSurges] = prepareStatsSurgeTables(SurgeTable,SurgeEventTable,RecordingMetadata)
%PREPARESTATSSURGETABLES Select schema, add metadata, and backfill events.

HasSurges = size(SurgeTable,1)>0;


SurgeTable = selectStatsSurgeSummaryColumns(SurgeTable);
SurgeTable = addStatsRecordingMetadata(SurgeTable,RecordingMetadata,'RecDuration_Surge');

if istable(SurgeEventTable)
    SurgeEventTable = refreshStatsEventMetadata(SurgeEventTable,RecordingMetadata);
end
end
