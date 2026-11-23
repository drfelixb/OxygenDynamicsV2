function E=buildBOIWholeEventEvidence(Review,Index)
% Adapt an existing, verified in-memory review; never read source images.
A=Review.Audit;assert(isscalar(Index)&&Index==fix(Index)&&Index>=1&&Index<=height(A), ...
    'OxygenDynamics:WholeEventPreviewInput','Select one saved event.');
a=A(Index,:);assert(string(a.EventType)=="sink",'OxygenDynamics:WholeEventPreviewInput','This experimental preview currently assesses sinks only.');
t=Review.Traces{Index};N=Review.AnalysisInfo.NFrames;
corrected=nan(N,1);if isfield(t,'DetectionDetrended'),corrected=t.DetectionDetrended;end
E=struct('Raw',t.Raw,'Corrected',corrected,'SampleHz',Review.AnalysisInfo.AnalysisParams.fs, ...
    'SeedStartFrame',a.StartFrame,'SeedEndFrame',a.EndFrame, ...
    'NativeStartFrame',a.DetectedStartFrame,'NativeEndFrame',a.DetectedEndFrame, ...
    'NativeContact',nan(N,1),'NativeMaskPixels',nan(N,1), ...
    'Identity',sprintf('Sink site %d / event %d',a.SiteID,a.EventID), ...
    'AuditPath',Review.AuditPath,'AuditSHA256',Review.AuditSHA256, ...
    'RawSourceSHA256',Review.AnalysisInfo.RawSHA256,'FootprintPixels',numel(t.Footprint));
if isfield(Review,'ReferenceSources')
    S=Review.ReferenceSources;
    assert(strcmp(S.AuditSHA256,Review.AuditSHA256)&&S.EventCount==height(A), ...
        'OxygenDynamics:WholeEventPreviewInput','Attached native context differs from the selected audit.');
    contact=false(N,1);
    for k=1:height(A)
        frames=double(Review.Traces{k}.DetectedFrames(:));pixels=S.EventFramePixels{k};
        assert(numel(frames)==numel(pixels),'OxygenDynamics:WholeEventPreviewInput','Incomplete attached native context.');
        for f=1:numel(frames)
            if ~contact(frames(f)),contact(frames(f))=any(ismember(pixels{f},t.Footprint));end
        end
    end
    E.NativeContact=contact;E.NativeMaskPixels=zeros(N,1);
    E.NativeMaskPixels(t.DetectedFrames)=cellfun(@numel,S.EventFramePixels{Index});
    E.NativeMasterSHA256=S.MasterSHA256;
elseif isfield(Review,'NativeMasks')&&numel(Review.NativeMasks)>=Index&&~isempty(Review.NativeMasks{Index})
    E.NativeMaskPixels=cellfun(@numel,Review.NativeMasks{Index}.FramePixels);
end
end
