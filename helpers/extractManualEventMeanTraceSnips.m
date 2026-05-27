function ManualEventTraceSnips = extractManualEventMeanTraceSnips(roiTraces,manualEventsSec,sampleFs,windowSec)
%EXTRACTMANUALEVENTMEANTRACESNIPS Extract ROI mean trace snippets around manual events.

if isempty(manualEventsSec)
    ManualEventTraceSnips = [];
    return
end

ManualEventTraceSnips = cell(1,numel(manualEventsSec));
for manualEventIdx = 1:numel(manualEventsSec)
    SeparateEvent = cell(size(roiTraces,1),6);
    SeparateEvent(:,1:5) = roiTraces(:,1:5);

    for recordingIdx = 1:size(roiTraces,1)
        CenterFrame = manualEventsSec(manualEventIdx)*sampleFs{recordingIdx};
        WindowFrames = windowSec*sampleFs{recordingIdx};
        SeparateEvent{recordingIdx,6} = extractCenteredTraceWindow( ...
            roiTraces{recordingIdx,7},CenterFrame,WindowFrames);
    end

    ManualEventTraceSnips{manualEventIdx} = SeparateEvent;
end

end
