function LoadedData = createStatsLoadedRecordingData(RecordingCells)
%CREATESTATSLOADEDRECORDINGDATA Combine loaded recording cells for stats.

LoadedData = struct();
LoadedData.TableOxygenSinks = vertcatCellTables(RecordingCells.TableOxygenSinks);
LoadedData.TableOxygenSinkEvents = vertcatCellTables(RecordingCells.TableOxygenSinkEvents);
LoadedData.HypoxicEventSpecificMetrics = vertcatCellTables(RecordingCells.HypoxicEventSpecificMetrics);
LoadedData.TableOxygenSurges = vertcatCellTables(RecordingCells.TableOxygenSurges);
LoadedData.TableOxygenSurgeEvents = vertcatCellTables(RecordingCells.TableOxygenSurgeEvents);
LoadedData.ROIsTraces = RecordingCells.ROIsTraces;
LoadedData.SurgesArea = RecordingCells.SurgesArea;
LoadedData.SinksTraces = RecordingCells.SinksTraces;
LoadedData.BehaviourDataCombo = RecordingCells.BehaviourDataCombo;
end
