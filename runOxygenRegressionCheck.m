function CheckResult = runOxygenRegressionCheck(varargin)
%RUNOXYGENREGRESSIONCHECK One-command helper for baseline-aware regression checks.

setupOxygenDynamicsPath();

Options = applyRegressionConfig(parseCheckOptions(varargin{:}),nargin);
Status = getOxygenRegressionStatus('masterFolder',Options.masterFolder, ...
    'statsOutputPath',Options.statsOutputPath,'baselinePath',Options.baselinePath);

CheckResult = struct();
CheckResult.Status = Status;
CheckResult.RegressionResult = [];

disp(Status.StatusTable);

if isempty(Status.StatsOutputFolder) || ~isfolder(Status.StatsOutputFolder)
    warning('OxygenDynamics:RegressionNoStatsOutput', ...
        'No Stats_Output_* folder was found. Run stats first.');
    return
end

if ~Status.BaselineExists
    if Options.createBaselineIfMissing
        Baseline = createOxygenRegressionBaseline(Status.StatsOutputFolder,Status.BaselinePath);
        Status = getOxygenRegressionStatus('masterFolder',Options.masterFolder, ...
            'statsOutputPath',Status.StatsOutputFolder,'baselinePath',Status.BaselinePath);
        CheckResult.Status = Status;
        CheckResult.Baseline = Baseline;
    else
        warning('OxygenDynamics:RegressionBaselineMissing', ...
            'No regression baseline was found. Create one with createOxygenRegressionBaseline after reviewing a known-good stats output.');
        return
    end
end

CheckResult.RegressionResult = runOxygenRegressionTest(Status.StatsOutputFolder, ...
    Status.BaselinePath,'ThrowOnFailure',Options.throwOnFailure);

end

function Options = applyRegressionConfig(Options,NumUserArgs)

if NumUserArgs>0 || exist('OxygenDynamics_Config','file')~=2
    return
end

Config = OxygenDynamics_Config();
if ~isfield(Config,'Regression') || ~isstruct(Config.Regression)
    return
end

RegressionConfig = Config.Regression;
Fields = fieldnames(RegressionConfig);
for FieldIdx = 1:numel(Fields)
    FieldName = Fields{FieldIdx};
    if isfield(Options,FieldName)
        Options.(FieldName) = RegressionConfig.(FieldName);
    end
end

if ~isempty(Options.baselinePath) && ~isfolder(fileparts(Options.baselinePath)) && ...
        ~isAbsolutePath(Options.baselinePath)
    Options.baselinePath = fullfile(Options.masterFolder,Options.baselinePath);
end

end

function tf = isAbsolutePath(PathValue)

PathText = char(PathValue);
tf = ~isempty(regexp(PathText,'^[A-Za-z]:[\\/]', 'once')) || startsWith(PathText,filesep);

end

function Options = parseCheckOptions(varargin)

Options = struct();
Options.masterFolder = pwd;
Options.statsOutputPath = '';
Options.baselinePath = '';
Options.throwOnFailure = false;
Options.createBaselineIfMissing = false;

if mod(numel(varargin),2)~=0
    error('OxygenDynamics:RegressionCheckOptions', ...
        'Optional arguments must be name-value pairs.');
end

for i = 1:2:numel(varargin)
    Name = char(varargin{i});
    Value = varargin{i+1};
    if ~isfield(Options,Name)
        error('OxygenDynamics:RegressionCheckOptions', ...
            'Unknown regression check option: %s',Name);
    end
    Options.(Name) = Value;
end

end
