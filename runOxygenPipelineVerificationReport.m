function Report = runOxygenPipelineVerificationReport(varargin)
%RUNOXYGENPIPELINEVERIFICATIONREPORT Non-destructive dataset readiness report.

setupOxygenDynamicsPath();

DefaultConfig = loadVerificationDefaults();
Parser = inputParser;
Parser.addParameter('inputCsv',DefaultConfig.InputCsv,@(Value) ischar(Value) || isstring(Value));
Parser.addParameter('masterFolder',pwd,@(Value) ischar(Value) || isstring(Value));
Parser.addParameter('outputRoot',DefaultConfig.OutputRoot,@(Value) ischar(Value) || isstring(Value));
Parser.addParameter('sinkFolderSelection',DefaultConfig.SinkFolderSelection,@isRecentOrOldest);
Parser.addParameter('surgeFolderSelection',DefaultConfig.SurgeFolderSelection,@isRecentOrOldest);
Parser.addParameter('behaviourFolderSelection',DefaultConfig.BehaviourFolderSelection,@isRecentOrOldest);
Parser.addParameter('overwriteOutputs',DefaultConfig.OverwriteOutputs,@islogical);
Parser.addParameter('requireBehaviour',DefaultConfig.RequireBehaviour,@islogical);
Parser.addParameter('requireVascularAnnotations',DefaultConfig.RequireVascularAnnotations,@islogical);
Parser.parse(varargin{:});

Options = Parser.Results;
Options.inputCsv = char(Options.inputCsv);
Options.masterFolder = char(Options.masterFolder);
Options.outputRoot = char(Options.outputRoot);

InputCsvPath = resolveInputCsvPath(Options.inputCsv,Options.masterFolder);
InputTable = readInputTable(InputCsvPath);
validateInputTableColumns(InputTable,requiredWrapperInputColumns(),InputCsvPath);

[Paths,~,~,~,Mice,Genotypes,Conditions,DrugIDs,Promoters,SampleFs,Pixelsizes] = ...
    unpackWrapperInputTable(InputTable);
validateRecordingPaths(Paths,Options.masterFolder,InputCsvPath);

Rows = repmat(createEmptyVerificationRow(),numel(Paths),1);
for RecordingIdx = 1:numel(Paths)
    Rows(RecordingIdx) = inspectVerificationRecording(RecordingIdx,Paths,Mice,Genotypes, ...
        Conditions,DrugIDs,Promoters,SampleFs,Pixelsizes,Options);
end

SummaryTable = orderVerificationSummaryColumns(struct2table(Rows));
Report = struct();
Report.Options = Options;
Report.InputCsv = InputCsvPath;
Report.CreatedAt = datetime('now');
Report.SummaryTable = SummaryTable;
Report.OutputFiles = writeVerificationReport(Report);

printVerificationConsoleSummary(Report);
fprintf('Pipeline verification report saved:\n');
fprintf('%s\n',Report.OutputFiles.Mat);
fprintf('%s\n',Report.OutputFiles.Xlsx);

end

function Defaults = loadVerificationDefaults()

Defaults = struct();
Defaults.InputCsv = 'GFAP_GeNL_Ctrl.csv';
Defaults.OutputRoot = 'Verification_Reports';
Defaults.SinkFolderSelection = 'Recent';
Defaults.SurgeFolderSelection = 'Recent';
Defaults.BehaviourFolderSelection = 'Recent';
Defaults.OverwriteOutputs = false;
Defaults.RequireBehaviour = false;
Defaults.RequireVascularAnnotations = false;

if exist('OxygenDynamics_Config','file')~=2
    return
end

Config = OxygenDynamics_Config();
if isfield(Config,'Stats')
    Defaults = copyIfField(Defaults,Config.Stats,'inputCsv','InputCsv');
    Defaults = copyIfField(Defaults,Config.Stats,'sinkFolderSelection','SinkFolderSelection');
    Defaults = copyIfField(Defaults,Config.Stats,'surgeFolderSelection','SurgeFolderSelection');
    Defaults = copyIfField(Defaults,Config.Stats,'behaviourFolderSelection','BehaviourFolderSelection');
end
if isfield(Config,'Verification')
    Defaults = copyIfField(Defaults,Config.Verification,'inputCsv','InputCsv');
    Defaults = copyIfField(Defaults,Config.Verification,'outputRoot','OutputRoot');
    Defaults = copyIfField(Defaults,Config.Verification,'sinkFolderSelection','SinkFolderSelection');
    Defaults = copyIfField(Defaults,Config.Verification,'surgeFolderSelection','SurgeFolderSelection');
    Defaults = copyIfField(Defaults,Config.Verification,'behaviourFolderSelection','BehaviourFolderSelection');
    Defaults = copyIfField(Defaults,Config.Verification,'overwriteOutputs','OverwriteOutputs');
    Defaults = copyIfField(Defaults,Config.Verification,'requireBehaviour','RequireBehaviour');
    Defaults = copyIfField(Defaults,Config.Verification,'requireVascularAnnotations','RequireVascularAnnotations');
end

end

function Defaults = copyIfField(Defaults,Source,sourceField,targetField)

if isfield(Source,sourceField) && ~isempty(Source.(sourceField))
    Defaults.(targetField) = Source.(sourceField);
end

end

function tf = isRecentOrOldest(Value)

tf = any(strcmp(Value,{'Recent','Oldest'}));

end

function InputCsvPath = resolveInputCsvPath(inputCsv,masterFolder)

InputCsvPath = inputCsv;
if ~isfile(InputCsvPath)
    InputCsvPath = fullfile(masterFolder,inputCsv);
end
if ~isfile(InputCsvPath)
    error('Input CSV not found: %s',inputCsv);
end

end

function Row = createEmptyVerificationRow()

Row = struct();
Row.Index = NaN;
Row.Mouse = "";
Row.RecordingFolder = "";
Row.Status = "";
Row.WarningCount = NaN;
Row.ErrorCount = NaN;
Row.RawTiffCount = NaN;
Row.DenoisedTiffCount = NaN;
Row.RawTiff = "";
Row.DenoisedTiff = "";
Row.PreflightValid = false;
Row.PreflightMessages = "";
Row.DetectionSource = "";
Row.QuantificationSource = "";
Row.OxygenSinksFolder = "";
Row.OxygenSinksMat = "";
Row.OxygenSinksBinaryTiff = "";
Row.CanExportEventMetrics = false;
Row.OxygenSurgesFolder = "";
Row.BehaviourFolder = "";
Row.HasBehaviourOutput = false;
Row.HasVascularAnnotations = false;
Row.ArteriesFile = "";
Row.VeinsFile = "";
Row.CanRunVascularRoi = false;
Row.CanRunVascularEvents = false;
Row.IssueSummary = "";
Row.RecommendedAction = "";

end

function Row = inspectVerificationRecording(RecordingIdx,Paths,Mice,Genotypes,Conditions, ...
    DrugIDs,Promoters,SampleFs,Pixelsizes,Options)

Row = createEmptyVerificationRow();
Row.Index = RecordingIdx;
Row.Mouse = string(Mice{RecordingIdx});
RecordingFolder = makeFullRecordingPath(Paths{RecordingIdx},Options.masterFolder);
Row.RecordingFolder = string(RecordingFolder);

Metadata = createRecordingMetadata(Mice{RecordingIdx},Conditions{RecordingIdx},DrugIDs{RecordingIdx}, ...
    Genotypes{RecordingIdx},Promoters{RecordingIdx});
Validation = runOneOutputSilently(@() validateOxygenRecording(RecordingFolder,SampleFs{RecordingIdx}, ...
    Pixelsizes{RecordingIdx},Options.overwriteOutputs,Metadata));
TiffStatus = Validation.TiffStatus;

Row.RawTiffCount = numel(TiffStatus.RawFiles);
Row.DenoisedTiffCount = numel(TiffStatus.DenoisedFiles);
Row.RawTiff = firstDirName(TiffStatus.RawFiles);
Row.DenoisedTiff = firstDirName(TiffStatus.DenoisedFiles);
Row.PreflightValid = Validation.IsValid;
Row.WarningCount = numel(Validation.Warnings);
Row.ErrorCount = numel(Validation.Errors);
Row.PreflightMessages = string(strjoin([Validation.Errors(:); Validation.Warnings(:)],' | '));
Row.DetectionSource = "original/raw TIFF";
if Row.DenoisedTiffCount==1
    Row.DetectionSource = "denoised TIFF";
end
Row.QuantificationSource = "original/raw TIFF";

[SinksFolder,HasSinks] = selectStatsOutputFolder(RecordingFolder,'OxygenSinks_Output','No', ...
    Options.sinkFolderSelection,'oxygen sinks','required',false,'recordingId',char(Row.Mouse));
[SurgesFolder,HasSurges] = selectStatsOutputFolder(RecordingFolder,'OxygenSurges','No', ...
    Options.surgeFolderSelection,'oxygen surges','required',false,'recordingId',char(Row.Mouse));
[BehaviourFolder,HasBehaviour] = selectStatsOutputFolder(RecordingFolder,'Behaviour','No', ...
    Options.behaviourFolderSelection,'behavioural','required',false,'recordingId',char(Row.Mouse));

Row.OxygenSinksFolder = string(SinksFolder);
Row.OxygenSurgesFolder = string(SurgesFolder);
Row.BehaviourFolder = string(BehaviourFolder);
Row.HasBehaviourOutput = HasBehaviour;

if HasSinks
    Row.OxygenSinksMat = string(firstMatchingFile(SinksFolder,'*Urefined*.mat','*.mat'));
    Row.OxygenSinksBinaryTiff = string(firstMatchingFile(SinksFolder,'IM_OxySinks_BW*.tif','*OxySinks*BW*.tif'));
    Row.CanExportEventMetrics = strlength(Row.OxygenSinksMat)>0 && strlength(Row.OxygenSinksBinaryTiff)>0 && ...
        matFileHasVariables(char(Row.OxygenSinksMat),{'Table_OxygenSinks_Out','OxySinkArea_all'});
end

[HasVascularAnnotations,ArteriesFile,VeinsFile] = inspectVascularAnnotations(RecordingFolder);
Row.HasVascularAnnotations = HasVascularAnnotations;
Row.ArteriesFile = string(ArteriesFile);
Row.VeinsFile = string(VeinsFile);
Row.CanRunVascularRoi = HasVascularAnnotations && HasSinks;
Row.CanRunVascularEvents = HasVascularAnnotations && Row.CanExportEventMetrics;

RequiredBehaviourOk = ~Options.requireBehaviour || HasBehaviour;
RequiredVascularOk = ~Options.requireVascularAnnotations || HasVascularAnnotations;

if Row.PreflightValid && HasSinks && HasSurges && RequiredBehaviourOk && RequiredVascularOk
    Row.Status = "Ready";
elseif Row.PreflightValid
    Row.Status = "Partial";
else
    Row.Status = "Blocked";
end

[Row.IssueSummary,Row.RecommendedAction] = summarizeVerificationIssues(Row,HasSinks,HasSurges,Options);

end

function Name = firstDirName(DirList)

Name = "";
if ~isempty(DirList)
    Name = string(DirList(1).name);
end

end

function FilePath = firstMatchingFile(folderPath,primaryPattern,fallbackPattern)

FilePath = '';
Matches = dir(fullfile(folderPath,primaryPattern));
if isempty(Matches) && nargin>2
    Matches = dir(fullfile(folderPath,fallbackPattern));
end
if isempty(Matches)
    return
end
[~,NewestIdx] = max([Matches.datenum]);
FilePath = fullfile(Matches(NewestIdx).folder,Matches(NewestIdx).name);

end

function tf = matFileHasVariables(matFile,variableNames)

tf = false;
if isempty(matFile) || ~isfile(matFile)
    return
end
AvailableVars = who('-file',matFile);
tf = all(ismember(variableNames,AvailableVars));

end

function [HasAnnotations,ArteriesFile,VeinsFile] = inspectVascularAnnotations(recordingFolder)

ArteriesMatches = findFilesMatchingName(recordingFolder,'Arteries','required',false);
VeinsMatches = findFilesMatchingName(recordingFolder,'Veins','required',false);
ArteriesFile = '';
VeinsFile = '';
if ~isempty(ArteriesMatches)
    ArteriesFile = ArteriesMatches{1};
end
if ~isempty(VeinsMatches)
    VeinsFile = VeinsMatches{1};
end
HasAnnotations = ~isempty(ArteriesFile) && ~isempty(VeinsFile);

end

function [IssueSummary,RecommendedAction] = summarizeVerificationIssues(Row,hasSinks,hasSurges,Options)

Issues = strings(0,1);
Actions = strings(0,1);

if ~Row.PreflightValid
    Issues(end+1,1) = "preflight failed";
    Actions(end+1,1) = "fix TIFF/metadata preflight errors";
end
if ~hasSinks
    Issues(end+1,1) = "no oxygen sink output folder";
    Actions(end+1,1) = "run wrapper/master sink analysis";
end
if ~hasSurges
    Issues(end+1,1) = "no oxygen surge output folder";
    Actions(end+1,1) = "run wrapper/master surge analysis";
end
if hasSinks && ~Row.CanExportEventMetrics
    Issues(end+1,1) = "event metrics not ready";
    Actions(end+1,1) = "check sink MAT and IM_OxySinks_BW TIFF";
end
if ~Row.HasBehaviourOutput && Options.requireBehaviour
    Issues(end+1,1) = "required behaviour output missing";
    Actions(end+1,1) = "run behaviour analysis";
elseif ~Row.HasBehaviourOutput
    Issues(end+1,1) = "optional behaviour output missing";
    Actions(end+1,1) = "run behaviour analysis if behaviour traces are needed";
end
if ~Row.HasVascularAnnotations && Options.requireVascularAnnotations
    Issues(end+1,1) = "required vascular annotations missing";
    Actions(end+1,1) = "add Arteries and Veins annotation images";
elseif ~Row.HasVascularAnnotations
    Issues(end+1,1) = "optional vascular annotations missing";
    Actions(end+1,1) = "add Arteries and Veins annotation images if vascular analysis is needed";
end

if isempty(Issues)
    IssueSummary = "none";
    RecommendedAction = "ready for stats";
else
    IssueSummary = strjoin(Issues,' | ');
    RecommendedAction = strjoin(unique(Actions,'stable'),' | ');
end

end

function OutputFiles = writeVerificationReport(Report)

OutputFolder = fullfile(Report.Options.masterFolder,Report.Options.outputRoot);
mkdirIfMissing(OutputFolder);
Timestamp = char(datetime('now','Format','yyyyMMdd''T''HHmmss'));
OutputBase = fullfile(OutputFolder,['PipelineVerification_',Timestamp]);

OutputFiles = struct();
OutputFiles.Mat = [OutputBase,'.mat'];
OutputFiles.Xlsx = [OutputBase,'.xlsx'];

VerificationReport = Report;
save(OutputFiles.Mat,'VerificationReport');
writetable(Report.SummaryTable,OutputFiles.Xlsx,'Sheet','RecordingSummary');
writetable(createVerificationRunSummary(Report),OutputFiles.Xlsx,'Sheet','RunSummary');
NeedsReview = Report.SummaryTable(Report.SummaryTable.Status~="Ready",:);
if ~isempty(NeedsReview)
    writetable(NeedsReview,OutputFiles.Xlsx,'Sheet','NeedsReview');
end

end

function printVerificationConsoleSummary(Report)

ReadyCount = sum(Report.SummaryTable.Status=="Ready");
PartialCount = sum(Report.SummaryTable.Status=="Partial");
BlockedCount = sum(Report.SummaryTable.Status=="Blocked");

fprintf('\nPipeline verification summary\n');
fprintf('Recordings: %d\n',height(Report.SummaryTable));
fprintf('Ready: %d\n',ReadyCount);
fprintf('Partial: %d\n',PartialCount);
fprintf('Blocked: %d\n',BlockedCount);
fprintf('Require behaviour: %s\n',string(Report.Options.requireBehaviour));
fprintf('Require vascular annotations: %s\n\n',string(Report.Options.requireVascularAnnotations));

end

function SummaryTable = orderVerificationSummaryColumns(SummaryTable)

PriorityColumns = {'Index','Mouse','Status','IssueSummary','RecommendedAction','PreflightValid', ...
    'RawTiffCount','DenoisedTiffCount','DetectionSource','QuantificationSource','CanExportEventMetrics', ...
    'HasBehaviourOutput','HasVascularAnnotations','CanRunVascularRoi','CanRunVascularEvents'};
PriorityColumns = PriorityColumns(ismember(PriorityColumns,SummaryTable.Properties.VariableNames));
RemainingColumns = setdiff(SummaryTable.Properties.VariableNames,PriorityColumns,'stable');
SummaryTable = SummaryTable(:,[PriorityColumns,RemainingColumns]);

end

function RunSummary = createVerificationRunSummary(Report)

InputCsv = string(Report.InputCsv);
CreatedAt = string(Report.CreatedAt);
RecordingCount = height(Report.SummaryTable);
ReadyCount = sum(Report.SummaryTable.Status=="Ready");
PartialCount = sum(Report.SummaryTable.Status=="Partial");
BlockedCount = sum(Report.SummaryTable.Status=="Blocked");
EventMetricReadyCount = sum(Report.SummaryTable.CanExportEventMetrics);
VascularRoiReadyCount = sum(Report.SummaryTable.CanRunVascularRoi);
VascularEventReadyCount = sum(Report.SummaryTable.CanRunVascularEvents);
RequireBehaviour = Report.Options.requireBehaviour;
RequireVascularAnnotations = Report.Options.requireVascularAnnotations;

RunSummary = table(InputCsv,CreatedAt,RecordingCount,ReadyCount,PartialCount,BlockedCount, ...
    EventMetricReadyCount,VascularRoiReadyCount,VascularEventReadyCount, ...
    RequireBehaviour,RequireVascularAnnotations);

end

function OutputValue = runOneOutputSilently(functionHandle) %#ok<INUSD>

[~,OutputValue] = evalc('functionHandle()');

end
