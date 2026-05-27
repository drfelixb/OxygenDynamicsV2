function PooledTraces = formatPooledTracesForExport(PooledTraces,PooledTraceMice)
%FORMATPOOLEDTRACESFOREXPORT Normalize puff-aligned traces and add mouse labels.

TimeLabels = append(string(-30:60),"sec");

for GroupIdx = 1:size(PooledTraces,2)
    for MetricIdx = 4:size(PooledTraces,1)
        if isempty(PooledTraces{MetricIdx,GroupIdx})
            continue
        end

        TraceMatrix = PooledTraces{MetricIdx,GroupIdx};
        TraceMatrix = TraceMatrix./mean(TraceMatrix(:,1:31),2,'omitnan');
        TraceMatrix = TraceMatrix-TraceMatrix(:,31);

        TraceTable = array2table(TraceMatrix);
        MouseTable = table(string(PooledTraceMice{MetricIdx,GroupIdx}(:)),'VariableNames',{'Mouse'});
        TraceTable = [MouseTable,TraceTable]; %#ok<AGROW>
        TraceTable = renamevars(TraceTable,2:width(TraceTable),TimeLabels);
        PooledTraces{MetricIdx,GroupIdx} = TraceTable;
    end
end

end
