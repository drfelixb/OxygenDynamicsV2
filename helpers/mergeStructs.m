function Merged = mergeStructs(varargin)
%MERGESTRUCTS Merge scalar structs from left to right.

Merged = struct();
for structi = 1:nargin
    ThisStruct = varargin{structi};
    if isempty(ThisStruct)
        continue
    end
    FieldNames = fieldnames(ThisStruct);
    for fieldi = 1:numel(FieldNames)
        Merged.(FieldNames{fieldi}) = ThisStruct.(FieldNames{fieldi});
    end
end

end
