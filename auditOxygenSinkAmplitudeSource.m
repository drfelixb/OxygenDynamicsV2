function Audit = auditOxygenSinkAmplitudeSource(sinksInput,varargin)
%AUDITOXYGENSINKAMPLITUDESOURCE Verify sink event amplitudes against raw traces.
%
% Audit = auditOxygenSinkAmplitudeSource()
% Audit = auditOxygenSinkAmplitudeSource(recordingFolderOrSinkMat)
% Audit = auditOxygenSinkAmplitudeSource(...,'writeXlsx',true)
%
% The audit recomputes NormOxySinkAmp from Mean_OxySink_Trace_Raw using the
% saved event start/end frames and compares it with the stored event table.

if nargin<1 || isempty(sinksInput)
    sinksInput = pwd;
end

Parser = inputParser();
Parser.addParameter('writeXlsx',false,@islogical);
Parser.addParameter('outputXlsx','',@(x) ischar(x) || isstring(x));
Parser.parse(varargin{:});
Options = Parser.Results;

SinksMatFile = resolveSinksMatFile(sinksInput);
Loaded = load(SinksMatFile);

RequiredVars = {'Mean_OxySink_Trace_Raw','Table_OxygenSinks_Out'};
for VarIdx = 1:numel(RequiredVars)
    if ~isfield(Loaded,RequiredVars{VarIdx})
        error('auditOxygenSinkAmplitudeSource:MissingVariable', ...
            '%s is missing from %s.',RequiredVars{VarIdx},SinksMatFile);
    end
end

AnalysisInfo = struct();
if isfield(Loaded,'AnalysisInfo')
    AnalysisInfo = Loaded.AnalysisInfo;
end

if isfield(Loaded,'Table_OxygenSinkEvents_Out') && istable(Loaded.Table_OxygenSinkEvents_Out) && ...
        ~isempty(Loaded.Table_OxygenSinkEvents_Out)
    Audit = auditEventTable(Loaded.Table_OxygenSinkEvents_Out,Loaded.Mean_OxySink_Trace_Raw,AnalysisInfo);
else
    Audit = auditSummaryTable(Loaded.Table_OxygenSinks_Out,Loaded.Mean_OxySink_Trace_Raw,AnalysisInfo);
end

Audit.SourceMatFile(:) = string(SinksMatFile);
Audit.RawFile(:) = string(getInfoField(AnalysisInfo,'RawFile'));
Audit.DenoisedFile(:) = string(getInfoField(AnalysisInfo,'DenoisedFile'));
Audit.DetectionSource(:) = string(getInfoField(AnalysisInfo,'DetectionSource'));
Audit.QuantificationSource(:) = string(getInfoField(AnalysisInfo,'QuantificationSource'));

MaxDiff = max(Audit.AbsDifference,[],'omitnan');
if isempty(MaxDiff) || ~isfinite(MaxDiff)
    MaxDiff = NaN;
end
fprintf('Amplitude source audit complete.\n');
fprintf('Source MAT: %s\n',SinksMatFile);
fprintf('Raw file: %s\n',getInfoField(AnalysisInfo,'RawFile'));
fprintf('Denoised file: %s\n',getInfoField(AnalysisInfo,'DenoisedFile'));
fprintf('Detection source: %s\n',getInfoField(AnalysisInfo,'DetectionSource'));
fprintf('Quantification source: %s\n',getInfoField(AnalysisInfo,'QuantificationSource'));
fprintf('Audited events: %d\n',height(Audit));
fprintf('Maximum absolute stored-vs-raw recomputed difference: %.12g\n',MaxDiff);

if Options.writeXlsx
    OutputXlsx = string(Options.outputXlsx);
    if strlength(OutputXlsx)==0
        [SinksFolder,SinksName] = fileparts(SinksMatFile);
        OutputXlsx = fullfile(SinksFolder,[SinksName,'_AmplitudeSourceAudit.xlsx']);
    end
    writetable(Audit,OutputXlsx,'Sheet','AmplitudeSourceAudit');
    fprintf('Audit workbook saved: %s\n',OutputXlsx);
end

end

function SinksMatFile = resolveSinksMatFile(sinksInput)

InputPath = char(sinksInput);
if isfile(InputPath)
    SinksMatFile = InputPath;
    return
end
if ~isfolder(InputPath)
    error('auditOxygenSinkAmplitudeSource:InputNotFound', ...
        'Input is neither a file nor a folder: %s',InputPath);
end

Candidates = dir(fullfile(InputPath,'OxygenSinks_Urefined*.mat'));
if isempty(Candidates)
    Candidates = dir(fullfile(InputPath,'OxygenSinks_Output*','OxygenSinks_Urefined*.mat'));
end
if isempty(Candidates)
    error('auditOxygenSinkAmplitudeSource:NoSinkMat', ...
        'No OxygenSinks_Urefined*.mat file found in or under %s.',InputPath);
end

[~,NewestIdx] = max([Candidates.datenum]);
SinksMatFile = fullfile(Candidates(NewestIdx).folder,Candidates(NewestIdx).name);

end

function Audit = auditEventTable(EventTable,RawTraces,AnalysisInfo)

NumRows = height(EventTable);
Rows = initializeAuditRows(NumRows,AnalysisInfo);

for RowIdx = 1:NumRows
    SinkIdx = EventTable.SinkID(RowIdx);
    EventIdx = EventTable.EventID(RowIdx);
    StartFrame = EventTable.StartFrame(RowIdx);
    EndFrame = EventTable.EndFrame(RowIdx);
    StoredAmp = EventTable.NormOxySinkAmp(RowIdx);
    Rows = setAuditRow(Rows,RowIdx,SinkIdx,EventIdx,StartFrame,EndFrame,StoredAmp,RawTraces,AnalysisInfo);
end

Audit = struct2table(Rows);

end

function Audit = auditSummaryTable(SinkTable,RawTraces,AnalysisInfo)

TotalEvents = sum(SinkTable.NumOxySinkEvents(:));
Rows = initializeAuditRows(TotalEvents,AnalysisInfo);
RowIdx = 0;

for SinkIdx = 1:height(SinkTable)
    NumEvents = SinkTable.NumOxySinkEvents(SinkIdx);
    for EventIdx = 1:NumEvents
        RowIdx = RowIdx+1;
        StartFrame = SinkTable.Start{SinkIdx}(EventIdx);
        DurationFrames = SinkTable.Duration{SinkIdx}(EventIdx);
        EndFrame = StartFrame+DurationFrames;
        StoredAmp = SinkTable.NormOxySinkAmp{SinkIdx}(EventIdx);
        Rows = setAuditRow(Rows,RowIdx,SinkIdx,EventIdx,StartFrame,EndFrame,StoredAmp,RawTraces,AnalysisInfo);
    end
end

Rows = Rows(1:RowIdx);
Audit = struct2table(Rows);

end

function Rows = initializeAuditRows(numRows,AnalysisInfo)

Rows = repmat(struct( ...
    'SinkID',NaN, ...
    'EventID',NaN, ...
    'EventStartFrame',NaN, ...
    'EventEndFrame',NaN, ...
    'BaselineStartFrame',NaN, ...
    'BaselineEndFrame',NaN, ...
    'BaselineRaw',NaN, ...
    'EventMinRaw',NaN, ...
    'StoredNormOxySinkAmp',NaN, ...
    'RecomputedRawNormOxySinkAmp',NaN, ...
    'AbsDifference',NaN, ...
    'AmplitudeFormula',"NormOxySinkAmp = (mean(raw baseline) - min(raw event window)) / mean(raw baseline)", ...
    'BaselineWindowFrames',getBaselineWindowFrames(AnalysisInfo), ...
    'SourceMatFile',"", ...
    'RawFile',"", ...
    'DenoisedFile',"", ...
    'DetectionSource',"", ...
    'QuantificationSource',""),numRows,1);

end

function Rows = setAuditRow(Rows,rowIdx,sinkIdx,eventIdx,startFrame,endFrame,storedAmp,RawTraces,AnalysisInfo)

StartFrame = max(1,round(startFrame));
EndFrame = min(size(RawTraces,2),round(endFrame));
BaselineWindowFrames = getBaselineWindowFrames(AnalysisInfo);

if StartFrame<=1
    BaselineStartFrame = min(size(RawTraces,2),EndFrame+1);
    BaselineEndFrame = min(size(RawTraces,2),EndFrame+BaselineWindowFrames);
else
    BaselineStartFrame = max(1,StartFrame-BaselineWindowFrames);
    BaselineEndFrame = max(1,StartFrame-1);
end

RawTrace = RawTraces(sinkIdx,:);
BaselineRaw = mean(RawTrace(BaselineStartFrame:BaselineEndFrame),'omitnan');
EventMinRaw = min(RawTrace(StartFrame:EndFrame),[],'omitnan');
RecomputedAmp = NaN;
if isfinite(BaselineRaw) && BaselineRaw~=0
    RecomputedAmp = (BaselineRaw-EventMinRaw)/BaselineRaw;
end

Rows(rowIdx).SinkID = sinkIdx;
Rows(rowIdx).EventID = eventIdx;
Rows(rowIdx).EventStartFrame = StartFrame;
Rows(rowIdx).EventEndFrame = EndFrame;
Rows(rowIdx).BaselineStartFrame = BaselineStartFrame;
Rows(rowIdx).BaselineEndFrame = BaselineEndFrame;
Rows(rowIdx).BaselineRaw = BaselineRaw;
Rows(rowIdx).EventMinRaw = EventMinRaw;
Rows(rowIdx).StoredNormOxySinkAmp = storedAmp;
Rows(rowIdx).RecomputedRawNormOxySinkAmp = RecomputedAmp;
Rows(rowIdx).AbsDifference = abs(storedAmp-RecomputedAmp);

end

function BaselineWindowFrames = getBaselineWindowFrames(AnalysisInfo)

BaselineWindowFrames = 20;
if isfield(AnalysisInfo,'AnalysisParams')
    Params = AnalysisInfo.AnalysisParams;
    if isfield(Params,'quantBaselineWindowSec') && isfield(Params,'fs')
        BaselineWindowFrames = round(Params.quantBaselineWindowSec*Params.fs);
    end
end

end

function Value = getInfoField(AnalysisInfo,fieldName)

Value = '';
if isstruct(AnalysisInfo) && isfield(AnalysisInfo,fieldName)
    Value = AnalysisInfo.(fieldName);
end
if isstring(Value)
    Value = char(Value);
end

end
