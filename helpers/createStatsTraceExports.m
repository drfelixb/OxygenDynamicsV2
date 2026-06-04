function [ExportTraces,ExportTraceCorrs] = createStatsTraceExports(GroupHeaders,Titles1,Titles2, ...
    FiltersROIsAndEvents,ROIsTraces,CommonTraceSources,TraceCorrs,IsBLI)
%CREATESTATSTRACEEXPORTS Build grouped trace and trace-correlation export tables.

ExportTraces = GroupHeaders;
ExportTraceCorrs = GroupHeaders;
BLITraceExportRows = [4 5 6 12 13 14];
BLITraceSourceCols = [7 8 9 10 11 12];
CommonTraceExportRows = [7 8 9 10 11 15];

for GroupIdx = 1:size(ExportTraces,2)
    GroupMask = FiltersROIsAndEvents{4,GroupIdx};

    if any(GroupMask)
        TraceHeader = cell(4,sum(GroupMask));
        TraceHeader(1,:) = ExportTraces(1,GroupIdx);
        TraceHeader(2,:) = ExportTraces(2,GroupIdx);
        TraceHeader(3,:) = ExportTraces(3,GroupIdx);
        TraceHeader(4,:) = ROIsTraces(GroupMask,2)';

        if IsBLI
            for TraceMapIdx = 1:numel(BLITraceExportRows)
                ExportTraces{BLITraceExportRows(TraceMapIdx),GroupIdx} = createPaddedTraceExportTable( ...
                    TraceHeader,ROIsTraces(GroupMask,BLITraceSourceCols(TraceMapIdx)));
            end
        end

        for TraceMapIdx = 1:numel(CommonTraceExportRows)
            ExportTraces{CommonTraceExportRows(TraceMapIdx),GroupIdx} = createPaddedTraceExportTable( ...
                TraceHeader,CommonTraceSources{TraceMapIdx}(GroupMask,6));
        end

        if IsBLI
            CorrHeader = ExportTraceCorrs(1:3,GroupIdx);
            for CorrMapIdx = 1:10
                ExportTraceCorrs{CorrMapIdx+3,GroupIdx} = createTraceCorrelationExportTable( ...
                    CorrHeader,TraceCorrs(GroupMask,CorrMapIdx+5));
            end
        end
    end
end

ExportTraces = [Titles1,ExportTraces];
if IsBLI
    ExportTraceCorrs = [Titles2,ExportTraceCorrs];
end

end
