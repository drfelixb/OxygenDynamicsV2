function GuiTables = buildOxygenRegressionGuiTables(RegressionStatus,RegressionResult)
%BUILDOXYGENREGRESSIONGUITABLES Prepare regression status tables for the GUI.

if nargin<1
    RegressionStatus = [];
end
if nargin<2
    RegressionResult = [];
end

GuiTables = struct();
GuiTables.StatusTable = regressionStatusTable(RegressionStatus);
GuiTables.SummaryTable = regressionActionTable(RegressionResult);
GuiTables.ArchiveTable = regressionArchiveTable(RegressionStatus);

end

function StatusTable = regressionStatusTable(RegressionStatus)

if isstruct(RegressionStatus) && isfield(RegressionStatus,'StatusTable') && ...
        istable(RegressionStatus.StatusTable)
    StatusTable = RegressionStatus.StatusTable;
else
    StatusTable = table('Size',[0 2], ...
        'VariableTypes',{'string','string'}, ...
        'VariableNames',{'Item','Value'});
end

end

function SummaryTable = regressionActionTable(RegressionResult)

SummaryColumns = {'Issue','Category','Status','WhereToLook','RecommendedAction'};
SummaryTable = table('Size',[0 numel(SummaryColumns)], ...
    'VariableTypes',repmat({'string'},1,numel(SummaryColumns)), ...
    'VariableNames',SummaryColumns);

if isstruct(RegressionResult) && isfield(RegressionResult,'ReviewFirst') && ...
        istable(RegressionResult.ReviewFirst) && ...
        all(ismember(SummaryColumns,RegressionResult.ReviewFirst.Properties.VariableNames))
    SummaryTable = RegressionResult.ReviewFirst(:,SummaryColumns);
    return
end

if isempty(RegressionResult) || ~isstruct(RegressionResult) || ...
        ~isfield(RegressionResult,'RegressionSummary') || ...
        ~istable(RegressionResult.RegressionSummary)
    return
end

SummaryColumns = {'Metric','Category','Status','CheckType','Message'};
Summary = RegressionResult.RegressionSummary;
if all(ismember(SummaryColumns,Summary.Properties.VariableNames))
    SummaryTable = Summary(:,SummaryColumns);
    SummaryTable.Properties.VariableNames = {'Issue','Category','Status','WhereToLook','RecommendedAction'};
end

end

function ArchiveTable = regressionArchiveTable(RegressionStatus)

ArchiveColumns = {'ArchiveTimestamp','BaselineCreated','WorkbookExists','SourceDataOutput'};
ArchiveTypes = {'string','string','logical','string'};
ArchiveTable = table('Size',[0 numel(ArchiveColumns)], ...
    'VariableTypes',ArchiveTypes, ...
    'VariableNames',ArchiveColumns);

if isempty(RegressionStatus) || ~isstruct(RegressionStatus) || ...
        ~isfield(RegressionStatus,'ArchivedBaselines') || ...
        ~istable(RegressionStatus.ArchivedBaselines) || ...
        height(RegressionStatus.ArchivedBaselines)==0
    return
end

Archives = RegressionStatus.ArchivedBaselines;
if all(ismember(ArchiveColumns,Archives.Properties.VariableNames))
    ArchiveTable = Archives(:,ArchiveColumns);
end

end
