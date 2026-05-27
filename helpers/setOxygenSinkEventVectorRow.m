function EventVectors = setOxygenSinkEventVectorRow(EventVectors,rowIdx,regionIdx,eventIdx,metadata,eventMetrics, ...
    sizeModulation,detectionAmp,morphology,fs)
%SETOXYGENSINKEVENTVECTORROW Fill one row of oxygen sink event vectors.

EventVectors.EventExperiment(rowIdx,1) = metadata.Experiment(regionIdx);
EventVectors.EventMouse(rowIdx,1) = metadata.Mouse(regionIdx);
EventVectors.EventCondition(rowIdx,1) = metadata.Condition(regionIdx);
EventVectors.EventDrugID(rowIdx,1) = metadata.DrugID(regionIdx);
EventVectors.EventGenotype(rowIdx,1) = metadata.Genotype(regionIdx);
EventVectors.EventPromoter(rowIdx,1) = metadata.Promoter(regionIdx);
EventVectors.EventPuffStim(rowIdx,1) = metadata.PuffStim(regionIdx);
EventVectors.SinkID(rowIdx,1) = regionIdx;
EventVectors.EventID(rowIdx,1) = eventIdx;
EventVectors.StartFrame(rowIdx,1) = eventMetrics.StartFrame;
EventVectors.EndFrame(rowIdx,1) = eventMetrics.EndFrame;
EventVectors.StartSec(rowIdx,1) = eventMetrics.StartFrame/fs;
EventVectors.EndSec(rowIdx,1) = eventMetrics.EndFrame/fs;
EventVectors.DurationFrames(rowIdx,1) = eventMetrics.DurationFrames;
EventVectors.DurationSec(rowIdx,1) = eventMetrics.DurationFrames/fs;
EventVectors.EventNormOxySinkAmp(rowIdx,1) = eventMetrics.NormAmp;
EventVectors.EventNormOxySinkAmpPercent(rowIdx,1) = eventMetrics.NormAmp*100;
EventVectors.EventSize_modulation(rowIdx,1) = sizeModulation;
EventVectors.EventDetectionOxySinkAmp(rowIdx,1) = detectionAmp;
EventVectors.EventMeanOxySinkArea_um(rowIdx,1) = morphology.MeanArea_um(regionIdx);
EventVectors.EventMeanOxySinkFilledArea_um(rowIdx,1) = morphology.MeanFilledArea_um(regionIdx);
EventVectors.EventMeanOxySinkDiameter_um(rowIdx,1) = morphology.MeanDiameter_um(regionIdx);
EventVectors.EventMeanOxySinkPerimeter_um(rowIdx,1) = morphology.MeanPerimeter_um(regionIdx);
EventVectors.EventMeanCircularity(rowIdx,1) = morphology.MeanCircularity(regionIdx);
EventVectors.EventMeanCentroid_x(rowIdx,1) = morphology.MeanCentroid_x(regionIdx);
EventVectors.EventMeanCentroid_y(rowIdx,1) = morphology.MeanCentroid_y(regionIdx);

end
