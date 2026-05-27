function printWrapperRecordingStatus(label,dataIndex,numRecordings,mouseId,recordingFolder,validation,mode)
%PRINTWRAPPERRECORDINGSTATUS Print one wrapper preflight summary.

TiffStatus = validation.TiffStatus;
fprintf('\n============================================================\n');
fprintf('%s recording %d of %d\n',label,dataIndex,numRecordings);
fprintf('Mouse/file ID: %s\n',string(mouseId));
fprintf('Folder: %s\n',recordingFolder);

if ~isempty(TiffStatus.RawFiles)
    fprintf('Original/raw TIFF: %s\n',TiffStatus.RawFiles(1).name);
else
    fprintf('Original/raw TIFF: NOT FOUND\n');
end

if strcmpi(mode,'ios')
    printIOSSourceStatus(TiffStatus);
else
    printOxygenSourceStatus(TiffStatus);
end

if validation.IsValid
    fprintf('Preflight validation: PASS\n');
    printTiffDimensions('Raw TIFF',validation.RawTiffInfo);
    if ~strcmpi(mode,'ios')
        printTiffDimensions('Denoised TIFF',validation.DenoisedTiffInfo);
    end
else
    fprintf('Preflight validation: FAIL\n');
end

for messageIdx=1:numel(validation.Warnings)
    fprintf('Preflight warning: %s\n',validation.Warnings{messageIdx});
end
for messageIdx=1:numel(validation.Errors)
    fprintf('Preflight error: %s\n',validation.Errors{messageIdx});
end
fprintf('============================================================\n\n');

end

function printOxygenSourceStatus(TiffStatus)
if ~isempty(TiffStatus.DenoisedFiles)
    fprintf('Denoised TIFF found: %s\n',TiffStatus.DenoisedFiles(1).name);
    fprintf('Detection source: denoised TIFF\n');
else
    fprintf('Denoised TIFF found: no\n');
    fprintf('Detection source: original/raw TIFF\n');
end
fprintf('Quantification source: original/raw TIFF\n');
end

function printIOSSourceStatus(TiffStatus)
if ~isempty(TiffStatus.DenoisedFiles)
    fprintf('Denoised TIFF found: %s\n',TiffStatus.DenoisedFiles(1).name);
    fprintf('iOS analysis source: original/raw TIFF; denoised TIFF ignored\n');
else
    fprintf('Denoised TIFF found: no\n');
    fprintf('iOS analysis source: original/raw TIFF\n');
end
end

function printTiffDimensions(label,tiffInfo)
if ~isempty(tiffInfo) && isfield(tiffInfo,'Frames')
    fprintf('%s dimensions: %d x %d x %d frames, bit depth %d\n', ...
        label,tiffInfo.Width,tiffInfo.Height,tiffInfo.Frames,tiffInfo.BitDepth);
end
end
