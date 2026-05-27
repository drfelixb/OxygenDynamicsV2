function StatsDataOutput = createStatsDataOutput(CoreData,IsBLI,BLIData)
%CREATESTATSDATAOUTPUT Build the legacy DataOutput.mat field struct.

if nargin<3 || isempty(BLIData)
    BLIData = struct();
end

StatsDataOutput = struct();
StatsDataOutput.Table_OxygenSurges_OutCombo = CoreData.TableOxygenSurges;
StatsDataOutput.Table_OxygenSurgeEvents_OutCombo = CoreData.TableOxygenSurgeEvents;
StatsDataOutput.Table_OxygenSinks_OutCombo = CoreData.TableOxygenSinks;
StatsDataOutput.Table_OxygenSinkEvents_OutCombo = CoreData.TableOxygenSinkEvents;
StatsDataOutput.FiltersOxySinksMetrics = CoreData.FiltersOxySinksMetrics;
StatsDataOutput.FiltersOxySurgesMetrics = CoreData.FiltersOxySurgesMetrics;
StatsDataOutput.Filters_ROIsandEvents = CoreData.FiltersROIsAndEvents;
StatsDataOutput.ExportTraces = CoreData.ExportTraces;
StatsDataOutput.NumOngoingOxysinks = CoreData.NumOngoingOxysinks;
StatsDataOutput.NumOngoingOxysinksPerMm2 = CoreData.NumOngoingOxysinksPerMm2;
StatsDataOutput.SinkCountAreaNormalization = CoreData.SinkCountAreaNormalization;
StatsDataOutput.TotalSinkArea_Norm = CoreData.TotalSinkAreaNorm;
StatsDataOutput.NumOngoingOxysurges = CoreData.NumOngoingOxysurges;
StatsDataOutput.TotalSurgeArea = CoreData.TotalSurgeArea;
StatsDataOutput.SinksRaster = CoreData.SinksRaster;
StatsDataOutput.SurgesRaster = CoreData.SurgesRaster;
StatsDataOutput.StatsInfo = CoreData.StatsInfo;
if isfield(CoreData,'HypoxicBurden')
    StatsDataOutput.HypoxicBurden = CoreData.HypoxicBurden;
end

if IsBLI
    StatsDataOutput.Behaviour_data_combo = BLIData.BehaviourDataCombo;
    StatsDataOutput.Behaviouraldatalogical = BLIData.BehaviourLogicals;
    StatsDataOutput.ROIs_Traces = BLIData.ROIsTraces;
    StatsDataOutput.ExportTraceCorrs = BLIData.ExportTraceCorrs;
    StatsDataOutput.TraceCorrs = BLIData.TraceCorrs;
end

end
