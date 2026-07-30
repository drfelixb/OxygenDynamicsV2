function ManifestPath = writeOxygenAnalysisManifest(StatsInput,varargin)
%WRITEOXYGENANALYSISMANIFEST Write a compact Markdown stats-run report.
%
% ManifestPath = writeOxygenAnalysisManifest(StatsInput)
% ManifestPath = writeOxygenAnalysisManifest(StatsInput,'outputPath',ManifestPath)
% ManifestPath = writeOxygenAnalysisManifest(StatsInput,'figuresFolder',FolderPath)

setupOxygenDynamicsPath();
VersionInfo = getOxygenPipelineVersion();

Options = parseManifestOptions(varargin{:});
[StatsFolder,DataOutputMat,WorkbookPath] = resolveManifestInputs(StatsInput);
if isempty(Options.outputPath) && ~isempty(Options.manifestPath)
    Options.outputPath = Options.manifestPath;
end
if isempty(Options.outputPath)
    ManifestPath = fullfile(StatsFolder,'AnalysisManifest.md');
else
    ManifestPath = char(Options.outputPath);
end

Data = load(DataOutputMat);
StatsResult = struct('DataOutputMat',DataOutputMat);
if isfield(Data,'StatsInfo')
    StatsResult.StatsInfo = Data.StatsInfo;
else
    Data.StatsInfo = struct();
end
AcceptanceRows = buildOxygenStatsAcceptanceRows(StatsResult);
QcRows = buildOxygenStatsQcRows(StatsResult);
PreviewRows = buildOxygenStatsPreviewRows(StatsResult);
FigureManifest = readManifestFigureManifest(StatsFolder,Data,Options.figuresFolder);

Lines = strings(0,1);
Lines(end+1) = "# Oxygen Dynamics Analysis Manifest";
Lines(end+1) = "";
Lines(end+1) = sprintf("Pipeline version: `v%s`",VersionInfo.Version);
Lines(end+1) = sprintf("Pipeline build: `%s`",VersionInfo.BuildTimestamp);
Lines(end+1) = sprintf("Generated: %s",char(datetime('now','Format','yyyy-MM-dd HH:mm:ss')));
Lines(end+1) = sprintf("Stats output: `%s`",StatsFolder);
Lines(end+1) = sprintf("Stats workbook: `%s`",WorkbookPath);
Lines(end+1) = sprintf("Data output: `%s`",DataOutputMat);
if ~isempty(Options.figuresFolder)
    Lines(end+1) = sprintf("Figures folder: `%s`",char(Options.figuresFolder));
end
Lines(end+1) = "";

Lines = appendRunOverview(Lines,Data,StatsResult);
Lines = appendAcceptanceSection(Lines,AcceptanceRows);
Lines = appendQcSection(Lines,QcRows);
Lines = appendPreviewSection(Lines,PreviewRows);
Lines = appendFigureSection(Lines,FigureManifest);
Lines = appendReviewChecklist(Lines);

writeTextFile(ManifestPath,strjoin(Lines,newline));
fprintf('Analysis manifest written:\n%s\n',ManifestPath);

end

function Options = parseManifestOptions(varargin)

Options = struct('outputPath','','manifestPath','','figuresFolder','');
if mod(numel(varargin),2)~=0
    error('OxygenDynamics:AnalysisManifestOptions', ...
        'Optional arguments must be name-value pairs.');
end
for Idx = 1:2:numel(varargin)
    Name = char(varargin{Idx});
    Value = varargin{Idx+1};
    if ~isfield(Options,Name)
        error('OxygenDynamics:AnalysisManifestOptions', ...
            'Unknown analysis manifest option: %s',Name);
    end
    Options.(Name) = Value;
end

end

function [StatsFolder,DataOutputMat,WorkbookPath] = resolveManifestInputs(StatsInput)

if nargin<1 || isempty(StatsInput)
    StatsFolder = findLatestStatsOutputFolder();
    DataOutputMat = fullfile(StatsFolder,'DataOutput.mat');
elseif isstruct(StatsInput)
    if isfield(StatsInput,'DataOutputMat')
        DataOutputMat = char(StatsInput.DataOutputMat);
        StatsFolder = fileparts(DataOutputMat);
    elseif isfield(StatsInput,'OutputFolders') && isfield(StatsInput.OutputFolders,'Stats')
        StatsFolder = char(StatsInput.OutputFolders.Stats);
        DataOutputMat = fullfile(StatsFolder,'DataOutput.mat');
    else
        error('OxygenDynamics:AnalysisManifestInput', ...
            'Stats result struct must contain DataOutputMat or OutputFolders.Stats.');
    end
elseif ischar(StatsInput) || isstring(StatsInput)
    StatsPath = char(StatsInput);
    if isfolder(StatsPath)
        StatsFolder = StatsPath;
        DataOutputMat = fullfile(StatsFolder,'DataOutput.mat');
    else
        DataOutputMat = StatsPath;
        StatsFolder = fileparts(DataOutputMat);
    end
else
    error('OxygenDynamics:AnalysisManifestInput', ...
        'StatsInput must be empty, a stats result struct, a stats folder, or DataOutput.mat.');
end

if ~isfile(DataOutputMat)
    error('OxygenDynamics:AnalysisManifestDataMissing', ...
        'DataOutput.mat not found: %s',DataOutputMat);
end
WorkbookPath = findStatsWorkbookForManifest(StatsFolder);

end

function WorkbookPath = findStatsWorkbookForManifest(StatsFolder)

Workbooks = dir(fullfile(StatsFolder,'FilteredData_*.xlsx'));
if isempty(Workbooks)
    WorkbookPath = '';
    return
end
[~,Idx] = max([Workbooks.datenum]);
WorkbookPath = fullfile(Workbooks(Idx).folder,Workbooks(Idx).name);

end

function Lines = appendRunOverview(Lines,Data,StatsResult)

Lines(end+1) = "## Run Overview";
Info = StatsResult.StatsInfo;
InputCsv = getStructString(Info,'InputCsv');
MasterFolder = getStructString(Info,'Masterfolder');
if strlength(MasterFolder)==0
    MasterFolder = getStructString(Info,'MasterFolder');
end
if strlength(InputCsv)>0
    Lines(end+1) = sprintf("- Input CSV: `%s`",InputCsv);
end
if strlength(MasterFolder)>0
    Lines(end+1) = sprintf("- Dataset folder: `%s`",MasterFolder);
end
Lines(end+1) = sprintf("- Recording rows with sinks: %d",heightIfField(Data,'Table_OxygenSinks_OutCombo'));
Lines(end+1) = sprintf("- Individual oxygen-sink event rows: %d",heightIfField(Data,'Table_OxygenSinkEvents_OutCombo'));
Lines(end+1) = sprintf("- Recording rows with surges: %d",heightIfField(Data,'Table_OxygenSurges_OutCombo'));
Lines(end+1) = sprintf("- Individual oxygen-surge event rows: %d",heightIfField(Data,'Table_OxygenSurgeEvents_OutCombo'));
if isfield(Info,'LoadSummary') && isstruct(Info.LoadSummary)
    Lines(end+1) = sprintf("- Loaded sink recordings: %s",fieldText(Info.LoadSummary,'RecordingsWithSinks'));
    Lines(end+1) = sprintf("- Loaded surge recordings: %s",fieldText(Info.LoadSummary,'RecordingsWithSurges'));
    Lines(end+1) = sprintf("- Loaded behaviour recordings: %s",fieldText(Info.LoadSummary,'RecordingsWithBehaviour'));
end
Lines(end+1) = "";

end

function Lines = appendQcSection(Lines,QcRows)

Lines(end+1) = "## Additional QC Rows";
if isempty(QcRows) || height(QcRows)==0
    Lines(end+1) = "- No QC rows available.";
    Lines(end+1) = "";
    return
end
for RowIdx = 1:height(QcRows)
    Lines(end+1) = sprintf("- **%s**: %s - %s", ...
        manifestRowValue(QcRows,RowIdx,["Item","Check"]), ...
        manifestRowValue(QcRows,RowIdx,"Status"), ...
        manifestRowValue(QcRows,RowIdx,"Message")); %#ok<AGROW>
end
Lines(end+1) = "";

end

function Lines = appendAcceptanceSection(Lines,AcceptanceRows)

Lines(end+1) = "## Acceptance And QC";
if isempty(AcceptanceRows) || height(AcceptanceRows)==0
    Lines(end+1) = "- No acceptance rows available.";
    Lines(end+1) = "";
    return
end
for RowIdx = 1:height(AcceptanceRows)
    Lines(end+1) = sprintf("- **%s**: %s - %s", ...
        manifestRowValue(AcceptanceRows,RowIdx,["Item","Check"]), ...
        manifestRowValue(AcceptanceRows,RowIdx,"Status"), ...
        manifestRowValue(AcceptanceRows,RowIdx,"Message")); %#ok<AGROW>
end
Lines(end+1) = "";

end

function Lines = appendPreviewSection(Lines,PreviewRows)

Lines(end+1) = "## Key Metrics";
if isempty(PreviewRows)
    Lines(end+1) = "- No preview rows available.";
    Lines(end+1) = "";
    return
end
KeepLabels = ["Hypoxic burden event rows","Hypoxic burden event sum", ...
    "Hypoxic burden event sum per 1 mm2","Hypoxic burden recordings", ...
    "Hypoxic burden total","Hypoxic burden total per 1 mm2", ...
    "Hypoxic burden time-series rows","Mean burden over time per 1 mm2", ...
    "Max burden over time per 1 mm2","Area-normalized recordings", ...
    "Mean area correction","Mean burden occupancy","Mean burden rank amplitude", ...
    "Mean burden amplitude composite","Mean grouped burden occupancy", ...
    "Mean grouped burden rank amplitude","Mean grouped burden amplitude composite"];
for RowIdx = 1:size(PreviewRows,1)
    Label = string(PreviewRows{RowIdx,1});
    if any(Label==KeepLabels)
        Lines(end+1) = sprintf("- %s: `%s`",Label,string(PreviewRows{RowIdx,2})); %#ok<AGROW>
    end
end
Lines(end+1) = "";

end

function Lines = appendFigureSection(Lines,FigureManifest)

Lines(end+1) = "## Generated Figures";
if isempty(FigureManifest) || ~istable(FigureManifest) || height(FigureManifest)==0
    Lines(end+1) = "- No summary figure manifest found yet. Run `runOxygenSummaryFigures` to refresh this section.";
    Lines(end+1) = "";
    return
end
MaxRows = min(height(FigureManifest),20);
for RowIdx = 1:MaxRows
    Label = tableValueAsString(FigureManifest,'Label',RowIdx);
    FilePath = tableValueAsString(FigureManifest,'FilePath',RowIdx);
    Lines(end+1) = sprintf("- %s: `%s`",Label,FilePath); %#ok<AGROW>
end
if height(FigureManifest)>MaxRows
    Lines(end+1) = sprintf("- ... %d additional figures listed in `OxygenSummaryFigureMetrics.xlsx`.", ...
        height(FigureManifest)-MaxRows);
end
Lines(end+1) = "";

end

function Lines = appendReviewChecklist(Lines)

Lines(end+1) = "## Review Checklist";
Lines(end+1) = "- Inspect `StatsAcceptance` first. Do not refresh the regression baseline if any row is `REVIEW`.";
Lines(end+1) = "- Inspect `HypoxicBurden_EventBased` for event-specific area matching before using burden metrics.";
Lines(end+1) = "- Use `HypoxicBurdenPerMm2OverTime` for FOV-normalized burden-over-time comparisons.";
Lines(end+1) = "- Create or refresh the regression baseline only from an accepted stats output.";
Lines(end+1) = "";

end

function Manifest = readManifestFigureManifest(StatsFolder,Data,FiguresFolder)

Manifest = table();
CandidateFolders = strings(0,1);
if ~isempty(FiguresFolder)
    CandidateFolders(end+1,1) = string(FiguresFolder);
end
if isfield(Data,'StatsInfo') && isstruct(Data.StatsInfo) && ...
        isfield(Data.StatsInfo,'OutputFolders') && isstruct(Data.StatsInfo.OutputFolders) && ...
        isfield(Data.StatsInfo.OutputFolders,'Figures')
    CandidateFolders(end+1,1) = string(Data.StatsInfo.OutputFolders.Figures);
end
CandidateFolders(end+1,1) = string(fullfile(StatsFolder,'Summary_Figures'));
[StatsParent,StatsName] = fileparts(StatsFolder);
CandidateFolders(end+1,1) = string(fullfile(StatsParent,strrep(StatsName,'Stats_Output','Figures_Output')));

for FolderIdx = 1:numel(CandidateFolders)
    ManifestPath = fullfile(char(CandidateFolders(FolderIdx)),'OxygenSummaryFigureMetrics.xlsx');
    if ~isfile(ManifestPath)
        continue
    end
    try
        if any(sheetnames(ManifestPath)=="FigureManifest")
            Manifest = readtable(ManifestPath,'Sheet','FigureManifest','TextType','string');
            return
        end
    catch
        Manifest = table();
    end
end

end

function Count = heightIfField(Data,FieldName)

if isfield(Data,FieldName) && istable(Data.(FieldName))
    Count = height(Data.(FieldName));
else
    Count = 0;
end

end

function Text = getStructString(StructValue,FieldName)

Text = "";
if isstruct(StructValue) && isfield(StructValue,FieldName)
    Text = string(StructValue.(FieldName));
    if isempty(Text)
        Text = "";
    else
        Text = Text(1);
    end
end

end

function Text = fieldText(StructValue,FieldName)

if isfield(StructValue,FieldName)
    Text = string(StructValue.(FieldName));
else
    Text = "n/a";
end

end

function Text = tableValueAsString(TableData,ColumnName,RowIdx)

if ismember(ColumnName,TableData.Properties.VariableNames)
    Text = string(TableData.(ColumnName)(RowIdx));
else
    Text = "";
end

end

function Text = manifestRowValue(TableData,RowIdx,ColumnNames)

Text = "";
for NameIdx = 1:numel(ColumnNames)
    ColumnName = char(ColumnNames(NameIdx));
    if ismember(ColumnName,TableData.Properties.VariableNames)
        Text = string(TableData.(ColumnName)(RowIdx));
        return
    end
end

end

function writeTextFile(FilePath,Text)

FileId = fopen(FilePath,'w');
if FileId<0
    error('OxygenDynamics:AnalysisManifestWriteFailed', ...
        'Could not write analysis manifest: %s',FilePath);
end
Cleaner = onCleanup(@() fclose(FileId));
fprintf(FileId,'%s',Text);
delete(Cleaner);

end
