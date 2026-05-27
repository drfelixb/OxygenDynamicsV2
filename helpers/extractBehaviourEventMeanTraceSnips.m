function EventTraceSnips = extractBehaviourEventMeanTraceSnips(roiTraces,eventLogicals,sampleFs,eventFs,windowSec)
% extractBehaviourEventMeanTraceSnips averages ROI trace windows around behavioural events.

if ~any(~cellfun(@isempty,eventLogicals))
    EventTraceSnips=[];
    return
end

EventTraceSnips=cell(size(roiTraces,1),6);
EventTraceSnips(:,1:5)=roiTraces(:,1:5);

for recordingIdx=1:size(roiTraces,1)
    if isempty(eventLogicals{recordingIdx})
        continue
    end

    Events=bwconncomp(eventLogicals{recordingIdx});
    WindowFrames=windowSec*sampleFs{recordingIdx};
    ROItraceSnip=nan(length(Events.PixelIdxList),WindowFrames*2+1);

    for eventIdx=1:length(Events.PixelIdxList)
        CenterFrame=fix(Events.PixelIdxList{eventIdx}(1)*sampleFs{recordingIdx}/eventFs);
        ROItraceSnip(eventIdx,:)=extractCenteredTraceWindow(roiTraces{recordingIdx,7},CenterFrame,WindowFrames);
    end

    EventTraceSnips{recordingIdx,6}=mean(ROItraceSnip,1,'omitnan');
end
end
