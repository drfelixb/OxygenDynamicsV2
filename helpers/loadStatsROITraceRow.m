function ROITraceRow = loadStatsROITraceRow(SurgesMatFile,RecordingMetadata)
%LOADSTATSROITRACEROW Load BLI ROI traces as a stats metadata row.

MeanROITraceZ = loadRequiredMatVar(SurgesMatFile,'Mean_ROI_TraceZ');
ROITraceRow = createStatsMetadataCellRow(RecordingMetadata,MeanROITraceZ);
end
