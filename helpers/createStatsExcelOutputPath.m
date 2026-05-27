function OutputXlsx = createStatsExcelOutputPath(StatsOutputFolderPath,InputCsv)
%CREATESTATSEXECELOUTPUTPATH Build stats Excel filename with input CSV suffix.

InputCsvText = char(InputCsv);
InputCsvParts = regexp(InputCsvText,'[^\\/]+$','match','once');
if isempty(InputCsvParts)
    InputCsvParts = InputCsvText;
end
InputCsvBaseName = regexprep(InputCsvParts,'\.[^.]*$','');
InputCsvBaseName = regexprep(InputCsvBaseName,'[<>:"/\\|?*\x00-\x1F]','_');
InputCsvBaseName = regexprep(InputCsvBaseName,'\s+','_');
InputCsvBaseName = strtrim(InputCsvBaseName);

if isempty(InputCsvBaseName)
    OutputFileName = 'FilteredData.xlsx';
else
    OutputFileName = ['FilteredData_',InputCsvBaseName,'.xlsx'];
end

OutputXlsx = fullfile(StatsOutputFolderPath,OutputFileName);

end
