function writeStatsBinnedTraceSheets(outputXlsx,leftPawTables,rightPawTables,pupilTables)
for rowIdx=4:size(leftPawTables,1)
    counter=1;
    for colIdx=2:size(leftPawTables,2)
        LeftPawSheet = makeValidExcelSheetName([leftPawTables{rowIdx,1},'LPawbin']);
        RightPawSheet = makeValidExcelSheetName([leftPawTables{rowIdx,1},'RPawbin']);
        PupilSheet = makeValidExcelSheetName([pupilTables{rowIdx,1},'Pupilbin']);
        writetable(leftPawTables{rowIdx,colIdx},outputXlsx,'Sheet',LeftPawSheet, ...
            'Range',[xlscol(counter),'1']);
        writetable(rightPawTables{rowIdx,colIdx},outputXlsx,'Sheet',RightPawSheet, ...
            'Range',[xlscol(counter),'1']);
        writetable(pupilTables{rowIdx,colIdx},outputXlsx,'Sheet',PupilSheet, ...
            'Range',[xlscol(counter),'1']);

        counter=counter+size(pupilTables{rowIdx,colIdx},2);
    end
end
end
