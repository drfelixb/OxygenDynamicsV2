function SinkSeries = computeOngoingSinkTimeSeries(SinkRows,RecDuration,PixelSize)
%COMPUTEONGOINGSINKTIMESERIES Build per-frame sink count, area, and raster traces.

SinkSeries = struct();
SinkSeries.Count = zeros(1,RecDuration);
SinkSeries.AreaNorm = zeros(1,RecDuration);
SinkSeries.AreaUm = zeros(1,RecDuration);
SinkSeries.Raster = false(height(SinkRows),RecDuration);

for SinkIdx = 1:height(SinkRows)
    for EventIdx = 1:numel(SinkRows.Start{SinkIdx})
        EventRange = SinkRows.Start{SinkIdx}(EventIdx): ...
            SinkRows.Start{SinkIdx}(EventIdx)+SinkRows.Duration{SinkIdx}(EventIdx)-1;
        SinkPixelCount = numel(SinkRows.OxySink_Pxls_all{SinkIdx});

        SinkSeries.Count(EventRange) = SinkSeries.Count(EventRange)+1;
        SinkSeries.AreaNorm(EventRange) = SinkSeries.AreaNorm(EventRange)+ ...
            SinkPixelCount/SinkRows.RecAreaSize{SinkIdx};
        SinkSeries.AreaUm(EventRange) = SinkSeries.AreaUm(EventRange)+ ...
            SinkPixelCount*PixelSize^2;
        SinkSeries.Raster(SinkIdx,EventRange) = true;
    end
end

end
