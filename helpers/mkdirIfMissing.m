function mkdirIfMissing(folderPath)
%MKDIRIFMISSING Create a folder when it does not already exist.

if ~isempty(folderPath) && ~isfolder(folderPath)
    mkdir(folderPath);
end

end
