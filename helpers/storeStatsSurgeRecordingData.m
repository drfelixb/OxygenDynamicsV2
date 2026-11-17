function [SurgeTables,SurgeEventTables,SurgeAreas,ROITraces] = storeStatsSurgeRecordingData( ...
    SurgeTables,SurgeEventTables,SurgeAreas,ROITraces,RecordingIndex,SurgeData,IncludeROITraces)
%STORESTATSSURGERECORDINGDATA Store one recording's prepared surge data.

if true
    SurgeTables{RecordingIndex}=SurgeData.Table;
    if istable(SurgeData.EventTable)
        SurgeEventTables{RecordingIndex}=SurgeData.EventTable;
    end
    SurgeAreas(RecordingIndex,:)=SurgeData.AreaRow;
end

if IncludeROITraces
    ROITraces(RecordingIndex,1:6)=SurgeData.ROITraceRow;
end
end
