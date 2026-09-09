function [NumOxySinkEvents,Start,Duration,NormOxySinkAmp,Size_modulation, ...
    Table_OxygenSinkEvents_Out,Trace_PotentialNoise] = collateOxygenSinkEvents( ...
    Overall_OxygenSinks_Pxllist,Overall_OxySinks_logical,Mean_OxySink_Trace_Convo, ...
    Mean_OxySink_Trace_Raw,Trace_PotentialNoise,metadata,morphology,fs,analysisParams, ...
    eventBaselineReturnTolerance,sinkDetectionNoiseAmpThreshold)
%COLLATEOXYGENSINKEVENTS Build sink event summaries and event-level output table.

[NumOxySinkEvents,Start,Duration,NormOxySinkAmp,Size_modulation] = ...
    initializeEventMetricCells(size(Overall_OxygenSinks_Pxllist,1));
TotalSinkEvents = countTrackedEvents(Overall_OxySinks_logical);
SinkEventVectors = initializeOxygenSinkEventVectors(TotalSinkEvents);
SinkEventRow = 0;
TimingSummary=table('Size',[TotalSinkEvents 9],'VariableTypes', ...
    {'double','double','double','double','string','string','logical','logical','double'}, ...
    'VariableNames',{'NativeStartFrame','NativeEndFrame','TimingSearchStartFrame','TimingSearchEndFrame', ...
    'StartBoundaryStatus','EndBoundaryStatus','TimingResolved','NativeTraceCrossesReturnLevel','TimingMaxExtensionFrames'});
MaxExtensionFrames=floor(analysisParams.sinkTimingMaxExtensionSec*fs);
BaselineWindowFrames = round(analysisParams.quantBaselineWindowSec*fs);

for i = 1:size(Overall_OxygenSinks_Pxllist,1)
    TempTrace = Mean_OxySink_Trace_Convo(i,:);
    RawTrace = Mean_OxySink_Trace_Raw(i,:);
    [p,~,mu] = polyfit(1:numel(TempTrace),TempTrace,7);
    TraceTrend = polyval(p,1:numel(TempTrace),[],mu);

    EventsTemp = regionprops(Overall_OxySinks_logical(i,:),'Area','PixelIdxList');
    NumOxySinkEvents(i) = length(EventsTemp);
    Start(i) = {NaN(1,length(EventsTemp))};
    Duration(i) = {NaN(1,length(EventsTemp))};
    NormOxySinkAmp(i) = {NaN(1,length(EventsTemp))};
    Size_modulation(i) = {NaN(1,length(EventsTemp))};
    DetectionOxySinkAmp = NaN(1,length(EventsTemp));

    for q = 1:length(EventsTemp)
        % Split each inter-event gap once. Neighboring searches cannot overlap.
        leftLimit=1;rightLimit=numel(TempTrace);
        if q>1,leftLimit=floor((EventsTemp(q-1).PixelIdxList(end)+EventsTemp(q).PixelIdxList(1))/2)+1;end
        if q<numel(EventsTemp),rightLimit=floor((EventsTemp(q).PixelIdxList(end)+EventsTemp(q+1).PixelIdxList(1))/2);end
        EventMetrics = quantifyOxygenSinkEvent(EventsTemp(q).PixelIdxList,TempTrace,TraceTrend, ...
            RawTrace,eventBaselineReturnTolerance,BaselineWindowFrames,MaxExtensionFrames,leftLimit,rightLimit);
        Start{i}(q) = EventMetrics.StartFrame;
        Duration{i}(q) = EventMetrics.DurationFrames;
        NormOxySinkAmp{i}(q) = EventMetrics.NormAmp;
        DetectionOxySinkAmp(q) = EventMetrics.DetectionAmp;
        Size_modulation{i}(q) = computeEventSizeModulation(Overall_OxygenSinks_Pxllist,i, ...
            EventsTemp(q).PixelIdxList);

        SinkEventRow = SinkEventRow+1;
        TimingSummary(SinkEventRow,:)=struct2table(rmfield(EventMetrics.Timing,{'StartFrame','EndFrame'}));
        SinkEventVectors = setOxygenSinkEventVectorRow(SinkEventVectors,SinkEventRow,i,q, ...
            metadata,EventMetrics,Size_modulation{i}(q),DetectionOxySinkAmp(q),morphology,fs);
    end

    if ~any(DetectionOxySinkAmp>sinkDetectionNoiseAmpThreshold)
        Trace_PotentialNoise(i) = false;
    end
end

Table_OxygenSinkEvents_Out = createOxygenSinkEventTable(SinkEventVectors.EventExperiment, ...
    SinkEventVectors.EventMouse,SinkEventVectors.EventCondition,SinkEventVectors.EventDrugID, ...
    SinkEventVectors.EventGenotype,SinkEventVectors.EventPromoter,SinkEventVectors.EventPuffStim, ...
    SinkEventVectors.SinkID,SinkEventVectors.EventID,SinkEventVectors.StartFrame, ...
    SinkEventVectors.EndFrame,SinkEventVectors.StartSec,SinkEventVectors.EndSec, ...
    SinkEventVectors.DurationFrames,SinkEventVectors.DurationSec,SinkEventVectors.EventNormOxySinkAmp, ...
    SinkEventVectors.EventNormOxySinkAmpPercent,SinkEventVectors.EventSize_modulation, ...
    SinkEventVectors.EventDetectionOxySinkAmp,SinkEventVectors.EventMeanOxySinkArea_um, ...
    SinkEventVectors.EventMeanOxySinkFilledArea_um,SinkEventVectors.EventMeanOxySinkDiameter_um, ...
    SinkEventVectors.EventMeanOxySinkPerimeter_um,SinkEventVectors.EventMeanCircularity, ...
    SinkEventVectors.EventMeanCentroid_x,SinkEventVectors.EventMeanCentroid_y);

Table_OxygenSinkEvents_Out=[Table_OxygenSinkEvents_Out TimingSummary];

end
