function [InputData,AnalysisInfo] = loadOxygenMasterInputs(recordingFolder,AnalysisParams)
%LOADOXYGENMASTERINPUTS Load oxygen raw/denoised TIFFs and provenance info.

fprintf('Loading data... \n');
[IM_Raw,IM_NoNoise,Miu,Miu_NoNoise,Tifffiles,RawTiffFile,DenoisedTiffFile] = loadOxygenStacks(recordingFolder);
fprintf('Loaded original/raw TIFF: %s\n',RawTiffFile.name);
if isempty(DenoisedTiffFile)
    fprintf('No denoised TIFF found. Detection will use the original/raw TIFF.\n');
else
    fprintf('Loaded denoised TIFF for detection: %s\n',DenoisedTiffFile.name);
end

[~,DatafileID] = fileparts(Tifffiles(1).folder);
RecDur = size(IM_Raw,3) / AnalysisParams.fs;

AnalysisInfo = struct();
AnalysisInfo.NFrames = size(IM_Raw,3);
AnalysisInfo.RecordingDurationSec = RecDur;
AnalysisInfo.PipelineContract=oxygenPipelineContract();
AnalysisInfo.AnalysisSchemaVersion = AnalysisInfo.PipelineContract.Schema;
AnalysisInfo.AnalysisDate = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
AnalysisInfo.RawFile = fullfile(RawTiffFile.folder,RawTiffFile.name);
if isempty(DenoisedTiffFile)
    AnalysisInfo.DenoisedFile = '';
else
    AnalysisInfo.DenoisedFile = fullfile(DenoisedTiffFile.folder,DenoisedTiffFile.name);
end
AnalysisInfo.RawSHA256=oxygenFileSHA256(AnalysisInfo.RawFile);
AnalysisInfo.DenoisedSHA256='';
if ~isempty(AnalysisInfo.DenoisedFile),AnalysisInfo.DenoisedSHA256=oxygenFileSHA256(AnalysisInfo.DenoisedFile);end
AnalysisInfo.QuantificationSource = 'Original/raw TIFF';
AnalysisInfo.DetectionSource = 'Denoised TIFF if present; otherwise original/raw TIFF';
AnalysisInfo.AnalysisParams = AnalysisParams;

InputData = struct();
InputData.IM_Raw = IM_Raw;
InputData.IM_NoNoise = IM_NoNoise;
InputData.Miu = Miu;
InputData.Miu_NoNoise = Miu_NoNoise;
InputData.Tifffiles = Tifffiles;
InputData.DatafileID = DatafileID;
InputData.RecDur = RecDur;

end
