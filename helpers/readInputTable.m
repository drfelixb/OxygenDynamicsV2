function InputTable = readInputTable(inputFile)
%READINPUTTABLE Read metadata CSV with delimiter fallback.
%
% Some Excel-exported CSV files are parsed as one column when the delimiter
% is forced. This helper keeps the existing fallback behavior in one place.

[~,~,Extension] = fileparts(inputFile);
AllowedExtensions = {'.csv','.txt','.tsv','.xlsx','.xls'};
if ~any(strcmpi(Extension,AllowedExtensions))
    error('OxygenDynamics:UnsupportedTableFile', ...
        ['Cannot read "%s" as a table input because "%s" is not a supported table extension. ', ...
        'Expected one of: %s.'],inputFile,Extension,strjoin(AllowedExtensions,', '));
end

try
    if any(strcmpi(Extension,{'.xlsx','.xls'}))
        InputTable = readtable(inputFile);
    else
        InputTable = readtable(inputFile,'Delimiter',',');
        if width(InputTable)<2
            InputTable = readtable(inputFile);
        end
    end
catch ME
    error('OxygenDynamics:ReadInputTableFailed', ...
        'Could not read table input "%s": %s',inputFile,ME.message);
end

end
