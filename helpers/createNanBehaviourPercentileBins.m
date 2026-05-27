function BinnedTraceCells = createNanBehaviourPercentileBins(NumBins)
%CREATENANBEHAVIOURPERCENTILEBINS Create NaN placeholders for bin metrics.

BinnedTraceCells = repmat({nan(1,NumBins)},1,12);

end
