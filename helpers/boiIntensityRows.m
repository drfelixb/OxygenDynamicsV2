function T=boiIntensityRows(T,source)
% Add recording-level calibration to event, recording or trace rows.
if ~istable(T) && isempty(T),T=table();end
C=boiIntensityCalibration(source);n=height(T);
v=C.CameraOffsetCounts;if isempty(v),v=NaN;end
T.CameraOffsetCounts=repmat(v,n,1);
T.CameraOffsetSource=repmat(string(C.CameraOffsetSource),n,1);
T.IntensityRatiosOffsetCorrected=repmat(C.IntensityRatiosOffsetCorrected,n,1);
T.IntensityRatioDefinition=repmat(string(C.IntensityRatioDefinition),n,1);
T.ReferencesAtOrBelowOffset=repmat(C.ReferencesAtOrBelowOffset,n,1);
end
