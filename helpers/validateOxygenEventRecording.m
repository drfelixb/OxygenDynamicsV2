function [R,Raw,Valid,dt,PixelArea] = validateOxygenEventRecording(R)
% Internal Y,X,T contract; full frames only. Unknown scale is [NaN NaN].
required={'RecordingID','MouseID','SourceIdentity','SignalProvenance','PixelSizeUm','NFrames','Intensity','AxisOrder','ValidMask'};
for k=1:numel(required), assert(isfield(R,required{k}),'eventFirst:Input','Missing Recording.%s',required{k}); end
for name={'RecordingID','MouseID','SourceIdentity','SignalProvenance'}
    R.(name{1})=string(R.(name{1}));
    assert(isscalar(R.(name{1})) && ~ismissing(R.(name{1})) && strlength(R.(name{1}))>0,'eventFirst:Input','%s must be nonempty scalar text.',name{1});
end
assert(string(R.AxisOrder)=="YXT",'eventFirst:Axes','Convert source explicitly to full-frame YXT before detection.');
validateattributes(R.Intensity,{'numeric'},{'real','nonempty'});
assert(ndims(R.Intensity)<=3 && size(R.Intensity,3)==R.NFrames && R.NFrames>=3,'eventFirst:Input','NFrames must match T and be at least 3.');
Raw=double(R.Intensity); sz=size(Raw); sz(3)=R.NFrames;
validateattributes(R.PixelSizeUm,{'numeric'},{'vector','numel',2,'real'});
assert(all(isnan(R.PixelSizeUm)) || all(isfinite(R.PixelSizeUm)&R.PixelSizeUm>0),'eventFirst:Calibration','Use positive [Y X] um or [NaN NaN].');
PixelArea=prod(R.PixelSizeUm);
if isfield(R,'FrameTimestampsSec')
    t=double(R.FrameTimestampsSec(:));
    assert(numel(t)==R.NFrames && all(isfinite(t)) && all(diff(t)>0),'eventFirst:Timing','Invalid timestamps.');
    d=median(diff(t));
    assert(max(abs(diff(t)-d))<=max(1e-9,1e-6*d),'eventFirst:Timing','Irregular or missing timestamps unsupported; provide contiguous exposures with ValidMask exclusions.');
    if isfield(R,'fs'), assert(abs(R.fs-1/d)<1e-6*R.fs,'eventFirst:Timing','fs conflicts with timestamps.'); end
    R.fs=1/d; R.TimeOriginSec=t(1);
else
    assert(isfield(R,'fs'),'eventFirst:Timing','fs or timestamps required.');
    R.TimeOriginSec=0;
end
validateattributes(R.fs,{'numeric'},{'scalar','real','finite','positive'}); dt=1/R.fs;
if isfield(R,'ExposureDurationSec')
    assert(all(abs(R.ExposureDurationSec-dt)<1e-9),'eventFirst:Timing','Noncontiguous/variable exposures unsupported.');
end
assert(islogical(R.ValidMask),'eventFirst:Mask','ValidMask must be logical.');
if isequal(size(R.ValidMask),sz(1:2)), Valid=repmat(R.ValidMask,1,1,sz(3));
else, assert(isequal(size(R.ValidMask),sz),'eventFirst:Mask','ValidMask must be YX or YXT.'); Valid=R.ValidMask; end
R.NonfiniteVoxelCount=nnz(~isfinite(Raw));
Valid=Valid & isfinite(Raw);
R.SaturatedVoxelCount=0;
if isfield(R,'SaturationLevel')
    validateattributes(R.SaturationLevel,{'numeric'},{'scalar','finite'});
    R.SaturatedVoxelCount=nnz(Raw>=R.SaturationLevel); Valid=Valid & Raw<R.SaturationLevel;
end
R.DarkOffsetStatus="unknown; relative BLI may be offset biased";
if isfield(R,'DarkOffset')
    assert(isfield(R,'DarkOffsetProvenance') && strlength(string(R.DarkOffsetProvenance))>0,'eventFirst:Calibration','Dark offset requires provenance.');
    validateattributes(R.DarkOffset,{'numeric'},{'scalar','finite','real'});
    Raw=Raw-R.DarkOffset; R.DarkOffsetStatus="calibrated subtraction: "+string(R.DarkOffsetProvenance);
end
if isfield(R,'TissueMask')
    assert(islogical(R.TissueMask)&&isequal(size(R.TissueMask),sz(1:2)),'eventFirst:Mask','TissueMask must be logical YX.');
    R.TissueMaskSource="explicit";
else
    proposal=Raw; proposal(~Valid)=NaN;
    med=median(proposal,3,'omitnan');
    R.TissueMask=isfinite(med)&med>0;
    R.TissueMaskSource="estimated: temporal median > 0; review required (not anatomical segmentation)";
end
Valid=Valid & R.TissueMask;
for name={'Condition','Genotype','Promoter','SourceScaling','MotionProvenance','ExclusionReasons'}
    if ~isfield(R,name{1}), R.(name{1})="unknown"; end
    R.(name{1})=string(R.(name{1}));
end
end
