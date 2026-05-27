function latestfile = getlatestfile(directory,type,filetype,partname)
%GETLATESTFILE Return the newest matching file or folder without changing pwd.
%
% latestfile = getlatestfile(directory)
% latestfile = getlatestfile(directory,'folder')
% latestfile = getlatestfile(directory,'file','*.mat')
% latestfile = getlatestfile(directory,'file','*.mat','*Combo')
% latestfile = getlatestfile(directory,'folder',[],'Stats_Output')

if nargin < 2 || isempty(type)
    disp('The most recent file of any type will be returned')
    type = 'file';
end
if nargin < 3
    filetype = [];
end
if nargin < 4
    partname = [];
end

if ~isfolder(directory)
    error('Directory not found: %s',directory);
end

switch lower(type)
    case 'file'
        Matches = listMatchingEntries(directory,filetype,partname,false);
    case 'folder'
        Matches = listMatchingEntries(directory,[],partname,true);
    otherwise
        error('type must be either "file" or "folder".');
end

if isempty(Matches)
    latestfile = '';
    return
end

[~,Index] = max([Matches.datenum]);
latestfile = fullfile(Matches(Index).folder,Matches(Index).name);

end

function Matches = listMatchingEntries(directory,filetype,partname,wantFolder)

if isempty(filetype)
    filePattern = '*';
else
    filePattern = filetype;
end

if isempty(partname)
    namePattern = filePattern;
else
    if isempty(filetype)
        namePattern = [partname,'*'];
    else
        namePattern = [partname,filePattern];
    end
end

Matches = dir(fullfile(directory,namePattern));
Matches = Matches(~ismember({Matches.name},{'.','..'}));
if wantFolder
    Matches = Matches([Matches.isdir]);
else
    Matches = Matches(~[Matches.isdir]);
end

end
