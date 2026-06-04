function [RecordingCells,StatsInfo] = loadStatsRecordingIntoCells( ...
    RecordingCells,StatsInfo,RecordingIndex,RecordingInput,MasterFolder,FolderSelection,UseCurated,ImagingMode,BehFs)
%LOADSTATSRECORDINGINTOCELLS Load one recording into stats aggregation cells.

RecordingInfo = createStatsRecordingSourceInfo(RecordingInput.Path,MasterFolder,FolderSelection.Mode, ...
    FolderSelection.Sinks,FolderSelection.Surges,FolderSelection.Behaviour);
RecordingFolder = RecordingInfo.Folder;
RecordingId = RecordingInfo.DatafileID;

RecordingMetadata = createStatsRecordingMetadata(RecordingId,RecordingInput.Mouse, ...
    RecordingInput.Condition,RecordingInput.DrugID,RecordingInput.Genotype, ...
    RecordingInput.Promoter,RecordingInput.Puff,RecordingInput.PixelSize,RecordingIndex);
BehaviourInputs = createStatsBehaviourInputs(RecordingInput.Posture,RecordingInput.Pupil, ...
    RecordingInput.Puff,RecordingInput.Whisking);
RecordingInfo.HasConfiguredBehaviourInputs = hasStatsBehaviourInputs(BehaviourInputs);
RecordingInfo.SinksMatFile = '';
RecordingInfo.SurgesMatFile = '';
RecordingInfo.HasSinks = false;
RecordingInfo.HasSurges = false;
RecordingInfo.HasBehaviourTraces = false;
RecordingInfo.HasROITraces = false;

if ~RecordingInfo.HasBehaviourData
    warning('No Behaviour output folders were found for recording %s in %s. Behaviour traces will be skipped.', ...
        RecordingId,RecordingFolder);
end
StatsInfo.Recordings(RecordingIndex) = RecordingInfo;

SinkData = loadStatsSinkRecordingData(RecordingInfo.SinksDataFolder,UseCurated,RecordingFolder,RecordingMetadata);
StatsInfo.Recordings(RecordingIndex).SinksMatFile = SinkData.MatFile;
StatsInfo.Recordings(RecordingIndex).HasSinks = SinkData.HasSinks;
[RecordingCells.TableOxygenSinks,RecordingCells.TableOxygenSinkEvents, ...
    RecordingCells.SinksArea,RecordingCells.SinksTraces] = storeStatsSinkRecordingData( ...
    RecordingCells.TableOxygenSinks,RecordingCells.TableOxygenSinkEvents, ...
    RecordingCells.SinksArea,RecordingCells.SinksTraces,RecordingIndex,SinkData);
if isfield(SinkData,'HypoxicEventSpecificMetrics')
    RecordingCells.HypoxicEventSpecificMetrics{RecordingIndex} = SinkData.HypoxicEventSpecificMetrics;
end

IncludeROITraces = strcmp(ImagingMode,'BLI');
SurgeData = loadStatsSurgeRecordingData(RecordingInfo.SurgesDataFolder,RecordingMetadata,IncludeROITraces);
StatsInfo.Recordings(RecordingIndex).SurgesMatFile = SurgeData.MatFile;
StatsInfo.Recordings(RecordingIndex).HasSurges = SurgeData.HasSurges;
[RecordingCells.TableOxygenSurges,RecordingCells.TableOxygenSurgeEvents, ...
    RecordingCells.SurgesArea,RecordingCells.ROIsTraces] = storeStatsSurgeRecordingData( ...
    RecordingCells.TableOxygenSurges,RecordingCells.TableOxygenSurgeEvents, ...
    RecordingCells.SurgesArea,RecordingCells.ROIsTraces,RecordingIndex,SurgeData,IncludeROITraces);
if IncludeROITraces && size(RecordingCells.ROIsTraces,2)>=6 && ~isempty(RecordingCells.ROIsTraces{RecordingIndex,6})
    StatsInfo.Recordings(RecordingIndex).HasROITraces = true;
end

if RecordingInfo.HasBehaviourData
    RecordingCells.BehaviourDataCombo(RecordingIndex,:) = loadStatsBehaviourRow( ...
        RecordingCells.BehaviourDataCombo(RecordingIndex,:),RecordingInfo.BehaviourDataFolder, ...
        RecordingFolder,RecordingId,BehaviourInputs,SinkData.RecordingDuration,BehFs);
    StatsInfo.Recordings(RecordingIndex).HasBehaviourTraces = any(~cellfun(@isempty, ...
        RecordingCells.BehaviourDataCombo(RecordingIndex,:)));
end
end
