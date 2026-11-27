function validateBOIAreaReview(D)
% Geometry/state validation only. Source files are revalidated by the loader.
id='OxygenDynamics:InvalidAreaReview';
assert(isstruct(D)&&isscalar(D)&&strcmp(D.Schema,'boi-reviewed-event-area-1')&&~D.AutomaticResultsChanged,id,'Unsupported area revision.');
C=D.Context;assert(strcmp(C.Schema,'boi-reviewed-area-context-1')&&strcmp(D.ContextSHA256,boiPocketDigest(C)),id,'Area context changed.');
frames=double(C.Frames(:));sz=double(C.FrameSize(:)');foot=double(C.FixedFootprint(:));
assert(numel(sz)==2&&all(isfinite(sz)&sz>=1&sz==fix(sz))&&~isempty(frames)&&all(isfinite(frames)&frames==fix(frames)&frames>=1)&&all(diff(frames)==1),id,'Invalid spatial/time grid.');
assert(~isempty(foot)&&all(isfinite(foot)&foot>=1&foot<=prod(sz)&foot==fix(foot))&&isequal(foot,unique(foot)),id,'Invalid accepted footprint.');
ampValid=isscalar(C.AmplitudePercent)&&isfinite(C.AmplitudePercent)&&C.AmplitudePercent>=0;
offset=boiCameraOffset(C);
blocked=~isempty(offset) && isfinite(C.RawReferenceMean) && C.RawReferenceMean<=offset && ...
    isfield(C,'AmplitudeStatus') && strcmp(C.AmplitudeStatus,'reference_at_or_below_camera_offset') && ...
    (isempty(C.AmplitudePercent)||(isscalar(C.AmplitudePercent)&&isnan(C.AmplitudePercent)));
assert(C.SampleHz==1&&C.FrameOrigin==1&&C.DurationSec==numel(frames)/C.SampleHz&& ...
    all(isfinite([C.PixelSizeUm C.RecordingAreaUm2 C.RecordingDurationSec]))&& ...
    all([C.PixelSizeUm C.RecordingAreaUm2 C.RecordingDurationSec]>0)&&(ampValid || blocked),id,'Invalid approved scales or amplitude.');
assert(isnumeric(D.Revision)&&isscalar(D.Revision)&&D.Revision>=0&&D.Revision==fix(D.Revision),id,'Invalid revision.');
assert(numel(D.FrameDecisions)==numel(frames),id,'Require exactly one decision for every reviewed frame.');
for k=1:numel(frames)
    F=D.FrameDecisions(k);p=double(F.Pixels(:));
    assert(F.Frame==frames(k)&&ismember(F.Status,{'unreviewed','accepted','empty','uncertain'}),id,'Invalid frame state or ordering.');
    assert(isnumeric(F.Pixels)&&isreal(F.Pixels)&&all(isfinite(p)&p==fix(p)&p>=1&p<=prod(sz))&&isequal(p,unique(p)),id,'Mask pixels must be unique, sorted and within the source frame.');
    assert(~strcmp(F.Status,'accepted')||~isempty(p),id,'Use an explicit empty judgment for zero area.');
    assert(~strcmp(F.Status,'empty')||isempty(p),id,'An empty judgment cannot retain area pixels.');
    if ismember(F.Status,{'accepted','empty'})
        assert(~isempty(strtrim(F.Reviewer))&&ischar(F.DecidedUTC)&&~isempty(regexp(F.DecidedUTC,'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$','once')),id,'Accepted frames need a reviewer and recorded decision time.');
    end
end
if D.Revision>0,assert(~isempty(strtrim(D.Reviewer))&&~isempty(strtrim(D.Reason))&&~isempty(D.CreatedUTC),id,'A saved revision needs reviewer, reason and time.');end
end
