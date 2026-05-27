function totalEvents = countTrackedEvents(trackedLogical)
%COUNTTRACKEDEVENTS Count contiguous event runs across tracked region rows.

totalEvents = 0;
for i = 1:size(trackedLogical,1)
    totalEvents = totalEvents+numel(regionprops(trackedLogical(i,:),'Area','PixelIdxList'));
end

end
