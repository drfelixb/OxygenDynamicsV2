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

restricted=isfield(DetectionParams,'restrictToSupport')&&DetectionParams.restrictToSupport;
if restricted
    validateBOIDetectionMask(SupportMask,[size(FrameStack,1),size(FrameStack,2)]);
end
RegionInfoAll = cell(size(FrameStack,3),1);
for FrameIdx = 1:size(FrameStack,3)
    if restricted
        Frame=FrameStack(:,:,FrameIdx);
        Values=transformFrame(Frame(SupportMask),DetectionParams.frameTransform);
        assert(all(isfinite(Values)),'OxygenDynamics:InvalidDetectionInput','Eligible detection values must be finite.');
        BW=false(size(SupportMask));
        BW(SupportMask)=Values>prctile(Values,DetectionParams.percentileThreshold);
    else
        Frame = transformFrame(FrameStack(:,:,FrameIdx),DetectionParams.frameTransform);
        BW = Frame > prctile(Frame(:),DetectionParams.percentileThreshold);
    end
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
