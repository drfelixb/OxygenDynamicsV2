function QcRows = buildOxygenStatsQcRows(StatsResult)
%BUILDOXYGENSTATSQCROWS Create compact QC rows from stats output.

Check = strings(0,1);
Status = strings(0,1);
Message = strings(0,1);
WhereToLook = strings(0,1);
RecommendedAction = strings(0,1);

Data = loadStatsPreviewData(StatsResult);
if (~isfield(StatsResult,'StatsInfo') || isempty(StatsResult.StatsInfo)) && ...
        isfield(Data,'StatsInfo')
    StatsResult.StatsInfo = Data.StatsInfo;
end
[Check,Status,Message,WhereToLook,RecommendedAction] = appendHypoxicBurdenQc( ...
    Check,Status,Message,WhereToLook,RecommendedAction,Data);
[Check,Status,Message,WhereToLook,RecommendedAction] = appendAreaNormalizationQc( ...
    Check,Status,Message,WhereToLook,RecommendedAction,Data);
[Check,Status,Message,WhereToLook,RecommendedAction] = appendStatsLoadQc( ...
    Check,Status,Message,WhereToLook,RecommendedAction,StatsResult);

QcRows = table(Check,Status,Message,WhereToLook,RecommendedAction);

end

function Data = loadStatsPreviewData(StatsResult)

Data = struct();
if isempty(StatsResult) || ~isstruct(StatsResult) || ...
        ~isfield(StatsResult,'DataOutputMat') || ~isfile(StatsResult.DataOutputMat)
    return
end
Data = load(StatsResult.DataOutputMat);

end

function [Check,Status,Message,WhereToLook,RecommendedAction] = appendHypoxicBurdenQc( ...
    Check,Status,Message,WhereToLook,RecommendedAction,Data)

if ~isfield(Data,'HypoxicBurden') || ~isstruct(Data.HypoxicBurden) || ...
        ~isfield(Data.HypoxicBurden,'EventTable') || ~istable(Data.HypoxicBurden.EventTable) || ...
        isempty(Data.HypoxicBurden.EventTable)
    [Check,Status,Message,WhereToLook,RecommendedAction] = appendQcRow(Check,Status,Message,WhereToLook,RecommendedAction, ...
        "Hypoxic burden events","INFO","No hypoxic burden event table found.", ...
        "FilteredData_<inputcsv>.xlsx: HypoxicBurden_EventBased", ...
        "Run stats with oxygen sink event outputs before using hypoxic burden.");
    return
end

EventTable = Data.HypoxicBurden.EventTable;
if ~ismember('BurdenAreaEventSpecificMatched',EventTable.Properties.VariableNames)
    [Check,Status,Message,WhereToLook,RecommendedAction] = appendQcRow(Check,Status,Message,WhereToLook,RecommendedAction, ...
        "Hypoxic burden area basis","REVIEW","Area match flag column is missing.", ...
        "FilteredData_<inputcsv>.xlsx: HypoxicBurden_EventBased", ...
        "Confirm whether the stats output was created with the current burden exporter.");
    return
end

Matched = logical(EventTable.BurdenAreaEventSpecificMatched);
NumMatched = sum(Matched);
NumEvents = height(EventTable);
if NumMatched==NumEvents
    [Check,Status,Message,WhereToLook,RecommendedAction] = appendQcRow(Check,Status,Message,WhereToLook,RecommendedAction, ...
        "Hypoxic burden area basis","PASS",sprintf('%d of %d events use event-specific area.',NumMatched,NumEvents), ...
        "FilteredData_<inputcsv>.xlsx: HypoxicBurden_EventBased", ...
        "No action needed.");
else
    [Check,Status,Message,WhereToLook,RecommendedAction] = appendQcRow(Check,Status,Message,WhereToLook,RecommendedAction, ...
        "Hypoxic burden area basis","REVIEW",sprintf('%d of %d events use event-specific area.',NumMatched,NumEvents), ...
        "FilteredData_<inputcsv>.xlsx: HypoxicBurden_EventBased", ...
        "Inspect HypoxicBurden_EventBased before using burden metrics.");
end

if ismember('PerEventBurdenContribution',EventTable.Properties.VariableNames)
    Contributions = tableColumnToDouble(EventTable.PerEventBurdenContribution);
    if all(isfinite(Contributions))
        [Check,Status,Message,WhereToLook,RecommendedAction] = appendQcRow(Check,Status,Message,WhereToLook,RecommendedAction, ...
            "Hypoxic burden contribution","PASS","All event burden contributions are finite.", ...
            "FilteredData_<inputcsv>.xlsx: HypoxicBurden_EventBased", ...
            "No action needed.");
    else
        [Check,Status,Message,WhereToLook,RecommendedAction] = appendQcRow(Check,Status,Message,WhereToLook,RecommendedAction, ...
            "Hypoxic burden contribution","REVIEW","Some event burden contributions are non-finite.", ...
            "FilteredData_<inputcsv>.xlsx: HypoxicBurden_EventBased", ...
            "Check event amplitude, area, and duration columns.");
    end
end

end

function [Check,Status,Message,WhereToLook,RecommendedAction] = appendAreaNormalizationQc( ...
    Check,Status,Message,WhereToLook,RecommendedAction,Data)

if ~isfield(Data,'SinkCountAreaNormalization') || ~istable(Data.SinkCountAreaNormalization) || ...
        isempty(Data.SinkCountAreaNormalization)
    [Check,Status,Message,WhereToLook,RecommendedAction] = appendQcRow(Check,Status,Message,WhereToLook,RecommendedAction, ...
        "Area normalization","INFO","No SinkCountAreaNormalization table found.", ...
        "FilteredData_<inputcsv>.xlsx: SinkCountNormFactors", ...
        "Run current stats export before comparing sink counts per 1 mm2.");
    return
end

NormTable = Data.SinkCountAreaNormalization;
RequiredColumns = {'FOVEdge_um','Kappa_1000umPerFOVEdge','AreaCorrectionFactor_1mm2'};
if ~all(ismember(RequiredColumns,NormTable.Properties.VariableNames))
    [Check,Status,Message,WhereToLook,RecommendedAction] = appendQcRow(Check,Status,Message,WhereToLook,RecommendedAction, ...
        "Area normalization","REVIEW","One or more normalization factor columns are missing.", ...
        "FilteredData_<inputcsv>.xlsx: SinkCountNormFactors", ...
        "Inspect SinkCountNormFactors before using OxySinksPer1mm2.");
    return
end

Values = [tableColumnToDouble(NormTable.FOVEdge_um), ...
    tableColumnToDouble(NormTable.Kappa_1000umPerFOVEdge), ...
    tableColumnToDouble(NormTable.AreaCorrectionFactor_1mm2)];
if all(isfinite(Values(:))) && all(Values(:)>0)
    [Check,Status,Message,WhereToLook,RecommendedAction] = appendQcRow(Check,Status,Message,WhereToLook,RecommendedAction, ...
        "Area normalization","PASS",sprintf('%d recording normalization rows are finite.',height(NormTable)), ...
        "FilteredData_<inputcsv>.xlsx: SinkCountNormFactors", ...
        "No action needed.");
else
    [Check,Status,Message,WhereToLook,RecommendedAction] = appendQcRow(Check,Status,Message,WhereToLook,RecommendedAction, ...
        "Area normalization","REVIEW","One or more normalization factors are missing or non-positive.", ...
        "FilteredData_<inputcsv>.xlsx: SinkCountNormFactors", ...
        "Check recording area and FOV edge values.");
end

end

function [Check,Status,Message,WhereToLook,RecommendedAction] = appendStatsLoadQc( ...
    Check,Status,Message,WhereToLook,RecommendedAction,StatsResult)

if isempty(StatsResult) || ~isstruct(StatsResult) || ~isfield(StatsResult,'StatsInfo') || ...
        ~isfield(StatsResult.StatsInfo,'LoadSummary')
    return
end

LoadSummary = StatsResult.StatsInfo.LoadSummary;
if isfield(LoadSummary,'NumWithConfiguredBehaviourInputs') && ...
        LoadSummary.NumWithConfiguredBehaviourInputs>0 && ...
        isfield(LoadSummary,'NumWithBehaviourTraces') && LoadSummary.NumWithBehaviourTraces==0
    [Check,Status,Message,WhereToLook,RecommendedAction] = appendQcRow(Check,Status,Message,WhereToLook,RecommendedAction, ...
        "Behaviour traces","REVIEW","Behaviour inputs were configured, but no behaviour traces loaded.", ...
        "FilteredData_<inputcsv>.xlsx: StatsLoadSummary and StatsLoadIssues", ...
        "Check Behaviour_Output folders and stats input CSV behaviour columns.");
end

end

function [Check,Status,Message,WhereToLook,RecommendedAction] = appendQcRow( ...
    Check,Status,Message,WhereToLook,RecommendedAction,ThisCheck,ThisStatus,ThisMessage,ThisWhereToLook,ThisAction)

Check(end+1,1) = string(ThisCheck);
Status(end+1,1) = string(ThisStatus);
Message(end+1,1) = string(ThisMessage);
WhereToLook(end+1,1) = string(ThisWhereToLook);
RecommendedAction(end+1,1) = string(ThisAction);

end

function Values = tableColumnToDouble(Column)

if isnumeric(Column) || islogical(Column)
    Values = double(Column);
elseif iscell(Column)
    Values = str2double(string(Column));
else
    Values = str2double(string(Column));
end
Values = Values(:);

end
