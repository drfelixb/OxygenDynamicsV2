function OutputFolder = createHypoxiaAmyloidOutputFolder(RecordingFolder,Overwrite)
%CREATEHYPOXIAAMYLOIDOUTPUTFOLDER Create a versioned per-recording output folder.

if nargin<2
    Overwrite = false;
end
BaseFolder = fullfile(RecordingFolder,'HypoxiaAmyloid_Output');
if Overwrite || ~isfolder(BaseFolder)
    OutputFolder = BaseFolder;
else
    Timestamp = char(datetime('now','Format','yyyyMMdd''T''HHmmss'));
    OutputFolder = [BaseFolder,'_',Timestamp];
end
mkdirIfMissing(OutputFolder);
end
