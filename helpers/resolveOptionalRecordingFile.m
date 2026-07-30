function FilePath = resolveOptionalRecordingFile(Value,RecordingFolder)
%RESOLVEOPTIONALRECORDINGFILE Resolve an optional image file or image folder.

if iscell(Value) && isscalar(Value)
    Value = Value{1};
end
if isempty(Value) || (isnumeric(Value) && isscalar(Value) && isnan(Value)) || ...
        (isstring(Value) && (ismissing(Value) || strlength(strtrim(Value))==0))
    FilePath = '';
    return
end

FilePath = char(string(Value));
FilePath = strtrim(FilePath);
if isempty(FilePath) || strcmpi(FilePath,'<missing>')
    FilePath = '';
    return
end

ResolvedPath = FilePath;
if ~isfile(ResolvedPath) && ~isfolder(ResolvedPath)
    ResolvedPath = fullfile(RecordingFolder,FilePath);
end

if isfolder(ResolvedPath)
    FilePath = singleTiffInFolder(ResolvedPath);
elseif isfile(ResolvedPath)
    FilePath = ResolvedPath;
else
    error('HypoxiaAmyloid:AmyloidFileNotFound', ...
        'Amyloid image was not found: %s',FilePath);
end
end

function FilePath = singleTiffInFolder(FolderPath)

TiffFiles = [dir(fullfile(FolderPath,'*.tif')); ...
    dir(fullfile(FolderPath,'*.tiff'))];
if isempty(TiffFiles)
    error('HypoxiaAmyloid:NoAmyloidTiffInFolder', ...
        'No TIFF amyloid image was found in folder: %s',FolderPath);
elseif numel(TiffFiles)>1
    error('HypoxiaAmyloid:AmbiguousAmyloidFolder', ...
        ['More than one TIFF amyloid image was found in %s. ', ...
        'Put the exact image path in AmyloidFile.'],FolderPath);
end
FilePath = fullfile(TiffFiles(1).folder,TiffFiles(1).name);
end
