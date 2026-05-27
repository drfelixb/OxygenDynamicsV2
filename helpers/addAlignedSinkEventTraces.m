function SinksTraces = addAlignedSinkEventTraces(SinksTraces,TableOxygenSinks,MinDuration,MaxDuration)
%ADDALIGNEDSINKEVENTTRACES Attach aligned sink-event traces to each recording row.

for RecordingIdx = 1:size(SinksTraces,1)
    SinkRows = TableOxygenSinks(logical(strcmp(TableOxygenSinks.Experiment(:),SinksTraces{RecordingIdx,1}) ...
        .*strcmp(TableOxygenSinks.Mouse(:),SinksTraces{RecordingIdx,2})),:);
    SinksTraces{RecordingIdx,7} = createAlignedOxygenSinkEventTraces( ...
        SinkRows,SinksTraces{RecordingIdx,6},MinDuration,MaxDuration);
end

end
