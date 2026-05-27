function OutTable = vertcatCellTables(TableCells)
TableCells=TableCells(~cellfun(@isempty,TableCells));
if isempty(TableCells)
    OutTable=[];
else
    OutTable=vertcat(TableCells{:});
end
end
