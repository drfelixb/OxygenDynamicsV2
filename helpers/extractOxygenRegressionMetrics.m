function Metrics = extractOxygenRegressionMetrics(DataOutputPath)
%EXTRACTOXYGENREGRESSIONMETRICS Extract compact validation metrics from stats output.

if nargin<1 || isempty(DataOutputPath)
    error('OxygenDynamics:RegressionMissingInput', ...
        'A DataOutput.mat file or stats output folder is required.');
end

DataOutputPath = resolveDataOutputPath(DataOutputPath);
Data = load(DataOutputPath);

MetricNames = strings(0,1);
MetricValues = zeros(0,1);

[MetricNames,MetricValues] = addMetric(MetricNames,MetricValues,'SinkROI_Count', ...
    tableHeightFromField(Data,'Table_OxygenSinks_OutCombo'));
[MetricNames,MetricValues] = addMetric(MetricNames,MetricValues,'SinkEvent_Count', ...
    tableHeightFromField(Data,'Table_OxygenSinkEvents_OutCombo'));
[MetricNames,MetricValues] = addMetric(MetricNames,MetricValues,'SurgeROI_Count', ...
    tableHeightFromField(Data,'Table_OxygenSurges_OutCombo'));
[MetricNames,MetricValues] = addMetric(MetricNames,MetricValues,'SurgeEvent_Count', ...
    tableHeightFromField(Data,'Table_OxygenSurgeEvents_OutCombo'));

[MetricNames,MetricValues] = addTableUniqueCountMetric(MetricNames,MetricValues,Data, ...
    'Table_OxygenSinkEvents_OutCombo','Mouse','SinkEvent_UniqueMouse_Count');
[MetricNames,MetricValues] = addTableUniqueCountMetric(MetricNames,MetricValues,Data, ...
    'Table_OxygenSinkEvents_OutCombo','SinkID','SinkEvent_UniqueSinkSite_Count');

[MetricNames,MetricValues] = addHypoxicBurdenMetrics(MetricNames,MetricValues,Data);
[MetricNames,MetricValues] = addAreaNormalizationMetrics(MetricNames,MetricValues,Data);
[MetricNames,MetricValues] = addTraceMetrics(MetricNames,MetricValues,Data, ...
    'NumOngoingOxysinks','NumOngoingOxysinks');
[MetricNames,MetricValues] = addTraceMetrics(MetricNames,MetricValues,Data, ...
    'NumOngoingOxysinksPerMm2','NumOngoingOxysinksPerMm2');
[MetricNames,MetricValues] = addTraceMetrics(MetricNames,MetricValues,Data, ...
    'TotalSinkArea_Norm','TotalSinkArea_Norm');
[MetricNames,MetricValues] = addTraceMetrics(MetricNames,MetricValues,Data, ...
    'NumOngoingOxysurges','NumOngoingOxysurges');
[MetricNames,MetricValues] = addTraceMetrics(MetricNames,MetricValues,Data, ...
    'TotalSurgeArea','TotalSurgeArea');

NumericMetrics = table(MetricNames,MetricValues, ...
    'VariableNames',{'Metric','Value'});
NumericMetrics = sortrows(NumericMetrics,'Metric');

TextMetrics = createTextMetrics(Data,DataOutputPath);
Metrics = struct();
Metrics.Version = 1;
Metrics.Created = formatRegressionTimestamp();
Metrics.DataOutputPath = DataOutputPath;
Metrics.NumericMetrics = NumericMetrics;
Metrics.TextMetrics = TextMetrics;
Metrics.FileManifest = createOxygenRegressionFileManifest(DataOutputPath,TextMetrics);
Metrics.CodeManifest = createOxygenRegressionCodeManifest();
Metrics.Metadata = createRegressionMetadata(Data,DataOutputPath,TextMetrics);

end

function Metadata = createRegressionMetadata(Data,DataOutputPath,TextMetrics)

Item = strings(0,1);
Value = strings(0,1);

[Item,Value] = addMetadata(Item,Value,'Created',formatRegressionTimestamp());
[Item,Value] = addMetadata(Item,Value,'MATLABVersion',version);
[Item,Value] = addMetadata(Item,Value,'DataOutputPath',DataOutputPath);
[Item,Value] = addMetadata(Item,Value,'StatsOutputFolder',fileparts(DataOutputPath));
HelperFolder = fileparts(mfilename('fullpath'));
[Item,Value] = addMetadata(Item,Value,'ProjectRoot',fileparts(HelperFolder));

for i = 1:height(TextMetrics)
    [Item,Value] = addMetadata(Item,Value,TextMetrics.Metric(i),TextMetrics.Value(i));
end

if isfield(Data,'StatsInfo') && isstruct(Data.StatsInfo)
    if isfield(Data.StatsInfo,'Recordings')
        [Item,Value] = addMetadata(Item,Value,'RecordingCount',numel(Data.StatsInfo.Recordings));
    end
    if isfield(Data.StatsInfo,'OutputXlsx')
        [Item,Value] = addMetadata(Item,Value,'StatsWorkbook',Data.StatsInfo.OutputXlsx);
    end
end

try
    FileManifest = createOxygenRegressionFileManifest(DataOutputPath,TextMetrics);
    [Item,Value] = addMetadata(Item,Value,'ManifestFileCount',height(FileManifest));
    [Item,Value] = addMetadata(Item,Value,'FileManifestCombinedHash',combinedFileManifestHash(FileManifest));
catch
end

try
    CodeManifest = createOxygenRegressionCodeManifest();
    [Item,Value] = addMetadata(Item,Value,'CodeFileCount',height(CodeManifest));
    [Item,Value] = addMetadata(Item,Value,'CodeManifestCombinedHash',combinedManifestHash(CodeManifest));
catch
end

Metadata = table(Item,Value);

end

function Hash = combinedFileManifestHash(FileManifest)

if isempty(FileManifest)
    Hash = "";
    return
end
Combined = strjoin(cellstr(FileManifest.Role + "|" + FileManifest.Path + "|" + FileManifest.SHA256),newline);
Hash = string(textSha256(Combined));

end

function Hash = combinedManifestHash(CodeManifest)

if isempty(CodeManifest)
    Hash = "";
    return
end
Combined = strjoin(cellstr(CodeManifest.RelativePath + "|" + CodeManifest.SHA256),newline);
Hash = string(textSha256(Combined));

end


function [Item,Value] = addMetadata(Item,Value,Name,TextValue)

Item(end+1,1) = string(Name);
Value(end+1,1) = string(TextValue);

end

function DataOutputPath = resolveDataOutputPath(InputPath)

if isfolder(InputPath)
    DataOutputPath = fullfile(InputPath,'DataOutput.mat');
else
    DataOutputPath = InputPath;
end

if ~isfile(DataOutputPath)
    error('OxygenDynamics:RegressionDataOutputMissing', ...
        'Could not find DataOutput.mat at: %s',DataOutputPath);
end

end

function [Names,Values] = addMetric(Names,Values,Name,Value)

Names(end+1,1) = string(Name);
Values(end+1,1) = double(Value);

end

function Count = tableHeightFromField(Data,FieldName)

Count = NaN;
if isfield(Data,FieldName) && istable(Data.(FieldName))
    Count = height(Data.(FieldName));
end

end

function [Names,Values] = addTableUniqueCountMetric(Names,Values,Data,FieldName,ColumnName,MetricName)

Count = NaN;
if isfield(Data,FieldName) && istable(Data.(FieldName)) && ...
        ismember(ColumnName,Data.(FieldName).Properties.VariableNames)
    Count = numel(unique(string(Data.(FieldName).(ColumnName))));
end
[Names,Values] = addMetric(Names,Values,MetricName,Count);

end

function [Names,Values] = addHypoxicBurdenMetrics(Names,Values,Data)

EventTable = table();
RecordingTable = table();
if isfield(Data,'HypoxicBurden') && isstruct(Data.HypoxicBurden)
    if isfield(Data.HypoxicBurden,'EventTable')
        EventTable = Data.HypoxicBurden.EventTable;
    end
    if isfield(Data.HypoxicBurden,'RecordingTable')
        RecordingTable = Data.HypoxicBurden.RecordingTable;
    end
end

[Names,Values] = addMetric(Names,Values,'HypoxicBurden_EventRow_Count',heightIfTable(EventTable));
[Names,Values] = addMetric(Names,Values,'HypoxicBurden_RecordingRow_Count',heightIfTable(RecordingTable));
[Names,Values] = addMetric(Names,Values,'HypoxicBurden_EventContribution_Sum', ...
    tableColumnSum(EventTable,'PerEventBurdenContribution'));
[Names,Values] = addMetric(Names,Values,'HypoxicBurden_EventContributionPerMm2_Sum', ...
    tableColumnSum(EventTable,'PerEventBurdenContribution_per_mm2'));
[Names,Values] = addMetric(Names,Values,'HypoxicBurden_ByRecording_Sum', ...
    tableColumnSum(RecordingTable,'HypoxicBurden'));
[Names,Values] = addMetric(Names,Values,'HypoxicBurden_ByRecordingPerMm2_Sum', ...
    tableColumnSum(RecordingTable,'HypoxicBurden_per_mm2'));
[Names,Values] = addMetric(Names,Values,'HypoxicBurden_ByRecordingPerSec_Sum', ...
    tableColumnSum(RecordingTable,'HypoxicBurden_per_sec'));
[Names,Values] = addMetric(Names,Values,'HypoxicBurden_ByRecordingPerMin_Sum', ...
    tableColumnSum(RecordingTable,'HypoxicBurden_per_min'));
[Names,Values] = addMetric(Names,Values,'HypoxicBurden_ByRecordingPerMm2PerSec_Sum', ...
    tableColumnSum(RecordingTable,'HypoxicBurden_per_mm2_per_sec'));
[Names,Values] = addMetric(Names,Values,'HypoxicBurden_ByRecordingPerMm2PerMin_Sum', ...
    tableColumnSum(RecordingTable,'HypoxicBurden_per_mm2_per_min'));
[Names,Values] = addMetric(Names,Values,'HypoxicBurden_EventAreaMatched_Count', ...
    tableLogicalCount(EventTable,'BurdenAreaEventSpecificMatched',true));
[Names,Values] = addMetric(Names,Values,'HypoxicBurden_EventAreaFallback_Count', ...
    tableLogicalCount(EventTable,'BurdenAreaEventSpecificMatched',false));
[Names,Values] = addMetric(Names,Values,'HypoxicBurden_EventArea_Mean', ...
    tableColumnMean(EventTable,'BurdenArea_um2'));
[Names,Values] = addMetric(Names,Values,'HypoxicBurden_EventAmplitude_Mean', ...
    tableColumnMean(EventTable,'BurdenAmplitudePercent'));
[Names,Values] = addMetric(Names,Values,'HypoxicBurden_EventDuration_Mean', ...
    tableColumnMean(EventTable,'BurdenDuration_sec'));
[Names,Values] = addMetric(Names,Values,'HypoxicBurden_RecordingArea_Mean', ...
    tableColumnMean(EventTable,'BurdenRecordingArea_um2'));
[Names,Values] = addMetric(Names,Values,'HypoxicBurden_RecordingDuration_Mean', ...
    tableColumnMean(EventTable,'BurdenRecordingDuration_sec'));

end

function [Names,Values] = addAreaNormalizationMetrics(Names,Values,Data)

if isfield(Data,'SinkCountAreaNormalization')
    NormTable = Data.SinkCountAreaNormalization;
else
    NormTable = table();
end

[Names,Values] = addMetric(Names,Values,'SinkCountNorm_Row_Count',heightIfTable(NormTable));
[Names,Values] = addMetric(Names,Values,'SinkCountNorm_FOVEdge_Mean', ...
    tableColumnMean(NormTable,'FOVEdge_um'));
[Names,Values] = addMetric(Names,Values,'SinkCountNorm_Kappa_Mean', ...
    tableColumnMean(NormTable,'Kappa_1000umPerFOVEdge'));
[Names,Values] = addMetric(Names,Values,'SinkCountNorm_AreaCorrectionFactor_Mean', ...
    tableColumnMean(NormTable,'AreaCorrectionFactor_1mm2'));

end

function [Names,Values] = addTraceMetrics(Names,Values,Data,FieldName,MetricPrefix)

TraceCell = {};
if isfield(Data,FieldName)
    TraceCell = Data.(FieldName);
end

TraceValues = extractTraceValues(TraceCell);
[Names,Values] = addMetric(Names,Values,MetricPrefix + "_TraceFiniteCount",sum(isfinite(TraceValues)));
[Names,Values] = addMetric(Names,Values,MetricPrefix + "_TraceSum",sum(TraceValues,'omitnan'));
[Names,Values] = addMetric(Names,Values,MetricPrefix + "_TraceMean",mean(TraceValues,'omitnan'));
[Names,Values] = addMetric(Names,Values,MetricPrefix + "_TraceMax",maxOrNan(TraceValues));

end

function TextMetrics = createTextMetrics(Data,DataOutputPath)

Names = strings(0,1);
Values = strings(0,1);
DataOutputPath = char(DataOutputPath); %#ok<NASGU>

if isfield(Data,'StatsInfo') && isstruct(Data.StatsInfo)
    if isfield(Data.StatsInfo,'InputCsv')
        [Names,Values] = addTextMetric(Names,Values,'InputCsv',Data.StatsInfo.InputCsv);
    end
    if isfield(Data.StatsInfo,'MasterFolder')
        [Names,Values] = addTextMetric(Names,Values,'MasterFolder',Data.StatsInfo.MasterFolder);
    end
end

if isfield(Data,'Table_OxygenSinkEvents_OutCombo') && istable(Data.Table_OxygenSinkEvents_OutCombo)
    T = Data.Table_OxygenSinkEvents_OutCombo;
    if ismember('Mouse',T.Properties.VariableNames)
        [Names,Values] = addTextMetric(Names,Values,'Mice',strjoin(cellstr(unique(string(T.Mouse))),','));
    end
end

TextMetrics = table(Names,Values,'VariableNames',{'Metric','Value'});
TextMetrics = sortrows(TextMetrics,'Metric');

end

function [Names,Values] = addTextMetric(Names,Values,Name,Value)

Names(end+1,1) = string(Name);
Values(end+1,1) = string(Value);

end

function N = heightIfTable(T)

if istable(T)
    N = height(T);
else
    N = NaN;
end

end

function Value = tableColumnSum(T,ColumnName)

Values = tableColumnValues(T,ColumnName);
Value = sum(Values,'omitnan');

end

function Value = tableColumnMean(T,ColumnName)

Values = tableColumnValues(T,ColumnName);
Value = mean(Values,'omitnan');

end

function Count = tableLogicalCount(T,ColumnName,Target)

Count = NaN;
if ~istable(T) || ~ismember(ColumnName,T.Properties.VariableNames)
    return
end
Values = T.(ColumnName);
if iscell(Values)
    Values = cellfun(@logical,Values);
end
Count = sum(logical(Values)==Target);

end

function Values = tableColumnValues(T,ColumnName)

Values = NaN;
if ~istable(T) || ~ismember(ColumnName,T.Properties.VariableNames)
    return
end

Column = T.(ColumnName);
if isnumeric(Column) || islogical(Column)
    Values = double(Column(:));
elseif iscell(Column)
    Values = cellfun(@safeCellMean,Column(:));
else
    Values = str2double(string(Column(:)));
end

end

function Values = extractTraceValues(TraceCell)

Values = NaN;
if ~iscell(TraceCell) || isempty(TraceCell)
    return
end

Collected = cell(numel(TraceCell),1);
N = 0;
for i = 1:numel(TraceCell)
    ThisValue = TraceCell{i};
    if isnumeric(ThisValue) || islogical(ThisValue)
        N = N + 1;
        Collected{N} = double(ThisValue(:));
    end
end

if N==0
    Values = NaN;
else
    Values = vertcat(Collected{1:N});
end

end

function Value = maxOrNan(Values)

FiniteValues = Values(isfinite(Values));
if isempty(FiniteValues)
    Value = NaN;
else
    Value = max(FiniteValues);
end

end
