function [InputData,AnalysisInfo] = loadiOSMasterInputs(recordingFolder,AnalysisParams)
%LOADIOSMASTERINPUTS Load iOS raw TIFF and provenance info.

fprintf('Loading data... \n');
[IM_Raw,Miu,Tifffiles] = loadRawTiffStack(recordingFolder);
fprintf('Loaded original/raw iOS TIFF: %s\n',Tifffiles.name);

[~,DatafileID] = fileparts(Tifffiles(1).folder);
RecDur = size(IM_Raw,3) / AnalysisParams.fs;

AnalysisInfo = struct();
AnalysisInfo.AnalysisDate = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
AnalysisInfo.RawFile = fullfile(Tifffiles.folder,Tifffiles.name);
AnalysisInfo.AnalysisParams = AnalysisParams;

InputData = struct();
InputData.IM_Raw = IM_Raw;
InputData.Miu = Miu;
InputData.Tifffiles = Tifffiles;
InputData.DatafileID = DatafileID;
InputData.RecDur = RecDur;

end
