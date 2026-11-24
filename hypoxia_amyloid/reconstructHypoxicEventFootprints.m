function [EventFootprints,TrackedEventPixels] = reconstructHypoxicEventFootprints( ...
    SinkBinaryStack,OxySinkAreaAll,SinkTable)
%RECONSTRUCTHYPOXICEVENTFOOTPRINTS Match tracked sink events to frame pixels.

SinkBinaryStack = logical(SinkBinaryStack);
if ndims(SinkBinaryStack)~=3
    error('HypoxiaAmyloid:InvalidSinkStack', ...
        'SinkBinaryStack must be a height-by-width-by-frame array.');
end
if size(OxySinkAreaAll,1)~=height(SinkTable)
    error('HypoxiaAmyloid:SinkRowMismatch', ...
        'OxySinkAreaAll rows must match SinkTable rows.');
end

FrameRegionInfo = cell(size(SinkBinaryStack,3),1);
for FrameIdx = 1:size(SinkBinaryStack,3)
    FrameRegionInfo{FrameIdx} = regionprops(SinkBinaryStack(:,:,FrameIdx), ...
        'Area','PixelIdxList');
end

TrackedEventPixels = cell(size(OxySinkAreaAll));
for SinkIdx = 1:size(OxySinkAreaAll,1)
    for FrameIdx = 1:min(size(OxySinkAreaAll,2),size(SinkBinaryStack,3))
        if isempty(OxySinkAreaAll{SinkIdx,FrameIdx})
            continue
        end
        TargetArea = OxySinkAreaAll{SinkIdx,FrameIdx};
        SinkPixels = SinkTable.OxySink_Pxls_all{SinkIdx};
        NumActive = nnz(~cellfun(@isempty,OxySinkAreaAll(:,FrameIdx)));
        [TrackedEventPixels{SinkIdx,FrameIdx},FrameRegionInfo{FrameIdx}] = ...
            matchPixels(FrameRegionInfo{FrameIdx},TargetArea,SinkPixels,NumActive);
    end
end

Template = struct('SinkIndex',NaN,'EventIndex',NaN,'StartFrame',NaN, ...
    'EndFrame',NaN,'Frames',[],'PixelIdxList',[],'MeanAreaPixels',NaN, ...
    'CentroidX',NaN,'CentroidY',NaN);
EventFootprints = repmat(Template,0,1);

for SinkIdx = 1:height(SinkTable)
    Active = ~cellfun(@isempty,TrackedEventPixels(SinkIdx,:));
    EventInfo = regionprops(Active,'PixelIdxList');
    ExpectedEvents = SinkTable.NumOxySinkEvents(SinkIdx);
    EventInfo = EventInfo(1:min(numel(EventInfo),ExpectedEvents));
    for EventIdx = 1:numel(EventInfo)
        Frames = EventInfo(EventIdx).PixelIdxList(:)';
        FramePixels = TrackedEventPixels(SinkIdx,Frames);
        Pixels = unique(vertcat(FramePixels{:}));
        Areas = cellfun(@numel,FramePixels);
        [CentroidX,CentroidY] = meanFrameCentroid(FramePixels,size(SinkBinaryStack(:,:,1)));

        Row = Template;
        Row.SinkIndex = SinkIdx;
        Row.EventIndex = EventIdx;
        Row.StartFrame = Frames(1);
        Row.EndFrame = Frames(end);
        Row.Frames = Frames;
        Row.PixelIdxList = Pixels;
        Row.MeanAreaPixels = mean(Areas,'omitnan');
        Row.CentroidX = CentroidX;
        Row.CentroidY = CentroidY;
        EventFootprints(end+1,1) = Row; %#ok<AGROW>
    end
end
end

function [Pixels,FrameRegions] = matchPixels(FrameRegions,TargetArea,SinkPixels,NumActive)

Pixels = [];
if isempty(FrameRegions)
    return
end

Areas = [FrameRegions.Area];
Available = isfinite(Areas);
AreaMatch = find(Available & Areas==TargetArea);
if isscalar(AreaMatch)
    [Pixels,FrameRegions] = claimRegions(FrameRegions,AreaMatch);
    return
end

AvailableIdx = find(Available);
if numel(AvailableIdx)>NumActive && numel(AvailableIdx)>=2
    PairIdx = nchoosek(AvailableIdx,2);
    PairAreas = Areas(PairIdx(:,1))+Areas(PairIdx(:,2));
    PairMatch = find(PairAreas==TargetArea);
    if isscalar(PairMatch)
        [Pixels,FrameRegions] = claimRegions(FrameRegions,PairIdx(PairMatch,:));
        return
    end
end

OverlapCounts = zeros(numel(FrameRegions),1);
for RegionIdx = AvailableIdx(:)'
    OverlapCounts(RegionIdx) = numel(intersect( ...
        FrameRegions(RegionIdx).PixelIdxList,SinkPixels));
end
if any(OverlapCounts>0)
    BestIdx = find(OverlapCounts==max(OverlapCounts),1,'first');
    [Pixels,FrameRegions] = claimRegions(FrameRegions,BestIdx);
end
end

function [Pixels,FrameRegions] = claimRegions(FrameRegions,Indices)

Pixels = vertcat(FrameRegions(Indices).PixelIdxList);
for Idx = Indices(:)'
    FrameRegions(Idx).Area = NaN;
end
end

function [CentroidX,CentroidY] = meanFrameCentroid(FramePixels,FrameSize)

Centroids = nan(numel(FramePixels),2);
for Idx = 1:numel(FramePixels)
    Mask = false(FrameSize);
    Mask(FramePixels{Idx}) = true;
    Props = regionprops(Mask,'Centroid','Area');
    if isempty(Props)
        continue
    end
    Areas = [Props.Area]';
    XY = vertcat(Props.Centroid);
    Centroids(Idx,:) = sum(XY.*Areas,1)/sum(Areas);
end
CentroidX = mean(Centroids(:,1),'omitnan');
CentroidY = mean(Centroids(:,2),'omitnan');
end
