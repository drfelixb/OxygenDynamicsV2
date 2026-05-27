function OverallPixelList = trackSurgeCandidates(SurgeInfoAll,minDurationFrames,minOverlapPixels)
%TRACKSURGECANDIDATES Track surge candidate regions across frames.

OverallPixelList = cell(1,length(SurgeInfoAll));
Counter = 1;

for FrameIdx = 1:length(SurgeInfoAll) - minDurationFrames
    for RegionIdx = 1:length(SurgeInfoAll{FrameIdx,1})
        StartPixels = SurgeInfoAll{FrameIdx,1}(RegionIdx).PixelIdxList;
        if isRemovedRegion(StartPixels)
            continue
        end

        OverallPixelList{Counter,FrameIdx} = StartPixels;
        for NextFrameIdx = FrameIdx + 1:length(SurgeInfoAll)
            for NextRegionIdx = 1:length(SurgeInfoAll{NextFrameIdx,1})
                NextPixels = SurgeInfoAll{NextFrameIdx,1}(NextRegionIdx).PixelIdxList;
                if isRemovedRegion(NextPixels)
                    continue
                end

                if length(intersect(StartPixels,NextPixels)) > minOverlapPixels
                    OverallPixelList{Counter,NextFrameIdx} = NextPixels;
                    SurgeInfoAll{NextFrameIdx,1}(NextRegionIdx).PixelIdxList = NaN;
                    break
                end
            end
        end

        SurgeInfoAll{FrameIdx,1}(RegionIdx).PixelIdxList = NaN;
        Counter = Counter + 1;
    end
end

end
