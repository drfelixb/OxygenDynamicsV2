function ExportTables = createBinnedTraceExport(GroupHeaders,FiltersROIsAndEvents,BinnedTraceCells)
%CREATEBINNEDTRACEEXPORT Build grouped percentile-bin trace export tables.

ExportTables = GroupHeaders;
BinLabels = num2cell(10:10:100);
ExportRows = 4:15;

for GroupIdx = 1:size(ExportTables,2)
    GroupFilter = FiltersROIsAndEvents{4,GroupIdx};
    HeaderCells = cell(4,10);
    HeaderCells(1,:) = ExportTables(1,GroupIdx);
    HeaderCells(2,:) = ExportTables(2,GroupIdx);
    HeaderCells(3,:) = ExportTables(3,GroupIdx);
    HeaderCells(4,:) = BinLabels;

    HasGroupData = any(GroupFilter) && all(~cellfun(@isempty,BinnedTraceCells(GroupFilter,1)));
    for BinIdx = 1:numel(ExportRows)
        if HasGroupData
            ExportTables{ExportRows(BinIdx),GroupIdx} = cell2table( ...
                [HeaderCells;num2cell(cell2mat(BinnedTraceCells(GroupFilter,BinIdx)))]);
        else
            ExportTables{ExportRows(BinIdx),GroupIdx} = cell2table([HeaderCells;num2cell(nan(1,10))]);
        end
    end
end

end
