function [Windows,Contrasts,TimeSeries] = measureOxygenEventWindows(Events,Masks,Raw,Valid,R,C)
% Exposure-weighted occupancy; half-open windows, fractional boundary interval clipping.
[h,w,n]=size(Raw); dt=1/R.fs; starts=(0:n-1)*dt; ends=starts+dt;
v=reshape(Valid,h*w,n); raw=reshape(Raw,h*w,n); raw(~v)=NaN;
areaPixels=sum(v,1); globalBLI=mean(raw,1,'omitnan');
count=zeros(2,n); occupied=zeros(2,n);
for signIndex=1:2
    sign=2*signIndex-3; occ=false(h*w,n);
    for k=1:numel(Masks)
        if Masks(k).Sign~=sign, continue; end
        count(signIndex,Masks(k).Frames)=count(signIndex,Masks(k).Frames)+1;
        for j=1:numel(Masks(k).Frames), occ(Masks(k).PixelIdxList{j},Masks(k).Frames(j))=true; end
    end
    occupied(signIndex,:)=sum(occ,1);
end
TimeSeries=table((1:n)',starts',ends',areaPixels',globalBLI',count(1,:)',count(2,:)',occupied(1,:)',occupied(2,:)', ...
    'VariableNames',{'Frame','StartSec','EndSec','ValidAreaPixels','GlobalPreservedBLI','SinkCount','SurgeCount','SinkOccupiedPixels','SurgeOccupiedPixels'});
W=table("whole",0,n*dt,'VariableNames',{'WindowID','StartSec','EndSec'});
if isfield(R,'Windows')
    assert(istable(R.Windows)&&all(ismember({'WindowID','StartSec','EndSec'},R.Windows.Properties.VariableNames)),'eventFirst:Windows','Windows require WindowID, StartSec, EndSec.');
    W=R.Windows(:,{'WindowID','StartSec','EndSec'}); W.WindowID=string(W.WindowID);
    assert(numel(unique(W.WindowID))==height(W)&&all(isfinite(W.StartSec)&isfinite(W.EndSec)&W.StartSec>=0&W.EndSec>W.StartSec&W.EndSec<=n*dt),'eventFirst:Windows','Invalid or duplicate windows.');
end
rows=struct([]);
for j=1:height(W)
    overlap=max(0,min(ends,W.EndSec(j))-max(starts,W.StartSec(j)));
    exposure=sum(areaPixels.*overlap); physicalExposure=exposure*prod(R.PixelSizeUm)/1e6;
    validSeconds=sum(overlap(areaPixels>0));
    globalOk=isfinite(globalBLI)&overlap>0;
    globalMean=NaN; if any(globalOk), globalMean=sum(globalBLI(globalOk).*overlap(globalOk))/sum(overlap(globalOk)); end
    for signIndex=1:2
        kind="sink"; if signIndex==2, kind="surge"; end
        onsets=nnz(Events.EventType==kind&Events.IntervalStartSec>=W.StartSec(j)&Events.IntervalStartSec<W.EndSec(j));
        eventSeconds=sum(count(signIndex,:).*overlap); occupiedExposure=sum(occupied(signIndex,:).*overlap);
        fraction=NaN; rate=NaN; density=NaN;
        if exposure>0, fraction=occupiedExposure/exposure; end
        if physicalExposure>0, rate=60*onsets/physicalExposure; density=eventSeconds/physicalExposure; end
        status="valid"; if exposure==0, status="no observable exposure"; elseif isnan(physicalExposure), status="pixel units only"; end
        row=struct('RecordingID',R.RecordingID,'MouseID',R.MouseID,'AnalysisRunID',C.AnalysisRunID, ...
            'Detector',"eventFirst",'WindowID',W.WindowID(j),'EventType',kind,'StartSec',W.StartSec(j),'EndSec',W.EndSec(j), ...
            'Onsets',onsets,'ActiveEventSeconds',eventSeconds,'OccupiedPixelSeconds',occupiedExposure, ...
            'ValidPixelSeconds',exposure,'ValidAreaMm2Seconds',physicalExposure,'ValidSeconds',validSeconds, ...
            'OnsetsPerMm2Min',rate,'MeanConcurrentPerMm2',density,'OccupiedTissueFraction',fraction, ...
            'GlobalPreservedBLIMean',globalMean,'Status',status);
        rows=[rows;row]; %#ok<AGROW>
    end
end
Windows=struct2table(rows);
cr=struct('RecordingID',{},'MouseID',{},'AnalysisRunID',{},'BaselineWindowID',{},'ComparisonWindowID',{},'EventType',{},'Metric',{},'BaselineValue',{},'ComparisonValue',{},'Difference',{},'Ratio',{},'PercentChange',{},'Status',{});
if isfield(R,'Contrasts')
    assert(istable(R.Contrasts)&&all(ismember({'BaselineWindowID','ComparisonWindowID'},R.Contrasts.Properties.VariableNames)),'eventFirst:Windows','Contrasts need explicit window IDs.');
    for j=1:height(R.Contrasts)
        a=string(R.Contrasts.BaselineWindowID(j)); b=string(R.Contrasts.ComparisonWindowID(j));
        assert(any(W.WindowID==a)&&any(W.WindowID==b),'eventFirst:Windows','Unknown contrast window.');
        for kind=["sink","surge"]
            for metric=["OnsetsPerMm2Min","OccupiedTissueFraction","GlobalPreservedBLIMean"]
                x=Windows.(metric)(Windows.WindowID==a&Windows.EventType==kind);
                y=Windows.(metric)(Windows.WindowID==b&Windows.EventType==kind);
                ratio=NaN; pct=NaN; status="missing value";
                if isfinite(x)&&isfinite(y)
                    status="zero baseline; relative change undefined";
                    if x~=0, ratio=y/x; pct=100*(ratio-1); status="valid"; end
                end
                cr(end+1)=struct('RecordingID',R.RecordingID,'MouseID',R.MouseID,'AnalysisRunID',C.AnalysisRunID, ...
                    'BaselineWindowID',a,'ComparisonWindowID',b,'EventType',kind,'Metric',metric,'BaselineValue',x,'ComparisonValue',y, ...
                    'Difference',y-x,'Ratio',ratio,'PercentChange',pct,'Status',status); %#ok<AGROW>
            end
        end
    end
end
Contrasts=struct2table(cr);
end
