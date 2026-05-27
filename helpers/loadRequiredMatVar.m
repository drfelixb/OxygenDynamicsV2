function Value = loadRequiredMatVar(MatFile,VarName)
%LOADREQUIREDMATVAR Load a required variable from a MAT file.

FileData = load(MatFile,VarName);
if ~isfield(FileData,VarName)
    error('Required variable %s was not found in %s.',VarName,MatFile);
end

Value = FileData.(VarName);
end
