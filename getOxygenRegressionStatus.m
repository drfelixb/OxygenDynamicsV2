function Status = getOxygenRegressionStatus(varargin)
%GETOXYGENREGRESSIONSTATUS Inspect latest stats output and regression baseline.

Options = parseStatusOptions(varargin{:});

Status = struct();
Status.MasterFolder = Options.masterFolder;
Status.StatsOutputFolder = resolveStatsOutputFolder(Options);
Status.BaselinePath = resolveBaselinePath(Options);
Status.BaselineWorkbook = baselineWorkbookPath(Status.BaselinePath);
Status.BaselineExists = isfile(Status.BaselinePath);
Status.BaselineWorkbookExists = isfile(Status.BaselineWorkbook);
Status.LatestRegressionReport = findLatestRegressionReport(Status.StatsOutputFolder);
Status.HasRegressionReport = isfile(Status.LatestRegressionReport);
Status.ArchiveFolder = fullfile(fileparts(Status.BaselinePath),'Archive');
Status.ArchivedBaselines = listOxygenRegressionBaselines(Status.BaselinePath);
Status.ArchivedBaselineCount = height(Status.ArchivedBaselines);
Status.ReadyToRun = ~isempty(Status.StatsOutputFolder) && isfolder(Status.StatsOutputFolder) && ...
    Status.BaselineExists;
Status.StatusTable = createStatusTable(Status);

end

function Options = parseStatusOptions(varargin)

Options = struct();
Options.masterFolder = pwd;
Options.statsOutputPath = '';
Options.baselinePath = '';

if mod(numel(varargin),2)~=0
    error('OxygenDynamics:RegressionStatusOptions', ...
        'Optional arguments must be name-value pairs.');
end

for i = 1:2:numel(varargin)
    Name = char(varargin{i});
    Value = varargin{i+1};
    if ~isfield(Options,Name)
        error('OxygenDynamics:RegressionStatusOptions', ...
            'Unknown regression status option: %s',Name);
    end
    Options.(Name) = Value;
end

end

function StatsOutputFolder = resolveStatsOutputFolder(Options)

StatsOutputFolder = '';
if ~isempty(Options.statsOutputPath)
    if isfolder(Options.statsOutputPath)
        StatsOutputFolder = Options.statsOutputPath;
    else
        StatsOutputFolder = fileparts(Options.statsOutputPath);
    end
    return
end

try
    StatsOutputFolder = findLatestStatsOutputFolder(Options.masterFolder);
catch
    StatsOutputFolder = '';
end

end

function BaselinePath = resolveBaselinePath(Options)

if ~isempty(Options.baselinePath)
    BaselinePath = Options.baselinePath;
else
    BaselinePath = fullfile(Options.masterFolder,'Regression_Baselines','OxygenRegressionBaseline.mat');
end

end

function WorkbookPath = baselineWorkbookPath(BaselinePath)

[Folder,Name] = fileparts(BaselinePath);
WorkbookPath = fullfile(Folder,[Name '.xlsx']);

end

function ReportPath = findLatestRegressionReport(StatsOutputFolder)

ReportPath = '';
if isempty(StatsOutputFolder)
    return
end
ReportFolder = fullfile(StatsOutputFolder,'Regression_Reports');
if ~isfolder(ReportFolder)
    return
end
Reports = dir(fullfile(ReportFolder,'OxygenRegressionReport_*.xlsx'));
if isempty(Reports)
    return
end
[~,Idx] = max([Reports.datenum]);
ReportPath = fullfile(Reports(Idx).folder,Reports(Idx).name);

end

function StatusTable = createStatusTable(Status)

Item = ["MasterFolder"; "StatsOutputFolder"; "BaselinePath"; "BaselineWorkbook"; ...
    "BaselineExists"; "BaselineWorkbookExists"; "LatestRegressionReport"; ...
    "HasRegressionReport"; "ArchivedBaselineCount"; "ReadyToRun"];
Value = [string(Status.MasterFolder); string(Status.StatsOutputFolder); ...
    string(Status.BaselinePath); string(Status.BaselineWorkbook); ...
    string(Status.BaselineExists); string(Status.BaselineWorkbookExists); ...
    string(Status.LatestRegressionReport); string(Status.HasRegressionReport); ...
    string(Status.ArchivedBaselineCount); string(Status.ReadyToRun)];
StatusTable = table(Item,Value);

end
