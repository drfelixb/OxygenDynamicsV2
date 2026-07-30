function Values = optionalWrapperInputColumn(InputTable,ColumnName)
%OPTIONALWRAPPERINPUTCOLUMN Return an optional metadata column as cells.

if ismember(ColumnName,InputTable.Properties.VariableNames)
    Values = table2cell(InputTable(:,{ColumnName}));
else
    Values = repmat({''},height(InputTable),1);
end
end
