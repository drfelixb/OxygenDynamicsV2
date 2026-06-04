function HypoxicBurden = updateHypoxicBurdenStatsOutput(statsOutputFolder)
%UPDATEHYPOXICBURDENSTATSOUTPUT Recompute hypoxic burden for an existing stats run.
%
% HypoxicBurden = updateHypoxicBurdenStatsOutput()
% HypoxicBurden = updateHypoxicBurdenStatsOutput(statsOutputFolder)
%
% This utility rewrites the HypoxicBurden_* sheets in an existing
% FilteredData_*.xlsx workbook using true event-specific Area_um from
% HypoxicEventSpecificMetrics4LME.mat when available.

setupOxygenDynamicsPath();

if nargin<1 || isempty(statsOutputFolder)
    statsOutputFolder = getlatestfile(fullfile(pwd,'Stats_Runs'),'folder',[],'Stats_Output');
end

if isempty(statsOutputFolder) || ~isfolder(statsOutputFolder)
    error('Stats output folder not found: %s',statsOutputFolder);
end

SinkEventTablePath = fullfile(statsOutputFolder,'SinkEventTable.mat');
EventSpecificPath = fullfile(statsOutputFolder,'HypoxicEventSpecificMetrics4LME.mat');
DataOutputPath = fullfile(statsOutputFolder,'DataOutput.mat');
WorkbookPath = findStatsWorkbook(statsOutputFolder);

if ~isfile(SinkEventTablePath)
    error('SinkEventTable.mat not found in stats output folder: %s',statsOutputFolder);
end
if ~isfile(WorkbookPath)
    error('FilteredData_*.xlsx workbook not found in stats output folder: %s',statsOutputFolder);
end

SinkEventData = load(SinkEventTablePath);
if ~isfield(SinkEventData,'Table_OxygenSinkEvents_OutCombo')
    error('SinkEventTable.mat does not contain Table_OxygenSinkEvents_OutCombo.');
end
TableOxygenSinkEvents = SinkEventData.Table_OxygenSinkEvents_OutCombo;

EventSpecificMetrics = table();
if isfile(EventSpecificPath)
    EventSpecificData = load(EventSpecificPath);
    if isfield(EventSpecificData,'Eventspecificmetrics')
        EventSpecificMetrics = EventSpecificData.Eventspecificmetrics;
    elseif isfield(EventSpecificData,'EventSpecificMetrics')
        EventSpecificMetrics = EventSpecificData.EventSpecificMetrics;
    end
end

TableOxygenSinks = table();
if isfile(DataOutputPath)
    DataOutput = load(DataOutputPath,'Table_OxygenSinks_OutCombo');
    if isfield(DataOutput,'Table_OxygenSinks_OutCombo')
        TableOxygenSinks = DataOutput.Table_OxygenSinks_OutCombo;
    end
end

HypoxicBurden = createHypoxicBurdenMetrics(TableOxygenSinkEvents,EventSpecificMetrics,TableOxygenSinks);
try
    writeHypoxicBurdenWorkbookSheets(WorkbookPath,HypoxicBurden);
    WrittenWorkbookPath = WorkbookPath;
catch ME
    WrittenWorkbookPath = fullfile(statsOutputFolder,'HypoxicBurden_Recomputed.xlsx');
    warning('OxygenDynamics:HypoxicBurdenWorkbookLocked', ...
        ['Could not update the main stats workbook, likely because it is open or locked. ', ...
        'Writing hypoxic burden sheets to %s instead. Original error: %s'], ...
        WrittenWorkbookPath,ME.message);
    if isfile(WrittenWorkbookPath)
        delete(WrittenWorkbookPath);
    end
    writeHypoxicBurdenWorkbookSheets(WrittenWorkbookPath,HypoxicBurden);
end

if isfile(DataOutputPath)
    save(DataOutputPath,'HypoxicBurden','-append');
end

fprintf('Hypoxic burden sheets updated:\n%s\n',WrittenWorkbookPath);

end

function WorkbookPath = findStatsWorkbook(statsOutputFolder)

Workbooks = dir(fullfile(statsOutputFolder,'FilteredData_*.xlsx'));
if isempty(Workbooks)
    WorkbookPath = '';
    return
end
[~,NewestIdx] = max([Workbooks.datenum]);
WorkbookPath = fullfile(Workbooks(NewestIdx).folder,Workbooks(NewestIdx).name);

end
