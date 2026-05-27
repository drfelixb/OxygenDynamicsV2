function EventVectors = initializeOxygenSinkEventVectors(totalEvents)
%INITIALIZEOXYGENSINKEVENTVECTORS Preallocate oxygen sink event-table vectors.

EventVectors = struct();
EventVectors.EventExperiment = cell(totalEvents,1);
EventVectors.EventMouse = cell(totalEvents,1);
EventVectors.EventCondition = cell(totalEvents,1);
EventVectors.EventDrugID = cell(totalEvents,1);
EventVectors.EventGenotype = cell(totalEvents,1);
EventVectors.EventPromoter = cell(totalEvents,1);
EventVectors.EventPuffStim = false(totalEvents,1);
EventVectors.SinkID = NaN(totalEvents,1);
EventVectors.EventID = NaN(totalEvents,1);
EventVectors.StartFrame = NaN(totalEvents,1);
EventVectors.EndFrame = NaN(totalEvents,1);
EventVectors.StartSec = NaN(totalEvents,1);
EventVectors.EndSec = NaN(totalEvents,1);
EventVectors.DurationFrames = NaN(totalEvents,1);
EventVectors.DurationSec = NaN(totalEvents,1);
EventVectors.EventNormOxySinkAmp = NaN(totalEvents,1);
EventVectors.EventNormOxySinkAmpPercent = NaN(totalEvents,1);
EventVectors.EventSize_modulation = NaN(totalEvents,1);
EventVectors.EventDetectionOxySinkAmp = NaN(totalEvents,1);
EventVectors.EventMeanOxySinkArea_um = NaN(totalEvents,1);
EventVectors.EventMeanOxySinkFilledArea_um = NaN(totalEvents,1);
EventVectors.EventMeanOxySinkDiameter_um = NaN(totalEvents,1);
EventVectors.EventMeanOxySinkPerimeter_um = NaN(totalEvents,1);
EventVectors.EventMeanCircularity = NaN(totalEvents,1);
EventVectors.EventMeanCentroid_x = NaN(totalEvents,1);
EventVectors.EventMeanCentroid_y = NaN(totalEvents,1);

end
