function [Summary,EventAudit,FrameAudit]=auditBOISavedMeasurementSupport(Sites,Events,Info,kind,RecordingID)
%AUDITBOISAVEDMEASUREMENTSUPPORT Development diagnostic; never excludes events.
assert(ismember(string(kind),["sink","surge"]));prefix='Sink';if strcmp(kind,'surge'),prefix='Surge';end
N=Info.NFrames;fs=Info.AnalysisParams.fs;px=Info.AnalysisParams.PixelSize;
shapeOrigin='saved_master_metadata';
if isfield(Info,'FrameSize')
    shape=Info.FrameSize;
else
    assert(~isempty(Sites)&&ismember('FrameSize',Sites.Properties.VariableNames), ...
        'OxygenDynamics:SupportAuditMasks','Native dimensions are unavailable in master metadata and saved sites.');
    shape=Sites.FrameSize{1};shapeOrigin='saved_site_table; older_master_metadata_lacks_FrameSize';
    assert(all(cellfun(@(v)isequal(v,shape),Sites.FrameSize)), ...
        'OxygenDynamics:SupportAuditMasks','Saved sites disagree on native dimensions.');
end
assert(numel(shape)==2&&all(isfinite(shape)&shape>=1&shape==fix(shape)));
assert(N>=1&&N==fix(N)&&fs>0&&isfinite(fs)&&px>0&&isfinite(px));
tissue=Info.([prefix 'EligibleTissuePixels']);mask=false(shape);mask(tissue)=true;area=nnz(mask)*px^2;
siteCol=[prefix 'ID'];ampCol=['NormOxy' prefix 'Amp'];
assert(all(string(Events.RecordingID)==string(RecordingID))&&all(string(Sites.RecordingID)==string(RecordingID)), ...
    'OxygenDynamics:SupportAuditIdentity','Events and sites must belong to the selected recording.');
assert(height(unique(Events(:,{siteCol,'EventID'}),'rows'))==height(Events)&&numel(unique(Sites.SiteID))==height(Sites), ...
    'OxygenDynamics:SupportAuditIdentity','Duplicate event or site identity.');
finite=isfinite(Events.(ampCol));nativeStarts=nan(height(Events),1);nativeEnds=nativeStarts;
classBySite=zeros(height(Sites),N);matched=false(height(Events),1);
for s=1:height(Sites)
    c=Sites.FramePixels{s};assert(iscell(c)&&numel(c)==N,'OxygenDynamics:SupportAuditMasks','Incomplete saved native masks.');
    assert(isequal(sort(Sites.EligibleTissuePixels{s}(:)),sort(tissue(:))), ...
        'OxygenDynamics:SupportAuditMasks','Site and source metadata tissue supports differ.');
    active=~cellfun(@isempty,c(:));starts=find(diff([false;active])==1);ends=find(diff([active;false])==-1);
    for f=1:N
        p=c{f};assert(isnumeric(p)&&all(isfinite(p(:))&p(:)>=1&p(:)<=prod(shape)&p(:)==fix(p(:)))&&numel(unique(p))==numel(p), ...
            'OxygenDynamics:SupportAuditMasks','Invalid native pixel support.');
    end
    for k=1:numel(starts)
        e=find(Events.(siteCol)==Sites.SiteID(s)&Events.EventID==k);
        assert(isscalar(e),'OxygenDynamics:SupportAuditIdentity','Every native run must map to one saved event; no silent dropped support.');
        nativeStarts(e)=starts(k);nativeEnds(e)=ends(k);matched(e)=true;
        classBySite(s,starts(k):ends(k))=1+double(~finite(e));
    end
end
assert(all(matched),'OxygenDynamics:SupportAuditIdentity','Every event must map to a saved native run.');
if ismember('NativeStartFrame',Events.Properties.VariableNames)
    assert(isequal(Events.NativeStartFrame,nativeStarts)&&isequal(Events.NativeEndFrame,nativeEnds), ...
        'OxygenDynamics:SupportAuditIdentity','Saved native bounds disagree with event runs.');
end
assert(all(Events.StartFrame>=1&Events.EndFrame<=N&Events.StartFrame<=Events.EndFrame& ...
    Events.StartFrame==fix(Events.StartFrame)&Events.EndFrame==fix(Events.EndFrame)), ...
    'OxygenDynamics:SupportAuditIdentity','Invalid measurement bounds.');
knownOnly=zeros(N,1);missingOnly=knownOnly;shared=knownOnly;
for f=1:N
    known=false(shape);missing=false(shape);
    for s=1:height(Sites)
        c=Sites.FramePixels{s};p=c{f};
        if classBySite(s,f)==1,known(p)=true;elseif classBySite(s,f)==2,missing(p)=true;end
    end
    known=known&mask;missing=missing&mask;
    knownOnly(f)=nnz(known&~missing);missingOnly(f)=nnz(missing&~known);shared(f)=nnz(known&missing);
    assert(knownOnly(f)+missingOnly(f)+shared(f)==nnz(known|missing));
end
FrameAudit=table(repmat(string(RecordingID),N,1),repmat(string(kind),N,1),(1:N)', ...
    knownOnly,missingOnly,shared,knownOnly+missingOnly+shared,ones(N,1)/fs, ...
    'VariableNames',{'RecordingID','EventType','Frame','FiniteAmplitudeOnlyPixels','UnavailableAmplitudeOnlyPixels','SharedPixels','AllCoveredPixels','ModeledIntervalSec'});
EventAudit=table(repmat(string(RecordingID),height(Events),1),repmat(string(kind),height(Events),1),Events.(siteCol),Events.EventID, ...
    Events.(ampCol),finite,string(Events.BaselineStatus),Events.StartFrame,Events.EndFrame,nativeStarts,nativeEnds, ...
    'VariableNames',{'RecordingID','EventType','SiteID','EventID','AmplitudeFraction','AmplitudeFinite','BaselineStatus', ...
    'MeasurementStartFrame','MeasurementEndFrame','NativeStartFrame','NativeEndFrame'});
EventAudit.MeasurementDurationSec=(Events.EndFrame-Events.StartFrame+1)/fs;
EventAudit.NativeDurationSec=(nativeEnds-nativeStarts+1)/fs;
overlap=max(0,min(Events.EndFrame,nativeEnds)-max(Events.StartFrame,nativeStarts)+1)/fs;
EventAudit.MeasurementSecondsOutsideNativeRun=EventAudit.MeasurementDurationSec-overlap;
EventAudit.NativeSecondsOutsideMeasurement=EventAudit.NativeDurationSec-overlap;
EventAudit.MeasurementStartsAtAcquisition=Events.StartFrame==1;EventAudit.MeasurementEndsAtAcquisition=Events.EndFrame==N;
EventAudit.NativeStartsAtAcquisition=nativeStarts==1;EventAudit.NativeEndsAtAcquisition=nativeEnds==N;
EventAudit.CloseNativeRun=nan(height(Events),1);
if ismember('CloseNativeRun',Events.Properties.VariableNames),EventAudit.CloseNativeRun=double(Events.CloseNativeRun);end
EventAudit.RecurrentSite=ismember(Events.(siteCol),Sites.SiteID(sum(diff([zeros(height(Sites),1),classBySite>0],1,2)==1,2)>1));
% Verify that splitting by availability preserved the complete native union.
series=computeOngoingRegionSeries(Sites,N,px,kind);
assert(all(abs(FrameAudit.AllCoveredPixels*px^2-series.AreaUm(:))<=1e-9*max(1,area)), ...
    'OxygenDynamics:SupportAuditUnion','Availability partition changed full native coverage.');
partition=[sum(knownOnly),sum(missingOnly),sum(shared)]*px^2/fs;total=sum(partition);den=area*N/fs;
Summary=struct('RecordingID',char(RecordingID),'EventType',kind,'NFrames',N,'SampleHz',fs,'PixelSizeUm',px, ...
    'SourceSHA256',Info.RawSHA256,'FrameSizeEvidence',shapeOrigin,'Events',height(Events),'FiniteAmplitudeEvents',sum(finite),'UnavailableAmplitudeEvents',sum(~finite), ...
    'NegativeFiniteAmplitudes',sum(Events.(ampCol)<0),'AnalyzedAreaUm2',area,'AnalyzedTissueTimeUm2Sec',den, ...
    'FiniteOnlyAreaTimeUm2Sec',partition(1),'UnavailableOnlyAreaTimeUm2Sec',partition(2),'SharedAreaTimeUm2Sec',partition(3), ...
    'AllCoveredAreaTimeUm2Sec',total,'AllOccupiedFraction',ratio(total,den), ...
    'FiniteAmplitudeUnionOccupiedFraction',ratio(partition(1)+partition(3),den), ...
    'UnavailableOnlyFractionOfCoveredAreaTime',ratio(partition(2),total), ...
    'MeasurementStartContact',sum(EventAudit.MeasurementStartsAtAcquisition),'MeasurementEndContact',sum(EventAudit.MeasurementEndsAtAcquisition), ...
    'NativeStartContact',sum(EventAudit.NativeStartsAtAcquisition),'NativeEndContact',sum(EventAudit.NativeEndsAtAcquisition), ...
    'MeasurementSeconds',sum(EventAudit.MeasurementDurationSec),'NativeEventSeconds',sum(EventAudit.NativeDurationSec), ...
    'MeasurementSecondsOutsideNativeRuns',sum(EventAudit.MeasurementSecondsOutsideNativeRun), ...
    'EventsWithMeasurementTimeOutsideNativeRun',sum(EventAudit.MeasurementSecondsOutsideNativeRun>0), ...
    'RecurrentSiteEvents',sum(EventAudit.RecurrentSite),'ScientificStatus','not_established');
end
function v=ratio(a,b)
v=NaN;if isfinite(b)&&b>0,v=a/b;end
end
