function ExportTable = createTraceCorrelationExportTable(HeaderCells,CorrelationCells)
%CREATETRACECORRELATIONEXPORTTABLE Combine grouped correlation values with headers.

ExportTable = cell2table([HeaderCells;num2cell(cell2mat(CorrelationCells))]);

end
