function Value = loadOptionalMatVar(MatFile,VarName,DefaultValue)
%LOADOPTIONALMATVAR Load a variable from a MAT file if present.

if nargin<3
    DefaultValue = [];
end

Value = DefaultValue;
if ismember(VarName,who('-file',MatFile))
    FileData = load(MatFile,VarName);
    Value = FileData.(VarName);
end

end
