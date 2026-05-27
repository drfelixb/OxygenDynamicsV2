function Burden = createHypoxicBurdenMetrics(TableOxygenSinkEvents,EventSpecificMetrics)
%CREATEHYPOXICBURDENMETRICS Compute event and recording hypoxic burden.
%
% The primary metric is true event-level:
%   burden = positive drop amplitude (%) * event area (um^2) * duration (s)

if nargin<2
    EventSpecificMetrics = table();
end

Burden = struct();
Burden.EventTable = table();
Burden.RecordingTable = table();
Burden.MetricBasis = createHypoxicBurdenBasisTable();

if isempty(TableOxygenSinkEvents)
    return
end

if ~ismember('DurationSec',TableOxygenSinkEvents.Properties.VariableNames)
    warning('OxygenDynamics:HypoxicBurdenMissingColumns', ...
        'Hypoxic burden was skipped because event-level duration columns were missing.');
    return
end

[AmplitudePercent,AmplitudeSource,AmplitudeSignConvention] = ...
    getPositiveDropAmplitudePercent(TableOxygenSinkEvents);
if isempty(AmplitudePercent)
    warning('OxygenDynamics:HypoxicBurdenMissingAmplitude', ...
        'Hypoxic burden was skipped because no event-level amplitude column was found.');
    return
end

EventTable = TableOxygenSinkEvents;
EventTable.MetricBasis = repmat({'EventBased'},height(EventTable),1);
EventTable.BurdenAmplitudePercent = AmplitudePercent;
EventTable.BurdenAmplitudeSource = repmat({AmplitudeSource},height(EventTable),1);
EventTable.BurdenAmplitudeSignConvention = repmat({AmplitudeSignConvention},height(EventTable),1);
[BurdenArea,AreaSource,EventSpecificMatched] = getEventSpecificBurdenArea(EventTable,EventSpecificMetrics);
if isempty(BurdenArea)
    warning('OxygenDynamics:HypoxicBurdenMissingArea', ...
        'Hypoxic burden was skipped because no event-level area column was found.');
    return
end
EventTable.BurdenArea_um2 = BurdenArea;
EventTable.BurdenAreaSource = repmat({AreaSource},height(EventTable),1);
EventTable.BurdenAreaEventSpecificMatched = EventSpecificMatched;
EventTable.BurdenDuration_sec = tableColumnToDouble(EventTable.DurationSec);
EventTable.BurdenDurationSource = repmat({'OxySinkEvents.DurationSec'},height(EventTable),1);
EventTable.PerEventBurdenContribution = EventTable.BurdenAmplitudePercent .* ...
    EventTable.BurdenArea_um2 .* EventTable.BurdenDuration_sec;
EventTable.BurdenContributionFormula = repmat( ...
    {'BurdenAmplitudePercent * BurdenArea_um2 * BurdenDuration_sec'},height(EventTable),1);

Burden.EventTable = EventTable;
Burden.RecordingTable = createRecordingBurdenTable(EventTable);
Burden.GroupSummaryTable = createGroupedBurdenSummaryTable(EventTable,Burden.RecordingTable);

end

function [AmplitudePercent,AmplitudeSource,SignConvention] = getPositiveDropAmplitudePercent(EventTable)

AmplitudePercent = [];
AmplitudeSource = '';
SignConvention = '';

if ismember('NormOxySinkAmpPercent',EventTable.Properties.VariableNames)
    RawAmplitude = tableColumnToDouble(EventTable.NormOxySinkAmpPercent);
    AmplitudeSource = 'NormOxySinkAmpPercent';
elseif ismember('NormOxySinkAmp',EventTable.Properties.VariableNames)
    RawAmplitude = tableColumnToDouble(EventTable.NormOxySinkAmp) .* 100;
    AmplitudeSource = 'NormOxySinkAmp_x100';
else
    return
end

FiniteAmplitude = RawAmplitude(isfinite(RawAmplitude));
if isempty(FiniteAmplitude) || median(FiniteAmplitude,'omitnan')<0
    AmplitudePercent = -RawAmplitude;
    SignConvention = 'negative_drop_flipped_to_positive_percent';
else
    AmplitudePercent = RawAmplitude;
    SignConvention = 'positive_drop_percent';
end

end

function [BurdenArea,AreaSource,EventSpecificMatched] = getEventSpecificBurdenArea(EventTable,EventSpecificMetrics)

BurdenArea = [];
AreaSource = '';
EventSpecificMatched = false(height(EventTable),1);

if ~isempty(EventSpecificMetrics) && istable(EventSpecificMetrics) && ...
        all(ismember({'EventID','Area_um'},EventSpecificMetrics.Properties.VariableNames))
    [MatchedArea,EventSpecificMatched] = matchEventSpecificArea(EventTable,EventSpecificMetrics);
    if any(EventSpecificMatched)
        BurdenArea = MatchedArea;
        AreaSource = 'EventSpecificMetrics.Area_um';
        return
    end
end

if ismember('MeanOxySinkArea_um',EventTable.Properties.VariableNames)
    BurdenArea = tableColumnToDouble(EventTable.MeanOxySinkArea_um);
    AreaSource = 'Fallback_TableOxygenSinkEvents.MeanOxySinkArea_um_site_level';
    EventSpecificMatched = false(height(EventTable),1);
end

end

function [MatchedArea,Matched] = matchEventSpecificArea(EventTable,EventSpecificMetrics)

EventKeys = makeSinkEventKeys(EventTable);
SpecificKeys = makeEventSpecificKeys(EventSpecificMetrics);
SpecificArea = tableColumnToDouble(EventSpecificMetrics.Area_um);
MatchedArea = nan(height(EventTable),1);
Matched = false(height(EventTable),1);

for EventIdx = 1:numel(EventKeys)
    MatchIdx = find(SpecificKeys==EventKeys(EventIdx),1,'first');
    if ~isempty(MatchIdx)
        MatchedArea(EventIdx) = SpecificArea(MatchIdx);
        Matched(EventIdx) = true;
    end
end

end

function Keys = makeSinkEventKeys(EventTable)

NumRows = height(EventTable);
Keys = strings(NumRows,1);
if ~all(ismember({'Mouse','SinkID','EventID'},EventTable.Properties.VariableNames))
    return
end

Mouse = tableColumnToString(EventTable.Mouse);
SinkID = tableColumnToString(EventTable.SinkID);
EventID = tableColumnToString(EventTable.EventID);
Keys = Mouse + "_" + SinkID + "_" + EventID;

end

function Keys = makeEventSpecificKeys(EventSpecificMetrics)

Keys = tableColumnToString(EventSpecificMetrics.EventID);

end

function Text = tableColumnToString(Column)

if iscell(Column)
    Text = string(Column);
elseif isstring(Column)
    Text = Column;
elseif isnumeric(Column) || islogical(Column)
    Text = string(Column);
else
    Text = string(Column);
end
Text = strip(Text(:));

end

function RecordingTable = createRecordingBurdenTable(EventTable)

GroupColumns = {'Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'};
GroupColumns = GroupColumns(ismember(GroupColumns,EventTable.Properties.VariableNames));
if isempty(GroupColumns)
    GroupColumns = {'Mouse'};
    EventTable.Mouse = repmat({'All'},height(EventTable),1);
end

[GroupValues,~,GroupIdx] = unique(EventTable(:,GroupColumns),'rows','stable');
NumGroups = height(GroupValues);
HypoxicBurden = nan(NumGroups,1);
NumEvents = zeros(NumGroups,1);
NumSinkSites = zeros(NumGroups,1);
MeanEventBurdenContribution = nan(NumGroups,1);
MedianEventBurdenContribution = nan(NumGroups,1);
MeanBurdenAmplitudePercent = nan(NumGroups,1);
MeanBurdenArea_um2 = nan(NumGroups,1);
MeanBurdenDuration_sec = nan(NumGroups,1);
MetricBasis = repmat({'RecordingEventSum'},NumGroups,1);
HypoxicBurdenFormula = repmat({'sum(PerEventBurdenContribution)'},NumGroups,1);

for GroupI = 1:NumGroups
    Mask = GroupIdx==GroupI;
    Contributions = EventTable.PerEventBurdenContribution(Mask);
    HypoxicBurden(GroupI) = sum(Contributions,'omitnan');
    NumEvents(GroupI) = sum(isfinite(Contributions));
    NumSinkSites(GroupI) = countUniqueSinkSites(EventTable,Mask);
    MeanEventBurdenContribution(GroupI) = mean(Contributions,'omitnan');
    MedianEventBurdenContribution(GroupI) = median(Contributions,'omitnan');
    MeanBurdenAmplitudePercent(GroupI) = mean(EventTable.BurdenAmplitudePercent(Mask),'omitnan');
    MeanBurdenArea_um2(GroupI) = mean(EventTable.BurdenArea_um2(Mask),'omitnan');
    MeanBurdenDuration_sec(GroupI) = mean(EventTable.BurdenDuration_sec(Mask),'omitnan');
end

RecordingTable = [GroupValues,table(NumEvents,NumSinkSites,HypoxicBurden, ...
    MeanEventBurdenContribution,MedianEventBurdenContribution,MeanBurdenAmplitudePercent, ...
    MeanBurdenArea_um2,MeanBurdenDuration_sec,MetricBasis,HypoxicBurdenFormula)];

end

function GroupSummaryTable = createGroupedBurdenSummaryTable(EventTable,RecordingTable)

GroupSummaryTable = table();
GroupColumns = {'DrugID','Condition','PuffStim','Genotype','Promoter'};
GroupColumns = GroupColumns(ismember(GroupColumns,RecordingTable.Properties.VariableNames));
if isempty(GroupColumns) || isempty(RecordingTable)
    return
end

[GroupValues,~,RecordingGroupIdx] = unique(RecordingTable(:,GroupColumns),'rows','stable');
[~,~,EventGroupIdx] = unique(EventTable(:,GroupColumns),'rows','stable');
NumGroups = height(GroupValues);
NumRecordings = zeros(NumGroups,1);
NumEvents = zeros(NumGroups,1);
NumSinkSites = zeros(NumGroups,1);
HypoxicBurden_Mean = nan(NumGroups,1);
HypoxicBurden_SEM = nan(NumGroups,1);
HypoxicBurden_Median = nan(NumGroups,1);
HypoxicBurden_Sum = nan(NumGroups,1);
MeanEventBurdenContribution = nan(NumGroups,1);
MedianEventBurdenContribution = nan(NumGroups,1);
MeanBurdenAmplitudePercent = nan(NumGroups,1);
MeanBurdenArea_um2 = nan(NumGroups,1);
MeanBurdenDuration_sec = nan(NumGroups,1);
EventSpecificAreaMatchRate = nan(NumGroups,1);
MetricBasis = repmat({'GroupedRecordingSummary'},NumGroups,1);

for GroupIdx = 1:NumGroups
    RecordingMask = RecordingGroupIdx==GroupIdx;
    EventMask = EventGroupIdx==GroupIdx;
    BurdenValues = RecordingTable.HypoxicBurden(RecordingMask);
    Contributions = EventTable.PerEventBurdenContribution(EventMask);

    NumRecordings(GroupIdx) = sum(RecordingMask);
    NumEvents(GroupIdx) = sum(isfinite(Contributions));
    NumSinkSites(GroupIdx) = countUniqueSinkSites(EventTable,EventMask);
    HypoxicBurden_Mean(GroupIdx) = mean(BurdenValues,'omitnan');
    HypoxicBurden_SEM(GroupIdx) = std(BurdenValues,'omitnan') ./ sqrt(max(sum(isfinite(BurdenValues)),1));
    HypoxicBurden_Median(GroupIdx) = median(BurdenValues,'omitnan');
    HypoxicBurden_Sum(GroupIdx) = sum(BurdenValues,'omitnan');
    MeanEventBurdenContribution(GroupIdx) = mean(Contributions,'omitnan');
    MedianEventBurdenContribution(GroupIdx) = median(Contributions,'omitnan');
    MeanBurdenAmplitudePercent(GroupIdx) = mean(EventTable.BurdenAmplitudePercent(EventMask),'omitnan');
    MeanBurdenArea_um2(GroupIdx) = mean(EventTable.BurdenArea_um2(EventMask),'omitnan');
    MeanBurdenDuration_sec(GroupIdx) = mean(EventTable.BurdenDuration_sec(EventMask),'omitnan');
    EventSpecificAreaMatchRate(GroupIdx) = mean(double(EventTable.BurdenAreaEventSpecificMatched(EventMask)),'omitnan');
end

GroupSummaryTable = [GroupValues,table(NumRecordings,NumEvents,NumSinkSites, ...
    HypoxicBurden_Mean,HypoxicBurden_SEM,HypoxicBurden_Median,HypoxicBurden_Sum, ...
    MeanEventBurdenContribution,MedianEventBurdenContribution,MeanBurdenAmplitudePercent, ...
    MeanBurdenArea_um2,MeanBurdenDuration_sec,EventSpecificAreaMatchRate,MetricBasis)];

end

function Count = countUniqueSinkSites(EventTable,Mask)

if ismember('SinkID',EventTable.Properties.VariableNames)
    Count = numel(unique(string(EventTable.SinkID(Mask))));
else
    Count = NaN;
end

end

function Values = tableColumnToDouble(Column)

if isnumeric(Column) || islogical(Column)
    Values = double(Column);
elseif iscell(Column)
    Values = cellfun(@safeCellMean,Column);
else
    Values = str2double(string(Column));
end
Values = Values(:);

end

function BasisTable = createHypoxicBurdenBasisTable()

WorkbookItem = {'HypoxicBurden_EventBased'; 'HypoxicBurden_ByRecording'; ...
    'BurdenArea_um2'; 'PerEventBurdenContribution'; 'HypoxicBurden'};
MetricBasis = {'Event-based'; 'Recording-level sum of true event rows'; ...
    'True event-specific area from EventSpecificMetrics.Area_um when available'; ...
    'BurdenAmplitudePercent * BurdenArea_um2 * BurdenDuration_sec'; ...
    'Sum of PerEventBurdenContribution across events in each recording/FOV'};
Notes = {'One row per oxygen sink event from OxySinkEvents'; ...
    'Grouped by available recording metadata'; ...
    'Falls back to site-level MeanOxySinkArea_um only when event-specific Area_um cannot be matched'; ...
    'Amplitude is converted to positive drop percent from the event amplitude column'; ...
    'Units are percent * um^2 * seconds'};

BasisTable = table(WorkbookItem,MetricBasis,Notes);

end
