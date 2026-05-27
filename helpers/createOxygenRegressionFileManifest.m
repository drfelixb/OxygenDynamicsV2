function FileManifest = createOxygenRegressionFileManifest(DataOutputPath,TextMetrics)
%CREATEOXYGENREGRESSIONFILEMANIFEST Record key input/output files for regression provenance.

if nargin<2
    TextMetrics = table();
end

DataOutputPath = resolveDataOutputPath(DataOutputPath);
StatsOutputFolder = fileparts(DataOutputPath);

FilePaths = strings(0,1);
Roles = strings(0,1);
[FilePaths,Roles] = addManifestFile(FilePaths,Roles,DataOutputPath,'DataOutput');
[FilePaths,Roles] = addTextMetricFile(FilePaths,Roles,TextMetrics,'InputCsv','InputCsv');

WorkbookFiles = dir(fullfile(StatsOutputFolder,'*.xlsx'));
for FileIdx = 1:numel(WorkbookFiles)
    [FilePaths,Roles] = addManifestFile(FilePaths,Roles, ...
        fullfile(WorkbookFiles(FileIdx).folder,WorkbookFiles(FileIdx).name),'StatsWorkbook');
end

MatFiles = {'SinkEventTable.mat','SurgeEventTable.mat','HypoxicEventSpecificMetrics4LME.mat'};
for FileIdx = 1:numel(MatFiles)
    [FilePaths,Roles] = addManifestFile(FilePaths,Roles, ...
        fullfile(StatsOutputFolder,MatFiles{FileIdx}),erase(MatFiles{FileIdx},'.mat'));
end

FilePaths = FilePaths(:);
Roles = Roles(:);
Exists = arrayfun(@isfile,FilePaths);
Bytes = nan(numel(FilePaths),1);
Modified = strings(numel(FilePaths),1);
SHA256 = strings(numel(FilePaths),1);

for FileIdx = 1:numel(FilePaths)
    if Exists(FileIdx)
        Info = dir(FilePaths(FileIdx));
        Bytes(FileIdx) = Info.bytes;
        Modified(FileIdx) = string(formatRegressionTimestamp(Info.datenum));
        SHA256(FileIdx) = string(fileSha256(FilePaths(FileIdx)));
    end
end

FileManifest = table(Roles,FilePaths,Exists,Bytes,Modified,SHA256, ...
    'VariableNames',{'Role','Path','Exists','Bytes','Modified','SHA256'});
FileManifest = unique(FileManifest,'rows','stable');

end

function DataOutputPath = resolveDataOutputPath(InputPath)

if isfolder(InputPath)
    DataOutputPath = fullfile(InputPath,'DataOutput.mat');
else
    DataOutputPath = InputPath;
end

end

function [FilePaths,Roles] = addTextMetricFile(FilePaths,Roles,TextMetrics,MetricName,Role)

if isempty(TextMetrics) || ~istable(TextMetrics) || ...
        ~all(ismember({'Metric','Value'},TextMetrics.Properties.VariableNames))
    return
end

Idx = find(TextMetrics.Metric==MetricName,1,'first');
if isempty(Idx)
    return
end
[FilePaths,Roles] = addManifestFile(FilePaths,Roles,TextMetrics.Value(Idx),Role);

end

function [FilePaths,Roles] = addManifestFile(FilePaths,Roles,FilePath,Role)

if strlength(string(FilePath))==0
    return
end
FilePaths(end+1,1) = string(FilePath);
Roles(end+1,1) = string(Role);

end
