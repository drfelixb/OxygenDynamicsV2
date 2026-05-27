function [IM_Raw,IM_NoNoise,Miu,Miu_NoNoise,RawTifFile,RawFile,DenoisedFile] = loadOxygenStacks(recordingFolder)
%LOADOXYGENSTACKS Load original/raw and optional denoised oxygen TIFF stacks.

TiffStatus = inspectOxygenTiffs(recordingFolder);
RawFiles = TiffStatus.RawFiles;
DenoisedFiles = TiffStatus.DenoisedFiles;

if isempty(TiffStatus.AllFiles)
    error('No tif files were found in this recording folder.');
end
if isempty(RawFiles)
    error(['No original/raw tif was found in this folder. ', ...
        'Keep the original tif and denoised tif in the same folder, ', ...
        'and include "denoised" in the denoised file name only.']);
end
if numel(RawFiles)>1
    error('More than one original/raw tif was found. Please keep exactly one non-denoised tif in the recording folder.');
end
if numel(DenoisedFiles)>1
    error('More than one denoised tif was found. Please keep exactly one tif with "denoised" in the file name.');
end

RawFile = RawFiles(1);
RawPath = fullfile(RawFile.folder,RawFile.name);
[IM_Raw,Miu,~] = loadtiff(RawPath);
RawTifFile = RawFile;

IM_NoNoise = [];
Miu_NoNoise = [];
DenoisedFile = [];
if ~isempty(DenoisedFiles)
    DenoisedFile = DenoisedFiles(1);
    DenoisedPath = fullfile(DenoisedFile.folder,DenoisedFile.name);
    [IM_NoNoise,Miu_NoNoise,~] = loadtiff(DenoisedPath);
    if ~isequal(size(IM_Raw),size(IM_NoNoise))
        error('The original and denoised tif stacks must have the same x/y dimensions and number of frames.');
    end
end

end
