function Receipt=exportBOIWindowReview(Review,Index,Folder,DictionaryPath,kind)
%EXPORTBOIWINDOWREVIEW Export a selected saved window and its replay evidence.
if nargin<4,DictionaryPath='';end
if nargin<5,kind='sink';end
assert(~isfolder(Folder)&&~isfile(Folder),'OxygenDynamics:WindowReviewOutputExists','Choose a new folder; earlier evidence is preserved.');
assert(strcmp(oxygenFileSHA256(Review.Path),Review.SHA256),'OxygenDynamics:WindowReviewChanged','Saved results changed since opening. Reopen before export.');
D=buildBOIWindowReviewData(Review,Index,kind);
surgeStatus='not_present_in_saved_window_export';
if isfield(Review,'HasSurgeWindows')&&Review.HasSurgeWindows,surgeStatus='available_separate_saved_windows';end
[~,dictionary,source]=getBOIMeasurementDictionary(DictionaryPath);dictHash=oxygenFileSHA256(source);dictText=fileread(source);
role='current_definitions_context_only';if ~isempty(DictionaryPath),role='selected_saved_dictionary; historical_binding_not_automatically_verified';end
mkdir(Folder);
for item={'Metrics','Checks','Frames','Events','RecordingExposure','QC'}
    writetable(D.(item{1}),fullfile(Folder,[item{1} '.csv']));
end
Receipt=struct('Schema','boi-window-review-export-1','RecordedUTC',char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ssXXX')), ...
    'ResultsPath',Review.Path,'ResultsSHA256',Review.SHA256,'ScientificStatus','not_established', ...
    'SavedWindow',table2struct(D.Window),'InputContract',D.Contract,'Metrics',D.Metrics,'Checks',D.Checks, ...
    'DictionarySHA256',dictHash,'DictionaryVersion',dictionary.Version,'DictionaryRole',role, ...
    'WindowOutcomeSign',char(kind),'SurgeWindowOutcomes',surgeStatus, ...
    'ReplayScope','Saved frame union areas and event timing; no native mask reconstruction, detection or statistics run');
if isfield(Review,'StatsInfo'),Receipt.SavedStatsInfo=Review.StatsInfo;end
Receipt.Implementation=struct('Function',{},'SHA256',{});
for name={'loadBOIWindowReview','buildBOIWindowReviewData','exportBOIWindowReview'}
    Receipt.Implementation(end+1)=struct('Function',name{1},'SHA256',oxygenFileSHA256(which(name{1})));
end
save(fullfile(Folder,'SelectedWindowReview.mat'),'D','Receipt');
writeText(fullfile(Folder,'SelectedWindowReview.json'),jsonencode(Receipt,'PrettyPrint',true));
writeText(fullfile(Folder,'BOIMeasurementDictionary.json'),dictText);
writeText(fullfile(Folder,'WindowReview.txt'),strjoin(string(D.Details),newline));
writeText(fullfile(Folder,'README.txt'),sprintf(['Local saved-window evidence. Contains original paths/metadata; review before public sharing.\n' ...
    'Frames.csv retains fractional window overlap and saved union/tissue area-time ingredients.\n' ...
    'Events.csv retains every selected-sign event in the recording, including events outside this window.\n' ...
    'Membership flags are 1/0. NaN (MAT/CSV) or null (JSON) denotes unavailable, never zero.\n' ...
    'Metrics.csv replays three selected-sign window quantities. Checks.csv records numerical/identity-context disagreements.\n' ...
    'A match is arithmetic agreement, not scientific acceptance. Surge window availability: %s. Selected sign: %s.\n' ...
    'Dictionary role: %s. Current or selected definitions are not silently bound to historical calculations.\n'],surgeStatus,char(kind),role));
files=dir(Folder);manifest=struct('Name',{},'SHA256',{});
for k=1:numel(files)
    if ~files(k).isdir,manifest(end+1)=struct('Name',files(k).name,'SHA256',oxygenFileSHA256(fullfile(Folder,files(k).name)));end %#ok<AGROW>
end
writeText(fullfile(Folder,'ArtifactChecksums.json'),jsonencode(manifest,'PrettyPrint',true));
end
function writeText(path,text)
fid=fopen(path,'w');assert(fid>=0);cleanup=onCleanup(@()fclose(fid));fprintf(fid,'%s\n',text);
end
