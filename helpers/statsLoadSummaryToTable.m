function SummaryTable = statsLoadSummaryToTable(StatsInfo)
%STATSLOADSUMMARYTOTABLE Convert StatsInfo.LoadSummary to a one-row table.

if ~isfield(StatsInfo,'LoadSummary') || isempty(StatsInfo.LoadSummary)
    SummaryTable = table();
    return
end

LoadSummary = StatsInfo.LoadSummary;
SummaryTable = struct2table(LoadSummary,'AsArray',true);
end
