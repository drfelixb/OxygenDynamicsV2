function SummaryTable = statsRecordingsToTable(StatsInfo)
if ~isfield(StatsInfo,'Recordings') || isempty(StatsInfo.Recordings)
    SummaryTable=table();
    return
end

Recordings=StatsInfo.Recordings(:);
NumRecordings=numel(Recordings);
Path=cell(NumRecordings,1);
Folder=cell(NumRecordings,1);
DatafileID=cell(NumRecordings,1);
SinksDataFolder=cell(NumRecordings,1);
SurgesDataFolder=cell(NumRecordings,1);
BehaviourDataFolder=cell(NumRecordings,1);
SinksMatFile=cell(NumRecordings,1);
SurgesMatFile=cell(NumRecordings,1);
HasBehaviourData=false(NumRecordings,1);
HasConfiguredBehaviourInputs=false(NumRecordings,1);
HasBehaviourTraces=false(NumRecordings,1);
HasROITraces=false(NumRecordings,1);
HasSinks=false(NumRecordings,1);
HasSurges=false(NumRecordings,1);

for reci=1:NumRecordings
    Path{reci}=getStructFieldOrDefault(Recordings(reci),'Path','');
    Folder{reci}=getStructFieldOrDefault(Recordings(reci),'Folder','');
    DatafileID{reci}=getStructFieldOrDefault(Recordings(reci),'DatafileID','');
    SinksDataFolder{reci}=getStructFieldOrDefault(Recordings(reci),'SinksDataFolder','');
    SurgesDataFolder{reci}=getStructFieldOrDefault(Recordings(reci),'SurgesDataFolder','');
    BehaviourDataFolder{reci}=getStructFieldOrDefault(Recordings(reci),'BehaviourDataFolder','');
    SinksMatFile{reci}=getStructFieldOrDefault(Recordings(reci),'SinksMatFile','');
    SurgesMatFile{reci}=getStructFieldOrDefault(Recordings(reci),'SurgesMatFile','');
    HasBehaviourData(reci)=logical(getStructFieldOrDefault(Recordings(reci),'HasBehaviourData',false));
    HasConfiguredBehaviourInputs(reci)=logical(getStructFieldOrDefault(Recordings(reci),'HasConfiguredBehaviourInputs',false));
    HasBehaviourTraces(reci)=logical(getStructFieldOrDefault(Recordings(reci),'HasBehaviourTraces',false));
    HasROITraces(reci)=logical(getStructFieldOrDefault(Recordings(reci),'HasROITraces',false));
    HasSinks(reci)=logical(getStructFieldOrDefault(Recordings(reci),'HasSinks',false));
    HasSurges(reci)=logical(getStructFieldOrDefault(Recordings(reci),'HasSurges',false));
end

SummaryTable=table(Path,Folder,DatafileID,SinksDataFolder,SurgesDataFolder,BehaviourDataFolder, ...
    SinksMatFile,SurgesMatFile,HasBehaviourData,HasConfiguredBehaviourInputs, ...
    HasBehaviourTraces,HasROITraces,HasSinks,HasSurges);
end

function Value = getStructFieldOrDefault(StructValue,FieldName,DefaultValue)
if isfield(StructValue,FieldName) && ~isempty(StructValue.(FieldName))
    Value=StructValue.(FieldName);
else
    Value=DefaultValue;
end
end
