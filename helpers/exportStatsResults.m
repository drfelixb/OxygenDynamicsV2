function ExportInfo = exportStatsResults(StatsOutputFolderPath,InputCsv,IsBLI,CoreData, ...
    BLIData,BLIWorkbookData,ExportReady,EventSnippetTables,EventSnippetSheetNames)
%EXPORTSTATSRESULTS Save stats MAT outputs and write the stats workbook.

mkdirIfMissing(StatsOutputFolderPath);

if isfield(CoreData,'HypoxicBurden')
    HypoxicBurden = CoreData.HypoxicBurden;
else
    if isfield(CoreData,'HypoxicEventSpecificMetrics')
        HypoxicBurden = createHypoxicBurdenMetrics( ...
            CoreData.TableOxygenSinkEvents,CoreData.HypoxicEventSpecificMetrics,CoreData.TableOxygenSinks);
    else
        HypoxicBurden = createHypoxicBurdenMetrics(CoreData.TableOxygenSinkEvents,table(),CoreData.TableOxygenSinks);
    end
end
CoreData.HypoxicBurden = HypoxicBurden;

StatsDataOutput = createStatsDataOutput(CoreData,IsBLI,BLIData);
fprintf('[Stats %s] Saving DataOutput.mat...\n',char(datetime('now','Format','HH:mm:ss')));
saveStatsDataOutput(StatsOutputFolderPath,StatsDataOutput,IsBLI);
fprintf('[Stats %s] Saving core stats MAT tables...\n',char(datetime('now','Format','HH:mm:ss')));
saveStatsCoreTables(StatsOutputFolderPath,CoreData.TableOxygenSinks,CoreData.TableOxygenSinkEvents, ...
    CoreData.TableOxygenSurges,CoreData.TableOxygenSurgeEvents);

OutputXlsx = createStatsExcelOutputPath(StatsOutputFolderPath,InputCsv);
if isfield(CoreData,'RecordingRegistry')
    RecordingRegistry=CoreData.RecordingRegistry; BaselineContrasts=CoreData.BaselineContrasts;
    RecordingWindowMetrics=CoreData.RecordingWindowMetrics;WindowBaselineContrasts=CoreData.WindowBaselineContrasts;
    save(fullfile(StatsOutputFolderPath,'DataOutput.mat'),'RecordingRegistry','BaselineContrasts','RecordingWindowMetrics','WindowBaselineContrasts','-append');
    writetable(RecordingRegistry,OutputXlsx,'Sheet','RecordingRegistry');
    writetable(RecordingWindowMetrics,OutputXlsx,'Sheet','RecordingWindowMetrics');
    if ~isempty(WindowBaselineContrasts), writetable(WindowBaselineContrasts,OutputXlsx,'Sheet','WindowBaselineContrasts'); end
    if ~isempty(BaselineContrasts), writetable(BaselineContrasts,OutputXlsx,'Sheet','PairedBaselineContrasts'); end
end
fprintf('[Stats %s] Writing acceptance and run summary sheets...\n',char(datetime('now','Format','HH:mm:ss')));
writeStatsAcceptanceSheet(OutputXlsx,struct('StatsInfo',CoreData.StatsInfo, ...
    'DataOutputMat',fullfile(StatsOutputFolderPath,'DataOutput.mat')));
writeStatsRunSummarySheets(OutputXlsx,CoreData.StatsInfo);
writeStatsMetricBasisSheet(OutputXlsx);
writeStatsMetricDefinitionsSheet(OutputXlsx);
writeStatsNormalizationGuideSheet(OutputXlsx);
fprintf('[Stats %s] Writing event and hypoxic burden sheets...\n',char(datetime('now','Format','HH:mm:ss')));
writeStatsEventTables(OutputXlsx,CoreData.TableOxygenSinkEvents,CoreData.TableOxygenSurgeEvents);
writeHypoxicBurdenWorkbookSheets(OutputXlsx,HypoxicBurden);
fprintf('[Stats %s] Writing grouped metric sheets...\n',char(datetime('now','Format','HH:mm:ss')));
writeStatsMetricWorkbookSheets(OutputXlsx,ExportReady);
if isfield(CoreData,'HypoxicEventSpecificMetrics')
    fprintf('[Stats %s] Exporting event-specific hypoxic metrics...\n',char(datetime('now','Format','HH:mm:ss')));
    EventSpecificExportInfo = exportHypoxicEventSpecificMetrics( ...
        StatsOutputFolderPath,CoreData.HypoxicEventSpecificMetrics);
else
    EventSpecificExportInfo = struct('OutputXlsx','','DataMat','');
end

StatsWorkbookOptions = createStatsWorkbookOptions(IsBLI,BLIWorkbookData);
fprintf('[Stats %s] Writing trace/event-snippet workbook sheets...\n',char(datetime('now','Format','HH:mm:ss')));
writeStatsAnalysisWorkbookOutputs(OutputXlsx,CoreData.ExportTraces,EventSnippetTables, ...
    EventSnippetSheetNames,IsBLI,StatsWorkbookOptions);
fprintf('[Stats %s] Finished workbook export: %s\n',char(datetime('now','Format','HH:mm:ss')),OutputXlsx);

ExportInfo = struct();
ExportInfo.OutputXlsx = OutputXlsx;
ExportInfo.DataOutputMat = fullfile(StatsOutputFolderPath,'DataOutput.mat');
ExportInfo.EventSpecificOutputXlsx = EventSpecificExportInfo.OutputXlsx;
ExportInfo.EventSpecificDataMat = EventSpecificExportInfo.DataMat;
ExportInfo.HypoxicBurden = HypoxicBurden;
ExportInfo.AnalysisManifest = writeOxygenAnalysisManifest(ExportInfo);

end
