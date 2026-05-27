function TiffStatus = inspectOxygenTiffs(recordingFolder)
%INSPECTOXYGENTIFFS Find original/raw and denoised oxygen recording TIFFs.

TifFiles = dir(fullfile(recordingFolder,'*.tif'));
IsDenoised = contains({TifFiles.name},'denoised','IgnoreCase',true);

TiffStatus = struct();
TiffStatus.AllFiles = TifFiles;
TiffStatus.RawFiles = TifFiles(~IsDenoised);
TiffStatus.DenoisedFiles = TifFiles(IsDenoised);

if numel(TiffStatus.RawFiles)>1
    fprintf('WARNING: More than one non-denoised TIFF found. Analysis will stop unless only one original/raw TIFF is present.\n');
end
if numel(TiffStatus.DenoisedFiles)>1
    fprintf('WARNING: More than one denoised TIFF found. Analysis will stop unless only one denoised TIFF is present.\n');
end

end
