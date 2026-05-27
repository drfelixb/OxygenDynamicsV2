function [OverallPixelList,OverallLogical] = refineTrackedSinkCandidates( ...
    OverallPixelList,minDurationFrames,maxDurationFrames,minEventSeparationFrames)
%REFINETRACKEDSINKCANDIDATES Apply duration and spacing filters to tracked sinks.

OverallLogical = ~cellfun(@isempty,OverallPixelList);
for SinkIdx = 1:size(OverallLogical,1)
    EventInfo = regionprops(OverallLogical(SinkIdx,:),'Area','PixelIdxList');

    for EventIdx = 1:length(EventInfo)
        if EventInfo(EventIdx).Area < minDurationFrames || EventInfo(EventIdx).Area > maxDurationFrames
            OverallLogical(SinkIdx,EventInfo(EventIdx).PixelIdxList) = false;
            OverallPixelList(SinkIdx,EventInfo(EventIdx).PixelIdxList) = {[]};
        end
    end

    EventInfo = regionprops(OverallLogical(SinkIdx,:),'Area','PixelIdxList');
    if isscalar(EventInfo)
        continue
    end

    EventPairs = nchoosek(1:length(EventInfo),2);
    for PairIdx = 1:size(EventPairs,1)
        FirstEvent = EventInfo(EventPairs(PairIdx,1));
        SecondEvent = EventInfo(EventPairs(PairIdx,2));
        if ~OverallLogical(SinkIdx,FirstEvent.PixelIdxList(1)) || ...
                ~OverallLogical(SinkIdx,SecondEvent.PixelIdxList(1))
            continue
        end

        if SecondEvent.PixelIdxList(1) - FirstEvent.PixelIdxList(end) < minEventSeparationFrames
            RemoveSecond = chooseSecondSinkEventForRemoval(FirstEvent,SecondEvent, ...
                minDurationFrames,maxDurationFrames);
            if RemoveSecond
                RemoveFrames = SecondEvent.PixelIdxList;
            else
                RemoveFrames = FirstEvent.PixelIdxList;
            end
            OverallLogical(SinkIdx,RemoveFrames) = false;
            OverallPixelList(SinkIdx,RemoveFrames) = {[]};
        end
    end
end

HasEvents = any(OverallLogical,2);
OverallPixelList = OverallPixelList(HasEvents,:);
OverallLogical = OverallLogical(HasEvents,:);

end

function RemoveSecond = chooseSecondSinkEventForRemoval(FirstEvent,SecondEvent,minDurationFrames,maxDurationFrames)

if abs(SecondEvent.Area - minDurationFrames) < abs(FirstEvent.Area - minDurationFrames) && ...
        abs(SecondEvent.Area - minDurationFrames) < abs(FirstEvent.Area - maxDurationFrames)
    RemoveSecond = true;
elseif abs(SecondEvent.Area - maxDurationFrames) < abs(FirstEvent.Area - minDurationFrames) && ...
        abs(SecondEvent.Area - maxDurationFrames) < abs(FirstEvent.Area - maxDurationFrames)
    RemoveSecond = true;
elseif abs(FirstEvent.Area - minDurationFrames) < abs(SecondEvent.Area - minDurationFrames) && ...
        abs(FirstEvent.Area - minDurationFrames) < abs(SecondEvent.Area - maxDurationFrames)
    RemoveSecond = false;
elseif abs(FirstEvent.Area - maxDurationFrames) < abs(SecondEvent.Area - minDurationFrames) && ...
        abs(FirstEvent.Area - maxDurationFrames) < abs(SecondEvent.Area - maxDurationFrames)
    RemoveSecond = false;
elseif FirstEvent.Area > SecondEvent.Area
    RemoveSecond = true;
else
    RemoveSecond = false;
end

end
