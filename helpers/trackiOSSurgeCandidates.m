function OverallPixelList = trackiOSSurgeCandidates(SurgeInfoAll,minDurationFrames,minOverlapPixels)
%TRACKIOSSURGECANDIDATES Legacy fixed-seed iOS tracking, isolated from BOI.

OverallPixelList = cell(1,length(SurgeInfoAll));
Counter = 1;
% Regionprops pixel indices are unique positive integers. Cache membership
% once rather than sorting/intersecting the same lists in every future frame.
% Unique also preserves the former intersect semantics for duplicate inputs.
OverlapPixels=cell(size(SurgeInfoAll));Active=cell(size(SurgeInfoAll));maxPixel=0;
for f=1:length(SurgeInfoAll)
    OverlapPixels{f}=cell(1,length(SurgeInfoAll{f}));
    Active{f}=true(1,length(SurgeInfoAll{f}));
    for r=1:length(SurgeInfoAll{f})
        px=SurgeInfoAll{f}(r).PixelIdxList;
        if isRemovedRegion(px),Active{f}(r)=false;continue;end
        assert(all(isfinite(px(:)) & px(:)>=1 & px(:)==floor(px(:))), ...
            'OxygenDynamics:InvalidRegionPixels','Region pixels must be positive integer indices.');
        OverlapPixels{f}{r}=unique(px);
        if ~isempty(px),maxPixel=max(maxPixel,max(px(:)));end
    end
end
StartMask=false(maxPixel,1);

for FrameIdx = 1:(length(SurgeInfoAll) - ceil(minDurationFrames) + 1)
    for RegionIdx = 1:length(SurgeInfoAll{FrameIdx,1})
        StartPixels = SurgeInfoAll{FrameIdx,1}(RegionIdx).PixelIdxList;
        if ~Active{FrameIdx}(RegionIdx)
            continue
        end
        StartMask(OverlapPixels{FrameIdx}{RegionIdx})=true;

        OverallPixelList{Counter,FrameIdx} = StartPixels;
        for NextFrameIdx = FrameIdx + 1:length(SurgeInfoAll)
            for NextRegionIdx = 1:length(SurgeInfoAll{NextFrameIdx,1})
                NextPixels = SurgeInfoAll{NextFrameIdx,1}(NextRegionIdx).PixelIdxList;
                if ~Active{NextFrameIdx}(NextRegionIdx)
                    continue
                end

                if nnz(StartMask(OverlapPixels{NextFrameIdx}{NextRegionIdx})) > minOverlapPixels
                    OverallPixelList{Counter,NextFrameIdx} = NextPixels;
                    Active{NextFrameIdx}(NextRegionIdx)=false;
                    break
                end
            end
        end

        StartMask(OverlapPixels{FrameIdx}{RegionIdx})=false;
        Active{FrameIdx}(RegionIdx)=false;
        Counter = Counter + 1;
    end
end

end
