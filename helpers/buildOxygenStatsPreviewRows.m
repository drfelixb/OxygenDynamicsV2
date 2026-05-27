function PreviewRows = buildOxygenStatsPreviewRows(StatsResult)
%BUILDOXYGENSTATSPREVIEWROWS Create compact GUI rows from stats output.

PreviewRows = cell(0,2);
if isempty(StatsResult) || ~isstruct(StatsResult)
    return
end

if isfield(StatsResult,'StatsInfo')
    Info = StatsResult.StatsInfo;
    PreviewRows(end+1,:) = {'Input CSV',getStructFieldText(Info,'InputCsv')};
    if isfield(Info,'ValidatedPaths')
        PreviewRows(end+1,:) = {'Recordings',num2str(numel(Info.ValidatedPaths))};
    end
    if isfield(Info,'LoadSummary') && isstruct(Info.LoadSummary)
        PreviewRows = appendLoadSummaryRows(PreviewRows,Info.LoadSummary);
    end
end

if isfield(StatsResult,'DataOutputMat') && isfile(StatsResult.DataOutputMat)
    PreviewRows = appendDataOutputRows(PreviewRows,StatsResult.DataOutputMat);
end
PreviewRows = appendStatsAcceptancePreviewRows(PreviewRows,StatsResult);
PreviewRows = appendStatsQcPreviewRows(PreviewRows,StatsResult);

end

function PreviewRows = appendStatsAcceptancePreviewRows(PreviewRows,StatsResult)

AcceptanceRows = buildOxygenStatsAcceptanceRows(StatsResult);
if isempty(AcceptanceRows) || height(AcceptanceRows)==0
    return
end

OverallIdx = find(AcceptanceRows.Item=="Overall stats acceptance",1,'first');
if ~isempty(OverallIdx)
    PreviewRows(end+1,:) = {'Stats acceptance', ...
        char(AcceptanceRows.Status(OverallIdx) + " - " + AcceptanceRows.Message(OverallIdx))};
end

ReviewCount = sum(AcceptanceRows.Status=="REVIEW");
PreviewRows(end+1,:) = {'Stats acceptance review items',num2str(ReviewCount)};

end

function PreviewRows = appendStatsQcPreviewRows(PreviewRows,StatsResult)

QcRows = buildOxygenStatsQcRows(StatsResult);
for RowIdx = 1:height(QcRows)
    PreviewRows(end+1,:) = {char("QC: " + QcRows.Check(RowIdx)), ...
        char(QcRows.Status(RowIdx) + " - " + QcRows.Message(RowIdx))}; %#ok<AGROW>
end

end

function PreviewRows = appendLoadSummaryRows(PreviewRows,LoadSummary)

FieldNames = {'RecordingsWithSinks','RecordingsWithSurges','RecordingsWithBehaviour','RecordingsMissingBehaviour'};
Labels = {'With sinks','With surges','With behaviour','Missing behaviour'};
for FieldIdx = 1:numel(FieldNames)
    if isfield(LoadSummary,FieldNames{FieldIdx})
        PreviewRows(end+1,:) = {Labels{FieldIdx},num2str(LoadSummary.(FieldNames{FieldIdx}))}; %#ok<AGROW>
    end
end

end

function PreviewRows = appendDataOutputRows(PreviewRows,DataOutputMat)

Data = load(DataOutputMat);
TableSpecs = { ...
    'Table_OxygenSinks_OutCombo','Sink/ROI rows'; ...
    'Table_OxygenSinkEvents_OutCombo','Sink event rows'; ...
    'Table_OxygenSurges_OutCombo','Surge/ROI rows'; ...
    'Table_OxygenSurgeEvents_OutCombo','Surge event rows'};
for TableIdx = 1:size(TableSpecs,1)
    FieldName = TableSpecs{TableIdx,1};
    if isfield(Data,FieldName) && istable(Data.(FieldName))
        PreviewRows(end+1,:) = {TableSpecs{TableIdx,2},num2str(height(Data.(FieldName)))}; %#ok<AGROW>
    end
end

if isfield(Data,'Table_OxygenSinks_OutCombo') && istable(Data.Table_OxygenSinks_OutCombo)
    SinkTable = Data.Table_OxygenSinks_OutCombo;
    PreviewRows = appendUniqueCount(PreviewRows,SinkTable,'Mouse','Mice');
    PreviewRows = appendUniqueCount(PreviewRows,SinkTable,'DrugID','Drug groups');
    PreviewRows = appendUniqueCount(PreviewRows,SinkTable,'Condition','Conditions');
    PreviewRows = appendUniqueCount(PreviewRows,SinkTable,'PuffStim','Stimulation levels');
end

PreviewRows = appendHypoxicBurdenPreviewRows(PreviewRows,Data);
PreviewRows = appendAreaNormalizationPreviewRows(PreviewRows,Data);

end

function PreviewRows = appendHypoxicBurdenPreviewRows(PreviewRows,Data)

if ~isfield(Data,'HypoxicBurden') || ~isstruct(Data.HypoxicBurden)
    return
end

if isfield(Data.HypoxicBurden,'EventTable') && istable(Data.HypoxicBurden.EventTable)
    EventTable = Data.HypoxicBurden.EventTable;
    PreviewRows(end+1,:) = {'Hypoxic burden event rows',num2str(height(EventTable))};
    PreviewRows = appendTableColumnSum(PreviewRows,EventTable, ...
        'PerEventBurdenContribution','Hypoxic burden event sum');
    if ismember('BurdenAreaEventSpecificMatched',EventTable.Properties.VariableNames)
        PreviewRows(end+1,:) = {'Event-specific area matches', ...
            sprintf('%d / %d',sum(logical(EventTable.BurdenAreaEventSpecificMatched)),height(EventTable))};
    end
end

if isfield(Data.HypoxicBurden,'RecordingTable') && istable(Data.HypoxicBurden.RecordingTable)
    RecordingTable = Data.HypoxicBurden.RecordingTable;
    PreviewRows(end+1,:) = {'Hypoxic burden recordings',num2str(height(RecordingTable))};
    PreviewRows = appendTableColumnSum(PreviewRows,RecordingTable,'HypoxicBurden','Hypoxic burden total');
end

if isfield(Data.HypoxicBurden,'GroupSummaryTable') && istable(Data.HypoxicBurden.GroupSummaryTable)
    GroupSummaryTable = Data.HypoxicBurden.GroupSummaryTable;
    PreviewRows(end+1,:) = {'Hypoxic burden groups',num2str(height(GroupSummaryTable))};
    PreviewRows = appendTableColumnMean(PreviewRows,GroupSummaryTable, ...
        'HypoxicBurden_Mean','Mean grouped burden');
    PreviewRows = appendTableColumnMean(PreviewRows,GroupSummaryTable, ...
        'EventSpecificAreaMatchRate','Mean area match rate');
end

end

function PreviewRows = appendAreaNormalizationPreviewRows(PreviewRows,Data)

if isfield(Data,'SinkCountAreaNormalization') && istable(Data.SinkCountAreaNormalization)
    NormTable = Data.SinkCountAreaNormalization;
    PreviewRows(end+1,:) = {'Area-normalized recordings',num2str(height(NormTable))};
    PreviewRows = appendTableColumnMean(PreviewRows,NormTable,'AreaCorrectionFactor_1mm2', ...
        'Mean area correction');
end

end

function PreviewRows = appendUniqueCount(PreviewRows,TableData,ColumnName,LabelText)

if ismember(ColumnName,TableData.Properties.VariableNames)
    Values = string(TableData.(ColumnName));
    Values = Values(~ismissing(Values) & Values~="");
    PreviewRows(end+1,:) = {LabelText,num2str(numel(unique(Values)))};
end

end

function PreviewRows = appendTableColumnSum(PreviewRows,TableData,ColumnName,LabelText)

if ismember(ColumnName,TableData.Properties.VariableNames)
    Values = tableColumnToDouble(TableData.(ColumnName));
    PreviewRows(end+1,:) = {LabelText,sprintf('%.6g',sum(Values,'omitnan'))};
end

end

function PreviewRows = appendTableColumnMean(PreviewRows,TableData,ColumnName,LabelText)

if ismember(ColumnName,TableData.Properties.VariableNames)
    Values = tableColumnToDouble(TableData.(ColumnName));
    PreviewRows(end+1,:) = {LabelText,sprintf('%.6g',mean(Values,'omitnan'))};
end

end

function Values = tableColumnToDouble(Column)

if isnumeric(Column) || islogical(Column)
    Values = double(Column);
elseif iscell(Column)
    Values = str2double(string(Column));
else
    Values = str2double(string(Column));
end
Values = Values(:);

end

function TextValue = getStructFieldText(StructValue,FieldName)

TextValue = '';
if isfield(StructValue,FieldName)
    Value = StructValue.(FieldName);
    if ischar(Value) || isstring(Value)
        TextValue = char(Value);
    elseif isnumeric(Value) || islogical(Value)
        TextValue = mat2str(Value);
    end
end

end
