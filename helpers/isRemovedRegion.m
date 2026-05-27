function IsRemoved = isRemovedRegion(pixelIdxList)
%ISREMOVEDREGION True when a region has been marked as removed.

IsRemoved = false;
if isempty(pixelIdxList)
    return
end

IsRemoved = isscalar(pixelIdxList) && isnumeric(pixelIdxList) && isnan(pixelIdxList);

end
