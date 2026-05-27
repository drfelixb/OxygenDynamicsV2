function FullPath = makeFullRecordingPath(recordingPath,baseFolder)
%MAKEFULLRECORDINGPATH Resolve a recording path against a base folder.

if nargin<2 || isempty(baseFolder)
    baseFolder = pwd;
end
if isstring(recordingPath)
    recordingPath = char(recordingPath);
end

if isAbsolutePath(recordingPath)
    FullPath = recordingPath;
else
    FullPath = fullfile(baseFolder,recordingPath);
end

end

function tf = isAbsolutePath(pathValue)
tf = startsWith(pathValue,'\\') || ~isempty(regexp(pathValue,'^[A-Za-z]:[\\/]', 'once')) || startsWith(pathValue,'/');
end
