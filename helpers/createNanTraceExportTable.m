function ExportTable = createNanTraceExportTable(HeaderCells,NumRows)
%CREATENANTRACEEXPORTTABLE Create an empty-group trace export placeholder.

ExportTable = cell2table([HeaderCells;num2cell(nan(NumRows,1))]);

end
