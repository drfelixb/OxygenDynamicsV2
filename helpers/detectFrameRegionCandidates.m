function RegionInfoAll = detectFrameRegionCandidates(FrameStack,SupportMask,DetectionParams)
%DETECTFRAMEREGIONCANDIDATES Detect filtered candidate regions frame by frame.

if ~isfield(DetectionParams,'maxArea') || isempty(DetectionParams.maxArea)
    DetectionParams.maxArea = Inf;
end
if ~isfield(DetectionParams,'forbiddenPixels')
    DetectionParams.forbiddenPixels = [];
end
if ~isfield(DetectionParams,'frameTransform') || isempty(DetectionParams.frameTransform)
    DetectionParams.frameTransform = 'none';
end

RegionInfoAll = cell(size(FrameStack,3),1);
for FrameIdx = 1:size(FrameStack,3)
    Frame = transformFrame(FrameStack(:,:,FrameIdx),DetectionParams.frameTransform);
    BW = Frame > prctile(Frame(:),DetectionParams.percentileThreshold);
    BW = filterRegionCandidates(BW,SupportMask,DetectionParams.minArea,DetectionParams.maxArea, ...
        DetectionParams.minCircularity,DetectionParams.maxOutsideFraction,DetectionParams.forbiddenPixels);
    RegionInfoAll{FrameIdx} = regionprops(BW,'Area','PixelIdxList');
end

end

function Frame = transformFrame(Frame,frameTransform)

switch lower(frameTransform)
    case 'none'
    case 'invert'
        Frame = imcomplement(Frame);
    case 'mat2gray'
        Frame = safeMat2Gray(Frame);
    otherwise
        error('detectFrameRegionCandidates:UnknownTransform', ...
            'Unknown frame transform "%s".',frameTransform);
end

end
