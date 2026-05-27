function [SurgeTables,SurgeEventTables,SurgeAreas,ROITraces] = storeStatsSurgeRecordingData( ...
    SurgeTables,SurgeEventTables,SurgeAreas,ROITraces,RecordingIndex,SurgeData,IncludeROITraces)
%STORESTATSSURGERECORDINGDATA Store one recording's prepared surge data.

if SurgeData.HasSurges
    SurgeTables{RecordingIndex}=SurgeData.Table;
    if ~isempty(SurgeData.EventTable)
        SurgeEventTables{RecordingIndex}=SurgeData.EventTable;
    end
    SurgeAreas(RecordingIndex,:)=SurgeData.AreaRow;
end

if IncludeROITraces
    ROITraces(RecordingIndex,1:6)=SurgeData.ROITraceRow;
end
end
