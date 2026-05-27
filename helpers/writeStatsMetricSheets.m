function writeStatsMetricSheets(outputXlsx,exportReady,sheetNames,columnIdx)
for rowIdx=1:numel(sheetNames)
    SheetName = makeValidExcelSheetName(sheetNames{rowIdx});
    writetable(exportReady{rowIdx,columnIdx},outputXlsx,'Sheet',SheetName,'WriteVariableNames',0);
end
end
