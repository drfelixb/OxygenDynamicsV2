function FilePath = findStatsSidecarFile(fileName,varargin)
% findStatsSidecarFile finds a sidecar file in candidate folders.

FilePath = '';
if isempty(fileName)
    return
end

if isstring(fileName)
    fileName = char(fileName);
end

if isfile(fileName)
    FilePath = fileName;
    return
end

for folderi=1:numel(varargin)
    CandidateFolder = varargin{folderi};
    if isempty(CandidateFolder) || ~isfolder(CandidateFolder)
        continue
    end

    CandidatePath = fullfile(CandidateFolder,fileName);
    if isfile(CandidatePath)
        FilePath = CandidatePath;
        return
    end

    MatchingFiles = dir(fullfile(CandidateFolder,['*',fileName,'*']));
    MatchingFiles = MatchingFiles(~[MatchingFiles.isdir]);
    if ~isempty(MatchingFiles)
        FilePath = fullfile(MatchingFiles(1).folder,MatchingFiles(1).name);
        return
    end
end

end
