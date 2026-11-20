function [events,frames,geom]=nearbyMeasure(R,e,ar,rawFile)
I=R.AnalysisInfo; shape=double(I.FrameSize(:)'); n=double(I.NFrames);
fs=double(I.AnalysisParams.fs); px=double(I.AnalysisParams.PixelSize);
assert(isscalar(px)&&isfinite(px)&&px>0,'A positive saved pixel size in micrometres is required.');
assert(isfield(I,'SinkEligibleTissuePixels'),'The saved sink tissue mask is missing.');
tissue=false(shape);tissue(I.SinkEligibleTissuePixels)=true;
assert(R.Acquisition.InputCompatible,'Saved acquisition reports an incompatible sampling clock or source.');
stack=tiffreadVolume(rawFile);
assert(ismatrix(stack(:,:,1)) && isequal([size(stack,1),size(stack,2),size(stack,3)],[shape,n]) && ndims(stack)<=3, ...
    'Source does not contain the saved single-channel Y x X x T volume.');
stack=reshape(stack,prod(shape),n);
ne=height(e); allFoot=cellfun(@(t)double(t.Footprint(:)),R.Traces,'UniformOutput',false);
members=cellfun(@numel,allFoot);
allMask=sparse(vertcat(allFoot{:}),repelem((1:numel(allFoot))',members(:)),1,prod(shape),numel(allFoot));
bounds=double([R.Audit.DetectedStartFrame,R.Audit.DetectedEndFrame]);
events=e(:,{'PocketKey','SinkID','EventID','StartFrame','EndFrame','NativeStartFrame','NativeEndFrame','SampleF','NFrames'});
events.Mouse=strings(ne,1);events.Group=strings(ne,1);events.SourceSHA256=strings(ne,1);
names={'FootprintPixels','NearRingPixels','FarRingPixels','NearRingTissueFraction','FarRingTissueFraction','InsideTissueFraction', ...
    'PocketBaseline','NearBaseline','FarBaseline','TissueOnlyPocketBaseline','PostOffsetSecondsAvailable'};
for col=string(names),events.(col)=nan(ne,1);end
events.PocketBaselineFlagged=logical(e.EventReferenceNeedsReview);
events.NearPotentialEventDuringBaseline=false(ne,1);
samples=cell(ne,1); masks=cell(ne,3);
columns={'PocketKey','RecordingFrame','FromOnset_s','FromOffset_s','PocketRaw','NearRaw','FarRaw','PocketPct','NearPct','FarPct', ...
    'LocalExcess_pp','TissueOnlyPocketRaw','TissueOnlyPocketPct','PocketBaselineFlagged','NearPotentialEventDuringBaseline','NearPotentialEvent','AfterNextSameSiteSink'};
for j=1:ne
    fp=allFoot{ar(j)};[near,far,coverage]=rings(fp,shape,px,tissue);
    restricted=fp(tissue(fp));masks(j,:)={uint32(fp),uint32(near),uint32(far)};
    start=e.StartFrame(j);stop=e.EndFrame(j);
    ff=(max(1,start-round(20*fs)):min(n,stop+floor(60*fs+1e-9)))';
    inside=meanRegion(stack,fp,ff); ring=meanRegion(stack,near,ff);
    outer=meanRegion(stack,far,ff); common=meanRegion(stack,restricted,ff);
    saved=double(R.Traces{ar(j)}.Raw(ff));saved=saved(:);
    assert(all(abs(inside-saved)<=1e-8+1e-12*abs(saved) | (isnan(inside)&isnan(saved))), ...
        'Raw source/footprint mismatch for site %d event %d.',e.SinkID(j),e.EventID(j));
    pre=ff<start; use=string(e.EventReferenceKind(j))=="immediate_pre_event" && ...
        isfinite(e.EventReferenceValue(j)) && e.EventReferenceValue(j)>0;
    [bp,ip]=normalize(inside,pre,use);[bn,rp]=normalize(ring,pre,use);
    [bf,op]=normalize(outer,pre,use);[bc,cp]=normalize(common,pre,use);
    if use
        assert(any(pre) && e.EventReferenceStartFrame(j)==ff(1) && e.EventReferenceEndFrame(j)==start-1 && ...
            abs(bp-e.EventReferenceValue(j))<=1e-8+1e-10*bp,'Saved pre-onset reference mismatch.');
    end
    hits=find(any(allMask(near,:),1));active=false(n,1);
    for h=hits(:)',active(bounds(h,1):bounds(h,2))=true;end
    marked=any(active(ff(pre)));
    later=e.StartFrame(e.SinkID==e.SinkID(j) & e.StartFrame>start);
    next=Inf;if ~isempty(later),next=min(later);end
    assert(next>stop,'Overlapping same-site saved intervals require review.');
    events{j,names}=[numel(fp),numel(near),numel(far),coverage,numel(restricted)/numel(fp),bp,bn,bf,bc,(ff(end)-stop)/fs];
    events.NearPotentialEventDuringBaseline(j)=marked;
    samples{j}=[repmat(e.PocketKey(j),numel(ff),1),ff,(ff-start)/fs,(ff-stop)/fs,inside,ring,outer,ip,rp,op,ip-rp,common,cp, ...
        repmat([events.PocketBaselineFlagged(j),marked],numel(ff),1),active(ff),ff>=next];
end
if ne==0,data=zeros(0,numel(columns));else,data=vertcat(samples{:});end
frames=array2table(data,'VariableNames',columns);
[~,row]=ismember(frames.PocketKey,e.PocketKey);
frames.FromNativeOnset_s=(frames.RecordingFrame-e.NativeStartFrame(row))/fs;
frames.FromNativeOffset_s=(frames.RecordingFrame-e.NativeEndFrame(row))/fs;
geom=struct('FrameSize',shape,'PixelSize_um',px,'SampleHz',fs,'PocketKey',e.PocketKey,'Masks',{masks}, ...
    'MaskColumns',{{'Pocket','Nearby_10to30um','Far_30to50um'}},'TissuePixels',uint32(find(tissue)));
end

function [near,far,coverage]=rings(fp,sz,scale,tissue)
[y,x]=ind2sub(sz,fp);pad=ceil(50/scale)+1;
y0=min(y)-pad;x0=min(x)-pad;
region=false(max(y)-y0+pad+1,max(x)-x0+pad+1);
region(sub2ind(size(region),y-y0+1,x-x0+1))=true;
% Nearest pixel index makes Euclidean distances double precision at cutoffs.
[~,nearest]=bwdist(region);
[yy,xx]=ndgrid(1:size(region,1),1:size(region,2));
[fy,fx]=ind2sub(size(region),double(nearest));
dist=hypot(yy-fy,xx-fx)*scale;
[near,coverage(1)]=clipRing(dist>10 & dist<=30,y0,x0,sz,tissue);
[far,coverage(2)]=clipRing(dist>30 & dist<=50,y0,x0,sz,tissue);
end
function [pixels,frac]=clipRing(region,y0,x0,sz,tissue)
[y,x]=find(region);total=numel(y);y=y+y0-1;x=x+x0-1;
in=y>=1 & x>=1 & y<=sz(1) & x<=sz(2);
pixels=sub2ind(sz,y(in),x(in));pixels=pixels(tissue(pixels));
frac=numel(pixels)/total;
end
function v=meanRegion(stack,pixels,ff)
if isempty(pixels),v=nan(numel(ff),1);else,v=mean(stack(pixels,ff),1,'double')';end
end
function [b,p]=normalize(v,pre,use)
b=NaN;p=nan(size(v));
if use && any(pre)
    candidate=mean(v(pre));
    if isfinite(candidate)&&candidate>0,b=candidate;p=100*(v-b)/b;end
end
end
