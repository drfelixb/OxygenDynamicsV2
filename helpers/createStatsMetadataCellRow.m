function CellRow = createStatsMetadataCellRow(RecordingMetadata,DataValue)
%CREATESTATSMETADATACELLROW Create a stats cell row with recording metadata.

CellRow = {RecordingMetadata.DatafileID,RecordingMetadata.Mouse, ...
    RecordingMetadata.Condition,RecordingMetadata.DrugID, ...
    RecordingMetadata.PuffStim,DataValue};
end
