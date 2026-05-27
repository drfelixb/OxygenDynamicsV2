function EventMask = createWindowedEventMask(NumSamples,EventCenters,HalfWindowSamples)
%CREATEWINDOWEDEVENTMASK Mark clamped windows around event center samples.

EventMask = false(NumSamples,1);
EventCenters = EventCenters(:);

for EventIdx = 1:numel(EventCenters)
    CenterSample = EventCenters(EventIdx);
    if isnan(CenterSample)
        continue
    end

    WindowStart = max(1,CenterSample-HalfWindowSamples);
    WindowEnd = min(NumSamples,CenterSample+HalfWindowSamples);
    EventMask(WindowStart:WindowEnd) = true;
end

end
