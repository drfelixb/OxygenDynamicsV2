function LoadSummary = warnStatsLoadedDataIssues(StatsInfo,RecordingCells,IsBLI)
%WARNSTATSLOADEDDATAISSUES Warn about missing loaded stats data categories.

Recordings = getStatsRecordings(StatsInfo);
LoadSummary = struct();
LoadSummary.NumRecordings = numel(Recordings);
LoadSummary.NumWithSinks = countRecordingFlag(Recordings,'HasSinks');
LoadSummary.NumWithSurges = countRecordingFlag(Recordings,'HasSurges');
LoadSummary.NumWithBehaviourFolders = countRecordingFlag(Recordings,'HasBehaviourData');
LoadSummary.NumWithConfiguredBehaviourInputs = countRecordingFlag(Recordings,'HasConfiguredBehaviourInputs');
LoadSummary.NumWithBehaviourTraces = countNonemptyRows(RecordingCells.BehaviourDataCombo);
LoadSummary.NumWithROITraces = countNonemptyColumn(RecordingCells.ROIsTraces,6);

if LoadSummary.NumRecordings==0
    warning('OxygenDynamics:StatsNoRecordings','No stats recordings were loaded.');
    return
end

if LoadSummary.NumWithSinks==0
    warning('OxygenDynamics:StatsNoSinks','No loaded recordings contained oxygen sinks.');
elseif LoadSummary.NumWithSinks<LoadSummary.NumRecordings
    warning('OxygenDynamics:StatsPartialSinks', ...
        '%d of %d loaded recordings contained oxygen sinks.', ...
        LoadSummary.NumWithSinks,LoadSummary.NumRecordings);
end

if LoadSummary.NumWithSurges==0
    warning('OxygenDynamics:StatsNoSurges','No loaded recordings contained oxygen surges.');
elseif LoadSummary.NumWithSurges<LoadSummary.NumRecordings
    warning('OxygenDynamics:StatsPartialSurges', ...
        '%d of %d loaded recordings contained oxygen surges.', ...
        LoadSummary.NumWithSurges,LoadSummary.NumRecordings);
end

if LoadSummary.NumWithConfiguredBehaviourInputs>0 && LoadSummary.NumWithBehaviourFolders==0
    warning('OxygenDynamics:StatsNoBehaviourFolders', ...
        'Behaviour inputs were configured, but no loaded recordings had behaviour output folders.');
elseif LoadSummary.NumWithConfiguredBehaviourInputs>0 && LoadSummary.NumWithBehaviourTraces==0
    warning('OxygenDynamics:StatsNoBehaviourTraces', ...
        'Behaviour inputs and output folders were found, but no behaviour traces were loaded.');
end

if IsBLI && LoadSummary.NumWithROITraces==0
    warning('OxygenDynamics:StatsNoROITraces','No BLI ROI traces were loaded.');
end
end

function Recordings = getStatsRecordings(StatsInfo)
if isfield(StatsInfo,'Recordings') && ~isempty(StatsInfo.Recordings)
    Recordings = StatsInfo.Recordings(:);
else
    Recordings = struct([]);
end
end

function Count = countRecordingFlag(Recordings,FieldName)
Count = 0;
for reci = 1:numel(Recordings)
    if isfield(Recordings(reci),FieldName) && logical(Recordings(reci).(FieldName))
        Count = Count+1;
    end
end
end

function Count = countNonemptyRows(CellRows)
Count = 0;
for rowi = 1:size(CellRows,1)
    if any(~cellfun(@isempty,CellRows(rowi,:)))
        Count = Count+1;
    end
end
end

function Count = countNonemptyColumn(CellRows,ColumnIdx)
Count = 0;
if size(CellRows,2)<ColumnIdx
    return
end
for rowi = 1:size(CellRows,1)
    if ~isempty(CellRows{rowi,ColumnIdx})
        Count = Count+1;
    end
end
end
