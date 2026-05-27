function writeAlignedSinkTraceSheets(outputXlsx,alignedSinkTraces)
for groupIdx=1:size(alignedSinkTraces,2)
    GroupLabel=alignedSinkTraces{1,groupIdx};
    if isempty(alignedSinkTraces{2,groupIdx})
        continue
    end

    findW=strfind(GroupLabel,'W');
    findUnderscore=strfind(GroupLabel,'_');
    if isempty(findW) || isempty(findUnderscore)
        SheetName=['SinksLevel',GroupLabel];
    else
        SheetName=['SinksLevel',GroupLabel(1:7),GroupLabel(findW(end):findUnderscore(1)-1),'stim'];
    end

    SheetName = makeValidExcelSheetName(SheetName);
    writetable(alignedSinkTraces{2,groupIdx},outputXlsx,'Sheet',SheetName,'WriteVariableNames',0);
end
end
