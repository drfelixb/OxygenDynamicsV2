function writeStatsRunSummarySheets(OutputXlsx,StatsInfo)
%WRITESTATSRUNSUMMARYSHEETS Write run-level stats summary workbook sheets.

StatsRunSummary = statsRecordingsToTable(StatsInfo);
if ~isempty(StatsRunSummary)
    writetable(StatsRunSummary,OutputXlsx,'Sheet','StatsRunSummary');
end

StatsLoadSummary = statsLoadSummaryToTable(StatsInfo);
if ~isempty(StatsLoadSummary)
    writetable(StatsLoadSummary,OutputXlsx,'Sheet','StatsLoadSummary');
end

StatsLoadIssues = statsLoadIssuesToTable(StatsInfo);
if ~isempty(StatsLoadIssues)
    writetable(StatsLoadIssues,OutputXlsx,'Sheet','StatsLoadIssues');
end

if isfield(StatsInfo,'SinkCountAreaNormalization') && ~isempty(StatsInfo.SinkCountAreaNormalization)
    writetable(StatsInfo.SinkCountAreaNormalization,OutputXlsx,'Sheet','SinkCountNormFactors');
end
end
