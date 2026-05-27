function FigureResult = runOxygenSummaryFigures(varargin)
%RUNOXYGENSUMMARYFIGURES Create first-pass summary figures from stats output.

setupOxygenDynamicsPath();

StatsInput = [];
if ~isempty(varargin) && ~isParameterName(varargin{1})
    StatsInput = varargin{1};
    varargin = varargin(2:end);
end

Parser = inputParser;
Parser.addParameter('outputFolder','',@(Value) ischar(Value) || isstring(Value));
Parser.parse(varargin{:});

[DataOutputMat,DefaultOutputFolder] = resolveStatsFigureInput(StatsInput);
OutputFolder = char(Parser.Results.outputFolder);
if isempty(OutputFolder)
    OutputFolder = DefaultOutputFolder;
end
mkdirIfMissing(OutputFolder);

Data = load(DataOutputMat);
if ~isfield(Data,'Table_OxygenSinks_OutCombo') || isempty(Data.Table_OxygenSinks_OutCombo)
    error('No Table_OxygenSinks_OutCombo table found in %s.',DataOutputMat);
end

SinkTable = Data.Table_OxygenSinks_OutCombo;
MetricSpecs = createSummaryMetricSpecs(SinkTable);
FigureFiles = cell(0,1);
SummaryRows = cell(0,1);
FigureManifestRows = cell(0,1);

for MetricIdx = 1:numel(MetricSpecs)
    Spec = MetricSpecs(MetricIdx);
    [FigureFile,SummaryTable] = writeMetricSummaryFigure(SinkTable,Spec,OutputFolder);
    FigureFiles{end+1,1} = FigureFile; %#ok<AGROW>
    SummaryRows{end+1,1} = SummaryTable; %#ok<AGROW>
    FigureManifestRows{end+1,1} = createFigureManifestRow("SinkSummary",Spec,FigureFile); %#ok<AGROW>
end

[BurdenFigureFiles,BurdenSummaryRows,BurdenManifestRows] = writeHypoxicBurdenSummaryFigures(Data,OutputFolder);
FigureFiles = [FigureFiles; BurdenFigureFiles];
SummaryRows = [SummaryRows; BurdenSummaryRows];
FigureManifestRows = [FigureManifestRows; BurdenManifestRows];

[TraceFigureFiles,TraceSummaryRows,TraceManifestRows] = writeNormalizedSinkTraceSummaryFigures(Data,OutputFolder);
FigureFiles = [FigureFiles; TraceFigureFiles];
SummaryRows = [SummaryRows; TraceSummaryRows];
FigureManifestRows = [FigureManifestRows; TraceManifestRows];

if isempty(SummaryRows)
    MetricSummary = table();
else
    SummaryRows = normalizeSummaryRows(SummaryRows);
    MetricSummary = vertcat(SummaryRows{:});
end

SummaryXlsx = fullfile(OutputFolder,'OxygenSummaryFigureMetrics.xlsx');
if ~isempty(MetricSummary)
    writetable(MetricSummary,SummaryXlsx,'Sheet','MetricSummary');
end
if isempty(FigureManifestRows)
    FigureManifest = table();
else
    FigureManifest = vertcat(FigureManifestRows{:});
    writetable(FigureManifest,SummaryXlsx,'Sheet','FigureManifest');
end

FigureResult = struct();
FigureResult.DataOutputMat = DataOutputMat;
FigureResult.OutputFolder = OutputFolder;
FigureResult.FigureFiles = FigureFiles;
FigureResult.FigureManifest = FigureManifest;
FigureResult.MetricSummary = MetricSummary;
FigureResult.SummaryXlsx = SummaryXlsx;

fprintf('Summary figures saved to:\n%s\n',OutputFolder);

end

function tf = isParameterName(Value)

tf = (ischar(Value) || isstring(Value)) && any(strcmpi(char(Value),{'outputFolder'}));

end

function SummaryRows = normalizeSummaryRows(SummaryRows)

AllVariables = strings(0,1);
for RowIdx = 1:numel(SummaryRows)
    AllVariables = union(AllVariables,string(SummaryRows{RowIdx}.Properties.VariableNames),'stable');
end

for RowIdx = 1:numel(SummaryRows)
    SummaryRows{RowIdx} = addMissingSummaryVariables(SummaryRows{RowIdx},AllVariables);
end

end

function SummaryTable = addMissingSummaryVariables(SummaryTable,AllVariables)

NumRows = height(SummaryTable);
for VarIdx = 1:numel(AllVariables)
    VarName = char(AllVariables(VarIdx));
    if ismember(VarName,SummaryTable.Properties.VariableNames)
        continue
    end
    switch VarName
        case {'Metric','Group','TimeAxis'}
            SummaryTable.(VarName) = strings(NumRows,1);
        otherwise
            SummaryTable.(VarName) = nan(NumRows,1);
    end
end
SummaryTable = SummaryTable(:,cellstr(AllVariables));

end

function [DataOutputMat,DefaultOutputFolder] = resolveStatsFigureInput(statsInput)

if nargin<1 || isempty(statsInput)
    StatsFolder = getlatestfile(fullfile(pwd,'Stats_Runs'),'folder',[],'Stats_Output');
    DataOutputMat = fullfile(StatsFolder,'DataOutput.mat');
    DefaultOutputFolder = fullfile(fileparts(StatsFolder),strrep(getFileNameOnly(StatsFolder),'Stats_Output','Figures_Output'));
    return
end

if isstruct(statsInput)
    if isfield(statsInput,'DataOutputMat')
        DataOutputMat = statsInput.DataOutputMat;
    elseif isfield(statsInput,'OutputFolders') && isfield(statsInput.OutputFolders,'Stats')
        DataOutputMat = fullfile(statsInput.OutputFolders.Stats,'DataOutput.mat');
    else
        error('Stats result struct must contain DataOutputMat or OutputFolders.Stats.');
    end
    if isfield(statsInput,'OutputFolders') && isfield(statsInput.OutputFolders,'Figures')
        DefaultOutputFolder = statsInput.OutputFolders.Figures;
    else
        DefaultOutputFolder = fullfile(fileparts(DataOutputMat),'Summary_Figures');
    end
    return
end

statsInput = char(statsInput);
if isfolder(statsInput)
    DataOutputMat = fullfile(statsInput,'DataOutput.mat');
    DefaultOutputFolder = fullfile(statsInput,'Summary_Figures');
else
    DataOutputMat = statsInput;
    DefaultOutputFolder = fullfile(fileparts(DataOutputMat),'Summary_Figures');
end

if ~isfile(DataOutputMat)
    error('DataOutput.mat not found: %s',DataOutputMat);
end

end

function Name = getFileNameOnly(folderPath)

[~,Name] = fileparts(folderPath);

end

function MetricSpecs = createSummaryMetricSpecs(SinkTable)

CandidateSpecs = struct( ...
    'Variable',{'MeanOxySinkEvent_NormAmp','MeanOxySinkEvent_Duration','NumOxySinkEvents_Norm','MeanOxySinkArea_um'}, ...
    'Label',{'Mean sink event normalized amplitude','Mean sink event duration','Normalized sink event count','Mean sink area'}, ...
    'FileStem',{'MeanOxySinkEvent_NormAmp','MeanOxySinkEvent_Duration','NumOxySinkEvents_Norm','MeanOxySinkArea_um'});

Keep = ismember({CandidateSpecs.Variable},SinkTable.Properties.VariableNames);
MetricSpecs = CandidateSpecs(Keep);
if isempty(MetricSpecs)
    error('No supported summary metrics were found in Table_OxygenSinks_OutCombo.');
end

end

function [FigurePng,SummaryTable] = writeMetricSummaryFigure(SinkTable,Spec,OutputFolder)

Values = tableColumnToNumeric(SinkTable.(Spec.Variable));
GroupLabels = createSummaryGroupLabels(SinkTable);
ValidRows = isfinite(Values) & GroupLabels~="";
Values = Values(ValidRows);
GroupLabels = GroupLabels(ValidRows);

if isempty(Values)
    error('No finite values available for metric %s.',Spec.Variable);
end

[GroupNames,~,GroupIdx] = unique(GroupLabels,'stable');
SummaryTable = summarizeMetricGroups(Spec.Variable,GroupNames,GroupIdx,Values);

Fig = figure('Visible','off','Color','w','Position',[100 100 960 540]);
AxesHandle = axes(Fig);
hold(AxesHandle,'on');
for GroupI = 1:numel(GroupNames)
    ThisGroup = Values(GroupIdx==GroupI);
    X = GroupI + linspace(-0.12,0.12,max(numel(ThisGroup),1))';
    scatter(AxesHandle,X,ThisGroup,36,'filled','MarkerFaceAlpha',0.55);
    plot(AxesHandle,[GroupI-0.25 GroupI+0.25],mean(ThisGroup,'omitnan')*[1 1], ...
        'k-','LineWidth',2);
end
hold(AxesHandle,'off');
AxesHandle.XTick = 1:numel(GroupNames);
AxesHandle.XTickLabel = cellstr(GroupNames);
AxesHandle.XTickLabelRotation = 25;
ylabel(AxesHandle,Spec.Label,'Interpreter','none');
title(AxesHandle,Spec.Label,'Interpreter','none');
box(AxesHandle,'off');
grid(AxesHandle,'on');

FigurePng = fullfile(OutputFolder,[Spec.FileStem,'.png']);
FigureFig = fullfile(OutputFolder,[Spec.FileStem,'.fig']);
saveas(Fig,FigurePng);
savefig(Fig,FigureFig);
close(Fig);

end

function [FigureFiles,SummaryRows,FigureManifestRows] = writeHypoxicBurdenSummaryFigures(Data,OutputFolder)

FigureFiles = cell(0,1);
SummaryRows = cell(0,1);
FigureManifestRows = cell(0,1);
if ~isfield(Data,'HypoxicBurden') || ~isstruct(Data.HypoxicBurden)
    return
end

if isfield(Data.HypoxicBurden,'EventTable') && istable(Data.HypoxicBurden.EventTable)
    EventSpecs = struct( ...
        'Variable',{'PerEventBurdenContribution','BurdenAmplitudePercent','BurdenArea_um2','BurdenDuration_sec'}, ...
        'Label',{'Per-event hypoxic burden contribution','Hypoxic burden event amplitude', ...
        'Hypoxic burden event area','Hypoxic burden event duration'}, ...
        'FileStem',{'HypoxicBurden_PerEventContribution','HypoxicBurden_EventAmplitude', ...
        'HypoxicBurden_EventArea','HypoxicBurden_EventDuration'});
    [FigureFiles,SummaryRows,FigureManifestRows] = appendTableMetricFigures(FigureFiles,SummaryRows, ...
        FigureManifestRows,Data.HypoxicBurden.EventTable,EventSpecs,OutputFolder,"HypoxicBurdenEvent");
    [FigureFiles,SummaryRows,FigureManifestRows] = appendHypoxicBurdenEventScatterFigure( ...
        FigureFiles,SummaryRows,FigureManifestRows,Data.HypoxicBurden.EventTable,OutputFolder);
end

if isfield(Data.HypoxicBurden,'RecordingTable') && istable(Data.HypoxicBurden.RecordingTable)
    RecordingSpecs = struct( ...
        'Variable',{'HypoxicBurden'}, ...
        'Label',{'Recording hypoxic burden'}, ...
        'FileStem',{'HypoxicBurden_ByRecording'});
    [FigureFiles,SummaryRows,FigureManifestRows] = appendTableMetricFigures(FigureFiles,SummaryRows, ...
        FigureManifestRows,Data.HypoxicBurden.RecordingTable,RecordingSpecs,OutputFolder, ...
        "HypoxicBurdenRecording");
end

if isfield(Data.HypoxicBurden,'GroupSummaryTable') && istable(Data.HypoxicBurden.GroupSummaryTable)
    GroupSpecs = struct( ...
        'Variable',{'HypoxicBurden_Mean','HypoxicBurden_Sum','EventSpecificAreaMatchRate'}, ...
        'Label',{'Grouped mean hypoxic burden','Grouped summed hypoxic burden', ...
        'Grouped event-specific area match rate'}, ...
        'FileStem',{'HypoxicBurden_GroupMean','HypoxicBurden_GroupSum', ...
        'HypoxicBurden_GroupAreaMatchRate'});
    [FigureFiles,SummaryRows,FigureManifestRows] = appendTableMetricFigures(FigureFiles,SummaryRows, ...
        FigureManifestRows,Data.HypoxicBurden.GroupSummaryTable,GroupSpecs,OutputFolder, ...
        "HypoxicBurdenGroupSummary");
end

end

function [FigureFiles,SummaryRows,FigureManifestRows] = appendHypoxicBurdenEventScatterFigure( ...
    FigureFiles,SummaryRows,FigureManifestRows,EventTable,OutputFolder)

RequiredColumns = {'BurdenArea_um2','BurdenAmplitudePercent','BurdenDuration_sec', ...
    'PerEventBurdenContribution'};
if ~all(ismember(RequiredColumns,EventTable.Properties.VariableNames))
    return
end

Area = tableColumnToNumeric(EventTable.BurdenArea_um2);
Amplitude = tableColumnToNumeric(EventTable.BurdenAmplitudePercent);
Duration = tableColumnToNumeric(EventTable.BurdenDuration_sec);
Contribution = tableColumnToNumeric(EventTable.PerEventBurdenContribution);
GroupLabels = createSummaryGroupLabels(EventTable);
ValidRows = isfinite(Area) & isfinite(Amplitude) & isfinite(Duration) & ...
    isfinite(Contribution) & GroupLabels~="";
Area = Area(ValidRows);
Amplitude = Amplitude(ValidRows);
Duration = Duration(ValidRows);
Contribution = Contribution(ValidRows);
GroupLabels = GroupLabels(ValidRows);
if isempty(Area)
    return
end

Spec = struct('Variable','BurdenAreaAmplitudeDurationContribution', ...
    'Label','Event area vs amplitude, sized by duration, colored by burden contribution', ...
    'FileStem','HypoxicBurden_AreaAmplitudeDuration');
FigureFile = writeHypoxicBurdenEventScatter(Area,Amplitude,Duration,Contribution, ...
    GroupLabels,Spec,OutputFolder);
SummaryTable = summarizeEventScatter(Area,Amplitude,Duration,Contribution);

FigureFiles{end+1,1} = FigureFile;
SummaryRows{end+1,1} = SummaryTable;
FigureManifestRows{end+1,1} = createFigureManifestRow("HypoxicBurdenEventRelationship", ...
    Spec,FigureFile);

end

function FigurePng = writeHypoxicBurdenEventScatter(Area,Amplitude,Duration,Contribution, ...
    GroupLabels,Spec,OutputFolder)

[GroupNames,~,GroupIdx] = unique(GroupLabels,'stable');
MarkerSizes = scaleMarkerSizes(Duration,30,150);

Fig = figure('Visible','off','Color','w','Position',[100 100 980 620]);
AxesHandle = axes(Fig);
hold(AxesHandle,'on');
for GroupI = 1:numel(GroupNames)
    Mask = GroupIdx==GroupI;
    scatter(AxesHandle,Area(Mask),Amplitude(Mask),MarkerSizes(Mask),Contribution(Mask), ...
        'filled','MarkerFaceAlpha',0.65,'DisplayName',char(GroupNames(GroupI)));
end
hold(AxesHandle,'off');
ColorbarHandle = colorbar(AxesHandle);
ColorbarHandle.Label.String = 'Per-event burden contribution';
xlabel(AxesHandle,'Event area (um^2)','Interpreter','none');
ylabel(AxesHandle,'Amplitude drop (%)','Interpreter','none');
title(AxesHandle,Spec.Label,'Interpreter','none');
legend(AxesHandle,'Location','bestoutside','Interpreter','none');
box(AxesHandle,'off');
grid(AxesHandle,'on');

FigurePng = fullfile(OutputFolder,[Spec.FileStem,'.png']);
FigureFig = fullfile(OutputFolder,[Spec.FileStem,'.fig']);
saveas(Fig,FigurePng);
savefig(Fig,FigureFig);
close(Fig);

end

function MarkerSizes = scaleMarkerSizes(Values,MinSize,MaxSize)

Values = double(Values(:));
FiniteMask = isfinite(Values);
MarkerSizes = repmat((MinSize+MaxSize)/2,size(Values));
if ~any(FiniteMask)
    return
end
FiniteValues = Values(FiniteMask);
ValueRange = max(FiniteValues)-min(FiniteValues);
if ValueRange==0
    return
end
MarkerSizes(FiniteMask) = MinSize + ...
    (FiniteValues-min(FiniteValues))./ValueRange.*(MaxSize-MinSize);

end

function SummaryTable = summarizeEventScatter(Area,Amplitude,Duration,Contribution)

Metric = ["BurdenArea_vs_BurdenAmplitude_Correlation"; ...
    "BurdenDuration_vs_PerEventContribution_Correlation"];
Group = ["All"; "All"];
N = [numel(Area); numel(Duration)];
Mean = [safeCorr(Area,Amplitude); safeCorr(Duration,Contribution)];
SEM = [NaN; NaN];
SummaryTable = table(Metric,Group,N,Mean,SEM);

end

function [FigureFiles,SummaryRows,FigureManifestRows] = writeNormalizedSinkTraceSummaryFigures(Data,OutputFolder)

FigureFiles = cell(0,1);
SummaryRows = cell(0,1);
FigureManifestRows = cell(0,1);
if ~isfield(Data,'NumOngoingOxysinksPerMm2') || isempty(Data.NumOngoingOxysinksPerMm2)
    return
end

TraceSummaryTable = createNormalizedSinkTraceSummaryTable(Data.NumOngoingOxysinksPerMm2);
if isempty(TraceSummaryTable)
    return
end

TraceSpecs = struct( ...
    'Variable',{'MeanOxySinksPer1mm2','MaxOxySinksPer1mm2','SumOxySinksPer1mm2'}, ...
    'Label',{'Mean ongoing oxygen sinks per 1 mm2', ...
    'Maximum ongoing oxygen sinks per 1 mm2', ...
    'Summed ongoing oxygen sinks per 1 mm2'}, ...
    'FileStem',{'OxySinksPer1mm2_Mean','OxySinksPer1mm2_Max','OxySinksPer1mm2_Sum'});
[FigureFiles,SummaryRows,FigureManifestRows] = appendTableMetricFigures(FigureFiles,SummaryRows, ...
    FigureManifestRows,TraceSummaryTable,TraceSpecs,OutputFolder,"AreaNormalizedSinkCount");

[TraceFigureFile,TraceTimeSummary] = writeNormalizedSinkTraceTimeCourseFigure( ...
    Data.NumOngoingOxysinksPerMm2,OutputFolder,Data);
if ~isempty(TraceFigureFile)
    FigureFiles{end+1,1} = TraceFigureFile;
    SummaryRows{end+1,1} = TraceTimeSummary;
    Spec = struct('Variable','NumOngoingOxysinksPerMm2_TimeCourse', ...
        'Label','OxySinksPer1mm2 group time course', ...
        'FileStem','OxySinksPer1mm2_TimeCourse');
    FigureManifestRows{end+1,1} = createFigureManifestRow("AreaNormalizedSinkCountTimeCourse", ...
        Spec,TraceFigureFile);
end

end

function [FigurePng,SummaryTable] = writeNormalizedSinkTraceTimeCourseFigure(TraceCells,OutputFolder,Data)

FigurePng = '';
SummaryTable = table();
[TraceMatrix,GroupLabels,SampleFs] = extractTraceMatrixAndGroups(TraceCells,Data);
if isempty(TraceMatrix)
    return
end

[GroupNames,~,GroupIdx] = unique(GroupLabels,'stable');
[Time,TimeLabel] = createTraceTimeAxis(size(TraceMatrix,2),SampleFs);
Fig = figure('Visible','off','Color','w','Position',[100 100 1040 620]);
AxesHandle = axes(Fig);
hold(AxesHandle,'on');
ColorOrder = lines(max(numel(GroupNames),1));
for GroupI = 1:numel(GroupNames)
    GroupTrace = TraceMatrix(GroupIdx==GroupI,:);
    MeanTrace = mean(GroupTrace,1,'omitnan')';
    SemTrace = std(GroupTrace,0,1,'omitnan')' ./ sqrt(max(sum(isfinite(GroupTrace),1)',1));
    Color = ColorOrder(GroupI,:);
    fill(AxesHandle,[Time; flipud(Time)],[MeanTrace-SemTrace; flipud(MeanTrace+SemTrace)], ...
        Color,'FaceAlpha',0.18,'EdgeColor','none','HandleVisibility','off');
    plot(AxesHandle,Time,MeanTrace,'Color',Color,'LineWidth',2, ...
        'DisplayName',char(GroupNames(GroupI)));
end
hold(AxesHandle,'off');
xlabel(AxesHandle,TimeLabel,'Interpreter','none');
ylabel(AxesHandle,'Ongoing oxygen sinks per 1 mm2','Interpreter','none');
title(AxesHandle,'OxySinksPer1mm2 group time course','Interpreter','none');
legend(AxesHandle,'Location','bestoutside','Interpreter','none');
box(AxesHandle,'off');
grid(AxesHandle,'on');

FigurePng = fullfile(OutputFolder,'OxySinksPer1mm2_TimeCourse.png');
FigureFig = fullfile(OutputFolder,'OxySinksPer1mm2_TimeCourse.fig');
saveas(Fig,FigurePng);
savefig(Fig,FigureFig);
close(Fig);

SummaryTable = summarizeTraceTimeCourseGroups(GroupNames,GroupIdx,TraceMatrix,SampleFs,TimeLabel);

end

function [TraceMatrix,GroupLabels,SampleFs] = extractTraceMatrixAndGroups(TraceCells,Data)

TraceMatrix = [];
GroupLabels = strings(0,1);
SampleFs = NaN;
if ~iscell(TraceCells) || size(TraceCells,2)<6
    return
end

TraceList = cell(size(TraceCells,1),1);
TraceLengths = zeros(size(TraceCells,1),1);
for RowIdx = 1:size(TraceCells,1)
    Trace = traceCellToNumeric(TraceCells{RowIdx,6});
    TraceList{RowIdx} = Trace(:)';
    TraceLengths(RowIdx) = numel(Trace);
end

MaxLength = max(TraceLengths);
if MaxLength==0
    return
end

TraceMatrix = nan(size(TraceCells,1),MaxLength);
for RowIdx = 1:size(TraceCells,1)
    Trace = TraceList{RowIdx};
    TraceMatrix(RowIdx,1:numel(Trace)) = Trace;
end

GroupLabels = createTraceGroupLabels(TraceCells);
ValidRows = any(isfinite(TraceMatrix),2) & GroupLabels~="";
TraceMatrix = TraceMatrix(ValidRows,:);
GroupLabels = GroupLabels(ValidRows);
SampleFs = getStatsFigureSampleFrequency(Data,ValidRows);

end

function SampleFs = getStatsFigureSampleFrequency(Data,ValidRows)

SampleFs = NaN;
if ~isfield(Data,'StatsInfo') || ~isstruct(Data.StatsInfo) || ~isfield(Data.StatsInfo,'SampleFs')
    return
end

Values = sampleFsToNumeric(Data.StatsInfo.SampleFs);
if numel(Values)==numel(ValidRows)
    Values = Values(ValidRows);
end
Values = Values(isfinite(Values) & Values>0);
if isempty(Values)
    return
end

if max(Values)-min(Values) > max(eps(max(Values)),1e-9)
    warning('OxygenDynamics:SummaryFigureMixedSampleFs', ...
        'OxySinksPer1mm2 time-course figure has mixed SampleF values; using the median sample frequency.');
end
SampleFs = median(Values,'omitnan');

end

function Values = sampleFsToNumeric(SampleFs)

if isnumeric(SampleFs) || islogical(SampleFs)
    Values = double(SampleFs(:));
elseif iscell(SampleFs)
    Values = nan(numel(SampleFs),1);
    for Idx = 1:numel(SampleFs)
        Values(Idx) = scalarToDouble(SampleFs{Idx});
    end
else
    Values = str2double(string(SampleFs(:)));
end

end

function Value = scalarToDouble(InputValue)

if isnumeric(InputValue) || islogical(InputValue)
    Value = double(InputValue(1));
else
    Parsed = str2double(string(InputValue));
    Value = Parsed(1);
end

end

function [Time,TimeLabel] = createTraceTimeAxis(NumFrames,SampleFs)

if isfinite(SampleFs) && SampleFs>0
    TimeSec = ((0:NumFrames-1)' ./ SampleFs);
    if max(TimeSec)>180
        Time = TimeSec ./ 60;
        TimeLabel = 'Time (min)';
    else
        Time = TimeSec;
        TimeLabel = 'Time (s)';
    end
else
    Time = (1:NumFrames)';
    TimeLabel = 'Frame';
end

end

function GroupLabels = createTraceGroupLabels(TraceCells)

NumRows = size(TraceCells,1);
Parts = strings(NumRows,0);
ColumnIdx = [4 3];
for Idx = ColumnIdx
    if size(TraceCells,2)>=Idx
        Parts(:,end+1) = string(TraceCells(:,Idx)); %#ok<AGROW>
    end
end

if isempty(Parts)
    GroupLabels = repmat("All",NumRows,1);
else
    GroupLabels = Parts(:,1);
    for PartIdx = 2:size(Parts,2)
        GroupLabels = GroupLabels + " | " + Parts(:,PartIdx);
    end
end

end

function SummaryTable = summarizeTraceTimeCourseGroups(GroupNames,GroupIdx,TraceMatrix,SampleFs,TimeLabel)

Metric = repmat("NumOngoingOxysinksPerMm2_TimeCourseMean",numel(GroupNames),1);
Group = GroupNames(:);
N = zeros(numel(GroupNames),1);
Mean = nan(numel(GroupNames),1);
SEM = nan(numel(GroupNames),1);

for GroupI = 1:numel(GroupNames)
    GroupTrace = TraceMatrix(GroupIdx==GroupI,:);
    PerRecordingMean = mean(GroupTrace,2,'omitnan');
    N(GroupI) = sum(isfinite(PerRecordingMean));
    Mean(GroupI) = mean(PerRecordingMean,'omitnan');
    SEM(GroupI) = std(PerRecordingMean,'omitnan') ./ sqrt(max(N(GroupI),1));
end

SummaryTable = table(Metric,Group,N,Mean,SEM);
SummaryTable.SampleF = repmat(SampleFs,height(SummaryTable),1);
SummaryTable.TimeAxis = repmat(string(TimeLabel),height(SummaryTable),1);

end

function TraceSummaryTable = createNormalizedSinkTraceSummaryTable(TraceCells)

TraceSummaryTable = table();
if ~iscell(TraceCells) || size(TraceCells,2)<6
    return
end

NumRows = size(TraceCells,1);
Experiment = strings(NumRows,1);
Mouse = strings(NumRows,1);
Condition = strings(NumRows,1);
DrugID = strings(NumRows,1);
Genotype = strings(NumRows,1);
MeanOxySinksPer1mm2 = nan(NumRows,1);
MaxOxySinksPer1mm2 = nan(NumRows,1);
SumOxySinksPer1mm2 = nan(NumRows,1);

for RowIdx = 1:NumRows
    Experiment(RowIdx) = string(TraceCells{RowIdx,1});
    Mouse(RowIdx) = string(TraceCells{RowIdx,2});
    Condition(RowIdx) = string(TraceCells{RowIdx,3});
    DrugID(RowIdx) = string(TraceCells{RowIdx,4});
    Genotype(RowIdx) = string(TraceCells{RowIdx,5});
    Trace = traceCellToNumeric(TraceCells{RowIdx,6});
    MeanOxySinksPer1mm2(RowIdx) = mean(Trace,'omitnan');
    MaxOxySinksPer1mm2(RowIdx) = max(Trace,[],'omitnan');
    SumOxySinksPer1mm2(RowIdx) = sum(Trace,'omitnan');
end

TraceSummaryTable = table(Experiment,Mouse,Condition,DrugID,Genotype, ...
    MeanOxySinksPer1mm2,MaxOxySinksPer1mm2,SumOxySinksPer1mm2);

end

function Trace = traceCellToNumeric(Value)

if isnumeric(Value) || islogical(Value)
    Trace = double(Value(:));
elseif iscell(Value)
    Trace = cellfun(@safeCellMean,Value);
    Trace = Trace(:);
else
    Trace = str2double(string(Value));
    Trace = Trace(:);
end

end

function [FigureFiles,SummaryRows,FigureManifestRows] = appendTableMetricFigures(FigureFiles, ...
    SummaryRows,FigureManifestRows,TableData,Specs,OutputFolder,FigureType)

if isempty(TableData)
    return
end
Keep = ismember({Specs.Variable},TableData.Properties.VariableNames);
Specs = Specs(Keep);
for SpecIdx = 1:numel(Specs)
    [FigureFile,SummaryTable] = writeMetricSummaryFigure(TableData,Specs(SpecIdx),OutputFolder);
    FigureFiles{end+1,1} = FigureFile; %#ok<AGROW>
    SummaryRows{end+1,1} = SummaryTable; %#ok<AGROW>
    FigureManifestRows{end+1,1} = createFigureManifestRow(FigureType,Specs(SpecIdx),FigureFile); %#ok<AGROW>
end

end

function ManifestRow = createFigureManifestRow(FigureType,Spec,FigureFile)

FigureType = string(FigureType);
Metric = string(Spec.Variable);
Label = string(Spec.Label);
FileName = string(getFileNameOnly(FigureFile)) + string(extractFileExtension(FigureFile));
FilePath = string(FigureFile);
ManifestRow = table(FigureType,Metric,Label,FileName,FilePath);

end

function Ext = extractFileExtension(FilePath)

[~,~,Ext] = fileparts(FilePath);

end

function Values = tableColumnToNumeric(Column)

if isnumeric(Column) || islogical(Column)
    Values = double(Column);
elseif iscell(Column)
    Values = cellfun(@safeCellMean,Column);
else
    Values = str2double(string(Column));
end
Values = Values(:);

end

function GroupLabels = createSummaryGroupLabels(SinkTable)

NumRows = height(SinkTable);
Parts = strings(NumRows,0);
CandidateColumns = {'DrugID','Condition','PuffStim'};
for ColIdx = 1:numel(CandidateColumns)
    ColumnName = CandidateColumns{ColIdx};
    if ismember(ColumnName,SinkTable.Properties.VariableNames)
        Parts(:,end+1) = string(SinkTable.(ColumnName)); %#ok<AGROW>
    end
end

if isempty(Parts)
    GroupLabels = repmat("All",NumRows,1);
else
    GroupLabels = Parts(:,1);
    for PartIdx = 2:size(Parts,2)
        GroupLabels = GroupLabels + " | " + Parts(:,PartIdx);
    end
end

end

function SummaryTable = summarizeMetricGroups(MetricName,GroupNames,GroupIdx,Values)

Metric = repmat(string(MetricName),numel(GroupNames),1);
Group = GroupNames(:);
N = zeros(numel(GroupNames),1);
Mean = nan(numel(GroupNames),1);
SEM = nan(numel(GroupNames),1);

for GroupI = 1:numel(GroupNames)
    ThisGroup = Values(GroupIdx==GroupI);
    N(GroupI) = numel(ThisGroup);
    Mean(GroupI) = mean(ThisGroup,'omitnan');
    SEM(GroupI) = std(ThisGroup,'omitnan') ./ sqrt(max(N(GroupI),1));
end

SummaryTable = table(Metric,Group,N,Mean,SEM);

end
