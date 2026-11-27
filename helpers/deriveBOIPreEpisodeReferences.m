function E=deriveBOIPreEpisodeReferences(E,Evidence,AllNativePixels,fs,baselineSec,source,offset)
% Derived sink reference on unchanged fixed footprints and measurement intervals.
% Evidence is one {Raw,Footprint,DetectedFrames} struct per event; AllNativePixels
% includes ALL sites of BOTH signs, before any statistics curation/filtering.
if nargin<7,offset=[];end
if nargin<6,source="preserved_input_event_footprint";end
P=boiEpisodeReferencePolicy(offset);E=initializeBOIEpisodeReferences(E,"unavailable",source);
assert(isscalar(fs)&&isfinite(fs)&&fs>0&&isscalar(baselineSec)&&isfinite(baselineSec)&&baselineSec>0, ...
    'OxygenDynamics:EpisodeScale','Positive sample rate and baseline duration are required.');
assert(iscell(AllNativePixels)&&iscell(Evidence)&&numel(Evidence)==height(E), ...
    'OxygenDynamics:EpisodeEvidence','Full native support and per-event evidence are required.');
N=numel(AllNativePixels);required=round(baselineSec*fs);
assert(required>=1,'OxygenDynamics:EpisodeScale','Baseline requires at least one sample.');
E.EpisodeReferenceVersion(:)=string(P.Version);
if isempty(E),return;end
assert(all(ismember({'SinkID','EventID','StartFrame','EndFrame'},E.Properties.VariableNames)), ...
    'OxygenDynamics:EpisodeEvidence','Event identity and measurement frames are required.');
if ismember('RecordingID',E.Properties.VariableNames)
    assert(numel(unique(string(E.RecordingID)))==1,'OxygenDynamics:EpisodeEvidence','Derive one recording at a time.');
end
assert(height(unique(E(:,{'SinkID','EventID'}),'rows'))==height(E), ...
    'OxygenDynamics:EpisodeEvidence','Duplicate event identity.');
nativeStart=zeros(height(E),1);nativeEnd=nativeStart;
for e=1:height(E)
    T=Evidence{e};d=double(T.DetectedFrames(:));px=double(T.Footprint(:));
    assert(numel(T.Raw)==N&&~isempty(px)&&all(isfinite(px)&px>=1&px==fix(px))&& ...
        ~isempty(d)&&all(isfinite(d)&d>=1&d<=N&d==fix(d))&&all(diff(d)==1), ...
        'OxygenDynamics:EpisodeEvidence','Invalid trace, footprint or native interval.');
    nativeStart(e)=d(1);nativeEnd(e)=d(end);
end
for f={'StartFrame','EndFrame'}
    v=E.(f{1});assert(all(isfinite(v)&v==fix(v)&v>=1&v<=N), ...
        'OxygenDynamics:EpisodeEvidence','Invalid measurement interval.');
end
assert(all(E.EndFrame>=E.StartFrame),'OxygenDynamics:EpisodeEvidence','Reversed measurement interval.');
if ismember('NativeStartFrame',E.Properties.VariableNames)
    assert(isequal(double(E.NativeStartFrame),nativeStart)&&isequal(double(E.NativeEndFrame),nativeEnd), ...
        'OxygenDynamics:EpisodeEvidence','Event native frames differ from saved evidence.');
end
head=(1:height(E))';
for s=reshape(unique(E.SinkID),1,[])
    rows=find(E.SinkID==s);[~,order]=sort(nativeStart(rows));rows=rows(order);
    for j=2:numel(rows)
        a=rows(j-1);b=rows(j);gap=(nativeStart(b)-nativeEnd(a)-1)/fs;
        assert(gap>0,'OxygenDynamics:EpisodeEvidence','Native runs at one site must be disjoint.');
        if gap<P.CloseNativeGapSec && ~isempty(intersect(Evidence{a}.Footprint,Evidence{b}.Footprint))
            head(b)=head(a);
        end
    end
end
for e=1:height(E)
    h=head(e);raw=double(Evidence{e}.Raw(:));px=Evidence{e}.Footprint;
    E.EpisodeHeadEventID(e)=E.EventID(h);
    E.EpisodeRecurrent(e)=sum(head==h)>1;
    E.EpisodeReferenceKind(e)="immediate_pre_event";
    if h~=e,E.EpisodeReferenceKind(e)="pre_episode";end
    E.EpisodeReferenceRequiredSamples(e)=required;
    first=E.StartFrame(h);shift=(E.StartFrame(e)-first)/fs;
    E.EpisodeReferenceShiftSec(e)=shift;
    E.EpisodeAcquisitionStart(e)=nativeStart(h)==1 || first==1;
    E.EpisodeReferenceStartFrame(e)=max(1,first-required);
    E.EpisodeReferenceEndFrame(e)=first-1;
    if E.EpisodeAcquisitionStart(e)
        E.EpisodeReferenceStartFrame(e)=NaN;E.EpisodeReferenceEndFrame(e)=NaN;
        E.EpisodeReferenceStatus(e)="recording_start_recovery_unclear";continue
    elseif shift<0 || shift>P.MaxReferenceShiftSec
        E.EpisodeReferenceStatus(e)="reference_too_old_review";continue
    end
    b=max(1,first-required):first-1;clean=isfinite(raw(b));
    for j=1:numel(b)
        clean(j)=clean(j)&&isempty(intersect(px,AllNativePixels{b(j)}));
    end
    E.EpisodeReferenceValidSamples(e)=sum(clean);
    if numel(b)~=required || ~all(clean)
        E.EpisodeReferenceStatus(e)="insufficient_clean_pre_episode_reference";continue
    end
    B=mean(raw(b));E.EpisodeReferenceValue(e)=B;
    signal=raw(E.StartFrame(e):E.EndFrame(e));
    [denom,blocked]=boiIntensityDenominator(B,offset);
    if blocked
        E.EpisodeReferenceStatus(e)="reference_at_or_below_camera_offset";
        if B>0 && all(isfinite(signal)),E.EpisodeReferenceNeedsReview(e)=min(signal)>B;end
        continue
    end
    if ~isfinite(B)||B<=0||any(~isfinite(signal))
        E.EpisodeReferenceStatus(e)="nonpositive_reference_or_missing_event_signal";continue
    end
    % Preserve direction; a negative drop is flagged, never made positive.
    E.EpisodeAmplitudePercent(e)=-100*min((signal-B)/denom);
    E.EpisodeReferenceStatus(e)="valid";E.EpisodeReferenceNeedsReview(e)=false;
    if E.EpisodeAmplitudePercent(e)<0
        E.EpisodeReferenceStatus(e)="wrong_direction";E.EpisodeReferenceNeedsReview(e)=true;
    end
end
end
