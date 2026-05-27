function BW = filterRegionCandidates(BW,recordingAreaMask,minArea,maxArea,minCircularity,maxOutsideFraction,forbiddenPixels)
%FILTERREGIONCANDIDATES Remove candidates outside area/shape/mask limits.

RegionInfo = regionprops(BW,'Area','PixelIdxList','Circularity');
if isempty(RegionInfo)
    return
end

OutsideMask = ~recordingAreaMask;
for regionIdx = 1:numel(RegionInfo)
    Pixels = RegionInfo(regionIdx).PixelIdxList;
    if isempty(Pixels)
        continue
    end

    OutsideFraction = nnz(OutsideMask(Pixels)) ./ numel(Pixels);
    IsTooSmall = RegionInfo(regionIdx).Area < minArea;
    IsTooLarge = RegionInfo(regionIdx).Area > maxArea;
    IsTooIrregular = RegionInfo(regionIdx).Circularity < minCircularity;
    IsTooFarOutside = OutsideFraction > maxOutsideFraction;
    TouchesForbiddenPixels = ~isempty(forbiddenPixels) && any(ismember(Pixels,forbiddenPixels));
    RemoveRegion = IsTooSmall || IsTooLarge || IsTooIrregular || ...
        IsTooFarOutside || TouchesForbiddenPixels;

    if RemoveRegion
        BW(Pixels) = false;
    end
end

end
