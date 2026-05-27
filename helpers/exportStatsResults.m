function ExportInfo = exportStatsResults(StatsOutputFolderPath,InputCsv,IsBLI,CoreData, ...
    BLIData,BLIWorkbookData,ExportReady,EventSnippetTables,EventSnippetSheetNames)
%EXPORTSTATSRESULTS Save stats MAT outputs and write the stats workbook.

mkdirIfMissing(StatsOutputFolderPath);

if isfield(CoreData,'HypoxicBurden')
    HypoxicBurden = CoreData.HypoxicBurden;
else
    if isfield(CoreData,'HypoxicEventSpecificMetrics')
        HypoxicBurden = createHypoxicBurdenMetrics( ...
            CoreData.TableOxygenSinkEvents,CoreData.HypoxicEventSpecificMetrics);
    else
        HypoxicBurden = createHypoxicBurdenMetrics(CoreData.TableOxygenSinkEvents);
    end
end
CoreData.HypoxicBurden = HypoxicBurden;

StatsDataOutput = createStatsDataOutput(CoreData,IsBLI,BLIData);
saveStatsDataOutput(StatsOutputFolderPath,StatsDataOutput,IsBLI);
saveStatsCoreTables(StatsOutputFolderPath,CoreData.TableOxygenSinks,CoreData.TableOxygenSinkEvents, ...
    CoreData.TableOxygenSurges,CoreData.TableOxygenSurgeEvents);

OutputXlsx = createStatsExcelOutputPath(StatsOutputFolderPath,InputCsv);
writeStatsAcceptanceSheet(OutputXlsx,struct('StatsInfo',CoreData.StatsInfo, ...
    'DataOutputMat',fullfile(StatsOutputFolderPath,'DataOutput.mat')));
writeStatsRunSummarySheets(OutputXlsx,CoreData.StatsInfo);
writeStatsMetricBasisSheet(OutputXlsx);
writeStatsMetricDefinitionsSheet(OutputXlsx);
writeStatsEventTables(OutputXlsx,CoreData.TableOxygenSinkEvents,CoreData.TableOxygenSurgeEvents);
writeHypoxicBurdenWorkbookSheets(OutputXlsx,HypoxicBurden);
writeStatsMetricWorkbookSheets(OutputXlsx,ExportReady);
if isfield(CoreData,'HypoxicEventSpecificMetrics')
    EventSpecificExportInfo = exportHypoxicEventSpecificMetrics( ...
        StatsOutputFolderPath,CoreData.HypoxicEventSpecificMetrics);
else
    EventSpecificExportInfo = struct('OutputXlsx','','DataMat','');
end

StatsWorkbookOptions = createStatsWorkbookOptions(IsBLI,BLIWorkbookData);
writeStatsAnalysisWorkbookOutputs(OutputXlsx,CoreData.ExportTraces,EventSnippetTables, ...
    EventSnippetSheetNames,IsBLI,StatsWorkbookOptions);

ExportInfo = struct();
ExportInfo.OutputXlsx = OutputXlsx;
ExportInfo.DataOutputMat = fullfile(StatsOutputFolderPath,'DataOutput.mat');
ExportInfo.EventSpecificOutputXlsx = EventSpecificExportInfo.OutputXlsx;
ExportInfo.EventSpecificDataMat = EventSpecificExportInfo.DataMat;
ExportInfo.HypoxicBurden = HypoxicBurden;

end
