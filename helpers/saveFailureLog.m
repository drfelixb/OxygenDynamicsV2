function saveFailureLog(failures,fileName,variableName)
%SAVEFAILURELOG Save non-empty wrapper failure logs with a chosen variable name.

if isempty(failures)
    return
end

SaveStruct = struct();
SaveStruct.(variableName) = failures;
save(fileName,'-struct','SaveStruct');

end
