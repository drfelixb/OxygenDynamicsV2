function writeStatsGroupedTables(outputXlsx,groupedTables,varargin)
writeVariableNames = getOption(varargin,'WriteVariableNames',0);

for rowIdx=4:size(groupedTables,1)
    counter=1;
    for colIdx=2:size(groupedTables,2)
        TableToWrite=groupedTables{rowIdx,colIdx};
        if isempty(TableToWrite)
            continue
        end

        SheetName = makeValidExcelSheetName(groupedTables{rowIdx,1});
        writetable(TableToWrite,outputXlsx,'Sheet',SheetName, ...
            'Range',[xlscol(counter),'1'],'WriteVariableNames',writeVariableNames);
        counter=counter+size(TableToWrite,2);
    end
end
end

function value = getOption(options,name,defaultValue)
value = defaultValue;
for optionIdx=1:2:numel(options)
    if strcmpi(options{optionIdx},name)
        value = options{optionIdx+1};
        return
    end
end
end
