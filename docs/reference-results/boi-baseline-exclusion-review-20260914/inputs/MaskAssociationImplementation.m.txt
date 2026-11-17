function Review=attachBOINativeMasks(Review,Index,MasterPath)
%ATTACHBOINATIVEMASKS Associate a selected event with a checked master snapshot.
% The original audit did not capture this file hash; do not imply otherwise.
Data=buildBOIEventReviewData(Review,Index);A=Data.Row;
assert(strcmp(oxygenFileSHA256(Review.AuditPath),Review.AuditSHA256), ...
    'OxygenDynamics:EventReviewChanged','Audit changed since opening; reopen before attaching masks.');
MasterPath=char(java.io.File(char(MasterPath)).getCanonicalPath());
before=oxygenFileSHA256(MasterPath);
prefix='Sink';if A.EventType=="surge",prefix='Surge';end
siteName=['Table_Oxygen' prefix 's_Out'];eventName=['Table_Oxygen' prefix 'Events_Out'];
S=load(MasterPath,'AnalysisInfo',siteName,eventName);
assert(all(isfield(S,{'AnalysisInfo',siteName,eventName}))&&isequaln(S.AnalysisInfo,Review.AnalysisInfo), ...
    'OxygenDynamics:NativeMaskProvenance','Master analysis metadata must exactly match the saved audit, including source, settings and acquisition snapshot.');
Sites=S.(siteName);Events=S.(eventName);siteCol=[prefix 'ID'];ampCol=['NormOxy' prefix 'Amp'];
assert(istable(Sites)&&istable(Events)&& ...
    all(ismember({'RecordingID','SiteID','FramePixels','FrameSize','NFrames','SampleF'},Sites.Properties.VariableNames))&& ...
    all(ismember({'RecordingID',siteCol,'EventID','StartFrame','EndFrame','BaselineValue','BaselineStatus',ampCol},Events.Properties.VariableNames)), ...
    'OxygenDynamics:NativeMaskIdentity','Master lacks native-mask identity or measurement evidence.');
s=find(string(Sites.RecordingID)==A.RecordingID&Sites.SiteID==A.SiteID);
e=find(string(Events.RecordingID)==A.RecordingID&Events.(siteCol)==A.SiteID&Events.EventID==A.EventID);
assert(isscalar(s)&&isscalar(e),'OxygenDynamics:NativeMaskIdentity','Require one matching recording/site/event in the selected master.');
E=Events(e,:);I=Review.AnalysisInfo;
assert(isequaln([E.StartFrame,E.EndFrame],[A.StartFrame,A.EndFrame])&& ...
    isequaln(E.BaselineValue,A.StoredBaseline)&&string(E.BaselineStatus)==A.StoredStatus&& ...
    isequaln(E.(ampCol),A.StoredAmplitude)&&isequal(Sites.FrameSize{s},I.FrameSize)&& ...
    Sites.NFrames(s)==I.NFrames&&Sites.SampleF(s)==I.AnalysisParams.fs, ...
    'OxygenDynamics:NativeMaskIdentity','Event timing, stored measurement or spatial/time grid differs from the audit.');
c=Sites.FramePixels{s};
assert(iscell(c)&&numel(c)==I.NFrames,'OxygenDynamics:NativeMaskSupport','Native frame support is incomplete.');
c=c(:);
for f=1:numel(c)
    p=c{f};
    assert(isnumeric(p)&&all(isfinite(p(:))&p(:)>=1&p(:)<=prod(I.FrameSize)&p(:)==fix(p(:)))&& ...
        numel(unique(p))==numel(p),'OxygenDynamics:NativeMaskSupport','Invalid native pixel indices at frame %d.',f);
    c{f}=p(:);
end
active=~cellfun(@isempty,c);starts=find(diff([false;active])==1);ends=find(diff([active;false])==-1);
k=A.EventID;
assert(k>=1&&k==fix(k)&&k<=numel(starts),'OxygenDynamics:NativeMaskIdentity','Event ID has no matching native run.');
frames=(starts(k):ends(k))';
assert(isequal(frames,Review.Traces{Index}.DetectedFrames(:))&& ...
    isequal(unique(vertcat(c{frames})),sort(Review.Traces{Index}.Footprint(:))), ...
    'OxygenDynamics:NativeMaskSupport','Native run bounds or union footprint differs from the audit.');
eventPixels=cell(I.NFrames,1);eventPixels(frames)=c(frames);
assert(strcmp(before,oxygenFileSHA256(MasterPath)), ...
    'OxygenDynamics:NativeMaskChanged','Master changed while loading; attach it again.');
association='AnalysisInfo, event identity, stored measurement, native run bounds and union matched. Original audit did not capture master checksum.';
if isfield(Review,'AuditCreationReceipt')
    signIndex=1;if strcmp(prefix,'Surge'),signIndex=2;end
    expected=string(Review.AuditCreationReceipt.MasterSHA256);
    assert(string(before)==expected(signIndex),'OxygenDynamics:NativeMaskProvenance','Master differs from the checksum captured when this audit was created.');
    association='Source, metadata, event identity, native support and master checksum match the saved audit creation receipt.';
end
Attachment=struct('Schema','boi-native-mask-attachment-1','AuditSHA256',Review.AuditSHA256, ...
    'RecordingID',char(A.RecordingID),'EventType',char(A.EventType),'SiteID',A.SiteID,'EventID',A.EventID, ...
    'MasterPath',MasterPath,'MasterSHA256',before,'FrameSize',I.FrameSize,'FramePixels',{eventPixels}, ...
    'AttachedUTC',char(datetime('now','TimeZone','UTC','Format','yyyy-MM-dd''T''HH:mm:ssXXX')), ...
    'Association',association, ...
    'ScientificStatus','not_established','OutsideNativeRun','Known empty for this selected event; other events at the same site are not included.');
if ~isfield(Review,'NativeMasks'),Review.NativeMasks=cell(height(Review.Audit),1);end
Review.NativeMasks{Index}=Attachment;
end
