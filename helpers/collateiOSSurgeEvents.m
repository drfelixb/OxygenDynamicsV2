function [NumOxySurgeEvents,Start_Surge,Duration_Surge,NormOxySurgeAmp,Size_Surge_modulation] = ...
    collateiOSSurgeEvents(Overall_OxygenSurges_Pxllist,Overall_OxySurges_logical,Mean_OxySurge_TraceZ, ...
    surgeBaselineWindowFrames)
%COLLATEIOSSURGEEVENTS Build iOS oxygen surge event metric cells.

[NumOxySurgeEvents,Start_Surge,Duration_Surge,NormOxySurgeAmp,Size_Surge_modulation] = ...
    initializeEventMetricCells(size(Overall_OxygenSurges_Pxllist,1));

for i = 1:size(Overall_OxygenSurges_Pxllist,1)
    EventsTemp = regionprops(Overall_OxySurges_logical(i,:),'Area','PixelIdxList');
    NumOxySurgeEvents(i) = length(EventsTemp);

    Start_Surge(i) = {NaN(1,length(EventsTemp))};
    Duration_Surge(i) = {NaN(1,length(EventsTemp))};
    NormOxySurgeAmp(i) = {NaN(1,length(EventsTemp))};
    Size_Surge_modulation(i) = {NaN(1,length(EventsTemp))};

    for q = 1:length(EventsTemp)
        EventMetrics = quantifyOxygenSurgeEvent(EventsTemp(q).PixelIdxList, ...
            Mean_OxySurge_TraceZ(i,:),surgeBaselineWindowFrames,false);
        Start_Surge{i}(q) = EventMetrics.StartFrame;
        Duration_Surge{i}(q) = EventMetrics.DurationFrames;
        NormOxySurgeAmp{i}(q) = EventMetrics.NormAmp;
        Size_Surge_modulation{i}(q) = computeEventSizeModulation(Overall_OxygenSurges_Pxllist,i, ...
            EventsTemp(q).PixelIdxList);
    end
end
end
