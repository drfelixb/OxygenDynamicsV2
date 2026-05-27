function QCSummary = compareRawDenoisedOutputs(inputSource,varargin)
%COMPARERAWDENOISEDOUTPUTS Summarize raw-vs-denoised oxygen output QC.
%
% Usage:
%   QCSummary = compareRawDenoisedOutputs('metadata.csv')
%   QCSummary = compareRawDenoisedOutputs({'Mouse1/Rec1','Mouse1/Rec2'})
%   QCSummary = compareRawDenoisedOutputs({'Mouse1/Rec1'},'baseFolder','D:\Data')
%
% The script looks for the selected OxygenSinks_Output folder in each
% recording, loads the Urefined sink MAT file, and exports a table with
% provenance, event counts, and raw-quantified vs detection-domain
% amplitude summaries.

setupOxygenDynamicsPath();

if nargin<1 || isempty(inputSource)
    inputSource = pwd;
end

Config = struct();
Config.folderSelection = 'Recent'; % 'Recent' or 'Oldest'
Config.outputFolder = fullfile(pwd,'QC_Output');
Config.baseFolder = pwd;
Config.extremeNormAmpThreshold = 1;
Config = parseNameValueConfig(Config,varargin{:});

[RecordingPaths,BaseFolder,SourceLabel] = resolveRecordingPaths(inputSource,Config.baseFolder);
validateRecordingPaths(RecordingPaths,BaseFolder,SourceLabel);

NumRecordings = numel(RecordingPaths);
Rows = repmat(emptyQCRow(),NumRecordings,1);

for reci=1:NumRecordings
    RecordingFolder = makeFullRecordingPath(RecordingPaths{reci},BaseFolder);
    Rows(reci).RecordingPath = RecordingFolder;
    [~,Rows(reci).DatafileID] = fileparts(RecordingFolder);

    SinkFolder = selectOutputFolder(RecordingFolder,'OxygenSinks_Output',Config.folderSelection);
    Rows(reci).SinkOutputFolder = SinkFolder;
    if isempty(SinkFolder)
        Rows(reci).Status = 'Missing OxygenSinks_Output folder';
        continue
    end

    SinkMatFile = selectMatFile(SinkFolder,'Urefined');
    Rows(reci).SinkMatFile = SinkMatFile;
    if isempty(SinkMatFile)
        Rows(reci).Status = 'Missing Urefined sink MAT file';
        continue
    end

    FileVars = who('-file',SinkMatFile);
    Loaded = load(SinkMatFile,'Table_OxygenSinks_Out','AnalysisInfo');
    if ~isfield(Loaded,'Table_OxygenSinks_Out')
        Rows(reci).Status = 'Sink MAT lacks Table_OxygenSinks_Out';
        continue
    end

    Rows(reci).Status = 'OK';
    Rows(reci).NumSinkLoci = height(Loaded.Table_OxygenSinks_Out);
    Rows(reci).RawFile = getAnalysisInfoField(Loaded,'RawFile');
    Rows(reci).DenoisedFile = getAnalysisInfoField(Loaded,'DenoisedFile');
    Rows(reci).DetectionSource = getAnalysisInfoField(Loaded,'DetectionSource');
    Rows(reci).QuantificationSource = getAnalysisInfoField(Loaded,'QuantificationSource');
    Rows(reci).RawBitDepth = getTiffBitDepth(Rows(reci).RawFile);
    Rows(reci).DenoisedBitDepth = getTiffBitDepth(Rows(reci).DenoisedFile);

    if ismember('Table_OxygenSinkEvents_Out',FileVars)
        EventData = load(SinkMatFile,'Table_OxygenSinkEvents_Out');
        EventTable = EventData.Table_OxygenSinkEvents_Out;
        Rows(reci).NumSinkEvents = height(EventTable);
        Rows(reci) = addEventAmplitudeSummary(Rows(reci),EventTable,Config.extremeNormAmpThreshold);
    else
        Rows(reci).NumSinkEvents = sum(cellfun(@numel,Loaded.Table_OxygenSinks_Out.NormOxySinkAmp));
        Rows(reci) = addLocusAmplitudeSummary(Rows(reci),Loaded.Table_OxygenSinks_Out,Config.extremeNormAmpThreshold);
    end
end

QCSummary = struct();
QCSummary.Created = char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
QCSummary.Source = SourceLabel;
QCSummary.Config = Config;
QCSummary.Table = struct2table(Rows);

Timestamp = char(datetime('now','Format','yyyyMMdd''T''HHmmss'));
OutputBase = fullfile(Config.outputFolder,['RawDenoisedQC_',Timestamp]);
save([OutputBase,'.mat'],'QCSummary');
writetable(QCSummary.Table,[OutputBase,'.xlsx'],'Sheet','RawDenoisedQC');

fprintf('Raw/denoised QC summary saved:\n%s.mat\n%s.xlsx\n',OutputBase,OutputBase);
end

function Config = parseNameValueConfig(Config,varargin)
if mod(numel(varargin),2)~=0
    error('Optional arguments must be name/value pairs.');
end
for argi=1:2:numel(varargin)
    Name = varargin{argi};
    Value = varargin{argi+1};
    if ~isfield(Config,Name)
        error('Unknown option "%s".',Name);
    end
    Config.(Name)=Value;
end
if ~ismember(Config.folderSelection,{'Recent','Oldest'})
    error('folderSelection must be "Recent" or "Oldest".');
end
if ~isfolder(Config.outputFolder)
    mkdir(Config.outputFolder);
end
end

function [RecordingPaths,BaseFolder,SourceLabel] = resolveRecordingPaths(inputSource,defaultBaseFolder)
BaseFolder = defaultBaseFolder;
if iscell(inputSource)
    RecordingPaths = inputSource(:);
    SourceLabel = 'cell array input';
elseif isstring(inputSource) && ~isscalar(inputSource)
    RecordingPaths = cellstr(inputSource(:));
    SourceLabel = 'string array input';
elseif ischar(inputSource) || (isstring(inputSource) && isscalar(inputSource))
    inputSource = char(inputSource);
    if isfile(inputSource)
        InputTable = readInputTable(inputSource);
        validateInputTableColumns(InputTable,{'Paths'},inputSource);
        RecordingPaths = table2cell(InputTable(:,{'Paths'}));
        [BaseFolder,~,~] = fileparts(inputSource);
        if isempty(BaseFolder)
            BaseFolder = fileparts(which(inputSource));
        end
        if isempty(BaseFolder)
            BaseFolder = defaultBaseFolder;
        end
        SourceLabel = inputSource;
    elseif isfolder(inputSource)
        RecordingPaths = {inputSource};
        BaseFolder = defaultBaseFolder;
        SourceLabel = inputSource;
    else
        RecordingPaths = {inputSource};
        BaseFolder = defaultBaseFolder;
        SourceLabel = inputSource;
    end
else
    error('inputSource must be a CSV file, folder path, cell array, or string array.');
end
end

function FolderPath = selectOutputFolder(recordingFolder,folderPrefix,selectionMode)
FolderList = dir(fullfile(recordingFolder,[folderPrefix,'*']));
FolderList = FolderList([FolderList.isdir]);
FolderList = FolderList(~ismember({FolderList.name},{'.','..'}));
if isempty(FolderList)
    FolderPath = '';
    return
end
if strcmp(selectionMode,'Oldest')
    [~,FolderIdx] = min([FolderList.datenum]);
else
    [~,FolderIdx] = max([FolderList.datenum]);
end
FolderPath = fullfile(FolderList(FolderIdx).folder,FolderList(FolderIdx).name);
end

function MatFile = selectMatFile(folderPath,namePart)
MatFiles = dir(fullfile(folderPath,'*.mat'));
Match = contains({MatFiles.name},namePart);
MatFiles = MatFiles(Match);
if isempty(MatFiles)
    MatFile = '';
else
    [~,FileIdx] = max([MatFiles.datenum]);
    MatFile = fullfile(MatFiles(FileIdx).folder,MatFiles(FileIdx).name);
end
end

function Row = addEventAmplitudeSummary(Row,EventTable,extremeThreshold)
if isempty(EventTable) || height(EventTable)==0
    return
end
NormAmp = EventTable.NormOxySinkAmp;
Row.MeanNormOxySinkAmp = mean(NormAmp,'omitnan');
Row.MedianNormOxySinkAmp = median(NormAmp,'omitnan');
Row.MaxNormOxySinkAmp = max(NormAmp,[],'omitnan');
if ismember('NormOxySinkAmpPercent',EventTable.Properties.VariableNames)
    Row.MeanNormOxySinkAmpPercent = mean(EventTable.NormOxySinkAmpPercent,'omitnan');
else
    Row.MeanNormOxySinkAmpPercent = Row.MeanNormOxySinkAmp*100;
end
if ismember('DetectionOxySinkAmp',EventTable.Properties.VariableNames)
    DetectionAmp = EventTable.DetectionOxySinkAmp;
    Row.MeanDetectionOxySinkAmp = mean(DetectionAmp,'omitnan');
    Row.MedianDetectionOxySinkAmp = median(DetectionAmp,'omitnan');
    Row.MaxDetectionOxySinkAmp = max(DetectionAmp,[],'omitnan');
end
Row.ExtremeNormAmpEventCount = nnz(abs(NormAmp)>extremeThreshold);
end

function Row = addLocusAmplitudeSummary(Row,SinkTable,extremeThreshold)
NormAmp = flattenNumericCells(SinkTable.NormOxySinkAmp);
if isempty(NormAmp)
    return
end
Row.MeanNormOxySinkAmp = mean(NormAmp,'omitnan');
Row.MedianNormOxySinkAmp = median(NormAmp,'omitnan');
Row.MaxNormOxySinkAmp = max(NormAmp,[],'omitnan');
Row.MeanNormOxySinkAmpPercent = Row.MeanNormOxySinkAmp*100;
Row.ExtremeNormAmpEventCount = nnz(abs(NormAmp)>extremeThreshold);
end

function Values = flattenNumericCells(CellValues)
Values = [];
for celli=1:numel(CellValues)
    if isnumeric(CellValues{celli})
        Values = [Values; CellValues{celli}(:)]; %#ok<AGROW>
    end
end
Values = Values(isfinite(Values));
end

function BitDepth = getTiffBitDepth(tiffPath)
BitDepth = NaN;
if isempty(tiffPath) || ~isfile(tiffPath)
    return
end
WarningState = warning('off','all');
RestoreWarnings = onCleanup(@() warning(WarningState));
Info = imfinfo(tiffPath);
BitDepth = Info(1).BitDepth;
end

function Value = getAnalysisInfoField(Loaded,FieldName)
Value = '';
if isfield(Loaded,'AnalysisInfo') && isfield(Loaded.AnalysisInfo,FieldName)
    Value = Loaded.AnalysisInfo.(FieldName);
end
end

function Row = emptyQCRow()
Row = struct();
Row.Status = 'Not processed';
Row.RecordingPath = '';
Row.DatafileID = '';
Row.SinkOutputFolder = '';
Row.SinkMatFile = '';
Row.RawFile = '';
Row.DenoisedFile = '';
Row.RawBitDepth = NaN;
Row.DenoisedBitDepth = NaN;
Row.DetectionSource = '';
Row.QuantificationSource = '';
Row.NumSinkLoci = NaN;
Row.NumSinkEvents = NaN;
Row.MeanNormOxySinkAmp = NaN;
Row.MedianNormOxySinkAmp = NaN;
Row.MaxNormOxySinkAmp = NaN;
Row.MeanNormOxySinkAmpPercent = NaN;
Row.MeanDetectionOxySinkAmp = NaN;
Row.MedianDetectionOxySinkAmp = NaN;
Row.MaxDetectionOxySinkAmp = NaN;
Row.ExtremeNormAmpEventCount = NaN;
end
