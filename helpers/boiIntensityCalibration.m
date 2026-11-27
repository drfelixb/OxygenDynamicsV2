function C=boiIntensityCalibration(source)
% Saved provenance for ratios. Original counts are always retained as evidence.
if nargin==0,source=[];end
offset=boiCameraOffset(source);
C=struct('CameraOffsetCounts',offset,'CameraOffsetSource','not_supplied', ...
    'IntensityRatiosOffsetCorrected',~isempty(offset),'IntensityRatioDefinition','0.4.0-draft','ReferencesAtOrBelowOffset',0);
if ~isempty(offset)
    C.CameraOffsetSource='user_supplied';
    C.IntensityRatioDefinition='0.5.0-offset';
end
if isstruct(source)&&isfield(source,'ReferencesAtOrBelowOffset')
    C.ReferencesAtOrBelowOffset=source.ReferencesAtOrBelowOffset;
end
end
