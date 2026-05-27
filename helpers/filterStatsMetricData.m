function [FilteredData,FilteredMice] = filterStatsMetricData(MouseValues,MetricSources,MetricNames,GroupFilters)
%FILTERSTATSMETRICDATA Split metric vectors into stats groups.

NumMetrics = numel(MetricNames);
NumGroups = size(GroupFilters,2);
FilteredData = cell(NumMetrics,NumGroups);
FilteredMice = cell(1,NumGroups);

for GroupIdx = 1:NumGroups
    GroupFilter = GroupFilters{4,GroupIdx};
    FilteredMice{1,GroupIdx} = MouseValues(GroupFilter);

    for MetricIdx = 1:NumMetrics
        FilteredData{MetricIdx,GroupIdx} = MetricSources.(MetricNames{MetricIdx})(GroupFilter);
    end
end

end
