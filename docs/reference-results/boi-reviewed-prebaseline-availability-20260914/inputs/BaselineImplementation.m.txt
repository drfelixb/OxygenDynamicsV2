function [Audit,Traces]=auditOxygenEventFootprints(Sites,Events,OtherSites,Raw,baselineFrames,kind)
% Independently audit the current event-footprint amplitude and baseline contract.
% Do not call the measurement finalizer: disagreement must remain detectable.
kind=string(validatestring(kind,{'sink','surge'}));
assert(baselineFrames>=1 && baselineFrames==round(baselineFrames));
N=size(Raw,3);flat=reshape(Raw,[],N);prefix='Sink';if kind=="surge",prefix='Surge';end
ampCol=['NormOxy' prefix 'Amp'];siteCol=[prefix 'ID'];
prototype=struct('RecordingID',"",'EventType',kind,'SiteID',0,'EventID',0,'EventRow',0, ...
    'StartFrame',0,'EndFrame',0,'DetectedStartFrame',0,'DetectedEndFrame',0, ...
    'FootprintPixels',0,'BaselineWindowFrames',baselineFrames,'CleanBaselineFrames',0, ...
    'TruncatedBaseline',false,'OverlapExcludedFrames',0,'NonfiniteBaselineFrames',0, ...
    'StoredBaseline',NaN,'RecomputedBaseline',NaN,'StoredStatus',"",'RecomputedStatus',"", ...
    'StoredAmplitude',NaN,'RecomputedAmplitude',NaN,'AbsDifference',NaN, ...
    'MeasurementMatches',false,'WrongDirection',false);
rows=repmat(prototype,height(Events),1);Traces=cell(height(Events),1);
allPixels=cell(1,N);
for t=1:N
    p=[];
    for s=1:height(Sites),c=Sites.FramePixels{s};p=[p;c{t}(:)];end %#ok<AGROW>
    for s=1:height(OtherSites),c=OtherSites.FramePixels{s};p=[p;c{t}(:)];end %#ok<AGROW>
    allPixels{t}=unique(p);
end
for e=1:height(Events)
    E=Events(e,:);s=E.(siteCol);k=E.EventID;c=Sites.FramePixels{s};
    assert(numel(c)==N,'OxygenDynamics:AuditDimensions','Native mask length differs from source.');
    runs=regionprops(~cellfun(@isempty,c),'PixelIdxList');
    assert(k>=1&&k<=numel(runs),'OxygenDynamics:EventMaskMismatch','Event has no native mask run.');
    detected=runs(k).PixelIdxList;px=unique(vertcat(c{detected}));
    assert(~isempty(px),'OxygenDynamics:EventMaskMismatch','Event has empty footprint.');
    first=E.StartFrame;last=E.EndFrame;
    assert(first>=1&&first<=last&&last<=N&&all([first last]==round([first last])), ...
        'OxygenDynamics:AuditEventBounds','Invalid saved event bounds.');
    trace=mean(double(flat(px,:)),1);b=max(1,first-baselineFrames):first-1;
    overlap=false(size(b));
    for j=1:numel(b),overlap(j)=any(ismember(px,allPixels{b(j)}));end
    clean=b(~overlap & isfinite(trace(b)));B=NaN;amp=NaN;status="insufficient_clean_prebaseline";
    if numel(clean)==baselineFrames
        B=mean(trace(clean));
        if B>0&&isfinite(B)&&all(isfinite(trace(first:last)))
            delta=(trace(first:last)-B)/B;
            if kind=="sink",amp=-min(delta);else,amp=max(delta);end
            status="valid";
        else
            status="nonpositive_baseline_or_missing_event_signal";
        end
    end
    r=prototype;r.RecordingID=string(E.RecordingID);r.SiteID=s;r.EventID=k;r.EventRow=e;
    r.StartFrame=first;r.EndFrame=last;r.DetectedStartFrame=detected(1);r.DetectedEndFrame=detected(end);
    r.FootprintPixels=numel(px);r.CleanBaselineFrames=numel(clean);r.TruncatedBaseline=numel(b)<baselineFrames;
    r.OverlapExcludedFrames=sum(overlap);r.NonfiniteBaselineFrames=sum(~isfinite(trace(b)));
    r.StoredBaseline=E.BaselineValue;r.RecomputedBaseline=B;
    r.StoredStatus=string(E.BaselineStatus);r.RecomputedStatus=status;
    r.StoredAmplitude=E.(ampCol);r.RecomputedAmplitude=amp;r.AbsDifference=abs(r.StoredAmplitude-amp);
    r.MeasurementMatches=sameNumber(r.StoredAmplitude,amp)&&sameNumber(r.StoredBaseline,B) ...
        &&r.StoredStatus==status&&E.BaselineValidSamples==numel(clean);
    r.WrongDirection=isfinite(amp)&&amp<0;rows(e)=r;
    Traces{e}=struct('Raw',trace,'Footprint',px,'CleanBaselineFrames',clean,'DetectedFrames',detected);
end
Audit=struct2table(rows);
end
function yes=sameNumber(a,b)
yes=(isnan(a)&&isnan(b)) || (isfinite(a)&&isfinite(b)&&abs(a-b)<=1e-10*max(1,abs(b)));
end
