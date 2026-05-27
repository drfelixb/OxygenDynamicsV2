function TiffoutOutput = runOxygenDynamicsTiffout(recordingFolder,Context)
%RUNOXYGENDYNAMICSTIFFOUT Create processed oxygen-dynamics TIFF outputs.

if nargin < 1 || isempty(recordingFolder)
    recordingFolder = pwd;
end
if nargin < 2 || isempty(Context)
    Context = struct();
end

setupOxygenDynamicsPath();

SmoothPixels = 10;
PixelSize = getContextValue(Context,'PiSz',2.5);
fs = getContextValue(Context,'SFs',1);
PixelFrame = SmoothPixels * 2;
ROISize = 20;
PercentileDetectionThres = 99;

AnalysisParams = struct();
AnalysisParams.smooth = SmoothPixels;
AnalysisParams.fs = fs;
AnalysisParams.PixelSize = PixelSize;
AnalysisParams.Pixel_frame = PixelFrame;
AnalysisParams.ROIsize = ROISize;
AnalysisParams.PercentileDetectionThres = PercentileDetectionThres;

fprintf('Loading data... \n');
[IM_Raw,IM_NoNoise,~,~,Tifffiles,RawTiffFile,DenoisedTiffFile] = loadOxygenStacks(recordingFolder);
fprintf('Loaded original/raw TIFF: %s\n',RawTiffFile.name);
if isempty(DenoisedTiffFile)
    fprintf('No denoised TIFF found. Processed detection-style TIFFs will use the original/raw TIFF.\n');
else
    fprintf('Loaded denoised TIFF for processed detection-style TIFFs: %s\n',DenoisedTiffFile.name);
end

[~,DatafileID] = fileparts(Tifffiles(1).folder);
RecDur = size(IM_Raw,3) * fs;

AnalysisInfo = struct();
AnalysisInfo.AnalysisDate = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
AnalysisInfo.RawFile = fullfile(RawTiffFile.folder,RawTiffFile.name);
AnalysisInfo.DenoisedFile = '';
if ~isempty(DenoisedTiffFile)
    AnalysisInfo.DenoisedFile = fullfile(DenoisedTiffFile.folder,DenoisedTiffFile.name);
end
AnalysisInfo.DetectionSource = 'Denoised TIFF if present; otherwise original/raw TIFF';
AnalysisInfo.QuantificationSource = 'Original/raw TIFF';
AnalysisInfo.AnalysisParams = AnalysisParams;

fprintf('Detrending... This might take some time! \n');
tic;
IM_Raw_Notrend = detrendOxygenStack(IM_Raw,3);
if ~isempty(IM_NoNoise)
    IM_Notrend = detrendOxygenStack(IM_NoNoise,3);
else
    fprintf('Cannot find denoised data... Analysis will continue with motion-corrected-only data! \n');
    IM_Notrend = IM_Raw_Notrend;
end
IM_Notrend = single(IM_Notrend);
toc;

fprintf('Calculating the dF/F data... \n');
[IM_Notrend_dFoF_global,IM_Notrend_dFoF_frame] = normalizeToDfof(IM_Notrend);
[IM_Raw_dFoF_global,IM_Raw_dFoF_frame] = normalizeToDfof(IM_Raw);

[~,IM_Zframetime_smoothed] = preprocessDetectionStack(IM_Notrend,SmoothPixels);

disp('Saving manipulated data matrices');
OverwriteOutputs = isfield(Context,'strOW') && strcmpi(Context.strOW,'Y');
OutputFolders = createOxygenOutputFolders(Tifffiles(1).folder,OverwriteOutputs);
AnalysisInfo.OutputFolders = OutputFolders;

saveOxygenTiffoutStacks(OutputFolders,DatafileID,IM_Notrend,IM_Notrend_dFoF_global, ...
    IM_Raw_dFoF_global,IM_Notrend_dFoF_frame,IM_Raw_dFoF_frame,IM_Zframetime_smoothed);

save(fullfile(OutputFolders.ImagesProcessedPath,['OxygenDynamics_Tiffout_AnalysisInfo',DatafileID,'.mat']), ...
    'AnalysisInfo');

TiffoutOutput = struct();
TiffoutOutput.Tifffiles = Tifffiles;
TiffoutOutput.RecDur = RecDur;
TiffoutOutput.OutputFolders = OutputFolders;
TiffoutOutput.AnalysisInfo = AnalysisInfo;
TiffoutOutput.DatafileID = DatafileID;

end

function Value = getContextValue(Context,FieldName,DefaultValue)

if isfield(Context,FieldName) && ~isempty(Context.(FieldName))
    Value = Context.(FieldName);
else
    Value = DefaultValue;
end

end
