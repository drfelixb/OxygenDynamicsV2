function Morphology = computeTrackedRegionMorphology(OverallPixelList,OverallLogical,frameSize,pixelSize,varargin)
%COMPUTETRACKEDREGIONMORPHOLOGY Measure tracked region morphology and maps.

Parser = inputParser();
Parser.addParameter('pixelFrame',0,@isnumeric);
Parser.addParameter('coordinates','full',@ischar);
Parser.addParameter('boundingBoxSummaryRow','self',@ischar);
Parser.parse(varargin{:});
Options = Parser.Results;

AreaAll = cell(size(OverallPixelList));
FilledAreaAll = cell(size(OverallPixelList));
DiameterAll = cell(size(OverallPixelList));
PerimeterAll = cell(size(OverallPixelList));
CircularityAll = cell(size(OverallPixelList));
CentroidXAll = cell(size(OverallPixelList));
CentroidYAll = cell(size(OverallPixelList));
BoundingBoxAll = cell(size(OverallPixelList));

BinaryMap = false(frameSize);
for FrameIdx = 1:size(OverallPixelList,2)
    FrameMask = false(frameSize(1),frameSize(2));
    for RegionIdx = 1:size(OverallPixelList,1)
        if isempty(OverallPixelList{RegionIdx,FrameIdx})
            continue
        end

        LinearPixels = toFullFrameLinearPixels(OverallPixelList{RegionIdx,FrameIdx},frameSize, ...
            Options.pixelFrame,Options.coordinates);
        SingleRegionMask = false(frameSize(1),frameSize(2));
        SingleRegionMask(LinearPixels) = true;
        Props = regionprops(SingleRegionMask,'Area','FilledArea','Centroid','Circularity', ...
            'Perimeter','EquivDiameter','BoundingBox');

        [AreaAll{RegionIdx,FrameIdx},FilledAreaAll{RegionIdx,FrameIdx}, ...
            DiameterAll{RegionIdx,FrameIdx},PerimeterAll{RegionIdx,FrameIdx}, ...
            CircularityAll{RegionIdx,FrameIdx},CentroidXAll{RegionIdx,FrameIdx}, ...
            CentroidYAll{RegionIdx,FrameIdx},BoundingBoxAll{RegionIdx,FrameIdx}] = summarizeRegionProps(Props);

        FrameMask(LinearPixels) = true;
    end
    BinaryMap(:,:,FrameIdx) = FrameMask;
end

Summary = summarizeMorphology(AreaAll,FilledAreaAll,DiameterAll,PerimeterAll,CircularityAll, ...
    CentroidXAll,CentroidYAll,BoundingBoxAll,OverallLogical,pixelSize,Options.boundingBoxSummaryRow);

Morphology = Summary;
Morphology.AreaAll = AreaAll;
Morphology.BinaryMap = BinaryMap;

end

function LinearPixels = toFullFrameLinearPixels(Pixels,frameSize,pixelFrame,coordinates)

if strcmpi(coordinates,'clipped')
    clippedSize = frameSize(1:2) - 2 * pixelFrame;
    [Rows,Cols] = ind2sub(clippedSize,Pixels);
    Rows = Rows + pixelFrame;
    Cols = Cols + pixelFrame;
    LinearPixels = sub2ind(frameSize(1:2),Rows,Cols);
else
    LinearPixels = Pixels;
end

end

function [Area,FilledArea,Diameter,Perimeter,Circularity,CentroidX,CentroidY,BoundingBox] = summarizeRegionProps(Props)

if numel(Props) > 1
    Area = sum([Props.Area]);
    FilledArea = sum([Props.FilledArea]);
    Diameter = sum([Props.EquivDiameter]);
    Perimeter = sum([Props.Perimeter]);
    Circularity = mean([Props.Circularity]);
    Centroids = [Props.Centroid];
    XIdx = 1:2:length(Centroids);
    YIdx = 2:2:length(Centroids);
    Centroid = round([mean(Centroids(XIdx)) mean(Centroids(YIdx))]);
    CentroidX = Centroid(1);
    CentroidY = Centroid(2);
    Boxes = [Props.BoundingBox];
    XIdx = 1:4:length(Boxes);
    YIdx = 2:4:length(Boxes);
    WidthIdx = 3:4:length(Boxes);
    HeightIdx = 4:4:length(Boxes);
    BoundingBox = [median(Boxes(XIdx)) median(Boxes(YIdx)) median(Boxes(WidthIdx)) median(Boxes(HeightIdx))];
else
    Area = Props.Area;
    FilledArea = Props.FilledArea;
    Diameter = Props.EquivDiameter;
    Perimeter = Props.Perimeter;
    Circularity = Props.Circularity;
    Centroid = round(Props.Centroid);
    CentroidX = Centroid(1);
    CentroidY = Centroid(2);
    BoundingBox = Props.BoundingBox;
end

end

function Summary = summarizeMorphology(AreaAll,FilledAreaAll,DiameterAll,PerimeterAll,CircularityAll, ...
    CentroidXAll,CentroidYAll,BoundingBoxAll,OverallLogical,pixelSize,boundingBoxSummaryRow)

NumRegions = size(AreaAll,1);
Summary.MeanArea_um = nan(NumRegions,1);
Summary.MeanFilledArea_um = nan(NumRegions,1);
Summary.MeanDiameter_um = nan(NumRegions,1);
Summary.MeanPerimeter_um = nan(NumRegions,1);
Summary.MeanCircularity = nan(NumRegions,1);
Summary.MeanCentroid_x = nan(NumRegions,1);
Summary.MeanCentroid_y = nan(NumRegions,1);
Summary.MeanBoundingBox = cell(NumRegions,1);

for RegionIdx = 1:NumRegions
    Summary.MeanArea_um(RegionIdx) = mean(cell2mat(AreaAll(RegionIdx,OverallLogical(RegionIdx,:)))) * pixelSize^2;
    Summary.MeanFilledArea_um(RegionIdx) = mean(cell2mat(FilledAreaAll(RegionIdx,OverallLogical(RegionIdx,:)))) * pixelSize^2;
    Summary.MeanDiameter_um(RegionIdx) = mean(cell2mat(DiameterAll(RegionIdx,OverallLogical(RegionIdx,:)))) * pixelSize;
    Summary.MeanPerimeter_um(RegionIdx) = mean(cell2mat(PerimeterAll(RegionIdx,OverallLogical(RegionIdx,:)))) * pixelSize;
    Summary.MeanCircularity(RegionIdx) = mean(cell2mat(CircularityAll(RegionIdx,OverallLogical(RegionIdx,:))));
    Summary.MeanCentroid_x(RegionIdx) = mean(cell2mat(CentroidXAll(RegionIdx,OverallLogical(RegionIdx,:))));
    Summary.MeanCentroid_y(RegionIdx) = mean(cell2mat(CentroidYAll(RegionIdx,OverallLogical(RegionIdx,:))));

    BoxRowIdx = RegionIdx;
    if strcmpi(boundingBoxSummaryRow,'first')
        BoxRowIdx = 1;
    end
    Summary.MeanBoundingBox{RegionIdx} = mean(vertcat(BoundingBoxAll{BoxRowIdx,OverallLogical(BoxRowIdx,:)}),1);
    Summary.MeanBoundingBox{RegionIdx} = roundBoundingBox(Summary.MeanBoundingBox{RegionIdx});
end

end

function BoundingBox = roundBoundingBox(BoundingBox)

BoundingBox(1) = floor(BoundingBox(1)) + floor((BoundingBox(1) - floor(BoundingBox(1))) / 0.5) * 0.5;
BoundingBox(2) = floor(BoundingBox(2)) + floor((BoundingBox(2) - floor(BoundingBox(2))) / 0.5) * 0.5;
BoundingBox(3) = round(BoundingBox(3));
BoundingBox(4) = round(BoundingBox(4));

end
