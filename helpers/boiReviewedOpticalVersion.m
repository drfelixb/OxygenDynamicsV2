function version=boiReviewedOpticalVersion(source,replay)
if nargin<2,replay=false;end
version='0.1.0-draft';
if ~isempty(boiCameraOffset(source)),version='0.2.0-offset';end
if replay && ~isempty(boiCameraOffset(source))
    assert(isfield(source,'ReviewedOpticalVersion'),'OxygenDynamics:ReviewedOpticalDefinitionChanged', ...
        'Offset-aware reviewed evidence must identify its saved definition.');
end
if isstruct(source) && isfield(source,'ReviewedOpticalVersion')
    assert(strcmp(version,source.ReviewedOpticalVersion),'OxygenDynamics:ReviewedOpticalDefinitionChanged', ...
        'Saved reviewed optical definition and camera offset disagree.');
    version=source.ReviewedOpticalVersion;
end
end
