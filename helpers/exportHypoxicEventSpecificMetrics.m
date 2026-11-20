function ExportInfo = exportHypoxicEventSpecificMetrics(StatsOutputFolderPath,EventSpecificMetrics)
%EXPORTHYPOXICEVENTSPECIFICMETRICS Save grouped event-based sink metrics.

ExportInfo = struct('OutputXlsx','','DataMat','');
if isempty(EventSpecificMetrics)
    return
end

EventSpecificMetrics.MetricBasis = repmat({'EventBased'},height(EventSpecificMetrics),1);
FiltersOxySinksMetrics = createHypoxicEventSpecificFilters(EventSpecificMetrics);
[ExportReady,SheetNames] = createHypoxicEventSpecificWorkbookData(EventSpecificMetrics,FiltersOxySinksMetrics);

ExportInfo.DataMat = fullfile(StatsOutputFolderPath,'HypoxicEventSpecificMetrics4LME.mat');
Eventspecificmetrics = EventSpecificMetrics;
save(ExportInfo.DataMat,'FiltersOxySinksMetrics','Eventspecificmetrics');

ExportInfo.OutputXlsx = fullfile(StatsOutputFolderPath,'SortedSinkEventMetrics.xlsx');
writeHypoxicEventSpecificWorkbook(ExportInfo.OutputXlsx,EventSpecificMetrics,ExportReady,SheetNames);
end

function Filters = createHypoxicEventSpecificFilters(EventSpecificMetrics)

Mouse = ensureTextCell(EventSpecificMetrics.Mouse);
DrugID = ensureTextCell(EventSpecificMetrics.DrugID);
Condition = cellstr(string(EventSpecificMetrics.Condition)+" ["+string(EventSpecificMetrics.Genotype)+"; "+string(EventSpecificMetrics.Promoter)+"]");
PuffStim = EventSpecificMetrics.PuffStim;
if iscell(PuffStim)
    PuffStim = cell2mat(PuffStim);
end

Filters = createStatsGroupFilters(DrugID,Condition,PuffStim,uniqueStrCell(DrugID), ...
    uniqueStrCell(Condition),unique(PuffStim),'mouseValues',Mouse);
end

function [ExportReady,SheetNames] = createHypoxicEventSpecificWorkbookData(EventSpecificMetrics,Filters)

MetricNames = {'NormOxySinkAmp','Start','Duration','Size_modulation','Area_um','Area_norm', ...
    'FilledArea_um','FilledArea_norm','Circularity','Perimeter_um','Diameter_um'};
SheetNames = {'EventBased_NormAmp','EventBased_Start','EventBased_Duration', ...
    'EventBased_SizeMod','EventBased_Area_um','EventBased_AreaNorm', ...
    'EventBased_FilledArea_um','EventBased_FilledAreaNorm','EventBased_Circularity', ...
    'EventBased_Perimeter_um','EventBased_Diameter_um'};

[FilteredData,FilteredMice] = filterStatsMetricData(ensureTextCell(EventSpecificMetrics.Mouse), ...
    EventSpecificMetrics,MetricNames,Filters);
ExportReady = createStatsMetricExportTables(FilteredData,FilteredMice,Filters);
end

function writeHypoxicEventSpecificWorkbook(OutputXlsx,EventSpecificMetrics,ExportReady,SheetNames)

BasisTable = table({'SortedSinkEventMetrics.xlsx'; 'EventBased_* sheets'; 'EventBased_AllEvents'}, ...
    {'Event-based'; 'Event-based grouped by drug, condition, stimulation, and mouse'; ...
    'One row per hypoxic event with event-specific morphology'}, ...
    'VariableNames',{'WorkbookItem','MetricBasis'});
writetable(BasisTable,OutputXlsx,'Sheet','MetricBasis');
writetable(EventSpecificMetrics,OutputXlsx,'Sheet','EventBased_AllEvents');

for SheetIdx = 1:numel(SheetNames)
    writetable(ExportReady{SheetIdx},OutputXlsx,'Sheet',SheetNames{SheetIdx},'WriteVariableNames',0);
end
end

function TextCell = ensureTextCell(Value)

if iscell(Value)
    TextCell = Value;
elseif isstring(Value)
    TextCell = cellstr(Value);
elseif isnumeric(Value) || islogical(Value)
    TextCell = cellstr(string(Value));
else
    TextCell = cellstr(Value);
end
end
