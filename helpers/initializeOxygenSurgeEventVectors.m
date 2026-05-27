function EventVectors = initializeOxygenSurgeEventVectors(totalEvents)
%INITIALIZEOXYGENSURGEEVENTVECTORS Preallocate oxygen surge event-table vectors.

EventVectors = struct();
EventVectors.SurgeEventExperiment = cell(totalEvents,1);
EventVectors.SurgeEventMouse = cell(totalEvents,1);
EventVectors.SurgeEventCondition = cell(totalEvents,1);
EventVectors.SurgeEventDrugID = cell(totalEvents,1);
EventVectors.SurgeEventGenotype = cell(totalEvents,1);
EventVectors.SurgeEventPromoter = cell(totalEvents,1);
EventVectors.SurgeEventPuffStim = false(totalEvents,1);
EventVectors.SurgeID = NaN(totalEvents,1);
EventVectors.SurgeEventID = NaN(totalEvents,1);
EventVectors.SurgeStartFrame = NaN(totalEvents,1);
EventVectors.SurgeEndFrame = NaN(totalEvents,1);
EventVectors.SurgeStartSec = NaN(totalEvents,1);
EventVectors.SurgeEndSec = NaN(totalEvents,1);
EventVectors.SurgeDurationFrames = NaN(totalEvents,1);
EventVectors.SurgeDurationSec = NaN(totalEvents,1);
EventVectors.EventNormOxySurgeAmp = NaN(totalEvents,1);
EventVectors.EventNormOxySurgeAmpPercent = NaN(totalEvents,1);
EventVectors.EventSize_Surge_modulation = NaN(totalEvents,1);
EventVectors.EventMeanOxySurgeArea_um = NaN(totalEvents,1);
EventVectors.EventMeanOxySurgeFilledArea_um = NaN(totalEvents,1);
EventVectors.EventMeanOxySurgeDiameter_um = NaN(totalEvents,1);
EventVectors.EventMeanOxySurgePerimeter_um = NaN(totalEvents,1);
EventVectors.EventMeanCircularity_Surge = NaN(totalEvents,1);
EventVectors.EventMeanCentroid_Surge_x = NaN(totalEvents,1);
EventVectors.EventMeanCentroid_Surge_y = NaN(totalEvents,1);

end
