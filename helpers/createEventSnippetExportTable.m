function ExportTable = createEventSnippetExportTable(eventSnips)
if isempty(eventSnips)
    ExportTable=[];
    return
end

ExportCells=eventSnips(:,1:5);
TraceCells=num2cell(cell2mat(eventSnips(:,6)));
ExportTable=cell2table([ExportCells,TraceCells]);
end
