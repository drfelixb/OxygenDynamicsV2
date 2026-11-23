function [Events,Traces,FrameMasks] = quantifyOxygenEventFirst(Masks,Raw,Valid,R,C)
% Fixed event-union footprint, clean pre-event baseline, preserved quantitative branch.
[h,w,n]=size(Raw); X=reshape(Raw,h*w,n); V=reshape(Valid,h*w,n);
occupied=false(h*w,n);
for k=1:numel(Masks)
    m=Masks(k);
    for j=1:numel(m.Frames), occupied(m.PixelIdxList{j},m.Frames(j))=true; end
end
prototype=struct('RecordingID',R.RecordingID,'MouseID',R.MouseID,'AnalysisRunID',C.AnalysisRunID, ...
    'Detector',"eventFirst",'DetectorVersion',C.Version,'EventID',"",'EventType',"", ...
    'SiteID',0,'SiteMembershipIoU',NaN,'SiteAmbiguous',false,'FirstFrame',0,'LastFrame',0, ...
    'IntervalStartSec',0,'IntervalEndSec',0,'ObservedDurationSec',0,'ElapsedSpanSec',0, ...
    'BaselineStartSec',NaN,'BaselineEndSec',NaN,'BaselineSampleCount',0,'BaselineValidFraction',0, ...
    'B0',NaN,'BaselineStatus',"",'BaselineDriftPerSec',NaN,'PeakRelativeBLI',NaN, ...
    'MeanSignedRelativeBLI',NaN,'SignedRelativeBLIAUC_sec',NaN,'MeanAreaPixels',0, ...
    'MaxAreaPixels',0,'MeanAreaUm2',NaN,'MaxAreaUm2',NaN,'CentroidXPixel',NaN,'CentroidYPixel',NaN, ...
    'AmbiguousComponent',false,'SeedCount',0,'BoundaryTruncated',false,'AdjacentUnknown',false, ...
    'WrongDirection',false,'GlobalTraceCorrelation',NaN,'QuantificationSource',"PreservedInputIntensity", ...
    'MaskReference',"EventFrameMasks");
rows=repmat(prototype,0,1); Traces=cell(numel(Masks),1);
fm=struct('EventID',{},'Frame',{},'PixelIdxList',{});
g=X; g(~V)=NaN; globalTrace=mean(g,1,'omitnan');
for k=1:numel(Masks)
    m=Masks(k); active=m.Frames; fp=double(m.Footprint);
    r=prototype; r.EventType="surge"; if m.Sign<0, r.EventType="sink"; end
    r.EventID=R.RecordingID+"/"+C.AnalysisRunID+"/"+r.EventType+"/"+string(k);
    r.FirstFrame=active(1); r.LastFrame=active(end);
    r.IntervalStartSec=(active(1)-1)/R.fs; r.IntervalEndSec=active(end)/R.fs;
    r.ObservedDurationSec=numel(active)/R.fs; r.ElapsedSpanSec=(active(end)-active(1)+1)/R.fs;
    % All footprint pixels must be valid; do not let changing support bias the trace.
    trace=mean(X(fp,:),1); trace(~all(V(fp,:),1))=NaN;
    pre=max(1,active(1)-ceil(C.PreEventSec*R.fs)):active(1)-1;
    clean=pre(~any(occupied(fp,pre),1)&isfinite(trace(pre)));
    r.BaselineSampleCount=numel(clean); r.BaselineValidFraction=numel(clean)/max(1,numel(pre));
    if ~isempty(pre), r.BaselineStartSec=(pre(1)-1)/R.fs; r.BaselineEndSec=pre(end)/R.fs; end
    fraction=nan(1,n); r.BaselineStatus="insufficient clean pre-event samples";
    if numel(clean)>=C.MinBaselineSamples && r.BaselineValidFraction>=C.MinBaselineFraction
        r.B0=mean(trace(clean));
        fit=polyfit((clean-1)/R.fs,trace(clean),1); r.BaselineDriftPerSec=fit(1);
        if r.B0>0
            fraction=(trace-r.B0)/r.B0; r.BaselineStatus="valid pre-event";
            f=fraction(active);
            if all(isfinite(f))
                r.PeakRelativeBLI=max(m.Sign*f); r.MeanSignedRelativeBLI=mean(f);
                r.SignedRelativeBLIAUC_sec=sum(f)/R.fs; r.WrongDirection=m.Sign*mean(f)<0;
            else
                r.BaselineStatus="valid baseline; incomplete fixed-footprint event trace";
            end
        else, r.BaselineStatus="nonpositive baseline"; end
    end
    sizes=cellfun(@numel,m.PixelIdxList); r.MeanAreaPixels=mean(sizes); r.MaxAreaPixels=max(sizes);
    r.MeanAreaUm2=r.MeanAreaPixels*prod(R.PixelSizeUm); r.MaxAreaUm2=r.MaxAreaPixels*prod(R.PixelSizeUm);
    [yy,xx]=ind2sub([h w],fp); r.CentroidXPixel=mean(xx); r.CentroidYPixel=mean(yy);
    r.AmbiguousComponent=m.Ambiguous; r.SeedCount=m.SeedCount; r.BoundaryTruncated=m.BoundaryTruncated; r.AdjacentUnknown=m.AdjacentUnknown;
    ok=isfinite(trace)&isfinite(globalTrace);
    if nnz(ok)>2 && std(trace(ok))>0 && std(globalTrace(ok))>0
        co=corrcoef(trace(ok),globalTrace(ok)); r.GlobalTraceCorrelation=co(1,2);
    end
    rows(end+1)=r; %#ok<AGROW>
    Traces{k}=struct('EventID',r.EventID,'Footprint',m.Footprint,'PreservedIntensity',trace,'SignedRelativeBLI',fraction,'BaselineFrames',clean);
    for j=1:numel(active)
        fm(end+1)=struct('EventID',r.EventID,'Frame',active(j),'PixelIdxList',m.PixelIdxList{j}); %#ok<AGROW>
    end
end
Events=struct2table(rows,'AsArray',true);
if isempty(rows), Events=struct2table(prototype); Events=Events([],:); end
FrameMasks=table(reshape(string({fm.EventID}),[],1),reshape([fm.Frame],[],1),reshape({fm.PixelIdxList},[],1), ...
    'VariableNames',{'EventID','Frame','PixelIdxList'});
if isempty(fm)
    FrameMasks=table(strings(0,1),zeros(0,1),cell(0,1),'VariableNames',{'EventID','Frame','PixelIdxList'});
end
end
