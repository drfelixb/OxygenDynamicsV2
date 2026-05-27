function [NumOxySinkEvents,Start,Duration,NormOxySinkAmp,Size_modulation,Trace_PotentialNoise] = ...
    collateiOSSinkEvents(Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical,Mean_OxySink_Trace_Convo, ...
    Trace_PotentialNoise,sinkDetectionNoiseAmpThreshold)
%COLLATEIOSSINKEVENTS Build iOS oxygen sink event metric cells.

[NumOxySinkEvents,Start,Duration,NormOxySinkAmp,Size_modulation] = ...
    initializeEventMetricCells(size(Overall_OxygenSinks_Pxllist,1));

for i = 1:size(Overall_OxygenSinks_Pxllist,1)
    TempTrace = Mean_OxySink_Trace_Convo(i,:);
    [p,~,mu] = polyfit(1:numel(TempTrace),TempTrace,7);
    TraceTrend = polyval(p,1:numel(TempTrace),[],mu);

    EventsTemp = regionprops(Overall_OxySinks_logical(i,:),'Area','PixelIdxList');
    NumOxySinkEvents(i) = length(EventsTemp);

    Start(i) = {NaN(1,length(EventsTemp))};
    Duration(i) = {NaN(1,length(EventsTemp))};
    NormOxySinkAmp(i) = {NaN(1,length(EventsTemp))};
    Size_modulation(i) = {NaN(1,length(EventsTemp))};

    for q = 1:length(EventsTemp)
        EventMetrics = quantifyiOSSinkEvent(EventsTemp(q).PixelIdxList,TempTrace,TraceTrend);
        Start{i}(q) = EventMetrics.StartFrame;
        Duration{i}(q) = EventMetrics.DurationFrames;
        NormOxySinkAmp{i}(q) = EventMetrics.NormAmp;
        Size_modulation{i}(q) = computeEventSizeModulation(Overall_OxygenSinks_Pxllist,i, ...
            EventsTemp(q).PixelIdxList);
    end

    if ~any(NormOxySinkAmp{i}>sinkDetectionNoiseAmpThreshold)
        Trace_PotentialNoise(i) = false;
    end
end
end
