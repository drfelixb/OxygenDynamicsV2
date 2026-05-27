function Result = checkOxygenPipelineHealth(SearchRoot)
%CHECKOXYGENPIPELINEHEALTH Run lightweight install and latest-output checks.

CodeRoot = setupOxygenDynamicsPath();
if nargin<1 || isempty(SearchRoot)
    SearchRoot = pwd;
end
SearchRoot = char(SearchRoot);

Component = strings(0,1);
Status = strings(0,1);
Message = strings(0,1);
RecommendedAction = strings(0,1);

[Component,Status,Message,RecommendedAction] = appendRequiredFileChecks( ...
    Component,Status,Message,RecommendedAction,CodeRoot);
[Component,Status,Message,RecommendedAction,LatestStatsFolder,AcceptanceStatus] = appendStatsAcceptanceCheck( ...
    Component,Status,Message,RecommendedAction,SearchRoot);
[Component,Status,Message,RecommendedAction,RegressionStatus] = appendRegressionReadinessCheck( ...
    Component,Status,Message,RecommendedAction,SearchRoot,LatestStatsFolder);

Checks = table(Component,Status,Message,RecommendedAction);

Result = struct();
Result.CodeRoot = CodeRoot;
Result.SearchRoot = SearchRoot;
Result.LatestStatsFolder = LatestStatsFolder;
Result.AcceptanceStatus = AcceptanceStatus;
Result.RegressionStatus = RegressionStatus;
Result.Checks = Checks;
Result.HasFailures = any(Status=="FAIL");
Result.NeedsReview = any(Status=="REVIEW");

printHealthSummary(Result);

end

function [Component,Status,Message,RecommendedAction] = appendRequiredFileChecks( ...
    Component,Status,Message,RecommendedAction,CodeRoot)

RequiredFiles = { ...
    'Start_OxygenPipeline.m'; ...
    'OxygenDynamics_GUI.m'; ...
    'OxygenDynamics_Wrapper.m'; ...
    'runOxygenDynamicsStats.m'; ...
    'OxygenDynamics_Config.m'; ...
    'setupOxygenDynamicsPath.m'; ...
    'runOxygenPipelineSmokeTest.m'; ...
    fullfile('helpers','runOxygenDynamicsMaster.m'); ...
    fullfile('helpers','runOxygenDynamicsTiffout.m'); ...
    fullfile('helpers','runOxygenDynamicsBehaviour.m'); ...
    fullfile('helpers','runiOSDynamicsMaster.m'); ...
    fullfile('helpers','runiOSTiffout.m'); ...
    fullfile('external','loadtiff.m'); ...
    fullfile('external','saveastiff.m')};

for FileIdx = 1:numel(RequiredFiles)
    FilePath = fullfile(CodeRoot,RequiredFiles{FileIdx});
    if isfile(FilePath)
        [Component,Status,Message,RecommendedAction] = appendHealthRow( ...
            Component,Status,Message,RecommendedAction, ...
            "Required file: " + string(RequiredFiles{FileIdx}),"PASS", ...
            "Found.","No action needed.");
    else
        [Component,Status,Message,RecommendedAction] = appendHealthRow( ...
            Component,Status,Message,RecommendedAction, ...
            "Required file: " + string(RequiredFiles{FileIdx}),"FAIL", ...
            "Missing from the code folder.","Restore the missing file before running the pipeline.");
    end
end

end

function [Component,Status,Message,RecommendedAction,LatestStatsFolder,AcceptanceStatus] = appendStatsAcceptanceCheck( ...
    Component,Status,Message,RecommendedAction,SearchRoot)

LatestStatsFolder = '';
AcceptanceStatus = struct();
try
    LatestStatsFolder = findLatestStatsOutputFolder(SearchRoot);
    AcceptanceStatus = getOxygenStatsAcceptanceStatus(LatestStatsFolder);
    if AcceptanceStatus.Passed
        RowStatus = "PASS";
    elseif AcceptanceStatus.ReviewCount>0
        RowStatus = "REVIEW";
    else
        RowStatus = "INFO";
    end
    [Component,Status,Message,RecommendedAction] = appendHealthRow( ...
        Component,Status,Message,RecommendedAction, ...
        "Latest stats acceptance",RowStatus, ...
        sprintf('%s: %s',AcceptanceStatus.OverallStatus,AcceptanceStatus.Message), ...
        "Inspect StatsAcceptance before refreshing a regression baseline.");
catch ME
    [Component,Status,Message,RecommendedAction] = appendHealthRow( ...
        Component,Status,Message,RecommendedAction, ...
        "Latest stats acceptance","INFO", ...
        sprintf('No latest stats output was reviewed: %s',ME.message), ...
        "Run stats, then rerun checkOxygenPipelineHealth.");
end

end

function [Component,Status,Message,RecommendedAction,RegressionStatus] = appendRegressionReadinessCheck( ...
    Component,Status,Message,RecommendedAction,SearchRoot,LatestStatsFolder)

RegressionStatus = struct();
try
    if isempty(LatestStatsFolder)
        RegressionStatus = getOxygenRegressionStatus('masterFolder',SearchRoot);
    else
        RegressionStatus = getOxygenRegressionStatus('masterFolder',SearchRoot, ...
            'statsOutputPath',LatestStatsFolder);
    end
    if RegressionStatus.ReadyToRun
        RowStatus = "PASS";
        RowMessage = "Regression baseline and stats output are available.";
    elseif ~RegressionStatus.BaselineExists
        RowStatus = "INFO";
        RowMessage = "No regression baseline found yet.";
    else
        RowStatus = "INFO";
        RowMessage = "Regression is not ready for the current dataset state.";
    end
    [Component,Status,Message,RecommendedAction] = appendHealthRow( ...
        Component,Status,Message,RecommendedAction, ...
        "Regression readiness",RowStatus,RowMessage, ...
        "Create a baseline after accepting a known-good stats run.");
catch ME
    [Component,Status,Message,RecommendedAction] = appendHealthRow( ...
        Component,Status,Message,RecommendedAction, ...
        "Regression readiness","INFO", ...
        sprintf('Regression readiness could not be checked: %s',ME.message), ...
        "Run stats and create a baseline when the output has been accepted.");
end

end

function [Component,Status,Message,RecommendedAction] = appendHealthRow( ...
    Component,Status,Message,RecommendedAction,ThisComponent,ThisStatus,ThisMessage,ThisAction)

Component(end+1,1) = string(ThisComponent);
Status(end+1,1) = string(ThisStatus);
Message(end+1,1) = string(ThisMessage);
RecommendedAction(end+1,1) = string(ThisAction);

end

function printHealthSummary(Result)

fprintf('\nOxygen pipeline health check\n');
fprintf('Code root: %s\n',Result.CodeRoot);
fprintf('Search root: %s\n',Result.SearchRoot);
if ~isempty(Result.LatestStatsFolder)
    fprintf('Latest stats output: %s\n',Result.LatestStatsFolder);
end
fprintf('Failures: %d\n',sum(Result.Checks.Status=="FAIL"));
fprintf('Review items: %d\n\n',sum(Result.Checks.Status=="REVIEW"));
disp(Result.Checks);

end
