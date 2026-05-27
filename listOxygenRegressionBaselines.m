function ArchiveTable = listOxygenRegressionBaselines(BaselinePath)
%LISTOXYGENREGRESSIONBASELINES List archived regression baselines.

setupOxygenDynamicsPath();

if nargin<1 || isempty(BaselinePath)
    BaselinePath = fullfile(pwd,'Regression_Baselines','OxygenRegressionBaseline.mat');
end

[BaselineFolder,BaselineName] = fileparts(BaselinePath);
ArchiveRoot = fullfile(BaselineFolder,'Archive');
ArchiveTable = createEmptyArchiveTable();
if ~isfolder(ArchiveRoot)
    return
end

ArchivedMatFiles = dir(fullfile(ArchiveRoot,'**',[BaselineName '.mat']));
if isempty(ArchivedMatFiles)
    return
end

ArchiveTimestamp = strings(numel(ArchivedMatFiles),1);
MatPath = strings(numel(ArchivedMatFiles),1);
WorkbookPath = strings(numel(ArchivedMatFiles),1);
MatExists = true(numel(ArchivedMatFiles),1);
WorkbookExists = false(numel(ArchivedMatFiles),1);
BaselineCreated = strings(numel(ArchivedMatFiles),1);
SourceDataOutput = strings(numel(ArchivedMatFiles),1);

for FileIdx = 1:numel(ArchivedMatFiles)
    MatPath(FileIdx) = string(fullfile(ArchivedMatFiles(FileIdx).folder,ArchivedMatFiles(FileIdx).name));
    ArchiveTimestamp(FileIdx) = string(getArchiveTimestamp(ArchivedMatFiles(FileIdx).folder));
    WorkbookCandidate = fullfile(ArchivedMatFiles(FileIdx).folder,[BaselineName '.xlsx']);
    WorkbookPath(FileIdx) = string(WorkbookCandidate);
    WorkbookExists(FileIdx) = isfile(WorkbookCandidate);
    [BaselineCreated(FileIdx),SourceDataOutput(FileIdx)] = inspectArchivedBaseline(MatPath(FileIdx));
end

ArchiveTable = table(ArchiveTimestamp,MatPath,WorkbookPath,MatExists,WorkbookExists, ...
    BaselineCreated,SourceDataOutput);
ArchiveTable = sortrows(ArchiveTable,'ArchiveTimestamp','descend');

end

function ArchiveTable = createEmptyArchiveTable()

ArchiveTimestamp = strings(0,1);
MatPath = strings(0,1);
WorkbookPath = strings(0,1);
MatExists = false(0,1);
WorkbookExists = false(0,1);
BaselineCreated = strings(0,1);
SourceDataOutput = strings(0,1);
ArchiveTable = table(ArchiveTimestamp,MatPath,WorkbookPath,MatExists,WorkbookExists, ...
    BaselineCreated,SourceDataOutput);

end

function Timestamp = getArchiveTimestamp(FolderPath)

[~,Timestamp] = fileparts(FolderPath);

end

function [BaselineCreated,SourceDataOutput] = inspectArchivedBaseline(MatPath)

BaselineCreated = "";
SourceDataOutput = "";
try
    Loaded = load(MatPath,'Baseline');
    if isfield(Loaded,'Baseline')
        if isfield(Loaded.Baseline,'BaselineCreated')
            BaselineCreated = string(Loaded.Baseline.BaselineCreated);
        end
        if isfield(Loaded.Baseline,'DataOutputPath')
            SourceDataOutput = string(Loaded.Baseline.DataOutputPath);
        end
    end
catch
end

end
