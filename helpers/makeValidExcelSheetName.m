function SheetName = makeValidExcelSheetName(sheetName)
%MAKEVALIDEXCELSHEETNAME Sanitize dynamic Excel sheet names for MATLAB.

SheetName = char(string(sheetName));
SheetName = regexprep(SheetName,'[:\\/\?\*\[\]]','_');
SheetName = strtrim(SheetName);
if isempty(SheetName)
    SheetName = 'Sheet';
end
if strlength(string(SheetName))>31
    SheetName = char(extractBefore(string(SheetName),32));
end

end
