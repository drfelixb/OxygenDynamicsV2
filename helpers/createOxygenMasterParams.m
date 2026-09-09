function [AnalysisParams,ParamVars] = createOxygenMasterParams(PixelSize,fs)
%CREATEOXYGENMASTERPARAMS Build oxygen master parameters and derived values.

AnalysisParams = struct();
AnalysisParams.smooth = 10;
AnalysisParams.ThresholdMinsize = 100;
AnalysisParams.ThresholdMaxsize = 6400;
AnalysisParams.CircularityThres = 0.3;
AnalysisParams.ThresholdMinsize_Surges = 400;
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
AnalysisParams.surgeOverlapSizeMarginPixels = AnalysisParams.smooth;
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
ParamVars.SurgeBaselineWindowFrames = round(AnalysisParams.surgeBaselineWindowSec * fs);
ParamVars.SurgeOverlapSizeMarginPixels = AnalysisParams.surgeOverlapSizeMarginPixels;
ParamVars.PercentileSurgeDetectionThres = AnalysisParams.PercentileSurgeDetectionThres;
ParamVars.SurgeCircularityThreshold = AnalysisParams.surgeCircularityThreshold;
ParamVars.MaxOutsideRecordingAreaFraction = AnalysisParams.maxOutsideRecordingAreaFraction;

end
