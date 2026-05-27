function ROITraceFeatures = computeROITraceFeatures(ROITraceMatrix)
%COMPUTEROITRACEFEATURES Calculate ROI distribution traces and correlations.

NumFrames = size(ROITraceMatrix,2);
ROIMean = zeros(1,NumFrames);
ROICovCoef = zeros(1,NumFrames);
ROIEntropy = zeros(1,NumFrames);

for FrameIdx = 1:NumFrames
    ROIMean(FrameIdx) = mean(ROITraceMatrix(:,FrameIdx));
    ScaledTrace = safeMat2Gray(ROITraceMatrix(:,FrameIdx));
    ROICovCoef(FrameIdx) = safeCoeffVariation(ScaledTrace);
    ROIEntropy(FrameIdx) = safeShannonEntropy(ScaledTrace);
end

ROIDiffMatrix = builtin('diff',ROITraceMatrix,1,2);
ROIDiffMean = zeros(1,NumFrames);
ROIDiffCovCoef = zeros(1,NumFrames);
ROIDiffEntropy = zeros(1,NumFrames);

for FrameIdx = 1:size(ROIDiffMatrix,2)
    ROIDiffMean(FrameIdx+1) = mean(ROIDiffMatrix(:,FrameIdx));
    ScaledDiff = safeMat2Gray(ROIDiffMatrix(:,FrameIdx));
    ROIDiffCovCoef(FrameIdx+1) = safeCoeffVariation(ScaledDiff);
    ROIDiffEntropy(FrameIdx+1) = safeShannonEntropy(ScaledDiff);
end

ROIMeanZ = safeZScore(ROIMean);
ROIDiffMeanZ = safeZScore(ROIDiffMean);

ROITraceFeatures = struct();
ROITraceFeatures.ROIMeanZ = ROIMeanZ;
ROITraceFeatures.ROICovCoef = ROICovCoef;
ROITraceFeatures.ROIEntropy = ROIEntropy;
ROITraceFeatures.ROIDiffMeanZ = ROIDiffMeanZ;
ROITraceFeatures.ROIDiffCovCoef = ROIDiffCovCoef;
ROITraceFeatures.ROIDiffEntropy = ROIDiffEntropy;
ROITraceFeatures.Correlations = [ ...
    safeCorr(ROIMeanZ,ROICovCoef), ...
    safeCorr(ROIMeanZ,ROIEntropy), ...
    safeCorr(ROICovCoef,ROIEntropy), ...
    safeCorr(ROIDiffMeanZ,ROIDiffCovCoef), ...
    safeCorr(ROIDiffMeanZ,ROIDiffEntropy), ...
    safeCorr(ROIDiffCovCoef,ROIDiffEntropy)];

end
