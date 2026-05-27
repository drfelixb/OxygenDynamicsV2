function SurgeData = loadStatsSurgeRecordingData(SurgesDataFolder,RecordingMetadata,IncludeROITraces)
%LOADSTATSSURGERECORDINGDATA Load and prepare surge stats for one recording.

SurgesMatFile = selectStatsMatFile(SurgesDataFolder,'Surges','oxygen surges',RecordingMetadata.DatafileID);
SurgeTable = loadRequiredMatVar(SurgesMatFile,'Table_OxygenSurges_Out');
SurgeEventTable = loadOptionalMatVar(SurgesMatFile,'Table_OxygenSurgeEvents_Out',[]);
[SurgeTable,SurgeEventTable,HasSurges] = prepareStatsSurgeTables( ...
    SurgeTable,SurgeEventTable,RecordingMetadata);

SurgeData = struct();
SurgeData.MatFile = SurgesMatFile;
SurgeData.Table = SurgeTable;
SurgeData.EventTable = SurgeEventTable;
SurgeData.HasSurges = HasSurges;
SurgeData.AreaRow = [];
SurgeData.ROITraceRow = [];

if HasSurges
    [SurgeData.AreaRow,~] = loadStatsSurgeArrayRows(SurgesMatFile,RecordingMetadata,false);
end

if IncludeROITraces
    SurgeData.ROITraceRow = loadStatsROITraceRow(SurgesMatFile,RecordingMetadata);
end
end
