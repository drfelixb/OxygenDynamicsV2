function Validation = validateOxygenRecording(recordingFolder,fs,pixelSize,overwriteOutputs,metadata)
%VALIDATEOXYGENRECORDING Lightweight checks before oxygen analysis starts.

if nargin<5
    metadata = struct();
end

Validation = struct();
Validation.IsValid = true;
Validation.Errors = {};
Validation.Warnings = {};
Validation.RecordingFolder = recordingFolder;
Validation.TiffStatus = inspectOxygenTiffs(recordingFolder);
Validation.RawFile = '';
Validation.DenoisedFile = '';
Validation.RawTiffInfo = struct();
Validation.DenoisedTiffInfo = struct();
Validation.OverwriteOutputs = overwriteOutputs;

if isempty(Validation.TiffStatus.AllFiles)
    Validation = addError(Validation,'No tif files were found in this recording folder.');
end
if isempty(Validation.TiffStatus.RawFiles)
    Validation = addError(Validation,'No original/raw tif was found. Keep exactly one non-denoised tif in the recording folder.');
elseif numel(Validation.TiffStatus.RawFiles)>1
    Validation = addError(Validation,'More than one original/raw tif was found. Keep exactly one non-denoised tif in the recording folder.');
else
    RawFile = Validation.TiffStatus.RawFiles(1);
    Validation.RawFile = fullfile(RawFile.folder,RawFile.name);
end

if numel(Validation.TiffStatus.DenoisedFiles)>1
    Validation = addError(Validation,'More than one denoised tif was found. Keep exactly one tif with "denoised" in the file name.');
elseif isscalar(Validation.TiffStatus.DenoisedFiles)
    DenoisedFile = Validation.TiffStatus.DenoisedFiles(1);
    Validation.DenoisedFile = fullfile(DenoisedFile.folder,DenoisedFile.name);
end

if ~isempty(Validation.RawFile)
    try
        Validation.RawTiffInfo = getTiffStackInfo(Validation.RawFile);
    catch ME
        Validation = addError(Validation,['Could not read raw tif metadata: ',ME.message]);
    end
end

if ~isempty(Validation.DenoisedFile)
    try
        Validation.DenoisedTiffInfo = getTiffStackInfo(Validation.DenoisedFile);
    catch ME
        Validation = addError(Validation,['Could not read denoised tif metadata: ',ME.message]);
    end
end

if ~isempty(fieldnames(Validation.RawTiffInfo)) && ~isempty(fieldnames(Validation.DenoisedTiffInfo))
    if Validation.RawTiffInfo.Width~=Validation.DenoisedTiffInfo.Width || ...
            Validation.RawTiffInfo.Height~=Validation.DenoisedTiffInfo.Height || ...
            Validation.RawTiffInfo.Frames~=Validation.DenoisedTiffInfo.Frames
        Validation = addError(Validation,'The original and denoised tif stacks do not have matching width, height, and frame count.');
    end
end

if ~(isnumeric(fs) && isscalar(fs) && isfinite(fs) && fs>0)
    Validation = addError(Validation,'Sampling frequency must be a positive numeric scalar.');
end
if ~(isnumeric(pixelSize) && isscalar(pixelSize) && isfinite(pixelSize) && pixelSize>0)
    Validation = addError(Validation,'Pixel size must be a positive numeric scalar.');
end
if ~(islogical(overwriteOutputs) && isscalar(overwriteOutputs))
    Validation = addError(Validation,'Overwrite mode must resolve to a scalar logical value.');
end

Validation = validateMetadata(Validation,metadata);

if isfolder(fullfile(recordingFolder,'OxygenSinks_Output')) && ~overwriteOutputs
    Validation = addWarning(Validation,'Existing OxygenSinks_Output folder found. A timestamped output folder will be used unless reanalysis is disabled.');
elseif isfolder(fullfile(recordingFolder,'OxygenSinks_Output')) && overwriteOutputs
    Validation = addWarning(Validation,'Existing OxygenSinks_Output folder found and overwrite mode is enabled.');
end

Validation.IsValid = isempty(Validation.Errors);

end

function StackInfo = getTiffStackInfo(tiffPath)

WarningState = warning('off','all');
RestoreWarnings = onCleanup(@() warning(WarningState));
Info = imfinfo(tiffPath);
StackInfo = struct();
StackInfo.Width = Info(1).Width;
StackInfo.Height = Info(1).Height;
StackInfo.Frames = numel(Info);
StackInfo.BitDepth = Info(1).BitDepth;
StackInfo.Format = Info(1).Format;

end

function Validation = validateMetadata(Validation,metadata)

RequiredFields = {'Mouse','Condition','DrugID','Genotype','Promoter'};
for FieldIdx=1:numel(RequiredFields)
    FieldName = RequiredFields{FieldIdx};
    if ~isfield(metadata,FieldName) || isMissingMetadata(metadata.(FieldName))
        Validation = addWarning(Validation,[FieldName,' metadata is missing or empty; analysis will use Unknown if the script needs it.']);
    end
end

end

function IsMissing = isMissingMetadata(value)

if isstring(value)
    IsMissing = all(ismissing(value) | strlength(value)==0);
elseif ischar(value)
    IsMissing = isempty(value);
elseif iscell(value)
    IsMissing = isempty(value) || all(cellfun(@isempty,value));
else
    IsMissing = isempty(value);
end

end

function Validation = addError(Validation,message)

Validation.Errors{end+1,1} = message;

end

function Validation = addWarning(Validation,message)

Validation.Warnings{end+1,1} = message;

end
