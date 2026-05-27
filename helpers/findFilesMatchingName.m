function MatchingFilePaths = findFilesMatchingName(folderPath,searchText,varargin)
%FINDFILESMATCHINGNAME Return full paths whose names contain searchText.

Parser = inputParser;
Parser.addParameter('required',true,@islogical);
Parser.addParameter('label',searchText,@(Value) ischar(Value) || isstring(Value));
Parser.parse(varargin{:});

FolderListing = dir(folderPath);
if isempty(FolderListing)
    MatchingFilePaths = {};
else
    IsMatch = contains({FolderListing.name},searchText);
    MatchingFilePaths = arrayfun(@(Item) fullfile(Item.folder,Item.name), ...
        FolderListing(IsMatch),'UniformOutput',false);
end

if Parser.Results.required && isempty(MatchingFilePaths)
    error('No %s files or folders were found in %s.',char(Parser.Results.label),folderPath);
end

end
