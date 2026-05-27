function validateRecordingPaths(paths,baseFolder,sourceName)
%VALIDATERECORDINGPATHS Error clearly if CSV recording folders are missing.

if nargin<2 || isempty(baseFolder)
    baseFolder = pwd;
end
if nargin<3 || isempty(sourceName)
    sourceName = 'recording paths';
end

if ischar(paths) || isstring(paths)
    paths = cellstr(paths);
end

if ~iscell(paths)
    error('validateRecordingPaths:InvalidInput','%s must be a cell array or string array.',sourceName);
end

missingPaths = {};
for pathIdx=1:numel(paths)
    candidatePath = paths{pathIdx};
    if isstring(candidatePath)
        candidatePath = char(candidatePath);
    end
    if isempty(candidatePath) || ~(ischar(candidatePath) || isStringScalar(candidatePath))
        missingPaths{end+1,1} = sprintf('<empty or invalid path at row %d>',pathIdx); %#ok<AGROW>
        continue
    end

    candidatePath = char(candidatePath);
    if isAbsolutePath(candidatePath)
        fullCandidatePath = candidatePath;
    else
        fullCandidatePath = fullfile(baseFolder,candidatePath);
    end

    if ~isfolder(fullCandidatePath)
        missingPaths{end+1,1} = candidatePath; %#ok<AGROW>
    end
end

if ~isempty(missingPaths)
    error('validateRecordingPaths:MissingFolders', ...
        '%s contains missing recording folder(s): %s',sourceName,strjoin(missingPaths,', '));
end

end

function tf = isStringScalar(value)

tf = isstring(value) && isscalar(value);

end

function tf = isAbsolutePath(pathValue)

tf = startsWith(pathValue,'\\') || ~isempty(regexp(pathValue,'^[A-Za-z]:[\\/]', 'once')) || startsWith(pathValue,'/');

end
