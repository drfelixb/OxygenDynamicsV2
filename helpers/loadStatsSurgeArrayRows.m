function [SurgeAreaRow,ROITraceRow] = loadStatsSurgeArrayRows(SurgesMatFile,RecordingMetadata,IncludeROITraces)
%LOADSTATSSURGEARRAYROWS Load surge area and optional ROI trace rows.

OxySurgeAreaAll = loadRequiredMatVar(SurgesMatFile,'OxySurgeArea_all');
SurgeAreaRow = createStatsMetadataCellRow(RecordingMetadata,OxySurgeAreaAll);

if IncludeROITraces
    ROITraceRow = loadStatsROITraceRow(SurgesMatFile,RecordingMetadata);
else
    ROITraceRow = [];
end
end
