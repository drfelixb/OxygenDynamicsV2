function ExportTables = createStatsMetricExportTables(FilteredData,FilteredMice,GroupFilters)
%CREATESTATSMETRICEXPORTTABLES Build per-mouse grouped metric export tables.

NumMetrics = size(FilteredData,1);
ExportTables = cell(NumMetrics,1);
MaxRows = max([1;cellfun(@numel,FilteredData(:))]);
MaxMicePerGroup = max([1,cellfun(@numel,GroupFilters(5,:))]);
MaxCols = size(FilteredData,2)*MaxMicePerGroup;

for MetricIdx = 1:NumMetrics
    MetricCells = cell(MaxRows+4,MaxCols);
    Counter = 1;

    for GroupIdx = 1:size(FilteredData,2)
        GroupMetricData = FilteredData{MetricIdx,GroupIdx};
        GroupMice = GroupFilters{5,GroupIdx};

        if isempty(GroupMetricData)
            continue
        end

        for MouseIdx = 1:numel(GroupMice)
            MouseFilter = strcmp(FilteredMice{1,GroupIdx},GroupMice{MouseIdx});
            MouseMetricData = GroupMetricData(MouseFilter);

            MetricCells(1,Counter) = GroupFilters(1,GroupIdx);
            MetricCells(2,Counter) = GroupFilters(2,GroupIdx);
            MetricCells(3,Counter) = GroupFilters(3,GroupIdx);
            MetricCells(4,Counter) = GroupMice(MouseIdx);
            MetricCells(5:4+numel(MouseMetricData),Counter) = num2cell(MouseMetricData);
            Counter = Counter+1;
        end
    end

    MetricCells = MetricCells(any(~cellfun(@isempty,MetricCells),2),:);
    MetricCells = MetricCells(:,any(~cellfun(@isempty,MetricCells),1));
    ExportTables{MetricIdx,1} = cell2table(MetricCells);
end

end
