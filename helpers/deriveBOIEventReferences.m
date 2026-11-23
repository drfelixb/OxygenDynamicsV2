function E=deriveBOIEventReferences(E,Evidence,AllNativePixels,fs,baselineSec,source,override)
% Fixed raw event footprints, unchanged timing. Both references are explicit.
% Optional override: scalar struct(StartFrame,EndFrame,Source), recording-wide.
% Empty native evidence permits measurements, but reports unknown overlap QC.
if nargin<6,source="preserved_input_event_footprint";end
if nargin<7,override=[];end
id='OxygenDynamics:EventReferenceEvidence';
assert(istable(E)&&iscell(Evidence)&&numel(Evidence)==height(E),id,'One evidence trace per event is required.');
assert(isscalar(fs)&&isfinite(fs)&&fs>0&&isscalar(baselineSec)&&isfinite(baselineSec)&& ...
    baselineSec>0&&round(baselineSec*fs)>=1,'OxygenDynamics:EventReferenceScale','Positive clock and reference duration required.');
P=boiEventReferencePolicy;required=round(baselineSec*fs);
requestedStart=1;requestedEnd=round(P.RecordingComparisonDefaultSec*fs);
overrideSource="default_first_20_seconds";
if ~isempty(override)
    assert(isstruct(override)&&isscalar(override)&&all(isfield(override,{'StartFrame','EndFrame','Source'})), ...
        id,'Override requires explicit StartFrame, EndFrame and Source.');
    requestedStart=override.StartFrame;requestedEnd=override.EndFrame;
    assert(isnumeric(requestedStart)&&isnumeric(requestedEnd)&&isscalar(requestedStart)&&isscalar(requestedEnd)&& ...
        all(isfinite([requestedStart requestedEnd]))&&requestedStart>=1&&requestedEnd>=requestedStart&& ...
        all(fix([requestedStart requestedEnd])==[requestedStart requestedEnd])&& ...
        isscalar(string(override.Source))&&strlength(strip(string(override.Source)))>0,id,'Invalid recording reference override.');
    overrideSource=string(override.Source);
end
E=initializeBOIEventReferences(E,"unavailable",source);
if isempty(E),return;end
assert(all(ismember({'SinkID','EventID','StartFrame','EndFrame'},E.Properties.VariableNames)),id,'Event identity and frames required.');
assert(height(unique(E(:,{'SinkID','EventID'}),'rows'))==height(E),id,'Duplicate event identity.');
if ismember('RecordingID',E.Properties.VariableNames)
    assert(numel(unique(string(E.RecordingID)))==1,id,'Derive one recording at a time.');
end
N=numel(Evidence{1}.Raw);
assert(iscell(AllNativePixels)&& (isempty(AllNativePixels)||numel(AllNativePixels)==N),id,'Native support must cover the recording.');
for e=1:height(E)
    T=Evidence{e};raw=double(T.Raw(:));px=double(T.Footprint(:));d=double(T.DetectedFrames(:));
    first=E.StartFrame(e);last=E.EndFrame(e);
    footprintKnown=~isempty(px)&&all(isfinite(px)&px>=1&px==fix(px));
    archivedMean=isempty(px)&&isempty(AllNativePixels)&&isfield(T,'FootprintSource')&& ...
        isscalar(string(T.FootprintSource))&&strlength(string(T.FootprintSource))>0;
    assert(numel(raw)==N&&(footprintKnown||archivedMean)&& ...
        ~isempty(d)&&all(isfinite(d)&d>=1&d<=N&d==fix(d))&&all(diff(d)==1)&& ...
        all(isfinite([first last]))&&all([first last]==fix([first last]))&&first>=1&&last>=first&&last<=N, ...
        id,'Invalid trace, footprint, native support or measurement interval.');
    E.EventReferenceFootprintSource(e)="native_event_pixel_union";
    if archivedMean,E.EventReferenceFootprintSource(e)=string(T.FootprintSource);end
    if ismember('NativeStartFrame',E.Properties.VariableNames)
        assert(E.NativeStartFrame(e)==d(1)&&E.NativeEndFrame(e)==d(end),id,'Native interval differs from evidence.');
    end
    if ismember('NFrames',E.Properties.VariableNames),assert(E.NFrames(e)==N,id,'Recording length differs.');end
    if ismember('SampleF',E.Properties.VariableNames),assert(E.SampleF(e)==fs,id,'Event clock differs.');end
    post=d(1)==1;
    b=max(1,first-required):first-1;kind="immediate_pre_event";
    if post,b=last+1:min(N,last+required);kind="post_event_recovery_unverified";end
    [B,counts,overlapStatus]=reference(raw,b,required,px,AllNativePixels,T);
    E.EventReferenceKind(e)=kind;E.EventReferenceValue(e)=B;
    E.EventReferencePostEvent(e)=post;E.EventReferenceRecoveryUnverified(e)=post;
    E=putReference(E,e,'EventReference',b,counts,overlapStatus);
    E.EventReferenceNeedsReview(e)=post||counts(2)<required||counts(4)>0||counts(5)>0||overlapStatus~="assessed";
    signal=raw(first:last);complete=all(isfinite(signal));E.EventSignalComplete(e)=complete;
    if complete,E.EventMinimumValue(e)=min(signal);end
    status="available";
    if isempty(b),status="no_actual_reference_samples";
    elseif counts(3)==0,status="no_finite_reference_samples";
    elseif ~isfinite(B)||B<=0,status="nonpositive_or_nonfinite_reference";
    elseif ~complete,status="missing_required_event_signal";
    else
        E.EventAmplitudePercent(e)=100*(B-E.EventMinimumValue(e))/B;
        E.EventAmplitudeAvailable(e)=isfinite(E.EventAmplitudePercent(e));
        E.EventAmplitudeNegative(e)=E.EventAmplitudePercent(e)<0;
        if E.EventReferenceNeedsReview(e),status="available_flagged";end
    end
    E.EventReferenceStatus(e)=status;
    if ~E.EventAmplitudeAvailable(e),E.EventReferenceNeedsReview(e)=true;end
    rb=requestedStart:min(N,requestedEnd);recRequired=requestedEnd-requestedStart+1;
    [RB,rc,ros]=reference(raw,rb,recRequired,px,AllNativePixels,T);
    E=putReference(E,e,'RecordingReference',rb,rc,ros);
    E.RecordingReferenceValue(e)=RB;E.RecordingReferenceSource(e)=overrideSource;
    E.RecordingReferenceOverride(e)=~isempty(override);
    E.RecordingReferenceRequestedStartFrame(e)=requestedStart;
    E.RecordingReferenceRequestedEndFrame(e)=requestedEnd;
    preceding=requestedEnd<first;E.RecordingReferencePreceding(e)=preceding;
    rs="assessable";
    if ~preceding,rs="not_assessable_not_preceding";
    elseif isempty(rb)||rc(3)==0,rs="not_assessable_missing_reference";
    elseif ~isfinite(RB)||RB<=0,rs="not_assessable_nonpositive_reference";
    elseif ~complete,rs="not_assessable_missing_event_signal";
    elseif ros~="assessed",rs="not_assessable_overlap_unknown";
    else,E.AboveRecordingReference(e)=double(E.EventMinimumValue(e)>RB);
    end
    E.RecordingReferenceStatus(e)=rs;
    E.RecordingReferenceNeedsReview(e)=rs~="assessable"||rc(2)<recRequired||rc(4)>0||rc(5)>0;
end
end
function [B,c,overlapStatus]=reference(raw,b,required,px,allNative,T)
v=raw(b);finite=isfinite(v);B=NaN;if any(finite),B=mean(v(finite));end
overlap=NaN;overlapStatus="not_assessed_no_native_evidence";
if ~isempty(allNative)
    overlap=sum(cellfun(@(q)~isempty(intersect(px,q)),allNative(b)));
    overlapStatus="assessed";
elseif isfield(T,'OverlapAssessedFrames')&&isfield(T,'OverlappingReferenceFrames')&&all(ismember(b,T.OverlapAssessedFrames))
    overlap=sum(ismember(b,T.OverlappingReferenceFrames));overlapStatus="assessed";
end
c=[required numel(b) sum(finite) sum(~finite) overlap];
end
function E=putReference(E,e,prefix,b,c,os)
if ~isempty(b),E.([prefix 'StartFrame'])(e)=b(1);E.([prefix 'EndFrame'])(e)=b(end);end
names={'RequestedSamples','ObservedSamples','FiniteSamples','MissingSamples','OverlapFrames'};
for j=1:numel(names),E.([prefix names{j}])(e)=c(j);end
E.([prefix 'Short'])(e)=c(2)<c(1);
E.([prefix 'Overlapping'])(e)=c(5)>0;
E.([prefix 'MissingSamplesFlag'])(e)=c(4)>0;
E.([prefix 'OverlapStatus'])(e)=os;
end
