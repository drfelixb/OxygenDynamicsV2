function AlignedTraces = createAlignedOxygenSinkEventTraces(SinkRows,SinkTraceMatrix,MinDuration,MaxDuration)
%CREATEALIGNEDOXYGENSINKEVENTTRACES Align sink-event traces to event start.

ValidStarts = {};
ValidDurations = {};
TotalEvents = 0;
MaxEventDuration = 0;

for RowIdx = 1:height(SinkRows)
    ValidEventMask = SinkRows.Duration{RowIdx}<=MaxDuration & SinkRows.Duration{RowIdx}>=MinDuration;
    Starts = SinkRows.Start{RowIdx}(ValidEventMask);
    Durations = SinkRows.Duration{RowIdx}(ValidEventMask);

    ValidStarts{RowIdx,1} = Starts; %#ok<AGROW>
    ValidDurations{RowIdx,1} = Durations; %#ok<AGROW>
    TotalEvents = TotalEvents+numel(Durations);
    if ~isempty(Durations)
        MaxEventDuration = max(MaxEventDuration,max(Durations));
    end
end

AlignedTraces = nan(TotalEvents,MaxEventDuration);
Counter = 1;
for RowIdx = 1:height(SinkRows)
    for EventIdx = 1:numel(ValidStarts{RowIdx})
        EventStart = ValidStarts{RowIdx}(EventIdx);
        EventDuration = ValidDurations{RowIdx}(EventIdx);
        EventTrace = SinkTraceMatrix(RowIdx,EventStart:EventStart+EventDuration-1);
        EventTrace = EventTrace-EventTrace(1);
        AlignedTraces(Counter,1:numel(EventTrace)) = EventTrace;
        Counter = Counter+1;
    end
end

end
