function BinnedTraceCells = computeBehaviourPercentileBins(BehaviourTrace,NumImagingFrames,TraceSources,IsBLI)
%COMPUTEBEHAVIOURPERCENTILEBINS Average trace metrics in behaviour percentiles.

BehaviourResize = reshape(BehaviourTrace,size(BehaviourTrace,1)/NumImagingFrames,[]);
BehaviourMean = mean(BehaviourResize,1);
BinEdges = prctile(BehaviourMean,0:10:100);
BinnedTraceCells = createNanBehaviourPercentileBins(numel(BinEdges)-1);

for BinIdx = 2:numel(BinEdges)
    BinMask = BehaviourMean>BinEdges(BinIdx-1) & BehaviourMean<=BinEdges(BinIdx);

    if IsBLI
        BinnedTraceCells{1}(BinIdx-1) = mean(TraceSources.ROIMean(BinMask));
        BinnedTraceCells{2}(BinIdx-1) = mean(TraceSources.ROICovCoef(BinMask));
        BinnedTraceCells{3}(BinIdx-1) = mean(TraceSources.ROIEntropy(BinMask));
        BinnedTraceCells{9}(BinIdx-1) = mean(TraceSources.ROIDiffMean(BinMask));
        BinnedTraceCells{10}(BinIdx-1) = mean(TraceSources.ROIDiffCovCoef(BinMask));
        BinnedTraceCells{11}(BinIdx-1) = mean(TraceSources.ROIDiffEntropy(BinMask));
    end

    BinnedTraceCells{4}(BinIdx-1) = mean(TraceSources.NumOngoingOxysinks(BinMask));
    BinnedTraceCells{5}(BinIdx-1) = mean(TraceSources.NumOngoingOxysinksPerMm2(BinMask));
    BinnedTraceCells{6}(BinIdx-1) = mean(TraceSources.TotalSinkAreaNorm(BinMask));
    BinnedTraceCells{7}(BinIdx-1) = mean(TraceSources.NumOngoingOxysurges(BinMask));
    BinnedTraceCells{8}(BinIdx-1) = mean(TraceSources.TotalSurgeArea(BinMask));
    BinnedTraceCells{12}(BinIdx-1) = mean(TraceSources.TotalSinkAreaUm(BinMask));
end

end
