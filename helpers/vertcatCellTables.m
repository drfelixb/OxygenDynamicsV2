function OutTable = vertcatCellTables(TableCells)
% Preserve an empty schema, while ignoring empty rows when measured rows exist.
TableCells = TableCells(cellfun(@istable,TableCells));
if isempty(TableCells),OutTable=table();return;end
nonempty=~cellfun(@isempty,TableCells);
if any(nonempty),TableCells=TableCells(nonempty);else,OutTable=TableCells{1};return;end
names=TableCells{1}.Properties.VariableNames;
for i=2:numel(TableCells)
    assert(isequal(sort(names),sort(TableCells{i}.Properties.VariableNames)), ...
        'OxygenDynamics:IncompatibleAnalysisSchemas', ...
        'Recordings have different analysis schemas. Rerun their master analyses with the same version before pooling.');
    TableCells{i}=TableCells{i}(:,names);
end
OutTable=vertcat(TableCells{:});
end
