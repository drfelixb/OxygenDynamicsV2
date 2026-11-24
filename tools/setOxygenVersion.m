function setOxygenVersion(newVersion)
%SETOXYGENVERSION Set the approved checkout version and its current mirrors.
% Use X.Y.Z-dev, X.Y.Z-rc.N or X.Y.Z. A release date is written for release
% versions and candidates only. This command never publishes a release.
arguments
    newVersion (1,1) string
end
component='(?:0|[1-9][0-9]*)';
syntax=['^' component '\.' component '\.' component '(?:-dev|-rc\.[1-9][0-9]*)?$'];
assert(~ismissing(newVersion)&&~isempty(regexp(char(newVersion),syntax,'once')), ...
    'OxygenDynamics:VersionFormat','Expected X.Y.Z-dev, X.Y.Z-rc.N or X.Y.Z.');
root=fileparts(fileparts(mfilename('fullpath')));
files={'core/getOxygenPipelineVersion.m','CITATION.cff','README.md','INSTALLATION.md','DISTRIBUTION_STATUS.md'};
original=cell(size(files)); updated=cell(size(files));
for k=1:numel(files),original{k}=fileread(fullfile(root,files{k}),'Encoding','UTF-8');end
v=char(newVersion);
updated{1}=changeOne(original{1},'(?m)^Info\.Version = ''[^'']+'';',sprintf('Info.Version = ''%s'';',v));
changedVersion=~strcmp(original{1},updated{1});
if changedVersion
    stamp=char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd HH:mm:ss XXX'));
    updated{1}=changeOne(updated{1},'(?m)^Info\.BuildTimestamp = ''[^'']+'';',sprintf('Info.BuildTimestamp = ''%s'';',stamp));
end
updated{2}=changeOne(original{2},'(?m)^version: "[^"]+"',sprintf('version: "%s"',v));
datePattern='(?m)^date-released: [^\r\n]+\r?\n';
if endsWith(newVersion,"-dev")
    updated{2}=regexprep(updated{2},datePattern,'');
elseif changedVersion || isempty(regexp(updated{2},datePattern,'once'))
    day=char(datetime('today','Format','yyyy-MM-dd'));
    updated{2}=regexprep(updated{2},datePattern,'');
    updated{2}=changeOne(updated{2},'(?m)^version: "[^"]+"',sprintf('version: "%s"\ndate-released: %s',v,day));
end
updated{3}=changeOne(original{3},'(?m)^Checkout version: \*\*[^*]+\*\*\.',sprintf('Checkout version: **%s**.',v));
updated{4}=changeOne(original{4},'(?m)^The version should be `[^`]+`\.',sprintf('The version should be `%s`.',v));
updated{5}=changeOne(original{5},'(?m)^Checkout version: \*\*[^*]+\*\*\.',sprintf('Checkout version: **%s**.',v));

% Stage all replacements before touching the originals. If publication of
% one file fails, restore the earlier replacements from their original bytes.
changed=find(~cellfun(@strcmp,original,updated));
staged=cell(size(files)); published=[];
try
    for k=changed
        staged{k}=tempname(fileparts(fullfile(root,files{k})));
        writeText(staged{k},updated{k});
    end
    for k=changed
        movefile(staged{k},fullfile(root,files{k}),'f');
        published(end+1)=k; %#ok<AGROW>
    end
catch err
    for k=published,writeText(fullfile(root,files{k}),original{k});end
    for k=changed,if ~isempty(staged{k}) && isfile(staged{k}),delete(staged{k});end,end
    rethrow(err)
end
rehash;
end

function out=changeOne(text,pattern,replacement)
assert(numel(regexp(text,pattern))==1,'OxygenDynamics:VersionMarker', ...
    'Expected exactly one current version declaration matching %s.',pattern);
out=regexprep(text,pattern,replacement);
end

function writeText(path,text)
[f,msg]=fopen(path,'wb');
assert(f>=0,'OxygenDynamics:VersionWrite','%s',msg);
bytes=unicode2native(text,'UTF-8');
clean=onCleanup(@()fclose(f));
count=fwrite(f,bytes,'uint8');
assert(count==numel(bytes),'OxygenDynamics:VersionWrite','Incomplete write to %s.',path);
end
