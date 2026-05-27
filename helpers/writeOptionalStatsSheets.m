function writeOptionalStatsSheets(outputXlsx,tablesToWrite,sheetNames)
for sheetIdx=1:numel(sheetNames)
    if ~isempty(tablesToWrite{sheetIdx})
        SheetName = makeValidExcelSheetName(sheetNames{sheetIdx});
        writetable(tablesToWrite{sheetIdx},outputXlsx,'Sheet',SheetName);
    end
end
end
