function SurgeSeries = computeOngoingSurgeTimeSeries(SurgeRows,RecDuration)
%COMPUTEONGOINGSURGETIMESERIES Build per-frame surge count, area, and raster traces.

SurgeSeries = struct();
SurgeSeries.Count = zeros(1,RecDuration);
SurgeSeries.AreaNorm = zeros(1,RecDuration);
SurgeSeries.Raster = false(height(SurgeRows),RecDuration);

for SurgeIdx = 1:height(SurgeRows)
    for EventIdx = 1:numel(SurgeRows.Start_Surge{SurgeIdx})
        EventRange = SurgeRows.Start_Surge{SurgeIdx}(EventIdx): ...
            SurgeRows.Start_Surge{SurgeIdx}(EventIdx)+SurgeRows.Duration_Surge{SurgeIdx}(EventIdx)-1;
        SurgePixelCount = numel(SurgeRows.OxySurge_Pxls_all{SurgeIdx});

        SurgeSeries.Count(EventRange) = SurgeSeries.Count(EventRange)+1;
        SurgeSeries.AreaNorm(EventRange) = SurgeSeries.AreaNorm(EventRange)+ ...
            SurgePixelCount/SurgeRows.RecAreaSize_Surge{SurgeIdx};
        SurgeSeries.Raster(SurgeIdx,EventRange) = true;
    end
end

end
