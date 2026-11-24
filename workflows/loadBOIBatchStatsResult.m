function [Result,Info]=loadBOIBatchStatsResult(Input)
%LOADBOIBATCHSTATSRESULT Reopen a completed automatic export without analysis.
% Checks receipts, contained files and recorded identities. Does not read or
% revalidate original movies, rerun statistics, or attest file-byte integrity.
setupOxygenDynamicsPath;
id='OxygenDynamics:BatchStatsSavedExport';
assert((ischar(Input)&&isrow(Input))||(isstring(Input)&&isscalar(Input)&&~ismissing(Input)), ...
    id,'Choose a completed combined-export folder or its BatchStatsResult.mat receipt.');
assert(strlength(strtrim(string(Input)))>0,id,'Choose a completed combined-export folder.');
folder=canonical(Input);
if isfile(folder)
    [folder,name,ext]=fileparts(folder);
    assert(ismember([name ext],{'BatchStatsResult.mat','BatchStatsSelection.mat','BatchStatsStatus.json'}), ...
        id,'Choose the combined-export folder or a BatchStats receipt, not an individual recording or workbook.');
end
assert(isfolder(folder),id,'The selected export folder is unavailable. Locate its completed combined-export folder.');
resultPath=contained(fullfile(folder,'BatchStatsResult.mat'),folder);
selectionPath=contained(fullfile(folder,'BatchStatsSelection.mat'),folder);
statusPath=contained(fullfile(folder,'BatchStatsStatus.json'),folder);
try
    checkVariable(resultPath,'Result','struct');checkVariable(selectionPath,'Plan','struct');
    saved=load(resultPath,'Result');selection=load(selectionPath,'Plan');
    Result=saved.Result;Plan=selection.Plan;Status=jsondecode(fileread(statusPath));
catch err
    error(id,'The saved export receipts cannot be read: %s. Choose an intact completed combined export.',err.message);
end
fields(Result,{'Schema','Status','Directory','Workbook','DataOutput','AnalysisManifest', ...
    'Included','Excluded','StatsResult','PlanDigest'},'result receipt');
fields(Plan,{'Schema','Digest','OutputFolder','Included','Excluded','InputRows','InputCSVName','SavedSources','Counts'},'selection receipt');
fields(Status,{'Schema','Status','Stage','Workbook','IncludedRecordings','ExcludedRecordings'},'completion receipt');
assert(strcmp(Result.Schema,'boi-batch-stats-result-1')&&strcmp(Plan.Schema,'boi-batch-stats-plan-1')&& ...
    strcmp(Status.Schema,'boi-batch-stats-status-1'),id,'Unsupported export receipt version. Choose a compatible completed batch export.');
assert(strcmp(Result.Status,'complete')&&strcmp(Status.Status,'complete')&&strcmp(Status.Stage,'complete'), ...
    id,'This export is incomplete or failed. Select a completed export; retained partial files are not a completed result.');
assert(strcmp(canonical(Result.Directory),folder)&&strcmp(canonical(Plan.OutputFolder),folder), ...
    id,'This receipt belongs to a different export folder. Choose its original folder; moved-folder recovery is not supported here.');
plain=rmfield(Plan,'Digest');
assert(strcmp(Plan.Digest,boiBatchQueueDigest(plain))&&strcmp(Result.PlanDigest,Plan.Digest), ...
    id,'The saved selection and result receipts do not match. Choose the original intact export.');
assert(istable(Result.Included)&&istable(Result.Excluded)&& ...
    isequaln(Result.Included,Plan.Included)&&isequaln(Result.Excluded,Plan.Excluded), ...
    id,'Saved included/excluded recording identities disagree. Choose the original intact export.');
assert(istable(Plan.InputRows)&&all(ismember({'RecordingID','BatchRowID','SinkMaster','SurgeMaster'},Result.Included.Properties.VariableNames))&& ...
    ismember('RecordingID',Plan.InputRows.Properties.VariableNames),id,'The saved recording selection is incomplete.');
ids=string(Result.Included.RecordingID);
assert(~isempty(ids)&&all(~ismissing(ids)&strlength(ids)>0)&&numel(unique(ids))==numel(ids)&& ...
    numel(unique(Result.Included.BatchRowID))==numel(ids)&&isequal(ids,string(Plan.InputRows.RecordingID)), ...
    id,'The saved recording selection contains missing, duplicate or reordered identities.');
fields(Plan.Counts,{'Included','Excluded'},'selection counts');
assert(Plan.Counts.Included==height(Result.Included)&&Plan.Counts.Excluded==height(Result.Excluded)&& ...
    Status.IncludedRecordings==height(Result.Included)&&Status.ExcludedRecordings==height(Result.Excluded), ...
    id,'Saved export recording counts disagree. Choose the original intact export.');
fields(Result.StatsResult,{'OutputXlsx','DataOutputMat','AnalysisManifest','StatsInfo'},'statistics receipt');
fields(Result.StatsResult.StatsInfo,{'Recordings'},'statistics source identity');
sources=Plan.SavedSources;records=Result.StatsResult.StatsInfo.Recordings;
assert(isstruct(sources)&&numel(sources)==numel(ids)&&all(isfield(sources,{'RecordingID','SinkMaster','SurgeMaster'}))&& ...
    isstruct(records)&&numel(records)==numel(ids)&&all(isfield(records,{'SinksMatFile','SurgesMatFile'})), ...
    id,'Saved statistics source identities are incomplete.');
assert(isequal(string({sources.RecordingID})',ids)&& ...
    isequal(string({sources.SinkMaster})',string(Result.Included.SinkMaster))&& ...
    isequal(string({sources.SurgeMaster})',string(Result.Included.SurgeMaster))&& ...
    isequal(string({records.SinksMatFile}),string({sources.SinkMaster}))&& ...
    isequal(string({records.SurgesMatFile}),string({sources.SurgeMaster})), ...
    id,'Statistics and selection refer to different saved recordings.');
% Source paths above are compared as recorded text. They need not be online.
for pair={'Workbook','OutputXlsx';'DataOutput','DataOutputMat';'AnalysisManifest','AnalysisManifest'}'
    path=contained(Result.(pair{1}),folder);
    assert(strcmp(path,contained(Result.StatsResult.(pair{2}),folder)),id,'Saved export output paths disagree.');
end
assert(strcmp(contained(Status.Workbook,folder),canonical(Result.Workbook)),id,'Completion receipt refers to a different workbook.');
csvName=char(string(Plan.InputCSVName));[parent,~,ext]=fileparts(csvName);
assert(isempty(parent)&&strcmpi(ext,'.csv'),id,'Saved export input CSV path is invalid.');
for name={csvName,'BatchSourceRows.csv','IncludedRecordings.csv','ExcludedRecordings.csv'}
    contained(fullfile(folder,name{1}),folder);
end
required={'RecordingRegistry','Table_OxygenSinks_OutCombo','Table_OxygenSinkEvents_OutCombo', ...
    'Table_OxygenSurges_OutCombo','Table_OxygenSurgeEvents_OutCombo'};
variables=matNames(Result.DataOutput);
assert(all(ismember(required,variables)),id,'Required result tables are missing from the combined MAT export.');
coreFiles={'SinkTable4LME.mat','SinkEventTable.mat','SurgeTable4LME.mat','SurgeEventTable.mat'};
for k=1:numel(coreFiles)
    path=contained(fullfile(fileparts(Result.DataOutput),coreFiles{k}),folder);
    checkVariable(path,required{k+1},'table');
end
% Do not load DataOutput table objects or inspect their byte sizes. Legacy
% tables can embed complete traces and native frame pixels. The existing
% recording-level workbook sheets carry the small identity/count summaries.
Info=struct('Directory',folder,'RecordingCount',numel(ids),'ReadOnly',true, ...
    'OriginalRecordingsRechecked',false,'FullFileChecksumsRechecked',false,'ReaderSoftware',getOxygenPipelineVersion());
Info.Burden=availability(Result.Workbook,ids);
Info.CreatorSoftware='not recorded';
creator=Result.StatsResult.StatsInfo;
if isfield(creator,'CalculationSoftware')&&isstruct(creator.CalculationSoftware)&&isfield(creator.CalculationSoftware,'Version')
    Info.CreatorSoftware=char(string(creator.CalculationSoftware.Version));
end
Info.Handoff=handoff(Result,Info);
end

function path=canonical(path)
path=char(java.io.File(char(string(path))).getCanonicalPath());
end
function path=contained(path,folder)
path=canonical(path);id='OxygenDynamics:BatchStatsSavedExport';
assert(startsWith(path,[folder filesep])&&isfile(path),id,'A required export file is missing or outside the selected folder: %s.',path);
d=dir(path);assert(isscalar(d)&&d.bytes>0,id,'A required export file is empty: %s.',path);
end
function fields(value,names,label)
assert(isstruct(value)&&isscalar(value)&&all(isfield(value,names)), ...
    'OxygenDynamics:BatchStatsSavedExport','The saved %s is incomplete or incompatible.',label);
end
function checkVariable(path,name,type)
id='OxygenDynamics:BatchStatsSavedExport';
names=matNames(path);
assert(ismember(name,names),id,'Required %s %s is missing from %s.',type,name,path);
end
function names=matNames(path)
id='OxygenDynamics:BatchStatsSavedExport';
try
    names=who('-file',path);
catch
    error(id,'A required MAT export cannot be read: %s.',path);
end
end
function A=availability(workbook,ids)
A=struct('Known',false,'Events',NaN,'AvailableEvents',NaN,'MissingEvents',NaN, ...
    'Recordings',numel(ids),'AvailableNormalizedRecordings',NaN);
id='OxygenDynamics:BatchStatsSavedExport';
try
    sheets=sheetnames(workbook);
    assert(any(string(sheets)=="RecordingRegistry"),id,'The workbook has no saved RecordingRegistry sheet.');
    registry=readtable(workbook,'Sheet','RecordingRegistry','VariableNamingRule','preserve');
    assert(ismember('RecordingID',registry.Properties.VariableNames)&&height(registry)==numel(ids)&& ...
        isequal(sort(string(registry.RecordingID)),sort(ids)),id,'Workbook and receipt recording identities disagree.');
    if ~any(string(sheets)=="HypoxicBurden_ByRecording"),return;end
    R=readtable(workbook,'Sheet','HypoxicBurden_ByRecording','VariableNamingRule','preserve');
catch err
    error(id,'The saved recording summary cannot be read from the workbook: %s.',err.message);
end
assert(ismember('RecordingID',R.Properties.VariableNames)&&height(R)==numel(ids)&& ...
    isequal(sort(string(R.RecordingID)),sort(ids)),id,'Saved burden and export recording identities disagree.');
required={'HypoxicBurden_per_mm2_per_min','NumEvents','NumValidCompositeEvents'};
if ~all(ismember(required,R.Properties.VariableNames)),return;end
if ~all(varfun(@isnumeric,R(:,required),'OutputFormat','uniform')),return;end
counts=[R.NumEvents R.NumValidCompositeEvents];
assert(all(isfinite(counts(:))&counts(:)>=0&counts(:)==floor(counts(:)))&& ...
    all(R.NumValidCompositeEvents<=R.NumEvents),id,'Saved burden availability counts are inconsistent.');
A.Known=true;A.Events=sum(R.NumEvents);A.AvailableEvents=sum(R.NumValidCompositeEvents);
A.MissingEvents=A.Events-A.AvailableEvents;
A.AvailableNormalizedRecordings=sum(isfinite(R.HypoxicBurden_per_mm2_per_min));
end
function lines=handoff(R,I)
lines={sprintf('Completed automatic export: %d recordings. Saved creator version: %s.',I.RecordingCount,I.CreatorSoftware), ...
    'Receipt check: required files and recording-sheet identities match; MAT variable names are present. Original recordings and full output checksums are not rechecked.', ...
    'Opening this export does not rerun analysis or apply newer calculations or manual review decisions.', ...
    '', 'START HERE FOR POSTPROCESSING', ...
    'HypoxicBurden_ByRecording: one row per recording. HypoxicBurden_per_mm2_per_min is the existing area- and time-normalized burden.', ...
    'HypoxicBurden_EventBased: event rows and ingredients — BurdenAmplitudePercent (%), BurdenArea_um2 (um^2), BurdenDuration_sec (s), PerEventBurdenContribution (% * um^2 * s).', ...
    'Recording normalization: contribution * (1e6 / saved recording area_um2) * (60 / saved recording duration_sec).', ...
    'BurdenAmplitudeSource and HypoxicBurden_ReferencePolicy (when present) identify the saved reference basis; original automatic columns remain evidence.', ...
    'For an unavailable contribution, inspect amplitude, area, duration and EpisodeReferenceStatus when present in the event sheet.', ...
    'MetricDefinitions, MetricBasis and NormalizationGuide explain the existing counts, rates, summaries, units and denominators.', ...
    'HypoxicBurden_GroupSummary: mouse summaries; retain each metric''s NValidMice when interpreting availability.'};
if I.Burden.Known
    A=I.Burden;
    lines{end+1}=sprintf('BURDEN AVAILABILITY: %d / %d normalized recording values available; %d / %d event contributions available (%d unresolved). Counts describe availability, not the fraction of burden measured.', ...
        A.AvailableNormalizedRecordings,A.Recordings,A.AvailableEvents,A.Events,A.MissingEvents);
else
    lines{end+1}='BURDEN AVAILABILITY: not recorded in these saved tables. Export completion does not establish burden availability.';
end
lines=[lines,{'Blank/NaN required contributions keep the complete recording burden unavailable. They are not zero; do not sum only the available rows.', ...
    '', 'MANUAL REVIEWS', ...
    'Not applied to this automatic workbook. Use the Reviewed burden / export tab for an explicitly selected burden-only companion, not a replacement for all automatic statistics. Drafts and experimental previews are not applied.', ...
    '', ['Workbook: ' char(R.Workbook)],['Export folder: ' I.Directory]}];
end
