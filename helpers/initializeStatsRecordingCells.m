function RecordingCells = initializeStatsRecordingCells(NumRecordings)
%INITIALIZESTATSRECORDINGCELLS Create stats aggregation cell arrays.

RecordingCells = struct();
RecordingCells.ManualEvents = [];
RecordingCells.TableOxygenSinks = cell(NumRecordings,1);
RecordingCells.TableOxygenSinkEvents = cell(NumRecordings,1);
RecordingCells.HypoxicEventSpecificMetrics = cell(NumRecordings,1);
RecordingCells.TableOxygenSurges = cell(NumRecordings,1);
RecordingCells.TableOxygenSurgeEvents = cell(NumRecordings,1);
RecordingCells.ROIsTraces = cell(NumRecordings,6);
RecordingCells.SurgesArea = cell(NumRecordings,6);
RecordingCells.SinksArea = cell(NumRecordings,6);
RecordingCells.SinksTraces = cell(NumRecordings,6);
RecordingCells.BehaviourDataCombo = cell(NumRecordings,10);

end
