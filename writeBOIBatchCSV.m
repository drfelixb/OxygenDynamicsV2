function [SavedBatch,BackupPath]=writeBOIBatchCSV(Batch,Path)
%WRITEBOIBATCHCSV Save a portable text CSV without overwriting external edits.
% The saved acquisition cells are resolved and source/result paths absolute.
% Implicit detection support is stored blank to preserve the default on
% reopening. Extra software columns preserve shared-setting inheritance.
% The working-file marker permits reopening for writeback. Imported sources
% require a new destination. Working-file updates require their original
% SHA-256. Replacement is atomic and retains a prior copy.
if nargin<2||isempty(Path)
    assert(isfield(Batch,'FilePath')&&~isempty(Batch.FilePath), ...
        'OxygenDynamics:BatchCSVWrite','Choose a CSV filename for this batch.');
    Path=Batch.FilePath;
end
assert((ischar(Path)&&isrow(Path))||(isstring(Path)&&isscalar(Path)&&~ismissing(Path)), ...
    'OxygenDynamics:BatchCSVWrite','Supply one CSV filename.');
assert(strlength(string(Path))>0,'OxygenDynamics:BatchCSVWrite','Supply one CSV filename.');
file=java.io.File(char(Path));
if ~file.isAbsolute(),file=java.io.File(fullfile(pwd,char(Path)));end
Path=char(file.getCanonicalPath());
parent=fileparts(Path);
assert(isfolder(parent),'OxygenDynamics:BatchCSVWrite','The CSV destination folder does not exist: %s',parent);
checked=createBOIBatch(Batch.Rows,Batch.BaseFolder);
SavedBatch=Batch;SavedBatch.Rows=checked.Rows;
[Resolved,Origins]=resolveBOIBatch(SavedBatch);
fields={'SampleF','Pixelsize','BOISupportProfile'};
if height(Resolved)==0
    hasSharedSettings=Batch.SharedConfirmed;
    for k=1:numel(fields)
        hasSharedSettings=hasSharedSettings||strlength(strtrim(string(Batch.Shared.(fields{k}))))>0;
    end
    assert(~hasSharedSettings,'OxygenDynamics:BatchCSVWrite', ...
        'Add a recording row before saving shared settings; an empty CSV has no row to store them.');
end
originNames={'BOIBatchSampleFOrigin','BOIBatchPixelsizeOrigin','BOIBatchBOISupportProfileOrigin'};
sharedNames={'BOIBatchSharedSampleF','BOIBatchSharedPixelsize','BOIBatchSharedBOISupportProfile'};
for k=1:numel(fields)
    Resolved.(originNames{k})=Origins.(fields{k});
    Resolved.(sharedNames{k})=repmat(string(Batch.Shared.(fields{k})),height(Resolved),1);
end
defaultSupport=Origins.BOISupportProfile=="default";
Resolved.BOISupportProfile(defaultSupport)="";
Resolved.BOIBatchBOISupportProfileOrigin(defaultSupport)="missing";
confirmed="false";if Batch.SharedConfirmed,confirmed="true";end
Resolved.BOIBatchSharedConfirmed=repmat(confirmed,height(Resolved),1);
Resolved.BOIBatchWorkingCSV=repmat("boi-working-1",height(Resolved),1);
sameOpened=false;
if isfield(Batch,'FilePath')&&~isempty(Batch.FilePath)
    previous=char(java.io.File(char(Batch.FilePath)).getCanonicalPath());
    if ispc,sameOpened=strcmpi(previous,Path);else,sameOpened=strcmp(previous,Path);end
end
assert(~sameOpened||~isfield(Batch,'WorkingCSV')||isequal(Batch.WorkingCSV,true), ...
    'OxygenDynamics:BatchImportedCSV','This is the imported CSV. Use Save as… and choose a new filename for the working CSV.');
expected='';
if sameOpened&&isfield(Batch,'FileSHA256'),expected=char(Batch.FileSHA256);end
checkDestination(Path,sameOpened,expected);
lock=[Path '.boi-write-lock'];
assert(java.io.File(lock).mkdir(),'OxygenDynamics:BatchCSVConflict', ...
    'The CSV is locked by another save, or its destination is not writable. Save a recovered copy to a new filename: %s',Path);
lockCleanup=onCleanup(@()removeLock(lock));
checkDestination(Path,sameOpened,expected);
temporary=[tempname(parent) '.csv'];
temporaryCleanup=onCleanup(@()removeTemporary(temporary));
fid=fopen(temporary,'wb');
assert(fid>=0,'OxygenDynamics:BatchCSVWrite','Cannot create a temporary CSV in %s.',parent);
try
    writeRecord(fid,string(Resolved.Properties.VariableNames));
    for row=1:height(Resolved)
        writeRecord(fid,Resolved{row,:});
    end
catch err
    fclose(fid);rethrow(err);
end
assert(fclose(fid)==0,'OxygenDynamics:BatchCSVWrite','The temporary CSV could not be closed successfully.');
newHash=csvFileHash(temporary);
checkDestination(Path,sameOpened,expected);
BackupPath='';
if sameOpened
    BackupPath=[Path '.backup-' char(java.util.UUID.randomUUID()) '.csv'];
    [ok,message]=copyfile(Path,BackupPath);
    assert(ok,'OxygenDynamics:BatchCSVWrite','The previous CSV could not be backed up: %s',message);
    assert(strcmp(csvFileHash(BackupPath),expected),'OxygenDynamics:BatchCSVConflict', ...
        'The CSV changed while its previous copy was being saved. The destination is unchanged; reconcile the external edit.');
    checkDestination(Path,sameOpened,expected);
end
source=java.io.File(temporary).toPath();destination=java.io.File(Path).toPath();
try
    if sameOpened
        options=javaArray('java.nio.file.CopyOption',2);
        options(1)=java.nio.file.StandardCopyOption.ATOMIC_MOVE;
        options(2)=java.nio.file.StandardCopyOption.REPLACE_EXISTING;
        java.nio.file.Files.move(source,destination,options);
    else
        % An atomic hard-link publication also refuses a competing new file.
        % Both names are in the same directory/filesystem. The temporary name
        % is removed by cleanup after the complete destination is published.
        java.nio.file.Files.createLink(destination,source);
    end
catch err
    if ~sameOpened&&isfile(Path)
        error('OxygenDynamics:BatchCSVConflict','Another writer created the destination. Save a recovered copy to a new filename: %s',Path);
    end
    error('OxygenDynamics:BatchCSVWrite','Atomic CSV save failed; the previous file is preserved. %s',err.message);
end
% Rebase the editable document to its saved location. Existing sources and
% result links keep their resolved identity; subsequently entered relative
% paths use this CSV's directory. Acquisition override blanks remain intact.
SavedBatch.Rows.Paths=Resolved.Paths;
SavedBatch.Rows.RunFolder=Resolved.RunFolder;
SavedBatch.BaseFolder=parent;
SavedBatch.FilePath=Path;SavedBatch.FileSHA256=newHash;
SavedBatch.WorkingCSV=true;
end

function writeRecord(fid,values)
values=string(values);values(ismissing(values))="";
% Quote every value, including headers. This preserves empty strings,
% whitespace, Unicode, embedded newlines and numeric-looking identifiers.
quote=string(char(34));
quoted=quote+replace(values,quote,quote+quote)+quote;
bytes=unicode2native(char(strjoin(quoted,",")+string(char(10))),'UTF-8');
assert(fwrite(fid,bytes,'uint8')==numel(bytes),'OxygenDynamics:BatchCSVWrite','The temporary CSV write was incomplete.');
end

function checkDestination(Path,sameOpened,expected)
if sameOpened
    assert(~isempty(expected)&&isfile(Path),'OxygenDynamics:BatchCSVConflict', ...
        'The opened CSV was removed or has no original checksum. Reopen it or save a recovered copy to a new filename.');
    assert(strcmp(csvFileHash(Path),expected),'OxygenDynamics:BatchCSVConflict', ...
        'The CSV changed outside this editor. Reopen and reconcile it, or save a recovered copy to a new filename.');
else
    assert(~isfile(Path)&&~isfolder(Path),'OxygenDynamics:BatchCSVConflict', ...
        'This destination already exists. Open that CSV first, or save to a new filename.');
end
end

function hash=csvFileHash(Path)
fid=fopen(Path,'rb');
assert(fid>=0,'OxygenDynamics:BatchCSVWrite','Cannot read the CSV checksum: %s',Path);
cleanup=onCleanup(@()fclose(fid));
md=java.security.MessageDigest.getInstance('SHA-256');
while true
    bytes=fread(fid,1024*1024,'*uint8');
    if isempty(bytes),break;end
    md.update(typecast(bytes,'int8'));
end
hash=lower(reshape(dec2hex(typecast(md.digest(),'uint8'),2)',1,[]));
end

function removeTemporary(Path)
if isfile(Path),delete(Path);end
end

function removeLock(Path)
if isfolder(Path),rmdir(Path);end
end
