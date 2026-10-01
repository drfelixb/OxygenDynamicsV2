function AuditPath=createBOIEventAudit(RecordingFolder,OutputFolder)
%CREATEBOIEVENTAUDIT Explicit preserved-source audit, accessible from the GUI.
setupOxygenDynamicsPath;AuditPath='';interactive=nargin==0;
if nargin<1
    RecordingFolder=uigetdir(pwd,'Choose one recording folder containing saved sink and surge masters');
    if isequal(RecordingFolder,0),return;end
end
if nargin<2
    parent=uigetdir(pwd,'Choose a parent for a NEW source-audit folder');if isequal(parent,0),return;end
    [~,name]=fileparts(tempname(parent));OutputFolder=fullfile(parent,['BOIEventAudit_' name]);
end
assert(~isfolder(OutputFolder)&&~isfile(OutputFolder),'OxygenDynamics:AuditOutputExists','Choose a new output folder; previous evidence is preserved.');
% Capture the selected input files before reading, and verify them afterwards.
patterns={{'OxygenSinks_Output*','OxygenSinks_Urefined*.mat'},{'OxygenSurges_Output*','OxygenSurges*.mat'}};
paths=cell(1,2);hashes=cell(1,2);
for k=1:2
    p=patterns{k};files=dir(fullfile(RecordingFolder,p{1},p{2}));
    assert(isscalar(files),'OxygenDynamics:AmbiguousAuditSource','Require one matching master per sign. Select a folder with an unambiguous run.');
    paths{k}=fullfile(files.folder,files.name);hashes{k}=oxygenFileSHA256(paths{k});
end
I=loadRequiredMatVar(paths{1},'AnalysisInfo');timer=tic;
fprintf('Reading the preserved source for event traces and baselines. No detector or statistics rerun. This reads the complete recording (%d frames).\n',I.NFrames);
if interactive
    progress=uifigure('Name','Creating BOI event source audit','Position',[300 300 600 150]);
    label=uilabel(progress,'Position',[20 20 560 110],'WordWrap','on', ...
        'Text',sprintf('Reading all %d source frames to check event traces and baselines. This may take several minutes. Existing detections and statistics are preserved.',I.NFrames)); %#ok<NASGU>
    closeProgress=onCleanup(@()delete(progress));drawnow;
end
try
[A,~]=auditOxygenEventAmplitudeSource(RecordingFolder,'reconstructDetection',false,'outputFolder',OutputFolder);
assert(strcmp(oxygenFileSHA256(I.RawFile),I.RawSHA256),'OxygenDynamics:SourceChanged','Source changed during auditing; output is incomplete.');
for k=1:2,assert(strcmp(hashes{k},oxygenFileSHA256(paths{k})),'OxygenDynamics:NativeMaskChanged','Master changed during auditing; output is incomplete.');end
AuditPath=fullfile(OutputFolder,'event-amplitude-audit.mat');
Receipt=struct('Schema','boi-created-event-audit-1','CreatedUTC',char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ssXXX')), ...
    'AuditSHA256',oxygenFileSHA256(AuditPath),'SourceSHA256',I.RawSHA256,'MasterPaths',{paths},'MasterSHA256',{hashes}, ...
    'EventCount',height(A),'MeasurementMismatches',sum(~A.MeasurementMatches),'WrongDirectionCount',sum(A.WrongDirection), ...
    'ElapsedSeconds',toc(timer),'DetectorReruns',0,'StatisticsReruns',0,'ScientificStatus','not_established', ...
    'ImplementationSHA256',oxygenFileSHA256(which('auditOxygenEventAmplitudeSource')));
fid=fopen(fullfile(OutputFolder,'AuditCreationReceipt.json'),'w');assert(fid>=0);clean=onCleanup(@()fclose(fid));fprintf(fid,'%s\n',jsonencode(Receipt,'PrettyPrint',true));clear clean
fid=fopen(fullfile(OutputFolder,'README.txt'),'w');assert(fid>=0);clean=onCleanup(@()fclose(fid));
fprintf(fid,['Preserved-source event audit, created explicitly from existing masters.\n' ...
    'Read event-amplitude-audit.mat in the MATLAB event inspector or attach it from a saved window review.\n' ...
    'Both signs and unavailable/negative amplitudes remain visible. No detector or statistics rerun.\n' ...
    'AuditCreationReceipt.json binds source/master checksums to this new audit. Older audits retain their original provenance limits.\n' ...
    'This does not establish anatomical or physiological validity. Local paths and original metadata are intentionally retained.\n']);
catch err
    if ~isfolder(OutputFolder),mkdir(OutputFolder);end
    failure=struct('Status','failed_incomplete','Identifier',err.identifier,'Message',err.message,'ScientificStatus','not_established');
    fid=fopen(fullfile(OutputFolder,'AuditCreationFailure.json'),'w');
    if fid>=0,fprintf(fid,'%s\n',jsonencode(failure,'PrettyPrint',true));fclose(fid);end
    rethrow(err);
end
end
