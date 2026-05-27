function OverallPixelList = trackSinkCandidates(SinkInfoAll,minDurationFrames,overlapThreshold)
%TRACKSINKCANDIDATES Track sink candidate regions across frames.

OverallPixelList = cell(1,length(SinkInfoAll));
Counter = 1;

for FrameIdx = 1:length(SinkInfoAll) - minDurationFrames
    for RegionIdx = 1:length(SinkInfoAll{FrameIdx,1})
        if isRemovedRegion(SinkInfoAll{FrameIdx,1}(RegionIdx).PixelIdxList)
            continue
        end

        CurrentPixels = SinkInfoAll{FrameIdx,1}(RegionIdx).PixelIdxList;
        OverallPixelList{Counter,FrameIdx} = CurrentPixels;

        for NextFrameIdx = FrameIdx + 1:length(SinkInfoAll)
            for NextRegionIdx = 1:length(SinkInfoAll{NextFrameIdx,1})
                NextPixels = SinkInfoAll{NextFrameIdx,1}(NextRegionIdx).PixelIdxList;
                if isRemovedRegion(NextPixels)
                    continue
                end

                CurrentOverlap = length(CurrentPixels) * overlapThreshold;
                NextOverlap = length(NextPixels) * overlapThreshold;
                NumOverlap = length(intersect(CurrentPixels,NextPixels));
                if NumOverlap > NextOverlap || NumOverlap > CurrentOverlap
                    OverallPixelList{Counter,NextFrameIdx} = vertcat(OverallPixelList{Counter,NextFrameIdx},NextPixels);
                    CurrentPixels = unique(vertcat(CurrentPixels,NextPixels));
                    SinkInfoAll{NextFrameIdx,1}(NextRegionIdx).PixelIdxList = NaN;
                end
            end
        end

        SinkInfoAll{FrameIdx,1}(RegionIdx).PixelIdxList = NaN;
        Counter = Counter + 1;
    end
end

end
