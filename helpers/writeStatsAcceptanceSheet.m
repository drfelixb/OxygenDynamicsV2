function writeStatsAcceptanceSheet(OutputXlsx,StatsResult)
%WRITESTATSACCEPTANCESHEET Write the stats acceptance checklist workbook sheet.

AcceptanceRows = buildOxygenStatsAcceptanceRows(StatsResult);
if ~isempty(AcceptanceRows)
    writetable(AcceptanceRows,OutputXlsx,'Sheet','StatsAcceptance');
end

end
