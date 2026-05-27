function CleanMask = removeShortLogicalEvents(EventMask,MinDurationSamples)
%REMOVESHORTLOGICALEVENTS Remove true-runs shorter than a duration threshold.

CleanMask = logical(EventMask(:));
Transitions = diff([false;CleanMask;false]);
EventStarts = find(Transitions==1);
EventEnds = find(Transitions==-1)-1;
EventLengths = EventEnds-EventStarts+1;

ShortEvents = find(EventLengths<MinDurationSamples);
for EventIdx = 1:numel(ShortEvents)
    CleanMask(EventStarts(ShortEvents(EventIdx)):EventEnds(ShortEvents(EventIdx))) = false;
end

end
