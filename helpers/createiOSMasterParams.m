function [AnalysisParams,ParamVars] = createiOSMasterParams(PixelSize,fs)
%CREATEIOSMASTERPARAMS Build iOS master parameters and derived values.

AnalysisParams = struct();
AnalysisParams.smooth = 10;
AnalysisParams.ThresholdMinsize = 100;
AnalysisParams.ThresholdMaxsize = 6400;
AnalysisParams.CircularityThres = 0.3;
AnalysisParams.ThresholdMinsize_Surges = 400;
AnalysisParams.fs = fs;
AnalysisParams.PixelSize = PixelSize;
AnalysisParams.Thesholdtime = 20 * fs;
AnalysisParams.ThresholMinddur = 3 * fs;
AnalysisParams.ThresholMaxddur = 150 * fs;
AnalysisParams.ThresholMinddur_Surges = 10 * fs;
AnalysisParams.Pixel_frame = AnalysisParams.smooth * 2;
AnalysisParams.PercentileDetectionThres = 98;
AnalysisParams.PercentileSurgeDetectionThres = 90;
AnalysisParams.SurgeCircularityThres = 0.1;
AnalysisParams.SurgeOverlapSizeMarginPixels = AnalysisParams.smooth;
AnalysisParams.SurgeBaselineWindowFrames = 20;
AnalysisParams.recAreaBackgroundPercentile = 25;
AnalysisParams.sinkTraceCorrelationThreshold = 0.8;
AnalysisParams.sinkNoiseCorrelationPercentile = 90;
AnalysisParams.sinkOverlapFractionThreshold = 0.7;
AnalysisParams.maxOutsideRecordingAreaFraction = 0.5;
AnalysisParams.putativeEventMaskMaxOutsideFraction = 0.3;

ParamVars = struct();
ParamVars.smooth = AnalysisParams.smooth;
ParamVars.ThresholdMinsize = AnalysisParams.ThresholdMinsize;
ParamVars.ThresholdMaxsize = AnalysisParams.ThresholdMaxsize;
ParamVars.CircularityThres = AnalysisParams.CircularityThres;
ParamVars.ThresholdMinsize_Surges = AnalysisParams.ThresholdMinsize_Surges;
ParamVars.Thesholdtime = AnalysisParams.Thesholdtime;
ParamVars.ThresholMinddur = AnalysisParams.ThresholMinddur;
ParamVars.ThresholMaxddur = AnalysisParams.ThresholMaxddur;
ParamVars.ThresholMinddur_Surges = AnalysisParams.ThresholMinddur_Surges;
ParamVars.Pixel_frame = AnalysisParams.Pixel_frame;
ParamVars.PercentileDetectionThres = AnalysisParams.PercentileDetectionThres;
ParamVars.PercentileSurgeDetectionThres = AnalysisParams.PercentileSurgeDetectionThres;
ParamVars.SurgeCircularityThres = AnalysisParams.SurgeCircularityThres;
ParamVars.SurgeOverlapSizeMarginPixels = AnalysisParams.SurgeOverlapSizeMarginPixels;
ParamVars.SurgeBaselineWindowFrames = AnalysisParams.SurgeBaselineWindowFrames;
ParamVars.RecAreaBackgroundPercentile = AnalysisParams.recAreaBackgroundPercentile;
ParamVars.SinkTraceCorrelationThreshold = AnalysisParams.sinkTraceCorrelationThreshold;
ParamVars.SinkNoiseCorrelationPercentile = AnalysisParams.sinkNoiseCorrelationPercentile;
ParamVars.SinkOverlapFractionThreshold = AnalysisParams.sinkOverlapFractionThreshold;
ParamVars.MaxOutsideRecordingAreaFraction = AnalysisParams.maxOutsideRecordingAreaFraction;
ParamVars.PutativeEventMaskMaxOutsideFraction = AnalysisParams.putativeEventMaskMaxOutsideFraction;

end
