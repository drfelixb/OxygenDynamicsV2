function [SinkAreaRow,SinkTraceRow] = loadStatsSinkArrayRows(SinksMatFile,IncludedPocs,RecordingMetadata)
%LOADSTATSSINKARRAYROWS Load curated sink area and trace rows for stats.

OxySinkAreaAll = loadRequiredMatVar(SinksMatFile,'OxySinkArea_all');
MeanOxySinkTraceConvo = loadRequiredMatVar(SinksMatFile,'Mean_OxySink_Trace_Convo');

if ~isempty(IncludedPocs)
    OxySinkAreaAll = OxySinkAreaAll(IncludedPocs,:);
    MeanOxySinkTraceConvo = MeanOxySinkTraceConvo(IncludedPocs,:);
end

SinkAreaRow = createStatsMetadataCellRow(RecordingMetadata,OxySinkAreaAll);
SinkTraceRow = createStatsMetadataCellRow(RecordingMetadata,MeanOxySinkTraceConvo);
end
