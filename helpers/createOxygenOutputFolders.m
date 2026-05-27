function OutputFolders = createOxygenOutputFolders(recordingFolder,overwriteOutputs)
%CREATEOXYGENOUTPUTFOLDERS Create oxygen-analysis output folders consistently.

if nargin<2 || isempty(overwriteOutputs)
    overwriteOutputs = false;
end

BaseNames = struct();
BaseNames.OxySinks = 'OxygenSinks_Output';
BaseNames.ManualCurOxySinks = 'ManualCurOxySinksData';
BaseNames.OxySurges = 'OxygenSurges_Output';
BaseNames.ImagesProcessed = 'Images_Processed';

UseBaseNames = overwriteOutputs || ~isfolder(fullfile(recordingFolder,BaseNames.OxySinks));
Timestamp = '';
if ~UseBaseNames
    Timestamp = char(datetime('now','Format','yyyyMMdd''T''HHmmss'));
end

OutputFolders = struct();
OutputFolders.Timestamp = Timestamp;
OutputFolders.OverwriteOutputs = overwriteOutputs;
OutputFolders.BaseFolder = recordingFolder;

if UseBaseNames
    OutputFolders.OxySinks = BaseNames.OxySinks;
    OutputFolders.ManualCurOxySinks = BaseNames.ManualCurOxySinks;
    OutputFolders.OxySurges = BaseNames.OxySurges;
    OutputFolders.ImagesProcessed = BaseNames.ImagesProcessed;
else
    OutputFolders.OxySinks = [BaseNames.OxySinks,'_',Timestamp];
    OutputFolders.ManualCurOxySinks = [BaseNames.ManualCurOxySinks,'_',Timestamp];
    OutputFolders.OxySurges = [BaseNames.OxySurges,'_',Timestamp];
    OutputFolders.ImagesProcessed = [BaseNames.ImagesProcessed,'_',Timestamp];
end

OutputFolders.OxySinksPath = fullfile(recordingFolder,OutputFolders.OxySinks);
OutputFolders.ManualCurOxySinksPath = fullfile(recordingFolder,OutputFolders.ManualCurOxySinks);
OutputFolders.OxySurgesPath = fullfile(recordingFolder,OutputFolders.OxySurges);
OutputFolders.ImagesProcessedPath = fullfile(recordingFolder,OutputFolders.ImagesProcessed);

mkdirIfMissing(OutputFolders.OxySinksPath);
mkdirIfMissing(OutputFolders.ManualCurOxySinksPath);
mkdirIfMissing(OutputFolders.OxySurgesPath);
mkdirIfMissing(OutputFolders.ImagesProcessedPath);

fprintf('Output folders:\n');
fprintf('  Oxygen sinks: %s\n',OutputFolders.OxySinksPath);
fprintf('  Manual curation: %s\n',OutputFolders.ManualCurOxySinksPath);
fprintf('  Oxygen surges: %s\n',OutputFolders.OxySurgesPath);
fprintf('  Processed images: %s\n',OutputFolders.ImagesProcessedPath);

end

function mkdirIfMissing(folderPath)

if ~isfolder(folderPath)
    mkdir(folderPath);
end

end
