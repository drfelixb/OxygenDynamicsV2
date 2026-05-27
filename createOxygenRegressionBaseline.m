function Baseline = createOxygenRegressionBaseline(StatsOutputPath,BaselinePath)
%CREATEOXYGENREGRESSIONBASELINE Save expected metrics from a known-good stats run.

setupOxygenDynamicsPath();

if nargin<1 || isempty(StatsOutputPath)
    StatsOutputPath = findLatestStatsOutputFolder();
end
if nargin<2 || isempty(BaselinePath)
    BaselinePath = fullfile(pwd,'Regression_Baselines','OxygenRegressionBaseline.mat');
end

Baseline = extractOxygenRegressionMetrics(StatsOutputPath);
Baseline.BaselineCreated = formatRegressionTimestamp();

BaselineFolder = fileparts(BaselinePath);
if ~isempty(BaselineFolder) && ~isfolder(BaselineFolder)
    mkdir(BaselineFolder);
end

ArchivedFiles = archiveExistingBaselineFiles(BaselinePath);
Baseline.ArchivedPreviousBaselineFiles = ArchivedFiles;
save(BaselinePath,'Baseline');
BaselineWorkbook = writeBaselineWorkbook(BaselinePath,Baseline);
Baseline.BaselineWorkbook = BaselineWorkbook;
save(BaselinePath,'Baseline');
fprintf('Regression baseline saved:\n%s\n',BaselinePath);
fprintf('Regression baseline workbook saved:\n%s\n',BaselineWorkbook);
if ~isempty(ArchivedFiles)
    fprintf('Previous regression baseline files archived in:\n%s\n',fileparts(ArchivedFiles{1}));
end
fprintf('Source stats output:\n%s\n',Baseline.DataOutputPath);

end

function ArchivedFiles = archiveExistingBaselineFiles(BaselinePath)

ArchivedFiles = {};
[BaselineFolder,BaselineName] = fileparts(BaselinePath);
ExistingFiles = {BaselinePath,fullfile(BaselineFolder,[BaselineName '.xlsx'])};
ExistingFiles = ExistingFiles(cellfun(@isfile,ExistingFiles));
if isempty(ExistingFiles)
    return
end

ArchiveFolder = fullfile(BaselineFolder,'Archive',formatRegressionTimestamp());
if ~isfolder(ArchiveFolder)
    mkdir(ArchiveFolder);
end

ArchivedFiles = cell(size(ExistingFiles));
for FileIdx = 1:numel(ExistingFiles)
    [~,Name,Ext] = fileparts(ExistingFiles{FileIdx});
    Destination = fullfile(ArchiveFolder,[Name Ext]);
    movefile(ExistingFiles{FileIdx},Destination);
    ArchivedFiles{FileIdx} = Destination;
end

end

function BaselineWorkbook = writeBaselineWorkbook(BaselinePath,Baseline)

[BaselineFolder,BaselineName] = fileparts(BaselinePath);
BaselineWorkbook = fullfile(BaselineFolder,[BaselineName '.xlsx']);

Summary = table(string(Baseline.BaselineCreated),string(Baseline.DataOutputPath), ...
    string(BaselineWorkbook),'VariableNames',{'BaselineCreated','SourceDataOutput','BaselineWorkbook'});
writetable(Summary,BaselineWorkbook,'Sheet','Summary');

if isfield(Baseline,'Metadata') && ~isempty(Baseline.Metadata)
    writetable(Baseline.Metadata,BaselineWorkbook,'Sheet','Metadata');
end
if isfield(Baseline,'NumericMetrics') && ~isempty(Baseline.NumericMetrics)
    writetable(Baseline.NumericMetrics,BaselineWorkbook,'Sheet','NumericMetrics');
end
if isfield(Baseline,'TextMetrics') && ~isempty(Baseline.TextMetrics)
    writetable(Baseline.TextMetrics,BaselineWorkbook,'Sheet','TextMetrics');
end
if isfield(Baseline,'FileManifest') && ~isempty(Baseline.FileManifest)
    writetable(Baseline.FileManifest,BaselineWorkbook,'Sheet','FileManifest');
end
if isfield(Baseline,'CodeManifest') && ~isempty(Baseline.CodeManifest)
    writetable(Baseline.CodeManifest,BaselineWorkbook,'Sheet','CodeManifest');
end

end
