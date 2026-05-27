function ExportTable = createPaddedTraceExportTable(HeaderCells,TraceCells)
%CREATEPADDEDTRACEEXPORTTABLE Pad unequal traces and combine them with headers.

TraceCells = TraceCells(:);
TraceLengths = cellfun(@(Trace) size(Trace,2),TraceCells);
MaxLength = max(TraceLengths);
PaddedTraces = cellfun(@(Trace) [Trace,nan(size(Trace,1),MaxLength-size(Trace,2))], ...
    TraceCells,'UniformOutput',false);

ExportTable = cell2table([HeaderCells;num2cell((cell2mat(PaddedTraces))')]);

end
