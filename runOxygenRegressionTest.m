function Result = runOxygenRegressionTest(StatsOutputPath,BaselinePath,varargin)
%RUNOXYGENREGRESSIONTEST Compare current stats output to a saved baseline.

setupOxygenDynamicsPath();

if nargin<1 || isempty(StatsOutputPath)
    StatsOutputPath = findLatestStatsOutputFolder();
end
if nargin<2 || isempty(BaselinePath)
    BaselinePath = fullfile(pwd,'Regression_Baselines','OxygenRegressionBaseline.mat');
end

Options = parseRegressionOptions(varargin{:});
if ~isfile(BaselinePath)
    error('OxygenDynamics:RegressionBaselineMissing', ...
        'Regression baseline was not found. Create it first with createOxygenRegressionBaseline.');
end

LoadedBaseline = load(BaselinePath,'Baseline');
Expected = LoadedBaseline.Baseline;
Actual = extractOxygenRegressionMetrics(StatsOutputPath);

Comparison = compareNumericMetrics(Expected.NumericMetrics,Actual.NumericMetrics,Options);
TextComparison = compareTextMetrics(Expected.TextMetrics,Actual.TextMetrics);
GuardrailChecks = createScientificGuardrailChecks(Actual);
if ~Options.StrictScientificChecks
    GuardrailChecks.Passed(:) = true;
end

Result = struct();
Result.Passed = all(Comparison.Passed) && all(TextComparison.Passed) && all(GuardrailChecks.Passed);
Result.BaselinePath = BaselinePath;
Result.ExpectedDataOutputPath = Expected.DataOutputPath;
Result.ActualDataOutputPath = Actual.DataOutputPath;
Result.NumericComparison = Comparison;
Result.TextComparison = TextComparison;
Result.GuardrailChecks = GuardrailChecks;
if isfield(Expected,'Metadata')
    Result.ExpectedMetadata = Expected.Metadata;
else
    Result.ExpectedMetadata = table();
end
if isfield(Actual,'Metadata')
    Result.ActualMetadata = Actual.Metadata;
else
    Result.ActualMetadata = table();
end
if isfield(Expected,'CodeManifest') && isfield(Actual,'CodeManifest')
    Result.CodeManifestComparison = compareCodeManifests(Expected.CodeManifest,Actual.CodeManifest);
else
    Result.CodeManifestComparison = table();
end
if isfield(Expected,'FileManifest') && isfield(Actual,'FileManifest')
    Result.FileManifestComparison = compareFileManifests(Expected.FileManifest,Actual.FileManifest);
else
    Result.FileManifestComparison = table();
end
Result.RegressionSummary = createRegressionSummary(Result);
Result.ReviewFirst = createRegressionReviewFirstTable(Result);

if Options.WriteReport
    Result.ReportPath = writeRegressionReport(Result,StatsOutputPath);
end

if Result.Passed
    fprintf('Oxygen regression test passed.\n');
else
    Failed = Comparison(~Comparison.Passed,:);
    FailedText = TextComparison(~TextComparison.Passed,:);
    FailedGuardrails = GuardrailChecks(~GuardrailChecks.Passed,:);
    fprintf('Oxygen regression test failed: %d numeric, %d text, and %d guardrail checks failed.\n', ...
        height(Failed),height(FailedText),height(FailedGuardrails));
    if ~isempty(Failed)
        disp(Failed(:,{'Metric','Expected','Actual','AbsDiff','AllowedTolerance'}));
    end
    if ~isempty(FailedText)
        disp(FailedText);
    end
    if ~isempty(FailedGuardrails)
        disp(FailedGuardrails);
    end
    fprintf('Regression summary:\n');
    disp(Result.RegressionSummary(:,{'CheckType','Category','Metric','Status','Message'}));
    if Options.ThrowOnFailure
        error('OxygenDynamics:RegressionFailed', ...
            'Current stats output differs from the saved regression baseline.');
    end
end

end

function Options = parseRegressionOptions(varargin)

Options = struct();
Options.AbsoluteTolerance = 1e-9;
Options.RelativeTolerance = 1e-6;
Options.WriteReport = true;
Options.StrictScientificChecks = true;
Options.ThrowOnFailure = true;

if mod(numel(varargin),2)~=0
    error('OxygenDynamics:RegressionOptions', ...
        'Optional arguments must be name-value pairs.');
end

for i = 1:2:numel(varargin)
    Name = char(varargin{i});
    Value = varargin{i+1};
    if ~isfield(Options,Name)
        error('OxygenDynamics:RegressionOptions', ...
            'Unknown regression option: %s',Name);
    end
    Options.(Name) = Value;
end

end

function Comparison = compareNumericMetrics(Expected,Actual,Options)

[AllMetrics,ExpectedIdx] = stableUnique(Expected.Metric);
[~,ActualMetricIdx] = ismember(AllMetrics,Actual.Metric);
ExpectedValue = Expected.Value(ExpectedIdx);
ActualValue = nan(numel(AllMetrics),1);
ActualFound = ActualMetricIdx>0;
ActualValue(ActualFound) = Actual.Value(ActualMetricIdx(ActualFound));

AbsDiff = abs(ActualValue - ExpectedValue);
AllowedTolerance = Options.AbsoluteTolerance + Options.RelativeTolerance .* abs(ExpectedValue);
BothNan = isnan(ExpectedValue) & isnan(ActualValue);
Passed = (AbsDiff <= AllowedTolerance | BothNan) & ActualFound;

Comparison = table(AllMetrics,ExpectedValue,ActualValue,AbsDiff,AllowedTolerance,Passed, ...
    'VariableNames',{'Metric','Expected','Actual','AbsDiff','AllowedTolerance','Passed'});

end

function Comparison = compareTextMetrics(Expected,Actual)

[AllMetrics,ExpectedIdx] = stableUnique(Expected.Metric);
[~,ActualMetricIdx] = ismember(AllMetrics,Actual.Metric);
ExpectedValue = Expected.Value(ExpectedIdx);
ActualValue = strings(numel(AllMetrics),1);
ActualFound = ActualMetricIdx>0;
ActualValue(ActualFound) = Actual.Value(ActualMetricIdx(ActualFound));
Passed = ExpectedValue==ActualValue & ActualFound;

Comparison = table(AllMetrics,ExpectedValue,ActualValue,Passed, ...
    'VariableNames',{'Metric','Expected','Actual','Passed'});

end

function CodeComparison = compareCodeManifests(ExpectedManifest,ActualManifest)

ExpectedFiles = ExpectedManifest.RelativePath;
ActualFiles = ActualManifest.RelativePath;
AllFiles = unique([ExpectedFiles; ActualFiles],'stable');
[~,ExpectedIdx] = ismember(AllFiles,ExpectedFiles);
[~,ActualIdx] = ismember(AllFiles,ActualFiles);

ExpectedSHA256 = strings(numel(AllFiles),1);
ActualSHA256 = strings(numel(AllFiles),1);
ExpectedSHA256(ExpectedIdx>0) = ExpectedManifest.SHA256(ExpectedIdx(ExpectedIdx>0));
ActualSHA256(ActualIdx>0) = ActualManifest.SHA256(ActualIdx(ActualIdx>0));

Status = strings(numel(AllFiles),1);
for i = 1:numel(AllFiles)
    if ExpectedIdx(i)==0
        Status(i) = "Added";
    elseif ActualIdx(i)==0
        Status(i) = "Removed";
    elseif ExpectedSHA256(i)==ActualSHA256(i)
        Status(i) = "Unchanged";
    else
        Status(i) = "Changed";
    end
end

CodeComparison = table(AllFiles,Status,ExpectedSHA256,ActualSHA256, ...
    'VariableNames',{'RelativePath','Status','ExpectedSHA256','ActualSHA256'});

end

function FileComparison = compareFileManifests(ExpectedManifest,ActualManifest)

ExpectedKeys = ExpectedManifest.Role + "|" + ExpectedManifest.Path;
ActualKeys = ActualManifest.Role + "|" + ActualManifest.Path;
AllKeys = unique([ExpectedKeys; ActualKeys],'stable');
[~,ExpectedIdx] = ismember(AllKeys,ExpectedKeys);
[~,ActualIdx] = ismember(AllKeys,ActualKeys);

Role = strings(numel(AllKeys),1);
Path = strings(numel(AllKeys),1);
ExpectedSHA256 = strings(numel(AllKeys),1);
ActualSHA256 = strings(numel(AllKeys),1);
ExpectedExists = false(numel(AllKeys),1);
ActualExists = false(numel(AllKeys),1);

for i = 1:numel(AllKeys)
    Parts = split(AllKeys(i),"|");
    Role(i) = Parts(1);
    Path(i) = strjoin(Parts(2:end),"|");
end

ExpectedMask = ExpectedIdx>0;
ActualMask = ActualIdx>0;
ExpectedSHA256(ExpectedMask) = ExpectedManifest.SHA256(ExpectedIdx(ExpectedMask));
ActualSHA256(ActualMask) = ActualManifest.SHA256(ActualIdx(ActualMask));
ExpectedExists(ExpectedMask) = ExpectedManifest.Exists(ExpectedIdx(ExpectedMask));
ActualExists(ActualMask) = ActualManifest.Exists(ActualIdx(ActualMask));

Status = strings(numel(AllKeys),1);
for i = 1:numel(AllKeys)
    if ExpectedIdx(i)==0
        Status(i) = "Added";
    elseif ActualIdx(i)==0
        Status(i) = "Removed";
    elseif ExpectedSHA256(i)==ActualSHA256(i) && ExpectedExists(i)==ActualExists(i)
        Status(i) = "Unchanged";
    else
        Status(i) = "Changed";
    end
end

FileComparison = table(Role,Path,Status,ExpectedExists,ActualExists,ExpectedSHA256,ActualSHA256);

end

function Summary = createRegressionSummary(Result)

CheckType = strings(0,1);
Category = strings(0,1);
Metric = strings(0,1);
Expected = nan(0,1);
Actual = nan(0,1);
Delta = nan(0,1);
PercentDelta = nan(0,1);
Status = strings(0,1);
Message = strings(0,1);

[CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message] = addOverallSummaryRow( ...
    CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message,Result);

NumericRows = Result.NumericComparison;
NumericRows.PercentDelta = computePercentDelta(NumericRows.Expected,NumericRows.Actual);
NumericRows.SortValue = abs(NumericRows.PercentDelta);
NumericRows.SortValue(~isfinite(NumericRows.SortValue)) = abs(NumericRows.AbsDiff(~isfinite(NumericRows.SortValue)));
NumericRows = sortrows(NumericRows,{'Passed','SortValue'},{'ascend','descend'});
NumRowsToWrite = min(height(NumericRows),20);
for RowIdx = 1:NumRowsToWrite
    [CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message] = addNumericSummaryRow( ...
        CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message,NumericRows(RowIdx,:));
end

FailedText = Result.TextComparison(~Result.TextComparison.Passed,:);
for RowIdx = 1:height(FailedText)
    [CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message] = addTextSummaryRow( ...
        CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message,FailedText(RowIdx,:));
end

FailedGuardrails = Result.GuardrailChecks(~Result.GuardrailChecks.Passed,:);
for RowIdx = 1:height(FailedGuardrails)
    [CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message] = addGuardrailSummaryRow( ...
        CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message,FailedGuardrails(RowIdx,:));
end

if isfield(Result,'CodeManifestComparison') && ~isempty(Result.CodeManifestComparison)
    ChangedCodeRows = Result.CodeManifestComparison(Result.CodeManifestComparison.Status~="Unchanged",:);
    if ~isempty(ChangedCodeRows)
        [CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message] = appendSummaryRow( ...
            CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message, ...
            "CodeManifest","CodeChange","ChangedFiles",height(ChangedCodeRows),height(ChangedCodeRows),0,0, ...
            "INFO",sprintf('%d MATLAB code files changed since the baseline.',height(ChangedCodeRows)));
    end
end

if isfield(Result,'FileManifestComparison') && ~isempty(Result.FileManifestComparison)
    ChangedFileRows = Result.FileManifestComparison(Result.FileManifestComparison.Status~="Unchanged",:);
    if ~isempty(ChangedFileRows)
        [CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message] = appendSummaryRow( ...
            CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message, ...
            "FileManifest","InputOutputFileChange","ChangedFiles",height(ChangedFileRows),height(ChangedFileRows),0,0, ...
            "INFO",sprintf('%d input/output files changed since the baseline.',height(ChangedFileRows)));
    end
end

Summary = table(CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message);

end

function ReviewFirst = createRegressionReviewFirstTable(Result)

Issue = strings(0,1);
Category = strings(0,1);
Status = strings(0,1);
WhereToLook = strings(0,1);
RecommendedAction = strings(0,1);

FailedGuardrails = Result.GuardrailChecks(~Result.GuardrailChecks.Passed,:);
for RowIdx = 1:height(FailedGuardrails)
    [Issue,Category,Status,WhereToLook,RecommendedAction] = appendReviewRow( ...
        Issue,Category,Status,WhereToLook,RecommendedAction, ...
        FailedGuardrails.Metric(RowIdx),"ScientificGuardrail","FAIL","ScientificGuardrails", ...
        guardrailRecommendedAction(FailedGuardrails.Metric(RowIdx)));
end

FailedNumeric = Result.NumericComparison(~Result.NumericComparison.Passed,:);
for RowIdx = 1:height(FailedNumeric)
    [Issue,Category,Status,WhereToLook,RecommendedAction] = appendReviewRow( ...
        Issue,Category,Status,WhereToLook,RecommendedAction, ...
        FailedNumeric.Metric(RowIdx),numericFailureCategory(FailedNumeric.Metric(RowIdx)), ...
        "FAIL","NumericChecks","Compare expected, actual, and allowed tolerance.");
end

FailedText = Result.TextComparison(~Result.TextComparison.Passed,:);
for RowIdx = 1:height(FailedText)
    [Issue,Category,Status,WhereToLook,RecommendedAction] = appendReviewRow( ...
        Issue,Category,Status,WhereToLook,RecommendedAction, ...
        FailedText.Metric(RowIdx),"DatasetMetadataChange","FAIL","TextChecks", ...
        "Confirm whether the dataset identity or grouping metadata intentionally changed.");
end

if isfield(Result,'CodeManifestComparison') && ~isempty(Result.CodeManifestComparison)
    ChangedCode = Result.CodeManifestComparison(Result.CodeManifestComparison.Status~="Unchanged",:);
    if ~isempty(ChangedCode)
        [Issue,Category,Status,WhereToLook,RecommendedAction] = appendReviewRow( ...
            Issue,Category,Status,WhereToLook,RecommendedAction, ...
            "Changed MATLAB files","CodeChange","INFO","CodeManifestDiff", ...
            "Review code changes before accepting a new regression baseline.");
    end
end

if isfield(Result,'FileManifestComparison') && ~isempty(Result.FileManifestComparison)
    ChangedFiles = Result.FileManifestComparison(Result.FileManifestComparison.Status~="Unchanged",:);
    if ~isempty(ChangedFiles)
        [Issue,Category,Status,WhereToLook,RecommendedAction] = appendReviewRow( ...
            Issue,Category,Status,WhereToLook,RecommendedAction, ...
            "Changed input/output files","InputOutputFileChange","INFO","FileManifestDiff", ...
            "Confirm that changed files are expected for this regression run.");
    end
end

if isempty(Issue)
    [Issue,Category,Status,WhereToLook,RecommendedAction] = appendReviewRow( ...
        Issue,Category,Status,WhereToLook,RecommendedAction, ...
        "Regression passed","Overall","PASS","RegressionSummary", ...
        "No action needed unless you want to inspect informational manifest rows.");
end

ReviewFirst = table(Issue,Category,Status,WhereToLook,RecommendedAction);

end

function [Issue,Category,Status,WhereToLook,RecommendedAction] = appendReviewRow( ...
    Issue,Category,Status,WhereToLook,RecommendedAction,ThisIssue,ThisCategory, ...
    ThisStatus,ThisWhereToLook,ThisAction)

Issue(end+1,1) = string(ThisIssue);
Category(end+1,1) = string(ThisCategory);
Status(end+1,1) = string(ThisStatus);
WhereToLook(end+1,1) = string(ThisWhereToLook);
RecommendedAction(end+1,1) = string(ThisAction);

end

function Action = guardrailRecommendedAction(Metric)

Metric = string(Metric);
if contains(Metric,"HypoxicBurden_EventArea")
    Action = "Check event-specific area matching before using hypoxic burden outputs.";
elseif contains(Metric,"HypoxicBurden_EventRows")
    Action = "Confirm that hypoxic burden uses individual event rows, not ROI summary rows.";
elseif contains(Metric,"SinkCountNorm")
    Action = "Check FOV edge and recording-area normalization metadata.";
else
    Action = "Inspect the scientific guardrail row and underlying metrics.";
end

end

function [CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message] = addOverallSummaryRow( ...
    CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message,Result)

NumFailed = sum(~Result.NumericComparison.Passed);
TextFailed = sum(~Result.TextComparison.Passed);
GuardrailFailed = sum(~Result.GuardrailChecks.Passed);
if Result.Passed
    ThisStatus = "PASS";
    ThisMessage = "All numeric, text, and scientific guardrail checks passed.";
else
    ThisStatus = "FAIL";
    ThisMessage = sprintf('%d numeric, %d text, and %d scientific guardrail checks failed.', ...
        NumFailed,TextFailed,GuardrailFailed);
end

[CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message] = appendSummaryRow( ...
    CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message, ...
    "Overall","Overall","Regression",NaN,NaN,NaN,NaN,ThisStatus,ThisMessage);

end

function [CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message] = addNumericSummaryRow( ...
    CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message,Row)

ThisStatus = passFailText(Row.Passed);
ThisDelta = Row.Actual - Row.Expected;
ThisPercent = computePercentDelta(Row.Expected,Row.Actual);
ThisMessage = sprintf('%s expected %.6g, actual %.6g, delta %.6g (%.3g%%).', ...
    char(Row.Metric),Row.Expected,Row.Actual,ThisDelta,ThisPercent);

[CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message] = appendSummaryRow( ...
    CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message, ...
    "Numeric",numericFailureCategory(Row.Metric),Row.Metric,Row.Expected,Row.Actual, ...
    ThisDelta,ThisPercent,ThisStatus,ThisMessage);

end

function [CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message] = addTextSummaryRow( ...
    CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message,Row)

ThisMessage = sprintf('%s expected "%s", actual "%s".', ...
    char(Row.Metric),char(Row.Expected),char(Row.Actual));
[CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message] = appendSummaryRow( ...
    CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message, ...
    "Text","DatasetMetadataChange",Row.Metric,NaN,NaN,NaN,NaN,"FAIL",ThisMessage);

end

function [CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message] = addGuardrailSummaryRow( ...
    CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message,Row)

ThisMessage = sprintf('%s failed: expected %s. %s', ...
    char(Row.Metric),char(Row.ExpectedRule),char(Row.Notes));
[CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message] = appendSummaryRow( ...
    CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message, ...
    "ScientificGuardrail","ScientificGuardrail",Row.Metric,NaN,Row.ActualValue,NaN,NaN, ...
    "FAIL",ThisMessage);

end

function [CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message] = appendSummaryRow( ...
    CheckType,Category,Metric,Expected,Actual,Delta,PercentDelta,Status,Message, ...
    ThisType,ThisCategory,ThisMetric,ThisExpected,ThisActual,ThisDelta,ThisPercent,ThisStatus,ThisMessage)

CheckType(end+1,1) = string(ThisType);
Category(end+1,1) = string(ThisCategory);
Metric(end+1,1) = string(ThisMetric);
Expected(end+1,1) = double(ThisExpected);
Actual(end+1,1) = double(ThisActual);
Delta(end+1,1) = double(ThisDelta);
PercentDelta(end+1,1) = double(ThisPercent);
Status(end+1,1) = string(ThisStatus);
Message(end+1,1) = string(ThisMessage);

end

function PercentDelta = computePercentDelta(Expected,Actual)

PercentDelta = nan(size(Expected));
Mask = isfinite(Expected) & Expected~=0 & isfinite(Actual);
PercentDelta(Mask) = 100 .* (Actual(Mask) - Expected(Mask)) ./ abs(Expected(Mask));

end

function Text = passFailText(Passed)

if Passed
    Text = "PASS";
else
    Text = "FAIL";
end

end

function Category = numericFailureCategory(Metric)

MetricText = string(Metric);
if startsWith(MetricText,"HypoxicBurden_EventArea") || ...
        contains(MetricText,"EventAreaMatched") || contains(MetricText,"EventAreaFallback")
    Category = "ScientificGuardrail";
elseif startsWith(MetricText,"SinkCountNorm") || contains(MetricText,"PerMm2")
    Category = "AreaNormalization";
else
    Category = "NumericMetricDrift";
end

end

function GuardrailChecks = createScientificGuardrailChecks(Actual)

Metric = strings(0,1);
ActualValue = zeros(0,1);
ExpectedRule = strings(0,1);
Passed = false(0,1);
Notes = strings(0,1);

SinkEventRows = metricValue(Actual.NumericMetrics,'SinkEvent_Count');
BurdenRows = metricValue(Actual.NumericMetrics,'HypoxicBurden_EventRow_Count');
MatchedAreaRows = metricValue(Actual.NumericMetrics,'HypoxicBurden_EventAreaMatched_Count');
FallbackAreaRows = metricValue(Actual.NumericMetrics,'HypoxicBurden_EventAreaFallback_Count');
BurdenSum = metricValue(Actual.NumericMetrics,'HypoxicBurden_EventContribution_Sum');
NormRows = metricValue(Actual.NumericMetrics,'SinkCountNorm_Row_Count');
FovEdgeMean = metricValue(Actual.NumericMetrics,'SinkCountNorm_FOVEdge_Mean');
AreaCorrectionMean = metricValue(Actual.NumericMetrics,'SinkCountNorm_AreaCorrectionFactor_Mean');

[Metric,ActualValue,ExpectedRule,Passed,Notes] = addGuardrail(Metric,ActualValue,ExpectedRule,Passed,Notes, ...
    'HypoxicBurden_EventRowsPresent',BurdenRows,'> 0',BurdenRows>0, ...
    'Hypoxic burden should be based on true individual event rows.');
[Metric,ActualValue,ExpectedRule,Passed,Notes] = addGuardrail(Metric,ActualValue,ExpectedRule,Passed,Notes, ...
    'HypoxicBurden_EventRowsMatchSinkEvents',BurdenRows,'equals SinkEvent_Count', ...
    isequaln(BurdenRows,SinkEventRows), ...
    'The burden table should contain one row per oxygen sink event.');
[Metric,ActualValue,ExpectedRule,Passed,Notes] = addGuardrail(Metric,ActualValue,ExpectedRule,Passed,Notes, ...
    'HypoxicBurden_EventAreaFallbackRows',FallbackAreaRows,'equals 0', ...
    isequaln(FallbackAreaRows,0), ...
    'No event should use ROI-level area as a fallback for hypoxic burden.');
[Metric,ActualValue,ExpectedRule,Passed,Notes] = addGuardrail(Metric,ActualValue,ExpectedRule,Passed,Notes, ...
    'HypoxicBurden_EventAreaMatchedRows',MatchedAreaRows,'equals HypoxicBurden_EventRow_Count', ...
    isequaln(MatchedAreaRows,BurdenRows) && BurdenRows>0, ...
    'All hypoxic burden rows should have event-specific area matches.');
[Metric,ActualValue,ExpectedRule,Passed,Notes] = addGuardrail(Metric,ActualValue,ExpectedRule,Passed,Notes, ...
    'HypoxicBurden_EventContributionFinite',BurdenSum,'finite',isfinite(BurdenSum), ...
    'The summed event burden contribution should be finite.');
[Metric,ActualValue,ExpectedRule,Passed,Notes] = addGuardrail(Metric,ActualValue,ExpectedRule,Passed,Notes, ...
    'SinkCountNorm_RowsPresent',NormRows,'> 0',NormRows>0, ...
    'Area-normalized sink counts require one normalization row per recording.');
[Metric,ActualValue,ExpectedRule,Passed,Notes] = addGuardrail(Metric,ActualValue,ExpectedRule,Passed,Notes, ...
    'SinkCountNorm_FOVEdgeFinite',FovEdgeMean,'finite and > 0', ...
    isfinite(FovEdgeMean) && FovEdgeMean>0, ...
    'FOV edge is needed for kappa = 1000 / FOV edge.');
[Metric,ActualValue,ExpectedRule,Passed,Notes] = addGuardrail(Metric,ActualValue,ExpectedRule,Passed,Notes, ...
    'SinkCountNorm_AreaCorrectionFinite',AreaCorrectionMean,'finite and > 0', ...
    isfinite(AreaCorrectionMean) && AreaCorrectionMean>0, ...
    'Area correction factor is needed for OxySinksPer1mm2.');

GuardrailChecks = table(Metric,ActualValue,ExpectedRule,Passed,Notes);

end

function Value = metricValue(Metrics,MetricName)

Idx = find(Metrics.Metric==MetricName,1,'first');
if isempty(Idx)
    Value = NaN;
else
    Value = Metrics.Value(Idx);
end

end

function [Metric,ActualValue,ExpectedRule,Passed,Notes] = addGuardrail( ...
    Metric,ActualValue,ExpectedRule,Passed,Notes,MetricName,Value,Rule,IsPassed,Note)

Metric(end+1,1) = string(MetricName);
ActualValue(end+1,1) = double(Value);
ExpectedRule(end+1,1) = string(Rule);
Passed(end+1,1) = logical(IsPassed);
Notes(end+1,1) = string(Note);

end

function [Values,Idx] = stableUnique(ValuesIn)

[Values,Idx] = unique(ValuesIn,'stable');

end

function ReportPath = writeRegressionReport(Result,StatsOutputPath)

if isfolder(StatsOutputPath)
    ReportFolder = fullfile(StatsOutputPath,'Regression_Reports');
else
    ReportFolder = fullfile(fileparts(StatsOutputPath),'Regression_Reports');
end
if ~isfolder(ReportFolder)
    mkdir(ReportFolder);
end

Timestamp = formatRegressionTimestamp();
ReportPath = fullfile(ReportFolder,['OxygenRegressionReport_' Timestamp '.xlsx']);
if isfield(Result,'ReviewFirst')
    writetable(Result.ReviewFirst,ReportPath,'Sheet','ReviewFirst');
end
Summary = table(string(Result.Passed),string(Result.BaselinePath), ...
    string(Result.ExpectedDataOutputPath),string(Result.ActualDataOutputPath), ...
    'VariableNames',{'Passed','BaselinePath','ExpectedDataOutput','ActualDataOutput'});
writetable(Summary,ReportPath,'Sheet','Summary');
writetable(Result.NumericComparison,ReportPath,'Sheet','NumericChecks');
writetable(Result.TextComparison,ReportPath,'Sheet','TextChecks');
writetable(Result.GuardrailChecks,ReportPath,'Sheet','ScientificGuardrails');
writetable(Result.RegressionSummary,ReportPath,'Sheet','RegressionSummary');
if isfield(Result,'ExpectedMetadata')
    writetable(Result.ExpectedMetadata,ReportPath,'Sheet','BaselineMetadata');
end
if isfield(Result,'ActualMetadata')
    writetable(Result.ActualMetadata,ReportPath,'Sheet','ActualMetadata');
end
if isfield(Result,'CodeManifestComparison') && ~isempty(Result.CodeManifestComparison)
    writetable(Result.CodeManifestComparison,ReportPath,'Sheet','CodeManifestDiff');
end
if isfield(Result,'FileManifestComparison') && ~isempty(Result.FileManifestComparison)
    writetable(Result.FileManifestComparison,ReportPath,'Sheet','FileManifestDiff');
end

end
