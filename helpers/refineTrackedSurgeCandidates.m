function [OverallPixelList,OverallLogical] = refineTrackedSurgeCandidates(OverallPixelList,minDurationFrames)
%REFINETRACKEDSURGECANDIDATES Apply minimum-duration filter to tracked surges.

OverallLogical = ~cellfun(@isempty,OverallPixelList);
for SurgeIdx = 1:size(OverallLogical,1)
    EventInfo = regionprops(OverallLogical(SurgeIdx,:),'Area','PixelIdxList');
    for EventIdx = 1:length(EventInfo)
        if EventInfo(EventIdx).Area < minDurationFrames
            OverallLogical(SurgeIdx,EventInfo(EventIdx).PixelIdxList) = false;
            OverallPixelList(SurgeIdx,EventInfo(EventIdx).PixelIdxList) = {[]};
        end
    end
end

HasEvents = any(OverallLogical,2);
OverallPixelList = OverallPixelList(HasEvents,:);
OverallLogical = OverallLogical(HasEvents,:);

end
