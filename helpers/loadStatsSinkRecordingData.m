function SinkData = loadStatsSinkRecordingData(SinksDataFolder,UseCurated,RecordingFolder,RecordingMetadata)
%LOADSTATSSINKRECORDINGDATA Load and prepare sink stats for one recording.

SinksMatFile = selectStatsMatFile(SinksDataFolder,'Urefined','Urefined oxygen sink',RecordingMetadata.DatafileID);
SinkTable = loadRequiredMatVar(SinksMatFile,'Table_OxygenSinks_Out');
SinkEventTable = loadOptionalMatVar(SinksMatFile,'Table_OxygenSinkEvents_Out',[]);

[SinkTable,SinkEventTable,IncludedPocs] = applyStatsSinkCuration( ...
    SinkTable,SinkEventTable,SinksMatFile,UseCurated,RecordingFolder);
[SinkTable,SinkEventTable,RecordingDuration,HasSinks] = prepareStatsSinkTables( ...
    SinkTable,SinkEventTable,RecordingMetadata);

SinkData = struct();
SinkData.MatFile = SinksMatFile;
SinkData.Table = SinkTable;
SinkData.EventTable = SinkEventTable;
SinkData.RecordingDuration = RecordingDuration;
SinkData.HasSinks = HasSinks;
SinkData.AreaRow = [];
SinkData.TraceRow = [];
SinkData.HypoxicEventSpecificMetrics = [];

if HasSinks
    [SinkData.AreaRow,SinkData.TraceRow] = loadStatsSinkArrayRows( ...
        SinksMatFile,IncludedPocs,RecordingMetadata);
    SinkData.HypoxicEventSpecificMetrics = createHypoxicEventSpecificMetrics( ...
        SinksDataFolder,SinksMatFile,SinkTable,IncludedPocs,RecordingMetadata);
end
end
