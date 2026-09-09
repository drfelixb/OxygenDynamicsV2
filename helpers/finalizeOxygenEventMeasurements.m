function [Sites,Events] = finalizeOxygenEventMeasurements(Sites,Events,Pixels,Raw,fs,pixelSize,border,recordingID,kind,baselineSec,OtherPixels,otherBorder)
% Quantify existing detections from fixed per-event raw footprints.
% Detection and trace-refined timing are preserved; no re-detection occurs.
assert(isfinite(fs)&&fs>0&&isfinite(pixelSize)&&pixelSize>0&&round(baselineSec*fs)>=1, ...
    'OxygenDynamics:InvalidQuantificationScale','Positive frame rate, pixel size and baseline window are required.');
if nargin<12,OtherPixels=cell(0,size(Raw,3));otherBorder=0;end
N = size(Raw,3); frameSize = [size(Raw,1),size(Raw,2)];
Sites.RecordingID = repmat(string(recordingID),height(Sites),1);
Sites.SiteID = (1:height(Sites))';
Sites.FramePixels = cell(height(Sites),1);
Sites.FrameSize = repmat({frameSize},height(Sites),1);
Sites.NFrames = repmat(N,height(Sites),1);
Sites.SampleF = repmat(fs,height(Sites),1);
contract=oxygenPipelineContract();
Sites.AnalysisSchemaVersion = repmat(string(contract.Schema),height(Sites),1);
for s=1:height(Sites)
    cells=Pixels(s,:);
    for t=1:numel(cells)
        if isempty(cells{t}), continue; end
        [y,x]=ind2sub(frameSize-2*border,cells{t});
        cells{t}=sub2ind(frameSize,y+border,x+border); cells{t}=cells{t}(:);
    end
    Sites.FramePixels{s}=cells;
end
% Both event signs contaminate a local pre-event baseline.
allPixels=cell(1,N);
for t=1:N
    px=[];
    for s=1:height(Sites),pc=Sites.FramePixels{s};px=[px;pc{t}(:)];end %#ok<AGROW>
    for s=1:size(OtherPixels,1)
        [y,x]=ind2sub(frameSize-2*otherBorder,OtherPixels{s,t});
        q=sub2ind(frameSize,y+otherBorder,x+otherBorder);px=[px;q(:)]; %#ok<AGROW>
    end
    allPixels{t}=unique(px);
end
Events.RecordingID = repmat(string(recordingID),height(Events),1);
Events.NFrames = repmat(N,height(Events),1);
Events.RecDuration = repmat(N/fs,height(Events),1);
Events.SampleF = repmat(fs,height(Events),1);
Events.AnalysisSchemaVersion = repmat(string(contract.Schema),height(Events),1);
Events.AmplitudeSignConvention = repmat("positive_drop_percent",height(Events),1);
Events.QuantificationSource = repmat("PreservedInput_EventFootprint",height(Events),1);
Events.BaselineValue = nan(height(Events),1);
Events.BaselineStartFrame = nan(height(Events),1);
Events.BaselineEndFrame = nan(height(Events),1);
Events.BaselineValidSamples = zeros(height(Events),1);
Events.BaselineStatus = repmat("insufficient_clean_prebaseline",height(Events),1);
Events.MeanSignedChangeFraction = nan(height(Events),1);
Events.SignedTraceAUC_sec = nan(height(Events),1);
Events.EventArea_um2 = nan(height(Events),1);
Events.RecAreaSize = nan(height(Events),1);
if strcmp(kind,'sink')
    siteCol='SinkID'; ampCol='NormOxySinkAmp'; areaCol='RecAreaSize';
else
    siteCol='SurgeID'; ampCol='NormOxySurgeAmp'; areaCol='RecAreaSize_Surge';
    Events.AmplitudeSignConvention(:)="positive_increase_percent";
end
Events.SiteTraceAmplitude = Events.(ampCol);
for e=1:height(Events)
    s=Events.(siteCol)(e); k=Events.EventID(e);
    first=Events.StartFrame(e); last=Events.EndFrame(e);
    cells=Sites.FramePixels{s};
    runs=regionprops(~cellfun(@isempty,cells),'PixelIdxList');
    if k>numel(runs), error('OxygenDynamics:EventMaskMismatch','Event index exceeds native mask runs.'); end
    detected=runs(k).PixelIdxList;
    footprint=unique(vertcat(cells{detected}));
    if isempty(footprint), continue; end
    frames=first:last;
    trace=nan(1,N);
    flat=reshape(Raw,[],N);
    trace(:)=mean(double(flat(footprint,:)),1);
    b=max(1,first-round(baselineSec*fs)):first-1;
    % Exclude other events on any overlapping spatial support, not only this site.
    clean=true(size(b));
    for j=1:numel(b)
        if ~isempty(intersect(footprint,allPixels{b(j)})), clean(j)=false; end
    end
    b=b(clean & isfinite(trace(b)));
    Events.BaselineValidSamples(e)=numel(b);
    amp=NaN;
    if numel(b)>=round(baselineSec*fs)
        B0=mean(trace(b));
        Events.BaselineValue(e)=B0;
        Events.BaselineStartFrame(e)=b(1); Events.BaselineEndFrame(e)=b(end);
        if isfinite(B0) && B0>0 && all(isfinite(trace(frames)))
            d=(trace(frames)-B0)/B0;
            if strcmp(kind,'sink'), amp=-min(d); else, amp=max(d); end
            Events.MeanSignedChangeFraction(e)=mean(d,'omitnan');
            Events.SignedTraceAUC_sec(e)=sum(d)/fs;
            Events.BaselineStatus(e)="valid";
        else
            Events.BaselineStatus(e)="nonpositive_baseline_or_missing_event_signal";
        end
    end
    Events.(ampCol)(e)=amp;
    Events.([ampCol 'Percent'])(e)=100*amp;
    Sites.(ampCol){s}(k)=amp;
    Events.StartSec(e)=(first-1)/fs; Events.EndSec(e)=last/fs;
    Events.DurationFrames(e)=last-first+1; Events.DurationSec(e)=(last-first+1)/fs;
    sizes=cellfun(@numel,cells(detected));
    Events.EventArea_um2(e)=mean(sizes)*pixelSize^2;
    Events.RecAreaSize(e)=Sites.(areaCol){s};
    % Replace inherited site morphology with event-mask morphology, retaining site values.
    if strcmp(kind,'sink'), prefix='MeanOxySink'; else, prefix='MeanOxySurge'; end
    for metric={'Area_um','FilledArea_um','Diameter_um','Perimeter_um'}
        col=[prefix metric{1}];
        if ~ismember(['Site' col],Events.Properties.VariableNames)
            Events.(['Site' col])=Events.(col);
        end
    end
    fields={'MeanCircularity','MeanCentroid_x','MeanCentroid_y'};
    if strcmp(kind,'surge'),fields={'MeanCircularity_Surge','MeanCentroid_Surge_x','MeanCentroid_Surge_y'};end
    for field=fields
        f=field{1};
        if ismember(f,Events.Properties.VariableNames) && ~ismember(['Site' f],Events.Properties.VariableNames)
            Events.(['Site' f])=Events.(f);
        end
    end
    vals=nan(numel(detected),4); extra=nan(numel(detected),3);
    for j=1:numel(detected)
        mask=false(frameSize); mask(cells{detected(j)})=true;
        props=regionprops(mask,'Area','FilledArea','Perimeter','Circularity','Centroid');
        a=sum([props.Area]); centers=reshape([props.Centroid],2,[]);
        extra(j,:)=[mean([props.Circularity]),sum(centers(1,:).*[props.Area])/a,sum(centers(2,:).*[props.Area])/a];
        vals(j,:)=[a,sum([props.FilledArea]),sqrt(4*a/pi),sum([props.Perimeter])];
    end
    for j=1:3, Events.(fields{j})(e)=mean(extra(:,j)); end
    scales=[pixelSize^2,pixelSize^2,pixelSize,pixelSize]; names={'Area_um','FilledArea_um','Diameter_um','Perimeter_um'};
    for j=1:4, Events.([prefix names{j}])(e)=mean(vals(:,j))*scales(j); end
end
end
