function [ROIsTraces,TraceCorrs] = prepareStatsROITraceFeatures(ROIsTraces,IsBLI)
%PREPARESTATSROITRACEFEATURES Add BLI ROI trace features and correlations.

TraceCorrs = {};
if ~IsBLI
    return
end

TraceCorrs = cell(size(ROIsTraces,1),11);
TraceCorrs(:,1:5) = ROIsTraces(:,1:5);

for RecordingIdx = 1:size(ROIsTraces,1)
    ROITraceFeatures = computeROITraceFeatures(ROIsTraces{RecordingIdx,6});
    TraceCorrs(RecordingIdx,6:11) = num2cell(ROITraceFeatures.Correlations);
    ROIsTraces{RecordingIdx,7} = ROITraceFeatures.ROIMeanZ;
    ROIsTraces{RecordingIdx,8} = ROITraceFeatures.ROICovCoef;
    ROIsTraces{RecordingIdx,9} = ROITraceFeatures.ROIEntropy;
    ROIsTraces{RecordingIdx,10} = ROITraceFeatures.ROIDiffMeanZ;
    ROIsTraces{RecordingIdx,11} = ROITraceFeatures.ROIDiffCovCoef;
    ROIsTraces{RecordingIdx,12} = ROITraceFeatures.ROIDiffEntropy;
end
end
