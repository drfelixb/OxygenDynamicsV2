function EventVectors = setOxygenSurgeEventVectorRow(EventVectors,rowIdx,regionIdx,eventIdx,metadata,eventMetrics, ...
    sizeModulation,morphology,fs)
%SETOXYGENSURGEEVENTVECTORROW Fill one row of oxygen surge event vectors.

EventVectors.SurgeEventExperiment(rowIdx,1) = metadata.Experiment(regionIdx);
EventVectors.SurgeEventMouse(rowIdx,1) = metadata.Mouse(regionIdx);
EventVectors.SurgeEventCondition(rowIdx,1) = metadata.Condition(regionIdx);
EventVectors.SurgeEventDrugID(rowIdx,1) = metadata.DrugID(regionIdx);
EventVectors.SurgeEventGenotype(rowIdx,1) = metadata.Genotype(regionIdx);
EventVectors.SurgeEventPromoter(rowIdx,1) = metadata.Promoter(regionIdx);
EventVectors.SurgeEventPuffStim(rowIdx,1) = metadata.PuffStim(regionIdx);
EventVectors.SurgeID(rowIdx,1) = regionIdx;
EventVectors.SurgeEventID(rowIdx,1) = eventIdx;
EventVectors.SurgeStartFrame(rowIdx,1) = eventMetrics.StartFrame;
EventVectors.SurgeEndFrame(rowIdx,1) = eventMetrics.EndFrame;
EventVectors.SurgeStartSec(rowIdx,1) = (eventMetrics.StartFrame-1)/fs;
EventVectors.SurgeEndSec(rowIdx,1) = eventMetrics.EndFrame/fs;
EventVectors.SurgeDurationFrames(rowIdx,1) = eventMetrics.DurationFrames;
EventVectors.SurgeDurationSec(rowIdx,1) = eventMetrics.DurationFrames/fs;
EventVectors.EventNormOxySurgeAmp(rowIdx,1) = eventMetrics.NormAmp;
EventVectors.EventNormOxySurgeAmpPercent(rowIdx,1) = (eventMetrics.NormAmp-1)*100;
EventVectors.EventSize_Surge_modulation(rowIdx,1) = sizeModulation;
EventVectors.EventMeanOxySurgeArea_um(rowIdx,1) = morphology.MeanArea_um(regionIdx);
EventVectors.EventMeanOxySurgeFilledArea_um(rowIdx,1) = morphology.MeanFilledArea_um(regionIdx);
EventVectors.EventMeanOxySurgeDiameter_um(rowIdx,1) = morphology.MeanDiameter_um(regionIdx);
EventVectors.EventMeanOxySurgePerimeter_um(rowIdx,1) = morphology.MeanPerimeter_um(regionIdx);
EventVectors.EventMeanCircularity_Surge(rowIdx,1) = morphology.MeanCircularity(regionIdx);
EventVectors.EventMeanCentroid_Surge_x(rowIdx,1) = morphology.MeanCentroid_x(regionIdx);
EventVectors.EventMeanCentroid_Surge_y(rowIdx,1) = morphology.MeanCentroid_y(regionIdx);

end
