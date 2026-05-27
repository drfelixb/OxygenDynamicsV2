function [EventSnippetTables,EventSnippetSheetNames,AlignedSinkTraces] = prepareStatsBLIExportData( ...
    FiltersROIsAndEvents,SinksTraces,EventSnips)
%PREPARESTATSBLIEXPORTDATA Prepare BLI-only event and aligned-trace exports.

[EventSnippetTables,EventSnippetSheetNames] = createStatsEventSnippetExports( ...
    EventSnips.Manual,EventSnips.LPaw,EventSnips.RPaw,EventSnips.Groom, ...
    EventSnips.Pupil,EventSnips.Puff,EventSnips.Whisk);
AlignedSinkTraces = createAlignedSinkTraceExport(FiltersROIsAndEvents,SinksTraces);

end
