function [Paths,Info]=prepareBOIBatchImportPaths(Paths,BaseFolder,OldPrefix,LocalFolder,Windows)
%PREPAREBOIBATCHIMPORTPATHS Translate relative separators and identify foreign roots.
% Relative paths remain relative to BaseFolder, including legacy paths with
% one leading backslash. Foreign rooted paths are preserved until the user
% explicitly maps an old directory prefix to an existing local folder.
% Optional Windows selects the path syntax for platform-independent tests.
if nargin<5,Windows=ispc;end
Original=string(Paths(:));Paths=Original;
if nargin>2&&~isempty(OldPrefix)
    assert(nargin>=4,'OxygenDynamics:BatchPathMapping','Choose an existing local folder for the old path prefix.');
    prefix=string(OldPrefix);
    local=string(LocalFolder);
    assert(isscalar(prefix)&&~ismissing(prefix)&&strlength(prefix)>0&& ...
        isscalar(local)&&~ismissing(local)&&strlength(local)>0, ...
        'OxygenDynamics:BatchPathMapping','Supply the old path prefix and an existing local folder.');
    nativeFolder=java.io.File(char(local));
    assert(nativeFolder.isAbsolute()&&isfolder(local),'OxygenDynamics:BatchPathMapping', ...
        'Choose an existing local folder for the old path prefix.');
    local=string(char(nativeFolder.getCanonicalPath()));
    prefix=withoutTrailingSlash(slashPath(prefix));
else
    prefix="";
end
roots=strings(size(Paths));
mapped=false(size(Paths));
for row=1:numel(Paths)
    value=Paths(row);
    if strlength(strtrim(value))==0,continue;end
    [Paths(row),root,remote,windowsPath]=classifyPath(value,BaseFolder,Windows);
    if strlength(root)==0,continue;end
    roots(row)=root;
    if strlength(prefix)==0,continue;end
    [matches,suffix]=matchingSuffix(remote,prefix,windowsPath);
    if ~matches,continue;end
    parts=split(suffix,"/");
    assert(~any(parts==".."),'OxygenDynamics:BatchPathMapping', ...
        'The path %s traverses outside the selected prefix. Edit that recording path directly.',value);
    if strlength(suffix)==0
        Paths(row)=local;
    else
        Paths(row)=string(fullfile(char(local),strrep(char(suffix),'/',filesep)));
    end
    mapped(row)=true;
end
unmapped=strlength(roots)>0&~mapped;
Info=struct('ChangedCount',nnz(Paths~=Original),'MappedCount',nnz(mapped), ...
    'NeedsMapping',table(find(unmapped),Original(unmapped),roots(unmapped), ...
    'VariableNames',{'RowIndex','Path','Root'}), ...
    'SuggestedPrefix',suggestedPrefix(Original(unmapped),roots(unmapped)));
end

function [value,root,remote,windowsPath]=classifyPath(value,base,windows)
root="";remote=slashPath(value);windowsPath=false;
drive=regexp(char(remote),'^[A-Za-z]:','match','once');
unc=startsWith(value,"\\")||(startsWith(value,"//")&&~startsWith(value,"///"));
if ~isempty(drive)
    driveAbsolute=startsWith(value,string(drive)+["/","\"]);
    if windows&&driveAbsolute,return;end
    root=string(drive);windowsPath=true;return;
end
if unc
    % A double forward slash can already identify a local Unix folder.
    if windows||(startsWith(value,"//")&&isfolder(value)),return;end
    fields=split(extractAfter(remote,2),"/");
    fields=fields(strlength(fields)>0);
    root="//"+strjoin(fields(1:min(2,numel(fields))),"/");
    windowsPath=true;return;
end
if startsWith(value,"/")
    if windows
        fields=split(extractAfter(remote,1),"/");
        take=1;
        if any(fields(1)==["Users","Volumes","home","mnt"]),take=2;end
        root="/"+strjoin(fields(1:min(take,numel(fields))),"/");
    elseif contains(value,"\")&&~isfolder(value)&&isfolder(remote)
        value=remote;
    end
    return;
end
% Existing Unix names may contain literal backslashes. Preserve those names
% before adapting relative Windows syntax to the local separator.
if ~windows&&contains(value,"\")&&isfolder(fullfile(base,char(value))),return;end
if startsWith(value,"\"),remote=extractAfter(remote,1);end
if windows
    value=replace(remote,"/","\");
else
    value=remote;
end
end

function out=slashPath(value)
out=replace(value,"\","/");
if ~isempty(regexp(char(out),'^[A-Za-z]:[^/]','once'))
    out=extractBefore(out,3)+"/"+extractAfter(out,2);
end
end

function out=withoutTrailingSlash(value)
out=string(regexprep(char(value),'(?<=.)/+$',''));
end

function [matches,suffix]=matchingSuffix(path,prefix,windowsPath)
path=withoutTrailingSlash(path);
if windowsPath
    matchPath=lower(path);matchPrefix=lower(prefix);
else
    matchPath=path;matchPrefix=prefix;
end
suffix="";
if matchPath==matchPrefix,matches=true;return;end
boundary=matchPrefix;
if ~endsWith(boundary,"/"),boundary=boundary+"/";end
matches=startsWith(matchPath,boundary);
if matches,suffix=string(regexprep(char(extractAfter(path,strlength(boundary))),'^/+',''));end
end

function prefix=suggestedPrefix(paths,roots)
prefix="";
if isempty(paths),return;end
root=roots(1);
windowsPath=startsWith(root,"//")||endsWith(root,":");
if windowsPath
    paths=paths(strcmpi(roots,root));
else
    paths=paths(roots==root);
end
prefix=parentWithinRoot(withoutTrailingSlash(slashPath(paths(1))),root);
for row=2:numel(paths)
    parent=parentWithinRoot(withoutTrailingSlash(slashPath(paths(row))),root);
    while strlength(prefix)>strlength(root)&&~matchingSuffix(parent,prefix,windowsPath)
        prefix=parentWithinRoot(prefix,root);
    end
end
end

function parent=parentWithinRoot(path,root)
parent=root;
lastSlash=find(char(path)=='/',1,'last');
if ~isempty(lastSlash)&&lastSlash>strlength(root)
    parent=extractBefore(path,lastSlash);
end
end
