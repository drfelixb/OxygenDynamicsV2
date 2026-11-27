function [RecordingCells,StatsInfo] = loadStatsRecordingIntoCells( ...
    RecordingCells,StatsInfo,RecordingIndex,RecordingInput,MasterFolder,FolderSelection,UseCurated,ImagingMode,BehFs)
%LOADSTATSRECORDINGINTOCELLS Load one recording into stats aggregation cells.

savedSources=[];
if isfield(RecordingInput,'SavedSources'),savedSources=RecordingInput.SavedSources;end
RecordingInfo = createStatsRecordingSourceInfo(RecordingInput.Path,MasterFolder,FolderSelection.Mode, ...
    FolderSelection.Sinks,FolderSelection.Surges,FolderSelection.Behaviour,savedSources);
RecordingFolder = RecordingInfo.Folder;
RecordingId = RecordingInfo.DatafileID;

RecordingMetadata = createStatsRecordingMetadata(RecordingId,RecordingInput.Mouse, ...
    RecordingInput.Condition,RecordingInput.DrugID,RecordingInput.Genotype, ...
    RecordingInput.Promoter,RecordingInput.Puff,RecordingInput.PixelSize,RecordingIndex);
RecordingMetadata.RecordingID = char(java.io.File(RecordingFolder).getCanonicalPath());
if isfield(RecordingInput,'RecordingID') && strlength(string(RecordingInput.RecordingID))>0
    RecordingMetadata.RecordingID = char(string(RecordingInput.RecordingID));
end
assert(isfield(RecordingInput,'SampleF') && isfinite(RecordingInput.SampleF) && RecordingInput.SampleF>0, ...
    'OxygenDynamics:MissingSampleRate','A positive recording SampleF is required.');
RecordingMetadata.SampleF = RecordingInput.SampleF;
BehaviourInputs = createStatsBehaviourInputs(RecordingInput.Posture,RecordingInput.Pupil, ...
    RecordingInput.Puff,RecordingInput.Whisking);
RecordingInfo.HasConfiguredBehaviourInputs = hasStatsBehaviourInputs(BehaviourInputs);
RecordingInfo.HasSinks = false;
RecordingInfo.HasSurges = false;
RecordingInfo.HasBehaviourTraces = false;
RecordingInfo.HasROITraces = false;

if ~RecordingInfo.HasBehaviourData
    warning('No Behaviour output folders were found for recording %s in %s. Behaviour traces will be skipped.', ...
        RecordingId,RecordingFolder);
end
StatsInfo.Recordings(RecordingIndex) = RecordingInfo;

SinkData = loadStatsSinkRecordingData(RecordingInfo.SinksDataFolder,UseCurated,RecordingFolder,RecordingMetadata,RecordingInfo.SinksMatFile);
SourceInfo=loadRequiredMatVar(SinkData.MatFile,'AnalysisInfo');
validateOxygenSourceFiles(SourceInfo,RecordingFolder);
StatsInfo.Recordings(RecordingIndex).SinksMatFile = SinkData.MatFile;
StatsInfo.Recordings(RecordingIndex).HasSinks = SinkData.HasSinks;
IncludeROITraces = strcmp(ImagingMode,'BLI');
SurgeData = loadStatsSurgeRecordingData(RecordingInfo.SurgesDataFolder,RecordingMetadata,IncludeROITraces,RecordingInfo.SurgesMatFile);
SurgeInfo=loadRequiredMatVar(SurgeData.MatFile,'AnalysisInfo');
assert(strcmp(SourceInfo.RawSHA256,SurgeInfo.RawSHA256) && strcmp(SourceInfo.DenoisedSHA256,SurgeInfo.DenoisedSHA256), ...
    'OxygenDynamics:MixedSourceRuns','Sink and surge outputs refer to different source data. Rerun the master.');
assert(isequal(boiCameraOffset(SourceInfo),boiCameraOffset(SurgeInfo)),'OxygenDynamics:MixedSourceRuns','Sink and surge camera offsets differ.');
SinkData.EventTable=boiIntensityRows(SinkData.EventTable,SourceInfo);
SurgeData.EventTable=boiIntensityRows(SurgeData.EventTable,SurgeInfo);
if strcmp(ImagingMode,'BLI')
    SinkData.EventTable=attachSavedBOIEpisodeReferences(SinkData.EventTable, ...
        SinkData.MatFile,SurgeData.MatFile,RecordingFolder,RecordingMetadata.SampleF);
end
[RecordingCells.TableOxygenSinks,RecordingCells.TableOxygenSinkEvents, ...
    RecordingCells.SinksArea,RecordingCells.SinksTraces] = storeStatsSinkRecordingData( ...
    RecordingCells.TableOxygenSinks,RecordingCells.TableOxygenSinkEvents, ...
    RecordingCells.SinksArea,RecordingCells.SinksTraces,RecordingIndex,SinkData);
if isfield(SinkData,'HypoxicEventSpecificMetrics')
    RecordingCells.HypoxicEventSpecificMetrics{RecordingIndex} = SinkData.HypoxicEventSpecificMetrics;
end
StatsInfo.Recordings(RecordingIndex).SurgesMatFile = SurgeData.MatFile;
StatsInfo.Recordings(RecordingIndex).HasSurges = SurgeData.HasSurges;
[RecordingCells.TableOxygenSurges,RecordingCells.TableOxygenSurgeEvents, ...
    RecordingCells.SurgesArea,RecordingCells.ROIsTraces] = storeStatsSurgeRecordingData( ...
    RecordingCells.TableOxygenSurges,RecordingCells.TableOxygenSurgeEvents, ...
    RecordingCells.SurgesArea,RecordingCells.ROIsTraces,RecordingIndex,SurgeData,IncludeROITraces);
if IncludeROITraces && size(RecordingCells.ROIsTraces,2)>=6 && ~isempty(RecordingCells.ROIsTraces{RecordingIndex,6})
    StatsInfo.Recordings(RecordingIndex).HasROITraces = true;
end

RecordingCells.RecordingRegistry{RecordingIndex} = createAnalysisRecordingRow(RecordingMetadata,SinkData,SurgeData);

if RecordingInfo.HasBehaviourData
    RecordingCells.BehaviourDataCombo(RecordingIndex,:) = loadStatsBehaviourRow( ...
        RecordingCells.BehaviourDataCombo(RecordingIndex,:),RecordingInfo.BehaviourDataFolder, ...
        RecordingFolder,RecordingId,BehaviourInputs,SinkData.RecordingDuration,BehFs);
    StatsInfo.Recordings(RecordingIndex).HasBehaviourTraces = any(~cellfun(@isempty, ...
        RecordingCells.BehaviourDataCombo(RecordingIndex,:)));
end
end
