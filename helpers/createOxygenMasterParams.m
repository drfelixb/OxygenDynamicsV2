function [AnalysisParams,ParamVars] = createOxygenMasterParams(PixelSize,fs)
%CREATEOXYGENMASTERPARAMS Build oxygen master parameters and derived values.

assert(isscalar(PixelSize)&&isfinite(PixelSize)&&PixelSize>0&&isscalar(fs)&&isfinite(fs)&&fs>0);
AnalysisParams = struct();
AnalysisParams.smooth = 10;
AnalysisParams.ThresholdMinsize = 100;
AnalysisParams.ThresholdMaxsize = 6400;
AnalysisParams.CircularityThres = 0.3;
% Development anchor: old 400-pixel cutoff at 4.75 um/pixel, not biology.
AnalysisParams.surgeMinAreaUm2 = 400 * 4.75^2;
AnalysisParams.ThresholdMinsize_Surges = ceil(AnalysisParams.surgeMinAreaUm2 / PixelSize^2);
AnalysisParams.surgeTrackingOverlapFraction = 0.6;
AnalysisParams.surgeTrackingContainmentFraction = 0.8;
AnalysisParams.surgeTrackingMaxAreaRatio = 2;
AnalysisParams.surgeGapReviewMaxSec = 2;
AnalysisParams.surgeSiteOverlapFraction = 0.6;
AnalysisParams.fs = fs;
AnalysisParams.PixelSize = PixelSize;
AnalysisParams.sinkCloseNativeGapSec = 20;
AnalysisParams.ThresholMinddur = 3 * fs;
AnalysisParams.ThresholMaxddur = 150 * fs;
AnalysisParams.ThresholMinddur_Surges = 10 * fs;
AnalysisParams.Pixel_frame = AnalysisParams.smooth * 2;
AnalysisParams.PercentileDetectionThres = 99;
AnalysisParams.PercentileSurgeDetectionThres = 90;
AnalysisParams.quantBaselineWindowSec = 20;
AnalysisParams.recAreaBackgroundPercentile = 30;
AnalysisParams.recAreaBinHalfSizeUm = 25;
AnalysisParams.recAreaMinCoverageFraction = 0.9;
AnalysisParams.sinkTraceCorrelationThreshold = 0.8;
AnalysisParams.sinkNoiseCorrelationPercentile = 90;
AnalysisParams.eventBaselineReturnTolerance = 0.015;
AnalysisParams.sinkTimingMaxExtensionSec = 20;
AnalysisParams.sinkDetectionNoiseAmpThreshold = 2.5;
AnalysisParams.surgeBaselineWindowSec = 20;
AnalysisParams.surgeCloseNativeGapSec = 20;
AnalysisParams.surgeCircularityThreshold = 0.1;
AnalysisParams.maxOutsideRecordingAreaFraction = 0.5;

ParamVars = struct();
ParamVars.smooth = AnalysisParams.smooth;
ParamVars.ThresholdMinsize = AnalysisParams.ThresholdMinsize;
ParamVars.ThresholdMaxsize = AnalysisParams.ThresholdMaxsize;
ParamVars.CircularityThres = AnalysisParams.CircularityThres;
ParamVars.ThresholdMinsize_Surges = AnalysisParams.ThresholdMinsize_Surges;
ParamVars.ThresholMinddur = AnalysisParams.ThresholMinddur;
ParamVars.ThresholMaxddur = AnalysisParams.ThresholMaxddur;
ParamVars.ThresholMinddur_Surges = AnalysisParams.ThresholMinddur_Surges;
ParamVars.Pixel_frame = AnalysisParams.Pixel_frame;
ParamVars.PercentileDetectionThres = AnalysisParams.PercentileDetectionThres;
ParamVars.RecAreaBackgroundPercentile = AnalysisParams.recAreaBackgroundPercentile;
ParamVars.RecAreaBinHalfSizeUm = AnalysisParams.recAreaBinHalfSizeUm;
ParamVars.RecAreaMinCoverageFraction = AnalysisParams.recAreaMinCoverageFraction;
ParamVars.SinkTraceCorrelationThreshold = AnalysisParams.sinkTraceCorrelationThreshold;
ParamVars.SinkNoiseCorrelationPercentile = AnalysisParams.sinkNoiseCorrelationPercentile;
ParamVars.EventBaselineReturnTolerance = AnalysisParams.eventBaselineReturnTolerance;
ParamVars.SinkDetectionNoiseAmpThreshold = AnalysisParams.sinkDetectionNoiseAmpThreshold;
ParamVars.PercentileSurgeDetectionThres = AnalysisParams.PercentileSurgeDetectionThres;
ParamVars.SurgeCircularityThreshold = AnalysisParams.surgeCircularityThreshold;
ParamVars.MaxOutsideRecordingAreaFraction = AnalysisParams.maxOutsideRecordingAreaFraction;

end
