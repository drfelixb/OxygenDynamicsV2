function Mean_ROI_TraceZ = extractSpatialBinTraces(IM_Zframetime,recAreaBins,binSizePx)
%EXTRACTSPATIALBINTRACES Extract mean z-scored traces from square spatial bins.

Mean_ROI_TraceZ = NaN(size(recAreaBins,1),size(IM_Zframetime,3));
for i = 1:size(recAreaBins,1)
    RowRange = recAreaBins(i,1):(recAreaBins(i,1)+binSizePx-1);
    ColRange = recAreaBins(i,2):(recAreaBins(i,2)+binSizePx-1);
    Mean_ROI_TraceZ(i,:) = squeeze(mean(mean(IM_Zframetime(RowRange,ColRange,:),1),2));
end

end
