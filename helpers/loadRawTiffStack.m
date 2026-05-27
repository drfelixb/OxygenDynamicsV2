function [IM_Raw,Miu,RawTifFile] = loadRawTiffStack(recordingFolder)
%LOADRAWTIFFSTACK Load exactly one non-denoised TIFF stack from a folder.

TiffStatus = inspectOxygenTiffs(recordingFolder);
RawFiles = TiffStatus.RawFiles;

if isempty(TiffStatus.AllFiles)
    error('No tif files were found in this recording folder.');
end
if isempty(RawFiles)
    error('No original/raw tif was found. Keep exactly one non-denoised tif in the recording folder.');
end
if numel(RawFiles)>1
    error('More than one original/raw tif was found. Please keep exactly one non-denoised tif in the recording folder.');
end

RawTifFile = RawFiles(1);
RawPath = fullfile(RawTifFile.folder,RawTifFile.name);
[IM_Raw,Miu,~] = loadtiff(RawPath);

end
