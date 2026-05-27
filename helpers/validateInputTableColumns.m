function validateInputTableColumns(InputTable,requiredColumns,sourceName)
%VALIDATEINPUTTABLECOLUMNS Error clearly if metadata CSV columns are missing.

if nargin<3 || isempty(sourceName)
    sourceName = 'input table';
end

if ~istable(InputTable)
    error('validateInputTableColumns:NotTable','%s must be a MATLAB table.',sourceName);
end

requiredColumns = cellstr(requiredColumns);
availableColumns = InputTable.Properties.VariableNames;
missingColumns = setdiff(requiredColumns,availableColumns,'stable');

if ~isempty(missingColumns)
    error('validateInputTableColumns:MissingColumns', ...
        '%s is missing required column(s): %s',sourceName,strjoin(missingColumns,', '));
end

end
