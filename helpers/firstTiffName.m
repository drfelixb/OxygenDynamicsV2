function FileName = firstTiffName(FileList)
%FIRSTTIFFNAME Return the first TIFF name from a dir result, or empty text.

if isempty(FileList)
    FileName = '';
else
    FileName = FileList(1).name;
end

end
