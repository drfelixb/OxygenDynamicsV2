function Batch=readBOIBatchCSV(Path,DuplicateMode)
%READBOIBATCHCSV Open a UTF-8 CSV as text; no type inference or execution.
% Quoted commas, quotes, line breaks, arbitrary descriptive headers, blanks
% and leading-zero IDs survive import. Relative paths use the CSV directory
% and adapt to the local separator. Foreign absolute paths need a mapping.
% A saved working-file marker is kept in Batch.WorkingCSV, outside Rows.
% Duplicate IDs are rejected by default. With explicit 'new-copies', keep
% each first identity, give its later copies new IDs, and clear copied links
% and outcome states. The source CSV is never changed during import.
if nargin<2,DuplicateMode='reject';end
assert((ischar(DuplicateMode)&&isrow(DuplicateMode))|| ...
    (isstring(DuplicateMode)&&isscalar(DuplicateMode)&&~ismissing(DuplicateMode)), ...
    'OxygenDynamics:InvalidBatchImportMode','Choose reject or new-copies for duplicate batch row identities.');
assert(any(string(DuplicateMode)==["reject","new-copies"]), ...
    'OxygenDynamics:InvalidBatchImportMode','Choose reject or new-copies for duplicate batch row identities.');
Path=batchCSVPath(Path);
fid=fopen(Path,'rb');
assert(fid>=0,'OxygenDynamics:BatchCSVRead','Cannot read the batch CSV: %s',Path);
cleanup=onCleanup(@()fclose(fid));
bytes=fread(fid,Inf,'*uint8')';
text=native2unicode(bytes,'UTF-8');
if ~isempty(text)&&double(text(1))==65279,text=text(2:end);end
records=parseCSV(text);
assert(~isempty(records),'OxygenDynamics:BatchCSVRead','The batch CSV is empty.');
headers=records{1};
assert(all(strlength(strtrim(string(headers)))>0), ...
    'OxygenDynamics:BatchColumnCollision','CSV headers cannot be blank.');
assert(numel(unique(lower(string(headers))))==numel(headers), ...
    'OxygenDynamics:BatchColumnCollision','CSV headers must be unique, including their letter case.');
assert(any(strcmp(headers,'Paths')),'OxygenDynamics:BatchMissingPaths', ...
    'The CSV needs a Paths column, with one recording folder per row.');
rows=table();
for column=1:numel(headers)
    values=strings(numel(records)-1,1);
    for row=2:numel(records)
        assert(numel(records{row})==numel(headers),'OxygenDynamics:BatchCSVRead', ...
            'CSV record %d has %d values; its header has %d. Check quoting and commas.',row,numel(records{row}),numel(headers));
        values(row-1)=string(records{row}{column});
    end
    rows.(headers{column})=values;
end
copyCount=0;
if strcmp(DuplicateMode,'new-copies')
    [rows,copyCount]=renewCopiedIdentities(rows);
end
Batch=createBOIBatch(rows,fileparts(Path));
Batch=restoreInheritance(Batch);
marker='BOIBatchWorkingCSV';
marked=ismember(marker,Batch.Rows.Properties.VariableNames);
Batch.WorkingCSV=marked&&all(Batch.Rows.(marker)=="boi-working-1");
if marked,Batch.Rows(:,{marker})=[];end
[Batch.Rows.Paths,Batch.PathImport]=prepareBOIBatchImportPaths(Batch.Rows.Paths,Batch.BaseFolder);
Batch.ImportNotice='';
if copyCount>0
    Batch.ImportNotice=sprintf(['Created new identities for %d copied row(s). ' ...
        'Their previous result links and analysis/review states were cleared; ' ...
        'descriptive metadata and acquisition values were preserved. The original CSV is unchanged.'],copyCount);
end
Batch.FilePath=Path;
md=java.security.MessageDigest.getInstance('SHA-256');md.update(typecast(bytes,'int8'));
Batch.FileSHA256=lower(reshape(dec2hex(typecast(md.digest(),'uint8'),2)',1,[]));
end

function [rows,copyCount]=renewCopiedIdentities(rows)
copyCount=0;
if ~ismember('BatchRowID',rows.Properties.VariableNames),return;end
copied=false(height(rows),1);seen=strings(0,1);
for row=1:height(rows)
    identity=rows.BatchRowID(row);
    if strlength(strtrim(identity))==0,continue;end
    if any(seen==identity)
        copied(row)=true;
    else
        seen(end+1,1)=identity; %#ok<AGROW>
    end
end
copyCount=nnz(copied);
if copyCount==0,return;end
for row=find(copied)'
    rows.BatchRowID(row)=string(char(java.util.UUID.randomUUID()));
end
defaults={'InputStatus','Unchecked';'AnalysisStatus','Not analyzed'; ...
    'ResultCheck','Unchecked';'ReviewStatus','Not reviewed';'RunID','';'RunFolder',''; ...
    'StartedUTC','';'CompletedUTC','';'SoftwareVersion','';'BOIBatchSourceCommit','';'BOIBatchSourceState','';'Stage','';'ElapsedSeconds','';'Message','';'AttemptHistory','[]'};
for k=1:size(defaults,1)
    if ismember(defaults{k,1},rows.Properties.VariableNames)
        rows.(defaults{k,1})(copied)=string(defaults{k,2});
    end
end
end

function Path=batchCSVPath(Path)
assert((ischar(Path)&&isrow(Path))||(isstring(Path)&&isscalar(Path)&&~ismissing(Path)), ...
    'OxygenDynamics:BatchCSVRead','Supply one CSV filename.');
assert(strlength(string(Path))>0,'OxygenDynamics:BatchCSVRead','Supply one CSV filename.');
file=java.io.File(char(Path));
if ~file.isAbsolute(),file=java.io.File(fullfile(pwd,char(Path)));end
Path=char(file.getCanonicalPath());
end

function records=parseCSV(text)
% Strict record parsing avoids import-option type conversion and header edits.
records={};fields={};value='';state=0;index=1;
while index<=numel(text)
    c=text(index);
    if state==2
        if c=='"',state=3;else,value(end+1)=c;end %#ok<AGROW>
    elseif state==3&&c=='"'
        value(end+1)='"';state=2; %#ok<AGROW>
    elseif c==','
        fields{end+1}=value;value='';state=0; %#ok<AGROW>
    elseif c==char(10)||c==char(13)
        fields{end+1}=value;records{end+1}=fields; %#ok<AGROW>
        fields={};value='';state=0;
        if c==char(13)&&index<numel(text)&&text(index+1)==char(10),index=index+1;end
    elseif state==3
        error('OxygenDynamics:BatchCSVRead','Unexpected text after a closing quote in CSV record %d.',numel(records)+1);
    elseif c=='"'
        assert(state==0,'OxygenDynamics:BatchCSVRead','Unexpected quote in CSV record %d.',numel(records)+1);
        state=2;
    else
        value(end+1)=c;state=1; %#ok<AGROW>
    end
    index=index+1;
end
assert(state~=2,'OxygenDynamics:BatchCSVRead','The CSV ends inside a quoted value.');
if state~=0||~isempty(fields)||~isempty(value)
    fields{end+1}=value;records{end+1}=fields;
end
end

function Batch=restoreInheritance(Batch)
fields={'SampleF','Pixelsize','BOISupportProfile'};
originNames={'BOIBatchSampleFOrigin','BOIBatchPixelsizeOrigin','BOIBatchBOISupportProfileOrigin'};
sharedNames={'BOIBatchSharedSampleF','BOIBatchSharedPixelsize','BOIBatchSharedBOISupportProfile'};
names=[originNames sharedNames {'BOIBatchSharedConfirmed'}];
present=ismember(names,Batch.Rows.Properties.VariableNames);
if ~any(present),return;end
assert(all(present),'OxygenDynamics:BatchCSVRead', ...
    'Batch inheritance columns are incomplete. Restore the complete saved CSV or remove all BOIBatch inheritance columns.');
if height(Batch.Rows)>0
    confirmed=Batch.Rows.BOIBatchSharedConfirmed;
    assert(all(confirmed==confirmed(1))&&any(confirmed(1)==["true","false"]), ...
        'OxygenDynamics:BatchCSVRead','Saved shared-setting confirmation is inconsistent.');
    Batch.SharedConfirmed=confirmed(1)=="true";
    for k=1:numel(fields)
        values=Batch.Rows.(sharedNames{k});origins=Batch.Rows.(originNames{k});
        assert(all(values==values(1))&&all(ismember(origins,["row","shared","missing"])), ...
            'OxygenDynamics:BatchCSVRead','Saved %s inheritance is inconsistent.',fields{k});
        Batch.Shared.(fields{k})=char(values(1));
        inherited=origins=="shared";
        assert(~any(inherited)||Batch.SharedConfirmed,'OxygenDynamics:BatchCSVRead','Unconfirmed settings cannot be inherited.');
        % If an external editor changed a resolved cell, retain it as an
        % explicit override instead of silently replacing that edit.
        inherited=inherited&Batch.Rows.(fields{k})==values;
        Batch.Rows.(fields{k})(inherited)="";
    end
end
Batch.Rows(:,names)=[];
end
