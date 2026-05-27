function IssuesTable = statsLoadIssuesToTable(StatsInfo)
%STATSLOADISSUESTOTABLE Create a user-facing per-recording stats audit table.

RunSummary = statsRecordingsToTable(StatsInfo);
if isempty(RunSummary)
    IssuesTable = table();
    return
end

NumRows = height(RunSummary);
Status = strings(NumRows,1);
IssueSummary = strings(NumRows,1);
RecommendedAction = strings(NumRows,1);

for RowIdx = 1:NumRows
    [Status(RowIdx),IssueSummary(RowIdx),RecommendedAction(RowIdx)] = ...
        summarizeStatsRecordingIssue(RunSummary(RowIdx,:));
end

IssuesTable = addvars(RunSummary,Status,IssueSummary,RecommendedAction, ...
    'Before','Path');

end

function [Status,IssueSummary,RecommendedAction] = summarizeStatsRecordingIssue(RecordingRow)

Issues = strings(0,1);
Actions = strings(0,1);

if ~RecordingRow.HasSinks
    Issues(end+1,1) = "No oxygen sink data loaded";
    Actions(end+1,1) = "Check selected OxygenSinks_Output folder and Urefined sink MAT file";
end

if ~RecordingRow.HasSurges
    Issues(end+1,1) = "No oxygen surge data loaded";
    Actions(end+1,1) = "Check selected OxygenSurges_Output folder and surge MAT file";
end

if RecordingRow.HasConfiguredBehaviourInputs && ~RecordingRow.HasBehaviourData
    Issues(end+1,1) = "Behaviour inputs configured but no Behaviour_Output folder selected";
    Actions(end+1,1) = "Run behaviour analysis or clear unused behaviour columns in the input CSV";
elseif RecordingRow.HasConfiguredBehaviourInputs && ~RecordingRow.HasBehaviourTraces
    Issues(end+1,1) = "Behaviour folder selected but no behaviour traces loaded";
    Actions(end+1,1) = "Check behaviour MAT files and CSV behaviour filename columns";
end

if ~RecordingRow.HasROITraces
    Issues(end+1,1) = "No ROI traces loaded";
    Actions(end+1,1) = "Check oxygen surge output contains Mean_ROI_TraceZ if BLI trace analyses are needed";
end

if isempty(Issues)
    Status = "Ready";
    IssueSummary = "No issues detected";
    RecommendedAction = "None";
else
    Status = "Needs review";
    IssueSummary = strjoin(Issues,"; ");
    RecommendedAction = strjoin(unique(Actions,'stable'),"; ");
end

end
