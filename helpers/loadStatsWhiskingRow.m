function BehaviourRow = loadStatsWhiskingRow(BehaviourRow,WhiskingFileName,BehaviourFolder,RecordingFolder,RecordingId,RecordingDuration,BehFs)
%LOADSTATSWHISKINGROW Load and clip the optional whisking trace for stats.

if ~isStatsOptionalInputConfigured(WhiskingFileName)
    return
end

WhiskingFile = findStatsSidecarFile(WhiskingFileName,BehaviourFolder,RecordingFolder);
if isempty(WhiskingFile)
    warning('OxygenDynamics:MissingWhiskingFile', ...
        'Could not find whisking file "%s" for recording %s.',WhiskingFileName,RecordingId);
    return
end
if ~isTableLikeFile(WhiskingFile)
    warning('OxygenDynamics:InvalidWhiskingFileType', ...
        'Ignoring whisking file for recording %s because it is not a table file: %s', ...
        RecordingId,WhiskingFile);
    return
end

WhiskingTable = readInputTable(WhiskingFile);
if ~ismember('RTrace_var',WhiskingTable.Properties.VariableNames)
    warning('OxygenDynamics:MissingWhiskingColumn', ...
        'Whisking file for recording %s does not contain RTrace_var.',RecordingId);
    return
end

WhiskingTrace = WhiskingTable.RTrace_var;
if isfinite(RecordingDuration)
    MaxSamples = floor(RecordingDuration*BehFs);
    if MaxSamples>=0 && size(WhiskingTrace,1)>MaxSamples
        WhiskingTrace = WhiskingTrace(1:MaxSamples);
    end
end

BehaviourRow{10} = WhiskingTrace;
end

function IsTableLike = isTableLikeFile(FilePath)

[~,~,Extension] = fileparts(FilePath);
AllowedExtensions = {'.csv','.txt','.tsv','.xlsx','.xls'};
IsTableLike = any(strcmpi(Extension,AllowedExtensions));

end
