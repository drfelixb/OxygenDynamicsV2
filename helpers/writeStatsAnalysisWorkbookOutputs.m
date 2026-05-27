function writeStatsAnalysisWorkbookOutputs(OutputXlsx,ExportTraces,EventSnippetTables, ...
    EventSnippetSheetNames,IsBLI,Options)
%WRITESTATSANALYSISWORKBOOKOUTPUTS Write grouped stats workbook outputs.

if nargin<6 || isempty(Options)
    Options = struct();
end

if IsBLI && hasOptionField(Options,'AlignedSinkTraces')
    writeAlignedSinkTraceSheets(OutputXlsx,Options.AlignedSinkTraces);
end

writeStatsGroupedTables(OutputXlsx,ExportTraces,'WriteVariableNames',0);

if IsBLI && hasOptionField(Options,'TraceCorrs')
    writeStatsGroupedTables(OutputXlsx,Options.TraceCorrs,'WriteVariableNames',0);
end

if IsBLI && hasOptionField(Options,'LPawBinnedTraces') && ...
        hasOptionField(Options,'RPawBinnedTraces') && hasOptionField(Options,'PupilBinnedTraces')
    writeStatsBinnedTraceSheets(OutputXlsx,Options.LPawBinnedTraces, ...
        Options.RPawBinnedTraces,Options.PupilBinnedTraces);
end

if IsBLI && hasOptionField(Options,'PooledTraces')
    writeStatsPooledTraceSheets(OutputXlsx,Options.PooledTraces);
end

writeOptionalStatsSheets(OutputXlsx,EventSnippetTables,EventSnippetSheetNames);

if IsBLI && hasOptionField(Options,'BehaviourLogicals') && hasOptionField(Options,'SampleFs') && ...
        hasOptionField(Options,'PuffsFs') && hasOptionField(Options,'FiguresOutputFolder')
    writeStatsPuffTraceFigures(ExportTraces,Options.BehaviourLogicals,Options.SampleFs, ...
        Options.PuffsFs,Options.FiguresOutputFolder);
end

end

function HasField = hasOptionField(Options,FieldName)

HasField = isfield(Options,FieldName) && ~isempty(Options.(FieldName));

end
