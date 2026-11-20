function RecordingInfo = createStatsRecordingSourceInfo(PathValue,MasterFolder,SelectionMode,SinkSelectionAge,SurgeSelectionAge,BehaviourSelectionAge,SavedSources)
%CREATESTATSRECORDINGSOURCEINFO Resolve per-recording stats source folders.

RecordingFolder = makeFullRecordingPath(PathValue,MasterFolder);
[~,DatafileID] = fileparts(RecordingFolder);

SinksMatFile='';SurgesMatFile='';
if nargin>=7&&~isempty(SavedSources)
    assert(isstruct(SavedSources)&&isscalar(SavedSources)&& ...
        all(isfield(SavedSources,{'RecordingFolder','SinkMaster','SurgeMaster'})), ...
        'OxygenDynamics:StatsSavedSource','Supply exact saved recording and master paths.');
    assert(strcmp(canonical(RecordingFolder),canonical(SavedSources.RecordingFolder)), ...
        'OxygenDynamics:StatsSavedSource','Saved source selection belongs to another recording.');
    SinksMatFile=checkedMaster(SavedSources.SinkMaster,RecordingFolder);
    SurgesMatFile=checkedMaster(SavedSources.SurgeMaster,RecordingFolder);
    SinksDataFolder=fileparts(SinksMatFile);SurgesDataFolder=fileparts(SurgesMatFile);
    % The BOI queue has no behavioural/stimulation analysis request. Do not
    % discover auxiliary outputs or infer a protocol while collecting results.
    BehaviourDataFolder='';HasBehaviourData=false;
else
SinksDataFolder = selectStatsOutputFolder(RecordingFolder,'OxygenSinks_Output',SelectionMode, ...
    SinkSelectionAge,'oxygen sinks','required',true,'recordingId',DatafileID);
SurgesDataFolder = selectStatsOutputFolder(RecordingFolder,'OxygenSurges',SelectionMode, ...
    SurgeSelectionAge,'oxygen surges','required',true,'recordingId',DatafileID);
[BehaviourDataFolder,HasBehaviourData] = selectStatsOutputFolder(RecordingFolder,'Behaviour',SelectionMode, ...
    BehaviourSelectionAge,'behavioural','required',false,'recordingId',DatafileID);
end

RecordingInfo = struct();
RecordingInfo.Path = PathValue;
RecordingInfo.Folder = RecordingFolder;
RecordingInfo.DatafileID = DatafileID;
RecordingInfo.SinksDataFolder = SinksDataFolder;
RecordingInfo.SurgesDataFolder = SurgesDataFolder;
RecordingInfo.BehaviourDataFolder = BehaviourDataFolder;
RecordingInfo.HasBehaviourData = HasBehaviourData;
RecordingInfo.SinksMatFile = SinksMatFile;
RecordingInfo.SurgesMatFile = SurgesMatFile;
end
function path=canonical(path)
path=char(java.io.File(char(path)).getCanonicalPath());
end
function path=checkedMaster(path,recording)
path=canonical(path);recording=canonical(recording);
assert(startsWith(path,[recording filesep])&&isfile(path), ...
    'OxygenDynamics:StatsSavedSource','Saved master is unavailable or outside its recording: %s.',path);
end
