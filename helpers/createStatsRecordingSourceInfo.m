function RecordingInfo = createStatsRecordingSourceInfo(PathValue,MasterFolder,SelectionMode,SinkSelectionAge,SurgeSelectionAge,BehaviourSelectionAge)
%CREATESTATSRECORDINGSOURCEINFO Resolve per-recording stats source folders.

RecordingFolder = makeFullRecordingPath(PathValue,MasterFolder);
[~,DatafileID] = fileparts(RecordingFolder);

SinksDataFolder = selectStatsOutputFolder(RecordingFolder,'OxygenSinks_Output',SelectionMode, ...
    SinkSelectionAge,'oxygen sinks','required',true,'recordingId',DatafileID);
SurgesDataFolder = selectStatsOutputFolder(RecordingFolder,'OxygenSurges',SelectionMode, ...
    SurgeSelectionAge,'oxygen surges','required',true,'recordingId',DatafileID);
[BehaviourDataFolder,HasBehaviourData] = selectStatsOutputFolder(RecordingFolder,'Behaviour',SelectionMode, ...
    BehaviourSelectionAge,'behavioural','required',false,'recordingId',DatafileID);

RecordingInfo = struct();
RecordingInfo.Path = PathValue;
RecordingInfo.Folder = RecordingFolder;
RecordingInfo.DatafileID = DatafileID;
RecordingInfo.SinksDataFolder = SinksDataFolder;
RecordingInfo.SurgesDataFolder = SurgesDataFolder;
RecordingInfo.BehaviourDataFolder = BehaviourDataFolder;
RecordingInfo.HasBehaviourData = HasBehaviourData;
end
