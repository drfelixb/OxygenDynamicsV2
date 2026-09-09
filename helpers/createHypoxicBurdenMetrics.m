function Burden = createHypoxicBurdenMetrics(TableOxygenSinkEvents,EventSpecificMetrics,TableOxygenSinks,RecordingRegistry)
%CREATEHYPOXICBURDENMETRICS Compute event and recording hypoxic burden.
%
% The primary metric is true event-level:
%   burden = positive drop amplitude (%) * event area (um^2) * duration (s)

if nargin<4, RecordingRegistry=table(); end
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
    Burden.RecordingTable=aggregateOxygenRecordingBurden(table(),RecordingRegistry);
    Burden.GroupSummaryTable=summarizeOxygenMouseMetrics(Burden.RecordingTable);
    Burden.TimeSeriesTable=completeOxygenBurdenTimeSeries(table(),RecordingRegistry);
    Burden.TimeSeriesBasis=createBurdenTimeSeriesBasisTable();
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
if ~isempty(RecordingRegistry), Burden.RecordingTable=aggregateOxygenRecordingBurden(EventTable,RecordingRegistry); end
Burden.GroupSummaryTable = summarizeOxygenMouseMetrics(Burden.RecordingTable);
[Burden.TimeSeriesTable,Burden.TimeSeriesBasis] = createBurdenTimeSeriesTable(EventTable);
if ~isempty(RecordingRegistry),Burden.TimeSeriesTable=completeOxygenBurdenTimeSeries(Burden.TimeSeriesTable,RecordingRegistry);end

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

AmplitudePercent = RawAmplitude;
SignConvention = 'positive_drop_percent';
if ismember('AmplitudeSignConvention',EventTable.Properties.VariableNames)
    Negative = string(EventTable.AmplitudeSignConvention)=="negative_drop_percent";
    AmplitudePercent(Negative) = -AmplitudePercent(Negative);
end
AmplitudePercent(AmplitudePercent<0) = NaN; % wrong direction, not hypoxic deficit

end

function [BurdenArea,AreaSource,EventSpecificMatched] = getEventSpecificBurdenArea(EventTable,EventSpecificMetrics)

BurdenArea=nan(height(EventTable),1);
AreaSource='NativeEventArea_or_unavailable';
EventSpecificMatched=false(height(EventTable),1);
if ismember('EventArea_um2',EventTable.Properties.VariableNames),BurdenArea=tableColumnToDouble(EventTable.EventArea_um2);end
if istable(EventSpecificMetrics) && ~isempty(EventSpecificMetrics) && all(ismember({'EventID','Area_um'},EventSpecificMetrics.Properties.VariableNames))
    [matched,EventSpecificMatched]=matchEventSpecificArea(EventTable,EventSpecificMetrics);
    BurdenArea(EventSpecificMatched)=matched(EventSpecificMatched);
    AreaSource='EventSpecificMetrics_or_NativeEventArea_or_unavailable';
end
end

function [A,source]=getBurdenRecordingArea(E,~)
assert(ismember('RecAreaSize',E.Properties.VariableNames),'OxygenDynamics:MissingExposure','Event rows require saved recording area.');
A=tableColumnToDouble(E.RecAreaSize);source='OxySinkEvents.RecAreaSize';
end
function [D,source]=getBurdenRecordingDuration(E,~)
assert(ismember('RecDuration',E.Properties.VariableNames),'OxygenDynamics:MissingExposure','Event rows require independent recording duration.');
D=tableColumnToDouble(E.RecDuration);source='OxySinkEvents.RecDuration';
end

function [MatchedArea,Matched] = matchEventSpecificArea(EventTable,EventSpecificMetrics)

SpecificArea = tableColumnToDouble(EventSpecificMetrics.Area_um);
[MatchedArea,Matched] = matchEventSpecificNumericColumn(EventTable,EventSpecificMetrics,SpecificArea);

end

function [MatchedValues,Matched] = matchEventSpecificNumericColumn(EventTable,EventSpecificMetrics,SpecificValues)

[EventKeys,SpecificKeys] = oxygenEventJoinKeys(EventTable,EventSpecificMetrics);
MatchedValues = nan(height(EventTable),1);
Matched = false(height(EventTable),1);

for EventIdx = 1:numel(EventKeys)
    MatchIdx = find(SpecificKeys==EventKeys(EventIdx));
    if numel(MatchIdx)>1
        error('OxygenDynamics:AmbiguousEventKey','Duplicate event-specific key: %s',EventKeys(EventIdx));
    end
    if ~isempty(MatchIdx)
        MatchedValues(EventIdx) = SpecificValues(MatchIdx);
        Matched(EventIdx) = true;
    end
end

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

GroupColumns = {'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'};
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
    HypoxicBurden(GroupI) = sum(Contributions);
    HypoxicBurden_per_mm2(GroupI) = sum(ContributionsPerMm2);
    RecordingArea_um2(GroupI) = median(EventTable.BurdenRecordingArea_um2(Mask),'omitnan');
    RecordingDuration_sec(GroupI) = median(EventTable.BurdenRecordingDuration_sec(Mask),'omitnan');
    HypoxicBurden_per_sec(GroupI) = HypoxicBurden(GroupI) ./ RecordingDuration_sec(GroupI);
    HypoxicBurden_per_min(GroupI) = HypoxicBurden(GroupI) .* 60 ./ RecordingDuration_sec(GroupI);
    HypoxicBurden_per_mm2_per_sec(GroupI) = HypoxicBurden_per_mm2(GroupI) ./ RecordingDuration_sec(GroupI);
    HypoxicBurden_per_mm2_per_min(GroupI) = HypoxicBurden_per_mm2(GroupI) .* 60 ./ RecordingDuration_sec(GroupI);
    NumEvents(GroupI) = sum(Mask);
    NumSinkSites(GroupI) = countUniqueSinkSites(EventTable,Mask);
    MeanEventBurdenContribution(GroupI) = mean(Contributions,'omitnan');
    MedianEventBurdenContribution(GroupI) = median(Contributions,'omitnan');
    MeanEventBurdenContribution_per_mm2(GroupI) = mean(ContributionsPerMm2,'omitnan');
    MedianEventBurdenContribution_per_mm2(GroupI) = median(ContributionsPerMm2,'omitnan');
    MeanBurdenAmplitudePercent(GroupI) = mean(EventTable.BurdenAmplitudePercent(Mask),'omitnan');
    MeanBurdenArea_um2(GroupI) = mean(EventTable.BurdenArea_um2(Mask),'omitnan');
    MeanBurdenDuration_sec(GroupI) = mean(EventTable.BurdenDuration_sec(Mask),'omitnan');
    Burden_Occupancy(GroupI) = sum(EventTable.PerEventBurdenOccupancy_per_mm2_per_min(Mask));
    Burden_RankAmplitude(GroupI) = sum(EventTable.PerEventBurdenRankAmplitude_per_mm2_per_min(Mask));
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

function [TimeSeriesTable,BasisTable] = createBurdenTimeSeriesTable(EventTable)

TimeSeriesTable = table();
BasisTable = createBurdenTimeSeriesBasisTable();
RequiredColumns = {'StartFrame','EndFrame','PerEventBurdenContribution', ...
    'PerEventBurdenContribution_per_mm2'};
if isempty(EventTable) || ~all(ismember(RequiredColumns,EventTable.Properties.VariableNames))
    return
end

GroupColumns = {'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'};
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
AllMetaColumns = {'RecordingID','Experiment','Mouse','Condition','DrugID','Genotype','Promoter','PuffStim'};
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


    for EventIdx = 1:height(EventRows)
        FirstFrame = max(1,StartFrame(EventIdx));
        LastFrame = min(NumFrames,EndFrame(EventIdx));
        if ~isfinite(FirstFrame) || ~isfinite(LastFrame) || LastFrame<FirstFrame
            continue
        end
        FrameIdx = FirstFrame:LastFrame;
        DurationSec = numel(FrameIdx)/Fs; % integrate exactly over the exported frame intervals
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

TimeSeriesTable = table(RecordingIndex,Meta.RecordingID,Meta.Experiment,Meta.Mouse,Meta.Condition, ...
    Meta.DrugID,Meta.Genotype,Meta.Promoter,Meta.PuffStim,Frame,TimeSec,SampleFs, ...
    RecordingDuration_sec,ActiveHypoxicEvents,HypoxicBurdenOverTime, ...
    HypoxicBurdenPerMm2OverTime,Formula,Units,UnitsPerMm2, ...
    'VariableNames',{'RecordingIndex','RecordingID','Experiment','Mouse','Condition','DrugID', ...
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

function Fs=inferBurdenSampleFrequency(E)
assert(ismember('SampleF',E.Properties.VariableNames),'OxygenDynamics:MissingSampleRate','Saved sampling rate is required.');
v=unique(E.SampleF);assert(isscalar(v)&&isfinite(v)&&v>0,'OxygenDynamics:InvalidExposure','Inconsistent recording sampling rates.');Fs=v;
end
function D=inferBurdenRecordingDuration(E,~)
v=unique(E.BurdenRecordingDuration_sec);assert(isscalar(v)&&isfinite(v)&&v>0,'OxygenDynamics:InvalidExposure','Independent recording duration is required.');D=v;
end

function NumFrames = inferBurdenNumFrames(EventRows,Fs,RecordingDuration)

NumFrames=round(RecordingDuration*Fs);
assert(abs(NumFrames-RecordingDuration*Fs)<1e-6 && all(EventRows.StartFrame>=1) && all(EventRows.EndFrame<=NumFrames), ...
    'OxygenDynamics:InvalidExposure','Event bounds are inconsistent with the independent recording exposure.');
end

function Count = countUniqueSinkSites(EventTable,Mask)

if ismember('SinkID',EventTable.Properties.VariableNames)
    cols=intersect({'RecordingID','Experiment','Mouse','SinkID'},EventTable.Properties.VariableNames,'stable');
    Count=height(unique(EventTable(Mask,cols),'rows'));
else
    Count = NaN;
end

end

function Quantile = computeWithinRecordingAmplitudeQuantile(EventTable)

Quantile = nan(height(EventTable),1);
assert(ismember('RecordingID',EventTable.Properties.VariableNames),'OxygenDynamics:MissingRecordingIdentity','RecordingID is required.');
Keys=string(EventTable.RecordingID);
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
    'Uses native EventArea_um2 when unmatched; missing native morphology remains NaN'; ...
    'Eligible analyzed tissue area from the event table or recording registry'; ...
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
    'Concurrent event-time density; not tissue occupancy or a calibrated oxygen deficit.'; ...
    'Interface-contract sensitivity variant; relative within recording only, not absolutely comparable across animals.'; ...
    'Interface-contract original composite; valid within matched-acquisition cohorts only.'};

BasisTable = table(WorkbookItem,MetricBasis,Notes);

end
