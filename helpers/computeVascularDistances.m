function DistanceTable = computeVascularDistances(objectPixelLists,centroidCoordinates,frameSize,veinsMask,arteriesMask)
%COMPUTEVASCULARDISTANCES Compute distance from objects to vein/artery masks.

VeinRegions = regionprops(veinsMask,'PixelIdxList');
ArteryRegions = regionprops(arteriesMask,'PixelIdxList');

RescaleVeins = size(veinsMask,1)/frameSize(1);
RescaleArteries = size(arteriesMask,1)/frameSize(1);

NumObjects = numel(objectPixelLists);
Veins_Distance_all = nan(NumObjects,1);
Veins_Distance_centroid = nan(NumObjects,1);
Arteries_Distance_all = nan(NumObjects,1);
Arteries_Distance_centroid = nan(NumObjects,1);

for ObjectIdx = 1:NumObjects
    Pixels = objectPixelLists{ObjectIdx};
    if isempty(Pixels)
        continue
    end

    [Rows,Cols] = ind2sub(frameSize,Pixels);
    ObjectCoords = [Cols,Rows];
    CentroidCoords = centroidCoordinates(ObjectIdx,:);

    [Veins_Distance_all(ObjectIdx),Veins_Distance_centroid(ObjectIdx)] = ...
        distanceToVascularRegions(ObjectCoords,CentroidCoords,VeinRegions,size(veinsMask),RescaleVeins);
    [Arteries_Distance_all(ObjectIdx),Arteries_Distance_centroid(ObjectIdx)] = ...
        distanceToVascularRegions(ObjectCoords,CentroidCoords,ArteryRegions,size(arteriesMask),RescaleArteries);
end

DistanceTable = table(Arteries_Distance_centroid,Arteries_Distance_all, ...
    Veins_Distance_centroid,Veins_Distance_all);

end

function [MinDistanceAll,MinDistanceCentroid] = distanceToVascularRegions( ...
    objectCoords,centroidCoords,vascularRegions,vascularMaskSize,rescaleFactor)

RegionDistanceAll = nan(numel(vascularRegions),1);
RegionDistanceCentroid = nan(numel(vascularRegions),1);

for RegionIdx = 1:numel(vascularRegions)
    [Rows,Cols] = ind2sub(vascularMaskSize,vascularRegions(RegionIdx).PixelIdxList);
    VascularCoords = ceil([Cols,Rows]/rescaleFactor);

    PixelDistances = pdist2(objectCoords,VascularCoords);
    CentroidDistances = pdist2(centroidCoords,VascularCoords);

    RegionDistanceAll(RegionIdx) = min(PixelDistances(:));
    RegionDistanceCentroid(RegionIdx) = min(CentroidDistances(:));
end

MinDistanceAll = min(RegionDistanceAll);
MinDistanceCentroid = min(RegionDistanceCentroid);

end
