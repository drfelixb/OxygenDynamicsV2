function CoreData = createStatsCoreData(TableOxygenSurges,TableOxygenSurgeEvents, ...
    TableOxygenSinks,TableOxygenSinkEvents,FiltersOxySinksMetrics,FiltersOxySurgesMetrics, ...
    FiltersROIsAndEvents,ExportTraces,NumOngoingOxysinks,NumOngoingOxysinksPerMm2, ...
    SinkCountAreaNormalization,TotalSinkAreaNorm, ...
    NumOngoingOxysurges,TotalSurgeArea,SinksRaster,SurgesRaster,StatsInfo)
%CREATESTATSCOREDATA Bundle common stats outputs before legacy MAT export.

CoreData = struct();
CoreData.TableOxygenSurges = TableOxygenSurges;
CoreData.TableOxygenSurgeEvents = TableOxygenSurgeEvents;
CoreData.TableOxygenSinks = TableOxygenSinks;
CoreData.TableOxygenSinkEvents = TableOxygenSinkEvents;
CoreData.HypoxicEventSpecificMetrics = table();
CoreData.FiltersOxySinksMetrics = FiltersOxySinksMetrics;
CoreData.FiltersOxySurgesMetrics = FiltersOxySurgesMetrics;
CoreData.FiltersROIsAndEvents = FiltersROIsAndEvents;
CoreData.ExportTraces = ExportTraces;
CoreData.NumOngoingOxysinks = NumOngoingOxysinks;
CoreData.NumOngoingOxysinksPerMm2 = NumOngoingOxysinksPerMm2;
CoreData.SinkCountAreaNormalization = SinkCountAreaNormalization;
CoreData.TotalSinkAreaNorm = TotalSinkAreaNorm;
CoreData.NumOngoingOxysurges = NumOngoingOxysurges;
CoreData.TotalSurgeArea = TotalSurgeArea;
CoreData.SinksRaster = SinksRaster;
CoreData.SurgesRaster = SurgesRaster;
CoreData.StatsInfo = StatsInfo;
end
