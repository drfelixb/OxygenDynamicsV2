function [NumOxySurgeEvents,Start_Surge,Duration_Surge,NormOxySurgeAmp,Size_Surge_modulation, ...
    Table_OxygenSurgeEvents_Out] = collateOxygenSurgeEvents(Overall_OxygenSurges_Pxllist, ...
    Overall_OxySurges_logical,metadata,morphology,fs,analysisParams)
%COLLATEOXYGENSURGEEVENTS Build surge event summaries and event-level output table.

[NumOxySurgeEvents,Start_Surge,Duration_Surge,NormOxySurgeAmp,Size_Surge_modulation] = ...
    initializeEventMetricCells(size(Overall_OxygenSurges_Pxllist,1));
TotalSurgeEvents = countTrackedEvents(Overall_OxySurges_logical);
SurgeEventVectors = initializeOxygenSurgeEventVectors(TotalSurgeEvents);
SurgeEventRow = 0;

for i = 1:size(Overall_OxygenSurges_Pxllist,1)
    EventsTemp = regionprops(Overall_OxySurges_logical(i,:),'Area','PixelIdxList');
    NumOxySurgeEvents(i) = length(EventsTemp);
    Start_Surge(i) = {NaN(1,length(EventsTemp))};
    Duration_Surge(i) = {NaN(1,length(EventsTemp))};
    NormOxySurgeAmp(i) = {NaN(1,length(EventsTemp))};
    Size_Surge_modulation(i) = {NaN(1,length(EventsTemp))};

    for q = 1:length(EventsTemp)
        frames=EventsTemp(q).PixelIdxList;
        % Amplitudes are filled only by the shared preserved-input finalizer.
        EventMetrics=struct('StartFrame',frames(1),'EndFrame',frames(end), ...
            'DurationFrames',numel(frames),'NormAmp',NaN);
        Start_Surge{i}(q) = EventMetrics.StartFrame;
        Duration_Surge{i}(q) = EventMetrics.DurationFrames;
        NormOxySurgeAmp{i}(q) = EventMetrics.NormAmp;
        Size_Surge_modulation{i}(q) = computeEventSizeModulation(Overall_OxygenSurges_Pxllist,i, ...
            EventsTemp(q).PixelIdxList);

        SurgeEventRow = SurgeEventRow+1;
        SurgeEventVectors = setOxygenSurgeEventVectorRow(SurgeEventVectors,SurgeEventRow,i,q, ...
            metadata,EventMetrics,Size_Surge_modulation{i}(q),morphology,fs);
    end
end

Table_OxygenSurgeEvents_Out = createOxygenSurgeEventTable(SurgeEventVectors.SurgeEventExperiment, ...
    SurgeEventVectors.SurgeEventMouse,SurgeEventVectors.SurgeEventCondition, ...
    SurgeEventVectors.SurgeEventDrugID,SurgeEventVectors.SurgeEventGenotype, ...
    SurgeEventVectors.SurgeEventPromoter,SurgeEventVectors.SurgeEventPuffStim, ...
    SurgeEventVectors.SurgeID,SurgeEventVectors.SurgeEventID,SurgeEventVectors.SurgeStartFrame, ...
    SurgeEventVectors.SurgeEndFrame,SurgeEventVectors.SurgeStartSec,SurgeEventVectors.SurgeEndSec, ...
    SurgeEventVectors.SurgeDurationFrames,SurgeEventVectors.SurgeDurationSec, ...
    SurgeEventVectors.EventNormOxySurgeAmp,SurgeEventVectors.EventNormOxySurgeAmpPercent, ...
    SurgeEventVectors.EventSize_Surge_modulation,SurgeEventVectors.EventMeanOxySurgeArea_um, ...
    SurgeEventVectors.EventMeanOxySurgeFilledArea_um,SurgeEventVectors.EventMeanOxySurgeDiameter_um, ...
    SurgeEventVectors.EventMeanOxySurgePerimeter_um,SurgeEventVectors.EventMeanCircularity_Surge, ...
    SurgeEventVectors.EventMeanCentroid_Surge_x,SurgeEventVectors.EventMeanCentroid_Surge_y);

Table_OxygenSurgeEvents_Out.NativeStartFrame=Table_OxygenSurgeEvents_Out.StartFrame;
Table_OxygenSurgeEvents_Out.NativeEndFrame=Table_OxygenSurgeEvents_Out.EndFrame;
Table_OxygenSurgeEvents_Out.TimingMethod=repmat("native_mask_bounds_not_refined",height(Table_OxygenSurgeEvents_Out),1);
Table_OxygenSurgeEvents_Out.TouchesRecordingStart=Table_OxygenSurgeEvents_Out.NativeStartFrame==1;
Table_OxygenSurgeEvents_Out.TouchesRecordingEnd=Table_OxygenSurgeEvents_Out.NativeEndFrame==size(Overall_OxySurges_logical,2);
Table_OxygenSurgeEvents_Out=annotateOxygenEventRecurrence(Table_OxygenSurgeEvents_Out,fs,analysisParams.surgeCloseNativeGapSec,'SurgeID');

end
