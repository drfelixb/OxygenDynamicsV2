function Burden = createHypoxicBurdenMetrics(TableOxygenSinkEvents,EventSpecificMetrics,TableOxygenSinks)
%CREATEHYPOXICBURDENMETRICS Compute event and recording hypoxic burden.
%
% The primary metric is true event-level:
%   burden = positive drop amplitude (%) * event area (um^2) * duration (s)

if nargin<2
    EventSpecificMetrics = table();
end
if nargin<3
    TableOxygenSinks = table();
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
[RecordingArea_um2,RecordingAreaSource] = getBurdenRecordingArea(EventTable,EventSpecificMetrics);
[RecordingDuration_sec,RecordingDurationSource] = getBurdenRecordingDuration(EventTable,TableOxygenSinks);
EventTable.BurdenArea_um2 = BurdenArea;
EventTable.BurdenAreaSource = repmat({AreaSource},height(EventTable),1);
EventTable.BurdenAreaEventSpecificMatched = EventSpecificMatched;
EventTable.BurdenRecordingArea_um2 = RecordingArea_um2;
EventTable.BurdenAreaNormalizationSource = repmat({RecordingAreaSource},height(EventTable),1);
EventTable.BurdenRecordingDuration_sec = RecordingDuration_sec;
EventTable.BurdenTimeNormalizationSource = repmat({RecordingDurationSource},height(EventTable),1);
EventTable.BurdenDuration_sec = tableColumnToDouble(EventTable.DurationSec);
EventTable.BurdenDurationSource = repmat({'OxySinkEvents.DurationSec'},height(EventTable),1);
EventTable.PerEventBurdenContribution = EventTable.BurdenAmplitudePercent .* ...
    EventTable.BurdenArea_um2 .* EventTable.BurdenDuration_sec;
EventTable.BurdenContributionFormula = repmat( ...
    {'BurdenAmplitudePercent * BurdenArea_um2 * BurdenDuration_sec'},height(EventTable),1);
EventTable.PerEventBurdenContribution_per_mm2 = EventTable.PerEventBurdenContribution .* ...
    (1e6 ./ EventTable.BurdenRecordingArea_um2);
EventTable.BurdenContributionPerMm2Formula = repmat( ...
    {'PerEventBurdenContribution * (1e6 / BurdenRecordingArea_um2)'},height(EventTable),1);
EventTable.PerEventBurdenContribution_per_sec = EventTable.PerEventBurdenContribution ./ ...
    EventTable.BurdenRecordingDuration_sec;
EventTable.PerEventBurdenContribution_per_min = EventTable.PerEventBurdenContribution .* ...
    (60 ./ EventTable.BurdenRecordingDuration_sec);
EventTable.PerEventBurdenContribution_per_mm2_per_sec = ...
    EventTable.PerEventBurdenContribution_per_mm2 ./ EventTable.BurdenRecordingDuration_sec;
EventTable.PerEventBurdenContribution_per_mm2_per_min = ...
    EventTable.PerEventBurdenContribution_per_mm2 .* (60 ./ EventTable.BurdenRecordingDuration_sec);
EventTable.BurdenContributionRateFormula = repmat( ...
    {'PerEventBurdenContribution divided by BurdenRecordingDuration_sec, optionally multiplied by 60 for per-minute rates'}, ...
    height(EventTable),1);
EventTable.BurdenRankAmplitudeQuantile = computeWithinRecordingAmplitudeQuantile(EventTable);
EventTable.PerEventBurdenOccupancy_per_mm2_per_min = EventTable.BurdenDuration_sec .* ...
    (1e6 ./ EventTable.BurdenRecordingArea_um2) .* (60 ./ EventTable.BurdenRecordingDuration_sec);
EventTable.PerEventBurdenRankAmplitude_per_mm2_per_min = ...
    EventTable.PerEventBurdenOccupancy_per_mm2_per_min .* EventTable.BurdenRankAmplitudeQuantile;
EventTable.PerEventBurdenAmplitudeComposite = EventTable.PerEventBurdenContribution;
EventTable.BurdenInterfaceFormula = repmat( ...
    {'Recording outputs: Burden_Occupancy=sum(duration)*1e6/area*60/recordingDuration; Burden_RankAmplitude=sum(duration*within-recording amplitude quantile)*1e6/area*60/recordingDuration; Burden_AmplitudeComposite=sum(amplitude*area*duration)'}, ...
    height(EventTable),1);

Burden.EventTable = EventTable;
Burden.RecordingTable = createRecordingBurdenTable(EventTable);
Burden.GroupSummaryTable = createGroupedBurdenSummaryTable(EventTable,Burden.RecordingTable);
[Burden.TimeSeriesTable,Burden.TimeSeriesBasis] = createBurdenTimeSeriesTable(EventTable);

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

function [RecordingArea_um2,RecordingAreaSource] = getBurdenRecordingArea(EventTable,EventSpecificMetrics)

RecordingArea_um2 = nan(height(EventTable),1);

if ~isempty(EventSpecificMetrics) && istable(EventSpecificMetrics) && ...
        all(ismember({'EventID','Area_um','Area_norm'},EventSpecificMetrics.Properties.VariableNames))
    SpecificArea = tableColumnToDouble(EventSpecificMetrics.Area_um);
    SpecificAreaNorm = tableColumnToDouble(EventSpecificMetrics.Area_norm);
    SpecificRecordingArea = nan(size(SpecificArea));
    Valid = isfinite(SpecificArea) & isfinite(SpecificAreaNorm) & SpecificAreaNorm>0;
    SpecificRecordingArea(Valid) = SpecificArea(Valid) ./ SpecificAreaNorm(Valid);
    [RecordingArea_um2,Matched] = matchEventSpecificNumericColumn(EventTable,EventSpecificMetrics,SpecificRecordingArea);
    if any(Matched)
        RecordingAreaSource = 'EventSpecificMetrics.Area_um / EventSpecificMetrics.Area_norm';
        return
    end
end

if ismember('RecAreaSize',EventTable.Properties.VariableNames)
    RecordingArea_um2 = tableColumnToDouble(EventTable.RecAreaSize);
    RecordingAreaSource = 'OxySinkEvents.RecAreaSize';
elseif ismember('RecordingArea_um2',EventTable.Properties.VariableNames)
    RecordingArea_um2 = tableColumnToDouble(EventTable.RecordingArea_um2);
    RecordingAreaSource = 'OxySinkEvents.RecordingArea_um2';
else
    RecordingAreaSource = 'Unavailable';
end

end

function [RecordingDuration_sec,RecordingDurationSource] = getBurdenRecordingDuration(EventTable,TableOxygenSinks)

RecordingDuration_sec = nan(height(EventTable),1);

if ~isempty(TableOxygenSinks) && istable(TableOxygenSinks) && ...
        ismember('RecDuration',TableOxygenSinks.Properties.VariableNames)
    [RecordingDuration_sec,Matched] = matchSinkRecordingNumericColumn(EventTable,TableOxygenSinks,'RecDuration');
    if any(Matched)
        RecordingDurationSource = 'TableOxygenSinks.RecDuration';
        return
    end
end

if ismember('RecDuration',EventTable.Properties.VariableNames)
    RecordingDuration_sec = tableColumnToDouble(EventTable.RecDuration);
    RecordingDurationSource = 'OxySinkEvents.RecDuration';
elseif ismember('EndSec',EventTable.Properties.VariableNames)
    RecordingDuration_sec(:) = max(tableColumnToDouble(EventTable.EndSec),[],'omitnan');
    RecordingDurationSource = 'Fallback_max(OxySinkEvents.EndSec)';
else
    RecordingDurationSource = 'Unavailable';
end

end

function [MatchedValues,Matched] = matchSinkRecordingNumericColumn(EventTable,SinkTable,columnName)

MatchedValues = nan(height(EventTable),1);
Matched = false(height(EventTable),1);
GroupColumns = {'Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'};
GroupColumns = GroupColumns(ismember(GroupColumns,EventTable.Properties.VariableNames) & ...
    ismember(GroupColumns,SinkTable.Properties.VariableNames));
if isempty(GroupColumns)
    return
end

EventKeys = makeTableGroupKeys(EventTable,GroupColumns);
SinkKeys = makeTableGroupKeys(SinkTable,GroupColumns);
SinkValues = tableColumnToDouble(SinkTable.(columnName));
UniqueEventKeys = unique(EventKeys,'stable');
for KeyIdx = 1:numel(UniqueEventKeys)
    CurrentKey = UniqueEventKeys(KeyIdx);
    EventMask = EventKeys==CurrentKey;
    SinkMask = SinkKeys==CurrentKey;
    if any(SinkMask)
        MatchedValues(EventMask) = median(SinkValues(SinkMask),'omitnan');
        Matched(EventMask) = true;
    end
end

end

function Keys = makeTableGroupKeys(DataTable,GroupColumns)

Keys = strings(height(DataTable),1);
for ColumnIdx = 1:numel(GroupColumns)
    Keys = Keys + "|" + tableColumnToString(DataTable.(GroupColumns{ColumnIdx}));
end

end

function [MatchedArea,Matched] = matchEventSpecificArea(EventTable,EventSpecificMetrics)

SpecificArea = tableColumnToDouble(EventSpecificMetrics.Area_um);
[MatchedArea,Matched] = matchEventSpecificNumericColumn(EventTable,EventSpecificMetrics,SpecificArea);

end

function [MatchedValues,Matched] = matchEventSpecificNumericColumn(EventTable,EventSpecificMetrics,SpecificValues)

EventKeys = makeSinkEventKeys(EventTable);
SpecificKeys = makeEventSpecificKeys(EventSpecificMetrics);
MatchedValues = nan(height(EventTable),1);
Matched = false(height(EventTable),1);

for EventIdx = 1:numel(EventKeys)
    MatchIdx = find(SpecificKeys==EventKeys(EventIdx),1,'first');
    if ~isempty(MatchIdx)
        MatchedValues(EventIdx) = SpecificValues(MatchIdx);
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
HypoxicBurden_per_mm2 = nan(NumGroups,1);
HypoxicBurden_per_sec = nan(NumGroups,1);
HypoxicBurden_per_min = nan(NumGroups,1);
HypoxicBurden_per_mm2_per_sec = nan(NumGroups,1);
HypoxicBurden_per_mm2_per_min = nan(NumGroups,1);
RecordingArea_um2 = nan(NumGroups,1);
RecordingDuration_sec = nan(NumGroups,1);
NumEvents = zeros(NumGroups,1);
NumSinkSites = zeros(NumGroups,1);
MeanEventBurdenContribution = nan(NumGroups,1);
MedianEventBurdenContribution = nan(NumGroups,1);
MeanEventBurdenContribution_per_mm2 = nan(NumGroups,1);
MedianEventBurdenContribution_per_mm2 = nan(NumGroups,1);
MeanBurdenAmplitudePercent = nan(NumGroups,1);
MeanBurdenArea_um2 = nan(NumGroups,1);
MeanBurdenDuration_sec = nan(NumGroups,1);
Burden_Occupancy = nan(NumGroups,1);
Burden_RankAmplitude = nan(NumGroups,1);
Burden_AmplitudeComposite = nan(NumGroups,1);
MetricBasis = repmat({'RecordingEventSum'},NumGroups,1);
Burden_Occupancy_Units = repmat({'event-seconds per 1 mm^2 per minute'},NumGroups,1);
Burden_RankAmplitude_Units = repmat({'rank-weighted event-seconds per 1 mm^2 per minute'},NumGroups,1);
Burden_AmplitudeComposite_Units = repmat({'percent * um^2 * seconds'},NumGroups,1);
HypoxicBurdenFormula = repmat({'sum(PerEventBurdenContribution)'},NumGroups,1);
HypoxicBurdenPerMm2Formula = repmat({'sum(PerEventBurdenContribution_per_mm2)'},NumGroups,1);
HypoxicBurdenRateFormula = repmat({'HypoxicBurden divided by RecordingDuration_sec'},NumGroups,1);
HypoxicBurdenPerMm2RateFormula = repmat({'HypoxicBurden_per_mm2 divided by RecordingDuration_sec'},NumGroups,1);
Burden_Occupancy_Formula = repmat({'sum(BurdenDuration_sec) * (1e6 / RecordingArea_um2) * (60 / RecordingDuration_sec)'},NumGroups,1);
Burden_RankAmplitude_Formula = repmat({'sum(BurdenDuration_sec * within-recording amplitude quantile) * (1e6 / RecordingArea_um2) * (60 / RecordingDuration_sec)'},NumGroups,1);
Burden_AmplitudeComposite_Formula = repmat({'sum(BurdenAmplitudePercent * BurdenArea_um2 * BurdenDuration_sec)'},NumGroups,1);

for GroupI = 1:NumGroups
    Mask = GroupIdx==GroupI;
    Contributions = EventTable.PerEventBurdenContribution(Mask);
    ContributionsPerMm2 = EventTable.PerEventBurdenContribution_per_mm2(Mask);
    HypoxicBurden(GroupI) = sum(Contributions,'omitnan');
    HypoxicBurden_per_mm2(GroupI) = sum(ContributionsPerMm2,'omitnan');
    RecordingArea_um2(GroupI) = median(EventTable.BurdenRecordingArea_um2(Mask),'omitnan');
    RecordingDuration_sec(GroupI) = median(EventTable.BurdenRecordingDuration_sec(Mask),'omitnan');
    HypoxicBurden_per_sec(GroupI) = HypoxicBurden(GroupI) ./ RecordingDuration_sec(GroupI);
    HypoxicBurden_per_min(GroupI) = HypoxicBurden(GroupI) .* 60 ./ RecordingDuration_sec(GroupI);
    HypoxicBurden_per_mm2_per_sec(GroupI) = HypoxicBurden_per_mm2(GroupI) ./ RecordingDuration_sec(GroupI);
    HypoxicBurden_per_mm2_per_min(GroupI) = HypoxicBurden_per_mm2(GroupI) .* 60 ./ RecordingDuration_sec(GroupI);
    NumEvents(GroupI) = sum(isfinite(Contributions));
    NumSinkSites(GroupI) = countUniqueSinkSites(EventTable,Mask);
    MeanEventBurdenContribution(GroupI) = mean(Contributions,'omitnan');
    MedianEventBurdenContribution(GroupI) = median(Contributions,'omitnan');
    MeanEventBurdenContribution_per_mm2(GroupI) = mean(ContributionsPerMm2,'omitnan');
    MedianEventBurdenContribution_per_mm2(GroupI) = median(ContributionsPerMm2,'omitnan');
    MeanBurdenAmplitudePercent(GroupI) = mean(EventTable.BurdenAmplitudePercent(Mask),'omitnan');
    MeanBurdenArea_um2(GroupI) = mean(EventTable.BurdenArea_um2(Mask),'omitnan');
    MeanBurdenDuration_sec(GroupI) = mean(EventTable.BurdenDuration_sec(Mask),'omitnan');
    Burden_Occupancy(GroupI) = sum(EventTable.PerEventBurdenOccupancy_per_mm2_per_min(Mask),'omitnan');
    Burden_RankAmplitude(GroupI) = sum(EventTable.PerEventBurdenRankAmplitude_per_mm2_per_min(Mask),'omitnan');
    Burden_AmplitudeComposite(GroupI) = HypoxicBurden(GroupI);
end

RecordingTable = [GroupValues,table(NumEvents,NumSinkSites,RecordingArea_um2,RecordingDuration_sec, ...
    HypoxicBurden,HypoxicBurden_per_mm2,HypoxicBurden_per_sec,HypoxicBurden_per_min, ...
    HypoxicBurden_per_mm2_per_sec,HypoxicBurden_per_mm2_per_min, ...
    Burden_Occupancy,Burden_RankAmplitude,Burden_AmplitudeComposite, ...
    Burden_Occupancy_Units,Burden_RankAmplitude_Units,Burden_AmplitudeComposite_Units, ...
    MeanEventBurdenContribution,MedianEventBurdenContribution, ...
    MeanEventBurdenContribution_per_mm2,MedianEventBurdenContribution_per_mm2, ...
    MeanBurdenAmplitudePercent,MeanBurdenArea_um2,MeanBurdenDuration_sec,MetricBasis, ...
    HypoxicBurdenFormula,HypoxicBurdenPerMm2Formula,HypoxicBurdenRateFormula, ...
    HypoxicBurdenPerMm2RateFormula,Burden_Occupancy_Formula, ...
    Burden_RankAmplitude_Formula,Burden_AmplitudeComposite_Formula)];

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
HypoxicBurden_per_mm2_Mean = nan(NumGroups,1);
HypoxicBurden_per_mm2_SEM = nan(NumGroups,1);
HypoxicBurden_per_mm2_Median = nan(NumGroups,1);
HypoxicBurden_per_mm2_Sum = nan(NumGroups,1);
HypoxicBurden_per_sec_Mean = nan(NumGroups,1);
HypoxicBurden_per_sec_SEM = nan(NumGroups,1);
HypoxicBurden_per_min_Mean = nan(NumGroups,1);
HypoxicBurden_per_min_SEM = nan(NumGroups,1);
HypoxicBurden_per_mm2_per_sec_Mean = nan(NumGroups,1);
HypoxicBurden_per_mm2_per_sec_SEM = nan(NumGroups,1);
HypoxicBurden_per_mm2_per_min_Mean = nan(NumGroups,1);
HypoxicBurden_per_mm2_per_min_SEM = nan(NumGroups,1);
Burden_Occupancy_Mean = nan(NumGroups,1);
Burden_Occupancy_SEM = nan(NumGroups,1);
Burden_RankAmplitude_Mean = nan(NumGroups,1);
Burden_RankAmplitude_SEM = nan(NumGroups,1);
Burden_AmplitudeComposite_Mean = nan(NumGroups,1);
Burden_AmplitudeComposite_SEM = nan(NumGroups,1);
MeanEventBurdenContribution = nan(NumGroups,1);
MedianEventBurdenContribution = nan(NumGroups,1);
MeanEventBurdenContribution_per_mm2 = nan(NumGroups,1);
MedianEventBurdenContribution_per_mm2 = nan(NumGroups,1);
MeanBurdenAmplitudePercent = nan(NumGroups,1);
MeanBurdenArea_um2 = nan(NumGroups,1);
MeanBurdenDuration_sec = nan(NumGroups,1);
EventSpecificAreaMatchRate = nan(NumGroups,1);
MetricBasis = repmat({'GroupedRecordingSummary'},NumGroups,1);

for GroupIdx = 1:NumGroups
    RecordingMask = RecordingGroupIdx==GroupIdx;
    EventMask = EventGroupIdx==GroupIdx;
    BurdenValues = RecordingTable.HypoxicBurden(RecordingMask);
    BurdenPerMm2Values = RecordingTable.HypoxicBurden_per_mm2(RecordingMask);
    BurdenPerSecValues = RecordingTable.HypoxicBurden_per_sec(RecordingMask);
    BurdenPerMinValues = RecordingTable.HypoxicBurden_per_min(RecordingMask);
    BurdenPerMm2PerSecValues = RecordingTable.HypoxicBurden_per_mm2_per_sec(RecordingMask);
    BurdenPerMm2PerMinValues = RecordingTable.HypoxicBurden_per_mm2_per_min(RecordingMask);
    OccupancyValues = RecordingTable.Burden_Occupancy(RecordingMask);
    RankAmplitudeValues = RecordingTable.Burden_RankAmplitude(RecordingMask);
    AmplitudeCompositeValues = RecordingTable.Burden_AmplitudeComposite(RecordingMask);
    Contributions = EventTable.PerEventBurdenContribution(EventMask);
    ContributionsPerMm2 = EventTable.PerEventBurdenContribution_per_mm2(EventMask);

    NumRecordings(GroupIdx) = sum(RecordingMask);
    NumEvents(GroupIdx) = sum(isfinite(Contributions));
    NumSinkSites(GroupIdx) = countUniqueSinkSites(EventTable,EventMask);
    HypoxicBurden_Mean(GroupIdx) = mean(BurdenValues,'omitnan');
    HypoxicBurden_SEM(GroupIdx) = std(BurdenValues,'omitnan') ./ sqrt(max(sum(isfinite(BurdenValues)),1));
    HypoxicBurden_Median(GroupIdx) = median(BurdenValues,'omitnan');
    HypoxicBurden_Sum(GroupIdx) = sum(BurdenValues,'omitnan');
    HypoxicBurden_per_mm2_Mean(GroupIdx) = mean(BurdenPerMm2Values,'omitnan');
    HypoxicBurden_per_mm2_SEM(GroupIdx) = std(BurdenPerMm2Values,'omitnan') ./ ...
        sqrt(max(sum(isfinite(BurdenPerMm2Values)),1));
    HypoxicBurden_per_mm2_Median(GroupIdx) = median(BurdenPerMm2Values,'omitnan');
    HypoxicBurden_per_mm2_Sum(GroupIdx) = sum(BurdenPerMm2Values,'omitnan');
    HypoxicBurden_per_sec_Mean(GroupIdx) = mean(BurdenPerSecValues,'omitnan');
    HypoxicBurden_per_sec_SEM(GroupIdx) = std(BurdenPerSecValues,'omitnan') ./ ...
        sqrt(max(sum(isfinite(BurdenPerSecValues)),1));
    HypoxicBurden_per_min_Mean(GroupIdx) = mean(BurdenPerMinValues,'omitnan');
    HypoxicBurden_per_min_SEM(GroupIdx) = std(BurdenPerMinValues,'omitnan') ./ ...
        sqrt(max(sum(isfinite(BurdenPerMinValues)),1));
    HypoxicBurden_per_mm2_per_sec_Mean(GroupIdx) = mean(BurdenPerMm2PerSecValues,'omitnan');
    HypoxicBurden_per_mm2_per_sec_SEM(GroupIdx) = std(BurdenPerMm2PerSecValues,'omitnan') ./ ...
        sqrt(max(sum(isfinite(BurdenPerMm2PerSecValues)),1));
    HypoxicBurden_per_mm2_per_min_Mean(GroupIdx) = mean(BurdenPerMm2PerMinValues,'omitnan');
    HypoxicBurden_per_mm2_per_min_SEM(GroupIdx) = std(BurdenPerMm2PerMinValues,'omitnan') ./ ...
        sqrt(max(sum(isfinite(BurdenPerMm2PerMinValues)),1));
    Burden_Occupancy_Mean(GroupIdx) = mean(OccupancyValues,'omitnan');
    Burden_Occupancy_SEM(GroupIdx) = std(OccupancyValues,'omitnan') ./ ...
        sqrt(max(sum(isfinite(OccupancyValues)),1));
    Burden_RankAmplitude_Mean(GroupIdx) = mean(RankAmplitudeValues,'omitnan');
    Burden_RankAmplitude_SEM(GroupIdx) = std(RankAmplitudeValues,'omitnan') ./ ...
        sqrt(max(sum(isfinite(RankAmplitudeValues)),1));
    Burden_AmplitudeComposite_Mean(GroupIdx) = mean(AmplitudeCompositeValues,'omitnan');
    Burden_AmplitudeComposite_SEM(GroupIdx) = std(AmplitudeCompositeValues,'omitnan') ./ ...
        sqrt(max(sum(isfinite(AmplitudeCompositeValues)),1));
    MeanEventBurdenContribution(GroupIdx) = mean(Contributions,'omitnan');
    MedianEventBurdenContribution(GroupIdx) = median(Contributions,'omitnan');
    MeanEventBurdenContribution_per_mm2(GroupIdx) = mean(ContributionsPerMm2,'omitnan');
    MedianEventBurdenContribution_per_mm2(GroupIdx) = median(ContributionsPerMm2,'omitnan');
    MeanBurdenAmplitudePercent(GroupIdx) = mean(EventTable.BurdenAmplitudePercent(EventMask),'omitnan');
    MeanBurdenArea_um2(GroupIdx) = mean(EventTable.BurdenArea_um2(EventMask),'omitnan');
    MeanBurdenDuration_sec(GroupIdx) = mean(EventTable.BurdenDuration_sec(EventMask),'omitnan');
    EventSpecificAreaMatchRate(GroupIdx) = mean(double(EventTable.BurdenAreaEventSpecificMatched(EventMask)),'omitnan');
end

GroupSummaryTable = [GroupValues,table(NumRecordings,NumEvents,NumSinkSites, ...
    HypoxicBurden_Mean,HypoxicBurden_SEM,HypoxicBurden_Median,HypoxicBurden_Sum, ...
    HypoxicBurden_per_mm2_Mean,HypoxicBurden_per_mm2_SEM,HypoxicBurden_per_mm2_Median, ...
    HypoxicBurden_per_mm2_Sum,HypoxicBurden_per_sec_Mean,HypoxicBurden_per_sec_SEM, ...
    HypoxicBurden_per_min_Mean,HypoxicBurden_per_min_SEM, ...
    HypoxicBurden_per_mm2_per_sec_Mean,HypoxicBurden_per_mm2_per_sec_SEM, ...
    HypoxicBurden_per_mm2_per_min_Mean,HypoxicBurden_per_mm2_per_min_SEM, ...
    Burden_Occupancy_Mean,Burden_Occupancy_SEM, ...
    Burden_RankAmplitude_Mean,Burden_RankAmplitude_SEM, ...
    Burden_AmplitudeComposite_Mean,Burden_AmplitudeComposite_SEM, ...
    MeanEventBurdenContribution,MedianEventBurdenContribution, ...
    MeanEventBurdenContribution_per_mm2,MedianEventBurdenContribution_per_mm2, ...
    MeanBurdenAmplitudePercent,MeanBurdenArea_um2,MeanBurdenDuration_sec, ...
    EventSpecificAreaMatchRate,MetricBasis)];

end

function [TimeSeriesTable,BasisTable] = createBurdenTimeSeriesTable(EventTable)

TimeSeriesTable = table();
BasisTable = createBurdenTimeSeriesBasisTable();
RequiredColumns = {'StartFrame','EndFrame','PerEventBurdenContribution', ...
    'PerEventBurdenContribution_per_mm2'};
if isempty(EventTable) || ~all(ismember(RequiredColumns,EventTable.Properties.VariableNames))
    return
end

GroupColumns = {'Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'};
GroupColumns = GroupColumns(ismember(GroupColumns,EventTable.Properties.VariableNames));
if isempty(GroupColumns)
    GroupColumns = {'Mouse'};
    EventTable.Mouse = repmat({'All'},height(EventTable),1);
end

[GroupValues,~,GroupIdx] = unique(EventTable(:,GroupColumns),'rows','stable');
NumGroups = height(GroupValues);
RecordingIndex = [];
Frame = [];
TimeSec = [];
ActiveHypoxicEvents = [];
HypoxicBurdenOverTime = [];
HypoxicBurdenPerMm2OverTime = [];
SampleFs = [];
RecordingDuration_sec = [];
Formula = {};
Units = {};
UnitsPerMm2 = {};
AllMetaColumns = {'Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'};
Meta = struct();
for MetaIdx = 1:numel(AllMetaColumns)
    Meta.(AllMetaColumns{MetaIdx}) = strings(0,1);
end

for GroupI = 1:NumGroups
    Mask = GroupIdx==GroupI;
    EventRows = EventTable(Mask,:);
    Fs = inferBurdenSampleFrequency(EventRows);
    RecordingDuration = inferBurdenRecordingDuration(EventRows,Fs);
    NumFrames = inferBurdenNumFrames(EventRows,Fs,RecordingDuration);
    if NumFrames<1 || ~isfinite(NumFrames)
        continue
    end

    Trace = zeros(NumFrames,1);
    TracePerMm2 = zeros(NumFrames,1);
    ActiveEvents = zeros(NumFrames,1);
    StartFrame = round(tableColumnToDouble(EventRows.StartFrame));
    EndFrame = round(tableColumnToDouble(EventRows.EndFrame));
    EventContribution = tableColumnToDouble(EventRows.PerEventBurdenContribution);
    EventContributionPerMm2 = tableColumnToDouble(EventRows.PerEventBurdenContribution_per_mm2);
    EventDuration = getBurdenEventDurationForTrace(EventRows,Fs,StartFrame,EndFrame);

    for EventIdx = 1:height(EventRows)
        FirstFrame = max(1,StartFrame(EventIdx));
        LastFrame = min(NumFrames,EndFrame(EventIdx));
        if ~isfinite(FirstFrame) || ~isfinite(LastFrame) || LastFrame<FirstFrame
            continue
        end
        FrameIdx = FirstFrame:LastFrame;
        DurationSec = EventDuration(EventIdx);
        if ~isfinite(DurationSec) || DurationSec<=0
            DurationSec = numel(FrameIdx) ./ Fs;
        end
        Trace(FrameIdx) = Trace(FrameIdx) + EventContribution(EventIdx) ./ DurationSec;
        TracePerMm2(FrameIdx) = TracePerMm2(FrameIdx) + EventContributionPerMm2(EventIdx) ./ DurationSec;
        ActiveEvents(FrameIdx) = ActiveEvents(FrameIdx) + 1;
    end

    NewRows = NumFrames;
    RecordingIndex = [RecordingIndex; repmat(GroupI,NewRows,1)]; %#ok<AGROW>
    Frame = [Frame; (1:NewRows)']; %#ok<AGROW>
    TimeSec = [TimeSec; ((0:NewRows-1)' ./ Fs)]; %#ok<AGROW>
    ActiveHypoxicEvents = [ActiveHypoxicEvents; ActiveEvents]; %#ok<AGROW>
    HypoxicBurdenOverTime = [HypoxicBurdenOverTime; Trace]; %#ok<AGROW>
    HypoxicBurdenPerMm2OverTime = [HypoxicBurdenPerMm2OverTime; TracePerMm2]; %#ok<AGROW>
    SampleFs = [SampleFs; repmat(Fs,NewRows,1)]; %#ok<AGROW>
    RecordingDuration_sec = [RecordingDuration_sec; repmat(RecordingDuration,NewRows,1)]; %#ok<AGROW>
    Formula = [Formula; repmat({'sum(active PerEventBurdenContribution / event duration)'},NewRows,1)]; %#ok<AGROW>
    Units = [Units; repmat({'percent * um^2'},NewRows,1)]; %#ok<AGROW>
    UnitsPerMm2 = [UnitsPerMm2; repmat({'percent * um^2 per 1 mm^2 FOV'},NewRows,1)]; %#ok<AGROW>
    for MetaIdx = 1:numel(AllMetaColumns)
        ColumnName = AllMetaColumns{MetaIdx};
        if ismember(ColumnName,GroupColumns)
            MetaValue = tableColumnToString(GroupValues.(ColumnName));
            MetaValue = MetaValue(GroupI);
        else
            MetaValue = "";
        end
        Meta.(ColumnName) = [Meta.(ColumnName); repmat(MetaValue,NewRows,1)];
    end
end

if isempty(RecordingIndex)
    return
end

TimeSeriesTable = table(RecordingIndex,Meta.Experiment,Meta.Mouse,Meta.Condition, ...
    Meta.DrugID,Meta.Genotype,Meta.Promoter,Meta.PuffStim,Frame,TimeSec,SampleFs, ...
    RecordingDuration_sec,ActiveHypoxicEvents,HypoxicBurdenOverTime, ...
    HypoxicBurdenPerMm2OverTime,Formula,Units,UnitsPerMm2, ...
    'VariableNames',{'RecordingIndex','Experiment','Mouse','Condition','DrugID', ...
    'Genotype','Promoter','PuffStim','Frame','TimeSec','SampleFs', ...
    'RecordingDuration_sec','ActiveHypoxicEvents','HypoxicBurdenOverTime', ...
    'HypoxicBurdenPerMm2OverTime','Formula','Units','UnitsPerMm2'});

end

function BasisTable = createBurdenTimeSeriesBasisTable()

Metric = {'HypoxicBurdenOverTime'; 'HypoxicBurdenPerMm2OverTime'; ...
    'ActiveHypoxicEvents'; 'TimeSec'};
OutputSheet = {'HypoxicBurden_TimeSeries'; 'HypoxicBurden_TimeSeries'; ...
    'HypoxicBurden_TimeSeries'; 'HypoxicBurden_TimeSeries'};
AnalysisUnit = {'Frame/time point'; 'Frame/time point'; ...
    'Frame/time point'; 'Frame/time point'};
Formula = {'sum(active PerEventBurdenContribution / event duration)'; ...
    'sum(active PerEventBurdenContribution_per_mm2 / event duration)'; ...
    'count of individual hypoxic events active at this frame'; ...
    '(Frame - 1) / SampleFs'};
Normalization = {'Not FOV-normalized and not per-minute normalized'; ...
    'FOV-normalized to 1 mm2; not per-minute normalized'; ...
    'Not FOV-normalized; use OxySinksPer1mm2 for normalized counts'; ...
    'Recording time axis in seconds'};
RecommendedUse = {'Frame-aligned burden signal inside the recorded FOV'; ...
    'Recommended burden-over-time signal for different FOV sizes and sleep-state alignment'; ...
    'Companion count trace for interpretation'; ...
    'Align this axis to EEG/ECG/sleep-state annotations'};

BasisTable = table(Metric,OutputSheet,AnalysisUnit,Formula,Normalization,RecommendedUse);

end

function Fs = inferBurdenSampleFrequency(EventRows)

Fs = NaN;
if all(ismember({'StartFrame','EndFrame','DurationSec'},EventRows.Properties.VariableNames))
    StartFrame = tableColumnToDouble(EventRows.StartFrame);
    EndFrame = tableColumnToDouble(EventRows.EndFrame);
    DurationSec = tableColumnToDouble(EventRows.DurationSec);
    FrameSpan = abs(EndFrame-StartFrame);
    if ismember('DurationFrames',EventRows.Properties.VariableNames)
        FrameSpan = tableColumnToDouble(EventRows.DurationFrames);
    end
    Rate = FrameSpan ./ DurationSec;
    Rate = Rate(isfinite(Rate) & Rate>0);
    if ~isempty(Rate)
        Fs = median(Rate,'omitnan');
    end
end
if ~isfinite(Fs) || Fs<=0
    Fs = 1;
end

end

function RecordingDuration = inferBurdenRecordingDuration(EventRows,Fs)

RecordingDuration = NaN;
if ismember('BurdenRecordingDuration_sec',EventRows.Properties.VariableNames)
    Durations = tableColumnToDouble(EventRows.BurdenRecordingDuration_sec);
    Durations = Durations(isfinite(Durations) & Durations>0);
    if ~isempty(Durations)
        RecordingDuration = median(Durations,'omitnan');
    end
end
if (~isfinite(RecordingDuration) || RecordingDuration<=0) && ismember('EndSec',EventRows.Properties.VariableNames)
    EndSec = tableColumnToDouble(EventRows.EndSec);
    EndSec = EndSec(isfinite(EndSec) & EndSec>0);
    if ~isempty(EndSec)
        RecordingDuration = max(EndSec);
    end
end
if ~isfinite(RecordingDuration) || RecordingDuration<=0
    EndFrame = tableColumnToDouble(EventRows.EndFrame);
    EndFrame = EndFrame(isfinite(EndFrame) & EndFrame>0);
    if ~isempty(EndFrame)
        RecordingDuration = max(EndFrame) ./ Fs;
    end
end

end

function NumFrames = inferBurdenNumFrames(EventRows,Fs,RecordingDuration)

EndFrame = tableColumnToDouble(EventRows.EndFrame);
EndFrame = EndFrame(isfinite(EndFrame) & EndFrame>0);
MaxEndFrame = 0;
if ~isempty(EndFrame)
    MaxEndFrame = max(EndFrame);
end
NumFrames = max(MaxEndFrame,ceil(RecordingDuration .* Fs));
NumFrames = round(NumFrames);

end

function EventDuration = getBurdenEventDurationForTrace(EventRows,Fs,StartFrame,EndFrame)

if ismember('DurationSec',EventRows.Properties.VariableNames)
    EventDuration = tableColumnToDouble(EventRows.DurationSec);
else
    EventDuration = nan(height(EventRows),1);
end
Invalid = ~isfinite(EventDuration) | EventDuration<=0;
EventDuration(Invalid) = max(1,EndFrame(Invalid)-StartFrame(Invalid)+1) ./ Fs;

end

function Count = countUniqueSinkSites(EventTable,Mask)

if ismember('SinkID',EventTable.Properties.VariableNames)
    Count = numel(unique(string(EventTable.SinkID(Mask))));
else
    Count = NaN;
end

end

function Quantile = computeWithinRecordingAmplitudeQuantile(EventTable)

Quantile = nan(height(EventTable),1);
GroupColumns = {'Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'};
GroupColumns = GroupColumns(ismember(GroupColumns,EventTable.Properties.VariableNames));
if isempty(GroupColumns)
    Quantile = tiedQuantile(EventTable.BurdenAmplitudePercent);
    return
end

Keys = makeTableGroupKeys(EventTable,GroupColumns);
UniqueKeys = unique(Keys,'stable');
for KeyIdx = 1:numel(UniqueKeys)
    Mask = Keys==UniqueKeys(KeyIdx);
    Quantile(Mask) = tiedQuantile(EventTable.BurdenAmplitudePercent(Mask));
end

end

function Quantile = tiedQuantile(Values)

Values = double(Values(:));
Quantile = nan(size(Values));
FiniteMask = isfinite(Values);
FiniteValues = Values(FiniteMask);
NumValues = numel(FiniteValues);
if NumValues==0
    return
end

[SortedValues,SortIdx] = sort(FiniteValues);
AverageRanks = nan(NumValues,1);
StartIdx = 1;
while StartIdx<=NumValues
    EndIdx = StartIdx;
    while EndIdx<NumValues && SortedValues(EndIdx+1)==SortedValues(StartIdx)
        EndIdx = EndIdx + 1;
    end
    AverageRanks(StartIdx:EndIdx) = mean(StartIdx:EndIdx);
    StartIdx = EndIdx + 1;
end

RankValues = nan(NumValues,1);
RankValues(SortIdx) = AverageRanks;
FiniteQuantile = (RankValues - 0.5) ./ NumValues;
Quantile(FiniteMask) = FiniteQuantile;

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
    'BurdenArea_um2'; 'BurdenRecordingArea_um2'; 'PerEventBurdenContribution'; ...
    'PerEventBurdenContribution_per_mm2'; 'BurdenRecordingDuration_sec'; ...
    'HypoxicBurden'; 'HypoxicBurden_per_mm2'; 'HypoxicBurden_per_sec'; ...
    'HypoxicBurden_per_min'; 'HypoxicBurden_per_mm2_per_sec'; ...
    'HypoxicBurden_per_mm2_per_min'; 'HypoxicBurden_TimeSeries'; ...
    'HypoxicBurdenOverTime'; 'HypoxicBurdenPerMm2OverTime'; ...
    'Burden_Occupancy'; 'Burden_RankAmplitude'; 'Burden_AmplitudeComposite'};
MetricBasis = {'Event-based'; 'Recording-level sum of true event rows'; ...
    'True event-specific area from EventSpecificMetrics.Area_um when available'; ...
    'Recording/FOV area used for 1 mm^2 burden normalization'; ...
    'BurdenAmplitudePercent * BurdenArea_um2 * BurdenDuration_sec'; ...
    'PerEventBurdenContribution * (1e6 / BurdenRecordingArea_um2)'; ...
    'Recording duration used for time-rate normalization'; ...
    'Sum of PerEventBurdenContribution across events in each recording/FOV'; ...
    'Sum of FOV-normalized event contributions on a 1 mm^2 area basis'; ...
    'HypoxicBurden / BurdenRecordingDuration_sec'; ...
    'HypoxicBurden * 60 / BurdenRecordingDuration_sec'; ...
    'HypoxicBurden_per_mm2 / BurdenRecordingDuration_sec'; ...
    'HypoxicBurden_per_mm2 * 60 / BurdenRecordingDuration_sec'; ...
    'Frame-wise burden trace from active individual event rows'; ...
    'sum(active PerEventBurdenContribution / event duration)'; ...
    'sum(active PerEventBurdenContribution_per_mm2 / event duration)'; ...
    'event frequency x mean event duration, normalized per mm2 and per minute'; ...
    'count x duration x within-recording rank/quantile-transformed amplitude, normalized per mm2 and per minute'; ...
    'original amplitude x area x duration composite'};
Notes = {'One row per oxygen sink event from OxySinkEvents'; ...
    'Grouped by available recording metadata'; ...
    'Falls back to site-level MeanOxySinkArea_um only when event-specific Area_um cannot be matched'; ...
    'Preferred source is EventSpecificMetrics.Area_um / EventSpecificMetrics.Area_norm'; ...
    'Amplitude is converted to positive drop percent from the event amplitude column'; ...
    'Units are percent * um^2 * seconds per 1 mm^2 recording area'; ...
    'Preferred source is TableOxygenSinks.RecDuration'; ...
    'Units are percent * um^2 * seconds'; ...
    'Use this metric to compare burden across recordings with different FOV sizes'; ...
    'Use this metric when recording durations differ'; ...
    'Same as per-second burden, reported on a per-minute scale'; ...
    'Use this metric when both recording duration and FOV size differ'; ...
    'Recommended compact burden-rate metric for mixed FOV and recording durations'; ...
    'Long-format sheet: one row per recording frame/time point for EEG/ECG/sleep-state alignment'; ...
    'Raw recorded-FOV burden signal over time; not FOV-normalized and not per-minute normalized'; ...
    'Recommended frame-aligned burden signal for recordings with different FOV sizes'; ...
    'Interface-contract default burden variant for cross-genotype/cross-cohort comparisons; amplitude-free.'; ...
    'Interface-contract sensitivity variant; relative within recording only, not absolutely comparable across animals.'; ...
    'Interface-contract original composite; valid within matched-acquisition cohorts only.'};

BasisTable = table(WorkbookItem,MetricBasis,Notes);

end
