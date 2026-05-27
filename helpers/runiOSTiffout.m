function TiffoutOutput = runiOSTiffout(recordingFolder,Context)
%RUNIOSTIFFOUT Create processed intrinsic optical signal TIFF outputs.

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
[IM_Raw,~,Tifffiles] = loadRawTiffStack(recordingFolder);
fprintf('Loaded original/raw iOS TIFF: %s\n',Tifffiles.name);

[~,DatafileID] = fileparts(Tifffiles(1).folder);
RecDur = size(IM_Raw,3) * fs;

AnalysisInfo = struct();
AnalysisInfo.AnalysisDate = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
AnalysisInfo.RawFile = fullfile(Tifffiles.folder,Tifffiles.name);
AnalysisInfo.AnalysisParams = AnalysisParams;

IM_resize = imcomplement(imresize(IM_Raw,512/size(IM_Raw,1)));

[IM_Raw_dFoF_global,~] = normalizeToDfof(IM_resize);
IM_Raw_dFoF_global = scaleStackToUint16(IM_Raw_dFoF_global);

fprintf('Detrending... This might take some time! \n');
tic;
IM_Notrend_dFoF_global = detrendOxygenStack(single(IM_Raw_dFoF_global),3);
IM_Notrend_dFoF_global = single(IM_Notrend_dFoF_global);
toc;

[~,IM_Zframetime_Conv_smoothed] = preprocessDetectionStack(IM_Notrend_dFoF_global,SmoothPixels);

disp('Saving manipulated data matrices');
OverwriteOutputs = isfield(Context,'strOW') && strcmpi(Context.strOW,'Y');
OutputFolders = createOxygenOutputFolders(Tifffiles(1).folder,OverwriteOutputs);
AnalysisInfo.OutputFolders = OutputFolders;

saveiOSTiffoutStacks(OutputFolders,DatafileID,IM_Notrend_dFoF_global, ...
    IM_Raw_dFoF_global,IM_Zframetime_Conv_smoothed);

save(fullfile(OutputFolders.ImagesProcessedPath,['iOS_Tiffout_AnalysisInfo',DatafileID,'.mat']), ...
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
