function writeStatsPooledTraceSheets(outputXlsx,pooledTraces)
for rowIdx=4:size(pooledTraces,1)
    counter=1;
    for colIdx=2:size(pooledTraces,2)
        TableToWrite=pooledTraces{rowIdx,colIdx};
        if isempty(TableToWrite)
            continue
        end

        tempcell=cell(3,width(TableToWrite));
        tempcell(1,:)=repmat(pooledTraces(1,colIdx),1,width(TableToWrite));
        tempcell(2,:)=repmat(pooledTraces(2,colIdx),1,width(TableToWrite));
        tempcell(3,:)=repmat(pooledTraces(3,colIdx),1,width(TableToWrite));

        sheetName=makeValidExcelSheetName([pooledTraces{rowIdx,1},'Pooled_Traces']);
        writetable(cell2table(tempcell),outputXlsx,'Sheet',sheetName,'Range',[xlscol(counter),'1']);
        writetable(TableToWrite,outputXlsx,'Sheet',sheetName,'Range',[xlscol(counter),'5']);

        counter=counter+width(TableToWrite);
    end
end
end
