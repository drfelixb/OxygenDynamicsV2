function RecordingArea = computeRecordingArea(IM_Notrend,PixelSize,backgroundPercentile,varargin)
%COMPUTERECORDINGAREA Estimate recorded tissue area from a detrended stack.
%
% Optional name-value inputs:
%   recAreaBinHalfSizeUm      Half-size in um for square spatial bins.
%   recAreaMinCoverageFraction Minimum mask coverage required for a bin.

Parser = inputParser();
Parser.addParameter('recAreaBinHalfSizeUm',[],@(x) isempty(x) || isnumeric(x));
Parser.addParameter('recAreaMinCoverageFraction',0.9,@isnumeric);
Parser.parse(varargin{:});
Options = Parser.Results;

Miu_Notrend = squeeze(mean(mean(IM_Notrend,1),2))';
AboveMean = false(size(IM_Notrend));
for FrameIdx = 1:length(Miu_Notrend)
    AboveMean(:,:,FrameIdx) = IM_Notrend(:,:,FrameIdx) > Miu_Notrend(FrameIdx);
end

CollapsedArea = squeeze(mean(single(AboveMean),3));
Aboveback = CollapsedArea > prctile(CollapsedArea(:),backgroundPercentile);

RecordingArea = struct();
RecordingArea.Mask = Aboveback;
RecordingArea.Filter = Aboveback;
RecordingArea.AreaUm2 = sum(Aboveback(:)) * PixelSize^2;
RecordingArea.Bins = zeros(0,2);
RecordingArea.BinSizePixels = [];

if ~isempty(Options.recAreaBinHalfSizeUm)
    [RecordingArea.Bins,RecordingArea.BinSizePixels] = makeRecordingAreaBins( ...
        Aboveback,PixelSize,Options.recAreaBinHalfSizeUm,Options.recAreaMinCoverageFraction);
end

end

function [RecAreaBins,RecAreaBinSize] = makeRecordingAreaBins(RecordingMask,PixelSize,BinHalfSizeUm,MinCoverageFraction)

RecAreaBinSize = fix(BinHalfSizeUm / PixelSize) * 2;
if RecAreaBinSize < 1
    RecAreaBins = zeros(0,2);
    return
end

AvailableMask = RecordingMask;
RecAreaBins = nan(numel(AvailableMask),2);
Counter = 1;

for RowIdx = 1:size(AvailableMask,1)
    for ColIdx = 1:size(AvailableMask,2)
        RowEnd = RowIdx + RecAreaBinSize - 1;
        ColEnd = ColIdx + RecAreaBinSize - 1;
        if RowEnd <= size(AvailableMask,1) && ColEnd <= size(AvailableMask,2)
            BinMask = AvailableMask(RowIdx:RowEnd,ColIdx:ColEnd);
            if nnz(BinMask) >= (RecAreaBinSize^2) * MinCoverageFraction
                RecAreaBins(Counter,1) = RowIdx;
                RecAreaBins(Counter,2) = ColIdx;
                AvailableMask(RowIdx:RowEnd,ColIdx:ColEnd) = false;
                Counter = Counter + 1;
            end
        end
    end
end

RecAreaBins = RecAreaBins(1:Counter-1,:);

end
