function [SinkTables,SinkEventTables,SinkAreas,SinkTraces] = storeStatsSinkRecordingData( ...
    SinkTables,SinkEventTables,SinkAreas,SinkTraces,RecordingIndex,SinkData)
%STORESTATSSINKRECORDINGDATA Store one recording's prepared sink data.



SinkTables{RecordingIndex}=SinkData.Table;
if istable(SinkData.EventTable)
    SinkEventTables{RecordingIndex}=SinkData.EventTable;
end
SinkAreas(RecordingIndex,:)=SinkData.AreaRow;
SinkTraces(RecordingIndex,:)=SinkData.TraceRow;
end
