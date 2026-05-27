function [SinkTables,SinkEventTables,SinkAreas,SinkTraces] = storeStatsSinkRecordingData( ...
    SinkTables,SinkEventTables,SinkAreas,SinkTraces,RecordingIndex,SinkData)
%STORESTATSSINKRECORDINGDATA Store one recording's prepared sink data.

if ~SinkData.HasSinks
    return
end

SinkTables{RecordingIndex}=SinkData.Table;
if ~isempty(SinkData.EventTable)
    SinkEventTables{RecordingIndex}=SinkData.EventTable;
end
SinkAreas(RecordingIndex,:)=SinkData.AreaRow;
SinkTraces(RecordingIndex,:)=SinkData.TraceRow;
end
