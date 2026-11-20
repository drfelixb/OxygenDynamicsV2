function Mean_ROI_TraceZ = extractSpatialBinTraces(IM_Zframetime,recAreaBins,binSizePx,Mask)
%EXTRACTSPATIALBINTRACES Extract mean z-scored traces from square spatial bins.

restricted=nargin>3;
if restricted,validateBOIDetectionMask(Mask,[size(IM_Zframetime,1),size(IM_Zframetime,2)]);end
Mean_ROI_TraceZ = NaN(size(recAreaBins,1),size(IM_Zframetime,3));
for i = 1:size(recAreaBins,1)
    RowRange = recAreaBins(i,1):(recAreaBins(i,1)+binSizePx-1);
    ColRange = recAreaBins(i,2):(recAreaBins(i,2)+binSizePx-1);
    if restricted
        local=Mask(RowRange,ColRange);
        assert(any(local(:)),'OxygenDynamics:InvalidDetectionSupport','A spatial bin has no included pixels.');
        values=reshape(IM_Zframetime(RowRange,ColRange,:),[],size(IM_Zframetime,3));
        Mean_ROI_TraceZ(i,:)=mean(values(local(:),:),1);
    else
        Mean_ROI_TraceZ(i,:) = squeeze(mean(mean(IM_Zframetime(RowRange,ColRange,:),1),2));
    end
end

end
