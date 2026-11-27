function [e,ar]=nearbyMatchEvents(R,e)
A=R.Audit;sink=find(string(A.EventType)=="sink");
[ok,k]=ismember([e.SinkID,e.EventID],[A.SiteID(sink),A.EventID(sink)],'rows');ar=sink(k(ok));
assert(all(ok)&&height(e)==numel(sink)&&numel(unique(ar))==numel(sink), ...
    'Saved event table and audit have different sink identities.');
assert(all(string(A.RecordingID(ar))==string(e.RecordingID)), ...
    'The selected statistics and audit identify different source recordings.');
if ismember('EventReferenceAuditSHA256',e.Properties.VariableNames)
    h=string(e.EventReferenceAuditSHA256);
    h=h(~ismissing(h) & strlength(h)>0);
    assert(all(strcmpi(h,R.AuditSHA256)),'Source audit differs from the event-reference audit saved in the statistics.');
end
assert(all(A.StartFrame(ar)==e.StartFrame & A.EndFrame(ar)==e.EndFrame & ...
    A.DetectedStartFrame(ar)==e.NativeStartFrame & A.DetectedEndFrame(ar)==e.NativeEndFrame), ...
    'Saved event table and audit have different bounds.');
if ismember('CameraOffsetCounts',e.Properties.VariableNames) && ~isempty(e)
    offset=boiCameraOffset(R.AnalysisInfo); if isempty(offset),offset=NaN;end
    assert(isequaln(e.CameraOffsetCounts,repmat(offset,height(e),1)),'OxygenDynamics:PocketSource', ...
        'Saved statistics and source audit use different camera offsets.');
end
fs=R.AnalysisInfo.AnalysisParams.fs;
assert(all(e.NFrames==R.AnalysisInfo.NFrames & e.SampleF==fs & e.EventReferenceRequestedSamples==round(20*fs)), ...
    'Saved clock, movie length or reference duration differs from the 20-second analysis.');
end
